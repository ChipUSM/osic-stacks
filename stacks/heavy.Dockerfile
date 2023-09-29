# OSIC Stacks - heavy
# Dev environment for ic design.
ARG BASE_IMG=osicstacks-base-desktop
FROM $BASE_IMG as heavy

# Update packages
RUN sudo pacman -Syuq --noconfirm

# Install packages
RUN sudo aur-install \
    xschem \
    glu \
    magic-git \
    klayout \
    netgen-lvs-git \
    verilator \
    iverilog \
    gtkwave \
    base-devel \
    cmake

# Clean cache
RUN sudo pacman -Scc

# - Desktop build
FROM heavy as heavy-desktop

# Initialize the environment keeping container alive
CMD ["sleep", "infinity"]

# - Web build
FROM heavy as heavy-web

# Run VNC server & desktop environment
CMD ["startserver"]
