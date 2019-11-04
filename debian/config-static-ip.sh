#!/bin/bash

setup_color() {
	# Only use colors if connected to a terminal
	if [[ -t 1 ]]; then
		RED=$(printf '\033[31m')
		GREEN=$(printf '\033[32m')
		YELLOW=$(printf '\033[33m')
		BLUE=$(printf '\033[34m')
		BOLD=$(printf '\033[1m')
		RESET=$(printf '\033[m')
	else
		RED=""
		GREEN=""
		YELLOW=""
		BLUE=""
		BOLD=""
		RESET=""
	fi
}

valid_ip(){
    local  ip=$1
    local  stat=1

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

valid_netmask(){
    local  netmask=$1
    local  stat=1

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
        read ipv4
        if valid_ip ${ipv4} ; then
            stat=1
        else
            printf "${RED}Invalid value enterd: ${BLUE}${ipv4} ${RESET} \n"
        fi
    done

    IPV4=${ipv4}
}

setup_netmask() {
    local stat=0
    local netmask=""

    while [[ ${stat} == 0 ]]; do
        printf "${YELLOW}Netmask :${RESET} "
        read netmask
        if valid_netmask ${netmask} ; then
            stat=1
        else
            printf "${RED}Invalid value enterd: ${BLUE}${netmask} ${RESET} \n"
        fi
    done

    NETMASK=${netmask}
}

setup_gateway() {
    local stat=0
    local gateway=""

    while [[ ${stat} == 0 ]]; do
        printf "${YELLOW}Gateway Address:${RESET} "
        read gateway
        if valid_ip ${gateway} ; then
            stat=1
        else
            printf "${RED}Invalid value enterd: ${BLUE}${gateway} ${RESET} \n"
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
    echo "
# This file describes the network interfaces available on your system
# and how to activate them. For more information, see interfaces(5).

source /etc/network/interfaces.d/*

# The loopback network interface
auto lo
iface lo inet loopback

# The primary network interface
# allow-hotplug ens192
# iface ens192 inet dhcp

auto ens192
allow-hotplug ens192
iface ens192 inet static
address ${IPV4}/${NETMASK}
gateway ${GATEWAY}
# dns-nameservers <DNS NameServers>

" > /etc/network/interfaces
    service networking restart
    ip a
}



main(){
    setup_color

    echo "${BLUE}Time to change your ip to static:${RESET}"

    # Prompt for user choice on changing the ip configure
    printf "${YELLOW}Do you want to change your ip? [Y/n]${RESET} "
    read opt
	case $opt in
		y*|Y*|"") echo "Changing the ip..." ;;
		n*|N*) echo "Ip change skipped."; return ;;
		*) echo "Invalid choice. Ip change skipped."; return ;;
	esac

    setup_ip
    setup_config_file
}

main "$@"


#
#service networking restart



