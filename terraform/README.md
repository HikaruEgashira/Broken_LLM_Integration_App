# AWS Deployment Guide

## Prerequisites

1. AWS CLI installed and configured with appropriate credentials
2. Terraform installed (v1.2.0 or later)
3. Docker installed
4. OpenAI API Key

## Deployment Steps

### 1. Configure AWS Credentials

```bash
aws configure
```

### 2. Create terraform.tfvars

Create a `terraform.tfvars` file with the following content:

```hcl
rds_password = "your-secure-password"  # Change this to a secure password
```

### 3. Initialize and Apply Terraform

```bash
# Initialize Terraform
terraform init

# Plan the changes
terraform plan

# Apply the changes
terraform apply
```

### 4. Push Docker Images to ECR

```bash
# Get ECR login password
aws ecr get-login-password --region ap-northeast-1 | docker login --username AWS --password-stdin $(aws sts get-caller-identity --query Account.output --output text).dkr.ecr.ap-northeast-1.amazonaws.com

# Build and push frontend image
cd ../chatapp/frontend
docker build -t chatbot-frontend .
docker tag chatbot-frontend:latest $(terraform output -raw frontend_repository_url):latest
docker push $(terraform output -raw frontend_repository_url):latest

# Build and push backend image
cd ../backend
docker build -t chatbot-backend .
docker tag chatbot-backend:latest $(terraform output -raw backend_repository_url):latest
docker push $(terraform output -raw backend_repository_url):latest
```

### 5. Update Environment Variables

After the infrastructure is deployed, the following environment variables will be available:

1. Frontend:
   - REACT_APP_API_URL: The ALB DNS name (e.g., http://chatbot-alb-xxx.ap-northeast-1.elb.amazonaws.com)

2. Backend:
   - DATABASE_URL: RDS endpoint (automatically configured)
   - OPENAI_API_KEY: Your OpenAI API key

You can get the ALB DNS name using:
```bash
terraform output alb_dns_name
```

### 6. Verify Deployment

1. Access the frontend application:
   - Open the ALB DNS name in your browser
   - The frontend should be accessible on port 80

2. Test the backend API:
   - The backend API will be available at `/api/*` endpoints
   - Health check endpoint: `/api/health`

## Infrastructure Overview

### Network
- VPC with public and private subnets
- Internet Gateway for public access
- NAT Gateway for private subnet outbound traffic

### Compute
- ECS Fargate for running containers
- Frontend and Backend services
- Auto scaling based on CPU/Memory usage

### Database
- RDS MySQL 8.0 in private subnet
- Automated backups enabled
- Multi-AZ deployment optional

### Load Balancing
- Application Load Balancer
- Path-based routing for frontend and backend
- Health checks enabled

### Security
- Security groups for all components
- Private subnets for application and database
- Encryption at rest for RDS
- Container image scanning enabled

## Cleanup

To destroy all created resources:

```bash
terraform destroy
```

Note: This will delete all resources including the database. Make sure to backup any important data before running this command.

## Local Development

For local development, use docker-compose:

```bash
cd ../chatapp
docker-compose up --build
```

Access the application at:
- Frontend: http://localhost
- Backend API: http://localhost/api
- PHPMyAdmin: http://localhost:8080
