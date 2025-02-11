# Kubernetes Stress Test Suite

This repository contains a collection of Kubernetes pods designed to generate various types of system stress for testing and validation purposes.

## Available Stress Tests

### CPU Stress Test
**File:** `manifests/stress/cpu-stress.yaml`

A CPU-intensive workload that:
- Uses pure bash arithmetic operations to generate CPU load
- Automatically scales to use all available CPU cores
- Runs continuous calculation loops to maintain consistent CPU pressure

### I/O Stress Test
**File:** `manifests/stress/io-stress.yaml`

A comprehensive I/O stress test that:
- Uses multiple tools (`fio`, `stress-ng`, and `dd`) for maximum I/O pressure
- Creates various I/O patterns with different block sizes (1K and 4K)
- Performs random and sequential writes
- Utilizes direct I/O for bypassing the page cache
- Runs multiple concurrent jobs for increased I/O load

### Memory Stress Test
**File:** `manifests/stress/memory-stress.yaml`

A memory-intensive workload designed to:
- Consume and exercise system memory
- Test memory management and allocation

### Java Memory Leak Tests
Two variants demonstrating different JVM memory behaviors in containers:

**Container-Aware JVM** (`manifests/stress/java-memory-leak.yaml`):
- Uses container-aware JVM configuration (`-XX:+UseContainerSupport`)
- Respects container memory limits
- Memory settings based on container resources
- Demonstrates proper container memory isolation

**Node-Level JVM** (`manifests/stress/java-memory-leak-nodejvm.yaml`):
- Disables container awareness (`-XX:-UseContainerSupport`)
- JVM sees full node resources
- Uses fixed heap sizes (`-Xms4g -Xmx16g`)
- Demonstrates potential memory issues when JVM isn't container-aware
- Useful for testing container runtime OOM handling

Both Java tests:
- Create gradual memory leaks
- Monitor JVM memory usage
- Handle OutOfMemoryErrors
- Generate GC logs for analysis

### Memory-IO Combined Stress Test
**File:** `manifests/stress/memory-io-stress.yaml`

A hybrid stress test that:
- Combines memory and I/O operations
- Tests system behavior under mixed workload conditions
- Exercises both memory subsystem and storage I/O

### Netlink Stress Test
**File:** `manifests/stress/netlink-stress.yaml`

A network interface monitoring test that:
- Continuously monitors network interface states
- Uses the `ip` command to list network interfaces
- Tests netlink socket functionality

## Usage

To deploy any of the stress tests, use:

```bash
kubectl apply -f manifests/stress/<stress-test-name>.yaml
```

For example, to deploy the CPU stress test:
```bash
kubectl apply -f manifests/stress/cpu-stress.yaml
```

## Node Selection

All stress tests are configured to run on a specific node using the `nodeSelector`:
```yaml
nodeSelector:
  kubernetes.io/hostname: aks-f16-23743720-vmss000000
```

Modify this selector in the YAML files to target different nodes in your cluster.

## Security Considerations

Some stress tests (particularly the I/O stress test) require privileged container access. Ensure your cluster's security policies allow privileged containers before deploying these tests.

## Monitoring

It's recommended to monitor node metrics when running these stress tests. Key metrics to watch:
- CPU utilization
- Memory usage
- Disk I/O rates
- Network interface statistics
- JVM memory metrics (for Java tests)
- Container runtime OOM events

## Cleanup

To remove a stress test pod:
```bash
kubectl delete -f manifests/stress/<stress-test-name>.yaml
```
