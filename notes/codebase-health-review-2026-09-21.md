# Codebase Health Review — 2026-09-21 (post-13u checkpoint)

**What this is:** a read-only health assessment of the whole tree at the author's request, taken at the
post-13u pause — after the 13u family closed (2026-09-21) and before 13i's book work. Method: five
independent Opus read-only explorers (long-text navigation machinery · god-file/structure audit ·
VariorumCore health · SwiftUI state-write + process-global sweep · observation/task lifecycle audit),
synthesized by the Fable session that ran them, with every finding reconciled against
`notes/KnownIssuesAndTechDebt.md` so tracked debt is marked as tracked. **Nothing in the repo was
changed by this review** — no code, no shared docs, no ledger rows. Where a finding wants a ledger row
or an owner, that is recorded here as a recommendation for the author (or the phase that adopts it) to
make; this file is the review's only artifact.

**Numbers at the review:** 381k lines of Swift; Mac app tests 293 files, core tests 158 files
(~49k lines); `Sources/VariorumCore` 34.5k lines across 156 files; migrations v1_core→v1_17, marker 8.

---

## 0. Executive summary

**Overall verdict: the codebase is in materially better shape than its file sizes suggest, and the
area the author is most worried about — long-text navigation — is the area that has been *converging*,
not rotting.** The core package is close to exemplary. The real findings cluster into: one live
accumulating leak (the autosave registry), one probable active bug (the inline editor's height
binding), one already-diverging duplication (the Mac↔mobile editor conductor band), one god-state
class (`EditorViewModel`), one god view whose decomposition should be planned into 13i (`BookView`),
and a set of small hygiene items with known fix patterns already shipped elsewhere in the tree.

Top items, ranked by (risk × cheapness):

1. **The autosave-coordinator registry leaks one entry per note opened, for the whole session**
   (§6.1). Mechanically certain; the felt cost is a linearly growing serial walk of `closeAutoCommit`
   write transactions at **every screen lock and every ⌘Q**. The release door exists, is tested, and
   is wired only on the phone. Fix ≈ six call sites. *17-entry class.*
2. **The inline editor's height binding is written inside `makeNSView`/`updateNSView`** (§5.2) — the
   top active-bug candidate for the tracked "double realization on long notes" mystery (ledger row 43's
   surviving half). ~4-line fix; measure first (pin the mechanism before fixing, per the hallucination
   guard). *17-entry class.*
3. **Note Read mode is the one landing surface with neither half of the landing answer** (§2.2) — the
   likeliest home of the author's remaining "small stutter, always the same amount." The fix is a
   transplant of the 13u4-F3 shape, roughly one unit. *Its own unit.*
4. **The Mac↔mobile editor conductor fork** (§4): ~700 lines line-for-line duplicated outside
   `Shared/EditorBrain/`, with the cross-block routing cascade **already diverged** between platforms.
   Hoist the routing decision as a pure function first. *A design-carrying unit; the mobile catch-up's
   natural companion.*
5. **BookView's decomposition should be a planned opening unit of 13i** (§3.3) — the author's own call
   at this review: 13i adds locked books, more book tags, and book identity, so the split happens
   *before* those features land, not after.
6. **`PanePublisher`'s synchronous mid-layout publish needs a ruling** (§5.1) — it is deliberate and
   documented, and it is probably the majority of the ~1,989 `Modifying state during view update`
   warnings. A ruling, then code. *Author sitting item; the implementation is Phase 12-shaped.*
