# Submodules

This directory contains the core submodules of the Rust Lambda FaaS project:

## Runtime (`runtime/`)
The Rust-based Lambda runtime implementation that provides:
- AWS Lambda Runtime API client
- Function execution environment
- Event handling and response processing
- Performance optimizations for cold starts

## Runtime API Gem (`runtime_api_gem/`)
A Ruby gem that implements the AWS Lambda Runtime API server interface:
- Full AWS Lambda Runtime API compatibility
- Function registration and management
- Invocation queuing and monitoring
- Real-time status tracking
- Health monitoring endpoints

## Git Submodules

These directories are configured as git submodules. To work with them:

### Initial Setup
```bash
# Clone with submodules
git clone --recursive <repository-url>

# Or initialize submodules after cloning
git submodule init
git submodule update
```

### Updating Submodules
```bash
# Update all submodules to latest
git submodule update --remote

# Update specific submodule
git submodule update --remote submodules/runtime
```

## Usage

Each submodule can be built and used independently:

### Runtime
```bash
cd submodules/runtime
cargo build --release
```

### Runtime API Gem
```bash
cd submodules/runtime_api_gem
bundle install
bundle exec bin/runtime_api_server
```

## Integration

The runtime and runtime_api_gem are designed to work together:
1. Start the Runtime API server (Ruby gem)
2. Register Lambda functions via the API
3. Launch the Rust runtime pointing to the API server
4. Monitor function executions through the API endpoints