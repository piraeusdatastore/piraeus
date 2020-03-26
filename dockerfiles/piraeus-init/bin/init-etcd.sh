#!/bin/bash -ex

source /init/bin/lib.etcd.sh

pod_set="${POD_NAME/-[0-9]*/}"
pod_num="${POD_NAME//*-}"

# assemble etcd urls
cluster="$( seq 0 $(( INIT_CLUSTER_SIZE - 1 )) | xargs -tI % echo "${pod_set}-%=http://${pod_set}-%.${pod_set}:${PEER_PORT}" | paste -sd ',' - )"

# clean up old member if joining an existing cluster
cluster_state=new
for i in $( seq 0 "$(( INIT_CLUSTER_SIZE - 1 ))" | grep -v "$pod_num" ); do
    export ETCD_ENDPOINT="http://${pod_set}-$i.${pod_set}:${CLIENT_PORT}"
    if _etcd_has_old_member "$POD_NAME"; then
        _etcd_remove_member "$POD_NAME"
        rm -fr /.etcd/data/*
        _etcd_add_member "$POD_NAME" "http://${POD_NAME}.${pod_set}:${PEER_PORT}"
        cluster_state=existing
        break
    fi
done

# write config file
cat > /init/etc/etcd/etcd.conf << EOF
name:                        ${POD_NAME}
max-txn-ops:                 1024
listen-peer-urls:            http://${POD_IP}:${PEER_PORT}
listen-client-urls:          http://${POD_IP}:${CLIENT_PORT},http://127.0.0.1:${CLIENT_PORT}
advertise-client-urls:       http://${POD_NAME}.${pod_set}:${CLIENT_PORT}
initial-advertise-peer-urls: http://${POD_NAME}.${pod_set}:${PEER_PORT}
initial-cluster-token:       ${pod_set}
initial-cluster:             ${cluster}
initial-cluster-state:       ${cluster_state}
data-dir:                    /.etcd/data
enable-v2:                   true
EOF
cat /init/etc/etcd/etcd.conf
