#!/usr/bin/env bash
set -e

############################################
# 0. Initialize variables
############################################
DISTRO_FAMILY=""
PKG_MANAGER=""

echo "🔧 Installing Rust Dev Tools …"

#-------------------------------------------
# 1. recognize the Linux distribution and package manager
#-------------------------------------------
if [ -f /etc/os-release ]; then
    . /etc/os-release
    case "${ID_LIKE:-$ID}" in
        debian*) DISTRO_FAMILY="debian"; PKG_MANAGER="apt-get";;
        rhel*|fedora*) DISTRO_FAMILY="rhel"; PKG_MANAGER="$(command -v dnf || command -v yum)";;
        alpine*) DISTRO_FAMILY="alpine"; PKG_MANAGER="apk";;
        arch*) DISTRO_FAMILY="arch"; PKG_MANAGER="pacman";;
        *) DISTRO_FAMILY="unknown";;
    esac
fi

echo "   Distro family: ${DISTRO_FAMILY:-unknown}"

install_pkgs() {
    local pkgs="$*"
    case "$PKG_MANAGER" in
        apt-get)  apt-get update -y && apt-get install -y --no-install-recommends $pkgs && rm -rf /var/lib/apt/lists/* ;;
        dnf)      dnf install -y $pkgs ;;
        yum)      yum install -y $pkgs ;;
        apk)      apk add --no-cache $pkgs ;;
        pacman)   pacman -Sy --noconfirm $pkgs ;;
        *)        echo "Warning: unknown distro, please install $pkgs manually";;
    esac
}

############################################
# 2. install Rust Dev Tools
############################################
echo "  Installing Rust Dev Tools …"
install_pkgs build-essential lldb pkg-config libssl-dev libclang-dev 

############################################
# 3. install tools that are not available in the package manager
############################################
if ! command -v rustup >/dev/null 2>&1; then
    echo "❌  rustup not found. Make sure the Rust Feature is installed before rust-dev."
    exit 1
fi

echo "  Installing additional Rust Dev Tools …"
RUN rustup component add rust-gdb rust-lldb \
    && cargo install cargo-watch

############################################
# 4. Optionally install nightly tools (miri, rust-src)
############################################
if [ "${FEATURE_WITHNIGHTLYTOOLS:-true}" = "true" ]; then
    # if the nightly toolchain is not installed install it
    if ! rustup toolchain list | grep -q "nightly"; then
        echo "  Nightly toolchain not found, installing it …"
        RUN rustup toolchain install nightly
    fi
    echo "  Nightly toolchain detected, adding rust-src and miri components …"
    RUN rustup component add rust-src miri --toolchain nightly
fi

echo "✅ Rust Dev Tools installation finished!"