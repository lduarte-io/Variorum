# 18o LADDER — ROUND 1 (cold review, fable-reviewer, 2026-09-30)

**Reviewer:** fresh `fable-reviewer`, `notes/REVIEW_PROMPT.md` verbatim ({PHASE} = 18o), zero framing.
**Range reviewed:** `044a6bb0^..HEAD` — the WHOLE phase (U1–U6). The brief named `cf887299..HEAD`,
whose base is U1's adjudication commit, so U1's own code diff sat outside the named range; it was
reviewed anyway (finding 3). No plan-time "Review foci" section exists; the per-unit adjudications'
"FOR THE FABLE LADDER" lines were treated as mandatory foci — each is addressed by name below.
**Canon read this round:** CLAUDE.md + auto-loaded canon · the plan file WHOLE (all six unit
records + adjudications) · `notes/SyncSpec.md` IN FULL (U6 touches `Sync/`) · the pre-13x postures
design's §13 sweep table + `PostureSwitch.swift` step 1 (the U5 item-1 dismissal's sources) ·
KnownIssues rows 54/55/64/66/73/78/79/84 · QUESTIONS #160–#165. TEXTKIT2_NOTES not required —
verified the diff touches no `EditorTextView`/`BlockRangeIndex`/`PaneSurface`/read-tier file
(`EditorSurfaceController`'s `.merge` arm is the named in-scope pair).
**Runs by this reviewer (all green):** core `swift test --filter
SampleLibrarySignedOutRetirementTests|SampleLibraryDedupeRepairTests` → **21/3**; core
`ShelfPinsSelfHealTests|BoundarySnappingTests|SegmentationLineEndingTests` → **52/4**; Mac
suite-level `-only-testing` over the phase's fifteen new/extended suites (OpenStripMenu ·
MergeCeremonyDoorAuthority · CaptureMicrosyntaxLineEnding ×2 · BookLeavingSavepoint ·
CompareLeavingSavepoint · BookLeavingRegistry · BookNoteTrail · WordsCopyDoor · PostureSwitch ·
LaunchSeedTombstone · CRLFImportDoor · BackupFutureStamp · CapabilityRegistry ·
TrayArchivedTruncation) → **138 tests / 15 suites passed** (one run, zero instances by PATH before
it, her app untouched).

---

## FINDINGS (severity-ranked)

**[MINOR] · `Sources/VariorumCore/Sync/SampleLibraryDedupe.swift:304-307` · The new leg's doc
claims a shield that does not cover its road** · The doc says *"A copy that itself arrived this
batch never reaches here (the F2 quiescence arm above defers the whole pass first)."* That is
false as written: the F2 arm (`copies.contains(where: touched.readingIDs.contains)` →
`setSampleDedupePending`, :239-242) sits AFTER the `copies.count == 1` early return (:224-227),
so on the single-live-copy road an arrived-this-batch copy goes straight into
`retireSignedOutCopyIfOutranked` with no deferral. The road is in fact shielded by the
never-accepted guard alone: every row a pull applies gets `recordSeq` inside the same apply
(`SyncEngine.swift:534/544`), so an arrived-this-batch live copy always has `knownSeq > 0` and
the `knownSeq == 0` guard (:328) declines. Behavior is therefore SAFE today — but in `Sync/` the
doc is the next toucher's map, and a toucher trusting "F2 defers first" could move or weaken the
seq guard believing a second net exists. No pin possible (doc-only; the behavior is already
right). **Fix:** reword the parenthetical to name the true shield — an applied row always
carries a recorded seq, so the never-accepted guard is what excludes arrived-this-batch copies
on this road.

**[MINOR] · `Tests/VariorumCoreTests/SampleLibrarySignedOutRetirementTests.swift:175-176` + the
U6 record · A named mutation that was never run: the restore guard's teeth are undemonstrated** ·
The test doc-comment for `aCopyRestoredAfterTheDeletionIsNeverTakenByTheOldTombstone` says
"M-noSeqGuard is its teeth", but no M-noSeqGuard run exists in the record (LIVE STATUS names only
M-always and the wide-comparator measurement). Traced: NEITHER recorded mutation reds this guard —
under **M-always** (skip classification, seq guards kept) the restored copy's `knownSeq > 0`
declines before classification is reached (green); under **M-wide** (`deadSeq > liveSeq`) the
restored copy's seq exceeds the old tombstone's (green). So the one guard protecting the
deliberate-restore corner is green-on-both-trees with no demonstrated ability to fail — exactly
the class the phase's own practice (P34's M-exact precedent; P-7's red-on-old absolutism) exists
to prevent, on a `Sync/` diff. **Fix:** run the named mutation once (drop the two `knownSeq`
guards at :328-331) — expected: the restore-guard pin reds (the from-scratch device retires the
restored copy) — record the count in the U6 record, restore clean; or, if not run, correct the
test doc-comment so it stops claiming teeth that were never shown.

