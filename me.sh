#!/bin/bash -x
# Installs a PPTP VPN system for (CentOS)
# VPN 1.0
# author  Mohamed Eltayeb  @altayeb


(

VPN_IP=`curl ipv4.icanhazip.com>/dev/null 2>&1`

USER="myuser"
PASS="mypass"

LOCAL_IP="192.168.1.150"
REMOTE_IP="192.168.1.151-200"

yum -y groupinstall "Development Tools"
rpm -Uvh http://poptop.sourceforge.net/yum/stable/rhel6/pptp-release-current.noarch.rpm
yum -y install policycoreutils policycoreutils
yum -y install ppp pptpd
yum -y update

echo "1" > /proc/sys/net/ipv4/ip_forward
sed -i 's/net.ipv4.ip_forward = 0/net.ipv4.ip_forward = 1/g' /etc/sysctl.conf

sysctl -p /etc/sysctl.conf

echo "localip $LOCAL_IP" >> /etc/pptpd.conf 
echo "remoteip $REMOE_IP" >> /etc/pptpd.conf 

echo "ms-dns 8.8.8.8" >> /etc/ppp/options.pptpd 
echo "ms-dns 209.244.0.3" >> /etc/ppp/options.pptpd

echo "$USER pptpd $PASS *" >> /etc/ppp/chap-secrets

service iptables start
echo "iptables -t nat -A POSTROUTING -o eth0 -j MASQUERADE" >> /etc/rc.local
iptables -t nat -A POSTROUTING -o eth0 -j MASQUERADE
service iptables save
service iptables restart

service pptpd restart
chkconfig pptpd on

echo -e 'Installation Log: /var/log/vpn.log'
echo -e 'You can now connect to your VPN via your external IP ($VPN_IP)'

echo -e 'UserName:$USER'
echo -e 'Password: $PASS'
) 2>&1 | tee /var/log/vpn.log

