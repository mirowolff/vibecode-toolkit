# Vibecode Toolkit

Development environment installer for designers learning to code ("vibecode"). Provides automated macOS setup with essential development tools.

## Project Structure

```
vibecode-toolkit/
├── docs/                      # GitHub Pages site
│   ├── index.html            # Installation overview page
│   ├── next-steps.html       # Post-install guidance
│   ├── install.sh            # Main installation script
│   └── config/               # Configuration templates
│       ├── ghostty.conf      # Ghostty terminal config
│       └── starship.toml     # Starship prompt config
├── config/                    # Local config copies
│   └── starship.toml
└── .github/workflows/
    └── pages.yml             # Auto-deploy docs to GitHub Pages
```

## What It Does

The installer (`docs/install.sh`) automates macOS development environment setup:

1. **Prerequisites**: Xcode CLI Tools, Rosetta 2 (Apple Silicon)
2. **Package Manager**: Homebrew
3. **CLI Tools**: git, gh, node, bun, claude, starship, jq, fzf, ripgrep, eza, bat
4. **Apps**: Ghostty (terminal), GitHub Desktop
5. **Configuration**: SSH keys, shell aliases, terminal/prompt customization
6. **Authentication**: GitHub CLI + SSH

## Installation Flow

- Opens docs in browser before installing (transparency)
- Interactive prompts for email (SSH key), GitHub auth
- Creates backups before modifying `.zshrc`
- Installs only if not already present
- Opens next-steps guide when complete

## Key Features

- **Ghostty Terminal**: Pre-configured modern terminal
- **Starship Prompt**: Custom prompt showing directory, git status, duration
- **Shell Aliases**: Shortcuts for common git/file commands (`c`, `g`, `gs`, `ll`, etc.)
- **SSH Setup**: Auto-generates ed25519 key, adds to keychain, guides GitHub upload

## Deployment

GitHub Actions automatically deploys `docs/` to GitHub Pages on push to main. Install URL: `https://mirowolff.github.io/vibecode-toolkit/install.sh`

## Target Audience

Designers transitioning to coding - prioritizes simplicity and guided experience over customization.
