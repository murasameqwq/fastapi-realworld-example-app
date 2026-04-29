# OST - Operational Specification: Repositories

## Public Interfaces

### BaseRepository
Abstract base for all repositories, holds an `asyncpg.Connection`.

**Key Methods**:
- `__init__(conn: Connection)` - Initialize with DB connection
- `connection` (property) - Access the underlying connection

### ArticlesRepository
CRUD and query operations for articles, including favorites and tags.

**Key Methods**:
- `create_article(slug, title, description, body, author, tags?) -> Article`
- `update_article(article, slug?, title?, body?, description?) -> Article`
- `delete_article(article) -> None`
- `filter_articles(tag?, author?, favorited?, limit, offset, requested_user?) -> List[Article]`
- `get_article_by_slug(slug, requested_user?) -> Article`
- `get_articles_for_user_feed(user, limit, offset) -> List[Article]`
- `add_article_into_favorites(article, user) -> None`
- `remove_article_from_favorites(article, user) -> None`

### CommentsRepository
CRUD operations for comments on articles.

**Key Methods**:
- `create_comment_for_article(body, article, user) -> Comment`
- `get_comment_by_id(comment_id, article, user?) -> Comment`
- `get_comments_for_article(article, user?) -> List[Comment]`
- `delete_comment(comment) -> None`

### ProfilesRepository
Profile lookup and follow/unfollow operations.

**Key Methods**:
- `get_profile_by_username(username, requested_user?) -> Profile`
- `is_user_following_for_another_user(target_user, requested_user) -> bool`
- `add_user_into_followers(target_user, requested_user) -> None`
- `remove_user_from_followers(target_user, requested_user) -> None`

### UsersRepository
User CRUD and credential management.

**Key Methods**:
- `create_user(username, email, password) -> UserInDB`
- `update_user(user, username?, email?, password?, bio?, image?) -> UserInDB`
- `get_user_by_email(email) -> UserInDB`
- `get_user_by_username(username) -> UserInDB`

### TagsRepository
Tag retrieval and creation.

**Key Methods**:
- `get_all_tags() -> List[str]`
- `create_tags_that_dont_exist(tags) -> None`

## Dependencies

**Internal**: `app.db.queries.queries` (aiosql), `app.db.queries.tables` (pypika), `app.db.repositories.profiles`, `app.db.repositories.tags`, `app.db.repositories.users`, `app.models.domain.*`
**External**: asyncpg (connection pool), pypika (dynamic query building), aiosql (SQL file loader)

## Exception Handling

- `EntityDoesNotExist` - Raised by `get_article_by_slug`, `get_user_by_email`, `get_user_by_username`, `get_comment_by_id` when the entity is not found
- All write operations run inside `async with self.connection.transaction()` for atomicity
- No explicit recovery; exceptions propagate to route handlers

## Preconditions & Postconditions

**Preconditions**:
- Active `asyncpg.Connection` must be available
- User must exist when creating articles or comments
- Article slug must be unique for creation

**Postconditions**:
- Successful writes return the created/updated domain model
- Tags are auto-created if they don't exist during article creation
- Follow operations use transactional consistency
