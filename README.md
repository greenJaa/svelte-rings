Svelte Rings ⚪✨

A modern, highly-reactive web application built with Svelte and SvelteKit. Svelte Rings provides a captivating, smooth visualization experience designed to be easily deployed across various environments, from local development to Kubernetes.

Installation & Deployment

You have several flexible options for running Svelte Rings, from using modern containerization to a full Kubernetes deployment via Helm.

Option 1: Kubernetes Deployment (Helm Chart)

The Helm chart for Svelte Rings is hosted via GitHub Pages, making it easy to integrate and deploy directly into your Kubernetes cluster.

1. Add the Helm Repository

First, add the official Svelte Rings repository using your GitHub Pages URL:

# Add the repository. Replace greenJaa with your GitHub username if necessary.
helm repo add svelte-rings-repo [https://greenJaa.github.io/svelte-rings/](https://greenJaa.github.io/svelte-rings/)
# Update your local helm chart cache
helm repo update


2. Install the Chart

You can now install the application into your Kubernetes cluster in a namespace of your choice (e.g., default):

helm install svelte-rings svelte-rings-repo/svelte-rings --wait


3. Access the Application

The chart typically deploys the application as a Deployment and Service. Check your service type (usually LoadBalancer or NodePort) to find the public IP or DNS name.

# Example for LoadBalancer service type
kubectl get svc svelte-rings


Option 2: Containerized Deployment (Docker)

If you prefer to run the application using a standard container runtime, you can build and run the Docker image yourself.

1. Build the Docker Image

Assuming your repository includes a standard Dockerfile, navigate to the root of the project and run:

# Builds the image and tags it locally as 'svelte-rings-app'
docker build -t svelte-rings-app .


2. Run the Container

Start the application container, mapping the container's internal port (usually 3000 or 80) to an external port on your machine (e.g., 8080):

docker run -d -p 8080:3000 --name svelte-rings-container svelte-rings-app


3. View the Application

The app will be accessible in your web browser at http://localhost:8080.

Option 3: Local Development and Testing

If you want to contribute, modify, or test the application locally without containers, follow the standard Svelte/Node.js setup.

1. Clone and Install

Clone the repository and install the dependencies:

git clone [https://github.com/greenJaa/svelte-rings.git](https://github.com/greenJaa/svelte-rings.git)
cd svelte-rings
npm install


2. Run in Development Mode

Run the app in development mode for hot-reloading and easy debugging:

npm run dev


The application will typically be available at http://localhost:5173 (or a similar port).

3. Build for Production

To create a static production build:

npm run build


The output will be placed in the build directory (or as configured in svelte.config.js), ready to be served by any static web server (like Nginx or an internal Node server).

🛠 Project Structure

This project follows the standard SvelteKit directory structure:

src/routes/: Your application pages and endpoints.

src/lib/: Reusable components, utilities, and assets.

static/: Static files that are served directly.

Dockerfile: Instructions for containerizing the application.

chart/: The Helm chart files for Kubernetes deployment.
