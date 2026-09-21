# 13u4 LADDER — ROUND 1 (fable-reviewer, cold, 2026-09-21)

**Diff under review:** `d232c2ad..HEAD` (113 commits — units E1 · E2 · E3 · C1 · C2 · F1 · S1 ·
S2 · S3 · F2 · F3, the orchestrator adjudications and the pre-ladder acceptance walk; 125 files,
~16k insertions including the plan records).
**Anchor:** `notes/plans/phase-13u4-restyle.md` (the SIZING-AND-RULINGS SITTING RECORD
R-13u4-1…8, the eleven unit records, the ledger, the CARRIED block, the pre-ladder walk).
Prompt: `notes/REVIEW_PROMPT.md` verbatim. **No "Review foci" section exists** in the plan or a
brief beside it — checked by grep; the seam rider applies (the diff reaches `TypedReturn`, the
merge join's editor consumers and the editor's view model/surface, so this round is Fable's).
**Read cold, in this session's own context:** the plan file whole (all 5,367 lines), the three
core files whole (`MergeJoin.swift` · `Operations+SpanToTake.swift` · the
`Operations+Structural.swift` merge diff), the seam files line by line (`TypedReturn`,
`EditorSurfaceController`'s typed-Return dispatch + merge roads + the C2 door,
`StructuralSeamEdit`'s merge/divide arms, `CrossBlockCompound`'s edge-join,
`EditorViewModel.keepingReadingPosition` + `parkAnchorRestore`/`overlayLayoutDidSettle`/
`topVisibleOffset`, `EditorView`'s two `applyChrome`s), the new brains whole
(`CaptureMicrosyntax`, `TypedTagPath`, `SpanToTakeGesture`, `SettingsShape`'s head,
`BookIndexPaneHeights`, `StampFace`/`CountsFace`/`WordTargetFace`, `FlippingStamp`'s consumers,
`BlockDecor`'s ring + `commentGutterFaces`, `ShellRouter`'s confirm channel + door ownership,
`BlockHistoryPane`'s seal watch, the two capture doors, the tutorial sweeps, the registry and
`EditorCommands` chord swap, the Timeline restyle, the mobile hoist consumers), the canonical-doc
deltas (AppSpec §7/§9, OverallModel §7), and the QUESTIONS #126–#135 + KnownIssues edits.
**Targeted verification run (core, the changed package):** `swift test --filter
'SpanToTakeTests|MergeJoinTests|StructuralMergeTests|StructuralMergeCeremonyTests'` — **51 tests
in 4 suites, all green** (no full suite at review start, per the standing rule; each unit's
closing runs and the pre-ladder walk stand as recorded). Zero files under
`Sources/VariorumCore/Sync/` and zero under `Server/` — verified by `git log`/`--stat` over the
range, not by the records' claims.

**STATUS: ROUND 1 FINDINGS COMPLETE — 0 BLOCKER · 0 MAJOR · 1 MINOR · 3 NIT, plus the
walk-flagged item answered. Awaiting the implementer responses / orchestrator authorization for
any fix pass.**

---

## FINDINGS (severity-ranked)

### R1-1 · [MINOR] · `notes/plans/phase-13u4-restyle.md:831–901` (doc + section) · UNIT E3's record sections are filed inside the UNIT E2 record region · traced by heading walk · move them under the E3 record heading

The plan file's `## UNIT E2 RECORD` region (lines 720–984) contains three sections that belong
to UNIT E3: `### THE BUILD (what moved, and why each line had to)` (line 831 — it describes
`MergeJoinRule`, `Operations.merge(joining:)` and the door/delete sites), a second
`### SEAM FILES THIS DIFF TOUCHES` list (line 858 — naming `CrossBlockCompound`,
`EditorSurfaceController`, `StructuralSeamEdit`) and a `### JUDGMENT CALLS` set (line 876 — all
six about the merge join). The `## UNIT E3 RECORD` region (line 1046 on) has NO build section
and NO seam-file list of its own. **The degradation is concrete and the ladder is its
consumer:** the E2 record's first line says "IT CHANGED NO PRODUCT CODE AT ALL" and its own
seam list says "NONE" — forty lines above a build section describing core operation changes and
a seam list naming three files. A fresh round-2/3 reviewer (or the closeout writer) anchoring
on the E3 record will not find E3's seam list where every other unit keeps its own; one
anchoring on E2's reads a self-contradiction. Clarity/record class — no pin owed (the
hallucination guard's architectural arm; the traced degradation is this file's own
navigability, which the ladder design leans on). **Fix:** move lines 831–901 under
`## UNIT E3 RECORD`, after its LIVE STATUS table. Nothing in the CONTENT of those sections is
wrong — I verified each claim in them against the code.

### R1-2 · [NIT] · `App/Variorum/Variorum/Core/Views/WordTargetFace.swift:215–242` · the counter's click target is exactly the label's own bounds — smallest at the icon face · answers the pre-ladder walk's flagged item · a one-line comfort, not a bug

**This is the walk's flagged item ("eyeball `CountsFace`'s hit target"), answered.** The
counter is a `Button` in `.buttonStyle(.plain)` whose label is a `Text` at `tokens.small`
(the icon face: a single `text.word.spacing` glyph); there is no `.contentShape` and no
padding, so the click target is the glyph/text bounds — real, but at the icon face roughly one
small glyph. **No traced defect:** UNIT S2's own walk clicked through all four faces in use
(crops 08–11) and opened the target door from the bare icon, and the orchestrator walk's three
failed synthetic clicks match its own recorded rig facts (a capture steals focus; multi-step
cliclick reliability), not a dead door. No red-on-old pin could exist for "the target feels
small," so this is labeled honestly as a suggestion: `.contentShape(Rectangle())` on a lightly
padded label would make the icon face comfortable under a real finger-sized click. Take it or
record it; either is fine.

### R1-3 · [NIT] · `notes/KnownIssuesAndTechDebt.md:51` (row 51's owner cell) · the surviving midnight-rollover note's owner reads "a 17 standing-fixes entry" — a kind, not a letter · the file's own header rule wants the named owner · the closeout duty already exists; keep it from dropping

Row 51's remainder (the midnight-rollover tick) carries owner "**a 17 standing-fixes entry**".
The file's header rule is "no entry without naming the owner," and a 17-entry owner is valid
**as a lettered entry** (CLAUDE.md's standing-fixes rule). The plan's post-S2 ORCHESTRATOR NOTE
already carries the duty ("the owner cell currently says 'a 17 standing-fixes entry' — the
file's rule wants the letter"); this finding exists only so the closeout doesn't drop it. Fix
at closeout: mint the lettered entry (17x) in `notes/plans/phase-17-standing-fixes.md` and put
the letter in the cell.

### R1-4 · [NIT] · `App/Variorum/Variorum/Features/BookView/BookIndexView.swift` (`BookIndexPaneNote.chromeAroundProse = 60`) beside `BookIndexPaneHeights.swift` (`Metrics.noteChrome = 60`) · one measurement stated as two independent constants · drift self-corrects by measurement but shows as a one-time shift · consider one reading the other

The note-row reservation subtracts `chromeAroundProse` (60) from the manifest height, and the
derived model adds `noteChrome` (60) — the code's own comments say "the two are the same
measurement of the same surface," but they are two literals in two files. If a restyle moves
the note's header/padding and updates one, the reservation drifts by the delta until the note
measures itself (rider-4's one-time-shift class — bounded, self-correcting, and the calibration
pin would likely catch a large one). One line closes it (`static let chromeAroundProse =
BookIndexPaneHeightModel.Metrics().noteChrome` or the mirror). Honest label: no pin could
red-on-old this today; it is a drift-hazard cleanliness item.

---

## THE WALK-FLAGGED ITEM AND THE FLAGGED ADJUDICATION (the reviewer's word, as the ladder owes them)

- **The counter-cycle rig failure (pre-ladder walk W5):** answered as R1-2 — the door is real
  and small; the rig failures match the walk's own recorded environment facts; no defect traced.
- **E3's Make Block-across-blocks = DOOR (the one architect call, flagged for her):**
  **CONCUR.** ⌘⇧K over a span is a deliberate confirm-gated gesture whose promise is "the span
  you selected becomes one block," and R-13u4-3's own sentence ("make all newlines within the
  selected portion part of a single block") describes that shape more literally than any other
  road in the app. The one-argument reversal stands recorded. It remains flagged for her at the
  closeout, correctly.
- **E2's DISMISSED-AS-HOLLOW verdict:** **CONFIRMED as the reviewer's own call.** The mechanism
  is structural, not observational — `deleteToBeginningOfLine:` resolves to the PARAGRAPH on
  macOS 26 (measured against a wrapped control) and the editor's block separator IS a newline,
  so the reported gesture cannot reach through the seam even in principle; her observable
  reproduces byte-for-byte under ⌥⌫ (`deleteWordBackward:`) in a bare `NSTextView`. The stop
  rule was applied exactly as written, the trace pins are kept as guards, and the product half
  is correctly hers (QUESTIONS #126). Nothing was fixed and nothing should have been.

## CLEAN BILL (load-bearing things specifically checked and found solid)

1. **The editor seam (the rider's whole reason).** `TypedReturn.act`'s new chain arm returns
   the SAME verdict a block's end returns (`.emptyBlock(edge:.below, closingEmptyTail:false)`),
   sits ahead of `textAt` (an empty block costs no text read), leaves the #92(c) empty-tail arm
   ahead of the walk, and `case nothing` is retired with the ONE site that returned it — the
   dispatch switch (`runTypedReturnAct`) loses the arm, and the mint routes through the shipped
   `insertEmptyBlock` body ⌘⇧⏎ already used (one body, two doors), whose `.divide` seam is
   arithmetically total over a zero-length source (`prefixLength 0 ≤ 0`, retained-bytes
   `"" == ""` — read in `StructuralSeamEdit`). Chaining is the act's own re-derivation; ⌥⌘Z
   rides `newBlock`'s standing registration (R-13u-3). Chip-OFF, U-19(2) and ⇧⏎ untouched.
   AppSpec §7's delta is exactly the ruled sentence, no further.
2. **The merge-join classification (R-13u4-3), end to end.** `MergeJoinRule` carries the ruling
   structurally (`.door` ignores its inputs BY RULING; `.deleteKeystroke` holds the 2026-07-06
   canon VERBATIM); `Operations.merge(joining:)` resolves it INSIDE the transaction on the
   store's rendered texts; every non-test `ops.merge` call site in the repo is classified
   correctly (grep-swept myself: the chain and Make Block loops default `.door`; `runSeamMerge`
   and `CrossBlockCompound.apply` pass `.deleteKeystroke`; the phone's Merge with Previous is a
   door); the ceremony's prePairing/hand-placed defaults and `CarryAllMerge.compose` consult
   `MergeJoinRule.door`; `mergeJoinMemory` still outranks the default; no `MergeJoin.canon`
   call survives anywhere (only history comments). `StructuralSeamEdit.derive`'s merge arm now
   tries `MergeJoin.allCases` — I verified the three candidates are mutually exclusive for any
   (lead, trail) pair, so first-match is only-match, and the door join's replacement is the
   byte already there (the differential road survives at P1, which left alone it would not
   have). The ceremony sheets' drift checks are byte-untouched; `canonJoin`'s old `.space`
   fallback collapses soundly (the door rule answers the same for empty texts). Both tutorials'
   falsified sentence fixed with pins; AppSpec §9 + OverallModel §7 carry the delta with her
   words, the delete exception, and the honest mid-sentence trade.
3. **`moveSpanToNewTake` (R-13u4-4), the whole transition table.** One transaction in the ruled
   order: `editableVariant` (live · active · unlocked · unsealed) + `liveBlock` + the
   `expectedText` CAS + bounds/grapheme validation through `BoundarySnapping.graphemeRange`;
   the insurance savepoint INSERTED BEFORE the buffer mutation (so it holds the pre-move text)
   and deduped on the standing `isDirty`; the span leaves exactly as selected (no snapping, no
   trimming); the mint at `fanPosition(at: .end)`, parented to the source, never chosen (neither
   pointer written), never locked; touch+churn via `registerTextChange(charDelta: span
   length)`; ONE undo entry with exact-row redo from the SAME do-time pre-images, `insuring:`
   carried for A12. The inverse restores-then-tombstones inside one write (a throw rolls the
   whole thing back — no half-apply), refuses on `variantIsChosen`/seal/lock/I10 and leaves
   divergence quietly; the redo flips the tombstone (never a fresh mint), voids purge intents,
   and insures a diverged buffer before overwriting. I10 by construction (the source keeps its
   remainder, an empty buffer legal). Sync shape: three ordinary rows through the shipped
   triggers, no repair class. 22 state-transition pins ran green here. The AppSpec §9 bullet
   matches the code.
4. **The C2 door.** `SpanToTakeGesture.plan` is the ONE brain for rendering AND firing
   (early-exit walk, separator overhang shrugged off by intersection, gap slots nil out via
   `variantID`); both doors render conditionally (P-2) from the same verdict; the fire path
   reads `expectedText` synchronously before the flight and `runStructural` flushes first, so
   the CAS is against the text the plan saw; `seam: nil` is the `deleteInEveryTake` posture with
   the cost stated. The registry row, the named `takesAccess` exemption (with expiry clause),
   the no-chord sweep and the two-form receipt (J8 copy-truth — the savepoint clause only when
   one was written) all check out against the code.
5. **F2's keeper.** The mechanism is real and correctly located: the park is stamped with the
   BUMPED generation before `overlayLayoutDidSettle()` schedules the hop, `parkAnchorRestore`
   guards `scrollView != nil` (inline editors inert), `consumePendingAnchorRestore`'s
   `generation >= pendingAnchorGeneration` keeps a stale hop from spending it, the first-
   application fence is `previous != nil && needsStorageRefresh(from: previous)` (the measured
   yank), the colour-only carve holds (`needsStorageRefresh` inputs are voice/inlineComments/
   paragraphGap only — palette/appearance never re-font since 18g/18j), the capture runs before
   the storage write and the restore a turn after (the R1-1 transaction rule by construction),
   the caret is never touched, and `restoreTopVisibleOffset` clamps to `documentLength`. No TK1
   API anywhere in the diff; the one `ensureLayout(documentRange)` is in a TEST with the reason
   at the line. `EditorTextView` is genuinely absent from the diff and the trace justifies the
   absence (the clamp is the scroll view's, not the text view's arithmetic).
6. **F1 + F3.** `LandingAuthority` is additive-only (one `LandingSurface` case, one measured
   policy; the decision/runner/seed/signpost and both shipped policies byte-identical —
   verified by the diff, not the record). The Index adoption keeps one landing road for all
   three target kinds; block reports are gated on the pending anchor (the corpus-growth
   argument holds); `landing.end()` on disappear. F3's heights: the pure model beside an
   unobserved store; ONE bounded `blockExtents` per entry set through the SHARED `flowExtents`
   cache (nothing at autosave rate); the manifest built at the landing only; the arming gate
   (`armed` riding inside the observed geometry value) closes the flow-ladder R2-5 zero-height
   trap the unit's own pin caught; a note learns only through its own loaded door (a
   reservation is never promoted to a measurement); width/voice drop everything via the stamp;
   the one surviving staleness (lengths keyed by entry-id list) is the flow's own recorded,
   bounded one and cannot touch anything on screen. The row-56 close is paired-verified with a
   mechanism that is the row's own sentence; row 56's warnings half stays open under owner 12,
   said plainly. The behavioural reverts (probe-only worktrees) properly attribute both fixes.
7. **C1's brains and doors.** `CaptureMicrosyntax.parse` implements R-13u4-1's letter (braced
   forms only; one-line tokens; malformed byte-intact including the `{#a{#b}` resume; seam
   whitespace; token-only lines dropped whole; no-brace fast path byte-identical); the curly-
   quote acceptance is the right call given the measured substitution; `applyTags` never throws
   and never undoes (the shelving posture); both doors parse at the hand-off only, mint first,
   tags after, and the tokens-only capture takes the standing empty branch (PROVISIONAL
   #127(f), recorded). The `TypedTagPath` hoist is faithful — I diffed the moved walk against
   both old bodies (Mac + phone): same order, same one-turn composition, same `alreadyTagged`
   swallow; every pre-move name forwards; refusal copy stays platform-local (MobileSoul §4.4).
8. **The chord swap (S1) is consistent everywhere it must be:** registry labels ⌥⌘[/⌥⌘] and
   ⌘[/⌘], the `keyEquivalent(for:)` table, the Format/View menu wirings, the helper rows, the
   tooltips now READING the declared chord, and the comment sweeps. Item 7's fix is at the
   class (all six rows from `menuTitle()` through one formatter, as a testable static), with
   the loose-pin lesson (⌥⌘⇧M containing ⌘⇧M) closed by exact-row assertion. The falsified-
   premise discipline was followed: W16's stated reason was measured, not relitigated, and #130
   carries the PROVISIONAL.
9. **S2/S3 chrome:** `StampFace`/`CountsFace` are pure file-scope rules with local, never-
   synced keys whose defaults families are stated at the declarations and whose pins mount
   under scrubbed `defaultAppStorage`; the words in every face are the one brain's; the target
   door survives in all four faces as data (`CountsMenu.rows`); the oracle-ownership fix
   (registrant names itself / teardown clears only its own) is applied identically at all
   three sites (two stamp oracles + `blockNamingDoor`) with the pin's unconditional reset
   preserved; the ring's gutter yield honors the gutter law (clamped at `textLeft`, nil
   byte-identical to shipped, the comment-face decision MOVED not copied, the highlight taking
   the same edge); the shell confirm channel cannot strand or double-resume a continuation
   (replace-answers-false; answer-and-clear one act; dismissal is an answer — traced through
   the RootView host including the post-action binding write, which no-ops on nil); the seal
   watch is held only while the pane is up with the op's refusal as backstop; the tutorial
   sweeps keep the pool's own name, the reserved `scrapPoolTitle` identity, and the phone's
   chapter title, each with the reason at the code; the Timeline speaks `TimeStampFace` through
   `LibrarySortFace.stampSubject` (asked, not copied) with R3-2's one-day-once rule.
10. **Sync-shape and scope fences:** zero `Sources/VariorumCore/Sync/`, zero `Server/`, zero
    schema/migrations (marker stays 8), no new dependency, no invariant relaxed; every write in
    the diff flows through the operations API; nothing tracks word-level change; nothing copies
    text across entities beyond the ruled span move (a variant on the same block); no cost that
    scales with corpus (the two new per-book costs are stated, bounded, and pinned). The
    canonical-doc deltas are exactly the ruled sentences (E1's §7 arm, E3's §9 bullet +
    OverallModel §7, C2's §9 bullet); §14's phase delta correctly remains the closeout's.
11. **KnownIssues discipline:** eleven owner-13u4 rows resolved/narrowed with evidence in the
    cells; no unresolved owner-13u4 row remains (grep-checked); the two rows F3 closed carry
    their own re-verification; the one row OPENED (F1's residual) was closed by F3 in the same
    range. QUESTIONS #126–#135 are faithful to the records and correctly route every product
    call to her; next-free bookkeeping is consistent (#136).

**Handed to round 2 (if the fixes land):** R1-1 is a records-only move inside the plan file;
R1-2/R1-3/R1-4 are one-liners or closeout duties. Nothing here reaches core, the seam, or any
behaviour a pin guards — a round 2 over these fixes should be quick and must still re-check the
plan file's heading structure after the R1-1 move.
