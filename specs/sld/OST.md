# OST - Operational Specification: Conduit (RealWorld API)

## System Overview

**Name**: Conduit (FastAPI RealWorld Example App)
**Type**: RESTful API backend service
**Version**: 0.0.0 (development)
**Architecture**: Layered architecture (Presentation → Domain → Infrastructure)
**Runtime**: Python 3.11+, FastAPI, uvicorn ASGI server

Conduit is a Medium-like blogging platform backend implementing the RealWorld API specification. It provides CRUD operations for articles, comments, user authentication, user profiles, social following, and tag discovery. The system is designed as a reference implementation demonstrating FastAPI best practices with async PostgreSQL access.

## External Interfaces

### HTTP REST API (Primary Interface)
Mounted at `/api` prefix. All endpoints return JSON with camelCase field names and ISO 8601 datetimes with `Z` suffix.

| Resource | Methods | Endpoint | Auth |
|----------|---------|----------|------|
| Users | POST | `/api/users` (register) | No |
| Users | POST | `/api/users/login` (login) | No |
| Users | GET/PUT | `/api/user` (current user) | Required |
| Profiles | GET | `/api/profiles/{username}` | Optional |
| Profiles | POST/DELETE | `/api/profiles/{username}/follow` | Required |
| Articles | GET/POST | `/api/articles` | Optional/Required |
| Articles | GET/PUT/DELETE | `/api/articles/{slug}` | Optional/Required/Required |
| Feed | GET | `/api/articles/feed` | Required |
| Favorites | POST/DELETE | `/api/articles/{slug}/favorite` | Required |
| Comments | GET/POST | `/api/articles/{slug}/comments` | Optional/Required |
| Comments | DELETE | `/api/articles/{slug}/comments/{id}` | Required |
| Tags | GET | `/api/tags` | No |

### OpenAPI Documentation
Auto-generated interactive API documentation at `/docs` (Swagger UI) and `/redoc` (ReDoc). OpenAPI JSON schema at `/openapi.json`.

### Database Interface
PostgreSQL connection via asyncpg connection pool. Schema managed by Alembic migrations.

### Authentication Protocol
- Header: `Authorization: Token <jwt>`
- Algorithm: HS256
- Expiry: 7 days
- No refresh token mechanism (re-authentication required on expiry)

## Deployment Architecture

### Packaging
- **Source**: Python package deployed as source code with Poetry dependency management
- **Container**: Docker image built from `Dockerfile` (Python base image, poetry install, uvicorn entrypoint)
- **Compose**: `docker-compose.yml` for local development with PostgreSQL service

### Runtime Environment
- **ASGI Server**: uvicorn (async mode)
- **Process Model**: Single process with async event loop; can scale to multiple workers
- **Port**: Configurable (default 8000)
- **Environment Variables**: `APP_ENV` (dev/prod/test), `DATABASE_URL`, `SECRET_KEY`

### Installation
1. `poetry install` (installs all dependencies)
2. `poetry shell` (activates virtual environment)
3. Configure `.env` with `DATABASE_URL`, `SECRET_KEY`, `APP_ENV`
4. `alembic upgrade head` (applies database migrations)
5. `uvicorn app.main:app --reload` (starts dev server)

## External Dependencies

| Dependency | Purpose | Version Management |
|------------|---------|-------------------|
| FastAPI | Web framework | pyproject.toml |
| asyncpg | PostgreSQL async driver | pyproject.toml |
| aiosql | SQL file loader | pyproject.toml |
| pypika | Dynamic SQL builder | pyproject.toml |
| Pydantic | Validation & serialization | pyproject.toml |
| PyJWT | JWT token management | pyproject.toml |
| bcrypt/passlib | Password hashing | pyproject.toml |
| Alembic | Database migrations | pyproject.toml |
| Loguru | Logging | pyproject.toml |
| Poetry | Package management | poetry.lock |
| PostgreSQL 12+ | Database | External service |

## Quality of Service

- **Performance**: Async I/O enables concurrent request handling; connection pooling (5-10 per worker) prevents database overload; response time dominated by database query latency
- **Scalability**: Stateless design enables horizontal scaling behind load balancer; each worker independent; database is the scaling bottleneck
- **Availability**: No built-in high availability; depends on PostgreSQL availability; no caching layer for offline operation
- **Throughput**: Limited by connection pool size and database query performance; N+1 query pattern in article listing is the primary throughput constraint

## Security & Compliance

- **Authentication**: JWT-based with HS256 signing; secret key stored as `SecretStr` to prevent log leakage
- **Authorization**: Per-endpoint auth requirements (required/optional); resource ownership enforced for write operations
- **Password Security**: bcrypt hashing with per-user salt; passwords never returned in API responses
- **Input Validation**: Pydantic schema validation on all request bodies; SQL injection prevented by parameterized queries (aiosql/pypika)
- **CORS**: Configurable via settings; default permissive (`allow_origins=["*"]`)
- **No rate limiting**: No built-in request throttling or brute-force protection

## Monitoring & Observability

- **Logging**: Loguru unified logging with uvicorn access log interception; output to stderr at configurable level (DEBUG for dev/test, INFO for prod)
- **Error Responses**: Centralized error handlers return consistent JSON error format with localized messages
- **Health Check**: No dedicated health endpoint; service availability inferred from HTTP responsiveness
- **OpenAPI**: Auto-generated API schema enables automated API testing and client generation
