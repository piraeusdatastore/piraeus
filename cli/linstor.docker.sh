# This script avoids creating container when running each linstor command.
# But it is still slower than linstor.runc.sh.

#!/bin/sh
REPO=quay.io/piraeusdatastore
IMG=piraeus-client
TAG=v1.0.11

echo "$@" > /etc/linstor/.cmd

if [[ "$1" == "UPGRADE" ]] || ! docker start -a piraeus-client; then
    docker rm piraeus-client
    docker create --name piraeus-client \
              -v /etc/linstor:/etc/linstor \
              --entrypoint bash \
              ${REPO}/${IMG}:${TAG} \
              -c 'linstor $( cat /etc/linstor/.cmd )'
fi
