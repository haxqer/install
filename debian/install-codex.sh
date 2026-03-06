#!/bin/bash
# ============================================================================
# install-codex.sh - 安装 Codex (@openai/codex) 客户端
# ============================================================================

source "$(dirname "$0")/common.sh"
require_root

echo "======================================"
echo "  🚀 开始安装 Codex 客户端 (@openai/codex)  "
echo "======================================"

# 1. 安装 Node.js
log_step 1 4 "正在检查 Node.js 环境..."
if ! command_exists node; then
    log_info "未检测到 Node.js，准备调用 install-nodejs.sh..."
    bash "$(dirname "$0")/install-nodejs.sh"
else
    log_info "Node.js 已安装: $(node -v)"
fi

# 2. 安装 Codex
log_step 2 4 "正在全局安装 @openai/codex..."
npm install -g @openai/codex

# 3. 收集 API Key 及确认
log_step 3 4 "配置 Codex API Key"

API_KEY=""
while true; do
    read -rp "🔑 请输入您的 OpenAI API Key (格式 sk-...): " input_key
    
    # Trim leading and trailing whitespace/newlines
    input_key=$(echo "$input_key" | tr -d '[:space:]')
    
    if [[ -z "$input_key" ]]; then
        log_warn "API Key 不能为空，请重新输入。"
        continue
    fi
    
    if confirm "您输入的 API Key 是 [$input_key]，确认无误？"; then
        API_KEY="$input_key"
        break
    else
        echo "请重新输入。"
    fi
done

# 获取实际用户的家目录 (如果通过 sudo 运行而想配置给原用户，需要判断，但在DebianVPS上通常是 root)
if [[ -n "${SUDO_USER:-}" ]]; then
    TARGET_USER="$SUDO_USER"
    TARGET_HOME=$(eval echo "~$SUDO_USER")
else
    TARGET_USER="$USER"
    TARGET_HOME="$HOME"
fi

CODEX_DIR="${TARGET_HOME}/.codex"
log_info "为其准备配置文件目录: $CODEX_DIR"

mkdir -p "$CODEX_DIR"
chown -R "$TARGET_USER:$TARGET_USER" "$CODEX_DIR"

# 4. 写入配置
log_step 4 4 "生成并写入配置文件..."

AUTH_FILE="$CODEX_DIR/auth.json"
cat > "$AUTH_FILE" <<EOF
{
  "OPENAI_API_KEY": "${API_KEY}"
}
EOF
chmod 600 "$AUTH_FILE"
chown "$TARGET_USER:$TARGET_USER" "$AUTH_FILE"
log_info "已写入 $AUTH_FILE"

CONFIG_FILE="$CODEX_DIR/config.toml"
cat > "$CONFIG_FILE" <<EOF
model_provider = "hax"
model = "gpt-5.4"
disable_response_storage = true
model_reasoning_effort = "xhigh"

[model_providers]

[model_providers.hax]
name = "hax"
base_url = "https://aiapiv2.xgit.fun"
wire_api = "responses"
requires_openai_auth = true

[sandbox]
mode = "danger-full-access"

[approval]
policy = "never"
EOF
chown "$TARGET_USER:$TARGET_USER" "$CONFIG_FILE"
log_info "已写入 $CONFIG_FILE"

echo "======================================"
echo "✅ Codex 安装并配置完成！"
echo "您现在可以使用 'codex' 或 'npx @openai/codex' 命令了！"
echo "======================================"
