#!/usr/bin/env bash
set -euo pipefail

# Enhanced logging function with timestamps and levels
log() {
    local level="${2:-INFO}"
    local timestamp=$(date '+%H:%M:%S')
    case "$level" in
        "DEBUG") echo "[EcoStack] 🔍 [$timestamp] $1" >&2 ;;
        "INFO")  echo "[EcoStack] ℹ️  [$timestamp] $1" >&2 ;;
        "WARN")  echo "[EcoStack] ⚠️  [$timestamp] $1" >&2 ;;
        "ERROR") echo "[EcoStack] ❌ [$timestamp] $1" >&2 ;;
        "SUCCESS") echo "[EcoStack] ✅ [$timestamp] $1" >&2 ;;
        *)       echo "[EcoStack] ℹ️  [$timestamp] $1" >&2 ;;
    esac
}

log "🚀 Starting EcoStack enhanced metrics collection..." "INFO"

# =============================================================================
# PIPELINE TIMING CALCULATION
# =============================================================================

# Try to determine actual pipeline start time from various GitHub event sources
PIPELINE_START_TIME=0
PIPELINE_START_ISO=""
ACTUAL_PIPELINE_DURATION=0

log "⏱️  Determining pipeline start time..." "DEBUG"

# Priority order for pipeline start time:
# 1. Commit timestamp (most accurate for push events)
# 2. Pull request creation time
# 3. Issue creation time
# 4. Release creation time
# 5. Current time as fallback

if [[ -n "${EVENT_HEAD_COMMIT_TIMESTAMP:-}" ]]; then
    PIPELINE_START_TIME=$(date -d "$EVENT_HEAD_COMMIT_TIMESTAMP" +%s 2>/dev/null || echo 0)
    PIPELINE_START_ISO="$EVENT_HEAD_COMMIT_TIMESTAMP"
    log "📅 Using commit timestamp: $EVENT_HEAD_COMMIT_TIMESTAMP" "DEBUG"
elif [[ -n "${EVENT_PULL_REQUEST_CREATED_AT:-}" ]]; then
    PIPELINE_START_TIME=$(date -d "$EVENT_PULL_REQUEST_CREATED_AT" +%s 2>/dev/null || echo 0)
    PIPELINE_START_ISO="$EVENT_PULL_REQUEST_CREATED_AT"
    log "📅 Using PR creation time: $EVENT_PULL_REQUEST_CREATED_AT" "DEBUG"
elif [[ -n "${EVENT_ISSUE_CREATED_AT:-}" ]]; then
    PIPELINE_START_TIME=$(date -d "$EVENT_ISSUE_CREATED_AT" +%s 2>/dev/null || echo 0)
    PIPELINE_START_ISO="$EVENT_ISSUE_CREATED_AT"
    log "📅 Using issue creation time: $EVENT_ISSUE_CREATED_AT" "DEBUG"
elif [[ -n "${EVENT_RELEASE_CREATED_AT:-}" ]]; then
    PIPELINE_START_TIME=$(date -d "$EVENT_RELEASE_CREATED_AT" +%s 2>/dev/null || echo 0)
    PIPELINE_START_ISO="$EVENT_RELEASE_CREATED_AT"
    log "📅 Using release creation time: $EVENT_RELEASE_CREATED_AT" "DEBUG"
else
    # Fallback: use current time minus estimated job duration
    PIPELINE_START_TIME=$(date +%s)
    PIPELINE_START_ISO=$(date -Iseconds 2>/dev/null || python - <<'PY'
import datetime;print(datetime.datetime.utcnow().replace(microsecond=0).isoformat()+"Z")
PY
)
    log "⚠️  No event timestamp found, using current time as fallback" "WARN"
fi

# Capture action start time
ACTION_START_TIME=$(date +%s)
ACTION_START_ISO=$(date -Iseconds 2>/dev/null || python - <<'PY'
import datetime;print(datetime.datetime.utcnow().replace(microsecond=0).isoformat()+"Z")
PY
)

