# 18l-b U4 — Opus cold review, ladder ROUND 1 (2026-09-27)

**Reviewer:** `opus-reviewer` (Opus, xhigh), zero implementation context, `notes/REVIEW_PROMPT.md` run verbatim.
**Diff under review:** `3389fedb..2aa43836` (code = `App/`, `Tools/`; the notes-only record commits read as the
record, not reviewed as code). Anchors read in own context: the U4 BRIEF / U4 RECORD / orchestrator acceptance
(`notes/plans/phase-18l-b-navigation-feel.md`, plus its kickoff, principles, cast, traps and ledger), the
charter's KICKOFF 2 U4 bullet (`post-13u-health-rounds.md`), health review §1.1–§1.3
(`codebase-health-review-2026-09-21.md`), QUESTIONS #97 and #153 (the diff's own edits), KnownIssues rows 58 and
98, the 17o batch b ladder's `read`-face click-through note (`use-report-round-2026-09-06.md`). Code read in
full or at every touched region: `Shared/LandingTarget.swift`, `BookIndexEditModel.swift` (whole),
`BookIndexView.swift` (`landOrSeed`, teardown, the pane note's landing hooks, `blockView`), `BookView.swift`
(the flow/paged `onWake`s, `editHere`, the Outline's authority + `outlineBody`, `outlineAnchor`),
`BookViewModel.requestLanding`/`consumeReveal`/`requestReveal`, `PaneSurface.swift` (`PaneCaretLanding`,
`makeNSView`/`updateNSView`, `noteLiveness`), `LandingAuthority.swift` (policy seeds, `land`/`begin`/`end`/`look`),
`BookHeightManifest.swift` (`Input`, `resolve`, init), `ReadingFlowView.swift` (`heightManifest`, `estimate(for:)`,
`FlowHeightEstimate`, `FlowStoryRow`), `ReadModeView.openInEdit`/`landIfPending`, `BlockTOCViewModel.makeLive`/
`armPaneCaretLanding`, `CommandRouter.noteFocusedBlock`/`currentBlock(for:)`, `CurrentBlockMemory.swift` (whole),
the three new test files (whole), `PaneSurfaceTests`' host doc, `Tools/VisualWalk/scenarios.zsh` + README diff
and the `lib.zsh` guard helpers. Evidence logs read: `App/Variorum/DerivedData/18lb-u4-item{1,2,3}-*.log`,
`18lb-u4-closing1.log`, `18lb-u4-ios.log`; walk reports `vis-walks/2026-09-27/{081039,081642,082126}/report.md`.
No "Review foci" section exists for this unit (grep-verified across the three plan files). No tests were run by
this seat: every claim below was checkable from code, git and the implementer's committed logs.

---

## THE SEAM CALL (asked for by the brief — stated with evidence)

**The diff stays OFF the editor seam and OFF any default's meaning.** `opus-reviewer` was the right cast.

- `git diff --name-only 3389fedb..2aa43836` touches no `Sources/`, no `Sync/`, no `Server/`, no migration, no
  `EditorTextView`, no `BlockRangeIndex`, no `PaneTextAuthority`.
- `Surface/PaneSurface.swift`: the whole change is three `///` doc lines inside `PaneCaretLanding`'s header
  (the host list, :875–879). No body line, no read-tier drawing, no measurement.
- **Default's meaning:** `PaneCaretLanding`'s default (`.leave`, PaneSurface.swift:1048/1173/1398) and the entry
  rule (`PaneCaretLanding.entering`, :903–906) are untouched. What moved is the ARGUMENT one host passes on one
  road — `BookIndexEditModel.takePendingLiveBlock` now arms `.start` (BookIndexEditModel.swift:177) where it
  armed nothing. That host sat in #97's scope paragraph among the hosts that keep the shipped END ("the Book
  Index's clicked-block-goes-live landing — the Act 10 record's row 22, unchanged"), outside #97's (a), which
  governs the note's ENTRY landings only; U4 moves it to the START under its own PROVISIONAL (#153) with a dated
  pointer on #97. That is a product-adjacent
  per-host call (the orchestrator's arbitration weighs it, as the acceptance already notes), not a change to
  what any default means.

---

## FINDINGS (severity-ranked)

**Counts: 0 BLOCKER · 0 MAJOR · 2 MINOR · 1 NIT.** All three are behaviour-neutral (a binding/clarity fix, a
decision-record fix, a doc line); none is bug-class, so none claims a red-on-old pin.

### MINOR-1 · ReadingFlowView.swift:1174–1178 (+ :822–826, FlowStoryHeightOneBrainTests.swift:51/57–65) · item 3 leaves TWO copies of the story-height expression — the production row's is unpinned, the pinned one has no production caller

- **What:** item 3's stated contract is "the height the row stands at and the height a landing aims by are ONE
  answer". The fix wrote that answer twice. `FlowStoryRow.honestHeight` (ReadingFlowView.swift:1174–1178) now
  inlines `BookHeightManifest.resolve(FlowHeightEstimate.storyInput(…)).0`; the static
  `FlowHeightEstimate.honestHeight` (:822–826) — "kept as a forward" — carries a second copy of the same
  expression. Grep: **zero production callers** of `FlowHeightEstimate.honestHeight` remain (its callers are
  `ReadingFlowEstimateTests.swift:146–152` and `FlowStoryHeightOneBrainTests.swift:51`, plus a doc mention at
  BookView.swift:2249). Before U4 the row's body WAS a call to that static (the diff's `-` lines), so the pins
  on it pinned production; after U4 they pin a parallel copy.
- **The traced degradation (three consequences, each read at the code):**
  1. **The new agreement pin cannot see the production row.** `theRowsHeightIsTheManifestsHeightForEveryInput`
     reads its "row" from the static forward (:51) and its "column" from a hand-rebuilt `Input` (:57–65) —
     neither is the production row (`FlowStoryRow.honestHeight`) nor the production column builder
     (`FlowHeightEstimate.storyInput`, which `heightManifest` calls at ReadingFlowView.swift:401). Concrete
     input → wrong outcome: revert ONLY ReadingFlowView.swift:1174–1178 to the pre-U4 two-arm rule (the row
     back on its own precedence — exactly the drift D1 exists to close) and the pin stays green, because
     nothing it calls changed. The implementer's own weak point (c) ("reds only on inputs production never
     writes") understates it: the pin does not reach the production row at all.
  2. **R2-1's pins lost their production binding.** `ReadingFlowEstimateTests.aRememberedSizeAppliesOnlyAtItsOwnWidth`
     (:144–156, "RED ON OLD (behavioral revert — the width ignored)") guarded the row's actual path until U4;
     it now guards a function the app never runs. An edit to the row's inline expression that bypasses
     `storyInput`'s width gate (e.g. `memory.size(entry.postID)?.height ?? estimate`) would ship green.
  3. **The records now overclaim.** KnownIssues row 58's U4 line names `FlowStoryHeightOneBrainTests` "the
     agreement pin"; BookView.swift:2249 still names `FlowHeightEstimate.honestHeight` as "the one brain" the
     flow's placeholder reasons through. Minor while the two copies agree (they do, byte-for-byte in meaning —
     the `id` argument is the only difference and `resolve` never reads it), but it is exactly the "two rules
     that happen to agree" shape the unit set out to retire.
  - Also: the inline copy builds `FlowRows.anchor(entry.postID)` — a string — on each of its two evaluations
    per body (placeholder + `known`) for an id `resolve` never reads (O(1), negligible; it disappears with the fix).
- **Class:** architecture/clarity — not bug-class. Behaviour is identical by construction today, so there is
  no red-on-old pin to write and none is claimed; the justification is the traced loss of pin coverage above.
- **Proposed fix (two lines, behaviour-identical):** (a) `FlowStoryRow.honestHeight` becomes
  `FlowHeightEstimate.honestHeight(remembered: memory.size(entry.postID), columnWidth: width, estimate: estimate)`
  — ONE copy, the pinned one, which restores R2-1's binding and makes BookView.swift:2249 true again; (b) in
  `FlowStoryHeightOneBrainTests`, build the column's input through `FlowHeightEstimate.storyInput(id:…)` (the
  production column builder) instead of by hand, so the pin reads "the row's function == `resolve` of the
  column's builder" — green today on both trees by construction (say so in its header), and it reds the day
  anyone gives the row's function a precedence of its own. The row-58 line then stands as written.
