# codex-git-branch-hook

A small Codex CLI hook project that shows the current Git branch when a Codex session starts and enables Codex's native TUI Git branch status line.

It is intentionally minimal: one `SessionStart` hook, one Bash script, and no runtime dependencies beyond `bash` and optional `git`.

## Example output

```text
🌿 Codex Git Branch Hook

Repository:
~/projects/candidateos

Branch:
feature/public-profile-page

Reminder:
Verify you are working on the expected branch before editing files.
```

See [examples/example-output.md](examples/example-output.md).

## How it works

Codex hooks are lifecycle commands that Codex runs during events such as session start, prompt submission, tool use, and stop.

This project uses the current official Codex hook layout and native TUI status line configuration:

- `.codex/config.toml` enables the hook feature flag with `[features].codex_hooks = true`.
- `.codex/config.toml` enables the persistent TUI footer branch item with `[tui].status_line = ["git-branch"]`.
- `.codex/hooks.json` registers a `SessionStart` command hook.
- `.codex/hooks/git-branch-session-start.sh` prints plain text to stdout.

For `SessionStart`, Codex adds plain stdout as extra developer context, so the branch reminder appears at startup.

The native status line keeps the branch visible in the Codex bottom pane while you work.

The hook matcher is `startup|resume|clear`, matching the current Codex `SessionStart` sources.

## Installation

Copy the `.codex` directory into the repository where you want the branch reminder:

```sh
cp -R .codex /path/to/your/repo/
chmod +x /path/to/your/repo/.codex/hooks/git-branch-session-start.sh
```

Then start Codex from that repository:

```sh
cd /path/to/your/repo
codex
```

Codex only loads project-local `.codex/` configuration when the project is trusted.

## Quick install

From inside a target Git repository:

```sh
mkdir -p .codex/hooks
curl -fsSL https://raw.githubusercontent.com/pixxelboy/codex-git-branch-hook/main/.codex/config.toml -o .codex/config.toml
curl -fsSL https://raw.githubusercontent.com/pixxelboy/codex-git-branch-hook/main/.codex/hooks.json -o .codex/hooks.json
curl -fsSL https://raw.githubusercontent.com/pixxelboy/codex-git-branch-hook/main/.codex/hooks/git-branch-session-start.sh -o .codex/hooks/git-branch-session-start.sh
chmod +x .codex/hooks/git-branch-session-start.sh
```

If you publish under a different repository name, replace `pixxelboy/codex-git-branch-hook` in the raw GitHub URLs.

## Local testing

Run the script directly from a Git repository:

```sh
bash .codex/hooks/git-branch-session-start.sh
```

Test from a subdirectory:

```sh
mkdir -p tmp/nested
cd tmp/nested
bash ../../.codex/hooks/git-branch-session-start.sh
```

Test outside Git:

```sh
tmpdir="$(mktemp -d)"
cd "$tmpdir"
bash /path/to/codex-git-branch-hook/.codex/hooks/git-branch-session-start.sh
```

Validate the hook configuration:

```sh
python3 -m json.tool .codex/hooks.json >/dev/null
```

## Behavior

The script detects:

- Git repository root
- Current branch
- Detached HEAD state
- Missing `git`
- Non-Git folders

Detached HEAD output looks like:

```text
Branch:
detached HEAD (abc1234)
```

In a non-Git folder, it exits successfully and reports:

```text
Branch:
Not a Git repository.
```

If `git` is missing from `PATH`, it exits successfully and reports that Git is unavailable.

## Troubleshooting

If nothing appears at session startup:

- Confirm hooks are enabled in `.codex/config.toml`.
- Confirm `.codex/hooks.json` is valid JSON.
- Confirm the script is executable with `chmod +x .codex/hooks/git-branch-session-start.sh`.
- Restart the Codex session after editing hook files.
- Make sure Codex trusts the project, because untrusted projects skip project-local config, hooks, and rules.
- Start Codex from inside the target repository.

If the hook cannot find the script from a subdirectory, check that the repository has Git metadata. The hook command resolves the script path from `git rev-parse --show-toplevel`, matching the official Codex recommendation for repo-local hooks.

## Compatibility

- macOS and Linux
- Bash
- Git repositories using normal branches or detached HEAD
- Current Codex hook system with `SessionStart`

Windows is not targeted by this project because the hook script is Bash-based.

## Limitations

- This hook is informational only. It does not prevent edits on the wrong branch.
- It does not inspect remote tracking state, dirty worktrees, or pull request metadata.
- Project-local hooks only load when the project `.codex/` layer is trusted.
- Codex hook behavior can change while the feature evolves; check the official docs when upgrading Codex.

## Official references

- [Codex hooks documentation](https://developers.openai.com/codex/hooks)
- [Codex config basics](https://developers.openai.com/codex/config-basic)
- [OpenAI Codex CLI repository](https://github.com/openai/codex)

## License

MIT. See [LICENSE](LICENSE).
