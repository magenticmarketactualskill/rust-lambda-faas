# AWS Rust Lambda FaaS Container

This project provides a custom AWS Lambda-compatible FaaS (Function as a Service) container for running Rust functions. It is designed to be lightweight, fast, and secure, with a focus on small container sizes and rapid context switching.

## Features

- **AWS Lambda Compatible:** Implements the AWS Lambda Runtime API for seamless integration.
- **RedHat Linux Base:** Built on Red Hat Universal Base Image (UBI) for enterprise-grade stability and security.
- **RPM Packaging:** Packaged as an RPM for easy installation and management on RedHat-based systems.
- **Cross-Platform Support:** Provides a Pacman-like experience on Windows (via MSYS2) and macOS (via Homebrew).
- **Small Container Images:** Utilizes multi-stage builds and minimal base images (UBI Minimal and Alpine) to create small, efficient container images.
- **Fast Context Switching:** Optimized for fast cold starts and low-latency function execution, leveraging Rust's performance and a lightweight runtime.
- **Dynamic Function Loading:** The runtime dynamically loads user-provided Rust functions from a shared library (`.so` file), allowing for easy updates and deployment.

## Architecture

The FaaS container consists of two main components:

1.  **FaaS Runtime:** A custom runtime written in Rust that implements the AWS Lambda Runtime API. It is responsible for fetching invocation events, executing user functions, and posting responses.
2.  **User Function:** A Rust function compiled as a shared library (`.so` file) that is dynamically loaded by the runtime at startup. This function contains the user's business logic.

### Container Base Images

Two Dockerfiles are provided to demonstrate the flexibility of the architecture:

- `Dockerfile`: Builds the FaaS container on a `ubi-minimal` base image. This is recommended for production environments that require RedHat compliance.
- `Dockerfile.alpine`: Builds an ultra-minimal container on an `alpine` base image, with the runtime statically linked against `musl`. This is ideal for environments where container size is the primary concern.

## Getting Started

### Prerequisites

- Docker
- Rust 1.82.0 or later
- `build-essential` (or equivalent) for your platform

### Building the Containers

A build script is provided to demonstrate the container size comparison:

```bash
./build.sh
```

This script will build both the UBI-based and Alpine-based containers and display their sizes.

### Running the Container

To run the container, you need to provide the `AWS_LAMBDA_RUNTIME_API` environment variable, which points to the Lambda Runtime API endpoint.

```bash
# Run the UBI-based container
docker run -e AWS_LAMBDA_RUNTIME_API=<your-lambda-runtime-api-endpoint> faas-runtime:ubi

# Run the Alpine-based container
docker run -e AWS_LAMBDA_RUNTIME_API=<your-lambda-runtime-api-endpoint> faas-runtime:alpine
```

### Creating a User Function

An example user function is provided in the `examples/simple-handler` directory. To create your own function:

1.  Create a new Rust library project:

    ```bash
    cargo new --lib my-function
    ```

2.  Add the following to your `Cargo.toml`:

    ```toml
    [lib]
    crate-type = ["cdylib"]

    [dependencies]
    serde_json = "1.0"
    ```

3.  Write your function in `src/lib.rs`:

    ```rust
    use serde_json::{json, Value};

    #[repr(C)]
    pub struct LambdaContext { /* ... */ }

    #[no_mangle]
    pub unsafe extern "C" fn handle(payload: &Value, _context: &LambdaContext) -> Result<Value, String> {
        // Your logic here
        Ok(json!({ "message": "Hello from my function!" }))
    }
    ```

4.  Build the shared library:

    ```bash
    cargo build --release
    ```

5.  Mount the resulting `.so` file into the `/var/task` directory of the container.

## Packaging and Distribution

### RPM (RedHat)

An RPM spec file is provided in `packaging/rpm/faas-runtime.spec`. To build the RPM, you can use `rpmbuild`.

### Pacman (Windows/MSYS2)

A `PKGBUILD` file is provided in `packaging/pacman/PKGBUILD` for use with MSYS2 on Windows.

### Homebrew (macOS)

A Homebrew formula is provided in `packaging/homebrew/faas-runtime.rb` for installation on macOS.

## Optimization

For a detailed overview of the optimization techniques used in this project, please see `OPTIMIZATION.md`.
