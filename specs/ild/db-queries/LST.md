# LST - Logic Specification: Query Definitions

## Main Workflow

```mermaid
flowchart TD
    A[Module load] --> B[aiosql.from_path reads sql/ directory]
    B --> C[Parse each .sql file into callable functions]
    C --> D[Expose as queries singleton]
    D --> E[Repository calls queries.func(conn, **params)]
    E --> F[aiosql executes SQL on asyncpg connection]
    F --> G[Return asyncpg Record]
```

## Key Algorithms

**Query Loading**: `aiosql.from_path(pathlib.Path(__file__).parent / "sql", "asyncpg")` scans the `sql/` directory for `.sql` files, parses each file's SQL statements into named queries, and returns an object with callable methods matching query names.

**TypedTable Resolution**: Each TypedTable subclass sets `__table__` class attribute mapping to the actual PostgreSQL table name. If `name` is not provided to `__init__`, it falls back to `__table__` or the class name. Field type annotations are used for IDE support, not runtime validation.

**Custom Parameter**: pypika's `Parameter` class is subclassed to prefix with `$` (PostgreSQL positional parameter syntax: `$1`, `$2`, etc.) instead of the default `?`.

## Control Flow

- **Module init**: Single call to `aiosql.from_path` at import time, creates singleton
- **Query execution**: Direct function call → aiosql dispatch → asyncpg execute → Record return
- **Dynamic queries**: pypika builds SQL string → `query.get_sql()` → `connection.fetch()` with params

## Business Rules

- SQL files use aiosql naming convention: `-- name: query_name ^`
- All write queries include `author_username` for ownership verification
- Parameter ordering in dynamic queries is manually tracked via `query_params_count` counter
