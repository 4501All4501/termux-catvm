#!/usr/bin/env bash

catvm_init_state() {
  if [[ ! -f "${CATVM_STATE_FILE}" ]]; then
    cat > "${CATVM_STATE_FILE}" <<STATE
CATVM_POWER=running
CATVM_CPU=generic-x86_64
CATVM_SOUNDCARD=ac97
CATVM_BIOS=default
CATVM_BOOT_COUNT=1
CATVM_ISO=none
STATE
  fi

  # shellcheck disable=SC1090
  source "${CATVM_STATE_FILE}"

  : "${CATVM_ISO:=none}"
}

catvm_persist_state() {
  {
    printf 'CATVM_POWER=%q\n' "${CATVM_POWER}"
    printf 'CATVM_CPU=%q\n' "${CATVM_CPU}"
    printf 'CATVM_SOUNDCARD=%q\n' "${CATVM_SOUNDCARD}"
    printf 'CATVM_BIOS=%q\n' "${CATVM_BIOS}"
    printf 'CATVM_BOOT_COUNT=%q\n' "${CATVM_BOOT_COUNT}"
    printf 'CATVM_ISO=%q\n' "${CATVM_ISO}"
  } > "${CATVM_STATE_FILE}"
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
    printf 'Usage: %s <arg>\n' "${cmd}" >&2
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
