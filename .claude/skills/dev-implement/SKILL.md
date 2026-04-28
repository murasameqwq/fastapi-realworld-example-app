---
name: dev-implement
description: Execute implementation tasks from tasks.md. Usage: /dev.implement
<!-- disable-model-invocation: true -->
---

# Dev.Implement - Task Execution Engine

You are an implementation specialist who executes tasks from tasks.md to generate code for brownfield projects.

## Mission

Execute tasks from `specs/new-features/{branch-name}/tasks.md` to:
1. Modify existing code based on plan.md design
2. Add new classes/methods to existing modules
3. Generate tests if specified in tasks
4. Mark completed tasks with [X]
5. Validate implementation against spec.md

## Execution Flow

### Step 1: Locate Feature Documents

Find feature documents at:
- `specs/new-features/{branch-name}/tasks.md` (required)
- `specs/new-features/{branch-name}/plan.md` (required)
- `specs/new-features/{branch-name}/spec.md` (required)

**Validation**:
- If tasks.md not found → ERROR: "Run /dev.tasks first"
- If plan.md not found → ERROR: "Run /dev.plan first"

### Step 2: Check Existing Code Context (Enhanced)

**Mapping**: dev-implement ←→ ILD + Source Code

**Load Context by Modification Type**:

| Modification Type | Reference Document | Purpose |
|-------------------|-------------------|---------|
| Modify existing module | `specs/ild/{module}/OST.md` | Ensure interface contract not broken |
| Extend subsystem functionality | `specs/dld/{subsystem}/SST.md` | Ensure data consistency |
| Add component interface | `specs/hld/{component}/FST.md` | Ensure compliance with component responsibility |

**Load affected modules from plan.md**:
- Read `specs/ild/{module-slug}/OST.md` for interface definitions
- Read `specs/ild/{module-slug}/FST.md` for capability boundaries
- Read actual source files to understand current implementation

**Understand Extension Points**:
- Where to add new fields in entities
- Where to add new methods in services
- Where to add new endpoints in controllers

**Verification Rules**:
- Check corresponding level design doc before modification
- Ensure no violation of Invariants defined in doc after modification

### Step 3: Verify Project Structure

**Check source file locations**:
```
src/main/java/com/nju/
├── entity/          # JPA entities
├── vo/              # Value objects
├── dto/             # Data transfer objects
├── controller/      # REST controllers
├── service/
│   ├── {Service}.java
│   └── impl/
│       └── {Service}Impl.java
├── repository/      # JPA repositories
└── util/            # Utility classes
```

**Create missing directories/files as needed**.

### Step 4: Execute Tasks Phase by Phase

**Execution Order**:
1. **Phase 1: Setup** - Prepare migration scripts, review modules
2. **Phase 2: Foundational** - Database + Entity/DTO/VO updates
3. **Phase 3+: User Stories** - In priority order (P1 → P2 → P3)
4. **Phase N: Polish** - Documentation, cleanup, verification

**Task Execution Rules**:
- Sequential tasks: Execute in order (T001 → T002 → T003)
- Parallel tasks [P]: Can execute together if different files
- Same file modifications: Execute sequentially
- Mark task as `[X]` immediately after completion

### Step 5: Execute Database Migration

**For ADD COLUMN operations**:
```sql
-- Generate migration script
ALTER TABLE {table} ADD COLUMN {column} {type} {constraints};
ALTER TABLE {table} ADD COLUMN {timestamp_column} TIMESTAMP NULL;
```

**Verification**:
- Confirm column added successfully
- Verify nullable constraints
- Test with sample data

### Step 6: Execute Entity Updates

**For JPA Entity Extension**:
```java
// Read existing entity
@Entity
@Table(name = "user")
public class User {
    // existing fields...
}

// Add new fields
@Column(name = "signature", length = 50, nullable = true)
private String signature;

@Column(name = "signature_update_time", nullable = true)
private Timestamp signatureUpdateTime;

// Add getters/setters
public String getSignature() { return signature; }
public void setSignature(String signature) { this.signature = signature; }
public Timestamp getSignatureUpdateTime() { return signatureUpdateTime; }
public void setSignatureUpdateTime(Timestamp signatureUpdateTime) { this.signatureUpdateTime = signatureUpdateTime; }
```

### Step 7: Execute VO/DTO Updates

**For VO Extension**:
```java
// Add field
private String signature;

// Add getter/setter
public String getSignature() { return signature; }
public void setSignature(String signature) { this.signature = signature; }
```

### Step 8: Execute Service Layer Implementation

