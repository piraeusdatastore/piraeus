# Piraeus Datastore - High-Availability Datastore for Kubernetes

Piraeus is a high performance, highly-available, simple, secure, and cloud agnostic storage solution for Kubernetes.

The Piraeus Project consists of:
* A [Kubernetes Operator] to create, configure and maintain all components of Piraeus.
* A [CSI Driver] to provision persistent volumes and snapshots on the storage cluster maintained by Piraeus.
* A [High Availability Controller] to speed up the failover process of stateful workloads
* A [Volume Affinity Controller], keeping Kubernetes Persistent Volumes reported affinity in sync with the cluster.
* Container images for the open source components Piraeus is built on:
  * [DRBD] is used as the underlying storage replication mechanism between cluster nodes.
    [Documentation](https://docs.linbit.com/docs/users-guide-9.0/) is provided by [LINBIT](https://www.linbit.com/).
  * [LINSTOR] creates and manages volumes on request of the CSI Driver, sets up replication using DRBD and prepares
    the backing storage devices.
    [Documentation](https://docs.linbit.com/docs/linstor-guide/) is provided by [LINBIT](https://www.linbit.com/).

[Kubernetes Operator]: https://github.com/piraeusdatastore/piraeus-operator
[CSI Driver]: https://github.com/piraeusdatastore/linstor-csi
[High Availability Controller]: https://github.com/piraeusdatastore/piraeus-ha-controller
[Volume Affinity Controller]: https://github.com/piraeusdatastore/linstor-affinity-controller
[DRBD]: https://github.com/LINBIT/drbd
[LINSTOR]: https://github.com/LINBIT/linstor-server

Piraeus is a [CNCF Sandbox Project](https://www.cncf.io/sandbox-projects/).

## Getting started

Installing Piraeus can be as easy as:

```
$ kubectl apply --server-side -k "https://github.com/piraeusdatastore/piraeus-operator//config/default?ref=v2"
namespace/piraeus-datastore configured
...
$ kubectl wait pod --for=condition=Ready -n piraeus-datastore -l app.kubernetes.io/component=piraeus-operator
pod/piraeus-operator-controller-manager-dd898f48c-bhbtv condition met
$ kubectl apply -f - <<EOF
apiVersion: piraeus.io/v1
kind: LinstorCluster
metadata:
  name: linstorcluster
spec: {}
EOF
```

Head on over to the [Piraeus Operator docs] to learn more. It contains detailed instructions on how to get started
using Piraeus.

[Piraeus Operator docs]: https://github.com/piraeusdatastore/piraeus-operator/tree/v2/docs

It also contains a basic Helm chart. See [here](https://github.com/piraeusdatastore/piraeus-operator/tree/v2/charts/piraeus).

### Contributing

You are welcome to contribute on Piraeus. See [CONTRIBUTING.md](./CONTRIBUTING.md) for how to get started.

### Community

Active communication channels:

* [Slack](https://piraeus-datastore.slack.com/join/shared_invite/enQtOTM4OTk3MDcxMTIzLTM4YTdiMWI2YWZmMTYzYTg4YjQ0MjMxM2MxZDliZmEwNDA0MjBhMjIxY2UwYmY5YWU0NDBhNzFiNDFiN2JkM2Q)

### License

Piraeus Datastore is licensed under the Apache License, Version 2.0. See [LICENSE](./LICENSE).
