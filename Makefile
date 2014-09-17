#########################################
# Configure these:
#########################################

# DOCKER	path to docker executable
# IMAGE		name for the image
# CONTAINTER	name for the container
# DNS		ip address of public DNS for vpn/socks
# DELUGE_PORT	host port for deluge web ui (default 8112)
# SOCKS_PORT	host port for socks5 (default 1080)
# DELUGE_PATH	host path for deluge config and state
# TORRENT_PATH	host path for torrent files
# PIA_USER	PIA user
# PIA_PASSWORD	PIA password
# PIA_GATEWAY	PIA gateway (for example sweden.privateinternetaccess.com or france.privateinternetaccess.com)
# HOST_SUBNET	The subnet address and mask for host network (used to route deluge-web and socks correctly)
# DOCKER_GW	The docker gateway (usually the ip address of the bridge interface on the host)
# TORRENT_UID	The HOST uid that will own the torrent files
# TORRENT_GID	The HOST gid that will own the torrent files

DOCKER       := "/usr/bin/docker"
IMAGE        := jeff/vpn
CONTAINER    := vpn
DNS          := 8.8.8.8
DELUGE_PORT  := 8112
SOCKS_PORT   := 1080
DELUGE_PATH  := /delugepathonhost
TORRENT_PATH := /torrentpathonhost
PIA_USER     := piauser
PIA_PASSWORD := piapassword
PIA_GATEWAY  := nl.privateinternetaccess.com
HOST_SUBNET  := 192.168.1.0/24
DOCKER_GW    := 192.168.5.1
TORRENT_UID  := 500
TORRENT_GID  := 500
#########################################
# End of user configuration.
#########################################

RUNARGS := --dns=${DNS} --cap-add=NET_ADMIN -p ${SOCKS_PORT}:1080 -p ${DELUGE_PORT}:8112 -v ${DELUGE_PATH}:/config/deluge -v ${TORRENT_PATH}:/torrents -v /etc/localtime:/etc/localtime:ro

all:	configure build

build:	configure
	sudo ${DOCKER} build -t ${IMAGE} .

configure:
	echo ${PIA_USER} > config/openvpn/pw
	echo ${PIA_PASSWORD} >> config/openvpn/pw
	sed -i 's#^remote\s.*$$#remote ${PIA_GATEWAY} 1194#' config/openvpn/default.conf
	sed -i 's#^ip route.*$$#ip route add ${HOST_SUBNET} via ${DOCKER_GW}#' scripts/startup/static_route.sh
	sed -i 's#--gid\s\+[0-9]\+\s#--gid ${TORRENT_GID} #' Dockerfile
	sed -i 's#--uid\s\+[0-9]\+\s#--uid ${TORRENT_UID} #' Dockerfile


run:	stop
	sudo ${DOCKER} run -d --restart=always --name ${CONTAINER} ${RUNARGS} ${IMAGE}
#	sudo ${DOCKER} logs -f ${CONTAINER}
stop:
	sudo ${DOCKER} kill ${CONTAINER} || true
	sudo ${DOCKER} rm -v ${CONTAINER} || true

shell:
	sudo ${DOCKER} run --rm --name ${CONTAINER} -t -i ${RUNARGS} ${IMAGE} /sbin/my_init -- bash -l


clean:
	sudo ${DOCKER} rmi ${IMAGE}

