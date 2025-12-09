#!/bin/bash
# https://mirowolff.github.io/vibecode-toolkit/install.sh

set -e

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
BLUE='\033[0;34m'
BOLD='\033[1m'
NC='\033[0m'

REPO_URL="https://mirowolff.github.io/vibecode-toolkit"

# =============================================================================
# HELPERS
# =============================================================================

print_step() {
    echo -e "${BLUE}→${NC} $1"
}

print_success() {
    echo -e "${GREEN}✓${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}!${NC} $1"
}

print_error() {
    echo -e "${RED}✗${NC} $1"
}

print_installed() {
    echo -e "  ${GREEN}✓${NC} $1 ${GRAY}(installed)${NC}"
}

print_will_install() {
    echo -e "  ${BLUE}→${NC} $1"
}

ask_yes_no() {
    local prompt="$1"
    local response
    while true; do
        read -p "$prompt (y/n): " response
        case "$response" in
            [yY]|[yY][eE][sS]) return 0 ;;
            [nN]|[nN][oO]) return 1 ;;
            *) echo "Please answer y or n." ;;
        esac
    done
}

# =============================================================================
# CHECK FUNCTIONS
# =============================================================================

check_brew() {
    command -v brew &>/dev/null
}

check_tool() {
    local tool="$1"
    if [[ "$tool" == "oven-sh/bun/bun" ]]; then
        brew list bun &>/dev/null 2>&1
    else
        brew list "$tool" &>/dev/null 2>&1
    fi
}

check_cask() {
    brew list --cask "$1" &>/dev/null 2>&1
}

check_xcode_cli() {
    xcode-select -p &>/dev/null
}

check_rosetta() {
    [[ $(uname -m) != "arm64" ]] || /usr/bin/pgrep -q oahd
}

check_gh_auth() {
    gh auth status &>/dev/null 2>&1
}

check_ssh_key() {
    [[ -f "$HOME/.ssh/id_ed25519" ]] || [[ -f "$HOME/.ssh/id_rsa" ]]
}

check_ghostty_config() {
    [[ -f "$HOME/.config/ghostty/config" ]]
}

check_starship_config() {
    [[ -f "$HOME/.config/starship.toml" ]]
}

check_zshrc_starship() {
    [[ -f "$HOME/.zshrc" ]] && grep -q 'starship init zsh' "$HOME/.zshrc"
}

check_zshrc_aliases() {
    [[ -f "$HOME/.zshrc" ]] && grep -q '# Vibecode aliases' "$HOME/.zshrc"
}

# =============================================================================
# WELCOME
# =============================================================================

clear
echo ""
echo -e "${BOLD}Vibecode Toolkit${NC}"
echo -e "Development environment for your Mac"
echo ""
echo "This script will set up your Mac with tools for local development:"
echo "terminal, CLI utilities, and GitHub integration."
echo ""

# =============================================================================
# STATUS CHECK
# =============================================================================

echo -e "${BOLD}Checking current setup...${NC}"
echo ""

NEED_INSTALL=false

# Prerequisites
if check_xcode_cli; then
    print_installed "Xcode Command Line Tools"
else
    print_will_install "Xcode Command Line Tools"
    NEED_INSTALL=true
fi

if [[ $(uname -m) == "arm64" ]]; then
    if check_rosetta; then
        print_installed "Rosetta 2"
    else
        print_will_install "Rosetta 2"
        NEED_INSTALL=true
    fi
fi

# Homebrew
if check_brew; then
    print_installed "Homebrew"
else
    print_will_install "Homebrew"
    NEED_INSTALL=true
fi

# CLI tools
CLI_TOOLS=(
    "git:Git"
    "gh:GitHub CLI"
    "node:Node.js"
    "oven-sh/bun/bun:Bun"
    "claude:Claude Code"
    "starship:Starship"
    "jq:jq"
    "fzf:fzf"
    "ripgrep:ripgrep"
    "eza:eza"
    "bat:bat"
)

for item in "${CLI_TOOLS[@]}"; do
    tool="${item%%:*}"
    name="${item##*:}"
    if check_brew && check_tool "$tool"; then
        print_installed "$name"
    else
        print_will_install "$name"
        NEED_INSTALL=true
    fi
done

# Apps
CASK_APPS=(
    "ghostty:Ghostty"
    "github:GitHub Desktop"
)

for item in "${CASK_APPS[@]}"; do
    cask="${item%%:*}"
    name="${item##*:}"
    if check_brew && check_cask "$cask"; then
        print_installed "$name"
    else
        print_will_install "$name"
        NEED_INSTALL=true
    fi
done

# Configs
if check_ghostty_config; then
    print_installed "Ghostty config"
else
    print_will_install "Ghostty config"
    NEED_INSTALL=true
fi

if check_starship_config; then
    print_installed "Starship config"
else
    print_will_install "Starship config"
    NEED_INSTALL=true
fi

if check_zshrc_starship && check_zshrc_aliases; then
    print_installed "Shell configuration"
else
    print_will_install "Shell configuration"
    NEED_INSTALL=true
fi

