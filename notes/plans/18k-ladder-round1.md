# 18k LADDER — ROUND 1 (Fable cold review over the combined diff `1b7858eb^..HEAD`)

**Reviewer:** `fable-reviewer`, fresh session, zero implementation context. The unit RECORDs and
ORCHESTRATOR ADJUDICATIONS in `notes/plans/phase-18k-runtime-hygiene.md` were read as the map; every
load-bearing claim below was re-checked at the code or by a run in this session, never taken from a
record. **Diff:** `git diff 1b7858eb^..HEAD -- App Sources Tests Tools` — 67 files, ~5.9k insertions,
131 commits (C0–C7 + C6b + the held walks). **Canon read:** CLAUDE.md, AppSpec (§7/§9/§14),
OverallModel (I1–I10/P1–P3/S1–S5), SyncSpec, TEXTKIT2_NOTES, KnownIssuesAndTechDebt, QUESTIONS,
the 17e entry, the health-rounds kickoff file. No "Review foci" section exists in the plan or a
brief (grep-verified); the adjudications' named review targets were each taken as mandatory checks
and are addressed in the clean bill.

**What I verified myself (not trusted from the record):**
- **Every production hunk read line by line:** `AppSession` (C1 registry + C5 P33 latch),
  `StoreBackup` (C5 P38 single-flight + C7 listing/pass-through), `JumpPrimitive` (C6 re-assert +
  C6b live scroll range + `readingLineIndex`), `EditorViewModel` (C1 deinit release + C6b
  `topVisibleOffset` baseline rule + `firstReadableLineStart`), `EditorView`
  (C2 coalescing hop), `EditorSurfaceController` (C5 P27 store-authorized unfanned merge),
  `ShellActions` (C1 seal flush + C5 latch doors), `CanvasViewModel` (C1 single acquisition + C5
  row-59 report), `CompareBoardView` / `BookIndexEditModel` / `TakesViewModel` / `BlockTOCView`
  (C1 releases), `DataSafetyModel`/`Pane`, `StructuralUndoCopy`/`MobileUndoDoor`,
  `DebugOracleOwnership` (whole file).
- **The DEBUG-only / comment-only claims re-proven independently:** my own release-projection
  script over every touched production file (strip `#if DEBUG` branches + comments, old vs new)
  — the ONLY files whose release projection changed are exactly the units' named production fixes;
  the 16 C4-converted view files and C3's six comment sites project byte-identically. (This
  independently re-proves C4's `release_projection.py` result and C3's zero-non-comment-lines claim.)
- **Two verification runs on the final tree (zero app instances first, `pgrep` by PATH):**
  run 1 — the 23 new/changed suites (`AutosaveRegistryLifecycleTests` ×2 +
  `AutosaveRegistryReleaseTests`, `InlineHeightReportTests`, `JumpViewportLayoutTests`,
  `RefontGapTopTests`, `RefontViewportTests`, `ScrollAnchorTests`, `BoundaryFluidityTests`,
  `BackupOwnFilesTests`, `BackupSingleFlightTests`, `BackupRunTests`,
  `DestructiveUndoWarningTests`, `FannedDefaultsTests`, `SeamMergeTests`,
  `CanvasFocusedBlockFactTests`, `DebugOracleTwoWindowTests`, `DebugOracleOwnershipTests`,
  `MarkdownPaletteWritersTests`, `LibraryPanelHostTests`, `PagedReadViewTests`,
  `SpreadBookViewTests`, `OutlineWritingSurfaceTests`):
  **`Test run with 191 tests in 23 suites passed`**, zero skipped, every named suite counted
  (`DerivedData/18k-ladder-r1-run1.log`); run 2 — the 13 ADAPTED reader suites (the 21 reset-door
  pin lines, the InlineEditorWindow harness line, the pure loop/line pins):
  **`Test run with 95 tests in 13 suites passed`**, zero skipped
  (`DerivedData/18k-ladder-r1-run2.log`). The opt-in `DebugOracleSingletonWindowTests` was in no
  set, per its own gate.
- **Traced mechanisms** for the four flagged review targets (C1 drop-through-leaving, C6
  re-assert, C6b capture/jump, C7 listing) — the clean bill names what was checked in each.
