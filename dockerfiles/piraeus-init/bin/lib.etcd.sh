#!/bin/bash 

_etcd_is_healthy() {
    [[ "$( curl -Ss --connect-timeout 2 "$1"/health | jq -r '.health' )" == 'true' ]]
}

_etcd_member_list() {
    curl -Ss --connect-timeout 2 "${ETCD_ENDPOINT}"/v2/members
}

_etcd_member_names() {
    curl -Ss --connect-timeout 2 "${ETCD_ENDPOINT}"/v2/members | jq -r '.members[].name'
}

_etcd_member_peerurls() {
    curl -Ss --connect-timeout 2 "${ETCD_ENDPOINT}"/v2/members | jq -r '.members[].peerURLs[0]'
}


_etcd_has_old_member() {
    [[ -n "$( curl -Ss --connect-timeout 2 "${ETCD_ENDPOINT}"/v2/members | jq -r ".members[] | select(.name==\"$1\")" )" ]]
}

_etcd_has_member() {
    [[ -n "$( curl -Ss --connect-timeout 2 "${ETCD_ENDPOINT}"/v2/members | jq -r ".members[] | select(.name==\"$1\")" ).clientURLs[0]" ]]
}

_etcd_member_id() {
    curl -Ss --connect-timeout 2 "${ETCD_ENDPOINT}"/v2/members | jq -r ".members[] | select(.name==\"$1\").id"
} 

_etcd_remove_member() {
    member_id="$( _etcd_member_id "$1" )"
    curl -Ss --connect-timeout 2 "${ETCD_ENDPOINT}/v2/members/${member_id}" -XDELETE
}

_etcd_add_member() {
    cat > /init/tmp/.data.json << EOF
{
    "name": "$1",
    "peerURLs": [ "$2" ]
}
EOF
    curl -Ss --connect-timeout 2 \
    -X POST "${ETCD_ENDPOINT}/v2/members" \
    -H "Content-Type: application/json" \
    -d @/init/tmp/.data.json \
    | jq '.'
}