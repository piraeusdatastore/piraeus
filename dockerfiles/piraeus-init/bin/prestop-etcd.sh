#!/bin/sh
data_dir=/var/lib/etcd/data
# backup data dir if not empty
if [ -d "$data_dir" ] && [ "$( ls -A "$data_dir" )" ]; then
    mod_time="$( date +%Y-%m-%d_%H-%M-%S -r "$data_dir" )"
    cp -vfr "$data_dir" "${data_dir}_${mod_time}"
fi

etcdctl get --prefix "LINSTOR/" -w simple > "${data_dir}_${mod_time}/keys.txt"
etcdctl get --prefix "LINSTOR/" -w json > "${data_dir}_${mod_time}/keys.json"