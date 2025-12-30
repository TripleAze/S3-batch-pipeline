# #!/bin/bash
# # -------------------------------
# # Bootstrap Jenkins on EC2 (Robust Version)
# # -------------------------------
# LOG_FILE="/tmp/jenkins_bootstrap.log"
# exec > >(tee -a "$LOG_FILE") 2>&1

# echo "Starting Jenkins bootstrap at $(date)"

# # Update system
# sudo apt-get update -y
# sudo apt-get upgrade -y

# # Install necessary dependencies
# sudo apt-get install -y git python3-pip ansible unzip curl

# # Create directory for Ansible
# INSTALL_DIR="/opt/ansible"
# sudo mkdir -p "$INSTALL_DIR/roles"
# cd "$INSTALL_DIR" || exit

# echo "Installing Jenkins role..."
# sudo ansible-galaxy install geerlingguy.jenkins --roles-path roles/

# echo "Creating playbook..."
# sudo cat <<EOF > ansible_playbook.yml
# ---
# - hosts: localhost
#   become: yes
#   roles:
#     - geerlingguy.jenkins
# EOF

# echo "Running Ansible playbook..."
# sudo ansible-playbook -i "localhost," -c local ansible_playbook.yml

# echo "Finalizing service..."
# sudo systemctl enable jenkins
# sudo systemctl start jenkins

# echo "Jenkins bootstrap complete at $(date)!"
# sudo touch /home/ubuntu/bootstrap_success
# sudo chown ubuntu:ubuntu /home/ubuntu/bootstrap_success
