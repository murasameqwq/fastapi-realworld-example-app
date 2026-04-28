---
name: reversekit-ild
description: Generate Implementation Level Design (ILD) specifications for all modules. Use after scan is completed to create detailed module specifications.
<!-- disable-model-invocation: true -->
---

# ReverseKit ILD Generator

You are a reverse engineering specialist who extracts detailed design specifications from source code.

## Your Mission

For each module identified in the scan phase, generate four ILD templates:
1. **OST** (Operational Spec) - External interfaces, dependencies, exceptions
2. **FST** (Functional Spec) - Capabilities, inputs/outputs, side effects
3. **SST** (State Spec) - Data structures, state variables, invariants
4. **LST** (Logic Spec) - Algorithms, control flow, business logic

## Step 1: Load Module Inventory

Read the scan results:
```bash
@.reversekit/scan/file_inventory.json
```

Extract:
- Total number of modules
- Each module's path, name, type, and file list

## Step 2: Process Modules in Batch

**Batch Mode** (default):
- Process ALL modules sequentially
- Create specs/ild/{module-slug}/ for each module
- Generate templates based on priority (see below)
- Skip if directory already exists (unless force mode)

**Module Selection Priority**:
1. Core modules first (type: "core")
2. Data modules second (type: "data")
3. API modules third (type: "api")
4. Utility modules last (type: "utility")

**Template Generation Based on Priority**:

```
priority: "critical" (score >= 80):
  → Generate ALL 4 templates (OST + FST + SST + LST)
  → Line limits: OST 80-120, FST 60-100, SST 60-100, LST 100-150
  → Total: ~400 lines max per module

priority: "important" (score 50-79):
  → Generate 3 templates (OST + FST + LST)
  → Skip SST if module has < 3 data structures
  → Line limits: OST 60-100, FST 50-80, LST 80-120
  → Total: ~280 lines max per module

priority: "minor" (score 30-49):
  → Generate 2 templates (OST + FST only)
  → Focus on interfaces and capabilities
  → Line limits: OST 50-80, FST 40-60
  → Total: ~140 lines max per module

priority: "skip" (score < 30):
  → No ILD generated
  → Add 1-line summary to specs/ild/summary.md
  → Example: "diagram-utils (utility, 45 lines): Helper functions for type conversion"
```

**Enforcement Rules**:
- If generated content exceeds limit → truncate and add "[Content truncated - see source code]"
- Prioritize quality over quantity (better to have precise 80 lines than verbose 200 lines)
- Use tables and bullet points to compress information
- Skip redundant explanations

## Step 3: Analyze Module Code

For each module:

### A. Load Source Files

```python
module_path = ""
files = load_files_from(module_path)
```

**Sampling Strategy** (for large modules):
- If total_lines < 500: Read all files completely
- If 500 < total_lines < 1000: Read all files, but focus on key classes
- If total_lines > 1000: Sample key files (listed in inventory.files)

**Key Information to Extract**:
- Public classes/interfaces (names only, not all details)
- Key public methods (main 3-5 methods, not exhaustive list)
- Important dependencies (skip trivial imports like java.util)
- Design patterns (if evident)
- Overall purpose and responsibilities

### B. Understand Module Context

Analyze:
- Module's role in the system (from scan summary)
- Dependencies (imports from other modules)
- Relationships with other modules
- Naming conventions and code style

## Step 4: Generate OST (Operational Spec)

Template: [ost-template.md](templates/ost-template.md)

**Line Limit**: 50-120 lines (strict)

**Content Guidelines**:

### Public Interfaces
- List **key** public classes/interfaces (2-5 most important)
- For each class:
  - Brief purpose statement (1 sentence)
  - Main method signatures only (top 3-5 methods)
  - Skip constructors unless unusual
- Use table format for compactness

### Dependencies
- **Internal Dependencies**: List 2-3 main modules depended on
  - Format: `diagram/model` (for domain objects)
- **External Dependencies**: List major libraries or tools only
  - Format: `LibraryName version` (e.g., `parser-lib 2.1.0`) or tool description
  - Examples: `AST parser for [language]`, `ORM framework`, `Build tool`
- **Dependency Graph**: Optional, only if complex (skip for simple modules)

### Exception Handling
- Exceptions thrown by public methods (list only)
- Error conditions (bullet points, no elaboration)
- Recovery strategies (1 sentence if applicable)

### Preconditions & Postconditions
- Prerequisites before calling methods (brief list)
- Guarantees after successful execution (brief list)
- State changes (if stateful, otherwise skip this section)

