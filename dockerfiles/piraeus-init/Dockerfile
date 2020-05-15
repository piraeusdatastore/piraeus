FROM python:3-alpine
MAINTAINER Alex Zheng <alex.zheng@daocloud.io>

# ENV LINSTOR_API_PY_VER 1.0.11

RUN set -x && \
    apk update && \
    apk add bash jq curl libcurl kmod && \
    rm -f /var/cache/apk/* 

# RUN set -x && \
#     pip install kubernetes nsenter docker-py python-etcd && \
#     rm -vf /usr/local/bin/nsenter

# RUN set -x && \
#     mkdir -vp /tmp/linstor && \
#     cd /tmp/linstor && \
#     curl -LO "https://github.com/LINBIT/linstor-api-py/archive/v${LINSTOR_API_PY_VER}.tar.gz" && \
#     tar -zxf "v${LINSTOR_API_PY_VER}.tar.gz" && \
#     cd "linstor-api-py-${LINSTOR_API_PY_VER}" && \
#     ./setup.py install && \
#     rm -vfr /tmp/linstor

ADD . /files/

RUN set -x && \
    mkdir -vp /init && \
    cd /files && \
    ls -1 && \
    chmod -vR +x bin && \
    for i in entry.sh Makefile README.md; do mv -v $i /; done

ENTRYPOINT [ "/entry.sh" ]