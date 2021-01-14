# Build

FROM phusion/baseimage:bionic-1.0.0 AS build

RUN apt-get -y update
RUN apt-get -y upgrade
RUN apt-get install -y --no-install-recommends \
        autoconf automake autopoint gettext texinfo gperf flex gcc git isc-dhcp-client \
        libidn2-0 libc6 libpsl-dev libpcre3-dev pkg-config libzstd-dev libssl-dev jq \
        libgnutls28-dev liblua5.1-0 liblua5.1-0-dev make net-tools pciutils sudo \
        python3 python3-pip python3-setuptools rsync software-properties-common wget curl
#RUN apt-get install -y libc-ares-dev
#libmetalink libcares

WORKDIR /app
RUN git clone --depth 1 --recurse-submodules https://github.com/ArchiveTeam/wget-lua.git

WORKDIR /app/wget-lua

RUN ./bootstrap
RUN ./configure --with-ssl=openssl --without-zstandard
RUN make


# Production

FROM python:3.9.1-slim-buster

COPY --from=build /app/wget-lua/src/wget /usr/local/bin/wget-at

RUN apt update
RUN apt upgrade -y
RUN apt install -y git liblua5.1-0 rsync
RUN apt-get install -y luarocks

RUN pip3 install setuptools wheel
RUN pip3 install requests warcio
RUN pip3 install -e git+https://github.com/SrihariThalla/seesaw-kit.git@edbd09f9eb84d27dc6ac70834215034ebad8bf0f#egg=seesaw
RUN pip3 install zstandard

WORKDIR /app

RUN mkdir data
RUN mkdir projects

RUN git clone --depth 1 --recurse-submodules https://github.com/ArchiveTeam/warrior-code2.git

EXPOSE 8001

COPY start.py .

CMD [ "python", "start.py" ]
