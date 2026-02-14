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

cmd_load_from_file() {
  catvm_require_one_arg "load-from-file" "$@" || return $?
  local state_file="$1"

  if [[ ! -f "${state_file}" ]]; then
    printf 'State file not found: %s\n' "${state_file}" >&2
    return 66
  fi

  cp "${state_file}" "${CATVM_STATE_FILE}"
  # shellcheck disable=SC1090
  source "${CATVM_STATE_FILE}"
  printf 'State loaded from file: %s.\n' "${state_file}"
}

cmd_load_from_folder() {
  catvm_require_one_arg "load-from-folder" "$@" || return $?
  local folder="$1"

  if [[ ! -d "${folder}" ]]; then
    printf 'Folder not found: %s\n' "${folder}" >&2
    return 66
  fi

  local state_file=""

  if [[ -f "${folder}/catvm.state" ]]; then
    state_file="${folder}/catvm.state"
  else
    state_file="$(find "${folder}" -maxdepth 1 -type f -name '*.state' | LC_ALL=C sort | head -n 1)"
  fi

  if [[ -z "${state_file}" ]]; then
    printf 'No state file found in folder: %s\n' "${folder}" >&2
    return 66
  fi

  cmd_load_from_file "${state_file}"
}
