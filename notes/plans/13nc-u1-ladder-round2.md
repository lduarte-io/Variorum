# 13n-c U1 — ladder round 2 (cold review, opus-reviewer, 2026-10-11)

**Reviewer model (stated per the plan's §5 rule): Opus 5.5 (`claude-opus-5-5`), xhigh.**

**Diff reviewed:** `9b1ec3dd..HEAD` (HEAD = `e969c063`), with round 2's job: re-review the round-1 fix
`c1047097` (F1 — `MCPGrantRule.decide` answers `rungTooLow` before the fence when a LIVE grant reaches
the note) and anything round 1 missed. **Anchor:** `notes/plans/phase-13n-c-mcp-launch-readiness.md`
read whole; the round-1 record `notes/plans/13nc-u1-ladder-round1.md` (findings + the orchestrator's
dispositions) as my anchor; `notes/REVIEW_PROMPT.md` run verbatim. No plan-time "Review foci" section
exists for 13n-c (round 1 grepped; I re-grepped the plan).

**Status:** COMPLETE — 0 BLOCKER · 0 MAJOR · 4 MINOR · 5 NIT; the round-1 fix `c1047097` re-traced CORRECT.

## Scope, said first (the brief's rule)

By the letter of the opus-reviewer brief, this diff is NOT outside Fable's mandatory scope: it
changes a default's meaning (what the fence covers — the plan's own FABLE-OWED rows F-1 and F-5 say
so) and edits the security rule itself (`MCPGrantRule.decide`, row F-10). It touches zero `Sync/`,
custody/keychain, schema/migrations or editor seam (verified: `git diff --name-only` over the range,
plus a grep for the seam and custody file names). The orchestrator already knows this: round 2 runs on
Opus only because her Fable budget died at HTTP 429 (the round-1 record's dispositions), and rows
F-1/F-5/F-10 carry the debt. **Nothing I found widens the Fable debt beyond those three rows.** The
re-spawn decision stays the orchestrator's; I proceeded with the review.

## Findings (severity-ranked; format: [severity] · where · what · evidence · fix)

### R2-1 — [MINOR] · `Tests/VariorumCoreTests/MCPGrantOperationsTests.swift:276-294` (`theJournalLegsFenceExactlyAsRuled`) · the ritual made "an arrival is never membership" hollow for the journal leg

**Evidence (traced):** U1's ritual re-pointed the archived and deleted fixtures from trait books to
`'daily'` bearers, but the ARRIVAL row still goes into `notebook` (`:281`, `arguments: [notebook.id,
arrivalOnly.id]`), and `notebook` is the TRAIT book (`profile: "journal"`, `:256`). Since VX-163 the
trait is not a fence leg. So `arrivalOnly`'s only `reading_post` row points at a book that
`dailyJournalLegForBook` rejects, and the `member_journal` EXISTS (`MCPGrantQueries.swift:300-302`)
reads false whether or not it filters `rp.status = 'member'`. The assertion at `:294` is now green on
both sides of that clause. The only other arrival-vs-fence pin is `MCPPrivateMarkTests:76/90`, which
guards the PRIVATE leg's own status clause, not the daily leg's. The U1 record's mutation set M1–M5
never dropped the status clause. The state is reachable: `shelveInDailyJournalBook` BELLS an
owned-elsewhere entry at the daily Journal's door as an arrival (AppSpec §9, the 13i-c op family), and
13n-b's rule that an arrival is never membership governs exactly that row.
**Pin (red-on-old, mutation-shaped):** point the arrival row at `daily.id`. Then deleting
`AND rp.status = 'member'` from the `member_journal` EXISTS turns `:294` red. Today the same mutation
stays green.
**Fix:** one argument (`notebook.id` → `daily.id`), plus a one-line comment naming the reason, plus
that mutation check recorded. The ritual's bar ("each pre-existing pin updated, named in the record")
was met for the assertions that changed. It was missed for an assertion whose fixture silently changed
meaning.

### R2-2 — [MINOR, product-question class — no pin owed] · D-1 / P-13nc-1 (the plan's ORCHESTRATOR DECISIONS; `MCPGrantQueries.swift:268-271`) · a ⌘J day entry that GRADUATES into an ordinary book stays per-ask forever, and no face says so

**Evidence (traced):** D-1 keeps the note's own `profile='journal'` leg. The only doors minting it are
the daily book's New Entry and ⌘J/Today's Entry (`BookStructureModel.swift:691`, `:911`) and the
phone's Today door (`MobileTodayDoor.swift:43`), all through `createOrOpenJournalEntry`
(`Operations+Container.swift:80`). This re-confirms D-1's trace. NO shipped door ever clears that
profile: `setProfile` (`Operations+Container.swift:398`) has no app caller.

The scenario: she ⌘J's an entry, then moves it from the daily Journal into "essays" to develop it into
a post. CoreDescription pillar 8 says "an entry can graduate to a full post with zero migration". She
then grants "essays" read always. The sheet says "“essays” — its notes, takes and tags", and the
confirm says "…always, including to future entries". The AI's `list_notes(book_id:)` omits the entry,
and `list_books` counts it out (the honest-count rule). The pane's wing line says "everything in Home
except your daily Journal and anything Private, which always ask", and the entry is neither, read as the
book. The entry can never take a standing grant again; only per-ask grants reach it.

Round 1's F6 caught the ask lead's wording only. This is not a bug: D-1 is a logged PROVISIONAL, in the
conservative direction (R-13nb-1's more asks, never fewer). The finding is that its ballot line
("P-13nc-1 — D-1 (the ⌘J edge kept)") doesn't put this consequence in front of her. Graduation is
named in her vision document, so she should rule knowing it.
**Fix (author-only call — nothing to build in U1):** widen P-13nc-1's #211 entry and the F-1
FABLE-OWED row with the graduation consequence and its three options:
- (a) keep D-1 and say it in the copy (e.g. "…your daily Journal, ⌘J entries wherever they live, and
  anything Private…");
- (b) the membership-only alternative (one SQL line — a ⌘J entry released from the daily Journal
  becomes standing-shareable);
- (c) a later door that lifts a graduated entry's day shape.

U3's brief (VX-164's in-note "why") should also name this leg, so the indicator can say "a day entry
— asks every time" rather than nothing.

### R2-3 — [MINOR] · `Queries.mcpSharedRows` (`MCPGrantQueries.swift:166-185`) + the pane row (`MCPPane.swift:273`) · a grant whose target the fence NOW blocks stays listed under "Shared with AI"; VX-163 opens a new, natural road into that state

**Evidence (traced):** she grants "dream journal" (a trait book, grantable only since VX-163) read
always. Later she presses Use as Daily Journal on it (`ShelfViewModel.swift:466` →
`setDailyJournalBook` moves the `'daily'` marker), and `mcpBookFacts` now reads `.journal`. Then
`reaches` is false for the book and every member is fenced. The Bookcase chip drops
(`mcpReachableBookIDs` re-decides through the rule). But `mcpSharedRows` lists every unrevoked,
unspent grant with only its title and reads no fence. So the pane keeps showing "dream journal · book ·
claude-code · read · always" for a grant that reaches nothing. The class is not new: the Private mark on
a granted book (13n-b) and designating a granted PLAIN book daily both reach it. VX-163 makes it
likelier, because a journal-style book is the most natural candidate to become the daily Journal. I
found no record of this state in the 13n-b plan.
**Not a U1 regression:** no red-on-old pin exists for U1, because the honest face does not exist yet.
**Fix:** route to U2 (the pane rows) and U3 (the pure "why" function — grant rows + facts → reach). A
Shared row whose target is fenced says so (e.g. "reaches nothing while it is your daily Journal /
Private"). If neither unit takes it, it becomes a ledger row and a ticket at closeout.

### R2-4 — [MINOR, product-question class + a characterization pin owed] · VX-163 × `setDailyJournalBook` (`Operations+Appearance.swift:430-452`) · "Use as Daily Journal" now MOVES THE FENCE: the outgoing Journal's hand-filed notes become standing-shareable at once, and the door says nothing

**Evidence (traced):** `setDailyJournalBook` demotes every other live `'daily'` bearer to
`journalTraitProfile` (`:439-443`) and stamps the designee. Before U1 the demoted book stayed fenced,
because the trait was a fence leg, so changing her daily Journal never changed what the MCP door
reached. After U1, `dailyJournalLegForBook` no longer matches the demoted book. Every note she filed
into the old Journal BY HAND then loses the member leg; these are the notes with no own profile (the
U1 suite's own "a loose page" shape). Those notes become reachable at once by any standing wing grant
on Home and by the OPEN BOOK, which reaches every approved client, always. Its ⌘J/New-Entry entries
stay fenced through their own profile. That is D-1, and this scenario is D-1's strongest
justification. Meanwhile the incoming designee's members become fenced.

Both doors are ordinary, unrelated to sharing: the Mac Bookcase (`ShelfViewModel.swift:466`) and the
PHONE's book details (`MobileBookDetails.swift:185`). The marker is a synced CAS write, so a designation
change made on the phone changes what the Mac's MCP door shares. The plan's MOBILE PARITY line ("VX-163
changes no synced row") is true but incomplete: a synced row's fence MEANING changed. The sync keeper
repair (`Repairs.swift`, `convergeDailyJournalDuplicates`) is NOT a road: it moves the loser's
memberships into the keeper, so they stay fenced. I read it and found that.

This IS VX-163's ruled letter: the fence keys on the marker, and moving the marker moves the fence.
So this is not a defect. But it is a fewer-asks road (against R-13nb-1's "more asks, never fewer"
posture) opened by an act that is not about sharing, and her "never surprised" (VX-164) has no face
for it. Neither D-1, VX-163's record, nor the U1 traces name it. The U1 record's "the marker, not the
keeper" note mentions the demotion only as convergence.
**Pin (red-on-old — a characterization of the ruled outcome, so it is deliberate rather than
incidental):** designate daily book A; file a plain note into A by hand; ⌘J an entry into A; then call
`setDailyJournalBook(B)`. Expect the hand-filed note's `fence == nil`, the ⌘J entry's
`fence == .journal`, and B's members fenced. On the pre-U1 tree the hand-filed note reads `.journal`,
so the pin is red.
**Fix:**
- (1) that pin;
- (2) a #211 question, hers: should "Use as Daily Journal" say so when MCP is on with an approved
  client (VX-272's gating — e.g. "notes you filed in “journal” by hand will be shared like any
  book's"), or should a demoted ex-daily book keep fencing?
- (3) the F-5 FABLE-OWED row gains this consequence, since it is precisely "what the fence covers";
- (4) the closeout's MOBILE PARITY line names the phone's designation door as a road that changes the
  Mac door's reach.

### R2-5 — [NIT] · doc comments VX-163 left stale · `MCPGrantRule.swift:266`, `MCPWriteTools.swift:445-446`

**Evidence:** `decideWing`'s doc says "so a wing never lists a journal". A wing now lists a journal-trait
book's notes, so it should say "never lists a fenced note". `noteIntoBook`'s doc says "a journal or
Private note is reachable per-ask only". It should say a daily-Journal or ⌘J entry, or a Private note.
These are comments only, so no pin is owed. The same files' headers were updated in this diff.
**Fix:** two comment edits at the next touch (U2/U6).

### R2-6 — [NIT] · the plan's CLOSEOUT CANON-DELTA CHECKLIST (the AF-6 line) · F1's refinement is not named beside the supersession

**Evidence:** the checklist reads "AF-6's fenced clause superseded (T-2/F-7)". After `c1047097`, the
supersession is not simply "fenced = the one answer". A LIVE per-ask grant holder asking past its rung
on a fenced note hears `rungTooLow` + the asked sentence, which is AF-6's own posture kept for that one
case. A future reader of AF-6 + the pointer would conclude "fenced always answers the one answer".
**Fix:** add one clause to the checklist line naming F1 / F-10.

### R2-7 — [NIT, routed] · the confirm's clause on a ONCE grant (D-3 / P-13nc-3) · "Grant read in “dream journal” once, including to future entries" reads as ongoing reach for a grant that lives one content read

**Evidence:** AF-7 as amended (`MCPGrantRule.spends`, `:254-257`): a once book READ grant is spent by
its first content read. The clause is literally true only until that read. P-13nc-3 already names
"every duration", so this is not a defect. The note is that her ballot should show the ONCE sentence
literally, since that is the case where the clause can mislead.
**Fix:** at the copy pass, show P-13nc-3's once sentence verbatim beside her always example. No code
change in U1.

### R2-8 — [NIT, routed to U5] · `MCPReadTools.swift:495-500` (search scoped to a note) · F1's stated rationale ("never 'or doesn't exist' about a note the client can read this second") holds on `decide`'s road only

**Evidence:** search serves STANDING reach only (13n-b's recorded restriction, the round-1 F1 of
13n-b). So a client whose only grant on a note is an unspent ONCE grant, which `read_note` honors,
hears the one `notShared` answer ("…or doesn't exist") from `search(note_id:)`. This holds for fenced
and unfenced notes alike, so there is no oracle and no U1 regression. It is the same dishonesty F1
fixed, left on another road by design.
**Fix:** none in U1. U5's rewrite of `MCPSession.instructions` (the AI's advice) should say that search
reaches standing grants only and that a once grant reads through `read_note`, so a model does not drop
a live id (the same family as round 1's F5).

### R2-9 — [NIT] · the plan file (THE one running record) · round 1's routed findings live only in the round-1 record, and the U1-4 row names a sentence that no longer ships

**Evidence:**
- The plan's LEDGER carries row 3b for round 1's F2 only. F4 (→ U2's brief), F5 (→ U5's brief) and F6
  (→ P-13nc-1 / the copy pass) are routed only in `13nc-u1-ladder-round1.md`'s dispositions table. The
  PROVISIONALs list still reads "P-13nc-1 — D-1 (the ⌘J edge kept)" with no F6 nuance. U2/U5's briefs
  are written just-in-time, possibly by a fresh orchestrator after a context death, so these routings
  are one missed read away from loss.
- The U1-4 row still says the wire's fenced BOOK refusal reads "That book is the daily Journal. Its
  entries…". The F-7 (a) build (`df704250`) replaced it with the one answer, and grep finds no such
  string in `Sources/` or `App/`.

**Fix:** one ledger row, "Stage A routed findings", naming F4 → U2, F5 → U5, F6 → #211/P-13nc-1 and
this round's routed items (R2-2/R2-4 → #211 + FABLE-OWED F-1/F-5; R2-3 → U2/U3; R2-7 → copy pass;
R2-8 → U5). Plus an in-place "(superseded by F-7 (a), `df704250`)" note on the U1-4 row.

## Re-review of the round-1 fix `c1047097` (the cross-model flow's sanity pass, folded into this round)

**Verdict: CORRECT, contained, well-pinned.**
- `decide` (`MCPGrantRule.swift:225-243`) hoists the `rungTooLow` branch above the fence. It is
  behavior-identical for UNFENCED targets (`offersAlways: fence == nil` → true, as before; still pinned
  by `MCPGrantRuleTests.aGrantCoversItsRungAndEveryRungBelowItAndNothingAbove`, `:93-105`). It is also
  behavior-identical for fenced BOOKS: `reaches` is false for every grant (`:302-303`), so `reaching` is
  empty and the fence branch answers.
- For a fenced NOTE, `reaching` can only hold live, note-scoped, non-always grants naming that very
  note (`:293-296`). So `rungTooLow` discloses nothing beyond the client's own grant, and `isLive`
  (`:108-110`) drops a spent once grant and a revoked one, so a lapsed grant falls through to the one
  answer (pinned at decide level and on the wire).
- `offersAlways` stays false on a fenced target. Her sheet is safe independently anyway:
  `MCPAsk.offersAlways` derives from the fence (`MCPWriteSupport.swift:62`) and `MCPDoor.durations`
  reads it (`MCPDoor.swift:384`).
- No consumer branches on `.fenced` vs `.rungTooLow` except `MCPRefusalCopy` (grepped every source and
  test). The in-transaction guards (`MCPWriteTools+Edit.refused`) now speak `rungTooLow` without the
  asked sentence where a guard re-decides — the same as their unfenced behaviour, since no ask is
  queued inside a guard.
- **Oracle check:** a client holding BOTH a per-ask grant on a note and a wider grant can infer a fence
  when the wider grant stops covering a note its per-ask grant still reads. That holds before and
  after F1 (`read_note` alone shows it) and is inherent to the grammar; F1 opens nothing new.
- **Red-on-old:** traced by construction rather than re-reverted (read-only round). On the old branch
  order the asserted inputs return `.fenced`: 4 decide-level issues (2 fences × the connected and
  unspent-once cases), invariant 5's fenced+reaching worlds, and 1 wire issue (the text equality; the
  ask assertions hold on both sides). That matches the commit message's counts.
- The server-side change in `c1047097` is comment-only (checked line by line), and zero app files
  changed after the Mac run at `4ee62dd2`. **No Mac re-run is owed for this fix.**

## Clean bill (load-bearing things specifically checked and found solid)

- **Suites, by my own hands (headless, no stage needed):** `swift test --filter
  "VariorumCoreTests.MCP"` → 95 tests / 11 suites green (the six fence suites alone 46/6, incl.
  `MCPFenceRekeyTests` 6 tests). `--filter VariorumMCPTests` (the whole server target) → **69 tests / 9
  suites green in 2.5 s**, no VX-132 stall, no stray process left. Both match the orchestrator's rerun
  record (MCP 69/9).
- **The re-key's premise:** her real daily Journal wears `'daily'` — v1_18 step 8 stamped the
  designated `'journal'` book (`Migrations.swift:756-768`), and every daily mint since stamps it (the
  suite asserts the shelved book's profile is `"daily"`). A pre-13i-a plain-profile designee was never
  fenced by the OLD leg either, so U1 changes nothing there.
- **NULL safety of `NOT (dailyJournalLegForBook)`:** `createReading`'s default profile is nil, and
  `theGrantSheetOffersExactlyTheBooksAGrantMayName` asserts the plain books are offered, so the
  `IS NOT NULL` guard is pinned. Without it, `NOT (NULL = 'daily')` would drop every plain book.
- **No agent can move the fence:** no tool in `Sources/VariorumMCP` writes a book profile or the
  marker (`create_book` → `createBook(named:inWing:)` takes no profile; no `setDailyJournalBook` /
  `setJournalTrait` on the wire). The sync keeper repair merges losers' memberships INTO the keeper, so
  convergence never unfences. Her own door is the only road (R2-4).
- **No id leak through listings:** `list_notes`' `book_ids` comes from a readable note's facts, and a
  member of a fenced book is itself fenced, so a fenced book's id never surfaces. `list_books` counts
  through the same per-note rule (the trait book's ⌘J entry counts 0, pinned).
- **D-1's trace re-verified:** the own-profile minters are exactly the daily book's New Entry and
  ⌘J/Today (`BookStructureModel.swift:691/911` — the non-daily journal books mint `.generic`, its
  `:658-672` doc) and the phone's Today door (`MobileTodayDoor.swift:43`).
- **The one answer (T-2/F-7 (a)) still holds after F1** for every UNREACHED fenced target. The
  byte-identity pin covers `read_note`, `export_note`, note-scoped `search`, `set_entry_date`, and
  zero-passage `search` — including the member-only word. The F-7 (a) wire pin asserts the Private
  book's answer equals a random book id's.
- **VX-269 in the sheet:** the only `confirm`/`confirmParts` caller is `MCPGrantSheet` (grepped).
  The approve-and-grant path shares the button, so the clause shows there too. 600 wide fits inside
  Settings' fixed 720×520 window (`AppSettingsView.swift:161`).
- **Discipline:** commits in range carry no `Co-Authored-By`/`Claude-Session` trailer (grepped).
  There are zero `Sync/`, persistence/migration, custody/keychain or editor-seam files in the range.
- **Round-1 dispositions landed as recorded:** the closeout canon-delta checklist exists (F3), ledger
  row 3b tracks F2, and FABLE-OWED F-10 is written. (R2-6 and R2-9 add to them.)
- **Honest tracking:** U1's REAL Claude Code live round and the dev-store walk are HELD (the locked
  session) and said so in LIVE STATUS. This round's bill is code review, NOT U1's use-shaped evidence
  (CLAUDE.md's sizing rule — a batch closes only on use-shaped evidence). U1 stays open on those until
  they run.

## Round-2 verdict

**0 BLOCKER · 0 MAJOR · 4 MINOR · 5 NIT.** The round-1 fix is correct and needs nothing.
- **R2-1** is the one code-side fix worth landing now: a one-argument fixture re-point plus its
  mutation check, a test-strength regression the ritual introduced.
- **R2-2 and R2-4** are consequences of D-1 and VX-163 that belong on her #211 ballot and the
  FABLE-OWED F-1/F-5 rows. R2-4 also owes a characterization pin, red on the pre-U1 tree.
- **R2-3** routes to U2/U3.
- **The NITs** are doc, checklist and brief routing.

**No new BLOCKER or MAJOR, so the ladder rule earns no round 3.**

---

## DISPOSITIONS (orchestrator, Opus — same-model flow: the orchestrator arbitrates against the spec)

| # | Severity | Disposition |
|---|---|---|
| R2-1 | MINOR | **FIXED `b3cd0565`** — the arrival row moved into THE daily Journal; dropping the daily leg's `status = 'member'` clause now turns the pin RED (mutation M-a: 1 issue), restored from the commit. |
| R2-2 | MINOR (hers) | **#211 + F-1:** D-1's consequence said plainly — a ⌘J entry stays per-ask wherever it is filed, and no shipped door clears a note's own day shape; options (a) keep D-1 and say it in the copy · (b) fence on membership only · (c) a later door that lifts a moved entry's day shape. U3's in-note "why" names the case ("a daily Journal entry — shared one ask at a time"). |
| R2-3 | MINOR | **ROUTED TO U2** (the pane's shared rows): a grant that reaches nothing (its target fenced since) is shown as inert, never as shared — P-13nb-U2-3's own letter ("the faces must not call such a grant 'shared' while it is inert"). |
| R2-4 | MINOR (hers) + pin | **PINNED** (`designatingAnotherDailyJournalMovesTheFence` — RED on the pre-U1 query file, 2 issues, restored) · **#211** question (should "Use as Daily Journal" say what it un-fences, or a demoted book keep fencing?) · the F-5 row names the consequence · the MOBILE PARITY line at closeout says the marker is synced and the phone's book-details door moves it too. |
| R2-5 | NIT | **FIXED `612de48c`** (comment-only). |
| R2-6 | NIT | **Closeout checklist** — the AF-6 line names F1's refinement (a live per-ask holder hears `rungTooLow` + the asked sentence). |
| R2-7 | NIT | **Copy pass (hers) under P-13nc-3** — "…once, including to future entries" shown literally in the handoff. |
| R2-8 | NIT | **ROUTED TO U5** — the AI's advice says `search` reaches standing grants only (a once grant reads by id). |
| R2-9 | NIT | **FIXED in the plan** — a "Stage A routed findings" ledger row; the U1-4 row's fenced-book sentence corrected by pointer to F-7 (a). |

**STAGE A LADDER CLOSED at round 2** (0 BLOCKER / 0 MAJOR in round 2 — no round 3 earned). U1's
use-shaped evidence (the GUI walk + the real Claude Code live round) stays HELD by the locked
session — U1 is NOT closed as a unit until it runs.
