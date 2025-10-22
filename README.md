# Jowin Strapi CMS

A headless CMS built with Strapi 5.11.2, featuring PostgreSQL database and comprehensive data management tools for the Jowin application ecosystem.

**Production API**: https://backend.jonwininternational.com

## 📋 Table of Contents

- [Overview](#overview)
- [Tech Stack](#tech-stack)
- [Project Structure](#project-structure)
- [Quick Start](#quick-start)
- [Database Management](#database-management)
- [Development](#development)
- [Server Deployment](#server-deployment)
- [Deployment Scripts](#deployment-scripts)
- [API Endpoints](#api-endpoints)
- [Troubleshooting](#troubleshooting)

## 🔍 Overview

This Strapi CMS manages content for the Jowin application, including:

- **Events Management** (42+ events)
- **Partner Directory** (30+ partners)
- **Store Locations** (8+ stores)
- **Media Assets** (379+ files)
- **User Management & Authentication**

The system is fully containerized with Docker and includes automated backup/restoration tools.

## 🛠 Tech Stack

- **Backend**: Strapi 5.11.2 (Node.js 20)
- **Database**: PostgreSQL
- **Language**: TypeScript
- **Process Manager**: PM2 (production)
- **Plugins**:
  - CKEditor for rich text editing
  - Users & Permissions
  - Cloud integration
  - Advanced UUID
  - Slugify

## 📁 Project Structure

```
strapi/
├── 📄 README.md                      # This documentation
├── 📄 DEPLOYMENT.md                  # Full deployment guide
├── 📄 README-DEPLOYMENT-QUICK.md     # Quick deployment reference
├── 📄 UPLOADS-SYNC-GUIDE.md          # Upload management guide
├── 📄 DATABASE-BACKUP-RESTORE.md     # Backup & restore guide
├── 📦 package.json                   # Dependencies & scripts
├── ⚙️ tsconfig.json                  # TypeScript configuration
├──
├── 📁 config/                        # Strapi configuration
│   ├── admin.ts                     # Admin panel settings
│   ├── api.ts                       # API configuration
│   ├── database.ts                  # Database connection (localhost)
│   ├── middlewares.ts               # Request middlewares
│   ├── plugins.ts                   # Plugin configuration
│   └── server.ts                    # Server settings
├──
├── 📁 src/                           # Application source code
│   ├── index.ts                     # Entry point
│   ├── admin/                       # Admin customizations
│   ├── api/                         # API routes & controllers
│   ├── components/                  # Reusable components
│   └── extensions/                  # Core extensions
├──
├── 📁 database/                      # Database related files
│   ├── backups/                     # Database backups
│   └── migrations/                  # Database dumps
│       └── jonwin_2025-08-25.dump
├──
├── 📁 scripts/                       # Automation scripts
│   ├── backup-db-standalone.sh      # Backup database (non-Docker)
│   ├── restore-db-standalone.sh     # Restore database (non-Docker)
│   ├── backup-db.sh                 # Backup (Docker - legacy)
│   └── restore-db.sh                # Restore (Docker - legacy)
├──
├── 🔧 prepare-deploy.sh              # Creates deployment package
├── 🔧 update-server.sh               # Deploy updates to server
├── 🔧 sync-uploads-from-server.sh    # Download server uploads
├── 🔧 sync-uploads-to-server.sh      # Upload files to server
├──
├── 📁 public/                        # Static assets
│   ├── robots.txt
│   └── uploads/                     # User uploads (379+ files)
├──
├── 📁 build/                         # Built admin panel
├── 📁 dist/                          # Compiled TypeScript
└── 📁 types/                         # TypeScript definitions
    └── generated/                   # Auto-generated types
```

## 🚀 Quick Start

### Prerequisites

- Node.js 18, 20, or 22
- PostgreSQL database
- PM2 (for production server)
- Git

### 1. Clone & Setup

```bash
git clone https://github.com/max199161/jonwin-backend.git
cd jonwin-backend
```

### 2. Install Dependencies

```bash
npm install
```

### 3. Environment Configuration

```bash
# Copy environment template
cp .env.example .env

# Edit .env with your settings
nano .env
```

Required environment variables:

```bash
DATABASE_CLIENT=postgres
DATABASE_HOST=localhost
DATABASE_PORT=5432
DATABASE_NAME=strapi
DATABASE_USERNAME=strapi
DATABASE_PASSWORD=your_password

NODE_ENV=development
HOST=0.0.0.0
PORT=1337

# Generate secure keys for production
APP_KEYS="key1,key2,key3,key4"
API_TOKEN_SALT=random_salt
ADMIN_JWT_SECRET=random_secret
TRANSFER_TOKEN_SALT=random_salt
JWT_SECRET=random_secret
```

**Generate secure keys:**

```bash
node -e "console.log(require('crypto').randomBytes(32).toString('base64'))"
```

### 4. Setup Database

```bash
# Create PostgreSQL database
sudo -u postgres psql
CREATE DATABASE strapi;
CREATE USER strapi WITH PASSWORD 'your_password';
GRANT ALL PRIVILEGES ON DATABASE strapi TO strapi;
\q
```

### 5. Start Development

```bash
# Development mode with hot reload
npm run develop

# Or build and start
npm run build
npm start
```

### 6. Access Applications

- **Strapi Admin**: http://localhost:1337/admin
- **API Endpoint**: http://localhost:1337/api
- **Production API**: https://backend.jonwininternational.com

## Database Management

### Current Data

- **Events**: 42+ records
- **Partners**: 30+ records
- **Stores**: 8+ records
- **Files**: 379+ media assets

### Database Connection

```bash
# Connect to PostgreSQL
psql -U strapi -h localhost -d strapi

# Check data counts
psql -U strapi -d strapi -c "
  SELECT 'events' as table_name, COUNT(*) as count FROM events
  UNION ALL SELECT 'partners', COUNT(*) FROM partners
  UNION ALL SELECT 'stores', COUNT(*) FROM stores
  UNION ALL SELECT 'files', COUNT(*) FROM files;
"
```

### Backup & Restore

**Quick Commands:**

```bash
# Create backup
./scripts/backup-db-standalone.sh

# Restore backup (interactive)
./scripts/restore-db-standalone.sh
```

**Complete Guide**: [DATABASE-BACKUP-RESTORE.md](DATABASE-BACKUP-RESTORE.md)

**What's included:**

- Automated backup & restore scripts
- Manual backup procedures
- Server backup strategies
- Automated cron jobs
- Emergency recovery
- Data verification

**Backup locations:**

- `database/backups/` - Timestamped backups
- `database/migrations/` - Initial/reference dumps

## 💻 Development

### Local Development

```bash
# Install dependencies
npm install

# Start in development mode
npm run develop

# Build for production
npm run build

# Start production server
npm start
```

### Available Scripts

| Script      | Command           | Purpose                  |
| ----------- | ----------------- | ------------------------ |
| **Develop** | `npm run dev`     | Start development server |
| **Build**   | `npm run build`   | Build admin panel        |
| **Start**   | `npm start`       | Start production server  |
| **Upgrade** | `npm run upgrade` | Upgrade Strapi version   |

### Environment Files

- `.env` - Your local/production environment variables
- `.env.example` - Template with all available variables

## 🚀 Server Deployment

### Quick Deploy to Server

Use the deployment script to package and deploy updates:

```bash
# 1. Build and create deployment package
./prepare-deploy.sh

# 2. Copy to your server
scp strapi-update.tar.gz user@your-server:/home/user/strapi/

# 3. On your server:
cd /home/user/strapi
tar -xzf strapi-update.tar.gz
rm -rf node_modules
npm install
pm2 restart strapi
```

### Complete Deployment Guides

- **[DEPLOYMENT.md](DEPLOYMENT.md)** - Full deployment guide with Nginx, SSL, security
- **[README-DEPLOYMENT-QUICK.md](README-DEPLOYMENT-QUICK.md)** - Quick reference
- **[UPLOADS-SYNC-GUIDE.md](UPLOADS-SYNC-GUIDE.md)** - Managing uploads between local and server

## � Deployment Scripts

### `prepare-deploy.sh` - Create Deployment Package

Creates a deployment package excluding node_modules, uploads, and .env:

```bash
./prepare-deploy.sh
```

**Output**: `strapi-update.tar.gz` (ready to deploy)

**What's excluded:**

- ❌ `node_modules/` (install fresh on server)
- ❌ `public/uploads/*` (preserves server uploads)
- ❌ `.env` (keeps server environment)
- ❌ `.git/` and `.tmp/`

### `update-server.sh` - Automated Deployment

Deploys code updates via rsync (preserves uploads):

```bash
# Configure server details in script first
./update-server.sh
```

**What it does:**

1. Builds admin panel locally
2. Syncs code to server (excluding uploads)
3. Installs dependencies on server
4. Restarts PM2

### `sync-uploads-from-server.sh` - Download Uploads

Downloads production uploads for local testing:

```bash
./sync-uploads-from-server.sh
```

### `sync-uploads-to-server.sh` - Upload Files

⚠️ **Use carefully** - Uploads local files to server:

```bash
./sync-uploads-to-server.sh
```

**See [UPLOADS-SYNC-GUIDE.md](UPLOADS-SYNC-GUIDE.md) for complete upload management**

## � API Endpoints

### Content Types

- **Events**: `GET /api/events`
- **Partners**: `GET /api/partners`
- **Stores**: `GET /api/stores`
- **Wholesale**: `GET /api/wholesale`
- **Files**: `GET /api/upload/files`

### Production API

Base URL: `https://backend.jonwininternational.com`

Example:

```bash
curl https://backend.jonwininternational.com/api/wholesale
```

### Authentication

- JWT tokens required for protected endpoints
- Admin panel: `/admin`
- User registration: `/api/auth/local/register`
- Login: `/api/auth/local`

## 🔧 Troubleshooting

### Common Issues

#### � Port Issues

```bash
# Check if port 1337 is in use
lsof -ti:1337 | xargs kill -9

# Or use a different port in .env
PORT=3000
```

#### 💾 Database Connection Issues

```bash
# Check PostgreSQL is running
sudo systemctl status postgresql

# Test connection
psql -U strapi -h localhost -d strapi

# Check database exists
psql -U postgres -l | grep strapi
```

#### � Node Module Issues

```bash
# Clean install
rm -rf node_modules package-lock.json
npm cache clean --force
npm install
```

#### 🏗️ Build Failures

```bash
# Remove build artifacts
rm -rf dist build .strapi

# Rebuild
npm run build
```

#### 📁 macOS Hidden Files (.\_\* files)

```bash
# Remove macOS metadata files that cause build errors
find . -type f -name "._*" -delete

# Then rebuild
rm -rf dist
npm run build
```

### Server Deployment Issues

#### npm install fails on server

```bash
# On server
cd /path/to/strapi
rm -rf node_modules package-lock.json
npm cache clean --force
npm install
```

#### PM2 not restarting

```bash
# Check PM2 status
pm2 list

# View logs
pm2 logs strapi --lines 100

# Restart
pm2 restart strapi

# Or delete and re-add
pm2 delete strapi
pm2 start npm --name "strapi" -- start
pm2 save
```

#### Uploads not syncing

See [UPLOADS-SYNC-GUIDE.md](UPLOADS-SYNC-GUIDE.md) for complete upload management instructions.

### Error Solutions

| Error                       | Solution                             |
| --------------------------- | ------------------------------------ |
| Port 1337 in use            | `lsof -ti:1337 \| xargs kill -9`     |
| Database connection failed  | Check PostgreSQL is running          |
| Module not found            | `rm -rf node_modules && npm install` |
| Permission denied           | `chmod +x *.sh`                      |
| Build fails with `._*` file | `find . -name "._*" -delete`         |

### Health Check Commands

```bash
# Check application status
pm2 status

# View logs
pm2 logs strapi

# Check database
psql -U strapi -d strapi -c "SELECT version();"

# Test API
curl http://localhost:1337/api/wholesale
```

## 🔐 Production Checklist

- [ ] Generate new secure keys for `.env`
- [ ] Set `NODE_ENV=production`
- [ ] Configure PostgreSQL with strong password
- [ ] Setup PM2 for process management
- [ ] Configure Nginx reverse proxy
- [ ] Setup SSL certificate (Let's Encrypt)
- [ ] Configure firewall (UFW)
- [ ] Setup database backups
- [ ] Configure monitoring & logging
- [ ] Setup CDN for media files (optional)

## 📚 Additional Resources

- **Strapi Documentation**: https://docs.strapi.io
- **Deployment Guide**: [DEPLOYMENT.md](DEPLOYMENT.md)
- **Quick Deploy**: [README-DEPLOYMENT-QUICK.md](README-DEPLOYMENT-QUICK.md)
- **Upload Sync**: [UPLOADS-SYNC-GUIDE.md](UPLOADS-SYNC-GUIDE.md)

## 📝 Project Notes

### Architecture

- **Frontend**: Next.js (separate repository)
- **Backend**: Strapi CMS (this repository)
- **Database**: PostgreSQL
- **Hosting**: VPS with PM2
- **Domain**: backend.jonwininternational.com

### Deployment Workflow

1. Make code changes locally
2. Test with `npm run develop`
3. Build: `npm run build`
4. Package: `./prepare-deploy.sh`
5. Deploy: `scp` to server or use `./update-server.sh`
6. On server: extract, `npm install`, `pm2 restart`

---

**💡 Quick Commands:**

```bash
# Development
npm run develop

# Build
npm run build

# Deploy
./prepare-deploy.sh
scp strapi-update.tar.gz user@server:/path/

# On Server
tar -xzf strapi-update.tar.gz
npm install
pm2 restart strapi
```

**🆘 Need Help?**

- Check [Troubleshooting](#troubleshooting)
- See [DEPLOYMENT.md](DEPLOYMENT.md) for detailed guide
- Check logs: `pm2 logs strapi`
