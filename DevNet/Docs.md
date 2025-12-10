# kurtosis-kubernetes-testnet

Spin up reproducible Ethereum and Optimism devnets on Kubernetes (or kind) with [Kurtosis](https://docs.kurtosis.com/), pre-wired observability, and helper automation driven by [mise](https://mise.jdx.dev/) and `just`.

## Contents
- [kurtosis-kubernetes-testnet](#kurtosis-kubernetes-testnet)
  - [Contents](#contents)
  - [Prerequisites](#prerequisites)
  - [Quick start](#quick-start)
  - [Running packages](#running-packages)
    - [Ethereum package](#ethereum-package)
    - [Optimism package (DevNet)](#optimism-package-devnet)
    - [L2 Customization with Hard Fork Transitions](#l2-customization-with-hard-fork-transitions)
    - [Multiple L2 Chains](#multiple-l2-chains)
    - [Rollup Boost for External Block Building](#rollup-boost-for-external-block-building)
    - [Combined L1 + L2 Setup](#combined-l1--l2-setup)
    - [Example Configuration Files](#example-configuration-files)
    - [Managing enclaves](#managing-enclaves)
  - [Observability \& dashboards](#observability--dashboards)
    - [Adding custom dashboards](#adding-custom-dashboards)
    - [Accessing Grafana](#accessing-grafana)
    - [Log Collection](#log-collection)
    - [Managing Grafana via Grizzly](#managing-grafana-via-grizzly)
      - [Grizzly Resources Structure](#grizzly-resources-structure)
      - [Getting Grafana Credentials from Kurtosis](#getting-grafana-credentials-from-kurtosis)
  - [Additional Tools](#additional-tools)
    - [Blob Me Baby](#blob-me-baby)
  - [Additional Recommended Helm Charts](#additional-recommended-helm-charts)
    - [Testnet Tools](#testnet-tools)
    - [Monitoring \& Tracing](#monitoring--tracing)
    - [Signing](#signing)
  - [Helper recipes](#helper-recipes)
    - [`mise` tasks (run from repo root)](#mise-tasks-run-from-repo-root)
    - [`DevNet/justfile`](#devnetjustfile)
  - [Kurtosis Starlark](#kurtosis-starlark)
    - [Key Concepts](#key-concepts)
    - [Writing Starlark Packages](#writing-starlark-packages)
    - [Package Structure](#package-structure)
    - [Running Custom Packages](#running-custom-packages)
    - [Development Tips](#development-tips)
    - [Example: Custom Optimism Testnet](#example-custom-optimism-testnet)
    - [Enclave Builder UI](#enclave-builder-ui)
    - [Configuring the Enclave Builder UI](#configuring-the-enclave-builder-ui)
  - [Helm Chart Development](#helm-chart-development)
    - [Available Commands](#available-commands)
    - [Prerequisites for Helm Development](#prerequisites-for-helm-development)
  - [Repository layout](#repository-layout)
  - [Troubleshooting](#troubleshooting)
  - [Contributing](#contributing)

## Prerequisites
| Tool | Version Source | Notes |
| --- | --- | --- |
| [mise](https://mise.jdx.dev/) | project-scoped (`mise.toml`) | Manages Go, Node, Python, Helm, kubectl, kind, Terraform, Kurtosis |
| Docker + Kubernetes | Docker Desktop or `minikube` | Cluster can be local kind (`mise run cluster-up`) or Minikube |
| [Kurtosis CLI](https://docs.kurtosis.com/install) | Managed by `mise` | Required for running packages |
| [`just`](https://github.com/casey/just) | optional | Convenience commands under `DevNet/justfile` |
| [`grr`](https://github.com/grafana/grizzly) | optional | Grafana provisioning helper (`just configure-grafana`) |

> **Why mise?** Inside this repo, `mise` injects the pinned versions from `mise.toml` without replacing your global tool installs. Outside the repo, your usual binaries take precedence.

## Quick start
1. **Install mise** (one time): follow the [mise docs](https://mise.jdx.dev/getting-started.html). Re-open your shell so `mise` is on `$PATH`.
2. **Bootstrap the toolchain**: at repo root run
	```bash
	mise run bootstrap
	```
	This installs every pinned CLI and verifies they are callable.
3. **Choose a Kubernetes backend**:
	- **kind (default)**: `mise run cluster-up` provisions a local cluster named `kurtosis-testnet` and points `kubectl` at it.
	- **Minikube** (recommended for larger workloads):
	  ```bash
	  minikube start --wait=all --addons=default-storageclass,storage-provisioner
	  kubectl get pods -A            # sanity check
	  ```
4. **Configure Kurtosis to talk to your cluster**:
	```bash
	kurtosis cluster set minikube   # or 'docker' if you stick with kind
	kurtosis engine start --enclave-pool-size 4
	```
	If you need to access the in-cluster engine from your laptop, run `kurtosis gateway` in a separate terminal (ensure port `9710` is free first).
5. **Verify Kurtosis**:
	```bash
	mise run kurtosis-check
	```

## Running packages

### Ethereum package
Use the canned parameters in `ethereum-package-params.yaml` to spin up a minimal beacon/execution testnet with MEV enabled.

```bash
kurtosis run --enclave eth-network github.com/ethpandaops/ethereum-package "$(cat ./ethereum-package-params.yaml)"
```

Edit the YAML to change the package locator (`KURTOSIS_PACKAGE`), client types, or MEV settings. The file uses the same format described in the [ethereum-package docs](https://github.com/ethpandaops/ethereum-package).

### Optimism package (DevNet)
The `DevNet` subdirectory is a Kotlin-style Kurtosis package (`kurtosis.yml`, `main.star`, `network-params.yaml`). From inside `DevNet/` run:

```bash
cd DevNet
kurtosis run . --args-file ./network-params.yaml
```

Highlights of the default config:
- `chains.chain-a.participants` define EL/CL types and images.
- `mev_params` enables Rollup Boost (image can be overridden).
- `observability.grafana_params.dashboard_sources` preloads Optimism dashboards.

For a lighter-weight example (single chain + rollup boost) you can also run:

```bash
kurtosis run github.com/ethpandaops/optimism-package "$(cat ../optimism-package-params.yaml)"
```

### L2 Customization with Hard Fork Transitions
To spin up an L2 chain with specific hard fork transition blocks and custom EL/CL components, use the `network_params` section:

```yaml
optimism_package:
  chains:
    opkurtosis:
      participants:
        node0:
          el:
            type: op-geth
            image: "us-docker.pkg.dev/oplabs-tools-artifacts/images/op-geth:<tag>"
          cl:
            type: op-node
            image: "us-docker.pkg.dev/oplabs-tools-artifacts/images/op-node:<tag>"
        node1:
          el:
            type: op-geth
            image: "us-docker.pkg.dev/oplabs-tools-artifacts/images/op-geth:<tag>"
          cl:
            type: op-node
            image: "us-docker.pkg.dev/oplabs-tools-artifacts/images/op-node:<tag>"
      network_params:
        fjord_time_offset: 0
        granite_time_offset: 0
        holocene_time_offset: 4
        isthmus_time_offset: 8
```

This configuration allows you to:
- Specify custom Docker images for op-geth and op-node
- Control hard fork activation times (fjord, granite, holocene, isthmus)
- Define when each fork activates relative to chain start

### Multiple L2 Chains
You can spin up multiple L2 networks by providing a list of L2 configurations:

```yaml
optimism_package:
  chains:
    op-rollup-one:
      participants:
        node0:
          el:
            type: op-geth
      network_params:
        name: op-rollup-one
        network_id: "3151909"
      blockscout_params:
        enabled: true
    op-rollup-two:
      participants:
        node0:
          el:
            type: op-geth
      network_params:
        network_id: "3151910"
      blockscout_params:
        enabled: true
```

**Important:** When configuring multiple L2s, ensure that the `network_id` and `name` are set to differentiate networks.

### Rollup Boost for External Block Building
Rollup Boost is a sidecar to the sequencer op-node that allows blocks to be built by an external builder on the L2 network.

To use Rollup Boost:

```yaml
optimism_package:
  chains:
    chain0:
      participants:
        node0:
          el_builder:
            type: op-rbuilder
          cl_builder:
            type: op-node
      mev_params:
        enabled: true
        image: "flashbots/rollup-boost:0.7.4"
        builder_host: "localhost"
        builder_port: "8545"
```

You can optionally specify:
- `builder_host`: Host of an external builder outside the Kurtosis enclave
- `builder_port`: Port for the external builder
- `image`: Rollup Boost Docker image to use

### Combined L1 + L2 Setup
You can run both Ethereum L1 and Optimism L2 in the same enclave:

```yaml
ethereum_package:
  participants:
    - el_type: geth
    - el_type: reth
  network_params:
    preset: minimal
    genesis_delay: 5
    additional_preloaded_contracts: '
      {
        "0x4e59b44847b379578588920cA78FbF26c0B4956C": {
          "balance": "0ETH",
          "code": "0x7fffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffe03601600081602082378035828234f58015156039578182fd5b8082525050506014600cf3",
          "storage": {},
          "nonce": "1"
        }
      }
    '
  additional_services:
    - dora
    - blockscout

optimism_package:
  chains:
    chain0:
      participants:
        node0:
          el:
            type: op-geth
```

### Example Configuration Files
Pre-configured examples are available in the `DevNet/` directory:
- **`optimism-l2-custom.yaml`**: Single L2 with custom hard fork transitions
- **`optimism-multi-l2.yaml`**: Multiple L2 chains running simultaneously
- **`optimism-rollup-boost.yaml`**: L2 with Rollup Boost for external block building
- **`ethereum-package-params.yaml`**: Minimal Ethereum L1 testnet

Run with:
```bash
cd DevNet
kurtosis run github.com/ethpandaops/optimism-package --args-file ./optimism-l2-custom.yaml
```

### Managing enclaves
- List: `kurtosis enclave ls`
- Inspect: `kurtosis enclave inspect <enclave-id>`
- Clean up: `kurtosis clean -a`

## Observability & dashboards
Grafana, Prometheus, Loki, and Tempo are provisioned automatically when `observability.enabled` is true in your args file.

### Adding custom dashboards
`optimism-package-params.yaml` demonstrates how to inject additional dashboard sources:

```yaml
observability:
  grafana_params:
	 dashboard_sources:
		- github.com/ethereum-optimism/grafana-dashboards-public/resources
		- github.com/op-rs/kona/docker/recipes/kona-node/grafana
```

You can provide custom dashboard sources to have Grafana pre-populated with your preferred dashboards. Each source should be a URL to a Github repository directory containing at minimum a dashboards directory:

```yaml
optimism_package:
  observability:
    grafana_params:
      dashboard_sources:
        - github.com/<org>/<repo>/<path-to-resources>
```

See [grafana-dashboards-public](https://github.com/ethereum-optimism/grafana-dashboards-public) for more info.

### Accessing Grafana
To access the Grafana UI, you can use the following command after starting the enclave:

```bash
just open-grafana <enclave name>
```

### Log Collection
Note that due to kurtosis limitations, log collection is not enabled by default, and is only supported for the Kubernetes backend. To enable log collection, you must set the following parameter:

```yaml
optimism_package:
  observability:
    enable_k8s_features: true
```

Note that since kurtosis runs pods using the namespace's default ServiceAccount, which is not typically able to modify cluster-level resources, such as ClusterRoles, as the promtail Helm chart requires, you must also install the ns-authz Helm chart to the Kubernetes cluster serving as the kurtosis backend using the following command:

```bash
just install-ns-authz
```

### Managing Grafana via Grizzly
Build or install `grr`, then use the `just` helpers:

```bash
cd DevNet
just configure-grafana prod https://your-grafana.example.com <token>
just use-context prod
just push prod
```

Optionally, set the following field(s), depending on your authentication method with the given Grafana instance:

- A token if using a Grafana service account (recommended)
- A username and password if using basic authentication

Next, consider setting a context to save this configuration.

Once you have configured your authentication method, you are ready to use the Grizzly server to view and/or edit resources.

`just push` uploads folders first, then dashboards, working around known Grizzly quirks. You can also use `just pull` to download existing resources and `just list-resources` to see what's available.

#### Grizzly Resources Structure
Grizzly manages Grafana resources through YAML files in the `resources/` directory:

```
resources/
├── folders/          # Folder definitions
│   └── kurtosis.yaml
└── dashboards/       # Dashboard definitions
    └── overview.yaml
```

#### Getting Grafana Credentials from Kurtosis
When running a Kurtosis package with observability enabled, you can get the Grafana URL and API token:

```bash
# Get the Grafana service URL
just open-grafana <enclave-name>

# Or manually get the URL
mise x -- kurtosis service inspect <enclave-name> grafana

# To get an API token, access Grafana UI and create a service account token
# Then update your Grizzly config:
grr config set grafana.token <actual-token>
```

`just push` uploads folders first, then dashboards, working around known Grizzly quirks.

## Additional Tools

### Blob Me Baby
A tool for sending arbitrary blob data in well-formatted blobs to test Ethereum's blob transactions.

**Deploy:**
```bash
mise x -- helm upgrade --install blob-me-baby ethereum-helm-charts/blob-me-baby --set config.rpcUrl="http://127.0.0.1:33287" --namespace default
```

**Access:**
```bash
kubectl port-forward svc/blob-me-baby 8080:8080
```
Then visit http://localhost:8080 to send blob transactions to your L1 network.

## Additional Recommended Helm Charts

From the `ethereum-helm-charts` repository, here are some useful charts you can add to enhance your testnet:

### Testnet Tools
- **testnet-faucet**: Web faucet for distributing test ETH
  ```bash
  helm install testnet-faucet ethereum-helm-charts/testnet-faucet --set faucet.rpcUrl="http://your-rpc-url" --set faucet.privateKey="your-private-key"
  ```
- **testnet-homepage**: Simple website displaying testnet information
  ```bash
  helm install testnet-homepage ethereum-helm-charts/testnet-homepage
  ```

### Monitoring & Tracing
- **tracoor-***: Ethereum beacon data and execution trace explorers (agent/server/single modes)
  ```bash
  helm install tracoor ethereum-helm-charts/tracoor-single  # or tracoor-server, tracoor-agent
  ```
- **xatu-***: Ethereum p2p monitoring tools (discovery, mimicry, sentry, cannon, server)
  ```bash
  helm install xatu ethereum-helm-charts/xatu-server  # or other xatu variants
  ```

### Signing
- **web3signer**: Remote signing service for Ethereum validators
  ```bash
  helm install web3signer ethereum-helm-charts/web3signer
  ```

Use `make lint` from the project root to validate any charts you add.

## Helper recipes

### `mise` tasks (run from repo root)
| Task | Description |
| --- | --- |
| `mise run bootstrap` | Installs and verifies every pinned CLI |
| `mise run cluster-up` / `mise run cluster-down` | Manages the local kind cluster named `kurtosis-testnet` |
| `mise run kurtosis-check` | Prints Kurtosis CLI and engine status |

### `DevNet/justfile`
| Recipe | Purpose |
| --- | --- |
| `just install-ns-authz` | Installs the `ns-authz` resources (ServiceAccount, ClusterRole, ClusterRoleBinding) for namespace authorization |
| `just uninstall-ns-authz` | Removes the ns-authz resources |
| `just lint` / `just test` | Run project linting (`kurtosis lint`, `kurtosis-lint`) and the package test suite |
| `just configure-grafana <ctx> <url> <token>` | Creates a Grizzly context and stores credentials |
| `just use-context <ctx>` | Switches to the specified Grizzly context |
| `just push <ctx>` | Pushes Grafana folders and dashboards via Grizzly |
| `just pull <ctx>` | Pulls existing Grafana resources via Grizzly |
| `just list-resources <ctx>` | Lists available Grafana resources via Grizzly |
| `just open-grafana <enclave>` | Opens the grafana service URL for the given enclave |

## Kurtosis Starlark

[Kurtosis](https://docs.kurtosis.com/) uses [Starlark](https://github.com/bazelbuild/starlark) (a Python-like configuration language) to define and run packages. Starlark scripts allow you to programmatically define services, networks, and configurations for reproducible test environments.

### Key Concepts
- **Packages**: Reusable modules that define services, networks, and configurations
- **Enclaves**: Isolated environments containing services and networks
- **Services**: Individual containers (e.g., Ethereum nodes, databases) with their configurations
- **Starlark Files**: `.star` files containing the package logic

### Writing Starlark Packages
Create a `main.star` file in your package directory:

```python
# Example: DevNet/main.star
def run(plan, args):
    # Add services to the plan
    plan.add_service(
        name="my-service",
        config=ServiceConfig(
            image="nginx:latest",
            ports={"http": PortSpec(number=80, transport_protocol="TCP")}
        )
    )
    
    # Return outputs
    return struct(
        service_url="http://my-service:80"
    )
```

### Package Structure
```
DevNet/
├── main.star          # Main package logic
├── kurtosis.yml       # Package metadata
├── justfile           # Convenience commands
└── params files       # Configuration parameters
```

### Running Custom Packages
```bash
# Run with parameters
kurtosis run . --args-file optimism-package-params.yaml

# Or run GitHub packages
kurtosis run github.com/ethpandaops/optimism-package
```

### Development Tips
- Use `kurtosis lint` to validate your Starlark code
- Test packages with `kurtosis run --dry-run` 
- Access the Kurtosis API documentation at https://docs.kurtosis.com/reference
- Starlark is deterministic - same inputs always produce same outputs

### Example: Custom Optimism Testnet
This project's `DevNet/main.star` demonstrates:
- Importing the official optimism-package
- Overriding parameters for custom configurations
- Adding additional services (like monitoring tools)

### Enclave Builder UI
You can now build enclaves without writing code using the Kurtosis Enclave Builder UI. This visual interface allows you to:

- **Drag & Drop Services**: Add pre-built services (databases, message queues, etc.) to your enclave
- **Configure Networks**: Set up service connections and networking rules visually
- **Real-time Preview**: See your enclave topology as you build
- **One-Click Deployment**: Deploy your configured enclave directly to Kubernetes

**Access the Builder**:
```bash
kurtosis web
```
This opens the Kurtosis Web UI (beta) at `http://localhost:9711/enclaves`, where you can construct enclaves interactively using a visual interface.

> **Note**: The Kurtosis Web UI is currently in beta and may not be fully functional in all local development environments. If the command exits without opening a browser or the page doesn't load, the web server may not be running. In such cases, use the CLI commands for enclave management.

### Configuring the Enclave Builder UI
The Enclave Builder UI connects to your Kurtosis engine and can be configured for different environments:

**Prerequisites**:
- Kurtosis CLI installed and configured
- Active Kubernetes cluster connection
- Web browser for the UI

**Configuration Options**:
```bash
# Basic usage
kurtosis web

# The UI runs on http://localhost:9711/enclaves
# Access via browser or use port forwarding in Codespaces
```

**UI Features**:
- **Service Catalog**: Browse and add pre-configured services (PostgreSQL, Redis, Nginx, etc.)
- **Ethereum Services**: Add Ethereum clients, testnets, and monitoring tools
- **Custom Services**: Define your own containers with ports, environment variables, and volumes
- **Network Configuration**: Set up service-to-service communication and external access
- **Resource Management**: Configure CPU, memory, and storage for each service
- **Export Options**: Generate Starlark code, Docker Compose, or Kubernetes manifests

**Integration with Your Project**:
The builder can import existing Starlark packages and modify them visually. Export your designs back to `main.star` files for version control.

**Troubleshooting**:
- Ensure Kurtosis engine is running: `kurtosis engine status`
- Check cluster connectivity: `kubectl cluster-info`
- Clear browser cache if UI doesn't load
- Use `kurtosis enclave builder --help` for all options

**When to Use**:
- Prototyping new service architectures
- Learning Kurtosis concepts before writing code
- Quick setups for development environments
- Collaborative enclave design

## Helm Chart Development

This project includes a `Makefile` for developing and testing Helm charts (e.g., when adding charts from `ethereum-helm-charts`).

### Available Commands
| Command | Description |
| --- | --- |
| `make init` | Install pre-commit hooks for code quality |
| `make lint` | Lint Helm charts using `chart-testing` |
| `make docs` | Generate documentation for Helm charts using `helm-docs` |
| `make clean` | Uninstall pre-commit hooks |

### Prerequisites for Helm Development
- Docker (for running linting and docs tools in containers)
- [pre-commit](https://pre-commit.com/) (installed via `make init`)

## Repository layout
```
.
├── DevNet/
│   ├── justfile                     # Grafana & lint/test helpers
│   ├── kurtosis.yml                 # Declarative package definition
│   ├── main.star                    # Kurtosis package entrypoint
│   ├── mise.toml                    # DevNet-specific tool pins (if needed)
│   ├── network-params.yaml          # Rich Optimism network configuration
│   └── resources/                   # Grafana folders & dashboards (for Grizzly)
├── ethereum-package-params.yaml     # Sample arguments for ethpandaops/ethereum-package
├── optimism-package-params.yaml     # Sample arguments with rollup-boost + dashboards
├── mise.toml                        # Top-level toolchain + helper tasks
└── README.md
```

## Troubleshooting
- **Port 9710 already in use** – ensure no stray `kurtosis gateway` or engine container is running: `pkill -f "kurtosis gateway" && kurtosis engine stop`.
- **"invalid configuration: no configuration has been provided"** – export `KUBECONFIG` to the kubeconfig you want Kurtosis to use (e.g. `export KUBECONFIG=$HOME/.kube/config`) before running `kurtosis cluster set ...`.
- **Helm repo `util` not found** – run `helm repo add util <chart-index-url>` before `just install-ns-authz`.
- **Args file fails to parse** – validate YAML with `ruby -ryaml -e "YAML.safe_load(File.read('<file>'))"` or `yamllint` before invoking Kurtosis.
- **Gateway can’t see the engine on Kubernetes** – make sure `kurtosis engine start --enclave-pool-size 4` succeeded and that your `kubectl` context points at a reachable cluster.

## Contributing
1. Format the DevNet package with `just fix-style`.
2. Keep `mise.toml`, `network-params.yaml`, and sample params up to date when bumping dependencies.
3. Open a PR detailing any new Helm repos, Grafana sources, or enclave recipes you add.