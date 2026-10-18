# VX-348 — Ladder round 1 (cold review, Fable at xhigh, 2026-10-18)

**Scope reviewed:** the run's whole diff — `git diff e6874b1d8..HEAD` in `~/dev/variorum-vx-348`
(124 files, +9,541/−305; the merge-base math over the two folds verified). Read in full: the run
record (`vx-348-prelaunch-sweep.md`, 2,423 lines), `notes/MCPSpec.md`'s changed clauses against the
whole file, every product-source hunk, the justified test edits, and the key pin suites. Spot-run
headless (allowed, no stage): `StoredTextTests` · `StoredTextNullStripTests` ·
`MCPOneGrantPerPlaceTests` · `TimeStampFaceTests` · `MCPListWingsServerTests` ·
`MCPConnectionEndServerTests` · `MCPNullCharacterServerTests` · `MCPWriteDigestServerTests` — 64
tests, all green on the tip. VX-357's factual premise verified at the cited line
(`.build/checkouts/GRDB.swift/.../StandardLibrary.swift:625` — `sqlite3_bind_text(…, -1, …)`).
VX-338 (the member her word names for this reviewer) read with particular care — its section leads
the clean bill.

**Fence check (mechanical, whole diff):** zero lines under `Sources/VariorumCore/Sync/`,
`Protection/`, `Server/`, custody/Keychain; zero `EditorTextView` / `BlockRangeIndex` /
`PaneTextAuthority` lines (the VX-357 editor-seam divergence was correctly fenced OUT and ticketed,
VX-395). No commit in the range carries an attribution trailer. The v1_30 migration is local-only
(no `sync_version`, no trigger, marker 13 untouched) — verified in `Migrations.swift` and
`MCPGrantSchema.swift`, with the index created AFTER the merge.

## Findings

