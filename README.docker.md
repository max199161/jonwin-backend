# Docker Development Setup for Strapi

This guide will help you set up a Docker environment for your Strapi application with PostgreSQL 17 database restoration and data persistence.

## Prerequisites

- Docker and Docker Compose installed
- Your database dump file: `database/migrations/jonwin_2025-08-25.dump` (PostgreSQL 17.5 format)

## ⚡ Quick Start

### One-Command Setup

```bash
./setup-docker.sh
```

This single command will:

- Create environment file
- Build Docker containers
- Start all services
- Restore your database automatically
- Verify everything is working

## 📋 Available Scripts

### 🚀 `./setup-docker.sh`

**Purpose:** Complete Docker environment setup from scratch

**What it does:**

- Checks Docker installation
- Creates `.env` file from template
- Creates necessary directories (`database/backups`, `public/uploads`)
- Makes all scripts executable
- Stops any existing containers
- Builds containers with fresh cache
- Starts all services
- Waits for services to be ready
- Shows access URLs and usage tips

### 🔄 `./scripts/reset-and-restore.sh`

**Purpose:** Complete database reset and restoration

**What it does:**

- Stops all Docker services
- Removes only the database volume (keeps uploads)
- Rebuilds and starts services
- Waits for restoration to complete
- Shows restoration logs
- Verifies database content
- Displays final status

### 💾 `./scripts/backup-db.sh`

**Purpose:** Create database backup

**What it does:**

- Creates timestamped backup file in `database/backups/`
- Uses `pg_dump` with custom format
- Connects to running PostgreSQL container
- Includes all data, schema, and sequences
- Provides backup confirmation

### 🔧 `./scripts/restore-db.sh`

**Purpose:** Restore database from dump (runs automatically)

**What it does:**

- Waits for PostgreSQL to be ready
- Checks if database already has data (skips if > 5 tables)
- Drops and recreates database for clean restore
- Restores using `pg_restore` with PostgreSQL 17 compatibility
- Handles both structure and data restoration
- Verifies restoration success
- Shows table count and sample data

### 🏥 `./scripts/health-check.sh`

**Purpose:** System health verification

**What it does:**

- Shows Docker service status
- Displays container resource usage
- Shows Docker volume usage
- Tests Strapi health endpoint
- Tests PostgreSQL connection
- Shows recent logs from all services
- Provides system overview

## 🛠️ Manual Commands

### Environment Setup

Copy the environment example file:

```bash
cp .env.example .env
```

Update the `.env` file with your specific configuration if needed.

### Development Environment

Start the development environment:

```bash
docker-compose up -d
```

This will:

- Start PostgreSQL 17 database
- Restore your database dump automatically
- Start Strapi in development mode with hot reload
- Start PgAdmin for database management (optional)

### Production Environment

For production deployment:

```bash
docker-compose -f docker-compose.prod.yml up -d
```

## 🌐 Access Points

- **Strapi Admin**: http://localhost:1337/admin
- **Strapi API**: http://localhost:1337/api
- **Strapi Health**: http://localhost:1337/\_health
- **PgAdmin**: http://localhost:5050 (admin@strapi.local / admin)
- **PostgreSQL**: localhost:5432 (strapi/strapi)

## 💾 Data Persistence

Your data is automatically persisted using Docker volumes:

- **Database data**: `postgres_data` volume (PostgreSQL 17 data)
- **Uploaded files**: `uploads_data` volume (Strapi media files)

**Important:** Even if you delete containers with `docker-compose down`, your data remains safe in these volumes.

## 🗃️ Database Management

### Automatic Restore

The database dump (`jonwin_2025-08-25.dump`) will be automatically restored when you first start the containers. The restore script:

- Checks if database already has significant data (>5 tables)
- Skips restoration if data exists
- Uses PostgreSQL 17 for full compatibility
- Restores complete data structure and content

### Manual Database Operations

**Create Backup:**

```bash
./scripts/backup-db.sh
```

Saves timestamped backup in `database/backups/`

**Force Database Reset:**

```bash
./scripts/reset-and-restore.sh
```

Completely resets database and restores from dump

**Check Database Status:**

```bash
docker-compose exec postgres psql -U strapi -d strapi -c "SELECT schemaname, relname, n_tup_ins FROM pg_stat_user_tables WHERE schemaname = 'public' ORDER BY n_tup_ins DESC LIMIT 10;"
```

**Manual Restore (if needed):**

```bash
docker-compose exec postgres pg_restore -U strapi -d strapi -v --clean --if-exists --no-owner --no-privileges /docker-entrypoint-initdb.d/jonwin_2025-08-25.dump
```

## 🐳 Container Management

### Start services

```bash
docker-compose up -d
```

### Stop services

```bash
docker-compose down
```

### Stop services and remove containers (data persists)

```bash
docker-compose down --remove-orphans
```

### View logs

```bash
docker-compose logs -f strapi
docker-compose logs -f postgres
```

### Rebuild containers

```bash
docker-compose down
docker-compose build --no-cache
docker-compose up -d
```

### Health Check

```bash
./scripts/health-check.sh
```

## 📦 Volume Management

### List volumes

```bash
docker volume ls
```

### Backup volumes to files

```bash
# Backup database volume
docker run --rm -v strapi_postgres_data:/data -v $(pwd):/backup alpine tar czf /backup/postgres_backup.tar.gz -C /data .

# Backup uploads volume
docker run --rm -v strapi_uploads_data:/data -v $(pwd):/backup alpine tar czf /backup/uploads_backup.tar.gz -C /data .
```

