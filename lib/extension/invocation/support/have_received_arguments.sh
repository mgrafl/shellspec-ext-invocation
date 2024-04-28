#shellcheck shell=bash  disable=SC2317 # all functions are reachable

# imported by "spec_helper.sh"

shellspec_syntax 'shellspec_matcher_have_received_arguments'
shellspec_syntax_compound 'shellspec_matcher_have_received'

# Since the current shellspec/shellspec Docker image still uses an older version of shellspec (presumable 0.28.*), 
# this syntax chain is still missing. Re-adding it here.
shellspec_syntax_chain 'shellspec_matcher_have'


shellspec_matcher_have_received_arguments() {
  shellspec_matcher__match() {
    if ! shellspec_is_number "${SHELLSPEC_SUBJECT:-}"; then
      shellspec_output SYNTAX_ERROR "mock number '${SHELLSPEC_SUBJECT}' is not a number"
      shellspec_on SYNTAX_ERROR
      return 0
    fi

    if (( SHELLSPEC_SUBJECT < 1 )); then
      shellspec_output SYNTAX_ERROR "invalid mock number ${SHELLSPEC_SUBJECT}: must start at 1"
      shellspec_on SYNTAX_ERROR
      return 0
    fi

    # shellcheck disable=SC2034
    IFS=" $IFS" && SHELLSPEC_EXPECT="$*" && IFS=${IFS#?}

    if (( SHELLSPEC_SUBJECT > "${#SHELLSPEC_EXT_INVOCATION_START_INDICES[@]}" )); then
      # shellcheck disable=SC2016  # variable expansion is done later be shellspec
      shellspec_syntax_failure_message + \
        'invalid mock number ${SHELLSPEC_SUBJECT}: only ${#SHELLSPEC_EXT_INVOCATION_START_INDICES[@]} mock invocations were captured';
      return 1;
    fi

    local -i overall_invocations_length
    overall_invocations_length="${#SHELLSPEC_EXT_CAPTURED_INVOCATIONS[@]}"

    # convert to zero-based index
    local -i mock_index
    mock_index=$(( SHELLSPEC_SUBJECT - 1 ))

    local -i invocation_start_index
    invocation_start_index="${SHELLSPEC_EXT_INVOCATION_START_INDICES[$mock_index]}"

    if (( invocation_start_index > overall_invocations_length )); then
      shellspec_output SYNTAX_ERROR "invocation start argument index ${invocation_start_index} must not be greater than ${overall_invocations_length}"
      shellspec_on SYNTAX_ERROR
      return 0
    fi

    # For the last invocation, the end index is the overall length
    local -i invocation_end_index
    invocation_end_index="${SHELLSPEC_EXT_INVOCATION_START_INDICES[$SHELLSPEC_SUBJECT]:-$overall_invocations_length}"

    if (( invocation_end_index < invocation_start_index )); then
      shellspec_output SYNTAX_ERROR "invocation end argument index ${invocation_start_index} must not be less than ${invocation_start_index}"
      shellspec_on SYNTAX_ERROR
      return 0
    fi

    if (( invocation_end_index > overall_invocations_length )); then
      shellspec_output SYNTAX_ERROR "invocation end argument index ${invocation_start_index} must not be greater than ${overall_invocations_length}"
      shellspec_on SYNTAX_ERROR
      return 0
    fi

    local -i actual_invocation_length
    actual_invocation_length=$(( invocation_end_index - invocation_start_index ))

    local -a expected_arguments
    expected_arguments=("$@")

    # Slice array
    # Not using local variables because shellspec_syntax_failure_message evals the a string constructed from arguments.
    # TODO declare somehow hides the variable from eval
    # declare -a SHELLSPEC_EXT_MATCH_ACTUAL_ARGUMENTS
    SHELLSPEC_EXT_MATCH_ACTUAL_ARGUMENTS=("${SHELLSPEC_EXT_CAPTURED_INVOCATIONS[@]:$invocation_start_index:$actual_invocation_length}")

    # declare -i SHELLSPEC_EXT_MATCH_EXPECTED_LENGTH
    SHELLSPEC_EXT_MATCH_EXPECTED_LENGTH=$#;
    # declare -i SHELLSPEC_EXT_MATCH_ACTUAL_LENGTH
    SHELLSPEC_EXT_MATCH_ACTUAL_LENGTH="${#SHELLSPEC_EXT_MATCH_ACTUAL_ARGUMENTS[@]}";
    
    # Not using actual_invocation_length for comparison because it might be larger (if SHELLSPEC_EXT_INVOCATION_START_INDICES was corrputed)
    if (( SHELLSPEC_EXT_MATCH_EXPECTED_LENGTH != SHELLSPEC_EXT_MATCH_ACTUAL_LENGTH )); then
        # Quote actual invocation arguments (to better highlight whitespaces in arguments)
        # shellcheck disable=SC2016  # variable expansion is done later be shellspec
        shellspec_syntax_failure_message + \
          'expected captured invocation arguments: ${SHELLSPEC_EXT_MATCH_EXPECTED_LENGTH}, got: ${SHELLSPEC_EXT_MATCH_ACTUAL_LENGTH}' \
          'actual invocation: ${SHELLSPEC_EXT_MATCH_ACTUAL_ARGUMENTS[*]@Q}';
        return 1;
    fi

    # Loop over arguments, verifying equality

    for (( i=0; i < SHELLSPEC_EXT_MATCH_EXPECTED_LENGTH; i++ )); do
      # Not using local variables because shellspec_syntax_failure_message evals the a string constructed from arguments.
      # declare SHELLSPEC_EXT_MATCH_EXPECTED
      SHELLSPEC_EXT_MATCH_EXPECTED="${expected_arguments[$i]}"
      # declare SHELLSPEC_EXT_MATCH_ACTUAL
      SHELLSPEC_EXT_MATCH_ACTUAL="${SHELLSPEC_EXT_MATCH_ACTUAL_ARGUMENTS[$i]}"

      if [[ "${SHELLSPEC_EXT_MATCH_EXPECTED}" != "${SHELLSPEC_EXT_MATCH_ACTUAL}" ]]; then
        # Quote actual invocation arguments (to better highlight whitespaces in arguments)
        # shellcheck disable=SC2016  # variable expansion is done later be shellspec
        shellspec_syntax_failure_message + \
          'argument $i: expected: '"'"'${SHELLSPEC_EXT_MATCH_EXPECTED}'"'"', got: '"'"'${SHELLSPEC_EXT_MATCH_ACTUAL}'"'" \
          'actual invocation: ${SHELLSPEC_EXT_MATCH_ACTUAL_ARGUMENTS[*]@Q}';
        return 1;
      fi
    done

    # shellcheck disable=SC2016  # variable expansion is done later be shellspec
    shellspec_syntax_failure_message - \
    'expected captured invocation to not have received arguments $2' \

    return 0
  }

  shellspec_matcher_do_match "$@"
}
