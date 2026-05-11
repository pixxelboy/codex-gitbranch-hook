# codex-git-branch-hook

A minimal Codex CLI configuration that keeps the current Git branch visible in the Codex TUI bottom pane and prints a branch reminder when a session starts.

It uses Codex's native `git-branch` status-line item for the persistent footer and a small `SessionStart` hook for the startup reminder. There are no runtime dependencies beyond `bash` and optional `git`.

## What you get

Persistent Codex TUI footer:

```text
🌿 main
```

Startup reminder:

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

Codex can render selected status-line items in the TUI footer through `[tui].status_line`. This project enables the built-in Git branch item:

```toml
[tui]
status_line = ["git-branch"]
```

Codex hooks are lifecycle commands that Codex runs during events such as session start, prompt submission, tool use, and stop. This project also registers a `SessionStart` hook that prints a readable branch summary.

This project uses the current official Codex hook layout and native TUI status line configuration:

- `.codex/config.toml` enables the persistent TUI footer branch item with `[tui].status_line = ["git-branch"]`.
- `.codex/config.toml` enables hooks with `[features].codex_hooks = true`.
- `.codex/hooks.json` registers a `SessionStart` command hook.
- `.codex/hooks/git-branch-session-start.sh` prints plain text to stdout.
- `bin/codex-git-branch-hook` installs, uninstalls, and checks those files in target repositories.

For `SessionStart`, Codex adds plain stdout as extra developer context, so the branch reminder appears at startup. The hook matcher is `startup|resume|clear`, matching the current Codex `SessionStart` sources.

## Installation

Install into the repository where you want the branch status line:

```sh
./bin/codex-git-branch-hook install /path/to/your/repo
```

Then start Codex from that repository:

```sh
cd /path/to/your/repo
codex
```

Codex only loads project-local `.codex/` configuration when the project is trusted.

## Quick install

From a source checkout of this repository:

```sh
git clone https://github.com/pixxelboy/codex-git-branch-hook.git
cd codex-git-branch-hook
./bin/codex-git-branch-hook install /path/to/your/repo
```

From inside this repository, install into the current directory:

```sh
./bin/codex-git-branch-hook install
```

You can also copy the files manually:

```sh
mkdir -p .codex/hooks
curl -fsSL https://raw.githubusercontent.com/pixxelboy/codex-git-branch-hook/main/.codex/config.toml -o .codex/config.toml
curl -fsSL https://raw.githubusercontent.com/pixxelboy/codex-git-branch-hook/main/.codex/hooks.json -o .codex/hooks.json
curl -fsSL https://raw.githubusercontent.com/pixxelboy/codex-git-branch-hook/main/.codex/hooks/git-branch-session-start.sh -o .codex/hooks/git-branch-session-start.sh
chmod +x .codex/hooks/git-branch-session-start.sh
```

If you publish under a different repository name, replace `pixxelboy/codex-git-branch-hook` in the raw GitHub URLs.

## Uninstall

Remove the managed files from a target repository:

```sh
./bin/codex-git-branch-hook uninstall /path/to/your/repo
```

The uninstaller is conservative. It removes only files that still match this project's bundled versions. If you changed one of the managed files, it skips that file instead of deleting your edits.

To remove modified managed files anyway:

```sh
./bin/codex-git-branch-hook uninstall /path/to/your/repo --force
```

Check what is installed:

```sh
./bin/codex-git-branch-hook status /path/to/your/repo
```

## Homebrew

This repository includes a Homebrew formula template at [Formula/codex-git-branch-hook.rb](Formula/codex-git-branch-hook.rb).

Once the project has a tagged release and the formula SHA is filled in, it can be published in a tap and installed with:

```sh
brew tap pixxelboy/tap
brew install codex-git-branch-hook
codex-git-branch-hook install /path/to/your/repo
```

Then uninstall from a project with:

```sh
codex-git-branch-hook uninstall /path/to/your/repo
```

And remove the Homebrew package with:

```sh
brew uninstall codex-git-branch-hook
```

## Local testing

Confirm the configured TUI status-line item:

```sh
grep -n 'status_line' .codex/config.toml
```

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

Test the installer in a temporary directory:

```sh
tmpdir="$(mktemp -d)"
./bin/codex-git-branch-hook install "$tmpdir"
./bin/codex-git-branch-hook status "$tmpdir"
./bin/codex-git-branch-hook uninstall "$tmpdir"
```

## Behavior

The persistent TUI status line uses Codex's built-in `git-branch` item. Codex hides that item when branch information is unavailable.

The startup hook script detects:

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

If the branch does not appear in the TUI footer:

- Confirm `.codex/config.toml` contains `[tui].status_line = ["git-branch"]`.
- Restart the Codex session after editing `.codex/config.toml`.
- Make sure Codex trusts the project, because untrusted projects skip project-local config, hooks, and rules.
- Start Codex from inside the target repository.

If nothing appears at session startup:

- Confirm hooks are enabled in `.codex/config.toml`.
- Confirm `.codex/hooks.json` is valid JSON.
- Confirm the script is executable with `chmod +x .codex/hooks/git-branch-session-start.sh`.
- Restart the Codex session after editing hook files.

If the hook cannot find the script from a subdirectory, check that the repository has Git metadata. The hook command resolves the script path from `git rev-parse --show-toplevel`, matching the official Codex recommendation for repo-local hooks.

## Compatibility

- macOS and Linux
- Bash
- Git repositories using normal branches or detached HEAD
- Current Codex TUI status-line support with `git-branch`
- Current Codex hook system with `SessionStart`

Windows is not targeted by this project because the hook script is Bash-based.

## Limitations

- This project is informational only. It does not prevent edits on the wrong branch.
- It does not inspect remote tracking state, dirty worktrees, or pull request metadata.
- Project-local hooks only load when the project `.codex/` layer is trusted.
- Codex status-line and hook behavior can change while the feature evolves; check the official docs when upgrading Codex.

## Official references

- [Codex hooks documentation](https://developers.openai.com/codex/hooks)
- [Codex config basics](https://developers.openai.com/codex/config-basic)
- [OpenAI Codex CLI repository](https://github.com/openai/codex)

## License

MIT. See [LICENSE](LICENSE).
