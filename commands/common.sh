#!/usr/bin/env bash

catvm_init_state() {
  if [[ ! -f "${CATVM_STATE_FILE}" ]]; then
    cat > "${CATVM_STATE_FILE}" <<STATE
CATVM_POWER=running
CATVM_CPU=generic-x86_64
CATVM_SOUNDCARD=ac97
CATVM_BIOS=default
CATVM_BOOT_COUNT=1
STATE
  fi

  # shellcheck disable=SC1090
  source "${CATVM_STATE_FILE}"
}

catvm_persist_state() {
  cat > "${CATVM_STATE_FILE}" <<STATE
CATVM_POWER=${CATVM_POWER}
CATVM_CPU=${CATVM_CPU}
CATVM_SOUNDCARD=${CATVM_SOUNDCARD}
CATVM_BIOS=${CATVM_BIOS}
CATVM_BOOT_COUNT=${CATVM_BOOT_COUNT}
STATE
}

catvm_require_zero_args() {
  local cmd="$1"
  shift
  if (($# != 0)); then
    printf '%s does not accept additional arguments\n' "${cmd}" >&2
    return 64
  fi
}

catvm_require_one_arg() {
  local cmd="$1"
  shift
  if (($# != 1)); then
    printf 'Usage: %s <name>\n' "${cmd}" >&2
    return 64
  fi
}

catvm_validate_name() {
  local value="$1"
  if [[ ! "${value}" =~ ^[A-Za-z0-9._-]+$ ]]; then
    printf 'Invalid value "%s". Allowed characters: letters, numbers, dot, underscore, hyphen.\n' "${value}" >&2
    return 65
  fi
}