**[MINOR] · process/record — the ladder brief's range vs. the plan's own rule** · The round's
brief named the combined diff as `cf887299..HEAD`; `cf887299` is U1's ORCHESTRATOR ADJUDICATION
commit, so U1's code diff (`044a6bb0..cf887299` — 22 files: the backup/Data Safety family, shelf
pins, the tray, the capability registry, BoundarySnapping doc) is outside the named range, while
the plan mandates ONE ladder over the phase's combined diff and U1's adjudication parks three
foci explicitly "FOR THE FABLE LADDER". This round reviewed the full phase range, so no coverage
was lost — but the record must say so, or round 2 (re-reviewing fixes against "the" range) and
the closeout inherit a mis-scoped base. **Fix:** this file records the true range (header);
the ledger row 18 / round-2 brief should name `044a6bb0^..HEAD` (or per-unit ranges) rather than
`cf887299..HEAD`. No code change.

No BLOCKER and no MAJOR findings. Nothing in the diff tracks word-level change, copies text
across entities, or scales with corpus size (the two new repair legs and the pin heal are all
∝ batch/pins — P1 checked per file below).

---

## THE NAMED LADDER FOCI, EACH ANSWERED

- **U6 — the narrowed guard's structural claim** (*"a meeting's keeper has always pushed —
  refute it if you can"*): attempted refutation FAILED; the claim holds structurally. For the
  new leg to fire, the live count must be exactly 1 and the live copy never-accepted. A
  never-accepted local copy is invisible to every other device, so an arriving same-name
  tombstone is always a FOREIGN copy's; and any live foreign keeper arrives in the SAME
  to-head pull (`pullIgnoringMarker` fetches the changefeed to head and applies in ONE
  transaction), making the count 2 and routing to the pair pass. The only way the count stays 1
  with an accepted dead arrival is every foreign same-name copy dead on the account — which IS
  the ruled retirement shape. Confirmed also that the real first-sync order matches the pin's:
  `SyncScheduler.runOneRound` is pinned pull → push (A3), and `VaultBootstrap` pulls before
  pushing, so the copy cannot be accepted before the tombstone can arrive.
- **U6 — the `tombstonedParents` arm:** reachable only where this store saw the foreign copy
  live earlier AND its own copy is still never-accepted (every push failed/refused since
  seeding) — rare, correct to include, same guards; harmless.
- **U6 — indeterminate-declines-permanently:** err-toward-keeping, no marker re-arm; consciously
  recorded; the state is barely reachable for a locally-seeded copy. Acceptable under
  PROVISIONAL #146 (hers).
- **U6 — the A5-band corner:** recorded in the leg's doc as the ruling's accepted (i) outcome;
  correct.
- **U6 — the #143(b) defense untouched by construction:** VERIFIED — `recordSampleCopyKillEvidence`
  resolves an arriving tombstone only to a LOCAL LIVE same-name copy (`Reading.fetchOne` on the
  phone returns nil for the Mac's ids; the Mac never saw the phone's copy live, and the phone's
  retirement rows arrive there already dead), and a self-retirement never passes
  `writeResolvedRow`; the defense suite rode unmodified and green (my 21/3 run).
- **U5 — the item-1 dismissal, re-verified cold (it decides a ruled row):** CONFIRMED at the
  sources. `RekeyRecencyProbe` has exactly one consumer (the U5 pin — grep over Sources+App);
  the pre-13x design's §13 sweep table (line 1998) records the UI caller as *"already gone
  (2b/3b) … retired at 2b"* with the in-place reason; `PostureSwitch.swift` step 1 drains
  (push, then `pullToHead`, ≤3 rounds, refuse on a non-empty outbox) and refuses a
  rotation-in-progress, then step 3 re-encrypts the SERVER's own rows via `sync_reencrypt` —
  no road writes local content over server rows (`truncateAccountData` has no app caller;
  `adoptLibrary` is additive). The GREEN documented-behaviour pin plus M-noPull's
  server-half-green are the right evidence shape; DISMISSED-AS-HOLLOW is the correct
  disposition, and the ruling's closure is properly hers (#164).
