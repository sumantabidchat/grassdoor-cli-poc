set -e

# Default settings
CLI=${CLI:-./.grassdoor-frontend-nextjs}
REPO=${REPO:-bidchatindia/grassdoor-frontend-nextjs}
REMOTE=${REMOTE:-https://github.com/${REPO}.git}
BRANCH=${BRANCH:-master}

setup_color() {
	# Only use colors if connected to a terminal
	if [ -t 1 ]; then
		RED=$(printf '\033[31m')
		GREEN=$(printf '\033[32m')
		YELLOW=$(printf '\033[33m')
		BLUE=$(printf '\033[34m')
		BOLD=$(printf '\033[1m')
		RESET=$(printf '\033[m')
	else
		RED=""
		GREEN=""
		YELLOW=""
		BLUE=""
		BOLD=""
		RESET=""
	fi
}

command_exists() {
	command -v "$@" >/dev/null 2>&1
}

error() {
	echo ${RED}"Error: $@"${RESET} >&2
}

clone_project() {
	# Prevent the cloned repository from having insecure permissions. Failing to do
	# so causes compinit() calls to fail with "command not found: compdef" errors
	# for users with insecure umasks (e.g., "002", allowing group writability). Note
	# that this will be ignored under Cygwin by default, as Windows ACLs take
	# precedence over umasks except for filesystems mounted with option "noacl".
	umask g-w,o-w

	echo "${BLUE}Cloning grassdoor-next-js...${RESET}"

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
  echo "${BLUE}Cloning grassdoor-next-js...${RESET}"

  setup_color
  clone_project

  printf "$GREEN"
	cat <<-'EOF'
    PROJECT WAS CLONED SUCCESSFULLY
	EOF
	printf "$RESET"

  # Relace ./src and ./store folder
  for file in ${CLI}/*; do
    BASENAME=$(basename "$file")
    if [ $BASENAME == 'src'  -o  $BASENAME == 'stores' -a -d $file ] 
    then
      echo "${BLUE}Copy $BASENAME ${RESET}" 
      # Remove if the directory present
      if [ -d ./$BASENAME ]
      then 
        rm -R ./$BASENAME
      fi
      cp -R ${CLI}/$BASENAME ./$BASENAME
    fi
  done

  echo "${GREEN}Provide system password to delete tmp cloned repository copy${RESET}" 
  sudo rm -r ${CLI}
}

main