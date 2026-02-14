#!/usr/bin/env bash

cmd_cpu() {
  catvm_require_one_arg "cpu" "$@" || return $?
  catvm_validate_name "$1" || return $?
  CATVM_CPU="$1"
  catvm_persist_state
  printf 'CPU set to %s.\n' "${CATVM_CPU}"
}

cmd_soundcard() {
  catvm_require_one_arg "soundcard" "$@" || return $?
  catvm_validate_name "$1" || return $?
  CATVM_SOUNDCARD="$1"
  catvm_persist_state
  printf 'Soundcard set to %s.\n' "${CATVM_SOUNDCARD}"
}

cmd_bios() {
  catvm_require_one_arg "bios" "$@" || return $?
  catvm_validate_name "$1" || return $?
  CATVM_BIOS="$1"
  catvm_persist_state
  printf 'BIOS set to %s.\n' "${CATVM_BIOS}"
}