**For new service method**:
```java
@Override
@Transactional
public void updateSignature(Integer userId, String signature) {
    // Validate input
    if (signature != null && signature.length() > 50) {
        throw new IllegalArgumentException("Signature exceeds maximum length of 50 characters");
    }

    // Sanitize input (prevent XSS)
    String sanitizedSignature = signature != null ? sanitizeInput(signature) : null;

    // Find and update user
    User user = userRepository.findById(userId)
        .orElseThrow(() -> new UserNotFoundException("User not found: " + userId));

    user.setSignature(sanitizedSignature);
    user.setSignatureUpdateTime(new Timestamp(System.currentTimeMillis()));

    userRepository.save(user);
}

private String sanitizeInput(String input) {
    // Basic XSS prevention
    return input.replaceAll("<[^>]*>", "");
}
```

### Step 9: Execute Controller Implementation

**For new endpoint**:
```java
@PutMapping("/users/{id}/signature")
public ResultVO<UserVO> updateSignature(
        @PathVariable Integer id,
        @RequestBody Map<String, String> request) {

    String signature = request.get("signature");
    userService.updateSignature(id, signature);

    UserVO userVO = userService.getUserInformation(id);
    return ResultVO.success(userVO);
}
```

### Step 10: Execute Test Implementation

**For integration test**:
```java
@SpringBootTest
@AutoConfigureMockMvc
public class UserSignatureIT {

    @Autowired
    private MockMvc mockMvc;

    @Test
    public void testUpdateSignature() throws Exception {
        String signature = "Test signature";

        mockMvc.perform(put("/users/{id}/signature", 1)
                .contentType(MediaType.APPLICATION_JSON)
                .content("{\"signature\":\"" + signature + "\"}"))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.code").value(200));
    }
}
```

### Step 11: Track Progress

**After each task**:
1. Mark task as `[X]` in tasks.md
2. Record what was done
3. Note any issues encountered
4. Verify changes compile/build successfully

**Progress Report Format**:
```
✅ T003: Database migration completed
   - Added signature column to user table
   - Added signature_update_time column

✅ T004: User entity updated
   - Added signature field (String, max 50 chars)
   - Added signatureUpdateTime field (Timestamp)
   - Generated getters/setters
```

### Step 12: Validate Implementation

**After each User Story phase**:
- Run the "Independent Test" from the phase
- Verify acceptance criteria from spec.md are met
- Check backward compatibility

**Validation Checklist**:
- [ ] Code compiles without errors
- [ ] Existing tests still pass
- [ ] New functionality works as specified
- [ ] API response format matches ResultVO pattern

### Step 13: Handle Errors

**If task fails**:
1. Document the error
2. Analyze root cause
3. Fix and retry (max 3 attempts)
4. If still failing, mark as `[!]` (blocked) and ask user

**If design gap found**:
1. Mark gap in tasks.md with note
2. Ask user for clarification
3. Update tasks.md if needed

### Step 14: Present Completion Report

```
✅ Implementation completed!

**Branch**: {branch-name}
**Tasks Completed**: {N}/{Total}

**Summary by Phase**:
- Setup: {N}/{N} tasks completed
- Foundational: {N}/{N} tasks completed
- User Story 1: {N}/{N} tasks completed ✅
- User Story 2: {N}/{N} tasks completed ✅
- User Story 3: {N}/{N} tasks completed ✅
- Polish: {N}/{N} tasks completed

**Files Modified**:
- {file1}
- {file2}

**Files Created**:
- {new file1}
- {new file2}

**Next Steps**:
- Run application and verify manually
- Deploy to staging environment
- Run full regression test suite
```

## Guidelines

### Code Style
- Match existing code style in the repository
- Follow Java 8 conventions
- Use Spring Boot 2.6.13 patterns
- Maintain consistency with existing services/controllers

### Extension vs Modification
- **Prefer extension**: Add new methods, don't modify existing ones
- **Backward compatibility**: Don't break existing API contracts
- **Deprecation**: If replacing, mark old as @Deprecated first

### Testing
- Run existing tests to ensure no regression
- Create new tests if specified in tasks.md
- Integration tests verify end-to-end flow

### Documentation
- Update JavaDoc for new public methods
- Add comments for complex logic
- Keep inline comments minimal and explanatory

## Error Handling

**Missing tasks.md**: ERROR "Run /dev.tasks first to generate task list"

**Compilation errors**:
- Analyze error message
- Fix import statements
- Check method signatures
- Retry compilation

**Test failures**:
- Distinguish between new test failures and regression
- Fix new test failures first
- Investigate regressions carefully

**Design inconsistencies**:
- Note the inconsistency
- Propose fix to user
- Wait for approval before proceeding

---

Begin: Locate tasks.md → Load context → Execute Phase 1 → Execute Phase 2 → Execute User Story phases (P1→P2→P3) → Execute Polish → Validate → Report results
