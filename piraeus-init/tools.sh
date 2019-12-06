#!/bin/bash -ex

# curl until succeed
_curl() 
{
    SECONDS=0
    until curl -s --connect-timeout 2 "$@"; do
        sleep 0.1
        [ "${SECONDS}" -ge 5 ] && return 1
    done
    return 0
}

# try until succeed
_best-effort() {
    i=0
    until "$@" > /init/.best_effort_ouput; do
        let "++i"
        [ "$i" -ge 5 ] && return 1 
    done
    cat /init/.best_effort_ouput
    return 0
}