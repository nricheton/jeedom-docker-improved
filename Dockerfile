FROM jeedom/jeedom:latest

MAINTAINER nicolas.richeton@gmail.com

# Preload homebridge install script
ADD plugins/homebridge/install_homebridge.sh /tmp/install_homebridge.sh

# Install script for additional setup
ADD install/setup.sh /root/setup.sh

## Preinstall dependencies
RUN apt-get update && apt-get -y dist-upgrade && \
# Mysql client & git
    apt-get install --no-install-recommends -y default-mysql-client git && \
# Plugin Network : fix ping
    apt-get install --no-install-recommends -y iputils-ping && \
# Plugin Z wave
    mkdir -p /tmp/jeedom/openzwave/ && cd /tmp && \
    git clone https://github.com/jeedom/plugin-openzwave.git && cd plugin-openzwave && git checkout master && cd resources && \
    chmod u+x ./install_apt.sh && ./install_apt.sh && cd /tmp && rm -Rf plugin-openzwave && \
# Plugin Homebridge
    cd /tmp && chmod u+x ./install_homebridge.sh && ./install_homebridge.sh && \
# Camera 
# Note: libav-tools python-imaging are deprecated
     apt-get install --no-install-recommends -y ffmpeg  python-pil php-gd  && \
# Freebox OS
     apt-get install --no-install-recommends -y  android-tools-adb netcat  && \
# PlayTTS
    cd /tmp && \
    git clone https://github.com/lunarok/jeedom_playtts.git && cd jeedom_playtts && git checkout master && cd resources && \
    sed -i 's/sudo usermod -a -G audio `whoami`/sudo usermod -a -G audio www-data/' ./install.sh && \
    chmod u+x ./install.sh && ./install.sh && cd /tmp && rm -Rf jeedom_playtts && \
# Reduce image size
    apt-get clean && rm -rf /var/lib/apt/lists/* && \
#Setup 
    sed -i 's/.*service atd restart.*/service atd restart\n. \/root\/setup.sh/' /root/init.sh
