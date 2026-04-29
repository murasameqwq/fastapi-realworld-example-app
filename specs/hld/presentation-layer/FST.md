# FST - Functional Specification: Presentation Layer

## Capabilities

- **API Gateway**: Routes HTTP requests to appropriate handlers based on method and URL path, with parameter extraction (path params, query params, request body)
- **Authentication Pipeline**: Validates JWT tokens from Authorization header, extracts user identity, enforces per-endpoint authentication requirements (required vs optional)
- **Authorization Enforcement**: Guards write operations with ownership verification; only resource authors can update or delete their content
- **Input Validation**: Validates all incoming data against typed Pydantic schemas with automatic 422 error responses for malformed input
- **Response Formatting**: Serializes internal domain objects to RealWorld-compliant JSON with proper wrappers, status codes, and field naming conventions
- **Entity Resolution**: Transforms path parameters (slugs, IDs, usernames) into fully populated domain model instances, raising 404 for missing entities

## System Boundary

```
┌─────────────────────────────────────────┐
│         Presentation Layer              │
│                                         │
│  HTTP Client ←→ Router → Handler → Resp │
│                                         │
│  External: HTTP/JSON requests           │
│  Internal: Domain objects, repositories │
└─────────────────────────────────────────┘
         ↓                    ↓
    Domain Layer      Infrastructure Layer
```

**Inputs**: HTTP requests (JSON body, headers, query parameters, path parameters)
**Outputs**: HTTP responses (JSON body, HTTP status codes)
**Consumed by**: External clients (web browsers, mobile apps, API consumers)

## Responsibilities

**Responsible for**:
- Defining all HTTP endpoints and their request/response contracts
- Parsing and validating authentication tokens
- Enforcing access control (authentication + authorization)
- Formatting responses per RealWorld API specification
- Managing request lifecycle (validation → auth → handler → response)

**Not responsible for**:
- Business logic execution (delegated to Domain Layer)
- Data persistence (delegated to Infrastructure Layer)
- Entity definitions (provided by Domain Layer)
- Database connection management (provided by Infrastructure Layer)

## Integration

- **With Domain Layer**: Receives domain models for response serialization; delegates JWT operations and business logic helpers
- **With Infrastructure Layer**: Acquires repository instances via DI for CRUD operations; receives enriched domain models from queries

## Failure Modes

- **Database unavailable**: All requests fail with connection errors; no caching or fallback
- **Invalid JWT**: Requests return 403; no session recovery
- **Malformed request**: Automatic 422 response with validation error details
- **Missing entity**: 404 response with descriptive error message
