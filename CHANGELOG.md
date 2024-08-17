# Changelog

All changes worthy of mention are noted here.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [0.1.0] - 2024-08-17

### Added

- Added inline docs + typespec public functions
- Added tests for `PolyPost.Builder` and `PolyPost.Depot` modules
- Added support for code highlighting using `makeup` in `code` blocks
- Added storage of content into ETS tables accessible via the `PolyPost.Depot` processes
- Added support to load files directly from configured, splattable paths
- Added `PolyPost.Resource` behaviour to specify `build/3` function callbacks for managing parsed markdown + metadata
- Added `README` with documentation for basic installing and usage of this library
- Added license (Apache 2.0) to project
