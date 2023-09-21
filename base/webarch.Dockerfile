# OSIC Stacks - osicstacks-base-webarch
# Base image for OSIC Stacks
FROM osicstacks-base-arch

# Update packages
RUN sudo pacman -Syuq --noconfirm

# Install KASM VNC server
RUN paru -S --noconfirm kasmvncserver-bin

# KASM requires the hostname binary to start
RUN sudo pacman -S --noconfirm inetutils

# KASM requires the "snakeoil" certificate key for SSL authentication
# This key comes from default in debian based distributions
# For archlinux this will need to be created manually
WORKDIR /etc/ssl
RUN sudo openssl genpkey -algorithm RSA -out private/ssl-cert-snakeoil.key
RUN sudo openssl req -new -key private/ssl-cert-snakeoil.key -out certs/ssl-cert-snakeoil.csr -subj "/CN=localhost"
RUN sudo openssl x509 -req -days 365 -in certs/ssl-cert-snakeoil.csr -signkey private/ssl-cert-snakeoil.key -out certs/ssl-cert-snakeoil.pem
RUN sudo chmod 640 private/ssl-cert-snakeoil.key
RUN sudo chmod 644 certs/ssl-cert-snakeoil.pem
RUN sudo usermod -aG root designer

# Install XFCE
RUN sudo pacman -S --noconfirm xorg xfce4

# Copy includes
RUN mkdir -p /home/designer/.media
COPY --chown=designer:designer include/media/* /home/designer/.media
RUN mkdir -p /home/designer/.config/autostart
COPY --chown=designer:designer include/desktopinit.desktop /home/designer/.config/autostart

# Start VNC & desktop environment
WORKDIR /home/designer
ENTRYPOINT ["startserver"]
