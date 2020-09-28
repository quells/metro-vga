FROM rust:slim-buster AS cargo
RUN cargo install uf2conv

FROM debian:10-slim
RUN apt update \
    && apt install -y \
    binutils-arm-none-eabi \
    gcc-arm-none-eabi \
    make \
    && apt clean
COPY --from=cargo \
    /usr/local/cargo/bin/uf2conv \
    /usr/local/bin/uf2conv

RUN mkdir -p /opt/build /opt/src
WORKDIR /opt
VOLUME [ "/opt/build" ]
VOLUME [ "/opt/src" ]
COPY entrypoint.sh .

ENTRYPOINT [ "./entrypoint.sh" ]
