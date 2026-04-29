# FST - Functional Specification: Article Routes

## Core Capabilities

- **Article Listing**: Returns paginated articles with optional tag/author/favorited filters
- **Article Creation**: Creates article with slug generation, tag linking, and author attribution
- **Article Retrieval**: Fetches single article by slug with full metadata
- **Article Update**: Partially updates article fields, regenerates slug if title changes
- **Article Deletion**: Removes article and associated data (cascade)
- **Feed Generation**: Returns articles from authors the current user follows
- **Favorite Management**: Toggle article favorite status with count adjustment

## Inputs & Outputs

**Input**: Pydantic request bodies (ArticleInCreate, ArticleInUpdate), query parameters (tag, author, favorited, limit, offset), path parameters (slug)
**Output**: Response models (ArticleInResponse, ListOfArticlesInResponse) with camelCase JSON keys
**Transformation**: Schema model → domain model → repository call → schema response

## Side Effects

- **Modifies external state**: POST/PUT/DELETE routes modify the database via repositories
- **Performs I/O**: All routes perform database reads/writes

## Responsibilities

✅ Validate request bodies via Pydantic schemas
✅ Enforce authentication requirements via dependency injection
✅ Delegate business logic to repositories and services
✅ Format response data using schema models with alias transformations
❌ NOT responsible for database query logic (handled by repositories)
❌ NOT responsible for slug generation (handled by services)
❌ NOT responsible for authorization checks (handled by dependencies)
