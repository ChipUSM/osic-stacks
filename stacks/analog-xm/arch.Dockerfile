# OSIC Stacks - analog-xm-arch
# Dev enviroment for analog circuits development using xschem and magic.
FROM osicstack-base-arch

# Update packages
RUN sudo pacman -Syuq --noconfirm

# Install packages
RUN sudo aur-install xschem magic

# Clean cache
RUN sudo pacman -Scc

# Initialize the enviroment keeping container alive
CMD ["sleep", "infinity"]