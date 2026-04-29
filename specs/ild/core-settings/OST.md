# OST - Operational Specification: Settings

## Public Interfaces

### BaseAppSettings
Base Pydantic settings class with environment type enum.

**Key Fields**:
- `app_env: AppEnvTypes` - Environment selector (prod/dev/test)
- `Config.env_file = ".env"` - Loads from .env file

### AppSettings
Main settings class with full application configuration.

**Key Fields**:
- `database_url: PostgresDsn` - PostgreSQL connection string
- `secret_key: SecretStr` - JWT signing key
- `max_connection_count` / `min_connection_count` - Connection pool sizing
- `api_prefix: str` - API route prefix (default "/api")
- `jwt_token_prefix: str` - Token header prefix (default "Token")

**Key Methods**:
- `fastapi_kwargs` (property) → Dict - Settings dict for FastAPI constructor
- `configure_logging() -> None` - Configures loguru as the logging backend

### DevAppSettings / ProdAppSettings / TestAppSettings
Environment-specific subclasses overriding debug, title, logging level, and connection pool sizes.

## Dependencies

**Internal**: `app.core.logging.InterceptHandler`
**External**: pydantic (BaseSettings, PostgresDsn, SecretStr), loguru

## Exception Handling

- Pydantic validation errors raised if required env vars (DATABASE_URL, SECRET_KEY) are missing
- `validate_assignment = True` on AppSettings catches invalid reassignments

## Preconditions & Postconditions

**Preconditions**:
- `.env` file must exist with required variables
- `APP_ENV` env var selects the settings subclass

**Postconditions**:
- Settings are cached via `@lru_cache` on `get_app_settings()`
- Logging is reconfigured to route through loguru
