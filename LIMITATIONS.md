# Limitations

## Package Availability

The cookbook installs BIND from operating system package repositories. ISC also
publishes current BIND 9 packages for selected Debian, Ubuntu, RHEL/CentOS, and
Fedora platforms.

### APT (Debian/Ubuntu)

* Debian 12: supported by ISC for BIND 9.18 and 9.20 on amd64 CI.
* Ubuntu 22.04 LTS: supported by ISC for BIND 9.18 and 9.20 on amd64 CI.
* Ubuntu 24.04 LTS: supported by ISC for BIND 9.18 and 9.20 on amd64 CI.
* Debian LTS releases are community-maintained from ISC's perspective and are
  not included in the active Kitchen matrix.

### DNF/YUM (RHEL family)

* RHEL 8, RHEL 9, and RHEL 10: supported by ISC for BIND 9.18 and 9.20 on amd64
  CI.
* CentOS Stream 9: community-maintained by ISC and covered by the cookbook test
  matrix.
* AlmaLinux 8/9, Oracle Linux 8/9, and Rocky Linux 8/9: supported by this
  cookbook through compatible distribution packages and CI coverage.
* Amazon Linux 2023: supported by this cookbook through distribution packages
  and CI coverage.
* CentOS 7 and CentOS Stream 8 are end-of-life and are not supported.

### Fedora

* Fedora latest: supported by ISC for BIND 9.18 and 9.20 on amd64 CI.

## Architecture Limitations

ISC's supported-platforms guidance describes primary support in terms of amd64
CI coverage. Other CPU architectures are best-effort or community-maintained
depending on the operating system and BIND branch.

## Source/Compiled Installation

This cookbook does not compile BIND from source. BIND 9 requires a POSIX system,
a C11-capable compiler, OpenSSL, libuv, and nghttp2 for current releases.
Package availability and build dependencies are delegated to the operating
system repositories used by each supported platform.

## Known Issues

* Windows is not supported by BIND 9.18 and later.
* Legacy cookbook recipes and node attributes are removed. Use the `bind_*`
  custom resources directly from a wrapper or policy cookbook.
