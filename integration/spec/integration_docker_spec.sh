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
  End
End
