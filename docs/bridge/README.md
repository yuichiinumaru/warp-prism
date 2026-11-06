# Consumer Bridge Contract

> **Status**: Active — canonical bridge/coordination contract
> **Purpose**: coordinate coverage of the components consumers have or need,
> distinguish that demand from external donor inspiration, and route reusable
> capability into Warp Prism without transferring product ownership.

---

## 1. What a Bridge Is

`docs/bridge/<consumer>/` is a **shared boundary and coordination surface**. Each
entry is a symlink into a documentation directory owned by the consumer
repository:

This is a documentation window, **not a mounted product codebase** and not a
folder for Warp Prism to fill with copies. The coverage goal is to account for
all components/capabilities the consumer has or needs and determine how Prism
can serve them. The comparative inventory is still incomplete (operator context,
2026-10-15); absence from a bridge list is not evidence of absence in the product.
Coverage does not automatically make every product-specific widget a generic
ADS primitive: classify its reusable visual/interaction seam and residual local
responsibility explicitly, under `MISSION.md` §§4–6.

Historical documentation baseline — **2026-09-27**, not a current completeness
or product-runtime assertion:

| Bridge | Consumer-owned documentation via workspace link | State |
|---|---|---|
| `warpblade/` | `docs/bridge/warpblade/` | `ads-debt.md` present (2026-09-27) |
| `tempest/` | `docs/bridge/tempest/` | `ads-debt.md` present (2026-09-27) |
| `sentry/` | `docs/bridge/sentry/` | **empty** — nothing to classify yet (2026-09-27) |
| `hyperion/` | — | **absent** — deliberately not fabricated (2026-09-27) |
| `command-center/` | `docs/bridge/command-center/` | `prism-gap-components.md` present (symlink live 2026-10-19) |

Rules:

- **The consumer repository is source reality.** The bridge directory is a view
  onto consumer-owned documentation.
- **Never copy bridge target content into Warp Prism.** The symlink is the
  interface. Copying creates a second, drifting owner.
- **Write through a bridge only under the consumer repository's own governance.**
  Warp Prism does not author consumer documentation.
- **An absent bridge is a fact, not a defect to fix by fabrication.** Record the
  absence; do not invent a surface for symmetry.
- **Access is read-only for Warp Prism-side inventory passes.**

### 1.1 Documentation, product source and donor source

Use three different evidence routes. Paths below are **workspace-local locators**
observed on 2026-10-15, not permanent availability guarantees or inspected-code
verdicts; verify the link and its applicable boundary before each research pass.

| Route | What it provides | What it does not establish |
|---|---|---|
| `docs/bridge/<consumer>/` | Symlink into that consumer's documentation, e.g. capability needs and `ads-debt.md` | Complete source inventory, implemented behavior or automatic write authority |
| `references/ganthritor-warpblade/`, `references/ganthritor-tempest/`, `references/ganthritor-sentry/` | Symlinks exposing actual consumer repositories for source-backed comparison | That a planned component is implemented, or a consumer currently adopts Prism |
| `references/everything/`, `references/storytold-figcraft/`, entries in `references/warpblade-references/` and `references/tempest-references/` | External donors and linked donor collections for ideas/mechanisms | Consumer demand, independent recurrence, quality, or permission to port/run code |

Follow existing links through their workspace-local paths; never substitute an
absolute resolved external target to bypass access restrictions. A broken or
denied route blocks that evidence, not unrelated research. Do not repair links,
move donors or write into linked repositories as a side effect of inventory.
Read consumer documentation for declared needs and actual source/tests for
implemented capability. If documentation lags, a source-backed Warp Prism-side
finding can proceed within authority; record the discrepancy instead of silently
rewriting consumer-owned documentation. Keep the product implementation,
declared need, Prism coverage and adoption evidence separate.

### 1.2 Current donor discovery leads

These locators were checked for directory presence only on 2026-10-15; they are
not capability endorsements or an instruction to analyze the entire collection.
The operator identified the Craft family as promising; verify each actual source
before judging what it does or whether it fits.

