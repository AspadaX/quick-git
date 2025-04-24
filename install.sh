#!/usr/bin/env sh

echo "Setting up quick-git..."

# Get the absolute path to the package directory (where this script is located)
# When spm runs this script, it will be inside the package directory
PACKAGE_DIR="$(cd "$(dirname "$0")" && pwd)"

# Make sure all scripts are executable
chmod +x "${PACKAGE_DIR}/main.sh"
chmod +x "${PACKAGE_DIR}/src/config.sh"
chmod +x "${PACKAGE_DIR}/src/git_utils.sh"

# Create a wrapper script in /usr/local/bin that sets the correct package directory
if [ -d "/usr/local/bin" ]; then
  cat > /tmp/quick-git-wrapper << EOF
#!/usr/bin/env sh
# Wrapper for quick-git that ensures correct path resolution
PACKAGE_DIR="${PACKAGE_DIR}"
exec "\${PACKAGE_DIR}/main.sh" "\$@"
EOF

  # Make the wrapper executable and move it to /usr/local/bin
  chmod +x /tmp/quick-git-wrapper
  sudo mv /tmp/quick-git-wrapper /usr/local/bin/quick-git
  echo "Created symlink in /usr/local/bin/quick-git"
else
  echo "Warning: /usr/local/bin directory not found. You may need to manually add this script to your PATH."
fi

# Initial configuration setup
source "${PACKAGE_DIR}/src/config.sh"

echo "Installation complete! Run 'quick-git help' to see available commands."
