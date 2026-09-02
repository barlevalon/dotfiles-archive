#!/usr/bin/env bash
set -euo pipefail

# Prompt for repo
repo=$(echo "" | fzf \
  --print-query \
  --prompt "GitHub repo (user/repo): " \
  --header "Enter a GitHub repository to clone" \
  | head -1 || true)

if [[ -z "$repo" ]]; then
  exit 0
fi

case $repo in
  https://github.com/*)
    repo_path=${repo#https://github.com/}
    ;;
  git@github.com:*)
    repo_path=${repo#git@github.com:}
    ;;
  */*)
    repo_path=$repo
    repo="https://github.com/$repo"
    ;;
  *)
    printf 'Expected owner/repo or a GitHub clone URL\n' >&2
    exit 1
    ;;
esac

repo_path=${repo_path%.git}
if [[ ! $repo_path =~ ^[^/[:space:]]+/[^/[:space:]]+$ ]] ||
   [[ $repo_path == ../* || $repo_path == ./* ||
      $repo_path == */.. || $repo_path == */. ]]; then
  printf 'Invalid GitHub repository: %s\n' "$repo_path" >&2
  exit 1
fi

root=$HOME/repos
mkdir -p -- "$root"
target_dir=$root/$repo_path
probe=$target_dir
while [[ ! -e $probe ]]; do
  probe=${probe%/*}
done

canonical_root=$(cd -P "$root" && pwd)
canonical_probe=$(cd -P "$probe" 2>/dev/null && pwd) || {
  printf 'Clone target must stay under ~/repos\n' >&2
  exit 1
}
case $canonical_probe in
  "$canonical_root"|"$canonical_root"/*) ;;
  *)
    printf 'Clone target must stay under ~/repos\n' >&2
    exit 1
    ;;
esac

# Clone if doesn't exist
if [[ -d "$target_dir" ]]; then
  echo "Directory already exists, connecting to session..."
else
  git clone "$repo" "$target_dir"
fi

# Connect to its tmux session
"$HOME/.local/bin/sesh" connect "$target_dir"
