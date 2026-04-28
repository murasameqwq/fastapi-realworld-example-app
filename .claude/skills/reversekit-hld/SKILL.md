---
name: reversekit-hld
description: ReverseKit HLD Generator. Use after DLD is completed to elevate subsystems to architectural component specifications.
<!-- disable-model-invocation: true -->
---

# ReverseKit HLD Generator

You are a software architect who elevates subsystem designs to system-level architecture.

## Mission

Generate HLD (High-Level Design) from DLD (Detailed Level Design):
- **Input**: 5 DLD subsystems (each with 4 templates)
- **Output**: 2-3 architectural components/layers (each with 4 templates)
- **Elevation**: Focus on system architecture, not subsystem details

---

## Step 1: Load DLD Inventory

Read:
```bash
specs/dld/summary.md
specs/dld/{subsystem}/OST.md (for all 5 subsystems)
```

Extract: subsystem count, responsibilities, dependencies, line counts

---

## Step 2: Analyze Subsystem Architecture

Build dependency graph from DLD:
- Map subsystem interactions
- Identify architectural layers
- Find integration points
- Note external dependencies

Key questions:
- Which subsystems form natural groups?
- What are the major architectural boundaries?
- Which subsystems represent infrastructure vs. domain vs. presentation?

---

## Step 3: Determine HLD Components

**Target component count**: 2-3 components (aggregate 5 subsystems)

**Aggregation strategies** (choose best):

### Strategy 1: Layer-Based
```
Presentation Layer: Interface-Subsystem
Application Layer: Orchestration + Analysis
Infrastructure Layer: Parsing + Model
```

### Strategy 2: Functional Domains
```
Core Engine: Orchestration + Processing + Model
Analysis Engine: Analysis
User Interface: Interface
```

### Strategy 3: Dependency-Based
```
Foundation: Model (no dependencies)
Processing: Parsing + Analysis (depend on Model)
Coordination: Orchestration + Interface (depend on all)
```

**Selection criteria**:
- Cohesion: Related responsibilities grouped together
- Coupling: Minimize cross-component dependencies
- Clarity: Clear architectural intent
- Balance: Reasonable component sizes

**Naming**: Use architectural terms
- Examples: `Core-Engine`, `Presentation-Layer`, `Analysis-Service`
- Avoid: Subsystem names (too granular)

---

## Step 4: Generate HLD Templates

For each component, create `specs/hld/{component-slug}/` with 4 templates.

**Templates** (located in `templates/` directory):
- [ost-template.md](templates/ost-template.md) - 80-150 lines
- [fst-template.md](templates/fst-template.md) - 60-120 lines
- [sst-template.md](templates/sst-template.md) - 60-120 lines
- [lst-template.md](templates/lst-template.md) - 100-180 lines

**Content Guidelines**:

### OST.md (Operational Spec)
- **Component Overview**: 1-2 sentences on architectural role
- **System-Level Interfaces**: Top 3-5 public APIs to external world or other components
- **Dependencies**: External libraries and inter-component dependencies
- **Deployment**: How component is deployed, configured, and resourced
- **Quality Attributes**: Performance, scalability, availability, security

### FST.md (Functional Spec)
- **Capabilities**: High-level capabilities by category
- **System Boundary**: Inputs/Outputs from external sources/consumers
- **Responsibilities**: What component is/is not responsible for
- **Integration**: How component integrates with others
- **Failure Modes**: What happens when component fails

### SST.md (State Spec)
- **Data Structures**: 2-3 core architectural structures
- **State Management**: Stateful/Stateless, persistence, caching strategy
- **Data Flow**: Mermaid diagram showing component-level data flow
- **Invariants**: System-level guarantees
- **Scalability**: How state affects scalability

### LST.md (Logic Spec)
- **Workflow**: Mermaid diagram (3-8 nodes) showing component-level flows
- **Patterns**: Architectural patterns (Layered, Pipes-Filters, MVC, etc.)
- **Cross-Cutting Concerns**: Logging, error handling, transactions
- **Performance**: Latency, throughput, bottlenecks
- **Extension**: How to add new features

**Total per component**: ~300-570 lines maximum

---

## Step 5: Generate HLD Summary

Create `specs/hld/summary.md`:

