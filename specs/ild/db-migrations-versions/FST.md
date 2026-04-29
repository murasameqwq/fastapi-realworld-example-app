# FST - Functional Specification: Migration Scripts

## Core Capabilities

- **Schema Definition**: Define complete PostgreSQL schema with 7 tables, foreign keys, and triggers
- **Cascade Management**: Set proper ON DELETE CASCADE/SET NULL for referential integrity
- **Timestamp Automation**: Create PL/pgSQL trigger function that auto-updates `updated_at` on row modification

## Inputs & Outputs

**Input**: Alembic migration command
**Output**: Modified database schema
**Transformation**: SQLAlchemy DDL → SQL executed via alembic op

## Side Effects

- **Modifies external state**: Creates/destroys database tables, functions, triggers

## Responsibilities

✅ Define all database tables with columns, types, and constraints
✅ Establish foreign key relationships with appropriate cascade behavior
✅ Create automatic timestamp update triggers
✅ Provide reversible migration (upgrade and downgrade)
❌ NOT responsible for data population (empty schema only)
❌ NOT responsible for connection management
