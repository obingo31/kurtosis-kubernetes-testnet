# Contributing to Kurtosis Kubernetes Testnet

Thank you for your interest in contributing to this project! This guide will help you understand how to customize and extend the Kurtosis Kubernetes deployment.

## Repository Structure

```
.
├── README.md                    # Main documentation
├── .gitignore                   # Git ignore file
├── deploy.sh                    # Quick deployment script
├── kubernetes/                  # Kubernetes manifests
│   ├── README.md               # Detailed installation guide
│   └── base/                   # Base manifests
│       ├── namespace.yaml      # Kurtosis namespace
│       ├── serviceaccount.yaml # Service account
│       ├── rbac.yaml          # RBAC permissions
│       ├── configmap.yaml     # Engine configuration
│       ├── deployment.yaml    # Engine deployment
│       ├── service.yaml       # Services
│       └── kustomization.yaml # Kustomize config
├── helm/                        # Helm chart
│   └── kurtosis/
│       ├── Chart.yaml
│       ├── values.yaml
│       ├── README.md
│       └── templates/
└── examples/                    # Example configurations
    ├── nodeport-service.yaml
    ├── nodeport-README.md
    ├── ingress.yaml
    └── ingress-README.md
```

## How to Customize

### 1. Modifying Kubernetes Manifests

#### Update Resource Limits

Edit `kubernetes/base/deployment.yaml`:

```yaml
resources:
  limits:
    cpu: 2000m        # Change CPU limit
    memory: 2Gi       # Change memory limit
  requests:
    cpu: 500m         # Change CPU request
    memory: 512Mi     # Change memory request
```

#### Change Image Version

Edit `kubernetes/base/deployment.yaml`:

```yaml
containers:
  - name: engine
    image: kurtosistech/engine:v0.89.0  # Specify exact version
```

#### Modify Configuration

Edit `kubernetes/base/configmap.yaml`:

```yaml
data:
  engine-config.yml: |
    log-level: debug  # Change to debug, info, warn, or error
    default-enclave-config:
      cpu-limit: "2000m"
      memory-limit: "2Gi"
```

### 2. Customizing the Helm Chart

#### Create a Custom Values File

Create `my-values.yaml`:

```yaml
replicaCount: 2

image:
  tag: v0.89.0

resources:
  limits:
    cpu: 2000m
    memory: 2Gi

ingress:
  enabled: true
  hosts:
    - host: kurtosis.mycompany.com
      paths:
        - path: /
          pathType: Prefix
```

Deploy with:

```bash
helm install kurtosis ./helm/kurtosis -f my-values.yaml
```

### 3. Creating New Examples

To add a new deployment example:

1. Create a directory in `examples/` (e.g., `examples/production/`)
2. Add your manifests
3. Create a README explaining the use case
4. Update the main README to reference it

### 4. Adding Overlays with Kustomize

Create environment-specific overlays:

```bash
mkdir -p kubernetes/overlays/production
```

Create `kubernetes/overlays/production/kustomization.yaml`:

```yaml
apiVersion: kustomize.config.k8s.io/v1beta1
kind: Kustomization

bases:
  - ../../base

namespace: kurtosis-prod

patches:
  - patch: |-
      - op: replace
        path: /spec/replicas
        value: 3
    target:
      kind: Deployment
      name: kurtosis-engine

resources:
  - ingress.yaml
```

Deploy with:

```bash
kubectl apply -k kubernetes/overlays/production
```

## Testing Your Changes

### 1. Validate YAML Syntax

```bash
# Using Python
python3 -c "
import yaml
import glob
for f in glob.glob('kubernetes/base/*.yaml'):
    with open(f) as file:
        yaml.safe_load_all(file)
print('All YAML files valid')
"
```

### 2. Lint Helm Chart

```bash
helm lint helm/kurtosis
```

### 3. Test Helm Rendering

```bash
helm template kurtosis helm/kurtosis --namespace kurtosis > /tmp/output.yaml
kubectl apply --dry-run=client -f /tmp/output.yaml
```

### 4. Test Kustomize Build

```bash
kubectl kustomize kubernetes/base/ > /tmp/output.yaml
```

## Development Workflow

1. **Fork the repository** (if contributing to the main project)

2. **Create a branch**:
   ```bash
   git checkout -b feature/my-enhancement
   ```

3. **Make your changes**

4. **Test your changes** locally if possible

5. **Commit your changes**:
   ```bash
   git add .
   git commit -m "Description of changes"
   ```

6. **Push to your fork**:
   ```bash
   git push origin feature/my-enhancement
   ```

7. **Create a Pull Request**

## Common Customizations

### Using a Different Namespace

Replace `kurtosis` with your preferred namespace in:
- `kubernetes/base/namespace.yaml`
- `kubernetes/base/kustomization.yaml`
- All `metadata.namespace` fields

### Adding Environment Variables

Edit `kubernetes/base/deployment.yaml`:

```yaml
env:
  - name: KURTOSIS_BACKEND_TYPE
    value: "kubernetes"
  - name: CUSTOM_VAR
    value: "custom_value"
```

### Adding Volume Mounts

For persistent storage, add to `kubernetes/base/deployment.yaml`:

```yaml
volumes:
  - name: data
    persistentVolumeClaim:
      claimName: kurtosis-data

volumeMounts:
  - name: data
    mountPath: /data
```

Then create a PVC in `kubernetes/base/pvc.yaml`.

### Using Secrets

Create a secret:

```bash
kubectl create secret generic kurtosis-secrets \
  --from-literal=api-key=your-key \
  -n kurtosis
```

Reference in deployment:

```yaml
env:
  - name: API_KEY
    valueFrom:
      secretKeyRef:
        name: kurtosis-secrets
        key: api-key
```

## Documentation

When making changes, please update:

1. **Main README.md** - For user-facing changes
2. **kubernetes/README.md** - For manifest changes
3. **helm/kurtosis/README.md** - For Helm chart changes
4. **This file** - For contributing guidelines

## Getting Help

- Review existing documentation in the `kubernetes/` and `helm/` directories
- Check [Kurtosis official documentation](https://docs.kurtosis.com/)
- Open an issue for questions or problems

## Code of Conduct

Be respectful and constructive in all interactions.

## License

By contributing, you agree that your contributions will be licensed under the same terms as the project.
