[![Docker Automated build](https://img.shields.io/docker/automated/piraeusdatastore/piraeus-server.svg)](https://hub.docker.com/r/piraeusdatastore/piraeus-server)
[![Docker Repository on Quay](https://quay.io/repository/piraeusdatastore/piraeus-server/status "Docker Repository on Quay")](https://quay.io/repository/piraeusdatastore/piraeus-server)

# piraeus-server

This is the Piraeus container image combining [LINBIT's](https://www.linbit.com) [linstor-controller and
linstor-satellite](https://github.com/LINBIT/linstor-server) components, as well as the
[linstor-client](https://github.com/LINBIT/linstor-client) which can be used for cluster setup and debugging.

# How to use
## As a controller
```
docker run -d --name=piraeus-controller -p 3370:3370 piraeusdatastore/piraeus-server startController
```

## As a satellite
```sh
docker run -d --name=piraeus-satellite --net=host --privileged -v /dev:/dev piraeusdatastore/piraeus-server startSatellite
```

If `startSatellite` is omitted, and no other command is given, starting a satellite is the default. Host
privileges are required as this container needs access to `/dev/drbdX` or LVM devices (it actually creates
them), as well as for communicating with the DRBD kernel module via "netlink".

## As a client
```sh
docker run -it --rm -e LS_CONTROLLERS=yourcontrollerIP piraeusdatastore/piraeus-server node list
```

If the command is not `startController` and not `startSatellite`, it is interpreted as a client command. The
environment variable is used to specify the current controller's IP.

# Registries
- [Docker Hub](https://hub.docker.com/r/piraeusdatastore/piraeus-server)
- [quay.io](https://quay.io/repository/piraeusdatastore/piraeus-server)

# How does this differ from LINBIT's LINSTOR?
The containers we provide in the Piraeus project are Debian based and packages get installed from a
PPA. These are maintained at a best effort basis, but make sure to understand the
[differences](https://launchpad.net/~linbit/+archive/ubuntu/linbit-drbd9-stack) between these packages and the
ones provided by LINBIT for its customers.

Additionally, container images provided by LINBIT as commercal offer on [drbd.io](http://drbd.io), are based
on RHEL/UBI images and are for example OpenShift certified.

# Maintainer workflow
- `make update TAG=v1.0.0 NOCACHE=true`
- `make upload TAG=v1.0.0 REGISTRY='quay.io/piraeusdatastore piraeusdatastore'`
