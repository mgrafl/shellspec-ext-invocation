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
      shellspec_output SYNTAX_ERROR "mock number '$SHELLSPEC_SUBJECT' is not a number"
      shellspec_on SYNTAX_ERROR
      return 0
    fi

    if (( "$SHELLSPEC_SUBJECT" < 1 )); then
      shellspec_output SYNTAX_ERROR "invalid mock number $SHELLSPEC_SUBJECT: must start at 1"
      shellspec_on SYNTAX_ERROR
      return 0
    fi

    # shellcheck disable=SC2034
    IFS=" $IFS" && SHELLSPEC_EXPECT="$*" && IFS=${IFS#?}

    # shellcheck disable=SC2154
    if (( "$SHELLSPEC_SUBJECT" > "${#SHELLSPEC_EXT_INVOCATION_START_INDICES[@]}" )); then
      shellspec_syntax_failure_message + \
        "invalid mock number $SHELLSPEC_SUBJECT: only ${#SHELLSPEC_EXT_INVOCATION_START_INDICES[@]} mock invocations were captured";
      return 1;
    fi

    local overall_invocations_length
    # shellcheck disable=SC2154
    overall_invocations_length="${#SHELLSPEC_EXT_CAPTURED_INVOCATIONS[@]}"

    # convert to zero-based index
    local mock_index
    mock_index=$((SHELLSPEC_SUBJECT - 1))

    local invocation_start_index
    invocation_start_index="${SHELLSPEC_EXT_INVOCATION_START_INDICES[$mock_index]}"

    if (( invocation_start_index > overall_invocations_length )); then
      shellspec_output SYNTAX_ERROR "invocation start argument index $invocation_start_index must not be greater than $overall_invocations_length"
      shellspec_on SYNTAX_ERROR
      return 0
    fi

    # For the last invocation, the end index is the overall length
    local invocation_end_index
    invocation_end_index="${SHELLSPEC_EXT_INVOCATION_START_INDICES[$SHELLSPEC_SUBJECT]:-$overall_invocations_length}"

    if (( invocation_end_index < invocation_start_index )); then
      shellspec_output SYNTAX_ERROR "invocation end argument index $invocation_start_index must not be less than $invocation_start_index"
      shellspec_on SYNTAX_ERROR
      return 0
    fi

    if (( invocation_end_index > overall_invocations_length )); then
      shellspec_output SYNTAX_ERROR "invocation end argument index $invocation_start_index must not be greater than $overall_invocations_length"
      shellspec_on SYNTAX_ERROR
      return 0
    fi

    local actual_invocation_length
    actual_invocation_length=$((invocation_end_index - invocation_start_index))

    local expected_arguments
    expected_arguments=("$@")

    # Slice array
    local actual_arguments
    actual_arguments=("${SHELLSPEC_EXT_CAPTURED_INVOCATIONS[@]:$invocation_start_index:$actual_invocation_length}")

    # Not using actual_invocation_length because it might be larger (if SHELLSPEC_EXT_INVOCATION_START_INDICES was corrputed)
    if [[ "$#" != "${#actual_arguments[@]}" ]]; then
        # Quote actual invocation arguments (to better highlight whitespaces in arguments)
        shellspec_syntax_failure_message + \
          "expected captured invocation arguments: $#, got: $actual_invocation_length" \
          "actual invocation: ${actual_arguments[*]@Q}";
        return 1;
    fi

    # Loop over arguments, verifying equality
    local expected
    local actual

    for ((i=0; i < $#; i++)); do
      expected="${expected_arguments[$i]}"
      actual="${actual_arguments[$i]}"

      if [[ "$expected" != "$actual" ]]; then
        # Quote actual invocation arguments (to better highlight whitespaces in arguments)
        shellspec_syntax_failure_message + \
          "argument $i: expected: '$expected', got: '$actual'" \
          "actual invocation: ${actual_arguments[*]@Q}";
        return 1;
      fi
    done

    # shellcheck disable=SC2016 # variable expansion is done later be shellspec
    shellspec_syntax_failure_message - \
    'expected captured invocation to not have received arguments $2' \

    return 0
  }

  shellspec_matcher_do_match "$@"
}
