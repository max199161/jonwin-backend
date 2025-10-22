# Quick Deployment Guide

## What You Need on Your Server

1. **Node.js** (v18 or v20 or v22)
2. **PostgreSQL** database
3. **PM2** (for running the app)

## Step-by-Step: Copy Project to Server

### 1. Prepare Locally

```bash
# Build the admin panel
npm run build

# Create a zip/tar without node_modules
tar -czf strapi-deploy.tar.gz \
  --exclude='node_modules' \
  --exclude='.git' \
  --exclude='docker-*' \
  --exclude='Dockerfile' \
  .
```

### 2. Copy to Server

```bash
# Upload the file
scp strapi-deploy.tar.gz user@your-server:/home/user/

# OR use rsync (better)
rsync -avz --exclude='node_modules' --exclude='.git' ./ user@your-server:/home/user/strapi/
```

### 3. Setup on Server

```bash
# SSH to server
ssh user@your-server

# Extract files (if using tar)
cd /home/user
tar -xzf strapi-deploy.tar.gz -C strapi/
cd strapi

# Install dependencies
npm install --production

# Create .env file
nano .env
```

**Add to `.env`:**
```bash
DATABASE_CLIENT=postgres
DATABASE_HOST=localhost
DATABASE_PORT=5432
DATABASE_NAME=strapi
DATABASE_USERNAME=strapi
DATABASE_PASSWORD=your_password

NODE_ENV=production
HOST=0.0.0.0
PORT=1337

# Generate new random keys!
APP_KEYS="key1,key2,key3,key4"
API_TOKEN_SALT=random_salt
ADMIN_JWT_SECRET=random_secret
TRANSFER_TOKEN_SALT=random_salt
JWT_SECRET=random_secret
```

### 4. Start the App

```bash
# Install PM2 globally
sudo npm install -g pm2

# Start Strapi
pm2 start npm --name "strapi" -- start

# Save configuration
pm2 save

# Auto-start on server reboot
pm2 startup
```

### 5. Access Your App

Visit: `http://your-server-ip:1337`

## Useful Commands

```bash
# View logs
pm2 logs strapi

# Restart app
pm2 restart strapi

# Stop app
pm2 stop strapi

# Check status
pm2 status
```

## Update Your App

```bash
# Copy new files to server
rsync -avz --exclude='node_modules' ./ user@your-server:/home/user/strapi/

# On server
cd /home/user/strapi
npm install --production
npm run build
pm2 restart strapi
```

## Database Setup

If PostgreSQL is not set up:

```bash
sudo apt install postgresql

# Create database
sudo -u postgres psql
CREATE DATABASE strapi;
CREATE USER strapi WITH PASSWORD 'your_password';
GRANT ALL PRIVILEGES ON DATABASE strapi TO strapi;
\q
```

## Need More Details?

See `DEPLOYMENT.md` for:
- Nginx reverse proxy setup
- SSL certificate setup
- Security best practices
- Troubleshooting
- Backup strategies

---

**Important:** Always generate new random keys for production!
```bash
node -e "console.log(require('crypto').randomBytes(32).toString('base64'))"
```
