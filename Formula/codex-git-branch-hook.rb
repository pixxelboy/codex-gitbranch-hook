class CodexGitBranchHook < Formula
  desc "Codex CLI Git branch status-line configuration and SessionStart hook"
  homepage "https://github.com/pixxelboy/codex-gitbranch-hook"
  url "https://github.com/pixxelboy/codex-gitbranch-hook/archive/refs/tags/v0.2.2.tar.gz"
  sha256 "ff6a74f6f39638b82d93e259867600bb9a8afaa358bfa2773d80d2e71a356457"
  license "MIT"
  head "https://github.com/pixxelboy/codex-gitbranch-hook.git", branch: "main"

  depends_on cask: "font-meslo-lg-nerd-font"

  def install
    bin.install "bin/codex-gitbranch-hook"
    bin.install "bin/codex-git-branch-hook"
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
