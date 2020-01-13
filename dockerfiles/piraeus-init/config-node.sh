#!/bin/bash -ex
source /init/cmd/func.lib.sh

if [[ ${CONTROLLER_ENDPOINTS} == 'default' ]]; then
    APP_NAME=${THIS_POD_NAME/-*/}
    CONTROLLER_ENDPOINTS_IP_VAR="${APP_NAME^^}_CONTROLLER_SERVICE_HOST"
    CONTROLLER_ENDPOINTS_PORT_VAR="${APP_NAME^^}_CONTROLLER_SERVICE_PORT_REST_API"
    CONTROLLER_ENDPOINTS="http://${!CONTROLLER_ENDPOINTS_IP_VAR}:${!CONTROLLER_ENDPOINTS_PORT_VAR}"
fi 

# wait until controller is up for at least 5 sec
SECONDS=0
TIMEOUT=3600
CONTROLLER_HEALTH_COUNT=0
until [ "${CONTROLLER_HEALTH_COUNT}" -ge  '5' ];  do
    if [ "${SECONDS}" -ge  "${TIMEOUT}" ]; then
        echo Timed Out !
        exit 1
    fi
    for i in $( echo ${CONTROLLER_ENDPOINTS} | tr ',' '\n' ); do
        if curl -Ss --connect-timeout 2 $i; then
            export CONTROLLER_ENDPOINT=$i
            let 'CONTROLLER_HEALTH_COUNT+=1'
        fi
    done 
    sleep 1
done 

# register node to cluster
THIS_POD_IF=$( ip a  | grep -B2 "inet ${THIS_POD_IP}" | head -1 | awk '{print $2}' | sed 's/://g' )

if [[ $( _linstor_node_list ${THIS_NODE_NAME} | jq '.[0]' ) != 'null' ]] ; then
    echo WARN: This node name is already registered
elif [[ ! -z $( _linstor_node_list | jq -r ".[] .net_interfaces[] | select(.address == \"${THIS_POD_IP}\" )" ) ]]; then
    echo WARN: This node ip is already registered
else
     _linstor_node_create ${THIS_NODE_NAME} ${THIS_POD_IF} ${THIS_POD_IP} 3366 plain true
fi

_linstor_node_list

# configure linstor cli
cat > /init/conf/linstor-client.conf << EOF
[global]
controllers = ${CONTROLLER_ENDPOINTS}
EOF
cat /init/conf/linstor-client.conf

# compile and install drbd kernel module

if grep -q '^drbd' /proc/modules; then 
    echo "DRBD module is already loaded:"
    cat /proc/drbd
elif [[ ${DRBD_IMG_TAG} == 'NoInstall' ]]; then
    echo "Skip loading drbd module"
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
    echo Pulling from $DRBD_IMG_URL

    if [[ "${DRBD_IMG_PULL_POLICY}" == "Always" ]] || [[ "$( _docker_image_inspect ${DRBD_IMG_URL} | jq '.Id' )" == "null" ]]; then
        _docker_pull ${DRBD_IMG_URL}
    fi
    _docker_run ${DRBD_IMG_URL}
fi