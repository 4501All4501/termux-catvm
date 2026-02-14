# Runtime data directory

`catvm.sh` persists VM state here at runtime:

- `catvm.state`: current VM state file (created on first run)
- `saves/*.state`: named snapshots created by `save <name>`

These files are generated locally and are not required to be committed.
