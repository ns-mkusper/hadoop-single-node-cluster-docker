FROM alpine:3.10

MAINTAINER Mark Kusper < mkusper [at] bydlosoft.com >

RUN apk update

# Generic dependencies

RUN apk add --no-cache rsync curl bash

RUN apk add --no-cache python

# Java™ must be installed. Recommended Java versions are described at HadoopJavaVersions ( http://wiki.apache.org/hadoop/HadoopJavaVersions ).
RUN apk add --no-cache openjdk8-jre

# To get a Hadoop distribution, download a recent stable release from one of the Apache Download Mirrors ( http://www.apache.org/dyn/closer.cgi/hadoop/common/ ).
RUN mkdir -p /usr/local/hadoop && curl http://mirrors.sonic.net/apache/hadoop/common/hadoop-3.2.0/hadoop-3.2.0.tar.gz | tar --strip 1 -xz -C /usr/local/hadoop
ADD conf/bashrc /root/.bashrc

# Setup passphraseless ssh
RUN apk add --no-cache openssh
RUN ssh-keygen -f /etc/ssh/ssh_host_dsa_key -N '' -t dsa
RUN ssh-keygen -f /etc/ssh/ssh_host_rsa_key -N '' -t rsa
RUN ssh-keygen -t rsa -P '' -f ~/.ssh/id_rsa
RUN cat ~/.ssh/id_rsa.pub >> ~/.ssh/authorized_keys
RUN sed -i 's/^#PermitRootLogin/PermitRootLogin/' /etc/ssh/sshd_config
RUN /usr/sbin/sshd
# root user needs passwd in order to prevent 'User root not allowed because account is locked'
RUN passwd -d root
# Alpine uses ash but we need bash for hadoop
RUN sed -i 's@root:x:0:0:root:/root:/bin/ash@root:x:0:0:root:/root:/bin/bash@' /etc/passwd


# Hadoop Config
# Hadoop can also be run on a single-node in a pseudo-distributed mode where each Hadoop daemon runs in a separate Java process.
ADD conf/core-site.xml /etc/hadoop/core-site.xmlp
ADD conf/hdfs-site.xml /etc/hadoop/hdfs-site.xml
# In the distribution, edit the file etc/hadoop/hadoop-env.sh to define some parameters as follows:
RUN echo 'export JAVA_HOME=$(readlink -f /usr/bin/java | sed "s:bin/java::")' >> /usr/local/hadoop/etc/hadoop/hadoop-env.sh

# start hadoop script
RUN mkdir /root/bin/
ADD bootstrap/start-hadoop.sh /root/bin/start-hadoop.sh
RUN chmod u+x /root/bin/start-hadoop.sh

# data volume
# VOLUME ["/data"]

# # Expose ports
# # hdfs port
EXPOSE 9000
EXPOSE 8020
# # namenode port
EXPOSE 50070
# # Resouce Manager
EXPOSE 8032
EXPOSE 8088

CMD [ "/root/bin/start-hadoop.sh" ]
CMD [ "/bin/bash" ]
