# DOCKER-VERSION 0.7.1
FROM      dockerfile/java:oracle-java8
MAINTAINER Julien Dubois <julien.dubois@gmail.com>

# make sure the package repository is up to date
RUN echo "deb http://archive.ubuntu.com/ubuntu trusty main universe" > /etc/apt/sources.list
RUN apt-get -y update

# install python-software-properties (so you can do add-apt-repository)
RUN DEBIAN_FRONTEND=noninteractive apt-get install -y -q software-properties-common

# install utilities
RUN apt-get -y install vim git sudo bzip2 curl

# install maven
RUN  \
  export DEBIAN_FRONTEND=noninteractive && \
  sed -i 's/# \(.*multiverse$\)/\1/g' /etc/apt/sources.list && \
  apt-get update && \
  apt-get -y upgrade && \
  apt-get install -y vim wget curl git maven

# install node.js from PPA
RUN add-apt-repository ppa:chris-lea/node.js
RUN apt-get update
RUN apt-get -y install nodejs

# install yeoman
RUN npm install -g yo

# install JHipster
RUN npm install -g generator-jhipster@2.7.0


# install the sample app to download all Maven dependencies
RUN cd /home/jhipster && \
    wget https://github.com/jhipster/jhipster-sample-app/archive/v2.7.0.zip && \
    unzip v2.7.0.zip && \
    rm v2.7.0.zip
RUN cd /home/jhipster/jhipster-sample-app-2.7.0 && npm install
RUN cd /home && chown -R jhipster:jhipster /home/jhipster
RUN cd /home/jhipster/jhipster-sample-app-2.7.0 && sudo -u jhipster mvn dependency:go-offline

# install SSH server so we can connect multiple times to the container
RUN apt-get -y install openssh-server && mkdir /var/run/sshd

# configure the "jhipster" and "root" users
RUN echo 'root:jhipster' |chpasswd
RUN groupadd jhipster && useradd jhipster -s /bin/bash -m -g jhipster -G jhipster && adduser jhipster sudo
RUN echo 'jhipster:jhipster' |chpasswd


# expose the working directory, the Tomcat port, the Grunt server port, the SSHD port, and run SSHD
VOLUME ["/jhipster"]
EXPOSE 8080 9000 22
CMD    /usr/sbin/sshd -D
