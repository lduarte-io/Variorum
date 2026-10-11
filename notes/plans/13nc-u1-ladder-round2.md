# 13n-c U1 — ladder round 2 (cold review, opus-reviewer, 2026-10-11)

**Reviewer model (stated per the plan's §5 rule): Opus 5.5 (`claude-opus-5-5`), xhigh.**

**Diff reviewed:** `9b1ec3dd..HEAD` (HEAD = `e969c063`), with round 2's job: re-review the round-1 fix
`c1047097` (F1 — `MCPGrantRule.decide` answers `rungTooLow` before the fence when a LIVE grant reaches
the note) and anything round 1 missed. **Anchor:** `notes/plans/phase-13n-c-mcp-launch-readiness.md`
read whole; the round-1 record `notes/plans/13nc-u1-ladder-round1.md` (findings + the orchestrator's
dispositions) as my anchor; `notes/REVIEW_PROMPT.md` run verbatim. No plan-time "Review foci" section
exists for 13n-c (round 1 grepped; I re-grepped the plan).

**Status:** IN PROGRESS — findings written incrementally below.

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
arrivalOnly.id]`), and `notebook` is the TRAIT book (`profile: "journal"`, `:256`). Since R-AIR-1 the
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

U3's brief (R-AIR-7's in-note "why") should also name this leg, so the indicator can say "a day entry
— asks every time" rather than nothing.

### R2-3 — [MINOR] · `Queries.mcpSharedRows` (`MCPGrantQueries.swift:166-185`) + the pane row (`MCPPane.swift:273`) · a grant whose target the fence NOW blocks stays listed under "Shared with AI"; R-AIR-1 opens a new, natural road into that state

**Evidence (traced):** she grants "dream journal" (a trait book, grantable only since R-AIR-1) read
always. Later she presses Use as Daily Journal on it (`ShelfViewModel.swift:466` →
`setDailyJournalBook` moves the `'daily'` marker), and `mcpBookFacts` now reads `.journal`. Then
`reaches` is false for the book and every member is fenced. The Bookcase chip drops
(`mcpReachableBookIDs` re-decides through the rule). But `mcpSharedRows` lists every unrevoked,
unspent grant with only its title and reads no fence. So the pane keeps showing "dream journal · book ·
claude-code · read · always" for a grant that reaches nothing. The class is not new: the Private mark on
a granted book (13n-b) and designating a granted PLAIN book daily both reach it. R-AIR-1 makes it
likelier, because a journal-style book is the most natural candidate to become the daily Journal. I
found no record of this state in the 13n-b plan.
**Not a U1 regression:** no red-on-old pin exists for U1, because the honest face does not exist yet.
**Fix:** route to U2 (the pane rows) and U3 (the pure "why" function — grant rows + facts → reach). A
Shared row whose target is fenced says so (e.g. "reaches nothing while it is your daily Journal /
Private"). If neither unit takes it, it becomes a ledger row and a ticket at closeout.

### R2-4 — [NIT] · doc comments R-AIR-1 left stale · `MCPGrantRule.swift:266`, `MCPWriteTools.swift:445-446`

**Evidence:** `decideWing`'s doc says "so a wing never lists a journal". A wing now lists a journal-trait
book's notes, so it should say "never lists a fenced note". `noteIntoBook`'s doc says "a journal or
Private note is reachable per-ask only". It should say a daily-Journal or ⌘J entry, or a Private note.
These are comments only, so no pin is owed. The same files' headers were updated in this diff.
**Fix:** two comment edits at the next touch (U2/U6).

### R2-5 — [NIT] · the plan's CLOSEOUT CANON-DELTA CHECKLIST (the AF-6 line) · F1's refinement is not named beside the supersession

**Evidence:** the checklist reads "AF-6's fenced clause superseded (T-2/F-7)". After `c1047097`, the
supersession is not simply "fenced = the one answer". A LIVE per-ask grant holder asking past its rung
on a fenced note hears `rungTooLow` + the asked sentence, which is AF-6's own posture kept for that one
case. A future reader of AF-6 + the pointer would conclude "fenced always answers the one answer".
**Fix:** add one clause to the checklist line naming F1 / F-10.

### R2-6 — [NIT, routed] · the confirm's clause on a ONCE grant (D-3 / P-13nc-3) · "Grant read in “dream journal” once, including to future entries" reads as ongoing reach for a grant that lives one content read

**Evidence:** AF-7 as amended (`MCPGrantRule.spends`, `:254-257`): a once book READ grant is spent by
its first content read. The clause is literally true only until that read. P-13nc-3 already names
"every duration", so this is not a defect. The note is that her ballot should show the ONCE sentence
literally, since that is the case where the clause can mislead.
**Fix:** at the copy pass, show P-13nc-3's once sentence verbatim beside her always example. No code
change in U1.

### R2-7 — [NIT, routed to U5] · `MCPReadTools.swift:495-500` (search scoped to a note) · F1's stated rationale ("never 'or doesn't exist' about a note the client can read this second") holds on `decide`'s road only

**Evidence:** search serves STANDING reach only (13n-b's recorded restriction, the round-1 F1 of
13n-b). So a client whose only grant on a note is an unspent ONCE grant, which `read_note` honors,
hears the one `notShared` answer ("…or doesn't exist") from `search(note_id:)`. This holds for fenced
and unfenced notes alike, so there is no oracle and no U1 regression. It is the same dishonesty F1
fixed, left on another road by design.
**Fix:** none in U1. U5's rewrite of `MCPSession.instructions` (the AI's advice) should say that search
reaches standing grants only and that a once grant reads through `read_note`, so a model does not drop
a live id (the same family as round 1's F5).