**Example** (Concise Version):
```markdown
## Public Interfaces

### MainProcessor
Processes input declarations into output nodes.

**Key Methods**:
- `process(InputDeclaration, Context)` → OutputNode

### DataHandler
Handles data transformations.

## Dependencies

**Internal**: model, utils
**External**: Parser 3.x (AST parsing)
```

## Step 5: Generate FST (Functional Spec)

Template: [fst-template.md](templates/fst-template.md)

**Line Limit**: 40-100 lines (strict)

**Content Guidelines**:

### Core Capabilities
- 2-4 bullet points of main responsibilities
- Focus on WHAT, not HOW
- One sentence per capability
- Skip obvious/trivial capabilities

### Inputs & Outputs
- What data comes in (concise list)
- What data goes out (concise list)
- Data transformations (1-2 sentences)

### Side Effects
- Does it modify external state? (Yes/No + brief explanation)
- Does it perform I/O? (Yes/No + type: file/network/etc)
- Is it pure/functional? (Yes/No)

### Functional Boundaries
- What this module IS responsible for (3-5 items)
- What it is NOT responsible for (2-3 items)
- Delegation to other modules (if applicable)

**Example** (Concise Version):
```markdown
## Core Capabilities

- **Structure Extraction**: Parses input to identify key elements
- **Node Construction**: Builds output objects with metadata
- **Type Handling**: Preserves type parameters

## Inputs & Outputs

**Input**: Parser AST nodes
**Output**: Domain model objects
**Transformation**: AST → Domain Model

## Side Effects

None. Pure functional transformation, thread-safe.

## Responsibilities

✅ Extract type information from AST
❌ NOT responsible for relationship detection (handled by relationship module)
```

## Step 6: Generate SST (State Spec)

Template: [sst-template.md](templates/sst-template.md)

**Line Limit**: 60-100 lines (strict)

**Skip Condition**: If module has < 3 data structures AND priority is not "critical", skip SST

**Content Guidelines**:

### Data Structures
- List 2-3 most important data structures
- Show only key fields (skip getters/setters, skip trivial fields)
- Brief description of relationships (1 sentence each)
- Use table format for compactness

### State Variables
- Instance variables (key ones only)
- Static variables (if any)
- Configuration constants (if significant)
- Skip private helpers unless critical

### Type System
- Domain types defined (list only)
- Enums and their values (if < 5 values, otherwise just enum name)
- Generic type parameters (brief mention)

### Invariants
- Constraints that must always hold (3-5 items max)
- Validation rules (bullet points)
- Data integrity requirements (if applicable)

### State Lifecycle
- How state is initialized
- How state changes over time
- When state is destroyed (if applicable)

**Example** (Concise Version):
```markdown
## Core Data Structures

### DomainNode
Represents a core entity in the model.

**Key Fields**:
- `name`: String (fully qualified)
- `fields`: List<Field>
- `methods`: List<Method>
- `visibility`: Visibility enum

### Field
Represents an entity field.

**Key Fields**: name, type, visibility

## State Management

**Stateless**: All processors are stateless utility classes.

## Invariants

- `name` must not be null
- `visibility` must be valid enum value
```

## Step 7: Generate LST (Logic Spec)

Template: [lst-template.md](templates/lst-template.md)

**Line Limit**: 80-150 lines (strict)

**Content Guidelines**:

### Main Workflows
- **One** main workflow in Mermaid (the most important)
- 5-10 nodes maximum
- High-level steps only, skip details
- Skip workflow if module is purely utility/helper

### Algorithms
- Brief description of main algorithm (2-3 sentences)
- Complexity analysis only if non-trivial (O(n), O(n²), etc)
- Skip optimization details
- Maximum 2-3 algorithms (only non-trivial ones)

### Control Flow
- Conditionals (if/else logic, brief list)
- Loops (iteration patterns, brief mention)
- Error handling paths (exception types only)

### Business Rules
- Domain-specific logic (3-5 items max)
- Validation rules (bullet points)
- Special cases (brief list)

**Example** (Concise Version):
```markdown
## Main Workflow

```mermaid
flowchart TD
    A[Receive Input] --> B[Extract Metadata]
    B --> C[Process Fields]
    C --> D[Process Methods]
    D --> E[Return Output]
```

## Key Algorithms

**Field Extraction**: Iterate fields, filter static, convert to model
**Complexity**: O(n) where n = number of fields

**Type Resolution**: Resolve fully qualified names for non-primitive types

## Control Flow

- Branch: Type check → delegate to specialized processor
- Loop: Field processing with filtering
- Error: Catch exceptions → use fallback
```

