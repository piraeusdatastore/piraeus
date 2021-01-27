## /dockerfiles

This directory contains `Dockerfile`s and shell scripts for Piraeus components. Each of the subdirectories has
a `README.md` with more information.

- [drbd-driver-loader](dockerfiles/drbd-driver-loader) contains is a collection of Piraeus container images
  containing the [DRBD](https://github.com/LINBIT/drbd-9.0) kernel source code that can be used to compile DRBD
  kernel modules from source and load them into the host kernel.
- [piraeus-server](dockerfiles/piraeus-server) combines [LINBIT's](https://www.linbit.com)
  [linstor-controller and linstor-satellite](https://github.com/LINBIT/linstor-server) components, as well as the
  [linstor-client](https://github.com/LINBIT/linstor-client) which can be used for cluster setup.  It also
  contains some useful debugging tools.
- [piraeus-client](dockerfiles/piraeus-client) is a stand alone version of the [linstor-client](https://github.com/LINBIT/linstor-client).

### Warning
Changes to the subdirectory will trigger a rebuild of the associated container images
