# Container image that runs your code
FROM php:7-cli
RUN apt-get update \
    && apt-get --quiet --yes --no-install-recommends install \
      keychain \
      unzip \
    && curl -L https://github.com/platformsh/platformsh-cli/releases/latest/download/platform.phar -o platform \
    && chmod +x platform && mv platform /usr/local/bin/platform \
    && curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip" \
    && unzip awscliv2.zip \
    && ./aws/install

# Copies your code file from your action repository to the filesystem path `/` of the container
COPY entrypoint.sh /entrypoint.sh

# Code file to execute when the docker container starts up (`entrypoint.sh`)
ENTRYPOINT ["/entrypoint.sh"]
