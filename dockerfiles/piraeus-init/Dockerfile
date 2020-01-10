FROM debian:buster

RUN set -x && \
    apt-get update -y && \
    apt-get install -y jq curl && \
    apt-get clean -y 

ADD * /root/cmd/

RUN mv /root/cmd/entrypoint.sh /; chmod +x entrypoint.sh; ls -1 /root/cmd

ENTRYPOINT [ "/entrypoint.sh" ]
