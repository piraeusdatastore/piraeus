#!/bin/bash
${INIT_DEBUG,,} && set -ex

source /init/bin/lib.linstor.sh

# wait until node is online
SECONDS=0
while [ "${SECONDS}" -lt '3600' ];  do
    if _linstor_node_is_online "$NODE_NAME"; then
        echo '... this node is ONLINE'
        break
    else
        echo '... this node is OFFLINE'
    fi
    sleep 5
done