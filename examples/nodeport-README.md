# Example: NodePort Deployment

Use this example when your Kubernetes cluster doesn't support LoadBalancer services (e.g., bare metal, local clusters like minikube).

## Deployment

```bash
kubectl apply -f nodeport-service.yaml
```

## Accessing the Service

1. Get the NodePort:
```bash
kubectl get svc kurtosis-engine-nodeport -n kurtosis
```

2. Get a node IP:
```bash
kubectl get nodes -o wide
```

3. Access Kurtosis:
- gRPC: `<NODE-IP>:<NODEPORT-GRPC>`
- HTTP: `<NODE-IP>:<NODEPORT-HTTP>`

## Notes

- NodePort range is typically 30000-32767
- Ensure your firewall allows traffic to the NodePort
- For minikube, use `minikube ip` to get the node IP
