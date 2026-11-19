# VM-64 — ladder round 1 (cold review, the whole run's diff)

**Reviewer:** `fable-reviewer`, fresh, `notes/REVIEW_PROMPT.md` verbatim, zero framing. **Diff:** `359ae214d...HEAD`
on `vm-64-timing-and-lags` (63 files, ~13.9k insertions). **Read:** the run record §1–§7 in full (plan, LIVE STATUS,
stage results, every batch closeout, the midpoint review + dispositions), CLAUDE.md + loaded canon, SyncSpec in full
(a schema migration landed), TEXTKIT2_NOTES §3–4 (editor seam), MobileSoul §1–5, and the production diff file by file
(every changed `Sources/`, `Shared/` and `VariorumMobile/` file read in this session), plus the load-bearing test
files (`LeavingSavepointTests`, `OwnerAdoptionTests`, `LibraryPoolPagingTests`, `MigrationTests` edits,
`MobileStructuralFlightFenceTests`' keyboard road, `MobileNoteOpenOnceTests`' hazard pins,
`MobileHerPathsPerfTests`' assertions). **Re-ran headless:**
`swift test --filter 'TimingRecorderTests|StructuralFlightFenceTests|LeavingSavepointTests|OwnerAdoptionTests|OwnerIdentityTests|LibraryPoolPagingTests|MigrationTests'`
— **103 tests in 10 suites passed.** Hosted suites were not re-run (no stage; the machine note forbids xcodebuild);
the record's stage results carry executed counts, red-on-old runs and local logs for every hosted claim, and the pin
code I read matches what those results claim to have run.

**Verdict: 0 BLOCKER · 0 MAJOR · 4 MINOR · 3 NIT.**

---

## Findings (severity-ranked)

**1. [MINOR] · `App/Variorum/Shared/AppSession.swift` (phone branch of `savepointOnLeaving`, ~:700–:745) · The
reader-read dedupe narrows the leaving savepoint's visibility window on the SINGLE-ask road, and the comment
over-claims equivalence.** Mechanism: the old road's one ask was a `runner.run { closeAutoCommit }` — a write
transaction queued on the writer's FIFO, so any working_text write already queued or committing before that turn was
seen by the op's in-transaction scan and savepointed. The new road reads the owed set on a READER (`database.read` →
`Queries.leavingSavepointCandidates`), which in WAL neither queues behind nor waits for the writer: a take dirtied by
a write that commits between the read's snapshot and the narrowed runner turn (a sync apply's working_text landing, a
conflict-take rescue — not her typing, which `flushExistingAutosave` lands before the read) is not listed, and
`closeAutoCommit(_:takes:)` (`Operations/Operations+Variant.swift:342–377`) deliberately re-checks only LISTED takes
— so that leaving writes no savepoint for it. On the multi-ask roads (Castle backgrounding, the lock) a later ask's
read catches it, exactly as the closeout's hazard (a) table says; on the POP road there is no later ask, and the
in-code comment ("anything that landed between two asks — her typing, a sync round's apply — is still savepointed,
exactly as before") plus hazard (b)'s "nothing can go stale" do not hold for that window. Bounded consequence: one
quiet insurance-class savepoint deferred to the next leaving/idle backstop — the text itself is in the store and
syncs regardless; nothing of hers is lost. Evidence: the two files above; D-7-1(b) in the closeout records the
adjacent "nothing landed since" problem without noting this window. **Fix shape (either):** (a) accept the narrowed
window as the design's cost and correct the two comments + hazard (b)'s record text to say it (no pin — a record
fix); or (b) when `owed` is non-empty, have the one runner turn re-run the candidates READ in its own transaction
(SQL only, no decode — ~6 ms at 100k on the simulator per the after-numbers) and write the union, closing the window
for the edited case (the empty-owed case keeps its no-turn win and its window). **Pin for (b):** hold the writer
with an uncommitted UPDATE dirtying a second take of the note before the leaving's read; release after the read
returns; the leaving must still savepoint that take — red on this tree, green on the pre-VM-71 tree. For (a), no pin
(record-only), labeled honestly here so the ladder does not dismiss it as hollow: the pinnable product difference
exists, the question is whether it is accepted cost or fixed.

**2. [MINOR] · `App/Variorum/VariorumMobile/Features/Write/MobileEditorViewModel.swift` (`takeAutosaveHold`) · A
screen shown again BEFORE its leaving finished keeps its hold but never re-establishes the coordinator observation
`teardown()` tears down.** Mechanism: cover → `onDisappear`'s task runs `teardown()`, whose last act is
`stopObserving` + `autosaveToken = nil`; re-show → `.task` → `takeAutosaveHold()` → `guard !holdsAutosave else {
return }` exits BEFORE the `if autosaveToken == nil { observe }` block — so the re-shown screen's editor records
into its coordinator but no longer hears `onSettled`/`onError`: `storeWriteGeneration` is not bumped when its own
writes settle and `applyPendingIfClean()` is not called at settle, so a deferred projection waits for the next
delivery and the S3-MAJOR-3 freshness fence degrades to the refetch road (extra reads, delayed apply — no text
loss, no stale write). The gap persists until a FULL leave-then-return cycle. The same gap existed pre-VM-70 (no
re-observe existed at all), but r1's `takeAutosaveHold` now fixes exactly this for the completed-leaving case and
misses the in-flight-leaving case by one line. **Fix:** hoist the `if autosaveToken == nil { … observe … }` block
above the `guard !holdsAutosave` early return (it is already idempotent and reads `autosave` at use time). **Pin:**
`MobileNoteOpenOnceTests`' world — open, type nothing, close while the writer is held (the
`theReleaseWaitsForTheLeavingSavepoint` posture), re-show the screen before releasing the writer, then release;
`model.observesAutosave == true` — red on this tree.