- **Not re-run by me** (read-only review; the records' evidence stands and was spot-checked
  structurally): the behavioural reverts / mutations (each is named-before-run in its unit record
  with per-issue counts, and I verified the pins are capable of failing by reading their
  assertions against the production code they drive), the iOS build, and the phone simulator
  suites (`MobileLivenessTests` — I read the P26 pin whole; it forces the interleaving with a held
  store and drives the real `MobileLivenessAuthority`).
- **TK1 discipline:** grep over the whole diff — no `.layoutManager`/`NSLayoutManager`; the new
  reads are `NSTextLayoutManager`/`NSTextParagraph`/`NSTextLineFragment` API only; the one added
  layout call is `layoutViewport()` (viewport-bounded, displaced-scroll-only — P1).
- **Records:** KnownIssues rows (65, 59, W-3/W-4/W-2 closed; the new rows with owners), 17e's
  copied dispositions ("18k's C5 — the dispositions"), QUESTIONS #146/#147, the master plan's 18k/18o
  registration, the health-rounds table — all present.

---

## FINDINGS (severity-ranked)

**No BLOCKER. No MAJOR.** Three NITs, none of which gates the run; none carries a red-on-old pin
obligation (none is a bug-class defect — two are copy/failure-mode notes, one is a convention echo).

1. `[NIT]` · `App/Variorum/Shared/StoreBackup.swift` (`performSecondLeg`, the `guard let source`
   arm) · **The failed-primary sentence is slightly false in its rare lane.** Mechanism: the
   primary leg THROWS (e.g. the recorded pre-existing arm where `prune` throws after a successful
   write) while the far folder is due → `standing` is nil → the far leg says *"There is no
   snapshot to copy yet."* although snapshots exist beside the library — only THIS ACT has none.
   Evidence: the code path is unconditional on the folder's contents; judgment call 2 records the
   behaviour (correct — never re-discover by listing) but not the wording. The primary row carries
   the true error, the face shows both legs failed, and the next run (≤ 1 h) heals. Proposed fix:
   one wording tweak ("This run made no snapshot to copy.") — copy only, no behaviour.

