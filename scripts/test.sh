#!/usr/bin/env bash
set -euo pipefail

# Test script for EcoStack metrics action
# This script simulates the environment variables and data that would be sent

echo "🧪 EcoStack Metrics Action Test Script"
echo "======================================"

# Check if required tools are available
command -v curl >/dev/null 2>&1 || { echo "❌ curl is required but not installed. Aborting." >&2; exit 1; }
command -v jq >/dev/null 2>&1 || { echo "⚠️  jq is not installed. JSON output will not be formatted." >&2; }

# Test configuration
API_URL="${1:-}"
API_KEY="${2:-}"

if [[ -z "$API_URL" ]]; then
    echo "❌ Usage: $0 <api_url> [api_key]"
    echo "   Example: $0 https://your-api.ecostack.com/metrics your-api-key"
    exit 1
fi

echo "📡 API URL: $API_URL"
if [[ -n "$API_KEY" ]]; then
    echo "🔑 API Key: ${API_KEY:0:8}..."
else
    echo "🔑 API Key: Not provided"
fi

# Simulate GitHub Actions environment
export REPO="test-org/test-repo"
export RUN_ID="1234567890"
export RUN_ATTEMPT="1"
export WORKFLOW="Test Workflow"
export JOB="test-job"
export ACTOR="test-user"
export REF="refs/heads/main"
export SHA="abc123def456789"
export RUNNER_NAME="ubuntu-latest"
export RUNNER_OS="Linux"
export RUNNER_ARCH="X64"
export RUNNER_LABELS="ubuntu-latest,ubuntu-22.04,X64"
export EVENT_NAME="push"
export EVENT_ACTION=""
export BASE_REF=""
export HEAD_REF=""
export WORKSPACE="/home/runner/work/test-repo"
export INCLUDE_SYSTEM="true"

echo ""
echo "🔧 Simulating GitHub Actions environment..."
echo "   Repository: $REPO"
echo "   Workflow: $WORKFLOW"
echo "   Runner: $RUNNER_NAME ($RUNNER_OS/$RUNNER_ARCH)"

# Collect system stats (similar to the actual action)
echo ""
echo "📊 Collecting system statistics..."
CORES=$(getconf _NPROCESSORS_ONLN 2>/dev/null || nproc 2>/dev/null || echo 0)
if [[ -r /proc/meminfo ]]; then
    MEM_TOTAL_MB=$(awk '/MemTotal/ {print int($2/1024)}' /proc/meminfo 2>/dev/null || echo 0)
else
    MEM_TOTAL_MB=0
fi
DISK_AVAIL_MB=$(df -Pm / 2>/dev/null | tail -1 | awk '{print $4}' 2>/dev/null || echo 0)

echo "   CPU Cores: $CORES"
echo "   Memory: ${MEM_TOTAL_MB}MB"
echo "   Disk Available: ${DISK_AVAIL_MB}MB"

# Build test payload
now_iso=$(date -Iseconds 2>/dev/null || python3 -c "import datetime; print(datetime.datetime.utcnow().replace(microsecond=0).isoformat()+'Z')")

payload=$(cat <<JSON
{
  "kind": "action_probe",
  "ts": "$now_iso",
  "repo": "$REPO",
  "workflow": "$WORKFLOW",
  "job": "$JOB",
  "actor": "$ACTOR",
  "ref": "$REF",
  "sha": "$SHA",
  "run_id": "$RUN_ID",
  "run_attempt": $RUN_ATTEMPT,
  "event": {
    "name": "$EVENT_NAME",
    "action": "$EVENT_ACTION",
    "base_ref": "$BASE_REF",
    "head_ref": "$HEAD_REF"
  },
  "runner": {
    "name": "$RUNNER_NAME",
    "os": "$RUNNER_OS",
    "arch": "$RUNNER_ARCH",
    "labels": "$RUNNER_LABELS"
  },
  "system": {
    "cores": $CORES,
    "mem_total_mb": $MEM_TOTAL_MB,
    "disk_avail_mb": $DISK_AVAIL_MB
  },
  "workspace": "$WORKSPACE"
}
JSON
)

echo ""
echo "📦 Test payload:"
if command -v jq >/dev/null 2>&1; then
    echo "$payload" | jq .
else
    echo "$payload"
fi

echo ""
echo "🚀 Sending test request..."

# Build headers
headers=(-H "Content-Type: application/json")
if [[ -n "$API_KEY" ]]; then
    headers+=(-H "Authorization: Bearer $API_KEY")
fi

# Send request
response=$(curl -sS -X POST "$API_URL" "${headers[@]}" -d "$payload" \
    -w "\n%{http_code}\n%{time_total}" 2>/dev/null || echo -e "\n000\n0")

# Parse response
body=$(echo "$response" | head -n -2)
code=$(echo "$response" | tail -n 2 | head -n 1)
time_total=$(echo "$response" | tail -n 1)

echo ""
if [[ "$code" -ge 200 && "$code" -lt 300 ]]; then
    echo "✅ Success! HTTP $code in ${time_total}s"
    if [[ -n "$body" ]]; then
        echo "📥 Response:"
        if command -v jq >/dev/null 2>&1; then
            echo "$body" | jq . 2>/dev/null || echo "$body"
        else
            echo "$body"
        fi
    fi
else
    echo "❌ Failed! HTTP $code"
    if [[ -n "$body" ]]; then
        echo "📥 Response: $body"
    fi
    exit 1
fi

echo ""
echo "🎉 Test completed successfully!"
echo "   Your EcoStack metrics action is properly configured."
echo ""
echo "💡 Next steps:"
echo "   1. Add the action to your GitHub workflow"
echo "   2. Set up the required secrets"
echo "   3. Test with an actual workflow run"