### Restore volumes from files

```bash
# Restore database volume
docker run --rm -v strapi_postgres_data:/data -v $(pwd):/backup alpine tar xzf /backup/postgres_backup.tar.gz -C /data

# Restore uploads volume
docker run --rm -v strapi_uploads_data:/data -v $(pwd):/backup alpine tar xzf /backup/uploads_backup.tar.gz -C /data
```

### Remove volumes (⚠️ WARNING: This will delete all data)

```bash
docker-compose down -v
```

## 🔄 Development Workflow

1. **Start development**: `./setup-docker.sh` (first time) or `docker-compose up -d`
2. **Make changes**: Edit your code normally
3. **View changes**: Hot reload is enabled in development mode
4. **Update content**: Use Strapi admin panel at http://localhost:1337/admin
5. **Backup data**: Run `./scripts/backup-db.sh` periodically
6. **Check health**: Run `./scripts/health-check.sh`
7. **Stop development**: `docker-compose down`

## 🧪 Testing and Verification

### Verify Database Content

```bash
# Check table count
docker-compose exec postgres psql -U strapi -d strapi -c "SELECT count(*) FROM information_schema.tables WHERE table_schema = 'public';"

# Check data in key tables
docker-compose exec postgres psql -U strapi -d strapi -c "SELECT relname, n_tup_ins FROM pg_stat_user_tables WHERE schemaname = 'public' AND n_tup_ins > 0 ORDER BY n_tup_ins DESC;"

# Check specific content (example)
docker-compose exec postgres psql -U strapi -d strapi -c "SELECT id, name FROM stores LIMIT 5;"
```

### Test API Endpoints

```bash
# Health check
curl http://localhost:1337/_health

# API example (replace with your actual endpoints)
curl http://localhost:1337/api/stores
curl http://localhost:1337/api/events
```

## 🛠️ Troubleshooting

### Database connection issues

```bash
# Check if PostgreSQL is running
docker-compose ps postgres

# Check PostgreSQL logs
docker-compose logs postgres

# Test database connection
docker-compose exec postgres psql -U strapi -d strapi -c "SELECT version();"

# Check PostgreSQL 17 version
docker-compose exec postgres psql -U strapi -d strapi -c "SHOW server_version;"
```

### Strapi connection issues

```bash
# Check Strapi logs
docker-compose logs strapi

# Restart Strapi
docker-compose restart strapi

# Check Strapi process inside container
docker-compose exec strapi ps aux
```

### Volume issues

```bash
# Check volume usage
docker system df

# Inspect volume contents
docker run --rm -v strapi_postgres_data:/data alpine ls -la /data
docker run --rm -v strapi_uploads_data:/data alpine ls -la /data
```

### Reset everything (⚠️ WARNING: Deletes all data)

```bash
./scripts/reset-and-restore.sh
# OR completely from scratch:
docker-compose down -v
docker system prune -f
./setup-docker.sh
```

## 📂 File Structure

```
strapi/
├── docker-compose.yml              # Development environment
├── docker-compose.prod.yml         # Production environment
├── Dockerfile                      # Production Dockerfile
├── Dockerfile.dev                  # Development Dockerfile
├── .dockerignore                   # Docker ignore rules
├── .env.example                    # Environment template
├── .env                           # Environment variables (created)
├── setup-docker.sh               # One-command setup script
├── scripts/
│   ├── restore-db.sh             # Database restoration script
│   ├── backup-db.sh              # Database backup script
│   ├── reset-and-restore.sh      # Complete reset and restore
│   └── health-check.sh           # System health verification
├── database/
│   ├── migrations/
│   │   └── jonwin_2025-08-25.dump  # PostgreSQL 17.5 database dump
│   └── backups/                    # Database backups (created)
├── public/
│   └── uploads/                    # Media files (persisted)
└── README.docker.md               # This documentation
```

## 🔧 Environment Variables

Key environment variables in `.env`:

```bash
# Database Configuration
DATABASE_CLIENT=postgres
DATABASE_HOST=postgres
DATABASE_PORT=5432
DATABASE_NAME=strapi
DATABASE_USERNAME=strapi
DATABASE_PASSWORD=strapi

# Application Configuration
NODE_ENV=development
HOST=0.0.0.0
PORT=1337

# Strapi Configuration
APP_KEYS="your,app,keys,here"
API_TOKEN_SALT=your_api_token_salt
ADMIN_JWT_SECRET=your_admin_jwt_secret
TRANSFER_TOKEN_SALT=your_transfer_token_salt
JWT_SECRET=your_jwt_secret
```

## 🚀 Deployment Notes

### For Production:

1. Use `docker-compose.prod.yml`
2. Update environment variables with production values
3. Set strong secrets in `.env`
4. Configure proper backup strategy
5. Set up monitoring and logging
6. Use HTTPS in production

### For Development:

1. Use `docker-compose.yml` (default)
2. Hot reload is enabled for code changes
3. Database and uploads are persisted
4. PgAdmin is available for database management
5. All development tools are included

---

## 📝 Summary

This Docker setup provides:

- ✅ **Complete database restoration** from PostgreSQL 17.5 dump
- ✅ **Data persistence** across container restarts/deletions
- ✅ **Development hot reload** for code changes
- ✅ **Automated backup system** with timestamped files
- ✅ **Health monitoring** and verification tools
- ✅ **One-command setup** for new environments
- ✅ **Production-ready** configuration available
- ✅ **Database management** tools (PgAdmin)
- ✅ **Volume management** for data portability

Your Strapi application is now fully containerized with persistent data storage! 🎉