# Calculate pipeline duration if we have a valid start time
if [[ $PIPELINE_START_TIME -gt 0 ]]; then
    ACTUAL_PIPELINE_DURATION=$((ACTION_START_TIME - PIPELINE_START_TIME))
    log "📊 Pipeline has been running for ${ACTUAL_PIPELINE_DURATION}s" "INFO"
else
    ACTUAL_PIPELINE_DURATION=0
    log "⚠️  Could not determine pipeline start time" "WARN"
fi

# =============================================================================
# ENHANCED SYSTEM RESOURCE MONITORING
# =============================================================================

# Initialize resource monitoring variables
CPU_USAGE=0; CPU_TIME=0; MEM_USAGE=0; MEM_PEAK=0; DISK_IO=0
CORES=0; MEM_TOTAL_MB=0; MEM_AVAILABLE_MB=0; DISK_AVAIL_MB=0
CPU_LOAD_1MIN=0; CPU_LOAD_5MIN=0; CPU_LOAD_15MIN=0

# Initialize additional system variables
MEM_BUFFERED_MB=0; MEM_CACHED_MB=0; DISK_TOTAL_MB=0; DISK_USED_MB=0
DISK_IO_READ=0; DISK_IO_WRITE=0; NET_IO_RX=0; NET_IO_TX=0

# Initialize GitHub context variables (with defaults for local testing)
REPO="${REPO:-test-org/test-repo}"
RUN_ID="${RUN_ID:-1234567890}"
RUN_ATTEMPT="${RUN_ATTEMPT:-1}"
WORKFLOW="${WORKFLOW:-Test Workflow}"
JOB="${JOB:-test-job}"
ACTOR="${ACTOR:-test-user}"
REF="${REF:-refs/heads/main}"
SHA="${SHA:-abc123def456789}"
RUNNER_NAME="${RUNNER_NAME:-ubuntu-latest}"
RUNNER_OS="${RUNNER_OS:-Linux}"
RUNNER_ARCH="${RUNNER_ARCH:-X64}"
RUNNER_LABELS="${RUNNER_LABELS:-ubuntu-latest,ubuntu-22.04,X64}"
EVENT_NAME="${EVENT_NAME:-push}"
EVENT_ACTION="${EVENT_ACTION:-}"
BASE_REF="${BASE_REF:-}"
HEAD_REF="${HEAD_REF:-main}"
WORKSPACE="${WORKSPACE:-/tmp/test-workspace}"

# Initialize event timestamp variables (with defaults for local testing)
EVENT_HEAD_COMMIT_TIMESTAMP="${EVENT_HEAD_COMMIT_TIMESTAMP:-}"
EVENT_PULL_REQUEST_CREATED_AT="${EVENT_PULL_REQUEST_CREATED_AT:-}"
EVENT_PULL_REQUEST_UPDATED_AT="${EVENT_PULL_REQUEST_UPDATED_AT:-}"
EVENT_PUSH_BEFORE="${EVENT_PUSH_BEFORE:-}"
EVENT_PUSH_AFTER="${EVENT_PUSH_AFTER:-}"
EVENT_ISSUE_CREATED_AT="${EVENT_ISSUE_CREATED_AT:-}"
EVENT_ISSUE_UPDATED_AT="${EVENT_ISSUE_UPDATED_AT:-}"
EVENT_RELEASE_CREATED_AT="${EVENT_RELEASE_CREATED_AT:-}"
EVENT_RELEASE_PUBLISHED_AT="${EVENT_RELEASE_PUBLISHED_AT:-}"
EVENT_SCHEDULE="${EVENT_SCHEDULE:-}"
EVENT_WORKFLOW_DISPATCH_INPUTS="${EVENT_WORKFLOW_DISPATCH_INPUTS:-{}}"

