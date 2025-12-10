# Kubernetes Troubleshooting Cheatsheet

## Kubernetes Error #1: CrashLoopBackOff
### What is it?
Pods repeatedly start and crash before the container becomes healthy, so Kubernetes loops between `Running` and `CrashLoopBackOff` states.

### What Could be the Issue?
- Fatal app configuration errors that cause the process to exit quickly (e.g., missing env vars, bad flags).
- Probes (liveness/readiness) failing and Kubernetes killing the container.
- PersistentVolume mounts failing, so the workload aborts.
- Insufficient CPU/memory requests leading to OOM kills.

### Steps to Take to Resolve the Issue
1. Inspect the pod: `kubectl describe pod <name> -n <ns>` for events and restart counts.
2. View container logs from the previous crash: `kubectl logs <name> -n <ns> --previous`.
3. Check probe definitions and adjust thresholds or endpoints.
4. Validate config maps/secrets mounted correctly.
5. Right-size resource requests/limits to prevent OOM.

### Examining Pod Logs
- Current logs: `kubectl logs ${POD_NAME} -c ${CONTAINER_NAME}` (omit `-c` if the pod has a single container).
- Previous crash logs: `kubectl logs ${POD_NAME} -c ${CONTAINER_NAME} --previous` to capture the last failed start.

### Debugging with `kubectl exec`
- Run ad-hoc commands inside a container that ships with debugging tools: `kubectl exec ${POD_NAME} -c ${CONTAINER_NAME} -- ${CMD} ${ARGS}`.
- Example: `kubectl exec cassandra -- cat /var/log/cassandra/system.log` to read in-pod log files.
- Launch an interactive shell: `kubectl exec -it cassandra -- sh` (omit `-c` for single-container pods).

### Debugging with an Ephemeral Debug Container (v1.25+)
When the base image lacks shells or utilities (e.g., distroless), attach a temporary helper container:
1. Create or identify the failing pod (example): `kubectl run ephemeral-demo --image=registry.k8s.io/pause:3.1 --restart=Never`.
2. Attempting `kubectl exec -it ephemeral-demo -- sh` fails because the pause image has no shell.
3. Use `kubectl debug -it ephemeral-demo --image=busybox:1.28 --target=ephemeral-demo` to add a BusyBox ephemeral container and attach to it.
4. If you do not see a prompt immediately, press Enter; confirm the ephemeral container via `kubectl describe pod ephemeral-demo`.
> Note: `--target` requires runtime support. Without it, the debug container may not share the target's process namespace.

### Checking Cluster Reachability
- Use `kubectl cluster-info` to confirm the API server and core services are reachable.
- Output includes the **Kubernetes master** URL (API server endpoint) and the **KubeDNS/CoreDNS** service address, which is critical for in-cluster service discovery.
## Kubernetes Error #2: ImagePullBackOff
### What is it?
Kubelet cannot download the container image, so it backs off and retries with exponential delay.

### What Could be the Issue?
- **Manifest not found** – the image tag spelled in the manifest never existed or has been deleted from the registry.
- **Repository does not exist** – the registry URL/namespace is incorrect, the image path moved, or the repo was never pushed.
- **Registry authentication failure** – missing or invalid credentials for a private registry, or the service account lacks access.
- **Network/registry reachability issues** – nodes cannot reach the registry due to firewalls, VPC rules, or proxy misconfigurations.

### Steps to Resolve the Issue
1. Gather context: `kubectl describe pod <pod> -n <ns>` and inspect the **Events** section for messages such as `manifest not found`, `repository does not exist`, or `may require authorization`.
2. Manually verify the image: `docker pull <image>:<tag>` (log in first with `docker login <registry-url>` if private). This confirms whether the tag exists and the registry is reachable.
3. Validate the repository reference: double-check the registry hostname, namespace, and image path in the workload manifest, updating the deployment if the registry layout changed.
4. Audit credentials: `kubectl get secret -n <ns>` and ensure the intended `imagePullSecrets` are populated and referenced by the service account or pod spec; rotate credentials if expired.
5. Confirm network access: ensure nodes can reach the registry, update firewall/VPC rules, and verify any proxy configuration for outbound traffic.
6. Review recent changes: tag bumps, CI pushes, registry migrations, or secret updates often introduce ImagePullBackOff—revert or fix the offending change.

