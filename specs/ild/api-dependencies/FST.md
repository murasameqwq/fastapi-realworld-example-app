# FST - Functional Specification: API Dependencies

## Core Capabilities

- **JWT Authentication**: Parse Authorization header, decode JWT token, lookup user, return User or raise 401/403
- **Connection Management**: Acquire asyncpg connections from pool per-request, return to pool after
- **Repository Factory**: Instantiate typed repositories with acquired connection via FastAPI DI
- **Entity Lookup**: Convert path parameters (slug, ID, username) into domain models, raising 404 if not found
- **Authorization Guards**: Verify current user owns a resource before allowing modification
- **Query Parameter Parsing**: Convert filter query params into validated ArticlesFilters object

## Inputs & Outputs

**Input**: FastAPI request context (headers, path params, query params), app state (pool)
**Output**: Domain models (User, Article, Comment, Profile), repository instances, or HTTP exceptions
**Transformation**: Raw HTTP data → validated/looked-up objects ready for route handlers

## Side Effects

- **Modifies external state**: None directly
- **Performs I/O**: Database lookups for user authentication and entity retrieval
- **Connection lifecycle**: Acquires and releases pool connections per request

## Responsibilities

✅ Extract and validate JWT tokens from requests
✅ Provide database connections to repositories
✅ Resolve path parameters to domain objects (404 if missing)
✅ Enforce resource ownership before modification
✅ Parse and validate query parameters into filter objects
❌ NOT responsible for business logic (delegated to services)
❌ NOT responsible for response formatting (handled by routes)
