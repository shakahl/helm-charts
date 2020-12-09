#!/usr/bin/env bash

#set -o errexit
#set -o nounset
#set -o pipefail

current_dir=$(dirname "${BASH_SOURCE[0]}")
current_arch=$(uname -m)

default_github_repository="shakahl/helm-charts"
runner_cache_dir="${runner_cache_dir:-$current_dir/.cache}"
path_base="$current_dir:$HOME/.local/bin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin"
chart_testing_version=v3.3.0
chart_testing_cache_dir="$runner_cache_dir/ct/$chart_testing_version/$current_arch"
chart_testing_config_dir="$chart_testing_cache_dir/etc"
chart_testing_bin="$chart_testing_cache_dir/ct"
py_virtualenv_dir=""
chart_testing_paths=""

tool_python3_bin=$(which python3)
tool_pip3_bin=$(which pip3)

export GITHUB_REPOSITORY="${GITHUB_REPOSITORY:-$default_github_repository}"

declare -a chart_testing_args

export color_red=$(tput setaf 1)
export color_green=$(tput setaf 2)
export color_reset=$(tput sgr0)

declare -r TRUE=0
declare -r FALSE=1

################################################################################
# Shows a log message
# Globals: none
# Arguments:
#   severity
#   message
# Outputs:
#   Writes location to stdout
################################################################################
function log() {
  local color_red=$(tput setaf 1)
  local color_green=$(tput setaf 2)
  local color_reset=$(tput sgr0)
  local timestamp=$(date -u "+%Y-%m-%dT%H:%M:%S.000+0000")
  local severity="INFO"
  local message=""
  if [ -z "$2" ]; then
    message="${1:-}"
  else
    severity="${1:-INFO}"
    message="${2:-}"
  fi
  severity=$(echo "$severity" | tr "[:upper:]" "[:lower:]")
  if [ ! -z "$CI" ]; then
    echo "{\"timestamp\":\"$timestamp\",\"level\":\"info\",\"type\":\"startup\",\"detail\":{\"kind\":\"docker-psql-cli\",\"info\":\"$message\"}}"
  else
    echo "$timestamp $severity - $message"
  fi
  return $TRUE
}

################################################################################
# Shows a log message
# Globals: none
# Arguments:
#   ...message
# Outputs:
#   Writes location to stdout
################################################################################
function log() {
  printf "$(date -u "+%Y-%m-%dT%H:%M:%S.000+0000") %b\\n" "${*}" >&2
}

export -f log

################################################################################
# Wait N second and informs about it
# Globals: none
# Arguments:
#   seconds
# Outputs:
#   Writes location to stdout
################################################################################
function wait_info() {
  echo "Sleeping for $1 seconds..."
  sleep $1
  echo "Continue..."
}

################################################################################
# Shows a log message with INFO severity
# Globals: none
# Arguments:
#   message
# Outputs:
#   Writes location to stdout
################################################################################
function info() {
  log "INFO" "${*:2}"
  return $TRUE
}
export -f info

################################################################################
# Shows a log message with INFO severity
# Globals: none
# Arguments:
#   message
# Outputs:
#   Writes location to stdout
################################################################################
function show_info() {
  info "$@"
  return $TRUE
}
export -f show_info

################################################################################
# Shows a log message with ERROR severity
# Globals: none
# Arguments:
#   message
#   exit code
# Outputs:
#   Writes location to stdout
################################################################################
function error() {
  log "ERROR" "${*:2}"
  return $TRUE
}
export -f error

################################################################################
# Shows a log message with ERROR severity
# Globals: none
# Arguments:
#   message
#   exit code
# Outputs:
#   Writes location to stdout
################################################################################
function show_error() {
  error "$@"
  return $TRUE
}
export -f show_error

################################################################################
# Shows a log message with ERROR severity
# Globals: none
# Arguments:
#   message
#   exit code
# Outputs:
#   Writes location to stdout
################################################################################
function die() {
  error "${*}"
  exit 1
}
export -f die

function script_die() {
  echo "${@}" >&2
  exit 1
}
export -f script_die

