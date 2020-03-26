#!/bin/sh

member_id="$( etcdctl member list -w fields | awk '/"MemberID"/ {print $NF}' )"

etcdctl member remove "$( printf "%x" "$member_id" )"

rm -fr /.etcd/data/*