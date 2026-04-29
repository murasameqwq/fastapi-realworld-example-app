# FST - Functional Specification: API Interface Subsystem

## Capabilities

- **Request Routing**: Maps HTTP methods and URL paths to handler functions, with path parameter extraction (slug, username, comment_id)
- **Authentication & Authorization**: Validates JWT tokens from Authorization header, enforces auth requirements per-endpoint, checks resource ownership before modification
- **Request Validation**: Parses and validates JSON request bodies via Pydantic schemas, query parameters for filtering, path parameters for entity lookup
- **Response Formatting**: Serializes domain models to RealWorld-compliant JSON with proper wrappers, status codes, and camelCase keys
- **Entity Resolution**: Converts path parameters into domain model instances via dependency injection, raising 404 if not found
- **Permission Enforcement**: Guards write operations (update, delete) with authorship verification, raising 403 for unauthorized modifications

## I/O Boundary

```
                   API Interface Subsystem
                   ┌──────────────────────┐
  HTTP Request →   │  Route Handler       │  →  HTTP Response
  (JSON, headers)  │                      │     (JSON, status code)
                   │  Dependency Providers│
                   │  - Auth              │  →  User / None
                   │  - DB connection     │  →  Repository instance
                   │  - Entity lookup     │  →  Domain model / 404
                   └──────────────────────┘
                          ↓↑
                   Data Access + Domain Model + Core Services
```

**Inputs**: HTTP requests (JSON body, headers, path params, query params)
**Outputs**: HTTP responses (JSON body, status code)
**External I/O**: HTTP/JSON over network, JWT token parsing

## Side Effects

- **Database modification**: POST/PUT/DELETE routes trigger write operations in repositories
- **JWT token generation**: Login and user retrieval endpoints generate new access tokens
- **No internal state**: All route handlers are stateless functions

## Boundaries

**Responsible for**:
- Defining all HTTP endpoints and their request/response contracts
- Parsing authentication headers and extracting user identity
- Validating incoming data against schema models
- Enforcing authorization (auth required, resource ownership)
- Formatting outgoing responses per RealWorld API specification

**Not responsible for**:
- Database query logic (Data Access subsystem)
- Password hashing or JWT encoding (Core Services subsystem)
- Business entity definitions (Domain Model subsystem)
- Application startup/shutdown (Core Infrastructure)
