#!/bin/bash
# Checking the arguments
if [ "$#" -lt 1 ]; then
    echo "Usage: $0 <CSV file path> [additional description]"
    exit 1
fi

csv_file=$1
additional_description=$2

tail -n +2 "$csv_file" | while IFS=, read -r bug_id description branch_name developer priority github_url
do
    current_datetime=$(date '+%Y-%m-%d %H:%M:%S')

    # Format the commit message
    if [ -n "$additional_description" ]; then
        commit_message="BugID:$bug_id:$current_datetime:$branch_name:$developer:$priority:$description:$additional_description"
    else
        commit_message="BugID:$bug_id:$current_datetime:$branch_name:$developer:$priority:$description"
    fi

    # Check if the branch exists
    if git show-ref --quiet refs/heads/"$branch_name"; then
        git checkout "$branch_name"
    else
        # Create the branch if it doesn't exist
        git checkout -b "$branch_name"
    fi

    # Perform Git operations
    git add .
    
    # Ensure that the file containing secrets is not added to the commit
    git reset HEAD "$csv_file"
    
    git commit -m "$commit_message"

    # Push the commit and check for errors
    if ! git push origin "$branch_name"; then
        echo "Error pushing to branch $branch_name. Please check for repository rules or other issues."
        exit 1
    fi

done
