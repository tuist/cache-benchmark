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

### mastodon-tuist-ios

Mastodon using generated projects.

#### Clean build without caching

https://github.com/tuist/cache-benchmark/actions/runs/18678254368/job/53253116480

```
Time (mean ± σ):     51.485 s ±  2.292 s    [User: 3.869 s, System: 1.774 s]
Range (min … max):   48.588 s … 54.436 s    5 runs
```

#### Clean build with pre-warmed cache (4.88.1)

https://github.com/tuist/cache-benchmark/actions/runs/18678254368/job/53253116462

```
Time (mean ± σ):     28.452 s ±  2.156 s    [User: 5.103 s, System: 3.656 s]
Range (min … max):   26.537 s … 31.762 s    5 runs
```

#### Clean build with local caching

https://github.com/tuist/cache-benchmark/actions/runs/18678254368/job/53253116489

```
Time (mean ± σ):     21.630 s ±  0.247 s    [User: 3.502 s, System: 1.599 s]
Range (min … max):   21.328 s … 21.959 s    5 runs
```

#### Clean build with module cache

https://github.com/tuist/cache-benchmark/actions/runs/18662844442/job/53207204836

```
Time (mean ± σ):     24.999 s ±  0.542 s    [User: 10.611 s, System: 2.723 s]
Range (min … max):   24.599 s … 25.932 s    5 runs
```

### Tuist CLI

#### Clean build without caching

https://github.com/tuist/cache-benchmark/actions/runs/18661637531/job/53203264755

```
Time (mean ± σ):     110.141 s ±  3.191 s    [User: 6.868 s, System: 3.338 s]
Range (min … max):   106.024 s … 113.082 s    5 runs
```

#### Clean build with pre-warmed cache (4.88.1)

https://github.com/tuist/cache-benchmark/actions/runs/18678245064/job/53253086378

```
Time (mean ± σ):     59.447 s ±  3.086 s    [User: 11.344 s, System: 8.449 s]
Range (min … max):   56.276 s … 63.313 s    5 runs
```

#### Clean build with local caching

https://github.com/tuist/cache-benchmark/actions/runs/18678245064/job/53253086402

```
Time (mean ± σ):     37.600 s ±  3.387 s    [User: 8.455 s, System: 4.779 s]
Range (min … max):   33.375 s … 40.504 s    5 runs
```

#### Module cache using generated projects

https://github.com/tuist/cache-benchmark/actions/runs/18661639514/job/53203270084

```
Time (mean ± σ):     34.936 s ±  3.437 s    [User: 32.681 s, System: 6.891 s]
Range (min … max):   30.482 s … 39.250 s    5 runs
```

### Tuist App

#### Clean build without caching

https://github.com/tuist/cache-benchmark/actions/runs/18677113072/job/53249420000

```
Time (mean ± σ):     68.049 s ±  1.212 s    [User: 4.795 s, System: 2.214 s]
Range (min … max):   66.195 s … 69.141 s    5 runs
```

#### Clean build with pre-warmed cache (4.88.1)

https://github.com/tuist/cache-benchmark/actions/runs/18677113072/job/53249420046

```
Time (mean ± σ):     43.661 s ±  4.253 s    [User: 7.639 s, System: 5.471 s]
Range (min … max):   38.467 s … 49.799 s    5 runs
```

#### Clean build with local cache

https://github.com/tuist/cache-benchmark/actions/runs/18677113072/job/53249420041

```
Time (mean ± σ):     25.761 s ±  1.458 s    [User: 5.586 s, System: 2.851 s]
Range (min … max):   23.781 s … 27.843 s    5 runs
```

#### Module cache

https://github.com/tuist/cache-benchmark/actions/runs/18676750661/job/53248258692

```
Time (mean ± σ):     28.080 s ±  1.936 s    [User: 25.013 s, System: 5.313 s]
Range (min … max):   24.976 s … 30.125 s    5 runs
```

###  pocket-casts-ios

#### Clean build without caching

https://github.com/tuist/cache-benchmark/actions/runs/18661646098/job/53205488741

```
Time (mean ± σ):     168.073 s ± 11.333 s    [User: 21.201 s, System: 9.153 s]
Range (min … max):   155.411 s … 177.266 s    3 runs
```

#### Clean build with pre-warmed cache (4.88.1)

https://github.com/tuist/cache-benchmark/actions/runs/18652147920/job/53172446664

```
Time (mean ± σ):     136.782 s ± 10.858 s    [User: 28.302 s, System: 15.671 s]
Range (min … max):   125.540 s … 147.210 s    3 runs
```

#### Clean build with local caching

https://github.com/tuist/cache-benchmark/actions/runs/18652147920/job/53172446706

```
Time (mean ± σ):     108.634 s ±  4.827 s    [User: 22.317 s, System: 9.123 s]
Range (min … max):   104.639 s … 113.997 s    3 runs
```

### wikipedia-ios

#### Clean build without caching

https://github.com/tuist/cache-benchmark/actions/runs/18675431659/job/53244336304

```
Time (mean ± σ):     69.328 s ±  2.320 s    [User: 4.730 s, System: 2.041 s]
Range (min … max):   67.065 s … 71.702 s    3 runs
```

#### Clean build with pre-warmed cache (4.88.1)

https://github.com/tuist/cache-benchmark/actions/runs/18675431659/job/53244336273

```
Time (mean ± σ):     57.691 s ±  1.594 s    [User: 6.220 s, System: 3.921 s]
Range (min … max):   55.993 s … 59.154 s    3 runs
```

#### Clean build with local caching

https://github.com/tuist/cache-benchmark/actions/runs/18675431659/job/53244336321

```
Time (mean ± σ):     53.072 s ±  1.253 s    [User: 3.979 s, System: 1.731 s]
Range (min … max):   51.648 s … 54.010 s    3 runs
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
