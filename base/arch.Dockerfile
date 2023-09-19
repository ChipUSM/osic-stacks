# OSIC Stacks - osicstacks-base-arch
# Base image for OSIC Stacks
FROM greyltc/archlinux-aur:paru

# Update packages
RUN pacman -Syuq --noconfirm

# Install packages
RUN aur-install sudo git git-lfs python python-pip python-pipx xz gnu-free-fonts vim ngspice gedit jupyter-notebook

# Clean cache
RUN pacman -Scc

# Add main user
RUN useradd -m designer
RUN echo "designer ALL=(ALL:ALL) NOPASSWD: ALL" | sudo tee /etc/sudoers.d/designer

# Install volare
USER designer
ENV PATH="${PATH}:/home/designer/.local/bin"
RUN pipx install volare
WORKDIR /home/designer

# PDK Environment variables
ENV PDK_ROOT /home/designer/.volare
ENV USER designer

# Add scripts
RUN mkdir -p .scripts
COPY --chown=designer:designer --chmod=755 scripts/klayout /home/designer/.scripts
ENV PATH="/home/designer/.scripts:${PATH}"

# Initialize the enviroment keeping container alive
CMD ["sleep", "infinity"]