# GitHub setup
NEED_GITHUB=false
if ! check_ssh_key || ! check_gh_auth; then
    NEED_GITHUB=true
fi

echo ""

# =============================================================================
# ALL SET?
# =============================================================================

if [[ "$NEED_INSTALL" == false ]] && [[ "$NEED_GITHUB" == false ]]; then
    echo -e "${GREEN}You're all set!${NC} Everything is already installed."
    echo ""
    if ask_yes_no "Open Ghostty with the next steps guide?"; then
        open "${REPO_URL}/next-steps.html"
        open -a Ghostty
    fi
    exit 0
fi

# =============================================================================
# CONFIRM INSTALL
# =============================================================================

if [[ "$NEED_INSTALL" == true ]]; then
    if ! ask_yes_no "Install missing tools?"; then
        echo "Installation cancelled."
        exit 0
    fi
    echo ""
fi

# =============================================================================
# GITHUB QUESTION
# =============================================================================

SKIP_GITHUB=false
if [[ "$NEED_GITHUB" == true ]]; then
    echo -e "${BOLD}GitHub Setup${NC}"
    echo "This configures SSH keys and authenticates the GitHub CLI."
    echo ""

    if ! ask_yes_no "Do you have a GitHub account?"; then
        echo ""
        print_step "Opening GitHub signup..."
        open "https://github.com/signup"
        echo ""
        echo "Create your account, then come back here."
        read -p "Press Enter when you have a GitHub account..."
        echo ""
    fi

    if ! ask_yes_no "Set up GitHub integration?"; then
        SKIP_GITHUB=true
    fi
    echo ""
fi

# =============================================================================
# XCODE CLI TOOLS
# =============================================================================

if ! check_xcode_cli; then
    print_step "Installing Xcode Command Line Tools..."
    xcode-select --install 2>/dev/null || true

    echo ""
    print_warning "A dialog will appear. Click 'Install' and wait for it to complete."
    read -p "Press Enter when the installation is finished..."

    if ! check_xcode_cli; then
        print_error "Xcode Command Line Tools installation failed"
        exit 1
    fi
    print_success "Xcode Command Line Tools installed"
    echo ""
fi

# =============================================================================
# ROSETTA 2
# =============================================================================

if [[ $(uname -m) == "arm64" ]] && ! check_rosetta; then
    print_step "Installing Rosetta 2..."
    softwareupdate --install-rosetta --agree-to-license
    print_success "Rosetta 2 installed"
    echo ""
fi

# =============================================================================
# HOMEBREW
# =============================================================================

if ! check_brew; then
    print_step "Installing Homebrew..."
    NONINTERACTIVE=1 /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

    # Add to path for this session
    if [[ $(uname -m) == "arm64" ]]; then
        eval "$(/opt/homebrew/bin/brew shellenv)"
    else
        eval "$(/usr/local/bin/brew shellenv)"
    fi
    print_success "Homebrew installed"
    echo ""
fi

print_step "Updating Homebrew..."
brew update --quiet
print_success "Homebrew updated"
echo ""

# =============================================================================
# CLI TOOLS
# =============================================================================

echo -e "${BOLD}Installing CLI tools...${NC}"
echo ""

for item in "${CLI_TOOLS[@]}"; do
    tool="${item%%:*}"
    name="${item##*:}"
    tool_name=$(basename "$tool")

    if check_tool "$tool"; then
        print_success "$name (already installed)"
    else
        print_step "Installing $name..."
        brew install "$tool" --quiet
        print_success "$name installed"
    fi
done

echo ""

# =============================================================================
# APPLICATIONS
# =============================================================================

echo -e "${BOLD}Installing applications...${NC}"
echo ""

for item in "${CASK_APPS[@]}"; do
    cask="${item%%:*}"
    name="${item##*:}"

    if check_cask "$cask"; then
        print_success "$name (already installed)"
    else
        print_step "Installing $name..."
        brew install --cask "$cask" --quiet
        print_success "$name installed"
    fi
done

echo ""

# =============================================================================
# GHOSTTY CONFIG
# =============================================================================

if ! check_ghostty_config; then
    print_step "Configuring Ghostty..."
    mkdir -p ~/.config/ghostty
    curl -fsSL "${REPO_URL}/config/ghostty.conf" -o ~/.config/ghostty/config
    print_success "Ghostty configured"
else
    print_success "Ghostty config (already configured)"
fi

# =============================================================================
# STARSHIP CONFIG
# =============================================================================

if ! check_starship_config; then
    print_step "Configuring Starship..."
    mkdir -p ~/.config
    curl -fsSL "${REPO_URL}/config/starship.toml" -o ~/.config/starship.toml
    print_success "Starship configured"
else
    print_success "Starship config (already configured)"
fi

echo ""

# =============================================================================
# SSH KEY
# =============================================================================

