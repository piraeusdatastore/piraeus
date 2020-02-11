#!/bin/sh
# this method is experimental
: ${CLIENT_DIR:=/opt/piraeus/client}

if [ "$1" = "INSTALL" ]; then

    rm -fr ${CLIENT_DIR}/oci
    mkdir -p ${CLIENT_DIR}/oci/rootfs
    cd ${CLIENT_DIR}/oci
    [ -z $2 ] && IMG=daocloud.io/piraeus/piraeus-client || IMG=$2
    echo Extracting image \"${IMG}\" to ${CLIENT_DIR}/oci/rootfs 
    docker export $( docker create --rm ${IMG} ) \
        | tar -xf - -C rootfs
    mv rootfs/runc ./
    mv rootfs/config.json.template ./
else
    cd ${CLIENT_DIR}/oci
    CMD=$( echo \"linstor\",\"--no-utf8\",\"$@\" | sed 's/ /","/g' )
    cat config.json.template \
        | sed "s/_COMMAND_/${CMD}/; s#LS_CONTROLLERS=#&${LS_CONTROLLERS}#" \
        > config.json
    runc run $( uuidgen )
fi
