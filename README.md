# kurtosis-kubernetes-testnet

Deploy Kurtosis on Kubernetes with production-ready manifests.

## Overview

This repository provides Kubernetes manifests and documentation for deploying [Kurtosis](https://www.kurtosis.com/) on a Kubernetes cluster. Kurtosis is a platform for packaging and launching ephemeral backend stacks with a focus on approachability for the average developer.

## Quick Start

Deploy Kurtosis to your Kubernetes cluster:

```bash
kubectl apply -f kubernetes/base/
```

For detailed installation instructions, configuration options, and troubleshooting, see the [Kubernetes Installation Guide](kubernetes/README.md).

## Repository Structure

```
.
├── README.md                    # This file
└── kubernetes/
    ├── README.md               # Detailed installation guide
    └── base/
        ├── namespace.yaml      # Kurtosis namespace
        ├── serviceaccount.yaml # Service account for engine
        ├── rbac.yaml          # RBAC permissions
        ├── configmap.yaml     # Engine configuration
        ├── deployment.yaml    # Kurtosis engine deployment
        ├── service.yaml       # Services for API access
        └── kustomization.yaml # Kustomize configuration
```

## What's Included

- **Namespace**: Dedicated `kurtosis` namespace
- **RBAC**: ServiceAccount with necessary cluster permissions
- **Deployment**: Kurtosis engine with configurable resources
- **Services**: Both ClusterIP and LoadBalancer for flexible access
- **Configuration**: ConfigMap for engine settings

## Prerequisites

- Kubernetes cluster (v1.20+)
- kubectl configured
- Minimum 2 CPU cores and 4GB RAM available

## Documentation

- [Kubernetes Installation Guide](kubernetes/README.md) - Complete installation and configuration guide
- [Kurtosis Official Documentation](https://docs.kurtosis.com/) - Kurtosis platform documentation

## Support

For issues with these Kubernetes manifests, please open an issue in this repository.

For Kurtosis platform issues, visit the [official Kurtosis repository](https://github.com/kurtosis-tech/kurtosis).

## License

These deployment configurations are provided as-is for deploying Kurtosis on Kubernetes.