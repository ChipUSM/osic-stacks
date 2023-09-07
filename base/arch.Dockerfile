# OSIC Stacks - osicstack-base-arch
# Base image for OSIC Stacks
FROM greyltc/archlinux-aur:paru

# Update packages
RUN pacman -Syuq --noconfirm

# Install packages
RUN aur-install sudo git python python-pipx xz gnu-free-fonts vim

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

# Initialize the enviroment keeping container alive
CMD ["sleep", "infinity"]