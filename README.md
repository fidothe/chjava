# chjava

Changes the current Java JVM in use on macOS by changing `$JAVA_HOME`. If you
want something more, there are tools like [sdkman] which do a lot more. I wanted
as little as possible. macOS already provides a `/usr/bin/java` that really just
points to a JDK/JRE under `/Library/Java/JavaVirtualMachines/`, and a mechanism
to change which JDK is chosen (`$JAVA_HOME`).

`chjava` just makes setting `JAVA_HOME` easier than mucking about with
`export JAVA_HOME=$(/usr/libexec/java_home -v ...)` especially now that the
`java_home` tool's filtering seems a bit buggy on macOS 11 and 12. (For me, the
fact filtering for x86_64 JDKs on an Apple Silicon Mac with `java_home` is broken
was the last straw.)

## Features

* Sets `$JAVA_HOME`
* Calls `hash -r` to clear the command-lookup hash-table. (Just in case.)
* Fuzzy matching of JDK version by version number (`11` will match `11.0.8`, or the latest version installed JDK 11).
* Supports picking JDK by architecture (e.g. use x86_64 on an Apple Silicon Mac).
* Supports any macOS packaged JDK/JRE installed in the standard macOS Java place.
* Does not alter `$JAVA_HOME` by default.
* Only alters `$JAVA_HOME` when run, and nothing else.
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
wget -O chjava-0.0.1.tar.gz https://github.com/fidothe/chjava/archive/v0.0.1.tar.gz
tar -xzvf chjava-0.0.1.tar.gz
cd chjava-0.0.1/
sudo make install
```

### setup.sh

chjava also includes a `setup.sh` script, which installs chjava into /etc/profile.d.
Simply run the script as root or via `sudo`:

```shell
sudo ./scripts/setup.sh
```

Or the absolute latest chjava can be installed from source:

```shell
brew install chjava --HEAD
```

## Acknowledgements

Many thanks to postmodern, `chruby`'s author, for a tool which has been an essential part of my setup for the best part of a decade.

[chruby]: https://github.com/postmodern/chruby
[sdkman]: https://sdkman.io/
[bash]: http://www.gnu.org/software/bash/
[zsh]: http://www.zsh.org/
