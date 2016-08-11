#!/bin/bash

# Old Firefox with JRE 6 for managing HP servers
# https://www.reddit.com/r/linuxquestions/comments/2oebqn/problems_using_ilo_java_interface_with_java_7_and/

user=${USER:-root}
home=${HOME:-/home/$user}
uid=${UID:-1000}		
gid=${uid:-1000}
tmpdir=$(mktemp -d)

echo "FROM ubuntu:10.04

RUN mkdir -p ${home} \\		
 && echo \"${user}:x:${uid}:${gid}:${user},,,:${home}:/bin/bash\" >> /etc/passwd \\		
 && echo \"${user}:x:${uid}:\"                                    >> /etc/group \\		
 && echo \"${user} ALL=(ALL) NOPASSWD: ALL\"                       > /etc/sudoers.d/${user} \\		
 && chmod 0440 /etc/sudoers.d/${user} \\		
 && chown ${uid}:${gid} -R ${home}

RUN /bin/sed -i -r 's#archive#old-releases#g' /etc/apt/sources.list \\
 && apt-get update \\
 && apt-get -y install ia32-libs xterm wget

RUN wget --no-check-certificate --no-cookies --header 'Cookie: oraclelicense=accept-securebackup-cookie' \\
         http://download.oracle.com/otn-pub/java/jdk/6u45-b06/jre-6u45-linux-i586.bin \\
 && bash jre-6u45-linux-i586.bin
 
RUN wget --no-check-certificate https://ftp.mozilla.org/pub/firefox/releases/3.6.3/linux-i686/en-US/firefox-3.6.3.tar.bz2 \\
 && tar xjvf firefox-3.6.3.tar.bz2 \\
 && mkdir -p /usr/lib/mozilla/plugins \\
 && ln -s /jre1.6.0_45/lib/i386/libnpjp2.so /usr/lib/mozilla/plugins 

USER ${user}
ENV HOME ${home}
CMD /firefox/firefox --no-remote $*
" > $tmpdir/Dockerfile

docker build -t firefox-with-java6 $tmpdir
rm -rf $tmpdir

docker run -it -e DISPLAY --net=host -v $HOME/.Xauthority:${home}/.Xauthority -v /tmp/.X11-unix:/tmp/.X11-unix \
  --rm firefox-with-java6
