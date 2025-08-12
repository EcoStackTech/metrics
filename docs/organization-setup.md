# Organization-Level Setup Guide

This guide explains how to set up the EcoStack metrics action at the organization level to automatically collect metrics from all repositories, including **carbon footprint measurement**.

## Prerequisites

1. **Organization Admin Access**: You need admin access to your GitHub organization
2. **EcoStack Access**: Your organization must be authorized in EcoStack (handled automatically)

## Step 1: Configure Organization Actions Settings

1. Go to your organization's **Settings** page
2. Click on **Actions** in the left sidebar
3. Under **General**, ensure the following settings:
   - **Actions permissions**: Select "Allow all actions and reusable workflows"
   - **Workflow permissions**: Select "Allow GitHub Actions to create and approve pull requests"
   - **Fork pull request workflows from outside collaborators**: Select "Require approval for first-time contributors"

## Step 2: Create Organization Workflow Template

1. In your organization, create a new repository called `.github` (if it doesn't exist)
2. Add the following workflow file: `.github/workflows/ecostack-metrics.yml`

```yaml
name: EcoStack Metrics Collection
description: "Template workflow for collecting runner metrics across the organization"

on:
  workflow_call:
    inputs:
      include_system_stats:
        description: "Collect system statistics and carbon footprint"
        required: false
        type: string
        default: "true"

jobs:
  collect-metrics:
    name: "Collect Runner Metrics"
    runs-on: ubuntu-latest
    timeout-minutes: 5
    
    steps:
      - name: Measure Carbon Footprint
        uses: EcoStackTech/metrics@v1
        with:
          include_system_stats: ${{ inputs.include_system_stats }}
```

## Step 3: Create Repository Template

Create a template repository that other repositories can copy from:

1. Create a new repository in your organization
2. Add the following workflow file: `.github/workflows/metrics.yml`

```yaml
name: Collect Metrics
on:
  push:
    branches: [ main, develop ]
  pull_request:
    branches: [ main ]
  workflow_dispatch:

jobs:
  metrics:
    uses: ./.github/workflows/ecostack-metrics.yml
    # Uses default EcoStack API automatically
```

## Step 4: Enable in Individual Repositories

For each repository where you want to collect metrics:

### Option A: Copy Template Workflow

1. Copy the `.github/workflows/metrics.yml` file to the repository
2. That's it! No additional configuration needed

### Option B: Use Organization Workflow

1. Add the following workflow file: `.github/workflows/metrics.yml`

```yaml
name: Collect Metrics
on:
  push:
    branches: [ main, develop ]
  pull_request:
    branches: [ main ]
  workflow_dispatch:

jobs:
  metrics:
    uses: your-org/.github/.github/workflows/ecostack-metrics.yml@main
    # Uses default EcoStack API automatically
```

## Step 5: Test the Setup

1. Make a small change to any repository with the workflow enabled
2. Check the Actions tab to see if the metrics collection job runs
3. Verify in your EcoStack dashboard that metrics are being received
4. Check that carbon footprint data is being collected

## Carbon Footprint Measurement

### What Gets Measured

- **Pipeline Duration**: Start time, end time, and total execution time
- **Resource Consumption**: CPU usage, memory usage, disk I/O
- **Energy Estimation**: Power consumption based on hardware specifications
- **Carbon Impact**: CO2 emissions in grams based on energy mix and duration

### Environmental Impact Tracking

Track your organization's CI/CD carbon footprint across all repositories:

- **GitHub-Hosted Runners**: Use renewable energy (lower carbon factor)
- **Self-Hosted Runners**: Use grid energy (higher carbon factor)
- **Resource Efficiency**: Monitor CPU and memory utilization
- **Sustainability Goals**: Set targets for reducing pipeline emissions

### Carbon Footprint Calculation

The action calculates carbon footprint using this formula:

```
Carbon Footprint = (CPU Power + Memory Power + Base Power) × Duration × Energy Mix Factor × Carbon Intensity
```

This gives you accurate environmental impact data for compliance, reporting, and sustainability initiatives.

## Advanced Configuration

### Conditional Metrics Collection

You can make metrics collection conditional based on various factors:

```yaml
jobs:
  metrics:
    if: github.event_name == 'push' && github.ref == 'refs/heads/main'
    uses: ./.github/workflows/ecostack-metrics.yml
    with:
      include_system_stats: 'false'  # Skip system stats and carbon footprint
```

### Batch Processing

For repositories with many workflows, consider batching metrics:

```yaml
jobs:
  metrics:
    if: github.event_name == 'push' && github.ref == 'refs/heads/main'
    uses: ./.github/workflows/ecostack-metrics.yml
    with:
      include_system_stats: 'true'  # Include carbon footprint data
```

## Troubleshooting

### Common Issues

1. **Workflow not found**: Ensure the organization workflow template exists and is accessible
2. **Permission denied**: Check organization Actions settings and repository permissions
3. **Access denied**: Repository not authorized in EcoStack (contact support)
4. **Carbon footprint not calculated**: Ensure `include_system_stats` is set to `true`

### Debug Mode

To debug issues, temporarily add logging to your workflow:

```yaml
- name: Debug information
  run: |
    echo "Repository: ${{ github.repository }}"
    echo "Event: ${{ github.event_name }}"
    echo "Ref: ${{ github.ref }}"
    echo "Actor: ${{ github.actor }}"
```

## Best Practices

1. **Start Small**: Begin with a few key repositories before rolling out organization-wide
2. **Monitor Usage**: Keep track of API usage and costs
3. **Track Carbon Footprint**: Use the data to optimize resource usage
4. **Set Sustainability Goals**: Establish targets for reducing pipeline emissions
5. **Documentation**: Document the setup process for your team
6. **Testing**: Test in staging environments before production deployment

## Support

If you encounter issues:

1. Check the [GitHub Actions documentation](https://docs.github.com/en/actions)
2. Review the [EcoStack metrics action documentation](../README.md)
3. Open an issue in the EcoStack metrics repository
4. Contact EcoStack support
