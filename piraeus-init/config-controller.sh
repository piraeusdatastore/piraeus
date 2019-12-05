#!/bin/bash

ETCD_CLUSTER=$( etcdctl member list | sed 's/,//g' |  awk '{print $5}' | paste -d, - - - )

    cat > /etc/linstor/linstor.toml <<EOF
[db]
user = "linstor"
password = "linstor"
connection_url = "etcd://${ETCD_CLUSTER}"
EOF
    cat /etc/linstor/linstor.toml
fi