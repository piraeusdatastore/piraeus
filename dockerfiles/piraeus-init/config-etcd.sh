#!/bin/bash -ex

# assemble etcd urls
THIS_POD_SET="${THIS_POD_NAME/-[0-9]*/}"

SVC_PEER_PORT_VAR="${THIS_POD_SET^^}_SERVICE_PORT_PEER"
SVC_PEER_PORT_VAR="${SVC_PEER_PORT_VAR/-/_}"
PEER_PORT="${!SVC_PEER_PORT_VAR}"

SVC_CLIENT_PORT_VAR="${THIS_POD_SET^^}_SERVICE_PORT_CLIENT"
SVC_CLIENT_PORT_VAR="${SVC_CLIENT_PORT_VAR/-/_}"
CLIENT_PORT="${!SVC_CLIENT_PORT_VAR}"

ETCD_CLUSTER=$( seq 0 2 | xargs -tI % echo "${THIS_POD_SET}-%=http://${THIS_POD_SET}-%.${THIS_POD_SET}:${PEER_PORT}" | paste -sd "," - )

# write config file
cat > /init/conf/etcd.conf <<EOF
name:                        ${THIS_POD_NAME}
max-txn-ops:                 1024
listen-peer-urls:            http://${THIS_POD_IP}:${PEER_PORT}
listen-client-urls:          http://${THIS_POD_IP}:${CLIENT_PORT},http://127.0.0.1:${CLIENT_PORT}
advertise-client-urls:       http://${THIS_POD_NAME}.${THIS_POD_SET}:${CLIENT_PORT}
initial-advertise-peer-urls: http://${THIS_POD_NAME}.${THIS_POD_SET}:${PEER_PORT}
initial-cluster-token:       ${THIS_POD_SET}
initial-cluster:             ${ETCD_CLUSTER}
initial-cluster-state:       new
data-dir:                    /.etcd/data
enable-v2:                   true
EOF
cat /init/conf/etcd.conf

# check resolv.conf
cat /etc/resolv.conf