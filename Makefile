include Makevars

RUNARGS := --dns=${DNS} --cap-add=NET_ADMIN -p ${SOCKS_PORT}:1080 -p ${DELUGE_PORT}:8112 -v ${DELUGE_PATH}:/config/deluge -v ${TORRENT_PATH}:/torrents -v /etc/localtime:/etc/localtime:ro

all:	configure build startcmds

build:	configure
	sudo ${DOCKER} build -t ${IMAGE} .

startcmds:
	echo "#!/bin/bash" > start_container.sh
	echo "${DOCKER} run -d --restart=always --name ${CONTAINER} ${RUNARGS} ${IMAGE}" >> start_container.sh
	chmod +x start_container.sh
	echo "#!/bin/bash" > start_container_shell.sh
	echo "${DOCKER} run --rm --name ${CONTAINER} -t -i ${RUNARGS} ${IMAGE} /sbin/my_init -- bash -l" >> start_container_shell.sh
	chmod +x start_container_shell.sh


configure:
	echo ${PIA_USER} > config/openvpn/pw
	echo ${PIA_PASSWORD} >> config/openvpn/pw
	sed -i 's#^remote\s.*$$#remote ${PIA_GATEWAY} 1194#' config/openvpn/default.conf
	sed -i 's#^ip route.*$$#ip route add ${HOST_SUBNET} via ${DOCKER_GW}#' scripts/startup/static_route.sh
	sed -i 's#--gid\s\+[0-9]\+\s#--gid ${TORRENT_GID} #' Dockerfile
	sed -i 's#--uid\s\+[0-9]\+\s#--uid ${TORRENT_UID} #' Dockerfile
	if [ ! -f config/openvpn/pia_client ]; then head -n 100 /dev/urandom | md5sum | tr -d " -" > config/openvpn/pia_client; fi;


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
