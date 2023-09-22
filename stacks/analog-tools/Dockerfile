ARG BASE_IMG=analog-xk
FROM $BASE_IMG as analog-tools

# Add scripts
COPY scripts/* .

RUN ./install-open-pdks.sh

RUN rm *.sh

# Initialize the enviroment keeping container alive
CMD ["sleep", "infinity"]