#!/bin/bash
# https://mirowolff.github.io/vibecode-toolkit/install.sh

set -e

# =============================================================================
# COLORS & SYMBOLS
# =============================================================================

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
BLUE='\033[0;34m'
MAGENTA='\033[0;35m'
CYAN='\033[0;36m'
GRAY='\033[0;90m'
BOLD='\033[1m'
DIM='\033[2m'
NC='\033[0m'

# Symbols
CHECK="${GREEN}✓${NC}"
CROSS="${RED}✗${NC}"
ARROW="${BLUE}→${NC}"
WARN="${YELLOW}!${NC}"
BULLET="${GRAY}•${NC}"
SPARKLE="${MAGENTA}✦${NC}"

REPO_URL="https://mirowolff.github.io/vibecode-toolkit"

# =============================================================================
# HELPERS
# =============================================================================

print_step() {
    echo -e "${ARROW} $1"
}

print_success() {
    echo -e "${CHECK} $1"
}

print_warning() {
    echo -e "${WARN} $1"
}

print_error() {
    echo -e "${CROSS} $1"
}

print_installed() {
    echo -e "  ${CHECK} $1 ${DIM}installed${NC}"
}

print_will_install() {
    echo -e "  ${ARROW} $1"
}

print_item() {
    echo -e "  ${BULLET} $1"
}

# Animated spinner for background tasks
spinner() {
    local pid=$1
    local message=$2
    local spin='⠋⠙⠹⠸⠼⠴⠦⠧⠇⠏'
    local i=0

    tput civis  # Hide cursor
    while kill -0 $pid 2>/dev/null; do
        i=$(( (i + 1) % 10 ))
        printf "\r${BLUE}${spin:$i:1}${NC} ${message}"
        sleep 0.1
    done
    tput cnorm  # Show cursor
    printf "\r"
}

# Progress bar
progress_bar() {
    local current=$1
    local total=$2
    local width=30
    local percent=$((current * 100 / total))
    local filled=$((current * width / total))
    local empty=$((width - filled))

    printf "\r  ${DIM}[${NC}"
    printf "${GREEN}%${filled}s${NC}" | tr ' ' '█'
    printf "${GRAY}%${empty}s${NC}" | tr ' ' '░'
    printf "${DIM}]${NC} ${percent}%%"
}

ask_yes_no() {
    local prompt="$1"
    local response
    while true; do
        echo -e -n "${prompt} ${DIM}(y/n)${NC} "
        read response
        case "$response" in
            [yY]|[yY][eE][sS]) return 0 ;;
            [nN]|[nN][oO]) return 1 ;;
            *) echo -e "${DIM}Please answer y or n.${NC}" ;;
        esac
    done
}

# Divider line
divider() {
    echo -e "${DIM}────────────────────────────────────────${NC}"
}

# =============================================================================
# CHECK FUNCTIONS
# =============================================================================

check_brew() {
    command -v brew &>/dev/null
}

check_tool() {
    local tool="$1"
    local cmd="${tool##*/}"  # Get the command name (last part after /)

    # First check if command exists in PATH
    if command -v "$cmd" &>/dev/null; then
        return 0
    fi

    # Fallback to brew list
    if [[ "$tool" == "oven-sh/bun/bun" ]]; then
        brew list bun &>/dev/null 2>&1
    else
        brew list "$tool" &>/dev/null 2>&1
    fi
}

check_cask() {
    local cask="$1"
    local app_name=""

    # Map cask names to app names
    case "$cask" in
        "ghostty") app_name="Ghostty" ;;
        "github") app_name="GitHub Desktop" ;;
        *) app_name="$cask" ;;
    esac

    # Check if app exists in /Applications
    if [[ -d "/Applications/${app_name}.app" ]]; then
        return 0
    fi

    # Fallback to brew list
    brew list --cask "$cask" &>/dev/null 2>&1
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

check_zshrc_configured() {
    # Check if starship is configured (the essential part)
    [[ -f "$HOME/.zshrc" ]] && grep -q 'starship init zsh' "$HOME/.zshrc"
}

# =============================================================================
# WELCOME
# =============================================================================

