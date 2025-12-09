#!/bin/bash
# Kurtosis Kubernetes Deployment Script

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Function to print colored messages
print_info() {
    echo -e "${GREEN}[INFO]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

# Check if kubectl is installed
if ! command -v kubectl &> /dev/null; then
    print_error "kubectl is not installed. Please install kubectl first."
    exit 1
fi

# Check if kubectl can connect to the cluster
if ! kubectl cluster-info &> /dev/null; then
    print_error "Cannot connect to Kubernetes cluster. Please configure kubectl."
    exit 1
fi

print_info "Starting Kurtosis deployment to Kubernetes..."

# Deploy Kurtosis
print_info "Applying Kubernetes manifests..."
kubectl apply -f kubernetes/base/

# Wait for deployment to be ready
print_info "Waiting for Kurtosis engine to be ready..."
kubectl wait --for=condition=available --timeout=300s deployment/kurtosis-engine -n kurtosis

# Get service information
print_info "Deployment successful!"
echo ""
print_info "Service Information:"
kubectl get svc -n kurtosis

echo ""
print_info "Pod Status:"
kubectl get pods -n kurtosis

echo ""
print_info "To access Kurtosis:"
echo "  - From within cluster: kurtosis-engine.kurtosis.svc.cluster.local:9710 (gRPC)"
echo "  - External access: Wait for LoadBalancer IP with 'kubectl get svc kurtosis-engine-lb -n kurtosis'"

echo ""
print_info "To view logs: kubectl logs -n kurtosis -l app=kurtosis"
print_info "To uninstall: kubectl delete -f kubernetes/base/"
