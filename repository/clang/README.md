# LLVM

LLVM comes from [this source repo](https://github.com/llvm/llvm-project)

## Build Requirements

### Installed Automatically

- cmake
- ninja
- python

## Options

```toml
"buildit:llvm" = { version = "latest", build_cores = "16", toolchain_only = false, build_sequentially = true, clang_extras = true }
```

build_cores: Number of parallel processes for cmake build. Defaults to number of cores cpu has.

toolchain_only: Whether or not to only include the end user core toolchain executables, not the dev aids and extras. Defaults to true

build_sequentially: Whether to apply locks such that if multiple llvm projects are being installed & built, they will build sequentially rather than in parallel. Defaults to false

clang_extras: Whether or not to include extra tools like clangd and clang-tidy etc. Defaults to false
