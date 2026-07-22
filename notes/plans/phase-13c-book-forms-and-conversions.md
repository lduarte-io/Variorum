# Phase 13c — book forms, conversions & carried work

**Status:** CREATED at the 13b closeout (2026-07-22, per the author's
13b end-of-life directive — recorded in
`notes/plans/phase-13b-make-it-work.md`, "The 13b end-of-life
directive"). NOT STARTED — the author kicks it off with
`/architect-phase 13c`.
**Shape:** runs under the `/architect-phase` skill
(`.claude/skills/architect-phase/SKILL.md`) — the 13b-proven
architect/orchestrator machinery; the skill file governs process; this
file is the phase's ONE running record.
**Cast:** all-Fable (orchestrator · fresh implementer per batch · fresh
cold reviewer per ladder round) — **author-confirmed IN ADVANCE,
2026-07-22** ("all fable is confirmed", the EOL addendum); she may still
redirect at the kickoff sitting. **She intends to kick 13c off when her
Fable credits reset** (stated at the 13b closeout).
**The paste-ready kickoff message is the third section below**
("Kickoff message"); the two sections before it exist because this file
changed hands between models and opens with two review obligations.

## PROVENANCE — read this before trusting any line (author's instruction, 2026-07-22)

**This file was drafted by FABLE and finished by OPUS, and the seam is
deliberately visible in git.** The Fable Stage 4 execution orchestrator
wrote the draft in its scratchpad and then hit the author's Fable token
limit mid-gate; an Opus session finished 13b's closeout and this plan.
Two commits make the handoff auditable:

1. **`224938b` — "FABLE-AUTHORED SCRATCH PLAN"**: the draft committed
   UNEDITED (constitution placeholder and empty baselines included).
2. **the next commit — the Opus edits**: `git diff 224938b <this file>`
   shows EXACTLY what changed hands.

**Your instruction as the 13c orchestrator (hers, verbatim-faithful):**
review the plan file overall AND the Opus changes specifically — "so it
can use its own judgement or ask me questions if anything seems to be
different." The largest deliberate divergence is named for you: **the
visual/design/UI review left this phase's scope entirely** (see
"What deliberately did NOT come here"). Everything else in the Opus diff
is the constitution splice, the real baselines, and the notes below.

## First acts at phase start (before any batch)

