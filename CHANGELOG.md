# `chjava` changelog

## 0.0.3

* Tidy up source in response to [shellcheck] warnings, fix version
  inconsistencies between Makefile and chjava.sh.
* Tidy up Makefile.
* Improve setup script so you can pass a config dir in.
* Add documentation for the auto-switching feature.
* Add this Changlelog.

[shellcheck]: https://www.shellcheck.net/

## 0.0.2

Add chjava_auto to auto-switch JDKs, again largely nicked from [chruby], with
tweaks to reflect the different way we store the arguments for switching (an
array versus a simple string).

## 0.0.1

First release: a shell-based tool for simply switching `$JAVA_HOME` on a Mac
without mucking about with `export JAVA_HOME=$(/usr/libexec/java_home ...)`.
Derived from postmodern's excellent [chruby]. This release implements the basic
`chjava` command and doesn't try to auto-switch.

[chruby]: https://github.com/postmodern/chruby