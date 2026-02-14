# Command Matrix

This document is the canonical, reviewable list of supported CLI commands in this repository.
Each command must map to a concrete implementation function (`file::function`) and include deterministic behavior notes.

## Supported commands

| Command | Input format | Implementation (`file::function`) | Side effects | Deterministic expected behavior | Error cases |
| --- | --- | --- | --- | --- | --- |
| `scripts/check-commands.sh validate` | No positional arguments. Optional `--matrix <path>`. | `scripts/check-commands.sh::cmd_validate` | Reads matrix markdown and implementation files. No writes. | Parses rows in this table, verifies every implementation file exists, verifies implementation functions exist, and fails if function body looks like a placeholder (`TODO`, `placeholder`, `stub`, `TBD`). Exits `0` on success. | Exits non-zero for malformed matrix rows, missing files/functions, placeholder markers, unknown options, or unreadable matrix path. |
| `scripts/check-commands.sh list` | No positional arguments. Optional `--matrix <path>`. | `scripts/check-commands.sh::cmd_list` | Reads matrix markdown only. No writes. | Prints command names from this table (first column) in row order, one per line. Exits `0` on success. | Exits non-zero for unknown options, malformed matrix rows, or unreadable matrix path. |

## Review checklist

- Every row uses `file::function` and points to a real implementation.
- Expected behavior statements are deterministic and testable by static review.
- Error cases are explicit and non-ambiguous.
- `scripts/check-commands.sh validate` passes.
