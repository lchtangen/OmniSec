# Homebrew Tap for OmniSec (macOS)
# Save as: homebrew/omnisec.rb

class Omnisec < Formula
  desc "Next-Gen Mobile Security Platform with AI, Mesh, eBPF, PQ Crypto"
  homepage "https://github.com/lchtangen/OmniSec"
  url "https://github.com/lchtangen/OmniSec/archive/refs/tags/v3.0.tar.gz"
  sha256 "SKIP"  # Will be auto-filled on first build
  head "https://github.com/lchtangen/OmniSec.git", branch: "main"

  depends_on "bash"
  depends_on "make"
  depends_on "gcc" => :build
  depends_on "python@3.12"
  depends_on "openssl"
  depends_on "nmap"

  def install
    # Build stage
    system "make", "stage"
    system "make", "build-c"

    # Install main binary
    bin.install "nhctl"
    bin.install Dir["src/device/bin/nh-*"] if Dir.exist?("src/device/bin")

    # Install C tools
    libexec.install Dir["build/nh-sudo"] if Dir.exist?("build/nh-sudo")
    libexec.install Dir["build/nh-trace"] if Dir.exist?("build/nh-trace")
    libexec.install Dir["build/nh-diag"] if Dir.exist?("build/nh-diag")

    # Install scripts
    pkgshare.install Dir["src/scripts/*.sh"] if Dir.exist?("src/scripts")

    # Install docs
    doc.install "README.md", "VERSION.md", "LICENSE" if File.exist?("LICENSE")

    # Install config
    etc.install "nh-defaults.sh" if File.exist?("nh-defaults.sh")
  end

  def post_install
    ohai "OmniSec installed!"
    ohai "   Run: nhctl help"
    ohai "   Docs: https://github.com/lchtangen/OmniSec"
  end

  test do
    # Run test suite
    system "make", "test"
  end

  def caveats
    <<~EOS
OmniSec v3.0 — Next-Gen Mobile Security Platform

For AI features, install:
  brew install llama.cpp

For mesh networking, install:
  pip install rns

For eBPF tools, install:
  brew install bpftool

Run 'nhctl help' to get started!
EOS
  end
end
