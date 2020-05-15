#!/bin/bash

_curl () {
    curl -Ss --connect-timeout 1 --retry 3 --retry-delay 0 "$@"
}

_linstor_node_list() {
    [[ -n "$1" ]] && node="?nodes=$1"
    _curl -X GET "${LS_CONTROLLERS}/v1/nodes${node}" \
          -H "Content-Type: application/json" \
         | jq '.'
}

_linstor_has_node() {
    [[ "$( _linstor_node_list "$1" | jq '.[0]' )" != 'null' ]]
}

_linstor_has_node_ip() {
    [[ -n "$( _linstor_node_list | jq -r ".[] .net_interfaces[] | select(.address == \"$1\" )" )" ]]
}

_linstor_node_is_online() {
    [[ "$( _linstor_node_list "$1" | jq -r '.[0].connection_status' )" == 'ONLINE' ]]
}

_linstor_node_create() {
    cat > /init/tmp/.data.json << EOF
{
    "name": "$1",
    "type": "SATELLITE",
    "net_interfaces": [
        {
            "name": "$2",
            "address": "$3",
            "satellite_port": "$4",
            "satellite_encryption_type": "$5",
            "is_active": "$6"
        }
    ]
}
EOF

    _curl -X POST "${LS_CONTROLLERS}/v1/nodes" \
          -H "accept: application/json" \
          -H "Content-Type: application/json" \
          -d @/init/tmp/.data.json \
          | jq '.'
}


_linstor_node_interface_create() {
    cat > /init/tmp/.data.json <<EOF
{
    "name": "$2",
    "address": "$3",
    "satellite_encryption_type": "$4"
}
EOF

    _curl -X POST "${LS_CONTROLLERS}/v1/nodes/$1/net-interfaces" \
          -H "accept: application/json" \
          -H "Content-Type: application/json" \
          -d @/init/tmp/.data.json \
          | jq '.'
}

_linstor_node_delete() {
    _curl -X DELETE "${LS_CONTROLLERS}/v1/nodes/k8s-node-1" \
          -H "Content-Type: application/json" \
          | jq '.'
}

_linstor_storage_pool_list() {
    _curl -X GET "${LS_CONTROLLERS}/v1/nodes/${NODE_NAME}/storage-pools" \
          -H "Content-Type: application/json" \
          | jq '.'
}

_linstor_create_storage_pool() {
    cat > /init/tmp/.data.json << EOF
{
    "storage_pool_name": "$3",
    "provider_kind": "$1",
    "props": {
        "StorDriver/FileDir": "$4"
    }
}
EOF
    _curl -X POST "${LS_CONTROLLERS}/v1/nodes/$2/storage-pools" \
          -H "Content-Type: application/json" \
          -d @/init/tmp/.data.json \
          | jq '.'

}

_linstor_has_storage_pool() {
    [[ "$( _curl -X GET "${LS_CONTROLLERS}/v1/view/storage-pools?nodes=$1&storage_pools=$2" \
                 -H 'Content-Type: application/json' \
                 | jq '.[0].storage_pool_name' )" != 'null' ]]
}

linstor_node_is_online() {
    [[ "$( linstor --machine node list --node "$1" \
            | jq '.[0].nodes[0].connection_status' )" == '2' ]]
}

linstor_has_storage_pool() {
    [[ "$( linstor --machine storage-pool list --node "$1" --storage-pools "$2" \
        | jq '.[0].stor_pools[0]' )" != 'null' ]]
}