#!/bin/bash

set -e

# Default settings
# CLI=${CLI:-/Users/bidchat/Documents/projects/nextjs_cli}
CLI=${CLI:-~/.grassdoor-cli}
FRAMEWORK=${FRAMEWORK:-./.grassdoor-frontend-framework}
REPO=${REPO:-bidchatindia/grassdoor-frontend-framework}
REMOTE=${REMOTE:-https://github.com/${REPO}.git}
BRANCH=${BRANCH:-master}

source $CLI/helper.sh
source $CLI/clone.sh

display_help_message() {
	cat <<-'EOF'
    There are available grassdoor-cli commands

    clone               Creat new project with Grassdoor Framework
    upgrade             Update your project with Grassdoor Framework 'master' branch
    -h  | --help        Get all available commands
    -u  | --uninstall   To uninstall grassdoor-cli
	EOF
}

exc_clone() {
  # Check if the current working directory is empty
  # Then clone the project
  # Else through error and exit
  # Call is_dir_empty from helper.sh
  is_dir_empty
  # IS_EMPTY is the return value from is_dir_empty function
  IS_EMPTY=$?
  # IS_EMPTY=0
  if [ "$IS_EMPTY" -et 1 ]
  then
    # Call clone_repo from clone.sh
    clone_repo

    # Rename pages folder to examplePages
    mv $FRAMEWORK/pages $FRAMEWORK/examplePages

    echo "Project was cloned successfully"

    # Copy files
    rsync -ap --exclude='.git' $FRAMEWORK/. ./

    echo "${GREEN}Project has setup successfully${RESET}"

    # Delete cloned folder
    rm -rf ${FRAMEWORK}
  else
    error "The directory is not empty"
    return
  fi
}

exc_upgrade() {
  # Just check if user haven't run the script on other folder
  if [ -d ./framework ] && [ -d ./pages ] && [ -d ./cypress ] && [ -f ./next.config.js ]
  then
    # Call clone_repo from clone.sh
    clone_repo
    update_files

    # Delete cloned folder
    rm -rf ${FRAMEWORK}
  else
    error "Not a Grassdoor Framework project"
    return
  fi
}

# grassdoor-cli() {
# Check arguments
# Display help message if no argument is passed
if [ "$#" -ne 1 ];
then
  display_help_message
  exit 1
else
  case $1 in
    -h | --help )
      display_help_message
      ;;
    # Clone and create project
    clone)
      exc_clone
      ;;
    # Upgrade the current project with grassdoor-framework
    upgrade)
      exc_upgrade
      ;;
    # Display error message for all other command
    *)
      error "Not a valid command!!"
      display_help_message
      ;;
  esac
fi

# return
# }