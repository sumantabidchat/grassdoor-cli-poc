#!/bin/bash

set -e

# Default settings
CLI=${CLI:-~/.grassdoor-cli}
FRAMEWORK=${FRAMEWORK:-./.grassdoor-frontend-nextjs}
REPO=${REPO:-bidchatindia/grassdoor-frontend-nextjs}
REMOTE=${REMOTE:-https://github.com/${REPO}.git}
BRANCH=${BRANCH:-master}

source $CLI/helper.sh
source $CLI/clone.sh

grassdoor-cli() {
  # Check if the current working directory is empty
  # Then clone the project
  # Else through error and exit
  # Call is_dir_empty from helper.sh
  is_dir_empty '.'
  IS_EMPTY=$?
  if [ "$IS_EMPTY" -eq "1" ]
  then
    # Call clone_repo from clone.sh
    clone_repo

    # Delete cloned folder
    rm -rf ${FRAMEWORK}
  else
    error "The directory is not empty"
    exit 1
  fi
}