ARG BASE_IMG=heavy-desktop
FROM $BASE_IMG as chipathon-tools

# Add scripts
COPY --chown=designer:designer --chmod=755 stacks/chipathon-tools/scripts/global-variables.sh .

COPY --chown=designer:designer --chmod=755 stacks/chipathon-tools/scripts/install-open-pdks.sh .
RUN ./install-open-pdks.sh

COPY --chown=designer:designer --chmod=755 stacks/chipathon-tools/scripts/* .
RUN ./patch-open-pdks-gf180.sh
RUN ./patch-open-pdks-sky130.sh

RUN rm *.sh

# Initialize the enviroment keeping container alive
CMD ["sleep", "infinity"]
