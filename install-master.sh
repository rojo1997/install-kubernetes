# Desactivar Swap
swapoff -a

# Configuración de las tablas IP
modprobe br_netfilter
echo "br_netfilter" > /etc/modules-load.d/k8s.conf
echo "net.bridge.bridge-nf-call-ip6tables = 1" >> /etc/sysctl.d/k8s.conf
echo "net.bridge.bridge-nf-call-iptables = 1" >> /etc/sysctl.d/k8s.conf
sysctl --system

# Instalar docker
apt-get install -y docker.io
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
echo '{
  "exec-opts": ["native.cgroupdriver=systemd"],
  "log-driver": "json-file",
  "log-opts": {
    "max-size": "100m"
  },
  "storage-driver": "overlay2"
}' > /etc/docker/daemon.json
systemctl enable docker
systemctl daemon-reload
systemctl restart docker

# Iniciar kubeadm
kubeadm init

# Instalar red cilium
sudo snap install helm --classic
helm repo add cilium https://helm.cilium.io/
helm install cilium cilium/cilium --version 1.9.9 --namespace kube-system