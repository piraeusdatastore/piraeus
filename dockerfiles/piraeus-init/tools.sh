#!/bin/bash -ex

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

# curl until succeed
_curl() 
{
    _best-effort curl -s --connect-timeout 2
}