2. `[NIT]` · `App/Variorum/Variorum/Features/Editor/EditorView.swift:680`
   (`MainActor.assumeIsolated { self?.scheduleRemeasure() }`) · **The storage-notification hop's
   failure mode changed from silently-safe to loud-trap.** The old road
   (`DispatchQueue.main.async { remeasure() }`) was thread-safe from any posting thread; the new
   one preconditions main-actor and traps (Debug AND Release) if a `didProcessEditing` ever
   arrives off-main. Today every storage edit is main-actor (verified: the writers are @MainActor
   view models/controllers; the comment cites the canary's precedent), so this is a deliberate
   loud-on-violation trade, not a defect — recorded here so a future background storage writer
   knows the trap exists. No fix owed; reverse in one line if ever wanted.

3. `[NIT]` · `App/Variorum/Variorum/Features/Settings/DataSafetyModel.swift`
   (`setInsurance`'s `guard !busy else { return }`) · **A toggle intent arriving in the sub-frame
   window before `busy` renders is silently dropped** — for a Toggle (unlike its three sibling
   BUTTONS) a dropped intent means the control springs back visually. Mechanism: two programmatic
   `setInsurance` calls in one turn → the second returns without writing. Reachability: the
   `.disabled(model.busy || …)` gate closes the human road; only automation/tests can hit it, and
   it is the pane's standing sibling convention. Honest label: traceable but negligible; recorded,
   not asked to change.

**Dismissals / non-findings, recorded so round 2 does not re-derive them:**
- **C1's drop-through-leaving was stress-traced for the text-loss class and holds.** Every drop
  path requires a LANDED leaving savepoint + zero holders + an unchanged acquisition generation +
  a clean coordinator; every racing order I could construct (leaving vs deinit, re-open mid-drop,
  the two-window still-shown pane, the lock-marks-left-then-mode-switch order, release-before vs
  after-acquire on a mode switch) ends in either a kept entry (safe) or a drop AFTER everything
  was committed — worst case an extra QUIET savepoint, which `closeAutoCommit`'s dedupe absorbs
  (the insurance class, J11's own doctrine). The stale-left mark a racing `markLeaving` can leave
  on a re-opened note is healed by the next acquisition and can at worst cost one deduped
  savepoint — not a defect.
- **A Release-build over-release** (the DEBUG `assert` compiled out) leaves `holders` negative and
  the entry PERMANENT — the safe side (under-release), not the loss side; the M2 mutation pins the
  loss class in DEBUG. Not a finding.
- **The C6 re-assert re-scrolls to the pre-pass `wanted`** even when the pass GREW the document so
  the un-clamped target became reachable — healed within the same loop iteration set because C6b's
  live `maxScroll()` re-clamps every later proposal. Composition verified at the code; the suites
  pin the outcome. Not a finding.
- **`existingBackups`' lowercase-hex tail rule** cannot orphan any app-written snapshot: every
  writer routes through `StoreKeyEnvelope.fingerprint(of:)` (`%02x`, lowercase — read at
  `Sources/VariorumCore/Persistence/StoreKeyEnvelope.swift:150`), and the stamp read-back is
  symmetric (`stampFormatter` is en_US_POSIX + UTC both directions). The Castle offer's changed
  contents match the runbook §7's own words. Not a finding.
- **`noteFocusedBlock` from a scraps-area canvas** is ignored by the router's own
  `guard activePostID == postID` (`CommandRouter.swift:175`) — the code comment's claim verified.
- **C1's recorded consequence** (a Mac-left note later changed only by sync no longer gets a Mac
  ⌘Q savepoint) is a correct reading of J11's letter; the idle backstop covers it; recorded in the
  plan and AppSession's doc. Not spec drift.

---

## CLEAN BILL (checked specifically, found solid)

1. **C1 — the autosave registry release (`AppSession` + 7 holders + `ShellActions`), the run's
   highest-value target.** Acquisition/release pairing grep-verified complete (7 Mac sites, each
   with exactly one release at its owner's real end of life; the phone's `MobileEditorViewModel:187`
   deliberately left, KnownIssues row filed, owner mobile). The double-release safety of the two
   per-post caches (teardown copies-and-clears, deinit sees empty) verified. Flush-then-release
   ordering verified per site. The three J11 roads a plain release would have cost (still-shown
   pane, book/Compare-peer notes, the open tail) each carry a green pin I ran; the open-tail pin
   is red-on-old per the record (T3.3). `finalizeAll`'s iteration is safe under mid-walk
   unregistration (value-semantics snapshot). The seal fallback's `flushExistingAutosave` reaches
   the same coordinator for holders-0 entries (keyed by post, not holders).
2. **C6/C6b — the `JumpPrimitive` seam (the second target).** The re-assert is bounded (one),
   clamp-vs-displacement discrimination correct (`reachable` re-clamped post-pass), and the C6b
   live `maxScroll()` closure composes with it so a grow-during-jump heals inside the ≤6-iteration
   loop; the pure `JumpCorrectionLoop` Double form forwards byte-identically (pins unmodified,
   ran green). `topVisibleOffset`'s baseline rule: coordinates verified consistent
   (container-space probe, fragment-local baselines = `typographicBounds.minY + glyphOrigin.y`);
   the blank test stops at the first visible character (P1); `firstReadableLineStart` is
   viewport-bounded with no `ensureLayout`; the end-of-document fall-through keeps the old answer.
   `EditorTextView`, `BlockRangeIndex`, `PaneSurface`, `PaneTextAuthority`, the storage seam:
   untouched (verified in the diff, not the record).
3. **C7 — the backup listing (data safety).** All SEVEN readers of `existingBackups` enumerated
   independently (the five in the trace + `DataSafetyModel.summarize` + `pruneSecond` +
   `PostureSwitch:1484`) — every one now reads the app's-own-names-only rule; the pass-through
   (`performSecondLeg(source:)` required, no default) removes the re-listing entirely; the prune
   can no longer count or delete foreign names; the just-written snapshot can never be its own
   prune victim (newest of 14). `BackupOwnFilesTests` runs on a real keyed on-disk store with her
   three A1 names verbatim; ran green. The future-stamp silent-stop residue is filed (owner 18o).
4. **C5 — the concurrency five.** P27's store read is the seam road's own `liveActiveFans`
   (never `slots`); the await sits before `runStructural`'s flight flag with the same window the
   carry-all road already has, and a second act inside it is refused by that guard. P33's latch is
   taken synchronously at press time, shared by both doors, released by `defer` in every path;
   refusal is the phone's exact sentence with one home (`StructuralUndoCopy.anotherIsLanding`,
   phone forwarding byte-identical). P38's single-flight is @MainActor-serialized (no suspension
   between the check and the install), the id-guarded clear cannot drop a newer flight, and the
   forced-behind-due-check exception matches Back Up Now's documented promise. Row 59's report
   rides before the ring's switch (the Takes board's placement) and the router ignores non-active
   posts. P26's pin forces the exact interleaving with a held store.
