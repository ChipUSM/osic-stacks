# OSIC Stacks - analog-xm-arch
# Dev enviroment for analog circuits development using xschem and magic.
FROM greyltc/archlinux-aur:paru

# Update packages
RUN pacman -Syuq --noconfirm

# Install packages
RUN aur-install sudo xschem magic python python-pipx xz git gnu-free-fonts

# Install volare
RUN pipx install volare

# Clean cache
RUN pacman -Scc

# Add main user
RUN useradd -m designer
RUN echo "designer ALL=(ALL:ALL) NOPASSWD: ALL" | sudo tee /etc/sudoers.d/designer

USER designer

# Initialize the enviroment keeping container alive
CMD ["sleep", "infinity"]