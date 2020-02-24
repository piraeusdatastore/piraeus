#!/bin/bash
if [[ ! "${LS_CONTROLLERS/:*/}" =~ \.svc\.cluster\.local$ ]]; then
    if [[ "${LS_CONTROLLERS}" =~ :[0-9]+$ ]]; then
        export LS_CONTROLLERS="${LS_CONTROLLERS/:/.svc.cluster.local:}"
    else
        export LS_CONTROLLERS="${LS_CONTROLLERS/$/.svc.cluster.local}"
    fi
fi
sed -i "s/_CONTROLLER_FQDN_/${LS_CONTROLLERS}/" /init/etc/haproxy/haproxy.cfg
cat /init/etc/haproxy/haproxy.cfg