### Visibility with Komodor
Komodor timelines expose when image tags, registry URLs, or secrets changed relative to the failed deployment, helping you pinpoint whether the regression came from a manifest edit, expired credential, or unreachable registry. It also tracks secret modifications so you can confirm that updated credentials propagated to the workload.

## Kubernetes Error #3: ErrImagePull
### What is it?
Immediate failure to pull the container image; Kubernetes is not yet backoff-throttling but the pull itself failed.

### What Could be the Issue?
- Malformed image reference (missing registry/namespace/tag).
- Registry requires authentication but no credentials were provided.
- TLS/CA problems while talking to the registry.

### Steps to Resolve the Issue
1. Describe the pod to read the exact error string (e.g., `not found`, `unauthorized`).
2. Fix the image reference in the deployment manifest and reapply.
3. Create/update `Secret` objects with credentials and add them as `imagePullSecrets`.
4. If using self-hosted registries, provide CA bundles via `trusted-ca-bundle` configmaps or node configuration.

## Kubernetes Error #4: CreateContainerConfigError
### What is it?
Kubelet cannot create the container specification because something is wrong before the container even starts.

### What Could be the Issue?
- **Missing ConfigMaps** – ConfigMaps are key/value stores for non-sensitive config. If they are deleted, renamed, or not created before the deployment runs, any pod referencing them via `envFrom`, `valueFrom`, or volumes will fail to start.
- **Missing Secrets** – Secrets hold sensitive data (passwords, tokens, keys). When the referenced Secret is absent or incorrectly named, the pod cannot mount or inject the data and Kubernetes blocks container creation.
- Other configuration resources (downward API fields, projected volumes) are malformed.
- Volume mounts point to nonexistent or conflicting paths.
- Environment variables reference missing fields/resources.

### Steps to Resolve the Issue
1. Check the pod status and events: `kubectl describe pod <pod> -n <ns>` and look for `configmap not found` or `secret not found` messages.
2. Verify the resources exist: `kubectl get configmap -n <ns>` / `kubectl get secret -n <ns>`. If missing, recreate them with `kubectl create configmap ...` or `kubectl create secret ...` before redeploying.
3. Inspect contents: `kubectl describe configmap <name> -n <ns>` or `kubectl describe secret <name> -n <ns>` to ensure expected keys/values are present and correctly encoded.
4. Validate JSON/YAML syntax in mounted configs and reapply if corrupted, then recreate or restart the affected pods.

## Where Komodor Can Help
Komodor tracks Kubernetes changes over time. For configuration-related failures, its timeline shows exactly which ConfigMap, Secret, or deployment change preceded the error, and links directly to the diff, reducing guesswork.

## Kubernetes Error #5: CreateContainerError
### What is it?
Kubelet created the container configuration but failed when trying to start the container runtime.

### What Could be the Issue?
- **Container runtime issues** – underlying runtimes (containerd, CRI-O, Docker) can hit corrupted metadata, dangling containers, or kubelet errors. Cleaning up old containers, checking kubelet logs, or restarting the runtime on the node often resolves it.
- **Resource constraints/system pressure** – nodes short on CPU, memory, disk, or inode capacity cause the runtime to deny new containers.
- **Corrupted/bad images** – partially downloaded or broken images interfere with new starts.
- Invalid container command/entrypoint causing immediate runtime errors.
- Volume or device mounts failing at runtime permissions.
- Security contexts (AppArmor/SELinux/seccomp) blocking startup.

### Steps to Resolve the Issue
1. Describe the pod to capture kubelet/runtime errors.
2. SSH to the node and inspect kubelet + container runtime logs; prune stale containers/images if the runtime is stuck.
3. Verify container `command`/`args` reference binaries that exist and have execute permissions.
4. Confirm hostPath or CSI volumes mount properly and that the pod has required permissions.
5. Review securityContext settings (AppArmor/SELinux/seccomp) and relax or adjust profiles if they block startup.
6. Check node resources with `kubectl top nodes` or cloud metrics; free disk/inodes and alleviate system pressure before retrying.

