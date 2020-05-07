#!/bin/bash

read -r -p "Are you sure you want to remove Grassdoor-Cli? [y/N] " confirmation
if [ "$confirmation" != y ] && [ "$confirmation" != Y ]; then
  echo "Uninstall cancelled"
  exit
fi

echo "Removing ~/.grassdoor-cli"
if [ -d ~/.grassdoor-cli ]; then
  rm -rf ~/.grassdoor-cli
fi

echo "Thanks for trying out Grassdoor-Cli. It's been uninstalled."