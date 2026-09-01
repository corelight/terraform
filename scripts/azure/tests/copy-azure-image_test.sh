#!/usr/bin/env bash

set -euo pipefail

SCRIPT_DIR=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)
SCRIPT_UNDER_TEST="${SCRIPT_DIR}/../copy-azure-image.sh"
TEST_TMP=$(mktemp -d)
trap 'rm -rf "$TEST_TMP"' EXIT

mkdir -p "$TEST_TMP/bin"

cat >"$TEST_TMP/bin/az" <<'EOF'
#!/usr/bin/env bash
set -euo pipefail

echo "$*" >>"$AZ_CALLS"

case "$*" in
    "storage blob generate-sas"*)
        echo '"https://destination.example/image.vhd?sig=test"'
        ;;
    "sig show"*)
        exit 1
        ;;
    "sig image-definition show"*)
        exit 1
        ;;
    "sig image-version show"*)
        if [[ "$*" == *"--query id"* ]]; then
            echo "/subscriptions/test/resourceGroups/test-rg/providers/Microsoft.Compute/galleries/corelightSensorGallery/images/${EXPECTED_IMAGE_DEFINITION}/versions/1.0.0"
        else
            exit 1
        fi
        ;;
esac
EOF

cat >"$TEST_TMP/bin/azcopy" <<'EOF'
#!/usr/bin/env bash
exit 0
EOF

cat >"$TEST_TMP/bin/date" <<'EOF'
#!/usr/bin/env bash
echo "2030-01-01T00:00:00Z"
EOF

chmod +x "$TEST_TMP/bin/az" "$TEST_TMP/bin/azcopy" "$TEST_TMP/bin/date"

run_case() {
    local blob_name="$1"
    local expected_definition="$2"
    local expected_generation="$3"
    local expected_controllers="$4"
    local calls_file="$TEST_TMP/${expected_definition}.calls"
    local output

    output=$(PATH="$TEST_TMP/bin:$PATH" \
        AZ_CALLS="$calls_file" \
        EXPECTED_IMAGE_DEFINITION="$expected_definition" \
        "$SCRIPT_UNDER_TEST" \
        --source-sas "https://source.example/images/${blob_name}?sig=test" \
        --dest-resource-group test-rg \
        --dest-account-name teststorage \
        --dest-container-name images)

    local expected_id="/subscriptions/test/resourceGroups/test-rg/providers/Microsoft.Compute/galleries/corelightSensorGallery/images/${expected_definition}/versions/1.0.0"

    grep -F "Terraform source_image_id: $expected_id" <<<"$output" >/dev/null
    grep -F -- "--gallery-image-definition $expected_definition" "$calls_file" >/dev/null
    grep -F -- "--gallery-image-version 1.0.0" "$calls_file" >/dev/null
    grep -F -- "--hyper-v-generation $expected_generation" "$calls_file" >/dev/null
    grep -F -- "--features DiskControllerTypes=$expected_controllers" "$calls_file" >/dev/null
}

run_case "corelight-sensor-v29.2.0-rc30.vhd" "corelight-sensor-v29.2.0-rc30" "V2" "SCSI,NVMe"
run_case "corelight-sensor-v29.2.0.vhd" "corelight-sensor-v29.2.0" "V2" "SCSI,NVMe"
run_case "corelight-sensor-v28.3.0-rc1.vhd" "corelight-sensor-v28.3.0-rc1" "V1" "SCSI"

echo "copy-azure-image tests passed"
