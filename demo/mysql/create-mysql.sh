#!/bin/bash -x

if [[ "$1" == 'cn' ]]; then
    cat demo-sts-mysql.yaml \
    | sed 's/gcr.io/gcr.azk8s.cn/' \
    | sed 's/docker.io/dockerhub.azk8s.cn/' \
    | kubectl apply -f -
else 
    kubectl apply -f demo-mysql.sh
fi

watch kubectl -n piraeus-demo -l app=mysql get po -o wide
