#!/bin/sh
set -e

if [ ! -t 0 ]; then
  echo "Error: This script must be run interactively, not piped."
  echo ""
  echo "Download and run separately:"
  echo "  curl -fsSL https://raw.githubusercontent.com/benpops89/kamino/main/bootstrap.sh -o /tmp/kamino.sh"
  echo "  chmod +x /tmp/kamino.sh"
  echo "  KAMINO_UNIT=jakku /tmp/kamino.sh"
  echo ""
  echo "Or for all hosts:"
  echo "  /tmp/kamino.sh"
  exit 1
fi

HOST="${KAMINO_UNIT:-all}"
SCRIPT="/tmp/kamino-bootstrap-$$"

trap 'rm -f "$SCRIPT"' EXIT

curl -fsSL https://raw.githubusercontent.com/benpops89/kamino/main/bootstrap.sh -o "$SCRIPT"
chmod +x "$SCRIPT"
KAMINO_UNIT="$HOST" "$SCRIPT"
