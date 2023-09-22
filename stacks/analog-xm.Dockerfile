# OSIC Stacks - analog-xm
# Dev enviroment for analog circuits development using xschem and magic.
ARG BASE_IMG=osicstacks-base-native
FROM $BASE_IMG as analog-xm

# Update packages
RUN sudo pacman -Syuq --noconfirm

# Install packages
RUN sudo aur-install xschem glu magic-git

# Clean cache
RUN sudo pacman -Scc

# - Desktop build
FROM analog-xm as analog-xm-desktop

# Initialize the environment keeping container alive
CMD ["sleep", "infinity"]

# - Web build
FROM analog-xm as analog-xm-web

# Run VNC server & desktop environment
CMD ["startserver"]
