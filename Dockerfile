FROM ubuntu:16.04

# install steamcmd dependencies
RUN apt-get update && apt-get -y install libcurl3 lib32gcc1 lib32stdc++6 wget

# install steamcmd
RUN mkdir -p /steam/steamcmd
WORKDIR /steam/steamcmd
RUN wget https://steamcdn-a.akamaihd.net/client/installer/steamcmd_linux.tar.gz && \
  tar -xvzf steamcmd_linux.tar.gz && \
  rm steamcmd_linux.tar.gz && \
  ./steamcmd.sh +quit

# install half-life dedicated server
# for some reason we have to run app_update twice to be succesful, the first install fails with "app state 0x6"
RUN ./steamcmd.sh +login anonymous +force_install_dir /steam/hlds +app_update 90 validate +app_update 90 validate +quit

# fixes/workarounds
RUN mkdir -p ~/.steam && \
  ln -s /steam/steamcmd/linux32 ~/.steam/sdk32

# expose ports
# VAC
EXPOSE 26900/udp
# Game data
EXPOSE 27015/udp
# RCON
EXPOSE 27015
# HLTV
EXPOSE 27020/udp

WORKDIR /steam/hlds

RUN wget -c http://www.amxmodx.org/release/amxmodx-1.8.2-base-linux.tar.gz && \
  wget -c http://www.amxmodx.org/release/amxmodx-1.8.2-cstrike-linux.tar.gz && \
  tar -xzvf amxmodx-1.8.2-base-linux.tar.gz && \
  tar -xzvf amxmodx-1.8.2-cstrike-linux.tar.gz && \
  rm *.tar.gz

# run half-life dedicated server
CMD ["./hlds_run", "-game", "cstrike", "-dev"]
