FROM docker:18 as DOCKER

FROM quay.io/coreos/etcd:v3.3.18 as ETCD

FROM piraeusdatastore/piraeus-client:v1.0.6

# install etcdctl
COPY --from=ETCD /usr/local/bin/etcdctl /usr/local/bin/

# install docker cli
COPY --from=DOCKER /usr/local/bin/docker /usr/local/bin/

RUN set -x && \
    apt-get update -y && \
    apt-get install -y jq curl && \
    apt-get clean -y 

ADD *.sh /root/cmd/

RUN mv /root/cmd/entrypoint.sh /; chmod +x entrypoint.sh; etcdctl version; docker -v

ENTRYPOINT [ "/entrypoint.sh" ]
