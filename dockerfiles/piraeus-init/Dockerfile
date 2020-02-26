FROM alpine
MAINTAINER Alex Zheng <alex.zheng@daocloud.io>

RUN set -x && \
    apk update && \
    apk add bash jq curl kmod && \
    rm -f /var/cache/apk/* 

ADD . /files/

RUN set -x && \
    mkdir -vp /init && \
    cd /files && \
    ls -1 && \
    chmod -vR +x bin && \
    for i in entry.sh Makefile README.md; do mv -v $i /; done

ENTRYPOINT [ "/entry.sh" ]