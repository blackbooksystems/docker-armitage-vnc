FROM phusion/baseimage:latest
MAINTAINER UserTaken <elysian@live.com>
WORKDIR /opt
RUN apt-add-repository ppa:brightbox/ruby-ng -y && \
	apt-get update && apt-get install htop net-tools expect man xserver-xorg-core \
	make gcc g++ patch libreadline-dev libssl-dev libpq5 libpq-dev zlib1g-dev \
	libreadline5 libsqlite3-dev libpcap-dev autoconf git postgresql openjdk-7-jdk \
	libxml2-dev libxslt1-dev libyaml-dev ruby2.2 ruby2.2-dev python lxde netsurf \
	x11-xserver-utils -y --no-install-recommends

RUN curl -O http://tigervnc.sourceforge.net/tiger.nightly/ubuntu-14.04LTS/amd64/tigervncserver_1.4.80+20150411gitccd09bae-3ubuntu1_amd64.deb && \
	dpkg -i *.deb || apt-get install -fy --no-install-recommends && rm *.deb

RUN curl http://www.fastandeasyhacking.com/download/armitage141120.tgz | tar xz

RUN git clone --depth=1 https://github.com/nmap/nmap.git && \
	cd nmap && \
	./configure --without-zenmap && \
	make -j 2 && \
	make install && \
	rm -rf ../nmap

RUN git clone --depth=1 https://github.com/rapid7/metasploit-framework.git && \
	cd /opt/metasploit-framework/ && \
	gem install bundler && \
	bundle install && \
	rm -rf .git /var/lib/gems/2.2.0/cache

RUN /etc/init.d/postgresql start && \
	su - postgres -c "psql -c \"ALTER USER postgres WITH SUPERUSER ENCRYPTED PASSWORD 'msf';\"" && \
	/etc/init.d/postgresql stop

RUN mkdir /etc/service/postgresql && \
	echo "#!/bin/sh\nexec su - postgres -c '/usr/lib/postgresql/9.3/bin/postgres -D /var/lib/postgresql/9.3/main -c \
	config_file=/etc/postgresql/9.3/main/postgresql.conf'" > /etc/service/postgresql/run

RUN mkdir /etc/service/vncserver && \
	echo "#!/bin/sh\nexec /usr/bin/startx" > /etc/service/vncserver/run

RUN echo "#!/bin/sh\n\nvncserver -name LXDE -rfbport 59000 -depth 16 -shmem -fg\n \
	killall Xvnc ssh-agent menu-cached &>/dev/null\nrm -rf ~/.vnc/*.pid /tmp/.* /tmp/ssh-* &>/dev/null" > /usr/bin/startx

RUN mkdir /root/.vnc /root/Desktop && \
	echo "pkill vncconfig\nvncconfig -nowin &\nstartlxde" > /root/.vnc/xstartup && \
	sed -i -e '160s/^/#/' -e '160iExec=lxterminal --working-directory=/root' /usr/share/applications/lxterminal.desktop && \
	cp /usr/share/applications/lxterminal.desktop /root/Desktop/ && \
	ln -s /opt/metasploit-framework/msf* /usr/bin/ && \
	ln -s /opt/* /root/Desktop/ && \
	chmod +x /root/.vnc/xstartup /usr/bin/startx /etc/service/vncserver/run /etc/service/postgresql/run && \
	echo -n /opt/metasploit-framework/config/database.yml > /etc/container_environment/MSF_DATABASE_CONFIG && \
	echo -n /root > /etc/container_environment/HOME

COPY vncpasswd /etc/my_init.d/
ADD https://raw.githubusercontent.com/UserTaken/docker-metasploit-framework/master/database.yml /opt/metasploit-framework/config/
WORKDIR /root
EXPOSE 59000
ENTRYPOINT ["/sbin/my_init"]