1. **Re-review the 13b gate fixes AND THE TWO DEFECTS THEY CORRECTED —
   76 lines, three commits (`e5b8221`, `16e5fcb`, `2e60d0d`), plus the
   round-3 post-cap hardening (`120c418`).** The author asked for this
   explicitly (2026-07-22): "look over the defects and the fixes." These
   were REAL bugs found when the stage-close gate ran tests that a
   locked login session had only ever compiled — not cosmetic. The two
   defects, so you know what you're re-checking:
   - **The mid-view-update `@State` height drop** (`16e5fcb`, hardened
     in `120c418`): `PaneSurface`'s `remeasure()` could publish a height
     through a SwiftUI `Binding` *during* an update pass, which SwiftUI
     silently drops — leaving a compare pane framed one line tall under
     two lines of text with nothing left to re-publish. `PaneSurface` is
     **the ONE text surface every pane composes** (P-3), so this reaches
     the editor, takes, lenses, compare, canvas, and the read tier
     alike. The fix routes every publish through one `PanePublisher`
     door with a bounded convergence heal; the first cut patched two
     instances, and `120c418` made it structural (that history is the
     round-3 record). **Confirm the class is truly closed** — a publish
     added later must inherit the discipline, not need its own repair.
   - **The multi-peer Compare flush** (`e5b8221`): `CompareComposition`
     force-flushed one peer's unrelated blocks into a sparse segment —
     the gap parade N29 exists to kill, at segment scale. The failing
     test was the correct pin. Two placement behaviors it left are
     recorded below (the kin-less-peer question) and are a live design
     item this phase — read them together with the fix.
   A ladder round-3 cold review already ran over these at 13b's close
   (verdict + traces in the 13b plan file's round-3 sections); this is a
   SECOND look with fresh eyes on code that landed under model
   exhaustion, not a repeat for its own sake.
2. **Review the applied canon deltas.** 13b's closeout wrote real
   semantic changes into the canonical docs — the merge-pairing
   extension (AppSpec §9 + OverallModel §7), the cut rule + parking
   semantics (same sections), and `restoreReading`'s deliberate
   reversal of the readings-have-no-restore-door boundary (AppSpec §9).
   These are not bookkeeping: a round-1 reviewer already caught the
   delta checklist incomplete once. Read them against the S4 rulings
   they encode before building on them.
3. **Verify the baselines below with your own runs** (the skill's
   verify-don't-trust rule).

## Kickoff message (for the fresh /architect-phase 13c orchestrator — read this first)

> You are the Phase 13c architect/orchestrator for Variorum under the
> `/architect-phase` skill — read the skill file IN FULL first (it
> carries the constitution, the machinery, and the environment
> invariants), then THIS plan file IN FULL, then the three committed-
> scope inputs: `notes/plans/phase-13c-uniform-page-view-brief.md`,
> `notes/plans/phase-13c-memo-smart-to-curated.md`, and the N41 row in
> the ledger below. Then `notes/handoffs/phase-13b-handoff.md` (state
> at the boundary; anything still-held there that the author has since
> discharged is recorded in its checklist). Confirm the repo state with
> `git log --oneline -10` and `git status`. **Read "PROVENANCE" and
> "First acts at phase start" below before anything else — this file
> changed hands between models mid-flight, the seam is auditable by
> `git diff`, and two review obligations open the phase.** Verify the
> baselines below with your own runs before building on them. Note what
> deliberately did NOT come into this phase (its own section). The
> phase OPENS with an
> author-attended kickoff sitting — the agenda is the "Kickoff sitting
> agenda" section; bring the question batches (≤4 per call), record
> her rulings verbatim-faithful in this file the same turn, then run
> batches through the standing machinery: fresh Fable implementer per
> batch, repo-first records, one review ladder per stage over the
> combined diff, PROVISIONAL-and-continue for non-gating ambiguity,
> the standing author-only hard stops untouched.

## Committed scope (the author's EOL directive — "ruled and wanted, deferred in time only, not optional")

1. **The uniform-page traditional book view** — built from
   `notes/plans/phase-13c-uniform-page-view-brief.md` (4F's detailed
   brief per her S4-16 condition: two-tier estimated/measured
   pagination outside the editor stack, estimated-page scrub domain,
   lazy spread-only realization per P1, edge cases decided on paper).
   The brief's FIVE open questions are the kickoff sitting's; its
   settled facts are cited, not re-derived. (S4-9(3); ledger N31's
   re-owned half.)
2. **Smart → smart+curated book conversion (N38)** — built from
   `notes/plans/phase-13c-memo-smart-to-curated.md` (4F's design memo
   per her S4-16-class condition: three conversion shapes with A —
   materialize-and-convert + the fresh-smart-book offer —
   recommended; zero schema change for A confirmed). The memo's FIVE
   plain-language rulings are HERS at the kickoff; build to her
   answers. (S4-28.4.)
3. **N41 — the inline-comments airiness** — 13c is the named owner
   (her EOL directive discharged the "13b closeout names its owner"
   duty). The mechanism constraint is on the record (S4-30(a): an
   overlay cannot reserve vertical space in TK2; the uniform gap is
   the honest mechanism) — if it still bothers her in use, this is an
   R116 design-memo conversation at the sitting, not a patch.
4. **Compare — a "show related blocks only" setting** *(author request
   2026-07-22, at the 13b closeout — verbatim: "we should have a
   setting to only show related blocks - that would make the pane feel
   more usable")*. A per-view toggle (session/view-local, the
   follow-order/lineage-colour toggle class from 4C — no schema) that
   collapses each column to only the blocks with lineage kinship to the
   anchor, hiding the unrelated stretches. **This RESOLVES the 4C
   kin-less-peer PROVISIONAL directly** (13b plan, Batch 4C judgment
   call 0 — a peer with no kinship renders its whole post below every
   aligned row): with the setting on, an unrelated peer simply shows
   nothing, and a partly-related one shows only its kin rows. Her call
   at the kickoff: whether "off" keeps today's shipped placement (the
   PROVISIONAL as-is) or the placement itself changes — the setting may
   make the placement question moot. Design detail (the empty-column
   affordance, whether "related" means direct `derived_from`/`version_of`
   or the transitive lineage the alignment already computes) is the
   kickoff's; it composes with the honesty line (N29) — an all-unrelated
   pair with the setting on says "there is no relationship here" over
   two empty columns.

## What deliberately did NOT come here (author's decision, 2026-07-22 — the largest Opus divergence from the Fable draft)

**The visual / design / UI review round is NOT 13c's.** The Fable draft
assumed 13b's closing propose-only sweep would feed this phase's kickoff
agenda. The author removed that: the sweep and the accumulated
screenshot/usability verification became a **standalone, re-runnable
item on the master plan's phase table** (unslotted, like the Apple Notes
import), because — her reasoning — 13c "already has a defined scope and
several big issues," the review is "something that can be run multiple
times," and separating it "saves the 13c orchestrator context from going
through a bunch of screenshots and items before it begins the more
defined items."

