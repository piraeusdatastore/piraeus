
[![Docker Automated build](https://img.shields.io/docker/automated/piraeusdatastore/ktls-utils.svg)](https://hub.docker.com/r/piraeusdatastore/ktls-utils)
[![Docker Repository on Quay](https://quay.io/repository/piraeusdatastore/ktls-utils/status "Docker Repository on Quay")](https://quay.io/repository/piraeusdatastore/ktls-utils)

# ktls-utils

This is the Piraeus container image packaging [ktls-utils](https://github.com/oracle/ktls-utils).

In-kernel TLS consumers need a mechanism to perform TLS handshakes on a connected socket to negotiate
TLS session parameters that can then be programmed into the kernel's TLS record protocol engine.

This container provides a TLS handshake user agent that listens for kernel requests and then materializes
a user space socket endpoint on which to perform these handshakes. The resulting negotiated session
parameters are passed back to the kernel via standard kTLS socket options.

# How to use

The image starts `tlshd` and loads the standard configuration, loading key material from `/etc/tlshd.d`.
`tlshd` is looking for `/etc/tlshd.d/ca.crt` as trusted CA certificate, `/etc/tlshd.d/tls.key` as private key
and `/etc/tlshd.d/tls.crt` as certificate.

To apply your own configuration, place it at `/etc/tlshd.conf` in the container.

# Registries
- [Docker Hub](https://hub.docker.com/r/piraeusdatastore/ktls-utils)
- [quay.io](https://quay.io/repository/piraeusdatastore/ktls-utils)

# Maintainer workflow
- `make update TAG=v0.10 NOCACHE=true`
- `make upload TAG=v0.10 REGISTRY='quay.io/piraeusdatastore piraeusdatastore'`
