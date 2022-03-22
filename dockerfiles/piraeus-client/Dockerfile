ARG DISTRO=bullseye
FROM debian:$DISTRO

MAINTAINER Roland Kammerer <roland.kammerer@linbit.com>

ARG LINSTOR_CLIENT_VERSION
ARG PYTHON_LINSTOR_VERSION
ARG DISTRO

RUN { echo 'APT::Install-Recommends "false";' ; echo 'APT::Install-Suggests "false";' ; } > /etc/apt/apt.conf.d/99_piraeus
RUN apt-get update && apt-get install -y wget ca-certificates
RUN apt-get install -y gnupg2 && \
    wget -O- https://packages.linbit.com/package-signing-pubkey.asc | gpg --dearmor > /etc/apt/trusted.gpg.d/linbit-keyring.gpg && \
    echo "deb http://packages.linbit.com/public" $DISTRO "misc" > /etc/apt/sources.list.d/linbit.list && \
    apt-get update && \
    apt-get install -y linstor-client=$LINSTOR_CLIENT_VERSION python-linstor=$PYTHON_LINSTOR_VERSION && \
    apt-get autoremove -y gnupg2 && apt-get clean
# candidates for squashing:
#	 && rm -rf /usr/share/doc /usr/share/man /var/cache/debconf /usr/share/locale /usr/bin/perl

ENTRYPOINT ["linstor"]
