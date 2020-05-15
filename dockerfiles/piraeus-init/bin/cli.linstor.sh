#!/bin/sh

docker run --rm --net host -it \
--env-file /opt/piraeus/client/env \
-v /opt/piraeus/client/resolv.conf:/etc/resolv.conf \
quay.io/piraeusdatastore/piraeus-client --no-utf8 "$@"