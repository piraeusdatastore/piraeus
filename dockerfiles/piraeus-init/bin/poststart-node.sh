#!/bin/bash
${INIT_DEBUG,,} && set -x

# save log
exec 1>> /var/log/linstor-satellite/k8s-lifecycle.log 2>&1
echo -e "\n\n#########"
echo "POSTSTART: $( date '+%Y-%m-%d %H:%M:%S' ) ${THIS_POD_NAME}"

source /init/bin/lib.linstor.sh
source /init/bin/lib.tools.sh

# wait until node is up, at least consecutive ${MIN_WAIT}
SECONDS=0
NODE_HEALTH_COUNT=0
until [ "${NODE_HEALTH_COUNT}" -ge "${MIN_WAIT}" ];  do
    if [ "${SECONDS}" -ge  "${MAX_WAIT}" ]; then
        echo Timed Out !
        exit 1
    fi
    echo "* Wait for node \"${THIS_NODE_NAME}\" to come up"
    if linstor_node_is_online ${THIS_NODE_NAME}; then
        echo '... this node is ONLINE'
        let 'NODE_HEALTH_COUNT+=1'
    else
        echo '... this node is OFFLINE'
    fi
    sleep 1
done

# add to DfltStorPool by filethin backend
POOL_NAME='DfltStorPool'
POOL_DIR="/var/local/${THIS_POD_NAME/-*/}/${POOL_NAME}"
if ! linstor_has_storage_pool ${THIS_NODE_NAME} ${POOL_NAME}; then
    echo "* Add storagepool \"${POOL_NAME}\" on node \"${THIS_NODE_NAME}\""
    mkdir -vp ${POOL_DIR}
    linstor storage-pool create filethin ${THIS_NODE_NAME} ${POOL_NAME} ${POOL_DIR}
else
    echo "StoragePool \"${POOL_NAME}\" is already created on ${THIS_NODE_NAME}"
fi

# don't block pod readiness
exit 0
