# Warp Prism — Component Curation and Adaptation

> **Owner:** Warp Prism architecture/design.
> **Scope:** Local design reference for translating consumer needs and donor
> ideas into Prism components. It does not change mission, layer law, acceptance
> or public-API promotion rules.

**Researching is not selecting; selecting is not designing; implementing is not
stable promotion.** Ordered execution lives in
[`wp-component-absorption`](../../.opencode/workflows/wp-component-absorption.md).
Generic research remains owned by the shared knowledge workflow; this document
supplies the Warp Prism-specific fit and adaptation questions.

## 1. Two inputs, different evidence

The [bridge contract](../bridge/README.md) owns consumer coordination and source
locators. Consumer capability coverage includes **what products have and what
they need**, not only what was already proposed for upstreaming. A missing
consumer inventory is unfinished research, not proof that no ADS gap exists.

An external donor supplies mechanisms, interaction ideas and visual examples.
It does not prove consumer demand, production quality, compatibility or
recurrence. Study a named capability in a bounded source slice rather than
planning a suite-wide rewrite. Preserve attribution, inspected revision/snapshot,
license/unknowns, source paths and relevant line ranges; reimplementation does not
erase provenance or licensing obligations for any reused material.

## 2. Curate before designing

Use these questions in the existing candidate record:

1. **Need and evidence:** what user problem or interaction is involved? Is it
   implemented in consumer code, explicitly requested, merely planned, observed
   in a donor, or still UNKNOWN? Which evidence supports each statement?
2. **Baseline:** can existing [Prism components](component-catalog.md), slots,
   variants or composition already serve it? Check source/barrels and current
   plans before claiming absence. The catalog is a discovery index, not the
   exhaustive API or proof of host behavior.
3. **Reusable seam:** what is visual presentation, what is interaction intent,
   and what is domain/runtime behavior? Consult the
   [layer matrix](../../.project/architecture/layer-contracts.md). A useful
   product-specific feature may expose a small reusable seam while its engine
   and domain model stay local.
4. **Disposition:** use bridge §3 vocabulary for consumer classification. For
   donor research, retain the generic workflow's fit/disposition dimensions;
   record any resulting Prism candidate separately. State reuse, extension,
   candidate, keep-local, defer trigger or rejection reason without treating
   these as an implementation grant.
5. **Maturity and priority:** what evidence is needed for an experiment versus
   stable promotion? Apply [MISSION](../../MISSION.md) §§5–6 and layer lifecycle;
   never count clones, screenshots or several donor apps as real consumers.
   Recurrence records unification priority only; it does not gate promotion of
   mandate-covered components (MISSION.md §3.1). Missing recurrence may still
   leave a candidate researched or a separately authorized experiment
   unpromoted; it need not erase the idea.

Full coverage means every scoped consumer need is accounted for: supported now,
composition/extension, candidate, domain-local seam, or an explicit unresolved
gap. It does **not** mean copying every product widget into the generic barrel.
Do not use KEEP_LOCAL to silently drop an unmet need: state where its reusable
presentation can come from and what still belongs to the product.

## 3. Translate the idea, not the donor's skin or framework

Use the Flutter UI/UX method at
`.opencode/skills/flutter/sub-skills/ui-ux/SUBSKILL.md` with these local owners:

