# FST - Functional Specification: Domain Models

## Core Capabilities

- **Entity Representation**: Pure data classes representing core business entities (Article, Comment, User, Profile)
- **Password Management**: UserInDB provides bcrypt password verification and hashing via security service
- **Mixin Composition**: ID and timestamp fields extracted into reusable mixins (IDModelMixin, DateTimeModelMixin)
- **Serialization**: Automatic camelCase output and UTC datetime formatting via RWModel base

## Inputs & Outputs

**Input**: Keyword arguments matching field names
**Output**: Typed model instances
**Transformation**: Raw DB data → typed domain model with validation

## Side Effects

- **Pure functional**: No side effects; data containers only
- `UserInDB.change_password()` modifies instance state (salt + hashed_password)

## Responsibilities

✅ Represent core business entities with typed fields
✅ Provide password hashing and verification methods
✅ Define the data shape used by repositories and services
❌ NOT responsible for API serialization (handled by schema models)
❌ NOT responsible for database access (handled by repositories)
