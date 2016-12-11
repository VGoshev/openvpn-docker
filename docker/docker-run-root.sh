#!/bin/sh
set -x

[ -d /dev/net ] || mkdir /dev/net
[ -c /dev/net/tun ] || mknod /dev/net/tun c 10 200

[ -z "$VPN_SUBNET" ] && VPN_SUBNET="10.0.0.0/16"

IPT="/sbin/iptables"
$IPT -t nat -A POSTROUTING -s $VPN_SUBNET -o eth0 -j MASQUERADE
$IPT -t nat -N ToVPN
$IPT -t nat -A POSTROUTING -d $VPN_SUBNET -o tun0 -j ToVPN
$IPT -t nat -A ToVPN -s $VPN_SUBNET -j RETURN
$IPT -t nat -A ToVPN -j MASQUERADE

$IPT -A INPUT -s $VPN_SUBNET -i !tun0 -j DROP
$IPT -A FORWARD -s $VPN_SUBNET -i tun0 -j ACCEPT
$IPT -A FORWARD -d $VPN_SUBNET -o tun0 -j ACCEPT
$IPT -A FORWARD -i eth0 -o eth0 -j DROP
$IPT -A OUTPUT -d $VPN_SUBNET -o !tun0 -j DROP



exec /usr/sbin/openvpn /etc/openvpn/openvpn.conf
#exec /bin/sh
