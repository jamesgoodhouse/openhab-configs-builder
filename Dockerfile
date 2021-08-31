ARG ALPINE_VERSION=3.14
ARG GOMPLATE_VERSION=3.9.0
ARG COLOR_LOGGER_VERSION=0.9.0

################################################################################

# would skip this but COPY --from doesn't do interpolation of ARGs
FROM hairyhenderson/gomplate:v${GOMPLATE_VERSION}-slim as gomplate

################################################################################

FROM alpine:${ALPINE_VERSION}
ARG COLOR_LOGGER_VERSION
RUN apk add --no-cache bash git less openssh rsync && \
    wget -O /usr/local/lib/color-logger.bash https://raw.githubusercontent.com/swyckoff/color-logger-bash/v${COLOR_LOGGER_VERSION}/color-logger.bash
COPY builder.sh /builder.sh
COPY --from=gomplate /gomplate /usr/local/bin/gomplate
ENTRYPOINT ["/builder.sh"]
