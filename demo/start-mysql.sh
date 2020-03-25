#!/bin/bash -x 

cat demo-sts-mysql.yaml \
| sed 's/docker.io/dockerhub.azk8s.cn/; s/gcr.io/gcr.azk8s.cn/' \
| kubectl apply -f -