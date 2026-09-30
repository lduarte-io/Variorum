# Post-13u Health Rounds — 18k · 18l · 18m · 18n (kickoff prompts; author-ratified 2026-09-22)

**What this is:** four ready-to-paste kickoff prompts, born from
`notes/codebase-health-review-2026-09-21.md` (the read-only five-explorer audit) and the author's
2026-09-22 ratifications:

1. **The PanePublisher ruling, ratified verbatim:** *"attempt the frame-synchronous / state-deferred
   shape, walk the boards under load, and revert on any felt regression."* (Health review §5.1 A1 —
   the pane's visible AppKit frame is set synchronously so no pane ever visibly waits; only the
   SwiftUI state write defers; the existing convergence loop stays as the net.)
2. **The packaging and order below** — 18k first, then 18l, then 18m (then mobile work resumes);
   18n is flexible-slot. ***THE NAMING RULING (author, 2026-09-22, at the RUN B morning session —
   her words: "it's too confusing to have these different names"): the four rounds are 18 LETTERS
   — 18k runtime hygiene · 18l navigation feel · 18m the editor-conductor hoist · 18n structure
   singles.*** The round names "RUN C" / "the navigation-feel round" / "the editor-conductor
   hoist" / "RUN D" are RETIRED (kept below only as was-names); the master plan's row 18
   registers the letters; an 18 entry is a valid KnownIssues owner exactly as a 17 entry is, and
   these entries mint NO 17 letters — each entry is its own roster.
3. **The warming trigger protocol** (§W at the end of this file): warming is deliberately NOT built
   in these rounds; it is committed to only if the author still feels a first-visit stutter after
   18l (the navigation-feel entry) ships.

**Her schedule as stated 2026-09-22:** these rounds → 13y → 13r → friends beta → 13i → 13o → 13s →
remaining residuals / website / onboarding → general release. ***SUPERSEDED the same day by her
later ruling (recorded 2026-09-22 at the RUN B morning session): 13y runs NEXT — before these
rounds.*** The rounds keep their internal order (18k → 18l → 18m; 18n
flexible) and run at her word after 13y; the rest of the chain stands as stated. **RUN B** (the
Sync-fenced roster in `notes/plans/pre-beta-standing-fix-runs.md`) has since RUN AND FULLY
CLOSED — 2026-09-22: five batches + the hosted stress pass + a two-round ladder, finals green on
all four gates, and the live two-device acceptance round PASSED at her morning window ("yep it
worked"; the record is `notes/plans/run-b-sync-correctness.md`). Its closes matter below: **17i
and 17d are CLOSED, 17l item 5 RESOLVED, KnownIssues rows 34 + 37 removed, 17s is the last-minted
letter**, and the test baselines are RUN B's finals (18k's read-first names them). Nothing
below touches `Sync/`, by design.

**How to use:** paste one kickoff into a fresh session at its turn. Each round keeps its own record
file (named in its kickoff) from the first commit, per `notes/SessionResiliencyProtocol.md`. When a
round closes, its closeout may strike its row here; this file is otherwise not edited by the rounds.

| Entry | Record file | Status |
|---|---|---|
| **18k** — runtime hygiene (was "RUN C") | `notes/plans/phase-18k-runtime-hygiene.md` | **DONE 2026-09-25** (handoff `notes/handoffs/phase-18k-handoff.md`) |
| **18o** — correctness & honesty singles (17e's remainder + 17t; minted at 18k's kickoff sitting, R-18k-1) | `notes/plans/phase-18o-correctness-singles.md` | **DONE 2026-09-30** (handoff `notes/handoffs/phase-18o-handoff.md`) |
| **18l** — navigation feel | `notes/plans/phase-18l-navigation-feel.md` | pending — **likely NEXT after 18k** (her word 2026-09-25, carrying the new U0: the Index click lands on the empty paragraph); 18o after it |
| **18m** — the editor-conductor hoist | `notes/plans/phase-18m-editor-conductor-hoist.md` | **DONE 2026-09-29** (handoff `notes/handoffs/phase-18m-handoff.md`) |
| **18n** — structure singles (was "RUN D") | `notes/plans/phase-18n-structure-singles.md` | pending (flexible slot) |