################################################################################
# Executes a command and informs the user about it
# Globals: none
# Arguments:
#   ...args
# Outputs:
#   Writes location to stdout
################################################################################
function exec_logged_cmd() {
  log 'INFO' "Executing: ${*}"
  /bin/bash -c "${*}"
}
export -f exec_logged_cmd

################################################################################
# Shows a line with # character
# Globals: none
# Arguments:
#   width
# Outputs:
#   Writes location to stdout
################################################################################
function print_hash_line() {
  for ((x = 0; x < "${1:-20}"; x++)); do
    printf '%s' '#'
  done
  echo
}
export -f print_hash_line

################################################################################
# Shows a line with - character
# Globals: none
# Arguments:
#   width
# Outputs:
#   Writes location to stdout
################################################################################
function print_dash_line() {
  for ((x = 0; x < "${1:-20}"; x++)); do
    printf '%s' '-'
  done
  echo
}
export -f print_dash_line

################################################################################
# Shows a DEBUG start message
# Globals: none
# Arguments: none
# Outputs:
#   Writes location to stdout
################################################################################
function print_debug_start() {
  print_hash_line
  echo " DEBUG"
  print_hash_line
}
export -f print_debug_start

################################################################################
# Shows a DEBUG end message
# Globals: none
# Arguments: none
# Outputs:
#   Writes location to stdout
################################################################################
function print_debug_end() {
  print_hash_line
}
export -f print_debug_end

##################################################################
# Converts a string to lower case
# Arguments:
#   input string
# Outputs:
#   Writes location to stdout
##################################################################
function to_lower() {
  local str="$@"
  local output
  output=$(tr '[A-Z]' '[a-z]' <<<"${str}")
  echo $output
}
export -f to_lower
readonly -f to_lower

##################################################################
# Display an error message and die
# Arguments:
#   message
#   exit status (optional)
# Outputs:
#   Writes location to stdout
##################################################################
function die() {
  local m="$1"   # message
  local e=${2-1} # default exit status 1
  echo "$m"
  exit $e
}
export -f die
readonly -f die

##################################################################
# Return true if script is executed by the root user
# Arguments: none
# Return
#   True or False
##################################################################
function is_root() {
  [ $(id -u) -eq 0 ] && return $TRUE || return $FALSE
}
export -f is_root
readonly -f is_root

##################################################################
# Return true $user exits in /etc/passwd
# Arguments:
#   username - username to check in /etc/passwd
# Return:
#   True or False
##################################################################
function is_user_exits() {
  local u="$1"
  grep -q "^${u}" $PASSWD_FILE && return $TRUE || return $FALSE
}
export -f is_user_exits
readonly -f is_user_exits

##################################################################
# Return true if the argument command does exists
# Arguments:
#   command to test
# Return:
#   True or False
##################################################################
function command_exists() {
  command -v "$@" >/dev/null 2>&1
}
export -f command_exists
readonly -f command_exists

##################################################################
# Return true if DRY_RUN is set
# Arguments:
#   -
# Return:
#   True or False
##################################################################
function is_dry_run() {
  if [ -z "$DRY_RUN" ]; then
    return 1
  else
    return 0
  fi
}
export -f is_dry_run
readonly -f is_dry_run

##################################################################
# Return true if the shell is under WSL
# Arguments:
#   -
# Return:
#   True or False
##################################################################
function is_wsl() {
  case "$(uname -r)" in
  *microsoft*) true ;; # WSL 2
  *Microsoft*) true ;; # WSL 1
  *) false ;;
  esac
}
export -f is_wsl
readonly -f is_wsl

##################################################################
# Return true if platform is darwin
# Arguments:
#   -
# Return:
#   True or False
##################################################################
function is_darwin() {
  case "$(uname -s)" in
  *darwin*) true ;;
  *Darwin*) true ;;
  *) false ;;
  esac
}
export -f is_darwin
readonly -f is_darwin

##################################################################
# Return the name of the OS distribution
# Arguments:
#   -
# Return:
#   distribution name
##################################################################
function get_distribution() {
  lsb_dist=""
  # Every system that we officially support has /etc/os-release
  if [ -r /etc/os-release ]; then
    lsb_dist="$(. /etc/os-release && echo "$ID")"
  fi
  # Returning an empty string here should be alright since the
  # case statements don't act unless you provide an actual value
  lsb_dist="$(echo "$lsb_dist" | tr '[:upper:]' '[:lower:]')"
  echo "$lsb_dist"
}
export -f get_distribution
readonly -f get_distribution

