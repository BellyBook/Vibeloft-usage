#!/bin/bash

# 获取 ccusage 的 json 数据（不直接输出）
json=$(ccusage daily --json)

# 用 curl POST 发送到指定的 Webhook 地址
curl -s -X POST http://localhost:9090/webhook/claude_code \
     -H "Content-Type: application/json" \
     -d "$json"

# 向 ~/.vibeloft/claude_code_usage.json 写入 json 数据 作为 log
echo "$json" > ~/.vibeloft/claude_code_usage.json