# Initialize action configuration variables (with defaults for local testing)
METRICS_API="${METRICS_API:-https://api.ecostack.tech/metric}"
INCLUDE_SYSTEM="${INCLUDE_SYSTEM:-true}"
CAPTURE_PIPELINE="${CAPTURE_PIPELINE:-true}"

if [[ "${INCLUDE_SYSTEM:-true}" == "true" ]]; then
    log "📊 Collecting enhanced system statistics..." "INFO"
    
    # Enhanced CPU information
    CORES="$(getconf _NPROCESSORS_ONLN 2>/dev/null || nproc 2>/dev/null || echo 0)"
    
    # CPU load averages (more accurate than single top command)
    if [[ -r /proc/loadavg ]]; then
        read -r CPU_LOAD_1MIN CPU_LOAD_5MIN CPU_LOAD_15MIN rest < /proc/loadavg 2>/dev/null || true
        # Convert load average to percentage (load per core)
        if [[ $CORES -gt 0 ]]; then
            CPU_USAGE=$(echo "scale=0; $CPU_LOAD_1MIN * 100 / $CORES" | bc 2>/dev/null || echo 0)
            CPU_USAGE=${CPU_USAGE%.*}  # Remove decimal part
        fi
    fi
    
    # Enhanced memory information
    if [[ -r /proc/meminfo ]]; then
        MEM_TOTAL_MB="$(awk '/MemTotal/ {print int($2/1024)}' /proc/meminfo 2>/dev/null || echo 0)"
        MEM_AVAILABLE_MB="$(awk '/MemAvailable/ {print int($2/1024)}' /proc/meminfo 2>/dev/null || echo 0)"
        MEM_BUFFERED_MB="$(awk '/Buffers/ {print int($2/1024)}' /proc/meminfo 2>/dev/null || echo 0)"
        MEM_CACHED_MB="$(awk '/^Cached:/ {print int($2/1024)}' /proc/meminfo 2>/dev/null || echo 0)"
        
        if [[ $MEM_TOTAL_MB -gt 0 ]]; then
            MEM_USAGE=$(( (MEM_TOTAL_MB - MEM_AVAILABLE_MB) * 100 / MEM_TOTAL_MB ))
        else
            MEM_USAGE=0
        fi
    else
        MEM_AVAILABLE_MB=0; MEM_BUFFERED_MB=0; MEM_CACHED_MB=0
    fi
    
    # Enhanced disk information
    DISK_AVAIL_MB="$(df -Pm / 2>/dev/null | tail -1 | awk '{print $4}' 2>/dev/null || echo 0)"
    DISK_TOTAL_MB="$(df -Pm / 2>/dev/null | tail -1 | awk '{print $2}' 2>/dev/null || echo 0)"
    DISK_USED_MB="$(df -Pm / 2>/dev/null | tail -1 | awk '{print $3}' 2>/dev/null || echo 0)"
    
    # Enhanced process monitoring
    if [[ -r /proc/$$/stat ]]; then
        CPU_TIME_RAW=$(awk '{print $14+$15}' /proc/$$/stat 2>/dev/null || echo 0)
        CPU_TIME=$((CPU_TIME_RAW / 100))  # Convert to seconds (integer)
    fi
    
    # Enhanced memory peak usage
    if [[ -r /proc/$$/status ]]; then
        MEM_PEAK=$(cat /proc/$$/status 2>/dev/null | grep VmPeak | awk '{print $2}' || echo 0)
        MEM_PEAK=$((MEM_PEAK / 1024))  # Convert to MB
    fi
    
    # Enhanced disk I/O monitoring
    if [[ -r /proc/$$/io ]]; then
        DISK_IO_READ=$(cat /proc/$$/io 2>/dev/null | awk '/^rchar:/ {print $2}' || echo 0)
        DISK_IO_WRITE=$(cat /proc/$$/io 2>/dev/null | awk '/^wchar:/ {print $2}' || echo 0)
        DISK_IO=$((DISK_IO_READ + DISK_IO_WRITE))
    fi
    
    # Network I/O if available
    NET_IO_RX=0; NET_IO_TX=0
    if [[ -r /proc/net/dev ]]; then
        # This is a simplified approach - in practice you'd want to track over time
        NET_IO_RX=$(awk '/eth0|ens|eno/ {print $2}' /proc/net/dev 2>/dev/null | head -1 || echo 0)
        NET_IO_TX=$(awk '/eth0|ens|eno/ {print $10}' /proc/net/dev 2>/dev/null | head -1 || echo 0)
    fi
    
    log "✅ Enhanced system stats collected:" "SUCCESS"
    log "   • CPU: $CORES cores (${CPU_USAGE}% load)" "INFO"
    log "   • Load averages: ${CPU_LOAD_1MIN}, ${CPU_LOAD_5MIN}, ${CPU_LOAD_15MIN}" "INFO"
    log "   • Memory: ${MEM_TOTAL_MB}MB total (${MEM_USAGE}% used)" "INFO"
    log "   • Memory breakdown: ${MEM_BUFFERED_MB}MB buffered, ${MEM_CACHED_MB}MB cached" "INFO"
    log "   • Disk: ${DISK_USED_MB}MB used, ${DISK_AVAIL_MB}MB available (${DISK_TOTAL_MB}MB total)" "INFO"
    log "   • Peak Memory: ${MEM_PEAK}MB" "INFO"
    log "   • Disk I/O: ${DISK_IO} bytes (${DISK_IO_READ} read, ${DISK_IO_WRITE} write)" "INFO"
    log "   • Network I/O: ${NET_IO_RX} bytes received, ${NET_IO_TX} bytes sent" "INFO"
