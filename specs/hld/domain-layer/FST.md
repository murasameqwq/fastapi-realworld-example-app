# FST - Functional Specification: Domain Layer

## Capabilities

- **Entity Modeling**: Defines all business entities with typed fields, default values, and inheritance-based mixin composition for shared fields (ID, timestamps)
- **API Contract Enforcement**: Validates incoming request data against typed schemas with automatic error responses for malformed input (email format, URL format, required fields)
- **Serialization**: Converts between Python snake_case and API camelCase; formats datetimes as ISO 8601 with Z suffix; enables ORM mode for direct domain-to-schema mapping
- **Token Lifecycle**: Creates signed JWT access tokens with configurable expiry; validates and decodes tokens to extract user identity
- **Password Management**: Generates per-user bcrypt salts, hashes passwords, and verifies plaintext against stored hashes
- **Configuration Management**: Selects environment-specific settings at startup; provides typed access to database URL, JWT secret, connection pool sizes, and API configuration
- **Business Logic**: Provides reusable helpers for slug generation, entity existence checks, and ownership verification

## System Boundary

```
┌─────────────────────────────────────────┐
│            Domain Layer                 │
│                                         │
│  Entities ←→ Schemas ←→ Services        │
│                                         │
│  Input: Raw data, passwords, titles     │
│  Output: Typed models, JWT, hashes      │
└─────────────────────────────────────────┘
         ↓                    ↑
  Infrastructure Layer   Presentation Layer
```

**Inputs**: Raw request data, passwords, article titles, JWT tokens, environment variables
**Outputs**: Typed domain models, validated schema instances, JWT tokens, password hashes, configuration objects
**Consumed by**: Presentation Layer (for request/response handling), Infrastructure Layer (for entity creation)

## Responsibilities

**Responsible for**:
- Defining the shape and types of all business entities
- Enforcing API contract validation at the data level
- Managing cryptographic operations (passwords, JWT)
- Providing environment-specific configuration
- Supplying reusable business logic helpers

**Not responsible for**:
- HTTP request handling (Presentation Layer)
- Database query execution (Infrastructure Layer)
- Schema migrations (Infrastructure Layer)
- Application startup/shutdown orchestration

## Integration

- **With Presentation Layer**: Provides schema models for request validation and response serialization; supplies JWT and password services for auth endpoints
- **With Infrastructure Layer**: Entity definitions used by repositories for domain model construction; existence check helpers call repository methods

## Failure Modes

- **Invalid env config**: Application fails to start with Pydantic validation error (missing DATABASE_URL or SECRET_KEY)
- **JWT decode failure**: `ValueError` raised on malformed or expired token; caught by Presentation Layer auth pipeline
- **Password hash failure**: bcrypt exception propagates upward; no graceful degradation
