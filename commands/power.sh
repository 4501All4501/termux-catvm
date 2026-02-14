#!/usr/bin/env bash

cmd_shutdown() {
  catvm_require_zero_args "shutdown" "$@" || return $?
  CATVM_POWER="off"
  catvm_persist_state
  printf 'VM shut down.\n'
}

cmd_reboot() {
  catvm_require_zero_args "reboot" "$@" || return $?
  CATVM_POWER="running"
  CATVM_BOOT_COUNT=$((CATVM_BOOT_COUNT + 1))
  catvm_persist_state
  printf 'VM rebooted (boot count: %s).\n' "${CATVM_BOOT_COUNT}"
}

cmd_sleep() {
  catvm_require_zero_args "sleep" "$@" || return $?
  CATVM_POWER="sleep"
  catvm_persist_state
  printf 'VM is now sleeping.\n'
}

cmd_start() {
  catvm_require_zero_args "start" "$@" || return $?
  if [[ "${CATVM_POWER}" == "running" ]]; then
    printf 'VM is already running.\n'
    return 0
  fi

  CATVM_POWER="running"
  CATVM_BOOT_COUNT=$((CATVM_BOOT_COUNT + 1))
  catvm_persist_state
  printf 'VM started (boot count: %s).\n' "${CATVM_BOOT_COUNT}"
}
