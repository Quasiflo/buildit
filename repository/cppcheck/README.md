# CPPCHECK

Cppcheck comes from [this source repo](https://github.com/danmar/cppcheck)

## Build Requirements

### Installed Automatically

- cmake
- python

### Manual Install required

- qt (only if building GUI)

## Options

```toml
"buildit:cppcheck" = {version = "latest", build_cores = "16", build_gui = true}
```

build_cores: Number of parallel processes for cmake build. Defaults to number of cores cpu has.

build_gui: Whether or not to build the cppcheck GUI. Defaults to off
