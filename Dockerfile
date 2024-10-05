# Set the BASE_IMAGE to shellspec-kcov-docker in order to build an image that has also docker installed.
ARG BASE_IMAGE=shellspec/shellspec:kcov

# Optional base image that has docker installed. 
# The stage is skipped by buildkit if not needed for the final target stage (see https://stackoverflow.com/a/63378694).
FROM shellspec/shellspec:kcov AS shellspec-kcov-docker
RUN apk add --no-cache docker

FROM ${BASE_IMAGE}
LABEL org.opencontainers.image.authors="Michael Grafl (https://github.com/mgrafl)" \
      org.opencontainers.image.ref.name="mgrafl/shellspec-ext-invocation"
ENV PATH_TO_SHELLSPEC_EXT_INVOCATION=/opt/shellspec-ext-invocation/
ENV PATH="${PATH_TO_SHELLSPEC_EXT_INVOCATION}:${PATH}"
COPY lib/extension/invocation LICENSE ${PATH_TO_SHELLSPEC_EXT_INVOCATION}lib/extension/invocation/
COPY shellspec-ext-invocation ${PATH_TO_SHELLSPEC_EXT_INVOCATION}
RUN chmod +x "${PATH_TO_SHELLSPEC_EXT_INVOCATION}shellspec-ext-invocation"

ENTRYPOINT [ "shellspec-ext-invocation" ]
