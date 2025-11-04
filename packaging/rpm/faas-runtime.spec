Name:           faas-runtime
Version:        0.1.0
Release:        1%{?dist}
Summary:        AWS Lambda-compatible FaaS runtime for Rust functions

License:        Apache-2.0
URL:            https://github.com/manus-ai/rust-lambda-faas
Source0:        %{name}-%{version}.tar.gz

BuildRequires:  gcc
BuildRequires:  gcc-c++
BuildRequires:  make
BuildRequires:  openssl-devel
BuildRequires:  curl

Requires:       ca-certificates

%description
An AWS Lambda-compatible Function as a Service (FaaS) runtime written in Rust.
This runtime implements the AWS Lambda Runtime API and provides a lightweight,
fast, and secure environment for executing Rust functions.

%prep
%setup -q

%build
# Install Rust if not already installed
if ! command -v cargo &> /dev/null; then
    curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y --default-toolchain 1.82.0
    source $HOME/.cargo/env
fi

# Build the runtime
cd runtime
cargo build --release

%install
rm -rf %{buildroot}

# Create installation directories
mkdir -p %{buildroot}/opt/faas-runtime/bin
mkdir -p %{buildroot}/var/runtime
mkdir -p %{buildroot}/var/task
mkdir -p %{buildroot}%{_sysconfdir}/faas-runtime

# Install the binary
install -m 0755 submodules/runtime/target/release/faas-runtime %{buildroot}/opt/faas-runtime/bin/runtime

# Install bootstrap script
cat > %{buildroot}/var/runtime/bootstrap << 'EOF'
#!/bin/sh
exec /opt/faas-runtime/bin/runtime
EOF
chmod 0755 %{buildroot}/var/runtime/bootstrap

# Install systemd service file (optional, for local testing)
mkdir -p %{buildroot}%{_unitdir}
cat > %{buildroot}%{_unitdir}/faas-runtime.service << 'EOF'
[Unit]
Description=FaaS Runtime Service
After=network.target

[Service]
Type=simple
ExecStart=/var/runtime/bootstrap
Restart=on-failure
Environment="AWS_LAMBDA_RUNTIME_API=localhost:9001"

[Install]
WantedBy=multi-user.target
EOF

%files
%license LICENSE
%doc README.md
/opt/faas-runtime/bin/runtime
/var/runtime/bootstrap
%dir /var/task
%dir %{_sysconfdir}/faas-runtime
%{_unitdir}/faas-runtime.service

%changelog
* Mon Nov 04 2024 Manus AI <dev@manus.ai> - 0.1.0-1
- Initial release
- AWS Lambda Runtime API implementation
- Optimized for small size and fast startup
- RedHat UBI-based container support
