#!/bin/bash -e
${INIT_DEBUG,,} && set -x

# drop files to /init
cp -r /files/* /init

# configure each component
echo "* This pod name is ${THIS_POD_NAME}"
if [[ "${THIS_POD_NAME}" =~ -etcd-[0-9]+$ ]]; then
    echo "* Initialize etcd"
    /init/bin/init-etcd.sh
elif [[ "${THIS_POD_NAME}" =~ -controller-[0-9a-z]+-[0-9a-z]+$ ]]; then
    echo "* Initialize controller"
    /init/bin/init-controller.sh
elif [[ "${THIS_POD_NAME}" =~ -node-[0-9a-z]+$ ]]; then
    echo "* Initialize node"
    /init/bin/init-node.sh
else
    echo "* Failed to identify the component"
    exit 1
fi
