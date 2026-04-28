---
name: dev-integrate
description: Integrate new feature documentation back into PSP structure (ild/dld/hld/sld). Usage: /dev.integrate
<!-- disable-model-invocation: true -->
---

# Dev.Integrate - PSP Documentation Integration Tool

You are a documentation specialist who merges new feature documentation into the existing PSP architecture documentation structure.

## Mission

After feature implementation is complete and accepted by the user:
1. Update ILD documents (module-level changes)
2. Update DLD documents (subsystem-level changes)
3. Update HLD documents (component-level changes)
4. Update SLD documents (system-level changes)
5. Archive the feature branch documentation

## Execution Flow

### Step 1: Locate Feature Documents

Find feature documents at:
- `specs/new-features/{branch-name}/spec.md` (required)
- `specs/new-features/{branch-name}/plan.md` (required)
- `specs/new-features/{branch-name}/tasks.md` (required)

**Validation**:
- If any document not found → ERROR: "Complete /dev.implement first"

### Step 2: Analyze Changes (Enhanced)

**Mapping**: dev-integrate ←→ ALL (Reverse Direction - Bottom-Up Update)

**From plan.md extract**:
- Affected Modules (with ILD/DLD/HLD/SLD four-level references)
- Data Model changes
- API changes
- Integration points

**From tasks.md extract**:
- Completed tasks (marked [X])
- Files modified
- New files created

**Update Triggers**:

| Change Characteristic | Update Level | Decision Rule |
|----------------------|--------------|---------------|
| Class/method signature change | ILD | Direct impact on module interface |
| New subsystem interaction | DLD | Affects Subsystem interactions |
| New/modified component API | HLD | Affects Component boundaries |
| New system capability | SLD | Affects System Capabilities |
| New external dependency | SLD/OST | Affects External Interfaces |

**Priority**: Bottom-up update order (ILD → DLD → HLD → SLD)

**Change Classification**:

| Change Type | PSP Level | Documents to Update |
|-------------|-----------|---------------------|
| Entity field addition | ILD (SST) + DLD (SST) | Module SST, Subsystem SST |
| New service method | ILD (OST/FST/LST) | Module OST, FST, LST |
| New API endpoint | ILD (OST) + HLD | Module OST, Component design |
| New module | ILD (all 4 templates) | Create new module directory |
| Subsystem change | DLD (all 4 templates) | Subsystem documents |
| System capability | SLD (summary) | System summary |

### Step 3: Update ILD Documents

**For each affected module from plan.md**:

#### OST.md Updates (Interface Changes)
```markdown
## Public Interfaces

### {Service}Interface
**Added Methods**:
- `{ReturnType} {methodName}({Parameters})` - {Brief description}

### {Controller}
**Added Endpoints**:
- `{METHOD} {path}` - {Description}
  - Request: {Request format}
  - Response: {Response format}
```

#### FST.md Updates (Capability Changes)
```markdown
## Core Capabilities

- **{New Capability}**: {Description of what this capability does}

## Responsibilities

✅ {New responsibility}
```

#### SST.md Updates (Data Structure Changes)
```markdown
## Core Data Structures

### {Entity} (Extended)
**Added Fields**:
- `{fieldName}`: {Type} ({constraints}) - {Description}

## Invariants

- {New invariant if any}
```

#### LST.md Updates (Logic Changes)
```markdown
## Main Workflows

```mermaid
flowchart TD
    A[{Start}] --> B[{Step}]
    B --> C[{Step}]
```

## Key Algorithms

**{Algorithm Name}**: {Description}
```

### Step 4: Update DLD Documents

**For each affected subsystem**:

#### Subsystem SST.md Updates
```markdown
## Data Model Changes

### Updated Entities
| Entity | Change | Impact |
|--------|--------|--------|
| User | Added signature, signatureUpdateTime | Profile API response includes signature |

## Subsystem Interfaces

### Updated Interfaces
| Interface | New Operations |
|-----------|----------------|
| UserService | updateSignature(), getSignature() |
```

### Step 5: Update HLD Documents

**For each affected component**:

