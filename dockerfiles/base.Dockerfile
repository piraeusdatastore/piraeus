ARG DISTRO=bookworm
FROM debian:$DISTRO

RUN { echo 'APT::Install-Recommends "false";' ; echo 'APT::Install-Suggests "false";' ; } > /etc/apt/apt.conf.d/99_piraeus

RUN --mount=type=cache,target=/var/cache,sharing=private \
    --mount=type=cache,target=/var/lib/apt/lists,sharing=private \
    --mount=type=tmpfs,target=/var/log \
	 apt-get update && \
	 apt-get install -y wget ca-certificates && \
	 wget https://packages.linbit.com/public/linbit-keyring.deb -O /var/cache/linbit-keyring.deb && \
	 dpkg -i /var/cache/linbit-keyring.deb && \
	 . /etc/os-release && \
	 echo "deb http://packages.linbit.com/public $VERSION_CODENAME misc" > /etc/apt/sources.list.d/linbit.list
