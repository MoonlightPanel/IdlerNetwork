#!/bin/bash
echo "ReCode by NoiMC"
apt-get update && apt-get install -y --no-install-recommends \
    qemu-system-x86 \
    qemu-utils \
    sudo \
    cloud-image-utils \
    software-properties-common \
    genisoimage \
    websockify \
    curl \
    unzip \
    python3-pip \
    openssh-client \
    net-tools \
    netcat-openbsd \
    && rm -rf /var/lib/apt/lists/* && apt clean
    
mkdir -p /data /novnc /opt/qemu /cloud-init
curl -L https://cloud-images.ubuntu.com/jammy/current/jammy-server-cloudimg-amd64.img \
-o /opt/qemu/ubuntu.img
echo "instance-id: idlernetwork\nlocal-hostname: idlernetwork" > /cloud-init/meta-data
printf "#cloud-config\n\
preserve_hostname: false\n\
hostname: idlernetwork\n\
users:\n\
  - name: root\n\
    gecos: root\n\
    shell: /bin/bash\n\
    lock_passwd: false\n\
    passwd: \$6\$abcd1234\$W6wzBuvyE.D1mBGAgQw2uvUO/honRrnAGjFhMXSk0LUbZosYtoHy1tUtYhKlALqIldOGPrYnhSrOfAknpm91i0\n\
    sudo: ALL=(ALL) NOPASSWD:ALL\n\
disable_root: false\n\
ssh_pwauth: true\n\
chpasswd:\n\
  list: |\n\
    root:root\n\
  expire: false\n\
runcmd:\n\
  - systemctl enable ssh\n\
  - systemctl restart ssh\n" > /cloud-init/user-data
genisoimage -output /opt/qemu/seed.iso -volid cidata -joliet -rock \
/cloud-init/user-data /cloud-init/meta-data
wget https://github.com/MoonlightPanel/IdlerNetwork/raw/refs/heads/main/batdau.sh
clear
echo "Đang chạy vui lòng đừng tắt"
chmod +x batdau.sh
bash batdau.sh