5. **C2 — the inline height hop.** No write inside `makeNSView`/`updateNSView` remains (the
   binding closure is only called from the hop); newest-wins coalescing cannot strand (M-stuck's
   class) because every trigger re-arms; `uninstall` nils `reportHeight` so a late hop is a no-op;
   the one harness adaptation adds a mount-time width the app supplies by construction, assertions
   unchanged.
6. **C4 — the oracle ownership.** `OwnedRegistrations`' index bookkeeping verified consistent
   across publish/withdraw/release/forget (including the re-publish-not-in-last-position branch);
   the whole file and every conversion compile to NOTHING in Release (my independent projection);
   the last-live-writer order preserves every pre-C4 reader's live behaviour; the parallel-suites
   axis is honestly excluded and its pins are opt-in-gated (`.enabled(if:)`, verified).
7. **C3 — the comment-only claim** re-proven by projection; the six comments now state the
   measured mechanism; the hops themselves byte-identical.
8. **Adapted pins not weakened:** `AutosaveRegistryReleaseTests`' `letGo` keeps every assertion's
   meaning (release-then-leaving is the Mac's real order); `ScrollAnchorTests`' ground truth moved
   WITH the product rule and its target defect still bites (M-inset, run twice in the record);
   `BoundaryFluidityTests` now waits on the scheduled compound (`pendingCrossBlockTask` is a
   pre-existing Phase 11 production member, not a test seam) and gains an assertion; the scrubber
   pins count composition NODES and drive the binding (stronger than the old NSView count); the
   inspector ban reads the body's static type (value-dump/test-name trap closed). The Outline's
   hollow `== 0` arm is now a real geometry assertion (bottom content inset + page-reaches-edge).
9. **Sync/custody/schema fences:** zero `Sources/`, zero `Sync/`, zero `Server/`, zero schema,
   marker 9 unchanged — verified by the diff's file list, not the record. No denormalization, no
   word-level tracking, no corpus-scaling cost anywhere in the diff; every new per-gesture cost is
   one indexed read or one viewport-bounded layout.
10. **Records:** ledger statuses current; KnownIssues rows closed/filed with owners; 17e
    dispositions copied; QUESTIONS #146/#147 filed; the morning bundle leads with C7's exposure +
    remedy; WalkKit/ENVIRONMENT TRAPS lines landed. **Owed at the CLOSEOUT, on the adjudications'
    own word (named here so it cannot slip):** the `TEXTKIT2_NOTES.md` measured-findings paragraph
    (C2's first-measure drift · C6's `layoutViewport()` clip displacement · C6b's fragment-frame /
    `glyphOrigin` / re-font-under-estimate facts), the full-Mac finals, and the install refresh at
    a zero-instance window.

**Round-1 verdict: 0 BLOCKER · 0 MAJOR · 0 MINOR · 3 NIT** — none of the three NITs requires the
cross-model fix flow (two are recorded trades/wording, one is a sibling-convention echo); if the
orchestrator wants NIT 1's one-line wording tweak, this reviewer can land it on authorization with
a copy-level pin. Per the ladder rule, no NEW BLOCKER/MAJOR arose, so no round-3 pass is owed by
this round's findings; round 2's re-review of any fixes is the orchestrator's call.
