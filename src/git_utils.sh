#!/usr/bin/env sh

# Import configuration
DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "${DIR}/config.sh"

# Function to push code to the remote branch
push_code() {
  local commit_message="$1"
  local branch_name=$(git rev-parse --abbrev-ref HEAD)
  
  # Check if we're in a git repository
  if ! git rev-parse --is-inside-work-tree > /dev/null 2>&1; then
    echo "Error: Not in a git repository"
    return 1
  fi
  
  # If no commit message is provided, prompt for one
  if [ -z "$commit_message" ]; then
    echo "Enter commit message:"
    read -r commit_message
    if [ -z "$commit_message" ]; then
      echo "Error: Commit message cannot be empty"
      return 1
    fi
  fi
  
  # Stage all changes, commit, and push
  echo "Pushing changes to branch: $branch_name"
  git add .
  git commit -m "$commit_message"
  git push origin "$branch_name"
  
  if [ $? -eq 0 ]; then
    echo "Successfully pushed changes to $branch_name"
  else
    echo "Error pushing changes to $branch_name"
    return 1
  fi
}

# Function to create a new branch in remote and clone it locally
create_and_clone_branch() {
  local branch_name="$1"
  local repo_url="$2"
  local date_suffix=$(date +"%Y-%m-%d")
  local container_folder="${DEFAULT_CONTAINER_PREFIX}-${branch_name}-${date_suffix}"
  
  # Validate inputs
  if [ -z "$branch_name" ]; then
    echo "Error: Branch name is required"
    return 1
  fi
  
  if [ -z "$repo_url" ]; then
    echo "Error: Repository URL is required"
    return 1
  fi
  
  # Extract repository name from URL
  local repo_name=$(basename -s .git "$repo_url")
  
  # Create container directory
  mkdir -p "$container_folder"
  cd "$container_folder" || return 1
  
  # Clone the repository
  git clone "$repo_url" 
  cd "$repo_name" || return 1
  
  # Create and checkout new branch
  git checkout -b "$branch_name"
  
  # Push the new branch to remote
  git push -u origin "$branch_name"
  
  echo "Created and cloned branch '$branch_name' in folder: $container_folder/$repo_name"
  echo "You are now in the new branch. After development, you can remove the entire folder:"
  echo "rm -rf $(pwd | sed 's/ /\\ /g' | sed "s|$repo_name$||")"
}

# Function to pull latest changes from remote
pull_latest() {
  # Check if we're in a git repository
  if ! git rev-parse --is-inside-work-tree > /dev/null 2>&1; then
    echo "Error: Not in a git repository"
    return 1
  fi
  
  local current_branch=$(git rev-parse --abbrev-ref HEAD)
  
  # Fetch all changes
  git fetch --all
  
  # Pull changes for current branch
  git pull origin "$current_branch"
  
  echo "Successfully pulled latest changes for branch: $current_branch"
}

# Function to switch branches
switch_branch() {
  local branch_name="$1"
  
  # Check if we're in a git repository
  if ! git rev-parse --is-inside-work-tree > /dev/null 2>&1; then
    echo "Error: Not in a git repository"
    return 1
  fi
  
  # If no branch name is provided, list available branches
  if [ -z "$branch_name" ]; then
    echo "Available branches:"
    git branch -a
    return 0
  fi
  
  # Check if branch exists locally
  if git show-ref --verify --quiet refs/heads/"$branch_name"; then
    git checkout "$branch_name"
  else
    # Check if branch exists remotely
    if git show-ref --verify --quiet refs/remotes/origin/"$branch_name"; then
      git checkout -b "$branch_name" origin/"$branch_name"
    else
      echo "Error: Branch '$branch_name' not found locally or remotely"
      return 1
    fi
  fi
  
  echo "Switched to branch: $branch_name"
}

# Function to show status with a cleaner output
show_status() {
  # Check if we're in a git repository
  if ! git rev-parse --is-inside-work-tree > /dev/null 2>&1; then
    echo "Error: Not in a git repository"
    return 1
  fi
  
  local branch_name=$(git rev-parse --abbrev-ref HEAD)
  local repo_name=$(basename -s .git $(git config --get remote.origin.url 2>/dev/null || echo "unknown-repo"))
  
  echo "Repository: $repo_name"
  echo "Current branch: $branch_name"
  echo "---"
  
  # Check for uncommitted changes
  if ! git diff --quiet; then
    echo "Uncommitted changes:"
    git diff --stat
    echo "---"
  fi
  
  # Check for staged changes
  if ! git diff --quiet --cached; then
    echo "Staged changes ready to commit:"
    git diff --stat --cached
    echo "---"
  fi
  
  # Check for untracked files
  if [ -n "$(git ls-files --others --exclude-standard)" ]; then
    echo "Untracked files:"
    git ls-files --others --exclude-standard
    echo "---"
  fi
  
  # Show recent commits
  echo "Recent commits:"
  git log --oneline -n 5
}

# Function to set up GitHub credentials (helpful for first-time users)
setup_git_credentials() {
  echo "Setting up Git credentials"
  
  # Check if global user name is set
  if [ -z "$(git config --global user.name)" ]; then
    echo "Enter your name for Git commits:"
    read -r git_name
    git config --global user.name "$git_name"
  else
    echo "Git user.name is already set to: $(git config --global user.name)"
  fi
  
  # Check if global email is set
  if [ -z "$(git config --global user.email)" ]; then
    echo "Enter your email for Git commits:"
    read -r git_email
    git config --global user.email "$git_email"
  else
    echo "Git user.email is already set to: $(git config --global user.email)"
  fi
  
  echo "Git credentials setup complete"
}