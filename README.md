
 
# svelte app
A Svelte web app with a Helm chart for easy Kubernetes deployment.
 
## Quick Start

### Clone & Install

```bash
git clone https://github.com/greenJaa/svelte-rings.git
cd svelte-rings
git checkout cool-edit
npm ci

## **Run locally**
npm run dev
⚪ Svelte Rings ✨

A modern, reactive web application built with Svelte and SvelteKit.
Svelte Rings delivers smooth, dynamic visualizations and supports deployments across Docker, Kubernetes (Helm), and Vercel.

🚀 Deployment Options
## 🌀 Option 1: Deploy with Helm (Kubernetes)

The official Helm chart is hosted via GitHub Pages:

Repository: https://greenJaa.github.io/svelte-rings/

### Add Helm repo
helm repo add svelte-rings https://greenJaa.github.io/svelte-rings/

helm repo update

### Install chart
helm install svelte-rings svelte-rings/svelte-rings --wait

### Check service (to access your app)
kubectl get svc svelte-rings


## 🐳 Option 2: Run with Docker

### Build Docker image
docker build -t svelte-rings-app .

### Run container (map external 8080 to internal 5000)
docker run -d -p 8080:3000 --name svelte-rings svelte-rings-app


## 💻 Option 3: Local Development
### Clone repo
git clone https://github.com/greenJaa/svelte-rings.git

cd svelte-rings

### Install dependencies
npm install

### Start dev server
npm run dev

Access locally at http://localhost:5000

To build for production:

npm run build

⚙️ CI/CD Automation
