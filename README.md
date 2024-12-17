# Kubernetes Node Stress Test

This repository contains Kubernetes manifests designed to stress test nodes and API server in a cluster to potentially trigger node not ready conditions, kubelet/containerd crashes, or API server issues through resource saturation.

⚠️ **WARNING: FOR TESTING PURPOSES ONLY** ⚠️
These manifests are designed to stress test cluster components and may cause service disruption. Do not use in production environments.

⚠️ **RESOURCE CONSUMPTION WARNING** ⚠️
These pods have no resource limits or requests defined, allowing them to consume as many resources as possible. This can quickly lead to node failure and service disruption.

## Available Stress Tests

### Node Stress Tests

1. `cpu-stress.yaml`: CPU stress test
   - Uses stress-ng to max out CPU cores
   - Targets 8 CPU cores at 100% utilization
   - No resource limits - will attempt to consume all available CPU

2. `memory-stress.yaml`: Memory stress test
   - Uses stress-ng to consume and touch memory
   - Allocates 8GB of memory with vm-keep to prevent swapping
   - No resource limits - will attempt to consume all available memory

3. `io-stress.yaml`: I/O stress test
   - Uses fio to generate intense I/O operations
   - Performs random reads and writes with 8 parallel jobs
   - Uses direct I/O to bypass page cache
   - Increased I/O depth to 64 for maximum pressure
   - 4GB test file size per operation
   - No resource limits - will attempt to saturate I/O

4. `file-stress.yaml`: File system stress test
   - Creates and deletes many small files rapidly
   - Operates across 8 directories simultaneously
   - Creates 25,000 files per directory
   - Increased file size to 4KB
   - No resource limits - will attempt to exhaust inodes and disk space

### API Server Stress Test

5. `crd-stress.yaml`: API Server CRD stress test
   - Continuously creates new Custom Resource Definitions
   - Generates unique CRD names with UUID suffixes
   - Includes required RBAC permissions
   - Can potentially cause API server memory issues or crashes
   - May impact etcd performance due to large number of objects
   - WARNING: CRDs are cluster-scoped resources and affect the entire cluster

### Combined Deployment

`stress-deployment.yaml`: Combines all node stress tests into a single deployment
- Includes all four node stress test containers
- No resource limits or requests
- Can be scaled using kubectl scale
- Each pod will attempt to consume maximum available resources

## Usage

### Node Stress Testing

1. Create a dedicated namespace for testing:
```bash
kubectl create namespace stress-test
```

2. Apply individual node stress tests:
```bash
kubectl apply -f manifests/cpu-stress.yaml -n stress-test
kubectl apply -f manifests/memory-stress.yaml -n stress-test
kubectl apply -f manifests/io-stress.yaml -n stress-test
kubectl apply -f manifests/file-stress.yaml -n stress-test
```

Or apply the combined deployment:
```bash
kubectl apply -f manifests/stress-deployment.yaml -n stress-test
```

3. Scale the deployment to increase pressure:
```bash
kubectl scale deployment node-stress -n stress-test --replicas=3
```

### API Server Stress Testing

Apply the CRD stress test (this will create cluster-wide resources):
```bash
kubectl apply -f manifests/crd-stress.yaml
```

## Expected Outcomes

### Node Stress Tests
- Immediate CPU saturation
- Rapid memory exhaustion
- Disk I/O saturation
- Quick inode exhaustion
- Node pressure triggering eviction
- Potential kubelet or containerd crashes
- Node not ready conditions
- Possible complete node failure

### API Server Stress Test
- Rapid increase in etcd database size
- API server memory consumption growth
- Potential API server crashes
- Slower API responses
- Possible etcd performance issues
- May affect cluster-wide operations

## Monitoring

Monitor node conditions:
```bash
kubectl get nodes
kubectl describe node <node-name>
```

Monitor pod status:
```bash
kubectl get pods -n stress-test
kubectl describe pod <pod-name> -n stress-test
```

Monitor node resource consumption:
```bash
kubectl top nodes
kubectl top pods -n stress-test
```

Monitor API server and etcd:
```bash
kubectl get events --sort-by='.metadata.creationTimestamp' -A
kubectl get --raw /metrics | grep etcd_object_counts
kubectl get --raw /metrics | grep apiserver_storage_objects
```

## Cleanup

Remove node stress test resources:
```bash
kubectl delete namespace stress-test
```

Remove API server stress test and RBAC:
```bash
kubectl delete -f manifests/crd-stress.yaml
# You may need to manually clean up created CRDs:
kubectl get crd | grep stress.test | awk '{print $1}' | xargs kubectl delete crd
```

## Note

Since these pods have no resource limits:
- They can consume all available node resources
- Node failure can occur very quickly
- Other workloads on the node may be severely impacted
- Recovery might require node reboot
- The API server stress test can affect the entire cluster
- Use with extreme caution
