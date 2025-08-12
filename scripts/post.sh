#!/usr/bin/env bash
set -euo pipefail

# Log function for consistent output
log() {
    echo "[EcoStack] $1" >&2
}

log "🚀 Starting EcoStack metrics collection..."

# Capture start time for duration calculation
START_TIME=$(date +%s)
START_ISO=$(date -Iseconds 2>/dev/null || python - <<'PY'
import datetime;print(datetime.datetime.utcnow().replace(microsecond=0).isoformat()+"Z")
PY
)

# Initialize resource monitoring variables
CPU_USAGE=0; CPU_TIME=0; MEM_USAGE=0; MEM_PEAK=0; DISK_IO=0

# Optional system stats (Linux)
CORES=0; MEM_TOTAL_MB=0; DISK_AVAIL_MB=0
if [[ "${INCLUDE_SYSTEM:-true}" == "true" ]]; then
  log "📊 Collecting system statistics..."
  
  # CPU information
  CORES="$(getconf _NPROCESSORS_ONLN 2>/dev/null || nproc 2>/dev/null || echo 0)"
  
  # Memory information
  if [[ -r /proc/meminfo ]]; then
    MEM_TOTAL_MB="$(awk '/MemTotal/ {print int($2/1024)}' /proc/meminfo 2>/dev/null || echo 0)"
    MEM_AVAILABLE_MB="$(awk '/MemAvailable/ {print int($2/1024)}' /proc/meminfo 2>/dev/null || echo 0)"
    if [[ $MEM_TOTAL_MB -gt 0 ]]; then
      MEM_USAGE=$(( (MEM_TOTAL_MB - MEM_AVAILABLE_MB) * 100 / MEM_TOTAL_MB ))
    else
      MEM_USAGE=0
    fi
  else
    MEM_AVAILABLE_MB=0
  fi
  
  # Disk information
  DISK_AVAIL_MB="$(df -Pm / 2>/dev/null | tail -1 | awk '{print $4}' 2>/dev/null || echo 0)"
  
  # CPU usage monitoring (if available)
  if command -v top >/dev/null 2>&1; then
    CPU_USAGE=$(top -bn1 2>/dev/null | grep "Cpu(s)" | awk '{print $2}' | cut -d'%' -f1 | cut -d'.' -f1 || echo 0)
  fi
  
  # Process CPU time
  if [[ -r /proc/$$/stat ]]; then
    CPU_TIME_RAW=$(awk '{print $14+$15}' /proc/$$/stat 2>/dev/null || echo 0)
    CPU_TIME=$((CPU_TIME_RAW / 100))  # Convert to seconds (integer)
  fi
  
  # Memory peak usage
  if [[ -r /proc/$$/status ]]; then
    MEM_PEAK=$(cat /proc/$$/status 2>/dev/null | grep VmPeak | awk '{print $2}' || echo 0)
    MEM_PEAK=$((MEM_PEAK / 1024))  # Convert to MB
  fi
  
  # Disk I/O (if available)
  if [[ -r /proc/$$/io ]]; then
    DISK_IO=$(cat /proc/$$/io 2>/dev/null | awk '/^rchar:/ {print $2}' || echo 0)
  fi
  
  log "✅ System stats collected:"
  log "   • CPU: $CORES cores"
  log "   • Memory: ${MEM_TOTAL_MB}MB total (${MEM_USAGE}% used)"
  log "   • Disk: ${DISK_AVAIL_MB}MB available"
  log "   • Peak Memory: ${MEM_PEAK}MB"
  log "   • Disk I/O: ${DISK_IO} bytes"
else
  log "⏭️  Skipping system statistics collection"
fi

# Calculate carbon footprint estimate
CARBON_FOOTPRINT=0
ENERGY_CONSUMPTION=0
TOTAL_POWER_W=0
ENERGY_MIX="unknown"
ENERGY_MIX_FACTOR=0
RUNNER_TYPE="unknown"

if [[ "${INCLUDE_SYSTEM:-true}" == "true" ]]; then
  log "🌱 Calculating carbon footprint estimate..."
  
  # Determine runner type and energy efficiency
  if [[ "$RUNNER_NAME" == *"github-hosted"* ]] || [[ "$RUNNER_NAME" == *"ubuntu-latest"* ]] || [[ "$RUNNER_NAME" == *"windows-latest"* ]] || [[ "$RUNNER_NAME" == *"macos-latest"* ]]; then
    RUNNER_TYPE="github-hosted"
    ENERGY_MIX="renewable"  # GitHub's claim
    ENERGY_MIX_FACTOR=1   # Lower carbon factor for renewable energy (multiply by 0.1 later)
    BASE_POWER_W=50         # Base power consumption in watts
  else
    RUNNER_TYPE="self-hosted"
    ENERGY_MIX="grid"
    ENERGY_MIX_FACTOR=5   # Higher carbon factor for grid energy (multiply by 0.1 later)
    BASE_POWER_W=100        # Higher base power for self-hosted
  fi
  
  # Calculate energy consumption (simplified model)
  # Energy = (CPU Power + Memory Power + Base Power) × Duration × Utilization
  CPU_POWER_W=$((CORES * 10))  # Estimate 10W per core
  MEM_POWER_W=$((MEM_TOTAL_MB / 1024 * 2))  # Estimate 2W per GB
  
  # Calculate total power consumption
  TOTAL_POWER_W=$((CPU_POWER_W + MEM_POWER_W + BASE_POWER_W))
  
  # Estimate energy consumption (this will be refined when we have actual duration)
  # For now, we'll use a placeholder that will be updated with actual duration
  ESTIMATED_DURATION=300  # 5 minutes placeholder
  ENERGY_CONSUMPTION=$((TOTAL_POWER_W * ESTIMATED_DURATION / 3600))  # Wh
  
  # Calculate carbon footprint (gCO2e)
  # Carbon = Energy × Energy Mix Factor × Carbon Intensity
  CARBON_INTENSITY=400  # gCO2e/kWh (typical data center)
  CARBON_FOOTPRINT=$((ENERGY_CONSUMPTION * ENERGY_MIX_FACTOR * CARBON_INTENSITY / 10000))  # Divide by 10000 to account for 0.1 factor
  
  log "⚡ Power consumption: ${TOTAL_POWER_W}W total"
  log "   • CPU: ${CPU_POWER_W}W"
  log "   • Memory: ${MEM_POWER_W}W"
  log "   • Base: ${BASE_POWER_W}W"
  log "   • Energy mix: $ENERGY_MIX"
