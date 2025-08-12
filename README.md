# EcoStack Runner Metrics GitHub Action

A GitHub Action that collects and sends GitHub Actions runner metrics to your EcoStack API for monitoring, analytics, and **carbon footprint measurement**.

## Features

- **Runner Information**: Collects runner name, OS, architecture, and labels
- **Workflow Context**: Captures workflow, job, repository, and actor details
- **System Metrics**: Optional collection of CPU cores, memory, and disk space (Linux)
- **Pipeline Performance**: Measures execution duration, CPU usage, and memory consumption
- **Carbon Footprint**: Calculates environmental impact based on resource consumption and energy mix
- **Zero Configuration**: Works out of the box with EcoStack's hosted API
- **Organization-Based Access**: Authentication handled automatically based on repository
- **Non-blocking**: Metrics collection won't fail your workflow

## Usage

### Repository Level

Add this step to your GitHub Actions workflow:

```yaml
- name: Measure Carbon Footprint
  uses: EcoStackTech/metrics@v1
  with:
    include_system_stats: 'true'  # Optional, defaults to true
```

**That's it!** The action will automatically use EcoStack's hosted API and authenticate based on your repository.

### Organization Level

Install the action at the organization level to automatically collect metrics from all repositories:

1. Go to your organization's **Settings** → **Actions** → **General**
2. Under "Workflow permissions", select "Allow GitHub Actions to create and approve pull requests"
3. Add the action to your organization's workflow templates

## Inputs

| Input | Description | Required | Default |
|-------|-------------|----------|---------|
| `include_system_stats` | Collect CPU/RAM/disk metrics and carbon footprint | No | `true` |

## Authentication

**No API keys required!** EcoStack automatically authenticates requests based on:

- **Repository**: `github.repository` (e.g., "owner/repo")
- **Organization**: Extracted from repository name
- **Access Control**: Managed on EcoStack's side

This means companies can start using your action immediately without any setup or configuration.

## Environment Variables

The action automatically provides these environment variables to your API:

- `REPO`: Repository name (e.g., "owner/repo")
- `WORKFLOW`: Workflow name
- `JOB`: Job name
- `ACTOR`: User who triggered the workflow
- `REF`: Git reference (branch/tag)
- `SHA`: Commit SHA
- `RUN_ID`: Unique run identifier
- `RUN_ATTEMPT`: Run attempt number
- `RUNNER_NAME`: Runner name
- `RUNNER_OS`: Runner operating system
- `RUNNER_ARCH`: Runner architecture
- `RUNNER_LABELS`: Runner labels

## Carbon Footprint Measurement

### What Gets Measured

- **Pipeline Duration**: Start time, end time, and total execution time
- **Resource Consumption**: CPU usage, memory usage, disk I/O
- **Energy Estimation**: Power consumption based on hardware specifications
- **Carbon Impact**: CO2 emissions in grams based on energy mix and duration

### Carbon Footprint Calculation

The action calculates carbon footprint using this formula:

```
Carbon Footprint = (CPU Power + Memory Power + Base Power) × Duration × Energy Mix Factor × Carbon Intensity
```

- **GitHub-Hosted Runners**: Use renewable energy (lower carbon factor)
- **Self-Hosted Runners**: Use grid energy (higher carbon factor)
- **Hardware Efficiency**: Accounts for CPU cores, memory, and runner type

### Example Carbon Footprint Output

```json
{
  "carbon_footprint": {
    "energy_consumption_wh": 25,
    "carbon_emissions_gco2e": 5,
    "energy_mix": "renewable",
    "energy_mix_factor": 0.1,
    "total_power_watts": 75,
    "runner_efficiency": "github-hosted"
  }
}
```

## Example Workflows

### Basic Usage (Zero Configuration)

```yaml
name: Example Workflow
on: [push, pull_request]

jobs:
  example:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      
      - name: Measure Carbon Footprint
        uses: EcoStackTech/metrics@v1
        # No configuration needed - uses default EcoStack API
      
      - name: Your actual job steps
        run: echo "Hello World"
```

### With Conditional Metrics

```yaml
name: Conditional Metrics
on: [push, pull_request]

jobs:
  example:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      
      - name: Measure Carbon Footprint
        uses: EcoStackTech/metrics@v1
        if: github.event_name == 'push'  # Only on push events
        with:
          include_system_stats: 'false'  # Skip system stats and carbon footprint
      
      - name: Your actual job steps
        run: echo "Hello World"
```

### Organization Template

Create `.github/workflows/ecostack-metrics.yml` in your organization:

```yaml
name: EcoStack Metrics Collection
on:
  workflow_call:
    inputs:
      include_system_stats:
        required: false
        type: string
        default: "true"

jobs:
  collect-metrics:
    runs-on: ubuntu-latest
    steps:
      - name: Measure Carbon Footprint
        uses: EcoStackTech/metrics@v1
        with:
          include_system_stats: ${{ inputs.include_system_stats }}
```

Then in any repository, call it like:

```yaml
- name: Measure Carbon Footprint
  uses: ./.github/workflows/ecostack-metrics.yml
  # Uses default EcoStack API automatically
```

## API Payload Format

The action sends a comprehensive JSON payload with carbon footprint data:

```json
{
  "kind": "action_probe",
  "ts": "2024-01-15T10:30:00Z",
  "repo": "owner/repo",
  "workflow": "CI",
  "job": "build",
  "actor": "username",
  "ref": "refs/heads/main",
  "sha": "abc123...",
  "run_id": "1234567890",
  "run_attempt": 1,
  "runner": {
    "name": "ubuntu-latest",
    "os": "Linux",
    "arch": "X64",
    "labels": "ubuntu-latest,ubuntu-22.04,X64",
    "type": "github-hosted"
  },
  "system": {
    "cores": 2,
    "mem_total_mb": 7168,
    "mem_available_mb": 5120,
    "mem_usage_percent": 29,
    "mem_peak_mb": 1024,
    "disk_avail_mb": 14000,
    "disk_io_bytes": 1048576
  },
  "performance": {
    "start_time": "2024-01-15T10:25:00Z",
    "end_time": "2024-01-15T10:30:00Z",
    "duration_seconds": 300,
    "duration_minutes": 5,
    "cpu_usage_percent": 45,
    "cpu_time_seconds": 135.5
  },
  "carbon_footprint": {
    "energy_consumption_wh": 25,
    "carbon_emissions_gco2e": 5,
    "energy_mix": "renewable",
    "energy_mix_factor": 0.1,
    "total_power_watts": 75,
    "runner_efficiency": "github-hosted"
  }
}
```

## Security

- **No API keys stored** - Authentication handled server-side
- **Repository-based access control** - Only authorized repos can send metrics
- **HTTPS only** - All communication encrypted
- **Non-blocking** - Failed API calls don't fail your workflow
- **Organization isolation** - Metrics are properly scoped

## Troubleshooting

### Common Issues

1. **Access denied**: Repository not authorized in EcoStack
2. **API endpoint not reachable**: Check your network connectivity
3. **System stats not collected**: System stats are Linux-only and require `/proc` access
4. **Carbon footprint not calculated**: Ensure `include_system_stats` is set to `true`

### Debug Mode

To see what data is being sent, you can temporarily modify the script to log the payload:

```bash
# In scripts/post.sh, add this line before the curl command:
echo "Sending payload: $payload" >&2
```

## Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Test thoroughly
5. Submit a pull request

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## Support

For support and questions:
- Open an issue on GitHub
- Contact EcoStack support
- Check the [documentation](https://docs.ecostack.com)