7. **Ledger bookkeeping the review cannot do itself** (§7): rows 56/57 are orphaned on the closed 17l;
   row 27's owner pointer is stale; row 28's known-forks list has new members (this review's §4).

Everything else is below, grouped by the author's original questions.

---

## 1. The navigation/landing area — is it healthy? (the author's prime concern)

**Verdict: architecturally sound and unusually well-founded at the core; unfinished at the perimeter.
Not accumulated patches.** The evidence, not taste:

- The hard part is a **pure function with its own suite** (`LandingSettle.decide`,
  `LandingAuthority.swift:212`; `LandingAuthorityTests`). Per-surface differences are **data**
  (`LandingPolicy`) with the measurement that justified each constant written beside it.
- The height problem is solved in the right order: heights known **before** the aim
  (`BookHeightManifest`, precedence MEASURED > REMEMBERED > DERIVED; `ProseHeightModel` over stored
  block lengths — never the prose, P1 by construction; `SurfaceSizeMemory` persisting measured truth
  per note per width), then one authority correcting the residue. 13u4 UNIT F3's measurement is the
  proof: 13/13 cold deep chapter clicks settling at `top=0` with `hops=0` where 6/6 stalled before.
- TK2's estimate-shift is accepted as a fact, not fought: `JumpPrimitive` never asks for a document
  height — it asks a single fragment where it is, repeatedly, bounded (≤6 corrections).
  `PaneMeasurement` refuses the `usageBoundsForTextContainer` ratchet on measured evidence; exactly
  **two** guarded reads of that property remain in the whole app, both documented.
- Almost no timing hacks: **two** `asyncAfter` in the entire Mac app + Shared, both inside named
  settle authorities. No observer leaks found in this subsystem (all `[weak self]`, all cancelled).
- Churn tells the same story: the hoisted pieces are young and quiet (`LandingAuthority` 5 commits,
  `BookHeightManifest` 3, `JumpPrimitive` 7) while the churn lives in the older surface files that
  predate them. The last three rounds (13u2b, 13u4 F1/F3) each **closed** ledger rows rather than
  opening them.

### 1.1 The map (for whoever works here next)

Six landing brains exist:

| # | Brain | Status |
|---|---|---|
| 1 | `LandingAuthority` (+ manifest + memory) | the real one; 3 adopters: book Outline, Read ▸ Scroll flow, book Index pane |
| 2 | `TakesArticleScroll` (~1,000 lines) | parallel reimplementation; its *restore* half encodes author rulings (R-Q20/R-Q21) and should stay; its *landing* half should adopt the authority at its next touch (the authority's own header says so) |
| 3 | Note Read, page face (`ReadModeView`) | **no brain** — one one-shot `scrollTo`, no correction, no memory, no signpost |
| 4 | Note Read, edit face (`ReadEditPane`) | **no brain** — same shape, different resting anchor |
| 5 | The two contents columns | one-shot `.center` scrolls, unwatched |
| 6 | `JumpPrimitive` | the AppKit/TK2 offset-domain brain — **correctly separate**; merging it with the SwiftUI anchor domain would be a category error |

Plus three non-landing correction loops that are healthy and should stay distinct: `PanePublisher`
(height convergence), `StableSurface` (size settle), `LongBlockLayout` (TK2 estimate heal).

### 1.2 The stutter, diagnosed

The author reports a small stutter on first navigation into long texts, "always the same amount," and
perfection on every visit after the first. Two mechanisms, two verdicts:

- **Book surfaces (Outline / flow / Index):** genuinely two-pass — aim on the manifest, correct once
  from quiet. "The same amount" there is the derived arm's deterministic error corrected in one hop,
  which is the design working. The shipping content-free signpost (`Logger` category `landing`) shows
  it: `derived=N hops=1`.
- **Note Read mode:** a **one-shot aim against SwiftUI's lazy estimate with no second look** — the
  target is nil'd immediately, the lazy column re-realizes under the landed offset, SwiftUI re-applies
  the pixel offset, and nothing re-aims. Same note + same width ⇒ same estimate error ⇒ the identical
  jump every time. **A fixed displacement on every attempt is the signature of this path**, not of the
  converging one. Diagnostic without a repro: a stutter with **no** `landing` line in Console is this
  path (note Read emits nothing, having no authority).

"Perfect after the first visit" is `SurfaceSizeMemory` + measured manifest rows: truth is remembered
per note per width and persists across launches; it resets on a width or voice change (correctly —
a remembered height at another width is a lie).

### 1.3 The remaining work, concretely (priority order)

1. **Note Read adopts the 13u4-F3 shape** — a `LandingPolicy.readNote`, a per-note *block* manifest
   from the already-cached `Queries.blockExtents` through `ProseHeightModel` (what
   `BookIndexPaneHeights` did for whole notes, one level down), rows as placeholders at asserted
   heights, the authority's aim/hold/correct loop, the signpost for free. Highest value, lowest risk;
   a transplant, not a design. ≈ one unit.
2. **Collapse the flow's two height rules** (D1): `FlowStoryRow`'s reservation reads
   `FlowHeightEstimate.honestHeight` while the same file's manifest reads `BookHeightManifest.resolve`
   — they agree today only by accident of a nil argument. Make the row read the manifest. Small,
   mechanical, pin-preserving. *(Book-adjacent — a natural 13i pickup, §3.3.)*
3. **Takes: split, don't merge.** Move the *landing* half (`articleLandingStep`, `revealDecision`,
   `revealAnchor`) onto the authority; this requires the authority to grow an **aim kind**
   (top · minimal-reveal · viewport-fraction — `ViewportCarry.anchor` already supplies the
   vocabulary), which also gives the currently-forked "where does a landing put the block" answer
   (top vs 0.08 vs center vs nearer-edge) a place to be *decided* rather than accreted. The restore
   half stays — it encodes her rulings and is a different problem.
4. **Two one-liners:** the book Outline is the only authority adopter without
   `.onDisappear { landing.end() }` (the flow and Index both carry it, citing ladder R2-12); and
   `LandingTarget.utf16Offset` is a dead field — declared with a paragraph of intent, set by no
   production site (the caret offset actually travels on `FocusedBlock` through `CommandRouter`).
   Wire it or delete it.
5. **Keep separate, deliberately:** `JumpPrimitive`, `PaneMeasurement`/`PanePublisher`,
   `ScrollAnchorController`, `LongBlockLayout`.

### 1.4 The background-warming design call (recorded so the reasoning isn't re-derived)

The author asked whether the app could pre-measure a book's heights in the background so even the
first-ever jump is exact. Three reasons to hesitate, and a recommended order:

1. **A headless warm needs a second height oracle, and second oracles drift.** A row's height is prose
   *plus chrome* (chips, callout frames, comment badges) — ledger row 60 already proved a one-line
   chip change silently moves landings by thousands of points. The only measurement guaranteed to
   match a row is the row rendering itself; a parallel headless layout model is the "two brains for
   one question" class this codebase keeps killing.
2. **"Once" becomes "often":** measured heights are valid per width × voice × typography, so the warm
   re-pays its full cost after every resize and theme change — and a warm kicked off at book-open
   often won't finish before the first jump anyway.
3. **Most of the benefit shipped at 13u4 F3** (self-consistent asserted heights ⇒ first aim exact on
   estimates), and note Read's adoption (item 1 above) removes the biggest unmanaged stutter.

**Order:** transplant note Read → extend assert-derived-heights where missing → live with it → only if
a first-visit stutter still annoys in practice, warm **through the real row pipeline** (briefly
realizing rows off-viewport so the real renderer produces the measurements), never a parallel
headless layout stack.

### 1.5 Latent traps in this area (named, unowned until adopted)

- **T2 — `PaneMeasurement.extent` enumerates the whole document with `.ensuresLayout`**, and two of
  its four call sites are whole-post surfaces — `InlineEditorSurface.Coordinator.remeasure` runs it
  **once per keystroke** in the book/spread/pool inline editor. Measured (0.19 ms at 42k chars,
  0.57 ms at 169k) and documented as handed forward, but still unowned. P1's letter, not its spirit;
  if a genuinely long note lands in an inline editor, this is where it shows. *(Phase 12's
  P1-tension family.)*
- **T3 — `StableSurface.report` schedules a non-cancellable 1 s `asyncAfter` on every geometry
  report** (generation-gated so only the last acts, but a fast scroll over N expanded stories queues
  N one-second blocks). Contrast `LandingAuthority.arm`, which cancels its previous work item — the
  right shape, one file over. *(Phase 12.)*
- Already tracked, unchanged by this review: row 60 (chip wrap vs manifest), row 58 (mode-switch carry
  write-direction mirror), row 44's residue, QUESTIONS #115(b) (voice change re-measures but does not
  re-land), #129 (should the app say anything when a landing cannot arrive).

