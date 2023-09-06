# OSIC Stacks - analog-xk-arch
# Dev enviroment for analog circuits development using xschem and klayout.
FROM osicstack-base-arch

# Update packages
RUN sudo pacman -Syuq --noconfirm

# Install packages
RUN sudo aur-install verilator gtkwave base-devel cmake

# Clean cache
RUN sudo pacman -Scc

# Initialize the enviroment keeping container alive
CMD ["sleep", "infinity"]