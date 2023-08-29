FROM jenkins/jenkins:2.414.1-jdk17

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

COPY jenkins_proxy.sh /usr/local/bin/jenkins_proxy.sh
RUN chmod +x /usr/local/bin/jenkins_proxy.sh
RUN chown -R jenkins /usr/local/bin/jenkins_proxy.sh

USER jenkins

ENTRYPOINT ["/usr/bin/tini", "--", "/bin/bash", "-o", "xtrace", "-e", "/usr/local/bin/jenkins_proxy.sh"]