---

## 2. God files, god state, structure (the author's second question)

**Verdict: almost none of the big files are god files; the repo's decomposition instincts are good
(pure brains in `Shared/`, planners in `Shared/EditorBrain/`, the declarative `CapabilityRegistry`).
The real problems are god *state* in `EditorViewModel`, one true god view (`BookView`), and a
shared-home rule being quietly ignored.**

### 2.1 `EditorViewModel` (4,231 lines, 131 commits since July — the churn and size leader)

- **It is a router, not a rules engine** — the hot path (`shouldChangeText`) does no text math; it
  asks `BlockRangeIndex` for a verdict and dispatches to planners that all live in
  `Shared/EditorBrain/`. That is the prescribed shape, and it held.
- **It is god state:** 92 type-level properties on one `@Observable` class; the hot ones (`index`
  ×107, `slots`, `bulkPending`, `pendingEdit`) are crossed by unrelated concerns, and the file's own
  history shows the failure mode (a `didSet` added to stop a third adopter reopening a ghost-selection
  bug; `pendingEdit` hardened into `ArmedEdit` after a crash).
- **The 13b N10 "one-seam move" produced two files, not two modules:** `EditorViewModel` ↔
  `EditorSurfaceController` hold a mutual `unowned` reference; the controller touches **40 distinct
  `model.` members across 270 call sites**. Any state invariant spans both files. **Rule for any
  future editor split: define a value seam (a state struct passed in and returned), never another
  `model:` back-reference** — otherwise file count grows and coupling doesn't fall.