clear
echo ""
echo -e "${YELLOW}❯_${NC} ${BOLD}Vibecode Toolkit${NC}"
echo -e "${DIM}Development environment for your Mac${NC}"
echo ""
divider
echo ""
echo -e "This will set up your Mac with:"
echo ""
print_item "Modern terminal ${DIM}(Ghostty)${NC}"
print_item "AI coding assistant ${DIM}(Claude Code)${NC}"
print_item "CLI utilities ${DIM}(git, node, bun, etc.)${NC}"
print_item "GitHub integration ${DIM}(SSH + CLI)${NC}"
echo ""
divider
echo ""

# =============================================================================
# STATUS CHECK
# =============================================================================

echo -e "${BOLD}Checking your setup${NC}"
echo ""

NEED_INSTALL=false
INSTALLED_COUNT=0
TOTAL_COUNT=0

# Prerequisites
TOTAL_COUNT=$((TOTAL_COUNT + 1))
if check_xcode_cli; then
    print_installed "Xcode Command Line Tools"
    INSTALLED_COUNT=$((INSTALLED_COUNT + 1))
else
    print_will_install "Xcode Command Line Tools"
    NEED_INSTALL=true
fi

if [[ $(uname -m) == "arm64" ]]; then
    TOTAL_COUNT=$((TOTAL_COUNT + 1))
    if check_rosetta; then
        print_installed "Rosetta 2"
        INSTALLED_COUNT=$((INSTALLED_COUNT + 1))
    else
        print_will_install "Rosetta 2"
        NEED_INSTALL=true
    fi
fi

# Homebrew
TOTAL_COUNT=$((TOTAL_COUNT + 1))
if check_brew; then
    print_installed "Homebrew"
    INSTALLED_COUNT=$((INSTALLED_COUNT + 1))
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
    TOTAL_COUNT=$((TOTAL_COUNT + 1))
    if check_brew && check_tool "$tool"; then
        print_installed "$name"
        INSTALLED_COUNT=$((INSTALLED_COUNT + 1))
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
    TOTAL_COUNT=$((TOTAL_COUNT + 1))
    if check_brew && check_cask "$cask"; then
        print_installed "$name"
        INSTALLED_COUNT=$((INSTALLED_COUNT + 1))
    else
        print_will_install "$name"
        NEED_INSTALL=true
    fi
done

# Configs
TOTAL_COUNT=$((TOTAL_COUNT + 1))
if check_ghostty_config; then
    print_installed "Ghostty config"
    INSTALLED_COUNT=$((INSTALLED_COUNT + 1))
else
    print_will_install "Ghostty config"
    NEED_INSTALL=true
fi

TOTAL_COUNT=$((TOTAL_COUNT + 1))
if check_starship_config; then
    print_installed "Starship config"
    INSTALLED_COUNT=$((INSTALLED_COUNT + 1))
else
    print_will_install "Starship config"
    NEED_INSTALL=true
fi

TOTAL_COUNT=$((TOTAL_COUNT + 1))
if check_zshrc_configured; then
    print_installed "Shell configuration"
    INSTALLED_COUNT=$((INSTALLED_COUNT + 1))
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
echo -e "${DIM}${INSTALLED_COUNT}/${TOTAL_COUNT} components ready${NC}"
echo ""

# =============================================================================
# ALL SET?
# =============================================================================

if [[ "$NEED_INSTALL" == false ]] && [[ "$NEED_GITHUB" == false ]]; then
    echo -e "${GREEN}${BOLD}You're all set!${NC} ${SPARKLE}"
    echo -e "${DIM}Everything is already installed.${NC}"
    echo ""
    if ask_yes_no "Open Ghostty with the next steps guide?"; then
        echo ""
        print_step "Opening Ghostty..."
        open "${REPO_URL}/next-steps.html"
        sleep 0.5
        open -a Ghostty
    fi
    echo ""
    echo -e "${DIM}Happy vibecoding!${NC} ${SPARKLE}"
    echo ""
    exit 0
fi

# =============================================================================
# CONFIRM INSTALL
# =============================================================================

divider
echo ""

