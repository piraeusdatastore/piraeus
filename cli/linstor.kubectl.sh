#!/bin/sh
kubectl -n piraeus-system exec -it piraeus-controller-0 -- linstor --no-utf8 "$@"