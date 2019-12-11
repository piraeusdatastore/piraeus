#!/bin/bash -ex
source /init/cmd/tools.sh

# check if etcd is healthy
SECONDS=0
until [ "$( _best-effort etcdctl member list | grep -E '-etcd-[0-9]+' | wc -l )" -ge "${ETCD_CLUSTER_SIZE}" ]; do
    sleep 1
    if [ "${SECONDS}" -ge  "${TIMEOUT}" ]; then
        echo ERR: Unable to reach etcd
        exit 0 
    fi
done

ETCD_CLUSTER=$( cat /init/.best_effort_ouput | sed 's/,//g' |  awk '/-etcd-[0-9]+/{print $5}' | paste -d, - - - )

    cat > /etc/linstor/linstor.toml <<EOF
[db]
user = "linstor"
password = "linstor"
connection_url = "etcd://${ETCD_CLUSTER}"
EOF
    cat /etc/linstor/linstor.toml