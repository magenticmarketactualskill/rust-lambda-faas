#!/bin/bash
# Build script for FaaS Runtime containers
# Demonstrates SMALL CONTAINERS and FAST CONTEXT SWITCHING

set -e

echo "==================================="
echo "Building FaaS Runtime Containers"
echo "==================================="

# Colors for output
GREEN='\033[0;32m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Build UBI-based container (RedHat Linux)
echo -e "\n${BLUE}Building UBI-based container (RedHat)...${NC}"
docker build -t faas-runtime:ubi -f Dockerfile .
UBI_SIZE=$(docker images faas-runtime:ubi --format "{{.Size}}")
echo -e "${GREEN}✓ UBI-based container built: $UBI_SIZE${NC}"

# Build Alpine-based container (Ultra-minimal)
echo -e "\n${BLUE}Building Alpine-based container (Ultra-minimal)...${NC}"
docker build -t faas-runtime:alpine -f Dockerfile.alpine .
ALPINE_SIZE=$(docker images faas-runtime:alpine --format "{{.Size}}")
echo -e "${GREEN}✓ Alpine-based container built: $ALPINE_SIZE${NC}"

# Display comparison
echo -e "\n==================================="
echo -e "${GREEN}Container Size Comparison${NC}"
echo -e "==================================="
echo "UBI-based (RedHat):    $UBI_SIZE"
echo "Alpine-based (Minimal): $ALPINE_SIZE"
echo ""

# Display detailed image information
echo -e "${BLUE}Detailed Image Information:${NC}"
docker images | grep faas-runtime

# Test cold start time (if Docker is available)
echo -e "\n==================================="
echo -e "${GREEN}Cold Start Performance Test${NC}"
echo -e "==================================="

test_cold_start() {
    local image=$1
    local name=$2
    
    echo -e "\n${BLUE}Testing $name...${NC}"
    
    # Simulate Lambda environment variable
    export AWS_LAMBDA_RUNTIME_API="127.0.0.1:9001"
    
    # Measure container startup time
    START_TIME=$(date +%s%N)
    CONTAINER_ID=$(docker run -d \
        -e AWS_LAMBDA_RUNTIME_API=$AWS_LAMBDA_RUNTIME_API \
        $image)
    
    # Wait for container to be running
    sleep 0.1
    
    END_TIME=$(date +%s%N)
    ELAPSED=$((($END_TIME - $START_TIME) / 1000000))
    
    echo "Container ID: $CONTAINER_ID"
    echo "Startup time: ${ELAPSED}ms"
    
    # Stop and remove container
    docker stop $CONTAINER_ID > /dev/null 2>&1
    docker rm $CONTAINER_ID > /dev/null 2>&1
}

# Note: These tests will fail without a Lambda Runtime API endpoint
# but they demonstrate the startup time measurement approach
echo "Note: Tests require AWS_LAMBDA_RUNTIME_API endpoint to be available"
echo "Skipping cold start tests (no runtime API available)"

echo -e "\n${GREEN}Build completed successfully!${NC}"
echo ""
echo "To run the containers:"
echo "  docker run -e AWS_LAMBDA_RUNTIME_API=<endpoint> faas-runtime:ubi"
echo "  docker run -e AWS_LAMBDA_RUNTIME_API=<endpoint> faas-runtime:alpine"
