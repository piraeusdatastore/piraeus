kubectl -n kube-system exec -it \
"$( kubectl -n kube-system get pod \
--selector app.kubernetes.io/component=piraeus-controller \
--field-selector status.phase=Running -o name )" \
-- linstor $@