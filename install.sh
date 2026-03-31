#!/bin/sh
set -e

SCRIPT="/tmp/kamino-bootstrap-$$"

trap 'rm -f "$SCRIPT"' EXIT

curl -fsSL https://raw.githubusercontent.com/benpops89/kamino/main/bootstrap.sh -o "$SCRIPT"
chmod +x "$SCRIPT"
"$SCRIPT"