else
    log "⏭️  Skipping system statistics collection" "INFO"
fi

# =============================================================================
# ENHANCED CARBON FOOTPRINT CALCULATION
# =============================================================================

# Initialize carbon footprint variables
CARBON_FOOTPRINT=0; ENERGY_CONSUMPTION=0; TOTAL_POWER_W=0
ENERGY_MIX="unknown"; ENERGY_MIX_FACTOR=0; RUNNER_TYPE="unknown"
CARBON_INTENSITY=0; RENEWABLE_PERCENTAGE=0

if [[ "${INCLUDE_SYSTEM:-true}" == "true" ]]; then
    log "🌱 Calculating enhanced carbon footprint..." "INFO"
    
    # Enhanced runner type detection and energy efficiency
    if [[ "$RUNNER_NAME" == *"github-hosted"* ]] || [[ "$RUNNER_NAME" == *"ubuntu-latest"* ]] || [[ "$RUNNER_NAME" == *"windows-latest"* ]] || [[ "$RUNNER_NAME" == *"macos-latest"* ]]; then
        RUNNER_TYPE="github-hosted"
        ENERGY_MIX="renewable"
        ENERGY_MIX_FACTOR=10  # 0.1 factor for renewable energy
        BASE_POWER_W=50
        RENEWABLE_PERCENTAGE=100
        log "🌿 Detected GitHub-hosted runner (100% renewable energy)" "INFO"
    elif [[ "$RUNNER_NAME" == *"self-hosted"* ]] || [[ "$RUNNER_NAME" == *"custom"* ]]; then
        RUNNER_TYPE="self-hosted"
        ENERGY_MIX="grid"
        ENERGY_MIX_FACTOR=50  # 0.5 factor for grid energy
        BASE_POWER_W=100
        RENEWABLE_PERCENTAGE=20  # Assume 20% renewable for self-hosted
        log "🏭 Detected self-hosted runner (grid energy mix)" "INFO"
    else
        RUNNER_TYPE="unknown"
        ENERGY_MIX="mixed"
        ENERGY_MIX_FACTOR=30  # 0.3 factor for mixed energy
        BASE_POWER_W=75
        RENEWABLE_PERCENTAGE=50
        log "❓ Unknown runner type, using conservative estimates" "WARN"
    fi
    
    # Enhanced power consumption calculation
    CPU_POWER_W=$((CORES * 12))  # 12W per core (more realistic)
    MEM_POWER_W=$((MEM_TOTAL_MB / 1024 * 3))  # 3W per GB (more realistic)
    
    # Dynamic power based on utilization
    CPU_UTILIZATION_FACTOR=$((CPU_USAGE * 100 / 100))  # Scale 0-100 to 0-100
    MEM_UTILIZATION_FACTOR=$((MEM_USAGE * 100 / 100))  # Scale 0-100 to 0-100
    
    # Calculate total power consumption with utilization
    TOTAL_POWER_W=$((CPU_POWER_W + MEM_POWER_W + BASE_POWER_W))
    UTILIZED_POWER_W=$((TOTAL_POWER_W * (CPU_UTILIZATION_FACTOR + MEM_UTILIZATION_FACTOR) / 200))  # Average of CPU and MEM utilization
    
    # Use actual pipeline duration if available, otherwise use action duration
    DURATION_FOR_CALCULATION=${ACTUAL_PIPELINE_DURATION:-0}
    if [[ $DURATION_FOR_CALCULATION -eq 0 ]]; then
        DURATION_FOR_CALCULATION=300  # 5 minutes fallback
        log "⚠️  Using fallback duration for energy calculation" "WARN"
    fi
    
    # Enhanced energy consumption calculation
    ENERGY_CONSUMPTION=$((UTILIZED_POWER_W * DURATION_FOR_CALCULATION / 3600))  # Wh
    
    # Enhanced carbon intensity based on energy mix
    case "$ENERGY_MIX" in
        "renewable")
            CARBON_INTENSITY=50   # gCO2e/kWh (very low for renewable)
            ;;
        "grid")
            CARBON_INTENSITY=400  # gCO2e/kWh (typical grid mix)
            ;;
        "mixed")
            CARBON_INTENSITY=200  # gCO2e/kWh (mixed energy)
            ;;
        *)
            CARBON_INTENSITY=300  # gCO2e/kWh (default)
            ;;
    esac
    
    # Enhanced carbon footprint calculation
    CARBON_FOOTPRINT=$((ENERGY_CONSUMPTION * ENERGY_MIX_FACTOR * CARBON_INTENSITY / 1000))  # gCO2e
    
    log "⚡ Enhanced power analysis:" "INFO"
    log "   • Total power: ${TOTAL_POWER_W}W" "INFO"
    log "   • Utilized power: ${UTILIZED_POWER_W}W (${CPU_USAGE}% CPU, ${MEM_USAGE}% MEM)" "INFO"
    log "   • CPU power: ${CPU_POWER_W}W" "INFO"
    log "   • Memory power: ${MEM_POWER_W}W" "INFO"
    log "   • Base power: ${BASE_POWER_W}W" "INFO"
    log "   • Energy mix: $ENERGY_MIX (${RENEWABLE_PERCENTAGE}% renewable)" "INFO"
    log "   • Carbon intensity: ${CARBON_INTENSITY}g CO2e/kWh" "INFO"
