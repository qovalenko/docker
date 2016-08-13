#!/bin/bash

image=$(basename $0 .sh)
user=${USER:-root}
home=${HOME:-/home/$user}
uid=${UID:-1000}
gid=${uid:-1000}
tmpdir=$(mktemp -d)

echo "FROM ubuntu:14.04

RUN mkdir -p ${home} \\
 && echo \"${user}:x:${uid}:${gid}:${user},,,:${home}:/bin/bash\" >> /etc/passwd \\
 && echo \"${user}:x:${uid}:\"                                    >> /etc/group \\
 && echo \"${user} ALL=(ALL) NOPASSWD: ALL\"                       > /etc/sudoers.d/${user} \\
 && chmod 0440 /etc/sudoers.d/${user} \\
 && chown ${uid}:${gid} -R ${home}

# fonts for low-dpi screens
RUN apt-get update \\
 && apt-get -y install python-software-properties software-properties-common \\
 && add-apt-repository -y ppa:no1wantdthisname/ppa \\
 && apt-get update; apt-get -y upgrade \\
 && apt-get -y install fontconfig-infinality \\
 && sed -i -r 's|<bool>false</bool>|<bool>true</bool>|g'        /etc/fonts/infinality/conf.src/50-base-rendering-win98.conf \\
 && sed -i -r 's|USE_STYLE=\"DEFAULT\"|USE_STYLE=\"WINDOWS\"|g' /etc/profile.d/infinality-settings.sh \\
 && /etc/fonts/infinality/infctl.sh setstyle win98

RUN apt-get -y install firefox

USER ${user}
ENV HOME ${home}
CMD /usr/bin/firefox --no-remote $*
" > $tmpdir/Dockerfile

docker build -t $image $tmpdir
rm -rf $tmpdir

# this may be run under Java's `Runtime.getRuntime.exec` or from XFCE menu, in this case no `docker -t` nor `docker -t` start
ti() {
  stty -a >/dev/null
  if [ $? -eq 0 ]; then echo "-ti"; fi
}

# start tmp session, firefox: second run will create a new tab in it; chrome: start second container
# X11 requires /root/.Xauthority, Xrdp requires /tmp/X11-unix
docker run $(ti) -e DISPLAY --net=host -v $HOME/.Xauthority:${home}/.Xauthority:ro -v /tmp/.X11-unix:/tmp/.X11-unix \
  --memory=1000mb \
  --rm $image

# multimedia
#docker run $(ti) -e DISPLAY --net=host -v $HOME/.Xauthority:${home}/.Xauthority:ro -v /tmp/.X11-unix:/tmp/.X11-unix \
#  -v /dev/dri:/dev/dri \
#  -v /dev/snd:/dev/snd \
#  --privileged \
#  --memory=4000mb \
#  --rm $image

