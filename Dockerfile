# Use Node.js 18 LTS
FROM node:18-alpine

# Set working directory
WORKDIR /opt/app

# Install dependencies for native modules and PostgreSQL client
RUN apk update && apk add --no-cache \
    build-base \
    gcc \
    autoconf \
    automake \
    zlib-dev \
    libpng-dev \
    nasm \
    bash \
    vips-dev \
    postgresql-client \
    && rm -rf /var/cache/apk/*

# Copy package files
COPY package*.json ./

# Install dependencies
RUN npm ci --only=production

# Copy source code
COPY . .

# Create necessary directories
RUN mkdir -p public/uploads

# Set proper ownership
RUN chown -R node:node /opt/app
USER node

# Build the application
RUN npm run build

# Expose port
EXPOSE 1337

# Health check
HEALTHCHECK --interval=30s --timeout=30s --start-period=60s --retries=3 \
    CMD curl -f http://localhost:1337/_health || exit 1

# Start the application
CMD ["npm", "start"]
