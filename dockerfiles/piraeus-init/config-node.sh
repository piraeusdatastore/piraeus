#!/bin/bash -e
${INIT_DEBUG,,} && set -x

# import functions
source /init/cmd/func.lib.sh

# wait until controller, at least consecutive ${MIN_WAIT}
echo '* Controller endpoints are:'
echo -e ${LS_CONTROLLERS/,/\n}

SECONDS=0
CONTROLLER_HEALTH_COUNT=0
until [ "${CONTROLLER_HEALTH_COUNT}" -ge "${MIN_WAIT}" ];  do
    if [ "${SECONDS}" -ge "${MAX_WAIT}" ]; then
        echo ${MAX_WAIT} seconds have timed out !
        exit 1
    fi
    PREV_CONTROLLER_HEALTH_COUNT="${CONTROLLER_HEALTH_COUNT}"
    for i in $( echo "${LS_CONTROLLERS}" | tr ',' '\n' ); do
        echo "${SECONDS}: Try to reach controller by curl $i"
        if curl -Ss --connect-timeout 2 $i | grep 'Linstor REST server'; then
            echo '... controller is UP'
            let "CONTROLLER_HEALTH_COUNT+=1"
            export CONTROLLER_ENDPOINT=$i
            break
        else
            echo '... controller is DOWN'
        fi
    done
    [ "${CONTROLLER_HEALTH_COUNT}" -eq ${PREV_CONTROLLER_HEALTH_COUNT} ] && CONTROLLER_HEALTH_COUNT=0
    sleep 0.5
done

# register node to cluster
THIS_POD_IF=$( _get_if_by_ip ${THIS_POD_IP} )
echo ${THIS_POD_IF} > /init/conf/this_pod_if
echo "This node IP: ${THIS_POD_IP}@${THIS_POD_IF}"

if _linstor_has_node ${THIS_NODE_NAME} ; then
    echo "WARN: This node name \"${THIS_NODE_NAME}\" is already registered"
elif _linstor_has_node_ip ${THIS_POD_IP}; then
    echo "WARN: This node ip \"${THIS_POD_IP}\" is already registered"
else
    echo "* Add node \"${THIS_NODE_NAME}\" to the cluster"
     _linstor_node_create ${THIS_NODE_NAME} ${THIS_POD_IF} ${THIS_POD_IP} 3366 plain true
fi

echo 'Now cluster has nodes:'
_linstor_node_list ${THIS_NODE_NAME}

# enable devicemapper thin-provisioning
echo '* Enable dm_thin_pool'
lsmod | grep -q ^dm_thin_pool || modprobe dm_thin_pool
lsmod | grep -E '^dm_thin_pool|^Module'

# compile and install drbd kernel module
if lsmod | grep -q drbd ; then
    echo 'DRBD module is already loaded'
    lsmod | grep -E '^drbd|^Module'
    modinfo drbd
elif [[ "v$( modinfo drbd | awk '/^version: / {print $2}' )" == "${DRBD_IMG_TAG}-1" ]]; then
    echo "* Load drbd module version \"${DRBD_IMG_TAG}\""
    modprobe drbd
    modprobe drbd_transport_tcp
    lsmod | grep -E '^drbd|^Module'
    modinfo drbd
elif [[ ${DRBD_IMG_TAG,,} == 'none' ]]; then
    echo '* Skip drbd installation'
else
    if [[ "$( uname -r ) " =~ el7 ]]; then
        DRBD_IMG_NAME=drbd9-centos7
    elif [[ "$( uname -r ) " =~ el8 ]]; then
        DRBD_IMG_NAME=drbd9-centos8
    elif [[ "$( uname -a ) " =~ Ubuntu ]]; then
        DRBD_IMG_NAME=drbd9-bionic
        MOUNT_USR_LIB=/usr/lib:/usr/lib:ro
    fi
    DRBD_IMG_URL=${DRBD_IMG_REPO}/${DRBD_IMG_NAME}:${DRBD_IMG_TAG}
    echo "* Compile and load drbd module by image \"${DRBD_IMG_URL}\""

    if [[ "${DRBD_IMG_PULL_POLICY}" == "Always" ]] || [[ "$( _docker_image_inspect ${DRBD_IMG_URL} | jq '.Id' )" == "null" ]]; then
        _docker_pull "${DRBD_IMG_URL}"
    fi
    _docker_run "${DRBD_IMG_URL}"
fi
