# termux-catvm

Minimal shell runtime for CatVM command parsing and state management.

## Entrypoints

- `./catvm.sh` — main command parser (single-command mode and interactive mode).
- `./catvm-change-bios` — convenience wrapper for changing BIOS profile.

## Command examples

```bash
./catvm.sh status
./catvm.sh cpu qemu64
./catvm.sh soundcard sb16
./catvm.sh save baseline
./catvm.sh reboot
./catvm.sh shutdown
./catvm.sh load-from-file ./runtime/isos/installer.iso
./catvm.sh load-from-folder ./runtime/isos
./catvm-change-bios uefi
```

Run without arguments for interactive mode:

```bash
./catvm.sh
```

## Command reference

- `shutdown`
- `reboot`
- `sleep`
- `start`
- `cpu <name>`
- `soundcard <name>`
- `bios <name>`
- `save <name>`
- `load <name>`
- `load-from-file <path>`
- `load-from-folder <dir>`
- `status`
- `help`

`load-from-file` and `load-from-folder` are for ISO media loading (not state snapshot loading).
