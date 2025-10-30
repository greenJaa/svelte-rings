# Use Debian-based Node (more stable)
FROM node:20-bullseye

WORKDIR /app

# Install dependencies
COPY package*.json ./
RUN npm ci

# Copy source and build
COPY . .
RUN npm run build

# Expose port 5000
EXPOSE 5000

# Start app on all interfaces
CMD ["npx", "sirv", "public", "--single", "--host", "0.0.0.0", "--port", "5000"]

