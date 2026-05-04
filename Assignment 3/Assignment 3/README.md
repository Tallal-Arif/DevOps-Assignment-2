# DevOps Assignment 03 - AWS Infrastructure Provisioning with Terraform

## 🚀 Project Overview
This project demonstrates the provisioning of a complete, production-grade AWS infrastructure using **Terraform**. All resources were created using Infrastructure as Code (IaC) principles, ensuring consistency, scalability, and repeatability.

### 📊 Infrastructure at a Glance
- **41 Total Resources** managed by Terraform.
- **6 Key Tasks** fully implemented.
- **Region**: `us-east-1` (N. Virginia).
- **Architecture**: Multi-tier architecture with public/private separation.

---

## 🛠️ Tasks & Implementation Details

### Task 1: Networking & Connectivity
- **VPB/Subnets**: Custom VPC with 2 Public Subnets and 2 Private Subnets.
- **Gateway**: Internet Gateway for public access and NAT Gateway for private subnet outbound traffic.
- **Routing**: Segregated route tables for public and private traffic flows.
- **Technique**: Used `depends_on` to ensure NAT Gateway waits for IGW readiness.

### Task 2: Compute & Security
- **Security Groups**: Least-privilege rules. DB server only allows traffic from the Web server.
- **EC2 Instances**: Automated Nginx deployment via `user_data`.
- **Validation**: Strict Terraform variable validation to restrict `instance_type` to `t3` family.
- **SSH Pattern**: Implemented a Bastion host pattern for secure access to the internal network.

### Task 3: Remote State Management
- **Persistence**: Terraform state stored in **S3** with versioning and AES-256 encryption.
- **Locking**: **DynamoDB** table used for state locking to prevent concurrent modification.
- **IAM**: Proper IAM roles for EC2 S3 access.

### Task 4: Auto Scaling & Monitoring
- **ASG**: Auto Scaling Group using Launch Templates.
- **Policies**: Dynamic scaling policies (Step Scaling) based on CPU utilization.
- **Alarms**: CloudWatch Alarms (`dev-high-cpu` and `dev-low-cpu`) to trigger scaling events.
- **Verification**: Tested using `stress-ng` to verify automatic scale-out and scale-in.

### Task 5: High Availability & Load Balancing
- **ALB**: Application Load Balancer distributing traffic across targets.
- **Target Groups**: Configured with active health checks.
- **Restriction**: EC2 instances only allow HTTP traffic from the ALB's security group.

### Task 6: Custom Professional Images (Packer)
- **Packer**: Custom AMI built using HCL template with pre-installed Nginx, curl, and stress-ng.
- **Modularity**: Project structured into 4 reusable modules (`vpc`, `security`, `compute`, `alb`).

---

## 💻 Technical Documentation

### Project Structure
```text
.
├── modules/
│   ├── vpc/       # Network resources
│   ├── security/  # SG definitions
│   ├── compute/   # EC2, ASG, LT
│   └── alb/       # Load Balancer
├── packer/
│   └── build.pkr.hcl  # AMI Template
├── backend.tf      # S3 Remote State
├── main.tf         # Root module
└── terraform.tfvars # Configuration variables
```

### Key Commands
```powershell
# Initialize and migrate state
terraform init -migrate-state

# Plan and Apply
terraform plan
terraform apply

# Build Custom Image
packer init packer/build.pkr.hcl
packer build packer/build.pkr.hcl

# Verification - Stress Test
ssh -i dev-key.pem ubuntu@<Public_IP>
sudo apt-get install -y stress-ng
stress-ng --cpu 4 --timeout 300s
```

---

## 🏆 Conclusion
This project successfully implements all 6 tasks following AWS and Terraform best practices, providing a secure, scalable, and fully automated cloud environment.
