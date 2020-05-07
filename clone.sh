#!/bin/bash

clone_repo() {
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
		--depth=1 --branch "$BRANCH" "$REMOTE" "$FRAMEWORK" || {
		error "git clone of grassdoor-frontend-nextjs repo failed"
		exit 1
	}

	echo "Project was cloned successfully"

  # Copy files
  rsync -av --progress "$FRAMEWORK" ./ --exclude .git

  echo "${GREEN}Project has setup successfully${RESET}"
}

update_files() {
  # Read the cloned project directory
  for file in ${FRAMEWORK}/*; do
    BASENAME=$(basename "$file")
    # -----------------------
    # If it is a DIRECTORY
    # -----------------------
    if [ -d $file ]
    then
      # Relace ./src and ./store folder
      if [ $BASENAME == 'src'  -o  $BASENAME == 'stores' ] 
      then
        echo "${BLUE}Copy $BASENAME ${RESET}" 
        # Remove if the directory present
        if [ -d ./$BASENAME ]
        then 
          rm -R ./$BASENAME
        fi
        cp -R ${FRAMEWORK}/$BASENAME ./$BASENAME
      fi
    # -----------------------
    # If it is a FILE
    # -----------------------
    elif [ -f $file ]
    then
      # Deal with next.config.js
      if [ $BASENAME == 'next.config.js' ]
      then
        # Check if the file exist
        if [ -f ./$BASENAME ]
        then
          echo "${BLUE}Comparing local and incoming $BASENAME file ${RESET}" 
          # We are using empty file as common ancestor as we don't have the previous version
          git merge-file "./$BASENAME" "$FRAMEWORK/TEST.js" "$file"
        else 
          error "${BASENAME} file not present"
        fi
      fi 
    fi
  done
}
