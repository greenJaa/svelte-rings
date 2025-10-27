# ---- Stage 1: Build the Svelte app ----
FROM node:18 AS builder

WORKDIR /app

COPY package*.json ./
RUN npm install

COPY . .
RUN npm run build

# ---- Stage 2: Serve the built app using a lightweight web server ----
FROM nginx:alpine

# Remove the default nginx page & copy built files
RUN rm -rf /usr/share/nginx/html/*

COPY --from=builder /app/public /usr/share/nginx/html

# Expose port 80 to host machine
EXPOSE 80

CMD ["nginx", "-g", "daemon off;"]

