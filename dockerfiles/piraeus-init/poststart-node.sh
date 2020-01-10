#!/bin/bash -x
# save log 
exec 2>> /var/log/k8s-lifecycle.log
echo POSTSTART: ${THIS_POD_NAME} $( date +%Y-%m-%d_%H-%M-%S )

# get controller endpoint
# CONTROLLER_ENDPOINT=$( awk '/controllers / {print $3}' /init/conf/linstor-client.conf )

# configure linstor cli
cp -vf /init/conf/linstor-client.conf /etc/linstor/

# install gojq for now
cp -v /init/cmd/gojq /usr/local/bin/gojq

# wait until node is up for at least 5 sec
SECONDS=0
TIMEOUT=3600
NODE_HEALTH_COUNT=0
until [ "${NODE_HEALTH_COUNT}" -ge  '5' ];  do
    if [ "${SECONDS}" -ge  "${TIMEOUT}" ]; then
        echo Timed Out !
        exit 1
    elif [[ "$( linstor --machine node list --node ${THIS_NODE_NAME} \
            | gojq '.[0].nodes[0].connection_status' )" == '2' ]]  ; then
        let 'NODE_HEALTH_COUNT+=1'
    fi 
    sleep 1
done 

mkdir -vp ${DemoPool_Dir} 

if [[ $( linstor --machine storage-pool list --node ${THIS_NODE_NAME} --storage-pools DemPool \
      | gojq '.[0].stor_pools[0]' ) == 'null' ]] ; then 
    linstor storage-pool create filethin ${THIS_NODE_NAME} DemoPool ${DemoPool_Dir} 
fi 