#!/bin/sh

POD="$( kubectl -n kube-system get pod \
-l app.kubernetes.io/component=piraeus-controller \
--field-selector status.phase=Running -o name )" 

kubectl -n kube-system exec -it "${POD}" -- linstor node list