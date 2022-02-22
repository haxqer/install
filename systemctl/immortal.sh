#!/bin/bash
set -euo pipefail

function prompt() {
    while true; do
        read -p "$1 [y/N] " yn
        case $yn in
            [Yy] ) return 0;;
            [Nn]|"" ) return 1;;
        esac
    done
}

if [[ $(id -u) != 0 ]]; then
    echo Please run this script as root.
    exit 1
fi

if [[ $(uname -m 2> /dev/null) != x86_64 ]]; then
    echo Please run this script on x86_64 machine.
    exit 1
fi

NAME=immortal
INSTALLPREFIX=/usr/bin
SYSTEMDPREFIX=/etc/systemd/system

BINARYPATH="${INSTALLPREFIX}/${NAME}dir"
CONFIGPATH="/data/immortal"
SYSTEMDPATH="${SYSTEMDPREFIX}/${NAME}.service"


if [[ -d "${SYSTEMDPREFIX}" ]]; then
    echo Installing ${NAME} systemd service to ${SYSTEMDPATH}...
    if ! [[ -f "${SYSTEMDPATH}" ]] || prompt "The systemd service already exists in ${SYSTEMDPATH}, overwrite?"; then
        cat > "${SYSTEMDPATH}" << EOF
[Unit]
Description=$NAME
Documentation=
After=network.target network-online.target nss-lookup.target

[Service]
Type=simple
StandardError=journal
ExecStart="$BINARYPATH" "$CONFIGPATH"
ExecReload=/bin/kill -HUP \$MAINPID
LimitNOFILE=51200
Restart=on-failure
RestartSec=3s

[Install]
WantedBy=multi-user.target
EOF

        echo Reloading systemd daemon...
        systemctl daemon-reload
    else
        echo Skipping installing ${NAME} systemd service...
    fi
fi

echo Done!
