# VM-5 — THE WHOLE-ROUND PASS (Mobile Round 2's closing cold read)

**Cold reviewer:** Fable, 2026-10-06, zero implementation context, running
`notes/REVIEW_PROMPT.md` verbatim over THE ROUND'S ENTIRE MOBILE-SIDE BODY
on this tree: `git diff 46ffa0c -- 'App/Variorum/VariorumMobile/**'`
(77 files, +17,719/−1,831) plus the test fabric
(`App/Variorum/VariorumMobileTests/**`, 66 files, +22,811/−548) and the
round's Shared survivals as they EXIST (most round-era Shared work was
rewritten by main's 13u1/18m — reviewed as it stands, per the brief).
This is the round-2 closeout commitment of 2026-08-22, run last; the three
prior VM-5 records (`vm-5-review-round-1.md`, `vm-5-stability-pass.md`,
`vm-5-review-round-3.md`) were read to avoid re-reporting their
dispositioned findings; this pass is independent of them.

**Method.** The round's named subjects read whole in this session: the
quick note (model + copy + host wiring + the scene seam), the Two rooms
(Trash/Archive models + views), the Versions face, the per-note tray, the
Library filters + the #93(b) union, the ⋯ vocabularies (note sheet, block
menu, take-card rows), the fan's hands (reorder/take→block/takes→blocks),
block multi-select (selection + list + copy), the starred page + the swipe
band (brain + shell), New Note/New Chapter in a book, the liveness
authority, the undo door, Block History, the note clipboard, the shelf
layout brain, the starter journal, the app entry's lifecycle wiring, and
the surface-driver test fabric. Cross-face sweeps: the seal vocabulary
across every `.lockedPost` arm; `archived_at`/star-cap model-fact comments;
P-2 dead-door checks; P1 windows on every held listing. Targeted suites
*[removed for publication]*
`MobileEmptyStoreTests` + `MobileFilterTests` + `MobileNoRedirectSweepTests`
— `✔ Test run with 18 tests in 3 suites passed` (TEST SUCCEEDED).

---

## Findings (severity-ranked)

### MINOR 1 · `Features/Shell/MobileArchiveView.swift:35–41` + `Features/Shell/MobileLibraryView.swift:83–86` · TWO FURTHER SITES of the falsified model fact round 1's MINOR 1 corrected at three sibling sites

Round 1 found three comments asserting, as a MODEL FACT, that a book
cannot be archived, and its disposition corrected "all three"
(`MobileListingFilters.swift`, `MobileLibraryViewModel.swift`,
`MobileShelfFaces.swift`). Two more sites carry the same falsified claim
and were not in that finding's list:

- `MobileArchiveView.swift:35–41` — *"`reading` carries no `archived_at`
  (AppSpec §7), so a book cannot be archived and a 'books' door here could
  never have content — P-2 in its strongest form … book-archiving would be
  a schema event, logged for her rather than improvised"* — **in the exact
  file where the owed archived-BOOKS face will land** (MobileSoul 13i-e
  row, F-U1-4 / VM-6 (4d)).
- `MobileLibraryView.swift:83–86` — *"(§0's model fact: a book cannot be
  archived at all)"*, justifying the archive door's placement.

**Evidence:** `Reading.archivedAt` exists
(`Sources/VariorumCore/Models/Reading.swift:77`),
`Operations+ReadingArchive.swift` exists, and the phone's own merged shelf
long-press archives the daily Journal — the schema event HAPPENED (13i-e,
v1_21/marker 12). The corrected sibling
(`MobileListingFilters.swift:99–118`) states today's fact and points at
the owed row; these two still state the old one, and one of them argues
the owed face is impossible. Same traced degradation as round 1's finding:
the session building VM-6 (4d) meets comments telling it the face "could
never have content", in the two files it must edit. Comment class — no pin
owed. **Fix:** correct both to the `archiveDoors` wording (today's fact +
the owed-row pointer).

### MINOR 2 · `Features/Shell/MobileLibraryView.swift:437–450` (`listingRows`' empty state) · under the `.bookless` filter, a library whose notes are ALL in books renders the fresh-install empty-store copy — three sentences that are false there, producing the exact "my writing is gone" reading the copy exists to prevent

