## /dockerfiles

This directory contains `Dockerfile`s for Piraeus components. Each of the subdirectories has
a `README.md` with more information on the image.

- [drbd-driver-loader](./drbd-driver-loader) contains is a collection of Piraeus container images
  containing the [DRBD](https://github.com/LINBIT/drbd-9.0) kernel source code that can be used to compile DRBD
  kernel modules from source and load them into the host kernel.
- [drbd-reactor](./drbd-reactor) is the user space DRBD events processing and monitoring daemon.
- [piraeus-server](./piraeus-server) combines [LINBIT's](https://www.linbit.com)
  [linstor-controller and linstor-satellite](https://github.com/LINBIT/linstor-server) components, as well as the
  [linstor-client](https://github.com/LINBIT/linstor-client) which can be used for cluster setup.  It also
  contains some useful debugging tools.
- [ktls-utils](./ktls-utils) is the user space utility used to initiate the TLS handshake on behald of DRBD.

# Maintainer workflow
Let GitHub do it for you! See [our GitHub workflow!](../../.github/workflows/build-docker.yaml)

or

```shell
# See what would be build
$ docker buildx bake --print
# Build the images
$ docker buildx bake
# Push the images to the registries
$ docker buildx bake --push
```
