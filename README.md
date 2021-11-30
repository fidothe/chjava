# chjava

[![CI](https://github.com/fidothe/chjava/actions/workflows/ci.yml/badge.svg?branch=main)](https://github.com/fidothe/chjava/actions/workflows/ci.yml)

Changes the current Java JVM in use on macOS by changing `$JAVA_HOME`. If you
want something more, there are tools like [sdkman] which do a lot more. I wanted
as little as possible.

`chjava` just makes setting `$JAVA_HOME` easier than mucking about with
`export JAVA_HOME=$(/usr/libexec/java_home -v ...)`.

## Why?

macOS provides a shim-like `/usr/bin/java` that points at one of the JDK/JRE's
under `/Library/Java/JavaVirtualMachines/`, and which can be explicitly chosen
by setting `$JAVA_HOME` to point at one of those. It also provides
`/usr/libexec/java_home` for querying available JDKs, which you often see used
like `export JAVA_HOME=$(/usr/libexec/java_home -v 11)`. I have to switch the
JDK I'm using a lot for different projects, and having to do the `export
JAVA_HOME=...` dance over and over has been both tedious and error-prone.

Added to that, `/usr/libexec/java_home`'s filtering seems a bit buggy on macOS
11 and 12. (For me, the fact filtering for x86_64 JDKs on an Apple Silicon Mac
with `java_home` is broken was the last straw.)

## Features

* Sets `$JAVA_HOME`
* Fuzzy matching of JDK version by version number (`11` will match `11.0.8`, or the latest version installed JDK 11).
* Supports picking JDK by architecture (e.g. use x86_64 on an Apple Silicon Mac).
* Supports any macOS packaged JDK/JRE installed in the standard macOS Java place.
* Does not alter `$JAVA_HOME` by default.
* Only alters `$JAVA_HOME` when run, and nothing else.
* Optionally supports auto-switching via a .java-version file.
* Supports [bash] and [zsh].
* Small (~100 LOC).
* Has tests.
* Mostly stolen (in structure if not method) from the ruby-switching tool [chruby].

## Anti-features

* Does not hook `cd`.
* Does not install executable shims or anything like that.
* Does not require Rubies be installed into your home directory.
* Does not automatically switch Rubies by default.
* Does not require write-access to the Ruby directory in order to install gems.
* Does not install JDKs for you.

## Requirements

* [bash] >= 3 or [zsh]

## Install

```shell
wget -O chjava-0.0.3.tar.gz https://github.com/fidothe/chjava/archive/v0.0.3.tar.gz
tar -xzvf chjava-0.0.3.tar.gz
cd chjava-0.0.3/
sudo make install
```

### setup.sh

chjava also includes a `setup.sh` script, which installs chjava and adds a `zshrc`/`bashrc`-type script into, by default, `/etc/profile.d` to load `chjava.sh` and `chjava/auto.sh`.
Simply run the script as root or via `sudo`:

```shell
sudo ./scripts/setup.sh
```

or, if you want to specifiy where to put the rc file:

```shell
sudo .scripts/setup.sh ~/.zshrc.d/
```

## Examples

List available JDKs:

    $ chjava
       adoptopenjdk-8.jdk 1.8.0_292 [x86_64]
       zulu-11.jdk 11.0.13 [x86_64]
       zulu-17.jdk 17.0.1 [arm64]
       zulu-8.jdk 1.8.0_312 [arm64]

Select a JDK:

    $ chjava 17
    $ chjava
       adoptopenjdk-8.jdk 1.8.0_292 [x86_64]
       zulu-11.jdk 11.0.13 [x86_64]
     * zulu-17.jdk 17.0.1 [arm64]
       zulu-8.jdk 1.8.0_312 [arm64]
    $ echo $JAVA_HOME
    /Library/Java/JavaVirtualMachines/zulu-17.jdk/Contents/Home

`chjava` ignores non-native arch JDKs by default:

    $ chjava 11
    chjava: unknown Java: 11
    $ echo $?
    1

But, you can specify the arch you want:

    $ chjava 11 x86_64
    $ chjava
       adoptopenjdk-8.jdk 1.8.0_292 [x86_64]
     * zulu-11.jdk 11.0.13 [x86_64]
       zulu-17.jdk 17.0.1 [arm64]
       zulu-8.jdk 1.8.0_312 [arm64]

Switch back to system default Java:

    $ chjava system
    $ test -z $JAVA_HOME && echo "system default"
    system default

Specify by using the JDK folder's name:

    $ chjava zulu-8.jdk
    $ chjava
       adoptopenjdk-8.jdk 1.8.0_292 [x86_64]
       zulu-11.jdk 11.0.13 [x86_64]
       zulu-17.jdk 17.0.1 [arm64]
     * zulu-8.jdk 1.8.0_312 [arm64]

## Auto-switching

If you want `chjava` to auto-switch `$JAVA_HOME` for you when you `cd` between projects, then source `chjava/auto.sh` in your `.bashrc`/`.zshrc`.

```shell
source /usr/local/share/chjava/chjava.sh
source /usr/local/share/chjava/chjava.sh
```

Much like `chruby` and other ruby auto-switchers, `chjava` will look for a special file, named `.java-version`, in the current or parent directories and switch based on it. The format is, essentially, nothing more than the arguments you'd pass to `chjava` in the file. These examples are all valid `.java-version` files.

```shell
11
```

```shell
11 arm64
```

```shell
zulu-17.jdk
```

## Acknowledgements

Many thanks to postmodern, `chruby`'s author, for a tool which has been an essential part of my setup for the best part of a decade.

[chruby]: https://github.com/postmodern/chruby
[sdkman]: https://sdkman.io/
[bash]: http://www.gnu.org/software/bash/
[zsh]: http://www.zsh.org/
