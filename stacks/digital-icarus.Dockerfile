# OSIC Stacks - digital-icarus
# Dev environment for digital circuits development using icarus verilog and yosys.
ARG BASE_IMG=osicstacks-base-desktop
FROM $BASE_IMG as digital-icarus

# Update packages
RUN sudo pacman -Syuq --noconfirm

# Install packages
RUN sudo aur-install \
    iverilog \
    gtkwave \
    base-devel \
    cmake

# Clean cache
RUN sudo pacman -Scc

# - Desktop build
FROM digital-icarus as digital-icarus-desktop

# Initialize the environment keeping container alive
CMD ["sleep", "infinity"]

# - Web build
FROM digital-icarus as digital-icarus-web

# Run VNC server & desktop environment
CMD ["startserver"]
