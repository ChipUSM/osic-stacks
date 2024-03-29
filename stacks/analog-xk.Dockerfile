# OSIC Stacks - analog-xk
# Dev environment for analog circuits development using xschem and klayout.
ARG BASE_IMG=osicstacks-base-desktop
FROM $BASE_IMG as analog-xk

# Update packages
RUN sudo pacman -Syuq --noconfirm

# Install packages
RUN sudo aur-install \
    xschem \
    klayout \
    netgen-lvs-git

# Clean cache
RUN sudo pacman -Scc

# - Desktop build
FROM analog-xk as analog-xk-desktop

# Initialize the environment keeping container alive
CMD ["sleep", "infinity"]

# - Web build
FROM analog-xk as analog-xk-web

# Run VNC server & desktop environment
CMD ["startserver"]
