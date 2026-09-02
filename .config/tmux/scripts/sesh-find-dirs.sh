#!/usr/bin/env bash
set -euo pipefail

roots=("$HOME/repos" "$HOME/.config" "$HOME/dotfiles" "$HOME/notes")
existing_roots=()

for root in "${roots[@]}"; do
  [[ -d "$root" ]] && existing_roots+=("$root")
done

{
  if ((${#existing_roots[@]})); then
    fd -H -t d '^\.git$' "${existing_roots[@]}" 2>/dev/null | sed -E 's#/.git/?$##'
  fi

  fd -H -d 2 -t d -E .Trash . "$HOME" 2>/dev/null
} | awk '!seen[$0]++'
