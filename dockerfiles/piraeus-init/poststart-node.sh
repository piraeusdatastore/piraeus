#!/bin/bash -x
# save log 
exec 2> /var/log/k8s-lifecycle.log
echo POSTSTART:

# wait until node is online
until linstor node list -p | grep -w "${THIS_NODE_NAME}" | grep -w Online; do
    sleep 1
    if [ "${SECONDS}" -ge 60 ]; then
        echo ERR: Satellite online-check timed out
        exit 0 # Don't block node readiness
    fi
done

mkdir -vp ${DemoPool_Dir} || true

if ! ( linstor storage-pool list -p | grep -w "${THIS_NODE_NAME}" | grep -w DemoPool ) ; then 
    linstor storage-pool create filethin ${THIS_NODE_NAME} DemoPool ${DemoPool_Dir} 
fi 