#! /bin/bash
#sudo sed -i -e "s/\( ssid=\).*/\1$1/" /etc/hostapd/hostapd.conf
#sudo sed -i -e "s/\(passphrase=\).*/\1$2/" /etc/hostapd/hostapd.conf
sudo cp hostapd.conf /etc/hostapd/hostapd.conf
sudo /etc/init.d/hostapd stop
sudo /etc/init.d/udhcpd stop
sudo ifdown wlan0
sudo ifconfig wlan0 down
sudo rm -rf /etc/network/interfaces
sudo cp /etc/network/interfaces.ap /etc/network/interfaces
sudo ifconfig wlan0 up
sudo ifup wlan0

x=tem.tem

touch $x
echo "DAEMON_CONF=\"/etc/hostapd/hostapd.conf\"" >> $x
sudo mv $x /etc/default/hostapd

touch $x
sudo sh -c "echo 1 >> /proc/sys/net/ipv4/ip_forward"
sudo echo "net.ipv4.ip_forward=1" >> /etc/sysctl.conf
sudo iptables -t nat -A POSTROUTING -o eth0 -j MASQUERADE
sudo iptables -A FORWARD -i eth0 -o wlan0 -m state --state RELATED,ESTABLISHED -j ACCEPT
sudo iptables -A FORWARD -i wlan0 -o eth0 -j ACCEPT
sudo sh -c "iptables-save >> /etc/iptables.ipv4.nat"

sudo /etc/init.d/hostapd start
sudo /etc/init.d/udhcpd start
sudo service hostapd status
