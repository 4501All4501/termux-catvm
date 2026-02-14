#!/usr/bin/env bash

cmd_help() {
  cat <<'HELP'
catvm command reference:
  shutdown             Power off the VM
  reboot               Restart the VM and increment boot count
  sleep                Put VM into sleep state
  start                Start VM from off/sleep state
  cpu <name>           Set CPU model name
  soundcard <name>     Set soundcard device name
  bios <name>          Set BIOS profile name
  save <name>          Save runtime state snapshot
  load <name>          Load runtime state snapshot
  load-from-file <path> Load VM state directly from a state file
  load-from-folder <dir> Load VM state from catvm.state or first *.state in a folder
  status               Show current VM state
  help                 Show this help text
  quit | exit          Exit interactive mode
HELP
}
