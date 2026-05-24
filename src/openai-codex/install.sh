#!/usr/bin/env bash
set -euo pipefail

echo "🔧 Installing OpenAI Codex CLI …"

INSTALL_URL="https://chatgpt.com/codex/install.sh"
INSTALL_DIR="/usr/local/bin"
CODEX_HOME_DIR="/usr/local/share/codex"

install_dependencies() {
    if command -v apt-get >/dev/null 2>&1; then
        export DEBIAN_FRONTEND=noninteractive
        apt-get update -y
        apt-get install -y --no-install-recommends ca-certificates curl gawk gzip tar
    elif command -v yum >/dev/null 2>&1; then
        yum install -y ca-certificates curl gawk gzip tar
    elif command -v apk >/dev/null 2>&1; then
        apk add --no-cache ca-certificates curl gawk gzip tar
    else
        echo "❌ Unsupported package manager. Please install ca-certificates, curl, gawk, gzip and tar before openai-codex."
        exit 1
    fi
}

install_dependencies

if command -v curl >/dev/null 2>&1; then
    curl -fsSL "${INSTALL_URL}" | CODEX_INSTALL_DIR="${INSTALL_DIR}" CODEX_HOME="${CODEX_HOME_DIR}" sh
elif command -v wget >/dev/null 2>&1; then
    wget -qO- "${INSTALL_URL}" | CODEX_INSTALL_DIR="${INSTALL_DIR}" CODEX_HOME="${CODEX_HOME_DIR}" sh
else
    echo "❌ curl or wget not found. Please install one before openai-codex."
    exit 1
fi

if ! command -v codex >/dev/null 2>&1; then
    echo "export PATH=\"${INSTALL_DIR}:\$PATH\"" > /etc/profile.d/codex.sh
fi

echo "✅ OpenAI Codex CLI installation finished!"
