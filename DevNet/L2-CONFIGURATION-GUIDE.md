# L2 Configuration Guide

This guide covers advanced Optimism L2 customization options available in the Kurtosis testnet framework.

## Overview

The Kurtosis framework allows you to configure Optimism L2 chains with:
- Custom hard fork transitions (Fjord, Granite, Holocene, Isthmus)
- Multiple simultaneous L2 networks
- Rollup Boost for MEV-aware block building
- Combined L1 + L2 setups
- Custom EL/CL client images

## Configuration Examples

### 1. L2 with Custom Hard Fork Transitions

**File:** `optimism-l2-custom.yaml`

This example shows how to:
- Deploy op-geth and op-node with custom images
- Control hard fork activation times
- Enable observability stack (Grafana, Prometheus, Loki)
- Deploy Blockscout for block exploration

**Key Parameters:**
- `fjord_time_offset`: Seconds after genesis when Fjord activates
- `granite_time_offset`: Seconds after genesis when Granite activates
- `holocene_time_offset`: Seconds after genesis when Holocene activates
- `isthmus_time_offset`: Seconds after genesis when Isthmus activates

**Usage:**
```bash
kurtosis run github.com/ethpandaops/optimism-package \
  --args-file ./optimism-l2-custom.yaml \
  --enclave l2-custom
```

### 2. Multiple L2 Chains

**File:** `optimism-multi-l2.yaml`

Run multiple L2 networks in parallel with different configurations.

**Key Features:**
- Each chain has unique `network_id` and `name`
- Independent hard fork schedules per chain
- Each chain can have different participant configurations
- Shared or independent observability stacks

**Important:** Different `network_id` values prevent transaction replay attacks between chains.

**Usage:**
```bash
kurtosis run github.com/ethpandaops/optimism-package \
  --args-file ./optimism-multi-l2.yaml \
  --enclave multi-l2
```

**Accessing Multiple Chains:**
```bash
# Get chain endpoints
kurtosis enclave inspect multi-l2

# Each chain will have separate RPC endpoints
# op-mainnet-test and op-testnet-test will be available
```

### 3. Rollup Boost Configuration

**File:** `optimism-rollup-boost.yaml`

Enable MEV-aware block building on L2 using Rollup Boost.

**Key Components:**
- `flashbots/rollup-boost`: Sidecar for MEV handling
- `op-rbuilder`: Optional external builder type
- Configurable builder host/port for external builders

**Configuration Options:**
```yaml
mev_params:
  enabled: true
  image: "flashbots/rollup-boost:0.7.4"
  builder_host: "localhost"        # or external IP
  builder_port: "8545"              # builder RPC port
```

**External Builder Setup:**
```yaml
mev_params:
  enabled: true
  image: "flashbots/rollup-boost:0.7.4"
  builder_host: "builder.example.com"
  builder_port: "8545"
```

**Usage:**
```bash
kurtosis run github.com/ethpandaops/optimism-package \
  --args-file ./optimism-rollup-boost.yaml \
  --enclave rollup-boost
```

## Custom Client Images

You can specify custom Docker images for op-geth and op-node:

```yaml
chains:
  custom-chain:
    participants:
      node0:
        el:
          type: op-geth
          image: "us-docker.pkg.dev/oplabs-tools-artifacts/images/op-geth:v1.101413.1"
        cl:
          type: op-node
          image: "us-docker.pkg.dev/oplabs-tools-artifacts/images/op-node:v1.3.0"
```

Replace the image tags with:
- Specific version tags from Docker registries
- Custom built images from your registry
- Local images (for development)

## Combined L1 + L2 Setup

To run both Ethereum L1 and Optimism L2:

```yaml
ethereum_package:
  participants:
    - el_type: geth
  network_params:
    preset: minimal
  additional_services:
    - blockscout

optimism_package:
  chains:
    l2-chain:
      participants:
        node0:
          el:
            type: op-geth
```

The L2 automatically detects and uses the L1 as settlement layer.

## Observability Stack

All configurations support the full observability stack:

```yaml
observability:
  enabled: true
  enable_k8s_features: true
  grafana_params:
    dashboard_sources:
      - github.com/ethereum-optimism/grafana-dashboards-public/resources
```

**Accessing Grafana:**
```bash
just open-grafana <enclave-name>
```

**Enable Log Collection (Kubernetes only):**
```bash
just install-ns-authz  # Set up required RBAC
```

Then set in config:
```yaml
observability:
  enable_k8s_features: true
```

## Managing Enclaves

```bash
# List all enclaves
mise x -- kurtosis enclave ls

# Inspect specific enclave
mise x -- kurtosis enclave inspect <enclave-id>

# View service endpoints
mise x -- kurtosis service ls <enclave-id>

# Clean up all enclaves
mise x -- kurtosis clean -a
```

## Troubleshooting

### Hard Fork Validation
If you see errors about required parameters for a specific fork, ensure:
1. The fork is properly scheduled (epoch or timestamp offset)
2. Network has sufficient validators for the fork requirements
3. All required parameters are included (e.g., withdrawal_address for Shanghai)

### Multiple Chain Issues
- Ensure unique `network_id` for each chain
- Verify `name` field is unique
- Check Blockscout configuration if explorer issues arise

### Rollup Boost Problems
- Verify builder service is running (`kurtosis service ls`)
- Check builder RPC connectivity
- Review logs: `kurtosis service logs <enclave-id> <service-name>`

## Performance Considerations

- **Participant Count:** More participants = more computational resources
- **Hard Forks:** Each fork activation may require temporary increased resources
- **Observability:** Grafana/Prometheus can use 500MB+ RAM
- **Storage:** Blockscout indexing requires additional disk space

## Next Steps

1. Start with `optimism-l2-custom.yaml` for basic setup
2. Transition to `optimism-multi-l2.yaml` for testing multiple chains
3. Add Rollup Boost when MEV testing is needed
4. Use `ethereum-package-params.yaml` as settlement layer reference
