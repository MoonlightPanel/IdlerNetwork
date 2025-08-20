#!/bin/bash
set -e
echo "Setup VM"
echo "Dung lượng:"
read disk1
echo "Ram:"
read ram1
DISK="/data/vm.qcow2"
IMG="/opt/qemu/ubuntu.img"
SEED="/opt/qemu/seed.iso"
DISK1="$disk1"
RAM="$ram1"
echo "Đang tạo..."
echo "ReCode by Noimc"
qemu-img convert -f qcow2 -O qcow2 "$IMG" "$DISK"
qemu-img resize "$DISK" "$DISK1"G

qemu-system-x86_64 \
    -m "$RAM"G \
    -cpu max \
    -accel tcg,thread=multi \
    -drive file="$DISK",format=qcow2,if=virtio \
    -drive file="$SEED",format=raw,if=virtio \
    -netdev user,id=net0,hostfwd=tcp::2222-:22 \
    -device virtio-net,netdev=net0 \
    -vga virtio \
    -nographic
