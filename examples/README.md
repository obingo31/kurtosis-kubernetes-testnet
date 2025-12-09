# Configuration Examples

This directory contains example configurations for different use cases.

## Available Examples

### 1. Minimal Configuration (`minimal.json`)
A single-node setup for quick testing or development.

```bash
kurtosis run github.com/obingo31/kurtosis-kubernetes-testnet --args-file examples/minimal.json
```

**Use cases:**
- Quick testing
- Minimal resource usage
- Development/debugging

### 2. Standard Configuration (`standard.json`)
The default setup with 3 nodes for typical testing scenarios.

```bash
kurtosis run github.com/obingo31/kurtosis-kubernetes-testnet --args-file examples/standard.json
```

**Use cases:**
- Standard testing
- Multi-node scenarios
- Load balancing tests

### 3. Large Testnet with Monitoring (`large-with-monitoring.json`)
A 10-node setup with Prometheus monitoring enabled.

```bash
kurtosis run github.com/obingo31/kurtosis-kubernetes-testnet --args-file examples/large-with-monitoring.json
```

**Use cases:**
- Performance testing
- Stress testing
- Production-like environments
- Monitoring and metrics collection

## Creating Custom Configurations

You can create your own configuration files based on these examples:

```json
{
  "num_nodes": <number>,
  "network_name": "<your-network-name>",
  "enable_monitoring": <true|false>
}
```

Then run:
```bash
kurtosis run github.com/obingo31/kurtosis-kubernetes-testnet --args-file your-config.json
```

## Inline Configuration

Alternatively, pass configuration directly on the command line:

```bash
kurtosis run github.com/obingo31/kurtosis-kubernetes-testnet '{"num_nodes": 5, "enable_monitoring": true}'
```
