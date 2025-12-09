# Kurtosis Kubernetes Quickstart

Get Kurtosis running on your Kubernetes cluster in minutes!

## Prerequisites Check

Before starting, ensure you have:

- ✅ A running Kubernetes cluster
- ✅ `kubectl` installed and configured
- ✅ Cluster admin permissions
- ✅ At least 2 CPU cores and 4GB RAM available in your cluster

## 5-Minute Deployment

### Option 1: Using kubectl (Recommended for beginners)

1. **Clone the repository**:
   ```bash
   git clone https://github.com/obingo31/kurtosis-kubernetes-testnet.git
   cd kurtosis-kubernetes-testnet
   ```

2. **Deploy Kurtosis**:
   ```bash
   kubectl apply -f kubernetes/base/
   ```

3. **Verify installation**:
   ```bash
   kubectl get pods -n kurtosis
   ```

   Wait until you see:
   ```
   NAME                              READY   STATUS    RESTARTS   AGE
   kurtosis-engine-xxxxxxxxxx-xxxxx  1/1     Running   0          1m
   ```

4. **Get access information**:
   ```bash
   kubectl get svc -n kurtosis
   ```

### Option 2: Using the deployment script

1. **Clone and run**:
   ```bash
   git clone https://github.com/obingo31/kurtosis-kubernetes-testnet.git
   cd kurtosis-kubernetes-testnet
   chmod +x deploy.sh
   ./deploy.sh
   ```

### Option 3: Using Helm

1. **Clone the repository**:
   ```bash
   git clone https://github.com/obingo31/kurtosis-kubernetes-testnet.git
   cd kurtosis-kubernetes-testnet
   ```

2. **Install with Helm**:
   ```bash
   helm install kurtosis ./helm/kurtosis --create-namespace --namespace kurtosis
   ```

3. **Check status**:
   ```bash
   helm status kurtosis -n kurtosis
   ```

## Accessing Kurtosis

### From Inside the Cluster

Services can connect to:
```
kurtosis-engine.kurtosis.svc.cluster.local:9710  # gRPC
kurtosis-engine.kurtosis.svc.cluster.local:9711  # HTTP
```

### From Outside the Cluster

Get the LoadBalancer IP:
```bash
kubectl get svc kurtosis-engine-lb -n kurtosis
```

Look for the `EXTERNAL-IP` column. Once assigned, you can access:
- gRPC: `<EXTERNAL-IP>:9710`
- HTTP: `<EXTERNAL-IP>:9711`

**Note**: If `EXTERNAL-IP` shows `<pending>`, your cluster may not support LoadBalancer services. See the [NodePort example](examples/nodeport-README.md) instead.

## Quick Verification

Test that Kurtosis is responding:

```bash
# Check pod logs
kubectl logs -n kurtosis -l app=kurtosis --tail=50

# Port-forward for local testing
kubectl port-forward -n kurtosis svc/kurtosis-engine 9711:9711

# In another terminal, test the API (if curl is available)
curl http://localhost:9711/health
```

## Next Steps

1. **Read the full documentation**: [kubernetes/README.md](kubernetes/README.md)
2. **Customize your installation**: [CONTRIBUTING.md](CONTRIBUTING.md)
3. **Explore examples**: [examples/](examples/)
4. **Learn about Kurtosis**: [docs.kurtosis.com](https://docs.kurtosis.com/)

## Troubleshooting

### Pod not starting

```bash
kubectl describe pod -n kurtosis -l app=kurtosis
kubectl logs -n kurtosis -l app=kurtosis
```

### Can't access the service

For clusters without LoadBalancer support (like minikube):

```bash
# Use NodePort instead
kubectl apply -f examples/nodeport-service.yaml

# Get the NodePort
kubectl get svc kurtosis-engine-nodeport -n kurtosis

# Access via node IP
kubectl get nodes -o wide
# Then use http://<NODE-IP>:<NODEPORT>
```

### Permission errors

Ensure you have cluster admin access:
```bash
kubectl auth can-i create namespaces
kubectl auth can-i create clusterrole
```

## Uninstalling

### kubectl
```bash
kubectl delete -f kubernetes/base/
```

### Helm
```bash
helm uninstall kurtosis -n kurtosis
kubectl delete namespace kurtosis
```

## Getting Help

- **Full docs**: See [kubernetes/README.md](kubernetes/README.md)
- **Kurtosis docs**: https://docs.kurtosis.com/
- **Issues**: Open an issue in this repository

---

**Ready to use Kurtosis?** Start with the [official Kurtosis documentation](https://docs.kurtosis.com/) to learn how to create and run enclaves!
