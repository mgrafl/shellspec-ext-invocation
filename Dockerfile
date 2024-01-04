# Note:
# Should be build with additional "--label" options for: 
# * org.opencontainers.image.created
# * org.opencontainers.image.version
# * org.opencontainers.image.revision
# * org.opencontainers.image.ref.name

FROM shellspec/shellspec:kcov

COPY lib/extension/invocation LICENSE /opt/shellspec/lib/extension/invocation/
LABEL org.opencontainers.image.authors="Michael Grafl (mgrafl)" \
      org.opencontainers.image.url="https://github.com/mgrafl/shellspec-ext-invocation" \
      org.opencontainers.image.documentation="https://github.com/mgrafl/shellspec-ext-invocation" \
      org.opencontainers.image.source="https://github.com/mgrafl/shellspec-ext-invocation.git" \
      org.opencontainers.image.licenses="MIT" \
      org.opencontainers.image.title="shellspec+kcov+extension_invocation" \
      org.opencontainers.image.description="Shellspec (Alpine based with Kcov) with extension for capturing mock invocations"

# Use bash, add the (slightly altered) location of the extension to the load-path, and require the extension
ENTRYPOINT [ "shellspec", "--shell=/bin/bash", "--load-path=/opt/shellspec/lib/extension/invocation", "--require", "capture_invocation_helper" ]
