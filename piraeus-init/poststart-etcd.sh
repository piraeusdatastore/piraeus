#!/bin/sh

export ETCDCTL_ENDPOINTS=$( cat /init/conf/etcd_local_endpoint )

# default api is v3, so add a shortcut for api v2              
cat > /usr/local/bin/etcdctl2 <<EOF
#!/bin/sh
export ETCDCTL_API=2
export ETCDCTL_ENDPOINTS=${ETCDCTL_ENDPOINTS}
etcdctl \$@
EOF
sed 's/API=2/API=3/' /usr/local/bin/etcdctl2 > /usr/local/bin/etcdctl3
chmod +x /usr/local/bin/etcdctl[23]

# get member id
etcdctl endpoint status | awk '{print $2}' | sed 's/,//g' > /init/conf/etcd_member_id
cat /init/conf/etcd_member_id