- **Three genuine leaks of rules into the class:**
  1. The **cross-block routing cascade's order** is itself a business rule, and it lives only as a
     prose-argued if/else ladder (`:1107–1177`) — untestable without a live NSTextView, and the mobile
     copy has a different arm set and order (§4). Highest-value extraction: a pure
     `Route`-deciding function in `Shared/EditorBrain/`.
  2. **Refusal copy duplicated against the canonical table:** `operationMessage(_:)` (`:4180`) is a
     private 12-string switch beside `Registry/OpsRefusalCopy.swift` (725 lines, ~20 consumers) — the
     code's own comment admits the duplication, and the sealed-note refusal is already **three
     different sentences in three places** (two on the Mac, one on the phone).
  3. **TK2 geometry computed in the view model:** `refreshDecorations()` (`:3755–3872`) does fragment
     lookups and coordinate conversion, defending itself from its own layout-forcing with a
     re-entrancy depth counter. Presentation geometry; belongs beside `BlockDecorOverlayController`.
- **Recommended splits (descending value):** `EditorDecorationCoordinator` (~350 lines + ~12
  properties, including the ones that exist only to defend the geometry walk);
  `EditorLandingController` (~520 lines: focus seeds, reveals, anchor restores, viewport carry,
  re-font reflow — self-contained); the routing cascade as a pure function; delete
  `operationMessage` in favour of `OpsRefusalCopy`; `contextMenuItems` as a builder over a facts
  struct. Together these drop the file under ~3,400 and remove the property clusters that make it a
  bug risk. `EditorSurfaceController`'s one seam: the merge ceremony is a self-contained ~700-line
  state machine (`:1241–1944`) — take it only when already in that code.

### 2.2 The explicit don't-touch list (big ≠ god)

`CapabilityRegistry` (1,679 — a declarative table; big means complete) · `TakesViewModel` (2,699 —
already decomposed into board/choreography/structure; the 82 forwards are the cost of the split, not
evidence of a missing one) · `RootView` (1,045 — the composition root the architecture rules require)
· `PaneSurface`, `EditorTextView`, `BlockDecor`, `PostureSwitch`, `BookIndexView` (one hard job each,
correctly layered) · the `XView.swift`-holds-`XViewModel` convention (trips greps, costs nothing).

### 2.3 `BookView` — the one true god view, and the 13i plan (author-directed)

`BookView.swift` (2,467 lines, 72 commits) is a single `View` struct with ~20 `@State` properties and
five unrelated jobs: the navigator (`:339–758`), a **second** sidebar note box beside the shared
`Core/Views/SidebarNoteBox` (`:758–849`), mode click-over carry, the order control, and the ~540-line
outline writing surface (`:1204–1745`).

**The author's call at this review (2026-09-21): 13i is where books gain locked books, more book
tags, and a real book identity — so the decomposition is PLANNED FOR 13i, as an opening unit, not
deferred as standalone cleanup.** The reasoning both ways, recorded:

- *Why not now:* splitting a SwiftUI View whose sub-views read ~20 sibling `@State` properties means
  threading bindings — view-identity and animation regression risk the suite cannot catch (it pins
  geometry and landings, not transitions). The monolith is ugly but stable.
- *Why 13i's opening unit:* every 13i feature lands in exactly these regions; splitting the stable
  monolith **before** new features land is strictly cheaper than splitting mid-feature or after,
  and 13i will be walking every book surface anyway, which is when transition regressions are
  cheapest to catch.
