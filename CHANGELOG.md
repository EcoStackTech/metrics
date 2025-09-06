# Changelog

All notable changes to the EcoStack Metrics GitHub Action will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [8.1.1] - 2025-01-06

### 🐛 Bug Fixes

#### **Common Metrics Consistency**
- **Energy Unit Conversion**: Fixed energy_kwh field to properly convert from Wh to kWh (divide by 1000)
- **Entity ID Sanitization**: Sanitized workflow and job names in entity_id by replacing special characters with underscores
- **Location Detection**: Added intelligent location detection for GitHub-hosted runners (US East/Virginia)
- **JSON Formatting**: Fixed location JSON to properly quote string values or use null

#### **Data Consistency Improvements**
- **Consistent Entity IDs**: All entity IDs now follow the format `org/repo-sanitized_workflow-sanitized_job-run_id`
- **Accurate Energy Values**: Energy consumption now correctly displayed in kWh instead of Wh
- **Location Data**: GitHub-hosted runners now show actual location instead of null values

### 🔧 Technical Improvements
- **Enhanced Location Detection**: Added timezone-based location detection for better geographic accuracy
- **Improved Error Handling**: Better fallback values for energy calculations when bc is not available
- **Sanitization Logic**: Robust character replacement for workflow and job names in entity IDs

---

## [2.0.0] - 2024-01-15

### 🚀 Major Features

#### **Enhanced Pipeline-Level Metrics**
- **True Pipeline Tracking**: Now measures from commit/PR creation to completion, not just action execution time
- **Pipeline Duration Calculation**: Captures actual pipeline duration using GitHub event timestamps
- **Efficiency Metrics**: Provides ratio of action time to total pipeline time for optimization insights

#### **Advanced Resource Monitoring**
- **CPU Load Averages**: 1-minute, 5-minute, and 15-minute load averages for better CPU utilization tracking
- **Enhanced Memory Monitoring**: Detailed breakdown including buffered, cached, and peak memory usage
- **Disk I/O Tracking**: Separate read/write operations and total disk usage statistics
- **Network I/O Monitoring**: Bytes received and sent for comprehensive resource tracking

#### **Improved Carbon Footprint Calculation**
- **Real Duration Data**: Uses actual pipeline duration instead of estimated values
- **Enhanced Energy Models**: More realistic power consumption calculations (12W per core, 3W per GB RAM)
- **Dynamic Carbon Intensity**: Different carbon factors based on energy mix (renewable: 50, grid: 400, mixed: 200 gCO2e/kWh)
- **Environmental Impact Context**: Provides relatable comparisons (phone charging, laptop usage, etc.)

### ✨ Enhancements

#### **Better Logging & Output**
- **Structured Logging**: Timestamped log levels (DEBUG, INFO, WARN, ERROR, SUCCESS)
- **Emoji-Rich Output**: Visual indicators for different types of information
- **Progress Tracking**: Clear indication of what's being measured and calculated

#### **Enhanced Error Handling**
- **Improved Retry Logic**: Exponential backoff with 5 retry attempts (was 3)
- **Better Timeout Handling**: 10-second connect timeout, 30-second max time
- **Detailed Error Messages**: More informative error reporting and debugging information

#### **Comprehensive Data Collection**
- **Extended GitHub Context**: Additional event data including PR creation, issue updates, release info
- **Runner Classification**: Better detection of GitHub-hosted vs self-hosted runners
- **Metadata Tracking**: Version information and feature flags in payload

### 🔧 Technical Improvements

#### **Bash Scripting Enhancements**
- **Decimal Arithmetic**: Uses `bc` for accurate calculations when available
- **Variable Initialization**: Proper initialization to prevent unbound variable errors
- **Error Prevention**: Division by zero checks and boundary condition handling

#### **API Integration**
- **Enhanced Headers**: User-Agent identification and better content handling
- **Response Parsing**: More detailed response analysis including upload size and speed
- **Payload Validation**: Better JSON structure and data integrity

#### **Performance Optimizations**
- **Efficient Resource Collection**: Optimized system calls and data gathering
- **Memory Management**: Better handling of large datasets and system information
- **Network Efficiency**: Improved curl options and timeout handling

### 📊 New Metrics

