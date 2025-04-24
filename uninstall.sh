#!/usr/bin/env sh

echo "Uninstalling quick-git..."

# Remove the symlink from /usr/local/bin
if [ -L "/usr/local/bin/quick-git" ]; then
  sudo rm /usr/local/bin/quick-git
  echo "Removed symlink from /usr/local/bin/quick-git"
fi

# Note about configuration file
echo "Note: Your configuration file at ~/.quick-git.conf has not been removed."
echo "You can manually remove it with: rm ~/.quick-git.conf"

echo "Uninstallation complete!"