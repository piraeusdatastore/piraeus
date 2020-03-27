#!/bin/sh
# remove this member from the cluster and clean up the data dir

member_id="$( etcdctl member list -w fields | awk '/"MemberID"/ {print $NF}' )"

etcdctl member remove "$( printf "%x" "$member_id" )"

mv -vf /var/lib/etcd/data "/var/lib/etcd/data.$(date +%Y-%m-%d_%H-%M-%S)"