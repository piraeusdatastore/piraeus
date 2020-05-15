#!/bin/bash -ex

# Get statefulset name
pod_sts="${POD_NAME/-[0-9]*/}"

cluster=$( seq 0 $(( CLUSTER_SIZE - 1 )) | xargs -tI % echo "${pod_sts}-%=http://${pod_sts}-%.${pod_sts}:${PEER_PORT}" | paste -sd "," - )

# write config file
cat > /init/etc/etcd/etcd.conf << EOF
name:                        ${POD_NAME}
max-txn-ops:                 1024
listen-peer-urls:            http://${POD_IP}:${PEER_PORT}
listen-client-urls:          http://${POD_IP}:${CLIENT_PORT},http://127.0.0.1:${CLIENT_PORT}
advertise-client-urls:       http://${POD_IP}:${CLIENT_PORT}
initial-advertise-peer-urls: http://${POD_IP}:${PEER_PORT}
initial-cluster-token:       ${pod_sts}
initial-cluster:             ${cluster}
initial-cluster-state:       new
data-dir:                    /var/lib/etcd/data
enable-v2:                   true
EOF
cat /init/etc/etcd/etcd.conf
