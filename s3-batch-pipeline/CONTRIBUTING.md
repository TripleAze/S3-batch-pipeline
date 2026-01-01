# Contributing to S3 Batch Operations Pipeline

Thank you for your interest in contributing! This document provides guidelines for contributing to this project.

---

## 🤝 How to Contribute

### **Reporting Issues**

Before creating an issue, please:
1. Check existing issues to avoid duplicates
2. Use the issue template (if available)
3. Provide detailed reproduction steps
4. Include relevant logs and error messages

**Good Issue Example**:
```
Title: Terraform fails with InvalidPermission.Duplicate

Environment:
- Terraform version: 1.5.0
- AWS region: eu-west-2
- OS: Ubuntu 22.04

Steps to reproduce:
1. Run `terraform apply -var-file=envs/prod.tfvars`
2. Error occurs during security group creation

Error message:
InvalidPermission.Duplicate: the specified rule "peer: 0.0.0.0/0, 
TCP, from port: 0, to port: 65535, ALLOW" already exists

Expected behavior:
Security group should be created without errors

Actual behavior:
Terraform fails with duplicate rule error
```

---

## 🔧 Development Setup

### **Prerequisites**
- Terraform >= 1.0
- Ansible >= 2.9
- AWS CLI v2
- Python 3.8+
- Git

### **Local Environment Setup**

1. **Clone the repository**:
```bash
git clone https://github.com/TripleAze/S3-batch-pipeline.git
cd S3-batch-pipeline
```

2. **Install Ansible dependencies**:
```bash
cd ansible
ansible-galaxy install -r roles/requirements.yml
```

3. **Configure AWS credentials**:
```bash
aws configure
# Enter your AWS Access Key ID, Secret Access Key, and region
```

4. **Create your own tfvars file**:
```bash
cp envs/prod.tfvars envs/dev.tfvars
# Edit dev.tfvars with your settings
```

5. **Initialize Terraform**:
```bash
terraform init
```

---

## 📝 Coding Standards

### **Terraform**

**File Organization**:
```
modules/<module-name>/
├── main.tf          # Primary resources
├── variables.tf     # Input variables
├── outputs.tf       # Output values
└── README.md        # Module documentation
```

**Naming Conventions**:
- Resources: `<resource_type>_<descriptive_name>`
- Variables: `snake_case`
- Outputs: `snake_case`

**Example**:
```hcl
# Good
resource "aws_instance" "jenkins_server" {
  ami           = var.ami_id
  instance_type = var.instance_type
}

# Bad
resource "aws_instance" "JenkinsServer" {
  ami           = var.AmiId
  instance_type = var.InstanceType
}
```

**Required Elements**:
- All resources must have `tags` with `Name`, `Environment`, and `Project`
- All variables must have `description`
- Sensitive outputs must be marked `sensitive = true`

---

### **Ansible**

**Playbook Structure**:
```yaml
---
- name: Descriptive playbook name
  hosts: target_group
  become: yes  # Only when needed
  
  pre_tasks:
    - name: Task description (present tense)
      module_name:
        parameter: value
  
  roles:
    - role_name
  
  tasks:
    - name: Another task description
      module_name:
        parameter: value
```

**Best Practices**:
- Use `name` for every task
- Prefer modules over shell commands
- Use `changed_when` and `failed_when` for shell tasks
- Group related tasks with `block`
- Use handlers for service restarts

**Example**:
```yaml
# Good
- name: Install Jenkins
  apt:
    name: jenkins
    state: present
    update_cache: yes
  notify: restart jenkins

# Bad
- shell: apt-get install -y jenkins
```

---

### **Jenkins Pipeline**

**Jenkinsfile Standards**:
```groovy
pipeline {
    agent any
    
    environment {
        // Use UPPERCASE for environment variables
        AWS_REGION = 'eu-west-2'
    }
    
    parameters {
        // Provide sensible defaults
        string(
            name: 'PARAM_NAME',
            defaultValue: 'default_value',
            description: 'Clear description'
        )
    }
    
    stages {
        stage('Descriptive Stage Name') {
            steps {
                script {
                    // Use try-catch for error handling
                    try {
                        sh 'command'
                    } catch (Exception e) {
                        error "Failed: ${e.message}"
                    }
                }
            }
        }
    }
    
    post {
        always {
            // Always cleanup
            cleanWs()
        }
    }
}
```

