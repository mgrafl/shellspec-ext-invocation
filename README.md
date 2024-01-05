# ShellSpec Extension: Invocation

A [ShellSpec](https://github.com/shellspec/shellspec) extension for capturing mock invocations.


## Overview

This extension enables [bash](https://www.gnu.org/software/bash/)-based ShellSpec tests to capture mock invocations and to verify expectations about these invocations.

```bash
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
```

> [!TIP]
> Passing the initial command ("git" in the above example) as first argument to `capture_invocation` is not strictly required, but it helps for distinguishing between multiple mocked functions/commands.

When [mocking](https://github.com/shellspec/shellspec/#mocking) functions or commands in ShellSpec, mocks might get invoked multiple times with different arguments.

```bash
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
    When call  some_complex_task "README.md" "Initial commit"
    The number of mocks should equal 4
    The 1st mock should have received arguments  edit_file "README.md"
    The 2nd mock should have received arguments  git add "--" "README.md"
    The 3rd mock should have received arguments  git commit "-m" "Initial commit"
    The 4th mock should have received arguments  git push
  End
End
```

```bash
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
```

This extension defines:
* The `capture_invocation` function to store the command name and the supplied arguments.
* A ShellSpec *subject* `number of mocks` (aliases are `number of invocations`, `count of mocks`, and `count of invocations`) the counts how many mocks have been invoked. 
* A ShellSpec *subject* `mock` (alias: `invocation`) to select an invocation for verification matching.
* A ShellSpec *matcher* `have received arguments` to match the selected invocation against expected arguments.


## Usage

### Linux

Assuming the code from this repository is located in `/path/to/shellspec-ext-invocation`: 

```
shellspec --shell=/bin/bash --load-path=/path/to/shellpec-ext-invocation/lib/extension/invocation --require capture_invocation_helper
```

### Docker

```
docker run --rm -t -v ".:/src" mgrafl/shellspec-ext-invocation
```

## Limitations

This extension is implemented in bash and is not POSIX-compatible.
