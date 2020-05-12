#!/bin/bash

/var/run/task

# restart pod if configmap gets updated
trap 'exit 0' SIGTERM SIGINT
previous_checksum="$( sha256sum /var/run/task )"
while sleep 5; do
    current_checksum="$( sha256sum /var/run/task )"
    [ "$current_checksum" != "$previous_checksum" ] && echo "* New task arrived!" && exit 0
done