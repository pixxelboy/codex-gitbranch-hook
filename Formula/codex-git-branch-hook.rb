class CodexGitBranchHook < Formula
  desc "Codex CLI Git branch status-line configuration and SessionStart hook"
  homepage "https://github.com/pixxelboy/codex-gitbranch-hook"
  url "https://github.com/pixxelboy/codex-gitbranch-hook/archive/refs/tags/v0.1.2.tar.gz"
  sha256 "16d6b0430d049b80d5d9f05ed3a4d742dfe9c3ac51c7ceb62d97b666809c5173"
  license "MIT"
  head "https://github.com/pixxelboy/codex-gitbranch-hook.git", branch: "main"

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
