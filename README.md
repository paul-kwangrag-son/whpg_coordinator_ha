## This repo is for HA for WarehousePG Coordinator node.

## setup keepalived at master and standby Master
sudo dnf install -y keepalived 

echo "net.ipv4.ip_forward = 1" | sudo tee -a /etc/sysctl.conf
echo "net.ipv4.ip_nonlocal_bind = 1" | sudo tee -a /etc/sysctl.conf # Allow VIP to not be bound locally
sudo sysctl -p 

> Allow VRRP protocol if firewall using <br><br>
sudo firewall-cmd --permanent --add-rich-rule='rule protocol value="vrrp" accept'
> Allow specific multicast addresses (VRRP uses 224.0.0.18 multicast) if firewall using <br><br>
sudo firewall-cmd --permanent --add-rich-rule='rule family="ipv4" destination address="224.0.0.18" protocol="vrrp" accept'
sudo firewall-cmd --reload # Reload the firewall to apply the changes

# folder / file
/etc/keepalived/keepalived.conf    <- 
/etc/keepalived/check_my_service.sh
/etc/keepalived/notify_master.sh
/etc/keepalived/notify_state_change.sh
/etc/keepalived/notify_stop.sh

# Change Owner and Permission
sudo chmod +x /etc/keepalived/*.sh
sudo chown gpadmin:gpadmin /etc/keepalived/*

# Start Keepalived Service
sudo systemctl enable keepalived
sudo systemctl start keepalived

# Check Keepalived Service 
sudo systemctl status keepalived
sudo journalctl -u keepalived -f
sudo tail -f /var/log/messages | grep Keepalived

# Check VIP 
nmcli connection show
ip a
ip a show [InterfaceName]

# Check VRRP Packet
sudo tcpdump -i [InterfaceName] vrrp
sudo tcpdump -i [InterfaceName] host 224.0.0.18

ex) 
sudo tcpdump -i eth1 vrrp
sudo tcpdump -i eth1 host 224.0.0.18

# WARNING
# If you want to perform VIP and DB failover only in case of server or network failure.
# change keepalived.conf at BACKUP(standby master) node.
vrrp_instance VI_1 {
    ..
    nopreempt      # if set preempt, when DB down, VIP and DB failover to BACKUP Node
                   # if set nopreempt, when DB down, no failover to BACKUP Node
    ..






