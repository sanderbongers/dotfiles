.SILENT:

help: # Display help message
	echo "Available commands:\n"
	grep -E "^[^#[:space:]]+:" Makefile | grep -v "^\." | sed "s/ #//" | column -t -s ":"

install: # Install dotfiles and packages
	scripts/install.sh

update: # Update dotfiles and packages
	git pull origin main
	make install

link: # Symlink all dotfiles to home directory
	stow --verbose --ignore \.DS_Store --restow --target ~ */

unlink: # Remove all dotfile symlinks
	stow --verbose --target ~ --delete */

bundle-install: # Install Homebrew packages from global Brewfile
	brew bundle check --global --no-upgrade || brew bundle install --global --no-upgrade

bundle-dump: # Write installed Homebrew packages into global Brewfile
	brew bundle dump --global --no-restart --force

fish-check: # Parse Fish files and check isolated interactive startup
	set -eu; \
	find fish/.config/fish -type f -name '*.fish' -exec sh -c ' \
		for file do \
			fish -n "$$file" || exit 1; \
		done \
	' sh {} +; \
	tmp=$$(mktemp -d); \
	trap 'rm -rf "$$tmp"' EXIT HUP INT TERM; \
	mkdir -p "$$tmp/config" "$$tmp/cache" "$$tmp/data"; \
	cp -R fish/.config/fish "$$tmp/config/fish"; \
	for run in 1 2; do \
		stderr="$$tmp/stderr.$$run"; \
		if ! env __ssh_key_checked=1 XDG_CONFIG_HOME="$$tmp/config" XDG_CACHE_HOME="$$tmp/cache" \
			XDG_DATA_HOME="$$tmp/data" fish -i -c exit 2>"$$stderr"; then \
			cat "$$stderr" >&2; \
			exit 1; \
		fi; \
		if test -s "$$stderr"; then \
			cat "$$stderr" >&2; \
			exit 1; \
		fi; \
	done
