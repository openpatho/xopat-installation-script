#!/bin/bash

echo "Welcome to the helper script to get xopat installed."
echo "You'll be asked a series of questions by the commands we run."
echo "This script is for internal use only, and so if you put in a username that's not authorised to access the right repos (for example) then it'll just fail."

echo ""
echo "Let's first install the dependencies"
for pkg in docker.io docker-doc docker-compose docker-compose-v2 podman-docker containerd runc; do sudo apt-get remove $pkg; done

# Add Docker's official GPG key:
sudo apt-get update
sudo apt-get install -y ca-certificates curl 
sudo install -m 0755 -d /etc/apt/keyrings
sudo curl -fsSL https://download.docker.com/linux/ubuntu/gpg -o /etc/apt/keyrings/docker.asc
sudo chmod a+r /etc/apt/keyrings/docker.asc

# Add the repository to Apt sources:
echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/ubuntu \
  $(. /etc/os-release && echo "$VERSION_CODENAME") stable" | \
  sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
sudo apt-get update

sudo apt-get install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin git-all github gh gedit unzip qemu-guest-agent

echo "Now we'll login to github, and download the main repo"
gh auth login
if [ $? -ne 0 ]; then
    echo "GitHub authentication failed. Exiting."
    exit 1
fi

git clone --recurse-submodules https://github.com/invivasolutions/xopat-with-server.git

# Prompt the user with a yes/no question
while true; do
    read -p "Are you on an EC2 machine with a role defined such that you can access all the secrets needed for this server? (yes/no): " yn
    case $yn in
        [Yy]* ) 
            echo "Great! Proceeding with the installation..."; 
            break;;
        [Nn]* ) 
            echo "OK let's get AWS CLI installed so you can get to them that way instead";
            curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
            unzip awscliv2.zip
            sudo ./aws/install
            aws configure


            break;;
        * ) 
            echo "Please answer yes or no.";;
    esac
done

echo "Lastly, please change any of the Tile Server settings that you need to"
gedit xopat-with-server/WSI-Service/.env &
