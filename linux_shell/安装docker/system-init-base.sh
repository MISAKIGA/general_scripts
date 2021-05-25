#!/bin/bash

echo "初始化系统配置"
swapoff -a
apt install-y ntpdate
ntpdate cn.pool.ntp.org
hwclock --systohc

cat >> /etc/systemd/resolved.conf << EOF
    DNS=114.114.114.114
EOF

apt update

#安装docker、docker-compose
echo "准备安装Docker、Docker-compose"
apt-get install -y  apt-transport-https  ca-certificates curl  software-properties-common
curl -fsSL https://mirrors.ustc.edu.cn/docker-ce/linux/ubuntu/gpg | sudo apt-key add -
add-apt-repository "deb [arch=amd64] https://mirrors.ustc.edu.cn/docker-ce/linux/ubuntu $(lsb_release -cs) stable" 
apt update
echo "安装docker"
apt install -y docker-ce

echo "安装docker-compose"
apt install -y docker-compose
sudo mkdir -p /etc/docker
sudo tee /etc/docker/daemon.json <<-'EOF'
{
  "registry-mirrors": ["https://2vhjdxyf.mirror.aliyuncs.com"]
}
EOF

echo "重启Docker"
systemctl daemon-reload
systemctl restart docker
echo "初始化完成！"
