# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Overview

This is a FastAPI implementation of the RealWorld backend ("Conduit" - a Medium-like blog platform). It implements CRUD for articles, comments, user authentication, profiles, and tags. The database is PostgreSQL, accessed via asyncpg with raw SQL queries managed by aiosql.

## Quickstart

```bash
# Install dependencies
poetry install
poetry shell

# Set up .env (or copy .env.example)
# Required: DATABASE_URL, SECRET_KEY, APP_ENV

# Run migrations
alembic upgrade head

# Start dev server
uvicorn app.main:app --reload
```

## Common Commands

| Task | Command |
|------|---------|
| Install deps | `poetry install` |
| Run dev server | `uvicorn app.main:app --reload` |
| Run all tests | `pytest` |
| Run single test | `pytest tests/path/to/test.py::test_name` |
| Lint (flake8) | `flake8 app tests` |
| Format (black) | `black app tests` |
| Sort imports | `isort app tests` |
| Type check | `mypy app` |
| DB migrations | `alembic upgrade head` / `alembic revision -m "message"` |

Tests require a running PostgreSQL database and `DATABASE_URL` set. The test environment (`APP_ENV=test`) uses `tests/conftest.py` fixtures with a fake asyncpg pool.

## Architecture

### Layered structure

```
app/
├── api/
│   ├── routes/          # FastAPI route definitions (endpoint handlers)
│   └── dependencies/    # FastAPI DI providers (auth, db, resource lookups)
├── core/
│   ├── settings/        # Pydantic settings per env (dev/prod/test)
│   ├── config.py        # Settings factory (selects by APP_ENV)
│   ├── events.py        # startup/shutdown handlers
│   └── logging.py       # Loguru interceptor for uvicorn
├── db/
│   ├── repositories/    # Data access layer, one per entity
│   ├── queries/
│   │   ├── sql/         # Raw SQL files (aiosql)
│   │   ├── queries.py   # aiosql loader
│   │   └── tables.py    # pypika typed table definitions
│   └── events.py        # asyncpg pool connect/disconnect
├── models/
│   ├── domain/          # Domain models (internal, used by repos/services)
│   └── schemas/         # Pydantic schemas (request/response, API-facing)
├── services/            # Business logic (JWT, auth, slug generation)
└── resources/
    └── strings.py       # Centralized string constants
```

### Key patterns

**Settings**: Three environment profiles (`dev`, `prod`, `test`) selected via `APP_ENV` env var. `app/core/config.py` uses `get_app_settings()` (cached) to return the correct config class.

**Database**: Uses an `asyncpg` connection pool stored on `app.state.pool`. Repositories are instantiated per-request via FastAPI's dependency injection (`get_repository(RepoType)`). Each repository receives a single `asyncpg.Connection` acquired from the pool.

**SQL queries**: Two approaches coexist:
- **aiosql** — SQL lives in `.sql` files under `app/db/queries/sql/`, loaded by `aiosql` into callable Python functions via `app/db/queries/queries.py`.
- **pypika** — Dynamic query building (e.g., article filtering) uses typed `TypedTable` classes in `app/db/queries/tables.py`.

**Domain vs Schema models**: Domain models (`models/domain/`) represent internal entities with full data. Schema models (`models/schemas/`) are Pydantic models for API request/response payloads, inheriting from `RWSchema` which sets `orm_mode = True`.

**Repositories**: Each repository extends `BaseRepository` (which holds an `asyncpg.Connection`). Repositories encapsulate all database access — routes never touch SQL directly. Repositories may delegate to sibling repositories (e.g., `ArticlesRepository` uses `ProfilesRepository` and `TagsRepository`).

**Dependencies**: Common DI providers in `app/api/dependencies/`:
- `get_current_user_authorizer()` — extracts JWT from `Authorization` header, returns `User` or raises 401/403.
- `get_repository(RepoType)` — acquires a db connection and instantiates the repository.
- Entity-specific deps (e.g., `get_article_by_slug_from_path`) validate path parameters and raise 404 if not found.

**Authentication**: JWT-based. Tokens are sent as `Token <jwt>` in the `Authorization` header. The secret key is set via `SECRET_KEY` env var. Passwords are hashed with bcrypt via passlib.

### Routes

All routes are mounted under `/api` prefix (configurable via `api_prefix`):

- `POST /api/users` — Register
- `POST /api/users/login` — Login
- `GET /api/user` — Get current user
- `PUT /api/user` — Update current user
- `GET /api/profiles/{username}` — Get profile
- `POST /api/profiles/{username}/follow` — Follow user
- `DELETE /api/profiles/{username}/follow` — Unfollow user
- `GET /api/articles` — List articles (with filters: tag, author, favorited)
- `POST /api/articles` — Create article
- `GET /api/articles/{slug}` — Get article
- `PUT /api/articles/{slug}` — Update article
- `DELETE /api/articles/{slug}` — Delete article
- `GET /api/articles/{slug}/comments` — Get comments
- `POST /api/articles/{slug}/comments` — Add comment
- `DELETE /api/articles/{slug}/comments/{id}` — Delete comment
- `GET /api/tags` — Get all tags
- `GET /api/articles/feed` — Feed for followed authors

### Testing

Tests use `pytest` with `httpx.AsyncClient` and `asgi_lifespan.LifespanManager`. Fixtures in `tests/conftest.py` provide `client`, `authorized_client`, `test_user`, and `test_article`. Run with `pytest` (configured in `pyproject.toml` with coverage at 100% threshold).
