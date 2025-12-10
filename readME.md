# kurtosis-kubernetes-testnet 
> 🚧 Under construction: configs and docs are actively being tuned; expect rapid changes.

Spin up reproducible Ethereum and Optimism devnets on Kubernetes (or kind) using [Kurtosis](https://docs.kurtosis.com/), with pre-wired observability and helper automation via `mise` and `just`.

## 🧭 What this repo gives you
- Canned args for `ethereum-package` and `optimism-package`
- A Kurtosis Starlark package under `DevNet/` for custom L1+L2 layouts
- Pre-baked Grafana/Prometheus/Loki wiring and example dashboards

## ⚡ Quick start
1) Install mise, then at repo root: `mise run bootstrap`
2) Start a cluster (kind by default): `mise run cluster-up` (or `minikube start`)
3) Run a package, e.g. `cd DevNet && kurtosis run . --args-file ./network_params.yaml`

## 🛠️ Handy paths
- `DevNet/ethereum-package-params.yaml` — minimal L1 config
- `DevNet/network_params.yaml` — Optimism devnet config
- `DevNet/justfile` — shortcuts for grafana, ns-authz, enclave helpers

## 🧱 Tech stack
- Go tooling managed via `mise` (for Kurtosis CLI, kind, Helm, kubectl)
- Starlark packages for Kurtosis orchestration under `DevNet/`

## 📜 License
Solidity Foundry License
