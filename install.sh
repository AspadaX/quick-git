#!/usr/bin/env sh

echo "Setting up quick-git..."

# Make sure all scripts are executable
chmod +x "$(dirname "$0")/main.sh"
chmod +x "$(dirname "$0")/src/config.sh"
chmod +x "$(dirname "$0")/src/git_utils.sh"

# Create a symlink to main.sh in /usr/local/bin for easy access
if [ -d "/usr/local/bin" ]; then
  sudo ln -sf "$(dirname "$0")/main.sh" /usr/local/bin/quick-git
  echo "Created symlink in /usr/local/bin/quick-git"
else
  echo "Warning: /usr/local/bin directory not found. You may need to manually add this script to your PATH."
fi

# Initial configuration setup
DIR="$(cd "$(dirname "$0")" && pwd)"
source "${DIR}/src/config.sh"

echo "Installation complete! Run 'quick-git help' to see available commands."