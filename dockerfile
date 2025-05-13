FROM kasmweb/core-ubuntu-focal:develop

USER root

# Install desktop environment and core apps
RUN apt-get update && apt-get install -y \
    xfce4 \
    xfce4-goodies \
    firefox \
    libreoffice \
    vlc \
    gimp \
    synaptic \
    software-properties-common \
    wget \
    gdebi-core \
    libappindicator3-1 \
    libgconf-2-4

# Add repositories
RUN add-apt-repository -y ppa:libretro/stable && \
    add-apt-repository -y ppa:pcsx2-team/pcsx2-daily && \
    add-apt-repository -y ppa:dolphin-emu/ppa && \
    wget -q -O - https://dl-ssl.google.com/linux/linux_signing_key.pub | apt-key add - && \
    echo "deb [arch=amd64] http://dl.google.com/linux/chrome/deb/ stable main" > /etc/apt/sources.list.d/google-chrome.list

# Install Chrome
RUN apt-get update && apt-get install -y \
    google-chrome-stable

# Install Discord
RUN wget -O /tmp/discord.deb "https://discord.com/api/download?platform=linux&format=deb" && \
    gdebi -n /tmp/discord.deb && \
    rm /tmp/discord.deb

# Install Steam and dependencies
RUN dpkg --add-architecture i386 && \
    apt-get update && \
    apt-get install -y \
    steam-installer \
    mesa-utils \
    vulkan-utils \
    libgl1-mesa-dri:i386 \
    libgl1-mesa-glx:i386 \
    libc6:i386 \
    libxtst6:i386 \
    libxrandr2:i386 \
    libglib2.0-0:i386 \
    libpulse0:i386 \
    libgdk-pixbuf2.0-0:i386 \
    libgtk2.0-0:i386 \
    libstdc++6:i386

# Automatically accept Steam license
RUN mkdir -p /usr/share/steam/steam_install_agreement && \
    echo "I have read and agree to the Steam License Agreement" > /usr/share/steam/steam_install_agreement/steam_license_agreement.txt

# Install emulators (previous setup)
RUN apt-get install -y \
    retroarch* \
    libretro-* \
    pcsx2 \
    dolphin-emu

# Configure environment for gaming
RUN echo "export PULSE_SERVER=unix:/run/user/1000/pulse/native" >> /etc/profile && \
    echo "export XDG_RUNTIME_DIR=/run/user/1000" >> /etc/profile && \
    echo "kasm-user ALL=(ALL) NOPASSWD: ALL" >> /etc/sudoers && \
    chown -R 1000:1000 /home/kasm-user

# Game controller permissions
RUN echo 'SUBSYSTEM=="input", GROUP="input", MODE="0666"' > /etc/udev/rules.d/99-input.rules && \
    usermod -a -G input kasm-user

# Copy startup script
COPY startxfce4.sh /dockerstartup/
RUN chmod +x /dockerstartup/startxfce4.sh

USER 1000
