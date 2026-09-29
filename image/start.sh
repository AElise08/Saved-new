#!/bin/sh
# Boot for Saved on the Plow OpenClaw base: seed the vault home, start the
# outbox drain, then hand PID 1 to the base's own boot.
set -eu

mkdir -p "$HERMES_HOME/.saved"
chmod 0700 "$HERMES_HOME/.saved"
for f in /opt/saved/templates/*.json; do
  [ -e "$HERMES_HOME/${f##*/}" ] || cp "$f" "$HERMES_HOME/"
done

# Drain the outbox every five minutes, including the Sunday weekly digest:
# drain() itself checks the owner's local weekly window. Runs the root-owned
# /opt/saved copy, never one a turn could have rewritten.
# ponytail: a plain background loop, not a supervised service; it survives a
# failed drain but not its own death. Move it under a supervisor if that bites.
(
  export PLOW_AGENT_TOKEN="${PLOW_AGENT_TOKEN:-proxied}"
  while :; do
    python3 /opt/saved/scripts/outbox.py drain \
      || echo "saved-outbox: drain exited non-zero; retrying at the next tick" >&2
    sleep 300
  done
) &

exec node /opt/plow/boot/main.js
