FROM base

ARG DRBD_REACTOR_VERSION=*
RUN --mount=type=cache,target=/var/cache,sharing=private \
    --mount=type=cache,target=/var/lib/apt/lists,sharing=private \
    --mount=type=tmpfs,target=/var/log \
	 apt-get update && \
	 apt-get install -y drbd-utils drbd-reactor=$DRBD_REACTOR_VERSION

CMD ["/usr/sbin/drbd-reactor"]
