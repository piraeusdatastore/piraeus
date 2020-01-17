FROM debian:buster

MAINTAINER Roland Kammerer <roland.kammerer@linbit.com>

RUN { echo 'APT::Install-Recommends "false";' ; echo 'APT::Install-Suggests "false";' ; } > /etc/apt/apt.conf.d/99_piraeus
RUN apt-get update && apt-get install -y wget ca-certificates
RUN apt-get install -y gnupg2 && \
    wget -O- https://packages.linbit.com/package-signing-pubkey.asc | apt-key add - && \
    echo "deb http://packages.linbit.com/piraeus buster drbd-9.0" > /etc/apt/sources.list.d/linbit.list && \
    apt-get update && \
    apt-get install -y linstor-client && \
    apt-get autoremove -y gnupg2 && apt-get clean
# candidates for squashing:
#	 && rm -rf /usr/share/doc /usr/share/man /var/cache/debconf /usr/share/locale /usr/bin/perl

ENTRYPOINT ["linstor"]
