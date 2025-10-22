# Strapi Deployment Guide (Without Docker)

## Prerequisites on Your Server

1. **Node.js** (version 18.x or 20.x or 22.x)
2. **npm** (version 6.x or higher)
3. **PostgreSQL** (version 12 or higher) - running and accessible
4. **PM2** (optional but recommended for process management)

## Step-by-Step Deployment Instructions

### 1. Prepare Your Server

```bash
# Update system packages
sudo apt update && sudo apt upgrade -y

# Install Node.js (using NodeSource)
curl -fsSL https://deb.nodesource.com/setup_20.x | sudo -E bash -
sudo apt install -y nodejs

# Verify installation
node --version
npm --version

# Install PM2 globally (for process management)
sudo npm install -g pm2

# Install PostgreSQL (if not already installed)
sudo apt install -y postgresql postgresql-contrib
```

### 2. Setup PostgreSQL Database

```bash
# Switch to postgres user
sudo -u postgres psql

# Create database and user
CREATE DATABASE strapi;
CREATE USER strapi WITH ENCRYPTED PASSWORD 'your_secure_password';
GRANT ALL PRIVILEGES ON DATABASE strapi TO strapi;
\q
```

### 3. Prepare Your Local Project

Before copying to server, prepare your project:

```bash
# Build your Strapi admin panel
npm run build

# Create a production-ready package (optional - tar the project)
tar -czf strapi-app.tar.gz \
  --exclude='node_modules' \
  --exclude='.git' \
  --exclude='.tmp' \
  --exclude='database/backups/*' \
  --exclude='docker-compose*.yml' \
  --exclude='Dockerfile' \
  --exclude='setup-docker.sh' \
  --exclude='setup-production.sh' \
  .
```

### 4. Copy Project to Server

Choose one of these methods:

**Option A: Using SCP**

```bash
scp strapi-app.tar.gz user@your-server-ip:/home/user/
```

**Option B: Using rsync (recommended)**

```bash
rsync -avz --progress \
  --exclude='node_modules' \
  --exclude='.git' \
  --exclude='.tmp' \
  --exclude='database/backups/*' \
  --exclude='docker-compose*.yml' \
  --exclude='Dockerfile' \
  --exclude='setup-docker.sh' \
  --exclude='setup-production.sh' \
  ./ user@your-server-ip:/home/user/strapi/
```

**Option C: Using Git (recommended)**

```bash
# On server
git clone https://github.com/max199161/jonwin-backend.git strapi
cd strapi
```

### 5. Setup on Server

```bash
# SSH into your server
ssh user@your-server-ip

# Navigate to project directory
cd /home/user/strapi

# Extract if you used tar
# tar -xzf strapi-app.tar.gz

# Install dependencies
npm install --production

# Create .env file
nano .env
```

### 6. Configure Environment Variables

Create a `.env` file with your production settings:

```bash
# Database Configuration
DATABASE_CLIENT=postgres
DATABASE_HOST=localhost
DATABASE_PORT=5432
DATABASE_NAME=strapi
DATABASE_USERNAME=strapi
DATABASE_PASSWORD=your_secure_password

# Application Configuration
NODE_ENV=production
HOST=0.0.0.0
PORT=1337

# Strapi Configuration (GENERATE NEW KEYS!)
APP_KEYS="key1,key2,key3,key4"
API_TOKEN_SALT=your_api_token_salt
ADMIN_JWT_SECRET=your_admin_jwt_secret
TRANSFER_TOKEN_SALT=your_transfer_token_salt
JWT_SECRET=your_jwt_secret

# Optional: Public URL
URL=https://your-domain.com
```

**Generate secure keys:**

```bash
# Generate random keys
node -e "console.log(require('crypto').randomBytes(32).toString('base64'))"
```

### 7. Build Admin Panel (if not done locally)

```bash
npm run build
```

### 8. Start Application

**Option A: Using PM2 (Recommended)**

```bash
# Start with PM2
pm2 start npm --name "strapi" -- start

# Save PM2 configuration
pm2 save

# Setup PM2 to start on server boot
pm2 startup

# Monitor application
pm2 status
pm2 logs strapi
```

**Option B: Direct Start (for testing)**

```bash
npm start
```

### 9. Setup Nginx Reverse Proxy (Recommended)

```bash
# Install Nginx
sudo apt install -y nginx

# Create Nginx configuration
sudo nano /etc/nginx/sites-available/strapi
```

Add this configuration:

```nginx
server {
    listen 80;
    server_name your-domain.com;

    location / {
        proxy_pass http://localhost:1337;
        proxy_http_version 1.1;
        proxy_set_header Upgrade $http_upgrade;
        proxy_set_header Connection 'upgrade';
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
        proxy_cache_bypass $http_upgrade;
    }
}
```

