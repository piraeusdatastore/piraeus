#!/bin/bash -ex
_curl() 
{
    SECONDS=0
    until curl -s --connect-timeout 2 "$@"; do
        sleep 0.1
        [ "${SECONDS}" -ge 5 ] && return 1
    done

    

    return 0
}