FROM base

ARG LINSTOR_VERSION=*
RUN --mount=type=cache,target=/var/cache,sharing=private \
    --mount=type=cache,target=/var/lib/apt/lists,sharing=private \
    --mount=type=tmpfs,target=/var/log \
	# Enable contrib repos for zfsutils \
	 . /etc/os-release && \
	 sed -i -r 's/^Components: (.*)$/Components: \1 contrib/' /etc/apt/sources.list.d/debian.sources && \
	 echo "deb http://deb.debian.org/debian $VERSION_CODENAME-backports contrib" > /etc/apt/sources.list.d/backports.list && \
	 apt-get update && \
	# Install useful utilities and general dependencies
	 apt-get install -y udev drbd-utils jq net-tools iputils-ping iproute2 dnsutils netcat-traditional sysstat curl util-linux && \
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
	  zfsutils-linux/$VERSION_CODENAME-backports \
	 && \
	# remove udev, no need for it in the container \
	 apt-get remove -y udev && \
	 apt-get install -y linstor-controller=$LINSTOR_VERSION linstor-satellite=$LINSTOR_VERSION linstor-common=$LINSTOR_VERSION linstor-client linstor-gui

# Log directory need to be group writable. OpenShift assigns random UID and GID, without extra RBAC changes we can only influence the GID.
RUN mkdir /var/log/linstor-controller && \
	 chown 0:1000 /var/log/linstor-controller && \
	 chmod -R 0775 /var/log/linstor-controller && \
	 # Ensure we log to files in containers, otherwise SOS reports won't show any logs at all
	 sed -i 's#<!-- <appender-ref ref="FILE" /> -->#<appender-ref ref="FILE" />#' /usr/share/linstor-server/lib/conf/logback.xml


RUN lvmconfig --type current --mergedconfig --config 'activation { udev_sync = 0 udev_rules = 0 monitoring = 0 } devices { global_filter = [ "r|^/dev/drbd|" ] obtain_device_list_from_udev = 0}' > /etc/lvm/lvm.conf.new && mv /etc/lvm/lvm.conf.new /etc/lvm/lvm.conf
RUN echo 'global { usage-count no; }' > /etc/drbd.d/global_common.conf

# controller
EXPOSE 3376/tcp 3377/tcp 3370/tcp 3371/tcp

# satellite
EXPOSE 3366/tcp 3367/tcp

COPY entry.sh /usr/bin/piraeus-entry.sh

ARG K8S_AWAIT_ELECTION_VERSION
# TARGETARCH is a docker special variable: https://docs.docker.com/engine/reference/builder/#automatic-platform-args-in-the-global-scope
ARG TARGETARCH

RUN wget https://github.com/LINBIT/k8s-await-election/releases/download/${K8S_AWAIT_ELECTION_VERSION}/k8s-await-election-${K8S_AWAIT_ELECTION_VERSION}-linux-${TARGETARCH}.tar.gz -O - | tar -xvz -C /usr/bin/

ARG LOSETUP_CONTAINER_VERSION=v1.0.1
RUN wget "https://github.com/LINBIT/losetup-container/releases/download/${LOSETUP_CONTAINER_VERSION}/losetup-container-$(uname -m)-unknown-linux-gnu.tar.gz" -O - | tar -xvz -C /usr/local/sbin && \
	 printf '#!/bin/sh\nLOSETUP_CONTAINER_ORIGINAL_LOSETUP=%s exec /usr/local/sbin/losetup-container "$@"\n' $(command -v losetup) > /usr/local/sbin/losetup && \
	 chmod +x /usr/local/sbin/losetup

RUN wget "https://dl.k8s.io/$(wget -O - https://dl.k8s.io/release/stable.txt)/bin/linux/${TARGETARCH}/kubectl" -O /usr/local/bin/kubectl && chmod +x /usr/local/bin/kubectl

CMD ["startSatellite"]
ENTRYPOINT ["/usr/bin/k8s-await-election", "/usr/bin/piraeus-entry.sh"]
