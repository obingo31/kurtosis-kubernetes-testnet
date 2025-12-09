# Kurtosis Helm Chart

This Helm chart deploys Kurtosis on a Kubernetes cluster.

## Prerequisites

- Kubernetes 1.20+
- Helm 3.0+

## Installing the Chart

To install the chart with the release name `kurtosis`:

```bash
helm install kurtosis ./helm/kurtosis
```

Or from the repository root:

```bash
helm install kurtosis ./helm/kurtosis --create-namespace --namespace kurtosis
```

## Uninstalling the Chart

To uninstall/delete the `kurtosis` deployment:

```bash
helm uninstall kurtosis -n kurtosis
```

## Configuration

The following table lists the configurable parameters of the Kurtosis chart and their default values.

| Parameter | Description | Default |
|-----------|-------------|---------|
| `replicaCount` | Number of replicas | `1` |
| `image.repository` | Image repository | `kurtosistech/engine` |
| `image.tag` | Image tag | `latest` |
| `image.pullPolicy` | Image pull policy | `Always` |
| `service.type` | Kubernetes service type | `ClusterIP` |
| `service.grpcPort` | gRPC service port | `9710` |
| `service.httpPort` | HTTP service port | `9711` |
| `loadBalancer.enabled` | Enable LoadBalancer service | `true` |
| `ingress.enabled` | Enable ingress | `false` |
| `ingress.className` | Ingress class name | `nginx` |
| `resources.limits.cpu` | CPU limit | `1000m` |
| `resources.limits.memory` | Memory limit | `1Gi` |
| `resources.requests.cpu` | CPU request | `100m` |
| `resources.requests.memory` | Memory request | `256Mi` |
| `config.logLevel` | Log level | `info` |

Specify each parameter using the `--set key=value[,key=value]` argument to `helm install`. For example:

```bash
helm install kurtosis ./helm/kurtosis \
  --set image.tag=v0.89.0 \
  --set resources.limits.memory=2Gi
```

Alternatively, a YAML file that specifies the values for the parameters can be provided:

```bash
helm install kurtosis ./helm/kurtosis -f custom-values.yaml
```

## Examples

### Install with custom image tag

```bash
helm install kurtosis ./helm/kurtosis \
  --set image.tag=v0.89.0
```

### Install with NodePort service

```bash
helm install kurtosis ./helm/kurtosis \
  --set service.type=NodePort \
  --set loadBalancer.enabled=false
```

### Install with Ingress enabled

```bash
helm install kurtosis ./helm/kurtosis \
  --set ingress.enabled=true \
  --set ingress.hosts[0].host=kurtosis.example.com \
  --set ingress.hosts[0].paths[0].path=/ \
  --set ingress.hosts[0].paths[0].pathType=Prefix
```

### Install with increased resources

```bash
helm install kurtosis ./helm/kurtosis \
  --set resources.limits.cpu=2000m \
  --set resources.limits.memory=2Gi \
  --set resources.requests.cpu=500m \
  --set resources.requests.memory=512Mi
```

## Upgrading

To upgrade the Kurtosis deployment:

```bash
helm upgrade kurtosis ./helm/kurtosis
```

## Values File Example

Create a `custom-values.yaml` file:

```yaml
replicaCount: 1

image:
  repository: kurtosistech/engine
  tag: v0.89.0
  pullPolicy: Always

service:
  type: ClusterIP
  grpcPort: 9710
  httpPort: 9711

loadBalancer:
  enabled: true

resources:
  limits:
    cpu: 2000m
    memory: 2Gi
  requests:
    cpu: 500m
    memory: 512Mi

config:
  logLevel: debug
```

Then install:

```bash
helm install kurtosis ./helm/kurtosis -f custom-values.yaml
```
