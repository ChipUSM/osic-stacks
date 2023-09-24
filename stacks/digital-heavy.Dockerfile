# OSIC Stacks - digital-heavy
# Dev environment for digital design.
ARG BASE_IMG=osicstacks-base-desktop
FROM $BASE_IMG as digital-heavy

# Update packages
RUN sudo pacman -Syuq --noconfirm

# Install packages
RUN sudo aur-install \
    verilator \
    iverilog \
    gtkwave \
    base-devel \
    cmake

# Clean cache
RUN sudo pacman -Scc

# - Desktop build
FROM digital-heavy as digital-heavy-desktop

# Initialize the environment keeping container alive
CMD ["sleep", "infinity"]

# - Web build
FROM digital-heavy as digital-heavy-web

# Run VNC server & desktop environment
CMD ["startserver"]
