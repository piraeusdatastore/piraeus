#!/bin/bash -ex

# drop scripts
mkdir -p /init/conf
cp -vfr /root/cmd /init/
chmod +x -R /root/cmd

# configure each component
if [[ ${THIS_POD_NAME} =~ -etcd-[0-9]+$ ]]; then
    echo Configure etcd
    /init/cmd/config-etcd.sh
elif [[ ${THIS_POD_NAME} =~ -controller-[0-9]+$ ]]; then
    echo Configure controller
    /init/cmd/config-controller.sh
elif [[ ${THIS_POD_NAME} =~ -node-[0-9a-z]+$ ]]; then
    echo Configure node
    /init/cmd/config-node.sh
else
    echo Failed to identify the component 
    exit 1
fi
