# Kurtosis Kubernetes Testnet

A Kurtosis package for quickly spinning up a Kubernetes testnet environment for development and testing purposes.

## Overview

This Kurtosis package provides a simple way to create a reproducible Kubernetes testnet with multiple nodes. It's designed for testing distributed applications, network configurations, and Kubernetes workloads in an isolated environment.

## Features

- ✅ Configurable number of nodes
- ✅ Automatic service discovery
- ✅ Optional monitoring with Prometheus
- ✅ Lightweight nginx-based nodes
- ✅ Easy to customize and extend

## Prerequisites

- [Kurtosis](https://docs.kurtosis.com/install/) installed on your system
- Docker or Podman running

## Quick Start

### Using the Quick Start Script

For a guided setup, use the included script:

```bash
./quickstart.sh
```

This script will:
- Check if Kurtosis is installed
- Verify Docker is running
- Show usage examples
- Optionally run the testnet

### Manual Quick Start

To run the Kubernetes testnet with default settings (3 nodes):

```bash
kurtosis run github.com/obingo31/kurtosis-kubernetes-testnet
```

## Configuration

You can customize the testnet by passing configuration parameters:

### Basic Configuration

```bash
kurtosis run github.com/obingo31/kurtosis-kubernetes-testnet '{"num_nodes": 5}'
```

### With Monitoring Enabled

```bash
kurtosis run github.com/obingo31/kurtosis-kubernetes-testnet '{"num_nodes": 3, "enable_monitoring": true}'
```

### Configuration Options

| Parameter | Type | Default | Description |
|-----------|------|---------|-------------|
| `num_nodes` | int | 3 | Number of nodes to deploy in the testnet |
| `network_name` | string | "kubernetes-testnet" | Name of the network |
| `enable_monitoring` | bool | false | Enable Prometheus monitoring |

## Usage Examples

### Example 1: Minimal Setup

```bash
kurtosis run github.com/obingo31/kurtosis-kubernetes-testnet
```

### Example 2: Large Testnet with Monitoring

```bash
kurtosis run github.com/obingo31/kurtosis-kubernetes-testnet '{
  "num_nodes": 10,
  "enable_monitoring": true,
  "network_name": "my-k8s-testnet"
}'
```

## Accessing Services

After the testnet is running, you can access individual nodes:

```bash
# List all enclaves
kurtosis enclave ls

# Inspect the enclave
kurtosis enclave inspect <enclave-name>

# Access a specific service
curl http://<service-hostname>:<port>
```

## Managing the Testnet

### Stop the testnet

```bash
kurtosis enclave stop <enclave-name>
```

### Remove the testnet

```bash
kurtosis enclave rm <enclave-name>
```

### Clean up all enclaves

```bash
kurtosis clean -a
```

## Development

### Local Development

To run the package locally during development:

```bash
kurtosis run . '{"num_nodes": 3}'
```

### Extending the Package

The `main.star` file contains the main logic. You can extend it to:
- Add custom services
- Configure networking rules
- Set up databases or other infrastructure
- Implement custom health checks

## Architecture

The testnet consists of:
- **Nodes**: Nginx-based containers simulating testnet nodes
- **Monitoring** (optional): Prometheus for metrics collection
- **Networking**: Automatic service discovery via Kurtosis

## Troubleshooting

### Check Kurtosis version

```bash
kurtosis version
```

### View logs

```bash
kurtosis service logs <enclave-name> <service-name>
```

### Common Issues

- **Docker not running**: Ensure Docker/Podman is running before starting Kurtosis
- **Port conflicts**: Clean up old enclaves with `kurtosis clean -a`
- **Network issues**: Check your Docker network settings

## Contributing

Contributions are welcome! Please feel free to submit issues or pull requests.

## License

MIT License - See LICENSE file for details

## Support

For issues related to:
- **Kurtosis**: Visit [Kurtosis Documentation](https://docs.kurtosis.com)
- **This Package**: Open an issue in this repository