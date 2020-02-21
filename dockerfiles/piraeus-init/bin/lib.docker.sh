#!/bin/bash
_curl_docker() {
    curl -Ss --connect-timeout 2 \
         --unix-socket /var/run/docker.sock \
         -H "Content-Type: application/json" \
         $@
}

_docker_ps() {
    _curl_docker \
    -X GET "http://localhost/containers/json" \
    | jq '.'
}

_docker_images() {
    _curl_docker \
        -X GET "http://localhost/images/json" \
        | jq '.'
}

_docker_image_inspect() {
    _curl_docker \
        -X GET "http://localhost/images/$1/json" \
        | jq '.'
}

_docker_login() {
    :
}

_docker_pull() {
    _curl_docker \
        -X POST "http://localhost/images/create?fromImage=$1" \
        | jq '.'
}

_docker_start() {
    _curl_docker \
        -X POST "http://localhost/containers/$1/start" \
        | jq '.'
}

_docker_logs() {
    _curl_docker \
        -X GET "http://localhost/containers/$1/logs?stderr=1&stdout=1&follow=1"
}

_docker_run_drbd_driver_loader() {
    cat > /init/tmp/.data.json <<EOF
{
    "Image": "$1",
    "Env": [
        "LB_INSTALL=yes"
    ],
    "HostConfig": {
        "Binds": [
            "/lib/modules:/lib/modules",
            "/usr/src:/usr/src:ro"
        ],
        "Privileged": true
    }
}
EOF
    # for ubuntu
    if [[ ! -z $2 ]]; then
        mv /init/tmp/.data.json /init/tmp/.old.data.json
        cat /init/tmp/.old.data.json | jq ".HostConfig.Binds += [\"$2\"]" > /init/tmp/.data.json
    fi

    ID="$( _curl_docker \
            -X POST "http://localhost/containers/create" \
            -d @/init/tmp/.data.json \
            | jq -r '.Id' )"

    if [[ ! -z "${ID}" ]]; then
        _docker_start "${ID}"
        _docker_logs "${ID}"
    else
        echo "ERROR: Failed to create container"
    fi
}





