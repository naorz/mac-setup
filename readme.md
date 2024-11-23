# Dev Tools Installer

Automate the setup of your a new Mac for development environments.

## table of contents
- [Dev Tools Installer](#dev-tools-installer)
  - [table of contents](#table-of-contents)
  - [Quick Install](#quick-install)
  - [Declaimer](#declaimer)
    - [Features](#features)
    - [Usage](#usage)
    - [Supported Tools](#supported-tools)
  - [Structure](#structure)


## Quick Install
```bash
curl -sSL https://raw.githubusercontent.com/naorz/mac-setup/main/setup.sh select | bash
```

## Declaimer
> 🚧 Currently under development, use at your own risk.  

Already tested:  
- [x] select
- [x] tools
- [x] help
- [ ] install
- [ ] export
- [ ] import

### Features
- 📦 Package management via Homebrew
- 🛠 Development tools installation
- 🚧 🔄 Export/Import macos system settings
- ⚡️ Resume interrupted installations
- ☁️ Settings sync via GitHub Gists

### Usage
1. Select tools: macsetup select
2. Install tools: macsetup install
3. Export (macOS preferences) settings: macsetup export [--gist]
4. Import (macOS preferences) settings: macsetup import [gist-id|file]
5. Print available tools: macsetup tools
6. Help: macsetup help

### Supported Tools
- IDEs: Visual Studio Code, WebStorm, Rider
- Languages: Node.js, Go, Rust, Python
- VM: Docker, Minikube
- CLI: zsh, jq, wget, git
- MacOS misc apps: Rectangle, DisplayLink, Maccy, iTerm2, Slack, Zoom, Postman, Alfred, 1Password, Spotify, Notion, Firefox, Chrome, Brave

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