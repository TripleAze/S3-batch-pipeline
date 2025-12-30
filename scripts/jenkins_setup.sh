#!/bin/bash
set -e

# -------------------------------
# Bootstrap Jenkins on EC2
# Production-ready
# -------------------------------

# Update system
sudo apt-get update -y
sudo apt-get upgrade -y

# Install necessary dependencies
sudo apt-get install -y git python3-pip ansible unzip curl

# Verify Ansible installation
ansible --version

# Create directory for Ansible roles
mkdir -p ~/ansible/roles
cd ~/ansible || exit

# Install geerlingguy.jenkins role from Ansible Galaxy
ansible-galaxy install geerlingguy.jenkins --roles-path roles/

# Create a minimal playbook for Jenkins
cat <<EOPLAYBOOK > jenkins_playbook.yml
- hosts: localhost
  become: yes
  roles:
    - geerlingguy.jenkins
EOPLAYBOOK

# Run the playbook
ansible-playbook jenkins_playbook.yml

# Verify Jenkins service
sudo systemctl enable jenkins
sudo systemctl start jenkins
sudo systemctl status jenkins

# Print final access info
echo "Jenkins bootstrap complete!"
echo "Access Jenkins at http://$(curl -s http://169.254.169.254/latest/meta-data/public-ipv4):8080"
