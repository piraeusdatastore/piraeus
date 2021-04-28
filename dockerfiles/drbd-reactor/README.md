[![Docker Automated build](https://img.shields.io/docker/automated/piraeusdatastore/drbd-reactor.svg)](https://hub.docker.com/r/piraeusdatastore/drbd-reactor)
[![Docker Repository on Quay](https://quay.io/repository/piraeusdatastore/drbd-reactor/status "Docker Repository on Quay")](https://quay.io/repository/piraeusdatastore/drbd-reactor)

# drbd-reactor

This is the Piraeus container image packaging [LINBIT's](https://www.linbit.com) [drbd-reactor](https://github.com/LINBIT/drbd-reactor).

# How to use

The image starts `drbd-reactor` and loads the standard (empty) configuration. To apply your own configuration, place
them in `/etc/drbd-reactor.d` in the container. To communicate with DRBD, the container also needs to be started in the
host network:
```
docker run -d --name=drbd-reactor --net=host -v /path/to/config-snippets:/etc/drbd-reactor.d piraeusdatastore/drbd-reactor
```

# Registries
- [Docker Hub](https://hub.docker.com/r/piraeusdatastore/drbd-reactor)
- [quay.io](https://quay.io/repository/piraeusdatastore/drbd-reactor)

# How does this differ from LINBIT's drbd-reactor?
The containers we provide in the Piraeus project are Debian based and packages get installed from a
PPA. These are maintained at a best effort basis, but make sure to understand the
[differences](https://launchpad.net/~linbit/+archive/ubuntu/linbit-drbd9-stack) between these packages and the
ones provided by LINBIT for its customers.

Additionally, container images provided by LINBIT as commercial offer on [drbd.io](http://drbd.io), are based
on RHEL/UBI images and are for example OpenShift certified.

# Maintainer workflow
- `make update TAG=v1.0.0 NOCACHE=true`
- `make upload TAG=v1.0.0 REGISTRY='quay.io/piraeusdatastore piraeusdatastore'`
