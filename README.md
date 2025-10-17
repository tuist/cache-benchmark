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

https://github.com/tuist/cache-benchmark/actions/runs/18592698275/job/53011177047#step:6:13371

```
Time (mean ± σ):      5.787 s ±  0.933 s    [User: 0.949 s, System: 0.361 s]
Range (min … max):    5.197 s …  8.263 s    10 runs
```

#### Clean build with pre-warmed cache (4.88.0)

https://github.com/tuist/cache-benchmark/actions/runs/18592698275/job/53011177047#step:7:14024

```
Time (mean ± σ):      2.933 s ±  0.130 s    [User: 0.766 s, System: 0.304 s]
Range (min … max):    2.792 s …  3.209 s    10 runs
```

#### Clean build without caching

https://github.com/tuist/cache-benchmark/actions/runs/18592698275/job/53011177047#step:8:4758

```
Time (mean ± σ):      4.596 s ±  0.068 s    [User: 0.715 s, System: 0.229 s]
Range (min … max):    4.454 s …  4.696 s    10 runs
```

#### Clean build with local caching

https://github.com/tuist/cache-benchmark/actions/runs/18592698275/job/53011177047#step:9:3968

```
Time (mean ± σ):      1.835 s ±  0.104 s    [User: 0.683 s, System: 0.188 s]
Range (min … max):    1.728 s …  2.118 s    10 runs
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