```markdown
# HLD Summary

Generated: {date}

## System Architecture

Total: **{N} components** (aggregated from 5 subsystems)

### Component 1: {Name}
**Aggregated Subsystems**: sub-1, sub-2
**Architectural Role**: {role}
**Key Responsibilities**: {brief}
**Documents**: [OST](), [FST](), [SST](), [LST]()

### Component 2: ...

## System Architecture Diagram

```mermaid
graph TD
    External[External User]
    External --> PresentationLayer
    PresentationLayer --> ApplicationLayer
    ApplicationLayer --> InfrastructureLayer
```

## Architectural Decisions

**Decision 1**: {Why this component structure}
**Decision 2**: {Key trade-offs}

## Aggregation Rationale

{Explain why subsystems grouped this way}

## Quality Attributes

- **Performance**: {Expected performance}
- **Scalability**: {Scaling strategy}
- **Maintainability**: {Modular architecture}
- **Extensibility**: {How to extend}

## Technology Stack

The technology stack is **determined by the analyzed codebase**, not hardcoded.

- **Language**: Detected from package manifests and file extensions (e.g., Java, Python, Go, Rust, etc.)
- **Build Tools**: Detected from build configuration files (e.g., Maven, Gradle, npm, Cargo, etc.)
- **Dependencies**: Extracted from package manifests (libraries, frameworks, tools)
- **Deployment**: Inferred from project structure (e.g., JAR, Docker, executable, package-based)

**Documentation approach**: Describe the detected stack accurately, noting that ReverseKit itself is a configuration framework with no compiled components.

## Next Steps

Run `/reversekit-sld` to generate System-Level Design.
```

---

## Content Elevation Principles

**DLD vs HLD**:

| Aspect | DLD (Detailed) | HLD (High-Level) |
|--------|---------------|------------------|
| Focus | Subsystem interactions | Component architecture |
| Interfaces | Top 5-10 per subsystem | Top 3-5 per component |
| Workflow | Inter-module flow (5-15 nodes) | Inter-component flow (3-8 nodes) |
| Data | Core structures per subsystem | Architectural data (2-3 key structures) |
| Patterns | Implementation patterns | Architectural patterns |

**Writing rules**:
- ❌ Don't describe subsystem internals
- ✅ Describe architectural layers and their interactions
- ✅ Focus on "system structure" not "subsystem structure"
- ✅ Use architectural vocabulary (layers, services, boundaries, contracts)

**Example elevation**:
- DLD: "Parsing-Subsystem uses TypeProcessor strategy to convert AST nodes"
- HLD: "Infrastructure layer provides parsing services to application layer"

---

## Edge Cases

- **2 vs 3 components**: Choose 2 if clear separation, 3 if complex
- **Unbalanced sizes**: OK if reflects architectural reality
- **Cross-cutting concerns**: Document in appropriate component, reference in others

---

## Completion Message

Present to user:

```
✅ HLD generation completed successfully!

🏗️ System Architecture:
  DLD Subsystems: 5
  HLD Components: {N}
  Aggregation Ratio: {5/N}:1

📐 Generated components:
  specs/hld/{component-1}/
  specs/hld/{component-2}/
  ...

📄 Each component includes:
  - OST.md (interfaces & deployment)
  - FST.md (capabilities & boundaries)
  - SST.md (architecture & data flow)
  - LST.md (workflows & patterns)

📊 Summary: specs/hld/summary.md

🎯 HLD focuses on system-level architecture,
   abstracting away subsystem implementation details.
```

## Trigger Handoff

Use the `AskUserQuestion` tool to ask the user if they want to proceed to the next step:

```yaml
questions:
  - question: "Would you like to proceed with the final step: Generate System-Level Design (SLD)?"
    header: "Next step"
    options:
      - label: "Generate SLD"
        description: "Synthesize HLD components into a holistic system architecture specification"
      - label: "Stop here"
        description: "End the HLD phase for now"
```

After receiving the user's response:

- **If user selected "Generate SLD"**: Immediately invoke the `Skill` tool with `skill="reversekit-sld"`. Do not generate SLD content yourself — let the skill handle it.
- **If user selected "Stop here"**: End the session and inform the user they can resume later by running `/reversekit-sld`.

---

Begin by loading DLD summary and determining optimal component structure.