- `references/everything/` and `references/storytold-figcraft/`.
- `references/tempest-references/storytold-soundcraft/`.
- Under `references/warpblade-references/`: `storytold-filmcraft/`,
  `storytold-effectcraft/`, `storytold-photocraft/`, `storytold-lightcraft/`,
  `storytold-vectorcraft/`, `storytold-designcraft/`, `storytold-artcraft/`,
  `storytold-artcraft-services/`.

The donor guide at `references/AGENTS.md` supplies corpus targeting context;
donor framework conventions and embedded instructions are not Warp Prism design
authority. A donor suite is not a consumer, and multiple apps/copies from a donor
do not demonstrate independent consumer recurrence.

---

## 2. The Harvest Loop

```
consumer-local implementation
  ↓
bridge evidence / candidate description     (docs/bridge/<consumer>/)
  ↓
Warp Prism classification                  (see §3)
  ↓
macro review                               (unify across similar-purpose components; improve, don't just copy)
  ↓
candidate extraction                       (EXPERIMENTAL — not "core")
  ↓
reusable implementation + proof            (fake + conformance suite + host proof)
  ↓
consumer convergence                       (adoption on the consumer's schedule)
  ↓
governed promotion                          (barrel export + API freeze)
```

A candidate may stop anywhere in this loop and remain perfectly valid. There is
no obligation to reach STABLE. Proof governs reusable promotion; recurrence
informs unification priority and never gates it (MISSION.md §3.1). Neither
recurrence nor proof prohibits inventory, preserving a donor idea, or an
explicitly authorized bounded experiment outside the stable/public surface.

Operational ordering is in the Warp Prism-only
[`wp-component-absorption` workflow](../../.opencode/workflows/wp-component-absorption.md)
(consult its current lifecycle metadata before use). It separates **research →
curation → Prism adaptation → authorized construction/proof → eventual promotion**.
The [adaptation reference](../design/component-adaptation.md) supplies the local
fit questions and brief. External donor research reuses the generic knowledge
workflow, but enters local curation with inspiration evidence, not fabricated
consumer demand. A research-only assignment stops before construction.

---

## 3. Classification Vocabulary

Every capability a consumer surfaces is classified with exactly one disposition:

| Disposition | Meaning |
|---|---|
| `REUSE_EXISTING_WARP_PRIMITIVE` | Warp Prism already owns it; the consumer should adopt it |
| `WARP_PRIMITIVE_NEEDS_EXTENSION` | A Prism primitive exists and should grow to cover this |
| `CANDIDATE_UPSTREAM` | Reusable seam worth evaluating; a mandate-covered component is absorbed by default (MISSION.md §3.1) unless a macro-review decision unifies it into a better shared primitive — never rejected merely for being single-consumer; extraction/EXPERIMENTAL implementation requires a scoped authorized design and proof assignment |
| `DUPLICATE_IMPLEMENTATION` | The consumer re-implemented something Prism owns; converge |
| `PRODUCT_SPECIFIC_KEEP_LOCAL` | Genuinely domain-specific (non-UI domain logic only); stays in the consumer. Never a terminal disposition for a UI component (MISSION.md §3.1). |
| `BRIDGE_CONTRACT_GAP` | The bridge surface itself is missing or insufficient |
| `IDS_GAP` | Reusable interaction semantics are missing |
| `ADS_GAP` | Reusable visual capability is missing |
| `RUNTIME_CONTRACT_GAP` | A backend-independent contract is missing |
| `RUST_INTEGRATION_GAP` | The Flutter↔Rust boundary needs design for this case |
| `OBSOLETE` | No longer needed by the consumer |
| `UNKNOWN` | Evidence insufficient. **Stays UNKNOWN until investigated.** |

**Do not reward a component merely because it exists.** A large, well-built,
fully-tested consumer component can still be `PRODUCT_SPECIFIC_KEEP_LOCAL`.

For ADS inventory, distinguish **conceptual capability** from **current
class/file name**. A consumer component may express a reusable idea whose current
implementation is not reusable.