if [[ "$NEED_INSTALL" == true ]]; then
    if ! ask_yes_no "Install missing components?"; then
        echo ""
        echo -e "${DIM}Installation cancelled.${NC}"
        echo ""
        exit 0
    fi
    echo ""
fi

# =============================================================================
# GITHUB QUESTION
# =============================================================================

SKIP_GITHUB=false
if [[ "$NEED_GITHUB" == true ]]; then
    divider
    echo ""
    echo -e "${BOLD}GitHub Setup${NC}"
    echo -e "${DIM}SSH keys and CLI authentication${NC}"
    echo ""

    if ! ask_yes_no "Do you have a GitHub account?"; then
        echo ""
        print_step "Opening GitHub signup..."
        open "https://github.com/signup"
        echo ""
        echo -e "${DIM}Create your account, then come back here.${NC}"
        read -p "Press Enter when ready..."
        echo ""
    fi

    if ! ask_yes_no "Set up GitHub integration?"; then
        SKIP_GITHUB=true
        echo ""
        echo -e "${DIM}You can set this up later.${NC}"
    fi
    echo ""
fi

# =============================================================================
# INSTALLATION
# =============================================================================

divider
echo ""
echo -e "${BOLD}Installing${NC}"
echo ""

# =============================================================================
# XCODE CLI TOOLS
# =============================================================================

if ! check_xcode_cli; then
    print_step "Installing Xcode Command Line Tools..."
    xcode-select --install 2>/dev/null || true

    echo ""
    echo -e "${WARN} ${YELLOW}A dialog will appear. Click 'Install' and wait for it to complete.${NC}"
    echo ""
    read -p "Press Enter when the installation is finished..."

    if ! check_xcode_cli; then
        print_error "Xcode Command Line Tools installation failed"
        exit 1
    fi
    print_success "Xcode Command Line Tools"
    echo ""
fi

# =============================================================================
# ROSETTA 2
# =============================================================================

if [[ $(uname -m) == "arm64" ]] && ! check_rosetta; then
    print_step "Installing Rosetta 2..."
    softwareupdate --install-rosetta --agree-to-license &>/dev/null
    print_success "Rosetta 2"
    echo ""
fi

# =============================================================================
# HOMEBREW
# =============================================================================

if ! check_brew; then
    print_step "Installing Homebrew..."
    echo ""
    NONINTERACTIVE=1 /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

    # Add to path for this session
    if [[ $(uname -m) == "arm64" ]]; then
        eval "$(/opt/homebrew/bin/brew shellenv)"
    else
        eval "$(/usr/local/bin/brew shellenv)"
    fi
    echo ""
    print_success "Homebrew"
    echo ""
fi

print_step "Updating Homebrew..."
brew update --quiet &
spinner $! "Updating Homebrew..."
print_success "Homebrew updated"
echo ""

# =============================================================================
# CLI TOOLS
# =============================================================================

echo -e "${BOLD}CLI Tools${NC}"
echo ""

