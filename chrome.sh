#!/bin/bash

image=$(basename $0 .sh)
user=${USER:-root}
home=${HOME:-/home/$user}
uid=${UID:-1000}
gid=${uid:-1000}
tmpdir=$(mktemp -d)

escape_me() {
  perl -e 'print(join(" ", map { my $x=$_; s/\\/\\\\/g; s/\"/\\\"/g; s/`/\\`/g; s/\$/\\\$/g; s/!/\"\x27!\x27\"/g; ($x ne $_) || /\s/ ? "\"$_\"" : $_ } @ARGV))' "$@"
}

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
 && perl -pi.old -e 's/<string>DejaVu Sans<.string>//g'                      /etc/fonts/infinality/conf.src/41-repl-os-win.conf \\
 && sed -i -r 's|USE_STYLE=\"DEFAULT\"|USE_STYLE=\"WINDOWS\"|g' /etc/profile.d/infinality-settings.sh \\
 && /etc/fonts/infinality/infctl.sh setstyle win98
 
RUN apt-get -y install wget libpango1.0-0 libxss1 fonts-liberation libappindicator1 libcurl3 xdg-utils libindicator7 libpangox-1.0-0 libpangoxft-1.0-0 gconf-service libasound2 libgconf-2-4 libnspr4 libnss3 \\
 && wget https://dl.google.com/linux/direct/google-chrome-stable_current_amd64.deb \\
 && dpkg -i google-chrome-stable_current_amd64.deb \\
 && rm -f google-chrome-stable_current_amd64.deb

RUN mkdir -p ${home} \\
 && chown ${uid}:${gid} -R ${home} \\
 && echo \"${user}:x:${uid}:${gid}:${user},,,:${home}:/bin/bash\" >> /etc/passwd \\
 && echo \"${user}:x:${uid}:\"                                    >> /etc/group \\
 && [ -d /etc/sudoers.d ] || (apt-get update && apt-get -y install sudo) \\
 && echo \"${user} ALL=(ALL) NOPASSWD: ALL\"                       > /etc/sudoers.d/${user} \\
 && chmod 0440 /etc/sudoers.d/${user}
USER ${user}
ENV HOME ${home}

CMD /usr/bin/google-chrome --user-data-dir=${home}/udd \
  --disable-translate \
  --disable-notifications \
  --disable-sync \
  --disable-smooth-scrolling \
  --no-default-browser-check \
  --no-first-run \
  $(escape_me "$@")
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
#docker run $(ti) -e DISPLAY --net=host -v $HOME/.Xauthority:${home}/.Xauthority:ro -v /tmp/.X11-unix:/tmp/.X11-unix \
#  --memory=1000mb \
#  --rm $image

# multimedia
docker run $(ti) -e DISPLAY --net=host -v $HOME/.Xauthority:${home}/.Xauthority:ro -v /tmp/.X11-unix:/tmp/.X11-unix \
  -v /dev/dri:/dev/dri \
  -v /dev/snd:/dev/snd \
  --privileged \
  --memory=2000mb \
  --rm $image

# start new session every time, the state is preserved upon chrome exit and can be resumed by 'docker start <some_random_name>';
#docker run $(ti) -e DISPLAY --net=host -v $HOME/.Xauthority:${home}/.Xauthority:ro -v /tmp/.X11-unix:/tmp/.X11-unix \
#  $image

# start named session, which can be resumed by 'docker start nameff'; second start would fail
#docker run $(ti) -e DISPLAY --net=host -v $HOME/.Xauthority:${home}/.Xauthority:ro -v /tmp/.X11-unix:/tmp/.X11-unix \
#  --name nameff $image
