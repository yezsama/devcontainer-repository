#!/usr/bin/env bash
set -euo pipefail

echo "🔧 Installing GitHub CLI …"

if ! command -v curl >/dev/null 2>&1; then
    echo "❌ curl not found. Please install 'curl' before github-cli."
    exit 1
fi

# Install GitHub CLI via official install script
curl -fsSL https://cli.github.com/install.sh | bash

echo "✅ GitHub CLI installation finished!"