fi

# =============================================================================
# FINAL TIMING CALCULATION
# =============================================================================

# Capture action end time
ACTION_END_TIME=$(date +%s)
ACTION_END_ISO=$(date -Iseconds 2>/dev/null || python - <<'PY'
import datetime;print(datetime.datetime.utcnow().replace(microsecond=0).isoformat()+"Z")
PY
)

# Calculate action duration
ACTION_DURATION_SECONDS=$((ACTION_END_TIME - ACTION_START_TIME))
ACTION_DURATION_MINUTES=$((ACTION_DURATION_SECONDS / 60))

# Calculate total pipeline duration
TOTAL_PIPELINE_DURATION=$((ACTION_END_TIME - PIPELINE_START_TIME))
TOTAL_PIPELINE_MINUTES=$((TOTAL_PIPELINE_DURATION / 60))

log "⏱️  Timing summary:" "INFO"
log "   • Action execution: ${ACTION_DURATION_SECONDS}s (${ACTION_DURATION_MINUTES}m)" "INFO"
if [[ $ACTUAL_PIPELINE_DURATION -gt 0 ]]; then
    log "   • Total pipeline: ${TOTAL_PIPELINE_DURATION}s (${TOTAL_PIPELINE_MINUTES}m)" "INFO"
    log "   • Pipeline efficiency: ${ACTION_DURATION_SECONDS}s action time for ${TOTAL_PIPELINE_DURATION}s total" "INFO"