**Mechanism (inputs → wrong output):** notes exist, every one a member of
a book (the journal-first default — `shelveInDailyJournalBook` books every
day's entry, and `Queries.poolPosts` excludes members and smart-collected
notes alike). She taps **Bookless**. `model.visible` under `.bookless` is
`bookless == []`; `shelved.rows` is `[]` by the ternary (books join only
under `.all`); the guard `model.visible.isEmpty, shelved.rows.isEmpty,
model.filter != .scraps` passes — and the surface renders
`MobileEmptyStoreCopy.noNotes` (**"No notes yet."**) +
`noNotesDoor` (**"+ New Note starts one."**) +
`signIn` (**"Have an account? Settings ▸ Sync signs you in."**). All three
mislead: notes exist; and the sign-in line implies her data has not
arrived. `MobileEmptyStore.swift`'s own header says the copy exists to
stop *"the emptiest, most alarming case — 'my writing is gone'"* from
being the reading; under this filter it CREATES it. (Under `.notes`/`.all`
the guard is honest — `visible` is then the whole listing. The books-half
clause was round 1's NIT 2; this is the note-half's own reachability,
which no prior record dispositioned and no test pins.)

**Pin (red on this tree):** one booked note in the store, filter
`.bookless`, mount the Library (the `MobileSurfaceDriver` shape the filter
batch's own pins use) — assert the store-empty copy does not render (an
honest bookless-specific line does). Fails today with all three sentences
on screen. **Fix:** a per-door empty line for the provenance filters
("No bookless notes — every note is in a book." class, 13s rewording
with the rest); the fresh-install copy stays `.all`'s (and `.notes`', where
`all` empty really is store-empty for notes).

### MINOR 3 · `Features/Shell/MobileQuickNote.swift:151–155` (`MobileQuickNoteCopy.refusal`, the `.lockedPost` arm) · refusal-copy drift against the phone's RULED seal vocabulary — "sealed"/"Unseal" where every other phone door says "locked"/"unlock", directing her at a door name that exists nowhere on the phone