```bash
# Enable the site
sudo ln -s /etc/nginx/sites-available/strapi /etc/nginx/sites-enabled/

# Test Nginx configuration
sudo nginx -t

# Restart Nginx
sudo systemctl restart nginx
```

### 10. Setup SSL with Let's Encrypt (Optional but Recommended)

```bash
# Install Certbot
sudo apt install -y certbot python3-certbot-nginx

# Get SSL certificate
sudo certbot --nginx -d your-domain.com

# Auto-renewal is set up automatically
```

## File Structure on Server

```
/home/user/strapi/
├── config/
├── src/
├── public/
│   └── uploads/        # Make sure this is writable
├── database/
├── node_modules/
├── build/              # Generated admin build
├── .env               # Your production environment variables
├── package.json
└── ...
```

## Important Considerations

### 1. File Permissions

```bash
# Ensure uploads directory is writable
chmod -R 755 public/uploads
chown -R www-data:www-data public/uploads  # If using nginx
```

### 2. Firewall Configuration

```bash
# Allow HTTP and HTTPS
sudo ufw allow 80
sudo ufw allow 443
sudo ufw allow 22  # SSH
sudo ufw enable
```

### 3. Database Backup

```bash
# Create backup script
nano ~/backup-strapi-db.sh
```

Add:

```bash
#!/bin/bash
BACKUP_DIR="/home/user/backups"
DATE=$(date +%Y%m%d_%H%M%S)
mkdir -p $BACKUP_DIR
pg_dump -U strapi -h localhost strapi > $BACKUP_DIR/strapi_backup_$DATE.sql
# Keep only last 7 days
find $BACKUP_DIR -name "strapi_backup_*.sql" -mtime +7 -delete
```

```bash
chmod +x ~/backup-strapi-db.sh

# Add to crontab for daily backups at 2 AM
crontab -e
# Add: 0 2 * * * /home/user/backup-strapi-db.sh
```

### 4. Restore Database (if needed)

```bash
# If you have a database dump from the project
psql -U strapi -h localhost strapi < database/migrations/jonwin_2025-08-25.dump
```

## Useful PM2 Commands

```bash
# View logs
pm2 logs strapi

# Restart application
pm2 restart strapi

# Stop application
pm2 stop strapi

# Delete from PM2
pm2 delete strapi

# Monitor resources
pm2 monit
```

## Updating Your Application

```bash
# Pull latest changes (if using Git)
cd /home/user/strapi
git pull origin master

# Or upload new files using rsync/scp

# Install new dependencies
npm install --production

# Rebuild admin
npm run build

# Restart with PM2
pm2 restart strapi
```

## Troubleshooting

### Application won't start

```bash
# Check logs
pm2 logs strapi --lines 100

# Check if port is already in use
sudo lsof -i :1337

# Check database connection
psql -U strapi -h localhost -d strapi
```

### Permission issues

```bash
# Fix ownership
sudo chown -R $USER:$USER /home/user/strapi

# Fix permissions
chmod -R 755 /home/user/strapi
chmod -R 755 public/uploads
```

### Out of memory

```bash
# Increase Node.js memory limit
pm2 delete strapi
pm2 start npm --name "strapi" --node-args="--max-old-space-size=4096" -- start
```

## Environment Variables Reference

| Variable            | Description       | Example                      |
| ------------------- | ----------------- | ---------------------------- |
| `DATABASE_HOST`     | PostgreSQL host   | `localhost`                  |
| `DATABASE_PORT`     | PostgreSQL port   | `5432`                       |
| `DATABASE_NAME`     | Database name     | `strapi`                     |
| `DATABASE_USERNAME` | Database user     | `strapi`                     |
| `DATABASE_PASSWORD` | Database password | `secure_password`            |
| `NODE_ENV`          | Environment       | `production`                 |
| `HOST`              | Server host       | `0.0.0.0`                    |
| `PORT`              | Server port       | `1337`                       |
| `URL`               | Public URL        | `https://api.yourdomain.com` |

## Security Checklist

- [ ] Use strong database passwords
- [ ] Generate new random keys for production
- [ ] Enable firewall (UFW)
- [ ] Setup SSL certificate
- [ ] Regular database backups
- [ ] Keep Node.js and dependencies updated
- [ ] Monitor application logs
- [ ] Restrict database access to localhost only
- [ ] Use environment variables for sensitive data
- [ ] Never commit .env file to Git

---

**Need Help?** Check Strapi documentation: https://docs.strapi.io/dev-docs/deployment
