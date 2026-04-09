## 📌 Important Context

This is a **production-style EKS platform** I built end-to-end. It was fully deployed and running on AWS with:
- **Karpenter** for dynamic node provisioning
- **KEDA** for event-driven autoscaling  
- **Prometheus + Grafana** for observability
- **Argo CD** for GitOps deployments
- **External Secrets** for secure credential management

The live deployment has been taken down to control AWS costs, but all infrastructure and deployment code is here.

**CI/CD Pipelines** are in the original GitLab repository (pipelines in `.gitlab-ci.yml`).

To see what was deployed: Check `infra-repo/` for Terraform (Karpenter, EKS, RDS) and `platform-repo/` for Kubernetes/Helm manifests.

# ✅ Todo App Platform (AWS EKS + GitOps + RDS PostgreSQL)

A production-style **Todo Web Application** deployed on **AWS EKS** using **Terraform (IaC)** + **Argo CD GitOps**, backed by **Amazon RDS PostgreSQL**, with **observability-ready metrics** and secure secret management.

> This repo is organized as a 3-part platform:
> - **infra-repo** → Terraform provisions AWS infrastructure (VPC, EKS, RDS, IAM, etc.)
> - **platform-repo** → GitOps deployment (Argo CD Applications + Helm charts)
> - **app-repo1** → Application source code + Docker build

---

## 🌐 Live Application Access

### ✅ Live URL 
**Live App URL:** `http://<ALB_DNS_NAME>/`



## 🧩 Architecture Overview
High-level Flow

Users access the app through an AWS Application Load Balancer (ALB) created via the AWS Load Balancer Controller on EKS.

The application runs as a containerized Streamlit service and connects privately to Amazon RDS PostgreSQL.

Secrets are injected securely using External Secrets Operator + AWS Secrets Manager, and Kubernetes access is secured via IRSA (OIDC).

Diagram (Mermaid)
🔒 Security Highlights

RDS in private subnets (no public IP)

IRSA/OIDC for Kubernetes service accounts (no static AWS keys)

Secrets from AWS Secrets Manager synced into Kubernetes via External Secrets

Least-privilege IAM for controllers (ALB Controller, External Secrets, Image Updater, etc.)

📈 Observability

The application exposes metrics (Prometheus format), making it easy to integrate with:

Prometheus scraping

Grafana dashboards

Alerting rules (future-ready)

📁 Repository Structure (All Three Folders)
.
├── app-repo1/           # Application source + Docker build
├── infra-repo/          # Terraform infrastructure provisioning
└── platform-repo/       # GitOps deployment (Argo CD + Helm)
1) 🚀 app-repo1 — Application (Streamlit + Docker)

Path: app-repo1/web_app_todo/

What it contains

Streamlit-based Todo UI

PostgreSQL integration (users + todos)

Password hashing (bcrypt)

Metrics endpoint (Prometheus client)

Dockerfile for container build

Local Run (optional)

If you want to run locally (requires PostgreSQL):

cd app-repo1/web_app_todo
pip install -r requirements.txt

export DB_HOST=localhost
export DB_PORT=5432
export DB_NAME=todo
export DB_USER=postgres
export DB_PASSWORD=postgres
export DB_SSLMODE=disable

streamlit run web.py --server.port 8501

Open:

http://localhost:8501

Docker Build (optional)
cd app-repo1/web_app_todo
docker build -t todo-app:local .
docker run -p 8501:8501 \
  -e DB_HOST=<dbhost> -e DB_PORT=5432 -e DB_NAME=todo \
  -e DB_USER=<user> -e DB_PASSWORD=<pass> \
  todo-app:local
2) 🏗️ infra-repo — Infrastructure (Terraform)

Goal: Provision AWS infrastructure for a production-style Kubernetes deployment.

What it provisions

Multi-AZ VPC with public & private subnets

EKS cluster

RDS PostgreSQL (private)

IAM roles + OIDC provider (IRSA-ready)

Terraform remote state (S3 + DynamoDB locking)

CI pipeline for fmt/validate/plan/apply

Typical Terraform Workflow
cd infra-repo
terraform init
terraform fmt -recursive
terraform validate
terraform plan
terraform apply

Outputs include RDS endpoint and secret ARN (depending on modules/outputs).

3) ⚙️ platform-repo — GitOps (Argo CD + Helm)

Goal: Deploy everything on EKS using GitOps, including the todo-app, controllers, and secrets.

What it contains

Argo CD Applications (root app orchestration)

Helm chart for todo-app

External Secret definitions for DB creds

Deploy order controlled using sync waves

Image automation support (Argo CD Image Updater)

Key Paths

platform-repo/apps/todo-app/
Helm chart + templates (Deployment, Service, Ingress, ConfigMaps)

platform-repo/clusters/prod/
Production overlays / Argo CD Application manifests

Deploy/Sync

Once Argo CD is installed and pointing to this repo, Argo CD sync will create:

Namespace todo-app

Todo deployment + service + ingress

ExternalSecrets that inject DB credentials into the pods

✅ What I Personally Built / Owned

End-to-end cloud-native platform implementation:

Terraform-based AWS provisioning (VPC/EKS/RDS/IAM)

GitOps deployment (Argo CD Applications + Helm)

Containerized application packaging (Docker/ECR-ready)

Secure secrets flow (AWS Secrets Manager → External Secrets → Kubernetes)

ALB Ingress routing to live app on EKS


📌 Tech Stack

AWS: EKS, RDS PostgreSQL, VPC, IAM, Secrets Manager

Kubernetes: Ingress, Services, Deployments, ConfigMaps, Secrets

GitOps: Argo CD (+ Image Updater support)

IaC: Terraform

App: Python + Streamlit

Observability: Prometheus metrics endpoint (Grafana-ready)

License

MIT 


---



## 🔧 Key Technologies & Why

- **Karpenter** — Dynamic node autoscaling based on pod resource requests (not just CPU)
- **KEDA** — Event-driven pod autoscaling on custom metrics
- **Argo CD** — GitOps-based deployments with automatic reconciliation
- **External Secrets Operator** — Secure credential injection from AWS Secrets Manager
- **AWS Load Balancer Controller** — Native AWS ALB routing on Kubernetes
- **IRSA** — IAM roles for Kubernetes service accounts (zero static credentials)



One Screenshot Helps
If you have a screenshot of:

The Argo CD dashboard showing the deployment
The Grafana dashboards
The Karpenter logs showing node scaling