fi

# Capture end time and calculate duration
END_TIME=$(date +%s)
END_ISO=$(date -Iseconds 2>/dev/null || python - <<'PY'
import datetime;print(datetime.datetime.utcnow().replace(microsecond=0).isoformat()+"Z")
PY
)

# Calculate actual duration
DURATION_SECONDS=$((END_TIME - START_TIME))
DURATION_MINUTES=$((DURATION_SECONDS / 60))

log "⏱️  Pipeline completed in ${DURATION_SECONDS}s (${DURATION_MINUTES}m)"

# Recalculate carbon footprint with actual duration
ACTUAL_ENERGY_CONSUMPTION=0
ACTUAL_CARBON_FOOTPRINT=0

if [[ "${INCLUDE_SYSTEM:-true}" == "true" ]]; then
  ACTUAL_ENERGY_CONSUMPTION=$((TOTAL_POWER_W * DURATION_SECONDS / 3600))
  ACTUAL_CARBON_FOOTPRINT=$((ACTUAL_ENERGY_CONSUMPTION * ENERGY_MIX_FACTOR * 400 / 10000))  # 400 gCO2e/kWh, divide by 10000 for 0.1 factor
  
  log "🌍 Final carbon footprint: ${ACTUAL_CARBON_FOOTPRINT}g CO2e"
  log "   • Energy consumed: ${ACTUAL_ENERGY_CONSUMPTION}Wh"
  log "   • Runner type: $RUNNER_TYPE"
  log "   • Energy mix: $ENERGY_MIX"
fi

# Build enhanced payload with carbon footprint data
payload=$(cat <<JSON
{
  "kind": "action_probe",
  "ts": "$END_ISO",
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
    "labels": "$RUNNER_LABELS",
    "type": "$RUNNER_TYPE"
  },
  "system": {
    "cores": $CORES,
    "mem_total_mb": $MEM_TOTAL_MB,
    "mem_available_mb": $MEM_AVAILABLE_MB,
    "mem_usage_percent": $MEM_USAGE,
    "mem_peak_mb": $MEM_PEAK,
    "disk_avail_mb": $DISK_AVAIL_MB,
    "disk_io_bytes": $DISK_IO
  },
  "performance": {
    "start_time": "$START_ISO",
    "end_time": "$END_ISO",
    "duration_seconds": $DURATION_SECONDS,
    "duration_minutes": $DURATION_MINUTES,
    "cpu_usage_percent": $CPU_USAGE,
    "cpu_time_seconds": $CPU_TIME
  },
  "carbon_footprint": {
    "energy_consumption_wh": $ACTUAL_ENERGY_CONSUMPTION,
    "carbon_emissions_gco2e": $ACTUAL_CARBON_FOOTPRINT,
    "energy_mix": "$ENERGY_MIX",
    "energy_mix_factor": $ENERGY_MIX_FACTOR,
    "total_power_watts": $TOTAL_POWER_W,
    "runner_efficiency": "$RUNNER_TYPE"
  },
  "workspace": "$WORKSPACE"
}
JSON
)

log "📡 Sending metrics to EcoStack API..."
log "🔐 Authentication: Repository-based ($REPO)"

# Build headers (no authentication needed)
hdrs=(-H "Content-Type: application/json")

# Send metrics with retry logic
max_retries=3
retry_count=0

while [[ $retry_count -lt $max_retries ]]; do
  if [[ $retry_count -gt 0 ]]; then
    log "🔄 Retry attempt $retry_count of $max_retries..."
    sleep $((retry_count * 2))  # Exponential backoff
  fi
  
  response=$(curl -sS -X POST "$METRICS_API" "${hdrs[@]}" -d "$payload" \
    -w "\n%{http_code}\n%{time_total}" 2>/dev/null || echo -e "\n000\n0")
  
  # Parse response
  body=$(echo "$response" | head -n -2)
  code=$(echo "$response" | tail -n 2 | head -n 1)
  time_total=$(echo "$response" | tail -n 1)
  
  if [[ "$code" -ge 200 && "$code" -lt 300 ]]; then
    log "✅ Metrics sent successfully!"
    log "   • HTTP Status: $code"
    log "   • Response Time: ${time_total}s"
    log "   • Carbon Footprint: ${ACTUAL_CARBON_FOOTPRINT}g CO2e"
    log "   • Pipeline Duration: ${DURATION_MINUTES}m"
    break
  else
    retry_count=$((retry_count + 1))
    log "❌ HTTP $code response: $body"
    
    if [[ $retry_count -eq $max_retries ]]; then
      log "💥 Failed to send metrics after $max_retries attempts"
      log "   • Last error: HTTP $code"
      log "   • Check your API endpoint and network connectivity"
      # Don't fail the build by default - change to 'exit 1' if you want hard-fail
      exit 0
    fi
  fi
done

log "🎉 EcoStack metrics collection completed successfully!"