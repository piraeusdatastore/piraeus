#!/bin/bash

_linstor_node_list() {
    [[ -z $1 ]] || NODE_NAME="?nodes=$1"
    curl -Ss --connect-timeout 2 \
         -X GET "${CONTROLLER_ENDPOINT}/v1/nodes${NODE_NAME}" \
         -H "Content-Type: application/json" \
        | jq '.'
}

_linstor_has_node() {
    [[ $( _linstor_node_list $1 | jq '.[0]' ) != 'null' ]]
}

_linstor_has_node_ip() {
    [ ! -z $( _linstor_node_list | jq -r ".[] .net_interfaces[] | select(.address == \"$1\" )" ) ]
}

_linstor_node_create() {
    cat > /init/tmp/.data.json <<EOF
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

    curl -Ss --connect-timeout 2 \
         -X POST "${CONTROLLER_ENDPOINT}/v1/nodes" \
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

    curl -Ss --connect-timeout 2 \
         -X POST "${CONTROLLER_ENDPOINT}/v1/nodes/$1/net-interfaces" \
         -H "accept: application/json" \
         -H "Content-Type: application/json" \
         -d @/init/tmp/.data.json \
        | jq '.'
}

_linstor_node_delete() {
    curl -Ss --connect-timeout 2
         -X DELETE "${CONTROLLER_ENDPOINT}/v1/nodes/k8s-node-1" \
         -H "Content-Type: application/json" \
        | jq '.'
}

_linstor_storage_pool_list() {
    curl -Ss --connect-timeout 2 \
         -X GET "${CONTROLLER_ENDPOINT}/v1/nodes/${NODE_NAME}/storage-pools" \
         -H "Content-Type: application/json" \
        | jq '.'
}

linstor_node_is_online() {
    [[ "$( linstor --machine node list --node $1 \
            | jq '.[0].nodes[0].connection_status' )" == '2' ]]
}

linstor_has_storage_pool() {
    [[ "$( linstor --machine storage-pool list --node $1 --storage-pools $2 \
        | jq '.[0].stor_pools[0]' )" != 'null' ]]
}