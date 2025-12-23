<div align="center">
  <img src="docs/img/logo.png" alt="Vibecode Toolkit" width="128">
  <h1>Vibecode Toolkit</h1>
  <p>One command to set up your Mac for local vibecoding</p>
  <br>
  <p>
    <a href="https://mirowolff.github.io/vibecode-toolkit/">Website</a> •
    <a href="https://mirowolff.github.io/vibecode-toolkit/tools.html">Tools</a> •
    <a href="https://mirowolff.github.io/vibecode-toolkit/faq.html">FAQ</a>
  </p>
  <br>
</div>

## Install

```bash
curl -fsSL https://mirowolff.github.io/vibecode-toolkit/install.sh | bash
```

> **Note:** macOS only. Requires Xcode Command Line Tools.

## What's Included

**Development tools**
- Git, GitHub CLI, Node.js, Bun, Claude Code

**Terminal**
- Ghostty (with preconfigured settings)
- Starship prompt
- Useful aliases

**Utilities**
- jq, fzf, ripgrep, eza, bat

**Applications**
- GitHub Desktop

**Configuration**
- SSH key setup for GitHub
- Shell aliases
- MCP servers (Context7, Figma, Miro Design System)

## Highlights

- ✨ Pre-configured Ghostty terminal with Starship prompt
- 🔧 Essential CLI tools (ripgrep, fzf, eza, bat, jq)
- 🤖 Claude Code AI assistant
- 🔐 SSH key setup for GitHub
- ⚡ Shell aliases for common commands

## Requirements

- macOS (Apple Silicon or Intel)
- Administrator access
- Internet connection

## After Installation

1. Set Ghostty as your default terminal
2. Open Ghostty and run `c --help` to test Claude Code
3. Check the [next steps guide](https://mirowolff.github.io/vibecode-toolkit/next-steps.html)

## Customization

Configuration files are located at:

| Tool | Config Path |
|------|-------------|
| Ghostty | `~/.config/ghostty/config` |
| Starship | `~/.config/starship.toml` |
| Shell | `~/.zshrc` |
| Claude Code | `~/.claude.json` |

See the [Tools page](https://mirowolff.github.io/vibecode-toolkit/tools.html) for detailed documentation.

## FAQ

**How long does installation take?**
1-5 minutes depending on your connection and what's already installed.

**Is this safe to run?**
Yes. The script is [open source](https://github.com/mirowolff/vibecode-toolkit) and only installs standard developer tools.

**Can I customize what gets installed?**
Fork the repo and modify `docs/install.sh` to skip components you don't want.

More questions? Check the [full FAQ](https://mirowolff.github.io/vibecode-toolkit/faq.html).

## License

MIT
