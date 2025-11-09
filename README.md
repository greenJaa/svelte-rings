# Svelte Rings 
 
[![Helm Chart](https://img.shields.io/badge/helm-v0.1.0-blue)](https://greenJaa.github.io/svelte-rings/) 
[![Docker](https://img.shields.io/badge/docker-latest-blue)](https://hub.docker.com/) 
[![Vercel](https://img.shields.io/badge/vercel-deploy-green)](https://vercel.com/)
 
Svelte Rings supports deployments across Docker, Kubernetes (Helm), and Vercel.

---
            
## Quick Start

### Clone & Install
```bash
git clone https://github.com/greenJaa/svelte-rings.git
cd svelte-rings
npm ci
```
### Run locally
```
npm run dev
```
The app will be accessible at http://localhost:5000


# Deployment Options
## ⚓ Option 1: Deploy with Helm (Kubernetes)

The official Helm chart is hosted via GitHub Pages:

Repository: https://greenJaa.github.io/svelte-rings/

Add Helm repo
```
helm repo add svelte-rings https://greenJaa.github.io/svelte-rings/
helm repo update

# Install chart

helm install svelte-rings svelte-rings/svelte-rings --wait

# Check service (to access your app)

kubectl get svc svelte-rings
```
## 🐳 Option 2: Run with Docker
Build Docker image
```
docker build -t svelte-rings-app .

# Run container (map external 8080 to internal 5000)

docker run -d -p 8080:5000 --name svelte-rings svelte-rings-app
```
The app will be available at http://localhost:8080

.
## 💻 Option 3: Local Development
Clone repo
```
git clone https://github.com/greenJaa/svelte-rings.git
cd svelte-rings

# Install dependencies

npm install

# Start dev server

npm run dev
```
Access locally at http://localhost:5000


Build for production
```
npm run build
```

⚙️ CI/CD Automation

    Helm Charts: Automatically packaged and published to GitHub Pages on branch updates.

    Vercel Deployment: Pushes to the cool-edit branch trigger production deployment.
## Project Structure
```
.
├── ansible
│   └── hosts.ini
├── CONTRIBUTORS.md
├── Dockerfile
├── package.json
├── package-lock.json
├── public
│   ├── build
│   │   ├── bundle.css
│   │   ├── bundle.css.map
│   │   ├── bundle.js
│   │   └── bundle.js.map
│   ├── favicon.png
│   ├── font
│   │   ├── GoodTimes.otf
│   │   ├── rings.eot
│   │   ├── rings.svg
│   │   ├── rings.ttf
│   │   ├── rings.woff
│   │   ├── rings.woff2
│   │   └── Skranji-Regular.ttf
│   ├── global.css
│   ├── index.html
│   └── sounds
│       ├── beat-wood-high.mp3
│       ├── beat-wood.mp3
│       ├── clap.mp3
│       ├── djembe-base.mp3
│       ├── djembe-slap.mp3
│       ├── djembe-tone.mp3
│       ├── dundunba.mp3
│       ├── kenkeni.mp3
│       ├── sangban-closed.mp3
│       ├── sangban.mp3
│       └── shake.mp3
├── README.md
├── rollup.config.js
├── src
│   ├── App.svelte
│   ├── arrange.js
│   ├── attack.js
│   ├── bpm_select.svelte
│   ├── circle.svelte
│   ├── colors.js
│   ├── debug.js
│   ├── debug_layer.svelte
│   ├── dot_next.svelte
│   ├── dot_rect.svelte
│   ├── dot.svelte
│   ├── episode_bar.svelte
│   ├── episode.js
│   ├── instrument_bar.svelte
│   ├── instrument.js
│   ├── lib
│   │   ├── firebase.js
│   │   ├── firebase.js.old
│   │   └── stores
│   │       └── user.js
│   ├── longpress.js
│   ├── main.js
│   ├── phrase.js
│   ├── play_button.svelte
│   ├── pointer.js
│   ├── progress_circle.svelte
│   ├── pulse.js
│   ├── rhythm.js
│   ├── rhythm_menu.svelte
│   ├── routes
│   │   ├── dashboard.svelte
│   │   ├── +layout.svelte
│   │   ├── login
│   │   │   └── +page.svelte
│   │   ├── login.svelte
│   │   └── register.svelte
│   ├── sounds.js
│   ├── symbols.js
│   ├── utils.js
│   └── volume_view.svelte
├── svelte-rings-chart
│   ├── Chart.yaml
│   ├── templates
│   │   ├── deployment.yaml
│   │   ├── _helpers.tpl
│   │   ├── hpa.yaml
│   │   ├── ingress.yaml
│   │   ├── NOTES.txt
│   │   ├── serviceaccount.yaml
│   │   ├── service.yaml
│   │   └── tests
│   │       └── test-connection.yaml
│   └── values.yaml
├── svelte-rings.yaml
└── terraform
    ├── k8s-key.pub
    ├── main.tf
    ├── main.tf.old
    ├── svelte-rings.yaml
    ├── terraform.tfstate
    ├── terraform.tfstate.1759573608.backup
    └── terraform.tfstate.backup

15 directories, 87 files

