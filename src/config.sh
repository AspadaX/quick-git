#!/usr/bin/env sh

# Default configuration values
QUICK_GIT_CONFIG_FILE="${HOME}/.quick-git.conf"

# Create default config file if it doesn't exist
if [ ! -f "${QUICK_GIT_CONFIG_FILE}" ]; then
  echo "# quick-git configuration file" > "${QUICK_GIT_CONFIG_FILE}"
  echo "GITHUB_BASE_URL=https://github.com" >> "${QUICK_GIT_CONFIG_FILE}"
  echo "DEFAULT_CONTAINER_PREFIX=xb" >> "${QUICK_GIT_CONFIG_FILE}"
  echo "# Add any other configuration options below" >> "${QUICK_GIT_CONFIG_FILE}"
fi

# Load configuration
source "${QUICK_GIT_CONFIG_FILE}"

# Function to update a configuration value
update_config() {
  local key="$1"
  local value="$2"
  
  # Check if the key already exists in the file
  if grep -q "^${key}=" "${QUICK_GIT_CONFIG_FILE}"; then
    # Replace the existing value
    sed -i.bak "s|^${key}=.*|${key}=${value}|" "${QUICK_GIT_CONFIG_FILE}" && rm "${QUICK_GIT_CONFIG_FILE}.bak"
  else
    # Add the new key-value pair
    echo "${key}=${value}" >> "${QUICK_GIT_CONFIG_FILE}"
  fi
  
  # Reload the configuration
  source "${QUICK_GIT_CONFIG_FILE}"
}

# Function to display current configuration
show_config() {
  echo "Current quick-git configuration:"
  echo "-------------------------------"
  echo "GITHUB_BASE_URL: ${GITHUB_BASE_URL}"
  echo "DEFAULT_CONTAINER_PREFIX: ${DEFAULT_CONTAINER_PREFIX}"
  echo "-------------------------------"
}