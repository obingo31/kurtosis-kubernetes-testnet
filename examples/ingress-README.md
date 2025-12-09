# Example: Ingress Configuration

Use this example to expose Kurtosis via an Ingress controller.

## Prerequisites

- Ingress controller installed (e.g., nginx-ingress, traefik)
- DNS configured to point to your ingress controller

## Deployment

1. Update the host in `ingress.yaml` to match your domain:
```yaml
host: kurtosis.example.com
```

2. Apply the configuration:
```bash
kubectl apply -f ingress.yaml
```

## Accessing the Service

Access Kurtosis at:
- HTTP API: `http://kurtosis.example.com`
- gRPC: Configure your client to use `kurtosis.example.com:80` (or 443 for TLS)

## TLS/SSL

To enable HTTPS:

1. Uncomment the TLS section in `ingress.yaml`
2. Create a TLS secret:
```bash
kubectl create secret tls kurtosis-tls \
  --cert=path/to/tls.crt \
  --key=path/to/tls.key \
  -n kurtosis
```

Or use cert-manager for automatic certificate management:
```yaml
annotations:
  cert-manager.io/cluster-issuer: "letsencrypt-prod"
```

## Notes

- Ensure your ingress controller supports gRPC if using the gRPC API
- Some ingress controllers may require additional annotations for gRPC
