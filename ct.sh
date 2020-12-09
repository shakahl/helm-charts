#!/usr/bin/env bash

set -o errexit
#set -o nounset
set -o pipefail

CURRENT_DIR=$(dirname "${BASH_SOURCE[0]}")
CURRENT_ARCH=$(uname -m)

DEFAULT_CHART_TESTING_VERSION=v3.3.0
DEFAULT_RUNNER_TOOL_CACHE="$CURRENT_DIR/.cache"
RUNNER_TOOL_CACHE="${RUNNER_TOOL_CACHE:-$DEFAULT_RUNNER_TOOL_CACHE}"
CACHE_DIR="$RUNNER_TOOL_CACHE/ct/$DEFAULT_CHART_TESTING_VERSION/$CURRENT_ARCH"
CT_CONFIG_DIR="$CACHE_DIR/etc"
CT_BIN="$CACHE_DIR/ct"
VIRTUAL_ENV=""
CT_ADD_PATH=""

declare -a CT_BIN_EXTRA_ARGS=("$CT_BIN")

show_help() {
  cat <<EOF
Usage: $(basename "$0") <options>
    -h, --help          Display help
    -v, --version       The chart-testing version to use (default: $DEFAULT_CHART_TESTING_VERSION)"
EOF
}

main() {
  local main_args
  local version="$DEFAULT_CHART_TESTING_VERSION"

  main_args="$@"
  parse_command_line "$@"
  install_chart_testing "$@"
  run_ct "$@"

}

print_env() {
  echo ""
  echo "# ct environment"
  echo "# --------------------------------------------------------------------------------"
  echo "DEFAULT_CHART_TESTING_VERSION=$DEFAULT_CHART_TESTING_VERSION"
  echo "DEFAULT_RUNNER_TOOL_CACHE=\"$CURRENT_DIR/.cache\""
  echo "RUNNER_TOOL_CACHE=\"${RUNNER_TOOL_CACHE:-$DEFAULT_RUNNER_TOOL_CACHE}\""
  echo "CACHE_DIR=\"$RUNNER_TOOL_CACHE/ct/$DEFAULT_CHART_TESTING_VERSION/$CURRENT_ARCH\""
  echo "CT_CONFIG_DIR=\"$CACHE_DIR/etc\""
  echo "CT_BIN=\"$CACHE_DIR/ct\""
  echo "VIRTUAL_ENV=\"$VIRTUAL_ENV\""
  echo "CT_ADD_PATH=\"$CT_ADD_PATH:\$PATH\""
  echo "PATH=\"$CT_ADD_PATH:$PATH\""
  echo "# --------------------------------------------------------------------------------"
  echo ""
}

run_ct() {
  local curarg
  curarg="$1"
  while :; do
    case "${1:-}" in
    lint)
      CT_BIN_EXTRA_ARGS=(${CT_BIN_EXTRA_ARGS[@]} "lint" "--all")
      shift
      ;;
    env)
      print_env "$@"
      exit 1
      ;;
    *)
      CT_BIN_EXTRA_ARGS=(${CT_BIN_EXTRA_ARGS[@]} "$@")
      break
      ;;
    esac
    shift

    #[ -n "$@" ] && curarg2=(${CT_BIN_EXTRA_ARGS[@]} "$@") || break

  done

  echo "CT_BIN_EXTRA_ARGS=\"${CT_BIN_EXTRA_ARGS[@]}\""

  "${CT_BIN_EXTRA_ARGS[@]}"
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

  if [[ ! -d "$RUNNER_TOOL_CACHE" ]]; then
    mkdir -p "$RUNNER_TOOL_CACHE"
  fi

  if [[ ! -d "$RUNNER_TOOL_CACHE" ]]; then
    echo "Cache directory '$RUNNER_TOOL_CACHE' does not exist" >&2
    exit 1
  fi

  local arch
  arch=$(uname -m)
  local cache_dir="$RUNNER_TOOL_CACHE/ct/$version/${CURRENT_ARCH:-$arch}"
  local venv_dir="$cache_dir/venv"

  if [[ ! -d "$cache_dir" ]]; then
    mkdir -p "$cache_dir"

    echo "# Installing chart-testing..."
    curl -sSLo ct.tar.gz "https://github.com/helm/chart-testing/releases/download/$version/chart-testing_${version#v}_linux_amd64.tar.gz"
    tar -xzf ct.tar.gz -C "$cache_dir"
    rm -f ct.tar.gz

    echo '# Creating virtual Python environment...'
    python3 -m venv "$venv_dir"

    echo '# Activating virtual environment...'
    # shellcheck disable=SC1090
    source "$venv_dir/bin/activate"

    echo '# Installing yamllint...'
    pip3 install yamllint==1.25.0

    echo '# Installing Yamale...'
    pip3 install yamale==3.0.4
  fi

  # https://github.com/helm/chart-testing-action/issues/62
  echo '# Adding ct directory to PATH...'
  CT_ADD_PATH="$cache_dir"
  PATH="$CT_ADD_PATH:$PATH"

  echo '# Setting CT_CONFIG_DIR...'
  CT_CONFIG_DIR="$cache_dir/etc"

  echo '# Configuring environment variables for virtual environment for subsequent workflow steps...'
  VIRTUAL_ENV="$venv_dir"
  CT_ADD_PATH="$venv_dir/bin:$CT_ADD_PATH"
  CT_BIN="$cache_dir/ct"

  PATH="$CT_ADD_PATH:$PATH"

  "$cache_dir/ct" version | sed -e "s/.*/# &/"

  CT_BIN="$cache_dir/ct"
}

main "$@"
