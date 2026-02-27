#!/bin/bash
# ============================================================================
# install-nodejs.sh - 安装最新版 Node.js (via NodeSource)
# ============================================================================

source "$(dirname "$0")/common.sh"
require_root

echo "======================================"
echo "  🚀 开始安装最新版 Node.js (Debian)  "
echo "======================================"

# 更新软件包列表并安装 curl
log_step 1 3 "正在更新系统并安装依赖 (curl)..."
apt-get update -y
apt-get install -y curl

# 下载并运行 NodeSource 安装脚本
# 注意：这里使用的是 setup_current.x (最新特性版)
# 如果你需要稳定版(LTS)，请将 setup_current.x 改为 setup_lts.x
log_step 2 3 "正在配置 NodeSource 仓库..."
curl -fsSL https://deb.nodesource.com/setup_current.x | bash -

# 安装 Node.js
log_step 3 3 "正在安装 Node.js 和 npm..."
apt-get install -y nodejs

# 验证安装结果
echo ""
echo "======================================"
echo "✅ 安装完成！验证版本信息："
echo -n "🟢 Node.js 版本: "
node -v
echo -n "🟢 npm 版本: "
npm -v
echo "======================================"
