#!/bin/bash
# ============================================================================
# config-static-ip.sh - 配置静态 IP 地址
# ============================================================================

source "$(dirname "$0")/common.sh"
require_root

valid_ip() {
    local ip=$1
    local stat=1
    if [[ ${ip} =~ ^[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}$ ]]; then
        OIFS=$IFS
        IFS='.'
        ip=($ip)
        IFS=${OIFS}
        [[ ${ip[0]} -le 255 && ${ip[1]} -le 255 \
            && ${ip[2]} -le 255 && ${ip[3]} -le 255 ]]
        stat=$?
    fi
    return ${stat}
}

valid_netmask() {
    local netmask=$1
    local stat=1
    if [[ ${netmask} =~ ^[0-9]{1,2}$ ]]; then
        [[ ${netmask} -le 32 && ${netmask} -ge 1 ]]
        stat=$?
    fi
    return ${stat}
}

setup_ipv4() {
    local stat=0
    local ipv4=""
    while [[ ${stat} == 0 ]]; do
        printf "${YELLOW}IPv4 Address:${RESET} "
        read -r ipv4
        if valid_ip "${ipv4}"; then
            stat=1
        else
            printf "${RED}Invalid value entered: ${BLUE}${ipv4} ${RESET} \n"
        fi
    done
    IPV4=${ipv4}
}

setup_netmask() {
    local stat=0
    local netmask=""
    while [[ ${stat} == 0 ]]; do
        printf "${YELLOW}Netmask:${RESET} "
        read -r netmask
        if valid_netmask "${netmask}"; then
            stat=1
        else
            printf "${RED}Invalid value entered: ${BLUE}${netmask} ${RESET} \n"
        fi
    done
    NETMASK=${netmask}
}

setup_gateway() {
    local stat=0
    local gateway=""
    while [[ ${stat} == 0 ]]; do
        printf "${YELLOW}Gateway Address:${RESET} "
        read -r gateway
        if valid_ip "${gateway}"; then
            stat=1
        else
            printf "${RED}Invalid value entered: ${BLUE}${gateway} ${RESET} \n"
        fi
    done
    GATEWAY=${gateway}
}

setup_ip() {
    echo "${BLUE}Time to set your ip configure:${RESET}"
    setup_ipv4
    setup_netmask
    setup_gateway
}

setup_config_file() {
    # 自动检测默认网卡名称
    local iface
    iface=$(ip route show default 2>/dev/null | awk '{print $5; exit}')
    if [[ -z "$iface" ]]; then
        iface="ens192"
        log_warn "无法自动检测网卡，使用默认值: ${iface}"
    else
        log_info "检测到默认网卡: ${iface}"
    fi

    cat > /etc/network/interfaces <<EOF
# This file describes the network interfaces available on your system
# and how to activate them. For more information, see interfaces(5).

source /etc/network/interfaces.d/*

# The loopback network interface
auto lo
iface lo inet loopback

# The primary network interface
auto ${iface}
allow-hotplug ${iface}
iface ${iface} inet static
address ${IPV4}/${NETMASK}
gateway ${GATEWAY}
# dns-nameservers <DNS NameServers>
EOF

    log_info "正在重启网络..."
    service networking restart
    ip a
}

main() {
    echo "${BLUE}Time to change your ip to static:${RESET}"

    printf "${YELLOW}Do you want to change your ip? [Y/n]${RESET} "
    read -r opt
    case $opt in
        y*|Y*|"") echo "Changing the ip..." ;;
        n*|N*) echo "Ip change skipped."; return ;;
        *) echo "Invalid choice. Ip change skipped."; return ;;
    esac

    setup_ip
    setup_config_file
}

main "$@"