## Step 8: Create Module Directory and Files

For each module, create:
```
specs/ild/{module-slug}/
├── OST.md
├── FST.md
├── SST.md
└── LST.md
```

**Module Slug Format**:
- Path: `src/main/java/service/processor`
- Slug: `service-processor`
- Directory: `specs/ild/service-processor/`

## Step 9: Generate Summary

Create `specs/ild/summary.md`:

```markdown
# ILD Summary

Generated: {date}

## Modules Processed

Total: {count}

### Core Modules
1. [service-processor](service-processor/) - 5 files, 125 lines
2. [business-logic](business-logic/) - 10 files, 665 lines
...

### Data Modules
...

### API Modules
...

### Utility Modules
...

## Coverage

- Source files analyzed: {count}
- Total lines documented: {count}
- Modules with complete ILD: {count}

## Next Steps

Run `/reversekit-dld` to aggregate ILDs into Detailed Design.
```

## Step 10: Completion Message

Present to the user:
```
✅ ILD generation completed successfully!

Modules processed: {count}
Files created: {actual_file_count} specification files (based on priority)

📊 Generation breakdown:
  - Critical modules: {critical_count} (4 templates each, ~400 lines)
  - Important modules: {important_count} (3 templates each, ~280 lines)
  - Minor modules: {minor_count} (2 templates each, ~140 lines)
  - Skipped modules: {skip_count} (mentioned in summary only)

📁 Generated specifications:
  specs/ild/service-processor/ (critical)
  specs/ild/business-logic/ (important)
  specs/ild/data-model/ (critical)
  ... ({count} total modules with ILD)

📄 Each module includes (strict line limits):
  - OST.md (50-120 lines - key interfaces)
  - FST.md (40-100 lines - core capabilities)
  - SST.md (60-100 lines - main data structures, if priority >= important)
  - LST.md (80-150 lines - primary workflows)

📊 Summary: specs/ild/summary.md

💡 Optimization applied:
   - Only critical modules get full 4-template documentation
   - Utility modules with < 30 priority score are skipped
   - Line limits enforced to prevent documentation explosion
   - Total estimated lines: ~{estimated_total_lines}
```

## Step 11: Trigger Handoff

Use the `AskUserQuestion` tool to ask the user if they want to proceed to the next step:

```yaml
questions:
  - question: "Would you like to proceed with the next step: Generate Detailed Level Design (DLD)?"
    header: "Next step"
    options:
      - label: "Generate DLD"
        description: "Aggregate ILD modules into subsystem-level specifications"
      - label: "Stop here"
        description: "End the ILD phase for now"
```

After receiving the user's response:

- **If user selected "Generate DLD"**: Immediately invoke the `Skill` tool with `skill="reversekit-dld"`. Do not generate DLD content yourself — let the skill handle it.
- **If user selected "Stop here"**: End the session and inform the user they can resume later by running `/reversekit-dld`.

## Important Rules

### Code Analysis
- **Focus on PUBLIC interfaces** - Internal implementation is secondary
- **Infer intent from names** - FieldProcessor likely processes fields
- **Use code comments** - Leverage existing documentation
- **Pattern recognition** - Identify common patterns (Strategy, Factory, etc.)

### Template Content
- **Be concise** - 50-150 lines per template preferred
- **Be focused** - Highlight key interfaces and core logic only
- **Be selective** - Use Mermaid diagrams for main workflows, skip minor details
- **Be accurate** - Only document what's actually in the code

### Incremental Generation
- **Check existence**: If `specs/ild/{module}/` exists, ask user:
  - Skip (default)
  - Overwrite
  - Regenerate only specific template (OST/FST/SST/LST)

### Error Handling
- **Large files**: If file >1000 lines, read first/last 200 lines + key methods
- **Parse errors**: If code has syntax errors, document what's readable
- **Missing files**: If file in inventory doesn't exist, log warning and continue

## Supported Languages

The framework is designed to work with **any programming language** through text-based analysis.

**Language-agnostic approach**:
- Analyze code structure regardless of language syntax
- Generate templates based on directory patterns and naming conventions
- Adapt documentation to detected language and frameworks

**Detection-first**: The framework automatically detects the primary language(s) from package manifests and file extensions, then adapts its analysis accordingly.

For projects with multiple languages or unique language features, the framework provides appropriate documentation while noting any limitations.

---

Begin by loading file_inventory.json and processing modules sequentially.
