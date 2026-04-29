# OST - Operational Specification: Article Routes

## Public Interfaces

### Articles Resource Router (`articles_resource.py`)
Handles CRUD endpoints for articles.

**Routes**:
- `GET /api/articles` → `ListOfArticlesInResponse` - List articles with filters
- `POST /api/articles` → `ArticleInResponse` - Create new article (auth required)
- `GET /api/articles/{slug}` → `ArticleInResponse` - Get article by slug
- `PUT /api/articles/{slug}` → `ArticleInResponse` - Update article (author only)
- `DELETE /api/articles/{slug}` → 204 No Content - Delete article (author only)

### Articles Common Router (`articles_common.py`)
Handles feed and favorite endpoints.

**Routes**:
- `GET /api/articles/feed` → `ListOfArticlesInResponse` - Get feed articles (auth required)
- `POST /api/articles/{slug}/favorite` → `ArticleInResponse` - Favorite article (auth required)
- `DELETE /api/articles/{slug}/favorite` → `ArticleInResponse` - Unfavorite article (auth required)

## Dependencies

**Internal**: `app.api.dependencies.articles` (filters, slug lookup, permissions), `app.api.dependencies.authentication`, `app.api.dependencies.database`, `app.db.repositories.articles`, `app.models.schemas.articles`, `app.services.articles`
**External**: FastAPI (APIRouter, Body, Depends, HTTPException)

## Exception Handling

- `HTTPException 400` - Article already exists, already favorited, or not favorited
- `HTTPException 403` - User not author of article (modification permission check)
- `HTTPException 404` - Article not found (handled in dependency layer)

## Preconditions & Postconditions

**Preconditions**:
- User must be authenticated for write operations and feed
- Article slug must exist in database for GET/PUT/DELETE by slug

**Postconditions**:
- Successful creation returns article with generated slug and tags
- Favorite operations update the in-memory response with adjusted count