**3. [MINOR] · `Sources/VariorumCore/Diagnostics/TimingRecorder.swift:309–328` · (midpoint finding 6, pre-agreed
for THIS fix pass; confirmed still present.)** `end(_:countingUnmatched: false)` calls `changed()` unconditionally,
so an `endIfOpen` that found nothing open — the common case for every `keyboardDidShow` — marks the record dirty
and schedules a needless 20 s file save of an unchanged table. **Fix:** call `changed()` only when something was
recorded or a counter moved (the `unmatchedEnds` increment IS a change; a bare no-op is not). **Pin:** the change
handler must not fire on a no-op `endIfOpen` (red today).

**4. [MINOR] · run record §5 (batch 7 row) + the run's own closing rule · The batches 6+7 combined simulator walk
is still OWED and batches 6/7 are already marked CLOSED.** The plan's rule (§2: "every umbrella closes on
use-shaped evidence on her phone or a simulator walk, never on a pin alone") and the batch-7 row's own note ("the
combined walk for batches 6 and 7 is owed before the run closes") both stand; batches 1 and 5 have their walks
recorded, 6 and 7 do not. Not a code defect — a closeout gate this round pins in place so it cannot evaporate
between the ladder and the merge. **Fix:** run and record the walk (or record the orchestrator's explicit decision
that the final-tree company run + the wave-1 install substitute, with her rule quoted) before the run closes.

**5. [NIT] · `Sources/VariorumCore/Domain/StructuralFlightFence.swift:94–96` · (midpoint finding 7, pre-agreed for
this fix pass; confirmed still present.)** `surfaceSettled()` is declared `mutating` but mutates nothing, and reads
like an event when it is a query. Drop `mutating` or rename.

**6. [NIT] · `App/Variorum/Shared/SyncSession.swift` (`endRoundTiming`) · `sent = start.owed − stillOwed` clamps
negative to 0 at `AppTiming.syncRoundEnded`,** so a round during which she queued more rows than it pushed reads
"0 sent (about)". Within the series' documented "about" semantics; worth one comment word ("can under-read under a
mid-round burst") so the readout sitting is not surprised. No pin.

**7. [NIT] · `notes/plans/fixes/vm-64-timing-and-lags.md` ·** The FOR A LATER READER section is still the
placeholder (correct while the run is open — flagged only so the closeout checklist carries it), and finding 1's
comment corrections (AppSession phone branch; hazard (b) "nothing can go stale") land with whichever arm of finding
1 is chosen.

## Review foci (each addressed explicitly)

1. **Timing layer content/cost — SOLID.** No entry point takes a string (two closed `String`-backed enums; the
   archive holds raw series names + numbers; the build key is version|build|LC_UUID — no user id, no note text);
   every mark is one relaxed atomic load on the Mac and O(1) enabled (lock + dict slot + ring write); memory
   bounded (64-ring per series, closed catalog, `TimingBook` capped at 2 builds); persistence is numbers-only JSON
   in the app container, batched 20 s off timed paths, `completeFileProtectionUntilFirstUserAuthentication`, the
   test host never persists (`MobileTiming.persists`). Verified by reading all seven files + the 31 headless tests.
