#!/bin/sh

# Colours
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

# Config
REPO="https://github.com/benpops89/kamino.git"
INSTALL_DIR="$HOME/github/kamino"

log_warn() {
  printf "%b[WARN]%b %s\n" "$YELLOW" "$NC" "$1"
}

log_error() {
  printf "%b[ERROR]%b %s\n" "$RED" "$NC" "$1" >&2
}

error_exit() {
  log_error "$1"
  exit 1
}

log_success() {
  printf "\n%bClone sequence complete!%b\n\n" "$GREEN" "$NC"
}

command_exists() {
  command -v "$1" >/dev/null 2>&1
}

run_step() {
  echo "● $1..."
  OUTPUT=$(eval "$3" 2>&1)
  RESULT=$?
  if [ $RESULT -ne 0 ]; then
    echo "$OUTPUT" >&2
    exit $RESULT
  fi
  echo "✓ $2"
  echo ""
}

detect_os() {
  case "$(uname -s)" in
    Darwin*) echo "macos" ;;
    Linux*)
      if [ -f /etc/debian_version ]; then
        echo "debian"
      elif [ -f /etc/arch-release ]; then
        echo "arch"
      else
        echo "debian"
      fi
      ;;
    *) error_exit "Unsupported OS" ;;
  esac
}

install_deps_debian() {
  MISSING=""
  for dep in git python3 ansible-core; do
    if ! command_exists "$dep"; then
      MISSING="$MISSING $dep"
    fi
  done

  if [ -n "$MISSING" ]; then
    log_warn "Missing:$MISSING"
    sudo apt update || exit 1
    sudo apt install -y$MISSING || exit 1
  fi
}

install_deps_arch() {
  MISSING=""
  for dep in git python ansible-core; do
    if ! command_exists "$dep"; then
      MISSING="$MISSING $dep"
    fi
  done

  if [ -n "$MISSING" ]; then
    log_warn "Missing:$MISSING"
    sudo pacman -Sy --needed$MISSING || exit 1
  fi
}

install_deps_macos() {
  for dep in git python3; do
    if ! command_exists "$dep"; then
      error_exit "$dep is required but not installed"
    fi
  done

  if ! command_exists ansible-core; then
    log_warn "Installing ansible-core via pip"
    python3 -m pip install ansible-core || exit 1
  fi
}

check_dependencies() {
  OS=$(detect_os)
  case "$OS" in
    debian) install_deps_debian ;;
    arch) install_deps_arch ;;
    macos) install_deps_macos ;;
  esac
}

setup_repo() {
  if [ -d "$INSTALL_DIR" ]; then
    echo "Repository already exists at $INSTALL_DIR, skipping..."
    cd "$INSTALL_DIR" || exit 1
  else
    git clone -b main "$REPO" "$INSTALL_DIR" || exit 1
    cd "$INSTALL_DIR" || exit 1
  fi
}

install_ansible_deps() {
  cd "$INSTALL_DIR" || exit 1
  ansible-galaxy install -r requirements.yml || exit 1
}

run_playbook() {
  if [ -z "$GITHUB_TOKEN" ]; then
    echo "GitHub token is used by mise to avoid rate limits when installing tools."
    printf "Enter GitHub token (press Enter to skip): "
    read -r GITHUB_TOKEN
    echo ""
    if [ -n "$GITHUB_TOKEN" ]; then
      export GITHUB_TOKEN
    fi
  fi
}

main() {
  cat <<'EOF'

   ╔══════════════════════════════════════════════════╗
   ║                                                  ║
   ║       ██████╗██████╗ ██████╗  ██████╗ ███████╗   ║
   ║      ██╔════╝██╔══██╗██╔══██╗██╔═══██╗██╔════╝   ║
   ║      ██║     ██████╔╝██████╔╝██║   ██║█████╗     ║
   ║      ██║     ██╔══██╗██╔══██╗██║   ██║██╔══╝     ║
   ║      ╚██████╗██║  ██║██║  ██║╚██████╔╝███████╗   ║
   ║       ╚═════╝╚═╝  ╚═╝╚═╝  ╚═╝ ╚═════╝ ╚══════╝   ║
   ║                                                  ║
   ║           Kamino Unit Deployment System          ║
   ║                                                  ║
   ╚══════════════════════════════════════════════════╝

EOF

  echo "● Authenticating..."
  sudo -v || exit 1
  echo "✓ Authenticated"
  echo ""

  run_step "Installing dependencies" "Installed dependencies" "check_dependencies"
  run_step "Setting up repository" "Set up repository" "setup_repo"
  run_step "Installing Ansible deps" "Installed Ansible deps" "install_ansible_deps"

  run_playbook

  echo "● Running playbook..."
  cd "$INSTALL_DIR" || exit 1
  UNIT="${KAMINO_UNIT:-all}"
  ansible-playbook main.yml -i inventory --limit "$UNIT" -K || exit 1
  echo "✓ Ran playbook"
  echo ""

  log_success
}

main "$@"
