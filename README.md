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

## Step-by-Step Guide

1. **Create the repository on GitHub.**

2. **Generate a new SSH key.**  
   Open a terminal, navigate to your SSH directory by typing `cd ~/.ssh`, and run:  
   <pre>
   $ ssh-keygen -t ed25519 -C "<b>your_email@example.com</b>"
   </pre>
   At the prompt, enter **key_name_for_file** and press enter to skip setting a passphrase.

3. **Start the SSH agent and add your new key.**
   <pre>
   $ eval "$(ssh-agent -s)"
   $ ssh-add ~/.ssh/<b>key_name_for_file</b>
   </pre>

4. **Copy your SSH key to your clipboard.**  
   <pre>
   $ cat ~/.ssh/<b>key_name_for_file</b>.pub
   </pre>
   You'll need to copy the result from the terminal. It should be one line, start with ssh-ed25519, and end with your email.
   
5. **Add your SSH key to GitHub.**  
   Paste this into the git website and add the key. It's under "deploy keys". You can also navigate there by going to:
   <pre>https://github.com/<b>git_username_or_org</b>/<b>repo_name</b>/settings/keys</pre>

6. **Navigate to your local repository directory.**  
   If the directory does not exist yet on your local machine, clone it with ssh and add any relevant changes:

   <pre>
   $ git clone git@github.com:<b>git_username_or_org</b>/<b>repo_name</b>
   $ git add .
   $ git commit -m "your message here"
   </pre>

7. **Connect your local repository to the remote repository and push your commits.**
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


 