2. **Speed claims carry numbers — SOLID.** Batch 4: 11.14 → 0.79–0.86 ms headless (median+range, n=5, "a Mac
   number, never a phone number") + 1.16 → 0.80 ms simulator; batch 5: fetch timings reported honestly as NOT
   faster per fetch, with the flat-growth VM-step evidence (6,332 → 6,164 at 300 → 1,200 vs 77k → 307k); batch 7:
   215 ms → 1.07 ms runner turn + the full after-table; batch 6: 496 → 342 ms open-to-live. Every table names the
   simulator and the load.
3. **VM-2 input roads — answered, with two honest residues.** Typed keys, ⌫, paste, formatting, edit menu,
   autocorrect: gate-consulted → refused, said once at the drain (never silent — the sentence is pre-existing copy,
   one home). Dictation/composition/programmatic: withheld — tiling kept, `recordAutosave` skipped,
   `forceFullRender` forces a store re-read before the fence drops. A typed key IS dropped-with-a-sentence (P-2-1,
   PROVISIONAL, hers at the merge — the E1-trace argument that hold-and-replay is dishonest on her keyboard road is
   sound); the tail's timer road is VM-226 (ticketed). The fence fails CLOSED (settling refuses until the page
   holds the store); the one latch's `didSet` + the undo door's hook mean no fencing door can fly unfenced; the
   insert-below exemption's hollow-row trace is correct and its guard pin is green-on-both by design.
4. **VM-67 S4 — SOLID.** The probe and the UPDATEs share ONE `writeWithoutTransaction` access (the writer's FIFO —
   no TOCTOU; `aRowFromAWriteAlreadyQueuedIsAdoptedByThatPass` pins it); predicate, call sites and occasions
   byte-unchanged; v1_38 is its own commit (`0e9948d03`), **no line in `Sources/VariorumCore/Sync/` or `Server/`**
   (verified by `--name-only`), the mirror untouched, marker 15 — SyncSpec read in full: §2's no-mirror-indexes
   rule and §12's table/column/semantics scope confirm a local partial index is not a lockstep event; an older
   build meeting a v1_38 store refuses as `.newerSchema` (the standing classifier). The migration test derives the
   index set from the registry so a future owner-carrying table fails red; the statement-trace + EXPLAIN pins are
   real and ran red-on-old by revert (5 failed / 7 issues, recorded per-pin).
5. **VM-68 — SOLID, with the PROVISIONALs correctly routed.** Held reads are a bounded keyset first page (200) or
   the listed depth she scrolled to; nothing held while hidden; the 201st-note and bookless-door pins ran RED on
   the red build at the stage; the union's book-withholding is P-68-4 (QUESTIONS at the merge) and books stay
   reachable under the Books filter meanwhile; the Mac's two statements are byte-identity-pinned against frozen
   pre-change builders and its 14 suites ran green; `sort_key` is non-null in every arm (all key expressions
   COALESCE to `created_at`). The return re-ask road (GRDB first-fetch-then-track) is correctly reasoned and
   guarded (`aNoteMintedWhileTheLibraryIsAway…`).
6. **VM-69/70 — SOLID (with finding 2's one-line gap).** No load-to-first-delivery gap: the load IS the
   observation's first value, GRDB's snapshot-compare contract is cited correctly and guarded by the
   writer-held pin; a re-arrival's first value takes the DELIVERY arm (never rewrite-by-age-unchecked); the
   release is the leaving's LAST act (deterministic — the r0→r1 falsification and re-design is exemplary
   evidence discipline), `releaseAutosave`'s phone rule keeps a dirty or held coordinator, and the three release
   pins ran red-on-old and green far inside their guards on the calm window. P3's one live editor untouched
   (liveness/standDown unchanged). VM-227 honestly ticketed.
7. **VM-71 — the lock did not move.** No line in `MobileRelock.swift`, `MobileShellRouter.swift`,
   `AppBootstrap.swift`'s lock path (its diff is two timing marks), `MobileQuickNote.swift`'s filing order, or
   `MobileWriteView`'s ask order — verified in the diff; who asks is unchanged on all five roads. A savepoint that
   should happen is never skipped by the dedupe itself (the matrix test covers every take class, including
   never-savepointed-empty = not owed, matching `isDirty` byte-for-byte superset semantics, and archived takes
   owed, matching `autoCommitDirtyVariants`) — the one narrowed window is finding 1. `StoreLockedError` on the
   read skips exactly where the old attempt failed-and-swallowed.
