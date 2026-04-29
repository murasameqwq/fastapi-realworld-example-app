# SLD Summary

Generated: 2026-04-29

## System Identity

| Attribute | Value |
|-----------|-------|
| **Name** | Conduit (FastAPI RealWorld Example App) |
| **Type** | RESTful API Backend Service |
| **Version** | 0.0.0 (development) |
| **Architecture Style** | Layered Architecture (3-tier) |
| **Runtime** | Python 3.11+, FastAPI, uvicorn ASGI |
| **Database** | PostgreSQL 12+ via asyncpg |

## System Overview

Conduit is a Medium-like blogging platform backend implementing the complete RealWorld API specification. It provides a production-quality REST API for user management, content publishing, social discovery, and engagement. The system serves dual purposes: a functional API backend and a reference implementation demonstrating FastAPI best practices with async I/O, typed models, and clean layered architecture.

**Target Users**: API consumers (frontend applications), developers studying FastAPI patterns, and RealWorld framework evaluators.

**Deployment Model**: Docker container with Poetry dependency management; configurable via `.env` file; deployed as async ASGI service behind optional load balancer.

## System Architecture Summary

| Layer | Responsibility | Key Technologies |
|-------|---------------|-----------------|
| **Presentation** | HTTP routing, auth, validation, response formatting | FastAPI, Pydantic, PyJWT |
| **Domain** | Entity models, JWT lifecycle, password security, configuration | Pydantic, bcrypt, passlib |
| **Infrastructure** | Database CRUD, SQL queries, schema migrations | asyncpg, aiosql, pypika, Alembic |

**Data Flow**: HTTP Client → Presentation Layer (route + auth) → Domain Layer (entities + services) → Infrastructure Layer (repositories + SQL) → PostgreSQL → enriched domain models → serialized JSON response.

## System Capabilities

1. **User Account Management**: Registration, login, profile management with JWT authentication
2. **Content Publishing**: Article CRUD with automatic slug generation, tagging, and authorship
3. **Social Discovery**: Profile viewing, follow/unfollow, personalized article feed
4. **Engagement**: Article commenting, favoriting with count tracking
5. **Content Discovery**: Filtered/paginated article listing, tag browsing

## System Interfaces

| Interface | Protocol | Purpose |
|-----------|----------|---------|
| REST API | HTTP/JSON | Primary client interface (15+ endpoints) |
| OpenAPI/Swagger | HTTP/HTML | Interactive API documentation |
| PostgreSQL | TCP (asyncpg) | Persistent data storage |
| CLI (Alembic) | Command-line | Database schema migration |
| CLI (pytest) | Command-line | Test execution and coverage |

## Technology Stack

| Category | Technology |
|----------|-----------|
| Language | Python 3.11+ |
| Web Framework | FastAPI (async) |
| ASGI Server | uvicorn |
| Database | PostgreSQL 12+ |
| DB Driver | asyncpg |
| SQL Management | aiosql (static) + pypika (dynamic) |
| Migrations | Alembic + SQLAlchemy DDL |
| Validation | Pydantic |
| Authentication | PyJWT (HS256) |
| Password Security | bcrypt + passlib |
| Logging | Loguru |
| Package Manager | Poetry |
| Testing | pytest + httpx + asgi_lifespan |
| Code Quality | flake8, black, isort, mypy |
| Containerization | Docker + docker-compose |

## Quality Attributes

| Attribute | Assessment |
|-----------|-----------|
| **Performance** | Async I/O throughout; connection pooling; bottleneck is DB query latency |
| **Scalability** | Stateless design enables horizontal scaling; DB is single bottleneck |
| **Maintainability** | Clear layer boundaries; repository pattern; self-documenting schemas |
| **Security** | JWT auth, bcrypt passwords, parameterized SQL queries, input validation |
| **Testability** | 100% coverage threshold; DI enables mocking; fake asyncpg pool for unit tests |
| **Extensibility** | Adding entities follows consistent 3-layer pattern |

## Deployment Model

- **Packaging**: Python source package with Poetry dependency resolution
- **Container**: Docker image (Python base, poetry install, uvicorn entrypoint)
- **Configuration**: `.env` file with APP_ENV, DATABASE_URL, SECRET_KEY
- **Migration**: `alembic upgrade head` before application start
- **Scaling**: Multiple uvicorn workers behind load balancer; each worker has independent connection pool

## System Constraints

- Python 3.11+ required (async features, pydantic compatibility)
- PostgreSQL 12+ required (asyncpg compatibility)
- No built-in rate limiting or caching layer
- JWT tokens cannot be invalidated server-side (no refresh token mechanism)
- N+1 query pattern in article listing limits throughput at scale
- Single database instance; no read replica support

## System Lifecycle

```
[Build] → poetry install → [Configure] → .env setup → [Migrate] → alembic upgrade
  → [Start] → uvicorn launch → [Serve] → handle requests → [Shutdown] → graceful drain
```

Configuration changes require restart. Schema changes require migration + restart. No hot-reload in production.

## Aggregation Summary

| Stage | Input | Output | Ratio |
|-------|-------|--------|-------|
| **Scan** | 194 files | 73 source files, 18 modules | - |
| **ILD** | 18 modules | 11 documented modules | 18:11 |
| **DLD** | 11 modules | 4 subsystems | 2.75:1 |
| **HLD** | 4 subsystems | 3 components | 1.33:1 |
| **SLD** | 3 components | 1 system design | 3:1 (final) |

## Key Design Decisions

| Decision | Rationale | Trade-off |
|----------|-----------|-----------|
| **Layered Architecture** | Clear boundaries, independent testing, simple data flow | Verbosity; data passes through multiple layers |
| **Hybrid Query Strategy** | aiosql for maintainability + pypika for flexibility | Two paradigms to learn |
| **Stateless Design** | Horizontal scaling without session coordination | No server-side token invalidation |
| **Repository Pattern** | Abstracts data access, enables testing | Boilerplate for simple CRUD |
| **No ORM** | Full SQL control, predictable queries | Manual mapping, more code |

## System Value Proposition

Conduit delivers a complete, production-ready blogging API with exemplary code architecture. It demonstrates that FastAPI can support complex, real-world applications with async I/O, typed models, and clean separation of concerns. The layered architecture makes it an ideal teaching tool for understanding modern Python web development patterns.

## Future Enhancements

- **Caching**: Redis or in-memory cache for frequently accessed data (articles, tags)
- **Rate Limiting**: Request throttling to prevent abuse
- **Refresh Tokens**: Server-side token invalidation support
- **Read Replicas**: Database read scaling via replica connections
- **Full-Text Search**: PostgreSQL full-text search or external search engine integration
- **Media Upload**: Article image attachment support
- **Email Notifications**: Comment replies, follow notifications
- **API Versioning**: `/api/v2/` prefix for breaking changes
