FROM shellspec/shellspec:kcov

LABEL org.opencontainers.image.authors="Michael Grafl (https://github.com/mgrafl)" \
      org.opencontainers.image.ref.name="mgrafl/shellspec-ext-invocation"
ENV PATH_TO_SHELLSPEC_EXT_INVOCATION /opt/shellspec/
#ENV PATH "${PATH_TO_SHELLSPEC_EXT_INVOCATION}:${PATH}"
COPY lib/extension/invocation LICENSE ${PATH_TO_SHELLSPEC_EXT_INVOCATION}lib/extension/invocation/
COPY shellspec-ext-invocation ${PATH_TO_SHELLSPEC_EXT_INVOCATION}


ENTRYPOINT [ "shellspec-ext-invocation" ]