8. **Mac unchanged; brains placed right — SOLID.** The Mac's `savepointOnLeaving` statements are unchanged (guard
   collapse only); `closeAutoCommit(_:)` byte-identical; the two new Core APIs have one caller (the phone branch);
   `adoptOwnerID`'s no-write-when-nothing-unowned improvement applies to the Mac too and is recorded; every Shared
   timing mark is inert on the Mac (one atomic load); Mac suites over the shared types ran green at three windows
   (61/9, 110/16, 48/7, 93/14). Brains: `Diagnostics/` + `StructuralFlightFence` in Core, the catalog in
   `Shared/`, phones own faces (MobileSoul §3).

## Clean bill (load-bearing things specifically checked and found solid)

- **The fence end-to-end:** latch `didSet` hooks (structural + undo door), the two-latch landing rule, the
  insert-below exemption's set/restore ordering (safe in both directions since `holdsFencingFlight` conjoins), the
  gate belt's position (after the gone/stood-down/sealed belts, attribute-only edits pass), the storage belt's
  withhold (tiling + restamp kept so the identity audit stays coherent; `forceFullRender` set), the settle loop's
  3-attempt + projection-hook convergence, `flushPendingText`'s fence re-read, and the drain's one sentence from
  the pre-existing copy home. The hosted pins drive the delegate-consult-then-insert road per TEXTKIT2 §3's new
  measured rule, and that canon line matches the evidence.
- **`leavingSavepointCandidates` ↔ `closeAutoCommit` equivalence:** same join, same ordering
  (`created_at DESC, id DESC`), byte-vs-canonical superset direction correct, never-savepointed-empty excluded on
  both sides, sealed/gone/cadence gates identical, the narrowed op's per-take re-check inside one transaction on
  one clock read; the matrix test covers every class and the same-rows test compares full row tuples.
- **v1_38 + `adoptOwnerID`:** probe-then-write inside one writer access; report shape preserved; the eleven
  indexes match the eleven owner-carrying tables; migration pins derive the set; export/recreation/sync-schema
  suites unaffected (242/20 recorded, and my own 103/10 re-run green).
- **The Library paging state machine:** generation/supersede guards on `loadMore`, single-flight follow with
  followAgain, `wantsMore` kept until an append, dedupe-keeps-first landing rule, cancellation guards before every
  landing, `isDrawn`'s zero-width guard, scraps stand-down, the bookless empty-line's store fact read in the same
  read. Nothing held while hidden; nothing corpus-shaped held ever.
- **The hold lifecycle (r1):** arrival-count capture at `onDisappear` vs `.task`'s main-actor increment —
  no gap; `deinit` releases exactly the never-given-back remainder; adoption of a re-minted coordinator
  (two-coordinators-for-one-note impossible); the dirty-keep rule in `releaseAutosave`'s phone branch read
  in code.
- **Timing marks:** every mark site is a one-line append; `SyncSession`'s round timing reads only the scheduler's
  public status + two local counts labeled "about", serial-guarded against stale readings; no `Sync/` line.
- **Process:** no `Sources/VariorumCore/Sync/`, no `Server/`, no custody/keychain code (the one
  `Features/Protection/` line is the lock-screen timing mark, named plainly in the record and inside the
  coordinator's granted slot); QUESTIONS/TICKETS/master plan untouched on the branch; every PROVISIONAL carried
  with options under "For QUESTIONS at the merge" headings; no commit trailers; no device identifiers in the
  record; `vm64-screens/` gitignored; the ladder-cap-five canon change matches her recorded verbatim words across
  CLAUDE.md, both skills and ProcessHistory; VM-226/VM-227 minted with evidence labels.
- **P1 across the diff:** no added cost scales with note or corpus — adoption ∝ unowned rows, the leaving read ∝
  the note's takes on a reader, pages ∝ page/scrolled depth, the fence O(1), the timing layer O(1)/bounded;
  nothing tracks word-level change; nothing copies text across entities.

*(Findings 3 and 5 are the midpoint review's pre-agreed items landing in this fix pass, restated here so the pass
has its round-1 row; findings 1 and 2 are new; finding 4 is a closeout gate, not code.)*
