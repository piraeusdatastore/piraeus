#!/bin/bash -x

kubectl delete -f demo-sts-mysql.yaml

kubectl -n piraeus-demo delete pvc data-mysql-{0..2}

sleep 5

linstor v l