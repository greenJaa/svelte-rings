# Svelte Rings

[![Helm Chart](https://img.shields.io/badge/helm-v0.1.0-blue)](https://greenJaa.github.io/svelte-rings/) 
[![Docker](https://img.shields.io/badge/docker-latest-blue)](https://hub.docker.com/) 
[![Vercel](https://img.shields.io/badge/vercel-deploy-green)](https://vercel.com/)

Svelte Rings supports deployments across Docker, Kubernetes (Helm), and Vercel.

---

## Quick Start

### Clone & Install

`git clone https://github.com/greenJaa/svelte-rings.git
cd svelte-rings
npm ci

Run locally

npm run dev

Deployment Options
# Option 1: Deploy with Helm (Kubernetes)

The official Helm chart is hosted via GitHub Pages:

Repository: https://greenJaa.github.io/svelte-rings/
Add Helm repo

helm repo add svelte-rings https://greenJaa.github.io/svelte-rings/
helm repo update

Install chart

helm install svelte-rings svelte-rings/svelte-rings --wait

Check service (to access your app)

kubectl get svc svelte-rings

# 🐳 Option 2: Run with Docker
Build Docker image

docker build -t svelte-rings-app .

Run container (map external 8080 to internal 5000)

docker run -d -p 8080:5000 --name svelte-rings svelte-rings-app

The app will be available at http://localhost:8080

.
# 💻 Option 3: Local Development
Clone repo

git clone https://github.com/greenJaa/svelte-rings.git
cd svelte-rings

Install dependencies

npm install

Start dev server

npm run dev

Access locally at http://localhost:5000

.
Build for production

npm run build

⚙️ CI/CD Automation

    Helm Charts: Automatically packaged and published to GitHub Pages on branch updates.

    Vercel Deployment: Pushes to the cool-edit branch trigger production deployment.

    Svelte App CI: Runs build, lint, and test workflows on every push or pull request to main branches.
