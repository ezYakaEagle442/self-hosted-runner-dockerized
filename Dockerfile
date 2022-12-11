
# docker build --build-arg --no-cache -t "gha-runner" -f Dockerfile .
# docker login -u "myusername" -p "mypassword" docker.io
# docker tag gha-runner pinpindock/gha-runner
# docker push pinpindock/gha-runner

# docker tag gha-runner acrfootoo.azurecr.io/gha-runner
# az acr login --name acrfoototo.azurecr.io -u $acr_usr -p $acr_pwd
# docker push acrfoototo.azurecr.io/gha-runner
# docker pull acrfoototo.azurecr.io/gha-runner

# docker image ls
# docker run -it -p 4242:4242 gha-runner
# docker container ls
# docker ps
# docker exec -it b177880414c5 /bin/sh
# docker inspect --format '{{ .NetworkSettings.Networks.bridge.IPAddress }}' <container>
# docker inspect gha-runner  '{{ ..[0].Config.ExposedPorts }}'
# docker images --filter reference=gha-runner --format "{{.Tag}}"

# https://mcr.microsoft.com/en-us/product/azure-cli/about
# FROM mcr.microsoft.com/azure-cli:latest 

# https://docs.github.com/en/actions/using-github-hosted-runners/about-github-hosted-runners#using-a-github-hosted-runner
FROM ubuntu:22.04

LABEL Maintainer="pinpin <noname@microsoft.com>"
LABEL Description="Pod installed with Kubectl - see Dockerfile at https://github.com/ezYakaEagle442/install-kubectl-from-pod/blob/main/Dockerfile"

# https://github.com/actions/runner-images/blob/main/images/linux/Ubuntu2004-Readme.md
# https://github.com/actions/runner/tags/
ENV RUNNER_VERSION=2.299.1

RUN useradd -m actions
RUN apt-get -yqq update && apt-get install -yqq curl jq wget

RUN \
  LABEL="$(curl -s -X GET 'https://api.github.com/repos/actions/runner/releases/latest' | jq -r '.tag_name')" \
  RUNNER_VERSION="$(echo ${latest_version_label:1})" \
  cd /home/actions && mkdir actions-runner && cd actions-runner \
    && wget https://github.com/actions/runner/releases/download/v${RUNNER_VERSION}/actions-runner-linux-x64-${RUNNER_VERSION}.tar.gz \
    && tar xzf ./actions-runner-linux-x64-${RUNNER_VERSION}.tar.gz

WORKDIR /home/actions/actions-runner
RUN chown -R actions ~actions && /home/actions/actions-runner/bin/installdependencies.sh

COPY entrypoint.sh .
RUN chmod +x entrypoint.sh
USER actions

# EXPOSE ${APP_PORT}
# CMD ["bash"]
ENTRYPOINT ["./entrypoint.sh"]