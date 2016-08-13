Shell scripts to run dockerized apps
====================================

* chrome.sh - download and run latest chrome (by default with no sound)
* firefox.sh - download and run latest firefox (by default with no sound)
* firefox-with-java6.sh - download and run 32-bit firefox with 32-bit Java 6 [why and how](https://www.reddit.com/r/linuxquestions/comments/2oebqn/problems_using_ilo_java_interface_with_java_7_and/)
* freerdp.sh - compiles and runs last version of freerdp, injecting XFCE hotkey script into the container; so selected hotkeys work even if FreeRDP has focus
* u14.sh - run command line (e.g. "u14.sh perl myscript.pl") in docker sharing current directory (base image is Ubuntu 14.04)
* u16.sh - run command line (e.g. "u16.sh perl myscript.pl") in docker sharing current directory (base image is Ubuntu 16.04)
