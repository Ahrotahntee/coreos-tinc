A tinc VPN Docker Container built for CoreOS.

This container uses etcdctl to perform 0-conf tinc connections with other members in the CoreOS cluster.

Requirements:
-----
* CoreOS
* etcd2 configured with SSL
* Certificates for etcd2 SSL communication
  * Stored in: /certs/
  * CA File: ca.pem
  * Server Cert: server.pem
  * Server Key: server.key

Running the Container:
------
The docker container **must** be started with

* `--cap-add NET_ADMIN`
* `--net=host`
* `--volume /etc/ssl/etcd:/certs`
* `--device=/dev/net/tun`

It is recommended that you mount the config directory somewhere:

* `--volume /srv/tinc:/etc/tinc`

Network Information
----
Network:   172.19.0.0/16 (Class B)

Broadcast: 172.19.255.255

HostMin:   172.19.0.1

HostMax:   172.19.255.254

Hosts/Net: 65534

Technical:
----------
The key exchange happens over etcd in /tinc-vpn.org/peers/<peer name>/config

You can use these to generate a DNS config if you're interested in setting up some LAN DNS.

Sample Fleetctl Unit File
-------------------------
[Unit]

Description=A tinc VPN Docker Container built for CoreOS

After=docker.service

Requires=docker.service

[Service]
Restart=always

TimeoutStartSec=0

ExecStartPre=-/bin/docker rm tinc

ExecStartPre=/bin/docker pull ahrotahntee/tinc

ExecStart=/bin/docker run --name tinc --volume /etc/ssl/etcd:/certs --volume /srv/tinc:/etc/tinc --device=/dev/net/tun --cap-add NET_ADMIN --net=host ahrotahntee/tinc:latest

ExecStartPost=/bin/sh -c "/bin/curl --insecure --cacert /etc/ssl/etcd/ca.pem --cert /etc/ssl/etcd/server.pem --key /etc/ssl/etcd/server.key https://127.0.0.1:2379/v2/keys/services/tinc/$(hostname) -XPUT -d value=$(ifconfig tun0 | grep 'inet ' | awk -F' ' '{print $2}')"

ExecStop=/bin/docker kill tinc

ExecStopPost=/bin/sh -c '/bin/curl --insecure --cacert /etc/ssl/etcd/ca.pem --cert /etc/ssl/etcd/server.pem --key /etc/ssl/etcd/server.key https://127.0.0.1:2379/v2/keys/services/tinc/$(hostname) -XDELETE'

[Install]

WantedBy=multi-user.target

[X-Fleet]

Global=true

