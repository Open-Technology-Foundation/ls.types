# ls.types Makefile
#
# Root install:     sudo make install
# User install:     make install
# Uninstall:        [sudo] make uninstall

SCRIPT := ls.types
CONFIG := types.conf
SYMLINKS := lsb lsbash lsp lspython lsphp

# Detect root vs user install
ifeq ($(shell id -u),0)
  PREFIX := /usr/local
  BINDIR := $(PREFIX)/bin
  CONFDIR := /etc/ls.types
else
  PREFIX := $(HOME)/.local
  BINDIR := $(PREFIX)/bin
  CONFDIR := $(PREFIX)/share/ls.types
endif

.PHONY: all install uninstall symlinks help

all: help

help:
	@echo "Usage:"
	@echo "  sudo make install    Install system-wide to /usr/local/bin"
	@echo "  make install         Install for current user to ~/.local/bin"
	@echo "  [sudo] make uninstall"
	@echo ""
	@echo "Paths (current context):"
	@echo "  Script:  $(BINDIR)/$(SCRIPT)"
	@echo "  Config:  $(CONFDIR)/$(CONFIG)"
	@echo "  Symlinks: $(SYMLINKS)"

install: $(BINDIR) $(CONFDIR)
	@echo "Installing $(SCRIPT) to $(BINDIR)"
	install -m 755 $(SCRIPT) $(BINDIR)/$(SCRIPT)
	@if [ ! -f $(CONFDIR)/$(CONFIG) ]; then \
	  echo "Installing $(CONFIG) to $(CONFDIR)"; \
	  install -m 644 $(CONFIG) $(CONFDIR)/$(CONFIG); \
	else \
	  echo "Config exists: $(CONFDIR)/$(CONFIG) (skipped)"; \
	fi
	@echo "Creating symlinks in $(BINDIR)"
	@for link in $(SYMLINKS); do \
	  ln -sf $(BINDIR)/$(SCRIPT) $(BINDIR)/$$link; \
	  echo "  $$link -> $(SCRIPT)"; \
	done
	@echo "Done."

uninstall:
	@echo "Removing $(SCRIPT) from $(BINDIR)"
	rm -f $(BINDIR)/$(SCRIPT)
	@echo "Removing symlinks from $(BINDIR)"
	@for link in $(SYMLINKS); do \
	  rm -f $(BINDIR)/$$link; \
	done
	@echo "Config preserved: $(CONFDIR)/$(CONFIG)"
	@echo "Done."

$(BINDIR):
	mkdir -p $(BINDIR)

$(CONFDIR):
	mkdir -p $(CONFDIR)