##################################################################
# Return the name of the OS architecture
# Arguments:
#   -
# Return:
#   architecture name
##################################################################
function get_arch() {
  arch=$(uname -m)
  echo "$arch"
}
export -f get_arch
readonly -f get_arch

##################################################################
# SCRIPT: show_help
# Arguments:
#   -
# Return:
#   -
##################################################################
show_help() {
  cat <<EOF
Usage: $(basename "$0") <options>
    -h, --help          Display help
    -v, --version       The chart-testing version to use (default: $chart_testing_version)"
EOF
}

##################################################################
# SCRIPT: main
# Arguments:
#   -
# Return:
#   -
##################################################################
main() {
  local main_args
  local version="$chart_testing_version"

  main_args="$@"
  parse_command_line "$@"
  install_chart_testing "$@"
  run_chart_testing "$@"

}

##################################################################
# SCRIPT: setup_environment
# Arguments:
#   -
# Return:
#   -
##################################################################
setup_environment() {
  local fnargs
  fnargs="$@"

  if [[ -n "${GITHUB_REPOSITORY}" ]]; then
    owner=$(cut -d '/' -f 1 <<<"$GITHUB_REPOSITORY")
    repo=$(cut -d '/' -f 2 <<<"$GITHUB_REPOSITORY")
    args=(--owner "$owner" --repo "$repo")

    if [[ -n "${inputs_charts_dir:-''}" ]]; then
      args+=(--charts-dir "${inputs_charts_dir}")
    fi
    if [[ -n "${inputs_version:-''}" ]]; then
      args+=(--version "${inputs_version}")
    fi
    if [[ -n "${inputs_config:-''}" ]]; then
      args+=(--config "${inputs_config}")
    fi
    if [[ -n "${inputs_charts_repo_url:-''}" ]]; then
      args+=(--charts-repo-url "${inputs_charts_repo_url}")
    fi

    chart_testing_args=(${args[@]})
  fi

  # "$GITHUB_ACTION_PATH/cr.sh" "${args[@]}"
}

##################################################################
# SCRIPT: print_env
# Arguments:
#   -
# Return:
#   -
##################################################################
print_env() {
  echo ""
  echo "# GitHub environment"
  echo "# --------------------------------------------------------------------------------"
  echo $(env | grep ^GITHUB_ --color=never)
  echo "# --------------------------------------------------------------------------------"
  echo ""
  echo "# ct environment"
  echo "# --------------------------------------------------------------------------------"
  echo "chart_testing_version=\"$chart_testing_version\""
  echo "runner_cache_dir=\"$current_dir/.cache\""
  echo "chart_testing_cache_dir=\"$runner_cache_dir/ct/$chart_testing_version/$current_arch\""
  echo "chart_testing_config_dir=\"$chart_testing_cache_dir/etc\""
  echo "chart_testing_bin=\"$chart_testing_cache_dir/ct\""
  echo "chart_testing_paths=\"$chart_testing_paths\""
  echo "py_virtualenv_dir=\"$py_virtualenv_dir\""
  echo "# --------------------------------------------------------------------------------"
  echo ""
}

##################################################################
# SCRIPT: run_chart_testing
# Arguments:
#   -
# Return:
#   -
##################################################################
run_chart_testing() {
  local curarg
  curarg="$1"
  while :; do
    case "${1:-}" in
    lint)
      chart_testing_args+=(lint --all)
      shift
      ;;
    env)
      print_env "$@"
      exit 1
      ;;
    *)
      chart_testing_args+=(${@})
      break
      ;;
    esac
    shift
  done

  echo "# Using binary: ${chart_testing_bin}"
  echo "# Using arguments: ${chart_testing_args[@]}"
  echo "# Executing: ${chart_testing_bin} ${chart_testing_args[@]}"

  "${chart_testing_bin}" "${chart_testing_args[@]}"
  exit 0
}

