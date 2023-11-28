ARG DEBIAN_RELEASE=bookworm

# Userland environment of choice
FROM debian:${DEBIAN_RELEASE}

# Git references for dependencies built from source
ARG LIB_BROADVOICE_TAG=85752d8
ARG LIB_ILBC_TAG=e186393
ARG LIB_KS_TAG=v2.0.3
ARG LIB_SILK_TAG=627102d
ARG LIB_SPANDSP_TAG=d540fdf
ARG LIB_SOFIA_TAG=v1.13.17
ARG LIB_SW_C_CLIENT=v2.0.0

# FreeSWITCH git reference
ARG FREESWITCH_TAG=v1.10.10

# Prerequisites
RUN apt-get update && \
    apt-get install -y autoconf automake build-essential bison cmake debhelper default-jdk devscripts doxygen dpkg-dev erlang-dev flite1-dev g++ gcc git ladspa-sdk libasound2-dev libavformat-dev libc6-dev libcodec2-dev libcurl4-openssl-dev libdb-dev libedit-dev libexpat1-dev libflac-dev libgdbm-compat-dev libgdbm-dev libglib2.0-dev libhiredis-dev libjpeg62-turbo-dev libldap2-dev libldns-dev liblua5.1-0-dev liblua5.2-dev libmagickcore-dev libmariadb-dev libmemcached-dev libmono-2.0-dev libmp3lame-dev libmpg123-dev libncurses5-dev libogg-dev libopencore-amrnb-dev libopencv-dev libopus-dev libopusfile-dev libpcre3-dev libperl-dev libpq-dev librabbitmq-dev libshout3-dev libsndfile1-dev libsnmp-dev libsoundtouch-dev libspeex-dev libspeexdsp-dev libsqlite3-dev libssl-dev libssl-dev libswscale-dev libtiff5-dev libtool libtool-bin libtpl-dev libnode-dev libvlc-dev libvorbis-dev libyaml-dev make mono-mcs pkg-config portaudio19-dev python3-dev python3-distutils-extra texlive unixodbc-dev uuid-dev wget yasm zlib1g-dev

RUN mkdir -p /usr/src
WORKDIR /usr/src

# Build libbroadvoice
RUN wget https://codeload.github.com/freeswitch/libbroadvoice/tar.gz/${LIB_BROADVOICE_TAG} -O - | tar zvx && \
    cd /usr/src/libbroadvoice-${LIB_BROADVOICE_TAG} && \
    ./autogen.sh && ./configure --prefix=/usr --disable-doc --enable-shared && \
    make -j && make install

# Build libilbc
RUN wget https://codeload.github.com/freeswitch/libilbc/tar.gz/${LIB_ILBC_TAG} -O - | tar zvx && \
    cd /usr/src/libilbc-${LIB_ILBC_TAG} && \
    ./bootstrap.sh && ./configure --prefix=/usr --disable-doc --enable-shared && \
    make -j && make install

# Build libks
RUN git clone -b ${LIB_KS_TAG} https://github.com/signalwire/libks.git && \
    cd /usr/src/libks && \
    cmake . -DCMAKE_INSTALL_PREFIX:PATH=/usr && \
    make -j && make install

# Build libsilk
RUN wget https://codeload.github.com/freeswitch/libsilk/tar.gz/${LIB_SILK_TAG} -O - | tar zvx && \
    cd /usr/src/libsilk-${LIB_SILK_TAG} && \
    ./bootstrap.sh && ./configure --prefix=/usr --disable-doc --enable-shared && \
    make -j && make install

# Build libspandsp
RUN wget https://codeload.github.com/freeswitch/spandsp/tar.gz/${LIB_SPANDSP_TAG} -O - | tar zvx && \
    cd /usr/src/spandsp-${LIB_SPANDSP_TAG} && \
    ./bootstrap.sh && ./configure --prefix=/usr --disable-doc --enable-shared && \
    make -j && make install

# Build libsofia
RUN wget https://codeload.github.com/freeswitch/sofia-sip/tar.gz/${LIB_SOFIA_TAG} -O - | tar zvx && \
    cd /usr/src/sofia-sip-* && \
    ./autogen.sh && ./configure --prefix=/usr --disable-doc --enable-shared && \
    make -j && make install

# Build signalwire-c-client
RUN git clone -b ${LIB_SW_C_CLIENT} https://github.com/signalwire/signalwire-c.git && \
    cd /usr/src/signalwire-c && \
    cmake . -DCMAKE_INSTALL_PREFIX:PATH=/usr && \
    make -j && make install

# Pull specific FreeSWITCH tag/release
RUN wget https://codeload.github.com/signalwire/freeswitch/tar.gz/${FREESWITCH_TAG} -O - | tar zvx

# Configure
RUN cd /usr/src/freeswitch* && \
    ./bootstrap.sh -j && \
    ./configure --with-python3 --prefix=/usr --sysconfdir=/etc --localstatedir=/var --disable-debug

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
