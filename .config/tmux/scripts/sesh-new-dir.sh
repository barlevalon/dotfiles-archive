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

case "/$dir_name/" in
  *"/../"*|*"/./"*|//*)
    printf 'Path must be relative to ~/repos\n' >&2
    exit 1
    ;;
esac

root=$HOME/repos
mkdir -p -- "$root"
target_dir=$root/$dir_name
probe=$target_dir
while [[ ! -e $probe ]]; do
  probe=${probe%/*}
done

canonical_root=$(cd -P "$root" && pwd)
canonical_probe=$(cd -P "$probe" 2>/dev/null && pwd) || {
  printf 'Path must stay under ~/repos\n' >&2
  exit 1
}
case $canonical_probe in
  "$canonical_root"|"$canonical_root"/*) ;;
  *)
    printf 'Path must stay under ~/repos\n' >&2
    exit 1
    ;;
esac

mkdir -p -- "$target_dir"

"$HOME/.local/bin/sesh" connect "$target_dir"