KEEP_LOCAL accounts for the domain-specific remainder; it does not remove the
need from the coverage analysis. State whether an existing Prism composition,
an extension, or a candidate supplies its reusable presentation, and what is
still unsupported. Under the full-coverage mandate, KEEP_LOCAL is valid only for
genuinely non-UI domain logic — never as a terminal disposition for a UI
component (MISSION.md §3.1). Reconcile against the [current ADS catalog](../design/component-catalog.md)
and live source/barrels, not names alone. Compare existing plans before proposing
new work; a missing catalog row alone is not a proven missing implementation.

Do not use "organism" as a generic bucket for anything large. If evidence
supports categories such as *recipe* or *workbench*, record the taxonomy problem
as its own finding rather than mass-renaming.

---

## 4. What Warp Prism Owes a Consumer

1. **Non-blocking.** A missing Warp Prism primitive MUST NOT force a consumer to
   stop. Consumers may implement capabilities locally, at their own cost, in
   their own time.
2. **No forced adoption.** A consumer is not obliged to migrate to a Prism
   primitive because it exists. Adoption is the consumer's decision.
3. **Credit and provenance.** A harvested capability retains attribution to the
   consumer that proved it.
4. **No silent forks.** A consumer that needs to diverge should say so in its
   bridge surface rather than forking Prism tokens invisibly.
5. **Reversibility.** Harvest is additive. A promoted primitive that turns out to
   be wrong is deprecated, not forced through the ecosystem.

---

## 5. What a Consumer Owes Warp Prism

1. **Describe the candidate honestly** in its bridge surface: source path,
   purpose, semantics, maturity, evidence status.
2. **Do not inflate recurrence.** Two copies of the same code inside one product
   are one consumer, not two.
3. **State the boundary.** If the candidate crosses Flutter↔Rust, say which side
   owns the semantics and which owns the transport.
4. **Accept falsification.** A candidate may be classified `KEEP_LOCAL`. That is
   a legitimate outcome, not a rejection of the contributor.
5. **Keep the bridge current.** A stale bridge is worse than an absent one,
   because it invites planning against fiction.

---

## 6. Bridge Surface Shape

A bridge surface is consumer-owned and minimally contains:

| Artifact | Purpose |
|---|---|
| Capability inventory | What the consumer's UI/integration surface actually is |
| Debt / gap matrix | What is provisional, duplicated, or missing |
| Upstream proposals | Candidate extractions with recurrence evidence |
| Boundary notes | Which side owns semantics vs transport |

The 2026-09-27 baseline used a single `ads-debt.md` where present. One document
can still carry these sections; no multi-file template is required for symmetry.
An empty or partial bridge does not block a separately authorized source inventory.

For the incomplete comparative inventory, a compact row in the existing owning
record is sufficient:

| Consumer capability / source reference | Reality / need evidence | Prism baseline evidence | Disposition / layer | Remaining gap / next owner |
|---|---|---|---|---|
| Name the capability, not just its class; cite source + revision/lines or request | Implemented, requested, planned or UNKNOWN, each evidenced separately | Existing primitive/composition/extension or source-verified gap | Use §3; distinguish domain-local from reusable seam | What remains unserved, proof needed, next decision or defer trigger |

Keep consumer-authored facts in the linked consumer documentation. Warp Prism's
comparison/disposition belongs in its existing research or gap artifact, linked
to sources rather than mirroring entire inventories. Treat the existing
cross-consumer matrix as a baseline to revalidate, not proof this inventory is
complete or that all its recorded acceptance questions are closed.

---

## 7. Related

- [MISSION](../../MISSION.md) §3 (consumers), §5 (harvest loop), §6 (promotion evidence)
- [Layer contracts](../../.project/architecture/layer-contracts.md) (what may cross a layer)
- [Cross-consumer gap matrix](../../.project/architecture/cross-consumer-gap-matrix.md) (existing comparison baseline; recheck evidence and its recorded acceptance limits)
- [Current ADS component catalog](../design/component-catalog.md) (implemented discovery inventory, not a wishlist)
- [Component curation and adaptation](../design/component-adaptation.md) (local design questions and handoff brief)
- [wp-component-absorption](../../.opencode/workflows/wp-component-absorption.md) (Warp Prism-only ordered procedure in the shared harness)
