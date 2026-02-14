#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CATVM_HOME="${CATVM_HOME:-${SCRIPT_DIR}/runtime}"
CATVM_STATE_FILE="${CATVM_STATE_FILE:-${CATVM_HOME}/catvm.state}"
CATVM_SAVES_DIR="${CATVM_SAVES_DIR:-${CATVM_HOME}/saves}"

mkdir -p "${CATVM_HOME}" "${CATVM_SAVES_DIR}"

# shellcheck disable=SC1091
source "${SCRIPT_DIR}/commands/common.sh"
# shellcheck disable=SC1091
source "${SCRIPT_DIR}/commands/power.sh"
# shellcheck disable=SC1091
source "${SCRIPT_DIR}/commands/hardware.sh"
# shellcheck disable=SC1091
source "${SCRIPT_DIR}/commands/state.sh"
# shellcheck disable=SC1091
source "${SCRIPT_DIR}/commands/meta.sh"

catvm_init_state

catvm_parse_and_execute() {
  local cmd="$1"
  shift || true

  case "${cmd}" in
    shutdown)
      cmd_shutdown "$@"
      ;;
    reboot)
      cmd_reboot "$@"
      ;;
    sleep)
      cmd_sleep "$@"
      ;;
    start)
      cmd_start "$@"
      ;;
    cpu)
      cmd_cpu "$@"
      ;;
    soundcard)
      cmd_soundcard "$@"
      ;;
    bios)
      cmd_bios "$@"
      ;;
    save)
      cmd_save "$@"
      ;;
    load)
      cmd_load "$@"
      ;;
    status)
      cmd_status "$@"
      ;;
    help)
      cmd_help
      ;;
    quit|exit)
      return 130
      ;;
    "")
      return 0
      ;;
    *)
      printf 'Unknown command: %s\n' "${cmd}" >&2
      cmd_help >&2
      return 2
      ;;
  esac
}

catvm_run_line() {
  local line="$1"
  local -a parts=()

  read -r -a parts <<< "${line}"
  if ((${#parts[@]} == 0)); then
    return 0
  fi

  catvm_parse_and_execute "${parts[@]}"
}

catvm_repl() {
  local line
  while true; do
    printf 'catvm> '
    if ! IFS= read -r line; then
      printf '\n'
      break
    fi

    if ! catvm_run_line "${line}"; then
      local rc=$?
      if ((rc == 130)); then
        break
      fi
      printf 'error: command failed with exit code %s\n' "${rc}" >&2
    fi
  done
}

main() {
  if (($# == 0)); then
    catvm_repl
    return 0
  fi

  catvm_parse_and_execute "$@"
}

main "$@"
