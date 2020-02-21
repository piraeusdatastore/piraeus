#!/bin/bash -e
${INIT_DEBUG,,} && set -x

# get etcd endpoints from linstor.toml
echo Etcd endpoints are:
echo -e ${ETCD_ENDPOINTS/,/\n}

# wait until etcd is healthy, at least consecutive ${MIN_WAIT}
SECONDS=0
ETCD_HEALTH_COUNT=0
until [ "${ETCD_HEALTH_COUNT}" -ge  "${MIN_WAIT}" ];  do
    if [ "${SECONDS}" -ge "${MAX_WAIT}" ]; then
        echo ${MAX_WAIT} seconds have timed out !
        exit 1
    fi
    PREV_ETCD_HEALTH_COUNT="${ETCD_HEALTH_COUNT}"
    for i in $( echo "${ETCD_ENDPOINTS}" | tr ',' '\n' ); do
        echo "${SECONDS}: Trying to reach etcd by curl $i/health"
        if [[ "$( curl -Ss --connect-timeout 2 $i/health | jq -r '.health' )" == 'true' ]] ; then
            echo ...etcd is healthy
            let "ETCD_HEALTH_COUNT+=1"
            break
        else
            echo ...etcd is NOT healthy
        fi
    done
    [[ "${ETCD_HEALTH_COUNT}" -eq "${PREV_ETCD_HEALTH_COUNT}" ]] && ETCD_HEALTH_COUNT=0
    sleep 0.5
done

# set up etcd
echo "* Set up etcd in /etc/linstor/linstor.toml:"
sed -i "s/_ETCD_ENDPOINTS_/${ETCD_ENDPOINTS}/" /init/etc/linstor/linstor.toml
cat /init/etc/linstor/linstor.toml
