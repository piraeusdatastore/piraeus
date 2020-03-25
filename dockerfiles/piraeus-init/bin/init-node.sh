#!/bin/bash -e
${INIT_DEBUG,,} && set -x

# import functions
source /init/bin/lib.linstor.sh
source /init/bin/lib.docker.sh
source /init/bin/lib.tools.sh

# wait until controller is up
SECONDS=0
while [ "${SECONDS}" -lt '3600' ];  do
    if curl -Ss --connect-timeout 2 "${LS_CONTROLLERS}" | grep 'Linstor REST server'; then
        echo '... controller is UP'
        break
    else
        echo '... controller is DOWN'
    fi
    sleep 1
done

# register node to cluster
THIS_POD_IF=$( _get_if_by_ip "${THIS_POD_IP}" )
echo "This node IP: ${THIS_POD_IP}@${THIS_POD_IF}"

if _linstor_has_node "${THIS_NODE_NAME}" ; then
    echo "WARN: This node name \"${THIS_NODE_NAME}\" is already registered"
elif _linstor_has_node_ip ${THIS_POD_IP}; then
    echo "WARN: This node ip \"${THIS_POD_IP}\" is already registered"
else
    echo "* Add node \"${THIS_NODE_NAME}\" to the cluster"
     _linstor_node_create "${THIS_NODE_NAME}" "${THIS_POD_IF}" "${THIS_POD_IP}" 3366 plain true
fi

echo 'Now cluster has nodes:'
_linstor_node_list "${THIS_NODE_NAME}"

# find and inherit current image repo
CONTAINER_ID="$( cat /proc/self/cgroup | grep :pids:/kubepods/pod${THIS_POD_UID} | awk -F/ '{print $NF}' )"
THIS_IMG=$( _docker_ps | jq -r ".[] | select(.Id == \"${CONTAINER_ID}\") | .Image" )
echo "${THIS_IMG}"
[[ "${THIS_IMG}" == "${THIS_IMG%/*}" ]] && THIS_IMG_REPO='docker.io/library' || THIS_IMG_REPO="${THIS_IMG%/*}"
echo "${THIS_IMG_REPO}"

# enable devicemapper thin-provisioning
echo '* Enable dm_thin_pool'
lsmod | grep -q ^dm_thin_pool || modprobe dm_thin_pool
lsmod | grep -E '^dm_thin_pool|^Module'

# compile and install drbd kernel module
if lsmod | grep -q drbd ; then
    echo 'DRBD module is already loaded'
    lsmod | grep -E '^drbd|^Module'
    modinfo drbd || echo "* WARN: DRBD binary is missing"
elif [[ "v$( modinfo drbd | awk '/^version: / {print $2}' )" == "${DRBD_IMG_TAG}-1" ]]; then
    echo "* Load drbd module version \"${DRBD_IMG_TAG}\""
    modprobe drbd
    modprobe drbd_transport_tcp
    lsmod | grep -E '^drbd|^Module'
    modinfo drbd
elif [[ ${DRBD_IMG_TAG,,} == 'none' ]]; then
    echo '* Skip drbd installation'
else
    # find image name according to linux distribution
    if [[ "$( uname -r )" =~ el7 ]]; then
        DRBD_IMG_NAME=drbd9-centos7
    elif [[ "$( uname -r )" =~ el8 ]]; then
        DRBD_IMG_NAME=drbd9-centos8
    elif [[ "$( uname -a )" =~ Ubuntu ]]; then
        DRBD_IMG_NAME=drbd9-bionic
        [[ "$( uname -r )" =~ 4\.15\. ]] && MOUNT_USR_LIB=/usr/lib:/usr/lib:ro
    fi

    # run drbd9 driver loader
    DRBD_IMG_URL="${THIS_IMG_REPO}/${DRBD_IMG_NAME}:${DRBD_IMG_TAG}"
    echo "* Compile and load drbd module by image \"${DRBD_IMG_URL}\""
    if [[ "${DRBD_IMG_PULL_POLICY}" == "Always" ]] || [[ "$( _docker_image_inspect ${DRBD_IMG_URL} | jq '.Id' )" == "null" ]]; then
        _docker_pull "${DRBD_IMG_URL}"
    fi
    _docker_run_drbd_driver_loader "${DRBD_IMG_URL}" "${MOUNT_USR_LIB}"
fi

# install linstor cli script
echo "* Install local linstor cli"
sed -i "s#quay.io/piraeusdatastore/#${THIS_IMG_REPO}/#" /init/bin/linstor.sh
CLI_DIR="/opt/${THIS_POD_NAME/-*/}/client"
mkdir -vp "${CLI_DIR}"
cp -vf /init/bin/linstor.sh "${CLI_DIR}/linstor"
cp -vf /etc/resolv.conf "${CLI_DIR}/"
printenv > "${CLI_DIR}/env"
ln -fs "${CLI_DIR}/linstor"  /usr/local/bin/linstor