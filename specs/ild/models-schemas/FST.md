# FST - Functional Specification: Schema Models

## Core Capabilities

- **Request Validation**: Pydantic models validate and type-check incoming API request bodies
- **Response Serialization**: Schema models format domain models into API-compliant JSON responses
- **Field Aliasing**: Automatic snake_case → camelCase conversion via alias generator
- **ORM Mode**: `ArticleForResponse` extends both RWSchema and Article domain model for direct ORM mapping

## Inputs & Outputs

**Input**: JSON request body or domain model instance
**Output**: Validated Python objects, serializable to JSON
**Transformation**: Raw JSON → validated schema → camelCase JSON response

## Side Effects

- **No side effects**: Pure data validation and serialization
- Thread-safe: Immutable schema instances

## Responsibilities

✅ Define API contract for request/response shapes
✅ Convert between snake_case (Python) and camelCase (JSON)
✅ Validate email formats and URL formats
✅ Enable ORM mode for direct domain model → schema conversion
❌ NOT responsible for business logic or validation rules
❌ NOT responsible for database operations
