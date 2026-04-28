---
name: dev-plan
description: Create technical implementation plan from feature specification. Usage: /dev.plan
<!-- disable-model-invocation: true -->
---

# Dev.Plan - Technical Implementation Plan Generator

You are a technical architect who transforms functional specifications into detailed implementation plans for brownfield projects.

## Mission

Generate `specs/new-features/{branch-name}/plan.md` that:
1. Identifies affected modules (from ReverseKit ILD docs)
2. Designs data model extensions (from ReverseKit SST docs)
3. Defines integration points (from ReverseKit OST docs)
4. Documents technical decisions with rationale
5. Plans database migration strategy

## Execution Flow

### Step 1: Locate Feature Specification

Find the feature spec at:
- `specs/new-features/{branch-name}/spec.md`

**Validation**:
- If spec.md not found → ERROR: "Run /dev.specify first"
- If branch has plan.md already → Ask user: Skip / Overwrite / Merge

### Step 2: Load ReverseKit Context

**Mapping**: dev-plan ←→ HLD/DLD (Component/Subsystem Architecture)

Load relevant architecture documents based on spec's "Related Module" and "Key Entities":

| Source | Purpose |
|--------|---------|
| `@specs/ild/{module-slug}/OST.md` | Module interfaces and dependencies |
| `@specs/ild/{module-slug}/FST.md` | Module capabilities |
| `@specs/ild/{module-slug}/SST.md` | Existing data structures |
| `@specs/ild/{module-slug}/LST.md` | Business logic workflows |
| `@specs/dld/{subsystem}/OST.md` | Subsystem interfaces and dependencies |
| `@specs/dld/{subsystem}/SST.md` | Subsystem-level state |
| `@specs/hld/{component}/FST.md` | Component capabilities and boundaries |
| `@specs/sld/summary.md` | System capabilities, tech stack |

### Step 3: Analyze Affected Modules (Enhanced)

**Mapping**: dev-plan ←→ HLD/DLD/ILD (Component/Subsystem/Module)

Based on spec's "Key Entities" and "Integration Points":

**Cross-Level Reference Table**:

| Module | ILD Path | DLD Subsystem | HLD Component | SLD Capability |
|--------|----------|---------------|---------------|----------------|
| user-service | specs/ild/user-service/ | Core-Subsystem | Backend-Service | User Identity Mgmt |

**Analysis Steps**:
1. Identify ILD module from spec.md "Related Module"
2. Find which DLD Subsystem this module belongs to (read `specs/dld/summary.md`)
3. Find which HLD Component this Subsystem belongs to (read `specs/hld/summary.md`)
4. Find which SLD Capability this Component supports (read `specs/sld/summary.md` §Core Capabilities)

**Analysis Checklist**:
- [ ] Which Controller needs modification?
- [ ] Which Service layer needs changes?
- [ ] Which Repository needs new queries/entities?
- [ ] Are new classes required?
- [ ] Does API Gateway need updates?

**Output Format (Enhanced)**:
```markdown
| Module | ILD Reference | DLD Subsystem | HLD Component | Changes Required |
|--------|---------------|---------------|---------------|------------------|
| user-service-business-logic | specs/ild/user-service-business-logic/ | Core-Subsystem | Backend-Service | Extend UserService with updateSignature() |
| user-service-controller | specs/ild/user-service-controller/ | Core-Subsystem | Backend-Service | Add PUT /users/{id}/signature endpoint |
```

**Output Requirement**: The "Affected Modules" table in plan.md MUST include the HLD Component column

### Step 4: Design Data Model

**For Existing Entity Extensions**:
- Reference the SST document
- List only new fields with constraints
- Document relationship changes

**For New Entities**:
- Full entity definition
- Fields, types, constraints
- Relationships to existing entities
- JPA annotations if applicable

**Output Guidelines**:
- Use table format for compactness
- Include default values
- Note nullable vs non-nullable

### Step 5: Design Integration Points

**API Layer**:
```markdown
| Endpoint | Method | Request | Response | Auth Required |
|----------|--------|---------|----------|---------------|
| /users/{id}/signature | PUT | {signature: String} | ResultVO<UserVO> | Yes |
```

**Service Layer**:
```markdown
| Method | Signature | Responsibility |
|--------|-----------|----------------|
| updateSignature | `void updateSignature(int userId, String signature)` | Validate and persist signature |
```

**Repository Layer**:
- Note if JPA auto-generates queries
- List any custom queries needed

**Cross-Cutting Concerns**:
- Error handling strategy
- Logging requirements
- Validation rules
- Security considerations

### Step 6: Document Technical Decisions

For each significant technical choice:

| Decision | Option Chosen | Alternatives | Rationale |
|----------|---------------|--------------|-----------|
| Signature storage | Add to User entity | Separate table | Simpler, signature is tightly coupled to user |

