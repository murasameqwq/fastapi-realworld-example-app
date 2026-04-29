# FST - Functional Specification: Settings

## Core Capabilities

- **Environment Selection**: Selects settings profile (dev/prod/test) based on `APP_ENV` environment variable
- **Configuration Loading**: Reads database URL, secret key, connection pool sizes from `.env` file
- **FastAPI Configuration**: Provides kwargs dict for FastAPI app initialization (debug mode, docs URLs, title)
- **Logging Setup**: Routes standard library logging through loguru

## Inputs & Outputs

**Input**: Environment variables and `.env` file
**Output**: Configured settings instance (AppSettings subclass)
**Transformation**: ENV vars → Pydantic validation → typed settings object

## Side Effects

- **Modifies external state**: None directly
- **Performs I/O**: Reads `.env` file at initialization
- **Logging side effect**: `configure_logging()` replaces all logging handlers with loguru interceptors

## Responsibilities

✅ Centralize all application configuration in typed Pydantic models
✅ Provide environment-specific overrides (dev has debug=True, test has fixed secret)
✅ Supply FastAPI initialization parameters via `fastapi_kwargs` property
❌ NOT responsible for runtime configuration changes
❌ NOT responsible for database connection management
