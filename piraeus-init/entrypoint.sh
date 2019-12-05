#!/bin/bash -ex

# drop scripts
mkdir -p /init/conf
cp -vfr /root/cmd /init/
chmod +x -R /root/cmd

# configure etcd
if [[ ${THIS_POD_NAME} =~ -etcd-[0-9]+$ ]]; then
    /init/cmd/config-etcd.sh
fi

# wait on etcd and get etcd cluster
if [[ ${THIS_POD_NAME} =~ -controller-[0-9]+$ ]]; then
    # Check if etcd is health  
    SECONDS=0
    # until curl -sS ${ETCD_SVC}/health --connect-timeout 2 | grep -w true; do
    until [ "$( etcdctl member list | wc -l )" -ge "${ETCD_CLUSTER_SIZE}" ]; do
    sleep 2
    if [ "${SECONDS}" -ge  "${TIMEOUT}" ]; then
        echo ERR: Unable to reach etcd
        exit 0 # 
    fi
    done

    /init/cmd/config-controller.sh
fi
