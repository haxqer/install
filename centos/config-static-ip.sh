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
  NEW_UUID_1=$(cat /dev/urandom | tr -dc 'a-f0-9' | fold -w 8 | head -n 1)
  NEW_UUID_2=$(cat /dev/urandom | tr -dc 'a-f0-9' | fold -w 12 | head -n 1)
    echo "
TYPE="Ethernet"
PROXY_METHOD="none"
BROWSER_ONLY="no"
BOOTPROTO="none"
DEFROUTE="yes"
IPV4_FAILURE_FATAL="yes"
IPV6INIT="yes"
IPV6_AUTOCONF="yes"
IPV6_DEFROUTE="yes"
IPV6_FAILURE_FATAL="no"
IPV6_ADDR_GEN_MODE="stable-privacy"
NAME="ens192"
UUID="${NEW_UUID_1}-45d8-4357-b502-${NEW_UUID_2}"
DEVICE="ens192"
ONBOOT="yes"
IPADDR="${IPV4}"
PREFIX="${NETMASK}"
GATEWAY="${GATEWAY}"
DNS1="119.29.29.29"
DNS2="58.215.45.20"
DNS3="114.114.114.114"
IPV6_PRIVACY="no"
" > /etc/sysconfig/network-scripts/ifcfg-ens192
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



