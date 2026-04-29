# FST - Functional Specification: Query Definitions

## Core Capabilities

- **SQL Query Loading**: Loads all `.sql` files from `app/db/queries/sql/` into callable Python functions via aiosql
- **Type-safe Table Definitions**: Provides pypika TypedTable subclasses with typed field annotations for dynamic query building
- **Parameterized Query Execution**: All queries use named parameters bound to asyncpg connection

## Inputs & Outputs

**Input**: asyncpg Connection + named parameters (slug, username, email, etc.)
**Output**: asyncpg Record(s) or None for reads; None for writes
**Transformation**: SQL file → aiosql callable function → asyncpg execution → Record

## Side Effects

- **Modifies external state**: Write queries (INSERT, UPDATE, DELETE) modify PostgreSQL
- **Performs I/O**: All queries execute against the database
- **Not pure**: Database-dependent operations

## Responsibilities

✅ Provide type-safe table definitions for pypika dynamic queries
✅ Load and expose SQL queries as callable functions
✅ Define custom Parameter class for pypika numbered placeholders ($1, $2, ...)
❌ NOT responsible for query logic (defined in .sql files)
❌ NOT responsible for domain model mapping (handled by repositories)
