#name of container: docker-opensimulator
#versison of container: 0.1.0
FROM quantumobject/docker-baseimage
MAINTAINER Angel Rodriguez  "angel@quantumobject.com"

# Set correct environment variables.
ENV HOME /root

#add repository and update the container
#Installation of nesesary package/software for this containers...
RUN apt-get update && apt-get install -y -q nant \
                                        libmono-microsoft8.0-cil \
                    && apt-get clean \
                    && rm -rf /tmp/* /var/tmp/*  \
                    && rm -rf /var/lib/apt/lists/*

##startup scripts  
#Pre-config scrip that maybe need to be run one time only when the container run the first time .. using a flag to don't 
#run it again ... use for conf for service ... when run the first time ...
RUN mkdir -p /etc/my_init.d
COPY startup.sh /etc/my_init.d/startup.sh
RUN chmod +x /etc/my_init.d/startup.sh


##Adding Deamons to containers
#refers to dockerfile_reference

# to add opensim deamon to runit
RUN mkdir /etc/service/opensim
COPY opensim.sh /etc/service/opensim/unrun
RUN chmod +x /etc/service/opensim/unrun

#pre-config scritp for different service that need to be run when container image is create 
#maybe include additional software that need to be installed ... with some service running ... like example mysqld
COPY pre-conf.sh /sbin/pre-conf
RUN chmod +x /sbin/pre-conf \
    && /bin/bash -c /sbin/pre-conf \
    && rm /sbin/pre-conf

#down/shutdown script ... use to be run in container before stop or shutdown .to keep service..good status..and maybe
#backup or keep data integrity .. 

##scritp that can be running from the outside using docker-bash tool ...
## for example to create backup for database with convitation of VOLUME   dockers-bash container_ID backup_mysql
COPY backup.sh /sbin/backup
RUN chmod +x /sbin/backup
VOLUME /var/backups

#script to execute after install configuration done .... 
COPY after_install.sh /sbin/after_install
RUN chmod +x /sbin/after_install

#add files and script that need to be use for this container
#include conf file relate to service/daemon 
#additionsl tools to be use internally 

# to allow access from outside of the container  to the container service
# at that ports need to allow access from firewall if need to access it outside of the server. 
EXPOSE 9000/tcp
EXPOSE 9000/udp

# Use baseimage-docker's init system.
CMD ["/sbin/my_init"]
