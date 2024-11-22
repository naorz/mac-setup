# Setup new development environment for macOS

> Automate your MacBook setup for development environments.

## Structure
```
new-setup/
├── setup.sh
├── README.md
└── src/
    ├── common/
    │   ├── colors.sh
    │   ├── logging.sh
    │   ├── utils.sh
    │   ├── gist.sh
    │   ├── state.sh
    │   ├── dependencies.sh
    │   └── installation_tracker.sh
    ├── modules/
    │   ├── select.sh
    │   ├── install.sh
    │   ├── export.sh
    │   ├── import.sh
    │   └── help.sh
    ├── config/
    │   └── tools.json
    └── state/
```

# Mac Development Environment Setup

Automate your MacBook setup for development environments.

## Quick Install
```bash
curl -sSL https://raw.githubusercontent.com/username/mac-setup/main/setup.sh | bash
```

### Features
- 🔄 Export/Import system settings
- 🛠 Development tools installation
- 📦 Package management via Homebrew
- ☁️ Settings sync via GitHub Gists
- ⚡️ Resume interrupted installations

### Usage
1. Select tools: macsetup select
2. Install tools: macsetup install
3. Export settings: macsetup export [--gist]
4. Import settings: macsetup import [gist-id|file]

### Supported Tools
- IDEs: VSCode, WebStorm, Rider
- Languages: Node.js, Go, Rust, Python
- VM: Docker, Minikube
- CLI: zsh, jq, wget, git
- MacOS misc apps: Rectangle, DisplayLink, Maccy, etc.



