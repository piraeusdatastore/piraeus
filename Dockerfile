FROM debian:buster

MAINTAINER Roland Kammerer <roland.kammerer@linbit.com>

RUN apt-get update && apt-get install -y gnupg2 && \
    apt-key adv --recv-key --keyserver keyserver.ubuntu.com 34893610CEAA9512 && \
    echo "deb http://ppa.launchpad.net/linbit/linbit-drbd9-stack/ubuntu bionic main" > /etc/apt/sources.list.d/linbit-ppa.list && \
	 apt-get update && \
	 apt-get install -y linstor-client && apt-get clean

ENTRYPOINT ["linstor"]
