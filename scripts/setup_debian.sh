#!/usr/bin/env bash
# =============================================================================
# setup_debian.sh — Dev environment bootstrap for Debian/Ubuntu
# =============================================================================

set -euo pipefail

# ── Colours ──────────────────────────────────────────────────────────────────
RED='\033[0;31m'; GREEN='\033[0;32m'; YELLOW='\033[1;33m'
CYAN='\033[0;36m'; BOLD='\033[1m'; RESET='\033[0m'

info()    { echo -e "${CYAN}[INFO]${RESET}  $*"; }
success() { echo -e "${GREEN}[OK]${RESET}    $*"; }
warn()    { echo -e "${YELLOW}[WARN]${RESET}  $*"; }
error()   { echo -e "${RED}[ERROR]${RESET} $*" >&2; exit 1; }
step()    { echo -e "\n${BOLD}▶ $*${RESET}"; }

# ── Config — edit before running ─────────────────────────────────────────────
NVIM_CONFIG_REPO="https://github.com/YOUR_USERNAME/nvim-config.git"   # <-- change me
NVIM_CONFIG_DIR="${XDG_CONFIG_HOME:-$HOME/.config}/nvim"
NVIM_VERSION="v0.12.2"   # AppImage fallback version

# ── Sanity check ─────────────────────────────────────────────────────────────
[[ -f /etc/os-release ]] || error "/etc/os-release not found — is this actually Debian/Ubuntu?"
. /etc/os-release
case "${ID,,}" in
    ubuntu|debian|linuxmint|pop) ;;
    *) error "Expected a Debian-based distro, got: $ID" ;;
esac
info "Detected: $PRETTY_NAME"

# ── Helpers ───────────────────────────────────────────────────────────────────
apt_install() { sudo apt-get install -y -qq "$@"; }
cmd_exists()  { command -v "$1" &>/dev/null; }

# ── Update package index ──────────────────────────────────────────────────────
step "Updating package index"
sudo apt-get update -qq
success "Package index updated"

# ── Git ───────────────────────────────────────────────────────────────────────
step "Installing git"
if cmd_exists git; then
    info "Already installed: $(git --version)"
else
    apt_install git
    success "Installed: $(git --version)"
fi

# ── Python ────────────────────────────────────────────────────────────────────
step "Installing Python 3"
if cmd_exists python3; then
    info "Already installed: $(python3 --version)"
else
    apt_install python3 python3-pip python3-venv
    success "Installed: $(python3 --version)"
fi

# ── Neovim ────────────────────────────────────────────────────────────────────
step "Installing Neovim"

install_nvim_appimage() {
    local url="https://github.com/neovim/neovim/releases/download/${NVIM_VERSION}/nvim-linux-x86_64.appimage"
    local dest="/usr/local/bin/nvim"
    info "apt Neovim is outdated — falling back to AppImage ${NVIM_VERSION}"
    apt_install curl fuse libfuse2 2>/dev/null || apt_install curl fuse || true
    sudo curl -fsSL "$url" -o "$dest"
    sudo chmod +x "$dest"
    # If FUSE isn't available, extract the AppImage in place
    if ! "$dest" --version &>/dev/null; then
        warn "FUSE unavailable — extracting AppImage instead"
        local tmpdir; tmpdir=$(mktemp -d)
        cd "$tmpdir"
        "$dest" --appimage-extract &>/dev/null || true
        sudo mv "$tmpdir/squashfs-root" /opt/nvim-extracted
        sudo ln -sf /opt/nvim-extracted/usr/bin/nvim "$dest"
        cd -
    fi
}

if cmd_exists nvim; then
    info "Already installed: $(nvim --version | head -1)"
else
    # apt ships an old nvim on many Debian/Ubuntu releases; check before using it
    if apt-cache show neovim 2>/dev/null | grep -qE "Version: 0\.[89]\.|Version: [1-9]"; then
        apt_install neovim
    else
        install_nvim_appimage
    fi
    success "Installed: $(nvim --version | head -1)"
fi

# ── Sioyek ────────────────────────────────────────────────────────────────────
step "Installing Sioyek (PDF reader)"

install_sioyek_from_github() {
    apt_install curl unzip
    local tag
    tag=$(curl -fsSL https://api.github.com/repos/ahrm/sioyek/releases/latest \
          | grep '"tag_name"' | head -1 | sed 's/.*"tag_name": *"\(.*\)".*/\1/')
    local url="https://github.com/ahrm/sioyek/releases/download/${tag}/sioyek-release-linux.zip"
    local tmpdir; tmpdir=$(mktemp -d)
    info "Downloading Sioyek ${tag}..."
    curl -fsSL "$url" -o "$tmpdir/sioyek.zip"
    unzip -q "$tmpdir/sioyek.zip" -d "$tmpdir/sioyek"
    local bin; bin=$(find "$tmpdir/sioyek" -name "sioyek" -type f | head -1)
    sudo install -m 755 "$bin" /usr/local/bin/sioyek
    rm -rf "$tmpdir"
}

if cmd_exists sioyek; then
    info "Already installed"
else
    if apt-cache show sioyek &>/dev/null; then
        apt_install sioyek
    else
        install_sioyek_from_github
    fi
    cmd_exists sioyek && success "Sioyek installed" || warn "Sioyek install may need manual follow-up"
fi

# ── Neovim config ─────────────────────────────────────────────────────────────
step "Setting up Neovim config"

if [[ "$NVIM_CONFIG_REPO" == *"YOUR_USERNAME"* ]]; then
    warn "NVIM_CONFIG_REPO not set — skipping. Edit the variable at the top and re-run."
elif [[ -d "$NVIM_CONFIG_DIR/.git" ]]; then
    info "Config already cloned — pulling latest"
    git -C "$NVIM_CONFIG_DIR" pull --ff-only
    success "Neovim config updated"
elif [[ -d "$NVIM_CONFIG_DIR" && -n "$(ls -A "$NVIM_CONFIG_DIR")" ]]; then
    warn "$NVIM_CONFIG_DIR exists and is non-empty but is not a git repo — skipping."
    warn "Back it up, remove it, then re-run."
else
    mkdir -p "$(dirname "$NVIM_CONFIG_DIR")"
    git clone "$NVIM_CONFIG_REPO" "$NVIM_CONFIG_DIR"
    success "Neovim config cloned to $NVIM_CONFIG_DIR"
fi

# ── Summary ───────────────────────────────────────────────────────────────────
echo ""
echo -e "${BOLD}════════════════════════════════════════${RESET}"
echo -e "${BOLD}  Setup complete — installed versions   ${RESET}"
echo -e "${BOLD}════════════════════════════════════════${RESET}"
for tool in git python3 nvim sioyek; do
    if cmd_exists "$tool"; then
        ver=$("$tool" --version 2>&1 | head -1)
        echo -e "  ${GREEN}✔${RESET} $tool — $ver"
    else
        echo -e "  ${YELLOW}⚠${RESET} $tool — not found (check warnings above)"
    fi
done
echo ""
