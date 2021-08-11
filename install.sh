# Desactivar Swap
swapoff -a

# Configuración de las tablas IP
cat <<EOF | tee /etc/modules-load.d/k8s.conf \
br_netfilter \
EOF
cat <<EOF | tee /etc/sysctl.d/k8s.conf \
net.bridge.bridge-nf-call-ip6tables = 1 \
net.bridge.bridge-nf-call-iptables = 1 \
EOF
sysctl --system

# Instalar docker
apt-get install docker.io
systemctl restart docker

# Instalar Kubectl Kubelet Kubeadm
apt-get update
apt-get install -y apt-transport-https ca-certificates curl
curl -fsSLo /usr/share/keyrings/kubernetes-archive-keyring.gpg https://packages.cloud.google.com/apt/doc/apt-key.gpg
echo "deb [signed-by=/usr/share/keyrings/kubernetes-archive-keyring.gpg] https://apt.kubernetes.io/ kubernetes-xenial main" | sudo tee /etc/apt/sources.list.d/kubernetes.list
apt-get update
apt-get install -y kubelet kubeadm kubectl
apt-mark hold kubelet kubeadm kubectl

# Configurar cgroup driver
cat <<EOF | sudo tee /etc/docker/daemon.json \
{ \
  "exec-opts": ["native.cgroupdriver=systemd"], \
  "log-driver": "json-file", \
  "log-opts": { \
    "max-size": "100m" \
  }, \
  "storage-driver": "overlay2" \
} \
EOF
systemctl enable docker
systemctl daemon-reload
systemctl restart docker