Consequences for you, stated plainly:

- **Do NOT import the visual backlog.** The per-batch visual-loop items
  live in 13b's batch records (4A–4F); a future design-review round
  starts by reading those lists. They are not 13c ledger rows.
- **Several 13b Stage 4 surfaces shipped with machine verification but
  NO visual pass** — the reworked take ceremony sheet, the merge
  ceremony sheet, the rebuilt Compare board, the reworked Canvas, and
  the paged book view + progress bar. The suite, soaks, and pins cover
  their behavior; nobody has LOOKED at them. The author accepted being
  first eyes.
- **ONE targeted exception you must honor:** the uniform-page book view
  (committed scope 1) composes directly with the **paged view and
  progress bar 4F shipped**, which are among those visually unverified
  surfaces. Look at them when you build on them — that is not the same
  as adopting the sweep.

## Kickoff sitting agenda (bring as question batches; record rulings verbatim)

- The N38 memo's five rulings; the uniform-page brief's five open
  questions.
- Any 13b handoff checklist items she has not yet discharged, incl.
  held ratifications (its "worth a look" list is advisory, never a
  requirement; the deferred-in-place judgment-call walk stays deferred
  and is never re-asked unprompted).
- Open organic-use findings from her 13b-era reports (standing triage:
  happy-path breaker / owned row / new row).