| Decision | Canonical owner / adaptation consequence |
|---|---|
| Product fit and boundaries | [MISSION](../../MISSION.md) §§3–7 and [layer contracts](../../.project/architecture/layer-contracts.md): presentation stays in ADS; reusable intent, bindings and runtime are separate; domain models/engines remain consumer-local. |
| Visual identity | [Black Obsidian Visual Contract](black-obsidian-visual-contract.md) §§1–5: neutral obsidian structure, controlled accents, role-separated typography and prohibited patterns. Do not copy donor backgrounds, brands, decorative chrome or global font choices. |
| Tokens, naming and component proof | [Token/Theme/Catalog Policy](token-theme-catalog-policy.md) §§2, 4–9, reconciled with live tokens/theme/barrels: use existing token roles and `Prism*` consumer API, not a new parallel palette or fictitious `PrismTokens` facade. Respect explicit provisional values and golden-freeze conditions; do not silently resolve historical drift in favor of convenient examples. |
| Interaction and accessibility | Define applicable pointer/keyboard/focus/selection states, loading/empty/error behavior, semantics, text scale, reduced motion and adaptive constraints. Map to existing Prism interaction patterns rather than carrying over browser/CSS assumptions or product routing. |
| Verification | Existing promotion owners plus `AGENTS.md` §§7.1–7.2: package proof and affected real-host composition are different. A theme-dependent component needs evidence that changes propagate, not just matching static hexes. |

Start from the smallest existing composition that preserves the useful behavior.
An atom/molecule/organism classification describes responsibility, not size or
prestige; a product workbench may remain a recipe/composition rather than a new
generic organism. Do not synthesize a framework, template or package merely to
house an attractive donor example.

## 4. Compact adaptation brief

Keep this in the owning candidate artifact or Task; no separate file/template or
new registry is mandatory. Resolve material choices before claiming builder
readiness, and retain UNKNOWN where research is incomplete.

| Field | Decision to carry to construction |
|---|---|
| Need / origin | Consumer request or implemented capability; donor evidence, inspected snapshot/license and precise source references. |
| Preserve / discard | User-visible behavior, states and accessibility worth preserving; donor domain coupling, branding, dependencies and structural accidents not carried over. |
| Baseline / local decision | Existing primitives inspected; reuse, compose, extend or new candidate; why; owner, priority and any defer trigger. |
| Composition / layer | Atom, molecule, organism, template or recipe as justified; slots and constituent primitives; ADS/IDS/bindings/runtime/product ownership. |
| Local contract | Proposed inputs, callbacks, controlled/uncontrolled state ownership, lifecycle and error behavior; domain projection boundary. Names are proposed until implemented and verified. |
| Visual translation | Existing surfaces/tokens/theme APIs, typography roles, density, spacing, hierarchy, shape/elevation, motion and adaptive layout. Identify real token gaps without inventing literals. |
| Interaction states | Relevant enabled/hover/focus/pressed/selected/disabled/busy/empty/error states, transitions, keyboard/semantics and edge cases. Mark genuine N/A with reason. |
| Proof / handoff | Gallery fixtures and variants; behavioral, semantics, visual and boundary checks; `affected_consumers` or justified NONE; host exercise and cross-boundary parity where applicable; maturity target, non-goals and authorized writes. |

## 5. Existing cases to reuse, not rediscover

- **Registry instead of a megafile port:** the current
  [`DSEntityIntelPanel` source](../../packages/warp_prism_ui/lib/src/organisms/entity_intel_panel/ds_entity_intel_panel.dart#L135-L165)
  explicitly preserves a dossier type-to-body registry, uses inspector-style
  chrome and documents empty/unknown-type fallbacks rather than structurally
  porting donor panels. This is evidence of that design, not fresh host acceptance.
- **Persistent job progress versus toast:** the
  [cross-consumer matrix](../../.project/architecture/cross-consumer-gap-matrix.md)
  §3 row 6 distinguishes a persistent job banner from a toast. Use the distinction
  as a research lead; recheck current components and consumer evidence before
  declaring a new gap or making an implementation-ready decision. The matrix
  retains mixed acceptance-status text; citing it is not closing that review.
- **Similar media controls, different semantics:** the same matrix §5 separates
  log/wall time, rational AV time and musical time. Seek a shared presentation
  seam without falsely unifying time arithmetic or engine behavior.

`everything`, Figcraft and the linked Craft suites are discovery leads listed in
bridge §1.2, not endorsed component sets. Their functionality and quality must be
established from each inspected source; this document makes no completeness or
runtime-quality claim about those repositories.
