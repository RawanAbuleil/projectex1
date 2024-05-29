#!/bin/bash
#checking the arguments
if [ "$#" -lt 1 ]; then
    echo "Usage: $0 <CSV file path> [additional description]"
    exit 1
fi

csv_file=$1
additional_description=$2

tail -n +2 "$csv_file" | while IFS=, read -r bug_id description branch_name developer priority github_url
do
    current_datetime=$(date '+%Y-%m-%d %H:%M:%S')

    #  the commit message formatt
    if [ -n "$additional_description" ]; then
        commit_message="BugID:$bug_id:$current_datetime:$branch_name:$developer:$priority:$description:$additional_description"
    else
        commit_message="BugID:$bug_id:$current_datetime:$branch_name:$developer:$priority:$description"
    fi

    # checks if da branch exists
    if git show-ref --quiet refs/heads/"$branch_name"; then
        git checkout "$branch_name"
    else
        # create da branch if  doesn't exist
        git checkout -b "$branch_name"
    fi

    git add .
    
    git reset HEAD "$csv_file"
    
    git commit -m "$commit_message"
    

done
