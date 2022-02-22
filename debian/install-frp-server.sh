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

NAME=frp
VERSION=$(curl -fsSL https://api.github.com/repos/fatedier/frp/releases/latest | grep tag_name | sed -E 's/.*"v(.*)".*/\1/')
TARBALL="${NAME}_${VERSION}_linux_amd64.tar.gz"
DOWNLOADURL="https://github.com/fatedier/$NAME/releases/download/v$VERSION/$TARBALL"
TMPDIR="$(mktemp -d)"
INSTALLPREFIX=/usr/local
SYSTEMDPREFIX=/etc/systemd/system

BINARYPATH="${INSTALLPREFIX}/bin/${NAME}s"
CONFIGPATH="${INSTALLPREFIX}/etc/${NAME}/frps.ini"
SYSTEMDPATH="${SYSTEMDPREFIX}/${NAME}s.service"

echo Entering temp directory ${TMPDIR}...
cd "${TMPDIR}"

echo Downloading $NAME $VERSION...
curl -LO --progress-bar "$DOWNLOADURL" || wget -q --show-progress "$DOWNLOADURL"

echo Unpacking $NAME $VERSION...
tar xzf "$TARBALL"
cd "${NAME}_${VERSION}_linux_amd64"

echo Installing "${NAME}s" $VERSION to "${BINARYPATH}"...
install -Dm755 "${NAME}s" "${BINARYPATH}"

echo Installing $NAME server config to $CONFIGPATH...
if ! [[ -f "$CONFIGPATH" ]] || prompt "The server config already exists in $CONFIGPATH, overwrite?"; then
    install -Dm644 frps_full.ini "$CONFIGPATH"
else
    echo Skipping installing $NAME server config...
fi

if [[ -d "$SYSTEMDPREFIX" ]]; then
    echo Installing ${NAME}s systemd service to $SYSTEMDPATH...
    if ! [[ -f "$SYSTEMDPATH" ]] || prompt "The systemd service already exists in $SYSTEMDPATH, overwrite?"; then
        cat > "$SYSTEMDPATH" << EOF
[Unit]
Description=${NAME}s
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

        echo Reloading systemd daemon...
        systemctl daemon-reload
    else
        echo Skipping installing ${NAME}s systemd service...
    fi
fi

echo Deleting temp directory $TMPDIR...
rm -rf "$TMPDIR"

echo Done!

