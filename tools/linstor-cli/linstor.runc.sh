#!/bin/sh
: ${IMG:=daocloud.io/piraeus/piraeus-client:latest.runc}
: ${OCI_DIR:=/opt/piraeus/client/oci}

_runc_run() {
    echo "LS_CONTROLLERS=${LS_CONTROLLERS} $@" \
    | runc run -b "${OCI_DIR}" "$( uuidgen )"
}

if [ "$1" = "--do-install" ]; then
    echo "* Installing image \"${IMG}\" to ${OCI_DIR}/rootfs"
    rm -fr "${OCI_DIR}" && mkdir -vp "${OCI_DIR}/rootfs"
    cd "${OCI_DIR}"
    docker export $( docker create --rm "${IMG}" ) \
        | tar -xf - -C rootfs \
              --checkpoint=400 --checkpoint-action=exec='printf "\b=>"'
    echo -e "\b]]"
    echo "* Installing runc and config.json"
    tar -zxvf rootfs/oci.tgz && rm -vf rootfs/oci.tgz
    echo "* Linstor client version:"
    _runc_run linstor -v
else
    _runc_run linstor --no-utf8 $@
fi
