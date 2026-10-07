# The Fable sweep review — FINDINGS (2026-08-30)

*Cold Fable reviewer, zero implementation context, run to
`notes/plans/mobile-fable-sweep-review-brief.md`. Everything below was
derived from the repo, the diff, and my own runs — no record was taken on
trust where a command could answer instead.*

**Environment of record:** worktree `~/dev/variorum-mobile`, branch `mobile`
at `18e13a6`. Private simulator `Fable-sweep` (iPhone 17 Pro, iOS 26.2,
`ApplicationAccessibilityEnabled` armed and verified `1`), private
DerivedData under this session's scratchpad; the simulator was deleted at
the end. Working tree left byte-identical except this file (the known
`TK2SpikeUITests.xcscheme` stray untouched).

**Measured suite counts (my own runs, not inherited):**

| suite | claimed | **measured** |
|---|---|---|
| mobile | 582/93 green | **`Test run with 582 tests in 93 suites passed`, 2 known issues** (ONE documented 4.5b diagnostic pin — `MobileTrashTests.anEmptyAccessibilityTreeIsDiagnosedRatherThanReadAsAnAbsentDoor`, whose single `withKnownIssue` block records two; corrected at R2-6, and grep-verified: it is the suite's only armed `withKnownIssue`) — exact |
| core | 1453/154 | **`Test run with 1453 tests in 154 suites passed`** — exact |
| Mac | 1843/312 (unverified since) | **NOT RUN, per the brief's own rule** — see the Mac-suite note below |

**The Mac-suite premise, verified by git rather than trust:** the
five-MAJOR fix round (`6bc4f18`) touches ONLY
`App/Variorum/VariorumMobile/`, `App/Variorum/VariorumMobileTests/` and its
record — zero `Variorum/`, zero `Shared/`, zero `VariorumTests/` paths in
`git diff --name-only 6bc4f18^..6bc4f18`. The claim "no Mac file was
touched" is TRUE. The mobile-side work that DID touch Mac-compiled code
since 13l (PL-10(b): `Shared/BookNameCopy.swift` + `OpsRefusalCopy.swift`;
batch 6a's `Shared/BlockHistoryFace.swift` hoist) each carries its own
recorded Mac run at 1843/312 in `mobile-batch-4.5d-record.md` §2.4 and
batch 6a's review. The only OTHER Mac-compiled deltas since those runs
arrived through the `fa522d6` merge FROM `main` (the 13p-fix keychain
work) — main's work, not this round's, already laddered there. So no Mac
run was owed here; finding 5 records the one docs consequence.

**Hygiene, verified:** `git diff 43a35ef..HEAD` (merge-base..HEAD) touches
ONLY `notes/` files; `git diff -- Sources/` empty; `SyncSchema.lockstepVersion == 7`;
no build-configuration files; `Shared/EditorBrain/` and the cross-block
planner untouched by the round's post-13l commits.

**A limit of this pass, stated up front:** the no-edit / leave-the-tree-
byte-identical constraint means I could NOT re-execute any red-on-old
revert myself. For every pin below, "verified" means: the pin exists, I
read what it asserts, I traced the mechanism it guards independently in the
shipped code, and the recorded failure text is concrete (values, not
adjectives). The one revert-run I could check by ancestry instead of
re-execution (A1's staleness claim) I checked by ancestry.

---

## FINDINGS, severity-ranked

### 1. [MAJOR] · `App/Variorum/VariorumMobile/Features/Takes/MobileLenses.swift:286-302` + `mobile-major-fix-round-record.md` (A1) · A1's class argument has an unclassified falsifier: the lenses adopt door mints an uncaught duplicate row per flight · READ-ONLY

The fix-round record closes A1 with a universal claim: *"none of them can
mint an uncaught duplicate row by the reasoning above"* — and the
architecture review's disposition banner narrows the defect class to *"the
three doors where a second flight mints an uncaught row."* **Both are
falsified by `MobileLenses.adoptView`,** a file the architecture review's
own twenty-file list named (*"`MobileLenses` (5)"*) and the record's
verdict table never classified.

**The mechanism, traced end to end:**

- The door is a persistent plain `Button { Task { await model.adoptView() } }`
  (`MobileLenses.swift:514-516`) — not an alert, not a `UIMenu`, so it does
  not dismiss on tap. It renders while `model.viewDiverges`, which stays
  true for the whole first flight (the peeks clear only at the
  chosen-caught-up self-heal AFTER flight 1's `refreshTakesFromStore()`).
- `adoptView()` captures `picks = displayedDivergences` before its first
  suspension, so a second tap inside flight 1's store round-trip captures
  the SAME non-empty picks and passes `guard !picks.isEmpty`.
- The op beneath, `adoptPicksPreservingChosen`
  (`Sources/VariorumCore/Operations/Operations+Versions.swift:337-368`),
  **unconditionally inserts a preservation `Lens` row** (`preservation.insert(db)`
  at :348, before any pick validation, returned even when `moved` is
  empty). The `lens` table carries no uniqueness. Nothing beneath the door
  can notice the second flight.
- End state of a double tap: **two auto-named preservation lenses** in the
  note's lens list. This is byte-for-byte the class the record itself
  called "defect" and latched at the comments and take-mint doors
  (*"a second take in the fan — the fan is a list; `branchVariant` has no
  arm that could notice"* — substitute lens list for fan).

**Severity, stated honestly (the PL-10(b) calibration applied):** no data
is lost — the harm is a duplicate "Preserved …" lens she must hand-delete,
the same clutter class as the latched branch doors, NOT a data defect. The
MAJOR grade is for the record, not the pixels: the sweep's primary question
was *"is the class argument right?"* and the answer is no — the argument
was applied to the doors the table lists and then stated as covering all
seventeen, while a named member of the review's own list mints an uncaught
row. The record's own hedge (*"that reasoning is a class argument, not
seventeen traces"*) is honest; the universal sentence beside it is not.

**Pinnable red-on-old:** yes, and cheaply — the `MobileWriteLatchTests`
two-concurrent-`Task` shape, asserting one preservation lens after a
double tap; it fails on today's code. **Proposed fix:** adopt the existing
`MobileWriteLatch` at `MobileLensesModel` for `adoptView` (and optionally
`saveIntoActiveLens`, though that one's upsert/clear writes converge and
are outcome-safe). Correct the record's universal sentence and the
architecture review's MAJOR-1 banner in the same commit.

**Doors I checked that do NOT falsify the argument** (so the fix session
does not re-derive them): `saveCurrentView` and `MobileReferences.addURL`
mint unguarded rows but live behind `.alert` action buttons, which dismiss
on first tap — outcome-safe by host; `MobileBlockHistory.commitNow`
appends a savepoint with no dedupe (manual `commit` always inserts —
verified at `Operations+Variant.swift:38-58`) but its ONE caller is a
`UIMenu` action (`MobileBlockMenu.swift:156-158`), which dismisses —
**safe TODAY only by its host; if batch 6b/9 ever gives the Block History
sheet its own commit button, that door needs the latch** (one line worth
carrying into that batch's brief); `MobileScraps.mintScrap` (unguarded
`newBlock`, plus a TOCTOU double-`createPool`) is alert-hosted too;
Block History's restore/unarchive/put-back/Bring-back are idempotent or
refused beneath (placeBlock's I2 index); stars/choose/label/lock are
last-write-wins; membership/tag doors are refused by live-unique indexes —
the table's existing cells are all RIGHT. The hole is coverage, and
`adoptView` is the one live member I found.

### 2. [MINOR] · `VariorumMobileApp.swift:118-130` + `MobileStarterJournal.swift:163-165` · B1's gate composition ignores the A4 fence: a signed-in dev-store launch can never seed and pays the 20 s poll on every empty-store launch · READ-ONLY

`SyncGate.unowned`'s own doc names its intended users: *"The composition
with no account anywhere — **a dev store**, or a caller that has no
services yet."* The call site never honors that intent: it passes the
account-reading gate for every store variant. Mechanism, concrete:

- Debug and Release share a bundle identity and therefore a Keychain
  (`SyncSession.swift`'s A4-fence header states it), so a Debug (dev-store)
  launch on a signed-in device reads `auth.currentUserID` non-nil →
  `account.variorum != nil` → `belongsToAnAccount()` true.
- A dev-store session NEVER configures sync (`allowsSync` false →
  `configure` returns → no scheduler → `status.lastSuccessAt` nil forever,
  verified at `SyncScheduler.swift:200` — set only after a clean
  pull+push).
- So on an empty dev store: `storeIsNew` true → 20 s poll →
  `.awaitingFirstSync`, every launch, forever. The starter Journal never
  seeds on the dev store, and each empty-store Debug launch carries a
  20-second background poll loop.

**Reachability caveat, honest:** simulator Debug runs have their own
un-signed-in Keychain (they seed fine), and her on-device installs are
Release; the reachable case is an on-device Debug run on a signed-in
phone — rare but real, and the composition contradicts the file's own doc
either way. **Fix shape:** fold the fence into the gate —
`belongsToAnAccount` should AND with `fresh.sync.allowsSync` (a store that
can never sync belongs to no account for the seed's purposes), or pass
`.unowned` when `bootstrap.storeVariant != .real`. Pinnable red-on-old
(a dev-variant gate with account-true/sync-refused should seed without
waiting; today it declines).

**Everything else about B1 verified sound** — see the clean bill.

### 3. [MINOR] · `notes/MobileSoul.md` §6, PL-11 status cell (+ PL-14's) · the parity ledger still owes-lists a hook that shipped at batch 4 · MEASURED (code grep)

PL-11's status cell lists among "Still owed: … **(e) the on-leaving
savepoint hook**". **It shipped at batch 4 (PR7) and is live on both
leaving roads:** the background road (`VariorumMobileApp.swift:189-196`
passing `session.savepointOnLeaving` into `mobileScenePhaseChanged`;
`MobileShellRouter.swift:250-253` calling it per registered post) and the
note-pop road (`MobileWriteView.swift:191`). The round's own status table
(§7.1 row 4) records it ✅. A future mobile session planning from the
ledger — which is exactly what §6's protocol prescribes — would re-derive
or re-build an existing hook.

Smaller, same class: **PL-14's status cell doesn't record that (d) (the
Block History twin) and (g) (the LR2-4 version-blind labels — batch 6a's
one bug-class fix) are delivered** — the discharge is recorded only as a
cross-reference inside PL-11's cell. Fix: strike (e) from PL-11's owed
list and note (d)/(g) on PL-14's cell.

### 4. [MINOR] · `mobile-round-2-handoff-2026-08-30.md` §7.1, PL-10(b) row · "Reviewed ✅ (was 4.5d's)" overstates — the wiring and its three pins had no review until this sweep · READ-ONLY

§7.1's header promises "built AND cold-reviewed unless the cell says
otherwise", and the PL-10(b) row's review cell reads ✅. But PL-10(b) was
NEW build work by the 4.5d fix-round session (the guard wiring, the
`BookNameCopy` hoist, `excluding:`, three pins) — the 4.5d COLD REVIEW
(§61) predates it, and §11.2 of the same handoff says so honestly ("Its
own three new pins are unreviewed"). The sweep brief's §2b repeats it. Two
registers in one document disagree; the authoritative table is the wrong
one. This pass now covers PL-10(b) (see the discharge section), so the fix
is one cell edit pointing here.

### 5. [MINOR] · `mobile-round-2-handoff-2026-08-30.md` §1 · the Mac cell reads "1843/312 — baseline exact" while the merged tree carries a KNOWN candidate Mac failure the same session recorded at #91 · READ-ONLY

The state table's Mac row says "baseline exact; unverified since the fix
round touched no Mac file". The "no Mac file" half is git-true (verified).
But the `fa522d6` merge brought main's 13p-fix keychain work into this
tree, and QUESTIONS #91 — written by the same session — records
`CustodyHandoverTests.theE2EESurfaceNamesTheSymptomWhenAWriteLandsUnreadable`
**failing on clean `main`**, deliberately not fixed, routed to the Mac
session. A fresh session reading "1843/312 baseline exact" would run the
Mac suite, meet a red, and spend exactly the which-kind-of-red time this
repo keeps paying. One clause in the cell ("expect #91's known
CustodyHandover failure, main's, until the Mac session lands its fix — and
possibly already fixed by the 13p-fix ladder's later rounds; unverified
here") closes it.

### 6. [MINOR] · `MobileQuickNote.swift` `file()` + `MobileShellView.tabDoor` · the §62-endorsed residual, given its fresh-eyes verdict: an empty-but-focused box's tab switch leaves the keyboard standing over the next tab · READ-ONLY

§62 item 3 deliberately left this and endorsed "round 2's reviewer" as the
place to look at it fresh — that is this pass, so here is the verdict. The
never-minted empty box's leaving takes `file()`'s first guard
(`reset(); return nil`) — no `handOffCount` bump, nothing drops `focused`.
The tab bar is reachable with the keyboard up (batch 5's own
keyboard-avoidance finding: default avoidance lifts the tab bar onto the
keyboard), so tap-box → type nothing → tap Library is an ordinary gesture,
and the keyboard stays over the Library. Same visible symptom as §59
MAJOR 3, different state. **The shipped `handOffCount == 0` pin is the
RIGHT contract and should not flip** — nothing was handed off. The honest
fix is at the focus seam, not the counter: drop the box's focus at
`tabDoor` (a tab switch is a leaving of the shelf surface, focus included)
or in `reset()`. Small, phone-local, and it composes with batch 5's
`setFocused` machinery. Recording this discharges the §62 endorsement.

### 7. [NIT] · `MobileLivenessTests.swift:44-119` · A2's pins drive the entry-guard arm only; the three post-suspension guard arms are unpinned · READ-ONLY

The pins mint both tokens up front and run the two grants sequentially
with the stale one completing last — a real red-on-old for the AT-ENTRY
`isCurrent` check (removing the guards makes the stale library grant
install, exactly as the recorded failure text shows). What no pin drives
is a grant superseded WHILE suspended at `flushNow`/`refreshTakesFromStore`
— the arms at `MobileLivenessAuthority.swift:167,170`. I traced all the
interleavings by hand and the token discipline holds at every suspension
(including `register`'s self-minted token, and the synchronous prefix
ordering on the main actor), so this is an honesty note, not a hole: the
record's "checked at entry and after every suspension" describes the code;
the pins cover entry. If anyone wants the stronger pin, the harness
already injects autosave stalls (the architecture review §4.1 named the
shape) — a stalled flush plus a second `beginHandoff` mid-flight would
drive the interior arms.

### 8. [NIT] · `notes/QUESTIONS.md` #90 · "MINOR 1 *is* 13u item 8's O(N²) row" over-equates · READ-ONLY

The architecture review was careful to establish the opposite: MINOR 1
(`applyDifferential`, BOTH platforms) is *"a different, unreported site"*
from the row's named `planVisibleTakeEdit` twin, owned only via the row's
sweep-the-class-to-completion clause. A 13u session reading #90 could fix
the named twin, declare the row done, and leave MINOR 1 standing. One
clause ("a second site of the same class — the row's class-sweep covers
it, the row's named example does not") closes it.

---

## CLEAN BILL — load-bearing things specifically checked and found solid

**The five-MAJOR fix round (2a):**

- **"No Mac file was touched" — verified by git**, not by trust:
  `git diff --name-only 6bc4f18^..6bc4f18` contains only
  `VariorumMobile/`, `VariorumMobileTests/`, and the record. The
  not-running of the Mac suite was therefore legitimate.
- **B1's gate is correct in both directions at the core.**
  `hasSyncedCleanly` reads `status.lastSuccessAt`, which
  `SyncScheduler.runRound` sets ONLY after `engine.pull()` +
  `engine.push()` both succeed — a failed round genuinely is not an
  answer (verified at `SyncScheduler.swift:195-200`). The
  `belongsToAnAccount` second disjunct is real: `AppServices.start()`
  sets `account.variorum` from the persisted Keychain session BEFORE
  `connectSyncIfAllowed`, and owner-adoption failure leaves
  `isConfigured` false with `variorum` non-nil — the unsafe direction the
  disjunct exists for (verified at `AppServices.swift:279-284`). The call
  site moved to `VariorumMobileApp`'s own task strictly AFTER
  `await fresh.start()` — the concurrency removed, not gated around. The
  timeout returns `.awaitingFirstSync` BEFORE `save(true)` — the mark is
  not consumed; the cheap local `storeIsNew` runs first so no ordinary
  launch pays the wait; the poll-not-subscribe reasoning is factually
  right (`onRoundCompleted` is a single closure, owned by `AppServices`
  for the bridge — verified). The four pins exist, drive the finding's own
  script (`herCorpusArrivingDuringTheWaitCancelsTheSeed` lands the corpus
  mid-wait), and the residual is correctly scoped as hers (#88; the
  sign-in door genuinely lives inside the shell). Finding 2 is the one
  composition gap, and it is dev-store-only.
- **A2's token mechanism holds at every interleaving I could construct**
  — synchronous mint at the tap in the same turn as `tab = target`
  (verified at `MobileShellView.swift:301-314`), entry + post-suspension
  checks, `register` minting its own token (a push IS a request), the
  stale grant's synchronous prefix always overwritten by the newer
  request's, and the abandoned grant's flush harmless by design. The pins'
  recorded reverts name concrete failure values, and the user-visible
  half is driven through the real gate (`typeEdit` accepted/refused).
- **C1 is fixed at both jointly-wrong constraints** (the unconditional
  line-cap reset at `MobileBlockHistorySheetView.swift:365-370`; measured
  section headers via `sectionHeaderHeight` with the 52 pt floor kept),
  and **the corrected pin is genuinely non-hollow**: it measures the
  needed height independently via `NSString.boundingRect`, configures the
  cell out of the recycle pool wearing a take-header's caps first, and
  reads the REAL delegate height on the REAL mounted sheet in a key
  window. The self-reported hollow pin (`sizeThatFits` honouring
  `numberOfLines`) is exactly the trap it names, and recording it rather
  than silently rewriting is the guard working.
- **C2's guard is right and the stop-short is correctly scoped**:
  `if history.isEmpty, active.count <= 1` — every reachable multi-take
  state now draws take sections; the one-take calm sentence is true where
  it still shows, held PROVISIONAL for her at #87 exactly as ruled. `m3`
  (the take-header's `.right` alignment with no reset) is verifiably
  still open and was rightly not smuggled into C1's fix.
- **The record's staleness claim about A1's sharpest case is
  git-verified**: `git merge-base --is-ancestor 66606c0 e495ce8` answers
  no — the guard post-dates the review. The wired guard sits inside all
  three runner closures with a real `duplicateBookName` catch arm.

**2b — the 4.5d round's pins + PL-10(b):**

- All three `MobileBookNameGuardTests` pins exist and ran green in my
  582/93 run; the `excluding:` rename half is wired
  (`MobileBookDetails.swift:133`) so a book can be recased into its own
  name; the guard sits INSIDE each runner closure (the Mac's shape, the
  R3-1 projection lesson honored). The `BookNameCopy` hoist is an address
  move — the Mac's `OpsRefusalCopy.swift` keeps the symbol as a pointer,
  and the 4.5d record's own Mac run (1843/312 exact, zero Mac test files
  edited) is the hoist proof. The severity correction (UI courtesy gate,
  no uniqueness on `reading.name`) is accurately propagated in all three
  records I checked.
- The §1.1 owed red-on-old (`aRebuiltBarKeepsHerWidthWhenTheOutgoingBarIsReleasedFirst`)
  exists with the `lastBuiltBarWidth` arm it guards
  (`MobileKeyboardBar.swift:558-561`); the recorded 12-issue revert output
  is concrete. The 13-of-14-already-fixed table spot-checks clean
  (MINOR 4's `air == 4` third clause, MINOR 6's one-derivation rule —
  both present in the tree).

**2c — 4.5a's owed ladder round 2 (a real pass, not a rubber stamp):**

- **`ownsTheWholeNote`** (`variantID != nil && frozenPrefix.isEmpty`) is
  the right predicate and its belt clause is honestly argued at the
  declaration; the withdrawal arm reads it, not `postID`
  (`MobileQuickNote.swift:900`).
- **The restore-a-turn-later** is correct AND its changed pin semantics
  are the right ones: `aHeldEditNeverStrandsTheFieldOnTextTheNoteDoesNotHold`
  drives UIKit's own input path on the mounted field, asserts model AND
  field AND store, and pins the caret collapse at exactly 16 so a later
  surface fix must come change it on purpose. The mechanism (SwiftUI not
  re-pushing a binding that ends its turn at the already-rendered value)
  is real and the didSet→next-turn fix is the minimal correct one; the
  `restoreTask?.cancel()` coalescing means the newest hold wins.
- **The expiration teeth** now exist on BOTH construction roads
  (`performBackgroundFlush` sets `mine.onExpire = { work.cancel() }` on
  the self-minted road, `MobileShellRouter.swift:211-218`), and the
  `isGranted` gate is GONE rather than patched — the §58(2) ruling
  executed, with the cancellation checks as the teeth.
- **MINOR 9's retry is bounded by construction** (`mintNow` cancels the
  clock as it runs — one retry per refusal, never a spin), and MAJOR 3's
  fix bumps `handOffCount` on the withdrawal road (`:906`) so the
  keyboard drops. The endorsed item 3 got its fresh-eyes verdict
  (finding 6). Q2's keep-text-and-reason shape is verified at `file()`
  (reset only on the empty-box and completed roads).
- The suite containing all of these measured green in my run.

**Docs-vs-tree (2d):**

- **The §7 status table's ✅ cells otherwise hold.** Batches 5 and 6a
  really do have cold-review files with dispositions; the five-MAJOR row
  honestly says its review was OWED (this pass is it); 4.5a's row honestly
  says round 2 was owed (ditto); the handback-checklist row's claims are
  independently confirmed by the architecture review's §3 (L-c/L-d
  verified landed at the code, with the callers that motivated them).
- **QUESTIONS #84–#91 are accurate** against the records (I verified #87
  against the shipped guard, #88 against the gate's real limits, #89
  against the batch-5 record's §3 list, #91's build-break claim against
  `43a35ef`'s diff). The "~15 held vs 8 entries" gap is REAL but
  ACKNOWLEDGED in the section's own header ("the closeout still owes a
  fuller pass over items held earlier in the round") — the still-unnumbered
  items live in the orchestrator handoff §6 (M14's decision · PR24 · the
  strip's two regimes · F2 · the Release-side boundary check · the three
  gap-fence notifications) and §8 (the 23 pt strip · Q1's residual cost ·
  the caret collapse · the R30-stale build re-offer · the Fragments
  bridge-on-phone question). Named here so the closeout's fuller pass is
  a transcription job, not a hunt.
- **KnownIssues' mobile-owned rows are all accurate with live owners** —
  the withdrawn-quick-note row (its §62 mechanism verified), the
  `planVisibleTakeEdit` row (13u1; the architecture review confirmed the
  phone routes through the fixed planner), M12 (13u2), and the
  forked-brains row current with 6a's discharges (`BlockPastCopy`/
  `OriginPeekCopy` moved to discharged; the remaining six enumerated). No
  blank owners; nothing the round resolved was left standing.
- **The architecture review's disposition banners are otherwise
  faithful** — MAJOR 2's banner matches what shipped and was pinned;
  MAJOR 1's banner is accurate about the staleness and the latch, and
  overstates only the class-closure (finding 1).

**Planning sanity (2e):**

- The 2026-08-30 handoff's §4 work list: every row has an owner and a
  design source; the one sequencing hazard (B45-2 before batch 7) is
  carried on both tables; the fence (§5) correctly routes 4.6, the
  cross-block semantics, arch MINORs 1–2, and U-1…U-7 to 13u; nothing NEW
  and unowned has appeared in `Shared/EditorBrain/` or the planner
  (git-verified — the post-merge-base diff is notes-only). PL-13's faces
  and PL-14's remaining faces are named-but-unslotted and SAY so —
  watch that they enter the batch map when batches resume (the
  homeless-row rule's letter is "the map is the only schedule", and the
  2026-08-30 handoff §7.2 has been declared authoritative over the stale
  map cells, which covers them for now).
- Signature-failure-mode hunt: no green-over-nothing pin found in the
  since-13l work (the two self-caught instances — C1's hollow pin and
  4.5d's never-run red — are recorded, which is the guard working); no
  traced-but-never-executed mechanism found presented as executed (B1's
  drive, C1's measurements, and the 4.5d reverts all carry run output);
  the one reported-done-when-not cell is finding 4; the one compressed
  summary that lost findings (§49's four NITs) was already self-reported
  as unrecoverable.

---

## WHICH OWED REVIEWS THIS PASS DISCHARGES

- **2a — the five-MAJOR fix round's R28 cold review: DISCHARGED.** Full
  adversarial pass over `6bc4f18`'s diff and record: every fix's mechanism
  traced independently at the code, every pin read against its claim, the
  no-Mac-file and staleness claims git-verified, the suites re-run and
  exact. Finding 1 (MAJOR) is its output; findings 2 and 7 ride it.
  *Caveat: red-on-old reverts were verified by pin-reading + recorded
  output + independent mechanism traces, not re-executed (the read-only
  constraint); nothing I traced contradicts any recorded red.*
- **2c — 4.5a's owed ladder round 2: DISCHARGED.** A real pass over §62's
  five fixes in `MobileQuickNote.swift`/`MobileShellRouter.swift` and
  their pins, including the changed-pin-semantics road and the endorsed
  item 3 (finding 6 is its verdict). §59's MINORs 10/11 and the two
  routed-out items verified still correctly routed (KnownIssues row;
  held-with-MAJOR-5's caret).
- **2b — the 4.5d fix round's new pins + PL-10(b): DISCHARGED as
  covered** — the three guard pins, the §1.1 pin, and the hoist verified
  at code + by the recorded Mac run; the dispositions table spot-checked.
  Finding 4 corrects its status-table cell.
- **NOT discharged, per the brief's §2f and said plainly so nobody later
  claims otherwise: the DEDICATED STABILITY PASS (batch 4.5's exit
  condition, owner of M27) and the WHOLE-ROUND PASS (closeout obligation
  ZERO).** Their triggers and targets in the standing handoff §3 bind
  unchanged; nothing in this sweep resembles or replaces them.

---

# ADJUDICATION + FIX BRIEF (the Fable orchestrator, 2026-08-30 — repo-first, before any fix session sees it)

**ALL EIGHT FINDINGS ACCEPTED. ZERO DISPUTES.** Finding 1's mechanism was
independently re-traced by the orchestrator before this was written (the
persistent `Button{Task}` door at `MobileLenses.swift:514-516`, the
pre-suspension `picks` capture, the unconditional `preservation.insert(db)`
at `Operations+Versions.swift:348` before validation, and the schema's only
lens-side uniqueness being `uq_lens_choice_live` on `(lens_id, block_id)` —
nothing beneath the door can notice a second flight). The severity split is
endorsed as graded: the MAJOR is for the record's overclaim; the outcome is
clutter-class.

**ONE Opus fix session executes the items below as one R28 unit — its own
diff then gets ONE cold review before any §4 batch opens.** The fence binds:
ZERO `Sources/`, ZERO `App/Variorum/Shared/`, ZERO `EditorBrain/`, zero
schema. Every code item is phone-local by construction; if a fix seems to
need a fenced file, STOP AND REPORT.

## The fix list (code first, then records)

1. **F1 — latch the lenses adopt door.** Adopt the existing
   `MobileWriteLatch` at `MobileLensesModel.adoptView` (leave
   `saveIntoActiveLens` unlatched — its upsert/clear writes converge;
   outcome-safe). Pin red-on-old in the `MobileWriteLatchTests`
   two-concurrent-`Task` shape: a double tap leaves ONE preservation lens
   (today it leaves two). Then correct BOTH overclaims in the same commit:
   `mobile-major-fix-round-record.md` A1's universal sentence ("none of
   them can mint an uncaught duplicate row") gains the falsifier + this
   fix; `mobile-architecture-review.md`'s MAJOR-1 disposition banner
   ("the three doors") becomes four. Also append one sentence to A1's
   "Left open" section: `MobileBlockHistory.commitNow` is safe TODAY only
   because its one caller is a dismissing `UIMenu` — if a later batch
   (6b/9) gives the sheet its own commit button, that door needs the latch.
2. **F2 — B1's gate honors the A4 fence.** A store that can never sync
   must read as unowned for the seed's purposes: compose the gate at the
   call site (`VariorumMobileApp.swift:118-130`) so the dev-store variant
   never waits and never declines forever — e.g. AND `sync.allowsSync`
   into `belongsToAnAccount`, or pass `.unowned` for a non-real store
   variant; pick whichever keeps `SyncGate`'s API honest and the REAL-store
   behavior byte-identical (the existing four `MobileStarterJournalTests`
   pins must ride unmodified). Red-on-old pin: account-true + sync-refused
   composition seeds without waiting (today: 20 s poll → declines forever).
3. **F6 — the empty-focused-box tab switch drops focus.** Fix at the FOCUS
   seam (the tab switch is a leaving of the shelf surface, focus included —
   `tabDoor` or `reset()`), never at the counter: the shipped
   `handOffCount == 0` pin is the right contract and must not flip. New
   red-on-old pin: after an empty-focused-box tab switch, the box is not
   focused.
4. **F7 — ATTEMPT the interior-arm liveness pin** (a stalled `flushNow`
   via the harness's injected stall + a second `beginHandoff` mid-flight,
   asserting the superseded grant installs nothing). It must be
   DETERMINISTIC — ordering expressed through the seams, never a timing
   race. If it cannot be made deterministic, DECLINE it and write why into
   your results section (a pin that sometimes reproduces is not a pin);
   the traced-sound/unpinned state is acceptable and already recorded.
5. **F3 — the parity ledger catches up** (`notes/MobileSoul.md` §6):
   strike **(e) the on-leaving savepoint hook** from PL-11's still-owed
   list (shipped at batch 4/PR7; live on both leaving roads —
   `MobileShellRouter.swift:250-253`, `MobileWriteView.swift:191`); note on
   PL-14's status cell that **(d)** the Block History twin and **(g)** the
   LR2-4 version-blind labels are DELIVERED (batch 6a, 2026-08-30).
6. **F4 — the status table stops overstating**
   (`mobile-round-2-handoff-2026-08-30.md` §7.1): the PL-10(b) row's
   review cell becomes "✅ reviewed at the Fable sweep (2026-08-30) —
   `mobile-fable-sweep-review.md` §2b discharge" (it had no review before).
7. **F5 — the §1 Mac cell carries the #91 caveat**: after "baseline exact",
   add that the merged tree carries #91's known-failing
   `CustodyHandoverTests` red from `main` (main's, routed there; possibly
   already fixed by later 13p-fix rounds — unverified here), so a fresh
   session does not burn the which-kind-of-red time.
8. **F8 — QUESTIONS #90's over-equation**: one clause — the architecture
   review's MINOR 1 (`applyDifferential`, both platforms) is a DIFFERENT
   site from 13u item 8's named `planVisibleTakeEdit` twin, covered only
   by that row's sweep-the-class-to-completion clause, not by fixing the
   named example.
9. **O1 — QUESTIONS.md's stale next-free marker** (orchestrator's own
   pre-review finding): the "*(Next free number: #83.)*" line sits mid-file
   above the Mobile Round 2 section while #84–#91 exist below it. Move the
   marker to the END of the file reading **#92**, with a parenthetical that
   #83 was skipped at the Mobile Round 2 section's creation and stays
   unused (nobody should later fill it and create two numbering histories).
10. **O2 — §70's staging-incident account** (`mobile-round-2.md`): add the
    one-sentence correction batch 6a's review (m6) asked to land IN §70 —
    the sweep committed the `OriginPeek.swift` deletion without its
    replacement, so the MAC TARGET COULD NOT COMPILE from `a232455` to
    `16ba929^` and batch 6a's commit restored it; a bisect through that
    window fails to build for an unrelated reason. Point at the
    orchestrator handoff §11.3, which carries the full account.

## Environment (binding for the fix session)

Worktree `~/dev/variorum-mobile`, branch `mobile`. Create your OWN
simulator (iPhone 17 family, newest iOS 26 runtime — every iPhone
16-series sim here is iOS 18.3, invalid), arm
`ApplicationAccessibilityEnabled` on it, use a private `-derivedDataPath`
under the session scratchpad, delete the simulator when done. Run the FULL
mobile suite at the end (baseline 582/93 + your new pins; report the exact
"Test run with N tests" line). Core/Mac untouched by construction — do not
run them; verify instead that `git diff -- Sources/ App/Variorum/Shared
App/Variorum/Variorum` stays EMPTY. Never touch the real store; never quit
the live Mac app; no Release builds, no installs, no pushes. Every pin
proven red by behavioural revert, run output quoted in your results.
Commit pathspec-limited (`git commit -- <paths>` — a bare commit publishes
the whole index) with the standing trailer; do NOT push. Append a "FIX
ROUND RESULTS" section to THIS file with per-item dispositions before your
final message.

---

# FIX ROUND RESULTS (the Opus fix session, 2026-08-30)

**All ten items executed as one R28 unit. Four code items, six record items,
six new pins, every bug-class fix proven red by behavioural revert.**

**Environment of record:** worktree `~/dev/variorum-mobile`, branch `mobile` at
`caa79ef`. Private simulator `Opus-fix-round` (iPhone 17 Pro, iOS 26.2,
`ApplicationAccessibilityEnabled` armed and verified `1`), private DerivedData
under this session's scratchpad; the simulator was deleted at the end.

**Final suite:** `Test run with 588 tests in 93 suites passed after 125.844
seconds with 2 known issues` — the 582/93 baseline plus this round's six pins,
and the two known issues come from the ONE documented 4.5b diagnostic pin the
sweep itself measured (`MobileTrashTests.anEmptyAccessibilityTreeIsDiagnosed`
`RatherThanReadAsAnAbsentDoor` — a single `withKnownIssue` block recording two
issues; the "two pins" wording is corrected here at R2-6). `pipestatus` `0 0 0 0`.

**Fence, verified before commit:** `git diff -- Sources/ App/Variorum/Shared
App/Variorum/Variorum` is **EMPTY**. Zero `Sources/`, zero `Shared/`, zero
`EditorBrain/`, zero schema, no build-configuration file. Nothing needed a
fenced file, so nothing was reported as blocked. Core and Mac suites were NOT
run, by that fence's own argument.

## Per-item dispositions

| item | what landed | pin + its proven red | files |
|---|---|---|---|
| **F1** — latch the lenses adopt door | `MobileLensesModel` gains its own `adoptLatch`; `adoptView` becomes the latched wrapper over a new `adoptViewOnce`. `saveIntoActiveLens` deliberately left unlatched (its upsert-and-clear writes converge — stated at the declaration) | **`MobileWriteLatchTests.twoTapsOnAdoptLeaveOnePreservationLens`.** Red by removing the latch (`adoptView` calling `adoptViewOnce` directly): `✘ recorded an issue at MobileWriteLatchTests.swift:266:13: Expectation failed: (preservations → 2) == 1`. Restored, green | `MobileLenses.swift` · `MobileWriteLatchTests.swift` |
| **F1 (records)** | the fix round's A1 gains a verdict-table row for `adoptView`, the fourth adoption is named beside the three, the **universal sentence is struck and corrected in place** (with the rule it leaves behind: *a class argument may be stated as a class argument and never as coverage*), the seventeen becomes sixteen, and the `commitNow`-safe-only-by-its-host warning is written for batch 6b/9. The architecture review's MAJOR-1 banner reads **four** doors and carries the amendment | *(record work — no pin)* | `mobile-major-fix-round-record.md` · `mobile-architecture-review.md` |
| **F2** — B1's gate honours the A4 fence | new `SyncGate.live(allowsSync:syncIsConfigured:hasAccountSession:hasSyncedCleanly:)` folds the fence into `belongsToAnAccount` (`allowsSync() && (isConfigured() ‖ hasAccount())`); the call site composes through it. **`SyncGate`'s two facts keep meaning exactly what they say**, and the REAL-store reading is byte-identical to the old expression. The four existing `MobileStarterJournalTests` gate pins ride **unmodified** | **`aDevStoreThatCanNeverSyncSeedsWithoutWaiting`** (+ its companion `theRealStoreCompositionStillDefersUntilSyncHasSpoken`, which holds the unsafe direction). Red by dropping `allowsSync() &&`: `✘ Expectation failed: !((gate → SyncGate(…)).belongsToAnAccount() → true)` and `✘ Issue recorded ↳ expected a seed, got .awaitingFirstSync`. Restored, green | `MobileStarterJournal.swift` · `VariorumMobileApp.swift` · `MobileStarterJournalTests.swift` |
| **F6** — the empty-focused-box tab switch drops focus | fixed at the **focus seam**, not the counter: `reset()` now calls `setFocused(false)` (it runs on every road the box lets go by — the never-minted empty box, the withdrawal, the completed hand-off), and the face releases first responder on `onChange(of: model.isFocused)` when the model says the box no longer holds it. **Only the drop is honoured** — raising the keyboard stays the user's own act. The shipped `handOffCount == 0` contract did NOT flip and is asserted inside the same pin | **`MobileQuickNoteTests.anEmptyFocusedBoxLeavingLetsGoOfTheKeyboard`** — driven on the REAL mounted field through UIKit's own responder API, because the finding is about first-responder state. Red by dropping `setFocused(false)` from `reset()`: `✘ Expectation failed: !((field → <SwiftUI.VerticalTextView: …>).isFirstResponder → true → true)` and `✘ Expectation failed: !((box → MobileQuickNoteModel).isFocused → true → true)`. Restored, green | `MobileQuickNote.swift` · `MobileQuickNoteTests.swift` |
| **F7** — the interior-arm liveness pin | **ATTEMPTED AND LANDED — both arms, deterministically.** TWO pins, `aGrantSupersededDuringItsFlushInstallsNothing` and `aGrantSupersededDuringItsRefreshInstallsNothing`, plus the `SupersedeOnSettle` seam and a `twoTabWorld` helper. **No production change** — `MobileLivenessAuthority.swift` is byte-identical to `HEAD`; the guards were already right and are now driven | Red by removing **both** post-suspension `guard isCurrent(token)` lines: `✘ aGrantSupersededDuringItsFlushInstallsNothing … !((world.shelf).isLive → true → true)` and `!(typeEdit(world.shelf, …))` — *the abandoned grant's editor ACCEPTED her keystroke, which is the hidden-pen end state the authority exists to forbid* — and `✘ aGrantSupersededDuringItsRefreshInstallsNothing … !((world.shelf).isLive → true → true)`. Restored, green | `MobileLivenessTests.swift` only |
| **F3** — the parity ledger catches up | PL-11's still-owed list **strikes (e)**, replaced by the delivered account naming both live leaving roads; PL-14's status cell now records **(d)** the Block History twin and **(g)** the LR2-4 version-blind labels as DELIVERED (batch 6a), with its own remaining list restated | *(record work — no pin)* | `notes/MobileSoul.md` |
| **F4** — the status table stops overstating | §7.1's PL-10(b) review cell reads *"✅ reviewed at the Fable sweep (2026-08-30) — `mobile-fable-sweep-review.md` §2b discharge"*, and names what it corrects (4.5d's cold review predates the build work; §11.2 said so and the table did not) | *(record work — no pin)* | `mobile-round-2-handoff-2026-08-30.md` |
| **F5** — the §1 Mac cell carries the #91 caveat | the Mac row now warns that the merged tree carries #91's known-failing `CustodyHandoverTests` red from `main` — main's, routed there, possibly already fixed by a later 13p-fix round, **unverified here** — so a fresh session checks #91 before spending the which-kind-of-red time | *(record work — no pin)* | `mobile-round-2-handoff-2026-08-30.md` |
| **F8** — QUESTIONS #90's over-equation | the *"MINOR 1 **is** 13u item 8's O(N²) row"* clause is replaced with the precision: MINOR 1 is `applyDifferential`, both platforms — **a different, unreported site** — covered only by the row's sweep-the-class-to-completion clause, never by fixing the row's named `planVisibleTakeEdit` example | *(record work — no pin)* | `notes/QUESTIONS.md` |
| **O1** — the stale next-free marker | the mid-file *"Next free number: #83"* is replaced by a note explaining what it was and where it went; the real marker now sits at the **END** of the file reading **#92**, with #83 recorded as permanently unused so nobody fills it and creates two numbering histories | *(record work — no pin)* | `notes/QUESTIONS.md` |
| **O2** — §70's staging-incident account | the correction batch 6a's review (m6) asked for lands **in §70**: the `OriginPeek.swift` deletion was committed without its replacement, so the **Mac target could not compile from `a232455` to `16ba929^`** and a bisect through that window fails to build for an unrelated reason. Points at the orchestrator handoff §11.3, which carries the full account (verified against it before writing) | *(record work — no pin)* | `mobile-round-2.md` |

## Notes worth carrying

- **F7 was not declined, and the reason it did not need to be is worth
  keeping.** The brief allowed a decline if the ordering could not be made
  deterministic, and a real second tap racing a real database write would
  have been exactly the timing race the A2 pins' own discipline forbids. The
  seam that made it deterministic is `AutosaveCoordinator.observe(onSettled:)`:
  it fires **synchronously at the tail of `flushNow`**, i.e. while
  `takeLiveness` is still inside its `await` and has not reached the guard
  that follows. And because `refreshTakesFromStore` opens with a `flushNow`
  of its own, the SAME seam fires a second time — inside the refresh, between
  the two guards — so a settle-counting observer reaches **both** interior
  arms with no sleeps, no yields, and no assumption about how long a write
  takes. Finding 7's third arm (`register`'s self-minted token) is unchanged
  and still traced-sound.
- **What F1's correction leaves behind for the next reviewer**, stated in the
  record rather than only here: sixteen unlatched files remain un-traced, and
  the class argument covering them is now labelled as a class argument. One of
  them, `MobileBlockHistory.commitNow`, is safe **only by its host** — its one
  caller is a dismissing `UIMenu` row — so a Block History commit BUTTON in
  batch 6b/9 needs the latch on the same day it ships.
- **F6's fix deliberately does not touch `handOffCount`.** Both halves are
  asserted in one pin so a later change cannot trade the focus release for a
  counter bump: nothing was handed off, and a counter claiming otherwise would
  make the box lie about a filing it never made.

---

# R28 ROUND 2 — THE FIX DIFF'S COLD REVIEW (2026-08-30; Opus, cold, target `caa79ef..fc73882`)

*Landed IN FULL by the orchestrator (the compressed-summary rule: two
summaries in this round lost findings forever). The reviewer ran the four
named suites four times green on its own armed simulator (65/4 each), the
full mobile suite at the claimed **588/93 + 2 known issues** exact, verified
the fence and F7's zero-production-change claim by git, re-traced F1's
mechanism at every layer independently, hunted for a SECOND falsifier of the
class argument and found none (`MobileMembership.diverge` refused by
`postNotInReading` in-transaction; `copyNote` writes no rows), and verified
O2's un-buildable-window claim by `git log --diff-filter=D`. **0 BLOCKER ·
0 MAJOR · 3 MINOR · 4 NIT** — per the ladder rule (round 3 only on a NEW
BLOCKER/MAJOR), NO round 3 is owed; the items below get ONE fix wave.*

**One environment fact from its run, promoted to a standing note: a mobile
`xcodebuild test` run BUMPS `Package.resolved` (four dependency pins
drifted; the reviewer reverted it).** This is why the pathspec-limited
commit rule matters — `fc73882` correctly excluded it, and every future
session should expect the drift and never sweep it into a commit.

## The findings (verbatim-faithful)

**R2-1 [MINOR] · `MobileSoul.md` PL-14 status cell (written by F3) ·
MEASURED.** F3's rewritten cell carried the PRE-session wording forward —
*"(b) the archive/trash separation, hers to design in its own session with
HTML mockups"* — while three places in this same tree record the
design-session gate DISCHARGED by her Two-rooms ruling (#84; PL-11's own
cell edited in the same commit; the handoff §7.1). Two adjacent ledger rows
edited in one commit disagree about whether a design session is owed. What
is still owed is the separation being BUILT, not designed. Fix: PL-14(b)
becomes "the archive/trash SEPARATION is unbuilt — its IA is RULED ('Two
rooms', QUESTIONS #84, 2026-08-30), so the design-session gate is
DISCHARGED; batch 6c."

**R2-2 [MINOR] · `MobileQuickNote.swift:910-943` · READ-ONLY (traced).**
F6 closed one of the THREE no-hand-off leaving roads; the two REFUSAL
roads return without `reset()` (by design — Q2 keeps her text) and
therefore without dropping focus: the refused mint (`guard let minted else
{ armMintClock(); return nil }`) and the dirty-autosave seal road. `tabDoor`
assigns `tab` synchronously and both stacks stay alive, so the keyboard
stands over the Library, over an invisible box holding un-filed text and an
error she cannot see — the finding's own symptom, from the two remaining
states. Nothing in the diff says whether the exception is deliberate.
Red-on-old is cheap (the ABORT-trigger world + the mounted-field responder
assertion the new pin already demonstrates).

**R2-3 [MINOR] · `MobileStarterJournal.swift:188-201` +
`VariorumMobileApp.swift:129-137` · READ-ONLY (traced).** F2 gates on a
fact the seed already receives: `allowsSync` is a `let` derived from
`storeVariant == .real`, so the new conjunct restates the parameter through
a fourth closure — and the UNSAFE combination (`storeVariant: .real,
allowsSync: { false }`) is unpinned and would SEED into an account store
(the batch-5 MAJOR's own direction) the day `allowsSync` stops being a pure
function of the variant (a future "pause sync" toggle is its natural home).
`SyncGate.unowned`'s doc is now half-stale too. Fix: single-source — `if
storeVariant == .real, gate.belongsToAnAccount() { … }` inside
`seedIfNeeded`; `SyncGate` reverts to its two honest account facts;
behaviourally identical today (verified: `.dev` never waits, `.real`
unchanged); makes `.real + no transport → seed` unconstructible; add one
`storeVariant: .real` fence pin; update `unowned`'s doc.

**R2-4 [NIT] · `MobileLivenessTests.swift:178-260` · READ-ONLY.** The two
interior-arm pins' recorded red removed BOTH post-suspension guards, so
the record does not establish that each pin drives its OWN arm (by trace
they do discriminate — `SupersedeOnSettle(at: 1)` is caught by the
takeLiveness-flush guard, `at: 2` only by the refresh-flush guard). Fix:
run and record the per-guard reverts, one line each.

**R2-5 [NIT] · `MobileWriteLatchTests.swift:243-267` · READ-ONLY traced /
MEASURED 4 green runs.** The adopt pin's red depends on Task interleaving
nothing forces, and it has a silent-green direction: if flight 2 ever
scheduled entirely after flight 1 completed, the self-healed peeks empty
`displayedDivergences`, `adoptViewOnce` returns at `guard !picks.isEmpty`,
and the pin passes WITH the latch removed — green-over-nothing. (Family
NIT: the three pre-existing latch pins share the shape; do not churn them.)
Fix: `adoptView` returns `runIfFree`'s Bool (`@discardableResult`); the pin
asserts `first == true && second == false` — proving the second flight was
DECLINED, not that the count came out right.

**R2-6 [NIT] · this file's FIX ROUND RESULTS + the sweep baseline table ·
MEASURED.** "The two documented 4.5b diagnostic pins" is ONE pin
(`MobileTrashTests.anEmptyAccessibilityTreeIsDiagnosedRatherThanReadAsAnAbsentDoor`)
whose single `withKnownIssue` block records two known issues. Fix the
wording in both places.

**R2-7 [NIT] · `notes/QUESTIONS.md:923-924` · MEASURED.** Two consecutive
list items are both numbered `78.` (the CONFIRMED wrapper + the original
entry) — pre-existing, but O1's own goal was ending double numbering
histories, and renderers silently renumber everything below. Fix: fold the
wrapper into a single `78.` block (the #77/#79 pattern).

**Clean bill highlights (full text in the session record):** fence exact by
git; all four test files purely additive; the four original gate pins and
all four `handOffCount == 0` sites ride unmodified; F1 completely fixed at
the door with the latch persisting across sheet presentations
(`@State`-built-once verified); the `saveIntoActiveLens` exclusion correct
(a genuine converging upsert); F2's real-store behaviour byte-identical;
F6's fix idempotent, drop-only, unreachable from `.inactive`; every record
correction faithful, O2's claim git-proven; the #92 marker arithmetic
correct (83 genuinely absent, nothing above 91).

## ADJUDICATION (the orchestrator) — ALL SEVEN ACCEPTED, ZERO DISPUTES

R2-2's fork is ruled the FIRST way: drop focus on the two refusal roads too
(text and `lastError` untouched — the principle IS "a leaving is a leaving
of the shelf surface, focus included", and a keyboard over an invisible box
holding an invisible error serves nobody; her text and the reason are still
there when she returns to the Shelf). R2-3's single-sourcing is adopted as
proposed — the reviewer's shape is strictly safer than the shipped one, and
the shipped one is mine to own: the fix brief offered the AND-composition
as an example and the fixer took it; the round-2 catch is the ladder doing
its job. R2-5's family NIT is recorded, not churned. R2-7's fold must not
renumber anything — it merges two blocks under ONE `78.`, the #77/#79
pattern, and nothing else in the file moves.

**WAVE 2 — one Opus fix session, the seven items above, then this R28 unit
CLOSES** (no round 3 — no new BLOCKER/MAJOR). Fence and environment as the
first fix brief. New pins proven red by behavioural revert with quoted
output; R2-4 is a RECORD act (two single-guard reverts run and quoted, then
restored). Append a WAVE 2 RESULTS section to this file; commit
pathspec-limited; do not push.

---

# WAVE 2 RESULTS (the Opus fix session, 2026-08-30)

**All seven items executed as one wave. Three code items, four record items,
four new pins, every changed behaviour proven red by behavioural revert — and
two of the reverts corrected a claim rather than confirming one.**

**Environment of record:** worktree `~/dev/variorum-mobile`, branch `mobile` at
`78af490`. Private simulator `Wave2-fix` (iPhone 17 Pro, iOS 26.2,
`ApplicationAccessibilityEnabled` armed and verified `1`), private DerivedData
under this session's scratchpad; the simulator was deleted at the end.

**Final suite:** `Test run with 592 tests in 93 suites passed after 129.211
seconds with 2 known issues` · `** TEST SUCCEEDED **` — the 588/93 baseline plus
this wave's four pins. **The 2 known issues are R2-6's own subject, and the run
proves R2-6 right:** both are recorded by the SINGLE test
`anEmptyAccessibilityTreeIsDiagnosedRatherThanReadAsAnAbsentDoor` (lines 497 and
498 of its one `withKnownIssue` block) — *"passed after 0.455 seconds with 2
known issues"*, one test, two issues.

**Fence, verified before commit:** `git diff --name-only -- Sources/
App/Variorum/Shared App/Variorum/Variorum "*.xcodeproj" "*.pbxproj"
"*.entitlements" "*.plist"` is **EMPTY**. Zero `Sources/`, zero `Shared/`, zero
`EditorBrain/`, zero Mac target, zero schema, zero build configuration. Nothing
needed a fenced file, so nothing was reported as blocked; core and Mac suites
were not run, by that fence's own argument. `Package.resolved` did NOT drift on
this machine's runs, and was checked before the commit anyway (the standing note
above).

## Per-item dispositions

| item | what landed | pin + its proven red | files |
|---|---|---|---|
| **R2-2** — both refusal roads let go of the keyboard | `file()`'s refused-mint arm and its dirty-autosave seal arm each drop focus at the point they return. **Text and `lastError` are untouched** (Q2's rule is the reason those roads skip `reset()` in the first place), and **all four `handOffCount == 0` sites are unmoved** — the counter must keep saying that nothing was filed. `reset()`'s doc gains the clause that the refusal roads carry the same rule by a different road | **TWO pins, one per arm**, both driven on the REAL mounted field through UIKit's responder API. `aRefusedMintAtALeavingLetsGoOfTheKeyboardToo` (ABORT-trigger world) — red by dropping `setFocused(false)` from the refused-mint arm: `✘ Expectation failed: !((field → <SwiftUI.VerticalTextView: …; text = 't...s' (length = 28)…>).isFirstResponder → true → true)` + `✘ !((box → MobileQuickNoteModel).isFocused → true → true)`, **and the seal pin stayed green in that same run**. `aLeavingWhoseKeystrokesWereRefusedLetsGoOfTheKeyboardToo` (the `lockPost` road) — red by dropping it from the `autosave?.isDirty` arm: `✘ !((field → …; text = 'b...t' (length = 29)…>).isFirstResponder → true → true)` + the `isFocused` twin. Restored, green | `MobileQuickNote.swift` · `MobileQuickNoteTests.swift` |
| **R2-2 (recorded consequence)** | `open()` shares `file()`'s body, so a ⏎ or open-door press whose mint is REFUSED now drops the keyboard too. Stated at the code rather than discovered later: the gesture asked to leave the box for the note and could not, the error it leaves is the thing worth looking at, and her text is still in the box | *(behaviour note — carried by the two pins above)* | `MobileQuickNote.swift` |
| **R2-3** — the fence is single-sourced at the variant | `seedIfNeeded` reads `if storeVariant == .real, gate.belongsToAnAccount()`; **`SyncGate` reverts to its two account facts** (`SyncGate.live` deleted); the call site composes the pre-F2 expression again; `unowned`'s doc and the file header say where the fence went and why. Real-store behaviour byte-identical; the `.dev` store never waits; **the unsafe pair (`.real` + a gate answering "no account" because a transport fact was folded in) is now unconstructible — the gate takes no transport fact at all** | **The four ORIGINAL gate pins ride green, adapted only as the fence forces:** each drives the ACCOUNT gate, so each now runs on the variant that consults it (`.dev` → `.real`; every one injects its own mark, so no defaults are touched and no claim moved). **NEW: `oneGateSeedsTheDevStoreAndDefersTheRealOne`** — one gate value, two variants, opposite outcomes. **THREE reverts run:** (a) drop `storeVariant == .real,` → `✘ aDevStoreThatCanNeverSyncSeedsWithoutWaiting … ↳ expected a seed, got .awaitingFirstSync` + the new pin's dev leg; (b) drop `gate.belongsToAnAccount()` → `✘ aDeviceWithNoAccountSeedsWithoutWaiting … failed after 30.038 seconds` (it spends the whole budget); (c) remove the gate consult entirely → `✘ theRealStoreCompositionStillDefersUntilSyncHasSpoken … (outcome → .seeded(readingID: …)) == .awaitingFirstSync`, plus `aSignedInDeviceDeclinesUntilItsFirstCleanRound`, `herCorpusArrivingDuringTheWaitCancelsTheSeed` (`books.count → 2`) and the new pin's real leg — **12 issues, the batch-5 MAJOR back in the room**. Restored, green | `MobileStarterJournal.swift` · `VariorumMobileApp.swift` · `MobileStarterJournalTests.swift` |
| **R2-4** — the per-guard reverts, RUN | **A RECORD ACT, and the record it produced is a CORRECTION.** `MobileLivenessAuthority.swift` is **byte-identical to `HEAD`** (`git diff --quiet` on that path, verified after every revert) — it lives at `App/Variorum/VariorumMobile/Features/Shell/`, phone-local, not under `Shared/`. **Measured, against the finding's trace:** removing the post-FLUSH guard ALONE reds NOTHING — `✔ aGrantSupersededDuringItsFlushInstallsNothing passed after 0.014 seconds` · `✔ aGrantSupersededDuringItsRefreshInstallsNothing passed after 0.014 seconds` · `✔ Test run with 9 tests in 1 suite passed`. Removing the post-REFRESH guard alone reds exactly one — `✔ aGrantSupersededDuringItsFlush… passed` · `✘ aGrantSupersededDuringItsRefreshInstallsNothing … !((world.shelf).isLive → true → true)`. **So the two pins do NOT discriminate as traced:** on a `refresh: true` grant the guards sit in SERIES, and the second catches the first's bump, so the flush pin proves the PAIR and not its own arm | **NEW pin, to make the record's goal true rather than merely recorded:** `aRefreshlessGrantSupersededDuringItsFlushInstallsNothing` runs the `refresh: false` road — `register`'s production shape — where the flush guard is the only one there is. Red by removing that guard alone: `✘ !((world.shelf).isLive → true → true)` + `✘ !(typeEdit((world.shelf), …))`, **with both existing pins green in the same run**. Restored, green. Both existing pins' doc comments now name the revert that actually reds them | `MobileLivenessTests.swift` only |
| **R2-5** — the adopt pin asserts the DECLINE | `adoptView` returns `runIfFree`'s Bool, `@discardableResult`, with the reason at the declaration: the door does not care (a declined second tap is not a refusal — P-2), a PIN does. The three pre-existing latch pins were **not churned** (the family NIT, recorded not acted on) | `twoTapsOnAdoptLeaveOnePreservationLens` now asserts `firstFlew && !secondFlew` beside the count. Red by pointing `adoptView` at `adoptViewOnce` directly: `✘ Expectation failed: !(secondFlew → <not evaluated>)` **and** `✘ (preservations → 2) == 1`. Restored, green | `MobileLenses.swift` · `MobileWriteLatchTests.swift` |
| **R2-1** — PL-14(b) stops owing a discharged design session | The cell now reads that the archive/trash SEPARATION is **unbuilt** while its IA is **RULED** (*"Two rooms"*, QUESTIONS #84, 2026-08-30) — the design-session gate DISCHARGED, batch 6c — and says in one parenthetical what it corrects and why two adjacent ledger rows had disagreed | *(record work — no pin)* | `notes/MobileSoul.md` |
| **R2-6** — one pin, two known issues | Both places corrected — the sweep's own baseline table and the FIX ROUND RESULTS line — each naming the single test and its single `withKnownIssue` block. Grep-verified: it is the suite's only ARMED `withKnownIssue` (`MobilePerfWalkTests`' `expectFlat(knownIssue:)` parameter has no call site passing it), and **this wave's own full-suite output proves it**: one test, "2 known issues" | *(record work — no pin; the final run is the measurement)* | `notes/plans/mobile-fable-sweep-review.md` |
| **R2-7** — one `78.`, nothing renumbered | The CONFIRMED wrapper and the original entry are ONE `78.` block in the #77/#79 pattern (`… The original entry:** **May a journal-day deletion travel…`). **Nothing else in the file moved:** `git diff --stat` is `1 insertion(+), 2 deletions(-)`, and #76/#77/#79 are untouched. The bold markers were re-counted after the fold (10, even — the pre-fold blocks carried 6 + 4; a first attempt collapsed one pair and was caught by counting rather than by reading) | *(record work — no pin)* | `notes/QUESTIONS.md` |

## Notes worth carrying

- **R2-4 asked for a record and produced a correction, which is the whole point
  of running reverts instead of tracing them.** The finding's parenthetical
  (*"by trace they do discriminate"*) is FALSE for the shipped pins, and the
  reason is structural rather than incidental: `takeLiveness(refresh: true)` puts
  the two guards in series on one road, so the downstream one absorbs the
  upstream one's bump and no assertion can tell which line caught it. The pair is
  genuinely pinned (the joint revert reds both pins, as the first wave recorded);
  the ARMS were not, until this wave added the refreshless road.
- **Finding 7's third arm stays undriven, and now for a stated reason.**
  Building the isolating pin, the natural target was `register` itself — the
  production `refresh: false` caller. It cannot be asserted this way:
  `MobileEditorViewModel.isLive` **defaults to `true`** (a screen with no
  authority must be able to type) and `takeLiveness` stands down OTHERS, never
  its own taker — so a superseded registration leaves the newcomer live *by
  default*, indistinguishable through this surface from one that was granted.
  Not a missing seam; an unobservable difference. Recorded at the pin.
- **R2-3's red-on-old is not symmetric, and the asymmetry is worth keeping.**
  Dropping the gate conjunct makes the condition MORE inclusive — every real
  store waits — so it reds the "no account anywhere" pin by spending the entire
  budget, not the deferral pins. The wave's first draft claimed the wrong revert
  in a doc comment; running it caught that, and both doc comments now name the
  revert that actually reds them.
- **Adapting the four original gate pins from `.dev` to `.real` is the fence's
  own consequence, not a weakening.** Each of those pins exists to drive the
  ACCOUNT gate, and after R2-3 only a real store consults it — so on `.dev` they
  would have gone on passing while asserting nothing, which is the green-over-
  nothing class R2-5 is about. Every one injects its own mark, so none of them
  touches this machine's defaults.
- **One untracked file was present in the worktree and left strictly alone:**
  `notes/plans/mobile-batch-6c-brief.md` (mtime 23:24, minutes before this
  session's simulator was created — not this session's work). The commit is
  pathspec-limited, so it could not be swept in.

---

# LADDER CLOSED (the orchestrator, 2026-08-30/31)

**The pre-batch mandate she set — thorough sweep → one Fable cold review →
Opus fixes — is COMPLETE.** Round 1 (the sweep): 1 MAJOR · 5 MINOR · 2 NIT,
all fixed at `fc73882`. Round 2 (cold review of the fixes): 0 BLOCKER ·
0 MAJOR · 3 MINOR · 4 NIT, all fixed at `8e81112` (wave 2). No new
BLOCKER/MAJOR at round 2 ⇒ no round 3, per the ladder rule. Final:
**mobile 592/93 green** (+2 known issues from the one R2-6 diagnostic
test), fence clean at every commit, `Package.resolved` never swept.

**Wave-2 adjudications (the orchestrator; all endorsed):**

1. **R2-4's execution FALSIFIED round 2's read-trace** — guard-1-only
   removal reds nothing (the two post-suspension guards sit in series on a
   refreshing grant), so the reviewer's claimed per-arm discrimination was
   wrong. The fixer's added pin (`register`'s refreshless production shape,
   red under guard-1-only removal with siblings green) is ENDORSED as the
   correct closing form — executed evidence outranks a read trace, and
   recording "unpinned" while able to pin it would have left the finding's
   own goal unmet. *Process note, standing: an in-batch widening like this
   is normally proposed before built (the implementer proposes, the
   architect rules); endorsed post-hoc here because the alternative was a
   record act that recorded a falsehood.*
2. **The four gate pins' `.dev` → `.real` move is a semantics-forced
   adaptation, not churn**: after single-sourcing, only a `.real` store
   consults the gate, so a `.dev`-variant pin would pass while asserting
   nothing — the exact vacuous-pin class this round polices. Each pin's
   CLAIM (what the account gate does) is preserved.
3. **R2-2's recorded consequence** — `open()` shares `file()`'s body, so a
   refused ⏎ now also drops the keyboard (text + error kept, one tap
   re-focuses) — ACCEPTED and recorded at the code; it rides the
   blur-with-text family already held for her at QUESTIONS #89.
4. **Finding 7's third arm is closed by reason, not by pin**:
   `isLive` defaults true and `takeLiveness` never stands down its own
   taker, so a superseded `register`'s newcomer is live-by-default —
   an UNOBSERVABLE difference, recorded at the pin. Accepted.

**What this whole exercise leaves standing for the round** (already owned,
listed for the closeout's convenience): the batch 5 / 6a MINORs+NITs and
architecture MINOR 3/MINOR 4/NIT 1/NIT 2 (work-list row 9) · the
`commitNow` latch-if-it-gets-a-button rider (carried into 6b/9's briefs) ·
the sixteen un-traced unlatched doors (adopt-as-touched, per the corrected
class argument) · the collapsed-box overflow MINOR (batch-5 review, row 9)
· the two standalone passes, untouched and binding.

**Batch 6c opens next** — brief: `notes/plans/mobile-batch-6c-brief.md`.
