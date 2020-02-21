# Piraeus Datastore - HA Datastore for Kubernetes

Piraeus is a high performance (i.e., in Linux kernel), highly-available, simple, secure, and cloud agnostic
data store for Kubernetes.

## Getting started

### Requirements

Using a Kubernetes cluster with at least 4 worker nodes is recommended. Due to CSI compatibility, kubelet version must be one of:

 * v1.14.x
 * v1.15.x
 * v1.16.x
 * v1.17.x

The hosts should use Docker as their container runtime and be running one of the following distributions to enable automatic DRBD kernel module injection:

* CentOS/RHEL 7
* CentOS/RHEL 8
* Ubuntu 16
* Ubuntu 18


### Node selection

The nodes on which piraeus should provide or consume storage should be labelled as follows:

```
kubectl label nodes $NODE_NAME piraeus/enabled=true
```

These nodes must also have the appropriate kernel development package installed unless DRBD is already present.
This is `kernel-devel` for CentOS based distributions and `` linux-headers-`uname -r` `` for Ubuntu.

### Installation

Install as follows:

```
kubectl apply -f https://raw.githubusercontent.com/piraeusdatastore/piraeus/master/deploy/all.yaml
```

This may take several minutes. You may observe the pods by command: 
```
kubectl -n kube-system get pod -l app.kubernetes.io/name=piraeus
```
Once the pods have started, the status of Piraeus can be checked by following commands.

On each Kubernetes work node where piraeus is deployed:
```
/opt/piraeus/client/linstor node list
```

Also on Kuberntes master nodes:
```
kubectl -n kube-system exec -it \
"$( kubectl -n kube-system get pod \
-l app.kubernetes.io/component=piraeus-controller \
--field-selector status.phase=Running -o name )" \
-- linstor node list
```

This should show that the selected nodes are `Online` at the LINSTOR level.

### Using storage (demo)

Piraeus preconfigures a `DfltStorPool` by using LINSTOR's `FileThin` backend, which is ready to use after yaml deployment.

The [demo](demo) directory contains examples of how to use `DfltStorPool`.
For instance:

```
kubectl apply -f https://raw.githubusercontent.com/piraeusdatastore/piraeus/master/demo/demo-sts.yaml
```

This demo statefulset is a 3-node MySQL cluster. Demo pods and pvcs are under `piraeus` namespace.

### Storage configuration

Piraeus can use storage that is local to the application as well as storage on other nodes.
On the nodes that should provide storage, backing devices must be available.
Assuming the hosts have empty storage devices of at least 1GB capacity, they can be listed as follows:

```
linstor physical-storage list
```

Piraeus can then configure LVM on these devices and create a storage pool.
Use the following steps for each node:

```
linstor physical-storage create-device-pool --pool-name pool0 LVM $NODE_NAME /dev/$DEVICE
linstor storage-pool create lvm $NODE_NAME DfltStorPool pool0
```

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
