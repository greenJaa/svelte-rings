# Svelte Rings

A Svelte web app with a Helm chart for easy Kubernetes deployment.

## Quick Start

### Clone & Install

```bash
git clone https://github.com/greenJaa/svelte-rings.git
cd svelte-rings
git checkout cool-edit
npm ci

Run Locally

npm run dev

Open http://localhost:5000

in your browser.
Build for Production

npm run build
npm run start

Helm Chart

Chart folder: svelte-rings-chart/
Deploy via Helm

# Package the chart and generate index
helm package svelte-rings-chart
helm repo index . --url https://greenJaa.github.io/svelte-rings

# Add repo and install
helm repo add svelte-rings https://greenJaa.github.io/svelte-rings
helm repo update
helm install my-svelte-app svelte-rings/svelte-rings

# Check deployed resources
kubectl get pods
kubectl get svc

License

MIT


This version is **short, clear, and covers both local dev and Helm deployment**.  

If you want, I can also make a **super-compact version** that focuses almost entirely on Helm
