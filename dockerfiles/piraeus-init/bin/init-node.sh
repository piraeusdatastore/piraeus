#!/bin/bash -e
${INIT_DEBUG,,} && set -x

# import functions
source /init/bin/lib.linstor.sh
source /init/bin/lib.docker.sh
source /init/bin/lib.tools.sh

# find and inherit current image repo
# container_id="$( cat /proc/self/cgroup | grep :pids:/kubepods/pod"${POD_UID}" | awk -F/ '{print $NF}' )"
# image_id="$( _docker_ps | jq -r ".[] | select(.Id == \"${container_id}\") | .ImageID" )"
# echo "* Current image ID is $image_id"
# image="$( _docker_images | jq -r ".[] | select(.Id == \"${image_id}\") | .RepoTags[0]" )"
# echo "* Current image name: $image"
# [[ "$image" == "${image%/*}" ]] && image_repo='docker.io/library' || image_repo="${image%/*}"
# echo "* Current image repository is: $image_repo"

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
        drbd_image_name=drbd9-centos7
    elif [[ "$( uname -r )" =~ el8 ]]; then
        drbd_image_name=drbd9-centos8
    elif [[ "$( uname -a )" =~ Ubuntu ]]; then
        drbd_image_name=drbd9-bionic
        # [[ "$( uname -r )" =~ 4\.15\. ]] && mount_usr_lib=/usr/lib:/usr/lib:ro
    fi

    # run drbd9 driver loader
    drbd_image_url="${DRBD_IMG_REPO}/${drbd_image_name}:${DRBD_IMG_TAG}"
    echo "* Compile and load drbd module by image \"${drbd_image_url}\""
    if [[ "${DRBD_IMG_PULL_POLICY,,}" == "always" ]] || [[ "$( _docker_image_inspect "$drbd_image_url" | jq '.Id' )" == "null" ]]; then
        _docker_pull "$drbd_image_url"
    fi
    _docker_run_drbd_driver_loader "$drbd_image_url" "$mount_usr_lib"
fi

# edit drbd.conf
cat > /etc/drbd.conf << 'EOF'
include "drbd.d/global_common.conf";
include "/etc/drbd.d/*.res";
include "/var/lib/linstor.d/*.res";
EOF
cat > /etc/drbd.d/global_common.conf << 'EOF'
global { 
    usage-count no; 
    }
EOF

# install cli script
echo "* Install local cli"
sed -i "s#quay.io/piraeusdatastore/#${DRBD_IMG_REPO}/#" /init/bin/cli.*.sh
cli_dir="/opt/${POD_NAME/-*/}/client"
mkdir -vp "$cli_dir"
cp -vuf /init/bin/cli.linstor.sh "${cli_dir}/linstor"
cp -vuf /init/bin/cli.drbdadm.sh "${cli_dir}/drbdadm"
cp -vuf /etc/resolv.conf "${cli_dir}/"
printenv > "${cli_dir}/env"
nsenter -t1 -m -- ln -vfs "${cli_dir}/linstor"  /usr/local/bin/linstor
nsenter -t1 -m -- ln -vfs "${cli_dir}/drbdadm"  /usr/local/bin/drbdadm

# wait until controller is up
SECONDS=0
while [ "${SECONDS}" -lt '3600' ];  do
    if curl -Ss --connect-timeout 2 "${LS_CONTROLLERS}" | grep 'Linstor REST server'; then
        echo '... controller is UP'
        break
    else
        echo '... controller is DOWN'
    fi
    sleep 5
done

# register node to cluster
pod_if=$( _get_if_by_ip "$POD_IP" )
echo "This node IP: ${POD_IP}@${pod_if}"

if _linstor_has_node "$NODE_NAME" ; then
    echo "WARN: This node name \"${NODE_NAME}\" is already registered"
elif _linstor_has_node_ip "$POD_IP"; then
    echo "WARN: This node ip \"${POD_IP}\" is already registered"
else
    echo "* Add node \"${NODE_NAME}\" to the cluster"
     _linstor_node_create "$NODE_NAME" "$pod_if" "$POD_IP" 3366 plain true
fi

echo 'Now cluster has nodes:'
_linstor_node_list "$NODE_NAME"