#!/bin/bash

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

RUN apt-get -y install xterm wget \\
 && wget https://download.jetbrains.com/idea/ideaIC-2016.2.1.tar.gz \\
 && tar xzvf ideaIC-2016.2.1.tar.gz \\
 && rm ideaIC-2016.2.1.tar.gz

USER ${user}
ENV HOME ${home}
#CMD /usr/bin/xterm
CMD /idea-*/bin/idea.sh 
" > $tmpdir/Dockerfile

docker build -t idea-free $tmpdir
rm -rf $tmpdir

docker run -it -e DISPLAY --net=host -v $HOME/.Xauthority:${home}/.Xauthority -v /tmp/.X11-unix:/tmp/.X11-unix \
  --memory=2000mb \
  --rm idea-free
