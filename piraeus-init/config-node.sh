#!/bin/bash

 # load drbd modules
grep '^drbd ' /proc/modules || modinfo drbd && modprobe -v drbd
grep '^drbd_transport_tcp ' /proc/modules || modinfo drbd_transport_tcp && modprobe -v drbd_transport_tcp

# wait until node process is up
until nc -zvw2 127.0.0.1 3366 ; do
    sleep 0.5 
    echo ${SECONDS} >> /tmp/poststart.log
    if [ "${SECONDS}" -ge 60 ]; then
        echo ERR: Unable to reach satellite
        exit 0 # Don't block node readiness
    fi
done

# wait until node is online
until linstor node list -p | tee -a /tmp/poststart.log | grep -w "${HOSTNAME}" | grep -w Online; do
    sleep 2
    echo ${SECONDS} >> /tmp/poststart.log
    if [ "${SECONDS}" -ge 60 ]; then
        echo ERR: Satellite online-check timed out >> /tmp/poststart.log
        exit 0 # Don't block node readiness
    fi
done

[ -d ${DfltStorPool_Dir} ] || mkdir -vp ${DfltStorPool_Dir}
if linstor storage-pool list -p | tee -a /tmp/poststart.log | grep -w "${HOSTNAME}" | grep -w DfltStorPool; then 
    exit 0 
else 
    linstor storage-pool create filethin ${HOSTNAME} DfltStorPool ${DfltStorPool_Dir} >> /tmp/poststart.log 2>&1 
fi 

# Check if controller is up  

SECONDS=0
until curl -sS ${LS_CONTROLLERS} --connect-timeout 2 ; do
sleep 0.5
if [ "${SECONDS}" -ge  "${TIMEOUT}" ]; then
    echo ERR: Unable to reach controller 
    exit 0 # Don't block node from coming up
fi
done

# Obtain node ip and interface
CONTROLLER_IP=$( getent hosts piraeus-controller.piraeus | awk '{print $1}' )
HOST_IF=$( ip route get ${CONTROLLER_IP} | grep -o 'dev [^ ]*' | awk '{print $2}' )
HOST_IP=$( ifconfig ${HOST_IF} | grep -o 'inet [^ ]*' | awk '{print $2}' )

# Register node to controller by "Best-Effort"
if linstor node list -p | tail -n+3 | grep -w "${HOSTNAME}\|${HOST_IP}"; then
    echo WARN: This node is already the cluster
    linstor node list -p 
elif linstor node create ${HOSTNAME} ${HOST_IP} --node-type Satellite --interface-name ${HOST_IF}; then
    echo INFO: Successfully added this node to the cluster
    linstor node list -p -N ${HOSTNAME}  
else 
    echo ERR: Failed to add this node to the cluster
    linstor node list -p 
fi