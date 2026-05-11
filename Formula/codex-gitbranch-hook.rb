class CodexGitbranchHook < Formula
  desc "Codex CLI Git branch status-line configuration and SessionStart hook"
  homepage "https://github.com/pixxelboy/codex-gitbranch-hook"
  url "https://github.com/pixxelboy/codex-gitbranch-hook/archive/refs/tags/v0.2.0.tar.gz"
  sha256 "0bd46a9925161fa440172505a4190191ac1b4256c092f7203a066158d748a926"
  license "MIT"
  head "https://github.com/pixxelboy/codex-gitbranch-hook.git", branch: "main"

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
    EOS
  end

  test do
    assert_match "Usage:", shell_output("#{bin}/codex-gitbranch-hook --help")
    assert_match "Codex Git Branch Hook", shell_output("#{bin}/codex-gitbranch-hook preview")
    assert_match "Codex Git Branch Hook", shell_output("#{bin}/codex-git-branch-hook preview")
  end
end