#### **Performance Data**
- `pipeline_duration_seconds`: Total time from event creation to completion
- `pipeline_duration_minutes`: Duration in human-readable format
- `action_duration_seconds`: Time spent in the metrics action itself
- `cpu_load_1min/5min/15min`: CPU load averages for trend analysis

#### **System Resources**
- `mem_buffered_mb`: Buffered memory usage
- `mem_cached_mb`: Cached memory usage
- `disk_total_mb`: Total disk space
- `disk_used_mb`: Used disk space
- `disk_io_read_bytes`: Disk read operations
- `disk_io_write_bytes`: Disk write operations
- `net_io_rx_bytes`: Network bytes received
- `net_io_tx_bytes`: Network bytes sent

#### **Carbon Footprint Details**
- `renewable_percentage`: Percentage of renewable energy used
- `utilized_power_watts`: Power consumption based on actual utilization
- `cpu_power_watts`: CPU-specific power consumption
- `memory_power_watts`: Memory-specific power consumption
- `base_power_watts`: Base system power consumption
- `carbon_intensity_gco2e_per_kwh`: Carbon intensity factor used

### 🎯 New Inputs

- **`capture_pipeline_metrics`**: Enable/disable true pipeline duration tracking (default: `true`)
- Enhanced validation for all inputs with better error messages

### 📈 API Payload Changes

- **New Payload Type**: `enhanced_action_probe` (was `action_probe`)
- **Extended Event Data**: Comprehensive GitHub event information
- **Enhanced Metadata**: Version tracking and feature flags
- **Better Structure**: Organized into logical sections for easier parsing

### 🌟 User Experience Improvements

#### **Better Guidance**
- **Placement Recommendations**: Clear guidance to place action at end of workflows
- **Configuration Tips**: Helpful suggestions for optimal setup
- **Troubleshooting**: Enhanced error messages and debugging information

#### **Visual Enhancements**
- **Progress Indicators**: Clear indication of what's happening at each step
- **Success Confirmation**: Detailed summary of what was accomplished
- **Environmental Context**: Relatable comparisons for carbon footprint impact

### 🔍 Debugging & Monitoring

- **Enhanced Logging**: Better visibility into what's happening during execution
- **Performance Metrics**: Detailed timing and resource usage information
- **Error Context**: More information about what went wrong and how to fix it

### 📚 Documentation Updates

- **Comprehensive README**: Complete rewrite with v2.0.0 features
- **Enhanced Examples**: Better workflow examples and best practices
- **Organization Guide**: Detailed setup instructions for enterprise use
- **Quick Start Guide**: Streamlined getting started experience

### 🚨 Breaking Changes

- **Payload Structure**: JSON payload format has changed significantly
- **New Required Fields**: Some fields are now always present
- **Enhanced Validation**: Stricter input validation may affect existing workflows

### 🔄 Migration Guide

#### **From v1.x to v2.0.0**

1. **Update Action Reference**:
   ```yaml
   # Old
   uses: EcoStackTech/metrics@v1
   
   # New
   uses: EcoStackTech/metrics@v8.1.2
   ```

2. **Review New Inputs**:
   ```yaml
   - name: Measure Carbon Footprint
     uses: EcoStackTech/metrics@v8.1.2
     with:
       include_system_stats: true
       capture_pipeline_metrics: true  # New input
   ```

3. **Update API Integration**:
   - Handle new payload structure
   - Process additional metrics fields
   - Update carbon footprint calculations

4. **Test Thoroughly**:
   - Verify metrics collection works as expected
   - Check API payload format changes
   - Validate carbon footprint calculations

### 🎉 What's Next

- **Real-time Monitoring**: Continuous resource tracking during pipeline execution
- **Machine Learning**: AI-powered carbon footprint optimization suggestions
- **Integration APIs**: Webhook support and third-party integrations
- **Advanced Analytics**: Predictive modeling and trend analysis

---

## [1.0.0] - 2024-01-10

### 🎉 Initial Release

- **Basic Metrics Collection**: Runner information, workflow context, and system statistics
- **Carbon Footprint Calculation**: Basic environmental impact measurement
- **GitHub Actions Integration**: Seamless workflow integration
- **Organization Support**: Multi-repository metrics collection
- **Zero Configuration**: Works out of the box with sensible defaults

---

**For detailed information about each version, see the [README](README.md) and [documentation](docs/).**
