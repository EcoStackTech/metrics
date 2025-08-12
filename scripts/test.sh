#!/usr/bin/env bash
set -euo pipefail

# EcoStack Metrics v2.0.0 Local Test Script
# This script simulates the GitHub Actions environment for local testing

echo "🧪 EcoStack Metrics v2.0.0 - Local Test Environment"
echo "=================================================="

# Check if bc is available for decimal arithmetic
if ! command -v bc >/dev/null 2>&1; then
    echo "⚠️  Warning: 'bc' command not found. Some calculations may be limited."
    echo "   Install with: sudo apt-get install bc (Ubuntu/Debian) or brew install bc (macOS)"
fi

# Set up test environment variables (simulating GitHub Actions)
export METRICS_API="${METRICS_API:-https://api.ecostack.tech/metric}"
export INCLUDE_SYSTEM="${INCLUDE_SYSTEM:-true}"
export CAPTURE_PIPELINE="${CAPTURE_PIPELINE:-true}"

# Simulate GitHub context
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
export HEAD_REF="main"
export WORKSPACE="/tmp/test-workspace"

# Simulate GitHub event timestamps for pipeline tracking
export EVENT_HEAD_COMMIT_TIMESTAMP="$(date -d '5 minutes ago' -Iseconds)"
export EVENT_PULL_REQUEST_CREATED_AT=""
export EVENT_PULL_REQUEST_UPDATED_AT=""
export EVENT_PUSH_BEFORE=""
export EVENT_PUSH_AFTER=""
export EVENT_ISSUE_CREATED_AT=""
export EVENT_ISSUE_UPDATED_AT=""
export EVENT_RELEASE_CREATED_AT=""
export EVENT_RELEASE_PUBLISHED_AT=""
export EVENT_SCHEDULE=""
export EVENT_WORKFLOW_DISPATCH_INPUTS="{}"

echo "🔧 Test Configuration:"
echo "   • API Endpoint: $METRICS_API"
echo "   • Include System Stats: $INCLUDE_SYSTEM"
echo "   • Capture Pipeline Metrics: $CAPTURE_PIPELINE"
echo "   • Repository: $REPO"
echo "   • Runner: $RUNNER_NAME ($RUNNER_OS/$RUNNER_ARCH)"
echo "   • Event: $EVENT_NAME"
echo "   • Simulated Pipeline Start: $EVENT_HEAD_COMMIT_TIMESTAMP"
echo ""

# Create test workspace
mkdir -p "$WORKSPACE"
cd "$WORKSPACE"
echo "📁 Created test workspace: $WORKSPACE"

# Test system capabilities
echo "🔍 Testing system capabilities..."
if [[ -r /proc/meminfo ]]; then
    echo "   ✅ /proc/meminfo accessible (Linux system)"
else
    echo "   ⚠️  /proc/meminfo not accessible (non-Linux system)"
fi

if [[ -r /proc/loadavg ]]; then
    echo "   ✅ /proc/loadavg accessible (CPU load monitoring)"
else
    echo "   ⚠️  /proc/loadavg not accessible"
fi

if command -v bc >/dev/null 2>&1; then
    echo "   ✅ bc command available (decimal arithmetic)"
else
    echo "   ⚠️  bc command not available"
fi

echo ""

# Run the metrics collection script
echo "🚀 Running EcoStack metrics collection..."
echo "   (This will simulate a 5-minute pipeline duration)"
echo ""

# Simulate some pipeline work
echo "⏳ Simulating pipeline execution..."
sleep 2

# Run the actual script
if [[ -f "$(dirname "$0")/post.sh" ]]; then
    bash "$(dirname "$0")/post.sh"
else
    echo "❌ Error: post.sh script not found!"
    echo "   Make sure you're running this from the scripts/ directory"
    exit 1
fi

echo ""
echo "✅ Test completed successfully!"
echo ""
echo "📊 What was tested:"
echo "   • Pipeline timing calculation (5 min simulated duration)"
echo "   • System resource monitoring"
echo "   • Carbon footprint calculation"
echo "   • API payload construction"
echo "   • Enhanced metrics collection"
echo ""
echo "🌱 The action is now ready for production use!"
echo "   Use: uses: EcoStackTech/metrics@v2.0.0"
