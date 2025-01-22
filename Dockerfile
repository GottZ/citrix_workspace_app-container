FROM ubuntu:22.04
MAINTAINER Jan-Stefan Janetzky <github@gottz.de>

ENV DEBIAN_FRONTEND noninteractive

RUN dpkg --add-architecture i386 && \
    apt-get update && \
    apt-get upgrade -y && \
    apt-get install -yq software-properties-common && \
    add-apt-repository ppa:mozillateam/ppa && \
    apt-get update && \
    apt-get install -y firefox-esr apt-utils xdg-utils wget && \
    wget $(wget -O - https://www.citrix.com/downloads/workspace-app/linux/workspace-app-for-linux-latest.html | sed -ne '/icaclient_.*deb/ s/<a .* rel="\(.*\)" id="downloadcomponent.*">/https:\1/p' | sed -e 's/\r//g') -O /tmp/icaclient.deb

RUN apt-get install -y libidn12 libwebkit2gtk-4.0-37 libgtk2.0-bin libva2 libspeexdsp1 \
        openssh-server wget libxpm4 libxmu6 dbus-x11 xauth libcurl4 curl libwebkitgtk-6.0-4 && \
    #apt-get install -y vim firefox apt-utils xdg-utils libwebkit2gtk-4.0-37 libgtk2.0-0 libxmu6 libxpm4 dbus-x11 xauth libcurl3 openssh-server wget && \
    #apt-get install -y vim firefox apt-utils xdg-utils libwebkit2gtk-4.0-37 libwebkitgtk-1.0-0 libxmu6 libxpm4 dbus-x11 xauth libcurl3 openssh-server wget && \
    mkdir /var/run/sshd && \
    echo "PermitEmptyPasswords yes" >> /etc/ssh/sshd_config && \
    echo "AddressFamily inet" >> /etc/ssh/sshd_config && \
    sed -i '1iauth sufficient pam_permit.so' /etc/pam.d/sshd

# todo:
# rm -rf /var/lib/apt/lists/*

#RUN wget $(wget -O - https://www.citrix.com/downloads/workspace-app/linux/workspace-app-for-linux-latest.html | sed -ne '/icaclient_.*deb/ s/<a .* rel="\(.*\)" id="downloadcomponent.*">/https:\1/p' | sed -e 's/\r//g') -O /tmp/icaclient.deb
RUN dpkg -i /tmp/icaclient.deb && \
    apt-get -y -f install && \
    rm /tmp/icaclient.deb && \
    cd /opt/Citrix/ICAClient/keystore/cacerts/ && \
    ln -s /usr/share/ca-certificates/mozilla/* /opt/Citrix/ICAClient/keystore/cacerts/ && \
    c_rehash /opt/Citrix/ICAClient/keystore/cacerts/

RUN useradd -m -s /bin/bash receiver && \
    echo "pref(\"browser.tabs.warnOnClose\", false);" >> /etc/firefox-esr/syspref.js && \
    echo "pref(\"browser.startup.homepage\", \"https://duckduckgo.com/\");" >> /etc/firefox-esr/syspref.js

USER receiver
WORKDIR /home/receiver
RUN mkdir -p .local/share/applications .config && \
    xdg-mime default wfica.desktop application/x-ica

USER root
CMD ["/usr/sbin/sshd", "-D"]
