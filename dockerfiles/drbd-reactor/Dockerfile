ARG DISTRO=bullseye
FROM debian:$DISTRO

ARG DRBD_REACTOR_VERSION
ARG DISTRO

RUN { echo 'APT::Install-Recommends "false";' ; echo 'APT::Install-Suggests "false";' ; } > /etc/apt/apt.conf.d/99_piraeus
RUN apt-get update && apt-get install -y wget ca-certificates
RUN apt-get install -y gnupg2 && \
	 wget -O- https://packages.linbit.com/package-signing-pubkey.asc | gpg --dearmor > /etc/apt/trusted.gpg.d/linbit-keyring.gpg && \
	 echo "deb http://packages.linbit.com/public" $DISTRO "misc" > /etc/apt/sources.list.d/linbit.list && \
	 apt-get update && \
	 apt-get install -y drbd-utils drbd-reactor=$DRBD_REACTOR_VERSION && \
	 apt-get clean

CMD ["/usr/sbin/drbd-reactor"]
