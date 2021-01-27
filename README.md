# Piraeus Datastore - High-Availability Datastore for Kubernetes

Piraeus is a high performance, highly-available, simple, secure, and cloud agnostic storage solution for Kubernetes.

The Piraeus Project consists of:
* A [Helm Chart and Kubernetes Operator] to create, configure and maintain all components of Piraeus.
* A [CSI Driver] to provision persistent volumes and snapshots on the storage cluster maintained by Piraeus.
* A [High Availability Controller] to speed up the failover process of stateful workloads
* Container images for the open source components Piraeus is built on:
  * [DRBD] is used as the underlying storage replication mechanism between cluster nodes.
    [Documentation](https://docs.linbit.com/docs/users-guide-9.0/) is provided by [LINBIT](https://www.linbit.com/).
  * [LINSTOR] creates and manages volumes on request of the CSI Driver, sets up replication using DRBD and prepares
    the backing storage devices.
    [Documentation](https://docs.linbit.com/docs/linstor-guide/) is provided by [LINBIT](https://www.linbit.com/).

[Helm Chart and Kubernetes Operator]: https://github.com/piraeusdatastore/piraeus-operator
[CSI Driver]: https://github.com/piraeusdatastore/linstor-csi
[High Availability Controller]: https://github.com/piraeusdatastore/piraeus-ha-controller 
[DRBD]: https://github.com/LINBIT/drbd-9.0
[LINSTOR]: https://github.com/LINBIT/linstor-server

## Getting started

Installing Piraeus can be as easy as:

```
$ git clone https://github.com/piraeusdatastore/piraeus-operator.git
$ cd piraeus-operator
$ git checkout v1.3.1 # Switch to the latest release!
$ helm install piraeus-op ./charts/piraeus 
```

Head on over to the [Piraeus Operator repository] to learn more. It contains detailed instructions on how to get started
using Piraeus.

[Piraeus Operator repository]: https://github.com/piraeusdatastore/piraeus-operator

It also contains a set of basic YAML files for deployment without Helm. See [here](https://github.com/piraeusdatastore/piraeus-operator/tree/master/deploy).

This repository also contains a set of YAML files for deploying Piraeus without the aid of the Piraeus Operator. Since
they are no longer actively maintained, they have been moved to [legacy](./legacy/).

### Contributing

You are welcome to contribute on Piraeus. See [CONTRIBUTING.md](./CONTRIBUTING.md) for how to get started.

### Community

Active communication channels:

* [Slack](https://piraeus-datastore.slack.com/join/shared_invite/enQtOTM4OTk3MDcxMTIzLTM4YTdiMWI2YWZmMTYzYTg4YjQ0MjMxM2MxZDliZmEwNDA0MjBhMjIxY2UwYmY5YWU0NDBhNzFiNDFiN2JkM2Q)

### License

Piraeus Datastore is licensed under the Apache License, Version 2.0. See [LICENSE](./LICENSE).
