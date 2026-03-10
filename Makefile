# Makefile - Install ls.types
# BCS1212 compliant

PREFIX  ?= /usr/local
BINDIR  ?= $(PREFIX)/bin
CONFDIR ?= /etc/ls.types
DESTDIR ?=

SYMLINKS := ls.bash ls.python ls.php ls.js ls.perl ls.ruby ls.sh

.PHONY: all install uninstall check help

all: help

install:
	install -d $(DESTDIR)$(BINDIR)
	install -m 755 ls.types $(DESTDIR)$(BINDIR)/ls.types
	install -d $(DESTDIR)$(CONFDIR)
	@if [ ! -f $(DESTDIR)$(CONFDIR)/types.conf ]; then \
	  install -m 644 types.conf $(DESTDIR)$(CONFDIR)/types.conf; \
	fi
	@for link in $(SYMLINKS); do \
	  ln -sf ls.types $(DESTDIR)$(BINDIR)/$$link; \
	done
	@if [ -z "$(DESTDIR)" ]; then $(MAKE) --no-print-directory check; fi

uninstall:
	rm -f $(DESTDIR)$(BINDIR)/ls.types
	@for link in $(SYMLINKS); do \
	  rm -f $(DESTDIR)$(BINDIR)/$$link; \
	done

check:
	@command -v ls.types >/dev/null 2>&1 \
	  && echo 'ls.types: OK' \
	  || echo 'ls.types: NOT FOUND (check PATH)'

help:
	@echo 'Usage: make [target]'
	@echo ''
	@echo 'Targets:'
	@echo '  install     Install to $(PREFIX)'
	@echo '  uninstall   Remove installed files'
	@echo '  check       Verify installation'
	@echo '  help        Show this message'
	@echo ''
	@echo 'Install from GitHub:'
	@echo '  git clone https://github.com/Open-Technology-Foundation/ls.types.git'
	@echo '  cd ls.types && sudo make install'