- *The split itself:* `BookNavigatorView.swift` (navigator + chapter menu + navigateToChapter) and
  `BookOutlineSurface.swift` (the outline writing surface with its landing and drop handling); the
  folder's 17 existing files show the seams are already half-cut. Reconcile the in-file note box with
  the shared `SidebarNoteBox` while there.
- *Book-adjacent items 13i should sweep up in the same pass:* the `MembershipChip` hoist (§2.5 — a
  BookView-minted component with **zero** BookView consumers), the flow's two-height-rules collapse
  (§1.3 item 2), and the Outline's missing `landing.end()` teardown (§1.3 item 4).

### 2.4 Layering violations (all small, all cheap)

- **`PostDetailView`** (1,343 lines): a View with **no view model** that runs **raw SQL** from a
  `.task` in its body (`:552`), fires `renameContainer` from the view (`:862`), and reads the DB again
  at `:904`. The only SwiftUI view body in the tree that writes SQL. Fix: a `PostDetailModel` + the
  SQL to `Queries/`.
- **Raw SQL in the App layer** in exactly 4 files: `PostDetailView`, `BlocksWorkbenchView`,
  `LibraryListingReads`, `MobileBookViewModel` — each a query that belongs in core `Queries/`.
- **Sibling view-model constructions (3):** `LibraryCatalogTagActs.swift:69` and
  `PoolPostsView.swift:112` construct `TagAssignmentViewModel` (and Pool calls `TagsViewModel.message`
  — a sibling's copy logic); `AppSettingsView.swift:78` mints a **second owner** of `TagsViewModel`
  beside RootView's. All three trivially fixed: the wrapper is 13 lines over `Shared/TypedTagPath` —
  call that directly.
- **`AppSettingsView`** performs setting writes directly from the View (`:733/:750/:763/:991`).
- **Word count exists twice, byte-identical** (`Shared/EditorBrain/TextMetrics.swift:14` ≡
  `Queries/ShelfQueries.swift:136`) — the core one's doc comment even names the fork. One line.

### 2.5 The shared-home rule — 7 components whose minting folder no longer uses them at all

Per the hoist-at-next-touch rule, these move at the next touch of work on each; listing them here so
"next touch" is recognized: `TrayPanel` (1,445 lines, five foreign consumers, zero local — the rule's
clearest case) · `BlockHistoryPane` · `NoteVersionsPane` · `FormatBar` · `NoteTagsRow` ·
`MembershipChip` (→ 13i, §2.3) · `SmartConversionOfferSheet`. Four more are cross-feature with the
owner still consuming (`LensNameSheet`, `ReadPostView`, `EditorView`, `ScrapsPanel`/`ReferencePanel`)
— legal renders, but the same rule fires at their next touch.

### 2.6 `TutorialSeeder` — a god function, trivially fixable

`seed(ops:existingTagID:)` is **one 1,546-line function**. The right shape is half-present (the
declarative `plan` table the walk tests assert against). Lift lesson content to data (one file per
chapter) and reduce `seed` to the ~40-line loop it wants to be — worth doing before the tutorial
gains another chapter, and `TutorialWalkTests` is a ready-made red-on-old check.

---

## 3. The Mac↔mobile editor conductor fork (the sharpest structural finding)

`Shared/EditorBrain/` (13 files, ~3,450 lines) genuinely holds the planners and both platforms consume
them. **What is not shared is the conductor code that drives them, and it is a line-for-line copy:**
crystallization ~89% identical (one function byte-identical *including comments*), the storage
primitives identical modulo accessor names, the identity audit identical modulo one accessor — ~700 of
`MobileEditorViewModel`'s 2,144 lines are parallel reimplementation rather than phone-native surface.

**The divergence is already live, in the safety-critical arm.** The cross-block routing cascade —
the code that decides whether a keystroke deletes blocks — has different arms in a different order on
the two platforms. Reconciliation with the ledger, so this is neither over- nor under-claimed:

- The phone's missing seam arms (A7 empty-block carve, #34 seam merge) are **tracked** — ledger row 53
  names them, owner the mobile catch-up.
- The phone's gap fence above the compound is plausibly deliberate (its async storage road).
- **What is untracked:** the duplicated conductor band itself, and the fact that the routing *order* —
  a ruled business rule, argued at length in comments — lives twice as prose-adjudicated if/else
  rather than once as a pure decision. Row 28's own 13u1 amendment says its list is "the KNOWN forks,
  never the proven-complete set" and that the honest answer to "are there others?" is a fresh grep.
  **This review is that grep; the conductor band is its answer.** (Also found: the tutorial seeder
  *scaffolding* — `Existing`/discover/restore machinery — duplicated ~120 lines on the phone; the
  content difference is deliberate, the machinery is not.)

**Recommendation:** hoist in this order — (1) the routing cascade as a pure `Route` function in
`Shared/EditorBrain/` (it is the part that is actually broken, and it forces the two platforms'
differences to become *declared* arms rather than drifted copies); (2) crystallization + storage
primitives + identity audit on the 3C zero-test-edit parity pattern the repo has now executed
successfully at least six times; (3) refusal copy onto one table with platform door-names kept local
(MobileSoul §4.4). Effort large, risk medium, mitigated by 293+68 app test files and the proven
pattern. This is the mobile catch-up round's natural spine, or its own unit before it.

---

## 4. VariorumCore (the substrate) — healthy, three actions

**Verdict: close to exemplary.** Zero TODO/FIXME in Sources; zero writes anywhere in `Queries/`;
18 strictly linear migrations (one guarded data rewrite, everything else additive); trigger discipline
exactly as specified — 11 cascades + generated outbox pairs, nothing leaked in; TEXT fractional
positions everywhere; every uniqueness index live-row partial; the E2EE per-column classification
complete with its own completeness test; op→suite mapping ~1:1 and genuinely state-transition-shaped;
exactly two sleeps in 49k test lines; real network confined to one env-gated suite.

Actions:

1. **`Operations+Structural.swift` (1,443 lines) is carrying two things:** the structural family AND
   the package's shared row primitives (`placedContext`, `ensureEditable`, `mintBlock`,
   `insertLineageEdge`) that six other Operations files import from it. Cleave the primitives into
   their own file. While there: the **neighbour-position SQL is written four times verbatim** (divideW
   / divideDuplicating / merge / mergeCeremony) — one helper; **`divideDuplicating` re-implements the
   divide choreography inline** instead of reusing the `*Rows` cores its three siblings share (and
   `splitBlockAtNewlines` composes beautifully — the pattern exists); `merge`/`mergeCeremony` share
   their whole outer skeleton and want a `mergeRows` core with `merge` as the degenerate call.
   Mechanical, test-protected, no semantics change.
