#!/bin/bash

# Check if CSV file is provided
if [ "$#" -lt 1 ]; then
  echo "Usage: $0 <path_to_csv> [<additional_description>]"
  exit 1
fi

CSV_FILE=$1
DEV_DESC=$2

# Check if the CSV file exists
if [ ! -f "$CSV_FILE" ]; then
  echo "Error: CSV file '$CSV_FILE' not found."
  exit 1
fi

# Extract data from the CSV file
#while IFS=, read -r BugID Description BranchName Developer Priority GITHUB_URL
#do
  # Debug statement to check variable values
  echo "Read values - BugID: $BugID, Description: $Description, BranchName: $BranchName, Developer: $Developer, Priority: $Priority, GITHUB_URL: $GITHUB_URL"
  
  # Skip the header row (assuming the first column has a header 'BugID')
  if [ "$BugID" != "BugID" ]; then
    # Check out to the branch or create it if it doesn't exist
    if ! git rev-parse --verify --quiet "$BranchName"; then
      git checkout -b "$BranchName"
      git push "${GITHUB_URL}" "$BranchName"
    else
      git checkout "$BranchName"
    fi
    
    # Generate the commit message
    COMMIT_MESSAGE="BugID:$BugID:$(date '+%Y-%m-%d %H:%M:%S'):Branch:$BranchName:Dev:$Developer:Priority:$Priority:Description:$Description"

    # Append developer's additional description if provided
    if [ -n "$DEV_DESC" ]; then
      COMMIT_MESSAGE="$COMMIT_MESSAGE:Dev Description:$DEV_DESC"
    fi

    # Perform Git operations
    git add .
    git commit -m "$COMMIT_MESSAGE"
    git push "${GITHUB_URL}" "$BranchName"

    echo "Committed and pushed changes with message: $COMMIT_MESSAGE"
  fi
#done < <(tail -n +2 "$CSV_FILE")
