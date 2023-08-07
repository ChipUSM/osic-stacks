# OSIC Stacks - analog-xk-arch
# Dev enviroment for analog circuits development using xschem and klayout.
FROM osicstack-base-arch

# Install packages
RUN aur-install xschem klayout

# Clean cache
RUN pacman -Scc

USER designer

# Initialize the enviroment keeping container alive
CMD ["sleep", "infinity"]