2. **`PurgeJanitor.swift` has become two types in one file** (`PurgeJanitor` + `LocalPurge`, each with
   its own `sweep()`); `ShelfQueries.swift` (770) is accreting the catalog search and the note picker
   under the shelf's name. File splits, nothing more.
3. **Risk drift worth naming for Phase 12** (tracked rows whose risk has grown since written):
   - *Pull-to-head memory (row 17)*: the one-transaction pull now also runs the straggler fixpoint,
     repairs, dedupe and ledger work in the same transaction, **and 14b added a decrypt of every row
     before it opens** — peak memory is now ciphertext + plaintext of the whole corpus. Push was
     chunked; pull was not.
   - *Janitor sweep (row 20) compounded by no-ANALYZE (row 45)*: four un-indexed tombstone scans plus
     the `commit_point` GROUP BY, with no statistics ever created — two independently-written rows now
     describe one hazard.
   - *Version-link severance (rows 12/29)*: every widening of purge-family expansion enlarges the
     surface on which a live note's version links can be severed, while owner 13w remains unslotted.
   - *Repairs.swift and SampleLibraryDedupe.swift* are among the package's most-churned files and both
     carry tracked narrow-race rows (33/34) whose owners (18a, 17i) have not run.
4. **Dead code, one file:** `Sync/RekeyRecencyProbe.swift` (159 lines, zero consumers) — already
   ledger row 56, but see §7: its owner just closed.

---

## 5. The SwiftUI state-write sweep (the ~1,989 warnings) and process-global state

### 5.1 The warnings are a handful of shapes, not a thousand sites

The models are already defended (`@ObservationIgnored` on geometry-fed fields); `onPreferenceChange`
doesn't exist in the codebase; the six known-correct deferral sites all check out. The generators:

