# drbd-driver-loader

This is a collection of Piraeus container images containing the [DRBD](https://github.com/LINBIT/drbd-9.0)
kernel source code that can be used to compile DRBD kernel modules from source and load them into the host
kernel.

# How to use

Note that for this to work, the kernel headers are bind-mounted from the host to the container. Therefore, you
need to install the according headers on the host system (e.g., `yum install kernel-devel`).

LINBIT provides containers that can directly install pre-built kernel modules on the host without
compiling/the requirement to have kernel headers installed.

## RHEL/Centos systems:

```sh
docker run -it --rm --privileged \
   -v /lib/modules:/lib/modules:ro -v /usr/src:/usr/src:ro \
   piraeusdatastore/drbd9-centos7:latest
```

## Ubuntu based systems:

```sh
docker run -it --rm --privileged \
   -v /lib/modules:/lib/modules:ro -v /usr/src:/usr/src:ro -v /usr/lib:/usr/lib:ro \
   piraeusdatastore/drbd9-bionic:latest
```

## Installing the kernel objects to the host

This feature is available since version 9.0.20. One has to mark the bind mounted `/lib/modules`
directory writable (by removing the ':ro'), and set the environment variable "LB_INSTALL" to "yes". For
RHEL/Centos this looks like this:

```sh
docker run -it --rm --privileged \
   -v /lib/modules:/lib/modules -v /usr/src:/usr/src:ro \
   -e "LB_INSTALL=yes" \
   piraeusdatastore/drbd9-centos7:latest
```

# Registries
- [Docker Hub](https://hub.docker.com/r/piraeusdatastore/)
- [quay.io](https://quay.io/repository/piraeusdatastore/)

# How does this differ from LINBIT's LINSTOR?
The containers we provide in the Piraeus project are Debian based and packages get installed from a
PPA. These are maintained at a best effort basis, but make sure to understand the
[differences](https://launchpad.net/~linbit/+archive/ubuntu/linbit-drbd9-stack) between these packages and the
ones provided by LINBIT for its customers.

Container used for module loading are based on Centos/Ubuntu.

Additionally, container images provided by LINBIT as commercal offer on [drbd.io](http://drbd.io), are based
on RHEL/UBI images and are for example OpenShift certified.

# Maintainer workflow
- `make update TAG=v1.0.0 NOCACHE=true`
- `make upload TAG=v1.0.0 REGISTRY='quay.io/piraeusdatastore piraeusdatastore'`