- **VERDICT (round 1):** CONFIRMED (self-traced; the orchestrator arbitrates).

### MINOR-2 · notes/QUESTIONS.md #153 ((a) and (b) paragraphs) + BookIndexEditModel.swift:173–175 + LandingTarget.swift:7–12 · the author-facing question overstates the "twin" and bundles the one cheap, #149-free alternative under (b)

- **What:** #153 — the question she rules on — justifies (a) as *"what the same click in a NOTE's Read already
  does"*, and the code comment says the same (*"note Read's twin click-through (`ReadModeView.openInEdit` → the
  entry rule's `.start`)"*); `LandingTarget`'s header now states *"making THAT block live, its caret at the
  block's start"* as the value's landing rule, for the book AND "the note's own version … consumes the same
  value". The note's twin does not always land at the start.
- **Evidence (traced):** `ReadModeView.openInEdit` reports the clicked block with a NIL offset
  (ReadModeView.swift:480–481) → `CommandRouter.noteFocusedBlock` → `CurrentBlockMemory.remember`, whose rule
  is *"a nil offset for the SAME block keeps what is known"* (CurrentBlockMemory.swift:86–92) → the edit face's
  `BlockTOCViewModel.makeLive` arms `PaneCaretLanding.entering(currentBlock(for:), block:)`
  (BlockTOCView.swift:269, 297–302) → `.offset(known)`. So a note-Read click on the block she was LAST IN lands
  at her remembered caret; only a click on any OTHER block lands `.start`. The book Index's landing after U4 is
  `.start` unconditionally (BookIndexEditModel.swift:177). (The 17o ladder's own note — "`openInEdit` reports
  the block first and so lands `.start`" — carried the same simplification; U4 inherited it.)
- **Why it matters for her ruling:** #153 files "edit here could then also land at your remembered caret" under
  (b) — the option entangled with #149 (Read's surfaces placing a caret at a character). It is not entangled:
  the remembered caret is already on the `FocusedBlock` road the charter names, and reading it needs no Read-face
  wiring at all. The one-line reading — at `takePendingLiveBlock`,
  `PaneCaretLanding.entering(session.commandRouter.currentBlock(for: postID), block: row.blockID) ?? .start`
  — is exactly note Read's twin (the entry rule), exactly the Outline/spread branch of the same "edit here" door
  (BookView.swift:844–849, which lands at `remembered?.utf16Offset ?? 0`), and #149-free. The implementer's
  call to NOT build it (a product step past the U0 artifact class) is within the brief's fence and is not
  disputed here; the point is that her question should show it as its own option rather than as a rider on (b).
- **Class:** decision-record accuracy on an author fork (the hallucination guard's written-justification arm:
  the degradation is a ruling made on a mis-stated comparison). Doc-only — no behaviour change proposed, no pin.
- **Proposed fix:** (1) #153's (a) sentence made exact — *"…what a note's Read click already does on any block
  other than the one you were last in (on that one, the note lands at your remembered caret)"*; (2) add the
  entry-rule reading as its own option (a′) — "START, except the block you were last in lands at your
  remembered caret (note Read's rule; also makes Index's 'edit here' match Outline's)" — separate from (b),
  which keeps the Read-face wiring and #149; (3) BookIndexEditModel.swift:173–175 says "the entry rule's
  `.start` arm (a block she was not last in)"; LandingTarget.swift:9–10 drops the caret sentence or says "the
  consumer places the caret (the book Index: the block's start, #153)", keeping the header's own "it carries no
  decision" true.
- **VERDICT (round 1):** CONFIRMED (self-traced; the orchestrator arbitrates — the option framing is the
  orchestrator's and hers, not this seat's).

### NIT-1 · App/Variorum/VariorumTests/PaneSurfaceTests.swift:44–46 · a pin's doc still lists the Book Index among the hosts that pass NO landing

- **What:** `PaneBareHost`'s doc names *"the six hosts outside R1-3's trace (… the Book Index)"* as hosts that
  pass no landing. The Book Index has passed `edit.caretLanding(forVariant:)` since 18l U0 (click `.offset`), and
  since U4 arms `.start` for a landing (BookIndexView.swift:1410, BookIndexEditModel.swift:177). Stale since U0;
  U4 widened the gap. The test's BODY is unaffected (it exercises a bare host, which is still correct for the
  other five).
- **Why not fixed at U4:** the unit's 3C discipline (every pre-existing pin file byte-unmodified) — right for the
  proof, so this rides the file's next touch. A comment edit, no pin.
- **VERDICT (round 1):** CONFIRMED, next-touch.

---

## CLEAN BILL (load-bearing things checked and found solid)

1. **Item 1 — the Outline's `.onDisappear { landing.end() }` (BookView.swift:1493) is R2-12 parity, and safe.**
   The four other adopters carry the same line (ReadingFlowView.swift:217–218, BookIndexView.swift:552,
   ReadModeView.swift:832, ReadEditPane.swift:133). `end()` is silent by design (LandingAuthority.swift:682–688:
   cancel, anchor/aim nil, no `finish`), so no false signpost is filed. Nothing needs the Outline's landing to
   outlive its body: `landOutlineReveal` consumes the reveal BEFORE `land` (BookView.swift:1588–1589) and the
   Outline's authority sets no `onFinish`. The modifier sits on the one body `structure.mode == .outline` mounts
   (BookView.swift:193–194), whose `SideColumn` `shown` depends only on the mode, so no same-mode remount can
   fire it mid-landing. The authority's `tops` seed map survives a mode switch (BookView's `@State`), but every
   Outline row reports through `outlineAnchor`'s `onGeometryChange` (BookView.swift:1986–1995) on the fresh
   surface, so no stale seed ends a later landing — checked, not a finding. Red→green verified in the committed
   logs: `DONE: settled at top=0.0 after 0 hops, 1014 ms` → `DONE lines after the switch: []`; the pin commit
   pair (`a39bd5cb`/`3e02eeb2`) and the fix (`9bf7f460`, BookView.swift only, 9 lines) differ by exactly the fix.
2. **Item 2 — `.start` reaches exactly the landing road and nothing else.** `goLive` is the one shared body;
   `makeLive(…clickOffset:)`'s signature and U0's `.offset` arm are unchanged (BookIndexEditModel.swift:73–77),
   a pane's own focus request still arms nothing (BookIndexView.swift:1399–1401 → nil → `.leave`), and
   `takePendingLiveBlock`'s locked-take / missing-row guards are untouched (:155–163). `.start` is applied only
   on a read→live transition that no click caused (PaneSurface.swift:1448–1495), so a click's own place still
   wins. The three producers (flow `onWake` BookView.swift:213–220, paged `onWake` :1599–1600, `editHere`
   :837–843) all funnel through `requestLanding` → `landOrSeed` → `requestLiveBlock` → `takePendingLiveBlock`,
   and the Index's teardown blurs the ring on disappear (BookIndexView.swift:544–552 → `edit.teardown()` →
   `blur()`), so every click-through arrives as a real migration and the `.start` transition fires. Red→green
   in the committed logs: 224/224 and 247/247 → 0/224 and 0/247; the model-half guard arms green both sides,
   as labelled. The re-born-live-pane re-application (a pane re-made while live re-applies its host's landing)
   is pre-existing in shape (U0's `.offset` does the same) and honestly recorded as NOTICED 3.
3. **`LandingTarget.utf16Offset` deletion is safe.** Every producer uses the two-field init
   (BookView.swift:218/843/1600, ReadModeView.swift:482; no mobile or `Shared/` consumer); the iOS build log
   reads `** BUILD SUCCEEDED **`. The replacement comment names the `FocusedBlock` road correctly
   (`CommandRouter.currentBlock(for:)`, `PaneCaretLanding.entering`, the `WriteIntent` doors), and
   `FocusedBlock.utf16Offset`'s doc (BlockHistoryPane.swift:140–146) no longer cites a dead field.
4. **Item 3 is behaviour-preserving on every reachable input.** For a story input (no measured arm),
   `BookHeightManifest.resolve` (BookHeightManifest.swift:145–153) equals the old two-arm rule for every positive
   finite remembered height and estimate; it differs only at a remembered height ≤ 0 (no production road writes
   one — the empty read remembers 20, ReadingFlowView.swift:1135–1137) or a negative/non-finite estimate, where
   `resolve` clamps to ≥ 0 and the old rule handed SwiftUI a negative frame height (if anything an improvement;
   `FlowHeightEstimate.height` is `ProseHeightModel`'s line arithmetic over non-empty extents or the 20-pt empty
   constant, positive for real notes — not proven here for every synthetic extent). The row's `width`/`estimate` and the column's are
   the same numbers (`columnWidth ?? defaultColumnWidth`, `estimate(for:)` at :267 and :403). The landing suites
   ride unmodified and green (30/5 in the proof log). (MINOR-1 is about the pins' binding, not the behaviour.)
5. **3C discipline held.** `git diff --name-status 3389fedb..2aa43836 -- App/Variorum/VariorumTests/` shows only
   the three added files; every pre-existing pin file is byte-unmodified.
6. **Closing evidence matches the record.** `18lb-u4-closing1.log`: `✔ Test run with 1287 tests in 221 suites
   passed after 586.425 seconds`, `** TEST SUCCEEDED **`. Walk reports: `081039` PASS 7/7 both voices;
   `081642` (the pre-U4 scratch build) FAIL 4/7 both voices on exactly rows A and C (`BookOutline` line filed
   after the switch; caret `593,0`, on-the-blank-line) — the new `book-landings` scenario has teeth, and row A's
   zero-line claim has its two controls (the Index's landing target = last row; the kept Outline landing
   `end=settled`).
7. **The harness scenario respects the walk rules.** Appended last in `SCN_ORDER` (no earlier recipe moves);
   row A's compound act (two clicks 0.8 s apart + an AX press 0.3 s later, bounded by the Outline's 1-s hold) is
   guarded once at its head by `vw_step` (author/HID check + activation), `vw_no_foreign_at` and
   `vw_our_window_is_key` — accepted as one timing-bound act; every other click goes through `vw_click`'s full
   guard.
8. **P1/P3 and cost.** Item 1: one `end()` per Outline disappearance. Item 2: one enum per landing; the `.start`
   arm is an existing `setSelectedRange`. Item 3: O(1) per row body, no new observation dependency (the same
   `memory.size` read). No work at scroll or keystroke rate; the flow realizes what it did.
9. **The keyboard-stall attribution stands by construction.** `mode-roundtrip` opens a note in Write before any
   book scenario runs (and first after a fresh launch in `084750`); U4's diff touches no Write view, no
   `EditorTextView`, no event handling. KnownIssues row 98 carries it with the `sample` discriminator.
10. **Scope and hygiene.** Zero `Sources/`, `Sync/`, schema, migrations; no commit trailers in the 21 commits
    (message bodies grep-clean); ledger row 8 (O-2) correctly left to U-B5; the only QUESTIONS edits are #153 and
    #97's dated pointer, both accurate to the code except as MINOR-2 notes; no KnownIssues row owned by U4 is left
    unresolved.

## ORCHESTRATOR ARBITRATION (same-model ladder — the orchestrator arbitrates against the spec; 2026-09-27)

**ALL THREE FINDINGS CONFIRMED (0 dismissed).** This arbitration is also where item 2's promised
Fable eye lands (the U4 acceptance's cast adjudication): the seam call is CONFIRMED on its
evidence — the default (`.leave`) and the entry rule are untouched; one host's argument moved on
one road, under its own PROVISIONAL, inside her U0 report's class. Opus was the right cast.

- **MINOR-1 — CONFIRMED, fix as proposed.** The one-brain claim must be structural, not
  narrative: the production row calls the pinned static (`FlowStoryRow.honestHeight` →
  `FlowHeightEstimate.honestHeight`), and the agreement pin's column side goes through the
  production builder (`storyInput`). Teeth check REQUIRED: with the row's body reverted to the
  old two-arm rule in the working tree, the strengthened pin must RED (the reviewer's own
  hollow-pin demonstration, closed) — restored clean after. Row 58's "agreement pin" line and
  the `BookView.swift:2249` doc corrected in the same pass (the row edit is the orchestrator's
  ledger pen delegated for this one line — cite this arbitration).
- **MINOR-2 — CONFIRMED as the framing fix, and ONLY the framing fix.** #153's (a) sentence
  corrected (the note-Read twin lands the remembered offset on the CURRENT block, `.start` only
  on others); the reviewer's one-line entry-rule option added as **(a′)** — "START, except the
  block you were last in lands at your remembered caret" — with its evidence (it matches the
  note-Read twin exactly, matches `editHere`'s Outline branch, needs no Read-face wiring, is
  #149-independent); the two comments tightened. **(a′) is NOT built** — (a) stands as shipped
  and PROVISIONAL; swapping to (a′) is exactly the one-line product pick #153 exists to hand
  her. PROVISIONAL-and-continue's letter.
- **NIT-1 — CONFIRMED, take now** (the fix pass is a touch): the `PaneSurfaceTests:44–46` host
  doc corrected — DOC LINES ONLY in a pre-existing test file, sanctioned as such and named out
  loud; zero assertion edits.

**The fix pass:** the U4 implementer (same-model flow — the implementer fixes; dispositions land
here first). **Round 2 = a FRESH `opus-reviewer` over the fix diff** (the ladder's letter); a new
BLOCKER/MAJOR there earns round 3 (cap three).

## FIX PASS (implementer — the U4 `opus-implementer`; 2026-09-27) — self-contained for round 2

The fix diff is `ecc2c969..HEAD` at this pass's close (code: `ReadingFlowView.swift`, `BookView.swift` (a doc), `BookIndexEditModel.swift` + `LandingTarget.swift` (comments), `FlowStoryHeightOneBrainTests.swift`, `IndexLandingCaretTests.swift` (header comment), `PaneSurfaceTests.swift` (doc lines); notes: QUESTIONS #153, KnownIssues row 58's U4 line, the U4 RECORD's two bracketed amendments, this table). Every line below names its commit and its evidence.

| Finding | Fix | Commit | Evidence |
|---|---|---|---|
| MINOR-1 | DONE — `FlowStoryRow.honestHeight` calls the pinned `FlowHeightEstimate.honestHeight` (the row holds no rule; its body is byte-identical to its pre-U4 call); the static's doc names it the row's one rule; `FlowStoryHeightOneBrainTests`' column side built through `FlowHeightEstimate.storyInput` (the production builder), its header rewritten; `BookView.swift`'s surface-placeholder doc and KnownIssues row 58's U4 line corrected (the row edit on the orchestrator's delegated pen, citing the arbitration) | `a4e05f39` | **R-two-arm (named at `39a31df9` before it ran): RED exactly as predicted** — `FlowStoryHeightOneBrainTests` on the 6 degenerate combinations only (row 0 / −5, manifest the estimate), `ReadingFlowEstimateTests` green: `✘ 8 tests in 2 suites … 1 issue` (`App/Variorum/DerivedData/18lb-u4-lr1-R-two-arm.log`); restored by `git checkout HEAD --`, `git status` clean, the one `resolve(storyInput(` line back (grep 1). The row's body is byte-identical to its pre-U4 call (`git show 3389fedb:` vs HEAD, lines 1145–1148 / 1180–1183) |
| MINOR-2 | DONE — the FRAMING fix only: #153's (a) sentence made exact (note Read's twin lands `.start` on a block she was NOT last in; on the block she was last in, her remembered caret); **(a′) added as its own option** — the START except the block she was last in, at her remembered caret — with its evidence (note Read's rule exactly, `editHere`'s Outline branch, no Read-face wiring, #149-independent) and its one line; the note-box rider removed from (b); **(a′) NOT built — (a) stands as shipped, PROVISIONAL**. Comments tightened: `BookIndexEditModel.takePendingLiveBlock` ("the entry rule's `.start` arm … a block she was NOT last in"), `LandingTarget`'s header ("the consumer placing its caret (the book Index: the block's start — #153)" — the header's own "it carries no decision" true again), and the same overstatement in `IndexLandingCaretTests`' header (a U4-new file; comment only). The U4 RECORD's decision section amended openly (two bracketed notes) | `3298b294` | the trace re-verified at the code by this seat: `CurrentBlockMemory.remember` keeps a known offset for a nil report on the SAME block (:80–92); `BlockTOCViewModel.makeLive` → `armPaneCaretLanding` → `PaneCaretLanding.entering` (BlockTOCView.swift:263–300). No behaviour change |
| NIT-1 | DONE — `PaneBareHost`'s doc in `PaneSurfaceTests.swift` no longer lists the Book Index among the hosts that pass no landing (it passes one since 18l U0's `.offset` and U4's `.start`, #153). **DOC LINES ONLY in a pre-existing test file — sanctioned by the arbitration and named as such; zero assertion edits** (`git diff -U0` of the file: every changed line is a `///` line — 0 others) | `d8b0dd2a` | the diff itself (doc-only); `PaneSurfaceTests` + `PanePublishDoorTests` green in the closing run below |

**THE TEETH CHECK, named before it runs (the arbitration's requirement; the pre-revert state is `a4e05f39`, committed
+ pushed): R-two-arm.** In the working tree only, the ROW's rule — `FlowHeightEstimate.honestHeight`'s body, the one
rule `FlowStoryRow.honestHeight` calls since this fix (the row's own body is byte-identical to its pre-U4 call, so "the
row reverted to the old two-arm rule" is exactly this body) — restored to the pre-U4 two-arm body (`if let remembered,
Self.remembered(remembered, appliesAt: columnWidth) { return remembered.height }; return estimate`). **Expected RED:**
`FlowStoryHeightOneBrainTests` on exactly the 6 degenerate combinations (a remembered height of 0 at 600 / −5 at 450,
× the three estimates: row 0 / −5, manifest the estimate). **Expected GREEN:** `ReadingFlowEstimateTests` (R2-1's width
gate — reachable inputs, on which the two rules agree). Restored by `git checkout HEAD --
App/Variorum/Variorum/Features/BookView/ReadingFlowView.swift`; `git status` clean after. **The residual, stated:** a
rule typed INTO the private `FlowStoryRow` (bypassing the static) is beyond a pure pin's reach — the structural defence
is that the row now holds no rule, only the one call.

**CLOSING RUN (the touched suites — the flow/landing set, the new pins, the pane file's two suites; each name grep-verified as a `@Suite`):** `FlowStoryHeightOneBrainTests` · `ReadingFlowEstimateTests` · `ReadingFlowEstimateMeasureTests` · `ReadingFlowLandingTests` · `TrailingFlowRowsTests` · `BookHeightManifestTests` · `BookOutlineLandingTests` · `BookOutlineRowsTests` · `OutlineLandingTeardownTests` · `IndexLandingCaretTests` · `BookIndexLandingTests` · `BookIndexEditingTests` · `IndexClickCaretTests` · `LandingAuthorityTests` · `LandingSignpostTests` · `PaneSurfaceTests` · `PanePublishDoorTests` — **`✔ Test run with 93 tests in 17 suites passed after 124.125 seconds`**, `** TEST SUCCEEDED **`, zero `✘`, zero skipped (`App/Variorum/DerivedData/18lb-u4-lr1-closing.log`). No behaviour moved in this pass: MINOR-1 restores the row's pre-U4 call (byte-identical) over the same one-brain rule; MINOR-2 and NIT-1 are words.

**For round 2 (what to weigh):** (1) MINOR-1's residual, stated — a rule typed INTO the private `FlowStoryRow` (bypassing the static) is beyond a pure pin; the defence is structural (the row holds one call, byte-identical to pre-U4). (2) (a′)'s one line is quoted in #153 but NOT built — (a) stands PROVISIONAL. (3) Beyond the arbitration's named sites, this pass also corrected the same twin overstatement in `IndexLandingCaretTests`' header (a U4-new file) and the U4 RECORD (two bracketed, dated amendments) — same finding, same words, stated here so nothing is silent. Deaths / resumes: none. Reverts in flight: none (R-two-arm ran and was restored).