## THE OWNERSHIP MAP (her 2026-09-22 instruction: every left-behind item traceable to an owner, 18 where the rounds were the answer)

The left-behind list she was handed (the adviser's seven, pre-dating RUN B's close), each item's
home as of 2026-09-22:

| # | Item | Where it lives |
|---|---|---|
| 1 | Phase 12 has no slot in the stated schedule (23 ledger rows park there) | **Owned by Phase 12 itself — NOT an 18 item** (moving the hardening phase's rows would dissolve it). The open half is SCHEDULING ONLY, hers: the adviser's recommendation — right after friends beta, fed by beta-scale evidence — stands recorded here for her word. **This is the one list item still needing her decision.** |
| 2 | Row 34 — the tag.path application loss (17i "never run") | **RESOLVED — RUN B** (closed 2026-09-22, live round passed): row 34 FIXED both faces (arrival-order + the F-3 reject face), 17i CLOSED. Nothing owed. |
| 3 | Rows 56/57 orphaned on the closed 17l (RekeyRecencyProbe wiring; the recovery-phrase copy doors) | **18k** (interim owner at her word — RUN B closed without adopting them; the ledger's owner cells updated this commit). 18k's C0 proposes the DURABLE owner and she confirms at its checkpoint; a fix carries the custody Fable rider. |
| 4 | 17e's correctness singles unscheduled (the Canvas ⌘K wrong-target; the #136(b)/#138(f) product calls) | **Rides 18k** (item C5 below, the adviser's fold-in at her word). The 17e entry stays the BINDING record; the product calls surface to her at 18k's checkpoint, never decided. |
| 5 | Row 51 — the phone's tutorial teaches the retired duplicate-divide default | **Owned — the mobile app project row** (the ledger's standing owner; "a 17 entry at her word takes it earlier" stands). Flag for her: if friends beta includes the phone, the pre-beta pull-forward needs her word. |
| 6 | 13w / the version-anchor schema call (#19(c)) | **Owned — 13w** (FuturePhases) holds both rows. The DESIGN decision's recommended sitting is 13i's (the next lockstep moment) — hers to adopt at 13i's kickoff; recorded, not moved. |
| 7 | The smaller residue | Accessibility → **filed by 18k's C0** onto the Design & UI review project row (the review's own §7.5 proposal). The EditorViewModel decomposition rows → **18m** (it IS the next phase that opens the editor — the BookView-at-13i pattern, letterized; C0 files them so). 13m's export polish → 13m (owned, FuturePhases). The dedupe residuals → 18a (owned). |

The adviser's four-kickoff list maps 1:1 onto the letters: kickoff 1 → **18k** · kickoff 2 →
**18l** · kickoff 3 → **18m** · kickoff 4 → **18n** (the PurgeJanitor-split exclusion it recorded
is owned at **18a** — the D1 paragraph below).

---

## KICKOFF 1 — 18k: the runtime-hygiene run (was "RUN C")

