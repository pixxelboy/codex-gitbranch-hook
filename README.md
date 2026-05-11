# codex-git-branch-hook

A minimal Codex CLI hook that shows the current Git branch in Codex. It configures Codex's built-in TUI footer branch segment and also prints a branch reminder when a session starts.

The recommended install is global: Homebrew installs `codex-gitbranch-hook` and the required Nerd Font, then `codex-gitbranch-hook install --global` updates the user-level Codex config at `~/.codex/config.toml`. There are no runtime dependencies beyond `bash` and optional `git`.

## What you get

Persistent Codex TUI footer branch display:

```text
gpt-5.5 medium · ~/Projects/candidateos · feature/public-profile-page
```

Codex startup reminder from any working directory:

```text
🌿 Codex Git Branch Hook

Repository:
~/projects/candidateos

Branch:
 feature/public-profile-page

Reminder:
Verify you are working on the expected branch before editing files.
```

See [examples/example-output.md](examples/example-output.md).

## How it works

Codex hooks are lifecycle commands that Codex runs during events such as session start, prompt submission, tool use, and stop.

The global installer updates `~/.codex/config.toml` by:

- enabling hooks with `[features].hooks = true`
- adding `git-branch` to `[tui].status_line`
- adding a managed `SessionStart` hook block
- calling the Homebrew-installed executable by absolute path
- backing up existing config before modifying it
- preserving unrelated Codex settings

Codex's built-in TUI status line reads `[tui].status_line` from `config.toml`. The installer preserves existing status-line items and appends `git-branch` when it is missing.

For `SessionStart`, Codex adds plain stdout as extra developer context, so the branch reminder appears at startup. The hook matcher is `startup|resume|clear`.

## Recommended Install

```sh
brew tap pixxelboy/brew-tap https://github.com/pixxelboy/brew-tap.git
brew install pixxelboy/brew-tap/codex-gitbranch-hook
codex-gitbranch-hook install --global
```

Homebrew installs the required Nerd Font cask automatically:

```text
font-meslo-lg-nerd-font
```

Then verify:

```sh
codex-gitbranch-hook doctor
codex-gitbranch-hook preview
```

Start or restart Codex from any folder. The first time Codex sees this hook, it may show:

```text
1 hook needs review before it can run. Open /hooks to review it.
```

Open `/hooks` in Codex, review the command, and approve it. This is expected Codex safety behavior for project hooks.

## Commands

Print the same output Codex will receive:

```sh
codex-gitbranch-hook
codex-gitbranch-hook preview
```

Register globally:

```sh
codex-gitbranch-hook install --global
```

Remove the global registration:

```sh
codex-gitbranch-hook uninstall --global
```

Inspect the setup:

```sh
codex-gitbranch-hook doctor
```

The legacy executable name is also installed for compatibility:

```sh
codex-git-branch-hook preview
```

## Branch Icon

The default branch icon is the Nerd Font Git branch glyph:

```text

```

Homebrew installs the required font automatically. You may still need to select it in your terminal settings. Recommended terminal font:

```text
MesloLGS NF
```

Terminal font selection examples:

- Terminal.app: Settings -> Profiles -> Text -> Font
- iTerm2: Settings -> Profiles -> Text -> Font
- Warp: Settings -> Appearance -> Text -> Terminal font
- VS Code terminal: set `terminal.integrated.fontFamily` to `MesloLGS NF`

Fallback icon modes are available through `CODEX_GITBRANCH_ICON`:

```sh
CODEX_GITBRANCH_ICON=emoji codex-gitbranch-hook preview
CODEX_GITBRANCH_ICON=text codex-gitbranch-hook preview
CODEX_GITBRANCH_ICON=none codex-gitbranch-hook preview
```

## Global vs Project Install

Global install is recommended because it works everywhere Codex runs. It modifies only the user-level Codex config:

```text
~/.codex/config.toml
```

Project-local install is still available for repositories that should carry their own `.codex/` files:

```sh
codex-gitbranch-hook install /path/to/your/repo
codex-gitbranch-hook uninstall /path/to/your/repo
codex-gitbranch-hook status /path/to/your/repo
```

Project-local hooks load only when that project `.codex/` layer is trusted. Global hooks load from the user config layer.

## Homebrew

