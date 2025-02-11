kubectl debug node/aks-f16-23743720-vmss000000 -it --image=busybox --privileged

wget -qO- http://10.224.0.4:19100/metrics | grep node_disk

# node_load
nl1=$(wget -qO- http://10.224.0.4:19100/metrics | grep -E '^node_load1(\s|\{)' | head -n1 | awk '{print $NF}') 
nl5=$(wget -qO- http://10.224.0.4:19100/metrics | grep -E '^node_load5(\s|\{)' | head -n1 | awk '{print $NF}')
echo "node_load1: " $nl1
echo "node_load5: " $nl5

# node_disk_io_now
wget -qO- http://10.224.0.4:19100/metrics | grep -E '^node_disk_io_now(\s|\{)' | head -n1 | awk '{print "node_disk_io_now: " $NF}'
# node_disk_io_time_weighted
wget -qO- http://10.224.0.4:19100/metrics | grep -E '^node_disk_io_time_weighted(\s|\{)' | head -n1 | awk '{print "node_disk_io_time_weighted: " $NF}'


# node_cpu_seconds_total
wget -qO- 'http://10.224.0.4:19100/api/v1/query?query=sum(rate(node_cpu_seconds_total{mode="iowait"}[1m]))'


echo "pressure/io: "
cat /proc/pressure/io
echo "cgroup/system.slice/io.pressure: " 
cat /sys/fs/cgroup/system.slice/io.pressure

cat /proc/pressure/memory
cat /proc/pressure/io
cat /proc/pressure/cpu
cat /sys/fs/cgroup/system.slice/memory.pressure
cat /sys/fs/cgroup/system.slice/io.pressure
cat /sys/fs/cgroup/system.slice/cpu.pressure

wget -qO- 'http://10.224.0.4::10250/metrics/cadvisor'

# monitor node_load1 every 5 seconds
while true; do date "+%Y-%m-%d %H:%M:%S" | tr -d '\n'; echo -n " "; wget -qO- http://10.224.0.4:19100/metrics | grep -E '^node_load1(\s|\{)' | head -n1 | awk '{print "node_load1: " $NF}'; sleep 5; done


# add node pool with small managed disk
az aks nodepool add \
  --resource-group  dafell-aks-nh-rg \
  --cluster-name  dafell-aks-nh \
  --name f16 \
  --node-vm-size standard_f16s_v2 \
  --node-osdisk-size 128 \
  --node-osdisk-type Managed

# monitor top pod memory-stress
kubectl top pod memory-stress -n stress-test