.SILENT:

.PHONY: $(shell grep -E "^[^#[:space:]]+:" $(MAKEFILE_LIST) | grep -v "^\." | sed "s/:.*//")

##@ General
help: # Display help message
	echo "Usage: make <target>"
	awk -F':.*# ' '/^##@/{printf "\n%s\n", substr($$0, 5)} /^[a-zA-Z][a-zA-Z0-9_-]*:.*# /{printf "  %-22s %s\n", $$1, $$2}' Makefile

##@ Setup
install: # Install dotfiles and packages
	scripts/install.sh

update: # Update dotfiles and packages
	git pull origin main
	$(MAKE) install

doctor: # Check that dotfiles are linked, the machine profile is set, and Homebrew packages installed
	scripts/link.sh --check
	scripts/brew/bundle.sh check
	scripts/check-fish.sh

##@ Symlinks
link: # Symlink all dotfiles to home directory
	scripts/link.sh

unlink: # Remove all dotfile symlinks
	scripts/link.sh --unlink

##@ Homebrew packages
install-packages: # Install Homebrew packages for this machine
	scripts/brew/bundle.sh install

dump-packages: # Write installed Homebrew packages into the shared Brewfile
	brew bundle dump --file=Brewfile --no-restart --force

##@ macOS defaults
apply-macos-defaults: # Apply macOS user defaults and Dock layout
	scripts/macos/apply-defaults.sh

snapshot-macos: # Snapshot current macOS defaults into baseline/ for later diffing
	scripts/macos/snapshot.sh

##@ Development
test-links: # Run the linker test suite
	tests/link.sh