if [[ "$SKIP_GITHUB" == false ]]; then
    echo -e "${BOLD}GitHub Setup${NC}"
    echo ""

    SSH_KEY_PATH="$HOME/.ssh/id_ed25519"

    if [[ -f "$SSH_KEY_PATH" ]]; then
        print_success "SSH key exists"

        if ! ask_yes_no "Use existing SSH key for GitHub?"; then
            SSH_KEY_PATH="$HOME/.ssh/id_ed25519_github"
            print_step "Generating new SSH key for GitHub..."
            read -p "Enter your email address: " email
            mkdir -p ~/.ssh
            ssh-keygen -t ed25519 -C "$email" -f "$SSH_KEY_PATH" -N ""
            print_success "SSH key generated"
        fi
    elif [[ -f "$HOME/.ssh/id_rsa" ]]; then
        print_success "SSH key exists (RSA)"
        SSH_KEY_PATH="$HOME/.ssh/id_rsa"

        if ask_yes_no "Create a new ed25519 key for GitHub? (recommended)"; then
            SSH_KEY_PATH="$HOME/.ssh/id_ed25519"
            print_step "Generating SSH key..."
            read -p "Enter your email address: " email
            mkdir -p ~/.ssh
            ssh-keygen -t ed25519 -C "$email" -f "$SSH_KEY_PATH" -N ""
            print_success "SSH key generated"
        fi
    else
        print_step "Generating SSH key..."
        read -p "Enter your email address: " email
        mkdir -p ~/.ssh
        ssh-keygen -t ed25519 -C "$email" -f "$SSH_KEY_PATH" -N ""
        print_success "SSH key generated"
    fi

    # Add to keychain
    eval "$(ssh-agent -s)" &>/dev/null
    ssh-add --apple-use-keychain "$SSH_KEY_PATH" 2>/dev/null || true

    # Copy public key
    pbcopy < "${SSH_KEY_PATH}.pub"
    print_success "Public key copied to clipboard"

    echo ""
    print_step "Opening GitHub SSH settings..."
    open "https://github.com/settings/ssh/new"

    echo ""
    echo -e "${YELLOW}Paste your SSH key (it's in your clipboard) and click 'Add SSH Key'${NC}"
    read -p "Press Enter when done..."
    echo ""

    # =============================================================================
    # GITHUB AUTH
    # =============================================================================

    if ! check_gh_auth; then
        print_step "Authenticating GitHub CLI..."
        echo ""
        echo "Follow the prompts to sign in."
        echo ""
        gh auth login
        print_success "GitHub CLI authenticated"
    else
        print_success "GitHub CLI (already authenticated)"
    fi

    echo ""
fi

# =============================================================================
# ZSH CONFIG
# =============================================================================

echo -e "${BOLD}Configuring shell...${NC}"
echo ""

ZSHRC="$HOME/.zshrc"

# Backup if exists
if [[ -f "$ZSHRC" ]]; then
    cp "$ZSHRC" "${ZSHRC}.backup.$(date +%Y%m%d%H%M%S)"
fi

# Ensure file exists
touch "$ZSHRC"

# Add Homebrew to path (Apple Silicon)
if [[ $(uname -m) == "arm64" ]]; then
    if ! grep -q '/opt/homebrew/bin/brew shellenv' "$ZSHRC"; then
        echo '' >> "$ZSHRC"
        echo '# Homebrew' >> "$ZSHRC"
        echo 'eval "$(/opt/homebrew/bin/brew shellenv)"' >> "$ZSHRC"
    fi
fi

# Add Starship init
if ! grep -q 'starship init zsh' "$ZSHRC"; then
    echo '' >> "$ZSHRC"
    echo '# Starship prompt' >> "$ZSHRC"
    echo 'eval "$(starship init zsh)"' >> "$ZSHRC"
fi

# Add aliases
if ! grep -q '# Vibecode aliases' "$ZSHRC"; then
    cat >> "$ZSHRC" << 'EOF'

# Vibecode aliases
alias c="claude"
alias g="git"
alias gs="git status"
alias gp="git push"
alias gl="git pull"
alias gco="git checkout"
alias gcm="git commit -m"
alias gaa="git add -A"
alias ll="eza -la --git"
alias cat="bat --paging=never"
alias ..="cd .."
alias ...="cd ../.."
EOF
fi

print_success "Shell configured"

# Check if zsh is default shell
if [[ "$SHELL" != *"zsh"* ]]; then
    echo ""
    print_warning "Your default shell is not zsh. Some features may not work."
    print_warning "Run 'chsh -s /bin/zsh' to change your default shell."
fi

# Source zshrc
source "$ZSHRC" 2>/dev/null || true

echo ""

# =============================================================================
# DONE
# =============================================================================

echo -e "${GREEN}${BOLD}Installation complete!${NC}"
echo ""
echo "Installed:"
echo "  • Ghostty, GitHub Desktop"
echo "  • git, gh, node, bun, claude"
echo "  • starship, jq, fzf, ripgrep, eza, bat"
echo ""

if ask_yes_no "Open Ghostty to see your new setup?"; then
    echo ""
    print_step "Opening Ghostty..."
    open "${REPO_URL}/next-steps.html"
    sleep 1
    open -a Ghostty
    echo ""
    echo "Welcome to your new terminal!"
else
    echo ""
    echo "Run 'open -a Ghostty' when you're ready."
    open "${REPO_URL}/next-steps.html"
fi

echo ""
echo -e "Happy vibecoding!"
echo ""
