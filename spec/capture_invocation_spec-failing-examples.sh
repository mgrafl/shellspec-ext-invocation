#shellcheck shell=bash
#
# Examples of failing tests for manual evaluation.
# This file is not run in this project's normal unit tests.
# Run as:  docker run --rm  -t -v ".:/src"shellspec/shellspec:kcov --pattern "*.sh" spec/capture_invocation_spec-failing-examples.sh
# 
# This includes the "mock" custom subject and
# the "have received arguments" expectation.

Describe 'capture_invocation failing examples'
  Describe 'capture_invocation in multiple mocks'
    It 'captures multiple invocations and their arguments'
      # Function mock:
      edit_file() {
        capture_invocation  edit_file "$@"
      }

      # Command mock:
      Mock git
        capture_invocation  git "$@"
      End

      some_complex_task() {
        # Do stuff
        edit_file "$1"
        git add "--" "$1"
        git commit "-m" "$2"
        git push
        # Do more stuff
      }
      # shellcheck disable=SC2016
      When call some_complex_task "README.md" 'some commit message <with> " {} with $special characters!'
      The number of mocks should equal 5  # Should fail with "got: 4"
      The 1st mock should have received arguments  edit_file  # Should fail with "expected captured arguments: 1, got: 2"
      The 2nd mock should have received arguments  git add "--" "README.md" "missing-argument"  # Should fail with "expected captured arguments: 5, got: 4"
      # shellcheck disable=SC2016
      The 3rd mock should have received arguments  git commit "-m" 'wrong-argument'  # Should fail with "argument 3: expected: 'wrong-argument', got: '...'"
      The 4th mock should have received arguments  git push  # Should succeed
      The 5th mock should have received arguments  too many invocations  # Should fail with "  # Should fail with "invalid mock number 5: only 4 mock invocations were captured"
    End
  End
End
