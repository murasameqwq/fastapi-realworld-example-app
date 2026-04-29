# OST - Operational Specification: Query Definitions

## Public Interfaces

### queries (aiosql instance)
Module-level singleton loaded from SQL files via `aiosql.from_path()`.

**Key Methods** (callable queries):
- `create_new_article(conn, slug, title, description, body, author_username) -> Record`
- `update_article(conn, slug, author_username, new_slug, new_title, new_body, new_description) -> datetime`
- `delete_article(conn, slug, author_username) -> None`
- `get_article_by_slug(conn, slug) -> Record`
- `get_tags_for_article_by_slug(conn, slug) -> List[Record]`
- `get_favorites_count_for_article(conn, slug) -> Record`
- `is_article_in_favorites(conn, username, slug) -> Record`
- `add_article_to_favorites(conn, username, slug) -> None`
- `remove_article_from_favorites(conn, username, slug) -> None`
- `get_articles_for_feed(conn, follower_username, limit, offset) -> List[Record]`
- `create_new_comment(conn, body, article_slug, author_username) -> Record`
- `get_comment_by_id_and_slug(conn, comment_id, article_slug) -> Record`
- `get_comments_for_article_by_slug(conn, slug) -> List[Record]`
- `delete_comment_by_id(conn, comment_id, author_username) -> None`
- `create_new_user(conn, username, email, salt, hashed_password) -> Record`
- `get_user_by_email(conn, email) -> Record`
- `get_user_by_username(conn, username) -> Record`
- `update_user_by_username(conn, username, new_username, new_email, new_salt, new_password, new_bio, new_image) -> datetime`
- `is_user_following_for_another(conn, follower_username, following_username) -> Record`
- `subscribe_user_to_another(conn, follower_username, following_username) -> None`
- `unsubscribe_user_from_another(conn, follower_username, following_username) -> None`
- `get_all_tags(conn) -> List[Record]`
- `create_new_tags(conn, [{"tag": ...}]) -> None`
- `add_tags_to_article(conn, [{"slug": ..., "tag": ...}]) -> None`

### TypedTable classes (pypika)
Typed table definitions for dynamic query building.

**Key Classes**:
- `Users`, `Articles`, `Tags`, `ArticlesToTags`, `Favorites` - TypedTable subclasses with field type annotations

## Dependencies

**Internal**: None (queries module has no imports beyond aiosql)
**External**: aiosql (SQL file loader), pypika (query builder)

## Exception Handling

- No explicit exception handling; SQL errors (constraint violations, syntax errors) propagate directly
- Parameter mismatch in SQL files raises aiosql runtime errors

## Preconditions & Postconditions

**Preconditions**:
- SQL files must exist under `app/db/queries/sql/`
- Database schema must match column references in SQL
- `asyncpg.Connection` must be passed as first argument

**Postconditions**:
- Read queries return asyncpg Record(s)
- Write queries return affected rows or None
- Bulk inserts accept list of dicts
