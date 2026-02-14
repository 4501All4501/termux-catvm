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
  : "${CATVM_ISO:=none}"
  printf 'State loaded from %s.\n' "${save_file}"
}

cmd_status() {
  catvm_require_zero_args "status" "$@" || return $?
  printf 'power=%s\n' "${CATVM_POWER}"
  printf 'cpu=%s\n' "${CATVM_CPU}"
  printf 'soundcard=%s\n' "${CATVM_SOUNDCARD}"
  printf 'bios=%s\n' "${CATVM_BIOS}"
  printf 'boot_count=%s\n' "${CATVM_BOOT_COUNT}"
  printf 'iso=%s\n' "${CATVM_ISO}"
}

cmd_load_from_file() {
  catvm_require_one_arg "load-from-file" "$@" || return $?
  local iso_file="$1"

  if [[ ! -f "${iso_file}" ]]; then
    printf 'ISO file not found: %s\n' "${iso_file}" >&2
    return 66
  fi

  if [[ ! "${iso_file}" =~ \.([iI][sS][oO])$ ]]; then
    printf 'Invalid file type for load-from-file: %s (expected .iso)\n' "${iso_file}" >&2
    return 65
  fi

  local iso_abs_path=""
  iso_abs_path="$(catvm_abs_path "${iso_file}")" || {
    printf 'Failed to resolve ISO path: %s\n' "${iso_file}" >&2
    return 70
  }

  CATVM_ISO="${iso_abs_path}"
  catvm_persist_state
  printf 'ISO loaded from file: %s.\n' "${iso_abs_path}"
}

cmd_load_from_folder() {
  catvm_require_one_arg "load-from-folder" "$@" || return $?
  local folder="$1"

  if [[ ! -d "${folder}" ]]; then
    printf 'Folder not found: %s\n' "${folder}" >&2
    return 66
  fi

  local iso_file=""

  if [[ -f "${folder}/catvm.iso" ]]; then
    iso_file="${folder}/catvm.iso"
  elif [[ -f "${folder}/CATVM.ISO" ]]; then
    iso_file="${folder}/CATVM.ISO"
  else
    iso_file="$(find "${folder}" -maxdepth 1 -type f -iname '*.iso' | LC_ALL=C sort | head -n 1)"
  fi

  if [[ -z "${iso_file}" ]]; then
    printf 'No ISO file found in folder: %s\n' "${folder}" >&2
    return 66
  fi

  cmd_load_from_file "${iso_file}"
}