## Diagnosing Issues with Komodor
Use Komodor to correlate pod failures with deployments, ConfigMap/Secret updates, or cluster events. The platform surfaces node-level conditions, image pull errors, and resource quota breaches so you can jump straight to the root cause.

## Kubernetes Error #6: FailedScheduling
### What is it?
The scheduler cannot place the pod on any node, so the pod remains pending indefinitely.

### What Could be the Issue?
- **Insufficient allocatable resources** – pods request more CPU/memory/ephemeral storage than any node can supply, or the cluster is at capacity.
- **Nodes marked unschedulable** – nodes cordoned for maintenance (`kubectl cordon`) will not accept pods until uncordoned.
- **Taints/tolerations conflicts** – tainted nodes require matching tolerations; without them the scheduler refuses placement.
- PodDisruptionBudgets or quota constraints blocking new replicas.

### Steps to Resolve the Issue
1. Run `kubectl describe pod` to read scheduler events (e.g., `0/5 nodes available: insufficient memory`, `node(s) had taint {key=value: NoSchedule}`).
2. For resource shortages, reduce pod requests/limits, free capacity by scaling other workloads down, or add nodes/expand node groups.
3. List node status: `kubectl get nodes` to see if they are `SchedulingDisabled`; uncordon with `kubectl uncordon <node>` when ready.
4. Inspect taints via `kubectl describe node <node>` and ensure the pod spec contains matching tolerations; remove unnecessary taints with `kubectl taint nodes <node> key:NoSchedule-` if appropriate.
5. Review namespace quotas and PodDisruptionBudgets so they do not block additional replicas.

## Cert-manager Errors
### What is it?
`cert-manager` automates TLS certificate issuance in Kubernetes. Errors appear when certificate resources, issuers, or ACME challenges fail, leaving Ingresses or services without valid certs.

### What Could be the Issue?
- Issuer/ClusterIssuer misconfigured (wrong ACME server URL, missing credentials, invalid CA data).
- DNS-01 or HTTP-01 challenges cannot reach the solver pod because of DNS/Ingress issues.
- Certificates referencing nonexistent secrets or conflicting key usages.
- Webhook or cert-manager controller deployment not running or lacking RBAC permissions.

### Steps to Resolve the Issue
1. Inspect the certificate and order status: `kubectl describe certificate <name>` and `kubectl describe order <name>`.
2. Check cert-manager controller logs for reconciliation errors.
3. Validate ClusterIssuer/Issuer YAML and ensure referenced secrets (API keys, service accounts) exist.
4. For ACME HTTP-01, confirm Ingress routes `/.well-known/acme-challenge` to the solver service. For DNS-01, ensure ExternalDNS or manual DNS entries are created.
5. Restart cert-manager pods if the webhook or controller is crash looping after an upgrade.

## ExternalDNS Errors
### What is it?
ExternalDNS syncs Kubernetes Services/Ingresses with DNS providers. Errors result in missing or stale DNS records for exposed services.

### What Could be the Issue?
- Provider credentials missing, expired, or lacking permissions to edit records.
- Records exceed provider quotas or collide with existing manual entries.
- Service annotations/ingress hosts missing or malformed, so ExternalDNS skips them.

### Steps to Resolve the Issue
1. Check logs: `kubectl logs deploy/external-dns -n <ns>` for provider-specific errors.
2. Validate RBAC/access keys and rotate credentials if necessary.
3. Ensure Services/Ingresses contain `external-dns.alpha.kubernetes.io/hostname` or host rules.
4. Remove conflicting manual DNS entries or adjust TXT ownership records if the provider enforces them.

## Autoscaler Issues
### What is it?
Cluster Autoscaler (CA) or Horizontal Pod Autoscaler (HPA) problems manifest as unscheduled pods or workloads stuck at low replica counts despite load.

### What Could be the Issue?
- Metrics pipeline broken (metrics-server unavailable, custom metrics missing), so HPAs lack data.
- Misconfigured thresholds (e.g., target CPU 10% on idle workloads) preventing scale-up.
- Cluster Autoscaler blocked by PodDisruptionBudgets, daemonsets, or cloud API limits.
- Insufficient cloud quotas or node groups marked as unscalable.

