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

---

## Implementer responses (fix pass)

*The fix pass's implementer (Opus, fresh, cross-model flow): one entry per finding, written before any fix and committed
first. Each says agree or dispute with its ground; the reviewer makes the final call on each. Line numbers are at
`4b4d64143`. The fix pass's own record is the run record §5 ▸ "Ladder round 1 — fix pass" and §7 ▸ "Fix pass".*

### 1 · [MINOR] the leaving's read narrows its visibility window — AGREE with the mechanism; recommend ARM (a); neither applied yet

**The trace, on today's code (the pop road).** `MobileWriteScreen.onDisappear`'s one task (`MobileWriteView.swift:234-241`)
runs `teardown()` — `finish()`: the tail's mint, then `autosave.flushNow()` (`MobileEditorViewModel.swift:815-827`) —
then `savepointOnLeaving`'s phone branch (`Shared/AppSession.swift:691-747`): its flush (`:718`, a no-op after teardown),
the candidates READ on a pool reader (`:720-723`, a WAL snapshot taken at the read's start), then — only when something is
owed (`:735`) — one runner turn, `closeAutoCommit(_:takes:)` (`:740-746` → `Operations+Variant.swift:342-373`), which
opens its own write transaction and re-checks ONLY the listed takes.

**Which writes can commit between the read's snapshot and the runner turn's transaction, for this note's takes:**
- **the sync engine's apply** — it writes through the database WRITER directly, never the runner
  (`AppDatabase.applyingRemote`, `Persistence/AppDatabase.swift:339-353`, called at `Sync/SyncEngine.swift:1008`; the pull's
  staging at `:676`): a remote `working_text`, a repair, and **the S5 rescue** — a pull meeting her not-yet-pushed row
  leaves the server's text on the row and moves HER words onto a new `'conflict'` take (SyncSpec §5/§6), a take never
  savepointed;
- a runner turn queued ahead of the leaving's (the runner runs one body at a time, `Shared/OperationsRunner.swift:17-31`)
  that names this note — on the phone only an act from ANOTHER screen, such as the shared structural undo stack's door
  on a different note, pressed inside the gap;
- another tab's editor of the same note — only after a tab switch, her typing and its 500 ms debounce, so never inside a
  gap of milliseconds; and that note is shown again, so its own leaving owes it.
- **Never her typing in the screen she left:** teardown's flush and the branch's flush land it in the same task before
  the read, and the screen is gone.

**What the old code guaranteed.** One write transaction on the runner decided and wrote (`closeAutoCommit(_:)`,
`Operations+Variant.swift:311-320` → `autoCommitDirtyVariants` `:441-464`): every write committed before that transaction
began was seen — an apply holding the writer when the turn asked (the turn waited behind it), and runner turns queued
ahead. A write committing after it was missed then too. So the old visibility point is the runner turn's transaction
start; today's is the read's snapshot — earlier by the read's own time (~6 ms at 100k words, Mac, headless) plus, when
something is owed, the runner hop and any wait for the writer. The gap is wide only when the writer is busy at the
leaving: a pull applying.

**Each arm, in both cases:**

| | Something owed (she edited) | Nothing owed (she only read it) |
|---|---|---|
| Old (pre-VM-71) | sees every write committed before the turn's transaction | the same — the turn always ran |
| (a) as built, comments corrected | writes each listed take still owed at the turn, holding its text then; a take only another writer dirtied after the snapshot is not written by THIS ask — it stays owed (its text differs from its last savepoint), and the next ask's read lists it. On the Castle and lock roads that ask comes in the same leaving (`mobileWillLock`'s, inside `runWillLock`, while the store is open); on the pop road it is the note's next leaving on this phone. The S5 case: her edited take is written holding the server's text the rescue left on it; her words, on the new conflict take, are kept by S5 as a live, synced take and are savepointed at the next leaving | no runner turn; a write after the snapshot is the next leaving's |
| (b) the turn re-reads and writes the union | the turn runs the candidates read inside its own transaction and writes the union, each take re-checked — it sees exactly what the whole op would see at the same moment (the old point, restored), her words on a conflict take included. (Since that read is a byte superset and every listed take still owed is in it, the union IS the in-turn read; the first read only decides whether to ask.) | **unchanged from (a):** no turn runs, so no transaction can re-read. Closing it needs a runner or writer turn on every leaving — the 6C/1D cost this unit removed |