You are the orchestrator of **18k — runtime hygiene** (the RUN A discipline: one roster, each item
independently scoped, cast, run and closed — but the entry is 18k ITSELF, her 2026-09-22 letters
ruling: no 17 letters are minted for C0–C5; they are 18k's own items, dispositioned in its record).
Every item is a runtime-hygiene fix from the post-13u health review.

**Read first, in this order:** `notes/codebase-health-review-2026-09-21.md` (§5, §6, §7 are this
run's charter); `notes/KnownIssuesAndTechDebt.md` (you will edit it — read the header rule); the
17-file `notes/plans/phase-17-standing-fixes.md` for **17e**, whose roster rides this run (item C5
— its dispositions land in the 17e entry, which stays the binding record; NO new 17 letters are
minted, per the letters ruling); `notes/SessionResiliencyProtocol.md` (you, at kickoff); the latest closed run's finals
for the test baseline — **RUN B's** (`notes/plans/run-b-sync-correctness.md` CLOSEOUT: core
**1679/179** clean · full Mac **3089/510** with the one paired-protocol standing flake · mobile
**642/109** with exactly the 4 known · iOS green · install `1ab27652`) — read it, never rerun the
suite at start.

**Cast (the author's standing shape; she may redirect at invocation):** Fable orchestrates (this
session, writes no feature code) · one `opus-implementer` per entry, briefed with the checkpoint
rules RESTATED in the brief's own text · cold review per R-cor-14: **Opus cold review always; Fable
cold review for any diff touching the editor seam (`EditorTextView`/the `EditorViewModel` storage
seam/`PaneSurface`), custody/keychain, or `Sync/`** — expected here only if C2's fix drifts wider
than planned. Strictly sequential, one agent at a time.

**Standing rules, restated because they bind every entry:** pin before fix — the red-on-old pin binds
exactly as in a phase review, and a pin green on both sides dismisses the entry as hollow (recorded,
not fixed). No finding is fixed until the fixer has traced the concrete mechanism themselves. Commit
per piece, LIVE STATUS in the run record from the first commit, push after each, synchronous
foreground waits only. NO commit trailers. Tests at the END. PROVISIONAL-and-continue for
non-gating ambiguity (log to `notes/QUESTIONS.md`); stop-and-report for gating ambiguity and every
author-only call. The run closes on use-shaped evidence, and the install refresh
(Release build → `/Applications`) follows if the Mac app changed.

**The roster (18k's own items, in this order):**

- **C1 — the autosave-registry release** (review §6.1). Seven Mac acquisition sites, one release
  caller (the phone). Fix: the six teardowns call `session.releaseAutosave(forPost:)` after their
  flush/`stopObserving` (sites enumerated in §6.1; `releaseAutosave` already refuses a dirty
  coordinator, so order the teardown flush-then-release). **Pin (red-on-old):**
  `AppSession.openAutosaveCount` / `QuitFinalizeRegistry.count` across an open→close cycle — old
  code ratchets, fixed code returns to baseline. **Use-shaped evidence:** the lock/⌘Q finalize walk
  is measured before/after with many notes opened (the felt cost §6.1 names). Verify no behavior
  change to the leaving-savepoint (`closeAutoCommit`) semantics for notes still open.
- **C2 — the inline editor's height binding** (review §5.1 A2; ledger row 43's surviving half).
  **MEASURE FIRST:** instrument the predicted chain (dropped mid-update write → 24 pt frame → under
  `StableSurface`'s 60 pt placeholder ceiling → `loaded` never flips → near-band on a false frame →
  second realization) against the row-43 long-note fixture BEFORE fixing; if the mechanism is
  confirmed, the pin is the double-realization count; if disproved, record that honestly — the
  deferral fix still lands as warning-class hygiene, but row 43 is not claimed. Fix: defer
  `reportHeight` out of `makeNSView`/`updateNSView` exactly as the same coordinator's
  storage-notification path already does (the pattern is in the file).
- **C3 — the mechanical state-write deferrals** (review §5.1 A3/A4/A5). The ~14 un-deferred geometry
  actions (the `BookIndexView:791` twin of the known-correct `BookView:1413` deferral first — it is
  a one-line copy), Canvas's observed-storage geometry writes, the plain-`@State` sites, and the
  window-registration sites **with care** (the sticky-key ruling in `WindowRegistry`'s header binds).
  Acceptance is a per-site verdict table (the 13u4 UNIT S3 precedent) + a before/after warning-count
  measurement on a bounded run; behavior byte-identical.
- **C4 — the DEBUG-oracle ownership sweep** (review §5.2). Apply the owner-keyed registration shape
  from the three reference implementations (`ShellRouter.blockNamingDoors`,
  `PostDetailOracle.stamp*`, `CatalogStampOracle`) to: `BookOutlineGeometry.focusDoors` (the
  clearest, and the one whose closure captures a `@State`-owned model), `PostDetailOracle`'s four
  unkeyed singletons, the unkeyed frame singletons (`ShellGeometry` · `CommitBarGeometry` ·
  `CanvasArrivalOracle` · `BookIndexGeometry`), the two append-only trace buffers, and
  `SeamGrip`/`SidebarGeometry`'s subject-keyed-not-owner-keyed maps. DEBUG-only blast radius; the
  pin class is the two-window cross-clear test the reference fixes already model. Add the one
  non-DEBUG guard: a comment-plus-pin on `MarkdownStyling.palette`'s three-writer invariant.
- **C0 — ledger housekeeping** (review §7; may run first or last). Rows 56/57's re-own is DONE
  INTERIM (owner **18k**, set at her 2026-09-22 word after RUN B closed without adopting them —
  the ledger's owner cells carry it): C0 proposes the DURABLE owner (a fresh protection-class
  letter, or 18b, whose restore/credential surface is adjacent) and the author confirms at the
  checkpoint; fix row 27's stale owner pointer (→ 13o); add the review's §3
  finds to row 28's fork list (the editor conductor band; the tutorial-seeder scaffolding); file the
  review's new rows with the owners its sections propose (T2 → 12; `StableSurface`'s asyncAfter →
  12; the warming assessment → 12; the EditorViewModel decomposition rows → **18m**, the next
  phase that opens the editor — the BookView-at-13i pattern, letterized; the §7.5 accessibility
  decision row → the Design & UI review project row, its own proposal; anything this run fixes
  needs no row). Every edit follows the ledger's own header rule: no row without an owner.
- **C5 — 17e's correctness singles RIDE THIS RUN** (her 2026-09-22 word, the left-behind list's
  item 4 — the fold-in). The 17e entry in the 17 file stays the BINDING record and its
  dispositions land there. Size at kickoff — 17e's own text expects a split: the minimum take is
  the Canvas focused-block row (⌘K "Block History" opening on the wrong target); the two
  product-call rows (**#136(b)** note-scoped undo · **#138(f)** cross-device deletion finality)
  are SURFACED to her at the checkpoint, never decided. If the fold makes 18k oversized under
  `notes/PhaseSizingGuidance.md`, say so to her rather than splitting silently.

**Close:** dispositions per item in the run record (C5's into the 17e entry); the ledger rows
updated; finals recorded;
MOBILE PARITY line (expected: "nothing mobile-visible" — C1–C4 are Mac-app/DEBUG surfaces; say so
explicitly); install refresh if the app changed; checkpoint report to the author; push.

---

## KICKOFF 2 — 18l: the navigation-feel round

You are the orchestrator of **18l — the navigation-feel round** — the entry that finishes the landing
subsystem's perimeter so the author can "click around everywhere with no issues." The subsystem's
core is sound and recently proven (13u4 UNIT F3: 13/13 cold deep clicks at `top=0, hops=0`); this
round transplants that shape onto the two surfaces that never adopted it and lands the author's
ratified PanePublisher change. Record file: `notes/plans/phase-18l-navigation-feel.md`.

**Read first:** `notes/codebase-health-review-2026-09-21.md` §1 whole (the map, the stutter
diagnosis, the work list, §1.4's warming refusal — warming is OUT of this round's scope by the
author's ratified protocol, §W below); `Surface/LandingAuthority.swift` (the header names the
adopt-at-next-touch expectation this round discharges) and `Surface/BookHeightManifest.swift`;
the 13u4 UNIT F3 record in `notes/plans/phase-13u4-restyle.md` (the pattern being transplanted);
`Features/Takes/TakesArticleScroll.swift` + the 13u2 UNIT E record + ledger row 44 (what U2 may and
may not touch); the 17q/R-Q20/R-Q21 record (`notes/plans/use-report-round-2026-09-12.md` R-8) —
**the Takes restore half encodes author rulings and is byte-preserved**; `PaneSurface.swift`'s
header (the deliberate-sync reasoning U3 supersedes under her ratification);
`notes/SessionResiliencyProtocol.md`.

**Cast:** Fable orchestrates · `opus-implementer` per unit · cold review per R-cor-14 — **U3 and
anything touching `PaneSurface`/the editor seam takes a FABLE cold reviewer; U1/U2 take Opus unless
their diffs drift onto the seam.** Sequential, one agent at a time.

**Units:**

- **U1 — note Read adopts the F3 shape** (review §1.3 item 1). A `LandingPolicy.readNote` (+ one for
  the edit face if its `.center` anchor wants its own constants), a per-note **block** manifest from
  the already-cached `Queries.blockExtents` through `ProseHeightModel` (exactly what
  `BookIndexPaneHeights` did for whole notes, one level down), rows as placeholders at asserted
  heights, the authority's aim/hold/correct/watchdog loop replacing the one-shot `scrollTo` in BOTH
  faces (`ReadModeView.land`, `ReadEditPane.land`), the signpost for free. **Keep the shipped
  resting anchors** (page 0.08, edit `.center`) — where a landing puts the block is product,
  not this round's call. The contents columns may adopt the same aim if cheap; else record.
  **Acceptance is measured, F3's own protocol:** cold and warm deep-click runs on the real
  long-note fixture, N-of-N settling at the anchor with `hops=0` cold, plus a hands-on walk; and
  the Console diagnostic from review §1.2 flips (the stutter path now EMITS `landing` lines).
- **U2 — Takes' landing half adopts the authority; the restore half is untouched** (review §1.3
  item 3). Grow the authority an **aim kind** (top · minimal-reveal · viewport-fraction —
  `ViewportCarry.anchor` supplies the vocabulary), then move `articleLandingStep` /
  `revealDecision` / `revealAnchor` onto it under a `takesArticle` policy. The `.holding` restore
  machinery, `ArticlePlace`, the 24-aim budget, and every R-Q20/R-Q21 behavior ride byte-unchanged;
  the ~15 gesture-end pins and the projection arm must pass UNMODIFIED (the 3C proof — if a pin
  needs editing, the move changed behavior; stop and re-trace). This is the round's hardest unit;
  ledger row 44's residue list is its known-issues context.
- **U3 — PanePublisher, the ratified shape** (review §5.1 A1). Implement frame-synchronous /
  state-deferred exactly as ratified: the AppKit frame lever answers the visible height in the same
  pass; the SwiftUI state write defers; the convergence loop and `deliverMeasuredHeight`'s existing
  deferral stay. **The gate is her sentence:** walk the boards under load (big fans, Compare pairs,
  the book Index, both voices, both appearances) and **revert on any felt regression** — a revert is
  a valid close for this unit, recorded with the observation that forced it. Measure the
  warning-count before/after (the A1 apportionment hypothesis: expect the majority of ~1,989 to
  fall); record the number either way.
- **U0 — FIRST: the book Index click lands the caret on the EMPTY paragraph, not the line clicked**
  (her report, 2026-09-25, during 18k's closeout — verbatim: *"it's a regression that's quite annoying
  honestly and it'll 100% be on the next session that runs. While in index mode on a book, clicking
  onto text isn't working correctly. When I'm in sherlock holmes and I click on top of a line of text,
  my cursor moves to the empty paragraph / block between the text and then I have to try clicking
  again to get onto the actual text. Maybe that should be part of 18l? In which case I would probably
  run 18l next."*). Seen on her INSTALLED build — 13y's `9e15f8bf…`, so it PREDATES 18k (none of 18k's
  changes were installed when she reported it). The Sherlock stories keep a blank paragraph between
  every two (18k C6b measured: 211 of *Copper Beeches*' 212 blocks end in a newline), which is exactly
  the target a vertically-offset hit-test would land on. **Unit shape:** REPRODUCE first (dev-store
  Debug, Sherlock ▸ Index ▸ click on a line; Accessibility + Screen Recording are granted to Ghostty
  since 18k), find WHEN it regressed (bisect by harness, never an old build on the dev store), trace
  the click → caret road (the read-tier → live-editor swap; the click's point converted through the
  surface's geometry — the 13c 1A container-inset class that `ScrollAnchorTests` guards is the first
  suspect; 18k C6b's `topVisibleOffset` baseline rule is NOT on this road but read its record), fix
  with a red-on-old pin, and walk it (both voices; lines at the top, middle and bottom of a note; the
  first and last line of a block). **The editor seam → a Fable review.** This unit runs FIRST in 18l.
  **HER FOLLOW-UP, the same evening (verbatim):** *"additionally, the bottom line of text in Read view is
  very slightly cut off at the bottom - in this image, it's clear that the G's in the final line of text
  in book view with a note extended are slightly cut off towards the bottom. also, I'm clicking DIRECTLY
  on the line of text and I always go to an empty line when I click, so it's not a slight mislick, it's
  a refusal of clicking into the text. I think that 13l will have to investigate editor regressions
  that must've happened during recent fixes."* (Her "13l" read as **18l** — 13l closed 2026-08-24; the
  orchestrator told her so the same turn.) Her capture:
  **`notes/plans/18l-inputs/2026-09-25-book-last-line-descenders-clipped.png`** — the book view, *about
  this text* expanded, the last line's descenders ("tagged") cut at the bottom edge. So U0 carries
  THREE things, and its first act is the investigation she asked for:
  1. **The click REFUSES the text** — clicking DIRECTLY on a line always lands the caret on an empty
     line; never a near-miss. (Treat as deterministic, not a hit-test tolerance problem.)
  2. **The last line's descenders are CLIPPED** in the book view with a note expanded (her capture).
     A context fact from 18k C2: TK2's first full measure after window entry / width change / edit can
     differ from the settled layout, and the inline editor has no convergence re-report — a frame sized
     from an unsettled SHORT measure would clip exactly like this (C2 measured the TALL direction; this
     may be the short one). Her build is 13y's, i.e. PRE-C2 — check both before and after C2's deferral.
  3. **An editor-regression SWEEP** (her ask): identify which recent fix introduced (1) and (2) —
     bisect by harness over the 13u2…13y/18k commits that touched the book surfaces, the inline editor,
     `PaneSurface`, the read-tier → live swap and landing — and report every regression found, not only
     these two. Each finding: reproduced, traced, pinned red-on-old, fixed or owned.
- **U0b — WRITE: removing a newline collapses the top padding** (her report, 2026-09-25, verbatim:
  *"when I am in write and remove a newline, the editor's height adjusts removing the whitespace between
  *[removed for publication]*
  **`notes/plans/18l-inputs/2026-09-25-write-before-removing-newline.png`** (block 4/4, the caret on an
  empty last block; the first line sits ~40 pt below the masthead's divider) and
  **`…-write-after-removing-newline.png`** (one backspace later — block 3/3: the first line has jumped UP
  to ~14 pt below the divider; the page's top air is gone). Reproduce, trace (a height/inset change on a
  block deletion at the note's end — the Write surface's top inset, the typewriter room, and the
  18k C6/C6b jump/anchor changes are all on the candidate list; her build is 13y's, pre-18k), pin
  red-on-old, walk. Part of U0's regression sweep; the editor seam → Fable review.
- **U-VIS — a VISUAL REGRESSION HARNESS (her standing ask, 2026-09-25, verbatim: *"in general, 18l
  should become responsible for devising some tests that can run (don't have to be part of the suite
  that run every time) where screenshots are taken of edits, clicks, if the editor has moved
  unexpectedly between clicks, etc."*).** An OPT-IN suite (gated like the keychain drills — an env flag,
  run on demand, never in the default run) that drives the REAL window on the dev-store Debug build
  (Accessibility + Screen Recording are granted to Ghostty since 18k; `Tools/WalkKit/` is the base) and
  captures before/after each scripted act — typing, a newline added and removed, a click on a line
  (assert the caret lands ON that line), a block divided/merged, a mode switch — and ASSERTS on
  measured geometry, not only pictures: the first visible line's y and the caret's line must not move
  unless the act moves them; the last line's full glyph box lies inside the surface (no clipped
  descenders); a click lands on the clicked line. Captures to a gitignored folder with a short report.
  Seed it with U0/U0b's three reproductions so each is a standing tripwire. Its design is 18l's to
  propose; its first run is the evidence for U0/U0b.
- **U4 — the one-liners** (review §1.3 items 2/4): the book Outline gains
  `.onDisappear { landing.end() }` (R2-12 parity with the flow and Index); `LandingTarget.utf16Offset`
  is wired or deleted (recommend delete + a comment naming the `FocusedBlock` road that actually
  carries the caret; PROVISIONAL either way, QUESTIONS row); `FlowStoryRow` reads
  `BookHeightManifest.resolve` instead of `FlowHeightEstimate.honestHeight` (D1) **unless** 13i has
  already taken it — check first.

**Standing rules:** as 18k's paragraph, verbatim — pin-before-fix and traced mechanisms bind;
commit-per-piece + LIVE STATUS + push; no trailers; tests at end against the last recorded finals;
PROVISIONAL-and-continue; author-only calls are hard stops. **The round closes on use-shaped
evidence** — the walk is the acceptance, pins are the floor — and the install refresh follows the
walk. MOBILE PARITY line at close: name what the phone owes a version of (likely: nothing for
U3/U4; U1's shape is the phone's own long-note landing pattern to inherit later — say which).

---

## KICKOFF 3 — 18m: the editor-conductor hoist (runs before mobile work resumes)

You are the orchestrator of **18m — the editor-conductor hoist** — retiring the ~700-line Mac↔mobile
conductor duplication and turning the drifted cross-block routing cascade into ONE pure, tested
decision. This round is the opening spine for the mobile catch-up that follows it: the phone's owed
seam work (ledger row 53) will then land as declared arms of a shared brain instead of a third
copy. Record file: `notes/plans/phase-18m-editor-conductor-hoist.md`.

**Read first:** `notes/codebase-health-review-2026-09-21.md` §3 (the charter) and §2.1 (the three
leaks — this round takes leak 1 and leak 2); ledger rows 28 (the fork rule and the 3C zero-test-edit
parity pattern — this round's proof standard) and 53 (what the phone deliberately lacks TODAY — this
round must NOT build the phone's seam carves; it makes them buildable); `MobileSoul.md` §3/§4.4;
both conductors side by side (`EditorViewModel` bands and `MobileEditorViewModel` bands — the
review's §3 table maps them); everything in `App/Variorum/Shared/EditorBrain/`;
`notes/SessionResiliencyProtocol.md`.

**Cast:** Fable orchestrates · `opus-implementer` per unit · **FABLE cold reviewer on every unit —
this is editor-seam surgery by definition (R-cor-14).** Sequential.

**Units, in this order (each lands alone, each on the 3C proof):**

- **U1 — the routing cascade becomes a pure function.** `EditorEditRoute.route(...) -> Route` in
  `Shared/EditorBrain/`, taking the verdict/index facts and a **declared platform capability set**
  (the Mac's seam-carve arms; the phone's gap fence) so each platform's arm set and ORDER is data
  the function is tested over, not prose in an if/else. Both view models' cascades become one call.
  **Proof:** every existing routing/gesture pin on BOTH platforms rides UNMODIFIED, plus a new pure
  table suite pinning the ORDER itself per platform (the thing that is untestable today). Zero
  behavior change per platform is the acceptance bar — a differing route for any input is a finding,
  not a fix.
- **U2 — crystallization, the storage primitives, the identity audit.** The review measured these
  ~89%-to-byte-identical; hoist on the 3C pattern (pre-move names forwarded where consumers need
  them; the platform accessor differences — `textStorage` vs `storage` etc. — become the thin
  injected surface). Zero test edits on both platforms is the proof; the Mac suite AND the full
  mobile suite run at the unit's end.
- **U3 — one refusal table.** `OpsRefusalCopy` hoists to `Shared/`; `EditorViewModel`'s private
  `operationMessage` switch is deleted; the six mobile `OperationError` switches collapse onto the
  table, **keeping platform door-names local** (MobileSoul §4.4). The three-way sealed-note wording
  converges on ONE sentence — the canonical table's string is the spec-defensible default,
  **PROVISIONAL** (copy is hers; QUESTIONS row with the three current sentences quoted).
- **Optional U4, take-or-leave at the orchestrator's sizing call:** the tutorial-seeder scaffolding
  dedup (~120 lines of `Existing`/discover/restore machinery; content stays per-platform by design).

**Standing rules:** as above, verbatim. Additionally: **zero `Sync/` lines** (nothing here touches
it; if a fix wants to, stop and report); the FULL mobile suite is part of every unit's finals, not
just the Mac's; ledger row 28's enumeration is updated as each fork is discharged (the touch rule,
honored in the same commit). MOBILE PARITY line at close: this round IS mobile-facing — state
exactly what the catch-up can now build on (the shared route function's declared-arm seam) and what
it still owes (row 53's carves, the refusal-copy faces).

---

## KICKOFF 4 — 18n: the structure-singles run (was "RUN D"; flexible slot; zero behavior change)

You are the orchestrator of **18n — structure singles**, a run of purely structural items — code
shape only, zero behavior change, each proven by unmodified-suite rides. It can run in any gap (the
author's stated lean: get the core solid now). Record file: `notes/plans/phase-18n-structure-singles.md`.
D1–D4 are 18n's own items (no 17 letters minted, per the letters ruling).

**Read first:** `notes/codebase-health-review-2026-09-21.md` §2.4/§2.5 and §4 (the charter);
`notes/SessionResiliencyProtocol.md`; the latest finals for the baseline.

**Cast:** Fable orchestrates · `opus-implementer` per entry · Opus cold review (nothing here touches
the editor seam, custody, or `Sync/` — if an entry's diff drifts onto one, the Fable rider fires).

**The roster:**

- **D1 — the `Operations+Structural` cleave** (review §4 action 1): the shared row primitives
  (`placedContext` / `ensureEditable` / `mintBlock` / `insertLineageEdge`) into their own file; ONE
  `neighborPosition` helper replacing the four verbatim copies; `divideDuplicating` adopts the
  `*Rows` core its siblings share; `merge`/`mergeCeremony` get a `mergeRows` core with `merge` as
  the degenerate call. **Proof: the entire structural state-transition suite rides UNMODIFIED**, and
  because `divideDuplicating` is live phone-side, the full mobile suite is part of the finals.
  **Excluded, deliberately: the `PurgeJanitor` two-types file split — it is `Sync/` (the rider),
  and RUN B was already mid-flight when this file was ratified (author, 2026-09-22), so it did not
  go there. The fork this paragraph carried ("17i if that runs pre-beta, else 18a") has since
  RESOLVED by its own else-arm: RUN B closed 2026-09-22 WITH 17i inside it — row 34's
  tag-application repair FIXED there (the very reason 17i was the recommendation) — and the split
  did not ride (RUN B touched `PurgeJanitor.swift` but split no files). The owner is therefore
  **18a**, the fork's own answer, and C0's ledger pass records 18a so it never sits unowned.**
- **D2 — layering singles** (review §2.4): the three sibling view-model constructions call
  `Shared/TypedTagPath.apply` directly; `AppSettingsView`'s second `TagsViewModel` owner routes
  through parent composition; `PostDetailView` gains a `PostDetailModel` and its raw SQL (plus the
  other three files' SQL) moves to core `Queries/`; `AppSettingsView`'s direct setting writes go
  through its model. Each is its own commit with the touched surface's pins riding unmodified.
- **D3 — dedup singles**: `TextMetrics.wordCount` consumes `Queries.wordCount` (whether the rule
  then belongs in `Domain/` is a one-line PROVISIONAL); `ShelfQueries` splits its catalog-search and
  note-picker concerns into their own files (pure moves, the 13u4 UNIT S2 pattern — a named
  `report(_:)`-class exception is recorded at the line if one is needed).
- **D4 (stretch, take-or-leave):** `TutorialSeeder.seed`'s 1,546-line body lifts to per-chapter
  `[LessonContent]` data + the ~40-line loop (`TutorialWalkTests` is the ready-made red-on-old);
  the seven zero-consumer shared-home hoists from review §2.5 — **except `MembershipChip`, which is
  13i's** — on the 3C pattern. If the run is full, these stay listed for their next touch; the
  hoist-at-next-touch rule already owns them.

**Standing rules:** as 18k's, verbatim. MOBILE PARITY line at close (expected "nothing
mobile-visible" except D1's core reshuffle riding under the phone's existing ops — say so).

---

## §W — the warming trigger (what the author says if the stutter survives)

Warming is deliberately unbuilt in all four rounds. The author's decision protocol, ratified
2026-09-22: ship 18l (the navigation-feel entry), use the app for a while, and commit to warming ONLY if a
first-visit stutter still registers. Her own observation, recorded because it bears on the design:
real users often dwell before navigating, which is exactly the window idle-warming exploits — so if
warming is ever built, its idle-chunked shape has the usage pattern on its side.

**If she still feels it, she says to a fresh session (verbatim, or near it):**

> Read `notes/codebase-health-review-2026-09-21.md` §1.4 and `notes/plans/post-13u-health-rounds.md`
> §W, plus the closed 18l (navigation-feel) record. I'm still noticing a first-visit stutter after
> that round, so I'm ratifying the warming build in §1.4's honest form: warm through the REAL row
> pipeline — realize the actual row views off-viewport at idle, chunked one note per tick, cancelled
> the instant I interact, invalidated per width/voice/edit — never a parallel headless layout model.
> Pull the Phase-12 warming-assessment row forward into this round. Name where the residual stutter
> was felt (which surface, which book/note) so the round measures that exact case first.

If she does NOT feel it, the Phase-12 row closes at 12 with "not earned" and this section is its
disposition.
