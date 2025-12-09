#!/bin/bash
# Quick start script for Kurtosis Kubernetes Testnet
# This script helps verify the setup and run the testnet

set -e

echo "=== Kurtosis Kubernetes Testnet Quick Start ==="
echo ""

# Check if Kurtosis is installed
if ! command -v kurtosis &> /dev/null; then
    echo "❌ Error: Kurtosis is not installed."
    echo ""
    echo "Please install Kurtosis first:"
    echo "  macOS:   brew install kurtosis-tech/tap/kurtosis-cli"
    echo "  Linux:   curl -fsSL https://get.kurtosis.com | bash"
    echo ""
    echo "Visit https://docs.kurtosis.com/install/ for more details."
    exit 1
fi

echo "✅ Kurtosis is installed"
kurtosis version
echo ""

# Check if Docker is running
if ! docker info &> /dev/null; then
    echo "❌ Error: Docker is not running."
    echo "Please start Docker and try again."
    exit 1
fi

echo "✅ Docker is running"
echo ""

# Show usage
echo "Usage examples:"
echo ""
echo "1. Run with default configuration (3 nodes):"
echo "   kurtosis run ."
echo ""
echo "2. Run with custom configuration:"
echo "   kurtosis run . '{\"num_nodes\": 5}'"
echo ""
echo "3. Run with monitoring enabled:"
echo "   kurtosis run . '{\"enable_monitoring\": true}'"
echo ""
echo "4. Run with example configuration file:"
echo "   kurtosis run . --args-file examples/minimal.json"
echo ""
echo "5. Clean up all enclaves:"
echo "   kurtosis clean -a"
echo ""

# Ask user what they want to do
read -p "Do you want to run the testnet now with default settings? (y/n) " -n 1 -r
echo ""

if [[ $REPLY =~ ^[Yy]$ ]]; then
    echo "Starting testnet with default configuration..."
    kurtosis run .
    echo ""
    echo "✅ Testnet is running!"
    echo ""
    echo "To inspect: kurtosis enclave inspect <enclave-name>"
    echo "To stop:    kurtosis enclave stop <enclave-name>"
    echo "To remove:  kurtosis enclave rm <enclave-name>"
else
    echo "Skipping testnet run. Use the commands above when ready."
fi

echo ""
echo "=== Quick Start Complete ==="
