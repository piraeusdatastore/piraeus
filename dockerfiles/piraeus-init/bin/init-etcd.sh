#!/bin/bash -ex

source /init/bin/lib.etcd.sh

# Get set name
pod_set="${POD_NAME/-[0-9]*/}"

# create data dir and backup the old if exits
_etcd_reset_data_dir

# Assemble cluster
if _etcd_is_healthy "$ETCD_ENDPOINT"; then
    # clean up duplicated member in case prestop cleanup fails
    _etcd_has_old_member "$POD_NAME" && \
    _etcd_remove_member "$POD_NAME" && \
    _etcd_reset_data_dir

    cluster_state=existing
    cluster="$( _etcd_cluster ),${POD_NAME}=http://${POD_IP}:${PEER_PORT}"

    _etcd_has_member "$POD_NAME" || \
    _etcd_add_member "$POD_NAME" "http://${POD_IP}:${PEER_PORT}"
else
    cluster_state=new
    cluster="${POD_NAME}=http://${POD_IP}:${PEER_PORT}"
fi


# write config file
cat > /init/etc/etcd/etcd.conf << EOF
name:                        ${POD_NAME}
max-txn-ops:                 1024
listen-peer-urls:            http://${POD_IP}:${PEER_PORT}
listen-client-urls:          http://${POD_IP}:${CLIENT_PORT},http://127.0.0.1:${CLIENT_PORT}
advertise-client-urls:       http://${POD_IP}:${CLIENT_PORT}
initial-advertise-peer-urls: http://${POD_IP}:${PEER_PORT}
initial-cluster-token:       ${pod_set}
initial-cluster:             ${cluster}
initial-cluster-state:       ${cluster_state}
data-dir:                    /var/lib/etcd/data
enable-v2:                   true
EOF
cat /init/etc/etcd/etcd.conf
