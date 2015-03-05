#!/bin/sh

MASTER_ADDR=master.kur.scpro.us

# Setup virty-testing repo
echo "[virt7-testing]
name=virt7-testing
baseurl=http://cbs.centos.org/repos/virt7-testing/x86_64/os/
gpgcheck=0
" > /etc/yum.repos.d/virt7-testing.repo
 
yum install -y http://cbs.centos.org/kojifiles/packages/etcd/0.4.6/7.el7.centos/x86_64/etcd-0.4.6-7.el7.centos.x86_64.rpm
yum -y install --enablerepo=virt7-testing kubernetes

echo "# Comma separated list of nodes in the etcd cluster
KUBE_ETCD_SERVERS=\"--etcd_servers=http://${MASTER_ADDR}:4001\"

# logging to stderr means we get it in the systemd journal
KUBE_LOGTOSTDERR=\"--logtostderr=true\"

# journal message level, 0 is debug
KUBE_LOG_LEVEL=\"--v=0\"

# Should this cluster be allowed to run privileged docker containers
KUBE_ALLOW_PRIV=\"--allow_privileged=true\"
" > /etc/kubernetes/config

# Start the minion services
for SERVICES in kube-proxy kubelet docker; do 
    systemctl restart $SERVICES
    systemctl enable $SERVICES
    systemctl status $SERVICES 
done