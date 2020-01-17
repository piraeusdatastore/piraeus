FROM debian:buster

MAINTAINER Roland Kammerer <roland.kammerer@linbit.com>

RUN { echo 'APT::Install-Recommends "false";' ; echo 'APT::Install-Suggests "false";' ; } > /etc/apt/apt.conf.d/99_piraeus
RUN apt-get update && apt-get install -y wget ca-certificates
RUN apt-get install -y gnupg2 && \
	 wget -O- https://packages.linbit.com/package-signing-pubkey.asc | apt-key add - && \
	 echo "deb http://packages.linbit.com/piraeus buster drbd-9.0" > /etc/apt/sources.list.d/linbit.list && \
	 apt-get update && \
	 apt-get install -y default-jre-headless && \
	 apt-get install -y udev linstor-controller linstor-satellite linstor-client \
	 drbd-utils wget xfsprogs jq \
	 net-tools iputils-ping iproute2 dnsutils netcat sysstat curl && \
	 apt-get clean
# remove jre-headless with linstor 0.9.13

# satellite
RUN wget https://packages.linbit.com/piraeus/lvm2_2.03.02-3+b1_amd64.deb -O /tmp/l.deb && { dpkg -i /tmp/l.deb; apt-get install -y -f; } && rm -f /tmp/l.deb && apt-get remove -y udev && apt-get clean
RUN sed -i 's/udev_rules.*=.*/udev_rules=0/ ; s/udev_sync.*=.*/udev_sync=0/ ; s/obtain_device_list_from_udev.*=.*/obtain_device_list_from_udev=0/' /etc/lvm/lvm.conf

# only get zfsutils from backports
RUN echo 'deb http://deb.debian.org/debian buster-backports main contrib' > /etc/apt/sources.list && apt update && apt-get install -y zfsutils-linux && apt clean all

# controller
EXPOSE 3376/tcp 3377/tcp 3370/tcp 3371/tcp

# satellite
EXPOSE 3366/tcp 3367/tcp

COPY entry.sh /usr/bin/piraeus-entry.sh

CMD ["startSatellite"]
ENTRYPOINT ["/usr/bin/piraeus-entry.sh"]
