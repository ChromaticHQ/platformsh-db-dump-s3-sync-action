# Container image that runs your code
FROM php:8-cli
RUN apt-get update \
    && apt-get --quiet --yes --no-install-recommends install \
      keychain \
      unzip
RUN curl -fsSL https://raw.githubusercontent.com/platformsh/cli/main/installer.sh | bash
RUN curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip" \
    && unzip awscliv2.zip \
    && ./aws/install

# Copies your code file from your action repository to the filesystem path `/` of the container
COPY entrypoint.sh /entrypoint.sh

# Code file to execute when the docker container starts up (`entrypoint.sh`)
ENTRYPOINT ["/entrypoint.sh"]
