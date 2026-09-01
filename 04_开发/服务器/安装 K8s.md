
关闭Swap
使用 `sed` 命令注释掉 `/etc/fstab` 文件中的 swap 配置行：
``` 
sed -i '/swap/d' /etc/fstab
```

设置主机名
``` bash
hostnamectl set-hostname k8s-master
```

配置 hosts 文件
``` bash
cat >> /etc/hosts <<EOF
<IP> k8s-master
EOF
```

``` bash
ctr -n k8s.io images import /home/<user>/k8s-v1.29.15-all.tar

ctr -n k8s.io images ls | grep "k8s.registry.cdn.w7.cc"
```

``` bash
#!/bin/bash

SRC_REGISTRY="k8s.registry.cdn.w7.cc"
DST_REGISTRY="registry.k8s.io"

IMAGES=(
  "kube-apiserver:v1.29.15"
  "kube-controller-manager:v1.29.15"
  "kube-scheduler:v1.29.15"
  "kube-proxy:v1.29.15"
  "pause:3.9"
  "etcd:3.5.16-0"
  "coredns/coredns:v1.11.1"
)

echo "Starting to retag images..."

for IMG in "${IMAGES[@]}"; do
  SRC_IMAGE="${SRC_REGISTRY}/${IMG}"
  DST_IMAGE="${DST_REGISTRY}/${IMG}"
  
  echo "Retagging: ${SRC_IMAGE} -> ${DST_IMAGE}"
  
  sudo ctr -n k8s.io images tag "${SRC_IMAGE}" "${DST_IMAGE}"
  
  if [ $? -eq 0 ]; then
    echo "SUCCESS: ${IMG}"
  else
    echo "FAILED: ${IMG}"
  fi
done

echo "Retagging process completed."

```

``` bash
kubeadm init \
  --pod-network-cidr=10.244.0.0/16 \
  --cri-socket=unix:///var/run/containerd/containerd.sock
  
kubectl auth can-i --list --kubeconfig=/etc/kubernetes/admin.conf

kubectl describe node k8s-master
```


``` bash
# 在能上网的机器上执行
docker pull registry.aliyuncs.com/calico/node:v3.26.0
docker save registry.aliyuncs.com/calico/node:v3.26.0 -o calico-node.tar

# 将 calico-node.tar 传输到 k8s-master 节点后执行
docker load -i calico-node.tar
```