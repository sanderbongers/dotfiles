.SILENT:

help: # Display help message
	echo "Available commands:\n"
	grep -E "^[^#[:space:]]+:" Makefile | grep -v "^\." | sed "s/ #//" | column -t -s ":"

install: # Install packages and dotfiles
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
