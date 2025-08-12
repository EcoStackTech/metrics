# Quick Start Guide

Get up and running with EcoStack metrics in under 5 minutes!

## 🚀 Repository Level Setup

### 1. Add to Your Workflow

Add this step to any GitHub Actions workflow:

```yaml
- name: Measure Carbon Footprint
  uses: EcoStackTech/metrics@v1
  # No configuration needed - works out of the box!
```

### 2. That's It! 🎉

The action will automatically collect and send metrics to EcoStack's hosted API. Authentication is handled automatically based on your repository.

## 🌱 Carbon Footprint Measurement

Your action now measures the environmental impact of CI/CD pipelines:

- **Pipeline Duration**: Execution time from start to finish
- **Resource Usage**: CPU, memory, and disk consumption
- **Energy Consumption**: Power usage in watt-hours
- **Carbon Emissions**: CO2 impact in grams based on energy mix

### Example Output
```
Pipeline completed with carbon footprint: 5g CO2e
Duration: 5m, Energy: 25Wh, Runner: github-hosted (renewable)
```

## 🏢 Organization Level Setup

### 1. Create Template Workflow

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

### 2. Use in Repositories

In any repository, call it like:

```yaml
- name: Measure Carbon Footprint
  uses: ./.github/workflows/ecostack-metrics.yml
  # Uses default EcoStack API automatically
```

## 📊 What Gets Collected

- **Runner Info**: Name, OS, architecture, labels, type
- **Workflow Context**: Repository, workflow, job, actor
- **System Stats**: CPU cores, memory, disk (Linux)
- **Performance Metrics**: Duration, CPU usage, memory consumption
- **Carbon Footprint**: Energy consumption and CO2 emissions
- **Event Details**: Push, PR, workflow dispatch info

## 🔧 Configuration Options

| Input | Description | Default |
|-------|-------------|---------|
| `include_system_stats` | Collect system metrics and carbon footprint | `true` |

## 🔐 Authentication

**No API keys needed!** EcoStack automatically authenticates based on:
- Repository name (e.g., "owner/repo")
- Organization membership
- Access control managed on EcoStack's side

## 🧪 Test Your Setup

Run the test script locally:

```bash
./scripts/test.sh https://api.ecostack.tech/metric
```

## 📚 Need More Help?

- [Full Documentation](README.md)
- [Organization Setup Guide](docs/organization-setup.md)
- [Examples](examples/)
- [Open an Issue](https://github.com/EcoStackTech/metrics/issues)

## 🎯 Common Use Cases

- **CI/CD Monitoring**: Track runner usage across workflows
- **Cost Optimization**: Monitor resource utilization
- **Performance Analysis**: Identify bottlenecks in your CI pipeline
- **Carbon Footprint**: Measure environmental impact of pipelines
- **Compliance**: Audit workflow execution across repositories
- **Sustainability**: Track and reduce CI/CD carbon emissions

## 💡 Why Zero Configuration?

- **Instant Setup**: No API keys or configuration required
- **Hosted Solution**: EcoStack manages the infrastructure
- **Always Available**: 99.9% uptime SLA
- **Secure by Default**: Organization-based access control
- **Scalable**: Handles any volume of metrics
- **Environmentally Aware**: Built-in carbon footprint measurement

## 🌍 Environmental Impact

Track your organization's CI/CD carbon footprint:
- **GitHub-Hosted Runners**: Renewable energy, lower impact
- **Self-Hosted Runners**: Grid energy, higher impact
- **Resource Efficiency**: Optimize for lower energy consumption
- **Sustainability Goals**: Set targets for reducing pipeline emissions
