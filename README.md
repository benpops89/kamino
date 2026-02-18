# Development Environment Setup with Ansible

This repository contains Ansible playbooks and configuration files to automate the setup of my development environment. It installs relevant packages and applications to ensure a consistent and efficient development setup across different machines.

## Supported Platforms

- **macOS** - Uses Homebrew for package management
- **Debian/Ubuntu** - Uses apt and AppImages

## Prerequisites

Before running the playbooks, ensure you have the following installed on your system:

- [Ansible](https://docs.ansible.com/ansible/latest/installation_guide/intro_installation.html) (version 2.16 or later)
- [Git](https://git-scm.com/book/en/v2/Getting-Started-Installing-Git)

## Installation

1. **Clone the repository:**

   ```sh
   git clone git@github.com:benpops89/ansible-jedi-setup.git
   cd ansible-jedi-setup
   ```

2. Install required Ansible roles:

   ```sh
   ansible-galaxy install -r requirements.yml
   ```

## Usage

Choose the appropriate playbook for your operating system:

### macOS

```sh
ansible-playbook macos.yml --ask-become-pass
```

### Debian/Ubuntu

```sh
ansible-playbook debian.yml --ask-become-pass
```

Both commands will prompt for your sudo password to install the necessary packages and applications.

## What's Installed

### Developer Tools (via mise)
Most developer tools are managed via [mise](https://mise.run). This playbook installs mise itself; tool versions are configured in your dotfiles.

### macOS
- **Homebrew packages**: gcc, stow, mise, openssl@3
- **Homebrew casks**: raycast, obsidian, wezterm, todoist, docker, dbeaver-community, spotify, slack, hammerspoon, hiddenbar, brainfm, font-maple-mono-nf

### Debian/Ubuntu
- **apt packages**: zsh, wezterm, build-essential, procps, curl, file, git, rpi-imager, dnsutils, gnupg, pass
- **AppImages**: obsidian, ghostty, bambustudio

### Both
- Dotfiles (via stow)
- Git configuration

## File Structure

```
.
├── .mise.toml          # Mise tasks for running playbooks
├── config.yml          # Configuration variables (packages, apps, git config)
├── macos.yml           # macOS playbook
├── debian.yml          # Debian/Ubuntu playbook
├── requirements.yml    # Ansible Galaxy roles/collections
├── inventory           # Ansible inventory (localhost)
├── ansible.cfg         # Ansible configuration
├── tasks/              # Reusable task files
│   ├── apt-packages.yml
│   ├── appimage.yml
│   ├── dotfiles.yml
│   ├── git.yml
│   └── homebrew.yml
└── templates/          # Desktop entry templates
```

## Configuration

Edit `config.yml` to customize:
- Packages to install
- Homebrew cask applications
- Git configuration (name, email, editor, etc.)
- Docker users
