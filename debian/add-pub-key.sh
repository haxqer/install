#!/bin/bash
# ============================================================================
# add-pub-key.sh - 添加 SSH 公钥到 authorized_keys
#
# 用法:
#   add-pub-key.sh --user haxqer          # 添加预设用户的公钥
#   add-pub-key.sh --user haxqer,k8s      # 添加多个用户的公钥
#   add-pub-key.sh --key "ssh-rsa ..."    # 添加自定义公钥
#   add-pub-key.sh --list                 # 列出所有预设用户
# ============================================================================

source "$(dirname "$0")/common.sh"

# ─── 预设公钥 ───────────────────────────────────────────────────────────────
declare -A KEYS=(
    [haxqer]="ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAINwzgqGNzBlRkdbFdBYIIw7EVRcycpVnOnfQ37YgSZh+ haxqer"
    [k8s]="ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQCyFEkvdIYvYPNcG52s9vW1uSW2CVt/WJZ6qQxmvCuOMKeT2SlyEN47D7iPz7uF6+6DQvqme6Y69o+reG3S1SvT7tPe2koon4qNzr+42yzUXRmgnH6EbhYFOVsXGnlIj7CTEHlD79a+wzTrLNPMSJ1va36bhFJvTDTOtdTNlKqi52qmP+p7TzGN29rpUs+67opeAYFxOAans5a+viGJiUyBvax4mVBwZsrTqdPJOZvW1QtjSZyyWcD9tD5nVqhCKYBNqOJ9Tlfn78oAZuC3qGX8URq5063HLdSs80AKbLC/hHHbF+cX0gPJyHXxpC/74LenszCHkBbLCs1f6pnbxkoh k8s"
    [nelson]="ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQC+9JNkIKoMwCQaFbzrsdzUTq68YnZCuSVa4VdCFE0g3YgvhQdaMBFGjpAHeBR7AyO4QcMIEqaNNGAkUfrFuBYAX+UqI8VRNUg3cwdkRhFgpDTFGLPaEla9BT5dRJEZPnDdkgPyqw4ru1I6YMACPrVXVSfFG9ZlnsUI3+Xoqq6ePX73kSCevOOkdUn1ZyxYeN49NNqEt5e2nX3ayicOx1p9cnUb2viw6qIVzD+3SLByhSqWoww3/OciaLRQF/Sxd9eulQgBlKis2wgMlmKTpMfmhiFI4U1+vG0s93F7cunXCrxosHpuTG4Iuxodxp4nV3UQQ0GylCpHfclZ5a0kukcN yetnelson@gmail.com"
    [xsharp]="ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQDCy5SN7sEpZwF2XRtcOt7HlO8mPiYktjNgCHGdJ43eNtNVNmNKjABtCSdRKvxUmdd8NMnmlnbFcMbmVjnljiHhT/Y+Kn7Li0vLG0qKRZIyBkuVOAM4HRUsqRnRNcsw/dHzfKs6kX83sP3HOeckIyso12oJEw8o7uJkO0kM1Bcqc/QwnucAB+MtwJ5hvbEB09B9yuSieMyci3btR5MH7KYHBMv4A986/pvsrj3XUmyTv5INPTCbL5Zku3QroizePZ58ZGwwyN5e0+gfNnhPZLmvA8B9lajOZxl2x2qyEwLdFvNbeYXUJn0kU1lgCCq3xLW+lEUvgdOkqVLiwW5fVZWR xsharp@gmail.com"
)

add_key() {
    local key="$1"
    mkdir -p ~/.ssh
    chmod 700 ~/.ssh
    # 避免重复添加
    if ! grep -qF "$key" ~/.ssh/authorized_keys 2>/dev/null; then
        echo "$key" >> ~/.ssh/authorized_keys
        chmod 600 ~/.ssh/authorized_keys
        log_info "公钥已添加"
    else
        log_warn "公钥已存在，跳过"
    fi
}

list_users() {
    log_info "可用的预设用户:"
    for user in "${!KEYS[@]}"; do
        echo "  - $user"
    done
}

usage() {
    echo "用法:"
    echo "  $(basename "$0") --user <name>[,<name>...]  添加预设用户的公钥"
    echo "  $(basename "$0") --key \"ssh-rsa ...\"        添加自定义公钥"
    echo "  $(basename "$0") --list                     列出所有预设用户"
    exit 1
}

# ─── 主逻辑 ─────────────────────────────────────────────────────────────────
if [[ $# -eq 0 ]]; then
    # 兼容旧行为：无参数时默认添加 haxqer 的公钥
    add_key "${KEYS[haxqer]}"
    exit 0
fi

case "$1" in
    --user)
        [[ -z "${2:-}" ]] && usage
        IFS=',' read -ra users <<< "$2"
        for user in "${users[@]}"; do
            if [[ -n "${KEYS[$user]:-}" ]]; then
                log_info "添加用户 ${BOLD}${user}${RESET} 的公钥..."
                add_key "${KEYS[$user]}"
            else
                log_error "未知用户: $user (使用 --list 查看可用用户)"
            fi
        done
        ;;
    --key)
        [[ -z "${2:-}" ]] && usage
        add_key "$2"
        ;;
    --list)
        list_users
        ;;
    *)
        usage
        ;;
esac
