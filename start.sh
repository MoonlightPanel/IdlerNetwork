#!/bin/bash
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
