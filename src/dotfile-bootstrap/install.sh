#!/usr/bin/env bash
set -euo pipefail

echo "Activating feature 'dotfile-bootstrap'"

: "${BRANCH:=master}"

REPOSITORY="https://github.com/PeteJohn6/dotfile.git"
TARGETDIR="/root/.dotfiles"

install_packages() {
    if [ "$#" -eq 0 ]; then
        return 0
    fi

    if command -v apt-get >/dev/null 2>&1; then
        export DEBIAN_FRONTEND=noninteractive
        apt-get update -y
        apt-get install -y --no-install-recommends "$@"
    elif command -v dnf >/dev/null 2>&1; then
        dnf install -y "$@"
    elif command -v yum >/dev/null 2>&1; then
        yum install -y "$@"
    elif command -v pacman >/dev/null 2>&1; then
        pacman -Sy --noconfirm --needed "$@"
    elif command -v apk >/dev/null 2>&1; then
        apk add --no-cache "$@"
    else
        echo "Unsupported package manager. Please install the following packages manually: $*" >&2
        exit 1
    fi
}

ensure_dependencies() {
    if command -v git >/dev/null 2>&1; then
        return 0
    fi

    echo "Installing git ..."
    install_packages git ca-certificates
}

resolve_repo_dir() {
    printf '%s\n' "$TARGETDIR"
}

sync_repository() {
    local repo_dir=$1

    mkdir -p "$(dirname "$repo_dir")"

    if [ -d "$repo_dir/.git" ]; then
        local existing_remote
        existing_remote="$(git -C "$repo_dir" config --get remote.origin.url || true)"
        if [ -n "$existing_remote" ] && [ "$existing_remote" != "$REPOSITORY" ]; then
            echo "Repository already exists at $repo_dir but points to '$existing_remote' instead of '$REPOSITORY'." >&2
            exit 1
        fi

        echo "Updating existing dotfile repository in $repo_dir ..."
        git -C "$repo_dir" fetch --depth 1 origin "$BRANCH"
        git -C "$repo_dir" checkout -B "$BRANCH" "FETCH_HEAD"
        return 0
    fi

    if [ -e "$repo_dir" ]; then
        echo "Target path already exists and is not a git repository: $repo_dir" >&2
        exit 1
    fi

    echo "Cloning $REPOSITORY#$BRANCH into $repo_dir ..."
    git clone --depth 1 --branch "$BRANCH" "$REPOSITORY" "$repo_dir"
}

run_bootstrap_up() {
    local repo_dir=$1

    if [ ! -f "$repo_dir/bootstrap-up.sh" ]; then
        echo "bootstrap-up.sh was not found in $repo_dir" >&2
        exit 1
    fi

    chmod +x "$repo_dir/bootstrap-up.sh"

    echo "Running bootstrap-up.sh as root from $repo_dir ..."
    cd "$repo_dir"
    export HOME=/root
    bash ./bootstrap-up.sh
}

main() {
    local repo_dir

    ensure_dependencies
    repo_dir="$(resolve_repo_dir)"
    sync_repository "$repo_dir"
    run_bootstrap_up "$repo_dir"

    echo "dotfile-bootstrap feature installation complete."
}

main "$@"
