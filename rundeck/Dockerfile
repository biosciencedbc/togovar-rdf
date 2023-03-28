FROM rundeck/rundeck:3.3.4

ARG RDF_PORTAL_GID=1118
ARG RDF_PORTAL_UID=1197
ARG RUNDECK_PASS=rundeck

USER root

RUN apt-get update && apt-get install -y git vim jq

ENV DOCKER_VERSION 18.09.2

RUN curl -fL -o docker.tgz "https://download.docker.com/linux/static/test/x86_64/docker-$DOCKER_VERSION.tgz" && \
tar --strip-component=1 -xvaf docker.tgz -C /usr/bin

RUN curl -L https://github.com/docker/compose/releases/download/1.24.1/docker-compose-'uname -s'-'uname -m' > /usr/local/bin/docker-compose && chmod +x /usr/local/bin/docker-compose

RUN groupadd -g ${RDF_PORTAL_GID} rdf_portal
RUN groupadd -g 998 docker
RUN useradd -m rdf_portal -u ${RDF_PORTAL_UID} -g ${RDF_PORTAL_GID}
RUN echo "rundeck:$RUNDECK_PASS" | chpasswd
RUN echo "rundeck ALL=(ALL) NOPASSWD: ALL" >> /etc/sudoers
RUN gpasswd -a rdf_portal docker

USER rundeck




