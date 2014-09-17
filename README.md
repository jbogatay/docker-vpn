A dockerfile with openvpn, [privateinternetaccess.com](https://www.privateinternetaccess.com/) port forward script, deluged, deluge-web, and a socks proxy.

Requirements
-------
- Docker 1.2+
- [privateinternetaccess.com](https://www.privateinternetaccess.com/) account

Features
-------
- Auto connect to PIA
- Torrents over VPN (deluge)
- SOCKS5 proxy over VPN (dante)
- Auto restart VPN every 24 hours
- Sets up and maintains port forwarding from PIA [link](https://www.privateinternetaccess.com/forum/index.php?p=/discussion/3359/port-forwarding-without-the-application-w-pia-script-advanced-users/p1)
- All in a container

Setup
-------
- Edit all the configuration values in Makefile

- Create the image
      make

- Run the image
      make run

Other make targets

|Parameter|Description|
|---------|-----------|
|configure|configure the dockerfile and scripts only|
|build|build the container only|
|run|stop and remove existing vpn container, then spool up a new one|
|stop|stop and remove any existing/running vpn containers|
|shell|start new container and all services with a shell prompt.  Container will be stopped and removed on exit|
|clean|remove image|

First Run
-------
Load up the deluge web interface (http://servernameorip:8112/) and set all the folders to start with /torrents/  (for example /torrents/downloading/  /torrents/downloaded/  /torrents/incoming/   etc)

Restart the daemon (or the container)


Usage
-------
Access deluge webui via http://servernameorip:8112/ 

Access socks5 proxy via http://servernameorip:1080/
