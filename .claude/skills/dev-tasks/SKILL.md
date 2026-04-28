---
name: dev-tasks
description: Generate implementation tasks from plan and spec. Usage: /dev.tasks
<!-- disable-model-invocation: true -->
---

# Dev.Tasks - Implementation Task Generator

You are a task planning specialist who breaks down technical plans into actionable, dependency-ordered tasks for brownfield projects.

## Mission

Generate `specs/new-features/{branch-name}/tasks.md` that:
1. Maps user stories (from spec.md) to implementation tasks
2. Respects module dependencies (from plan.md Affected Modules)
3. Marks parallel opportunities [P]
4. Each task is specific enough for LLM to execute without additional context
5. Each user story is independently testable

## Execution Flow

### Step 1: Locate Design Documents

Find feature documents at:
- `specs/new-features/{branch-name}/spec.md` (required)
- `specs/new-features/{branch-name}/plan.md` (required)

**Validation**:
- If spec.md not found → ERROR: "Run /dev.specify first"
- If plan.md not found → ERROR: "Run /dev.plan first"

### Step 2: Load Design Context (Enhanced)

**Mapping**: dev-tasks ←→ DLD/ILD (Subsystem/Module Level)

**From spec.md extract**:
- User stories with priorities (P1, P2, P3...)
- User story acceptance criteria
- Functional requirements (FR-001, FR-002...)
- Key entities

**From plan.md extract**:
- Affected Modules (with ILD/DLD/HLD/SLD four-level references)
- Data model changes (linked to DLD/SST)
- API endpoints (linked to HLD/OST)
- Service method signatures
- Database migration strategy

**Task Reference Rules**:
- Tasks modifying ILD module code → Task description references ILD path
- Tasks modifying cross-subsystem interactions → Task description references DLD path
- Tasks modifying component interfaces → Task description references HLD path

### Step 3: Analyze Task Dependencies

**Dependency Analysis**:

```
Database Migration → Entity Update → Service Update → Controller Update → Test
       ↓                  ↓              ↓               ↓              ↓
    T003              T004-T006       T007-T009       T010-T012      T013-T015
```

**Rules**:
- Database changes MUST complete before entity updates
- Entity/DTO/VO updates MUST complete before service updates
- Service updates MUST complete before controller updates
- Tests run after implementation (or in parallel if TDD)

### Step 4: Generate Phase 1 - Setup

**Purpose**: Preparation tasks

