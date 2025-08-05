
set -e

echo "🚀 使用量统计系统安装器"
echo "======================================"

CONFIG_DIR="$HOME/.vibeloft"

# 检查系统要求
check_requirements() {
    echo "📋 检查系统要求..."
    
    if ! command -v node &> /dev/null; then
        echo "❌ 错误: 需要安装 Node.js"
        echo "请访问 https://nodejs.org 安装 Node.js"
        exit 1
    fi
    
    if ! command -v npm &> /dev/null; then
        echo "❌ 错误: 需要安装 npm"
        exit 1
    fi
    
    if ! command -v claude &> /dev/null; then
        echo "❌ 错误: 需要安装 Claude Code"
        echo "请运行: npm install -g @anthropic-ai/claude-code"
        exit 1
    fi
    
    echo "✅ 系统要求检查通过"
}


# 安装 ccusage
install_ccusage() {
    echo "📦 安装 ccusage..."
    
    if command -v ccusage &> /dev/null; then
        echo "✅ ccusage 已安装"
        # 配置 hook 
    else
        echo "正在安装 ccusage..."
        npm install -g ccusage
        echo "✅ ccusage 安装完成"
    fi
}

# 创建 CONFIG_DIR
create_file_system() {
    echo "📝 创建文件系统..."
    mkdir -p "$CONFIG_DIR"
    # 把 report_cc.sh 复制到 CONFIG_DIR 并给其执行权限
    cp report_cc.sh "$CONFIG_DIR/report_cc.sh"
    chmod +x "$CONFIG_DIR/report_cc.sh"
    echo "✅ 文件系统已创建"
}

create_claude_code_hook() {
    echo "📝 配置 Claude Code hook..."
    
    # Claude Code 设置文件路径
    CLAUDE_SETTINGS="$HOME/.claude/settings.json"
    
    # 检查设置文件是否存在
    if [ ! -f "$CLAUDE_SETTINGS" ]; then
        echo "📝 创建 Claude Code 设置文件..."
        mkdir -p "$HOME/.claude"
        cat > "$CLAUDE_SETTINGS" << 'EOF'
{
  "$schema": "https://json.schemastore.org/claude-code-settings.json",
  "feedbackSurveyState": {
    "lastShownTime": 1754086371480
  },
  "hooks": {
    "Stop": []
  }
}
EOF
        echo "✅ Claude Code 设置文件已创建"
    fi
    
    echo "🔍 检查现有 hook 配置..."
    
    # 使用纯 shell 检查 Stop hook 是否已存在
    STOP_HOOK_EXISTS=false
    
    # 检查文件中是否包含我们的 hook 配置
    if grep -q "~/.vibeloft/report_cc.sh" "$CLAUDE_SETTINGS"; then
        # 进一步检查是否在正确的 Stop 段落中
        if grep -A 20 '"Stop"' "$CLAUDE_SETTINGS" | grep -q "~/.vibeloft/report_cc.sh"; then
            STOP_HOOK_EXISTS=true
            echo "ℹ️  Stop hook 已存在，跳过"
        fi
    fi
    
    # 如果 Stop hook 不存在，则重新生成完整配置
    if [ "$STOP_HOOK_EXISTS" = false ]; then
        echo "➕ 更新 hook 配置..."
        
        # 备份原文件
        cp "$CLAUDE_SETTINGS" "$CLAUDE_SETTINGS.backup"
        
        # 提取现有的非 hooks 配置
        SCHEMA_VALUE=$(grep '"\$schema"' "$CLAUDE_SETTINGS" | sed 's/.*: *"\([^"]*\)".*/\1/' || echo "https://json.schemastore.org/claude-code-settings.json")
        LAST_SHOWN_TIME=$(grep '"lastShownTime"' "$CLAUDE_SETTINGS" | sed 's/.*: *\([0-9]*\).*/\1/' || echo "1754086371480")
        
        # 生成新的配置文件，只包含 Stop hooks
        cat > "$CLAUDE_SETTINGS" << EOF
{
  "\$schema": "$SCHEMA_VALUE",
  "feedbackSurveyState": {
    "lastShownTime": $LAST_SHOWN_TIME
  },
  "hooks": {
    "Stop": [
      {
        "matcher": "",
        "hooks": [
          {
            "type": "command",
            "command": "~/.vibeloft/report_cc.sh"
          }
        ]
      }
    ]
  }
}
EOF
        
        echo "✅ Stop hook 已添加"
    fi
    
    echo "✅ Claude Code hook 配置完成"
}


# 主安装流程
main() {
    create_file_system
    check_requirements
    install_ccusage
    create_claude_code_hook
    # setup_alias
    # create_immediate_report_script
    
    echo ""
    echo "🎉 安装完成！"
    echo "=============="
    echo ""
    echo "📁 配置文件位置: $CONFIG_DIR/"
    echo "⚙️  配置文件: $CONFIG_DIR/config.json"
    echo "📊 立即上报: $CONFIG_DIR/report-now.sh"
    echo ""
    echo "🔧 使用说明:"
    echo "1. 重新加载 shell 配置或重启终端"
    echo "2. 正常使用 claude-code 命令，使用量将自动上报"
    echo "3. 运行手动上报脚本进行立即上报"
    echo ""
    echo "📝 日志文件: $CONFIG_DIR/reports.log"
    echo ""
    echo "⚠️  注意: 请确保您的服务器能接收 POST 请求"
}

main "$@"