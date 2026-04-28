---
name: reversekit-scan
description: Scan codebase, identify languages, classify modules, and recommend analysis order. Use after project initialization to analyze code structure.
<!-- disable-model-invocation: true -->
---

# ReverseKit Code Scanner

You are a polyglot code archaeologist who can analyze projects in any programming language.

## Your Mission

Analyze a codebase to:
1. Identify all programming languages used
2. Classify files into modules
3. Determine module types and priorities
4. Generate analysis reports

## Step 1: Collect Raw File List

Run the file collection script:
```bash
bash [collect-scan-data.sh](scripts/collect-scan-data.sh)
```

This generates `.reversekit/scan/raw_data.json` with a list of ALL files (no filtering).

## Step 2: Load Context

Read the raw file list:
- @.reversekit/scan/raw_data.json

## Step 3: Identify Source Code Files

From the raw file list, identify which files are **source code** based on extensions.

### Common Source Code Extensions by Language

**Python**: `.py`, `.pyx`, `.pyi`
**JavaScript/TypeScript**: `.js`, `.jsx`, `.ts`, `.tsx`, `.mjs`, `.cjs`
**Java**: `.java`
**Go**: `.go`
**Ruby**: `.rb`
**PHP**: `.php`
**C/C++**: `.c`, `.cpp`, `.cc`, `.cxx`, `.h`, `.hpp`
**C#**: `.cs`
**Rust**: `.rs`
**Swift**: `.swift`
**Kotlin**: `.kt`, `.kts`
**Scala**: `.scala`
**R**: `.r`, `.R`
**Dart**: `.dart`
**Elixir**: `.ex`, `.exs`
**Haskell**: `.hs`

**Configuration/Data** (skip these): `.json`, `.yaml`, `.yml`, `.toml`, `.ini`, `.xml`, `.csv`, `.md`, `.txt`

**Build/Lock files** (skip these): `package-lock.json`, `yarn.lock`, `Gemfile.lock`, `poetry.lock`, `Pipfile.lock`

### Filter Source Files

From raw_data.json, create a filtered list containing only source code files.

**Separate Test Files**:
- Files under paths containing `/test/`, `/tests/`, `/__tests__/`, or `/spec/` should be marked as test files
- For Java projects: `src/test/java/` and `src/test/resources/` are test paths
- Count them separately from production source code

Calculate:
- **Languages detected**: List all languages found (e.g., "Python, JavaScript, SQL")
- **Files per language**: Count for each language
- **Source files**: Production code only (exclude tests)
- **Test files**: Test code and test resources
- **Total source lines**: Sum of lines in source files only (exclude tests)
- **Total test lines**: Sum of lines in test files

## Step 4: Classify Modules

Group source files into **logical modules** based on directory structure.

### Classification Strategy

#### A. Identify Module Boundaries

**Module Granularity Rules**:
- **Ideal size**: 5-15 files per module (good for ILD analysis)
- **Too small**: <3 files → merge with parent or related module
- **Too large**: >20 files → split into sub-modules

**Module Identification Strategy**:

1. **Start with leaf directories** (directories containing source files)
2. **Group by subdirectories** if parent has multiple subdirs
3. **Apply size limits**:
   - If directory has >20 files AND has subdirectories → split by subdirectories
   - If directory has <5 files AND no subdirectories → may merge with siblings

**Examples**:
```
src/services/core/               (43 files - TOO LARGE)
├── processor/                   → Module: "processor" (5 files) ✓
├── analyzer/                    → Module: "analyzer" (10 files) ✓
├── validator/                   → Module: "validator" (5 files) ✓
└── [Main.java, App.java]        → Module: "core-entry" (2 files) ✓

src/commands/                    (6 files - GOOD SIZE)
                                 → Module: "commands" (6 files) ✓
```

**Priority for ILD**:
- Prefer **subdirectory-based modules** for better cohesion
- Each module should have clear, single responsibility

#### B. Infer Module Purpose

Based on directory names, classify the module's **type** (not priority):

**Core Business Logic** (`type: "core"`):
- Keywords: `services`, `domain`, `business`, `core`, `usecases`, `application`, `handlers`, `processors`
- Examples: `src/services/`, `domain/`, `app/core/`

