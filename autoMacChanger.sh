#!/usr/bin/env bash
# auto-macchange.sh
# Requires: macchanger, ip (iproute2)
# Usage: sudo ./auto-macchange.sh

set -euo pipefail

# --- helper funcs ---
err() { echo "ERROR: $*" >&2; }
info() { echo "-> $*"; }

# require root
if [[ $EUID -ne 0 ]]; then
  err "This script must be run as root (use sudo)."
  exit 1
fi

# check macchanger exists
if ! command -v macchanger >/dev/null 2>&1; then
  err "macchanger not found. Install with: sudo apt update && sudo apt install macchanger"
  exit 1
fi

# prompt for interface
read -rp "Enter network interface to change (e.g. wlan0, eth0): " IFACE
IFACE=${IFACE:-wlan0}

# validate interface exists
if ! ip link show dev "$IFACE" >/dev/null 2>&1; then
  err "Interface '$IFACE' not found. Use 'ip link' to list available interfaces."
  exit 1
fi

# save original MAC
ORIG_MAC=$(cat /sys/class/net/"$IFACE"/address)
info "Original MAC for $IFACE: $ORIG_MAC"

# prompt for number of times
read -rp "How many times do you want to change the MAC? " TIMES_INPUT
# validate integer > 0
if ! [[ $TIMES_INPUT =~ ^[0-9]+$ ]] || [[ $TIMES_INPUT -le 0 ]]; then
  err "Invalid number of times: '$TIMES_INPUT'. Must be a positive integer."
  exit 1
fi
TIMES=$TIMES_INPUT

# prompt for delay in seconds
read -rp "Delay between changes (seconds): " DELAY_INPUT
# allow decimal or integer? we'll accept positive numbers (integer or float)
if ! [[ $DELAY_INPUT =~ ^[0-9]+(\.[0-9]+)?$ ]] || (( $(echo "$DELAY_INPUT <= 0" | bc -l) )); then
  err "Invalid delay: '$DELAY_INPUT'. Must be a positive number."
  exit 1
fi
DELAY=$DELAY_INPUT

# ensure ip command can bring interface down/up
info "I will change the MAC $TIMES times on interface $IFACE with $DELAY second(s) delay."

cleanup() {
  echo
  info "Restoring original hardware MAC (attempt) for $IFACE..."
  # try to bring down/up and restore permanent MAC
  ip link set dev "$IFACE" down || true
  # attempt to reset to permanent factory MAC:
  macchanger -p "$IFACE" >/dev/null 2>&1 || true
  # if macchanger -p doesn't change (some drivers), set original explicitly:
  macchanger -m "$ORIG_MAC" "$IFACE" >/dev/null 2>&1 || true
  ip link set dev "$IFACE" up || true
  NEW=$(cat /sys/class/net/"$IFACE"/address 2>/dev/null || echo "unknown")
  info "MAC after restore attempt: $NEW"
  info "Done."
}
trap cleanup EXIT INT TERM

# perform changes
for ((i=1;i<=TIMES;i++)); do
  echo
  info "Iteration $i / $TIMES: changing MAC..."
  # bring down
  ip link set dev "$IFACE" down
  # change to a random MAC
  macchanger -r "$IFACE" || { err "macchanger failed."; exit 1; }
  # bring up
  ip link set dev "$IFACE" up
  # show the current MAC and vendor info via macchanger -s
  echo "Result:"
  macchanger -s "$IFACE"
  # wait specified seconds (allow fractional delays)
  if (( i < TIMES )); then
    # for fractional sleep we use sleep directly (supports floats)
    sleep "$DELAY"
  fi
done

# normal exit -> cleanup trap will restore original
exit 0
