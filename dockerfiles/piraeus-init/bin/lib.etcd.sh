#!/bin/bash

_curl () {
    curl -Ss --connect-timeout 1 --retry 3 --retry-delay 0 "$@"
}

_etcd_is_healthy() {
    [[ "$( _curl "$1"/health | jq -r '.health' )" == 'true' ]]
}

_etcd_member_list() {
    _curl "${ETCD_ENDPOINT}"/v2/members
}

_etcd_has_member() {
    [[ -n "$( _curl "${ETCD_ENDPOINT}"/v2/members | jq -r ".members[] | select(.name==\"$1\")" )" ]]
}

_etcd_has_old_member() {
    [[ -n "$( _curl "${ETCD_ENDPOINT}"/v2/members | jq -r ".members[] | select(.name==\"$1\").clientURLs[0]" )" ]]
}

_etcd_cluster() {
    _curl "${ETCD_ENDPOINT}"/v2/members \
    | jq -r '.members[] | select( (.name | length)>0 ) | (.name + "=" + .peerURLs[0])' \
    | paste -sd ',' -
}

_etcd_member_id() {
    _curl "${ETCD_ENDPOINT}"/v2/members | jq -r ".members[] | select(.name==\"$1\").id"
}

_etcd_remove_member() {
    member_id="$( _etcd_member_id "$1" )"
    _curl "${ETCD_ENDPOINT}/v2/members/${member_id}" -XDELETE
}

_etcd_add_member() {
    cat > /init/tmp/.data.json << EOF
{
    "name": "$1",
    "peerURLs": [ "$2" ]
}
EOF
    _curl \
    -X POST "${ETCD_ENDPOINT}/v2/members" \
    -H "Content-Type: application/json" \
    -d @/init/tmp/.data.json \
    | jq '.'
}

_etcd_backup_data_dir() {
    timestamp="$( date +%Y-%m-%d_%H-%M-%S )"
    data_dir=/var/lib/etcd/data
    [ -d "$data_dir" ] && \
    cp -vrf "$data_dir" "${data_dir}.${timestamp}"
}