else
    log "   • Total pipeline: Could not determine (using action duration)" "WARN"
fi

# =============================================================================
# FINAL CARBON FOOTPRINT WITH REAL DATA
# =============================================================================

# Recalculate carbon footprint with actual pipeline duration
FINAL_ENERGY_CONSUMPTION=0
FINAL_CARBON_FOOTPRINT=0

if [[ "${INCLUDE_SYSTEM:-true}" == "true" ]]; then
    # Use the best available duration
    BEST_DURATION=${ACTUAL_PIPELINE_DURATION:-$ACTION_DURATION_SECONDS}
    
    FINAL_ENERGY_CONSUMPTION=$((UTILIZED_POWER_W * BEST_DURATION / 3600))
    FINAL_CARBON_FOOTPRINT=$((FINAL_ENERGY_CONSUMPTION * ENERGY_MIX_FACTOR * CARBON_INTENSITY / 1000))
    
    log "🌍 Final carbon footprint calculation:" "SUCCESS"
    log "   • Energy consumed: ${FINAL_ENERGY_CONSUMPTION}Wh" "INFO"
    log "   • Carbon emissions: ${FINAL_CARBON_FOOTPRINT}g CO2e" "INFO"
    log "   • Runner type: $RUNNER_TYPE" "INFO"
    log "   • Energy mix: $ENERGY_MIX (${RENEWABLE_PERCENTAGE}% renewable)" "INFO"
    log "   • Duration used: ${BEST_DURATION}s" "INFO"
    
    # Environmental impact context
    if [[ $FINAL_CARBON_FOOTPRINT -lt 100 ]]; then
        log "   🌱 Impact: Very low - equivalent to charging a phone for ~${FINAL_ENERGY_CONSUMPTION} minutes" "SUCCESS"
    elif [[ $FINAL_CARBON_FOOTPRINT -lt 500 ]]; then
        log "   🌱 Impact: Low - equivalent to using a laptop for ~${FINAL_ENERGY_CONSUMPTION} minutes" "SUCCESS"
    elif [[ $FINAL_CARBON_FOOTPRINT -lt 1000 ]]; then
        log "   🌱 Impact: Moderate - equivalent to running a desktop for ~${FINAL_ENERGY_CONSUMPTION} minutes" "INFO"
    else
        log "   🌱 Impact: High - consider optimizing your pipeline for efficiency" "WARN"
    fi
fi

# =============================================================================
# ENHANCED JSON PAYLOAD
# =============================================================================

