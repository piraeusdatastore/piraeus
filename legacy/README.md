# Legacy Deployment

:warning: The deployment configuration in this directory is no longer maintained. Please check out the [other ways]
to deploy Piraeus first.

[other ways]: ../README.md#getting-started

### Node selection

The 3 nodes on which piraeus runs etcd clusters should be labelled as follows:

```
kubectl label nodes $NODE_NAME piraeus/etcd=true
```

The nodes on which piraeus should provide or consume storage should be labelled as follows:

```
kubectl label nodes $NODE_NAME piraeus/node=true
```

These nodes must also have the appropriate kernel development package installed unless DRBD is already present.
This is `kernel-devel` for CentOS based distributions and `` linux-headers-`uname -r` `` for Ubuntu.

### Installation

Install as follows:

```
kubectl apply -f https://raw.githubusercontent.com/piraeusdatastore/piraeus/master/legacy/deploy/all.yaml
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
kubectl -n piraeus-system exec -it piraeus-controller-0 -- linstor node list
```

This should show that the selected nodes are `Online` at the LINSTOR level.

### Upgrade

`all.yaml` is only for installation.
For upgrade, please use `upgrade.yaml`. It skips etcd upgrade (which is dangerous), and storageclass upgrade (which is immutable).

```
kubectl apply -f https://raw.githubusercontent.com/piraeusdatastore/piraeus/master/legacy/deploy/upgrade.yaml
```


### Using storage (demo)

Piraeus preconfigures a `DfltStorPool` by using LINSTOR's `FileThin` backend, which is ready to use after yaml deployment.

The [demo](legacy/demo) directory contains examples of how to use `DfltStorPool`.
For instance:

```
kubectl apply -f https://raw.githubusercontent.com/piraeusdatastore/piraeus/master/legacy/demo/demo-sts.yaml
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
