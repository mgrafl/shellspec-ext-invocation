#shellcheck shell=bash

# imported by "spec_helper.sh"

shellspec_syntax 'shellspec_subject_invocation'
shellspec_syntax_alias 'shellspec_subject_mock' 'shellspec_subject_invocation'


shellspec_subject_invocation() {
  shellspec_syntax_param count [ $# -ge 1 ] || return 0
  shellspec_syntax_param 1 is number "$1" || return 0

  # shellcheck disable=SC2034  # Predefined shellspec variable
  SHELLSPEC_META="mock:$1"

  # Simply store the first parameter for evaluation in the matcher
  # shellcheck disable=SC2034  # Predefined shellspec variable
  SHELLSPEC_SUBJECT="$1"
  shift

  eval shellspec_syntax_dispatch modifier ${1+'"$@"'}
}
