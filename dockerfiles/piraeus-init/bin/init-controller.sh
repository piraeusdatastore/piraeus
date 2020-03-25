#!/bin/bash -e
${INIT_DEBUG,,} && set -x

# get etcd endpoints from linstor.toml
echo Etcd endpoints are:
echo -e "${ETCD_ENDPOINTS/,/\n}"
 
# wait until etcd is up 
SECONDS=0
while [ "${SECONDS}" -lt '3600' ];  do
    for i in $( echo "${ETCD_ENDPOINTS}" | tr ',' '\n' ); do # Considering multiple etcd addresses
        if [[ "$( curl -Ss --connect-timeout 2 $i/health | jq -r '.health' )" == 'true' ]] ; then
            echo ...etcd is healthy
            break 2
        else
            echo ...etcd is NOT healthy
        fi
    done
    sleep 0.5
done

# set up etcd
echo "* Set up etcd in /etc/linstor/linstor.toml:"
sed -i "s/_ETCD_ENDPOINTS_/${ETCD_ENDPOINTS}/" /init/etc/linstor/linstor.toml
cat /init/etc/linstor/linstor.toml
