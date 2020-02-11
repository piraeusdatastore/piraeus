#!/bin/bash -e
${INIT_DEBUG,,} && set -x

# drop scripts
mkdir -p /init/conf /init/cmd
cp -f /root/cmd/*.sh /init/cmd/
chmod +x -R /root/cmd

# configure each component
if [[ ${THIS_POD_NAME} =~ -etcd-[0-9]+$ ]]; then
    /init/cmd/config-etcd.sh
elif [[ ${THIS_POD_NAME} =~ -controller-[0-9]+$ ]]; then
    /init/cmd/config-controller.sh
elif [[ ${THIS_POD_NAME} =~ -node-[0-9a-z]+$ ]]; then
    /init/cmd/config-node.sh
else
    echo Failed to identify the component 
    exit 1
fi
