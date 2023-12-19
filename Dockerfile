FROM amazon/aws-lambda-provided:al2023

ARG RUST_VERSION=1.74.1

ARG CARGO_DIR=/cargo
ARG RUSTUP_DIR=/rustup

RUN dnf update -y && \
    dnf install -y gcc gcc-c++ make openssl-devel && \
    dnf clean all

RUN curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | CARGO_HOME=$CARGO_DIR RUSTUP_HOME=$RUSTUP_DIR sh -s -- -y --profile minimal --default-toolchain $RUST_VERSION

VOLUME ["/fn"]
WORKDIR /fn

COPY build.sh /build.sh
ENTRYPOINT ["/build.sh"]
