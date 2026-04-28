# Implementation Plan: {{FEATURE_NAME}}

**Branch**: `{{BRANCH_NAME}}` | **Date**: {{GENERATION_DATE}} | **Status**: Draft
**Spec**: [spec.md](../spec.md)

---

## Summary

> **Purpose**: Concise overview of the feature and technical approach.

{{SUMMARY_SECTION}}

---

## Technical Context (Fixed Stack)

> **Purpose**: Document the fixed technology stack for this brownfield project.
> Reference: specs/sld/summary.md

| Aspect | Technology |
|--------|------------|
| **Language** | Java 8 |
| **Framework** | Spring Boot 2.6.13, Spring Cloud 2021.0.x |
| **Database** | MySQL 8.0 + Spring Data JPA |
| **Caching** | Redis (cache-aside pattern) |
| **Authentication** | JWT tokens (7-day validity) |
| **API Style** | RESTful JSON with ResultVO wrapper |
| **Deployment** | Docker Compose (dev) / Kubernetes (prod) |

---

## Architecture Constraints Check

> **Purpose**: Verify the plan aligns with existing architecture patterns from ReverseKit.

### Pattern Compliance

| Constraint | Status | Notes |
|------------|--------|-------|
| Layered Architecture (Controller → Service → Repository) | [ ] Pass [ ] N/A | |
| Stateless JWT Authentication | [ ] Pass [ ] N/A | |
| ResultVO Wrapper for API Responses | [ ] Pass [ ] N/A | |
| Cache-Aside Pattern (if caching used) | [ ] Pass [ ] N/A | |
| Transaction Management (@Transactional) | [ ] Pass [ ] N/A | |

### Architecture Violations (if any)

> **Note**: Any violation MUST be justified with clear rationale.

| Violation | Rationale | Approved By |
|-----------|-----------|-------------|
| | | |

---

## Affected Modules

> **Purpose**: Identify which existing modules need modification.
> Reference: specs/ild/*/

### Modules to Modify

| Module | ILD Reference | Changes Required |
|--------|---------------|------------------|
| {{MODULE_1}} | specs/ild/{{module-1-slug}}/ | {{CHANGE_DESC_1}} |
| {{MODULE_2}} | specs/ild/{{module-2-slug}}/ | {{CHANGE_DESC_2}} |

### New Classes/Interfaces

| Class/Interface | Package | Responsibility |
|-----------------|---------|----------------|
| {{NEW_CLASS_1}} | {{PACKAGE}} | {{RESPONSIBILITY}} |
| {{NEW_CLASS_2}} | {{PACKAGE}} | {{RESPONSIBILITY}} |

---

## Data Model Design

> **Purpose**: Define data entities for this feature.
> Reference: specs/dld/*/SST.md, specs/ild/*/SST.md

### Existing Entities (Extension)

> **Note**: For existing entities, only document the changes.

#### {{ENTITY_NAME}} (Extension)

**Source**: specs/ild/{{module-slug}}/SST.md

| New Field | Type | Constraints | Default |
|-----------|------|-------------|---------|
| {{FIELD}} | {{TYPE}} | {{CONSTRAINTS}} | {{DEFAULT}} |

### New Entities (if any)

#### {{ENTITY_NAME}}

| Field | Type | Constraints | Default |
|-------|------|-------------|---------|
| {{FIELD}} | {{TYPE}} | {{CONSTRAINTS}} | {{DEFAULT}} |

**Relationships**:
- {{RELATIONSHIP_DESC}}

---

## Integration Design

> **Purpose**: Describe how modules interact after this feature.
> Reference: specs/ild/*/OST.md

### API Layer Changes

| Endpoint | Method | Request | Response | Auth Required |
|----------|--------|---------|----------|---------------|
| {{ENDPOINT}} | {{METHOD}} | {{REQUEST}} | {{RESPONSE}} | [ ] Yes [ ] No |

### Service Layer Changes

| Method | Signature | Responsibility |
|--------|-----------|----------------|
| {{METHOD}} | `{{SIGNATURE}}` | {{RESPONSIBILITY}} |

### Repository Layer Changes

| Change | Description |
|--------|-------------|
| {{CHANGE}} | {{DESC}} |

### Cross-Cutting Concerns

| Concern | Implementation |
|---------|----------------|
| **Error Handling** | {{ERROR_HANDLING}} |
| **Logging** | {{LOGGING}} |
| **Validation** | {{VALIDATION}} |
| **Security** | {{SECURITY}} |

---

## Key Technical Decisions

> **Purpose**: Document important technical choices and their rationale.

| Decision | Option Chosen | Alternatives Considered | Rationale |
|----------|---------------|------------------------|-----------|
| {{DECISION_1}} | {{CHOSEN}} | {{ALTERNATIVES}} | {{RATIONALE}} |
| {{DECISION_2}} | {{CHOSEN}} | {{ALTERNATIVES}} | {{RATIONALE}} |

---

## Research Notes (Optional)

> **Purpose**: Document any domain-specific research (e.g., OSS integration, Kafka patterns).
> Only present if research was needed.

### {{RESEARCH_TOPIC}}

**Findings**: {{FINDINGS}}

**Best Practices**: {{BEST_PRACTICES}}

---

## Success Criteria (Technical)

> **Purpose**: Measurable technical outcomes.

| Criteria | Target | Measurement |
|----------|--------|-------------|
| **API Performance** | <{{X}}ms p95 | Load testing |
| **Database Impact** | <{{X}}ms query time | Query profiling |
| **Code Coverage** | >{{X}}% | Unit tests |
| **Backward Compatibility** | [ ] Maintained | API testing |

---

## Migration Strategy

> **Purpose**: Plan for database/schema changes.

### Database Changes

| Change | Type | Downtime Required | Rollback Plan |
|--------|------|-------------------|---------------|
| {{CHANGE}} | ALTER TABLE / CREATE TABLE | [ ] Yes [ ] No | {{ROLLBACK}} |

### Data Migration (if any)

{{MIGRATION_DESC}}

---

## Open Issues

> **Purpose**: Track unresolved technical questions.

| Issue | Impact | Resolution Needed By |
|-------|--------|---------------------|
| {{ISSUE}} | {{IMPACT}} | {{DEADLINE}} |

---

## Appendix: ReverseKit References

### Source Documents

- `specs/ild/{{module-slug}}/OST.md` - Module interfaces
- `specs/ild/{{module-slug}}/FST.md` - Module capabilities
- `specs/ild/{{module-slug}}/SST.md` - Data structures
- `specs/ild/{{module-slug}}/LST.md` - Business logic
- `specs/dld/{{subsystem}}/SST.md` - Subsystem state

---

**Next**: Run `/dev.tasks` to break down this plan into actionable tasks.
