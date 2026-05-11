class CodexGitBranchHook < Formula
  desc "Codex CLI Git branch status-line configuration and SessionStart hook"
  homepage "https://github.com/pixxelboy/codex-gitbranch-hook"
  url "https://github.com/pixxelboy/codex-gitbranch-hook/archive/refs/tags/v0.1.0.tar.gz"
  sha256 "2915cb93f586a635607b95f60777686750d8916e70234c93b1539280f631b121"
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
