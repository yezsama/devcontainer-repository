#!/usr/bin/env bash
set -e

echo "🔧 Installing OpenAI Codex CLI …"

############################################
# 1. Node.js 已由依赖 Feature 提供，直接用 npm 安装 Codex
############################################
if ! command -v npm >/dev/null 2>&1; then
    echo "❌  Node.js / npm not found. Make sure the Node Feature is installed before openai-codex."
    exit 1
fi

npm install -g @openai/codex

############################################
# 2. 可选：为当前用户补全 PATH（某些基础镜像 npm 全局路径不在 PATH）
############################################
if ! command -v codex >/dev/null 2>&1; then
    NPM_PREFIX=$(npm config get prefix)
    echo "export PATH=\"${NPM_PREFIX}/bin:\$PATH\"" >> /etc/profile.d/codex.sh
fi

echo "✅ OpenAI Codex CLI installation finished!"