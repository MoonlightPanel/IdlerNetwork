#!/bin/bash
clear
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
wget https://raw.githubusercontent.com/MoonlightPanel/IdlerNetwork/refs/heads/main/start.sh
clear
set -e
echo "Setup VM"
echo "Dung lượng (GB):"
read disk1
echo "Ram (GB):"
read ram1

# Tự động lấy tối đa số nhân CPU của VPS/Container
MAX_CORES=$(nproc)
echo "------------------------------------------------"
echo "Phát hiện hệ thống có $MAX_CORES CPU Cores."
echo "Máy ảo sẽ được cấp tối đa $MAX_CORES Cores này."
echo "------------------------------------------------"

DISK="/data/vm.qcow2"
IMG="/opt/qemu/ubuntu.img"
SEED="/opt/qemu/seed.iso"

echo "Đang tạo..."
echo "ReCode by Noimc"

qemu-img convert -f qcow2 -O qcow2 "$IMG" "$DISK"
qemu-img resize "$DISK" "${disk1}G"

# Khởi chạy QEMU với KVM và tự động scale CPU
qemu-system-x86_64 \
    -accel tcg,thread=multi \
    -cpu max \
    -m "${ram1}G" \
    -smp "$MAX_CORES" \
    -drive file="$DISK",format=qcow2,if=virtio \
    -drive file="$SEED",format=raw,if=virtio \
    -netdev user,id=net0,hostfwd=tcp::2222-:22 \
    -device virtio-net,netdev=net0 \
    -vga virtio \
    -nographic
