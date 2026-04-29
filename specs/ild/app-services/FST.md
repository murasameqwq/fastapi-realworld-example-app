# FST - Functional Specification: Services

## Core Capabilities

- **Password Security**: Hash and verify passwords using bcrypt via passlib
- **JWT Token Management**: Create and parse access tokens for user authentication
- **Slug Generation**: Convert article titles to URL-safe slugs using python-slugify
- **Existence Checks**: Validate username/email uniqueness during registration
- **Authorization Checks**: Verify user owns an article or comment before modification

## Inputs & Outputs

**Input**: Plain text (passwords, titles), JWT tokens, domain models, repository instances
**Output**: Hashed strings, boolean checks, username strings, slugs
**Transformation**: Plain text → bcrypt hash; JWT → decoded payload → username

## Side Effects

- **No external state modification**: All functions are pure except bcrypt salt generation (reads system randomness)
- **No I/O**: Services delegate I/O to repositories; themselves are stateless utilities

## Responsibilities

✅ Provide cryptographic password hashing and verification
✅ Generate and validate JWT tokens with proper expiry
✅ Convert titles to URL-safe slugs
✅ Check entity uniqueness for registration validation
✅ Verify resource ownership for authorization
❌ NOT responsible for database access (delegates to repositories)
❌ NOT responsible for HTTP error responses (handled by routes)
