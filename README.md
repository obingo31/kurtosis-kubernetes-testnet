# kurtosis-kubernetes-testnet

Deploy Kurtosis on Kubernetes with production-ready manifests.

## Overview

This repository provides Kubernetes manifests and documentation for deploying [Kurtosis](https://www.kurtosis.com/) on a Kubernetes cluster. Kurtosis is a platform for packaging and launching ephemeral backend stacks with a focus on approachability for the average developer.

## Quick Start

Deploy Kurtosis to your Kubernetes cluster:

```bash
kubectl apply -f kubernetes/base/
```

**New to this?** Check out the [Quickstart Guide](QUICKSTART.md) for a step-by-step walkthrough!

For detailed installation instructions, configuration options, and troubleshooting, see the [Kubernetes Installation Guide](kubernetes/README.md).

## Repository Structure

```
.
├── README.md                    # This file
├── QUICKSTART.md               # 5-minute deployment guide
├── CONTRIBUTING.md             # Customization and contribution guide
├── deploy.sh                   # Automated deployment script
├── kubernetes/
│   ├── README.md               # Detailed installation guide
│   └── base/
│       ├── namespace.yaml      # Kurtosis namespace
│       ├── serviceaccount.yaml # Service account for engine
│       ├── rbac.yaml          # RBAC permissions
│       ├── configmap.yaml     # Engine configuration
│       ├── deployment.yaml    # Kurtosis engine deployment
│       ├── service.yaml       # Services for API access
│       └── kustomization.yaml # Kustomize configuration
├── helm/
│   └── kurtosis/              # Helm chart for Kurtosis
│       ├── Chart.yaml
│       ├── values.yaml
│       ├── README.md
│       └── templates/
└── examples/
    ├── nodeport-service.yaml  # NodePort service example
    ├── ingress.yaml           # Ingress configuration example
    └── *.md                   # Example documentation
```

## What's Included

- **Namespace**: Dedicated `kurtosis` namespace
- **RBAC**: ServiceAccount with necessary cluster permissions
- **Deployment**: Kurtosis engine with configurable resources
- **Services**: Both ClusterIP and LoadBalancer for flexible access
- **Configuration**: ConfigMap for engine settings
- **Helm Chart**: Alternative deployment method with customizable values
- **Examples**: NodePort and Ingress configurations
- **Scripts**: Automated deployment script for quick setup

## Prerequisites

- Kubernetes cluster (v1.20+)
- kubectl configured
- Minimum 2 CPU cores and 4GB RAM available

## Documentation

- [Quickstart Guide](QUICKSTART.md) - Get started in 5 minutes
- [Kubernetes Installation Guide](kubernetes/README.md) - Complete installation and configuration guide
- [Helm Chart Documentation](helm/kurtosis/README.md) - Helm-based deployment
- [Contributing Guide](CONTRIBUTING.md) - How to customize and extend
- [Examples](examples/) - NodePort, Ingress, and other configurations
- [Kurtosis Official Documentation](https://docs.kurtosis.com/) - Kurtosis platform documentation

## Support

For issues with these Kubernetes manifests, please open an issue in this repository.

For Kurtosis platform issues, visit the [official Kurtosis repository](https://github.com/kurtosis-tech/kurtosis).

## License

These deployment configurations are provided as-is for deploying Kurtosis on Kubernetes.