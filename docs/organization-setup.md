# 🏢 Organization Setup Guide

> **Set up EcoStack Metrics across your entire organization for comprehensive CI/CD monitoring and sustainability tracking**

## 🎯 Overview

This guide will help you set up EcoStack Metrics at the organization level, allowing you to:
- 📊 Monitor all repositories automatically
- 🌱 Track organization-wide carbon footprint
- ⚡ Standardize metrics collection
- 🔐 Manage access centrally
- 📈 Get organization-level insights

## 🚀 Quick Setup

### 1. Install EcoStack App

1. Go to your organization's **Settings** → **Integrations** → **GitHub Apps**
2. Click **Configure** next to **EcoStack Metrics**
3. Select repositories to grant access to
4. Click **Install**

### 2. Configure Workflow Permissions

1. Go to **Settings** → **Actions** → **General**
2. Under **Workflow permissions**, select:
   - ✅ "Allow GitHub Actions to create and approve pull requests"
   - ✅ "Allow GitHub Actions to read and write permissions"
3. Click **Save**

### 3. Create Organization Template

Create `.github/workflows/ecostack-metrics.yml` in your organization:

```yaml
name: EcoStack Metrics Collection Template
on:
  workflow_call:
    inputs:
      include_system_stats:
        description: 'Include system statistics and carbon footprint'
        required: false
        type: boolean
        default: true
      capture_pipeline_metrics:
        description: 'Capture true pipeline duration and resource usage'
        required: false
        type: boolean
        default: true
      runner_type:
        description: 'Type of runner to use'
        required: false
        type: string
        default: 'ubuntu-latest'

jobs:
  collect-metrics:
    runs-on: ${{ inputs.runner_type }}
    timeout-minutes: 10
    
    permissions:
      contents: read
      id-token: write
    
    steps:
      - name: Checkout repository
        uses: actions/checkout@v4
        with:
          fetch-depth: 1
      
      # 🌱 MEASURE CARBON FOOTPRINT
      - name: Measure Carbon Footprint
        uses: EcoStackTech/metrics@v8.1.2
        with:
          include_system_stats: ${{ inputs.include_system_stats }}
          capture_pipeline_metrics: ${{ inputs.capture_pipeline_metrics }}
```

## 📋 Repository Usage

### Basic Implementation

In any repository, add this to your workflow:

```yaml
- name: Use EcoStack Metrics
  uses: ./.github/workflows/ecostack-metrics.yml
  with:
    include_system_stats: true
    capture_pipeline_metrics: true
```

### Advanced Implementation

```yaml
jobs:
  build:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      
      - name: Install dependencies
        run: npm ci
      
      - name: Run tests
        run: npm test
      
      - name: Build application
        run: npm run build
      
      # 🌱 Measure Carbon Footprint
      - name: Use EcoStack Metrics
        uses: ./.github/workflows/ecostack-metrics.yml
        with:
          include_system_stats: true
          capture_pipeline_metrics: true
          runner_type: ubuntu-latest
```

## 🔧 Configuration Options

### Advanced Configuration

For users who need fine-grained control, the action supports these input parameters:

| Input | Description | Default | Required |
|-------|-------------|---------|----------|
| `include_system_stats` | Collect CPU/memory/disk metrics | `true` | No |
| `capture_pipeline_metrics` | Track true pipeline duration | `true` | No |

### Example with Custom Configuration

```yaml
- name: Measure Carbon Footprint
  uses: EcoStackTech/metrics@v8.1.2
  with:
    include_system_stats: false      # Skip detailed system monitoring
    capture_pipeline_metrics: true   # Keep pipeline duration tracking
```

### When to Use Advanced Configuration

- **`include_system_stats: false`**: When you want faster execution and only need basic metrics
- **`capture_pipeline_metrics: false`**: When you only want to measure the action execution time
- **Both `true` (default)**: Recommended for comprehensive monitoring and accurate carbon calculations

## 📊 Organization Dashboard

### What You'll See

- **Repository Overview**: All repositories using the action
- **Carbon Footprint**: Organization-wide environmental impact
- **Resource Usage**: Aggregate runner utilization
- **Pipeline Efficiency**: Performance metrics across teams
- **Trends**: Historical data and improvements

### Key Metrics

