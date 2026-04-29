# OST - Operational Specification: Migrations

## Public Interfaces

### Migration Environment (`env.py`)
Alembic migration runner configuration.

**Key Functions**:
- `run_migrations_online() -> None` - Executes migrations using async-compatible connection

### Main Migration (`fdf8821871d7_main_tables.py`)
Initial database schema creation.

**Key Functions**:
- `upgrade() -> None` - Creates all tables and triggers
- `downgrade() -> None` - Drops all tables in reverse order
- `create_users_table()`, `create_articles_table()`, `create_tags_table()`, `create_followers_to_followings_table()`, `create_articles_to_tags_table()`, `create_favorites_table()`, `create_commentaries_table()`, `create_updated_at_trigger()`

## Dependencies

**Internal**: None
**External**: alembic, sqlalchemy

## Exception Handling

- Migration failures rollback the transaction automatically
- No custom error handling

## Preconditions & Postconditions

**Preconditions**:
- PostgreSQL database must be running and accessible
- `DATABASE_URL` must be configured

**Postconditions**:
- Database schema matches the migration definition
- `updated_at` trigger function exists for automatic timestamp updates
