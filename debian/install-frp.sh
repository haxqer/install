#!/bin/bash
# ============================================================================
# install-frp.sh - 安装 frp 客户端或服务端
#
# 用法:
#   install-frp.sh --mode client    安装 frpc (客户端)
#   install-frp.sh --mode server    安装 frps (服务端)
# ============================================================================

source "$(dirname "$0")/common.sh"
require_root
require_x86_64

# ─── 参数解析 ───────────────────────────────────────────────────────────────
MODE=""
while [[ $# -gt 0 ]]; do
    case "$1" in
        --mode)
            MODE="$2"
            shift 2
            ;;
        *)
            log_error "未知参数: $1"
            echo "用法: $(basename "$0") --mode client|server"
            exit 1
            ;;
    esac
done

if [[ "$MODE" != "client" && "$MODE" != "server" ]]; then
    echo "用法: $(basename "$0") --mode client|server"
    exit 1
fi

# 根据模式设置变量
if [[ "$MODE" == "client" ]]; then
    SUFFIX="c"
    ROLE="client"
    CONFIG_FILE="frpc.ini"
    FULL_CONFIG_FILE="frpc_full.ini"
else
    SUFFIX="s"
    ROLE="server"
    CONFIG_FILE="frps.ini"
    FULL_CONFIG_FILE="frps_full.ini"
fi

# ─── 安装流程 ───────────────────────────────────────────────────────────────
prompt() {
    while true; do
        read -rp "$1 [y/N] " yn
        case $yn in
            [Yy]) return 0 ;;
            [Nn]|"") return 1 ;;
        esac
    done
}

NAME=frp
VERSION=$(curl -fsSL https://api.github.com/repos/fatedier/frp/releases/latest | grep tag_name | sed -E 's/.*"v(.*)".*/\1/')
TARBALL="${NAME}_${VERSION}_linux_amd64.tar.gz"
DOWNLOADURL="https://github.com/fatedier/$NAME/releases/download/v$VERSION/$TARBALL"
TMPDIR="$(mktemp -d)"
INSTALLPREFIX=/usr/local
SYSTEMDPREFIX=/etc/systemd/system

BINARYPATH="${INSTALLPREFIX}/bin/${NAME}${SUFFIX}"
CONFIGPATH="${INSTALLPREFIX}/etc/${NAME}/${CONFIG_FILE}"
SYSTEMDPATH="${SYSTEMDPREFIX}/${NAME}${SUFFIX}.service"

log_info "进入临时目录 ${TMPDIR}..."
cd "${TMPDIR}"

log_info "下载 $NAME $VERSION ($ROLE)..."
curl -LO --progress-bar "$DOWNLOADURL" || wget -q --show-progress "$DOWNLOADURL"

log_info "解压 $NAME $VERSION..."
tar xzf "$TARBALL"
cd "${NAME}_${VERSION}_linux_amd64"

log_info "安装 ${NAME}${SUFFIX} $VERSION 到 ${BINARYPATH}..."
install -Dm755 "${NAME}${SUFFIX}" "${BINARYPATH}"

log_info "安装 $NAME $ROLE 配置到 $CONFIGPATH..."
if ! [[ -f "$CONFIGPATH" ]] || prompt "配置文件 $CONFIGPATH 已存在，是否覆盖?"; then
    install -Dm644 "$FULL_CONFIG_FILE" "$CONFIGPATH"
else
    log_warn "跳过配置文件安装..."
fi

if [[ -d "$SYSTEMDPREFIX" ]]; then
    log_info "安装 ${NAME}${SUFFIX} systemd 服务到 $SYSTEMDPATH..."
    if ! [[ -f "$SYSTEMDPATH" ]] || prompt "systemd 服务 $SYSTEMDPATH 已存在，是否覆盖?"; then
        cat > "$SYSTEMDPATH" << EOF
[Unit]
Description=${NAME}${SUFFIX}
Documentation=
After=network.target network-online.target nss-lookup.target

[Service]
Type=simple
StandardError=journal
ExecStart="$BINARYPATH" -c "$CONFIGPATH"
ExecReload=/bin/kill -HUP \$MAINPID
LimitNOFILE=51200
Restart=on-failure
RestartSec=1s

[Install]
WantedBy=multi-user.target
EOF

        log_info "重载 systemd daemon..."
        systemctl daemon-reload
    else
        log_warn "跳过 systemd 服务安装..."
    fi
fi

log_info "清理临时目录 $TMPDIR..."
rm -rf "$TMPDIR"

log_info "✅ frp $ROLE 安装完成!"
