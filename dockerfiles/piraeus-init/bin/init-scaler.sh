#!/bin/bash
${INIT_DEBUG,,} && set -ex

# import functions
source /init/bin/lib.docker.sh
source /init/bin/lib.linstor.sh
source /init/bin/lib.tools.sh

# wait until node is online
SECONDS=0
while [ "${SECONDS}" -lt '3600' ];  do
    if _linstor_node_is_online "${THIS_NODE_NAME}"; then
        echo '... this node is ONLINE'
        break
    else
        echo '... this node is OFFLINE'
    fi
    sleep 1
done

# add to DfltStorPool by filethin backend
POOL_NAME='DfltStorPool'
POOL_DIR="${POOL_BASE_DIR}/${POOL_NAME}"
if ! _linstor_has_storage_pool "${THIS_NODE_NAME}" "${POOL_NAME}"; then
    echo "* Add storagepool \"${POOL_NAME}\" on node \"${THIS_NODE_NAME}\""
    mkdir -vp "${POOL_DIR}"
    _linstor_create_storage_pool "FILE_THIN" "${THIS_NODE_NAME}" "${POOL_NAME}" "${POOL_DIR}"
else
    echo "* StoragePool \"${POOL_NAME}\" is already created on ${THIS_NODE_NAME}"
fi

# host on port 1336
while true; 
do 
    { echo -e 'HTTP/1.1 200 OK\r\n'; \
    echo 'Waiting for more piraeus tasks...'; } \
    | nc -l -p 13366 
done