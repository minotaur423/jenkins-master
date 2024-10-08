FROM jenkins/jenkins:2.462-jdk17

USER root

ENV TZ=America/New_York
RUN apt-get update -qq
RUN apt-get install -qqy apt-transport-https ca-certificates gnupg \curl
RUN install -m 0755 -d /etc/apt/keyrings
RUN curl -fsSL https://download.docker.com/linux/debian/gpg | gpg --dearmor -o /etc/apt/keyrings/docker.gpg
RUN chmod a+r /etc/apt/keyrings/docker.gpg
RUN echo \
  "deb [arch="$(dpkg --print-architecture)" signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/debian \
  "$(. /etc/os-release && echo "$VERSION_CODENAME")" stable" | \
  tee /etc/apt/sources.list.d/docker.list > /dev/null
RUN apt-get update -qq
RUN apt-get install -qqy docker-ce

USER jenkins

RUN jenkins-plugin-cli
