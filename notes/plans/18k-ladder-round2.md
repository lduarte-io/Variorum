# 18k LADDER — ROUND 2 (fresh Fable cold review; a real pass over round 1's fix and what it touched, plus an independent pass over the combined diff)

**Reviewer:** `fable-reviewer`, fresh session, zero implementation context. Anchor: THE LADDER
section of `notes/plans/phase-18k-runtime-hygiene.md` + round 1's findings/dispositions
(`notes/plans/18k-ladder-round1.md`, `af2a761b`), per the ladder rule — round 1's dismissals were
taken as the thread, not re-derived blind; the load-bearing ones were re-verified at the code by
this session's own eyes. **Diff:** `git diff 1b7858eb^..HEAD -- App Sources Tests Tools` — now
INCLUDING the round-1 fix `0ebc3b5e`. **Canon read:** CLAUDE.md, AppSpec (§7/§9/§14), OverallModel
(I1–I10/P1–P3/S1–S5), SyncSpec, TEXTKIT2_NOTES; the 18k plan's ledger, kickoff rulings, unit
RECORDs and adjudications. No "Review foci" section exists in the plan or a brief (round 1
grep-verified; confirmed by this session's own heading scan).

---

## THE FIX UNDER RE-REVIEW (round 1's NIT 1, `0ebc3b5e`) — CONFIRMED SOUND

- **The fix read whole at the code, in context** (`StoreBackup.performSecondLeg`, the
  `guard let source` arm, `StoreBackup.swift:396–405`): exactly one string changed plus its
  comment; the arm's position is correct — it answers only AFTER the far folder's own due-check,
  so an up-to-date far folder still answers `.upToDate` and never speaks this sentence;
  `outcome == .failed` and the early return are byte-identical; every other leg arm untouched.
  The new sentence is true in the one lane it fires in (the primary leg threw, so THIS act made
  no snapshot; older copies' existence is no longer denied).
- **The pin read whole** (`BackupRunTests.aFailedPrimaryLegLeavesTheFarFolderAnHonestSentence`,
  `DataSafetyTests.swift:264–286`): it builds a REACHABLE, DUE picked folder (empty, so the
  due-check passes through to the guard) and hands `source: nil` — the exact lane; it asserts
  both the `.failed` outcome and the new string, so it is red-on-old by the old string exactly as
  the record claims. Off-main via `Task.detached`, matching `performSecondLeg`'s nonisolated
  contract (no main-queue precondition inside it — verified at the code; the preconditions live
  in `performRun`/`performPrimaryLeg`).
- **QUESTIONS #148** filed correctly (PROVISIONAL, copy is hers; next-free-number moved to #149).
- **Scope:** the commit touched only `StoreBackup.swift` (the string + comment),
  `DataSafetyTests.swift` (the pin), `QUESTIONS.md`, and the round-1 findings file — verified by
  `git show --stat`. No behaviour moved. The five Data Safety suites re-run green by this
  session (below).
- **What the fix touched, re-swept:** the whole of `StoreBackup.swift` was re-read line by line
  in this session (the single-flight `run(force:)`, `performOneRun`, `performRun`,
  `performSecondLeg` whole, `existingBackups`/`date(fromBackupURL:)`'s own-names rule,
  `prune`/`pruneSecond`/`removeSnapshotPair`, the lock-time copy family, the stamp formatter) —
  no regression, no adjacent hazard introduced by the wording change.

## WHAT THIS SESSION VERIFIED ITSELF (not taken from round 1's record)

1. **Independent release-projection proof.** My own script (strip comments + `#if DEBUG`
   branches, old tree vs HEAD) over every touched production file: the ONLY files whose Release
   projection changed are the 16 that carry the units' named production fixes (AppSession ·
   StoreBackup · StructuralUndoCopy + MobileUndoDoor · the six C1 holder models · 
   EditorSurfaceController · EditorView · JumpPrimitive · DataSafetyModel + Pane · ShellActions);
   the 19 C4-converted / C3-commented view files (BookView, BookIndexView, ReadModeView,
   SidebarView, LibraryInfoPanel, LibraryCatalogView, PostDetailView, TakesBoardView, CanvasView,
   ReadingFlowView, CommitBar, SeamGrip, SideColumn, SidebarNoteBox, StableSurface, ShellSplit,
   RootView, MarkdownStyling, DebugOracleOwnership) project byte-identically. This independently
   re-confirms round 1's same check on the post-fix tree.
2. **Production hunks read line by line in this session:** AppSession (C1 registry: `Hold`'s
   acquisitions/leftAtAcquisition generation, `autosave` mint + re-acquire, `releaseAutosave`'s
   Mac arm, `markLeaving`/`dropAfterLeaving`, `savepointOnLeaving`'s landed-gate; P33's
   begin/end door), StoreBackup whole (P38 single-flight + C7 + the fix), JumpPrimitive whole
   (C6 re-assert, C6b live `maxScroll()`, `readingLineIndex`, `lineSpan`, the R2-1 end-of-document
   probes), EditorViewModel's C6b hunk (`topVisibleOffset`'s baseline rule, `isBlankParagraph`,
   `firstReadableLineStart` — coordinate spaces verified consistent: the probe point, the limit
   argument and `layoutFragmentFrame` are all container-space) + the `isolated deinit` release,
   EditorView (C2's `scheduleRemeasure` generation coalescing, `viewUpdated`, `install`'s
   scheduled first report, `uninstall` nil-ing `reportHeight` so a late hop no-ops),
   EditorSurfaceController (P27's `liveActiveFans` store read — two indexed per-block reads,
   P1-shaped, never `slots`), ShellActions (C1 flush-never-mint; P33's two doors, latch at press
   before any await, `defer` release in the Task), CanvasViewModel (C1 single acquisition +
   deinit release; row 59's `noteFocusedBlock` before the ring switch), the two per-post caches
   (CompareBoardView, BookIndexEditModel — copy-and-clear teardown, deinit sees empty, so no
   double release in any order; re-acquire-during-teardown-flight traced balanced),
   TakesViewModel/BlockTOCView deinits, DebugOracleOwnership whole (index bookkeeping consistent
   across publish/withdraw/release/forget, including the re-publish-not-last branch),
   MarkdownStyling's three-writer invariant comment, DataSafetyModel/Pane (the busy latch + the
   `.disabled` gate round 1's NIT 3 stands on), StructuralUndoCopy/MobileUndoDoor (the one
   sentence, one home, phone forwarding byte-identical), RootView + SeamGrip + SidebarNoteBox +
   CommitBar C4 hunks (uniform owner-keyed pattern).
