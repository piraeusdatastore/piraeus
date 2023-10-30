ARG DISTRO=bookworm
FROM debian:$DISTRO

ARG KTLS_UTILS_VERSION
ARG DISTRO

RUN { echo 'APT::Install-Recommends "false";' ; echo 'APT::Install-Suggests "false";' ; } > /etc/apt/apt.conf.d/99_piraeus
RUN apt-get update && apt-get install -y wget ca-certificates
RUN apt-get install -y gnupg2 && \
	 wget -O- https://packages.linbit.com/package-signing-pubkey.asc | gpg --dearmor > /etc/apt/trusted.gpg.d/linbit-keyring.gpg && \
	 echo "deb http://packages.linbit.com/public" $DISTRO "misc" > /etc/apt/sources.list.d/linbit.list && \
	 apt-get update && \
	 apt-get install -y ktls-utils=$KTLS_UTILS_VERSION && \
	 apt-get clean

COPY --chmod=0600 tlshd.conf /etc/tlshd.conf

CMD ["/usr/sbin/tlshd", "--stderr"]