- **U5 — the five-screen widening:** verified all five Mac words screens compose the ONE
  `WordsCopyDoor`; the hoist is statement-for-statement the pane's old closure (clear, one-line
  write, `changeCount`, conditional clear at 60 s); no second timer exists; the shared faces'
  door is `#if os(macOS)` so the phone's rendering is unchanged. Correct breadth — her ask's
  own words.
- **U5 — #165 weighed (Universal Clipboard, now five screens):** recommendation recorded —
  option (a) `currentHostOnly` is one line in the one rule and makes the 60-s promise cover
  every copy that exists; but decision 23 as built is RULED behavior and the change is a
  product/security call, so QUESTIONS #165 (which already recommends (a)) is the right home.
  Nothing to build in-round; her bundle carries it.
- **U4 — judgment call 5** (leaving-the-book includes "Open in the full editor"): benign — the
  savepoint is of just-flushed text, dedupe-able, and C1's generation guard keeps the receiving
  pane's own entry. **Call 8** (a swapped-out peer's entry retires only at board close): the
  safe side — an entry kept, never dropped early. **Call 12** (an Index re-entry cache hit can
  cost one extra quiet savepoint at the Index's close): dedupe-bounded, nothing can be lost.
  **NOTICED 1** (the Outline's stale focus after an Index excursion): pre-existing, correctly
  read as a move-back under the trail's rule, owner assigned.
- **U3 — the row-13 divergence + the retired fallthrough's reachability:** `openMergeCeremony`
  has exactly ONE caller (grep re-verified this round); the divergence (the open's post-flush
  read is the door's one authorization; unfanned → `mergeCeremonyNeedsAFan`, never the instant
  merge) is the right design under P-2 and P27's rule, with both directions pinned and per-half
  mutations. **The confirm-time fallback** (`runCarryAllMerge`'s unfanned arm after a fan
  vanishes between open and confirm): correct as it stands — she confirmed a MERGE, and the
  instant merge is the merge of what is there; the ceremony sheet's own confirm road refuses
  through the op's I10-at-birth family instead. Not a defect.
- **U2 — judgment call 7's early-decision arm** (declining an account-owned store BEFORE its
  first round when the tombstone is already local): traced safe — nothing a round could bring
  makes a silent mint right (a restored copy arrives by sync as a live reading, and the
  whole-copy check outranks the tombstone at both reads); recording the decision early is A2's
  own rule. **Call 2** (`one_block` normalizes line endings too): correct — the stored block's
  breaks are the ones the `"\n"`-keyed block brains recognize, pinned as documented behavior.
  **The drafted row-66 wording:** accurate, including the purge residual and the #146 pointer.
- **U1 — the lock-time due-check** (custody-adjacent): only the freshness READ changed
  (`newestTrustedBackup`); the WAL/key-file/pair legs are byte-untouched, and the rule's only
  possible effect is MORE copies, never fewer — the data-safe direction. **The weekly-export
  widening** (call 2): the same clock on the same run and pane; one rule is the correct breadth.
  **The 17e(12) source-walk pin tightness** (call 6): deliberate and recorded; a reformat reds
  loudly by design — acceptable as is.

## CLEAN BILL (load-bearing things checked and found solid)

1. **SyncSpec conformance of U6** (read in full): pull-only occasion (`isPullBatch`), repairs
   inside the apply transaction with EXPLICIT outbox rows (§7's rule — pin asserts
   `outboxContains`), one-stamp family retirement through `retireSampleCopy` UNCHANGED, zero
   schema (marker 9), zero server lines, deterministic and idempotent (the pin's
   `syncToQuiescence` dump-equality leg). `knownSeq` is §3's `sync_row_seq` rule verbatim
   (never-accepted ranks 0). The occasion fires on a dead arriving reading (`noteApplied`
   inserts every applied reading row into `readingIDs`).
2. **U6 corner sweep:** deliberate-restore durable on every device (a once-accepted reading row
   keeps `knownSeq > 0` forever); Put back after retirement never re-taken (no new tombstone
   arrival); a renamed-then-deleted account book declines (name mismatch — the safe direction);
   the loser-tombstone-beside-kept-keeper convergence declines (keeper accepted); the
   both-signed-out two-phone case retires each device's own copy and converges; retirement cost
   ∝ batch (the leg is two indexed reads until the genuine scenario).
3. **U5 item 2 mechanics:** `WordsClipboard.copy`'s changeCount guard means a later copy of hers
   is never erased; the pins drive the composed door against a PRIVATE pasteboard; M-receipt
   proves the door reaches the face's own `markWordsCopied()`; `PhraseOnlySheet`'s receipt is a
   pure function of its inputs, reset per mint; `KeyDoorView`'s caption branch outside the
   `#if` stays permanently false on the phone (the flag is model-side).
4. **U4's machinery discipline:** zero `AppSession`/`Operations`/editor-seam/`Sources/`/mobile
   lines (fence verified against the diff); roads 5–6 are thin weak-session closures onto the
   ONE `savepointOnLeaving` entry; `BookNoteTrail`'s table is right on every traced edge —
   `.live` same/different, `.selected` same/different (kept-memory on same), `.empty` inert
   (including the measured Outline→Index empty frame — M-empty's evidence), `leaveBook`;
   the never-committed-take consequence is `closeAutoCommit`'s standing rule, honestly stated
   at #163; C1's, L-d's and J11's suites have zero diff and ran green in my 138/15 run.
5. **U3 row 73:** keys only within `ordinalCap` (9); the ONE `Character` conversion sits in the
   menu's own extension; every row acts by the id it names (P-2 — the second found defect's fix
   verified in `openStripRow`); the ⌘<n> sibling is capped by a closed enum of seven and pinned
   (`theModeKeysCanNeverReachTen`); no other `KeyEquivalent(Character(…))` construction exists.
6. **Row 12b:** rule 0 runs before the no-brace fast path (M-afterfast pinned the placement);
   U+2028/2029/0085 stay content; `normalizedLineEndings` is the segmenter's own public body,
   byte-unchanged, its two steps in `PlainPaste` rule 1's order with a correct UTF-8 byte fast
   path; the only two production callers of `CaptureMicrosyntax.parse` are the two Mac capture
   doors (grep re-verified).
7. **U2 P23:** normalize-at-entry over `isNewline` is the right family split — verified
   `NewlineSplitting`'s doc and the M-isNewline evidence (the idle mint would have split a
   typed Control-Return); `crystallizedBoundary` byte-untouched; the phone inherits through the
   shared op.
