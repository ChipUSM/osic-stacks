# OSIC Stacks - analog-xk-arch
# Dev enviroment for analog circuits development using xschem and klayout.
FROM osicstack-base-arch

# Update packages
RUN sudo pacman -Syuq --noconfirm

# Install packages
RUN sudo aur-install xschem klayout

RUN pip install gdsfactory --break-system-packages
RUN pip install gf180 --upgrade --break-system-packages

# Clean cache
RUN sudo pacman -Scc

# Initialize the enviroment keeping container alive
CMD ["sleep", "infinity"]