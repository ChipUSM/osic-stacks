# OSIC Stacks - analog-xk-arch
# Dev enviroment for analog circuits development using xschem and klayout.
FROM osicstack-base-arch

# Update packages
RUN pacman -Syuq --noconfirm

# Install packages
RUN aur-install verilator gtkwave base-devel cmake

# Clean cache
RUN pacman -Scc

USER designer

# Initialize the enviroment keeping container alive
CMD ["sleep", "infinity"]