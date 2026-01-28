# RealWorld Example Application (CI/CD on k3s)

This repository contains a complete full-stack implementation of the [RealWorld](https://realworld.io/) API specification, showcasing containerized application delivery with automated CI/CD deployment to a self-hosted k3s Kubernetes cluster.

The project demonstrates a real-world DevOps workflow: build, push, resolve, and deploy container images using GitHub Actions, Kubernetes, and HashiCorp Vault on a Proxmox-based homelab infrastructure.

---

## Overview

This repository builds and deploys both frontend and backend services using Docker and Kubernetes (k3s).

A GitHub Actions pipeline running on a **self-hosted runner** automates:

- Docker image builds
- Container registry push (GitHub Container Registry)
- Secure retrieval of Kubernetes credentials from Vault
- Deployment and rollout verification on k3s

---

## Architecture

### Application Components

- **Backend** (`spring-boot-realworld-example-app/`)
  - Spring Boot REST API
  - RealWorld specification compliant
  - Dockerized via multi-stage build

- **Frontend** (`vue-realworld-example-app/`)
  - Vue.js single-page application
  - Built into a static site and served via Nginx
  - Dockerized frontend container

---

### Kubernetes (k3s)

Kubernetes manifests are located in the `k3s/` directory:

- `backend-deployment.yaml` — Backend Deployment & Service
- `frontend-deployment.yaml` — Frontend Deployment & Service
- `ingress.yaml` — HTTP routing via Ingress

Deployments support dynamic image resolution to avoid unnecessary restarts when services are unchanged.

---

## CI/CD Pipeline

GitHub Actions workflow: `.github/workflows/docker-build.yml`



### Pipeline Characteristics

- Runs on a **self-hosted GitHub Actions runner** inside the Proxmox environment
- Uses Docker Buildx for image builds
- Pushes images to **GitHub Container Registry (GHCR)**
- Fetches Kubernetes credentials securely from **HashiCorp Vault**
- Deploys directly to the k3s cluster using `kubectl`
- Verifies deployment rollout status

---

### Pipeline Flow

1. **Detect Changes**
   - Path-based filtering determines which services require rebuilding

2. **Build & Push Images**
   - Backend and frontend images are built independently
   - Two tags are pushed per image:
     - `sha-<commit>`
     - `latest`

3. **Secure Access via Vault**
   - Kubernetes kubeconfig is fetched from Vault at deployment time
   - No kubeconfig is stored in the repository or runner filesystem

4. **Deploy to k3s**
   - Image tags are resolved dynamically using `image-resolver.sh`
   - Kubernetes manifests are applied
   - Deployment rollout status is verified

---

## Secrets Management

- HashiCorp Vault is used during CI/CD execution
- Kubernetes access credentials are retrieved dynamically
- No static credentials are committed to the repository
- No long-lived kubeconfig exists on the runner

Vault access is restricted to deployment-time usage.

---

## Infrastructure Foundation

This project is built on top of a home-lab infrastructure defined in [tf_on_prxmx](https://github.com/uvegesi/tf_on_prxmx), a Terraform and Ansible-based infrastructure-as-code project that automates setup on Proxmox. 

The foundation includes: 
- **Kubernetes Cluster**: 3 VMs provisioned on Proxmox - 1 master node - 2 worker nodes - Managed by Tailscale for secure networking 
- **Self-Hosted Services**: - LXC container for self-hosted GitHub Actions runner - LXC container for HashiCorp Vault (secrets management) 
- **Networking**: Tailscale integration for secure remote access to the infrastructure

---

## Local Development

### Backend

```bash
cd spring-boot-realworld-example-app
./gradlew build
./gradlew bootRun
```

**Frontend:**
```bash
cd vue-realworld-example-app
npm install
npm run dev
```

### Deployment

Deployment is fully automated.

Pushing changes to the main branch triggers the GitHub Actions pipeline, which builds, pushes, and deploys updated services to the k3s cluster.

No manual kubectl apply is required.

## Project Structure

```
.
├── spring-boot-realworld-example-app/   # Backend service
├── vue-realworld-example-app/           # Frontend service
├── k3s/                                 # Kubernetes manifests
│   ├── backend-deployment.yaml
│   ├── frontend-deployment.yaml
│   └── ingress.yaml
├── .github/workflows/                   # GitHub Actions CI/CD
│   └── docker-build.yml
├── image-resolver.sh                    # Image resolution helper
└── README.md
```

## API Documentation

The backend provides both REST and GraphQL endpoints implementing the RealWorld specification. See the [RealWorld API](https://realworld.io/docs/specs/backend-specs/introduction/) for detailed endpoint documentation.

## License

See LICENSE files in individual service directories for licensing information.
