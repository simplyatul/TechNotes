#!/bin/bash

# Initialize variables
DIR_NAME=""
DRY_RUN=false

# Function to display usage
usage() {
  echo "Usage: $0 --dir <dir_name> [--dry-run]"
  exit 1
}

# Function to execute or log commands based on dry-run mode
execute() {
  if [[ "$DRY_RUN" = true ]]; then
    echo "DRY RUN: $1"
  else
    eval "$1"
  fi
}

# Parse command-line arguments
while [[ $# -gt 0 ]]; do
  case "$1" in
    --dir)
      DIR_NAME="$2"
      shift 2
      ;;
    --dry-run)
      DRY_RUN=true
      shift
      ;;
    *)
      echo "Error: Unknown option '$1'"
      usage
      ;;
  esac
done

# Check if directory name is provided
if [ -z "$DIR_NAME" ]; then
  echo "Error: Directory name not provided."
  usage
fi

# Check if the directory already exists
if [ -d "$DIR_NAME" ]; then
  echo "Error: Directory '$DIR_NAME' already exists."
  exit 1
fi

# Create the directory
execute "mkdir -p '$DIR_NAME'"

# Define the curl commands
execute "curl -s localhost:19000/config_dump > '$DIR_NAME/config_dump.log'"
execute "curl -s localhost:19000/clusters > '$DIR_NAME/clusters.log'"
execute "curl -s localhost:19000/clusters?format=json > '$DIR_NAME/clusters.json'"
execute "curl -s localhost:19000/listeners?format=json > '$DIR_NAME/listeners.json'"
execute "curl -s localhost:19000/listeners > '$DIR_NAME/listeners.log'"
execute "curl -s localhost:19000/server_info > '$DIR_NAME/server_info.log'"
execute "curl -s localhost:19000/stats > '$DIR_NAME/stats.log'"
execute "curl -s localhost:19000/stats/prometheus > '$DIR_NAME/stats-prometheus.log'"

# Final message
if [[ "$DRY_RUN" = true ]]; then
  echo "Dry-run completed. No changes were made."
else
  echo "Data successfully saved in directory: $DIR_NAME"
fi
