#!/bin/bash

set -e

# Default settings
CLI=${CLI:-~/.grassdoor-cli}
REPO=${REPO:-sumantabidchat/grassdoor-cli-poc}
REMOTE=${REMOTE:-https://github.com/${REPO}.git}
BRANCH=${BRANCH:-master}

source ../helper.sh

clone_project() {
	# Prevent the cloned repository from having insecure permissions. Failing to do
	# so causes compinit() calls to fail with "command not found: compdef" errors
	# for users with insecure umasks (e.g., "002", allowing group writability). Note
	# that this will be ignored under Cygwin by default, as Windows ACLs take
	# precedence over umasks except for filesystems mounted with option "noacl".
	umask g-w,o-w

	echo "${BLUE}Cloning grassdoor-cli...${RESET}"

	command_exists git || {
		error "git is not installed"
		exit 1
	}

	if [ "$OSTYPE" = cygwin ] && git --version | grep -q msysgit; then
		error "Windows/MSYS Git is not supported on Cygwin"
		error "Make sure the Cygwin git package is installed and is first on the \$PATH"
		exit 1
	fi

	git clone -c core.eol=lf -c core.autocrlf=false \
		-c fsck.zeroPaddedFilemode=ignore \
		-c fetch.fsck.zeroPaddedFilemode=ignore \
		-c receive.fsck.zeroPaddedFilemode=ignore \
		--depth=1 --branch "$BRANCH" "$REMOTE" "$CLI" || {
		error "git clone of grassdoor-frontend-nextjs repo failed"
		exit 1
	}

  echo
}

main() {
  setup_color
  clone_project

  printf "$GREEN"
	cat <<-'EOF'
   ____                       _                        ____ _ _ 
  / ___|_ __ __ _ ___ ___  __| | ___   ___  _ __      / ___| (_)
 | |  _| '__/ _` / __/ __|/ _` |/ _ \ / _ \| '__|____| |   | | |
 | |_| | | | (_| \__ \__ \ (_| | (_) | (_) | | |_____| |___| | |
  \____|_|  \__,_|___/___/\__,_|\___/ \___/|_|        \____|_|_|  ....is now installed!                                                                 

	EOF
	printf "$RESET"
  echo "${YELLOW}Run grassdoor-cli to try it out.${RESET}"
}

main