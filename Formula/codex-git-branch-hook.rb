class CodexGitBranchHook < Formula
  desc "Codex CLI Git branch status-line configuration and SessionStart hook"
  homepage "https://github.com/pixxelboy/codex-gitbranch-hook"
  url "https://github.com/pixxelboy/codex-gitbranch-hook/archive/refs/tags/v0.2.3.tar.gz"
  sha256 "02eac28c38ca26164ea15211fc334c2dc8399c303b8b35ac02b673e514012352"
  license "MIT"
  head "https://github.com/pixxelboy/codex-gitbranch-hook.git", branch: "main"

  def install
    bin.install "bin/codex-gitbranch-hook"
    bin.install "bin/codex-git-branch-hook"
  end

  def post_install
    return if quiet_system "brew", "list", "--cask", "font-meslo-lg-nerd-font"

    ohai "Installing required Nerd Font cask: font-meslo-lg-nerd-font"
    return if quiet_system "brew", "install", "--cask", "font-meslo-lg-nerd-font"

    opoo "Could not install font-meslo-lg-nerd-font automatically."
    opoo "Run `brew install --cask font-meslo-lg-nerd-font` if the branch glyph does not render."
  end

  def caveats
    <<~EOS
      Register the global Codex hook:
        codex-gitbranch-hook install --global

      Check your setup:
        codex-gitbranch-hook doctor

      Preview the current folder output:
        codex-gitbranch-hook preview

      Homebrew installs the required Nerd Font automatically:
        font-meslo-lg-nerd-font

      Select this font in your terminal settings if the branch glyph does not render:
        MesloLGS NF
    EOS
  end

  test do
    assert_match "Usage:", shell_output("#{bin}/codex-gitbranch-hook --help")
    assert_match "Codex Git Branch Hook", shell_output("#{bin}/codex-gitbranch-hook preview")
    assert_match "Codex Git Branch Hook", shell_output("#{bin}/codex-git-branch-hook preview")
  end
end
