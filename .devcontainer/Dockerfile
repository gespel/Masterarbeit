FROM nvcr.io/nvidia/doca/doca:devel-cuda13.0.0-3.5.0-devel-host

RUN apt-get update \
    && DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends \
        zsh curl git ca-certificates \
    && rm -rf /var/lib/apt/lists/*

RUN sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended

RUN chsh -s "$(command -v zsh)" root
