FROM debian:buster
MAINTAINER Alex Zheng <alex.zheng@daocloud.io>

RUN { echo 'APT::Install-Recommends "false";' ; echo 'APT::Install-Suggests "false";' ; } > /etc/apt/apt.conf.d/99_piraeus
RUN set -x && \
    apt-get update -y && \
    apt-get install -y jq curl kmod && \
    apt-get clean -y 

ADD * /root/cmd/

RUN mv /root/cmd/entrypoint.sh /; chmod +x entrypoint.sh; ls -1 /root/cmd

ENTRYPOINT [ "/entrypoint.sh" ]