**Data/Model Layer** (`type: "data"`):
- Keywords: `models`, `entities`, `schema`, `database`, `db`, `repositories`, `dao`, `orm`
- Examples: `src/models/`, `entities/`, `data/`

**API/Interface Layer** (`type: "api"`):
- Keywords: `api`, `routes`, `controllers`, `views`, `handlers`, `endpoints`
- Examples: `api/`, `controllers/`, `routes/`

**Utility/Infrastructure** (`type: "utility"`):
- Keywords: `utils`, `helpers`, `common`, `shared`, `lib`, `tools`, `config`
- Examples: `utils/`, `lib/`, `common/`

**Frontend Components** (`type: "frontend"`):
- Keywords: `components`, `pages`, `layouts`, `hooks`, `store`

**Note**: Type classification helps with DLD aggregation later (e.g., all "data" modules might form a "Data Access Layer" component).

#### C. Calculate Module Priority

Each module needs a **priority** field to determine ILD generation depth.

**Priority Scoring Algorithm**:

```
Base Score = 0

1. Type-based score:
   - core: +50 points
   - data: +40 points
   - api: +30 points
   - utility: +10 points

2. Size-based score:
   - Lines > 500: +30 points
   - Lines 200-500: +20 points
   - Lines 100-200: +10 points
   - Lines < 100: +0 points

3. Dependency-based score (from imports):
   - Referenced by 5+ other modules: +20 points
   - Referenced by 3-4 modules: +10 points
   - Referenced by 1-2 modules: +5 points
   - Not referenced: +0 points

4. Naming-based score:
   - Contains keywords (service, manager, handler, processor, controller): +15 points
   - Contains keywords (helper, util, constant, config): -10 points

Final Priority Classification:
- Score >= 80: "critical" (full ILD with all 4 templates)
- Score 50-79: "important" (ILD with OST + FST + LST, skip SST if simple)
- Score 30-49: "minor" (ILD with OST + FST only)
- Score < 30: "skip" (mention in summary only, no ILD)
```

**Add to JSON**:
```json
{
  "name": "Diagram Generator",
  "priority": "critical",
  "priority_score": 95,
  "priority_reasoning": "core type (50) + large size (30) + high references (20) + key naming (15)"
}
```

#### D. Handle Multi-Language Projects

If multiple languages detected:
- Group by language first, then by module
- Example structure:
```
  Backend (Python):
    - Core: src/services/
    - Data: src/models/
  Frontend (JavaScript):
    - Components: src/components/
    - Pages: src/pages/
  Scripts (Shell):
    - Deployment: scripts/
```

#### D. Handle Special Cases

**Microservices**: Treat each service as separate module group
**Monorepo**: Treat each package/app as separate

**Root-level files**:
- Group as "Entry Points" or "Root"
- Examples: `main.py`, `app.py`, `server.js`, `index.js`

## Step 5: Generate File Inventory

Create `.reversekit/scan/file_inventory.json`:
```json
{
  "scan_date": "2025-01-15",
  "total_files_scanned": 1250,
  "source_files": 487,
  "test_files": 125,
  "total_source_lines": 45230,
  "total_test_lines": 8940,
  "languages": {
    "Java": {
      "files": 52,
      "lines": 3337
    }
  },
  "modules": [
    {
      "name": "Core Processor",
      "path": "src/main/java/core/processor",
      "language": "Java",
      "type": "core",
      "priority": "critical",
      "priority_score": 95,
      "file_count": 5,
      "total_lines": 450
    },
    {
      "name": "Business Logic",
      "path": "src/main/java/business",
      "language": "Java",
      "type": "core",
      "priority": "important",
      "priority_score": 75,
      "file_count": 10,
      "total_lines": 890
    }
  ]
}
```

**Important**:
- Module name should be human-readable (infer from directory)
- Only include source code files
- Sort modules by priority, then by size

## Step 6: Generate Scan Summary

Using template [scan-summary-template.md](templates/scan-summary-template.md), create:

`.reversekit/scan/scan_summary.md`

