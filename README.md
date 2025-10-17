# Tuist Cache Benchmark

This repository contains benchmarks for Tuist Cache to measure build performance with and without caching.

## Structure

- `xcode_project_with_cache/` - Sample Xcode project with CAS (Content Addressable Storage) enabled

## Benchmarks

The GitHub Actions workflow runs the following benchmarks:

1. **Clean build with cache uploads** - Measures time for a clean build that uploads artifacts to cache
2. **Clean build with pre-warmed cache** - Measures time for a clean build when cache is already populated
3. **Clean build without caching** - Baseline measurement with caching disabled

## Results

### xcode_project_with_cache

#### Clean build with cache uploads (4.88.0)

```
Time (mean ± σ): 5.654 s ± 0.554 s [User: 0.804 s, System: 0.333 s]
Range (min … max): 4.985 s … 6.630 s 10 runs
```

#### Clean build with pre-warmed cache (4.88.0)
```
Time (mean ± σ): 5.478 s ± 0.384 s [User: 0.795 s, System: 0.327 s]
Range (min … max): 4.991 s … 6.130 s 10 runs
```

#### Clean build without caching
```
Time (mean ± σ): 4.558 s ± 0.043 s [User: 0.701 s, System: 0.227 s]
Range (min … max): 4.453 s … 4.615 s 10 runs
```

#### Clean build with local caching
```
Time (mean ± σ): 1.241 s ± 0.021 s [User: 0.650 s, System: 0.171 s]
Range (min … max): 1.214 s … 1.292 s 10 runs
```

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
