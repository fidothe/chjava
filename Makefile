NAME=chjava
VERSION=0.0.1
AUTHOR=fidothe
URL=https://github.com/$(AUTHOR)/$(NAME)

DIRS=etc lib bin sbin share
INSTALL_DIRS=`find $(DIRS) -type d 2>/dev/null`
INSTALL_FILES=`find $(DIRS) -type f 2>/dev/null`
DOC_FILES=*.md *.txt

PKG_DIR=pkg
PKG_NAME=$(NAME)-$(VERSION)
PKG=$(PKG_DIR)/$(PKG_NAME).tar.gz
SIG=$(PKG).asc

PREFIX?=/usr/local
SHARE_DIR=share
DOC_DIR=$(SHARE_DIR)/doc/$(PKG_NAME)

all:

pkg:
	mkdir $(PKG_DIR)

download: pkg
	wget -O $(PKG) $(URL)/archive/v$(VERSION).tar.gz

build: pkg
	git archive --output=$(PKG) --prefix=$(PKG_NAME)/ HEAD

clean:
	rm -rf test/fixtures/*
	rm -f $(PKG) $(SIG)

check:
	shellcheck share/$(NAME)/*.sh

configure_tests:
	./test/unit/configure

test: configure_tests
	SHELL=`command -v bash` ./test/unit/runner
	SHELL=`command -v zsh`  ./test/unit/runner

integration_tests:
	SHELL=`command -v bash` ./test/integration/runner
	SHELL=`command -v zsh`  ./test/integration/runner

tag:
	git push origin main
	git tag -s -m "Releasing $(VERSION)" v$(VERSION)
	git push origin main --tags

release: tag download

install:
	for dir in $(INSTALL_DIRS); do mkdir -p $(DESTDIR)$(PREFIX)/$$dir; done
	for file in $(INSTALL_FILES); do cp $$file $(DESTDIR)$(PREFIX)/$$file; done
	mkdir -p $(DESTDIR)$(PREFIX)/$(DOC_DIR)
	cp -r $(DOC_FILES) $(DESTDIR)$(PREFIX)/$(DOC_DIR)/

uninstall:
	for file in $(INSTALL_FILES); do rm -f $(DESTDIR)$(PREFIX)/$$file; done
	rm -rf $(DESTDIR)$(PREFIX)/$(DOC_DIR)
	rmdir $(DESTDIR)$(PREFIX)/$(SHARE_DIR)/chjava

.PHONY: build download clean check configure_tests test integration_tests tag release install uninstall all