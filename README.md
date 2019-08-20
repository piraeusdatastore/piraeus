[![Docker Automated build](https://img.shields.io/docker/automated/piraeusdatastore/piraeus-client.svg)](https://hub.docker.com/r/piraeusdatastore/piraeus-client)
[![Docker Repository on Quay](https://quay.io/repository/piraeusdatastore/piraeus-client/status "Docker Repository on Quay")](https://quay.io/repository/piraeusdatastore/piraeus-client)

# piraeus-client

This is the Piraeus container image containing the [linstor-client](https://github.com/LINBIT/linstor-client)
which can be used for cluster setup and debugging.

# How to use
```sh
docker run -it --rm -e LS_CONTROLLERS=yourcontrollerIP piraeusdatastore/piraeus-client node list
```

The environment variable is used to specify the current controller's IP.

# Registries
- [Docker Hub](https://hub.docker.com/r/piraeusdatastore/piraeus-client)
- [quay.io](https://quay.io/repository/piraeusdatastore/piraeus-client)

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
