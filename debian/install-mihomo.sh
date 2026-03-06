#!/bin/bash
# ============================================================================
# install-mihomo.sh - 安装 Mihomo (Clash Meta) 代理工具客户端
# 适用于 Debian 系统，让国内服务器可以访问国外的服务
# ============================================================================

source "$(dirname "$0")/common.sh"
require_root
require_x86_64

echo "======================================"
echo "  🚀 开始安装 Mihomo (Clash Meta)  "
echo "======================================"

# 1. 获取最新版本
log_step 1 4 "正在获取最新版本信息..."
LATEST_VERSION=$(curl -s "https://api.github.com/repos/MetaCubeX/mihomo/releases/latest" | grep '"tag_name":' | head -n 1 | sed -E 's/.*"([^"]+)".*/\1/')
if [[ -z "$LATEST_VERSION" ]]; then
    # 如果 API 请求受限或失败，使用一个较新的稳定兜底版本
    LATEST_VERSION="v1.18.3"
    log_warn "获取最新版本号失败，将使用默认版本: $LATEST_VERSION"
else
    log_info "发现最新版本: $LATEST_VERSION"
fi

# 2. 下载二进制文件
log_step 2 4 "正在下载 Mihomo 二进制文件..."

# 检查 CPU 是否支持 AVX2 指令集（Mihomo 默认版本要求 GOAMD64=v3 即 AVX2 支持）
if grep -q "avx2" /proc/cpuinfo 2>/dev/null; then
    log_info "检测到 CPU 支持 AVX2，将下载默认版本 (v3)"
    ARCH_SUFFIX="amd64"
else
    log_info "未检测到 AVX2 支持，将下载 compatible 版本 (v1)"
    ARCH_SUFFIX="amd64-compatible"
fi

DOWNLOAD_URL="https://github.com/MetaCubeX/mihomo/releases/download/${LATEST_VERSION}/mihomo-linux-${ARCH_SUFFIX}-${LATEST_VERSION}.gz"
# 使用代理加速下载
PROXY_URL="https://ghproxy.net/${DOWNLOAD_URL}"

log_info "下载地址: ${PROXY_URL}"
if ! curl -L -f -o mihomo.gz "${PROXY_URL}"; then
    log_warn "从 ghproxy.net 下载失败，尝试使用 mirror.ghproxy.com..."
    PROXY_URL="https://mirror.ghproxy.com/${DOWNLOAD_URL}"
    if ! curl -L -f -o mihomo.gz "${PROXY_URL}"; then
        log_error "下载失败，请检查网络或稍后重试"
        exit 1
    fi
fi

log_info "解压并安装..."
gzip -d mihomo.gz
mv mihomo /usr/local/bin/mihomo
chmod +x /usr/local/bin/mihomo

# 检查是否安装成功
if command_exists mihomo; then
    VER=$(mihomo -v 2>&1 | head -n 1)
    log_info "Mihomo 已安装至 /usr/local/bin/mihomo, 版本: $VER"
else
    log_error "Mihomo 安装失败"
    exit 1
fi

# 3. 创建配置目录和默认配置文件
log_step 3 4 "创建配置目录和默认配置文件..."
mkdir -p /etc/mihomo

# 提前下载 Geo 数据库（使用代理）
log_info "正在下载 Geo 数据库..."
curl -s -L -o /etc/mihomo/Country.mmdb "https://ghproxy.net/https://github.com/MetaCubeX/meta-rules-dat/releases/download/latest/country.mmdb" || log_warn "Country.mmdb 下载失败"
curl -s -L -o /etc/mihomo/geosite.dat "https://ghproxy.net/https://github.com/MetaCubeX/meta-rules-dat/releases/download/latest/geosite.dat" || log_warn "geosite.dat 下载失败"

CONFIG_FILE="/etc/mihomo/config.yaml"
if [[ ! -f "$CONFIG_FILE" ]]; then
    cat > "$CONFIG_FILE" <<EOF
# Mihomo (Clash Meta) 配置文件
port: 7890
socks-port: 7891
allow-lan: true
mode: rule
log-level: info
external-controller: 0.0.0.0:9090
secret: ""

# 代理提供商（通过订阅链接获取节点，推荐使用此方式）
proxy-providers:
  # 取消下方注释并填入你的订阅链接
  # my_provider:
  #   type: http
  #   url: "https://your-subscription-url"
  #   interval: 3600
  #   path: ./my_provider.yaml
  #   health-check:
  #     enable: true
  #     interval: 600
  #     url: http://www.gstatic.com/generate_204

# 静态代理节点
proxies:
  # 如果不使用订阅链接，可以在这里填写你的静态节点信息

# 策略组
proxy-groups:
  - name: PROXY
    type: select
    proxies:
      - DIRECT
    # 取消下方注释引入提供商节点
    # use:
    #   - my_provider

# 路由规则
rules:
  # 国内 IP 直连
  - GEOIP,CN,DIRECT
  # 国内域名直连
  - GEOSITE,CN,DIRECT
  # 其他默认走代理
  - MATCH,PROXY
EOF
    log_info "已生成默认配置文件: $CONFIG_FILE"
else
    log_warn "配置文件已存在，跳过覆盖: $CONFIG_FILE"
fi

# 4. 配置 Systemd 服务
log_step 4 4 "配置 Systemd 服务..."
SERVICE_FILE="/etc/systemd/system/mihomo.service"
cat > "$SERVICE_FILE" <<EOF
[Unit]
Description=Mihomo Daemon, Another Clash Kernel
After=network.target network-online.target nss-lookup.target

[Service]
Type=simple
StandardError=journal
User=root
ExecStart=/usr/local/bin/mihomo -d /etc/mihomo
Restart=on-failure
RestartSec=5s
LimitNOFILE=1048576

[Install]
WantedBy=multi-user.target
EOF

systemctl daemon-reload
# 尝试启用并启动，此时若因为没有代理节点启动会报错或不生效，但也无妨，等用户修了配置再restart
systemctl enable mihomo
systemctl start mihomo || log_warn "Mihomo 启动异常，可能是配置文件未填写节点信息。您可以填写后手动重启。"

log_info "Mihomo 服务已设置为开机自启"

echo "=========================================================================="
echo "✅ Mihomo 安装并配置完成！"
echo ""
echo "📂 配置文件路径: /etc/mihomo/config.yaml"
echo "👉 下一步:"
echo "  1. 请编辑 /etc/mihomo/config.yaml 文件，填入您的订阅链接或国外节点信息。"
echo "  2. 修改配置后，重启服务生效:"
echo "     systemctl restart mihomo"
echo "  3. 查看服务状态:"
echo "     systemctl status mihomo"
echo ""
echo "🌐 如何让当前终端通过 Mihomo 访问外网："
echo "只需在终端执行以下命令（可写入 ~/.bashrc 或 ~/.zshrc）："
echo "  export http_proxy=http://127.0.0.1:7890"
echo "  export https_proxy=http://127.0.0.1:7890"
echo "  export all_proxy=socks5://127.0.0.1:7891"
echo "=========================================================================="