The arm reads: *"This note is sealed, so it can't take new text. Unseal it
in the note to keep writing."* The phone's ruled words are
`SealedNoteCopy.Words.phone` = state **"locked"**, verb **"unlock"**
(`Features/Write/MobileRefusalRoads.swift:19–24` — *"the phone's shipped
vocabulary"*), spoken by every sibling: `MobileWriteView.sealedStateLine`
("This note is locked — reading only." beside the **Unlock Note** door),
`MobileStructural`/`MobileComments`/`MobileBlockMenu` through
`SealedNoteCopy.sentence(words: .phone)`, `MobileTakesBrowser`,
`MobileBlockHistory`, `MobileLenses`, the undo door through the shared
table. No phone door is named "Unseal". The file's own doc (lines 128–130)
anticipated joining a shared refusal vocabulary once one existed — 18m U3
built it (`Shared/OpsRefusalTable.swift`) and this arm never joined.

**Reachability:** the box OWNS the minted note and autosaves into it
(`adopt` wires `coordinator.observe(onError:)` →
`MobileQuickNoteCopy.refusal`); a seal landing by sync while the box holds
the note (sealed on the Mac mid-capture) refuses the flush `.lockedPost`
and this sentence renders in the box's red slot. **Pin (red on old):** the
arm's output for `.lockedPost` composes
`SealedNoteCopy.sentence(act: …, words: .phone)` / contains "locked",
never "sealed"/"Unseal". **Fix:** compose the shared sentence.
**Rider (NIT-class, shared home):** `Shared/VersionActs.swift`'s
`.lockedPost` arm — *"This note is marked complete — unseal it to restore
a version."* — renders "unseal" on the phone's Versions face too; the
durable fix there is the same `SealedNoteCopy` composition (18m's own
pattern), one change serving both platforms' words.

### MINOR 4 · `Features/Write/MobileEditorViewModel.swift:1213–1219` (`saveVersion`) + `Shared/VersionActs.swift:28–34` (`save`) · the one ⋯-sheet door that does not refuse on a dirty coordinator — a REFUSED flush still mints the moment, missing the pending bytes, and reports "Saved"

**Mechanism:** `VersionActs.save` runs
`await session.flushExistingAutosave(forPost:)` —
`AppSession.swift:295–297`, a bare `coordinator.flushNow()` with **no
dirty check after** — then `saveNoteVersion`. On a refused flush (pending
surface bytes on a take a remote lock froze — the coordinator's
keep-pending posture; the exact state `flushPendingText` exists for) the
save proceeds: the minted moment lacks the pending bytes and the receipt
says `VersionsPath.saved`. The sheet's SIBLING doors guard exactly this —
`deleteNote`/`lockNote` → `flushPendingText()` →
`unsavedChangesRefusal` — and `VersionActs`' own header states *"FLUSH
FIRST … is not optional … a version saved while a keystroke is still
pending would be a moment missing the words that summoned it"*: the flush
RUNS, but its outcome is never consulted, so the header's named failure is
exactly what the refused-flush road produces. Shared layer ⇒ both
platforms' ⌘⇧S/Save-a-Version doors.

**Honest caveats, stated:** the refused-flush state is already visibly
erroring (the coordinator's own onError speaks), and the moment matches
the STORE's truth — a defensible outcome. But the family's contract is
refuse-and-speak, and `restore`'s save-of-NOW has the same hole with a
worse consequence shape (its own doc: *"the restore then deletes the
blocks those bytes belonged to"* — the save-of-now silently misses them;
they stay pending against tombstoned rows). **Pin (red on old):** pending
text on a locked take → `saveVersion()` → assert the door refuses with the
flush-refusal wording (old: reports Saved; the version lacks the bytes).
**Fix:** consult dirtiness after the flush in `VersionActs.save`/`restore`
(or thread the VM's `flushPendingText` guard at the phone door and its Mac
twin), refusing in the family's voice.

### MINOR 5 · `Features/Write/MobileEditTrace.swift` (632 lines) + five `MobileEditorViewModel` call sites + Settings ▸ Diagnostics · the E1 instrument's own recorded removal condition has been met since 2026-08-23, and no surviving record owns its retirement

The file's header: *"Removing it — When E1 is settled, delete this file
and the five call sites it names … plus the Settings ▸ Diagnostics
section. Nothing else refers to it."* E1 IS settled — it ran on her device
and fired (2026-08-23; `DetailedPlanForPhases.md` 13u item 7: *"E1 RAN ON
HER DEVICE AND FIRED; M1's ROOT IS PROVEN … The iOS half is answered"*;
the crash trace carries the result banner). The instrument is deliberately
**Release-live** (its own rule — no `#if DEBUG` may gate the capture), so
a diagnostics surface and five keystroke-road call sites ship in her real
app for a question that is answered — and a grep of
`KnownIssuesAndTechDebt.md`, the orchestrator handoff and the fixes
records finds no retirement row, so the debt sits unowned (the KnownIssues
rule's own forbidden state). No perf claim (disarmed cost is one static
Bool; armed is a bounded ring) — this is the cleanliness/doctrine class.
No pin owed. **Fix:** delete per its own instruction, or record the
keep-decision (e.g. "kept armable until the 13u-era gesture-matrix device
walk — VM-13 — completes") in a record that does not close, so the next
session inherits a decision rather than a derelict instrument.

### NIT 6 · `Features/Shell/MobileStarredView.swift:32–33` + `Features/Shell/MobileStars.swift:170` · two stale star-cap comments say FIVE; the merged cap is FIFTEEN

`Operations.starLimit == 15` (`Operations+Appearance.swift:257`). Round 1's
clean bill corrected the tutorial lesson to "up to fifteen"; these two
comments still argue from "at most five rows by construction" / "at most
five point-reads". The bound ARGUMENTS survive (bounded by the cap either
way — the no-window justification holds at 15), only the number is wrong.
Comment class. Fix: say `Operations.starLimit` (the number's one home)
instead of a literal.

### Observation (not a finding — recorded so the round's close is exact)

The whole-round brief's subject list names *"the fan's hands
(reorder/take→block/copy-all)"*. **Copy-all-takes (PL-10(c)) was
deliberately NOT built in the round** — the batch-7 record's own "What I
deliberately did NOT do" names it — and it remains owed on the OPEN
PL-10 ledger row (the `UIPasteboard` twin, HOIST never copy, with
`MobileClipboard` already positioned as the one composer). Owned, so not a
finding; stated so the subject list is not read as shipped.

---

## Clean bill (checked and found solid)

1. **The quick note's loss-proofing chain holds end to end.** The
   boundary decision (`applyingChange`) applies the tail's half and
   refuses the prefix's with the spoken hold; the next-turn restore
   (measured divergence fix) cancels on `reset()`; the withdrawal gates on
   OWNERSHIP (`variantID != nil && frozenPrefix.isEmpty`), never `postID`;
   a refused mint keeps text + reason and re-arms the clock; a refused
   post-mint flush returns nil so navigation never leaves the box's text
   behind; `handoffHold`/`boundaryHold`'s not-captured consequence is
   recorded at the arms; `reset()` releases the coordinator through
   `releaseAutosave`, whose iOS arm verifiably keeps a dirty one
   (`AppSession.swift:381–387`). All four early-mint occasions are wired:
   ⏎/open door (`file()`), tab switch (`selectPage`), push off the shelf
   (`leavingShelf` on all three shelf roads), backgrounding
   (`performBackgroundFlush` first leg).
2. **The scene seam** — the grant taken synchronously with an expiration
   handler on both construction roads; flush order quick note → editors →
   savepoints → sync; the 13p re-lock lands LAST inside the same grant and
   deliberately un-gated on cancellation; `.active` asks the re-lock
   before `triggerSync`.
3. **The Two-rooms IA is structural, not remembered:** two models, two
   message slots; `MobileArchiveModel` carries NO purge road at all; both
   purge doors live in the Trash room; every confirm rides
   `presenting:` + the setter-clears-presentation-only rule (the 4.5b
   BLOCKER's fix shape, consistently at the Trash, tray, Library row,
   Versions, and — via the authorization split — the undo door's two
   hosts).
4. **The per-note tray** keeps her G5 shape (archived/leaving, no
   unclocked-originals section); every listing windowed in SQL with a
   visible marker; the stranded-filter probe residual is recorded at the
   code AND owned (the KnownIssues bounded-windows row carries the Mac
   twin). The take's one purge road is the Leaving section, confirmed
   every time, through the shared `TrashPurge`.
5. **The Versions face:** bounded listing + probe + visible marker; the
   reader closes on a failed read (never three verbs over an unread
   moment); Restore/Delete confirmed, Promote instant (#80(c)/(d));
   the four phone-voiced strings are enumerated and pinned clear of the
   shared sentences; the whole-shell door pin exists
   (`theVersionsRowOpensTheRoomThroughTheWholeShell`).
6. **The union (#93(b))** is a pure, deterministic interleave (stamp desc,
   note-first ties, source order within kind) over the two windowed sets;
   the book-stamp mapping is PROVISIONAL and recorded; `.title` is
   refused at `setSort` (the 18h trap named and fenced); one book-row
   rule under both doors; the two-number truncation sentence where the
   total is known.
7. **The swipe band:** pure arithmetic brain, one named coordinate space
   (the 13e rider), `@GestureState` so cancellation cannot strand the
   drag, the direction latch, walls at the ends, flick-and-distance
   landing agreeing in sign, ONE road to a page change (`selectPage`)
   carrying A5-8's filing + the liveness handoff token + the settle.
8. **The liveness seam as it stands:** the monotonic token checked at
   entry and after every suspension; every tombstone refusal
   store-confirmed before the pen is withheld; the refusal withdrawn
   narrowly at a grant; `flushAll` walks the registration set;
   `registeredPostIDs` deduped for the savepoint leg.
9. **The fan's hands:** reorder flushes then reads the fan FROM THE STORE
   (never the frozen projection — the B45-2 lesson applied one layer up);
   ends refuse by name; the AR-1 doors latch (`structureLatch`) with
   op-owned verdicts and op-registered undo+redo; mints latch; the locked
   half re-checked per keystroke in the card gate; `branchDisplayed`'s
   refused-flush behavior is her ruled Q-M1 (a), seed-from-ledger.
10. **Block multi-select:** ids-only selection (P1), pruned on every
    adopt; picking exits on BOTH dismiss roads; the outcome decides, not
    the re-read; refusal keeps picks (#59(k)); the confirm composes the
    tray's road phrase so the two delete doors cannot promise different
    roads back; the act composes the ONE structural delete road.
11. **New Note / New Chapter in a book:** refuse-before-mint through
    `newPostInReading` (gate inside the transaction); chapters by ID with
    empty-chapter headers and the truncation-aware `populated` answer;
    `doorRefusal` renders beside the doors; refusal words forward to the
    phone's ONE reading-refusal home.
12. **No-redirect (§4.4):** `MobileNoRedirectSweepTests` green by name in
    this session's own run; the lenses dangling-pick fork, the tray row
    faces and the selection copies are all RECORDED forks on the
    KnownIssues forked-brains row (owned), not silent drift.
13. **The note clipboard:** one pasteboard writer; the export projection
    byte-identical rule; the callout fence's silent road now SPEAKS
    (`copiedSavedTakes`); the `exportMapped` fix rides the owned #94
    hoists (VM-1).
14. **P1/memory on the phone:** every held listing in the round's body is
    windowed+probed or bounded by data/author-scale with the reason at
    the site; the block TOC is deliberately unwindowed with the lazy-rows
    argument; the shelf split is a pure brain with her floor guarantee
    pinned; no `DragGesture` outside the band's named space; no new
    corpus-shaped read found on any keystroke road.
15. **Hollow-checked and NOT raised:** the withdrawn quick note's stale
    undo entry (KnownIssues row, owned); the Trash/tray observation's
    `now` captured once per visit (short-lived pushed surfaces — no wrong
    output within a visit); the unarchive refusal's `.putBack` arm
    (recorded at the code with the durable `.unarchive`-arm fix named);
    the structural-flight keystroke fence (VM-2 — ticketed and held by her
    explicit ruling; nothing new found that changes its shape); the
    `commitNow` latch gap (recorded at `MobileBlockMenu`, duplicate
    savepoint = append-only, never a loss).

---

## Disposition slots (the orchestrator's)

| # | severity | disposition |
|---|---|---|
| 1 | MINOR | |
| 2 | MINOR | |
| 3 | MINOR | |
| 4 | MINOR | |
| 5 | MINOR | |
| 6 | NIT | |

---

## FIX WAVE (implementer)

**Implementer:** Opus, 2026-10-06, briefed by the orchestrator with exactly
three findings — MINOR 2, MINOR 3 (+ its `VersionActs` rider), MINOR 4.
MINOR 1 / NIT 6 (fixed by the orchestrator, `ddc68c6e`), MINOR 5
(dispositioned deferred) and the Observation are NOT touched here.

### LIVE STATUS

| piece | state |
|---|---|
| MINOR 2 — the `.bookless` empty state | NOT-STARTED — design: the store-empty trio renders only where the store's note listing is genuinely empty; `.bookless` with notes present gets its own per-door line (PROVISIONAL copy, in `MobileListingFilter` beside `noBooksLine`) |
| MINOR 3 — the quick note's `.lockedPost` arm + the `VersionActs.words` rider | NOT-STARTED — design: compose `SealedNoteCopy.sentence(act:words:)` (`.phone` in the box; `VersionActs.words` takes the platform's `SealedNoteCopy.Words` as a REQUIRED parameter, each call site passing its own) |
| MINOR 4 — `VersionActs.save`/`restore` past a refused flush | NOT-STARTED — design: the flush reports whether the post's buffer landed; both acts refuse (a typed `VersionActs` refusal worded with the standing unsaved-changes sentence) when it did not |
| Final full mobile suite | PENDING |
