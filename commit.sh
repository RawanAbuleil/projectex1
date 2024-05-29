#!/bin/bash

# Check if the correct number of arguments is provided
if [ "$#" -lt 1 ]; then
    echo "Usage: $0 <Excel file path> [additional description]"
    exit 1
fi

# Assign arguments to variables
csv_file=$1
additional_description=$2

# Read the CSV file and extract the necessary details
while IFS=, read -r bug_id description branch_name developer priority github_url
do
    # Skip the header row
    if [ "$bug_id" = "BugID" ]; then
        continue
    fi

    # Get the current date and time
    current_datetime=$(date '+%Y-%m-%d %H:%M:%S')

    # Format the commit message
    if [ -n "$additional_description" ]; then
        commit_message="BugID:$bug_id:$current_datetime:$branch_name:$developer:$priority:$description:$additional_description"
    else
        commit_message="BugID:$bug_id:$current_datetime:$branch_name:$developer:$priority:$description"
    fi

    # Perform Git operations
    git checkout "$branch_name"
    git add .
    git commit -m "$commit_message"
    git push origin "$branch_name"

done < "$csv_file"
