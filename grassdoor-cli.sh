#!/bin/bash

set -e

# Default settings
# CLI=${CLI:-/Users/bidchat/Documents/projects/nextjs_cli}
CLI=${CLI:-~/.grassdoor-cli}
FRAMEWORK=${FRAMEWORK:-./.grassdoor-frontend-framework}
REPO=${REPO:-bidchatindia/grassdoor-frontend-framework}
REMOTE=${REMOTE:-https://github.com/${REPO}.git}
BRANCH=${BRANCH:-master}
INVALID=0
COMMAND=0

source $CLI/helper.sh
source $CLI/clone.sh
source $CLI/tools/uninstall.sh

display_help_message() {
	cat <<-'EOF'
    There are available grassdoor-cli commands

    clone               Creat new project with Grassdoor Framework
    pull                Update your project with Grassdoor Framework 'master' branch
    -h  | --help        Get all available commands
    -up | --update      Update Grassdoor-Cli
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

# Check arguments
# Display help message if no argument is passed
if [ "$#" -lt 1 ];
then
  printf "$GREEN"
	cat <<-'EOF'
   ____                       _                        ____ _ _ 
  / ___|_ __ __ _ ___ ___  __| | ___   ___  _ __      / ___| (_)
 | |  _| '__/ _` / __/ __|/ _` |/ _ \ / _ \| '__|____| |   | | |
 | |_| | | | (_| \__ \__ \ (_| | (_) | (_) | | |_____| |___| | |
  \____|_|  \__,_|___/___/\__,_|\___/ \___/|_|        \____|_|_|                                                          

	EOF
	printf "$RESET"
  echo "${YELLOW}Run grassdoor-cli --help to check available commands.${RESET}"
  exit 1
else
  # Read all arguments
  while [ ! -z "$1" ]; do
    case "$1" in
      pull | -h | --help | -up | --update | -u | --uninstall | clone)
        if [ $COMMAND == 0 ]
        then
          COMMAND=$1
        else
          INVALID=1
        fi
        ;;
      origin)
        shift
        BRANCH=$1
        ;;
      *)
        INVALID=1
        ;;
    esac
    shift
  done

  # Display error message if invalid command found
  if [ $INVALID == 1 ]
  then
    error "Not a valid command!!"
    display_help_message
  else
    case $COMMAND in
      -h | --help )
        display_help_message
        ;;
      # Update the CLI
      -up | --update )
        # Check for grassdoor-cli update
        sh "$CLI/tools/upgrade.sh"
        ;;
      # Uninstall the CLI
      -u | --uninstall )
        unstall_grassdoor_cli
        ;;
      # Clone and create project
      clone)
        exc_clone
        ;;
      # Upgrade the current project with grassdoor-framework
      pull)
        exc_upgrade
        ;;
      # Display error message for all other command
      *)
        error "Not a valid command!!"
        display_help_message
        ;;
    esac
  fi
fi
