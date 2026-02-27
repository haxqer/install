#!/bin/bash

# 1. 检查是否以 root 或 sudo 权限运行
if [ "$EUID" -ne 0 ]; then
  echo "❌ 错误: 请使用 sudo 或 root 权限运行此脚本。"
  echo "例如: sudo ./install_node.sh"
  exit 1
fi

echo "======================================"
echo "  🚀 开始安装最新版 Node.js (Debian)  "
echo "======================================"

# 2. 更新软件包列表并安装 curl
echo -e "\n📦 [1/3] 正在更新系统并安装依赖 (curl)..."
apt-get update -y
apt-get install -y curl

# 3. 下载并运行 NodeSource 安装脚本
# 注意：这里使用的是 setup_current.x (最新特性版)
# 如果你需要稳定版(LTS)，请将 setup_current.x 改为 setup_lts.x
echo -e "\n🌐 [2/3] 正在配置 NodeSource 仓库..."
curl -fsSL https://deb.nodesource.com/setup_current.x | bash -

# 4. 安装 Node.js
echo -e "\n⚙️ [3/3] 正在安装 Node.js 和 npm..."
apt-get install -y nodejs

# 5. 验证安装结果
echo -e "\n======================================"
echo "✅ 安装完成！验证版本信息："
echo -n "🟢 Node.js 版本: "
node -v
echo -n "🟢 npm 版本: "
npm -v
echo "======================================"

