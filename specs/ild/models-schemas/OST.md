# OST - Operational Specification: Schema Models

## Public Interfaces

### RWSchema
Base schema class extending RWModel with `orm_mode = True` for Pydantic ORM mode.

### Article Schemas
- `ArticleForResponse` - Article data for API responses (includes `tagList` alias)
- `ArticleInResponse` - Wrapper: `{article: ArticleForResponse}`
- `ArticleInCreate` - Request body: title, description, body, tagList (optional)
- `ArticleInUpdate` - Partial update: title, description, body (all optional)
- `ListOfArticlesInResponse` - Paginated list: articles array + articles_count
- `ArticlesFilters` - Query params: tag, author, favorited, limit (20), offset (0)

### User Schemas
- `UserInCreate` - Registration: username, email, password
- `UserInLogin` - Login: email, password
- `UserInUpdate` - Partial update: username, email, password, bio, image (all optional)
- `UserWithToken` - User + JWT token string
- `UserInResponse` - Wrapper: `{user: UserWithToken}`

### Comment Schemas
- `CommentInCreate` - Request: body
- `CommentInResponse` - Wrapper: `{comment: Comment}`
- `ListOfCommentsInResponse` - Array: `{comments: [Comment]}`

### Other Schemas
- `ProfileInResponse` - Wrapper: `{profile: Profile}`
- `JWTMeta` / `JWTUser` - JWT payload structure
- `TagsInList` - Wrapper: `{tags: [str]}`

## Dependencies

**Internal**: `app.models.domain.*` (domain models), `app.models.domain.rwmodel.RWModel`
**External**: pydantic (BaseModel, Field, EmailStr, HttpUrl)

## Exception Handling

- Pydantic validation errors auto-generated for invalid request bodies (422)
- EmailStr validation rejects malformed emails
- HttpUrl validation rejects invalid URLs

## Preconditions & Postconditions

**Preconditions**:
- Domain models must have matching field names for schema inheritance
- Field aliases (e.g., `tagList`) must match RealWorld API spec

**Postconditions**:
- All schemas serialize to JSON with camelCase keys (via RWModel alias_generator)
- Datetime fields serialized to ISO 8601 with `Z` suffix