**The cost of (b), measured by batch 7's own headless method** (`VARIORUM_VM71_MEASURE=1 swift test --filter
LeavingSavepointMeasurementTests`; the Mac, Debug, an encrypted on-disk WAL store, one note of 1,370 blocks / 131,520 words,
every take savepointed once; n = 5 per series; three calm runs, load averages 8–14; median (min–max)). A new gated series
emulates (b)'s turn exactly — the read inside one write transaction, then the union re-checked and written, as
`closeAutoCommit(_:takes:)` re-checks — beside the existing series in the same runs:

| Series | run 1 | run 2 | run 3 |
|---|---|---|---|
| (b)'s runner turn, one take edited | 12.84 (12.34–13.41) | 12.40 (12.33–13.32) | 13.55 (13.33–14.01) |
| today's runner turn, one take edited (`closeAutoCommit(_:takes:)`) | 1.07 (0.95–1.16) | 0.98 (0.95–1.02) | 1.06 (0.99–1.12) |
| the read alone, inside a write transaction on the writer | 11.69 (11.00–12.03) | 11.13 (11.06–12.12) | 11.75 (11.72–11.96) |
| the read alone, on a reader (today's) | 5.97 (5.89–6.08) | 6.00 (5.84–6.05) | 6.09 (5.78–6.49) |
| the pre-VM-71 whole op, one take edited | 211.30 (210.46–214.36) | 210.56 (209.98–211.88) | 211.77 (210.24–220.28) |

So (b) adds ~11–12 ms of O(note) work to the runner and the writer on every leaving of a 100k note she edited — the same
read costs about twice as much inside a write transaction as on a reader — keeping roughly 94% of 1D's win (211 → ~13 ms
instead of 211 → ~1 ms) and making the runner turn grow with the note again whenever she edited. On the simulator the
edited leaving's runner hold (6.71 ms, the AFTER table's run 2) and the box's first save behind it (7.83 ms) would each
grow by about that much — an estimate, not a stage number; on her phone, unmeasured. A Mac number, never a phone number.

**Recommendation: (a).**
1. The gap never admits her own words on this road (the flush lands them first, in the same task, and the screen is
   gone). It admits another device's writes through sync, and her words only in the S5 case — where S5 itself is what
   keeps them, as a live synced take, and the next leaving savepoints it.
2. The occasion's rule is one savepoint per take she edited in the session that ends ("one quiet savepoint per edited
   take when the note stops being shown anywhere", OverallModel §3): (a) writes every such take at the turn. A remote
   edit's savepoint belongs to the cadence of the device that made it; the old road caught one only when the apply
   happened to commit before its turn — a write a millisecond later was missed then as now. That is timing, not a
   guarantee the spec names.
3. (b) buys the old point back only when she also edited, at O(note) on the one serial runner on every such leaving —
   the class 1D removed — to cover a gap that needs a pull applying to that very note within milliseconds of her
   leaving; and the read-only case keeps its gap under either arm.
4. Under (a) the consequence is bounded and can be pinned: the take stays owed and the next ask writes it. Nothing of
   hers is ever lost; the text is in the store and syncs.

**The pin, per arm.**
- **(a)** has no red-on-old pin — it fixes no bug; the narrowed point is the design, said honestly. I propose one
  headless GUARD of the bound in `LeavingSavepointTests`: the read lists the one edited take → a direct `UPDATE` dirties a
  second take (as an apply writes) → `closeAutoCommit(_:takes:)` with the read's list writes the edited take only → the
  next read lists the second → the next ask writes it. Green by design (new API), named as a guard. With it, the
  corrections: the branch's comment (`AppSession.swift:711-714` — "anything that landed between two asks … exactly as
  before" — rewritten to name the gap inside one ask and what bounds it), `closeAutoCommit(_:takes:)`'s doc
  (`Operations+Variant.swift:330-334` — the rows equal the whole op's when the list covers the dirty set AT THE TURN; a
  take another writer dirtied after the read is the next ask's), and the record: §7 batch 7 ▸ hazard (b)'s "nothing can
  go stale" (true across asks, not inside one), D-7-1, and the hazard (a) table's pop row.
- **(b)**: the reviewer's race pin, hosted (`MobileLeavingSavesOnceTests`' world): edit take 1 and let it land, hold the
  writer with an uncommitted `UPDATE` dirtying take 2, leave (the read runs, lists take 1, the turn waits on the writer),
  release after the read has returned, and the leaving must still savepoint take 2 — red on this tree, green on the
  pre-VM-71 tree (`vm64-b7r1-red` holds those four production files) and on (b). Beside it a headless Core pin of the
  op's new contract: the list `[take 1]`, take 2 dirtied after the read, `closeAutoCommit(_:takes:)` writes both — red on
  this tree, which I would run red and green myself. (b)'s code: the in-turn read inside `closeAutoCommit(_:takes:)`
  (the Mac's `closeAutoCommit(_:)` untouched), its doc and the branch's comment, the gated series kept as its cost.

The measurement series behind the table is committed after this section as a test-only, gated instrument
(`LeavingSavepointMeasurementTests`' `union-turn-one-edit` and `read-on-writer-clean`), so the numbers reproduce from
the repo whichever arm is chosen.

### 2 · [MINOR] a screen shown again before its leaving finished never re-observes — AGREE; applied this pass, in the shape below; VM-227 NARROWED, not closed

**Traced as written.** Cover → `onDisappear`'s task: `teardown()`, whose last lines stop observing
(`MobileEditorViewModel.swift:406-409`), then the savepoint, then `releaseAutosaveHold(ifNotShownSince:)` (`:337-341`),
which gives nothing back when the screen arrived again. Re-show → `.task` → `takeAutosaveHold()` (`:307-332`) returns at
`guard !holdsAutosave` (`:309`), before the re-observe (`:322-331`).

**The shape, and why not the literal hoist.** Moving the `if autosaveToken == nil { … }` block above the guard would
break the re-acquire path the r1 pins hold: it would observe the coordinator the editor GAVE BACK, then the adopt branch
(`:313-321`) would stop that very token and nil it, leaving the adopted coordinator unobserved
(`MobileNoteHoldTests.aScreenShownAgainAfterItsLeavingTakesTheHoldBackAndIsWiredToIt`). So: the guard's early return
becomes `if !holdsAutosave { … }` around the re-acquire, and the re-observe block, unchanged, runs after it on BOTH paths.
The reviewer's intent exactly (it is idempotent — it observes only when no token is held — and reads `autosave` at use
time); nothing else in the hold's lifecycle moves; batch 2's fence untouched.

**Pin:** `MobileNoteHoldTests.aScreenShownAgainBeforeItsLeavingFinishedListensToItsCoordinator` — the parked-leaving
posture of the suite's own `aScreenShownAgainBeforeItsLeavingFinishedKeepsItsHold` (the store held, so the leaving waits
in its savepoint after teardown ran), the screen shown again, the store released, the leaving ends: the editor still
holds AND observes, and what it observes is the registry's coordinator for the note. Red on the pre-fix
`takeAutosaveHold` (the red build `vm64-fix-red`: this pass's tree with that one function as it was), green on the fix.
Hosted — the stage runs it.

**What it closes, and what it does not — the VM-227 question, by trace.** The roads where a note screen is covered and
shown again with the SAME model are pushes on its own stack — Note ▸ Versions (`onOpenVersions`) and the diverged copy's
landing (`onOpenNote`, R67) — then Back (`MobileShellView.swift:476-483`). A tab switch is not one: the band keeps every
page mounted and only offsets it (`MobileShellView.swift:10-15`, `:326-335`), so no `onDisappear` fires; a sheet is not
one either. On the push-and-Back road, by when the re-show lands against the cover's leaving:
- **after the leaving's give-back** — the ordinary case, a push and Back take most of a second, the leaving
  milliseconds: re-observed since batch 6's r1 (`takeAutosaveHold` re-acquires and observes). VM-227's text ("nothing
  adds it back when it shows again") describes the tree before r1.
- **after teardown, before the give-back** (the leaving parked in its savepoint: the read, or its runner turn behind a
  busy runner or writer): re-observed by THIS fix — the pin above.
- **while teardown itself is still suspended** — her keys pending at the cover, so `finish()`'s flush (or the tail's
  mint settle, or a pending gesture) outlasts the push and Back behind a busy runner or writer: **NOT re-observed.** The
  re-show's `takeAutosaveHold` finds the token still set and does nothing; teardown's last lines then remove it; the
  give-back is skipped (shown again). The screen holds and does not listen until a full leave-and-return.
So VM-227 is **narrowed, not closed**, by this fix. The one shape I traced that closes the last road too: at the leaving's
last act, when the screen arrived again (`arrivalCount != arrival`) and no token is held, re-observe — one conditional
in `releaseAutosaveHold(ifNotShownSince:)`. It changes the leaving's half of the lifecycle, outside this fix's fence, so
it is NOT applied; offered for the reviewer's call (its pin: the same suite, a re-show while teardown's flush waits on
the held writer with a key pending — red on this pass's tree).

### 3 · [MINOR] `TimingRecorder.end` marks the record changed on a no-op — AGREE (pre-agreed at the midpoint); applied this pass

`end(_:countingUnmatched:)` (`Diagnostics/TimingRecorder.swift:309-329`) calls `changed()` on every path. The fix is the
windows' own shape (`openWindow`/`closeWindow`, `:431`, `:442` — `if recorded { changed() }`): the locked body reports
whether something kept changed — a sample recorded, `unmatchedEnds` counted, a stale begin's `abandoned` counted — and
only then is the change handler told. **Pin:** `TimingRecorderTests.aNoOpEndIfOpenLeavesTheRecordUnchanged` — after a
save, an `endIfOpen` with nothing open tells the handler nothing and leaves no unsaved change (red on this tree); guard
arms in the same test: an unmatched `end`, a stale end and a recorded end each tell it once per save. Headless — run red,
then green, by me.

### 4 · [MINOR] the batches 6+7 combined walk is owed — the orchestrator's (queued on the stage); nothing in this pass moves what that walk exercises.

### 5 · [NIT] `surfaceSettled()` is `mutating` and reads like an event — AGREE (pre-agreed); applied this pass

`mutating` dropped (`Domain/StructuralFlightFence.swift:94-96`) and its doc says it is a QUERY ("whether a drain is
owed now"). The name stays: its one production caller is in the editor seam (`MobileEditorViewModel.swift:1341`), and a
rename there buys no behaviour; the call sites compile unchanged. No pin (cleanliness); `StructuralFlightFenceTests` green.

### 6 · [NIT] the round's "sent" under-reads under a mid-round burst — AGREE; applied this pass

Said where the series' meaning lives — the catalog line (`Shared/AppTiming.swift:86-88`, the one place every mark's
meaning is written) and the clamp (`syncRoundEnded`, `:385-390`): the count is the outbox's drop, so rows queued during
the round are subtracted from it, and a burst of writes mid-round under-reads it, down to 0. Comment only; `SyncSession`
untouched. No pin.

### 7 · [NIT] FOR A LATER READER is a placeholder — the closeout's; finding 1's comment and record corrections land with the arm the reviewer picks (the second turn).
