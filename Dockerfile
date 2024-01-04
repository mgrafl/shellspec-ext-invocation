FROM shellspec/shellspec:kcov

COPY lib/extension/invocation LICENSE /opt/shellspec/lib/extension/invocation/

# Use bash, add the (slightly altered) location of the extension to the load-path, and require the extension
ENTRYPOINT [ "shellspec", "--shell=/bin/bash", "--load-path=/opt/shellspec/lib/extension/invocation", "--require", "capture_invocation_helper" ]