- **Kickoff candidates (propose-only, recorded during Stage 4 — each
  enters scope ONLY on her approval; none is owed):** the canvas BANK
  as a future face atop culling (the 4E fork she preserved); synced
  canvas card-size columns (`w`/`h` — a §12 lockstep event); the full
  margin-hover comment grammar (4D built the minimal caret-block
  "+ //"); the N34 GLOBAL one_block face (one small core setter away —
  the 4D-recorded blocker); the word-target face's discoverability (the
  4F quiet door); consolidating the two sibling refusal-copy homes onto
  `OpsRefusalCopy` (the round-1 fix pass's recorded candidate).

## Binding principles

**The P-1…P-9 constitution is copied VERBATIM below (the skill's
requirement; the author's directive: copy, don't summarize; byte-exact
from 13b's plan file).**

- **P-1 — One capability registry.** Every user-facing act is declared
  exactly once: verb, scope (block/take/post/book), per-mode availability
  rule, its doors (menu / context / bar / shortcut / palette), and its
  refusal copy. Surfaces render their doors FROM the registry; gating is
  data, never per-view if-statements. A registry-walk test asserts every
  declared door exists and every rendered door is declared. This kills the
  D3/D4 class structurally — the capability matrix stays green by
  construction instead of by audit.
- **P-2 — Fire-and-DO (R115).** A rendered door either performs the act —
  including any mode-switch choreography, done visibly for the user — or
  delivers the operations layer's real refusal. A door that can never act in
  its context isn't rendered. Lecture-and-redirect is retired.
- **P-3 — One text surface, one liveness authority.** ONE TK2 surface
  component (live + read modes; one measurement brain — the width-gated
  remeasure; the shared canary) that every pane composes; the live editor
  core's identity machinery (`BlockRangeIndex`, crystallization) becomes its
  live mode, not a sibling implementation. "What text does this pane show,
  and is it live" is answered by ONE pure, unit-tested authority
  (`PaneTextAuthority`); views never re-derive it. Its invariants stated as
  code: exactly one live pane; the live pane is buffer-authoritative; read
  panes are projection-authoritative once caught up.
- **P-4 — Broadcasts carry signals, never decisions.** NotificationCenter
  may announce that something happened (mode changed, post opened); no
  listener derives business state or availability from a broadcast, and no
  flow's correctness depends on broadcast ordering. Cross-feature flows
  route through composition. (Stage 0's survey enumerates today's
  notification bus; Stage 1 disciplines it.)
- **P-5 — The friction doctrine (R116).** Repeated pushback against a rule
  marks an under-architected feature. The response is never another patch:
  write the feature's DESIGN MEMO — intended behavior whole, edge cases
  enumerated on paper, refusal wordings, undo story — get the author's
  rulings on the product-flavored edges, then build to the memo. Happy path
  ships first, but the edges are *decided at design time*, not discovered by
  the author. First two memos owed: **merge** and **the W ceremony**.
- **P-6 — The tutorial is the executable spec (R113).** The guided tutorial
  flow is the contract for every happy path. It stays green — automated
  where the harness allows, screenshot-walked otherwise — and any change
  that breaks a tutorial step is a regression by definition.
- **P-7 — Find bugs before she does.** Every layer keeps a proactive
  harness: the ops-layer soaks (exist), the board/view-model invariant soak
  (Stage 1), the registry walk (P-1), the per-batch scripted screenshot
  walkthrough. Red-on-old stays absolute: no bug-class fix without a pin
  that fails on the pre-fix code.
- **P-8 — Standing law, consolidated.** P1–P3 performance invariants bind
  the rebuilt layer exactly as they bind the substrate (invalidation ∝
  realized rows; one live editor; virtualized long views). Overlays, never
  rendering attributes. Chrome `fixedSize` texts always carry a `lineLimit`
  (the b6dae25 class). `Theme/VoiceControls.swift` is THE chrome vocabulary.
  Complexity lives in the store; restraint lives in the UI.
- **P-9 — No god objects in the frontend either.** A view model mixing
  board layout, text authority, and gesture routing splits by concern
  (`TakesViewModel` at 890 lines is the standing counterexample). Same
  hygiene rule as the substrate, applied where it was being waived.

**The skill's "Applying the constitution" precisions bind here as
written there** (P-1's routed-vocabulary scope + `.surface`; P-3's two
surface kinds — the full-document editor is never absorbed; layer
placement + parity-by-forwards; the overlay/sink delivery law).

## Stage 4 lessons (established by 13b Stage 4 — binding here explicitly, per the EOL directive)

1. **One-ring-across-contexts lives ON `PaneTextAuthority`**
   (`PaneKey.context`, the 4C extension): any new editable surface —
   the uniform-page view included, if it ever wakes to edit — adopts
   the authority; never a second liveness mechanism (4C/4E are the
   worked examples).
2. **A new editable surface joins `commitTake`'s availability AND
   registers a `.commit` handler** (`takeFamilyPlusEditableBoards` —
   the N5 class closes per surface; 4D/4E precedent).
3. **ONE snap brain:** `BoundarySnapping`'s ruled word rule + gentle
   settle is THE cut rule at every gesture door (plain divide, the
   ceremony, extract, `CutPropagation` seeds). Never a second snap
   table.
4. **ONE join brain:** `MergeJoin` resolves every merge join (op,
   ceremony, previews) — no surface re-derives a join byte.
5. **Ceremony-sheet disciplines** (the W + merge sheets): one-flight
   guard before any await; drift-refresh against the CURRENT fans at
   confirm; cancel-inert; honest confirm blockers; I10-at-birth gates
   (`divideSideWouldBeEmpty` / `mergedBlockWouldHaveNoTake`).
6. **The realization-bound discipline for free-2D / long surfaces:**
   the realized set is a PURE function of (positions, sizes,
   visibleRect, margin); silhouettes under overview zoom keep the
   bound; DEBUG materialization counters are the hosted pin form (4E;
   the ReadingFlow precedent). The uniform-page view's brief already
   binds its pagination to this discipline.
7. **Ops returning take mappings carry correspondence arrays**
   (`FanHalf.sourceVariantIDs`, `mergeCeremony`'s `sources` — the 4A/4B
   precedent).
8. **Model-driven navigation re-affirmed** (the Phase 6 ruling, applied
   at 4F): progress, scrub, and page domains ride the POST LIST /
   stored estimates — never live TK2 geometry.
9. **The locked-session regime** (a Stage 4 environment discovery): the
   Mac test runner hangs pre-connection under a locked login session —
   verified against control suites. Under lock: core `swift test` +
   `build-for-testing` compile gates run per batch; Mac suite
   executions, app-side behavioral-revert reds, visual loops, and
   install refreshes consolidate at the first unlocked window with
   EXACT procedures recorded per batch (the 4A–4F records' form).
10. **In-view affordances vs declared acts:** view-mode toggles,
    progress faces, sheet controls, and recovery doors are surface-
    local (recorded, not declared); routed acts and doors-with-
    shortcuts are declared (the standing 4A–4F reading).
11. **The §12 deploy-gate pattern** (also in the skill): mirror deploys
    only on her explicit go-ahead; install refreshes that would outrun
    the deployed marker are HELD; lesson edits stale the seeded field
    guide — re-seed behind the A1 rail at close.

## The running ledger

| # | Item | Status |
|---|------|--------|
| C1 | The uniform-page book view (from the 4F brief) | committed, not started |
| C2 | N38 smart→smart+curated conversion (from the 4F memo; her five rulings first) | committed, not started |
| C3 | N41 inline-comments airiness (R116-class conversation first) | committed, not started |
| — | [kickoff-approved candidates enter here as rows] | — |

## Baselines at open (VERIFY with your own runs — the skill's rule)

- **Core `swift test`: 817 tests / 96 suites** green.
- **Mac `xcodebuild test`: 645 tests / 122 suites** green — the count
  the 13b gate verified by execution. NOTE the arithmetic lesson worth
  carrying: the batch records' hand-estimated 648 was wrong by 3 because
  **a parameterized `@Test(arguments:)` reports as ONE test regardless
  of case count** (13b Stage 4 added two 2-seed soaks that were each
  counted as two), plus a retired/migrated pin. Estimate counts that
  way or don't estimate them.
- **Mobile: 11 / 4**, builds clean.
- **The v1_12 lockstep state and the `/Applications` + field-guide seed
  state are recorded in the 13b handoff's checklist** — read it there
  rather than trusting a number copied here.

## Environment traps (the invariant core — the skill's environment section binds; this phase's specifics)

Instance checks: `pgrep -fl 'Variorum.app/Contents/MacOS'` AND
discriminate by PATH (the DerivedData test host matches mid-run since
4G; `/Applications` = hers/real-store); real-store instances by STORE,
not path — NEVER quit/kill one; no Release builds or `/Applications`
refreshes while one lives; Mac suites DO run beside her live app since
4G (the Debug host is `io.lduarte.Variorum.debug`; its container holds
the seeded design corpus); `xcodebuild build-for-testing` compiles
without the runner; Mac tests from `App/Variorum/`, SUITE-level
`-only-testing` only, confirm the "Test run with N tests" line; zsh
`pipestatus` (lowercase); NEVER add a custom build configuration (SPM
builds packages release under any config not named "Debug" — strips
the DEBUG oracles); test windows flash beside a live session — prefer
zero-instance windows for timing-sensitive measurement; the Mac runner
needs an UNLOCKED login session (lock-flag check:
`swift -e 'import CoreGraphics; print((CGSessionCopyCurrentDictionary()
as? [String: Any])?["CGSSessionScreenIsLocked"] ?? 0)'`); backups
WAL-safe with UTC names, ALWAYS before touching the real store (the A1
rail); the real store lives in the SANDBOX CONTAINER
`~/Library/Containers/io.lduarte.Variorum/Data/Library/Application
Support/Variorum/`; drives need unlocked + author-free + own
`caffeinate -d`; osascript System Events menu clicks work
(accessibility granted); fresh hosting views for remounts; a bare
NSWindow auto-assigns first responder on order-front; async-poll
(never sync RunLoop pumping) drains settle hops; screenshots in
gitignored dirs; never `git checkout` over uncommitted work; never
push.

## Batch records

*(appended per batch, the 13b form: commits, counts before → after,
traced mechanisms, numbered judgment calls/PROVISIONALs, red-on-old
evidence, deviations with reasons, ladder foci)*
