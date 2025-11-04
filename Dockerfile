# Multi-stage Dockerfile for AWS Lambda-compatible FaaS Runtime
# Stage 1: Builder - Full UBI with Rust toolchain
FROM registry.access.redhat.com/ubi9/ubi:latest AS builder

# Install build dependencies
RUN dnf install -y \
    gcc \
    gcc-c++ \
    make \
    openssl-devel \
    && dnf clean all

# Install Rust toolchain
RUN curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y --default-toolchain 1.82.0
ENV PATH="/root/.cargo/bin:${PATH}"

# Set working directory
WORKDIR /build

# Copy runtime source
COPY submodules/runtime/Cargo.toml submodules/runtime/Cargo.lock* ./
COPY submodules/runtime/src ./src

# Build the runtime with optimizations
RUN cargo build --release

# Stage 2: Runtime - Minimal UBI
FROM registry.access.redhat.com/ubi9/ubi-minimal:latest

# Install minimal runtime dependencies
RUN microdnf install -y \
    ca-certificates \
    && microdnf clean all

# Create runtime directories
RUN mkdir -p /var/runtime /opt/faas-runtime/bin /var/task

# Copy the compiled binary from builder
COPY --from=builder /build/target/release/faas-runtime /opt/faas-runtime/bin/runtime

# Create bootstrap script
RUN echo '#!/bin/sh' > /var/runtime/bootstrap && \
    echo 'exec /opt/faas-runtime/bin/runtime' >> /var/runtime/bootstrap && \
    chmod +x /var/runtime/bootstrap

# Set working directory to Lambda task directory
WORKDIR /var/task

# Set the entrypoint to the bootstrap script
ENTRYPOINT ["/var/runtime/bootstrap"]
