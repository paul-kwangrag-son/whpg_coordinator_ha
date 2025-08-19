## This repo is for HA for WarehousePG Coordinator node.

### setup keepalived at master and standby Master
 ```
sudo dnf install -y keepalived 

echo "net.ipv4.ip_forward = 1" | sudo tee -a /etc/sysctl.conf
echo "net.ipv4.ip_nonlocal_bind = 1" | sudo tee -a /etc/sysctl.conf # Allow VIP to not be bound locally
sudo sysctl -p
 ```

Allow VRRP protocol if firewall using <br>
 ```
sudo firewall-cmd --permanent --add-rich-rule='rule protocol value="vrrp" accept'
 ```
Allow specific multicast addresses (VRRP uses 224.0.0.18 multicast) if firewall using <br>
 ```
sudo firewall-cmd --permanent --add-rich-rule='rule family="ipv4" destination address="224.0.0.18" protocol="vrrp" accept'
sudo firewall-cmd --reload # Reload the firewall to apply the changes
 ```

### folder / files
 ```
/etc/keepalived/keepalived.conf    # keepalived.conf.master for MASTER, keepalived.conf.backup for BACKUP
/etc/keepalived/check_my_service.sh
/etc/keepalived/notify_master.sh
/etc/keepalived/notify_state_change.sh
/etc/keepalived/notify_stop.sh
 ```
### change scripts
```
DB_HOST="whpg-m"     # 호스트 (또는 IP 주소)
DB_PORT="5432"       # 포트
DB_USER="gpadmin" 
VIP 192.168.56.100
COORDINATOR_DATA_DIRECTORY=/data/master/gpseg-1
and so on.
```
### Change Owner and Permission
 ```
sudo chmod +x /etc/keepalived/*.sh
sudo chown gpadmin:gpadmin /etc/keepalived/*
sudo usermod -aG wheel gpadmin
 ```

### Start Keepalived Service
 ```
sudo systemctl enable keepalived
sudo systemctl start keepalived
 ```
### Check Keepalived Service 
 ```
sudo systemctl status keepalived
sudo journalctl -u keepalived -f
sudo tail -f /var/log/messages | grep Keepalived
 ```
### Check VIP 
 ```
nmcli connection show
ip a
ip a show [InterfaceName]
 ```
### Check VRRP Packet
 ```
sudo tcpdump -i [InterfaceName] vrrp
sudo tcpdump -i [InterfaceName] host 224.0.0.18

ex) 
sudo tcpdump -i eth1 vrrp
sudo tcpdump -i eth1 host 224.0.0.18
 ```

### WARNING
If you want to perform VIP and DB failover only in case of server or network failure. <br>
change keepalived.conf at BACKUP(standby master) node.<br>
 ```
vrrp_instance VI_1 {
    ..
    nopreempt      # if set preempt, when DB down, VIP and DB failover to BACKUP Node
                   # if set nopreempt, when DB down, no failover to BACKUP Node
    ..

 ```

### Keepalived RPM Dependency.
```
libnl: A library that uses the Netlink protocol. It is essential for keepalived to handle the network interface and routing table information required to send and receive VRRP (Virtual Router Redundancy Protocol) messages.
libnfnetlink: A library used for features such as Netfilter connection tracking.
libmnl: A low-level library for handling Netlink messages.
openssl: An SSL/TLS protocol library. It may be required for keepalived's communication security or for certain authentication methods.
systemd: Required for managing keepalived as a system service. Systemd is responsible for starting, stopping, and restarting the keepalived process.
libcap: A library for process permissions management. It is used by keepalived to securely grant permissions for certain network operations.
popt: A library for parsing command-line options. It is required for keepalived to process various command-line arguments.
coreutils: A package containing core Linux utilities such as chown, chmod, and ln.

```

