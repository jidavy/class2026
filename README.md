# Two-Tier Automated Infrastructure Setup 🚀

This project demonstrates a fully automated CI/CD workflow to deploy a Two-Tier Web Application (Fruits & Vegetable Market) on AWS. It leverages Packer for Image creation, Terraform for Infrastructure as Code (IaC), and Jenkins for orchestration.

## 🏗 Architecture Overview
- **Tier 1 (Frontend):** Nginx Web Server running on Amazon Linux 2023.
- **Tier 2 (Backend):** Python 3 and Java 17 nodes.
- **Automation:** 100% manual-intervention-free deployment after the initial Jenkins setup.



## 🛠 Tech Stack
- **Cloud:** AWS (EC2, S3, IAM, Security Groups)
- **CI/CD:** Jenkins
- **Image Building:** HashiCorp Packer
- **Infrastructure:** HashiCorp Terraform
- **OS:** Amazon Linux 2023
- **Local Dev:** Windows 11 with VS Code & Git Bash

## 🚀 The Pipelines

### 1. Pipeline 1: Image Creation (Packer)
- Builds 2 custom Amazon Machine Images (AMIs).
- **Frontend AMI:** Pre-installed with Nginx and Git.
- **Backend AMI:** Pre-installed with Java 17 (Corretto) and Python 3.
- Uses **Data Sources** to dynamically fetch the latest Amazon Linux 2023 base image.

### 2. Pipeline 2: Infrastructure Provisioning (Terraform)
- Deploys 3 EC2 instances across the specific VPC and Subnets.
- **State Management:** Terraform state is stored securely in an **S3 Bucket** to ensure team collaboration and recovery.
- **Dynamic Linking:** Uses Terraform Data Sources to find the latest AMIs produced by the Packer pipeline automatically.
- Configures Security Groups for Port 80 (Web), 8080 (Python), and 9090 (Java).

### 3. Pipeline 3: Automated Deployment
- Pulls application code from the [Fruit & Vegetable Market Repo](https://github.com/techbleat/fruits-veg_market).
- Uses **AWS CLI** to dynamically discover instance IPs via Tags (`web-node-frontend`, etc.).
- Deploys code via SSH and starts services in the background using `nohup`.

## 🔧 How to Run
1. **Prerequisites:** Create an S3 bucket for the Terraform state and store AWS credentials in Jenkins.
2. **Step 1:** Run the `Packer-Pipeline`.
3. **Step 2:** Run the `Terraform-Pipeline` with the `apply` parameter.
4. **Step 3:** Run the `Deploy-Pipeline`.

## 📸 Proof of Deployment
*(Note: Replace these placeholders with your actual screenshots)*
- **Infrastructure:** [Link to screenshot of EC2 Console]
- **Live App:** [Link to screenshot of the Fruit Market running in browser]
