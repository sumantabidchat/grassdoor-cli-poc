CLI=${CLI:-~/.grassdoor-cli}

if [ -t 1 ]; then
  RED=$(printf '\033[31m')
  BLUE=$(printf '\033[34m')
  RESET=$(printf '\033[m')
else
  RED=""
  BLUE=""
  RESET=""
fi

cd "$CLI"

command_exists() {
	command -v "$@" >/dev/null 2>&1
}

command_exists git || {
    error "git is not installed"
    exit 1
}

git config core.eol lf
git config core.autocrlf false
git config fsck.zeroPaddedFilemode ignore
git config fetch.fsck.zeroPaddedFilemode ignore
git config receive.fsck.zeroPaddedFilemode ignore
resetAutoStash=$(git config --bool rebase.autoStash 2>&1)
git config rebase.autoStash true


printf "${BLUE}%s${RESET}\n" "Updating Grassdoor-Cli"
if git pull --rebase --stat origin master
then
  echo "Please provide system password to copy file(s)"
  sudo cp "${CLI}/grassdoor-cli.sh" /usr/local/bin/grassdoor-cli
  # Provide necessary permission
  sudo chmod +x /usr/local/bin/grassdoor-cli
  printf "${BLUE}%s\n" "Grassdoor-Cli has been updated and/or is at the current version."
else
  printf "${RED}%s${RESET}\n" 'There was an error updating. Try again later?'
fi

# Unset git-config values set just for the upgrade
case "$resetAutoStash" in
  "") git config --unset rebase.autoStash ;;
  *) git config rebase.autoStash "$resetAutoStash" ;;
esac