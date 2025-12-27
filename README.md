Project Overview

This project provisions a production-like AWS infrastructure (development environment) using Terraform, focused on high availability, scalability, and cost optimization.

The architecture serves a static web application stored in S3, delivered through EC2 instances behind an Application Load Balancer, managed by an Auto Scaling Group using Spot instances.

All infrastructure is fully reproducible (terraform destroy → terraform apply) and validated end-to-end.

🧱 Architecture Components
🌐 Networking

Custom VPC

Public and private subnets

Modular networking design

Outputs exposed for reuse across modules

📦 Static Content (S3)

S3 bucket hosting a zipped static website (catalogo.zip)

Website files uploaded via Terraform

EC2 instances download content from S3 at boot time

⚖️ Application Load Balancer (ALB)

Public ALB listening on HTTP :80

Target Group with health checks

Routes traffic to:

A legacy EC2 instance (on-demand)

EC2 instances managed by the ASG

Fully tested via curl and browser access

🖥️ Compute (Legacy EC2)

Single EC2 instance created via Terraform

Acts as a baseline / on-prem-like node

Registered in the ALB Target Group

Uses Nginx to serve static content

🔁 Auto Scaling Group (ASG)

Dedicated Terraform module

Spot instances only (cost-optimized)

Launch Template–based

Min: 1 | Desired: 1 | Max: 2

Integrated with ALB Target Group

Instance replacement tested successfully (terminate → auto-recreate)

🔐 IAM & Security

IAM Role attached to EC2 / ASG instances

Least-privilege S3 access (GetObject, ListBucket)

No hardcoded AWS credentials

Security Groups fully managed via Terraform

Temporary SSH access enabled for debugging (to be restricted later)

📊 Observability

ALB access logs enabled and stored in S3

CloudWatch metrics available for ALB and EC2

Infrastructure behavior observable without manual instance access

⚙️ User Data & Bootstrapping

EC2 instances bootstrapped via user-data.sh

On launch:

Install Nginx and AWS CLI

Download website from S3

Unzip and deploy content to /var/www/html

Inject dynamic runtime data into HTML:

Hostname

Instance ID

Used to visually validate ALB load balancing and ASG replacement

✅ Validations Performed

✔ ALB listener and routing verified
✔ Target Group health checks passing
✔ ASG instance creation and replacement validated
✔ Web availability confirmed via ALB endpoint
✔ Infrastructure recreated after full terraform destroy
✔ No manual changes required in AWS Console

📂 Project Structure
.
├── envs/
│   ├── dev/
│   ├── staging/
│   └── prod/
├── modules/
│   ├── networking/
│   ├── alb/
│   ├── compute/
│   ├── asg/
│   ├── iam/
│   └── s3_static_site/
├── catalogo/
└── README.md

🧠 Key Takeaways

Infrastructure follows real-world enterprise patterns

Fully modular Terraform design

Cost-optimized using Spot instances

High availability via ALB + ASG

End-to-end validated, reproducible infrastructure