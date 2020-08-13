#!/bin/sh

[ -x /usr/bin/pre-start.sh ] && /usr/bin/pre-start.sh

case $1 in
	startSatellite)
		shift
		/usr/share/linstor-server/bin/Satellite --logs=/var/log/linstor-satellite --config-directory=/etc/linstor --skip-hostname-check "$@"
		;;
	startController)
		shift
		/usr/share/linstor-server/bin/Controller --logs=/var/log/linstor-controller --config-directory=/etc/linstor "$@"
		;;
	*) linstor "$@" ;;
esac
