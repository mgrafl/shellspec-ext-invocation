#shellcheck shell=bash

# imported by "spec_helper.sh"

# Note: The subject is written as "number of mocks", which is then converted by shellspec into "mocks number"
shellspec_syntax 'shellspec_subject_invocations_count'
shellspec_syntax_alias 'shellspec_subject_invocations_number' 'shellspec_subject_invocations_count'
shellspec_syntax_alias 'shellspec_subject_mocks_count' 'shellspec_subject_invocations_count'
shellspec_syntax_alias 'shellspec_subject_mocks_number' 'shellspec_subject_invocations_count'
shellspec_syntax_compound 'shellspec_subject_invocations'
shellspec_syntax_compound 'shellspec_subject_mocks'


shellspec_subject_invocations_count() {
  # shellcheck disable=SC2034  # Predefined shellspec variable
  SHELLSPEC_META="number"

  # shellcheck disable=SC2034,SC2154  # Predefined shellspec/extension variables
  SHELLSPEC_SUBJECT="${#SHELLSPEC_EXT_INVOCATION_START_INDICES[@]}"

  eval shellspec_syntax_dispatch modifier ${1+'"$@"'}
}
