# Vibeloft Usage - AI 编程工具使用量统计系统

🚀 自动化统计和上报多平台 AI 编程工具使用量的轻量级系统

## 🎯 支持的工具

| 工具 | 状态 | 说明 |
|------|------|------|
| **Claude Code** | ✅ 已实现 | Anthropic 官方 CLI 工具 |
| **Cursor** | 🚧 计划中 | AI-powered 代码编辑器 |
| **GitHub Copilot** | 🚧 计划中 | GitHub 官方 AI 编程助手 |

> 📢 **当前版本**：v1.0 - 仅支持 Claude Code，其他工具正在开发中

## 📋 系统要求

安装前请确保系统已安装以下基础依赖：

- **Node.js** (v14 或更高版本) - 运行时环境
- **npm** - 包管理器

```bash
# 检查是否已安装
node --version
npm --version

# macOS 安装方式
brew install node

# 或访问官网下载
# https://nodejs.org/
```

> 💡 **提示**：AI 编程工具（如 Claude Code、Cursor、Copilot）无需预先安装，系统会根据实际使用情况自动配置

## 🛠️ 安装方式

### 方式一：一键安装（推荐）

```bash
# 下载并运行安装脚本
git clone https://github.com/BellyBook/Vibeloft-usage
cd Vibeloft-usage
sh ./install.sh
```

### 方式二：curl 在线安装

```bash
# 直接通过 curl 下载并运行
curl -fsSL https://raw.githubusercontent.com/BellyBook/Vibeloft-usage/main/install.sh | sh
```

### 方式三：手动安装

```bash
# 1. 安装 ccusage
npm install -g ccusage

# 2. 创建配置目录
mkdir -p ~/.vibeloft

# 3. 下载并配置脚本
curl -o ~/.vibeloft/report_cc.sh https://raw.githubusercontent.com/BellyBook/Vibeloft-usage/main/report_cc.sh
chmod +x ~/.vibeloft/report_cc.sh

# 4. 手动配置 Claude Code Hook（如果使用 Claude Code）
# 编辑 ~/.claude/settings.json 添加 Stop hook
```

### 方式四：Docker 部署（适合服务器）

```bash
# 构建镜像
docker build -t vibeloft-usage .

# 运行容器
docker run -d --name usage-monitor \
  -v ~/.vibeloft:/root/.vibeloft \
  -v ~/.claude:/root/.claude \
  vibeloft-usage
```

## 📋 安装说明

安装脚本会自动检查和安装必要的依赖，包括：
- ccusage 使用量统计工具
- 相关的配置和监听脚本

### 安装过程

安装脚本会自动完成以下步骤：

1. **📝 创建文件系统** - 在 `~/.vibeloft` 目录下创建必要的配置文件
2. **📋 检查依赖** - 验证 Node.js 和 npm 是否已安装
3. **📦 安装 ccusage** - 自动安装全局的 ccusage 工具
4. **⚙️ 配置监听机制** - 根据已安装的 AI 工具自动配置相应的监听机制

> 💡 **智能检测**：安装脚本会检测您系统中已安装的 AI 编程工具，只配置相应的统计功能

## 📁 文件结构

安装完成后，系统会在以下位置创建文件：

```
~/.vibeloft/
├── report_cc.sh          # 使用量上报脚本
└── reports.log           # 上报日志文件

~/.claude/
└── settings.json         # Claude Code 配置文件（自动添加 hook）
```

## 🔧 工作原理

### Claude Code 模块

1. **自动监听** - 通过 Claude Code 的 Stop hook 机制，在每次 Claude Code 会话结束时自动触发
2. **使用量收集** - 运行 `ccusage` 命令获取最新的使用量数据
3. **数据上报** - 将使用量数据通过 HTTP POST 请求发送到指定服务器
4. **日志记录** - 记录每次上报的结果和时间戳

### 未来计划

- **Cursor 模块** - 通过插件或配置文件监听 Cursor 的使用情况
- **Copilot 模块** - 集成 GitHub Copilot API 统计代码生成使用量

## ⚙️ 配置说明

### Hook 配置

安装脚本会自动在 `~/.claude/settings.json` 中添加以下配置：

```json
{
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
```

### 智能检测

- ✅ **避免重复配置** - 安装脚本会检查 hook 是否已存在，避免重复添加
- ✅ **配置保护** - 保留用户现有的 Claude Code 配置
- ✅ **自动备份** - 修改配置前自动创建备份文件

## 🚀 使用方法

### Claude Code

安装完成后，Claude Code 使用量统计将完全自动化：

1. **正常使用** Claude Code - 无需任何额外操作
2. **自动上报** - 每次会话结束时自动上报使用量
3. **查看日志** - 检查 `~/.vibeloft/reports.log` 了解上报状态

```bash
# 查看上报日志
tail -f ~/.vibeloft/reports.log

# 手动触发上报（如需要）
~/.vibeloft/report_cc.sh
```

### 其他工具

> 🚧 **Cursor** 和 **GitHub Copilot** 的使用方法将在后续版本中提供

## 🔍 故障排除

### 常见问题

**Q: 安装时提示缺少依赖？**
A: 请确保已正确安装 Node.js、npm 和 Claude Code

**Q: Hook 没有生效？**
A: 检查 `~/.claude/settings.json` 文件是否正确配置，或重启终端

**Q: 上报失败？**
A: 检查网络连接和服务器地址配置

### 检查安装状态

```bash
# 检查 ccusage 是否安装
which ccusage

# 检查配置文件
cat ~/.claude/settings.json

# 检查脚本权限
ls -la ~/.vibeloft/report_cc.sh
```

## 📝 日志格式

上报日志记录格式：
```
[时间戳] 上报状态 - 详细信息
```

## ⚠️ 注意事项

- 确保目标服务器能正常接收 POST 请求
- 首次安装后建议重启终端或重新加载 shell 配置
- 系统会自动备份现有配置，安全无忧

## 🤝 贡献

欢迎提交 Issue 和 Pull Request 来改进这个项目！

### 开发路线图

- [ ] **Cursor 集成** - 支持 Cursor 编辑器使用量统计
- [ ] **GitHub Copilot 集成** - 支持 Copilot 代码生成统计  
- [ ] **可视化面板** - Web 界面展示使用量数据
- [ ] **多种数据格式** - 支持更多数据导出格式
- [ ] **团队管理** - 支持团队级别的使用量管理

---

📊 让 AI 编程工具使用量统计变得简单而高效！