ARG UBUNTU_VERSION=20.04
FROM ubuntu:${UBUNTU_VERSION}
ENV DEBIAN_FRONTEND=nonintercative
RUN mkdir -p /app/src
WORKDIR /app

# development dependencies
RUN apt-get update -y && apt-get install -y \
  automake \
  build-essential \
  g++\
  git \
  jq \
  nodejs \
  libicu-dev \
  libffi-dev \
  libgmp-dev \
  libncursesw5 \
  libpq-dev \
  libssl-dev \
  libsystemd-dev \
  libtinfo-dev \
  libtool \
  make \
  pkg-config \
  tmux \
  wget \
  zlib1g-dev libreadline-dev llvm libnuma-dev \
  && rm -rf /var/lib/apt/lists/*

ARG CABAL_VERSION=3.6.2.0
ARG GHC_VERSION=8.10.7
ARG HLS_VERSION=1.7.0.0
ARG CARDANO_NODE_VERSION=1.35.6
ARG CHAIN=preview
ARG IOHK_LIBSODIUM_GIT_REV=66f017f16633f2060db25e17c170c2afa0f2a8a1
ARG IOKH_LIBSECP251_GIT_REV=ac83be33d0956faf6b7f61a60ab524ef7d6a473a

# install secp2561k library with prefix '/'
RUN git clone https://github.com/bitcoin-core/secp256k1 &&\
  cd secp256k1 \
  && git fetch --all --tags &&\
  git checkout ${IOKH_LIBSECP251_GIT_REV} \
  && ./autogen.sh && \
  ./configure --prefix=/usr --enable-module-schnorrsig --enable-experimental && \
  make && \
  make install  && cd .. && rm -rf ./secp256k1


# install libsodium from sources with prefix '/'
RUN git clone https://github.com/input-output-hk/libsodium.git &&\
  cd libsodium \
  && git fetch --all --tags &&\
  git checkout ${IOHK_LIBSODIUM_GIT_REV} \
  && ./autogen.sh && \
  ./configure --prefix=/usr && \
  make && \
  make install  && cd .. && rm -rf ./libsodium


# install ghcup
ENV PATH=${PATH}:${HOME:-/root}/.ghcup/bin
RUN wget --secure-protocol=TLSv1_2 \
  https://downloads.haskell.org/~ghcup/$(arch)-linux-ghcup  \ 
  && chmod +x $(arch)-linux-ghcup \
  && mkdir -p ${HOME:-/root}/.ghcup/bin \
  && mv $(arch)-linux-ghcup ${HOME:-/root}/.ghcup/bin/ghcup 

RUN ghcup config set downloader Wget \ 
  && ghcup install ghc ${GHC_VERSION} \
  && ghcup install cabal ${CABAL_VERSION} \
  && ghcup set ghc ${GHC_VERSION}
RUN ghcup install hls ${HLS_VERSION}

# install cardano-node
ENV PATH=${PATH}:${HOME:-/root}/.local/bin
RUN wget --secure-protocol=TLSv1_2 \
  https://s3.ap-southeast-1.amazonaws.com/update-cardano-mainnet.iohk.io/cardano-node-releases/cardano-node-${CARDANO_NODE_VERSION}-linux.tar.gz \
  && chmod +x cardano-node-${CARDANO_NODE_VERSION}-linux.tar.gz \
  && mkdir -p ${HOME:-/root}/.local/bin \
  && mv cardano-node-${CARDANO_NODE_VERSION}-linux.tar.gz ${HOME:-/root}/.local/bin \
  && cd ${HOME:-/root}/.local/bin \
  && tar xvf cardano-node-${CARDANO_NODE_VERSION}-linux.tar.gz

# download setting files
RUN mkdir -p ${HOME:-/root}/cardano \
    && cd ${HOME:-/root}/cardano \
    && mkdir -p db \
    && wget --secure-protocol=TLSv1_2 https://book.world.dev.cardano.org/environments/${CHAIN}/config.json \
    && wget --secure-protocol=TLSv1_2 https://book.world.dev.cardano.org/environments/${CHAIN}/byron-genesis.json \
    && wget --secure-protocol=TLSv1_2 https://book.world.dev.cardano.org/environments/${CHAIN}/shelley-genesis.json \
    && wget --secure-protocol=TLSv1_2 https://book.world.dev.cardano.org/environments/${CHAIN}/alonzo-genesis.json \
    && cat config.json | jq '. |= .+ {"enableP2P": true}'

# set an alias to .bashrc
RUN echo "alias mc='CARDANO_NODE_SOCKET_PATH=/root/cardano/node.socket NETWORK=2 cabal run market-cli'" >> /root/.bashrc