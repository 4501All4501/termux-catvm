#!/usr/bin/env bash
set -euo pipefail

MATRIX_PATH="docs/COMMAND_MATRIX.md"

usage() {
  cat <<'USAGE'
Usage:
  scripts/check-commands.sh validate [--matrix <path>]
  scripts/check-commands.sh list [--matrix <path>]
USAGE
}

parse_matrix_rows() {
  local matrix_path="$1"

  if [[ ! -r "$matrix_path" ]]; then
    echo "error: matrix file is not readable: $matrix_path" >&2
    return 1
  fi

  awk '
    /^\| `/ {
      line=$0
      gsub(/^\|[[:space:]]*/, "", line)
      gsub(/[[:space:]]*\|[[:space:]]*$/, "", line)
      n=split(line, cols, /[[:space:]]*\|[[:space:]]*/)
      if (n < 6) {
        printf("error: malformed matrix row (expected >= 6 columns): %s\n", $0) > "/dev/stderr"
        exit 2
      }

      command=cols[1]
      impl=cols[3]

      gsub(/^`/, "", command)
      gsub(/`$/, "", command)
      gsub(/^`/, "", impl)
      gsub(/`$/, "", impl)

      if (command == "" || impl == "") {
        printf("error: empty command or implementation in row: %s\n", $0) > "/dev/stderr"
        exit 2
      }

      printf("%s\t%s\n", command, impl)
    }
  ' "$matrix_path"
}

function_exists() {
  local file_path="$1"
  local fn_name="$2"

  rg -n "^[[:space:]]*(function[[:space:]]+)?${fn_name}[[:space:]]*\(\)[[:space:]]*\{" "$file_path" >/dev/null
}

function_has_placeholder_markers() {
  local file_path="$1"
  local fn_name="$2"

  awk -v fn_name="$fn_name" '
    BEGIN {
      in_fn = 0
      depth = 0
      saw_open = 0
    }

    $0 ~ "^[[:space:]]*(function[[:space:]]+)?" fn_name "[[:space:]]*\\(\\)[[:space:]]*\\{" {
      in_fn = 1
    }

    in_fn {
      open_count = gsub(/\{/, "{")
      close_count = gsub(/\}/, "}")
      depth += open_count
      if (open_count > 0) {
        saw_open = 1
      }

      if ($0 ~ /(TODO|todo|placeholder|PLACEHOLDER|stub|STUB|TBD)/) {
        print $0
        exit 0
      }

      depth -= close_count
      if (saw_open && depth <= 0) {
        exit 1
      }
    }

    END {
      exit 1
    }
  ' "$file_path" >/dev/null
}

cmd_list() {
  local matrix_path="$1"
  parse_matrix_rows "$matrix_path" | cut -f1
}

cmd_validate() {
  local matrix_path="$1"
  local had_error=0

  while IFS=$'\t' read -r command impl; do
    if [[ -z "$command" ]]; then
      continue
    fi

    if [[ "$impl" != *"::"* ]]; then
      echo "error: implementation for '$command' must use file::function format: $impl" >&2
      had_error=1
      continue
    fi

    local file_path="${impl%%::*}"
    local fn_name="${impl##*::}"

    if [[ ! -f "$file_path" ]]; then
      echo "error: file for '$command' does not exist: $file_path" >&2
      had_error=1
      continue
    fi

    if ! function_exists "$file_path" "$fn_name"; then
      echo "error: function for '$command' not found: ${file_path}::${fn_name}" >&2
      had_error=1
      continue
    fi

    if function_has_placeholder_markers "$file_path" "$fn_name"; then
      echo "error: function for '$command' contains placeholder marker: ${file_path}::${fn_name}" >&2
      had_error=1
    fi
  done < <(parse_matrix_rows "$matrix_path")

  if [[ "$had_error" -ne 0 ]]; then
    return 1
  fi

  echo "command matrix validation passed: $matrix_path"
}

main() {
  local subcommand="${1:-validate}"
  shift || true

  local matrix_path="$MATRIX_PATH"

  while (($#)); do
    case "$1" in
      --matrix)
        if (($# < 2)); then
          echo "error: --matrix requires a path argument" >&2
          return 1
        fi
        matrix_path="$2"
        shift 2
        ;;
      -h|--help)
        usage
        return 0
        ;;
      *)
        echo "error: unknown option: $1" >&2
        usage >&2
        return 1
        ;;
    esac
  done

  case "$subcommand" in
    validate)
      cmd_validate "$matrix_path"
      ;;
    list)
      cmd_list "$matrix_path"
      ;;
    -h|--help|help)
      usage
      ;;
    *)
      echo "error: unknown subcommand: $subcommand" >&2
      usage >&2
      return 1
      ;;
  esac
}

main "$@"
