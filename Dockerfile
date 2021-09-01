ARG ALPINE_VERSION=3.14
ARG COLOR_LOGGER_VERSION=0.9.0
ARG GOLANG_VERSION=1.16
ARG GOMPLATE_VERSION=3.9.0
ARG SOPS_VERSION=3.7.1

################################################################################

# build sops from source (no arm version available currently)
FROM golang:${GOLANG_VERSION} AS sops

ARG SOPS_VERSION
ENV CGO_ENABLED=0

WORKDIR /go/src/github.com/mozilla
RUN git clone --depth 1 --branch v${SOPS_VERSION} https://github.com/mozilla/sops.git

WORKDIR /go/src/github.com/mozilla/sops/cmd/sops
RUN go get -d -v ./... && \
    go install -v ./...

################################################################################

# would skip this but COPY --from doesn't do interpolation of ARGs
FROM hairyhenderson/gomplate:v${GOMPLATE_VERSION}-slim AS gomplate

################################################################################

FROM alpine:${ALPINE_VERSION}
ARG COLOR_LOGGER_VERSION
RUN apk add --no-cache bash git less openssh rsync && \
    wget -O /usr/local/lib/color-logger.bash https://raw.githubusercontent.com/swyckoff/color-logger-bash/v${COLOR_LOGGER_VERSION}/color-logger.bash
COPY builder.sh /builder.sh
COPY --from=gomplate /gomplate /usr/local/bin/gomplate
COPY --from=sops /go/bin/sops /usr/local/bin/sops
ENTRYPOINT ["/builder.sh"]
