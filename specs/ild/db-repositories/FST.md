# FST - Functional Specification: Repositories

## Core Capabilities

- **Article CRUD**: Create, read, update, and delete articles with tag associations
- **Article Filtering**: Query articles by tag, author, or favorited status with pagination
- **Favorite Management**: Add/remove articles from user favorites, track favorite counts
- **Comment CRUD**: Create and retrieve comments for articles, delete comments
- **Profile Operations**: Retrieve user profiles with following status, follow/unfollow users
- **User Management**: Create/update users with bcrypt password hashing, lookup by email or username
- **Tag Management**: List all tags, create missing tags on article creation

## Inputs & Outputs

**Input**: Keyword arguments (slug, title, body, author User, tags list, etc.)
**Output**: Domain model instances (Article, Comment, Profile, UserInDB) or lists thereof
**Transformation**: Raw asyncpg Record rows → enriched domain models with profile, tags, and favorite metadata

## Side Effects

- **Modifies external state**: All create/update/delete methods write to PostgreSQL
- **Performs I/O**: Database reads and writes via asyncpg connection pool
- **Not pure**: All methods have database side effects
- Transactions are used for multi-step operations (article+tags, follow operations)

## Responsibilities

✅ Manage all database access for articles, comments, users, profiles, and tags
✅ Enrich raw DB records with related data (profile, tags, favorite count)
✅ Handle tag creation implicitly during article creation
✅ Provide filtered/paginated article queries via pypika dynamic SQL
❌ NOT responsible for request validation (handled by Pydantic schemas)
❌ NOT responsible for authentication (handled by API dependencies)
❌ NOT responsible for business logic like slug generation (handled by services)
