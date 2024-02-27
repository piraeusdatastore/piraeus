FROM ubuntu:bionic

ARG DRBD_VERSION=9.1.5

RUN apt-get update && apt-get upgrade -y && apt-get install -y kmod gnupg wget make gcc patch curl libelf-dev && apt-get clean

RUN wget https://github.com/LINBIT/drbd/archive/refs/tags/drbd-${DRBD_VERSION}.tar.gz -O /drbd.tar.gz && \
    wget https://github.com/LINBIT/drbd/raw/drbd-${DRBD_VERSION}/docker/entry.sh -O /entry.sh && chmod +x /entry.sh

ENV LB_HOW compile
ENTRYPOINT [ "/entry.sh" ]