- **A1 — `PanePublisher` publishes pane heights synchronously mid-layout, by documented choice**
  (starvation risk of a deferred-only publish under a busy main queue, with a deferred convergence
  turn behind it). Fires per pane × per mount × per layout pass across ten composers, several of which
  mount panes by the dozen. **Estimated majority of the count. This needs a RULING, not just code**
  — defer and accept the named starvation risk, keep sync via a path SwiftUI doesn't flag, or accept
  and document. *(Author sitting item; the irony: `deliverMeasuredHeight` beside it already defers,
  with a comment naming this exact hazard.)*
- **A2 — `InlineEditorSurface`'s height `@Binding` is written from inside `makeNSView` and every
  `updateNSView`** (`EditorView.swift:552–562`, target `@State inlineHeight` read in the same body).
  **Top active-bug candidate:** a dropped write leaves the editor framed at 24 pt → under
  `StableSurface`'s 60 pt placeholder ceiling → `loaded` never flips → the near-band decides on a
  false frame → a second realization. That chain would explain row 43's surviving double-realization
  *and* why it only shows on long notes — and the 13u2 trace eliminated the Outline row's publish,
  **not** the representable's binding. ~4-line fix (defer, as the same coordinator's storage path
  already does); measure first.
- **A3 — ~14 un-deferred geometry actions**, one of which is a gift:
  `BookIndexView.swift:791` is the **un-deferred twin** of the known-correct deferral at
  `BookView.swift:1413` — same call, same author, one wrapped and one not. Canvas is the only view
  model handing geometry straight into observed storage (including the `ForEach`-driving
  `realizedIDs`) — and `CanvasDragTrackingTests` is on the load-flaky list; structure matches symptom,
  unproven without a run.