The Homebrew tap is published at [pixxelboy/brew-tap](https://github.com/pixxelboy/brew-tap).

Tap it and install the formula:

```sh
brew tap pixxelboy/brew-tap https://github.com/pixxelboy/brew-tap.git
brew install pixxelboy/brew-tap/codex-gitbranch-hook
codex-gitbranch-hook install --global
```

The formula depends on `font-meslo-lg-nerd-font`, so Homebrew installs the required Nerd Font with the CLI. Terminal font selection remains a user preference and is not changed automatically.

To install the latest `main` branch instead of the tagged release:

```sh
brew install --HEAD pixxelboy/brew-tap/codex-gitbranch-hook
```

Because the tap repository is named `brew-tap`, use the explicit URL form above. The shorter Homebrew command below would require a repository named `pixxelboy/homebrew-tap`:

```sh
brew tap pixxelboy/tap
```

Unregister from Codex:

```sh
codex-gitbranch-hook uninstall --global
```

Remove the Homebrew package:

```sh
brew uninstall codex-gitbranch-hook
```

If `brew tap pixxelboy/tap` asks for a GitHub username, use the explicit URL form:

```sh
brew tap pixxelboy/brew-tap https://github.com/pixxelboy/brew-tap.git
```

## Local testing

Run the test suite:

```sh
test/run-tests.sh
```

Run ShellCheck:

```sh
shellcheck bin/codex-gitbranch-hook bin/codex-git-branch-hook test/run-tests.sh .codex/hooks/git-branch-session-start.sh
```

Preview output:

```sh
bin/codex-gitbranch-hook preview
```

Test outside Git:

```sh
tmpdir="$(mktemp -d)"
cd "$tmpdir"
codex-gitbranch-hook preview
```

## Behavior

The hook detects:

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

If `codex-gitbranch-hook` is not found after Homebrew install:

- On Apple Silicon, make sure `/opt/homebrew/bin` is on `PATH`.
- On Intel macOS, make sure `/usr/local/bin` is on `PATH`.
- Open a new terminal after installing with Homebrew.
- Run `brew --prefix` to confirm your Homebrew prefix.

If the branch icon shows as a box or odd symbol:

- Confirm Homebrew installed `font-meslo-lg-nerd-font`.
- Select `MesloLGS NF` as your terminal font.
- Run `codex-gitbranch-hook doctor` and check the glyph preview.
- The font is installed, but your terminal may not be using it yet.
- Use `CODEX_GITBRANCH_ICON=emoji`, `text`, or `none` if you prefer a fallback.

If nothing appears at session startup:

- Run `codex-gitbranch-hook doctor`.
- Confirm `~/.codex/config.toml` contains `[features].hooks = true`.
- If Codex says a hook needs review, open `/hooks` in Codex and approve the hook.
- Restart Codex after running `codex-gitbranch-hook install --global`.

If the branch is missing from the bottom Codex pane:

- Run `codex-gitbranch-hook install --global` again; it is idempotent.
- Confirm `~/.codex/config.toml` contains `[tui]` with `status_line` including `"git-branch"`.
- Restart Codex after changing `~/.codex/config.toml`.
- Run `codex-gitbranch-hook doctor` and check `TUI status line`.

If global uninstall cannot find a managed block, the tool leaves your config untouched. Remove custom hook entries manually only if you added them yourself.

## Compatibility

- macOS and Linux
- Bash
- Git repositories using normal branches or detached HEAD
- Current Codex hook system with `SessionStart`

Windows is not targeted by this project because the hook script is Bash-based.

## Limitations

- This project is informational only. It does not prevent edits on the wrong branch.
- It does not inspect remote tracking state, dirty worktrees, or pull request metadata.
- The global installer manages its marked hook block and adds `git-branch` to Codex's TUI `status_line`.
- The tool does not approve Codex hooks for you; review remains a Codex safety step.
- The tool does not modify Terminal.app, iTerm2, Warp, Ghostty, VS Code, or shell profile settings.
- Codex status-line and hook behavior can change while the feature evolves; check the official docs when upgrading Codex.

## Official references

- [Codex hooks documentation](https://developers.openai.com/codex/hooks)
- [Codex config basics](https://developers.openai.com/codex/config-basic)
- [OpenAI Codex CLI repository](https://github.com/openai/codex)

## License

MIT. See [LICENSE](LICENSE).
