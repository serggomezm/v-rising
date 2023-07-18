# Imagen base de Ubuntu
FROM ubuntu:22.04
# Instalar dependencias necesarias basicas
RUN apt-get update \
    && apt-get upgrade \
    && apt-get install -y \
    wget \
    build-essential

# Instalar dependencias necesarias steamcmd
RUN dpkg --add-architecture i386 \
    && add-apt-repository multiverse \
    && apt install software-properties-common \
    && apt update \
    && apt install lib32gcc-s1 steamcmd \
    && apt install wine 
    
# Crear un directorio para SteamCMD
RUN mkdir -p /opt/steamcmd

RUN cd /opt/steamcmd
RUN wget -q  https://steamcdn-a.akamaihd.net/client/installer/steamcmd_linux.tar.gz
RUN tar -xzf steamcmd_linux.tar.gz


# Crear un enlace simbólico para simplificar el uso
RUN ln -s /opt/steamcmd/steamcmd.sh /usr/local/bin/steamcmd

# Definir variables de entorno para SteamCMD
ENV STEAMCMD_DIR /opt/steamcmd
ENV STEAMCMD_GAME_ID 1829350
ENV STEAMCMD_VALIDATE ""

# Crear un usuario para ejecutar SteamCMD
RUN useradd -ms /bin/bash steam
USER steam

# Crear un directorio para la instalación del juego
RUN mkdir -p /home/steam/steamapps

# Definir el directorio de trabajo
WORKDIR /home/steam/steamapps

# Descargar e instalar el juego cuando se inicia el contenedor
RUN steamcmd +@sSteamCmdForcePlatformType windows \
             +force_install_dir ./ \
             +login anonymous \
             +app_update $STEAMCMD_APPID $STEAMCMD_VALIDATE \
             +quit
# Instalar dependencias necesarias windows vrising
RUN apt-get install -y \ 
    wine32 \ 
    wine64 \ 
    xvfb \ 
    mingw-w64 \ 
    screen

RUN cd /home/steam/steamapps/common/VRisingDedicatedServer
WORKDIR /home/steam/steamapps/common/VRisingDedicatedServer

# Definir variables de entorno DE VRISING SERVER HOST
ENV NAME Server-rising
ENV DESCRIP Server-base
ENV PORT 9876
ENV QPORT 9877
ENV MAX_USER 40
ENV MAX_ADMIN 4
ENV SERVER_FPS 30
ENV SAVE_NAME world1
ENV PASSWORD ""
ENV SECURE true
ENV LIST_STEAM false
ENV LIST_EOS false
ENV AUTO_SAVE_COUNT 20
ENV AUTO_SAVE_COUNT_INTERVAL 120
ENV COMPRE_SAVE_FILES true
ENV PRESET_GAME ""
ENV ADMIN_DEBUG true
ENV DISABLE_DEBUG false
ENV API_ENABLE_DISABLE false
ENV RCON_ENABLE_DISABLE false
ENV RCON_PORT 25575
ENV RCON_PASSWORD ""
# VARIABLES DE ENTORNO SERVER GAME
ENV GAME_MODE PvP
ENV CASTLE_DAMAGE_MODE Always
ENV WEAPON_HEALTH Normal
ENV PLAYER_DAMAGE Always
# reemplazo de archivo host y game setting
COPY substitute-env-vars.sh /home/
RUN chmod +x /app/substitute-env-vars.sh
# ejecucion de server
CMD /app/substitute-env-vars.sh && exec xvfb-run --auto-servernum --server-args='-screen 0 640x480x24:32' wine ./VRisingServer.exe -log

