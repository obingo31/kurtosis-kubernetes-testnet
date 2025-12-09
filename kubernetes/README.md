# Kurtosis Kubernetes Installation

This repository provides Kubernetes manifests for deploying Kurtosis on a Kubernetes cluster.

## Prerequisites

- A running Kubernetes cluster (version 1.20+)
- `kubectl` configured to communicate with your cluster
- Sufficient cluster resources (minimum 2 CPU cores and 4GB RAM available)

## Quick Start

### Option 1: Using kubectl

Deploy Kurtosis to your cluster with a single command:

```bash
kubectl apply -f kubernetes/base/
```

This will create:
- A dedicated `kurtosis` namespace
- ServiceAccount and RBAC permissions for the Kurtosis engine
- ConfigMap with engine configuration
- Kurtosis engine Deployment
- Services for accessing the Kurtosis API

### Option 2: Using Kustomize

If you have kustomize installed or are using kubectl 1.14+:

```bash
kubectl apply -k kubernetes/base/
```

## Deployment Components

### Namespace
- **Name**: `kurtosis`
- All Kurtosis components are deployed in this namespace

### RBAC
- **ServiceAccount**: `kurtosis-engine`
- **ClusterRole**: Grants permissions to manage:
  - Namespaces (for enclaves)
  - Pods, Services, ConfigMaps, Secrets
  - Deployments, StatefulSets, Jobs
  - PersistentVolumeClaims

### Kurtosis Engine
- **Image**: `kurtosistech/engine:latest`
- **Replicas**: 1
- **Ports**:
  - gRPC API: 9710
  - HTTP Gateway: 9711
- **Resources**:
  - Requests: 100m CPU, 256Mi memory
  - Limits: 1000m CPU, 1Gi memory

### Services
Two services are created:

1. **kurtosis-engine** (ClusterIP)
   - Internal cluster access
   - Ports: 9710 (gRPC), 9711 (HTTP)

2. **kurtosis-engine-lb** (LoadBalancer)
   - External access
   - Ports: 9710 (gRPC), 9711 (HTTP)

## Accessing Kurtosis

### From within the cluster

```bash
# gRPC API
kurtosis-engine.kurtosis.svc.cluster.local:9710

# HTTP Gateway
kurtosis-engine.kurtosis.svc.cluster.local:9711
```

### From outside the cluster

Get the LoadBalancer external IP:

```bash
kubectl get svc kurtosis-engine-lb -n kurtosis
```

Wait for the EXTERNAL-IP to be assigned, then access:
- gRPC: `<EXTERNAL-IP>:9710`
- HTTP: `<EXTERNAL-IP>:9711`

## Configuration

The Kurtosis engine configuration is managed via ConfigMap. To modify:

1. Edit `kubernetes/base/configmap.yaml`
2. Apply changes:
   ```bash
   kubectl apply -f kubernetes/base/configmap.yaml
   ```
3. Restart the engine:
   ```bash
   kubectl rollout restart deployment/kurtosis-engine -n kurtosis
   ```

### Configuration Options

- **log-level**: Set logging level (debug, info, warn, error)
- **cpu-limit**: Default CPU limit for enclave containers
- **memory-limit**: Default memory limit for enclave containers

## Verifying the Installation

Check that all components are running:

```bash
# Check namespace
kubectl get namespace kurtosis

# Check deployment
kubectl get deployment -n kurtosis

# Check pods
kubectl get pods -n kurtosis

# Check services
kubectl get svc -n kurtosis

# View logs
kubectl logs -n kurtosis -l app=kurtosis,component=engine
```

Expected output:
```
NAME               READY   STATUS    RESTARTS   AGE
kurtosis-engine-*  1/1     Running   0          1m
```

## Upgrading

To upgrade to a newer version of Kurtosis:

1. Update the image tag in `kubernetes/base/deployment.yaml`:
   ```yaml
   image: kurtosistech/engine:v0.XX.XX
   ```

2. Apply the changes:
   ```bash
   kubectl apply -f kubernetes/base/deployment.yaml
   ```

## Uninstalling

To remove Kurtosis from your cluster:

```bash
kubectl delete -f kubernetes/base/
```

Or with kustomize:

```bash
kubectl delete -k kubernetes/base/
```

## Troubleshooting

### Pod not starting

Check pod status and logs:
```bash
kubectl describe pod -n kurtosis -l app=kurtosis
kubectl logs -n kurtosis -l app=kurtosis
```

### Permission errors

Ensure the ClusterRole and ClusterRoleBinding are properly created:
```bash
kubectl get clusterrole kurtosis-engine
kubectl get clusterrolebinding kurtosis-engine
```

### Service not accessible

Check service status:
```bash
kubectl get svc -n kurtosis
kubectl describe svc kurtosis-engine-lb -n kurtosis
```

For LoadBalancer services, ensure your cluster supports LoadBalancer provisioning.

## Advanced Configuration

### Using NodePort instead of LoadBalancer

If your cluster doesn't support LoadBalancer, edit `kubernetes/base/service.yaml`:

```yaml
spec:
  type: NodePort
```

Then access via:
```
<NODE-IP>:<NODE-PORT>
```

### Resource Limits

Adjust resource requests/limits in `kubernetes/base/deployment.yaml` based on your workload:

```yaml
resources:
  requests:
    cpu: 500m
    memory: 512Mi
  limits:
    cpu: 2000m
    memory: 2Gi
```

### High Availability

For production deployments, consider:
1. Increasing replicas (requires session affinity or state management)
2. Adding PersistentVolume for state
3. Implementing pod anti-affinity rules

## Support

For issues and questions:
- Kurtosis Documentation: https://docs.kurtosis.com/
- GitHub Issues: https://github.com/kurtosis-tech/kurtosis/issues

## License

This deployment configuration is provided as-is for deploying Kurtosis on Kubernetes.
