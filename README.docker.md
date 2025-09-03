# Jowin Strapi Docker Setup

## 📁 Docker Files Overview

- **`Dockerfile`** - Strapi application container configuration (Node.js 18)
- **`docker-compose.yml`** - Production services orchestration
- **`docker-compose.override.yml`** - Development overrides
- **`.env.docker`** - Environment variables for Docker
- **`.dockerignore`** - Files to exclude from Docker contextepository contains Docker configuration for running the Jowin Strapi application with PostgreSQL database.

## 🚀 Quick Start

### Prerequisites

- Docker and Docker Compose installed
- macOS/Linux environment (for shell scripts)

### 1. Initial Setup

```bash
# Run the setup script (this will generate secrets and start services)
./setup-docker.sh
```

### 2. Restore Database

```bash
# Restore your database backup (jonwin_2025-08-25.dump)
./scripts/restore-db.sh
```

### 3. Access Application

- **Strapi Admin Panel**: http://localhost:1337/admin
- **Strapi API**: http://localhost:1337/api
- **Database Admin (Adminer)**: http://localhost:9090
- **Database Direct Connection**: localhost:5432

## � Docker Files Overview

- **`Dockerfile`** - Strapi application container configuration
- **`docker-compose.yml`** - Production services orchestration
- **`docker-compose.override.yml`** - Development overrides
- **`.env.docker`** - Environment variables for Docker
- **`.dockerignore`** - Files to exclude from Docker context

## �️ Available Commands

All commands are defined in `package.json` for convenience:

```bash
# Container Management
npm run docker:setup      # Initial setup with secret generation
npm run docker:start      # Start all services
npm run docker:stop       # Stop all services
npm run docker:restart    # Restart all services
npm run docker:clean      # Stop and remove containers + volumes

# Monitoring & Maintenance
npm run docker:logs       # View container logs
npm run docker:health     # Check service health
npm run docker:backup     # Create database backup
```

## 🔧 Manual Commands

If you prefer using Docker Compose directly:

```bash
# Start services
docker-compose up -d

# Stop services
docker-compose down

# View logs
docker-compose logs -f

# Rebuild images
docker-compose build --no-cache
```

## �️ Database Management

### Restore Database

```bash
./scripts/restore-db.sh
```

### Create Backup

```bash
./scripts/backup-db.sh
```

### Connect to Database

```bash
# Using psql
docker exec -it strapi-strapiDB-1 psql -U strapi -d strapi

# Using Adminer (Web UI)
# Go to http://localhost:9090
# Server: strapiDB
# Username: strapi
# Password: strapi
# Database: strapi
```

## � Security Configuration

The setup script automatically generates secure secrets for:

- `APP_KEYS`
- `API_TOKEN_SALT`
- `ADMIN_JWT_SECRET`
- `TRANSFER_TOKEN_SALT`
- `JWT_SECRET`

These are stored in `.env.docker`. **Keep this file secure and never commit it to version control.**

## 🌍 Environment Configurations

### Development (default)

- Hot reload enabled
- Source code mounted as volumes
- Development database settings

### Production

```bash
# Set NODE_ENV to production in .env.docker
NODE_ENV=production

# Restart services
npm run docker:restart
```

## 📊 Monitoring

### Health Check

```bash
npm run docker:health
```

### View Logs

```bash
# All services
npm run docker:logs

# Specific service
docker-compose logs -f strapi
docker-compose logs -f strapiDB
```

## 🔧 Troubleshooting

### Services Won't Start

1. Check if ports are available:

   ```bash
   lsof -i :1337  # Strapi
   lsof -i :5432  # PostgreSQL
   lsof -i :9090  # Adminer
   ```

2. Check Docker status:
   ```bash
   docker ps
   docker-compose ps
   ```

### Database Connection Issues

1. Ensure database container is running:

   ```bash
   docker ps | grep strapiDB
   ```

2. Check database logs:
   ```bash
   docker-compose logs strapiDB
   ```

### Reset Everything

```bash
npm run docker:clean
npm run docker:setup
./scripts/restore-db.sh
```

## 🏗️ Architecture

```
┌─────────────────┐    ┌──────────────────┐    ┌─────────────────┐
│                 │    │                  │    │                 │
│   Strapi App    │────│   PostgreSQL     │    │    Adminer      │
│   (Port 1337)   │    │   (Port 5432)    │    │   (Port 9090)   │
│                 │    │                  │    │                 │
└─────────────────┘    └──────────────────┘    └─────────────────┘
```

## 📝 File Structure

```
strapi/
├── docker-compose.yml          # Main orchestration file
├── docker-compose.override.yml # Development overrides
├── Dockerfile                  # Strapi app container
├── .env.docker                 # Environment variables
├── .dockerignore              # Docker ignore file
├── setup-docker.sh            # Initial setup script
├── scripts/
│   ├── restore-db.sh          # Database restoration
│   ├── backup-db.sh           # Database backup
│   └── health-check.sh        # Health monitoring
└── database/
    └── migrations/
        └── jonwin_2025-08-25.dump  # Your database backup
```

## 🤝 Contributing

When making changes to the Docker configuration:

1. Test with development environment first
2. Update documentation if needed
3. Ensure scripts remain executable
4. Test database restoration process

## 📞 Support

For issues with the Docker setup:

1. Check the troubleshooting section above
2. Run health check: `npm run docker:health`
3. Check logs: `npm run docker:logs`
4. Try clean restart: `npm run docker:clean && npm run docker:setup`

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
