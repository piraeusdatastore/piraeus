FROM debian:buster

ARG DRBD_REACTOR_VERSION

RUN { echo 'APT::Install-Recommends "false";' ; echo 'APT::Install-Suggests "false";' ; } > /etc/apt/apt.conf.d/99_piraeus
RUN apt-get update && apt-get install -y wget ca-certificates
RUN apt-get install -y gnupg2 && \
	 wget -O- https://packages.linbit.com/package-signing-pubkey.asc | apt-key add - && \
	 echo "deb http://packages.linbit.com/piraeus buster drbd-9.0" > /etc/apt/sources.list.d/linbit.list && \
	 apt-get update && \
	 apt-get install -y drbd-utils drbd-reactor=$DRBD_REACTOR_VERSION && \
	 apt-get clean

CMD ["/usr/sbin/drbd-reactor"]
