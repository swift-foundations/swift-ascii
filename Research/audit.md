# Audit: swift-ascii

## Legacy — Consolidated 2026-04-08

### From: swift-institute/Research/audit-foundations.md (2026-04-03)

**Pre-publication audit — P0/P1/P2 checks**

#### P1: Multi-type Files [API-IMPL-005]

**Minor (2 types in one file)**:

| File | Nature |
|------|--------|
| `Binary.ASCII.Parsing.Machine.Decimal.swift` | Namespace + `FoldState` helper |
| `Int+ASCII.Serializable.swift` | `Decimal` namespace + `Error` enum |

---

### From: swift-institute/Research/modularization-audit-foundations-batch-B.md (2026-03-20)

**Modularization audit — MOD-001 through MOD-014**

1 product + internal test support: ASCII, ASCII Test Support (target only, not product).

| Rule | Status | Notes |
|------|--------|-------|
| MOD-001 | N/A | Single product, Main + Test Support pattern |
| MOD-002 | N/A | Single main target, no centralization needed |
| MOD-003 | N/A | No variant targets |
| MOD-004 | N/A | No ~Copyable concerns |
| MOD-005 | N/A | Single product, no umbrella needed |
| MOD-006 | PASS | 7 external deps, all from primitives/standards layer |
| MOD-007 | PASS | Depth 1 (Test Support depends on ASCII) |
| MOD-008 | REVIEW | 34 files in single target — at boundary for split consideration |
| MOD-009 | N/A | No inline variants |
| MOD-010 | N/A | No stdlib extensions observed |
| MOD-011 | **FAIL** | ASCII Test Support is a target but NOT published as a library product — downstream packages cannot depend on it |
| MOD-012 | PASS | `ASCII`, `ASCII Test Support` — correct L3 naming |
| MOD-013 | N/A | 3 targets (including test), threshold is 5 |
| MOD-014 | N/A | No cross-package optional integration |

**Findings**: 1 FAIL (MOD-011). ASCII Test Support exists as a target at `Tests/Support` with 1 file but is not published as a `.library(name: "ASCII Test Support", ...)` product. This prevents downstream consumers from importing test fixtures. 1 REVIEW (MOD-008): 34 files in a single target may warrant decomposition if distinct semantic sub-domains exist (e.g., parsing, serialization, character classification).
