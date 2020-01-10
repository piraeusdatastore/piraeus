#!/bin/bash -ex

# use built-in etcd url if no other is provided
if [[ "${ETCD_ENDPOINTS}" == 'default' ]]; then
    APP_NAME=${THIS_POD_NAME/-*/}
    ETCD_ENDPOINTS_IP_VAR="${APP_NAME^^}_ETCD_SERVICE_HOST"
    ETCD_ENDPOINTS_PORT_VAR="${APP_NAME^^}_ETCD_SERVICE_PORT_CLIENT"
    ETCD_ENDPOINTS="http://${!ETCD_ENDPOINTS_IP_VAR}:${!ETCD_ENDPOINTS_PORT_VAR}"
fi 

# wait until etcd is healthy for at least 5 sec
SECONDS=0
TIMEOUT=3600
ETCD_HEALTH_COUNT=0
until [ "${ETCD_HEALTH_COUNT}" -ge  '5' ];  do
    if [ "${SECONDS}" -ge  "${TIMEOUT}" ]; then
        echo Timed Out !
        exit 1
    fi
    for i in $( echo ${ETCD_ENDPOINTS} | tr ',' '\n' ); do
        if [[ "$( curl -Ss --connect-timeout 2 $i/health | jq -r '.health' )" == 'true' ]] ; then
            let 'ETCD_HEALTH_COUNT+=1'
        fi 
    done 
    sleep 1
done 

# configure controller
cat > /etc/linstor/linstor.toml <<EOF
[db]
user = "linstor"
password = "linstor"
connection_url = "etcd://${ETCD_ENDPOINTS}"
EOF

cat /etc/linstor/linstor.toml