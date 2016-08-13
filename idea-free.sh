#!/bin/bash

image=$(basename $0 .sh)
user=${USER:-root}
home=${HOME:-/home/$user}
uid=${UID:-1000}
gid=${uid:-1000}
tmpdir=$(mktemp -d)

echo "FROM ubuntu:14.04

# fonts for low-dpi screens
RUN apt-get update \\
 && apt-get -y install software-properties-common \\
 && add-apt-repository -y ppa:no1wantdthisname/ppa \\
 && apt-get update; apt-get -y upgrade \\
 && apt-get -y install fontconfig-infinality \\
 && apt-get -y purge software-properties-common \\
 && apt-get -y autoremove \\
 && perl -pi.old -e 's/false/true/ if /<edit name=.antialias./ ... /<.edit/' /etc/fonts/infinality/conf.src/50-base-rendering-win98.conf \\
 && perl -pi.old -e 's/<string>DejaVu Sans<.string>//g'                      /etc/fonts/infinality/conf.d/41-repl-os-win.conf \\
 && sed -i -r 's|USE_STYLE=\"DEFAULT\"|USE_STYLE=\"WINDOWS\"|g' /etc/profile.d/infinality-settings.sh \\
 && /etc/fonts/infinality/infctl.sh setstyle win98

RUN apt-get -y install xterm wget \\
 && wget https://download.jetbrains.com/idea/ideaIC-2016.2.1.tar.gz \\
 && tar xzvf ideaIC-2016.2.1.tar.gz \\
 && rm ideaIC-2016.2.1.tar.gz

RUN mkdir -p ${home} \\
 && chown ${uid}:${gid} -R ${home} \\
 && echo \"${user}:x:${uid}:${gid}:${user},,,:${home}:/bin/bash\" >> /etc/passwd \\
 && echo \"${user}:x:${uid}:\"                                    >> /etc/group \\
 && [ -d /etc/sudoers.d ] || (apt-get update && apt-get -y install sudo) \\
 && echo \"${user} ALL=(ALL) NOPASSWD: ALL\"                       > /etc/sudoers.d/${user} \\
 && chmod 0440 /etc/sudoers.d/${user}
USER ${user}
ENV HOME ${home}

#CMD /usr/bin/xterm
CMD /idea-*/bin/idea.sh
" > $tmpdir/Dockerfile

docker build -t $image $tmpdir
rm -rf $tmpdir

# this may be run under Java's `Runtime.getRuntime.exec` or from XFCE menu, in this case no `docker -t` nor `docker -t` start
ti() {
  stty -a >/dev/null
  if [ $? -eq 0 ]; then echo "-ti"; fi
}

docker run $(ti) -e DISPLAY --net=host -v $HOME/.Xauthority:${home}/.Xauthority:ro -v /tmp/.X11-unix:/tmp/.X11-unix \
  --memory=2000mb \
  --rm $image
