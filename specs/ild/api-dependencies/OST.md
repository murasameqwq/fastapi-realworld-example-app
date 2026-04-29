# OST - Operational Specification: API Dependencies

## Public Interfaces

### Authentication Dependencies (`authentication.py`)
JWT-based user authentication providers.

**Key Functions**:
- `get_current_user_authorizer(*, required=True) -> Callable` - Factory returning _get_current_user or _get_current_user_optional
- `get_repository(repo_type: Type[BaseRepository]) -> Callable[[Connection], BaseRepository]` - DI factory for repository instantiation

### Database Dependencies (`database.py`)
Connection pool and repository instantiation.

**Key Functions**:
- `_get_db_pool(request: Request) -> Pool` - Extract pool from app.state
- `_get_connection_from_pool(pool: Pool) -> AsyncGenerator[Connection]` - Acquire connection from pool
- `get_repository(repo_type) -> Callable` - Higher-order function creating repository instances

### Article Dependencies (`articles.py`)
Article lookup and filter providers.

**Key Functions**:
- `get_articles_filters(tag?, author?, favorited?, limit, offset) -> ArticlesFilters` - Parse query params into filter object
- `get_article_by_slug_from_path(slug, user?, articles_repo) -> Article` - Lookup article or raise 404
- `check_article_modification_permissions(current_article, user) -> None` - Verify authorship or raise 403

### Comment Dependencies (`comments.py`)
Comment lookup provider.

**Key Functions**:
- `get_comment_by_id_from_path(comment_id, article, user?, comments_repo) -> Comment` - Lookup comment or raise 404
- `check_comment_modification_permissions(comment, user) -> None` - Verify comment authorship

### Profile Dependencies (`profiles.py`)
Profile lookup provider.

**Key Functions**:
- `get_profile_by_username_from_path(username, user?, profiles_repo) -> Profile` - Lookup profile or raise 404

## Dependencies

**Internal**: `app.db.repositories.*`, `app.db.errors`, `app.models.domain.*`, `app.models.schemas.*`, `app.services.*`, `app.core.config`, `app.core.settings`, `app.resources.strings`
**External**: FastAPI (Depends, HTTPException, Security), starlette

## Exception Handling

- `HTTPException 401/403` - Missing/invalid auth header, wrong token prefix, malformed JWT
- `HTTPException 404` - Entity not found (article by slug, comment by ID, profile by username)
- `HTTPException 403` - User not author of resource

## Preconditions & Postconditions

**Preconditions**:
- `app.state.pool` must be initialized (startup handler)
- Auth header format: `Token <jwt>`

**Postconditions**:
- Auth dependencies return User or None/raise
- Lookup dependencies return domain model or raise 404
