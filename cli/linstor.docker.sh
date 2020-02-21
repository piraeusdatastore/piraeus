docker run --rm -it --net host \
-e LS_CONTROLLERS=${LS_CONTROLLERS} \
-v /etc/linstor:/etc/linstor:ro \
quay.io/piraeusdatastore/piraeus-client \
$@
