#!/bin/sh
#���԰汾4.7.9.589��@cqupt

#��װpppoe-server
#opkg update
#opkg install rp-pppoe-server

#/etc/ppp/option �� logfile /dev/null Ϊ logfile /tmp/pppoe.log
sed -i "s/dev/tmp/" /etc/ppp/options
sed -i "s/null/pppoe.log/" /etc/ppp/options
#pppoe-server����rp-pppoe.so�޷����أ�����openwrt�Դ���rp-pppoe.so
cp /etc/ppp/plugins/rp-pppoe.so /etc/ppp/plugins/rp-pppoe.so.bak
cp /usr/lib/pppd/2.4.7/rp-pppoe.so /etc/ppp/plugins/rp-pppoe.so
#/etc/ppp/pppoe-server-options ��require-papΪrequire-chap
sed -i "s/require-pap/require-chap/" /etc/ppp/pppoe-server-options
#/etc/ppp/chap-secrets���һ���û�(������޷�����)
echo "test * test *">>/etc/ppp/chap-secrets

#�ο�confnetwork.sh���޸�ifname����wan������
#uci delete network.wan
uci delete network.wan6
uci commit network

uci set network.netkeeper=interface
uci set network.netkeeper.ifname=$(uci show network.wan.ifname | awk -F "'" '{print $2}')
uci set network.netkeeper.macaddr=aabbccddeeff
uci set network.netkeeper.proto=pppoe
#TODO:set pppoe password
uci set network.netkeeper.username=username
uci set network.netkeeper.password=password
uci set network.netkeeper.metric='0'
uci commit network
#set firewall
uci set firewall.@zone[1].network='wan netkeeper' 
uci commit firewall
/etc/init.d/firewall restart
/etc/init.d/network reload
/etc/init.d/network restart

#ʹpppoe֧��ת���ַ�
cp /lib/netifd/proto/ppp.sh /lib/netifd/proto/ppp.sh_bak
sed -i '/proto_run_command/i username=`echo -e "$username"`' /lib/netifd/proto/ppp.sh
sed -i '/proto_run_command/i password=`echo -e "$password"`' /lib/netifd/proto/ppp.sh

#���������ű�
cp /root/nk4 /etc/init.d/nk4
chmod +x /etc/init.d/nk4
/etc/init.d/nk4 enable
/etc/init.d/nk4 start &