##################################################################
# SCRIPT: parse_command_line
# Arguments:
#   -
# Return:
#   -
##################################################################
parse_command_line() {
  local curarg
  #curarg="${1:-}"
  #[ -n "$1" ] && curarg="${1:-}" || break
  while :; do
    [ -n "$1" ] && curarg="${1:-}" || break
    case "${1:-}" in
    -h | --help)
      show_help
      exit
      ;;
    -v | --version)
      if [[ -n "${2:-}" ]]; then
        version="$2"
        shift
      else
        echo "ERROR: '-v|--version' cannot be empty." >&2
        show_help
        exit 1
      fi
      ;;
    *)
      break
      ;;
    esac
    shift
    curarg="$1"
  done
}

##################################################################
# Checks if multiple commands are exists
# Arguments:
#   command1
#   ...
#   commandN
# Return:
#   True or False
##################################################################
err_check_command_msg=""
export err_check_command_msg

check_command() {
  local cmd_arr
  local cmd_to_check
  local fn_ret
  cmd_arr=("$@")
  cmd_to_check="$1"
  fn_ret=0
  export err_check_command_msg=""
  for cmd_item in "${cmd_arr[@]}"; do
    #if ! command -v $cmd_item &>/dev/null; then
    if ! command -v $cmd_item; then
      err_check_command_msg="Command \"$cmd_item\" does not exists in path!"
      fn_ret=1
      break
    fi
  done
  return $fn_ret
}
export -f check_command

##################################################################
# SCRIPT: install_chart_testing
# Arguments:
#   -
# Return:
#   -
##################################################################
install_chart_testing() {

  if [[ ! -d "$runner_cache_dir" ]]; then
    mkdir -p "$runner_cache_dir"
  fi

  if [[ ! -d "$runner_cache_dir" ]]; then
    echo "Cache directory '$runner_cache_dir' does not exist" >&2
    exit 1
  fi

  # Check tools
  tool_ok_all=$(check_command "dsfdfd" "curl tar $tool_python3_bin $tool_pip3_bin")
  [[ $tool_ok_all == $TRUE ]] || error "Missing tool: $err_check_command_msg"

  # if ! command -v $tool_python3_bin &>/dev/null; then
  #   echo "Python3 binary does not exists in PATH ..." && exit 1
  # fi
  # if ! command -v $tool_pip3_bin &>/dev/null; then
  #   echo "Python PIP 3 binary does not exists in PATH ..." && exit 1
  # fi

  local path_prepend
  local arch
  arch=$(uname -m)
  local cache_dir="$runner_cache_dir/ct/$version/${current_arch:-$arch}"
  local venv_dir="$cache_dir/venv"

  path_prepend="$path_base"

  if [[ ! -d "$cache_dir" ]]; then
    mkdir -p "$cache_dir"

    echo "# Installing chart-testing..."
    curl -sSLo "$cache_dir/ct.tar.gz" "https://github.com/helm/chart-testing/releases/download/$version/chart-testing_${version#v}_linux_amd64.tar.gz"
    tar -xzf "$cache_dir/ct.tar.gz" -C "$cache_dir"
    rm -f "$cache_dir/ct.tar.gz"

    echo '# Creating virtual Python environment...'
    "$tool_python3_bin" -m venv "$venv_dir"

    echo '# Activating virtual environment...'
    # shellcheck disable=SC1090
    source "$venv_dir/bin/activate"

    echo '# Installing yamllint...'
    "$tool_pip3_bin" install yamllint==1.25.0

    echo '# Installing Yamale...'
    "$tool_pip3_bin" install yamale==3.0.4
  fi

  # https://github.com/helm/chart-testing-action/issues/62
  path_prepend="$venv_dir/bin:$cache_dir:$path_prepend"
  py_virtualenv_dir="$venv_dir"
  chart_testing_cache_dir="$cache_dir"
  chart_testing_bin="$cache_dir/ct"
  chart_testing_config_dir="$cache_dir/etc"
  chart_testing_paths="$path_prepend"

  PATH="$path_prepend:$PATH" && echo "# PATH environment variable is modified ..."

  "$chart_testing_bin" version | sed -e "s/.*/# &/"
}

main "$@"
