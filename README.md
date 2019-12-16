# Piraeus Datastore - HA Datastore for Kubernetes

Piraeus is a high performance (i.e., in Linux kernel), highly-available, simple, secure, and cloud agnostic
data store for Kubernetes.

## Getting started

### Requirements

Using a Kubernetes cluster with at least 4 nodes is recommended.
The hosts should use Docker as their container runtime and be running one of the following distributions to enable automatic DRBD kernel module injection:

* CentOS/RHEL 7
* CentOS/RHEL 8
* Ubuntu 18.04 

### Node selection

The nodes on which piraeus should provide or consume storage should be labelled as follows:

```
kubectl label nodes $NODE_NAME piraeus/node=true
```

These nodes must also have the appropriate kernel development package installed unless DRBD is already present.
This is `kernel-devel` for CentOS based distributions and `` linux-headers-`uname -r` `` for Ubuntu.

### Installation

Install as follows:

```
kubectl apply -f https://raw.githubusercontent.com/piraeusdatastore/piraeus/master/deploy/all.yaml
```

This may take several minutes.
Once the pods have started, the status of Piraeus can be checked with:

```
kubectl -n kube-system exec piraeus-controller-0 -- linstor node list
```

This should show that the selected nodes are `Online` at the LINSTOR level.

### Storage configuration

Piraeus can use storage that is local to the application as well as storage on other nodes.
On the nodes that should provide storage, backing devices must be available.
Assuming the hosts have empty storage devices of at least 1GB capacity, they can be listed as follows:

```
kubectl -n kube-system exec piraeus-controller-0 -- linstor physical-storage list
```

Piraeus can then configure LVM on these devices and create a storage pool.
Use the following steps for each node:

```
kubectl -n kube-system exec piraeus-controller-0 -- linstor physical-storage create-device-pool --pool-name pool0 LVM $NODE_NAME /dev/$DEVICE
kubectl -n kube-system exec piraeus-controller-0 -- linstor storage-pool create lvm $NODE_NAME DfltStorPool pool0
```

### Using storage

The [demo](demo) directory contains examples of how to use the newly configured storage.
For instance:

```
kubectl apply -f https://raw.githubusercontent.com/piraeusdatastore/piraeus/master/demo/piraeus-demo-pvc.yaml
kubectl label nodes $NODE_NAME piraeus/demo=true
kubectl apply -f https://raw.githubusercontent.com/piraeusdatastore/piraeus/master/demo/piraeus-demo-app.yaml
```

This demo app exposes some stats about the new volume as an HTTP page available on port 31279 of its host.

## Components

Piraeus consists of a number of open source components.

### DRBD

[DRBD](https://github.com/LINBIT/drbd-9.0) is used as the underlying storage replication mechanism.
[Documentation](https://docs.linbit.com/docs/users-guide-9.0/) is provided by [LINBIT](https://www.linbit.com/).

### LINSTOR

[LINSTOR](https://github.com/LINBIT/linstor-server) is used for storage management.
[Documentation](https://docs.linbit.com/docs/linstor-guide/) is provided by [LINBIT](https://www.linbit.com/).

### LINSTOR CSI Plugin

[The LINSTOR CSI plugin](https://github.com/LINBIT/linstor-csi) integrates LINSTOR with the Container Storage Interface.
[Documentation](https://docs.linbit.com/docs/linstor-guide/#ch-kubernetes) is included with the LINSTOR documentation.

## Structure of this repository

### dockerfiles

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
