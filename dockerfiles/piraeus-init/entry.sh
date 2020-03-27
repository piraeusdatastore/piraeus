#!/bin/bash -e
${INIT_DEBUG,,} && set -x

# drop files to /init
cp -fr /files/* /init
[[ -d /init/tmp ]] || mkdir -v /init/tmp # for storing temp data for curl

# configure each component
case $1 in
    initEtcd)
        echo "* Initialize etcd"
        /init/bin/init-etcd.sh
        ;;
    initController)
        echo "* Initialize controller"
        /init/bin/init-controller.sh
        ;;
    initNode)
        echo "* Initialize node"
        /init/bin/init-node.sh
        ;;
    initScaler)
        echo "* Run tasks"
        /init/bin/init-scaler.sh
        ;;
    * )
        echo "* Missing argument"
        exit 1
        ;;
esac    