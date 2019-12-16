#!/bin/bash -ex
source /init/cmd/tools.sh

# load drbd modules
# grep '^drbd ' /proc/modules || modinfo drbd && modprobe -v drbd
# grep '^drbd_transport_tcp ' /proc/modules || modinfo drbd_transport_tcp && modprobe -v drbd_transport_tcp

# check if controller is up  
SECONDS=0
until linstor node list -p; do
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

# compile and install drbd kernel module

if [[ "$( uname -r ) " =~ el7 ]]; then
    DRBD_DRIVER_LOADER_IMAGE="$REGISTRY/drbd9-centos7"
elif [[ "$( uname -r ) " =~ el8 ]]; then
    DRBD_DRIVER_LOADER_IMAGE="$REGISTRY/drbd9-centos8"
elif [[ "$( uname -a ) " =~ Ubuntu ]]; then
    DRBD_DRIVER_LOADER_IMAGE="$REGISTRY/drbd9-bionic"
    MOUNT_USR_LIB='-v /usr/lib:/usr/lib:ro'
fi

if [[ "${IMAGE_PULL_POLICY}" == "Always" ]]; then
    docker pull ${DRBD_DRIVER_LOADER_IMAGE}
fi

docker run --rm --privileged \
-v /lib/modules:/lib/modules \
${MOUNT_USR_LIB} \
-v /usr/src:/usr/src:ro \
-e "LB_INSTALL=yes" \
${DRBD_DRIVER_LOADER_IMAGE}
