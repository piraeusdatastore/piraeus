# piraeus-client

This is the Piraeus container image containing the [linstor-client](https://github.com/LINBIT/linstor-client)
which can be used for cluster setup and debugging.

# How to use
```sh
docker run -it --rm -e LS_CONTROLLERS=yourcontrollerIP piraeusdatastore/piraeus-client node list
```

The environment variable is used to specify the current controller's IP.

# How does this differ from LINBIT's LINSTOR?
The containers we provide in the Piraeus project are Debian based and packages get installed from a
PPA. These are maintained at a best effort basis, but make sure to understand the
[differences](https://launchpad.net/~linbit/+archive/ubuntu/linbit-drbd9-stack) between these packages and the
ones provided by LINBIT for its customers.

Additionally, container images provided by LINBIT as commercal offer on [drbd.io](http://drbd.io), are based
on RHEL/UBI images and are for example OpenShift certified.
