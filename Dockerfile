FROM debian:stable

LABEL name="jasonmorganson/dotfiles"
LABEL maintainer="Jason Morganson <jmorganson@gmail.com>"

ARG USER=jason

ENV USER=$USER \
    HOME=/home/$USER \
    LANG=en_US.UTF-8

RUN apt-get update \
    && apt-get install --yes --no-install-recommends \
    # Install sudo
    sudo \
    # Install all locales
    locales \
    # Install chezmoi requirements
    curl git \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/* \
    # Make the "en_US.UTF-8" locale
    # SEE: https://github.com/docker-library/postgres/blob/69bc540ecfffecce72d49fa7e4a46680350037f9/9.6/Dockerfile#L21-L24
    && localedef -i en_US -c -f UTF-8 -A /usr/share/locale/locale.alias en_US.UTF-8 \
    # Add user account
    && useradd --groups sudo --create-home --home-dir $HOME $USER \
    && echo "$USER ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers

USER $USER

WORKDIR $HOME

SHELL ["/bin/bash", "-o", "pipefail", "-c"]

ENV PATH=./bin:$PATH

RUN curl -sfL https://git.io/chezmoi | sh
COPY --chown=$USER . .
RUN chezmoi init --apply --verbose .

CMD ["zsh"]
