ARG BASE_IMG=heavy-desktop
FROM $BASE_IMG as chipathon-tools

# Add scripts
COPY --chown=designer:designer --chmod=755 scripts/install-open-pdks.sh .
RUN ./install-open-pdks.sh

COPY --chown=designer:designer --chmod=755 scripts/* .
RUN ./patch-open-pdks.sh

RUN rm *.sh

# Initialize the enviroment keeping container alive
CMD ["sleep", "infinity"]