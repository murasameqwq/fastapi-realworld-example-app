# FST - Functional Specification: Core Services Subsystem

## Capabilities

- **Configuration Management**: Selects environment-specific settings (dev/prod/test) based on `APP_ENV`, caches the result, and provides typed access to database URL, JWT secret, connection pool sizes, and API configuration
- **Logging Setup**: Intercepts stdlib logging calls and routes them through loguru for unified log management
- **JWT Token Lifecycle**: Creates signed access tokens with 7-day expiry for authenticated users, decodes and validates tokens to extract user identity
- **Password Security**: Generates bcrypt salts, hashes passwords with per-user salt, and verifies plaintext against stored hashes
- **Entity Existence Checks**: Wraps repository lookups in try/except to return boolean existence results (used by registration and article creation validation)
- **Slug Generation**: Converts article titles to URL-safe slugs using python-slugify
- **Ownership Verification**: Compares entity author username with current user username for authorization decisions

## I/O Boundary

```
                    Core Services Subsystem
                    ┌──────────────────────┐
  ENV vars       →  │  Settings Loader     │  →  Typed config object
  .env file      →  │                      │
                    │  JWT Service         │  →  Token string / username
  User + secret  →  │                      │     (from decode)
                    │  Security Service    │  →  Hashed password / bool
  Plain password →  │                      │
                    │  Business Helpers    │  →  bool (existence/ownership)
  Entity + user  →  │                      │
                    └──────────────────────┘
```

**Inputs**: Environment variables, user objects, passwords, titles, JWT tokens
**Outputs**: Settings objects, JWT strings, boolean checks, hashed passwords, slugs
**External I/O**: `.env` file reading (at settings initialization)

## Side Effects

- **File I/O**: Reads `.env` file at settings initialization
- **Randomness**: bcrypt salt generation consumes system entropy
- **Logging**: `configure_logging()` replaces all logging handlers (global side effect)
- **Stateless functions**: All service functions are pure (no persistent state)

## Boundaries

**Responsible for**:
- Centralized application configuration with environment-specific profiles
- Cryptographic operations (password hashing, JWT token management)
- Simple business logic helpers (existence checks, slug generation, ownership)
- Logging infrastructure setup

**Not responsible for**:
- Database connection management (handled by startup events)
- HTTP routing or request handling (API Interface subsystem)
- Entity definitions or data schemas (Domain Model subsystem)
- Direct database queries (Data Access subsystem)
