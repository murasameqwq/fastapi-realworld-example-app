# Code Scan Summary

**Date**: 2026-04-29
**Project**: FastAPI RealWorld Example App

## Overview

This project is a **FastAPI** implementation of the RealWorld backend specification ("Conduit" - a Medium-like blog platform). It implements CRUD for articles, comments, user authentication, profiles, and tags, with PostgreSQL database access via asyncpg and aiosql.

| Metric | Value |
|--------|-------|
| Languages | Python |
| Total Files Scanned | 194 |
| Source Files | 73 (38%) |
| Test Files | 23 (12%) |
| Total Source Lines | 2,567 |
| Total Test Lines | 1,395 |

## Language Breakdown

| Language | Source Files | Lines | Test Files | Test Lines |
|----------|--------------|-------|------------|------------|
| Python   | 73           | 2,567 | 23         | 1,395      |

## Directory Distribution

| Directory | Files | Lines | Type | Languages |
|-----------|-------|-------|------|-----------|
| app/api/routes/ | 11 | 584 | API | Python |
| app/api/dependencies/ | 6 | 276 | API | Python |
| app/db/repositories/ | 7 | 611 | Data | Python |
| app/db/queries/ | 9 | 322 | Data | Python |
| app/db/migrations/ | 3 | 277 | Utility | Python |
| app/models/schemas/ | 8 | 122 | Data | Python |
| app/models/domain/ | 6 | 79 | Data | Python |
| app/services/ | 6 | 106 | Core | Python |
| app/core/settings/ | 6 | 112 | Core | Python |
| app/core/ | 4 | 71 | Core | Python |
| app/api/errors/ | 3 | 35 | API | Python |
| app/db/ | 3 | 27 | Data | Python |
| app/resources/ | 2 | 25 | Utility | Python |
| app/models/ | 2 | 19 | Data | Python |
| app/ | 2 | 45 | Utility | Python |
| tests/ | 23 | 1,395 | Test | Python |

## Core Modules

- **Settings** (`app/core/settings/`) - Python, 6 files, 112 lines
- **Services** (`app/services/`) - Python, 6 files, 106 lines

## Data Modules

- **Repositories** (`app/db/repositories/`) - Python, 7 files, 611 lines
- **Query Definitions** (`app/db/queries/`) - Python, 4 files, 201 lines
- **SQL Queries** (`app/db/queries/sql/`) - Python, 5 files, 252 lines
- **Schema Models** (`app/models/schemas/`) - Python, 8 files, 122 lines
- **Domain Models** (`app/models/domain/`) - Python, 6 files, 79 lines

## API Modules

- **API Routes** (`app/api/routes/`) - Python, 7 files, 352 lines
- **Article Routes** (`app/api/routes/articles/`) - Python, 4 files, 232 lines
- **API Dependencies** (`app/api/dependencies/`) - Python, 6 files, 276 lines
- **Error Handlers** (`app/api/errors/`) - Python, 3 files, 35 lines

## Utility Modules

- **Core Configuration** (`app/core/`) - Python, 4 files, 71 lines
- **Database Events** (`app/db/`) - Python, 3 files, 27 lines
- **Migration Scripts** (`app/db/migrations/versions/`) - Python, 1 file, 216 lines
- **Model Commons** (`app/models/`) - Python, 2 files, 19 lines
- **Resource Strings** (`app/resources/`) - Python, 2 files, 25 lines
- **Application Entry** (`app/`) - Python, 2 files, 45 lines

## Frontend Components

_No frontend detected, section omitted._

## Test Coverage

- **Test Files**: 23 (12% of total files)
- **Test Lines**: 1,395 (54% of source lines)
- **Test/Source Ratio**: 1:3.2

## Statistics

- **Total Modules**: 18 (2 core, 5 data, 4 api, 7 utility)
- **Average File Size**: 35 lines
- **Code Organization**: Well-structured layered architecture with clear separation between API routes, dependencies, services, repositories, domain models, and schema models. Follows a repository pattern with SQL queries managed via aiosql and pypika.
- **Key Files**: `app/db/repositories/articles.py` (330 lines) is the largest source file; `tests/test_api/test_routes/test_articles.py` (575 lines) is the largest test file.
