#!/bin/bash
# ============================================================================
# install-trojan.sh - 安装 Trojan 代理服务 (Docker 方式)
#
# 用法:
#   install-trojan.sh            单实例模式 (配置存放 /etc/trojan/)
#   install-trojan.sh --multi    多实例模式 (配置存放 /etc/myweb${PORT}/)
# ============================================================================

source "$(dirname "$0")/common.sh"

MULTI_MODE=false
if [[ "${1:-}" == "--multi" ]]; then
    MULTI_MODE=true
fi

base_install() {
    apt-get update -y \
    && apt-get install -y sed curl
}

valid_port() {
    local port=$1
    local stat=1
    if [[ ${port} =~ ^[0-9]{1,5}$ ]]; then
        [[ $port -le 65535 ]]
        stat=$?
    fi
    return ${stat}
}

valid_password() {
    local password=$1
    local stat=1
    if [[ ${password} =~ ^[0-9a-zA-Z*#_\&-]{1,40}$ ]]; then
        stat=$?
    fi
    return ${stat}
}

random_port() {
    local port=0
    while true; do
        port=$(( RANDOM % 55536 + 10000 ))
        if ! ss -tlnp | grep -q ":${port} " 2>/dev/null; then
            echo ${port}
            return
        fi
    done
}

setup_port() {
    local stat=0
    local port=""

    while [[ ${stat} == 0 ]]; do
        printf "${YELLOW}Port (press Enter for random):${RESET} "
        read -r port
        if [[ -z "${port}" ]]; then
            port=$(random_port)
            printf "${GREEN}Auto-generated random port: ${BOLD}${port}${RESET}\n"
            stat=1
        elif valid_port "${port}"; then
            stat=1
        else
            printf "${RED}Invalid value entered: ${BLUE}${port} ${RESET} \n"
        fi
    done

    PORT=${port}
}

random_password() {
    tr -dc 'a-zA-Z0-9' < /dev/urandom | head -c 16
}

setup_password() {
    local stat=0
    local password=""

    while [[ ${stat} == 0 ]]; do
        printf "${YELLOW}Password (press Enter for random):${RESET} "
        read -r password
        if [[ -z "${password}" ]]; then
            password=$(random_password)
            printf "${GREEN}Auto-generated random password: ${BOLD}${password}${RESET}\n"
            stat=1
        elif valid_password "${password}"; then
            stat=1
        else
            printf "${RED}Invalid value entered: ${BLUE}${password} ${RESET} \n"
        fi
    done

    PASSWORD=${password}
}

setup_port_password() {
    setup_port
    setup_password
}

setup_config_file() {
    local config_dir
    local container_name
    local db_name="trojan"
    local db_user="trojan"
    local log_max_size="50m"
    local log_max_file="3"

    if [[ "$MULTI_MODE" == true ]]; then
        config_dir="/etc/myweb${PORT}"
        container_name="myweb-${PORT}"
        db_name="myweb111"
        db_user="myweb111"
        log_max_size="5m"
        log_max_file="1"
    else
        config_dir="/etc/trojan"
        container_name="trojan"
    fi

    mkdir -p "${config_dir}"
    local config_file_path="${config_dir}/config.json"

    cat > "${config_file_path}" <<EOF
{
    "run_type": "server",
    "local_addr": "0.0.0.0",
    "local_port": ${PORT},
    "remote_addr": "127.0.0.1",
    "remote_port": 11111,
    "password": [
        "${PASSWORD}"
    ],
    "log_level": 4,
    "ssl": {
        "cert": "/opt/1.crt",
        "key": "/opt/1.key",
        "key_password": "",
        "cipher": "ECDHE-ECDSA-AES128-GCM-SHA256:ECDHE-RSA-AES128-GCM-SHA256:ECDHE-ECDSA-AES256-GCM-SHA384:ECDHE-RSA-AES256-GCM-SHA384:ECDHE-ECDSA-CHACHA20-POLY1305:ECDHE-RSA-CHACHA20-POLY1305:DHE-RSA-AES128-GCM-SHA256:DHE-RSA-AES256-GCM-SHA384",
        "cipher_tls13": "TLS_AES_128_GCM_SHA256:TLS_CHACHA20_POLY1305_SHA256:TLS_AES_256_GCM_SHA384",
        "prefer_server_cipher": true,
        "alpn": [
            "http/1.1"
        ],
        "reuse_session": true,
        "session_ticket": false,
        "session_timeout": 600,
        "plain_http_response": "",
        "curves": "",
        "dhparam": ""
    },
    "tcp": {
        "prefer_ipv4": false,
        "no_delay": true,
        "keep_alive": true,
        "reuse_port": false,
        "fast_open": false,
        "fast_open_qlen": 20
    },
    "mysql": {
        "enabled": false,
        "server_addr": "127.0.0.1",
        "server_port": 3306,
        "database": "${db_name}",
        "username": "${db_user}",
        "password": ""
    }
}
EOF

    docker stop "${container_name}" >/dev/null 2>&1 || true
    docker rm "${container_name}" >/dev/null 2>&1 || true
    docker run -d \
        -p "${PORT}":"${PORT}" \
        --name "${container_name}" \
        --log-opt max-size="${log_max_size}" \
        --log-opt max-file="${log_max_file}" \
        --restart=always \
        -v "${config_dir}":/etc/myweb111 \
        haxqer/myweb111
}

print_clash_config() {
    local server_ip
    server_ip=$(curl -s4 ip.sb 2>/dev/null || curl -s4 ifconfig.me 2>/dev/null || echo "YOUR_SERVER_IP")

    local config_dir
    if [[ "$MULTI_MODE" == true ]]; then
        config_dir="/etc/myweb${PORT}"
    else
        config_dir="/etc/trojan"
    fi
    local clash_file="${config_dir}/clash.yaml"

    cat > "${clash_file}" <<EOF
mixed-port: 7890
allow-lan: true
bind-address: '*'
mode: rule
log-level: info
external-controller: '127.0.0.1:9090'

dns:
  enable: true
  listen: 0.0.0.0:53
  enhanced-mode: fake-ip
  fake-ip-range: 198.18.0.1/16
  nameserver:
    - 8.8.8.8
    - 1.1.1.1
  fallback:
    - tls://8.8.4.4
    - tls://1.0.0.1

proxies:
  - name: trojan-${PORT}
    type: trojan
    server: ${server_ip}
    port: ${PORT}
    password: ${PASSWORD}
    sni: ""
    skip-cert-verify: true
    udp: true

proxy-groups:
  - name: PROXY
    type: select
    proxies:
      - trojan-${PORT}
      - DIRECT

rules:
  - GEOIP,LAN,DIRECT
  - GEOIP,CN,DIRECT
  - MATCH,PROXY
EOF

    echo ""
    echo "${GREEN}${BOLD}===== Clash config saved to: ${clash_file} =====${RESET}"
    echo ""
    cat "${clash_file}"
    echo ""
    echo "${GREEN}${BOLD}=================================================${RESET}"
    echo ""
}

main() {
    echo "${BLUE}Time to set your trojan:${RESET}"

    printf "${YELLOW}Do you want to set your trojan? [Y/n]${RESET} "
    read -r opt
    case $opt in
        y*|Y*|"") echo "Set trojan..." ;;
        n*|N*) echo "Trojan setting skipped."; return ;;
        *) echo "Invalid choice. Trojan setting skipped."; return ;;
    esac

    base_install
    setup_port_password
    setup_config_file
    print_clash_config
}

main "$@"
