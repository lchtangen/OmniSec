<!-- NH_SETUP_VERSION: 2.0 nextgen -->
<!-- PRIORITY: P1 HIGH - Performance standards -->

# NetHunter NextGen Performance Standards

> **Priority**: HIGH — All P0/P1 code must meet these standards
> **Version**: 2.0.0

## 1. Performance Requirements by Priority

| Priority | Max Boot Time | Max Command Latency | Max Memory | Max Storage |
|----------|---------------|---------------------|------------|-------------|
| P0 | 30s (kernel) | 100ms | 16MB | 50MB |
| P1 | 5s (script) | 500ms | 8MB | 20MB |
| P2 | 10s (script) | 2s | 4MB | 10MB |
| P3 | 30s (script) | 5s | 2MB | 5MB |

## 2. Optimization Rules

### 2.1 Shell Scripts
```bash
# AVOID (slow):
- Pipes within loops (cat file | while read...)
- External commands in tight loops (ls, grep, sed per iteration)
- Forking subshells unnecessarily ($(command) in loops)

# PREFER (fast):
- Built-in shell operations (${var#pattern}, ${var%pattern})
- Read files once, process with shell
- Use awk/sed for bulk transformations
- Batch operations with xargs -P for parallelism
```

### 2.2 Kernel
```bash
# CONFIG OPTIONS:
- HZ=1000 for performance variant
- HZ=100 for battery variant
- BBR congestion control for maximum throughput
- BFQ I/O scheduler for interactive performance
```

### 2.3 Network
```bash
# TCP tuning:
net.core.rmem_max = 134217728
net.core.wmem_max = 134217728
net.ipv4.tcp_rmem = 4096 87380 134217728
net.ipv4.tcp_wmem = 4096 65536 134217728
net.ipv4.tcp_congestion_control = bbr
net.core.default_qdisc = fq
```

### 2.4 Storage
```bash
# Filesystem:
- F2FS for /data (better than ext4 on flash)
- BTRFS for workspaces (snapshots, compression)
- ZRAM for swap (compressed in-memory)
```

## 3. Benchmark Suite

Use `nh-bench` to verify performance:

```bash
# Full benchmark
nh-bench --all

# Individual
nh-bench cpu     # Prime number calculation
nh-bench memory  # Memory bandwidth
nh-bench storage # Sequential/random I/O
nh-bench dns     # DNS resolution speed
nh-bench kernel  # Kernel build benchmarks
```

## 4. Profiling

### 4.1 Script Profiling
```bash
# Measure script execution time
time nh-status
time nh-dev setup

# Profile with bash -x
bash -x nh-status 2>&1 | grep '+'
```

### 4.2 Kernel Profiling
```bash
# perf (if available in kernel)
perf stat ./nh-bench cpu
perf record ./nh-bench cpu
perf report

# ftrace
echo function > /sys/kernel/debug/tracing/current_tracer
cat /sys/kernel/debug/tracing/trace
```

## 5. Regression Testing

All P0/P1 changes must not regress performance beyond these thresholds:

| Metric | Threshold | Tool |
|--------|-----------|------|
| Kernel boot time | +10% | `time kernel/build-kernel.sh` |
| Script execution | +20% | `time nh-*` |
| Network throughput | -15% | `nh-net --bandwidth` |
| Storage I/O | -20% | `nh-bench storage` |
| Memory usage | +25% | `nh-proc --memory` |
