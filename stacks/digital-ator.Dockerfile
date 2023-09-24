# OSIC Stacks - analog-xk-arch
# Dev enviroment for analog circuits development using xschem and klayout.
ARG BASE_IMG=osicstacks-base-desktop
FROM $BASE_IMG as digital-ator

# Update packages
RUN sudo pacman -Syuq --noconfirm

# Install packages
RUN sudo aur-install \
    verilator \
    gtkwave \
    base-devel \
    cmake

# Clean cache
RUN sudo pacman -Scc

# - Desktop build
FROM digital-ator as digital-ator-desktop

# Initialize the environment keeping container alive
CMD ["sleep", "infinity"]

# - Web build
FROM digital-ator as digital-ator-web

# Run VNC server & desktop environment
CMD ["startserver"]
