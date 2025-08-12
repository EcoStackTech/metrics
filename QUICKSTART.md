# 🚀 EcoStack Metrics - Quick Start Guide

> **Get up and running with EcoStack Metrics in under 5 minutes!**

## ⚡ Super Quick Start

### 1. Add to Your Workflow

```yaml
jobs:
  build:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      
      # Your build steps here...
      - run: echo "Building..."
      
      # 🌱 Measure Carbon Footprint (place at the end!)
      - name: Measure Carbon Footprint
        uses: EcoStackTech/metrics@v2.0.0
```

**That's it!** The action will automatically:
- ✅ Measure your pipeline's carbon footprint
- ✅ Track resource usage and efficiency
- ✅ Send metrics to EcoStack API
- ✅ Provide environmental impact insights

## 🎯 Best Practices

### **Place at the End** ⭐
```yaml
# ✅ RECOMMENDED: Capture entire pipeline
- name: Measure Carbon Footprint
  uses: EcoStackTech/metrics@v2.0.0

# ❌ AVOID: Only measures action time
- name: Measure Carbon Footprint
  uses: EcoStackTech/metrics@v2.0.0
  # ... other steps after this
```

### **Enable Enhanced Features**
```yaml
- name: Measure Carbon Footprint
  uses: EcoStackTech/metrics@v2.0.0
  with:
    include_system_stats: true      # Resource monitoring
    capture_pipeline_metrics: true  # Pipeline duration tracking
```

## 🔧 Configuration Options

| Input | Description | Default |
|-------|-------------|---------|
| `include_system_stats` | Collect CPU/memory/disk metrics | `true` |
| `capture_pipeline_metrics` | Track true pipeline duration | `true` |

## 📊 What You'll Get

### 🌱 Carbon Footprint
- Energy consumption in Watt-hours
- CO2 emissions in grams
- Environmental impact context

### ⏱️ Performance Metrics
- Total pipeline duration
- Resource utilization
- Efficiency insights

### 📈 System Resources
- CPU usage and load averages
- Memory consumption
- Disk and network I/O

## 🚀 Advanced Usage

### Organization-Wide Setup
1. Install the EcoStack app in your organization
2. Grant access to repositories
3. Use the organization template:

```yaml
- name: Use EcoStack Metrics
  uses: ./.github/workflows/ecostack-metrics.yml
  with:
    include_system_stats: true
    capture_pipeline_metrics: true
```

### Conditional Collection
```yaml
- name: Measure Carbon Footprint
  uses: EcoStackTech/metrics@v2.0.0
  if: github.event_name == 'push'  # Only on pushes
```

## 🔍 Troubleshooting

**Common Issues:**
- **High carbon footprint**: Review pipeline efficiency
- **Missing metrics**: Ensure action is at the end of your workflow
- **API errors**: Check repository permissions

**Need Help?**
- 📖 [Full Documentation](README.md)
- 🐛 [GitHub Issues](https://github.com/EcoStackTech/metrics/issues)
- 💬 [Discussions](https://github.com/EcoStackTech/metrics/discussions)

## 🌟 What's New in v2.0.0

- **🔍 True Pipeline Tracking**: Measures from commit to completion
- **⚡ Enhanced Resource Monitoring**: Better CPU, memory, and network tracking
- **🌱 Improved Carbon Footprint**: More accurate calculations
- **📊 Better Insights**: Pipeline efficiency metrics
- **🔄 Enhanced Reliability**: Better error handling

---

**🌱 Ready to measure your environmental impact? Add the action to your workflow and start tracking sustainability today!**