- **[MINOR] · notes/plans/fixes/vx-348-prelaunch-sweep.md §W2-1 · two proof legs are still owed at
  ladder time · the new pin `VX351BookBoxStampsTests` (commit `77c8f7f16`, test-only; both u4
  products rebuilt) has NOT yet run its red/fixed legs, and the walk's W2-1 re-check (the AX
  discriminator with the info panel as control, plus the ⌘S receipt-band capture) is open — so one
  walk finding (no live tooltip on the book box's stamps line, three dwells, while the panel's
  rendered under the same method) is argued-by-reading but not yet discharged · evidence: the U4
  record's own W2-1 section and LIVE STATUS ("PENDING: W2-1's one-suite red/fixed run and the
  walk's W2-1 re-check") · fix: run both before the closeout claims U4 whole; if the AX pair shows
  the panel answering and the box not, it is a real VX-351 gap at the sidebar host and returns to
  the implementer (the record's own routing). No code change owed by this finding itself.*

- **[MINOR] · App/Variorum/Variorum/Features/BookView (BookView's `hostsQuietReceipt` wiring, read
  via the U4 record's traced gap) · Index with a LIVE block has no visible quiet-receipt home ·
  mechanism (the record's, re-read in `BookNoteBox.quietReceiptHome` usage): Index's live box is
  bar-less (one block's `PaneTextAuthority` pane, no `EditorViewModel`), `quietReceiptHome`
  answers `.liveNoteBox`, and the Index column footer's line stands at opacity 0 — a receipt
  spoken while an Index block is live (Arrivals Add/Dismiss, Remove/Release) speaks nowhere under
  quiet: the VX-385 class on the book surface · PRE-EXISTING, not this diff's regression (the
  routing predates the run); the U4 record already names it "a ticket candidate, not this unit's" ·
  fix: the closeout MUST mint that ticket (Bug · Confirmed · Books, Low/Medium) so the trace is not
  lost; no fix in this run.

- **[MINOR] · worktree state · `App/Variorum/Variorum.xcodeproj/.../Package.resolved` sits modified
  and uncommitted in the run worktree (xcodebuild auto-resolve churn — the U3 record's own note
  says it is "never staged") · evidence: `git status` at review time · fix: `git checkout --` it
  before the merge ask so the merged tree carries no accidental dependency-pin change; verify the
  committed copy matches main's.

- **[NIT] · App/Variorum/Variorum/Features/BookView/BookArchived.swift:~309,
  BookArrivals.swift (the twin line), Features/Timeline/TimelineView.swift:~322 · three speakers
  bypass the one no-hover idiom with `.help(wholeFact ?? glance)` · the U4 record states "ONE
  modifier says 'no hover' (`Core/Views/StampHelp` — no tooltip at all, never an empty one)", but
  these three fall back to repeating the glance words as a tooltip when the whole fact cannot be
  spelled (an unparseable stamp — synthetic only, so no pin could bite; labelled honestly:
  cleanliness, not a bug) · fix: route through `.stampHelp(...)` at the next touch.

- **[NIT] · Sources/VariorumMCP/MCPNullCharacters.swift:41 (`count(_ document:)`) ·
  `fallbackTitle` is counted alongside `parsed.title` · today every wire road builds
  `NamedDocument(fallbackTitle: "", …)` (verified: MCPWriteTools.swift:353/391,
  Operations+MCPWrites.swift:446/497), so the count can never over-report — but a future road
  passing a non-empty fallback while the parsed title wins would count a null in text that is
  never stored · fix: a one-line comment or counting only the title that will be stored; no
  behavior change today (hence NIT, no pin possible).

- **[NIT] · Sources/VariorumMCP/MCPSession.swift (`claimEndLine`'s `awaitingKey == nil` guard) vs
  P-VX394-6's wording · P-VX394-6 says "a pending connection request's end is logged too (it named
  itself)", while the claim guard excludes any connection whose key still waits (`awaitingKey !=
  nil` — the VX-258 waiting-setup state), which also carries a name · the two states (an
  unknown-name connection request vs a known name's key-wait) may genuinely differ, but the
  provisional's sentence doesn't distinguish them · fix: one clarifying sentence in the QUESTIONS
  bundle so her ruling lands on what is built (which connections with a name get no line).

**No BLOCKER. No MAJOR.** Every bug-class fix in the diff carries a red-on-old pin whose red leg is
recorded as run (the batch records, per unit, with exact expected-red counts and premise-failure
discipline), except the one named above (VX351BookBoxStampsTests — built, not yet run). The two
U5 "hollow halves" (an empty book granted alone; the non-empty wing road) are recorded as hollow,
not fixed — the hallucination guard applied correctly.

## Clean bill — checked and found solid

1. **VX-338 (the Fable-named member) — the deletion-safety argument HOLDS, re-derived
   independently.** The far folder's ONLY retention deletion is `pruneSecond` →
   `removeSnapshotPair` over `BackupRetention.prune(candidates, policy:, ownedBy: own)`, and the
   pure rule filters candidates to `own.contains(lastPathComponent)` first
   (BackupRetention.swift:133) — `doomed ⊆ own` by construction, pinned
   (`theOwnSweepNeverReturnsACopyThatIsNotOwn`). A name enters `own` at exactly ONE site:
   `performSecondLeg`, immediately after THIS Mac's `copyItem` succeeds (StoreBackup.swift:414).
   The other flat prunes (`prune(directory:keep:)` at :621 and :714) run only on the in-container
   `Backups/` folder (verified at both call sites, incl. VariorumApp.swift:270-277's lock-time
   directory) — per-Mac by location. Pre-fix copies are on no list → never deleted (pinned,
   `copiesWrittenBeforeTheFixAreNeverDeleted`, red leg ran at the batch 4/5 + guard). Failure
   modes all fall toward KEEPING (list lost → nothing deleted; unreadable folder throws before the
   defer registers; a throw mid-sweep rewrites the list to the own copies left; an iCloud-evicted
   own copy leaves the list and is thereafter never pruned — a keep-direction leak the record
   already names). The pre-existing same-name replace in `performSecondLeg` (removeItem+copyItem)
   is the one non-retention deletion and is unchanged, and a same-name collision requires the same
   fingerprint in the same UTC second. The chosen third form (device-local list) vs the brief's
   two: the argument that both named forms leak past the two-file fence checks out against the
   named readers (`BackupRestoreCandidates.backupDate`, `LibraryClassifier.backupNameFingerprint`,
   `PostureSwitch`'s flat listing). The pins exercise the REAL `performRun` road with two defaults
   domains over one picked folder.
2. **VX-357** — `StoredText` is byte-exact (0x00 occurs in UTF-8 only as U+0000; `String(decoding:
   utf8.filter…)` stays valid), no-allocation fast path; the op-layer sweep covers every
   caller-text write I could enumerate independently (takes/autosave/imports/compound, titles +
   floating notes + references, labels, every name family, tag mints + renameTag + TagPath,
   commit messages via `SavepointName.normalized` at both call sites, comments incl. the undo
   capture, plus the row-level re-strip at `mintBlock`/`mintFanBlock`/`insertPost`/`insertTag`);
   churn counts switched to the STORED text's length (`importDocument`, `insertBlocks`); the
   exclusions (sync apply, client/setup names, JSON columns, preconditions/locators) are each
   argued correctly — a null-holding precondition can never match a stored buffer, so it refuses
   honestly. The wire's count (`MCPNullCharacters`) is an exhaustive switch (no default) at the
   one `land` seam, present only when > 0; `sha256` digests the returned (stored) row by
   construction. 32 core tests re-run green here; the record's red legs verified on a scratch
   pre-fix tree. The found identity/editor-seam/due-check hazards are ticketed (VX-395/396/397).
3. **VX-393** — the one-row rule lives at the ONE mint (`insertMCPGrant`: the standing-row revoke
   on the act's stamp inside the act's transaction, once grants exempt), with the DB-backed
   partial unique index refusing any future road that forgets; the v1_30 merge's rank
   (always → rung → created_at desc → id desc) matches P-VX393-2's argued order and the
   while-connected-rows-are-dead-at-migration reasoning is correct (every server start revokes
   them). Local-only throughout; MigrationTests' index list updated as a named justified edit. The
   downgrade consequence of upgrade-in-place is flagged prominently for her (P-VX393-1).
4. **VX-392** — `list_wings` answers the client's OWN live wing grants only (no oracle: ungranted,
   gone, and book/note-reached wings absent — pinned), rungs/duration read OFF `decideWing` (never
   a parallel rule), counts computed through the same `decide`/`decideGathering` the listings use
   (fenced/archived never count), `grantOnly` keeps the open book from listing a tool that could
   only answer empty (P-2), listing spends no once grant (pinned), cost ∝ granted wings with the
   container scan matching `list_notes(wing_id:)`'s existing shape (the missing wing_id index
   honestly recorded as synced-DDL, out of lane). The docs sweep reaches every wing_id-taking
   tool; the instructions pointer landed at the orchestrator's adjudication (2,994/3,000) with the
   truth pin updated. The two hollow halves recorded, not fixed.
5. **VX-394** — the trace is a definite kill path (Castle's re-lock → detach → EOF → "MCP server
   disconnected"), the ruled-out list is argued per item and no speculative keep-alive shipped;
   the end line is said ONCE whichever road is first (`claimEndLine`'s settle; the lock road
   writes before the store closes via `macWillLock`'s new step, ordered after the leaving
   savepoints; the fix leg makes the line host-lifetime-independent — the session writes through
   its OWN store, and the `else` arm of the serve task covers a dropped host). The door's two stop
   reasons wired (`.serverOff` / `.libraryClosed`); over-limit rides the transport's flag.
   `ProtectionController`/`AppBootstrap` untouched. The author-only lock question correctly left
   to her ("Needs Lillian"); the skipped `endMCPConnectionGrants` on the dropped-host arm is
   ticketed (VX-400) with the exposure argument (the start sweep runs first) checked.
6. **VX-339** — the press now reads the clear's answer; a standing marker keeps the hold, the line,
   and resumes nothing (the gates would refuse anyway); the no-storeURL arm keeps P-U2-2's press-
   still-clears behavior; the seam defaults to the real `LibraryRestoreHold.clear` so every
   existing caller is byte-unchanged; the banner line is line-limited for the minimum-size probe.
   Live-verified both halves in the walk (chflags-held marker).
7. **VX-347** — the leave machinery is sound under the roads I adversarially traced: one settle per
   field (`SavepointNameLeaving` — first report decides; `lastLeft` keeps a late `willClose` from
   re-adopting; ⎋ settles at the field before any closing; the closing classifier can call ⎋ only
   for a fresh ⎋/⌘. dispatched TO this popover's window or its parent, and `NSApp.currentEvent`
   makes a stale-event misfire structurally impossible); every model files `ask.targetID` (never
   the caret/ring at filing time) through the per-press `SavepointAskLedger`, so the model-direct
   road and the presenter's report cannot double-file while two presses stay two commits; Compare
   flushes `ask.context`'s own coordinator; the rename door keeps ⏎-only; all seven hosts compose
   the ONE presenter (verified: no inline field in the book views — no VX-382 rebase owed). The
   flipped pin encodes her ruling and ran red-on-old (13 behavioral reds, zero premise failures,
   the re-batch); the lock-cell fix (counting the lock's quiet AUTO savepoint out) is the correct
   reading of AppSpec §9's quiet occasions. ⌘Q files nothing — recorded (P-VX347-5), the leaving
   savepoint still insures the text.
8. **VX-350/VX-176/VX-349** — the third width class is decided from STABLE widths inside the ONE
   Layout (never ViewThatFits — P-U3-5 held; the field's line is HER state, so typing/searching
   never moves the line count); the whole-point `decidingWidth` makes the sizing and placement
   passes decide identically (the 301.5 case pinned both ways, replicated red on the old rule
   headless); unshown controls are placed outside the row, never squeezed (the Tab consequence
   recorded, P-VX350-3); the panel takes its width first, floored at 200 and never wider than the
   library, the list clips — the walk verified all three widths in both voices. `.tint` at the
   catalog root is the panes' shipped idiom (pinned against both voices × both schemes, red 4/4 on
   old). The header floats only over content (the pure rule + the mounted pixel pin, red 4/4 on
   old); hosts that don't read their scroll keep the shipped face by the environment default.
9. **VX-351/VX-384/VX-385+355** — one stamp brain (`whole`/`tooltip(labelled:)` — a day key spells
   its day, never an invented noon); the 27-speaker sweep table matches the diff's call sites
   one-for-one (I walked them all); the two gap fixes carry justified pin edits that name
   themselves; the fact change (panel: major revision → last touch) and the glance change (note
   box gains today's time) are each PROVISIONAL for her. VX-384 rides VX-231's road exactly (the
   held listing's membership set, order excluded, single-flight re-ask outside the observation's
   turn; `RootView`'s one `LibraryViewModel` verified as the instance the catalog observes); the
   P1 guard is pinned green-by-nature and the out-of-window remainder honestly left to VX-122.
   VX-385's foot composes only while a receipt speaks and the Pool's error does not (the pure
   slot rule + the instance-reading composition pin after the fix leg's honest re-shape); VX-355's
   open question answered by the ruled fix shape, both tickets' cases pinned and live-walked.
10. **Spec alignment** — MCPSpec's trio paragraph + the VX-254 digest sentence match what shipped
    (I diffed the clauses against the code); no surviving MCPSpec sentence contradicts the one-row
    rule or `list_wings`; AppSpec §9's conventions hold across the diff (no-op guards kept, seals
    checked first, touch-without-churn on the structural roads, I10 untouched); S1/S2 untouched
    (the v1_30 merge revokes, never deletes); P1 respected at every new read (hovers are
    per-drawn-row over already-held stamps; `list_wings` ∝ granted wings; the follow ∝ the held
    window). The commit vocabulary (R-13s-31/32) holds in every new string; no shouty caps; no
    literal colour outside the token layer in the touched faces.
11. **Process** — per-piece commits each naming their member and "Part of VX-348", no trailers
    anywhere in the range; red products built from durable checkouts with cmp-verified reverts;
    the one standing headless flake (VX-353's harness timing) correctly attributed each time it
    appeared; the DestructiveUndoWarning red settled by a true discriminator (red on the pre-U4
    product) and appended to VX-167, with the fix-leg's read-only exoneration argued from the
    harness's actual object graph; the ReleaseNotes 0.9.8 section landed on this branch before the
    merge ask, as her release word requires.

**Pending at ladder time (the closeout's checklist, not findings):** the VX351BookBoxStampsTests
red/fixed one-suite run + the W2-1 AX discriminator and ⌘S band capture (finding 1); the QUESTIONS
bundles (P-VX357-1…5, P-VX338-1…2, P-VX339-1, P-VX347-1…5, P-VX176-1, P-VX349-1, P-VX350-1…7,
P-VX351-1…7, P-VX384-1, P-VX385-1, P-VX392-1…5, P-VX393-1…3, P-VX394-1…6) at the merge; VX-394's
"Needs Lillian" lock question; the Index-live receipt-home ticket (finding 2) and P-VX351-4's
raw-day-key words ticket; canon deltas (AppSpec §9's no-U+0000 line, §12's three U4 lines, §7's
v1_30 note, QUESTIONS #121(b) superseded) exactly as the unit records propose.
