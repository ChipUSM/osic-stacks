# OSIC Stacks - analog-heavy
# Dev environment for analog design.
ARG BASE_IMG=osicstacks-base-desktop
FROM $BASE_IMG as analog-heavy

# Update packages
RUN sudo pacman -Syuq --noconfirm

# Install packages
RUN sudo aur-install \
    xschem \
    glu \
    magic-git \
    klayout \
    netgen-lvs-git

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