8. **U2 row 66:** ONE predicate (`readerDeletedTheBook`) read by the ensure and both launch
   deciding reads from one read transaction; whole-copy-first ordering (a deleted-then-restored
   book stays `.alreadyPresent`); the decision recorded through the launch's own injectable mark
   leaf; the explicit doors byte-untouched and pinned as guards.
9. **U1:** row 84's one trusted-stamp rule at all four due-checks and the face — never deletes,
   forced runs untouched, C7's own-names pins unmodified; P35's pin-needs-live/unpin-never with
   the value-guarded no-op and a heal ∝ the pins (`setting` stays server-wins CAS metadata,
   zero `Sync/`); P37's marker mirrors the deleted marker's condition; 17e(12)'s registry gate
   preserves the old `session == nil` half through `enabled()`'s nil-router false.
10. **Verification this round:** 21/3 + 52/4 core and 138/15 Mac — every new suite green on the
    final tree; the record's counts (U6 21/3; core arithmetic 1747→1751/184) are consistent
    with what ran here.
11. **QUESTIONS #160–#165** landed as written, tail marker #166; the closeout obligations
    (KnownIssues rows 54/55/64/66/73/78/79/84, the 17-file copies, the MOBILE PARITY line with
    U4's OWED phone-trace) are drafted-and-pending at ledger row 19, which is the correct state
    at this point in the phase — nothing owed by a unit is silently missing.
12. **Scope fences held everywhere:** zero editor-seam files (the `.merge` arm named in-scope),
    zero schema/migrations, `Sync/` touched only by the pre-authorized U6 leg, zero commit
    trailers (spot-checked messages across the range).

## DISPOSITIONS (filled after the cross-model exchange / orchestrator arbitration)

- Finding 1 — (pending)
- Finding 2 — (pending)
- Finding 3 — (pending)