3. **Round 1's key dismissals re-traced at the code:**
   - **C1 drop-through-leaving:** every drop requires a LANDED `closeAutoCommit` + zero holders
     + an unchanged acquisition generation + a clean coordinator (`dropAfterLeaving`'s four
     guards). The racing orders I constructed (re-open during the savepoint's awaits → generation
     mismatch, no drop; last-release-spawned savepoint racing a re-open → stale left mark healed
     by the next acquisition or at worst one deduped quiet savepoint; two concurrent leaving
     savepoints → the serialized runner dedupes the second and the second drop finds no entry)
     all end safe. Confirms round 1.
   - **The router's scraps-canvas guard:** `CommandRouter.noteFocusedBlock`'s
     `guard activePostID == postID` read at the code — a scraps-area canvas is ignored, as the
     CanvasViewModel comment claims.
   - **`existingBackups`' lowercase-hex tail:** `StoreKeyEnvelope.shortFingerprint` is `%02x`
     (round 1 verified at the source; this session verified the parse side — `isFingerprintSuffix`
     is `-` + exactly 8 of `0-9a-f`, and the stamp round-trips through the one en_US_POSIX/UTC
     formatter both directions). `stampLength` 17 matches `yyyy-MM-dd-HHmmss`.
   - **The C6 re-assert:** bounded to one, `reachable` re-read AFTER the layout pass so a
     shrunk-maximum clamp is left alone; a grow-during-jump heals through C6b's live
     `maxScroll()` on the next proposal.
   - **BoundaryFluidity's adaptation:** `pendingCrossBlockTask` confirmed a pre-existing
     production member (`EditorSurfaceController:2000`, `private(set)`, 13u1-era history), not a
     test seam; the pin now waits on the act itself and GAINS a `#require`.
   - **The scrubber/inspector re-mechanizations:** `ComposedSliders` counts `SwiftUI.Slider<…>`
     NODES (never dump text), descends only into SwiftUI's own classes, drives the found
     `Binding<Double>`; the inspector ban reads the body's STATIC type. Both stronger than what
     they replace.
4. **Verification runs on the final tree (zero app instances first, checked by pgrep):**
   - Run 1 — the units' core suites + the fix's Data Safety five (21 suites: BackupRunTests,
     BackupOwnFilesTests, BackupSingleFlightTests, BackupRetentionTests, DataSafetyRunbookTests,
     AutosaveRegistryLifecycleTests ×2 suites, AutosaveRegistryReleaseTests, RefontGapTopTests,
     RefontViewportTests, JumpViewportLayoutTests, ScrollAnchorTests, InlineHeightReportTests,
     BoundaryFluidityTests, DebugOracleTwoWindowTests, DebugOracleOwnershipTests,
     MarkdownPaletteWritersTests, CanvasFocusedBlockFactTests, SeamMergeTests,
     DestructiveUndoWarningTests, FannedDefaultsTests, LibraryPanelHostTests):
     **`✔ Test run with 175 tests in 21 suites passed`**, zero skipped
     (`App/Variorum/DerivedData/18k-ladder-r2-run1.log`).
   - Run 2 — the adapted reader suites (11 suites, 88 tests) and run 3 — the remaining adapted
     suites under their real struct names (JumpCorrectionLoopTests, FragmentLinesTests,
     StructuralUndoTests, PageDomainTests, PagePaginatorTests, PagedReadViewTests,
     NoteBoxGeometryTests, NoteBoxCompositionTests, SpreadBookViewTests,
     OutlineWritingSurfaceTests, ScrollAnchorTests — 11 suites, 55 tests):
     **both `✔ … passed`**, zero skipped (`…r2-run2.log`, `…r2-run3.log`).
   - Total this round: **318 test executions across 43 suite runs, zero failures** — every
     new/changed suite and every adapted reader suite named by round 1, re-run green on the tree
     that includes the fix.
