# FST - Functional Specification: Data Access Subsystem

## Capabilities

- **Article Management**: Create, read, update, delete articles with automatic tag linking, slug-based lookup, filtered/paginated listing by tag/author/favorited status, and feed generation from followed authors
- **Comment Management**: Create and retrieve comments for articles, delete comments with authorship verification
- **User Management**: Register users with bcrypt-hashed passwords, update profiles, lookup by email or username
- **Profile & Social**: Retrieve public profiles with follow status, follow/unfollow other users with self-follow prevention
- **Tag Management**: List all tags, auto-create missing tags during article creation
- **Favorite Tracking**: Add/remove articles from user favorites, track favorite counts, check per-user favorite status
- **Schema Management**: Define and evolve database schema with reversible Alembic migrations, including automatic timestamp triggers

## I/O Boundary

```
                    Data Access Subsystem
                    ┌─────────────────────┐
  Repositories  →   │  Article/User/Comment│  →  Domain Models
  (keyword args)    │  CRUD Operations     │     (Article, User, etc.)
                    │                     │
                    │  SQL Files (.sql)    │  →  asyncpg Records
                    │  TypedTables         │     (raw rows)
                    │                     │
  Migration cmd →   │  Alembic DDL ops     │  →  PostgreSQL schema
                    └─────────────────────┘
```

**Inputs**: Keyword arguments (slugs, usernames, emails, domain model instances), Alembic CLI commands
**Outputs**: Domain model instances (Article, Comment, User, Profile), lists thereof, or None
**External I/O**: PostgreSQL database (reads/writes), `.sql` files (static queries)

## Side Effects

- **Database writes**: All create/update/delete methods modify PostgreSQL state
- **Schema changes**: Migration scripts create/drop tables, functions, and triggers
- **Transactional**: Multi-step operations (article+tags, follow operations) use database transactions
- **Auto-creation**: Tags are implicitly created during article creation if they don't exist

## Boundaries

**Responsible for**:
- All database access and query execution
- Mapping raw database records to enriched domain models
- Building dynamic SQL queries with pypika for filtering
- Defining and evolving the database schema
- Ensuring data integrity through transactions and foreign keys

**Not responsible for**:
- Request validation (Domain Model subsystem)
- API serialization (API Interface subsystem)
- Authentication/authorization (Core Services / API Interface subsystems)
- Business logic like slug generation (Core Services subsystem)
- HTTP error responses (API Interface subsystem)