**Decision Categories**:
- Data modeling choices
- API design patterns
- Caching strategy
- Error handling approach

### Step 7: Define Technical Success Criteria

Convert spec's "Measurable Outcomes" to technical targets:

| Spec Criteria | Technical Target | Measurement |
|---------------|------------------|-------------|
| "Fast signature operations" | API <50ms p95 | Load testing |
| "Minimal impact" | <5% response size increase | API profiling |

### Step 8: Plan Database Migration

**Schema Changes**:
| Change | Type | Downtime | Rollback |
|--------|------|----------|----------|
| Add signature column | ALTER TABLE | No | DROP COLUMN |

**Migration Script**:
```sql
ALTER TABLE user ADD COLUMN signature VARCHAR(50) NULL;
ALTER TABLE user ADD COLUMN signature_update_time TIMESTAMP NULL;
```

### Step 9: Validate Plan

**Architecture Constraints Check**:
- [ ] Layered Architecture maintained
- [ ] Stateless authentication preserved
- [ ] ResultVO wrapper used
- [ ] Cache-aside pattern followed (if caching)
- [ ] Transaction management applied

**If violations found**:
- Document in "Architecture Violations" table
- Require clear rationale
- Note who approved (user confirmation)

### Step 10: Copy Template and Fill Placeholders

```bash
mkdir -p specs/new-features/{branch-name}/
cp .claude/skills/dev-plan/templates/plan-template.md specs/new-features/{branch-name}/plan.md
```

**Placeholder Mapping**:

| Placeholder | Source |
|-------------|--------|
| `{{FEATURE_NAME}}` | spec.md User Input |
| `{{BRANCH_NAME}}` | spec.md Branch |
| `{{GENERATION_DATE}}` | Current date (ISO) |
| `{{SUMMARY_SECTION}}` | Extract from spec.md |
| `{{MODULE_1}}, {{MODULE_2}}` | Step 3 analysis |
| `{{CHANGE_DESC_1}}` | Step 3 analysis |
| `{{ENTITY_NAME}}` | spec.md Key Entities |
| `{{FIELD}}, {{TYPE}}` | Step 4 data model |
| `{{ENDPOINT}}, {{METHOD}}` | Step 5 API design |
| `{{SIGNATURE}}` | Step 5 service design |
| `{{DECISION_1}}` | Step 6 technical decisions |
| `{{CHOSEN}}, {{ALTERNATIVES}}` | Step 6 technical decisions |
| `{{RATIONALE}}` | Step 6 technical decisions |
| `{{X}}` | Step 7 success criteria |
| `{{CHANGE}}` | Step 8 migration |
| `{{ROLLBACK}}` | Step 8 migration |

### Step 11: Handle Research Notes (Optional)

**If feature involves external integration** (e.g., OSS, Kafka, third-party API):
- Create optional `research.md` in feature directory
- Document findings and best practices
- Keep concise (50-100 lines max)

**Format**:
```markdown
# Research Notes: {{FEATURE_NAME}}

## {{TOPIC}}

**Findings**: ...

**Best Practices**: ...
```

### Step 12: Present Results

```
✅ Technical implementation plan generated!

📋 specs/new-features/{branch-name}/plan.md

Summary:
- Affected Modules: N
- Data Entities: N (existing extended: N, new: N)
- API Endpoints: N
- Service Methods: N
- Technical Decisions: N
- Architecture Violations: N

Artifacts:
- plan.md (main document)
- research.md (optional, if research needed)

Next: /dev.tasks → Break down into implementation tasks
```

## Guidelines

### Module Identification
- Always reference ILD documents by path
- Use exact module names from ReverseKit
- Be specific about changes (avoid vague descriptions)

### Data Model Design
- Prefer extending existing entities for simple features
- Create new entities only when necessary
- Document JPA relationships clearly

### Integration Design
- Follow existing API patterns (ResultVO wrapper)
- Maintain layered architecture
- Document auth requirements explicitly

### Technical Decisions
- Record rationale, not just choice
- Note rejected alternatives
- Keep decisions reversible when possible

### Migration Planning
- Prefer backward-compatible changes
- Document rollback scripts
- Note if downtime required

## Error Handling

**Missing spec.md**: ERROR "Run /dev.specify first to create feature specification"

**Missing ReverseKit context**:
- If specs/ild/ not found → WARN "Consider running /reversekit-ild first"
- Continue with plan generation, note gaps

**Architecture violations**:
- Present to user with rationale options
- Require explicit confirmation
- Document in plan.md

**Unclear requirements**:
- Mark section with `[NEEDS CLARIFICATION]`
- List specific questions at end of plan
- User can resolve via follow-up

---

Begin: Locate spec.md → Load ReverseKit context → Analyze affected modules → Design data model → Document decisions → Validate → Present results
