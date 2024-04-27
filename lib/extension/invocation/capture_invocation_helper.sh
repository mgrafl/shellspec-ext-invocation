#shellcheck shell=bash
#
# Helper functions for capturing mock invocations.

#######################################
# Callback function that imports custom shellspec subjects and matcher.
# These enable assertions on captured invocations of mocks.
# See capture_invocations documentation for details.
# Arguments:
#   (none)
#######################################
capture_invocation_helper_configure() {
  import 'support/invocations_count'
  import 'support/invocation'
  import 'support/have_received_arguments'
}

#######################################
# Captures mock invocation arguments for later verification.
# Usage:
#   It 'captures an invocation'
#     Mock foo
#       # Adding "foo" as first argument is not strictly required,
#       # but it helps for distinguishing between multiple mocked functions/commands.
#       capture_invocation  foo "$@"
#     End
#     When run  foo bar
#     The number of mocks should equal 1
#     The first mock should have received arguments  foo bar
#   End
#
# Arguments:
#   $1..n - invocation arguments
#######################################
capture_invocation() {
  SHELLSPEC_EXT_INVOCATION_START_INDICES+=("${#SHELLSPEC_EXT_CAPTURED_INVOCATIONS[@]}")
  SHELLSPEC_EXT_CAPTURED_INVOCATIONS+=("$@")
  # The %preserve directive can only be used as part of the spec, not in helper functions. 
  # Internally, it is mapped to shellspec_preserve
  shellspec_preserve SHELLSPEC_EXT_INVOCATION_START_INDICES SHELLSPEC_EXT_CAPTURED_INVOCATIONS
}
# Exporting the function so it can be called in Mocks (see https://github.com/shellspec/shellspec#command-based-mock)
export -f capture_invocation
