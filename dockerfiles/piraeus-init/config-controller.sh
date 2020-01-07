#!/bin/bash -ex

# wait until etcd is healthy
ETCD_IS_HEALTHY=false
SECONDS=0
until ${ETCD_IS_HEALTHY};  do
    if [ "${SECONDS}" -ge  "${TIMEOUT}" ]; then
        echo Timed Out !
        exit 1
    fi 
    for i in $( echo $ETCD_URLS | tr ',' '\n' ); do
        if curl -s --connect-timeout 2 $ETCD_URLS/health | grep -w 'true'; then
            ETCD_IS_HEALTHY=true
            break
        fi
    done  
done 

# configure controller
cat > /etc/linstor/linstor.toml <<EOF
[db]
user = "linstor"
password = "linstor"
connection_url = "etcd://${ETCD_URLS}"
EOF

cat /etc/linstor/linstor.toml