# OSIC Stacks - osicstacks-base-webarch
# Base image for OSIC Stacks
FROM osicstacks-base-arch

# Update packages
RUN sudo pacman -Syuq --noconfirm

# Install KASM VNC server
RUN paru -S --noconfirm kasmvncserver-bin

# KASM requires the hostname binary to start
RUN pacman -S --noconfirm inetutils

# KASM requires the "snakeoil" certificate key for SSL authentication
# This key comes from default in debian based distributions
# For archlinux this will need to be created manually
WORKDIR /etc/ssl
RUN sudo openssl genpkey -algorithm RSA -out private/ssl-cert-snakeoil.key
RUN sudo openssl req -new -key private/ssl-cert-snakeoil.key -out certs/ssl-cert-snakeoil.csr -subj "CN=localhost"
RUN sudo openssl x509 -req -days 365 -in certs/ssl-cert-snakeoil.csr -signkey private/ssl-cert-snakeoil.key -out certs/ssl-cert-snakeoil.pem
RUN sudo chmod 640 private/ssl-cert-snakeoil.key
RUN sudo chmod 644 certs/ssl-cert-snakeoil.pem
RUN sudo usermod -aG root designer

# Set desktop wallpaper
RUN mkdir /home/designer/.media
COPY media/defaultwallpaper.png /home/designer/.media
RUN setwallpaper /home/designer/.media/defaultwallpaper.png

# Run VNC server & desktop environment
CMD["vncserver", "-select-de", "xfce"]
