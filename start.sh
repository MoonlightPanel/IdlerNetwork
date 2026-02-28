#!/bin/bash

# Thiết lập thư mục gốc là thư mục hiện tại của Pterodactyl (thường là /home/container)
BASE_DIR="$PWD"

# Tạo các thư mục ngay trong thư mục của server
mkdir -p "$BASE_DIR/data" "$BASE_DIR/novnc" "$BASE_DIR/qemu" "$BASE_DIR/cloud-init"

# Tải Ubuntu Image vào thư mục cục bộ
curl -L https://cloud-images.ubuntu.com/jammy/current/jammy-server-cloudimg-amd64.img \
-o "$BASE_DIR/qemu/ubuntu.img"

# Tạo cấu hình Cloud-init
echo -e "instance-id: idlernetwork\nlocal-hostname: idlernetwork" > "$BASE_DIR/cloud-init/meta-data"

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
  - systemctl restart ssh\n" > "$BASE_DIR/cloud-init/user-data"

# Tạo file ISO cấu hình
genisoimage -output "$BASE_DIR/qemu/seed.iso" -volid cidata -joliet -rock \
"$BASE_DIR/cloud-init/user-data" "$BASE_DIR/cloud-init/meta-data"

set -e
echo "Setup VM"
echo "Dung lượng (GB):"
read disk1
echo "Ram (GB):"
read ram1

MAX_CORES=$(nproc)
echo "------------------------------------------------"
echo "Phát hiện hệ thống có $MAX_CORES CPU Cores."
echo "Máy ảo sẽ được cấp tối đa $MAX_CORES Cores này."
echo "------------------------------------------------"

DISK="$BASE_DIR/data/vm.qcow2"
IMG="$BASE_DIR/qemu/ubuntu.img"
SEED="$BASE_DIR/qemu/seed.iso"

echo "Đang tạo..."
echo "ReCode by Noimc - Fixed for Pterodactyl"

qemu-img convert -f qcow2 -O qcow2 "$IMG" "$DISK"
qemu-img resize "$DISK" "${disk1}G"

# Khởi chạy QEMU
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
