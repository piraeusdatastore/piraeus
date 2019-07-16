FROM debian:buster

MAINTAINER Roland Kammerer <roland.kammerer@linbit.com>

RUN apt-get update && apt-get install -y gnupg2 && \
    apt-key adv --recv-key --keyserver keyserver.ubuntu.com 34893610CEAA9512 && \
    echo "deb http://ppa.launchpad.net/linbit/linbit-drbd9-stack/ubuntu bionic main" > /etc/apt/sources.list.d/linbit-ppa.list && \
	 apt-get update && \
	 apt-get install -y default-jre-headless && \
	 apt-get install -y udev linstor-controller linstor-satellite linstor-client \
	 drbd-utils lvm2 && \
	 apt-get clean
# remove jre-headless with linstor 0.9.13

# satellite
RUN sed -i 's/udev_rules.*=.*/udev_rules=0/' /etc/lvm/lvm.conf
RUN sed -i 's/udev_sync.*=.*/udev_sync=0/' /etc/lvm/lvm.conf

# controller
EXPOSE 3376/tcp 3377/tcp 3370/tcp

# satellite
EXPOSE 3366/tcp 3367/tcp

COPY entry.sh /usr/bin/piraeus-entry.sh

CMD ["startSatellite"]
ENTRYPOINT ["/usr/bin/piraeus-entry.sh"]
