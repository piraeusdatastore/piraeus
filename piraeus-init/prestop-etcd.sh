#!/bin/sh -x
# save log 
exec 2> /var/log/k8s-lifecycle.log
echo PRESTOP:

export ETCDCTL_ENDPOINTS=$( cat /init/conf/etcd_local_endpoint )
MEMBER_ID=$( cat /init/conf/etcd_member_id )
etcdctl member remove ${MEMBER_ID} || true 
mv -vf /var/run/etcd/data /var/run/etcd/data_$( date +%Y-%m-%d_%H-%M-%S )