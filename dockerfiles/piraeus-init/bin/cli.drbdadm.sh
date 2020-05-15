#!/bin/sh

docker run --rm --privileged -it --net host \
-v /etc/drbd.conf:/etc/drbd.conf:ro \
-v /etc/drbd.d:/etc/drbd.d:ro \
-v /var/lib/linstor.d:/var/lib/linstor.d:ro \
quay.io/piraeusdatastore/drbd-utils drbdadm "$@"