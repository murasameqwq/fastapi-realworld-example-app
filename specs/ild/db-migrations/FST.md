# FST - Functional Specification: Migrations

## Core Capabilities

- **Schema Initialization**: Creates all database tables (users, articles, tags, favorites, comments, followers)
- **Trigger Setup**: Creates `update_updated_at_column()` PL/pgSQL function for automatic timestamp updates
- **Schema Rollback**: Provides downgrade path that drops tables in reverse dependency order

## Inputs & Outputs

**Input**: Alembic migration command (`alembic upgrade head` / `alembic downgrade base`)
**Output**: Modified PostgreSQL database schema
**Transformation**: SQLAlchemy DDL operations → SQL executed against database

## Side Effects

- **Modifies external state**: Creates/drops database tables, functions, and triggers

## Responsibilities

✅ Define the complete initial database schema
✅ Set up foreign key relationships with proper cascade behavior
✅ Create automatic updated_at triggers on mutable tables
❌ NOT responsible for data migration (no data exists at this stage)
❌ NOT responsible for connection management (handled by alembic)
