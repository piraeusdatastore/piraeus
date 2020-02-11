#!/bin/bash -ex
source /init/cmd/tools.sh

# identify network mode, and get ip and address
ETCD_IP=${THIS_POD_IP}
if [[ "${THIS_NODE_IP}" == "${THIS_POD_IP}" ]]; then
    echo Found host network, using host ip
    ETCD_ADDR=${ETCD_IP}
elif [[ "${HOSTNAME}" == "${THIS_POD_NAME}" ]]; then
    echo Found kube network, using pod dns name
    #THIS_STS_NAME=$( echo ${THIS_POD_NAME} | sed 's/-[0-9]*$//' )
    ETCD_ADDR="${THIS_POD_NAME}.${THIS_POD_NAME/-[0-9]*/}.${THIS_POD_NAMESPACE}"
else
    echo Unable to identify network mode
    exit 1
fi

# set internal ports to svc ports
PEER_PORT=${PIRAEUS_ETCD_SERVICE_PORT_PEER}
CLIENT_PORT=${PIRAEUS_ETCD_SERVICE_PORT_CLIENT}
export ETCDCTL_ENDPOINTS="http://${PIRAEUS_ETCD_SERVICE_HOST}:${CLIENT_PORT}"

# add to cluster and
if [ ! -f /init/conf/etcd.conf ]; then
    echo Adding node to the cluster
    if [[ ${THIS_POD_NAME} =~ -etcd-0$ ]] && ! _best-effort etcdctl endpoint status; then
        INI_STATE=new
    elif _best-effort etcdctl member list; then
        INI_STATE=existing
        EXISTING_CLUSTER=$( cat /init/.best_effort_ouput | grep -v ${ETCD_ADDR} | sed 's/,//g' |  awk ' /-etcd-[0-9]+/ {print ","$3"="$4}' )
        _best-effort etcdctl member add etcd-${ETCD_ADDR} --peer-urls=http://${ETCD_ADDR}:${PEER_PORT}
    else
        exit 1
    fi

    # write config file
    cat > /init/conf/etcd.conf <<EOF
name: ${THIS_POD_NAME}
max-txn-ops: 1024
listen-peer-urls: http://${ETCD_IP}:${PEER_PORT}
listen-client-urls: http://${ETCD_IP}:${CLIENT_PORT}
advertise-client-urls: http://${ETCD_ADDR}:${CLIENT_PORT}
initial-advertise-peer-urls: http://${ETCD_ADDR}:${PEER_PORT}
initial-cluster-token: piraeus-etcd-cluster
initial-cluster: "${THIS_POD_NAME}=http://${ETCD_ADDR}:${PEER_PORT}${EXISTING_CLUSTER}"
initial-cluster-state: ${INI_STATE}
data-dir: /var/run/etcd/data
enable-v2: true
EOF
fi

# check config file
cat /init/conf/etcd.conf

# get local endpoints
echo http://${ETCD_IP}:${CLIENT_PORT} > /init/conf/etcd_local_endpoint
