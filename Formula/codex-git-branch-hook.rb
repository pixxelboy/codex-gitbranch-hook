class CodexGitBranchHook < Formula
  desc "Codex CLI Git branch status-line configuration and SessionStart hook"
  homepage "https://github.com/pixxelboy/codex-gitbranch-hook"
  head "https://github.com/pixxelboy/codex-gitbranch-hook.git", branch: "main"
  license "MIT"

  def install
    bin.install "bin/codex-git-branch-hook"
    pkgshare.install ".codex"
  end

  test do
    assert_match "Usage:", shell_output("#{bin}/codex-git-branch-hook --help")
    system bin/"codex-git-branch-hook", "install", testpath
    assert_match "current:", shell_output("#{bin}/codex-git-branch-hook status #{testpath}")
  end
end
