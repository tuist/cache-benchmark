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

#### Clean build without caching

https://github.com/tuist/cache-benchmark/actions/runs/18592698275/job/53011177047#step:8:4758

```
Time (mean ± σ):      4.596 s ±  0.068 s    [User: 0.715 s, System: 0.229 s]
Range (min … max):    4.454 s …  4.696 s    10 runs
```

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

#### Clean build with local caching

https://github.com/tuist/cache-benchmark/actions/runs/18592698275/job/53011177047#step:9:3968

```
Time (mean ± σ):      1.835 s ±  0.104 s    [User: 0.683 s, System: 0.188 s]
Range (min … max):    1.728 s …  2.118 s    10 runs
```

### mastodon-ios

#### Clean build without caching

https://github.com/tuist/cache-benchmark/actions/runs/18648931978/job/53162216387

```
Time (mean ± σ):     64.718 s ±  4.549 s    [User: 14.379 s, System: 4.916 s]
Range (min … max):   59.697 s … 68.564 s    3 runs
```

#### Clean build with pre-warmed cache (4.88.1)

https://github.com/tuist/cache-benchmark/actions/runs/18648931978/job/53162216374

```
Time (mean ± σ):     52.311 s ±  1.342 s    [User: 14.883 s, System: 6.097 s]
Range (min … max):   50.825 s … 53.434 s    3 runs
```

#### Clean build with local caching

https://github.com/tuist/cache-benchmark/actions/runs/18648931978/job/53162216387

```
Time (mean ± σ):     45.262 s ±  3.545 s    [User: 14.994 s, System: 5.318 s]
Range (min … max):   41.223 s … 47.854 s    3 runs
```

### Tuist CLI

#### Clean build without caching

https://github.com/tuist/cache-benchmark/actions/runs/18661637531/job/53203264755

```
Time (mean ± σ):     110.141 s ±  3.191 s    [User: 6.868 s, System: 3.338 s]
Range (min … max):   106.024 s … 113.082 s    5 runs
```

#### Clean build with pre-warmed cache (4.88.1)

https://github.com/tuist/cache-benchmark/actions/runs/18661637531/job/53203264725

```
Time (mean ± σ):     110.166 s ± 16.402 s    [User: 12.010 s, System: 8.855 s]
Range (min … max):   94.206 s … 133.653 s    5 runs
```

#### Clean build with local caching

https://github.com/tuist/cache-benchmark/actions/runs/18661637531/job/53203264757

```
Time (mean ± σ):     33.746 s ±  2.287 s    [User: 7.376 s, System: 4.023 s]
Range (min … max):   31.384 s … 36.950 s    5 runs
```

#### Module cache using generated projects

https://github.com/tuist/cache-benchmark/actions/runs/18661639514/job/53203270084

```
Time (mean ± σ):     34.936 s ±  3.437 s    [User: 32.681 s, System: 6.891 s]
Range (min … max):   30.482 s … 39.250 s    5 runs
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
