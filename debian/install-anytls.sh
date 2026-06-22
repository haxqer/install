#!/bin/bash
# ============================================================================
# install-anytls-docker.sh - 一键部署 AnyTLS 代理服务端 (Docker 方式)
# 适用于 Debian / Ubuntu 系统
#
# 直接拉取预编译镜像 ghcr.io/haxqer/anytls，无需在服务器上编译。
# 镜像由 https://github.com/haxqer/anytls-docker 的 GitHub Actions 构建，
# 提供 linux/amd64 与 linux/arm64 双架构。
#
# 服务端使用内置自签证书，客户端 (mihomo / sing-box) 连接时跳过证书校验即可。
#
# 用法:
#   install-anytls.sh     交互式设置端口和密码后部署
#
# 可选环境变量 (设置后跳过对应交互):
#   PORT      监听端口   (默认随机)
#   PASSWORD  连接密码   (默认随机)
#   IMAGE     镜像地址   (默认 ghcr.io/haxqer/anytls:latest)
#   WORKDIR   部署目录   (默认 /opt/anytls${PORT}，按端口区分以支持多实例)
#
# 多实例: 每个实例按监听端口独立部署，配置目录与容器名均带端口后缀，
#         可在同一台机器上启动多个 AnyTLS 容器互不影响。
# ============================================================================

source "$(dirname "$0")/common.sh"
require_root

IMAGE="${IMAGE:-ghcr.io/haxqer/anytls:latest}"
# WORKDIR / CONTAINER_NAME 在确定 PORT 后再赋值 (见 setup_port 之后)，以便按端口区分多实例

# ─── 校验与生成函数 ──────────────────────────────────────────────────────────
valid_port() {
    local port=$1
    [[ ${port} =~ ^[0-9]{1,5}$ ]] && [[ $port -ge 1 && $port -le 65535 ]]
}

random_port() {
    local port=0
    while true; do
        port=$(( RANDOM % 55536 + 10000 ))
        if ! ss -tlnp 2>/dev/null | grep -q ":${port} "; then
            echo "${port}"
            return
        fi
    done
}

random_password() {
    LC_ALL=C tr -dc 'a-zA-Z0-9' < /dev/urandom | head -c 16 || true
}

setup_port() {
    if [[ -n "${PORT:-}" ]]; then
        valid_port "${PORT}" || { log_error "环境变量 PORT 无效: ${PORT}"; exit 1; }
        return
    fi
    local port=""
    while true; do
        printf "${YELLOW}端口 Port (回车随机生成):${RESET} "
        read -r port
        if [[ -z "${port}" ]]; then
            port=$(random_port)
            printf "${GREEN}已随机生成端口: ${BOLD}${port}${RESET}\n"
            break
        elif valid_port "${port}"; then
            break
        else
            printf "${RED}无效端口: ${BLUE}${port}${RESET}\n"
        fi
    done
    PORT=${port}
}

