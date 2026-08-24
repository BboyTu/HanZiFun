# syntax=docker/dockerfile:1

# ---- Build stage ----
FROM node:22-alpine AS builder

WORKDIR /app

# Install system tools needed to unpack the .deb font package
RUN apk add --no-cache binutils xz

# Install Node dependencies
COPY package*.json ./
RUN npm ci

# Copy source
COPY . .

# Build app shell and produce dist/
RUN npm run build

# ---- Runtime stage ----
FROM caddy:2.8-alpine

# Copy built static files
COPY --from=builder /app/dist /srv/hanzifun
COPY Caddyfile /etc/caddy/Caddyfile

# Caddy listens on 80 by default
EXPOSE 80

CMD ["caddy", "run", "--config", "/etc/caddy/Caddyfile", "--adapter", "caddyfile"]
