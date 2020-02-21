# Access CLI

## Overview
Linstor CLI is available in both piraeus-server and piraeus-client images: the former for deployment; the latter for standalone usage.

## On Kubernetes masters
On a kubernetes node where `kubectl` works, usually a master node
```
$ cat > /usr/local/bin/linstor << 'EOF'
kubectl -n kube-system exec -it \
"$( kubectl -n kube-system get pod \
--selector app.kubernetes.io/component=piraeus-controller \
--field-selector status.phase=Running -o name )" \
-- linstor $@
EOF
$ chmod +x /usr/local/bin/linstor
```
Now, test it by running
```
$ linstor node list
```

## On Kubernetes node
On kubernetes nodes with piraeus-node deployed, linstor cli is accessible by running script `/opt/piraeus/client/linstor`

## Outside of Kubernetes

piraeus-client provides standalone access to linstor cli, but it must be pointed to piraeus-controller's REST API address, either by environmental variable `LS_CONTROLLERS` or configuration file `/etc/linstor/linstor-client.conf`. Multiple addresses are spported for failover purpose.

### Configuration example:

```
$ export LS_CONTROLLERS = 192.168.176.151:3370,192.168.176.152:3370,192.168.176.153:3370
```
or
```
$ cat > /etc/linstor/linstor-client.conf << 'EOF'
[global]
controllers = 192.168.176.151:3370,192.168.176.152:3370,192.168.176.153:3370
EOF
```

### Run piraeus-client
```
$ cat > /usr/local/bin/linstor << 'EOF'
docker run --rm -it --net host \
    -e LS_CONTROLLERS=${LS_CONTROLLERS} \
    -v /etc/linstor:/etc/linstor:ro \
    quay.io/piraeusdatastore/piraeus-client \
    $@
EOF
$ chmod +x /usr/local/bin/linstor
```
Now, test it by running
```
$ linstor node list
```
