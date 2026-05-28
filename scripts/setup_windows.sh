#!/usr/bin/env bash
# =============================================================================
# setup_windows.sh — Dev environment bootstrap for Windows (Git Bash / MSYS2)
# Run from Git Bash, MSYS2, or any bash that ships with Windows.
# Winget must be available (Windows 10 1709+ / 11).
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
NVIM_CONFIG_REPO="https://github.com/tragicprometheus/nvim.git"
# Neovim config lives in %LOCALAPPDATA%\nvim on Windows
NVIM_CONFIG_DIR="${LOCALAPPDATA:-$USERPROFILE/AppData/Local}/nvim"

# ── Sanity checks ─────────────────────────────────────────────────────────────
step "Checking environment"

# Must be running on Windows (MSYS / Git Bash sets OSTYPE to msys or cygwin)
case "${OSTYPE,,}" in
    msys*|cygwin*|mingw*) ;;
    *) error "This script targets Windows (Git Bash/MSYS2). Got OSTYPE=$OSTYPE" ;;
esac

# winget is required for package installs
if ! command -v winget &>/dev/null; then
    error "winget not found. Install 'App Installer' from the Microsoft Store (Windows 10 1709+ / 11)."
fi

info "winget: $(winget --version)"

# ── Helpers ───────────────────────────────────────────────────────────────────
cmd_exists() { command -v "$1" &>/dev/null; }

winget_install() {
    local id="$1"; local name="$2"
    # winget exits 0 even when already installed; -e = exact match, --silent suppresses UI
    winget install --id "$id" --exact --silent --accept-package-agreements \
          --accept-source-agreements 2>&1 \
        | grep -v "^$" || true
}

# Refresh PATH so newly installed tools are visible without reopening the shell
refresh_path() {
    # Git Bash doesn't auto-refresh; re-source common locations
    local win_paths
    win_paths=$(cmd.exe /c "echo %PATH%" 2>/dev/null | tr ';' ':' | tr -d '\r' || true)
    export PATH="$PATH:$win_paths"
    hash -r 2>/dev/null || true
}

# ── Git ───────────────────────────────────────────────────────────────────────
step "Installing git"
if cmd_exists git; then
    info "Already installed: $(git --version)"
else
    winget_install "Git.Git" "Git"
    refresh_path
    cmd_exists git && success "Installed: $(git --version)" || warn "git installed — reopen shell if 'git' isn't found yet"
fi

# ── Python ────────────────────────────────────────────────────────────────────
step "Installing Python 3"
if cmd_exists python || cmd_exists python3; then
    ver=$(python --version 2>&1 || python3 --version 2>&1)
    info "Already installed: $ver"
else
    winget_install "Python.Python.3.12" "Python 3.12"
    refresh_path
    cmd_exists python && success "Installed: $(python --version)" \
                      || warn "Python installed — reopen shell if 'python' isn't found yet"
fi

# ── Neovim ────────────────────────────────────────────────────────────────────
step "Installing Neovim"
if cmd_exists nvim; then
    info "Already installed: $(nvim --version | head -1)"
else
    winget_install "Neovim.Neovim" "Neovim"
    refresh_path
    cmd_exists nvim && success "Installed: $(nvim --version | head -1)" \
                    || warn "Neovim installed — reopen shell if 'nvim' isn't found yet"
fi

# ── Sioyek ────────────────────────────────────────────────────────────────────
step "Installing Sioyek (PDF reader)"
if cmd_exists sioyek; then
    info "Already installed"
else
    winget_install "ahrm.sioyek" "Sioyek"
    refresh_path
    cmd_exists sioyek && success "Sioyek installed" \
                      || warn "Sioyek installed — reopen shell if 'sioyek' isn't found yet"
fi

# ── Neovim config ─────────────────────────────────────────────────────────────
step "Setting up Neovim config"

# Convert Windows path to bash-friendly path if needed
NVIM_CONFIG_DIR_BASH=$(cygpath -u "$NVIM_CONFIG_DIR" 2>/dev/null || echo "$NVIM_CONFIG_DIR")

if [[ "$NVIM_CONFIG_REPO" == *"YOUR_USERNAME"* ]]; then
    warn "NVIM_CONFIG_REPO not set — skipping. Edit the variable at the top and re-run."
elif [[ -d "$NVIM_CONFIG_DIR_BASH/.git" ]]; then
    info "Config already cloned — pulling latest"
    git -C "$NVIM_CONFIG_DIR_BASH" pull --ff-only
    success "Neovim config updated"
elif [[ -d "$NVIM_CONFIG_DIR_BASH" && -n "$(ls -A "$NVIM_CONFIG_DIR_BASH" 2>/dev/null)" ]]; then
    warn "$NVIM_CONFIG_DIR_BASH exists and is non-empty but is not a git repo — skipping."
    warn "Back it up, remove it, then re-run."
else
    mkdir -p "$NVIM_CONFIG_DIR_BASH"
    git clone "$NVIM_CONFIG_REPO" "$NVIM_CONFIG_DIR_BASH"
    success "Neovim config cloned to $NVIM_CONFIG_DIR_BASH"
fi

# ── Summary ───────────────────────────────────────────────────────────────────
echo ""
echo -e "${BOLD}════════════════════════════════════════${RESET}"
echo -e "${BOLD}  Setup complete — installed versions   ${RESET}"
echo -e "${BOLD}════════════════════════════════════════${RESET}"

check_tool() {
    local cmd="$1"
    if cmd_exists "$cmd"; then
        ver=$("$cmd" --version 2>&1 | head -1)
        echo -e "  ${GREEN}✔${RESET} $cmd — $ver"
    else
        echo -e "  ${YELLOW}⚠${RESET} $cmd — not in PATH yet (reopen your shell)"
    fi
}

check_tool git
# python may be 'python' not 'python3' on Windows
cmd_exists python  && check_tool python  || check_tool python3
check_tool nvim
cmd_exists sioyek  && echo -e "  ${GREEN}✔${RESET} sioyek — installed" \
                   || echo -e "  ${YELLOW}⚠${RESET} sioyek — not in PATH yet (reopen your shell)"
echo ""
echo -e "${CYAN}Note:${RESET} If any tool shows ⚠, close and reopen Git Bash — winget"
echo -e "      updates the system PATH but the current shell may not see it yet."
echo ""
