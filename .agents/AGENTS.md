Structure:
- ~/repos/ - code repos and projects
- ~/notes/ - notes vault, daily notes, dev journals, general context (read its agents file for more info)
- ~/.dotfiles.git/ - bare git repo of personal environment configuration files

General instructions:
- Default communication: caveman full. See caveman skill for detailed mode rules. Off: "stop caveman" / "normal mode".
- No AI attribution in commits, PRs, or code comments.
- Don't pander. Don't tell me I'm right.
- Evidence over speculation.
- Simplicity first: prefer fewer modes, fewer branches, less configuration, and direct behavior over compatibility layers.
- Backwards compatibility must be earned: preserve it for long-lived behavior with actual users or explicit commitments, not for recent accidents or hypothetical callers.
- When working in a git repo, check status first. If the worktree is dirty and the task involves edits, commits, or overlapping files, ask how to proceed. Ignore unrelated changes and never overwrite them.
- Ask before destructive or hard-to-reverse operations. Explain target and impact first.
- When working in a git repo and `wt` is available, prefer Worktrunk for branch/worktree lifecycle (`wt list`, `wt switch`, `wt merge`, `wt remove`); use plain git for low-level inspection and commit/push operations
- For non-trivial, multi-file, or risky edits, give a short plan before changing files. For small localized changes, proceed directly.
- Use tmux for sudo or long-running commands:
  - Create session first: `tmux new-session -d -s session-name` or attach to existing
  - Send command: `tmux send-keys -t session-name 'command' Enter`
  - This provides better visibility - user can see the actual command and session persists after completion
  - For projects with multiple long-running commands (tests, builds, dev servers), use a single persistent session
  - Monitor progress with: `tmux capture-pane -t session-name -p | tail -50`
  - Do not kill tmux sessions by default; preserve them unless the user asks or the process is clearly safe to stop
- Use `interactive_shell` for interactive coding-agent CLIs and supervised TUIs where user takeover matters (e.g. `k9s`, `lazygit`). Do not use it for normal shell commands, sudo, package installs, tests, or dev servers.

## Tool preferences
- Use `rg` for text search. Use `ast-grep` for structural code search/refactors.
  - `ast-grep` takes one language per run, e.g. `ast-grep --lang ts -p 'console.log($$$ARGS)' .`
- If Semgrep is installed, use `semgrep scan --config p/default --metrics=off` for security/static-analysis passes, not normal code navigation.
- Prefer `nu` for structured shell/data tasks (tables, JSON/YAML, filtering, simple transforms).
- Use native `browser` tool for web interaction. Old `agent-browser` skill is disabled.
  - Default browser state persists in `~/.agent-browser/pi-profile`.
  - If using real Chromium profile, repeat `--profile Default` on every browser command.
  - Do not inspect authenticated accounts unless explicitly asked.
- Use `pi-subagents` only for large-repo scouting, independent review, or parallel investigation. Prefer single-agent flow otherwise.
- Use Hunk for interactive code review. Load the Hunk review skill when a Hunk session is running.
- Tool ownership:
  - languages and language linters via mise/npm/uv
  - standalone system CLIs via pacman/yay

