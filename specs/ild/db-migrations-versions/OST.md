# OST - Operational Specification: Migration Scripts

## Public Interfaces

### Main Migration (`fdf8821871d7_main_tables.py`)
Single Alembic migration creating the entire database schema.

**Key Functions**:
- `upgrade() -> None` - Execute all create operations
- `downgrade() -> None` - Drop all tables in reverse order
- `create_updated_at_trigger()` - Create PL/pgSQL function for automatic timestamp updates
- `create_users_table()` - Create users table with unique username/email
- `create_articles_table()` - Create articles table with foreign key to users
- `create_followers_to_followings_table()` - Many-to-many self-referencing follow table
- `create_tags_table()` - Create tags table
- `create_articles_to_tags_table()` - Many-to-many article-tag association
- `create_favorites_table()` - Many-to-many user-article favorites
- `create_commentaries_table()` - Create comments table with foreign keys

## Dependencies

**Internal**: None
**External**: alembic (op), sqlalchemy (sa)

## Exception Handling

- No custom error handling; Alembic manages transaction rollback on failure

## Preconditions & Postconditions

**Preconditions**:
- Empty database or no conflicting tables

**Postconditions**:
- All 7 tables created with proper foreign keys and cascades
- `update_updated_at_column()` trigger function created
- Triggers attached to users, articles, and commentaries tables
