# Jowin Strapi CMS

A headless CMS built with Strapi 5.11.2, featuring Docker containerization, PostgreSQL database, and comprehensive data management tools for the Jowin application ecosystem.

## 📋 Table of Contents

- [Overview](#overview)
- [Tech Stack](#tech-stack)
- [Project Structure](#project-structure)
- [Quick Start](#quick-start)
- [Docker Configuration](#docker-configuration)
- [Database Management](#database-management)
- [Scripts & Automation](#scripts--automation)
- [Development](#development)
- [Production Deployment](#production-deployment)
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

- **Backend**: Strapi 5.11.2 (Node.js 18)
- **Database**: PostgreSQL 17 Alpine
- **Container**: Docker & Docker Compose
- **Language**: TypeScript
- **Plugins**:
  - CKEditor for rich text editing
  - Users & Permissions
  - Cloud integration
  - Advanced UUID
  - Slugify

## 📁 Project Structure

```
strapi/
├── 📄 README.md                 # This documentation
├── 🐳 Dockerfile               # Multi-stage Docker build
├── 🐳 docker-compose.yml       # Development orchestration
├── 📦 package.json             # Dependencies & scripts
├── ⚙️ tsconfig.json            # TypeScript configuration
├──
├── 📁 config/                  # Strapi configuration
│   ├── admin.ts               # Admin panel settings
│   ├── api.ts                 # API configuration
│   ├── database.ts            # Database connection
│   ├── middlewares.ts         # Request middlewares
│   ├── plugins.ts             # Plugin configuration
│   └── server.ts              # Server settings
├──
├── 📁 src/                     # Application source code
│   ├── index.ts               # Entry point
│   ├── admin/                 # Admin customizations
│   ├── api/                   # API routes & controllers
│   ├── components/            # Reusable components
│   └── extensions/            # Core extensions
├──
├── 📁 database/               # Database related files
│   ├── backups/               # Automated backups
│   └── migrations/            # Database dumps
│       └── jonwin_2025-08-25.dump
├──
├── 📁 scripts/                # Automation scripts
│   ├── backup-db.sh           # Database backup
│   ├── restore-db.sh          # Database restoration
│   ├── health-check.sh        # Service monitoring
│   └── restore-db-manual.sh   # Manual restoration
├──
├── 📁 public/                 # Static assets
│   ├── robots.txt
│   └── uploads/               # User uploads (379+ files)
└──
└── 📁 types/                  # TypeScript definitions
    └── generated/             # Auto-generated types
```

## 🚀 Quick Start

### Prerequisites

- Docker & Docker Compose
- Node.js 18+ (for local development)
- Git

### 1. Clone & Setup

```bash
git clone <repository-url>
cd strapi
chmod +x scripts/*.sh
```

### 2. Environment Configuration

```bash
# Copy environment template
cp .env.example .env.docker

# Edit environment variables (optional)
# Default values are configured for Docker development
```

### 3. Start Services

```bash
# Start all services (Database + Strapi + Adminer)
npm run docker:start
# or
docker-compose up -d
```

### 4. Restore Database (if needed)

```bash
# Restore from backup with production data
./scripts/restore-db.sh
```

### 5. Access Applications

- **Strapi Admin**: http://localhost:1337/admin
- **API Endpoint**: http://localhost:1337/api
- **Database Admin**: http://localhost:9090 (Adminer)

## 🐳 Docker Configuration

### Services Architecture

```mermaid
graph TB
    A[Strapi CMS<br/>Port: 1337] --> B[PostgreSQL DB<br/>Port: 5432]
    C[Adminer<br/>Port: 9090] --> B
    D[Volume: strapi-data] --> B
    E[Volume: uploads] --> A
    F[Network: Strapi] --> A
    F --> B
    F --> C
```

### Service Details

| Service           | Image               | Ports     | Purpose              |
| ----------------- | ------------------- | --------- | -------------------- |
| **strapi**        | Custom (Node.js 18) | 1337:1337 | Main CMS application |
| **strapiDB**      | postgres:17-alpine  | 5432:5432 | Database server      |
| **strapiAdminer** | adminer             | 9090:8080 | Database GUI         |

### Volumes

- `strapi-data`: PostgreSQL data persistence
- `uploads`: Media files storage
- Local mounts for development

### Networks

- `Strapi`: Isolated bridge network for service communication

## 💾 Database Management

### Current Data

- **Events**: 42 records
- **Partners**: 30 records
- **Stores**: 8 records
- **Files**: 379 media assets
- **Tables**: 71 total (includes Strapi system tables)

### Backup Operations

```bash
# Create timestamped backup
npm run docker:backup
# or
./scripts/backup-db.sh

# Backup location: ./database/backups/strapi_backup_YYYY-MM-DD_HH-MM-SS.dump
```

### Restoration Operations

```bash
# Automated restoration (recommended)
./scripts/restore-db.sh

# Manual restoration (advanced)
./scripts/restore-db-manual.sh
```

### Database Access

```bash
# CLI access to database
docker-compose exec strapiDB psql -U strapi -d strapi

# Check data counts
docker-compose exec strapiDB psql -U strapi -d strapi -c "
  SELECT 'events' as table_name, COUNT(*) as count FROM events
  UNION ALL SELECT 'partners', COUNT(*) FROM partners
  UNION ALL SELECT 'stores', COUNT(*) FROM stores
  UNION ALL SELECT 'files', COUNT(*) FROM files;
"
```

## 🔧 Scripts & Automation

### Available Scripts

| Script      | Command                  | Purpose                         |
| ----------- | ------------------------ | ------------------------------- |
| **Start**   | `npm run docker:start`   | Start all services              |
| **Stop**    | `npm run docker:stop`    | Stop all services               |
| **Restart** | `npm run docker:restart` | Restart services                |
| **Logs**    | `npm run docker:logs`    | View live logs                  |
| **Health**  | `npm run docker:health`  | Check service status            |
| **Backup**  | `npm run docker:backup`  | Create database backup          |
| **Clean**   | `npm run docker:clean`   | Remove all containers & volumes |

### Script Details

#### 🔄 Health Check (`scripts/health-check.sh`)

```bash
./scripts/health-check.sh
```

- Verifies all containers are running
- Shows service URLs
- Displays container status

#### 💾 Database Backup (`scripts/backup-db.sh`)

```bash
./scripts/backup-db.sh
```

- Creates PostgreSQL custom format dump
- Timestamped filenames
- Stored in `./database/backups/`

#### 🔄 Database Restoration (`scripts/restore-db.sh`)

```bash
./scripts/restore-db.sh
```

- **Smart restoration** with multiple methods:
  1. `pg_restore` (custom format)
  2. `psql` (plain text)
  3. `gunzip + psql` (compressed)
- Handles connection management
- Validates restoration success

## 💻 Development

### Local Development Setup

```bash
# Install dependencies
npm install

# Start in development mode (without Docker)
npm run develop

# Build for production
npm run build

# Start production server
npm start
```

### Environment Variables

Key configuration in `.env.docker`:

```bash
# Database
DATABASE_CLIENT=postgres
DATABASE_HOST=strapiDB
DATABASE_NAME=strapi
DATABASE_USERNAME=strapi
DATABASE_PASSWORD=strapi

# Security (change in production)
JWT_SECRET=your-super-secret-jwt-token
ADMIN_JWT_SECRET=your-super-secret-admin-jwt-token
APP_KEYS=your-app-keys
API_TOKEN_SALT=your-api-token-salt
```

### TypeScript Configuration

- Configured for Strapi 5.x
- Type generation for content types
- Development server with hot reload

## 🚀 Production Deployment

### Production Checklist

- [ ] Update security tokens in environment variables
- [ ] Configure SSL/TLS certificates
- [ ] Set up database backups automation
- [ ] Configure monitoring & logging
- [ ] Set up CDN for media files
- [ ] Configure email provider

### Production Docker Compose

Use `docker-compose.prod.yml` (if available) or modify environment:

```bash
NODE_ENV=production
DATABASE_SSL=true
# Add production database URL
DATABASE_URL=postgresql://user:pass@host:port/db
```

## 🔧 Troubleshooting

### Common Issues

#### 🐳 Docker Issues

```bash
# Check Docker system resources
docker system df

# Clean up disk space
docker system prune -f
docker volume prune -f

# Restart Docker daemon (macOS)
sudo service docker restart
```

#### 💾 Database Issues

```bash
# Check database connectivity
docker-compose exec strapiDB pg_isready -U strapi

# View database logs
docker-compose logs strapiDB

# Reset database (⚠️ DATA LOSS)
docker-compose down -v
docker-compose up -d
```

#### 📱 Application Issues

```bash
# Check application logs
docker-compose logs strapi

# Restart Strapi only
docker-compose restart strapi

# Rebuild Strapi container
docker-compose build strapi --no-cache
```

### Error Solutions

| Error                      | Solution                          |
| -------------------------- | --------------------------------- |
| Port 1337 in use           | `lsof -ti:1337 \| xargs kill -9`  |
| Database connection failed | Check PostgreSQL container status |
| Out of disk space          | Run `docker system prune -f`      |
| Permission denied          | `chmod +x scripts/*.sh`           |

### Health Check Commands

```bash
# Full system check
./scripts/health-check.sh

# Quick status
docker-compose ps

# Resource usage
docker stats

# Network connectivity
docker-compose exec strapi ping strapiDB
```

## 📝 API Documentation

### Content Types

- **Events**: `/api/events`
- **Partners**: `/api/partners`
- **Stores**: `/api/stores`
- **Files**: `/api/upload/files`

### Authentication

- JWT tokens required for protected endpoints
- Admin panel: `/admin`
- User registration: `/api/auth/local/register`

## 🤝 Contributing

1. Create feature branch
2. Test with Docker environment
3. Update documentation if needed
4. Submit pull request

## 📄 License

Private project for Jowin application ecosystem.

---

**💡 Quick Reference:**

- Start: `docker-compose up -d`
- Backup: `./scripts/backup-db.sh`
- Restore: `./scripts/restore-db.sh`
- Health: `./scripts/health-check.sh`
- Admin: http://localhost:1337/admin
- Database: http://localhost:9090

**🆘 Need Help?** Check the [Troubleshooting](#troubleshooting) section or run `./scripts/health-check.sh`