setup_password() {
    if [[ -n "${PASSWORD:-}" ]]; then
        return
    fi
    local password=""
    while true; do
        printf "${YELLOW}密码 Password (回车随机生成):${RESET} "
        read -r password
        if [[ -z "${password}" ]]; then
            password=$(random_password)
            printf "${GREEN}已随机生成密码: ${BOLD}${password}${RESET}\n"
            break
        elif [[ ${password} =~ ^[0-9a-zA-Z*#_\&-]{1,40}$ ]]; then
            break
        else
            printf "${RED}无效密码 (仅支持字母/数字及 *#_&- 共 1-40 位): ${BLUE}${password}${RESET}\n"
        fi
    done
    PASSWORD=${password}
}

# ─── 安装 Docker ─────────────────────────────────────────────────────────────
install_docker() {
    if command_exists docker; then
        log_info "Docker 已安装: $(docker --version)"
    else
        log_info "正在安装 Docker (官方源)..."
        export DEBIAN_FRONTEND=noninteractive
        apt-get update -y >/dev/null 2>&1 || log_warn "apt-get update 失败，继续尝试..."
        apt-get install -y ca-certificates curl gnupg lsb-release >/dev/null 2>&1

        install -m 0755 -d /etc/apt/keyrings
        local os_id
        os_id="$(. /etc/os-release && echo "$ID")"
        curl -fsSL "https://download.docker.com/linux/${os_id}/gpg" \
            -o /etc/apt/keyrings/docker.asc
        chmod a+r /etc/apt/keyrings/docker.asc

        echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] \
https://download.docker.com/linux/${os_id} $(. /etc/os-release && echo "$VERSION_CODENAME") stable" \
            > /etc/apt/sources.list.d/docker.list

        apt-get update -y >/dev/null 2>&1
        apt-get install -y docker-ce docker-ce-cli containerd.io \
            docker-buildx-plugin docker-compose-plugin >/dev/null 2>&1 \
            || { log_error "Docker 安装失败"; exit 1; }
        log_info "Docker 安装完成: $(docker --version)"
    fi

    systemctl enable --now docker >/dev/null 2>&1 || true

    if ! docker compose version >/dev/null 2>&1; then
        log_error "未检测到 docker compose 插件，请手动安装 docker-compose-plugin"
        exit 1
    fi
}

# ─── 生成部署文件 ────────────────────────────────────────────────────────────
write_files() {
    mkdir -p "${WORKDIR}"

    cat > "${WORKDIR}/docker-compose.yml" <<EOF
services:
  anytls:
    image: ${IMAGE}
    container_name: ${CONTAINER_NAME}
    restart: always
    network_mode: host
    command: ["-l", "0.0.0.0:${PORT}", "-p", "${PASSWORD}"]
EOF

    # 保存配置备查
    cat > "${WORKDIR}/anytls.env" <<EOF
PORT=${PORT}
PASSWORD=${PASSWORD}
IMAGE=${IMAGE}
EOF
    chmod 600 "${WORKDIR}/anytls.env"
}

# ─── 安装步骤 ────────────────────────────────────────────────────────────────
echo "======================================"
echo "  🚀 部署 AnyTLS (Docker / GHCR 镜像)  "
echo "======================================"

setup_port
setup_password

# 按端口区分多实例: 配置目录与容器名均带端口后缀
WORKDIR="${WORKDIR:-/opt/anytls${PORT}}"
CONTAINER_NAME="anytls-${PORT}"

log_step 1 4 "检测并安装 Docker..."
install_docker

log_step 2 4 "生成部署文件到 ${WORKDIR}..."
write_files

log_step 3 4 "拉取镜像并启动容器..."
cd "${WORKDIR}"
docker compose pull || { log_error "镜像拉取失败 (${IMAGE})"; exit 1; }
docker compose up -d || { log_error "容器启动失败"; exit 1; }

sleep 2
if docker compose ps --status running 2>/dev/null | grep -q "${CONTAINER_NAME}"; then
    log_info "AnyTLS 容器 ${CONTAINER_NAME} 已启动并设置为开机自启"
else
    log_warn "AnyTLS 容器启动异常，请使用 'docker compose -f ${WORKDIR}/docker-compose.yml logs' 查看日志"
fi

# 4. 输出客户端配置
log_step 4 4 "生成客户端配置..."
SERVER_IP=$(curl -s4 ip.sb 2>/dev/null || curl -s4 ifconfig.me 2>/dev/null || echo "YOUR_SERVER_IP")
CLASH_FILE="${WORKDIR}/clash.yaml"

cat > "${CLASH_FILE}" <<EOF
# AnyTLS 节点 (mihomo / Clash.Meta 客户端)
proxies:
  - name: anytls-${PORT}
    type: anytls
    server: ${SERVER_IP}
    port: ${PORT}
    password: ${PASSWORD}
    client-fingerprint: chrome
    udp: true
    idle-session-check-interval: 30
    idle-session-timeout: 30
    skip-cert-verify: true

proxy-groups:
  - name: PROXY
    type: select
    proxies:
      - anytls-${PORT}
      - DIRECT

rules:
  - GEOIP,CN,DIRECT
  - MATCH,PROXY
EOF

echo ""
echo "=========================================================================="
echo "✅ AnyTLS (Docker) 部署完成！"
echo ""
echo "  服务器地址: ${SERVER_IP}"
echo "  端口 Port : ${PORT}"
echo "  密码 Pass : ${PASSWORD}"
echo "  镜像 Image: ${IMAGE}"
echo "  容器 Name : ${CONTAINER_NAME}"
echo ""
echo "  客户端 URI: anytls://${PASSWORD}@${SERVER_IP}:${PORT}/?insecure=1"
echo ""
echo "📂 客户端配置已保存至: ${CLASH_FILE}"
echo "📂 部署目录: ${WORKDIR}"
echo "🔧 常用命令:"
echo "     docker compose -f ${WORKDIR}/docker-compose.yml ps        # 查看状态"
echo "     docker compose -f ${WORKDIR}/docker-compose.yml logs -f   # 查看日志"
echo "     docker compose -f ${WORKDIR}/docker-compose.yml pull && \\"
echo "       docker compose -f ${WORKDIR}/docker-compose.yml up -d   # 升级镜像"
echo "     docker compose -f ${WORKDIR}/docker-compose.yml down       # 停止并移除"
echo ""
echo "⚠️  服务端为自签证书，客户端需开启 skip-cert-verify / insecure。"
echo "⚠️  请在防火墙/安全组放行 TCP ${PORT} 端口。"
echo "=========================================================================="
echo ""
cat "${CLASH_FILE}"
echo ""
