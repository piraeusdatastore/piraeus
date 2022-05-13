ARG DISTRO=bullseye
FROM debian:$DISTRO

MAINTAINER Roland Kammerer <roland.kammerer@linbit.com>

ARG LINSTOR_VERSION
ARG DISTRO

RUN { echo 'APT::Install-Recommends "false";' ; echo 'APT::Install-Suggests "false";' ; } > /etc/apt/apt.conf.d/99_piraeus
RUN apt-get update && apt-get install -y wget ca-certificates && apt-get clean
RUN apt-get install -y gnupg2 && \
	 wget -O- https://packages.linbit.com/package-signing-pubkey.asc | gpg --dearmor > /etc/apt/trusted.gpg.d/linbit-keyring.gpg && \
	# Enable contrib repos for zfsutils \
	 sed -r -i 's/^deb(.*)$/deb\1 contrib/' /etc/apt/sources.list && \
	 echo "deb http://packages.linbit.com/public" $DISTRO "misc" > /etc/apt/sources.list.d/linbit.list && \
	 echo "deb http://packages.linbit.com/public/staging" $DISTRO "misc" >> /etc/apt/sources.list.d/linbit.list && \
	 apt-get update && \
	# Install useful utilities and general dependencies
	 apt-get install -y udev drbd-utils jq net-tools iputils-ping iproute2 dnsutils netcat sysstat curl util-linux && \
	# Install dependencies for optional features \
	 apt-get install -y \
	# cryptsetup: luks layer
	  cryptsetup \
	# e2fsprogs: LINSTOR can create file systems \
	  e2fsprogs \
	# lsscsi: exos layer \
	  lsscsi \
    # lvm2: manage lvm storage pools \
      lvm2 \
	# multipath-tools: exos layer \
	  multipath-tools \
	# nvme-cli: nvme layer
	  nvme-cli \
	# procps: used by LINSTOR to find orphaned send/receive processes \
	  procps \
	# socat: used with thin-send-recv to send snapshots to another LINSTOR cluster
	  socat \
	# thin-send-recv: used to send/receive snapshots of LVM thin volumes \
	  thin-send-recv \
	# xfsprogs: LINSTOR can create file systems; xfs deps \
	  xfsprogs \
	# zstd: used with thin-send-recv to send snapshots to another LINSTOR cluster \
	  zstd \
	# zfsutils-linux: for zfs storage pools \
	  zfsutils-linux \
	 && \
	# remove udev, no need for it in the container \
	 apt-get remove -y udev && \
	 apt-get install -y linstor-controller=$LINSTOR_VERSION linstor-satellite=$LINSTOR_VERSION linstor-common=$LINSTOR_VERSION  linstor-client && \
	 apt-get clean

# Log directory need to be group writable. OpenShift assigns random UID and GID, without extra RBAC changes we can only influence the GID.
RUN mkdir /var/log/linstor-controller && \
	 chown 0:1000 /var/log/linstor-controller && \
	 chmod -R 0775 /var/log/linstor-controller && \
	 # Ensure we log to files in containers, otherwise SOS reports won't show any logs at all
	 sed -i 's#<!-- <appender-ref ref="FILE" /> -->#<appender-ref ref="FILE" />#' /usr/share/linstor-server/lib/conf/logback.xml


RUN lvmconfig --type current --mergedconfig --config 'activation { udev_rules = 0 } devices { global_filter = [ "r|^/dev/drbd|" ] obtain_device_list_from_udev = 0}' > /etc/lvm/lvm.conf.new && mv /etc/lvm/lvm.conf.new /etc/lvm/lvm.conf

# controller
EXPOSE 3376/tcp 3377/tcp 3370/tcp 3371/tcp

# satellite
EXPOSE 3366/tcp 3367/tcp

COPY entry.sh /usr/bin/piraeus-entry.sh

ARG K8S_AWAIT_ELECTION_VERSION
# TARGETARCH is a docker special variable: https://docs.docker.com/engine/reference/builder/#automatic-platform-args-in-the-global-scope
ARG TARGETARCH

RUN wget https://github.com/LINBIT/k8s-await-election/releases/download/${K8S_AWAIT_ELECTION_VERSION}/k8s-await-election-${K8S_AWAIT_ELECTION_VERSION}-linux-${TARGETARCH}.tar.gz -O - | tar -xvz -C /usr/bin/

CMD ["startSatellite"]
ENTRYPOINT ["/usr/bin/k8s-await-election", "/usr/bin/piraeus-entry.sh"]
