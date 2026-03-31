#!/bin/sh
set -e

if [ ! -t 0 ]; then
  echo "Downloading bootstrap script..."
  curl -fsSL https://raw.githubusercontent.com/benpops89/kamino/main/bootstrap.sh -o /tmp/kamino.sh
  chmod +x /tmp/kamino.sh
  echo "Running interactively..."
  KAMINO_UNIT="$KAMINO_UNIT" exec /tmp/kamino.sh < /dev/tty
fi

HOST="${KAMINO_UNIT:-all}"
SCRIPT="/tmp/kamino-bootstrap-$$"

trap 'rm -f "$SCRIPT"' EXIT

curl -fsSL https://raw.githubusercontent.com/benpops89/kamino/main/bootstrap.sh -o "$SCRIPT"
chmod +x "$SCRIPT"
KAMINO_UNIT="$HOST" "$SCRIPT"
