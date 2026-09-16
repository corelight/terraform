#!/usr/bin/env bash
#
# Register sensors with Fleet Manager and maintain the pairing manifest.
#
# Usage:
#   ./scripts/register-sensors.sh \
#     --fleet-url https://fleet.example.com:1443 \
#     --username admin \
#     --password 'secret' \
#     --sensors sensor-1,sensor-2,sensor-3
#
# The script reads sensors.json (if it exists), creates Fleet catalog entries
# only for sensors not already in the manifest, and writes the updated manifest.
# Existing entries are never modified — tokens are stable across runs.

set -euo pipefail

MANIFEST="sensors.json"
FLEET_URL=""
USERNAME=""
PASSWORD=""
SENSORS=""

usage() {
  cat <<EOF
Usage: $0 --fleet-url URL --username USER --password PASS --sensors name1,name2,...

Options:
  --fleet-url   Fleet Manager URL (e.g. https://fleet.example.com:1443)
  --username    Fleet admin username
  --password    Fleet admin password
  --sensors     Comma-separated list of desired sensor names
  --manifest    Path to sensors.json (default: sensors.json)
  -h, --help    Show this help
EOF
  exit 1
}

while [[ $# -gt 0 ]]; do
  case "$1" in
    --fleet-url)  FLEET_URL="$2"; shift 2 ;;
    --username)   USERNAME="$2"; shift 2 ;;
    --password)   PASSWORD="$2"; shift 2 ;;
    --sensors)    SENSORS="$2"; shift 2 ;;
    --manifest)   MANIFEST="$2"; shift 2 ;;
    -h|--help)    usage ;;
    *)            echo "Unknown option: $1"; usage ;;
  esac
done

if [[ -z "$FLEET_URL" || -z "$USERNAME" || -z "$PASSWORD" || -z "$SENSORS" ]]; then
  echo "Error: --fleet-url, --username, --password, and --sensors are all required."
  usage
fi

# Strip trailing slash from Fleet URL
FLEET_URL="${FLEET_URL%/}"

# Load existing manifest or start empty
if [[ -f "$MANIFEST" ]]; then
  manifest=$(cat "$MANIFEST")
else
  manifest='{}'
fi

# Login to Fleet API
echo "Logging in to Fleet at ${FLEET_URL}..."
login_response=$(curl -sk -X POST "${FLEET_URL}/fleet/v1/login" \
  -H "Content-Type: application/json" \
  -d "{\"username\": \"${USERNAME}\", \"password\": \"${PASSWORD}\"}")

bearer_token=$(echo "$login_response" | jq -r '.token // empty')
if [[ -z "$bearer_token" ]]; then
  echo "Error: Failed to authenticate with Fleet API."
  echo "Response: $login_response"
  exit 1
fi
echo "Authenticated successfully."

# Process each sensor
IFS=',' read -ra sensor_names <<< "$SENSORS"
new_count=0

for sensor_name in "${sensor_names[@]}"; do
  sensor_name=$(echo "$sensor_name" | xargs)  # trim whitespace

  # Skip if already in manifest
  if echo "$manifest" | jq -e ".\"${sensor_name}\"" > /dev/null 2>&1; then
    echo "  ${sensor_name}: already registered (skipping)"
    continue
  fi

  echo "  ${sensor_name}: creating catalog entry..."
  catalog_response=$(curl -sk -X POST "${FLEET_URL}/fleet/v1/sensor/catalog" \
    -H "Content-Type: application/json" \
    -H "Authorization: Bearer ${bearer_token}" \
    -d "{\"name\": \"${sensor_name}\", \"provider\": \"TETHERED\"}")

  pairing_token=$(echo "$catalog_response" | jq -r '.tethering_token // empty')

  if [[ -z "$pairing_token" ]]; then
    echo "    Error: Failed to create catalog entry for ${sensor_name}."
    echo "    Response: $catalog_response"
    exit 1
  fi

  manifest=$(echo "$manifest" | jq \
    --arg name "$sensor_name" \
    --arg token "$pairing_token" \
    '.[$name] = $token')

  echo "    Registered with token ${pairing_token:0:8}..."
  ((new_count++))
done

# Write updated manifest
echo "$manifest" | jq '.' > "$MANIFEST"
echo ""
echo "Done. ${new_count} new sensor(s) registered. Manifest written to ${MANIFEST}."
echo "Existing sensors were not modified."
