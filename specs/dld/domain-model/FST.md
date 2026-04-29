# FST - Functional Specification: Domain Model Subsystem

## Capabilities

- **Entity Representation**: Pure typed data classes for all business entities (Article, Comment, User, Profile) with inheritance-based mixin composition for ID and timestamp fields
- **Password Management**: UserInDB provides bcrypt password verification and hashing with per-user salt generation
- **API Contract Definition**: Pydantic request/response schemas that enforce the RealWorld API specification with proper field validation (email format, URL format)
- **Serialization**: Automatic snake_case → camelCase field name conversion, UTC datetime formatting with Z suffix, and ORM mode for direct domain model → schema mapping
- **JWT Payload Structure**: Typed models for JWT token metadata (expiration, subject) and user payload (username)

## I/O Boundary

```
                  Domain Model Subsystem
                  ┌─────────────────────┐
  JSON Request →  │  Schema Validation   │  →  Typed Python Objects
  (camelCase)     │                     │
                  │  Domain Models       │  →  JSON Response
  DB Records   →  │  (Article, User...)  │  →  (camelCase, Z-datetime)
                  │                     │
  ORM objects  →  │  RWSchema.from_orm   │  →  Serialized JSON
                  └─────────────────────┘
```

**Inputs**: JSON request bodies, raw database records, domain model instances
**Outputs**: Validated Python objects, serialized JSON responses
**Transformation**: camelCase JSON ↔ snake_case Python ↔ camelCase JSON output

## Side Effects

- **Pure functional**: All models are immutable data containers with no side effects
- Exception: `UserInDB.change_password()` modifies instance state (salt + hashed_password fields)
- Thread-safe: Pydantic model instances are immutable after creation

## Boundaries

**Responsible for**:
- Defining the shape and types of all business entities
- Validating incoming API request data against type constraints
- Serializing domain models to RealWorld-compliant JSON responses
- Converting between Python naming conventions and API naming conventions

**Not responsible for**:
- Database access or queries (Data Access subsystem)
- Business logic operations (Core Services / API Interface subsystems)
- HTTP routing or request handling (API Interface subsystem)
- Authentication token generation (Core Services subsystem)
