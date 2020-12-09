#!/usr/bin/env bash

set -o errexit
#set -o nounset
set -o pipefail

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

show_help() {
  cat <<EOF
Usage: $(basename "$0") <options>
    -h, --help          Display help
    -v, --version       The chart-testing version to use (default: $chart_testing_version)"
EOF
}

main() {
  local main_args
  local version="$chart_testing_version"

  main_args="$@"
  parse_command_line "$@"
  install_chart_testing "$@"
  run_chart_testing "$@"

}

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

install_chart_testing() {

  if [[ ! -d "$runner_cache_dir" ]]; then
    mkdir -p "$runner_cache_dir"
  fi

  if [[ ! -d "$runner_cache_dir" ]]; then
    echo "Cache directory '$runner_cache_dir' does not exist" >&2
    exit 1
  fi

  # Check tools
  if ! command -v $tool_python3_bin &>/dev/null; then
    echo "Python3 binary does not exists in PATH ..." && exit 1
  fi
  if ! command -v $tool_pip3_bin &>/dev/null; then
    echo "Python PIP 3 binary does not exists in PATH ..." && exit 1
  fi

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