### Fill Template Placeholders

**{{SCAN_DATE}}**: Current date in ISO format (e.g., "2026-02-27")

**{{LANGUAGES}}**: Comma-separated list of all languages detected (e.g., "Java, Python, Shell")

**{{SOURCE_FILES}}**: Count of source files only (exclude tests, configs, docs)

**{{SOURCE_PERCENTAGE}}**: Percentage of source files out of total files scanned (e.g., "38")

**{{TEST_FILES}}**: Count of test files (e.g., "125")

**{{TEST_PERCENTAGE}}**: Percentage of test files out of total files scanned (e.g., "10")

**{{SOURCE_LINES}}**: Sum of lines in source files only (exclude tests)

**{{TEST_LINES}}**: Sum of lines in test files

**{{LANGUAGE_BREAKDOWN}}**: Table format:
```markdown
| Language | Source Files | Lines | Test Files | Test Lines |
|----------|--------------|-------|------------|------------|
| Java     | 140          | 25,430| 85         | 8,500      |
| Python   | 5            | 320   | 0          | 0          |
```

**{{DIRECTORY_DISTRIBUTION}}**: Table of top-level directories
```markdown
| Directory | Files | Lines | Type | Languages |
|-----------|-------|-------|------|-----------|
| src/services/ | 85 | 12,400 | Core | Python |
| src/models/ | 45 | 6,200 | Data | Python |
```

**{{CORE_MODULES}}** / **{{DATA_MODULES}}** / **{{API_MODULES}}** / **{{UTILITY_MODULES}}**: Markdown list (use `_No X modules identified_` if none)
```markdown
- **Service Handler** (`src/services/handler/`) - Java, 8 files, 1,234 lines
- **Business Logic** (`src/business/`) - Java, 6 files, 890 lines
```

**{{FRONTEND_SECTION}}**: If frontend detected (JS/TS with `components/`), add:
```markdown
### Frontend Components
- **UI Components** (`src/components/`) - React, 45 files, 3,200 lines
```
If no frontend: `<!-- No frontend detected, section omitted -->`

**{{TEST_COVERAGE}}**: Use `_No test files detected_` if none
```markdown
- **Test Files**: 85 (37% of source files)
- **Test Lines**: 8,500 (33% of source lines)
- **Test/Source Ratio**: 1:1.6
```

**{{STATISTICS}}**: Summary bullets
```markdown
- **Total Modules**: 12 (4 core, 3 data, 2 api, 3 utility)
- **Average File Size**: 181 lines
- **Code Organization**: Well-structured with clear separation of concerns
```

## Step 7: Completion Message

Present to user:
```
✅ Code scan completed successfully!

Scan Results:
- Languages detected: [list]
- Source files: [count] ([X]% of total files)
- Total source lines: [count]
- Modules identified: [count]

Generated files:
1. .reversekit/scan/file_inventory.json
   → Structured data (for programmatic use)

2. .reversekit/scan/scan_summary.md
   → Human-readable overview
```

## Step 8: Trigger Handoff

Use the `AskUserQuestion` tool to ask the user if they want to proceed to the next step:

```yaml
questions:
  - question: "Would you like to proceed with the next step: Generate Implementation Level Design (ILD)?"
    header: "Next step"
    options:
      - label: "Generate ILD"
        description: "Proceed to generate detailed specifications for each module identified in the scan"
      - label: "Stop here"
        description: "End the scan phase for now"
```

After receiving the user's response:

- **If user selected "Generate ILD"**: Immediately invoke the `Skill` tool with `skill="reversekit-ild"`. Do not generate ILD content yourself — let the skill handle it.
- **If user selected "Stop here"**: End the session and inform the user they can resume later by running `/reversekit-ild`.

## Important Rules

- **Support multiple languages** - don't assume single language
- **Skip non-source files** - ignore configs, docs, build artifacts
- **Infer intelligently** - use directory names and patterns
- **Be conservative** - if unsure about classification, mark as "[Needs review]"
- **Group logically** - related files should be in same module
- **Note frontend separately** - if detected, call it out

Begin by running the data collection script.
