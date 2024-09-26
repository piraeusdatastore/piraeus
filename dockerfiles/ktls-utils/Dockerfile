FROM base

ARG KTLS_UTILS_VERSION=*
RUN --mount=type=cache,target=/var/cache,sharing=private \
    --mount=type=cache,target=/var/lib/apt/lists,sharing=private \
    --mount=type=tmpfs,target=/var/log \
	 apt-get update && \
	 apt-get install -y tini ktls-utils=$KTLS_UTILS_VERSION

COPY --chmod=0600 tlshd.conf /etc/tlshd.conf

CMD ["/usr/bin/tini", "-g", "/usr/sbin/tlshd", "--", "--stderr"]
