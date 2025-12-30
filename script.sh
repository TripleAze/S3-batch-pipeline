#!/bin/bash

# Project root folder
PROJECT_NAME="s3-batch-pipeline"

# Create root folder
mkdir -p $PROJECT_NAME
cd $PROJECT_NAME || exit

# Root-level files
touch README.md main.tf variables.tf outputs.tf provider.tf terraform.tfvars

# Modules
mkdir -p modules/iam modules/ec2 modules/s3 modules/pipeline

# IAM module files
touch modules/iam/main.tf modules/iam/variables.tf modules/iam/outputs.tf

# EC2 module files
touch modules/ec2/main.tf modules/ec2/variables.tf modules/ec2/outputs.tf

# S3 module files
touch modules/s3/main.tf modules/s3/variables.tf modules/s3/outputs.tf

# Pipeline module files
touch modules/pipeline/main.tf modules/pipeline/variables.tf modules/pipeline/outputs.tf

# Environment variables folder
mkdir -p envs
touch envs/prod.tfvars envs/dev.tfvars

# Scripts folder
mkdir -p scripts
touch scripts/jenkins_setup.sh scripts/ansible_playbook.yml

# Make jenkins_setup.sh executable
chmod +x scripts/jenkins_setup.sh

echo "Production Terraform project structure created successfully!"