# Build enhanced payload with comprehensive data
payload=$(cat <<JSON
{
  "kind": "enhanced_action_probe",
  "ts": "$ACTION_END_ISO",
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
    "head_ref": "$HEAD_REF",
    "head_commit_timestamp": "$EVENT_HEAD_COMMIT_TIMESTAMP",
    "pull_request_created_at": "$EVENT_PULL_REQUEST_CREATED_AT",
    "pull_request_updated_at": "$EVENT_PULL_REQUEST_UPDATED_AT",
    "push_before": "$EVENT_PUSH_BEFORE",
    "push_after": "$EVENT_PUSH_AFTER",
    "issue_created_at": "$EVENT_ISSUE_CREATED_AT",
    "issue_updated_at": "$EVENT_ISSUE_UPDATED_AT",
    "release_created_at": "$EVENT_RELEASE_CREATED_AT",
    "release_published_at": "$EVENT_RELEASE_PUBLISHED_AT",
    "schedule": "$EVENT_SCHEDULE",
    "workflow_dispatch_inputs": "$EVENT_WORKFLOW_DISPATCH_INPUTS"
  },
  "runner": {
    "name": "$RUNNER_NAME",
    "os": "$RUNNER_OS",
    "arch": "$RUNNER_ARCH",
    "labels": "$RUNNER_LABELS",
    "type": "$RUNNER_TYPE"
  },
  "system": {
    "cores": $CORES,
    "mem_total_mb": $MEM_TOTAL_MB,
    "mem_available_mb": $MEM_AVAILABLE_MB,
    "mem_usage_percent": $MEM_USAGE,
    "mem_peak_mb": $MEM_PEAK,
    "mem_buffered_mb": $MEM_BUFFERED_MB,
    "mem_cached_mb": $MEM_CACHED_MB,
    "disk_total_mb": $DISK_TOTAL_MB,
    "disk_used_mb": $DISK_USED_MB,
    "disk_avail_mb": $DISK_AVAIL_MB,
    "disk_io_bytes": $DISK_IO,
    "disk_io_read_bytes": $DISK_IO_READ,
    "disk_io_write_bytes": $DISK_IO_WRITE,
    "net_io_rx_bytes": $NET_IO_RX,
    "net_io_tx_bytes": $NET_IO_TX
  },
      "performance": {
      "pipeline_start_time": "$PIPELINE_START_ISO",
      "action_start_time": "$ACTION_START_ISO",
      "action_end_time": "$ACTION_END_ISO",
      "pipeline_duration_seconds": $TOTAL_PIPELINE_DURATION,
      "pipeline_duration_minutes": $TOTAL_PIPELINE_MINUTES,
      "action_duration_seconds": $ACTION_DURATION_SECONDS,
      "action_duration_minutes": $ACTION_DURATION_MINUTES,
      "cpu_usage_percent": $CPU_USAGE,
      "cpu_time_seconds": $CPU_TIME,
      "cpu_load_1min": $CPU_LOAD_1MIN,
      "cpu_load_5min": $CPU_LOAD_5MIN,
      "cpu_load_15min": $CPU_LOAD_15MIN
    },
  "carbon_footprint": {
    "energy_consumption_wh": $FINAL_ENERGY_CONSUMPTION,
    "carbon_emissions_gco2e": $FINAL_CARBON_FOOTPRINT,
    "energy_mix": "$ENERGY_MIX",
    "energy_mix_factor": $ENERGY_MIX_FACTOR,
    "renewable_percentage": $RENEWABLE_PERCENTAGE,
    "total_power_watts": $TOTAL_POWER_W,
    "utilized_power_watts": $UTILIZED_POWER_W,
    "cpu_power_watts": $CPU_POWER_W,
    "memory_power_watts": $MEM_POWER_W,
    "base_power_watts": $BASE_POWER_W,
    "runner_efficiency": "$RUNNER_TYPE",
    "carbon_intensity_gco2e_per_kwh": $CARBON_INTENSITY
  },
  "workspace": "$WORKSPACE",
  "metadata": {
    "version": "2.0.0",
    "enhanced_metrics": true,
    "pipeline_tracking": ${CAPTURE_PIPELINE:-true},
    "system_monitoring": ${INCLUDE_SYSTEM:-true}
  }
}
JSON
)

# =============================================================================
# API TRANSMISSION WITH ENHANCED ERROR HANDLING
# =============================================================================