5. **Fences:** the diff's file list holds zero `Sources/` (so zero `Sync/`, zero schema, zero
   core), zero `Server/`; marker 9 untouched. TK1 discipline re-checked over the diff: no
   `.layoutManager`/`NSLayoutManager`; the C6b additions are `NSTextLayoutManager`/
   `NSTextParagraph`/`NSTextLineFragment` reads, the blank test stops at the first visible
   character, `firstReadableLineStart` is viewport-bounded with no `ensureLayout` (P1). No
   denormalization, no word-level tracking, no corpus-scaling cost anywhere in the diff.
6. **Records:** the plan's THE LADDER section carries round 1's verdict + adjudication and the
   corrected fix hash (`5355e037`'s correction verified against `git log`); KnownIssues rows 65 /
   W-4/W-2 (row 81) / W-3 (row 82) CLOSED with the fix mechanisms named; QUESTIONS #147/#148
   filed; no commit trailers on any ladder commit (checked `0ebc3b5e`, `af2a761b`, `5355e037`,
   `4401d6c1`).

---

## FINDINGS (severity-ranked)

**No BLOCKER. No MAJOR. No MINOR. No NIT.** Round 1's three NITs stand exactly as adjudicated
(NIT 1 fixed and confirmed above; NITs 2 and 3 re-read at the code and confirmed as the recorded
deliberate trades — the `MainActor.assumeIsolated` loud-trap note and the `setInsurance` busy
guard's sibling convention, whose human road is closed by the `.disabled(model.busy || …)` gate
this session read at `DataSafetyPane.swift:177`).

**One dismissal sharpened, recorded so it is not re-derived (not a finding — no red-on-old pin is
possible against current code):** round 1's Release-over-release note ("holders negative, entry
permanent — the safe side") is the whole story only for the negative-count case. A hypothetical
DOUBLE release by one of two live holders would put `holders` at 0 without tripping the DEBUG
assert at that moment (it trips later, at the true last release), and in a Release build a leaving
savepoint could then drop the entry while a surface still holds the coordinator — the coordinator
itself keeps flushing (its debounce is its own), so what is exposed is only the ⌘Q-walk
registration for text typed in the quit-race window. This requires a pairing bug that does not
exist (the seven sites were each verified one-release-per-acquisition, here and in round 1), DEBUG
catches the class at the eventual negative, and the M2 mutation pin covers the loss class — so it
is recorded as the precise shape of the accepted trade, nothing more.

---

## CLEAN BILL (checked specifically in THIS session, found solid)

1. **The round-1 fix (`0ebc3b5e`)** — correct in its lane, honestly pinned red-on-old, tightly
   scoped, its home file re-swept whole with no adjacent hazard.
2. **C1's registry lifecycle** — acquisition/release pairing re-verified at all seven Mac sites +
   the ShellActions flush-never-mint conversion; the generation-guarded drop's four conditions;
   the per-post caches' copy-and-clear/deinit split; the J11 roads (still-shown pane, book/Compare
   notes, the open tail, mode switch, two-surface close) each covered by a green pin this session
   ran.
3. **The editor seam (C6/C6b)** — `JumpPrimitive` and `topVisibleOffset` read whole; coordinate
   spaces consistent; the re-assert bounded; the live scroll range composing with it;
   `EditorTextView`/`BlockRangeIndex`/`PaneTextAuthority` untouched (verified in the diff's file
   list, not the record).
4. **C5's four Mac latches + row 59** — P33 taken synchronously at press, shared by both doors,
   `defer`-released, one refusal sentence with one home; P38's id-guarded single-flight with the
   forced-behind-due-check exception matching Back Up Now's documented promise; P27's
   store-authorized unfanned merge; row 59's report ahead of the ring switch behind the router's
   active-post guard.
5. **C7 + the fix** — the own-names listing rule re-derived from the code (prefix + exact stamp
   round-trip + empty-or-8-hex tail); the pass-through `source:` required with no default; the
   prune counting only own names; the far folder's due-check unmoved ahead of the fixed guard.
6. **C4's ownership sweep** — `OwnedRegistrations` bookkeeping consistent; conversions uniform
   across all view files; Release projection of the whole sweep byte-identical by my own script;
   the two-window pins green this session.
7. **C2's hop** — no binding write inside `makeNSView`/`updateNSView` remains; newest-wins
   coalescing cannot strand (every trigger re-arms); uninstall closes the late-hop door.
8. **The suite evidence** — 318 green test executions this round on the post-fix tree, including
   every suite the fix's file participates in.

**Round-2 verdict: 0 BLOCKER · 0 MAJOR · 0 MINOR · 0 NIT.** No new finding of any severity; the
one fix under re-review is confirmed. Per the ladder rule, no round 3 is owed.
