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
        exit 0 # Don't block node from coming up
    fi
done

# add node to cluster
THIS_POD_IF=$( ip a  | grep -B2 "inet ${THIS_POD_IP}" | head -1 | awk '{print $2}' | sed 's/://g' )

if linstor node list -p | tail -n+3 | grep -w "${THIS_NODE_NAME}\|${THIS_POD_IP}"; then
    echo WARN: This node is already the cluster
    linstor node list -p 
elif linstor node create ${THIS_NODE_NAME} ${THIS_POD_IP} --node-type Satellite --interface-name ${THIS_POD_IF} ; then 
    echo INFO: Successfully added this node to the cluster
    linstor node list -p -N ${THIS_NODE_NAME} ${THIS_POD_IP} 
else 
    echo ERR: Failed to add this node to the cluster
    linstor node list -p 
fi

# # wait until node is online
# until linstor node list -p | tee -a /tmp/poststart.log | grep -w "${THIS_NODE_NAME}" | grep -w Online; do
#     sleep 2
#     echo ${SECONDS} >> /tmp/poststart.log
#     if [ "${SECONDS}" -ge 60 ]; then
#         echo ERR: Satellite online-check timed out >> /tmp/poststart.log
#         exit 0 # Don't block node readiness
#     fi
# done

# [ -d ${DfltStorPool_Dir} ] || mkdir -vp ${DfltStorPool_Dir}
# if linstor storage-pool list -p | tee -a /tmp/poststart.log | grep -w "${THIS_NODE_NAME}" | grep -w DfltStorPool; then 
#     exit 0 
# else 
#     linstor storage-pool create filethin ${THIS_NODE_NAME} DfltStorPool ${DfltStorPool_Dir} >> /tmp/poststart.log 2>&1 
# fi 