# ShellSpec Extension: Invocation

[![License](https://img.shields.io/github/license/shellspec/shellspec.svg)](https://github.com/mgrafl/shellspec-ext-invocation/blob/master/LICENSE)
[![Docker Image Version (latest semver)](https://img.shields.io/docker/v/mgrafl/shellspec-ext-invocation?label=DockerHub)](https://hub.docker.com/r/mgrafl/shellspec-ext-invocation)

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

This extension consists of:
* The `capture_invocation` function to store the command name and the supplied arguments.
* A ShellSpec *subject* `number of mocks` (aliases are `number of invocations`, `count of mocks`, and `count of invocations`) that counts how many mocks have been invoked. 
* A ShellSpec *subject* `mock` (alias: `invocation`) to select an invocation for verification matching.
* A ShellSpec *matcher* `have received arguments` to match the selected invocation against expected arguments.


## Usage

The easiest way to run the unit tests is via the dedicated Docker image [mgrafl/shellspec-ext-invocation](https://hub.docker.com/r/mgrafl/shellspec-ext-invocation).

### Docker

```
docker run --rm -t -v ".:/src" mgrafl/shellspec-ext-invocation
```


<details>
  <summary>
    <h3>Linux</h3>
  </summary>

Assuming the code from this repository is located in `/path/to/shellspec-ext-invocation/`, run `shellspec` directly as: 

```sh
shellspec --shell=/bin/bash --load-path=/path/to/shellpec-ext-invocation/lib/extension/invocation --require capture_invocation_helper
```

or:


```sh
PATH_TO_SHELLSPEC_EXT_INVOCATION="/path/to/shellspec-ext-invocation/"
PATH="${PATH_TO_SHELLSPEC_EXT_INVOCATION}:${PATH}"
chmod +x "${PATH_TO_SHELLSPEC_EXT_INVOCATION}shellspec-ext-invocation"

# Append ShellSpec CLI parameters as needed
shellspec-ext-invocation
```

[ShellSpec CLI](https://github.com/shellspec/shellspec#shellspec-cli) parameters can be appended to the command.
</details>

## Limitations

This extension is implemented in Bash and is not POSIX-compliant.


## Contributing

Contributions to this project via Merge Requests are welcome. 

Some general guidelines:
* Unit test your code via [ShellSpec](https://github.com/shellspec/shellspec).
* Please document all functions and any non-trivial code. Keep in mind that not everyone is an expert on advanced Bash syntax.
* Use [ShellCheck](https://github.com/koalaman/shellcheck) for static code analysis. There is a [ShellCheck extension for Visual Studio Code](https://marketplace.visualstudio.com/items?itemName=timonwong.shellcheck).
* Follow the Google [Shell Style Guide](https://google.github.io/styleguide/shellguide.html).


## License
This project is licensed under the [MIT license](LICENSE).
