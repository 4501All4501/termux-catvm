#!/usr/bin/env bash

cmd_save() {
  catvm_require_one_arg "save" "$@" || return $?
  local name="$1"
  catvm_validate_name "${name}" || return $?

  local save_file="${CATVM_SAVES_DIR}/${name}.state"
  catvm_persist_state
  cp "${CATVM_STATE_FILE}" "${save_file}"
  printf 'State saved to %s.\n' "${save_file}"
}

cmd_load() {
  catvm_require_one_arg "load" "$@" || return $?
  local name="$1"
  catvm_validate_name "${name}" || return $?

  local save_file="${CATVM_SAVES_DIR}/${name}.state"
  if [[ ! -f "${save_file}" ]]; then
    printf 'Save state not found: %s\n' "${save_file}" >&2
    return 66
  fi

  cp "${save_file}" "${CATVM_STATE_FILE}"
  # shellcheck disable=SC1090
  source "${CATVM_STATE_FILE}"
  printf 'State loaded from %s.\n' "${save_file}"
}

cmd_status() {
  catvm_require_zero_args "status" "$@" || return $?
  printf 'power=%s\n' "${CATVM_POWER}"
  printf 'cpu=%s\n' "${CATVM_CPU}"
  printf 'soundcard=%s\n' "${CATVM_SOUNDCARD}"
  printf 'bios=%s\n' "${CATVM_BIOS}"
  printf 'boot_count=%s\n' "${CATVM_BOOT_COUNT}"
}
