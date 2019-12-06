#!/bin/bash -ex

# load drbd modules
# grep '^drbd ' /proc/modules || modinfo drbd && modprobe -v drbd
# grep '^drbd_transport_tcp ' /proc/modules || modinfo drbd_transport_tcp && modprobe -v drbd_transport_tcp

# check if controller is up  
SECONDS=0
until curl -sS ${LS_CONTROLLERS} --connect-timeout 2 ; do
    sleep 0.5
    if [ "${SECONDS}" -ge  "${TIMEOUT}" ]; then
        echo ERR: Unable to reach controller 
        exit 1 
    fi
done

# register node to cluster
THIS_POD_IF=$( ip a  | grep -B2 "inet ${THIS_POD_IP}" | head -1 | awk '{print $2}' | sed 's/://g' )

if linstor node list -p | tail -n+3 | grep -w "${THIS_NODE_NAME}\|${THIS_POD_IP}"; then
    echo WARN: This node is already the cluster
elif linstor node create ${THIS_NODE_NAME} ${THIS_POD_IP} --node-type Satellite --interface-name ${THIS_POD_IF} ; then 
    echo INFO: Successfully added this node to the cluster
else 
    echo ERR: Failed to add this node to the cluster
    exit 1
fi

linstor node list -p 

