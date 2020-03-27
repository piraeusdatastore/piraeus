#!/bin/bash

_get_ip_by_if() {
    ip -f inet address | grep -w "$1" | awk '/inet / {print $2}' | sed 's#/.*##'
}

_get_if_by_ip() {
    ip -f inet address | grep -B1 "inet $1" | head -1 | awk '{print $2}' | sed 's/://g'
}