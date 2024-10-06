#shellcheck shell=bash
#
# Run this integration test with the following command:
#   Linux:
#     docker run --rm -t -v ".:/src" -v "/var/run/docker.sock:/var/run/docker.sock" --entrypoint shellspec mgrafl/shellspec-ext-invocation:docker -c integration
#
#   Windows:
#     docker run --rm -t -v ".:/src" -v "//var/run/docker.sock:/var/run/docker.sock" --entrypoint shellspec mgrafl/shellspec-ext-invocation:docker -c integration

Describe 'docker image variant'
  It 'starts a container based on the mounted Docker socket'
    When run  docker run --rm alpine:latest echo "Hello, World!"
    The output should equal "Hello, World!"
    # Depending on the Docker host, alpine:latest might or might not be available locally.
    # Pulling the image would write to stderr, which shall be ignored (see https://github.com/shellspec/shellspec/issues/122#issuecomment-726143163).
    The stderr should be defined
  End
End
