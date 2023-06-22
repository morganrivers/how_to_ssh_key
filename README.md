# Adding SSH Keys on GitHub

This tutorial explains how to add SSH keys on GitHub and the command line with linux and bash, usually for pushing / pulling from a private repo. This is also particularly useful if you've encountered this error:

> remote: Support for password authentication was removed on August 13, 2021.  
> Please see [this link](https://docs.github.com/en/get-started/getting-started-with-git/about-remote-repositories#cloning-with-https-urls) for information on currently recommended modes of authentication.

## Prerequisites
Before we begin, you will need the following:

1. Your GitHub organization or username: **git_username_or_org** (replace with your username or organization name)
2. Your Git email: **your_email@example.com** (replace with your email)
3. A short name for your SSH key file (to identify it later): **key_name_for_file** (replace with your preferred name relating to the repository)
4. Your repository name: **repo_name** (replace with your repository name)

## Script Walkthrough (also see below if you prefer the manual step-by-step guide, you'll learn more that way)

The `setup_git_repo.sh` script can be run in a Unix-like environment that has git and ssh installed. It assumes that the main branch of your git repository is called "main". If your default branch has a different name (e.g., "master"), please replace "main" with your branch's name in the last git push command.

Save this script in a file with a .sh extension, for example, `setup_git_repo.sh. Remember to give the file executable permissions before running it with the following command: chmod +x setup_git_repo.sh.

<b>Make sure you're in the directory you want the git repo folder to be created before running the script</b> 

To run the `setup_git_repo.sh` script, you can copy the following commands into your terminal:

```
# Note: make sure you're in the directory where the repo folder is created will be put before running lines below!

# 1. Download the script
curl -O https://raw.githubusercontent.com/morganrivers/how_to_ssh_key/main/setup_git_repo.sh

# 2. Make script executable
chmod +x setup_git_repo.sh

# 3. Run the script to walk you through the step-by-step guide below
./setup_git_repo.sh.
```

## Step-by-Step Guide

1. **Create the repository on GitHub.**

2. **Generate a new SSH key.**  
   Open a terminal, navigate to your SSH directory by typing
   ```
   $ cd ~/.ssh
   ```
    and then run:  
   <pre>
   $ ssh-keygen -t ed25519 -C "<b>your_email@example.com</b>"
   </pre>
   At the prompt, enter **key_name_for_file** and press enter to skip setting a passphrase.

4. **Start the SSH agent and add your new key.**
   <pre>
   $ eval "$(ssh-agent -s)"
   $ ssh-add ~/.ssh/<b>key_name_for_file</b>
   </pre>

5. **Copy your SSH key to your clipboard.**  
   <pre>
   $ cat ~/.ssh/<b>key_name_for_file</b>.pub
   </pre>
   You'll need to copy the result from the terminal. It should be one line, start with ssh-ed25519, and end with your email.
   
6. **Add your SSH key to GitHub.**  
   Paste this into the git website and add the key. It's under "deploy keys". You can also navigate there by going to:
   <pre>https://github.com/<b>git_username_or_org</b>/<b>repo_name</b>/settings/keys</pre>

   Title doesn't really matter.
   Don't forget to select "Allow write access"!

7. **Navigate to your local repository directory.**  
   If the directory does not exist yet on your local machine, clone it with ssh and add any relevant changes:

   <pre>
   $ cd ~ # or whatever path you want the git repository to sit in
   $ git clone git@github.com:<b>git_username_or_org</b>/<b>repo_name</b>
   $ git add .
   $ git commit -m "your message here"
   </pre>

8. **Connect your local repository to the remote repository and push your commits.**
   <pre>
   $ git remote add origin git@github.com:<b>git_username_or_org</b>/<b>repo_name</b>.git
   $ git push -u origin main
   </pre>


## Pushing / pulling to the repository in the future:
In any future terminal sessions you want to use, you'll need to run the following commands before a git push or git pull:

<pre>
$ eval `ssh-agent -s`
$ ssh-add ~/.ssh/<b>key_name_for_file</b>
</pre>
I suggest adding such a set of commands as a function in your ~/.bash_rc file as follows, for easy configuration. You can also add any virtual environment activations for the relevant codebase at the same time in the bashrc function. For example in ~/.bashrc:
<pre>
function your_repo_activate(){
    eval `ssh-agent -s`
    ssh-add ~/.ssh/<b>key_name_for_file</b>
    # if you've set up a conda environment with your repository name followed by "_env", you could have something like the line below:
    # conda activate <b>your_repo</b>_env
}
</pre>


 