---

## 🧪 Testing Guidelines

### **Terraform Testing**

**Before Submitting**:
1. Run `terraform fmt` to format code
2. Run `terraform validate` to check syntax
3. Run `terraform plan` to preview changes
4. Test in a dev environment first

**Example Test Workflow**:
```bash
# Format code
terraform fmt -recursive

# Validate syntax
terraform validate

# Plan with dev vars
terraform plan -var-file=envs/dev.tfvars

# Apply to dev
terraform apply -var-file=envs/dev.tfvars

# Verify functionality
# ... test the deployed resources ...

# Destroy dev resources
terraform destroy -var-file=envs/dev.tfvars
```

---

### **Ansible Testing**

**Syntax Check**:
```bash
ansible-playbook --syntax-check playbooks/jenkins.yml
```

**Dry Run**:
```bash
ansible-playbook -i inventories/dev/hosts.ini playbooks/jenkins.yml --check
```

**Idempotency Test**:
```bash
# Run twice, second run should show no changes
ansible-playbook -i inventories/dev/hosts.ini playbooks/jenkins.yml
ansible-playbook -i inventories/dev/hosts.ini playbooks/jenkins.yml
```

---

## 🔀 Pull Request Process

### **1. Create a Feature Branch**
```bash
git checkout -b feature/descriptive-name
# or
git checkout -b fix/issue-number-description
```

### **2. Make Your Changes**
- Follow coding standards above
- Add tests if applicable
- Update documentation

### **3. Commit Your Changes**

**Commit Message Format**:
```
<type>(<scope>): <subject>

<body>

<footer>
```

**Types**:
- `feat`: New feature
- `fix`: Bug fix
- `docs`: Documentation changes
- `style`: Code style changes (formatting)
- `refactor`: Code refactoring
- `test`: Adding tests
- `chore`: Maintenance tasks

**Example**:
```
feat(terraform): add CloudWatch monitoring for S3 Batch jobs

- Added CloudWatch alarms for job failures
- Created SNS topic for notifications
- Updated IAM policies to allow CloudWatch access

Closes #42
```

### **4. Push and Create PR**
```bash
git push origin feature/descriptive-name
```

Then create a Pull Request on GitHub with:
- Clear title describing the change
- Reference to related issues
- Description of what changed and why
- Screenshots (if UI changes)
- Test results

---

## 📋 PR Checklist

Before submitting, ensure:

- [ ] Code follows project style guidelines
- [ ] All tests pass
- [ ] Documentation is updated
- [ ] Commit messages are clear
- [ ] No sensitive data in commits
- [ ] Branch is up to date with main
- [ ] PR description is complete

---

## 🔍 Code Review Process

### **What Reviewers Look For**

1. **Functionality**: Does it work as intended?
2. **Security**: Are there any security implications?
3. **Performance**: Will it scale?
4. **Maintainability**: Is it easy to understand?
5. **Documentation**: Is it well-documented?

### **Responding to Feedback**

- Be open to suggestions
- Ask questions if unclear
- Make requested changes promptly
- Mark conversations as resolved when addressed

---

## 🏷️ Versioning

This project follows [Semantic Versioning](https://semver.org/):

- **MAJOR**: Breaking changes
- **MINOR**: New features (backward compatible)
- **PATCH**: Bug fixes (backward compatible)

**Example**: `1.2.3`
- `1` = Major version
- `2` = Minor version
- `3` = Patch version

---

## 📜 License

By contributing, you agree that your contributions will be licensed under the MIT License.

---

## 🎯 Priority Areas

We're especially interested in contributions for:

1. **High Availability**: Jenkins master-agent setup
2. **Monitoring**: CloudWatch dashboards and alarms
3. **Testing**: Automated integration tests
4. **Documentation**: More examples and tutorials
5. **Security**: Additional security hardening

---

## 💬 Getting Help

- **Questions**: Open a GitHub Discussion
- **Bugs**: Create an issue with the bug template
- **Features**: Create an issue with the feature request template
- **Security**: Email security concerns privately

---

## 🙏 Recognition

Contributors will be:
- Listed in the project README
- Mentioned in release notes
- Credited in documentation

---

**Thank you for contributing to make this project better!** 🚀