- **A4/A5 — ~6 one-line deferrals** in window registration and onAppear paths (care: the sticky-key
  ruling in `WindowRegistry`'s header).

Sizing: one focused session for A2 + A3 + the twin; a separate ruling-then-implement unit for A1.
Fixing A1+A2 alone should more than halve the warning count — which matters beyond hygiene, because
the load-flaky test family (rows 25/26/38/44/52's residue) most plausibly lives downstream of it.

### 5.2 Process-global mutable state

The 13u4 ownership-defect shape (a global registration keyed by subject with no record of WHO
registered it) has **unfixed instances**: `BookOutlineGeometry.focusDoors` (the clearest — two windows
on one book cross-clear each other's doors; its closure captures a `@State`-owned model),
`PostDetailOracle`'s four unkeyed singletons (`beginTitleEditing` is never cleared by anyone),
`ShellGeometry`/`CommitBarGeometry`/`CanvasArrivalOracle`/`BookIndexGeometry` unkeyed frames, two
append-only trace buffers never cleared by `resetNavigator()`, and `SidebarGeometry`'s subject-keyed
(not owner-keyed) maps. All DEBUG-only blast radius — but "a pin green for an ordering reason" is
exactly the class 13u4 existed to kill, and the fix is applying the twenty-line owner-keyed shape that
already exists in three fixed reference sites (`ShellRouter.blockNamingDoors`,
`PostDetailOracle.stamp*`, `CatalogStampOracle`). *(17-entry or Phase 12 harness family.)*

Non-DEBUG globals: one to guard — **`MarkdownStyling.palette`** has three writers, one of them a
pane's `updateNSView` (`applyFace`, "the third writer of that global"); fine while appearance is
app-wide, a real race the day anything is per-window. `EditorTypography.current` same class, lower
risk. Everything else checked clean (locks, idempotence latches, owner-keyed seed latches).

---

## 6. The lifecycle audit — one real leak, everything else clean

**Verdict: there IS a systemic lifecycle discipline and it holds.** One convention — *the `.task` is
the cancellable, the `.id(postID)` is the note switch, `catch CancellationError` is the exit* —
applied to all 63 GRDB observation sites; token-guarded registries designed around SwiftUI's
mount-order non-guarantee; **no Combine, no KVO, no Timer on the Mac at all** (three leak families
absent by construction); nothing structurally prevents deinit of any big view model. No accumulating
ValueObservation leak exists: a note switch cannot strand one, a mode switch cannot double one.

### 6.1 The leak: the autosave-coordinator registry (HIGH confidence, verified independently)

`AppSession.autosave(forPost:)` mints a coordinator into `postAutosaves` and registers a
`quitFinalize` closure per post. **`releaseAutosave(forPost:)` exists, is conservative (refuses to
drop a dirty coordinator), is unit-tested — and has exactly ONE production caller, the phone's quick
note** (grep-verified at this review). All seven Mac holders take and never give back
(`EditorViewModel`, `TakesViewModel`, `BlockTOCView`, `CanvasViewModel`, `CompareBoardView` ×2,
`BookIndexEditModel`) — each teardown calls `stopObserving` but never releases.

Consequence: one coordinator + one quit-finalize closure per **distinct note touched this session**,
forever — and the felt cost is that **every screen lock and every ⌘Q** serially walks ALL of them,
each an awaited `closeAutoCommit` **write transaction opened unconditionally**. After days and
hundreds of notes, that is hundreds of serialized DB writes on the path that blocks lock teardown.

Fix: call `releaseAutosave` in the six teardowns. Confirmation before/after is already wired:
`AppSession.openAutosaveCount` and `QuitFinalizeRegistry.count` exist for exactly this claim — print
either after a day of normal use; hundreds instead of a handful confirms it. *(17-entry class; the
red-on-old pin is the registry count across an open/close cycle.)*

### 6.2 Smaller, bounded, named

- `EditorRouter`'s three per-note dictionaries grow monotonically per note opened, never pruned —
  the per-note-defaults family (ledger row 39), tiny per entry; prune on note purge alongside it.
- `PoolViewModel.restartItems`'s nested Task is orphaned if the outer loop exits via a **DB error**
  rather than cancellation (store-lock races) — `[weak self]` saves the model, not the re-querying.
  One-line restructure.
- `ThemeStore.start()` has no re-entrancy guard — up to 4 concurrent observations of a tiny table per
  window. Duplicate work, not a leak.
- `StoreBackup.onRun` captures one per-window model app-lifetime, overwritten by the next window —
  bounded at exactly one stale model.
- `BookIndexView`'s per-near-row `observeBlockTOC` re-queries at keystroke cadence × near-viewport
  rows — **by design**, bounded by viewport, and the widest member of the tracked row-13 family;
  named here so Phase 12's measurement includes it.
- Verified-clean list (don't re-walk): all 63 observation sites enumerated in the audit; all 9
  block-based `addObserver` sites paired; all 5 local event monitors paired; the three long-running
  service loops correctly guarded.

---

## 7. Bookkeeping this review cannot do itself (shared docs untouched by instruction)

For the author or the next session that legitimately owns the ledger:

1. **Rows 56 and 57 point at owner 17l, and 17l CLOSED 2026-09-21** (RUN A batch A2 re-owned only
   item 5 → RUN B). Both rows are now in the blank-owner state the file's own rule forbids — and row
   56 guards the package's only dead file (`RekeyRecencyProbe`).
2. **Row 27's owner** ("the Whole-library text search row") is stale — FuturePhases records that row
   elevated into **13o** on 2026-08-19.
3. **Row 28's fork list has new members** from this review's §3: the editor conductor band
   (crystallization / storage primitives / identity audit / the routing cascade) and the tutorial
   seeder scaffolding. The row's own 13u1 amendment invited exactly this refresh.
4. **New rows this review would file** (each with the owner class suggested in its section): the
   autosave-registry leak (§6.1) · the InlineEditorSurface height binding (§5.1 A2, tied to row 43)
   · the PanePublisher ruling (§5.1 A1) · note Read's landing adoption (§1.3) · the BookView-at-13i
   decomposition plan (§2.3) · the conductor hoist (§3) · `PaneMeasurement`'s per-keystroke
   whole-document walk (§1.5 T2) · the DEBUG-oracle ownership sweep (§5.2).
5. **A row nothing owns anywhere: accessibility/VoiceOver.** It appears in no canonical doc. Deferring
   is fine; it should be a decision with a row (the Design & UI review project row is the natural
   home), not an omission — "commercial someday" makes it eventually load-bearing.

---

## 8. Method + provenance

Five Opus read-only explorer agents (2026-09-21), each reporting with file:line evidence; claims that
carry recommendations in this file were spot-verified by the synthesizing session where load-bearing
(the `releaseAutosave` single-caller claim was independently grep-verified; churn counts from
`git log`). Static analysis only — no builds, no test runs, no app launches. Numbers quoted from
agent reports are line-referenced in their sections; anything a future session acts on should re-trace
its mechanism per the hallucination guard before fixing. This file is a REVIEW record, not canon:
where it disagrees with the spec docs or the ledger, they win.