log "📡 Sending enhanced metrics to EcoStack API..." "INFO"
log "🔐 Authentication: Repository-based ($REPO)" "INFO"

# Build headers
hdrs=(-H "Content-Type: application/json" -H "User-Agent: EcoStack-Metrics/2.0.0")

# Enhanced retry logic with exponential backoff
max_retries=5
retry_count=0
base_delay=2

while [[ $retry_count -lt $max_retries ]]; do
    if [[ $retry_count -gt 0 ]]; then
        delay=$((base_delay * (2 ** (retry_count - 1))))
        log "🔄 Retry attempt $retry_count of $max_retries (waiting ${delay}s)..." "WARN"
        sleep $delay
    fi
    
    # Enhanced curl with timeout and better error handling
    response=$(curl -sS -X POST "$METRICS_API" "${hdrs[@]}" -d "$payload" \
        -w "\n%{http_code}\n%{time_total}\n%{size_upload}\n%{speed_upload}" \
        --connect-timeout 10 --max-time 30 2>/dev/null || echo -e "\n000\n0\n0\n0")
    
    # Parse enhanced response (portable across different systems)
    response_lines=$(echo "$response" | wc -l)
    if [[ $response_lines -ge 4 ]]; then
        body=$(echo "$response" | head -n $((response_lines - 4)))
        code=$(echo "$response" | tail -n 4 | head -n 1)
        time_total=$(echo "$response" | tail -n 3 | head -n 1)
        size_upload=$(echo "$response" | tail -n 2 | head -n 1)
        speed_upload=$(echo "$response" | tail -n 1)
    else
        # Fallback for short responses
        body="$response"
        code="000"
        time_total="0"
        size_upload="0"
        speed_upload="0"
    fi
    
    if [[ "$code" -ge 200 && "$code" -lt 300 ]]; then
        log "✅ Enhanced metrics sent successfully!" "SUCCESS"
        log "   • HTTP Status: $code" "INFO"
        log "   • Response Time: ${time_total}s" "INFO"
        log "   • Payload Size: ${size_upload} bytes" "INFO"
        log "   • Upload Speed: ${speed_upload} bytes/s" "INFO"
        log "   • Carbon Footprint: ${FINAL_CARBON_FOOTPRINT}g CO2e" "INFO"
        log "   • Pipeline Duration: ${TOTAL_PIPELINE_MINUTES}m" "INFO"
        break
    else
        retry_count=$((retry_count + 1))
        log "❌ HTTP $code response: $body" "ERROR"
        
        if [[ $retry_count -eq $max_retries ]]; then
            log "💥 Failed to send metrics after $max_retries attempts" "ERROR"
            log "   • Last error: HTTP $code" "ERROR"
            log "   • Check your API endpoint and network connectivity" "ERROR"
            log "   • Metrics payload size: ${#payload} characters" "DEBUG"
            # Don't fail the build by default - change to 'exit 1' if you want hard-fail
            exit 0
        fi
    fi
done

# =============================================================================
# FINAL SUMMARY
# =============================================================================

log "🎉 EcoStack enhanced metrics collection completed successfully!" "SUCCESS"
log "📊 Summary:" "INFO"
log "   • Pipeline duration: ${TOTAL_PIPELINE_MINUTES}m" "INFO"
log "   • Action duration: ${ACTION_DURATION_MINUTES}m" "INFO"
log "   • Carbon footprint: ${FINAL_CARBON_FOOTPRINT}g CO2e" "INFO"
log "   • Energy consumed: ${FINAL_ENERGY_CONSUMPTION}Wh" "INFO"
log "   • Runner efficiency: $RUNNER_TYPE" "INFO"
log "   • Enhanced metrics: Enabled" "INFO"
log "   • Pipeline tracking: ${CAPTURE_PIPELINE:-true}" "INFO"

log "🌱 Thank you for using EcoStack to measure your environmental impact!" "SUCCESS"