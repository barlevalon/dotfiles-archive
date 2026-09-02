#!/usr/bin/env bash
set -euo pipefail

dir_name=$(printf '' | fzf \
  --print-query \
  --prompt 'New directory: ' \
  --header 'Enter directory name or relative path under ~/repos' \
  | head -1 || true)

if [[ -z "$dir_name" ]]; then
  exit 0
fi

if [[ $dir_name == /* ]]; then
  printf 'Path must be relative to ~/repos\n' >&2
  exit 1
fi

target_dir=$(realpath -m -- "$HOME/repos/$dir_name")
if [[ $target_dir != "$HOME/repos/"* ]]; then
  printf 'Path must stay under ~/repos\n' >&2
  exit 1
fi

mkdir -p -- "$target_dir"

"$HOME/.local/bin/sesh" connect "$target_dir"
