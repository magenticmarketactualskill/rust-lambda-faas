class FaasRuntime < Formula
  desc "AWS Lambda-compatible FaaS runtime for Rust functions"
  homepage "https://github.com/manus-ai/rust-lambda-faas"
  url "https://github.com/manus-ai/rust-lambda-faas/archive/v0.1.0.tar.gz"
  sha256 "REPLACE_WITH_ACTUAL_SHA256"
  license "Apache-2.0"
  head "https://github.com/manus-ai/rust-lambda-faas.git", branch: "main"

  depends_on "rust" => :build

  def install
    cd "runtime" do
      system "cargo", "build", "--release", "--locked"
      bin.install "target/release/faas-runtime" => "faas-runtime"
    end

    # Create runtime directories
    (prefix/"var/runtime").mkpath
    (prefix/"var/task").mkpath
    (prefix/"opt/faas-runtime/bin").mkpath

    # Install binary to opt directory
    (prefix/"opt/faas-runtime/bin").install bin/"faas-runtime" => "runtime"

    # Create bootstrap script
    (prefix/"var/runtime/bootstrap").write <<~EOS
      #!/bin/sh
      exec #{prefix}/opt/faas-runtime/bin/runtime
    EOS
    chmod 0755, prefix/"var/runtime/bootstrap"

    # Symlink to bin for easy access
    bin.install_symlink prefix/"opt/faas-runtime/bin/runtime" => "faas-runtime"
  end

  test do
    # Test that the binary exists and is executable
    assert_predicate bin/"faas-runtime", :exist?
    assert_predicate bin/"faas-runtime", :executable?
    
    # Test version output (if implemented)
    # system bin/"faas-runtime", "--version"
  end

  def caveats
    <<~EOS
      FaaS Runtime has been installed!
      
      To use with AWS Lambda, set the AWS_LAMBDA_RUNTIME_API environment variable:
        export AWS_LAMBDA_RUNTIME_API=<your-lambda-runtime-api-endpoint>
      
      Bootstrap script location: #{prefix}/var/runtime/bootstrap
      Task directory: #{prefix}/var/task
    EOS
  end
end
