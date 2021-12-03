ARG DEBIAN_RELEASE=bullseye

FROM debian:${DEBIAN_RELEASE}

ARG FREESWITCH_TAG=v1.10.7

# Prerequisites
RUN apt-get update && \
    apt-get install -y gnupg2 wget lsb-release && \
    wget -O /usr/share/keyrings/freeswitch-archive-keyring.gpg https://files.freeswitch.org/repo/deb/debian-release/freeswitch-archive-keyring.gpg && \
    echo "deb [signed-by=/usr/share/keyrings/freeswitch-archive-keyring.gpg] http://files.freeswitch.org/repo/deb/debian-release/ `lsb_release -sc` main" > /etc/apt/sources.list.d/freeswitch.list && \
    echo "deb-src [signed-by=/usr/share/keyrings/freeswitch-archive-keyring.gpg] http://files.freeswitch.org/repo/deb/debian-release/ `lsb_release -sc` main" >> /etc/apt/sources.list.d/freeswitch.list && \
    apt-get update && \
    apt-get build-dep -y freeswitch

# Pull desired code base
RUN mkdir -p /usr/src && \
    cd /usr/src && \
    wget https://codeload.github.com/signalwire/freeswitch/tar.gz/refs/tags/${FREESWITCH_TAG} -O - | tar zvx

# Configure
RUN cd /usr/src/freeswitch* && \
    ./bootstrap.sh -j && \
    ./configure --prefix=/usr --sysconfdir=/etc --localstatedir=/var --disable-debug

# Enable most modules
RUN cd /usr/src/freeswitch* && \
    cp ./build/modules.conf.most modules.conf && \
    sed -i \
    -e "s/#databases\/mod_mariadb/databases\/mod_mariadb/g" \
    -e "s/applications\/mod_mongo/#applications\/mod_mongo/g" \
    -e "s/applications\/mod_mp4/#applications\/mod_mp4/g" \
    -e "s/codecs\/mod_sangoma_codec/#codecs\/mod_sangoma_codec/g" \
    -e "s/codecs\/mod_siren/#codecs\/mod_siren/g" \
    modules.conf

# Build and install
RUN cd /usr/src/freeswitch* && make -j && make install

# Install audio files
RUN cd /usr/src/freeswitch* && make sounds-install && make moh-install

ENTRYPOINT ["/usr/bin/freeswitch", "-nonat"]
