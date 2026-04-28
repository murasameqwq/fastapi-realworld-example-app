---
name: dev-specify
description: Create feature specification from user input. Usage: /dev.specify <feature description>
<!-- disable-model-invocation: true -->
---

# Dev.Specify - Brownfield Feature Specification Generator

You are a specification-driven development specialist who creates functional specifications for brownfield projects using ReverseKit context.

## User Input

```text
$ARGUMENTS
```

You **MUST** consider the user input before proceeding (if not empty).

## Mission

Generate `specs/new-features/{branch-name}/spec.md` that:
1. Integrates with existing architecture (from ReverseKit docs)
2. Follows existing patterns and conventions
3. Is independently testable (MVP deployable)
4. Uses ReverseKit context for accuracy

## Execution Flow

### 1. Validate Input
If empty → ERROR with usage examples.

### 2. Load ReverseKit Context (by hierarchy level)

**Mapping**: dev-specify ←→ SLD/HLD (System/Component Level)

| Level | Document | Purpose |
|-------|----------|---------|
| SLD/FST | `specs/sld/summary.md` §Core Capabilities | Determine which system capability the new feature belongs to |
| SLD/OST | `specs/sld/OST.md` §External Interfaces | Ensure new API style matches existing interfaces |
| HLD/Summary | `specs/hld/summary.md` | Identify which architectural component the feature belongs to |

**Constraint**: Each new feature MUST be linked to at least one Core Capability in SLD/FST or SLD/summary.md

**Note**: dev-specify focuses on system-level capabilities. DLD/ILD details are loaded by dev-plan and dev-tasks respectively.

### 3. Generate Branch Name
Format: `{number}-{action-noun}`

Extract 2-4 keywords from user input, convert to kebab-case, auto-increment number.

### 4. Create Branch & Directory

```bash
git checkout -b {branch-name}
mkdir -p specs/new-features/{branch-name}/checklists
cp .claude/skills/dev-specify/templates/spec-template.md specs/new-features/{branch-name}/spec.md
cp .claude/skills/dev-specify/templates/checklist-template.md specs/new-features/{branch-name}/checklists/requirements.md
```

This creates:
```
specs/
├── sld/                    # System Level Design (ReverseKit)
├── hld/                    # High Level Design (ReverseKit)
├── dld/                    # Detailed Level Design (ReverseKit)
├── ild/                    # Implementation Level Design (ReverseKit)
└── new-features/           # New Features (Dev workflow)
    └── {branch-name}/
        ├── spec.md
        ├── checklists/
        ├── plan.md
        └── tasks.md
```

### 5. Fill Template Placeholders

| Placeholder | Source |
|-------------|--------|
| `{{FEATURE_NAME}}` | Human-readable from user input |
| `{{BRANCH_NAME}}` | Generated branch name |
| `{{GENERATION_DATE}}` | Current date (ISO) |
| `{{FEATURE_DESCRIPTION}}` | User input verbatim |
| `{{RELATED_SYSTEM_CAPABILITY}}` | specs/sld/summary.md §Capability |
| `{{RELATED_COMPONENT}}` | specs/hld/ summary |
| `{{RELATED_MODULE}}` | specs/ild/ summary |
| `{{EXISTING_ENTITIES_LIST}}` | From SST docs |
| `{{USER_STORIES_SECTION}}` | Generate 1-3 stories (P1/P2/P3) |
| `{{EDGE_CASES_SECTION}}` | Generate 2-4 edge cases |
| `{{FUNCTIONAL_REQUIREMENTS_SECTION}}` | FR-001 through FR-NNN |
| `{{KEY_ENTITIES_SECTION}}` | Existing + new entities |
| `{{INTEGRATION_POINTS_SECTION}}` | API/Service/Repository layers |
| `{{SUCCESS_CRITERIA_SECTION}}` | 2-4 measurable outcomes |
| `{{OUT_OF_SCOPE_SECTION}}` | Explicitly excluded items |
| `{{ASSUMPTIONS_SECTION}}` | Document assumptions |

While filling, identify all aspects that need clarification.

### 6. Clarify with User (AskUserQuestion)

For each ambiguity, use `AskUserQuestion` to get user input:

**Format**:
- Header: "Question [N]: [Topic]"
- Context: Quote relevant spec section
- Question: Specific question
- Options: Table with Option A/B/C and implications

Wait for user response, then fill the spec with user's choices.

### 7. Validate Specification

Validate the spec against checklist items and update `checklists/requirements.md`:
- Mark each item as Pass/Fail
- Document specific issues found (quote spec sections)
- Fill in Validation Results table
- List issues found (if any)

### 8. Handle Validation Results

**If all items pass**: Mark checklist complete, proceed to Step 9.

**If items fail**:
1. List failing items and issues
2. Update spec.md to address each issue
3. Re-run validation (max 3 iterations)
4. If still failing, document in checklist notes and warn user

### 9. Present Results
```
✅ Feature specification generated!

📋 specs/new-features/{branch-name}/spec.md
📍 Validation: specs/new-features/{branch-name}/checklists/requirements.md

Summary:
- User Stories: N (P1: N, P2: N, P3: N)
- Functional Requirements: N
- Key Entities: N (existing: N, new: N)
- Success Criteria: N
- Validation: [✓] Pass | [✗] Needs revision

Next: /dev.plan → /dev.tasks → /dev.implement
```

## Guidelines

### User Stories
- P1: MVP core functionality
- P2: Incremental value
- P3: Polish enhancements
- Each must be independently testable

### Requirements
- MUST for mandatory, SHOULD for recommended
- Each FR independently testable
- No ambiguous terms ("fast" → "<100ms")

### Success Criteria
- Measurable (numbers, percentages, time)
- Technology-agnostic
- User-focused outcomes

### Context Loading

**Hierarchy Mapping** (each dev skill loads only its relevant level):
- **dev-specify** ←→ SLD/HLD (System/Component Level) - Focus: capability ownership
- **dev-plan** ←→ HLD/DLD (Component/Subsystem Level) - Focus: architecture design
- **dev-tasks** ←→ ILD (Module Level) - Focus: task decomposition
- **dev-implement** ←→ ILD + Source Code - Focus: implementation

- Always load ReverseKit docs first
- Reference specific sections ( Capability, Module)
- Maintain terminology consistency

## Error Handling

**Missing Context**: specs/sld/summary.md not found → Run /reversekit-sld first

**Empty Input**: Show usage with examples

**Ambiguous Aspects** (during spec generation): Use AskUserQuestion to clarify on the spot (all ambiguities should be resolved)

---

Begin: Validate input → Load ReverseKit context → Create branch → Fill template → Clarify ambiguities (AskUserQuestion) → Validate → Present results
