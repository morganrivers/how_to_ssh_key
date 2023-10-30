#!/bin/bash

# Title: Setup Git Repository with SSH keys
# Author: Morgan Rivers
# Date: June 2023
# Description: This script automates the process of setting up a Git repository with SSH keys. 
# It prompts the user for their GitHub username/organization, Git email, SSH key name, and 
# repository name. Then it generates a new SSH key, adds it to the SSH agent, and provides the
# public key to be added to GitHub as a deploy key. Afterward, it clones the repository, adds 
# any changes, commits them with a user-provided message, and finally, connects the local repository 
# to the remote one and pushes the commits. 
#
# Usage: Run this script in a Unix-like environment that has git and ssh installed. 


echo ""
echo "NOTE: This script automates several tasks related to setting up a new private repository on GitHub. Here's a breakdown of its functionality:"
echo "1. GENERATES an SSH key: A new SSH key is generated based on your provided Git email. If a key with the same name already exists, the script will ask if you wish to overwrite it."
echo "2. ADDS SSH Key to GitHub: You'll be prompted to manually add this SSH key to your GitHub repository as a deploy key. This allows secure push/pull without entering credentials every time."
echo "3. CLONES the Repository (Optional): If chosen, the script will attempt to clone the repository to your local machine. If a directory with the repository's name already exists, you'll be asked for further action."
echo "4. CREATES README.md (Optional): If the repository doesn't have a README.md, you'll get the option to create one with the repository name as its title."
echo "5. COMMITS & PUSHES: If you've made any changes, the script will prompt you for a commit message and will then push these changes to the repository."
echo "6. HANDLES 'origin' REMOTE: If the 'origin' remote already exists, it means the local repository already knows about a remote repository it can push to or pull from. In this case the script will ask whether you want to overwrite it."
echo ""
echo "Please ensure you have the necessary permissions and the correct repository name to avoid any errors."
echo ""


set -e  # Exit immediately if a pipeline returns a non-zero status

# Check for necessary programs
if ! command -v git &> /dev/null; then
    echo "Error: git is not installed."
    exit 1
fi

if ! command -v ssh &> /dev/null; then
    echo "Error: ssh is not installed."
    exit 1
fi

get_response() {
    local input="$1"
    input=$(echo "$input" | tr '[:upper:]' '[:lower:]')  # Convert input to lowercase

    if [[ "$input" == "y" ]] || [[ "$input" == "yes" ]]; then
        echo "y"
    else
        echo "n"
    fi
}

# User inputs
echo "Enter your GitHub username or organization:"
read git_username_or_org
echo "Enter your Git email:"
read git_email
echo "Enter a name for your SSH key file:"
read key_name
echo "Enter your repository name:"
read repo_name

# newline for readability
echo ""

# Check if ~/.ssh directory exists
if [[ ! -d ~/.ssh ]]; then
    # If not, create it
    mkdir ~/.ssh
    echo "Directory ~/.ssh created."
fi

# Go to .ssh directory
cd ~/.ssh


if [[ -e "$key_name" ]]; then
    echo "SSH key named $key_name already exists."
    echo "Do you want to overwrite it? [y/n]"
    read response
    response=$(get_response $response)
    if [[ $response != "y" ]]; then
        echo "Exiting without overwriting existing key."
        exit 1
    fi
fi

# Generate a new SSH key
ssh-keygen -t ed25519 -C "$git_email" -f $key_name -q -N ""

# Start the SSH agent and add the key
eval "$(ssh-agent -s)"
ssh-add ~/.ssh/$key_name

# newline for readability
echo ""

# Print the public key
echo "Your SSH public key is: (Copy the line below!)"
cat ~/.ssh/$key_name.pub

# newline for readability
echo ""

echo "Please add the SSH key to your GitHub under 'deploy keys' at this link:"
echo "https://github.com/$git_username_or_org/$repo_name/settings/keys"

echo "Don't forget to check 'Allow write access'!"
echo ""
echo "Once you have added the key, press any key to continue..."

# Wait for user to press a key
read -n 1 -s

# Change directory back to where the repo goes
cd -

# Ask user if they want to clone the repository
echo "Do you want to clone the repository? (This is not necessary if the directory already exists and you're just setting a new SSH key.) [y/n]"
read response
response=$(get_response $response)
if [[ $response == "y" ]]; then
    if [[ -d $repo_name ]]; then
        echo "ERROR: A directory with the name $repo_name already exists."
        exit 1
    fi
    git clone git@github.com:$git_username_or_org/$repo_name.git
    cd $repo_name
fi

# figure out if we're setting default to main or master
default_branch=$(git symbolic-ref refs/remotes/origin/HEAD | sed 's@^refs/remotes/origin/@@')


if [[ ! -e README.md ]]; then
    # Ask user if they want to add a readme
    echo "Do you want to add a README.md? [y/n]"
    read response
    response=$(get_response $response)
    if [[ $response == "y" ]]; then
        # create it and write $repo_name to it as the title
        echo "# $repo_name" > README.md
        git add .
    fi
fi

# Ask user if they want to commit and push
echo "Do you want to commit and push changes? [y/n]"
read response
response=$(get_response $response)
if [[ $response == "y" ]]; then
    echo "Enter commit message:"
    read commit_msg
    git commit -m "$commit_msg"

    # newline for readability
    echo ""

    # Check if remote 'origin' already exists
    if git remote | grep -q 'origin'; then
        echo "Warning: Remote 'origin' already exists."
        echo "Do you want to overwrite it? [y/n]"
        read response
        response=$(get_response $response)
        if [[ $response == "y" ]]; then
            # Set a new URL for the 'origin' remote
            git remote set-url origin git@github.com:$git_username_or_org/$repo_name.git
            git push -u origin $default_branch
        else
            echo "Push aborted."
            exit 1
        fi
    else
        # Connect local repository to the remote one and push commits
        git remote add origin git@github.com:$git_username_or_org/$repo_name.git
        git push -u origin $default_branch
    fi
fi
