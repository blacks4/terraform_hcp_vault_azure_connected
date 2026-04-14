#!/bin/sh
set -eu

PRIVATE_KEY_PATH="$1"
PUBLIC_KEY_PATH="${PRIVATE_KEY_PATH}.pub"

if [ ! -f "$PRIVATE_KEY_PATH" ] || [ ! -f "$PUBLIC_KEY_PATH" ]; then
  mkdir -p "$(dirname "$PRIVATE_KEY_PATH")"
  rm -f "$PRIVATE_KEY_PATH" "$PUBLIC_KEY_PATH"
  ssh-keygen -q -t rsa -b 4096 -m PEM -N "" -f "$PRIVATE_KEY_PATH" >/dev/null
  chmod 600 "$PRIVATE_KEY_PATH"
  chmod 644 "$PUBLIC_KEY_PATH"
fi

PUBLIC_KEY="$(tr -d '\n' < "$PUBLIC_KEY_PATH")"

printf '{"public_key":"%s","private_key_path":"%s","public_key_path":"%s"}\n' \
  "$PUBLIC_KEY" \
  "$PRIVATE_KEY_PATH" \
  "$PUBLIC_KEY_PATH"
