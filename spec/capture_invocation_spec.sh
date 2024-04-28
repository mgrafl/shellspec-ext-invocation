#shellcheck shell=bash disable=SC2317  # Don't warn about unreachable commands in this file
#
# Meta tests of the capture invocation support functions. 
# This includes the "mock" custom subject and
# the "have received arguments" expectation.

Describe 'capture_invocation'
  # Your typical usage example:
  Describe 'capture_invocation in a simple mock'
    It 'captures an invocation and its arguments'
      Mock git
        capture_invocation  git "$@"
      End
      When run  git commit "-m" "Initial commit"
      The number of mocks should equal 1
      The first mock should have received arguments  git commit "-m" "Initial commit"
    End
  End

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
      When call some_complex_task "README.md" "Initial commit"
      The number of mocks should equal 4
      The 1st mock should have received arguments  edit_file "README.md"
      The 2nd mock should have received arguments  git add "--" "README.md"
      The 3rd mock should have received arguments  git commit "-m" "Initial commit"
      The 4th mock should have received arguments  git push
    End
  End

  # Demonstrates available aliases for subjects
  Describe 'capture_invocation expectations have aliases'
    It 'captures a simple invocation without additional arguments'
      When call capture_invocation  foo
      
      # aliases
      The invocations count should equal 1
      The count of invocations should equal 1
      The number of invocations should equal 1
      The count of mocks should equal 1
      The number of mocks should equal 1

      # aliases
      The first invocation should have received arguments  foo
      The mock 1 should have received arguments  foo
    End
  End

  It 'captures an empty invocation'
    When call capture_invocation
    The mock 1 should have received arguments
  End

  It 'captures a simple invocation without arguments and checks for negation'
    When call capture_invocation  foo
    The mock 1 should not have received arguments  bar
  End

  It 'captures multiple invocations with different arguments'
    capture_multiple_invocations() {
      capture_invocation  foo bar bla
      capture_invocation  foo blub
      capture_invocation  frobnicate 'foo filter'
    }
    When call capture_multiple_invocations
    The number of mocks should equal 3
    The 1st mock should have received arguments  foo bar bla
    The second mock should have received arguments  foo blub
    The mock 3 should have received arguments  frobnicate 'foo filter'
  End

  Describe 'invocations_count.sh'
    # From https://github.com/shellspec/shellspec/blob/0.28.1/helper/spec_helper.sh#L99
    subject_mock() {
      shellspec_output() { shellspec_puts "$1" >&2; }
    }
    BeforeRun subject_mock
    
    It 'counts empty captured invocations list'
      preserve() { 
        %preserve SHELLSPEC_META:META SHELLSPEC_SUBJECT:SUBJECT
      }
      AfterRun preserve
      When run shellspec_subject mocks number should equal 0
      The variable META should equal "number"
      The variable SUBJECT should equal "0"
      The stderr should equal MATCHED
      The status should be success
    End

    Describe 'with previously captured invocation'
      BeforeEach 'capture_invocation  foo'

      It 'matches captured invocations'
        preserve() { 
          %preserve SHELLSPEC_META:META SHELLSPEC_SUBJECT:SUBJECT
        }
        AfterRun preserve
        When run shellspec_subject mocks number should equal 1
        The variable META should equal "number"
        The variable SUBJECT should equal "1"
        The stderr should equal MATCHED
        The status should be success
      End
    End
  End


  # Now the internal stuff
  Describe 'invocation.sh'
    # From https://github.com/shellspec/shellspec/blob/0.28.1/helper/spec_helper.sh#L99
    subject_mock() {
      shellspec_output() { shellspec_puts "$1" >&2; }
    }
    BeforeRun subject_mock

    It 'outputs error if nothing was captured'
      When run shellspec_subject mock 1 should have received arguments  foo
      The stderr should equal UNMATCHED
    End

    Describe 'with previously captured invocation'
      BeforeEach 'capture_invocation  foo'

      # Based on https://github.com/shellspec/shellspec/blob/0.28.1/spec/core/subjects/variable_spec.sh
      It 'sets internal variables'
        preserve() { 
          %preserve SHELLSPEC_META:META SHELLSPEC_SUBJECT:SUBJECT
        }
        AfterRun preserve
        When run shellspec_subject mock 1 should have received arguments  foo
        The variable META should equal "mock:1"
        The variable SUBJECT should equal "1"
        The stderr should equal MATCHED
        The status should be success
      End

      It 'outputs error if invocation number is missing'
        When run shellspec_subject mock
        The stderr should equal SYNTAX_ERROR_WRONG_PARAMETER_COUNT
      End

      It 'outputs error if next word is missing'
        When run shellspec_subject mock 1
        The stderr should equal SYNTAX_ERROR_DISPATCH_FAILED
      End

      It 'outputs error if mock is not a number'
        When run shellspec_subject mock NaN should have received arguments foo
        The stderr should equal SYNTAX_ERROR_PARAM_TYPE
      End

      It 'outputs error if mock number is missing'
        # This might change in the future (i.e., could default to 1 if not specified)
        When run shellspec_subject mock should have received arguments foo
        The stderr should equal SYNTAX_ERROR_PARAM_TYPE
      End
    End
  End

  Describe 'have_received_arguments.sh'
    # From https://github.com/shellspec/shellspec/blob/0.28.1/helper/spec_helper.sh
    set_subject() {
      if subject > /dev/null; then
        SHELLSPEC_SUBJECT=$(subject; echo _)
        SHELLSPEC_SUBJECT=${SHELLSPEC_SUBJECT%_}
      else
        unset SHELLSPEC_SUBJECT ||:
      fi
    }
    # From https://github.com/shellspec/shellspec/blob/0.28.1/helper/spec_helper.sh
    matcher_mock() {
      shellspec_output() { shellspec_puts "$1" >&2; }
      shellspec_proxy "shellspec_matcher_do_match" "shellspec_matcher__match"
    }
    BeforeRun set_subject matcher_mock

    It 'fails if no invocation was captured'
      subject() {
        %- 1
      }
      When run shellspec_matcher_have_received_arguments
      The status should be failure
    End

    It 'matches empty invocation'
      BeforeRun 'capture_invocation'
      subject() {
        %- 1
      }
      When run shellspec_matcher_have_received_arguments
      The status should be success
    End

    Describe 'with previously captured invocation with single argument'
      BeforeEach 'capture_invocation  foo bar'
      subject() {
        %- 1
      }
      It 'matches invocation'
        When run shellspec_matcher_have_received_arguments  foo bar
        The status should be success
      End

      It 'fails without subject'
        subject() {
          :
        }
        When run shellspec_matcher_have_received_arguments
        The stderr should equal SYNTAX_ERROR
      End

      It 'fails with non-numeric subject'
        subject() {
          %- foo
        }
        When run shellspec_matcher_have_received_arguments
        The stderr should equal SYNTAX_ERROR
      End

      It 'fails with too small subject number'
        subject() {
          %- 0
        }
        When run shellspec_matcher_have_received_arguments
        The stderr should equal SYNTAX_ERROR
      End

      It 'fails with too large subject number'
        subject() {
          %- 2
        }
        When run shellspec_matcher_have_received_arguments
        The status should be failure
      End

      It 'does not match a different invocation'
        When run shellspec_matcher_have_received_arguments  bla bla
        The status should be failure
      End
      It 'does not match a fewer arguments'
        When run shellspec_matcher_have_received_arguments  foo
        The status should be failure
      End
      It 'does not match a more arguments'
        When run shellspec_matcher_have_received_arguments  foo bar bla
        The status should be failure
      End
    End

    Describe 'with previously captured invocation with arguments containing whitespaces'
      BeforeEach 'capture_invocation  foo bar "white space"'
      subject() {
        %- 1
      }

      It 'matches invocation'
        When run shellspec_matcher_have_received_arguments  foo bar "white space"
        The status should be success
      End
      It 'does not match separated arguments'
        When run shellspec_matcher_have_received_arguments  foo bar white space
        The status should be failure
      End
      It 'does not match combined argument'
        When run shellspec_matcher_have_received_arguments  foo "bar white space"
        The status should be failure
      End
    End

    Describe 'with previously captured invocation with arguments containing angle brackets'
      BeforeEach 'capture_invocation  foo bar "<bla>bla"'
      subject() {
        %- 1
      }

      It 'matches invocation'
        When run shellspec_matcher_have_received_arguments  foo bar "<bla>bla"
        The status should be success
      End
      It 'does not match a different invocation'
        When run shellspec_matcher_have_received_arguments  foo bar "blub"
        The status should be failure
      End
    End

    Describe 'with previously captured invocations'
      capture_multiple_invocations() {
        capture_invocation  foo bar
        capture_invocation  bla
        capture_invocation  blub ''
      }
      BeforeEach capture_multiple_invocations

      It 'matches the first invocation'
        subject() {
          %- 1
        }
        When run shellspec_matcher_have_received_arguments  foo bar
        The status should be success
      End
      It 'matches the second invocation'
        subject() {
          %- 2
        }
        When run shellspec_matcher_have_received_arguments  bla
        The status should be success
      End
      It 'matches the third invocation containing empty argument'
        subject() {
          %- 3
        }
        When run shellspec_matcher_have_received_arguments  blub ''
        The status should be success
      End
      It 'does not match the third invocation without empty argument'
        subject() {
          %- 3
        }
        When run shellspec_matcher_have_received_arguments  blub
        The status should be failure
      End
      It 'does not match the third invocation with additional empty argument'
        subject() {
          %- 3
        }
        When run shellspec_matcher_have_received_arguments  blub '' ''
        The status should be failure
      End
      It 'does not match concatenation of two invocations'
        subject() {
          %- 1
        }
        When run shellspec_matcher_have_received_arguments  foo bar bla
        The status should be failure
      End
    End

    Describe 'with previously captured invocations containing sepcial characters'
      capture_multiple_invocations() {
        capture_invocation  foo '<bar> bar %20 " {}'
        capture_invocation  bla
        capture_invocation  blub ''
      }
      BeforeEach capture_multiple_invocations

      It 'matches the first invocation'
        subject() {
          %- 1
        }
        When run shellspec_matcher_have_received_arguments  foo '<bar> bar %20 " {}'
        The status should be success
      End
      It 'matches the second invocation'
        subject() {
          %- 2
        }
        When run shellspec_matcher_have_received_arguments  bla
        The status should be success
      End
      It 'matches the third invocation containing empty argument'
        subject() {
          %- 3
        }
        When run shellspec_matcher_have_received_arguments  blub ''
        The status should be success
      End
      It 'does not match the third invocation without empty argument'
        subject() {
          %- 3
        }
        When run shellspec_matcher_have_received_arguments  blub
        The status should be failure
      End
      It 'does not match the third invocation with additional empty argument'
        subject() {
          %- 3
        }
        When run shellspec_matcher_have_received_arguments  blub '' ''
        The status should be failure
      End
      It 'does not match concatenation of two invocations'
        subject() {
          %- 1
        }
        When run shellspec_matcher_have_received_arguments  foo bar bla
        The status should be failure
      End
    End
  End
End
