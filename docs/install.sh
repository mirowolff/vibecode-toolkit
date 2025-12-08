#!/bin/bash
# v1.0.1

set -e

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

REPO_URL="https://mirowolff.github.io/vibecode-toolkit"

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

echo ""
echo -e "${BLUE}🛠  Vibecode Toolkit Installer${NC}"
echo ""

# Open pre-install page
print_step "Opening installation guide..."
open "${REPO_URL}/index.html"
echo ""
read -p "Review what's being installed, then press Enter to continue..."
echo ""

# =============================================================================
# PREFLIGHT CHECKS
# =============================================================================

echo "Checking prerequisites..."
echo ""

# Xcode Command Line Tools
if xcode-select -p &>/dev/null; then
    print_success "Xcode Command Line Tools"
else
    print_step "Installing Xcode Command Line Tools..."
    xcode-select --install
    echo ""
    print_warning "A dialog will appear. Click 'Install' and wait for completion."
    read -p "Press Enter when installation is complete..."
    
    if xcode-select -p &>/dev/null; then
        print_success "Xcode Command Line Tools"
    else
        print_error "Xcode Command Line Tools installation failed"
        exit 1
    fi
fi

# Rosetta 2 (Apple Silicon only)
if [[ $(uname -m) == "arm64" ]]; then
    if /usr/bin/pgrep -q oahd; then
        print_success "Rosetta 2"
    else
        print_step "Installing Rosetta 2..."
        softwareupdate --install-rosetta --agree-to-license
        print_success "Rosetta 2"
    fi
fi

echo ""

# =============================================================================
# HOMEBREW
# =============================================================================

if command -v brew &>/dev/null; then
    print_success "Homebrew already installed"
else
    print_step "Installing Homebrew..."
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
    
    # Add to path for this session
    if [[ $(uname -m) == "arm64" ]]; then
        eval "$(/opt/homebrew/bin/brew shellenv)"
    else
        eval "$(/usr/local/bin/brew shellenv)"
    fi
    print_success "Homebrew"
fi

print_step "Updating Homebrew..."
brew update --quiet
print_success "Homebrew updated"

echo ""

# =============================================================================
# CLI TOOLS
# =============================================================================

echo "Installing CLI tools..."
echo ""

CLI_TOOLS=(
    "git"
    "gh"
    "node"
    "oven-sh/bun/bun"
    "claude"
    "starship"
    "jq"
    "fzf"
    "ripgrep"
    "eza"
    "bat"
)

for tool in "${CLI_TOOLS[@]}"; do
    tool_name=$(basename "$tool")
    if brew list "$tool_name" &>/dev/null; then
        print_success "$tool_name (already installed)"
    else
        print_step "Installing $tool_name..."
        brew install "$tool" --quiet
        print_success "$tool_name"
    fi
done

echo ""

# =============================================================================
# APPLICATIONS
# =============================================================================

echo "Installing applications..."
echo ""

CASK_APPS=(
    "ghostty"
    "github"
)

for app in "${CASK_APPS[@]}"; do
    if brew list --cask "$app" &>/dev/null; then
        print_success "$app (already installed)"
    else
        print_step "Installing $app..."
        brew install --cask "$app" --quiet
        print_success "$app"
    fi
done

echo ""

# =============================================================================
# GHOSTTY CONFIG
# =============================================================================

print_step "Configuring Ghostty..."

mkdir -p ~/.config/ghostty

curl -fsSL "${REPO_URL}/config/ghostty.conf" -o ~/.config/ghostty/config

print_success "Ghostty config written"

echo ""

# =============================================================================
# STARSHIP CONFIG
# =============================================================================

print_step "Configuring Starship..."

mkdir -p ~/.config

curl -fsSL "${REPO_URL}/config/starship.toml" -o ~/.config/starship.toml

print_success "Starship config written"

echo ""

# =============================================================================
# SSH KEY
# =============================================================================

echo "Setting up SSH key for GitHub..."
echo ""

SSH_KEY_PATH="$HOME/.ssh/id_ed25519"

if [[ -f "$SSH_KEY_PATH" ]]; then
    print_success "SSH key already exists"
else
    print_step "Generating SSH key..."
    
    read -p "Enter your email address: " email
    
    mkdir -p ~/.ssh
    ssh-keygen -t ed25519 -C "$email" -f "$SSH_KEY_PATH" -N ""
    
    print_success "SSH key generated"
    
    print_step "Adding to keychain..."
    eval "$(ssh-agent -s)" &>/dev/null
    ssh-add --apple-use-keychain "$SSH_KEY_PATH" 2>/dev/null
    print_success "Added to keychain"
fi

# Copy public key to clipboard
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
# ZSH CONFIG
# =============================================================================

print_step "Configuring shell..."

ZSHRC="$HOME/.zshrc"

# Backup
if [[ -f "$ZSHRC" ]]; then
    BACKUP="${ZSHRC}.backup.$(date +%Y%m%d%H%M%S)"
    cp "$ZSHRC" "$BACKUP"
    print_success "Backed up .zshrc to $BACKUP"
fi

# Ensure file exists
touch "$ZSHRC"

# Add Homebrew to path if not present (for Apple Silicon)
if [[ $(uname -m) == "arm64" ]]; then
    if ! grep -q '/opt/homebrew/bin/brew shellenv' "$ZSHRC"; then
        echo '' >> "$ZSHRC"
        echo '# Homebrew' >> "$ZSHRC"
        echo 'eval "$(/opt/homebrew/bin/brew shellenv)"' >> "$ZSHRC"
    fi
fi

# Add Starship init if not present
if ! grep -q 'starship init zsh' "$ZSHRC"; then
    echo '' >> "$ZSHRC"
    echo '# Starship prompt' >> "$ZSHRC"
    echo 'eval "$(starship init zsh)"' >> "$ZSHRC"
fi

# Add aliases if not present
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

echo ""

# =============================================================================
# GITHUB AUTH
# =============================================================================

print_step "Authenticating with GitHub..."
echo ""
echo "Follow the prompts to sign in with your GitHub account."
echo ""

gh auth login

print_success "GitHub authenticated"

echo ""

# =============================================================================
# DONE
# =============================================================================

echo -e "${GREEN}✓ Installation complete!${NC}"
echo ""
echo "Installed:"
echo "  • git, gh, node, bun, claude"
echo "  • starship, jq, fzf, ripgrep, eza, bat"
echo "  • Ghostty, GitHub Desktop"
echo ""

# Open next steps
print_step "Opening next steps guide..."
open "${REPO_URL}/next-steps.html"

echo ""
echo -e "${BLUE}Next:${NC}"
echo "  1. Set Ghostty as your default terminal"
echo "  2. Open Ghostty"
echo "  3. Run: claude"
echo ""
echo -e "Happy vibecoding ✨"
echo ""
