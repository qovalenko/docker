#!/bin/bash

image=$(basename $0 .sh)
user=${USER:-root}
home=${HOME:-/home/$user}
uid=${UID:-1000}
gid=${uid:-1000}
tmpdir=$(mktemp -d)

echo "FROM ubuntu:16.04

# https://github.com/nodesource/docker-node/blob/master/base/ubuntu/xenial/Dockerfile
RUN apt-get update \
 && apt-get install -y --force-yes --no-install-recommends \
      apt-transport-https \
      ssh-client \
      build-essential \
      curl \
      ca-certificates \
      git \
      libicu-dev \
      'libicu[0-9][0-9].*' \
      lsb-release \
      python-all \
      rlwrap

# https://github.com/nodesource/docker-node/blob/master/ubuntu/trusty/node/5.12.0/Dockerfile
RUN curl https://deb.nodesource.com/node_5.x/pool/main/n/nodejs/nodejs_5.12.0-1nodesource1~\$(lsb_release -cs)1_amd64.deb > node.deb \\
 && dpkg -i node.deb \\
 && rm node.deb

# for electron
RUN apt-get install -y libgtk2.0-dev libxtst6 libxss1 libgconf-2-4 libnss3 libasound2 libnotify4

#RUN npm install -g pangyp\
# && ln -s $(which pangyp) $(dirname $(which pangyp))/node-gyp\
# && npm cache clear\
# && node-gyp configure || echo ""

RUN mkdir -p ${home} \\
 && chown ${uid}:${gid} -R ${home} \\
 && echo \"${user}:x:${uid}:${gid}:${user},,,:${home}:/bin/bash\" >> /etc/passwd \\
 && echo \"${user}:x:${uid}:\"                                    >> /etc/group \\
 && [ -d /etc/sudoers.d ] || (apt-get update && apt-get -y install sudo) \\
 && echo \"${user} ALL=(ALL) NOPASSWD: ALL\"                       > /etc/sudoers.d/${user} \\
 && chmod 0440 /etc/sudoers.d/${user}
USER ${user}
ENV HOME ${home}

CMD cd $(pwd); /bin/bash
#CMD cd $(pwd)/black-screen; npm start
" > $tmpdir/Dockerfile

docker build -t $image $tmpdir
rm -rf $tmpdir

docker run -ti -e DISPLAY --net=host -v $HOME/.Xauthority:${home}/.Xauthority:ro -v /tmp/.X11-unix:/tmp/.X11-unix \
  -v $(pwd):$(pwd) \
  -v ${home}/.m2:${home}/.m2 \
  -v /opt:/opt:ro \
  --memory=1000mb \
  --rm $image
