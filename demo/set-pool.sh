#!/bin/bash -x
# generate demo yamls for lvmpool

[ -z "$1" ] && echo 'Must Provide a Pool name prefix, such as "lvm"' && exit 1

prefix_lower=${1,,}
prefix_upper=${prefix_lower^}

rm -fr "${prefix_lower}_pool"
mkdir -v "${prefix_lower}_pool"

cp -v demo-*.yaml "${prefix_lower}_pool"
cp -v *-mysql.sh "${prefix_lower}_pool"
cp -v ../deploy/42_sc.yaml "${prefix_lower}_pool/sc.yaml"

sed -i "s/dflt/${prefix_lower}/g; s/Dflt/${prefix_upper}/g" "${prefix_lower}_pool/"*.yaml
