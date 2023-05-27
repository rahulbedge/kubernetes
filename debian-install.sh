clear
apt update -y && sudo apt dist-upgrade -y
swapoff -a 
apt-get install ca-certificates curl gnupg -y

curl -fsSL https://download.docker.com/linux/debian/gpg | sudo gpg --dearmor -o /usr/share/keyrings/docker.gpg
echo \
  "deb [arch="$(dpkg --print-architecture)" signed-by=/usr/share/keyrings/docker.gpg] https://download.docker.com/linux/debian \
  "$(. /etc/os-release && echo "$VERSION_CODENAME")" stable" | \
   tee /etc/apt/sources.list.d/docker.list > /dev/null

apt-get update -y
apt-get install docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin -y
docker run hello-world

# Run these commands as root
###Install GO###
mkdir -p /root/installer/cri
cd /root/installer/cri
wget https://go.dev/dl/go1.20.4.linux-amd64.tar.gz
tar -C /root/installer/cri -xzf go1.20.4.linux-amd64.tar.gz
git clone https://github.com/Mirantis/cri-dockerd.git
cd cri-dockerd
mkdir bin
/root/installer/cri/go/bin/go build -o bin/cri-dockerd
mkdir -p /usr/local/bin
install -o root -g root -m 0755 bin/cri-dockerd /usr/local/bin/cri-dockerd
cp -a packaging/systemd/* /etc/systemd/system
sed -i -e 's,/usr/bin/cri-dockerd,/usr/local/bin/cri-dockerd,' /etc/systemd/system/cri-docker.service
systemctl daemon-reload
systemctl enable cri-docker.service
systemctl enable --now cri-docker.socket
cd /root/installer
rm -rf ./cri
