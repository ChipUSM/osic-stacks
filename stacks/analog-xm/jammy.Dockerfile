# OSIC Stacks - analog-xm-jammy
# Dev enviroment for analog circuits development using xschem and magic.
FROM phusion/baseimage:jammy-1.0.1

# Install packages
RUN install_clean xschem magic python3 python3-pip xz-utils git

# Install volare
RUN python3 -m pip install --upgrade --no-cache-dir volare

# Initialize the enviroment keeping container alive
CMD ["sleep", "infinity"]