TOOL_INDEX=0
TOOL_COUNT=${#CLI_TOOLS[@]}

for item in "${CLI_TOOLS[@]}"; do
    tool="${item%%:*}"
    name="${item##*:}"
    TOOL_INDEX=$((TOOL_INDEX + 1))

    if check_tool "$tool"; then
        print_success "$name ${DIM}already installed${NC}"
    else
        print_step "Installing $name..."
        brew install "$tool" --quiet 2>/dev/null
        print_success "$name"
    fi
done

echo ""

# =============================================================================
# APPLICATIONS
# =============================================================================

echo -e "${BOLD}Applications${NC}"
echo ""

for item in "${CASK_APPS[@]}"; do
    cask="${item%%:*}"
    name="${item##*:}"

    if check_cask "$cask"; then
        print_success "$name ${DIM}already installed${NC}"
    else
        print_step "Installing $name..."
        brew install --cask "$cask" --quiet 2>/dev/null
        print_success "$name"
    fi
done

echo ""

# =============================================================================
# CONFIGURATION
# =============================================================================

echo -e "${BOLD}Configuration${NC}"
echo ""

# Ghostty config
if ! check_ghostty_config; then
    print_step "Configuring Ghostty..."
    mkdir -p ~/.config/ghostty
    curl -fsSL "${REPO_URL}/config/ghostty.conf" -o ~/.config/ghostty/config
    print_success "Ghostty config"
else
    print_success "Ghostty config ${DIM}already configured${NC}"
fi

# Starship config
if ! check_starship_config; then
    print_step "Configuring Starship..."
    mkdir -p ~/.config
    curl -fsSL "${REPO_URL}/config/starship.toml" -o ~/.config/starship.toml
    print_success "Starship config"
else
    print_success "Starship config ${DIM}already configured${NC}"
fi

# Claude Code MCP servers
print_step "Configuring Claude Code MCP servers..."
claude mcp add context7 -- npx -y @upstash/context7-mcp@latest 2>/dev/null || true
print_success "Context7 MCP configured"

echo ""

# MCP Server Configuration
echo -e "${BOLD}MCP Server Configuration${NC}"
echo ""

CLAUDE_CONFIG="$HOME/.claude.json"
MCP_SERVERS=""

# Figma MCP
if ask_yes_no "Configure Figma MCP?"; then
    MCP_SERVERS="figma"
fi

echo ""

# Miro Design System MCP
echo -e "${DIM}Get your Miro DS token at:${NC} ${BLUE}https://miro.design/mcp/token${NC}"
echo ""
open "https://miro.design/mcp/token" 2>/dev/null || true

echo -e -n "Paste your Miro DS token ${DIM}(or press Enter to skip):${NC} "
read -r MIRO_DS_TOKEN

MIRO_EMAIL=""
if [[ -n "$MIRO_DS_TOKEN" ]]; then
    echo -e -n "Enter your Miro email: "
    read -r MIRO_EMAIL
    MCP_SERVERS="${MCP_SERVERS} miro"
fi

echo ""

# Write MCP config
if [[ -n "$MCP_SERVERS" ]]; then
    if [[ -f "$CLAUDE_CONFIG" ]]; then
        cp "$CLAUDE_CONFIG" "${CLAUDE_CONFIG}.backup"
    fi

    # Build the JSON config
    echo "{" > "$CLAUDE_CONFIG"
    echo '  "mcpServers": {' >> "$CLAUDE_CONFIG"

    FIRST=true

    # Add Figma if selected
    if [[ "$MCP_SERVERS" == *"figma"* ]]; then
        if [[ "$FIRST" == false ]]; then
            echo "," >> "$CLAUDE_CONFIG"
        fi
        FIRST=false
        cat >> "$CLAUDE_CONFIG" << 'EOF'
    "figma": {
      "type": "http",
      "url": "https://mcp.figma.com/mcp"
    }
EOF
    fi

    # Add Miro DS if token provided
    if [[ "$MCP_SERVERS" == *"miro"* ]]; then
        if [[ "$FIRST" == false ]]; then
            # Add comma to previous entry
            sed -i '' '$ s/}$/},/' "$CLAUDE_CONFIG"
        fi
        cat >> "$CLAUDE_CONFIG" << EOF
    "miro-design-system": {
      "type": "http",
      "url": "https://miro.design/api/mcp",
      "headers": {
        "Authorization": "Bearer ${MIRO_DS_TOKEN}",
        "X-User-Email": "${MIRO_EMAIL}"
      }
    }
EOF
    fi

    echo "  }" >> "$CLAUDE_CONFIG"
    echo "}" >> "$CLAUDE_CONFIG"

    print_success "MCP servers configured"
else
    echo -e "${DIM}No MCP servers configured. You can add them later in ~/.claude.json${NC}"
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
            echo ""
            echo -e -n "${DIM}Enter your email address:${NC} "
            read email
            mkdir -p ~/.ssh
            ssh-keygen -t ed25519 -C "$email" -f "$SSH_KEY_PATH" -N "" -q
            print_success "SSH key generated"
        fi
    elif [[ -f "$HOME/.ssh/id_rsa" ]]; then
        print_success "SSH key exists ${DIM}(RSA)${NC}"
        SSH_KEY_PATH="$HOME/.ssh/id_rsa"

        if ask_yes_no "Create a new ed25519 key? ${DIM}(recommended)${NC}"; then
            SSH_KEY_PATH="$HOME/.ssh/id_ed25519"
            echo ""
            echo -e -n "${DIM}Enter your email address:${NC} "
            read email
            mkdir -p ~/.ssh
            ssh-keygen -t ed25519 -C "$email" -f "$SSH_KEY_PATH" -N "" -q
            print_success "SSH key generated"
        fi
    else
        print_step "Generating SSH key..."
        echo ""
        echo -e -n "${DIM}Enter your email address:${NC} "
        read email
        mkdir -p ~/.ssh
        ssh-keygen -t ed25519 -C "$email" -f "$SSH_KEY_PATH" -N "" -q
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
    echo -e "${YELLOW}Paste your SSH key ${DIM}(it's in your clipboard)${NC}${YELLOW} and click 'Add SSH Key'${NC}"
    echo ""
    read -p "Press Enter when done..."
    echo ""

    # =============================================================================
    # GITHUB AUTH
    # =============================================================================

    if ! check_gh_auth; then
        print_step "Authenticating GitHub CLI..."
        echo ""
        echo -e "${DIM}Follow the prompts to sign in.${NC}"
        echo ""
        gh auth login
        echo ""
        print_success "GitHub CLI authenticated"
    else
        print_success "GitHub CLI ${DIM}already authenticated${NC}"
    fi

    echo ""
fi

# =============================================================================
# ZSH CONFIG
# =============================================================================

echo -e "${BOLD}Shell Configuration${NC}"
echo ""

ZSHRC="$HOME/.zshrc"

# Backup if exists
if [[ -f "$ZSHRC" ]]; then
    cp "$ZSHRC" "${ZSHRC}.backup.$(date +%Y%m%d%H%M%S)"
fi

# Ensure file exists
touch "$ZSHRC"

SHELL_MODIFIED=false

# Add Homebrew to path (Apple Silicon)
if [[ $(uname -m) == "arm64" ]]; then
    if ! grep -q '/opt/homebrew/bin/brew shellenv' "$ZSHRC"; then
        echo '' >> "$ZSHRC"
        echo '# Homebrew' >> "$ZSHRC"
        echo 'eval "$(/opt/homebrew/bin/brew shellenv)"' >> "$ZSHRC"
        SHELL_MODIFIED=true
    fi
fi

# Add Starship init
if ! grep -q 'starship init zsh' "$ZSHRC"; then
    echo '' >> "$ZSHRC"
    echo '# Starship prompt' >> "$ZSHRC"
    echo 'eval "$(starship init zsh)"' >> "$ZSHRC"
    SHELL_MODIFIED=true
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
alias grep="rg"
alias ..="cd .."
alias ...="cd ../.."
EOF
    SHELL_MODIFIED=true
fi

if [[ "$SHELL_MODIFIED" == true ]]; then
    print_success "Shell configured"
else
    print_success "Shell ${DIM}already configured${NC}"
fi

# Check if zsh is default shell
if [[ "$SHELL" != *"zsh"* ]]; then
    echo ""
    print_warning "Your default shell is not zsh"
    echo -e "  ${DIM}Run 'chsh -s /bin/zsh' to change it${NC}"
fi

# Source zshrc
source "$ZSHRC" 2>/dev/null || true

echo ""

# =============================================================================
# DONE
# =============================================================================

divider
echo ""
echo -e "${GREEN}${BOLD}Installation complete!${NC} ${SPARKLE}"
echo ""
echo -e "${DIM}Installed:${NC}"
print_item "Ghostty, GitHub Desktop"
print_item "git, gh, node, bun, claude"
print_item "starship, jq, fzf, ripgrep, eza, bat"
echo ""
divider
echo ""

print_step "Launching Ghostty..."
open "${REPO_URL}/next-steps.html"
sleep 0.5
open -a Ghostty
echo ""
echo -e "${BOLD}Welcome to your new terminal!${NC}"

echo ""
echo -e "Happy vibecoding! ${SPARKLE}"
echo ""
