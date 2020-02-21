FROM debian:buster
MAINTAINER Alex Zheng <alex.zheng@daocloud.io>

RUN { echo 'APT::Install-Recommends "false";' ; echo 'APT::Install-Suggests "false";' ; } > /etc/apt/apt.conf.d/99_piraeus
RUN set -x && \
    apt-get update -y && \
    apt-get install -y jq curl kmod && \
    apt-get clean -y 

ADD . /files/

RUN set -x && \
    mkdir /init && \
    cd /files && \
    ls -1 && \
    chmod -vR +x bin && \
    for i in entry.sh Makefile README.md; do mv -v $i /; done

ENTRYPOINT [ "/entry.sh" ]