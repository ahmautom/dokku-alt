FROM phusion/baseimage:0.9.16
MAINTAINER Kamil Trzciński <ayufan@ayufan.eu>

# Install required dependencies
RUN apt-get update && \
	apt-get install -y apt-transport-https locales git make \
	curl software-properties-common \
	nginx dnsutils aufs-tools \
	dpkg-dev man-db
RUN apt-get install -y apache2-utils
RUN chmod ugo+s /usr/bin/sudo

# Configure environment
RUN locale-gen en_US.UTF-8
ENV LANG en_US.UTF-8
ENV LC_ALL en_US.UTF-8

# Install docker
RUN apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv-keys 36A1D7869245C8950F966E92D8576A8BA88D21E9 && \
	echo deb https://get.docker.io/ubuntu docker main > /etc/apt/sources.list.d/docker.list && \
	apt-get update && \
	apt-get install -y lxc-docker

# Configure ssh daemon
RUN sed -i 's/^#UsePAM.*/UsePAM yes/g' /etc/ssh/sshd_config
RUN rm -f /etc/service/sshd/down

# Configure volumes
VOLUME /home/dokku
VOLUME /var/lib/docker

# Install dokku-alt
ADD / /srv/dokku-alt
WORKDIR /srv/dokku-alt
RUN sed -i 's/linux-image-extra-virtual, //g' deb/dokku-alt/DEBIAN/control
RUN make install

# Configure daemon
ADD runit/docker.sh /etc/service/docker/run
ADD runit/nginx.sh /etc/service/nginx/run
ADD runit/dokku.sh /etc/service/dokku/run

# Configure startup scripts
ADD my_init.d/dokku-redeploy.sh /etc/my_init.d/dokku-redeploy.sh

EXPOSE 22 80 443
