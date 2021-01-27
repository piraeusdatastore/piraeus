#!/bin/bash -x

if [[ "$1" == 'cn' ]]; then
    cat demo-sts-mysql.yaml \
    | sed 's#gcr.io/google-samples/#daocloud.io/piraeus/#' \
    | sed 's#docker.io/library/#daocloud.io/piraeus/#' \
    | kubectl apply -f -
else 
    kubectl apply -f demo-sts-mysql.sh
fi

watch kubectl -n piraeus-demo -l app=mysql get po -o wide