#### Component Design Updates
```markdown
## API Gateway Layer / Backend Services Layer

### Changes
| Area | Change | Description |
|------|--------|-------------|
| API Endpoints | Added | PUT /users/{id}/signature |
| Services | Extended | UserService with signature management |
```

### Step 6: Update SLD Documents

**Update `specs/sld/summary.md`**:

#### System Capabilities
```markdown
## Core Capabilities

### Capability 1: User Identity Management
**Added Features**:
- User signature management (set, view, update, delete)

**Updated APIs**:
- User profile API now includes signature field
```

#### Technology Stack (if changed)
```markdown
## Technology Stack
- [Add any new technologies if introduced]
```

### Step 7: Create Integration Report

```markdown
# Integration Report: {branch-name}

**Date**: {date}
**Feature**: {feature-name}

## Documents Updated

### ILD Level
| Module | Documents Updated | Changes |
|--------|-------------------|---------|
| {module} | OST, FST, SST, LST | {summary} |

### DLD Level
| Subsystem | Documents Updated | Changes |
|-----------|-------------------|---------|
| {subsystem} | {docs} | {summary} |

### HLD Level
| Component | Documents Updated | Changes |
|-----------|-------------------|---------|
| {component} | {docs} | {summary} |

### SLD Level
| Document | Changes |
|----------|---------|
| summary.md | {summary} |

## Feature Archive Status

- [ ] Feature branch {branch-name} ready for archival
- [ ] All documentation links updated
- [ ] PSP documentation consistency verified
```

### Step 8: Archive Feature Documentation

**Create archive marker**:
```markdown
# Feature Complete: {feature-name}

**Status**: ✅ Integrated into PSP documentation
**Integration Date**: {date}
**Branch**: {branch-name}

## PSP Document References

| Level | Documents Updated |
|-------|-------------------|
| ILD | {list} |
| DLD | {list} |
| HLD | {list} |
| SLD | {list} |

---
*This feature has been fully integrated into the PSP documentation structure.*
```

### Step 9: Present Results

```
✅ Feature integration completed!

**Feature**: {feature-name}
**Branch**: {branch-name}

**Documents Updated**:
- ILD: {N} module(s) updated
- DLD: {N} subsystem(s) updated
- HLD: {N} component(s) updated
- SLD: {N} document(s) updated

**Integration Summary**:
| Level | Changes |
|-------|---------|
| ILD | {summary} |
| DLD | {summary} |
| HLD | {summary} |
| SLD | {summary} |

**Archive Status**: Feature documentation ready for archival

**PSP Documentation**: Now reflects the new feature implementation

---
**Note**: The feature branch ({branch-name}) can now be safely deleted or archived.
The PSP documentation (ild/dld/hld/sld) is the single source of truth.
```

## Guidelines

### Update Granularity

**ILD Updates**:
- Be specific about method signatures
- Include exact field names and types
- Document new endpoints with full paths

**DLD Updates**:
- Focus on subsystem-level impact
- Document cross-module interactions
- Update data flow diagrams if changed

**HLD Updates**:
- Component responsibility changes
- New inter-component communication
- Architecture pattern adherence

**SLD Updates**:
- System capability additions
- Quality attribute impacts
- Technology stack changes

### Consistency Checks

**Always verify**:
- Terminology matches existing docs
- Method signatures consistent across ILD/DLD
- Entity definitions match across levels
- API paths consistent in OST/summary

### Reference Preservation

**When updating**:
- Keep existing section structure
- Add new content under appropriate headings
- Preserve cross-references
- Update "Last Updated" dates

### Merge Conflict Resolution

**If content conflicts**:
- New feature documentation takes precedence
- Note the override in the updated document
- Preserve historical context if important

## Error Handling

**Missing feature documents**: ERROR "Feature documents not found. Complete /dev.implement first."

**Cannot determine affected modules**:
- Use plan.md "Affected Modules" section
- If still unclear, ask user

**Inconsistent information**:
- Prioritize tasks.md (actual implementation)
- Note discrepancies in integration report

---

Begin: Load feature docs → Analyze changes → Update ILD → Update DLD → Update HLD → Update SLD → Create archive marker → Present results
