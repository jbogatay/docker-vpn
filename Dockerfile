FROM phusion/baseimage:0.9.11
MAINTAINER Jeff Bogatay <jeff@bogatay.com>
ENV DEBIAN_FRONTEND noninteractive
ENV HOME /root

# setup locale
RUN echo 'LANG="en_US.UTF-8"' > /etc/default/locale && \
    echo 'LANGUAGE="en_US:en"' >> /etc/default/locale && \
    locale-gen en_US.UTF-8 &&\
    update-locale en_US.UTF-8

# add a service user change 500/500 to match whatever host uid/gid you want
RUN groupadd --gid 500 torrents  &&\
    useradd --gid 500 --no-create-home --shell /usr/sbin/nologin --uid 500 torrents

# update and install
RUN apt-get update -qy && apt-get upgrade -qy && \
    apt-get install -qy openvpn dante-server deluged deluge-web deluge-console

# Clean up APT when done
RUN apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

# Disable Phusion SSH
RUN rm -rf /etc/service/sshd /etc/my_init.d/00_regen_ssh_host_keys.sh

# Use baseimage-docker's init system.
CMD ["/sbin/my_init"]

VOLUME /config/deluge
VOLUME /torrents

EXPOSE 1080
EXPOSE 8112

# Create some dirs
RUN mkdir -p /config/deluge/ /etc/my_init.d/ /var/log/deluged/     && \
    chown torrents:torrents -R /config/deluge && \
    chown torrents:torrents -R /var/log/deluged


# Add configs
ADD config/openvpn/ /config/openvpn
ADD config/sockd/   /config/sockd

# Add util scripts
ADD scripts/util/ /usr/bin/

# Add startup scripts
ADD scripts/startup/ /etc/my_init.d/

# Add services
ADD scripts/service/ /etc/service/

# Make sure scripts and services are executable
RUN find /etc/service/ -name run -exec chmod +x {} \;   &&\
    find /etc/my_init.d/* -exec chmod +x {} \;

