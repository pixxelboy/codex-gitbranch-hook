class CodexGitBranchHook < Formula
  desc "Codex CLI Git branch status-line configuration and SessionStart hook"
  homepage "https://github.com/pixxelboy/codex-gitbranch-hook"
  url "https://github.com/pixxelboy/codex-gitbranch-hook/archive/refs/tags/v0.1.1.tar.gz"
  sha256 "0a321f6ef26466226077acb6e7e4e93b02911796be574b3bd41af0430f3bed8b"
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