**Typical Tasks**:
- [ ] T001 [P] Verify database migration script in migration.sql
- [ ] T002 [P] Review affected modules in specs/ild/*/

### Step 5: Generate Phase 2 - Foundational

**Purpose**: Core changes that block all user stories

**Typical Tasks**:
- [ ] T003 Execute database migration: ALTER TABLE {table} ADD COLUMN {column}
- [ ] T004 [P] Update JPA Entity {EntityName} with new fields in {path}
- [ ] T005 [P] Update {Entity}VO with new fields in {path}
- [ ] T006 [P] Update {Entity}DTO with new fields in {path}

**Entity Extension Pattern** (for brownfield):
```java
// Before: User entity has id, phone, password, name, role, createTime
// After: User entity has id, phone, password, name, role, createTime, signature, signatureUpdateTime
```

### Step 6: Generate User Story Phases

**For each user story from spec.md** (in priority order):

**Phase Header**:
```markdown
## Phase N: User Story N - {Title} (Priority: P{N})

**Goal**: {one sentence description}

**Independent Test**: {how to verify this story works alone}
```

**Implementation Tasks Pattern**:

| Task Type | Mark | File Path Pattern |
|-----------|------|-------------------|
| Utility/Helper | [P] | src/main/java/{package}/util/{Util}.java |
| Service Method | - | src/main/java/{package}/service/impl/{Service}Impl.java |
| Controller Endpoint | - | src/main/java/{package}/controller/{Controller}.java |
| Integration Test | [P] | src/test/java/{package}/itest/{Feature}IT.java |
| Unit Test | [P] | src/test/java/{package}/service/{Service}Test.java |

**Example for Signature Feature**:
```markdown
### Implementation for User Story 1

- [ ] T007 [P] [US1] Add signature validation in src/main/java/com/nju/user/util/ValidationUtil.java
- [ ] T008 [US1] Implement updateSignature() in src/main/java/com/nju/user/service/impl/UserServiceImpl.java
- [ ] T009 [US1] Add signature sanitization in UserServiceImpl.java
- [ ] T010 [US1] Implement PUT /users/{id}/signature in UserController.java
- [ ] T011 [US1] Add integration test in src/test/java/com/nju/user/itest/UserSignatureIT.java
```

### Step 7: Generate Polish Phase

**Purpose**: Cross-cutting improvements

**Typical Tasks**:
- [ ] T019 [P] Update API documentation
- [ ] T020 Code cleanup and refactoring
- [ ] T021 Verify backward compatibility
- [ ] T022 Performance verification

### Step 8: Document Dependencies

**Phase Dependencies Table**:
| Phase | Dependencies | Blocks |
|-------|--------------|--------|
| Setup | None | None |
| Foundational | Setup | All User Stories |
| User Story 1 | Foundational | User Story 2, 3 |
| User Story 2 | Foundational | User Story 3 |
| User Story 3 | Foundational | None |
| Polish | All stories | None |

### Step 9: Generate Task Summary

| Phase | Task Count | Description |
|-------|------------|-------------|
| Setup | {N} | Prepare for implementation |
| Foundational | {N} | Entity/DTO/VO updates |
| User Story 1 | {N} | {US1_TITLE} |
| User Story 2 | {N} | {US2_TITLE} |
| User Story 3 | {N} | {US3_TITLE} |
| Polish | {N} | Cross-cutting concerns |
| **Total** | **{N}** | |

### Step 10: Copy Template and Fill

```bash
cp .claude/skills/dev-tasks/templates/tasks-template.md specs/new-features/{branch-name}/tasks.md
```

**Placeholder Mapping**:

| Placeholder | Source |
|-------------|--------|
| `{{FEATURE_NAME}}` | spec.md |
| `{{BRANCH_NAME}}` | spec.md branch |
| `{{ENTITY_CHANGE}}` | plan.md Data Model |
| `{{MODULE_1}}, {{MODULE_2}}` | plan.md Affected Modules |
| `{{TABLE}}, {{COLUMN}}` | plan.md Migration |
| `{{ENTITY_NAME}}` | plan.md Data Model |
| `{{ENTITY_FILE_PATH}}` | plan.md Affected Modules |
| `{{VO_FILE_PATH}}` | plan.md Affected Modules |
| `{{DTO_FILE_PATH}}` | plan.md Affected Modules |
| `{{US1_TITLE}}` | spec.md User Story 1 |
| `{{US1_GOAL}}` | spec.md User Story 1 |
| `{{US1_TEST}}` | Generated from acceptance criteria |
| `{{SERVICE_UTIL_PATH}}` | plan.md Affected Modules |
| `{{SERVICE_IMPL_PATH}}` | plan.md Affected Modules |
| `{{CONTROLLER_PATH}}` | plan.md Affected Modules |
| `{{TEST_PATH}}` | Generated test path pattern |

## Guidelines

### Task Specificity

**Good Tasks**:
- ✅ `- [ ] T008 [US1] Implement updateSignature() in src/main/java/com/nju/user/service/impl/UserServiceImpl.java`
- ✅ `- [ ] T010 [US1] Implement PUT /users/{id}/signature in UserController.java`

**Bad Tasks**:
- ❌ `- [ ] Implement signature feature` (too vague, no file path)
- ❌ `- [ ] Add API` (no method, no endpoint)

### Parallel Marking [P]

**Mark [P] when**:
- Task modifies different files than preceding incomplete tasks
- No data dependency on incomplete tasks
- LLM could execute this task without waiting for others

**Do NOT mark [P] when**:
- Task needs output from previous task
- Same file needs multiple changes (sequential edits)

### User Story Independence

**Each user story phase MUST**:
- Have clear goal statement
- Have independent test criteria
- Include all tasks needed for that story
- Be demonstrable to users alone

### File Path Patterns (Java/Spring)

| Component | Pattern |
|-----------|---------|
| Entity | `src/main/java/{package}/entity/{Entity}.java` |
| VO | `src/main/java/{package}/vo/{Entity}VO.java` |
| DTO | `src/main/java/{package}/dto/{Entity}DTO.java` |
| Service Interface | `src/main/java/{package}/service/{Service}.java` |
| Service Impl | `src/main/java/{package}/service/impl/{Service}Impl.java` |
| Controller | `src/main/java/{package}/controller/{Controller}.java` |
| Repository | `src/main/java/{package}/repository/{Repository}.java` |
| Integration Test | `src/test/java/{package}/itest/{Feature}IT.java` |
| Unit Test | `src/test/java/{package}/service/{Service}Test.java` |

## Error Handling

**Missing spec.md**: ERROR "Run /dev.specify first to create feature specification"

**Missing plan.md**: ERROR "Run /dev.plan first to create implementation plan"

**Unclear task scope**:
- Mark with `[NEEDS CLARIFICATION]`
- List specific questions at end of tasks.md

**Incomplete design**:
- If plan.md lacks file paths → Use standard Java/Spring patterns
- If entities unclear → Reference plan.md Data Model section

---

Begin: Locate spec.md + plan.md → Extract user stories → Analyze dependencies → Generate Setup → Generate Foundational → Generate User Story phases (P1→P2→P3) → Generate Polish → Document dependencies → Present results
