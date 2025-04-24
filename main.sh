#!/usr/bin/env sh

# Import utility functions
DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "${DIR}/src/config.sh"
source "${DIR}/src/git_utils.sh"

# Display help information
show_help() {
  echo "quick-git: A tool for Git workflow automation"
  echo ""
  echo "USAGE:"
  echo "  quick-git [COMMAND] [ARGS]"
  echo ""
  echo "COMMANDS:"
  echo "  push [message]        Stage, commit, and push changes (with optional commit message)"
  echo "  new <branch> <repo>   Create a new branch and clone it in a container folder"
  echo "  pull                  Pull latest changes from remote branch"
  echo "  switch [branch]       Switch to a branch (or list available branches if no name provided)"
  echo "  status                Show Git status with a clean output format"
  echo "  config                Show current configuration"
  echo "  config:set <key> <value> Update configuration settings"
  echo "  setup                 Set up Git credentials"
  echo "  help                  Show this help information"
  echo ""
  echo "EXAMPLES:"
  echo "  quick-git push \"Fix login bug\""
  echo "  quick-git new feature-user-profile https://github.com/username/repo.git"
  echo "  quick-git config:set GITHUB_BASE_URL https://github.company.com"
}

# Main function to parse arguments and execute commands
main() {
  # If no arguments provided, show help
  if [ $# -eq 0 ]; then
    show_help
    return 0
  fi

  # Parse command and arguments
  COMMAND="$1"
  shift

  case "$COMMAND" in
    push)
      push_code "$*"
      ;;
      
    new)
      if [ $# -lt 2 ]; then
        echo "Error: 'new' command requires a branch name and repository URL"
        echo "Usage: quick-git new <branch-name> <repository-url>"
        return 1
      fi
      create_and_clone_branch "$1" "$2"
      ;;
      
    pull)
      pull_latest
      ;;
      
    switch)
      switch_branch "$1"
      ;;
      
    status)
      show_status
      ;;
      
    config)
      show_config
      ;;
      
    config:set)
      if [ $# -lt 2 ]; then
        echo "Error: 'config:set' command requires a key and value"
        echo "Usage: quick-git config:set <key> <value>"
        return 1
      fi
      update_config "$1" "$2"
      ;;
      
    setup)
      setup_git_credentials
      ;;
      
    help|--help|-h)
      show_help
      ;;
      
    *)
      echo "Error: Unknown command '$COMMAND'"
      echo ""
      show_help
      return 1
      ;;
  esac
}

# Execute the main function with all passed arguments
main "$@"