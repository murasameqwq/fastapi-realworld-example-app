# Tasks: {{FEATURE_NAME}}

**Branch**: `{{BRANCH_NAME}}` | **Input**: [plan.md](./plan.md), [spec.md](./spec.md)

---

## Format: `[ID] [P?] [Story] Description`

- **[P]**: Can run in parallel (different files, no dependencies)
- **[Story]**: User story label - [US1], [US2], [US3] (maps to spec.md priorities P1, P2, P3)
- File paths are relative to repository root

---

## Phase 1: Setup (Shared Infrastructure)

**Purpose**: Prepare for feature implementation

- [ ] T001 [P] Verify database migration script for {{ENTITY_CHANGE}} in specs/new-features/{{BRANCH_NAME}}/migration.sql
- [ ] T002 [P] Review affected modules in specs/ild/{{MODULE_1}}/ and specs/ild/{{MODULE_2}}/

---

## Phase 2: Foundational (Blocking Prerequisites)

**Purpose**: Core changes that MUST be complete before user story implementation

**⚠️ CRITICAL**: No user story work can begin until this phase is complete

- [ ] T003 Execute database migration: ALTER TABLE {{TABLE}} ADD COLUMN {{COLUMN}}
- [ ] T004 [P] Update JPA Entity {{ENTITY_NAME}} with new fields in {{ENTITY_FILE_PATH}}
- [ ] T005 [P] Update UserVO with new fields in {{VO_FILE_PATH}}
- [ ] T006 [P] Update UserDTO with new fields in {{DTO_FILE_PATH}}

**Checkpoint**: Foundation ready - user story implementation can now begin

---

## Phase 3: User Story 1 - {{US1_TITLE}} (Priority: P1) 🎯 MVP

**Goal**: {{US1_GOAL}}

**Independent Test**: {{US1_TEST}}

### Implementation for User Story 1

- [ ] T007 [P] [US1] Add signature validation method in {{SERVICE_UTIL_PATH}}
- [ ] T008 [US1] Implement updateSignature() in {{SERVICE_IMPL_PATH}}
- [ ] T009 [US1] Add signature sanitization to prevent XSS in {{SERVICE_IMPL_PATH}}
- [ ] T010 [US1] Implement PUT /users/{id}/signature endpoint in {{CONTROLLER_PATH}}
- [ ] T011 [US1] Add integration test for signature update in {{TEST_PATH}}
- [ ] T012 [US1] Verify signature persistence with database query test

**Checkpoint**: User Story 1 is fully functional and independently testable

---

## Phase 4: User Story 2 - {{US2_TITLE}} (Priority: P2)

**Goal**: {{US2_GOAL}}

**Independent Test**: {{US2_TEST}}

### Implementation for User Story 2

- [ ] T013 [P] [US2] Add getSignature() method in {{SERVICE_IMPL_PATH}}
- [ ] T014 [US2] Return signature in user profile response in {{CONTROLLER_PATH}}
- [ ] T015 [US2] Add test for signature retrieval

**Checkpoint**: User Stories 1 AND 2 both work independently

---

## Phase 5: User Story 3 - {{US3_TITLE}} (Priority: P3)

**Goal**: {{US3_GOAL}}

**Independent Test**: {{US3_TEST}}

### Implementation for User Story 3

- [ ] T016 [P] [US3] Add deleteSignature() method in {{SERVICE_IMPL_PATH}}
- [ ] T017 [US3] Implement signature update logging in {{SERVICE_IMPL_PATH}}
- [ ] T018 [US3] Add test for signature deletion and logging

**Checkpoint**: All user stories are independently functional

---

## Phase N: Polish & Cross-Cutting Concerns

**Purpose**: Improvements and cleanup

- [ ] T019 [P] Update API documentation with new endpoints
- [ ] T020 Code cleanup and refactoring
- [ ] T021 Verify backward compatibility with existing API clients
- [ ] T022 Performance verification (<50ms p95 for signature operations)

---

## Dependencies & Execution Order

### Phase Dependencies

| Phase | Dependencies | Blocks |
|-------|--------------|--------|
| Setup (Phase 1) | None | None |
| Foundational (Phase 2) | Setup complete | All User Stories |
| User Story 1 (Phase 3) | Foundational complete | User Story 2, 3 |
| User Story 2 (Phase 4) | Foundational complete | User Story 3 |
| User Story 3 (Phase 5) | Foundational complete | None |
| Polish (Phase N) | All user stories complete | None |

### User Story Dependencies

- **User Story 1 (P1)**: No dependency on other stories → **MVP**
- **User Story 2 (P2)**: Independent of P1, can run in parallel after Foundational
- **User Story 3 (P3)**: Independent of P1/P2, can run in parallel after Foundational

### Within Each User Story

1. Models/Entities (marked [P]) before Services
2. Services before Endpoints
3. Core implementation before Integration tests
4. Story complete before moving to next priority

### Parallel Opportunities

- All Setup tasks marked [P] can run in parallel
- All Foundational tasks marked [P] can run in parallel
- Once Foundational is complete, all user stories can start in parallel
- All tasks within a story marked [P] can run in parallel

---

## Implementation Strategy

### MVP First (User Story 1 Only)

1. Complete Phase 1: Setup
2. Complete Phase 2: Foundational (CRITICAL - blocks all stories)
3. Complete Phase 3: User Story 1
4. **STOP and VALIDATE**: Test User Story 1 independently
5. Deploy if ready

### Incremental Delivery

1. Setup + Foundational → Foundation ready
2. Add User Story 1 → Test → Deploy (MVP!)
3. Add User Story 2 → Test → Deploy
4. Add User Story 3 → Test → Deploy

Each story adds value without breaking previous stories.

---

## Task Summary

| Phase | Task Count | Description |
|-------|------------|-------------|
| Setup | {{N}} | Prepare for implementation |
| Foundational | {{N}} | Entity/DTO/VO updates |
| User Story 1 | {{N}} | {{US1_TITLE}} |
| User Story 2 | {{N}} | {{US2_TITLE}} |
| User Story 3 | {{N}} | {{US3_TITLE}} |
| Polish | {{N}} | Cross-cutting concerns |
| **Total** | **{{N}}** | |

---

**Next**: Run `/dev.implement` to start executing tasks in priority order.
