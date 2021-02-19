FROM rundeck/rundeck:SNAPSHOT

ARG TOGOVAR_GID=2021 
ARG TOGOVAR_UID=2021
ARG RUNDECK_PASS=rundeck

USER root
RUN apt-get update
RUN apt-get install -y jq
RUN groupadd -g ${TOGOVAR_GID} togovar
RUN useradd -m togovar -u ${TOGOVAR_UID} -g ${TOGOVAR_GID}
RUN echo "rundeck:$RUNDECK_PASS" | chpasswd
RUN echo "rundeck ALL=(ALL) NOPASSWD: ALL" >> /etc/sudoers
RUN gpasswd -a togovar docker
USER rundeck