### Steps to Resolve the Issue
1. For HPAs, run `kubectl describe hpa <name>` to view metrics and scaling decisions.
2. Ensure `metrics-server` is healthy and TLS configs allow scraping from kubelet.
3. Review CA logs to see why node groups are skipped (`kubectl logs deploy/cluster-autoscaler -n kube-system`).
4. Increase cloud provider quotas or add additional node pools/instance types when CA reports `max node group size reached`.
5. Audit PDBs to make sure they permit eviction when CA tries to downscale.

## Handling Networking Errors in Kubernetes
Networking problems often present as timeouts, connection resets, or services unreachable across namespaces or from outside the cluster. Address them systematically by checking DNS, service discovery, traffic health, policies, and CNI state.

### DNS Resolution Failures
- **Symptoms**: Pods cannot resolve service names (`nslookup` fails), external hostname lookups time out.
- **Causes**: `coredns` pods crash looping, stub domains misconfigured, NodeLocal DNS cache stale, network policies blocking UDP/53.
- **Actions**:
	1. Check `kube-system` for `coredns` pod health and inspect logs for plugin errors.
	2. Validate the `Corefile` config map; look for malformed forward/upstream entries.
	3. From within a pod, run `dig +short kubernetes.default.svc.cluster.local`. If it fails, ensure the pod's `/etc/resolv.conf` has the cluster DNS IP.
	4. Relax NetworkPolicies to allow UDP/TCP 53 between pods and CoreDNS, or add explicit rules.

### Service Discovery Issues
- **Symptoms**: Service ClusterIP exists but endpoints list is empty, or traffic never reaches backing pods.
- **Causes**: Selector mismatch between Service and pods, pods not ready (readiness gate failing), headless service missing endpoints.
- **Actions**:
	1. Run `kubectl get endpoints <svc>` to confirm targets populate.
	2. Align labels between Deployments/StatefulSets and the Service selector.
	3. Verify readiness probes succeed so endpoints are marked ready.
	4. For headless services, ensure StatefulSet pods have the correct DNS records and SRV entries.

### Network Congestion and Latency
- **Symptoms**: High request latency, retransmissions, or throttled throughput across services.
- **Causes**: Node-level resource saturation, noisy neighbor workloads, undersized CNI bandwidth limits, or external load balancer throttling.
- **Actions**:
	1. Use `kubectl top nodes/pods` plus cloud metrics to locate saturated nodes.
	2. Enable eBPF or CNI-level observability (Cilium Hubble, Calico Flow Logs) to pinpoint heavy flows.
	3. Scale out replicas, spread workloads with topology constraints, or upgrade node instance types.
	4. Configure QoS classes and network policies to isolate latency-sensitive traffic.

### Firewall and Network Policy Misconfigurations
- **Symptoms**: Connections drop between namespaces or from external clients; pods reachable only from certain nodes.
- **Causes**: Cloud firewalls blocking node ports, overly restrictive `NetworkPolicy`, or missing egress rules.
- **Actions**:
	1. Audit cloud security groups / firewall rules for node subnets and control plane endpoints.
	2. List applied `NetworkPolicy` objects and confirm they allow required ingress/egress selectors.
	3. Use `kubectl exec` with `curl` or `netcat` to test path connectivity while adjusting rules.
	4. Consider adopting default-deny policies plus explicit allowlists to avoid accidental lockouts.

### Pod Networking Conflicts
- **Symptoms**: Pods stuck in `ContainerCreating` with CNI errors, overlapping CIDRs, or pods unable to reach services across clusters.
- **Causes**: CNI plugin misconfiguration, IP exhaustion in the pod CIDR, conflicting MTU settings, or multiple CNIs fighting over interfaces.
- **Actions**:
	1. Inspect CNI logs (`/var/log/containers/*cni*`) on affected nodes.
	2. Confirm cluster pod/service CIDRs do not overlap with VPC or VPN ranges.
	3. Adjust MTU settings in the CNI config when running across encapsulated networks (e.g., WireGuard, IPSec).
	4. Reconcile multiple CNI installations; ensure only one plugin manages the primary `eth0`.
