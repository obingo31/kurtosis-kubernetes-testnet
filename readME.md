# kurtosis-kubernetes-testnet 
![Go](https://img.shields.io/badge/Go-Tooling-blue?style=for-the-badge&logo=go&logoColor=white)
![Starlark](https://img.shields.io/badge/Starlark-Kurtosis%20pkg-5e5e5e?style=for-the-badge&logo=google&logoColor=white)
![Kubernetes](https://img.shields.io/badge/Kubernetes-Backend-326ce5?style=for-the-badge&logo=kubernetes&logoColor=white)
![Helm](https://img.shields.io/badge/Helm-Charts-0f1689?style=for-the-badge&logo=helm&logoColor=white)
![License](https://img.shields.io/badge/License-MIT-orange?style=for-the-badge)

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
- Go tooling managed via `mise` (Kurtosis CLI, kind, Helm, kubectl)
- Starlark packages for Kurtosis orchestration under `DevNet/`

## 📜 License
MIT
