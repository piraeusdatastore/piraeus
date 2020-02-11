#!/bin/sh

kubectl -n kube-system exec piraeus-controller-0 -- linstor $@
