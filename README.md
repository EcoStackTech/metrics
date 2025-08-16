# EcoStack GitHub Actions Metrics

> **🌱 Measure the environmental impact of your CI/CD pipelines with precision**

[![GitHub release (latest by date)](https://img.shields.io/github/v/release/EcoStackTech/metrics)](https://github.com/EcoStackTech/metrics/releases)
[![GitHub license](https://img.shields.io/github/license/EcoStackTech/metrics)](https://github.com/EcoStackTech/metrics/blob/main/LICENSE)
[![GitHub issues](https://img.shields.io/github/issues/EcoStackTech/metrics)](https://github.com/EcoStackTech/metrics/issues)

## 🚀 What's New in v2.0.0

**Enhanced Pipeline-Level Metrics** - Now captures true pipeline duration and resource usage, not just action execution time!

### ✨ Key Improvements
- **🔍 True Pipeline Tracking**: Measures from commit/PR creation to completion
- **⚡ Enhanced Resource Monitoring**: CPU load averages, detailed memory breakdown, network I/O
- **🌱 Improved Carbon Footprint**: More accurate calculations with real pipeline duration
- **📊 Better Insights**: Pipeline efficiency metrics and environmental impact context
- **🔄 Enhanced Reliability**: Better error handling and retry logic
- **🔄 Unified Structure**: Common metrics for dashboard aggregation across multiple sources
- **🌍 API-Side Carbon**: Real-time carbon calculations using current carbon intensity data

## 📖 Overview

EcoStack Metrics is a GitHub Action that automatically collects comprehensive metrics about your GitHub Actions runners and calculates the carbon footprint of your CI/CD pipelines. Perfect for organizations committed to sustainability and efficiency.

### 🌟 Features

- **🔋 Carbon Footprint Calculation**: Measure CO2 emissions from your pipelines
- **⚡ Resource Monitoring**: CPU, memory, disk, and network usage tracking
- **⏱️ Pipeline Duration**: True pipeline execution time measurement
- **🌿 Energy Mix Awareness**: Different calculations for renewable vs. grid energy
- **📊 Comprehensive Metrics**: Detailed system and performance data
- **🔐 Organization-Level**: Install once, monitor all repositories
- **🚀 Zero Configuration**: Works out of the box with sensible defaults

## 🚀 Quick Start

### Basic Usage

```yaml
jobs:
  build:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      
      - name: Build application
        run: |
          echo "Building..."
          sleep 30
      
      # Place at the end to capture true pipeline metrics
      - name: Measure Carbon Footprint
        uses: EcoStackTech/metrics@v2.0.0
```

> **💡 Simple & Smart**: The action works out of the box with sensible defaults. For advanced configuration options, see the [Organization Setup Guide](docs/organization-setup.md).

### Advanced Usage

```yaml
jobs:
  build:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      
      - name: Install dependencies
        run: npm install
      
      - name: Run tests
        run: npm test
      
      - name: Build application
        run: npm run build
      
      # Enhanced metrics with custom configuration
      - name: Measure Carbon Footprint
        uses: EcoStackTech/metrics@v2.0.0
        with:
          include_system_stats: true
          capture_pipeline_metrics: true
```

## 📋 Inputs

| Input | Description | Required | Default |
|-------|-------------|----------|---------|
| `include_system_stats` | Collect CPU/RAM/disk metrics and carbon footprint | `false` | `true` |
| `capture_pipeline_metrics` | Capture true pipeline duration and resource usage | `false` | `true` |

> **Note**: The `api_url` input is available for internal development but not documented for end-users.

## 📊 Metrics Collected

### 🏃‍♂️ Runner Information
- Runner name, OS, architecture, and labels
- Runner type (GitHub-hosted vs self-hosted)
- Energy efficiency classification

### ⚡ System Resources
- **CPU**: Cores, usage percentage, load averages (1min, 5min, 15min)
- **Memory**: Total, available, used, buffered, cached, peak usage
- **Disk**: Total, used, available space, I/O operations
- **Network**: Bytes received/sent

### ⏱️ Performance Metrics
- **Pipeline Duration**: From commit/PR creation to completion
- **Action Duration**: Time spent in the metrics action
- **Efficiency Ratio**: Action time vs. total pipeline time

### 🌱 Carbon Footprint
- **Energy Consumption**: Watt-hours based on actual resource usage
- **Carbon Emissions**: Grams of CO2 equivalent
- **Energy Mix**: Renewable vs. grid energy factors
- **Environmental Impact**: Contextual comparisons (phone charging, laptop usage, etc.)

## 🔧 Installation

### Repository Level

1. Add the action to your workflow file (see Quick Start above)
2. The action will automatically authenticate based on your repository

### Organization Level

1. Go to your organization's **Settings** → **Actions** → **General**
2. Under **Workflow permissions**, select "Allow GitHub Actions to create and approve pull requests"
3. Install the EcoStack Metrics app from the GitHub Marketplace
4. Grant access to repositories you want to monitor

## 📈 API Response Format

The action sends a unified JSON payload to your API with consistent structure for dashboard aggregation:

```json
{
  "type": "github_action",
  "ts": "2024-01-15T10:30:00Z",
  "source": "github_actions",
  "version": "2.0.0",
  "metadata": {
    "source_version": "v4.0.0",
    "collection_method": "action"
  },
  "common_metrics": {
    "entity_id": "owner/repo-workflow-job-run_id",
    "entity_name": "Workflow - Job",
    "location": {
      "country": "USA",
      "region": "East US",
      "city": "Ashburn"
    },
    "energy_kwh": 0.025,
    "category": "ci_cd",
    "department": "engineering"
  },
  "payload": {
    "repo": "owner/repo",
    "workflow": "CI",
    "job": "build",
    "runner": {
      "name": "ubuntu-latest",
      "type": "github-hosted",
      "os": "Linux",
      "arch": "X64"
    },
    "performance": {
      "pipeline_duration_seconds": 1800,
      "pipeline_duration_minutes": 30,
      "action_duration_seconds": 5,
      "action_duration_minutes": 0
    },
    "system": {
      "cores": 2,
      "mem_total_mb": 7168,
      "cpu_usage_percent": 45
    }
  }
}
```

### 🔄 **Unified Structure Benefits**
- **Consistent Aggregation**: Common metrics enable dashboard aggregation across all sources
- **Geographic Analysis**: Location data for regional breakdowns
- **Category Filtering**: Business and technical classification
- **Entity Tracking**: Unique identification for specific pipelines
- **Energy Data**: Raw energy consumption for accurate carbon calculations

## 🌍 Carbon Footprint Calculation

### Energy Data Collection
The action collects raw energy consumption data (`energy_kwh`) and sends it to the EcoStack API, where accurate carbon footprint calculations are performed using real-time carbon intensity data.

### What the Action Provides
- **Energy Consumption**: Watt-hours based on actual resource usage and duration
- **Resource Utilization**: CPU, memory, and disk usage metrics
- **Pipeline Duration**: Accurate timing for energy calculations
- **Runner Information**: Energy efficiency classification

### What the API Calculates
- **Carbon Emissions**: Based on real-time carbon intensity data
- **Energy Mix Factors**: Dynamic calculations for different regions
- **Carbon Intensity**: Up-to-date values for renewable vs. grid energy
- **Environmental Impact**: Contextual comparisons and insights

### Benefits of API-Side Calculation
- **Real-Time Accuracy**: Uses current carbon intensity data
- **Regional Precision**: Location-specific calculations
- **Dynamic Updates**: Reflects changing energy mix
- **Consistent Methodology**: Standardized across all sources

## 🎯 Best Practices

### 1. **Place at the End** ⭐
```yaml
# ✅ Recommended: Capture entire pipeline
- name: Measure Carbon Footprint
  uses: EcoStackTech/metrics@v2.0.0

# ❌ Avoid: Only measures action time
- name: Measure Carbon Footprint
  uses: EcoStackTech/metrics@v2.0.0
  # ... other steps after this
```

### 2. **Enable Enhanced Metrics**
```yaml
- name: Measure Carbon Footprint
  uses: EcoStackTech/metrics@v2.0.0
  with:
    include_system_stats: true      # Resource monitoring
    capture_pipeline_metrics: true  # Pipeline duration tracking
```

### 3. **Monitor Pipeline Efficiency**
- Track the ratio of action time to total pipeline time
- Identify bottlenecks and optimization opportunities
- Set carbon footprint targets for your team

## 🔍 Troubleshooting

### Common Issues

**"Resource not accessible by integration"**
- Ensure the action has `contents: write` permissions
- Check that the repository is accessible to the action

**"Could not determine pipeline start time"**
- This is normal for some event types
- The action will fall back to action duration measurement

**High carbon footprint values**
- Review your pipeline efficiency
- Consider using GitHub-hosted runners (100% renewable)
- Optimize build times and resource usage

### Debug Mode

Enable debug logging by setting the `ACTIONS_STEP_DEBUG` secret to `true` in your repository.

## 📚 Examples

See the [`examples/`](examples/) directory for complete workflow templates:

- [`repository-usage.yml`](examples/repository-usage.yml) - Basic repository setup
- [`organization-template.yml`](examples/organization-template.yml) - Organization-wide template

## 🤝 Contributing

We welcome contributions! Please see our [Contributing Guide](CONTRIBUTING.md) for details.

### Development

```bash
# Clone the repository
git clone https://github.com/EcoStackTech/metrics.git
cd metrics

# Test locally
./scripts/test.sh

# Make changes and test
# Submit a pull request
```

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 🌟 Support

- **Documentation**: [docs/](docs/)
- **Issues**: [GitHub Issues](https://github.com/EcoStackTech/metrics/issues)
- **Discussions**: [GitHub Discussions](https://github.com/EcoStackTech/metrics/discussions)

## 🙏 Acknowledgments

- GitHub for providing renewable energy for hosted runners
- The open source community for sustainability tools
- All contributors helping measure and reduce CI/CD environmental impact

---

**🌱 Together, let's build a more sustainable future, one pipeline at a time!**
