#!/bin/bash

init(){
echo "初始化系统配置"
swapoff -a
apt install-y ntpdate
ntpdate cn.pool.ntp.org
hwclock --systohc

cat >> /etc/systemd/resolved.conf << EOF
    DNS=114.114.114.114
EOF

apt update
}

#docker的国内镜像
dockerURL=https://mirrors.ustc.edu.cn/docker-ce/linux/ubuntu/gpg
#docker国内镜像库
aptRepository="deb [arch=amd64] https://mirrors.ustc.edu.cn/docker-ce/linux/ubuntu $(lsb_release -cs) stable" 
#docker镜像加速地址，可加快pull镜像的速度
dockerMirrors="https://2vhjdxyf.mirror.aliyuncs.com"

#安装docker、docker-compose
installDocker(){
echo "准备安装Docker、Docker-compose"
apt-get install -y  apt-transport-https  ca-certificates curl  software-properties-common
curl -fsSL $dockerURL | sudo apt-key add -
add-apt-repository $aptRepository
apt update
echo "安装docker"
apt install -y docker-ce
if [ ! $? -eq 0 ];then
  echo "docker 安装失败！"
  exit 3
fi
echo "安装docker-compose"
apt install -y docker-compose
sudo mkdir -p /etc/docker
sudo tee /etc/docker/daemon.json <<-'EOF'
{
  "registry-mirrors": [$dockerMirrors]
}
EOF

echo "重启Docker"
systemctl daemon-reload
systemctl restart docker
echo "初始化完成！"
}


main(){
  init
  installDocker
}

main