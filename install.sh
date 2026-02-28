#!/bin/bash
clear
cd /mnt/server
echo "Đang tải script khởi động..."
curl -L https://raw.githubusercontent.com/MoonlightPanel/IdlerNetwork/refs/heads/main/start.sh -o start.sh
chmod +x start.sh
echo "Cài đặt hoàn tất."
