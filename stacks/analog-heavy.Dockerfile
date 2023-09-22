# OSIC Stacks - analog-heavy-arch
# Dev enviroment for analog circuits development using xschem and klayout.
ARG BASE_IMG=osicstacks-base-native
FROM $BASE_IMG as analog-heavy

# Update packages
RUN sudo pacman -Syuq --noconfirm

# Install packages
RUN sudo aur-install xschem glu magic-git klayout

# Clean cache
RUN sudo pacman -Scc

# - Desktop build
FROM analog-heavy as analog-heavy-desktop

# Initialize the environment keeping container alive
CMD ["sleep", "infinity"]

# - Web build
FROM analog-heavy as analog-heavy-web

# Run VNC server & desktop environment
CMD ["startserver"]
