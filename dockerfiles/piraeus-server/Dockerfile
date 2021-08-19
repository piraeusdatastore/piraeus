FROM debian:buster

MAINTAINER Roland Kammerer <roland.kammerer@linbit.com>

ARG LINSTOR_VERSION

RUN { echo 'APT::Install-Recommends "false";' ; echo 'APT::Install-Suggests "false";' ; } > /etc/apt/apt.conf.d/99_piraeus
RUN apt-get update && apt-get install -y wget ca-certificates
RUN apt-get install -y gnupg2 && \
	 wget -O- https://packages.linbit.com/package-signing-pubkey.asc | apt-key add - && \
	 echo "deb http://packages.linbit.com/piraeus buster drbd-9.0" > /etc/apt/sources.list.d/linbit.list && \
	 apt-get update && \
	 apt-get install -y udev drbd-utils wget xfsprogs jq procps nvme-cli \
	 net-tools iputils-ping iproute2 dnsutils netcat sysstat curl \
	 util-linux cryptsetup && \
	 apt-get install -y linstor-controller=$LINSTOR_VERSION linstor-satellite=$LINSTOR_VERSION linstor-common=$LINSTOR_VERSION  linstor-client && \
	 apt-get clean

# Log directory need to be group writable. OpenShift assigns random UID and GID, without extra RBAC changes we can only influence the GID.
RUN mkdir /var/log/linstor-controller && \
	 chown 0:1000 /var/log/linstor-controller && \
	 chmod -R 0775 /var/log/linstor-controller && \
	 # Ensure we log to files in containers, otherwise SOS reports won't show any logs at all
	 sed -i 's#<!-- <appender-ref ref="FILE" /> -->#<appender-ref ref="FILE" />#' /usr/share/linstor-server/lib/conf/logback.xml

# satellite
# needs a newer lvm, debian bug #932433
COPY preferences /etc/apt/preferences
RUN echo 'deb http://deb.debian.org/debian/ bullseye main contrib' >> /etc/apt/sources.list && \
	apt-get update && apt-get install -y -t bullseye lvm2 && apt-get remove -y udev && apt-get clean
RUN sed -i 's/udev_rules.*=.*/udev_rules=0/ ; s/udev_sync.*=.*/udev_sync=0/ ; s/obtain_device_list_from_udev.*=.*/obtain_device_list_from_udev=0/' /etc/lvm/lvm.conf
RUN sed -i '/^devices {/a global_filter = [ "r|^/dev/drbd|" ]' /etc/lvm/lvm.conf

# get zfsutils from bullseye
RUN apt-get install -y -t bullseye zfsutils-linux && apt-get clean

# controller
EXPOSE 3376/tcp 3377/tcp 3370/tcp 3371/tcp

# satellite
EXPOSE 3366/tcp 3367/tcp

COPY entry.sh /usr/bin/piraeus-entry.sh

ARG K8S_AWAIT_ELECTION_VERSION
ARG TARGETARCH

RUN wget https://github.com/LINBIT/k8s-await-election/releases/download/${K8S_AWAIT_ELECTION_VERSION}/k8s-await-election-${K8S_AWAIT_ELECTION_VERSION}-linux-${TARGETARCH}.tar.gz -O - | tar -xvz -C /usr/bin/

CMD ["startSatellite"]
ENTRYPOINT ["/usr/bin/k8s-await-election", "/usr/bin/piraeus-entry.sh"]