- **Total CO2 Emissions**: Combined impact of all pipelines (calculated by API)
- **Energy Consumption**: Total watt-hours used across all sources
- **Runner Efficiency**: GitHub-hosted vs self-hosted usage
- **Pipeline Duration**: Average execution times
- **Resource Utilization**: CPU and memory efficiency
- **Geographic Distribution**: Regional breakdown of emissions
- **Department Analysis**: Business unit impact assessment
- **Category Insights**: CI/CD vs IoT vs Cloud service comparisons

## 🎯 Best Practices

### 1. **Standardize Across Teams**
```yaml
# Use consistent naming and configuration
- name: Measure Carbon Footprint
  uses: ./.github/workflows/ecostack-metrics.yml
  with:
    include_system_stats: true
    capture_pipeline_metrics: true
```

### 2. **Monitor Pipeline Efficiency**
- Track action time vs. total pipeline time
- Identify bottlenecks across repositories
- Set organization-wide efficiency targets

### 3. **Set Sustainability Goals**
- Carbon footprint reduction targets
- Energy efficiency improvements
- Runner optimization strategies

### 4. **Regular Reviews**
- Monthly sustainability reports
- Quarterly efficiency reviews
- Annual carbon footprint assessments

## 🔐 Security & Permissions

### Required Permissions

- **Contents**: Read access to repository code
- **Actions**: Read workflow information
- **Metadata**: Read repository metadata

### Access Control

- **Repository Level**: Individual repository access
- **Organization Level**: Centralized management
- **Team Level**: Group-based permissions

## 📈 Scaling Considerations

### Large Organizations

- **Repository Limits**: Monitor API rate limits
- **Data Retention**: Configure data storage policies
- **Performance**: Optimize metrics collection timing

### Multi-Region Teams

- **Runner Distribution**: Use appropriate runner types
- **Time Zones**: Consider local business hours
- **Compliance**: Regional data requirements

## 🔍 Troubleshooting

### Common Issues

**"Workflow not found"**
- Ensure template is in organization's `.github/workflows/` directory
- Check repository access to organization templates

**"Permission denied"**
- Verify workflow permissions are enabled
- Check repository access settings

**"Metrics not collected"**
- Ensure action is placed at the end of workflows
- Check `capture_pipeline_metrics` is enabled

### Debug Mode

Enable debug logging in repositories:

```yaml
env:
  ACTIONS_STEP_DEBUG: true
```

## 📚 Examples

### Complete Organization Template

See [`examples/organization-template.yml`](../examples/organization-template.yml) for a comprehensive template with:
- Pre-metrics setup
- Post-metrics summary
- Conditional notifications
- Error handling

### Repository Implementation

See [`examples/repository-usage.yml`](../examples/repository-usage.yml) for repository-level usage examples.

## 🔄 Unified Metrics Structure

EcoStack Metrics v2.0.0 uses a unified payload structure that enables:

### **Common Metrics for Aggregation**
- **Entity Identification**: Unique IDs for pipelines, devices, and services
- **Geographic Location**: Regional breakdown and analysis
- **Energy Consumption**: Raw energy data for accurate carbon calculations
- **Business Classification**: Department and category organization
- **Consistent Timestamps**: Universal time tracking across all sources

### **Dashboard Benefits**
- **Cross-Source Aggregation**: Combine metrics from GitHub Actions, GitLab, CloudWatch, IoT
- **Regional Analysis**: Geographic breakdown of environmental impact
- **Department Insights**: Business unit sustainability tracking
- **Category Comparison**: CI/CD vs infrastructure vs manufacturing metrics
- **Real-Time Carbon**: API-side calculations using current carbon intensity data

## 🚀 Next Steps

1. **Install the EcoStack app** in your organization
2. **Create the metrics template** workflow
3. **Add to key repositories** to start collecting data
4. **Monitor your dashboard** for insights
5. **Set sustainability goals** and track progress
6. **Prepare for multi-source expansion** (GitLab, CloudWatch, IoT devices)

## 🌟 Benefits

- **🌱 Environmental Impact**: Measure and reduce carbon footprint
- **📊 Visibility**: Organization-wide CI/CD insights
- **⚡ Efficiency**: Identify optimization opportunities
- **🔐 Security**: Centralized access management
- **📈 Scalability**: Grow with your organization

---

**🏢 Ready to transform your organization's CI/CD sustainability? Follow this guide and start measuring your environmental impact today!**
