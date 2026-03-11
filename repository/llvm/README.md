# LLVM

LLVM comes from [this source repo](https://github.com/llvm/llvm-project)

## Build Requirements

### Installed Automatically

- gh
- cmake
- ninja
- python

## Options

```toml
"buildit:llvm" = { version = "latest", build_cores = "16", toolchain_only = false }
```

build_cores: Number of parallel processes for cmake build. Defaults to number of cores cpu has.

toolchain_only: Whether or not to only include the end user core toolchain executables, not the dev aids and extras. Defaults to true
