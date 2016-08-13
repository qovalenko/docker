#!/bin/bash

user=${USER:-root}
home=${HOME:-/home/$user}
uid=${UID:-1000}
gid=${uid:-1000}
tmpdir=$(mktemp -d)

echo "FROM ubuntu:16.04

RUN mkdir -p ${home} \\
 && echo \"${user}:x:${uid}:${gid}:${user},,,:${home}:/bin/bash\" >> /etc/passwd \\
 && echo \"${user}:x:${uid}:\"                                    >> /etc/group \\
 && chown ${uid}:${gid} -R ${home}

RUN apt-get update && apt-get -y install perl libwww-perl

USER ${user}
ENV HOME ${home}
CMD cd $(pwd); $*
" > $tmpdir/Dockerfile

docker build -t any $tmpdir
rm -rf $tmpdir

docker run -ti -e DISPLAY --net=host -v $HOME/.Xauthority:${home}/.Xauthority -v /tmp/.X11-unix:/tmp/.X11-unix \
  -v $(pwd):$(pwd) \
  -v ${home}/.m2:${home}/.m2 \
  -v /opt:/opt:ro \
  --memory=1000mb \
  --rm any
