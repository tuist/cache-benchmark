# Tuist Cache Benchmark

This repository contains benchmarks for Tuist Cache to measure build performance with and without caching.

## Structure

- `xcode_project_with_cache/` - Sample Xcode project with CAS (Content Addressable Storage) enabled

## Benchmarks

The GitHub Actions workflow runs the following benchmarks:

1. **Clean build with cache uploads** - Measures time for a clean build that uploads artifacts to cache
2. **Clean build with pre-warmed cache** - Measures time for a clean build when cache is already populated
3. **Clean build without caching** - Baseline measurement with caching disabled

## Running Locally

```bash
# Install dependencies
mise install

# Setup cache
cd xcode_project_with_cache
tuist setup cache

# Run benchmark
xcodebuild -project App.xcodeproj -scheme App -destination 'platform=iOS Simulator,name=iPhone 17' clean build
```