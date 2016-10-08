A tinc VPN Docker Container built for CoreOS.

This container uses etcdctl to perform 0-conf tinc connections with other members in the CoreOS cluster.
The system automatically sets up and discovers peers, while it's running it monitors etcd for changes to the peers.

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
```Network:   172.19.0.0/16 (Class B)
Broadcast: 172.19.255.255
HostMin:   172.19.0.1
HostMax:   172.19.255.254
Hosts/Net: 65534
```

Technical:
----------
The key exchange happens over etcd in /tinc-vpn.org/peers/<peer name>/config

You can use these to generate a DNS config if you're interested in setting up some LAN DNS.

Sample Fleetctl Unit File
-------------------------
```[Unit]
Description=A tinc VPN Docker Container built for CoreOS
After=docker.service
Requires=docker.service tinc-discovery.service

[Service]
Restart=always
TimeoutStartSec=0
ExecStartPre=-/bin/docker kill tinc
ExecStartPre=-/bin/docker rm tinc
ExecStartPre=/bin/docker pull ahrotahntee/tinc
ExecStartPre=/bin/docker run --rm --volume /etc/ssl/CoreOS:/certs --volume /srv/tinc:/etc/tinc --entrypoint tinc-setup --net=host ahrotahntee/tinc:latest
ExecStart=/bin/docker run --rm --name tinc --volume /etc/ssl/CoreOS:/certs --volume /srv/tinc:/etc/tinc --device=/dev/net/tun --cap-add NET_ADMIN --net=host ahrotahntee/tinc:latest

[Install]
WantedBy=multi-user.target

[X-Fleet]
Global=true
```

