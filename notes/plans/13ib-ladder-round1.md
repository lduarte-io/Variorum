# 13i-b — LADDER ROUND 1 (cold review, fable-reviewer, 2026-10-01)

**Scope:** `git diff dd1b9c0d..7cf0dc88` — the combined 13i-b diff (U1–U4 + the adjudication
batch; 52 commits, ~10.5k insertions over 64 files), reviewed per `notes/REVIEW_PROMPT.md`
verbatim. Review anchors read whole in this session: `notes/plans/phase-13i-b-gatherings.md`
(plan + all four unit records + the adjudication batch + ledger), the sitting record
(`notes/plans/phase-13i-sitting-record-2026-09-30.md` §3/§4/§5/§8/§14/§17–§25), the 13i-a
execution record (§4/§5/§9), CLAUDE.md + AppSpec + OverallModel + CoreDescription,
KnownIssuesAndTechDebt. No "Review foci" section exists in the plan; the binding principles
P-1…P-9 and the sitting rulings stood in as mandatory checks. Every Sources/ file in the diff
was read in full; test files were read for the load-bearing claims; targeted suites re-run
(below). No `Sync/`, `Server/`, schema or migration lines exist in the diff (verified against
the diff stat and the tree) — the SyncSpec posture review was done against the plan §2.7's
letter (S1-shaped writes, shipped R1, documented tombstones-win).

**STATUS: ROUND 1 FINDINGS COMPLETE.**

---

## FINDINGS (severity-ranked)

### F-R1-1 · MAJOR · `Sources/VariorumCore/Operations/Operations+ReadingConversion.swift:231` (revertSmartConversion) × `Operations+Intake.swift:263` (intakePairState) — an undone bind's member tombstones permanently deafen a re-bound book's intake for those pairs

**What's wrong:** P-13ib-6's inverse tombstones every live row on the reverted gathering
with its `status` left as `'member'`. Under U1's tombstone-means-decided table, a tombstoned
MEMBER row is `PairState.leftAsMember` — "decided against every occasion" (the her-removal
class). But these tombstones record no decision of hers about the pair — they record "a
gathering holds nothing." If the row is later bound AGAIN, every such pair is silently dead
to intake forever.

**Evidence (traced mechanism, inputs → wrong outcome):**
1. Gathering G (rule `#x`), note A tagged `#x` → G shows A.
2. Bind → `convertSmartReadingToCurated` mints a live member row (G, A).
3. ⌥⌘Z → `revertSmartConversion` tombstones the row; `status` stays `'member'`
   (`Operations+ReadingConversion.swift:244–249` sets only `deletedAt`).
4. She untags A (G no longer shows it), then re-binds by the door (any new structural act
   also clears the redo road back). The fresh bind materializes only the CURRENT assembly
   (`:124–127`, `livePairRow` — live rows only), so (G, A) gets no new row.
5. She re-tags A — a fresh applying act. `intakeAfterTagging` → `intakePairState` reads
   `left > 0` → `.leftAsMember` → `IntakeDecision.verdict` returns `.nothing`
   (`Domain/IntakeDecision.swift:141–143`). Backfill/catch-up sweeps exclude the pair too
   (`intakeSweep`'s `NOT EXISTS` over ANY row, `Operations+Intake.swift:117`).
6. The bound book's own sheet promised "it keeps collecting after you bind it: new notes
   that match its rule join at the end" (`BindCopy.keepsCollecting`) — false for exactly
   these notes, silently and permanently; only a hand-add recovers the pair.

The asymmetry sharpens it: an ARRIVAL taken by the same undo reads `.dismissed` and rings
again on a fresh act (P-13ib-U1-1, ratified) — only the member-status residue is a
permanent deafening. The intake SOAK cannot see this (its 15 acts include no bind/undo).

**Red-on-old pin:** core — gathering + rule, tag A, bind, structural undo, untag A, bind
again, re-tag A → expect a live pair row (arrival or seat) for (book, A). RED on the
current tree (`reading_post` count for the pair stays 1, tombstoned); the control (a note
still matching at re-bind) stays green.

**Proposed fix:** mechanical shape — `revertSmartConversion` records the taken rows as the
DISMISSAL class rather than the removal class (flip `status` → `'arrival'` as it
tombstones, with the redo's box carrying `(id, status)` pre-images so redo restores
exact rows byte-true), OR `intakePairState` learns to rank these rows as `.dismissed`.
Either changes what a tombstoned row MEANS at one site, and the first touches the redo
contract — so the chosen reading should ride the morning bundle beside P-13ib-U3-3
(same undo, same rows) before it lands. The pin above is buildable against either shape.

### F-R1-2 · MINOR · `App/Variorum/Variorum/Features/Shelf/ShelfViewModel.swift:197–206` (spawnBook) — the sole-tag auto-tag derivation counts tags under NOT, so a negated-tag rule spawns a book whose outflow is the very tag its rule excludes

**Evidence:** `RuleGrammar.tagIDs` descends `.not` (`Domain/RuleGrammar.swift:160`), so a
gathering whose rule is `NOT #a` yields `ruleTagIDs == {a}` → count 1 → the spawned book's
`auto_tag_id = #a`. Notes then minted or hand-added in that book are tagged `#a` — the one
tag the book's rule rejects. (A two-tag rule like `#a ∧ NOT #b` lands in the unset arm and
is fine; the broken cell is a rule whose ONLY tag reference is negated.) Her morning ruling
reads "where the copied rule references exactly ONE distinct tag" — the honest reading of an
outflow is the sole POSITIVE tag.

**Red-on-old pin:** spawn from a `{"not":{"tag":…}}` gathering → expect `autoTagId == nil`;
RED on the current tree (it is the negated tag).

**Proposed fix:** derive from positive-polarity tag references only (a small
`positiveTagIDs` walk, or a polarity check before adopting the sole tag); the PROVISIONAL's
bundle paragraph gains one sentence naming the boundary.

### F-R1-3 · MINOR · `App/Variorum/Variorum/Features/Readings/BookOrderAndConversion.swift` (BindCopy.spawnMessage) × `Operations+Reading.swift` (createReading backfill guard) — the spawn sheet's promise is false for a RULE-LESS gathering

**Evidence:** `BindCopy.spawnMessage` promises "A new book with the same rule: the notes it
matches now join it, and new matches keep joining." A rule-less gathering (exactly what
"Create Smart Book" mints today — the U4 record's F-U4-7) shows EVERY note in its wing, but
the spawned book copies `querySpec = nil`, `createReading`'s backfill is guarded by
`intakeRuns` (readable rule required — P-13ib-5), so ZERO notes join and the book never
collects; the receipt then says "Made “X” — 0 notes joined, and it keeps collecting."
Both clauses false, on a state one shipped door mints. (This is F-1's class — a door
sentence the mechanics make false — which this phase itself treated as must-carry.)

**Pin:** mounted — spawn from a rule-less gathering; assert the door speaks the no-rule
truth (whatever shape is chosen) rather than "the notes it matches now join it". RED on
the current words.

**Proposed fix:** smallest honest shape — the spawn door on a rule-less gathering words its
sheet for that case ("it has no rule, so the book starts empty and collects nothing until
you give it one") or routes her to Edit Rule first; whether a rule-less gathering should
offer the spawn at all is product-flavored — one line in the morning bundle beside F-U4-7
(the same root: a gathering born without a rule).

### F-R1-4 · MINOR · doc alignment, two letters the closeout's canon delta should carry (no behavior change; no pin — written justification per the architectural-finding rule)

(a) **AppSpec §7 `reading_post` note:** "dismissing writes a born-tombstoned row" describes
the sitting §4 sketch, not the build: since 13i-a an arrival is a LIVE synced row, and
`dismissArrival` / `lockReading`'s sweep tombstone the STANDING row (created at the ring,
deleted at the judgment) — the plan §2.4 already re-spells it "born-tombstoned-EQUIVALENT
decided rows." The §7 parenthetical should say the as-built thing at closeout.
(b) **AppSpec §9 structural-undo bullet:** "an exact-row `redo` built from do-time
pre-images (never a re-run)" — the bind's redo is now exact-row via UNDO-time captures
(the `LockIsolated` box), because the inverse deliberately takes more than the do-time
mints (P-13ib-6). The contract's INTENT (ids survive undo↔redo; never a re-run) holds; its
letter ("do-time") no longer covers this entry. One clause in the closeout delta keeps the
canon honest. Both are closeout-sized, not code.

### F-R1-5 · MINOR · `Sources/VariorumCore/Operations/Operations+ReadingConversion.swift:104–105` — the dead `keepCollecting:`/`collectingName:` parameters survive, and can still mint the "(collecting)" sibling no door offers

**Evidence:** no door passes them since U3 (verified: the only callers in App/ pass
neither), but the public op still accepts them and `keepCollecting: true` still mints a
sibling whose reason (the bound book stops collecting) the §14.6 recast abolished — a
double-collect machine reachable by any future caller, and a drift hazard against the
ruled design. Already recorded as F-U3-4, held by the orchestrator "for the LADDER-fix
window or a closeout structure single" — this round confirms it belongs in the window.
No pin possible (no behavior changes at any shipped door — a structure finding); the
justification is the reachable-dead-door hazard above. Fix: drop both parameters and the
sibling block; rewrite the two core pins that exercise them to pin the surviving shape.

### F-R1-6 · NIT · `App/Variorum/Variorum/Features/QuickNote/QuickNoteView.swift:487` — a re-file's `.alreadyTagged` receipt claims a Quicknotes landing after she deleted Quicknotes

**Evidence:** `fileAsQuicknote` answers `.alreadyTagged` without consulting the dangling
designation, and the face's `case .filed, .alreadyTagged:` speaks `filedNote` ("Filed in
Quicknotes — tagged #quicknote.") — with Quicknotes deleted, a RE-file of an
already-tagged note claims the landing P-13ib-U4-2's own receipt fix exists to stop
claiming. Edge of an edge (a re-file of one note); pinnable as a state-transition on the
filing outcome. Fix: `.alreadyTagged` gains the same `guard let readingID` arm.

### F-R1-7 · NIT · `Sources/VariorumCore/Operations/Operations+Intake.swift:280–296` (membershipElsewhere) — no `r.kind = 'book'` filter on the elsewhere probe

A stray live MEMBER row on a GATHERING (the two-device race residue the U4 soak class
tolerates; P-13ib-6 closed the local mint road) would read a note as "membered elsewhere"
and make an owned book's intake bell instead of claim. Unreachable until 13i-c mints owned
books, and self-limiting (a bell, never a wrong seat) — record for 13i-c's door
enumeration rather than fix now; a one-word `AND r.kind='book'` if taken.

### F-R1-8 · NIT · `Sources/VariorumCore/Queries/ShelfQueries.swift` (poolListing) — `window: 0` returns zero COUNTS for non-empty classes

`rn <= 0` cuts every row, and the per-class counts are read off returned rows — so a
count-only call (the `bookArrivals(limit: 0)` idiom this phase itself established one file
over) silently answers 0/0. No caller passes 0 today; either guard/doc the parameter or
read counts from a row-independent aggregate if a count-only consumer ever lands.

---

## CLEAN BILL (load-bearing things specifically checked and found solid)

- **The intake decision table vs the rulings** (`Domain/IntakeDecision.swift` read whole
  against sitting §4/§5/§6/§14/§19/§24 + P-13ib-5 + P-13ib-U1-1): occasions, the dial,
  capacity, finished-pauses, dismissed-rings-again-as-arrival-on-event-only,
  leftAsMember-decided, the owned arms — including the §18.4 competing-owned-books cell,
  which composes correctly from `livingBooks`' deterministic order (first claim seats, the
  second book's verdict reads membered-elsewhere → bell).
- **The ONE `post_tag` application road**: grep over Sources/ confirms `PostTag(` is
  constructed only inside `insertPostTag`; `applyTag(toPost:)` and the collect door route
  through it; no raw `INSERT INTO post_tag` exists. Un-tag/un-star/restores are non-events
  as ruled (F-6 recorded honestly).
- **Member-reader hygiene**: `liveMembership` member-only; remove/reorder/diverge/
  assign-to-chapter/capacity/`readingsContaining`/`assembleReading` all filter
  `status='member'` (read at each site); `livePairRow` serves exactly the uniqueness and
  hand-add-seat questions. The hand-add seats a waiting arrival (same row, her position,
  auto-tag rides) and refuses at capacity with the arrival standing.
- **Hooks**: `createReading` (backfill; gathering/rule-less silent; the new params refused
  on a gathering), `setReadingQuerySpec` (NULL→rule backfill · changed rule catch-up ·
  malformed→readable catch-up per P-13ib-U1-5 · byte-identical no occasion),
  `lockReading` (arrival sweep in-transaction, stamps consistent with the record
  formatter), `unlockReading` (catch-up iff was finished), `restoreReading` (catch-up
  AFTER exact-stamp revival; finished restores paused), `addPostToReading` /
  `newPostInReading` (auto-tag through the road, after the membership), `setStarred` (fires
  only on a newly-starred NOTE, after the setting write, inside the transaction; the cap
  REFUSES so no phantom event).
- **Wing scoping**: `ruleSQL`'s applied-tag walk, `hasLiveTagApplication` (the collect
  probe), `intakeAfterTagging`'s candidates, `appliedTag` subtree test, `tagAllMembers`'
  and `applyAutoTag`'s belts, the editor's offered tags — all scoped; the two probes can no
  longer disagree (RuleWingScopingTests re-run green).
- **The star context (F-U3-3 closed)**: `ruleMatchSQL`/`matchesRule`/`smartMembershipSQL`
  lost the `= []` default — the compiler enumerates sites; `StarContext` reads the setting
  only when a rule carries ★ (held-observation tracking verified in the gathering arm);
  sites confirmed: assembly (+ filter + capped path), word counts, pool, chip,
  Library-card listing, collect probes, intake event + sweep. `starredNoteIDs` is
  note-targets-only, cap-bounded.
- **The judgment ops**: `seatArrival` (live-arrival guard, book guard, finished refuses,
  dead note refuses, capacity re-checked in the transaction, END + unsectioned),
  `dismissArrival` (allowed on finished per P-13ib-U1-7), `arrivalNotFound` honest on
  already-judged. `tagAllMembers` (members only, archived included, finished allowed, nil
  → auto-tag with `readingHasNoAutoTag`, each application fires other books' intake;
  `membersMissingTag` is the same predicate, so the offer's N is the act's N).
- **P-13ib-6 undo/redo**: revert takes EVERY live row on one stamp and returns ids; redo
  revives exactly those via the `LockIsolated` box, status untouched; obsolete-quiet and
  finished-throws buckets kept; ping-pong stays exact-row. (The §9 letter note is
  F-R1-4(b); the member-residue consequence is F-R1-1.)
- **The Arrivals face**: one shared predicate for count and rows; `CROSS JOIN` plan pinned;
  archived/deleted notes and dead/gathering rows excluded; the one renderer declares
  `.seatArrival`/`.dismissArrival` (registry walk green); the Outline third host matches
  her morning ruling with the U2 absence pin honestly flipped; Read stays line-less;
  expansion is view state; per-row in-flight guard; the probe is owner-keyed.
- **The rule editor**: `RuleEditing` is a bijection with the stored grammar (no silent
  drop by construction — the corpus property pinned); `.not` a wrapper node; legacy terms
  read-only including through parents (`isRemovable` subtree check); `needsWrite`
  structural (non-canonical spellings can never fake a catch-up); malformed never
  overwritten while a book's dial still saves; empty rule saves NULL — and the kill
  switch is pinned END-TO-END (`clearingTheRuleKillsALivingBooksIntake`: NULL stored, a
  fresh matching act neither seats nor bells). Save order dial→auto-tag→rule is right
  (the occasion hears the dial she chose).
- **The bind/spawn doors**: `BindOffer` carries its count (F-U2-3's stale-snapshot
  mechanism traced, pinned red through the real shelf, and the fix shape is structural —
  the sheet is a function of its item); F-1's false sentence retired with the
  "(collecting)" toggle; §19.6 identity pinned (same row id, name, star, wing); the
  teaching offer is the sitting's verbatim words, opens the real confirm, writes nothing,
  and a finished gathering hears the refusal; the spawn's sole-live-tag auto-tag matches
  her morning ruling for the positive cases (the negated-sole-tag cell is F-R1-2).
- **The Pool tuck**: the DEFINITION unchanged (no live member row; an arrival is not a
  home); loose ∪ tucked = bookless exactly (lesson 10 pinned); `poolPosts` keeps its
  contract so the phone reads the one split; per-gathering letters (none/malformed/
  no-rule) each the assembly's own; **F-U4-1** (the `NOT (<rule>)` NULL swallow over
  legacy terms) traced, fixed by the COALESCE classification, revert-checked red; the
  placement fix (run at the TOP) and tuck-away-on-leave both pinned; P1 stated honestly
  (the shipped Pool's own cost class, no new dimension).
- **The starred gathering + Quicknotes**: ensure is one transaction, signature = Home +
  (rule ★ or reserved name), live-first then tombstone, deleted-stays-deleted; the seeder
  carries the sample discipline (per-variant mark, sync gate, refusal unmarked) and the
  Mac launch wiring is after the sample books; Quicknotes re-mint special-casing removed
  with its red-on-old pin, the `taggedOnly` receipt honest (the `.alreadyTagged` edge is
  F-R1-6), restore is the ordinary door.
- **`saveFilterAsGathering`**: the association table matches P-13ib-U4-6 exactly (rule →
  rule; gathering-malformed refuses; gathering-no-rule = filter exactly; book falls to
  live in-wing auto-tag else none-reported); `conjoin` flat and pure; the filter is a read
  (capped path runs over the capped ids; order and chapters kept; nil byte-identical).
- **Sync posture**: zero `Sync/`/`Server/`/migration/schema lines in the diff (diff stat +
  tree); every write is ordinary rows through the operations layer (S1); all deletes are
  tombstones (S2); the raw-SQL stamps use the one record formatter, so exact-stamp
  restore semantics hold; outbox capture rides the standing triggers (raw UPDATEs
  included); the two-device pair races rest on shipped R1 + the documented
  tombstones-win, with no new repair introduced — as the plan's stop rule demands.
- **Suites re-run by this reviewer** (targeted, never the full suite): GatheringRitual +
  IntakeDecision + RuleWingScoping + StarContext + PoolTuck + ReadingFilter +
  StarredNotesGathering + ArrivalMemberHygiene + RuleEditing + ArrivalQueries — **88/10
  green**; IntakeOperations + IntakeSoak (6 seeds × 300 steps) + SmartConversion +
  QuicknoteShelf — **73/4 green**. Test counts in the files match the ledger's claims
  (42/1/10/9/9/6 with the adjudication batch's two additions). The kill-switch,
  Outline-flip and spawn-auto-tag pins were read in source and say what the records claim.
- **Process**: 52 commits, zero attribution trailers (her 2026-09-04 rule); the honest
  test edits (`keepCollecting…` → keeps-collecting, the undo-reach rewrite, the U2
  absence-pin flip, `aUIBuiltSmartSpecRoundTrips…` → the editor's round trip) are each
  justified by a named ruling; no KnownIssues row owned by 13i-b stands unresolved (the
  recorded F-U2-2/F-U2-4/F-U3-2 rows are closeout's, ledger row 7, not yet due); the
  F-U3-1 fix's no-mounted-pin deviation is recorded and adjudicated honestly (the
  before/after captures are its evidence — accepted).

## DISPOSITIONS — THE REVIEWER'S FINAL CALLS (2026-10-01, after the implementer's agree/dispute; fixes implemented by the reviewer in the same session, per the cross-model flow)

**F-R1-1 — CONFIRMED · FIXED (df25b855).** Built to the architect's ruled shape (a), the
implementer's refinements taken whole: `revertSmartConversion` flips each row it takes to
`status='arrival'` AS it tombstones (one write — the dismissal class; a row she removed by
hand was already tombstoned and keeps its member-class record), the redo box carries
`(id, undo-time status)` and `reapplySmartConversion` restores each row AS WHAT IT WAS. Pin
`anUndoneBindsResidueRingsAgainAsAnArrivalAfterARebind` — **RED WATCHED on the pre-fix tree**
at the traced silence (`#require` nil at the fresh act), green after; it asserts a LIVE
ARRIVAL exactly (refinement 3 — a seat would override the ruling as surely as silence).
Both existing redo pins gained status assertions (refinement 2 — a status-forgetting redo
now bites; the arrival pin already held its half). **Recorded, not built (per the
orchestrator's constraints, both in the op's doc + the bundle):** the
remove→re-add-by-hand→undo corner (the OLDER member tombstone still outranks the flip in
`intakePairState`; closing it means ranking by the LATEST tombstone — low-priority,
pinnable, hers to want) and the cross-device undo-vs-removal race (server-wins CAS; worst
case her removal reads as a dismissal — the note rings again as an ARRIVAL, never
auto-seated; self-limiting, no repair, zero `Sync/` stands).

**F-R1-2 — CONFIRMED · FIXED (c5f84d88), the implementer's shape.** The derivation is the
pure `RuleGrammar.soleOutflowTagID` (business rule out of the view model, P-9);
`ShelfViewModel` keeps only the liveness fact. **The reviewer's final call on
`#a ∧ NOT #b`: it stays UNSET** — her letter is "references exactly ONE distinct tag" and
that rule references two; the ambiguous arm is the bundled PROVISIONAL, so the conservative
reading risks nothing she ruled and the editor's row is one click (the architect's
#a-satisfies-it reading is recorded here as the alternative, one line to flip). Polarity is
PARITY (`NOT NOT #a` is positive); mixed polarity of one tag counts its positive reference.
Core `RuleOutflowTests` 7/7 (the table, every arm) + Mac pin
`spawnFromANegatedRuleLeavesTheOutflowUnset` — **RED WATCHED by behavioural revert** of the
`ShelfViewModel` hunk (autoTagId = the negated tag), green on the fix; BindDoorTests 10/10
at that commit.

**F-R1-3 — CONFIRMED · FIXED (223ffaa8), words only, the implementer's malformed cell
included.** The honest gate is `RuleGrammar.read == .rule`: `BindCopy.spawnMessage(for:)`
speaks three truths (readable → the standing promise; no rule → "starts empty and collects
nothing by itself until you give it a rule"; malformed → "starts empty and won't collect
until the rule is fixed") and `spawned(_:count:collects:)` reserves "keeps collecting" for
a readable rule. Pin `spawnFromARuleLessGatheringNeverClaimsItCollects` — **RED WATCHED on
the pre-fix words** (the receipt's exact lie: "0 notes joined, and it keeps collecting."),
green after, with the malformed cell end-to-end and the per-state words table.
**The question half stays BUNDLED** beside F-U4-7 (whether a rule-less gathering should
offer the spawn at all — hers). BindDoorTests 11/11.

**F-R1-4 — CONFIRMED · RECORD-ONLY (closeout's canon delta drafts; no code).** The two
clauses, drafted for ledger row 7 to lift:
(a) AppSpec §7 `reading_post.status` note — replace "dismissing writes a born-tombstoned
row" with the CLASS, per the implementer's refinement: *"a tombstoned `arrival`-status row
is a dismissal record — a judged dismissal, finishing's sweep, or an un-bind's residue
(F-R1-1); dismissing tombstones the standing arrival row (created at the ring, deleted at
the judgment — the born-tombstoned-EQUIVALENT decision record)."*
(b) AppSpec §9 structural-undo bullet — after "an exact-row `redo` built from do-time
pre-images (never a re-run — IDs must survive undo↔redo)" add: *"…or, where the inverse
deliberately takes more than the do-time rows (the bind's undo, P-13ib-6), from UNDO-time
captures carrying (id, status) — exact-row either way: ids AND statuses survive the round
trip."*

**F-R1-5 — CONFIRMED · FIXED (665431ad), the full removal at the implementer's corrected
census.** `keepCollecting`/`collectingName`, `SmartConversionResult.collectingReading`, the
collector mint, both undo halves' collector arms and the registration's `collectingID` all
removed; three pins died whole with their subject, three kept their trimmed real subjects
(the finished refusal still asserts no-second-book; the undo/redo pin keeps its exact-row
contract; the outbox pin its rows), and the retirement's own pin landed
(`theBindMintsNoSiblingAndTheBoundBookKeepsCollecting`). Structural cleanup — no behavior
change at any shipped door, so no red-on-old exists or is claimed (the justification is the
reachable dead double-collector). SmartConversionTests 23/23.

**F-R1-6 — DISPUTE SUSTAINED · RECORD-ONLY.** The implementer's unreachability trace is
concrete and verified against the source: `fileAsQuicknote` has ONE caller, which files the
post `importPost` minted in the SAME serialized runner closure, untagged; the pad's
microsyntax applies tags only AFTER the filing returns; no re-file door exists. So
`.alreadyTagged` under a deleted Quicknotes cannot be produced by any door, no red-on-old
pin can exist, and the hallucination guard's stop sign binds: record, don't fix. Recorded
for whichever future door first re-files a note — the structural shape then is
`.alreadyTagged(tagID:, readingID: String?)` so the face can choose its words honestly.

**F-R1-7 — CONFIRMED AS RECORDED · 13i-c's door enumeration.** The stray-member-row-on-a-
gathering reading reaches THREE readers (the implementer's addition folded in):
`membershipElsewhere` (the owned arms would bell instead of claim — self-limiting), the
Pool exclusion (a stray member row reads as a home — the note leaves the Pool), and
`readingsContaining`'s membership leg (the gathering listed as a book). All unreachable by
local doors since P-13ib-6; sync strays only. One row for 13i-c's enumeration checklist
(`AND r.kind = 'book'` where membership means a BOOK's) — carried to the closeout's
hand-off notes.

**F-R1-8 — CONFIRMED · GUARD + DOC (this commit).** `poolListing` now documents the
`window ≥ 1` contract (the counts ride the rows; the `bookArrivals(limit: 0)` idiom does
not transfer) and asserts it (a DEBUG oracle — no caller passes 0; release behaves as
today). A count-only consumer, if one ever lands, needs a row-independent aggregate.

### The fix pass, verified

Commits: df25b855 (F-R1-1) · c5f84d88 (F-R1-2) · 223ffaa8 (F-R1-3) · 665431ad (F-R1-5) ·
this commit (F-R1-8 + dispositions + ledger). Every bug-class fix carries its red-watched
pin (F-R1-1 red at the traced silence; F-R1-2 red by behavioural revert; F-R1-3 red on the
pre-fix words); the structure single (F-R1-5) claims none. **End-of-pass verification, after
the last code edit:** the FULL core suite — **"Test run with 1913 tests in 200 suites
passed"** (1 skipped: the standing env-gated Supabase integration test; baseline 1907/199
at the pre-ladder close → +7 `RuleOutflowTests` + the F-R1-1 pin + F-R1-5's net −2). The
touched Mac suites, struct-named, counts read exactly: BindDoor · BookOrderConversion ·
PoolTuckFace · SnippetGroupTrash · BlockTOC — **"Test run with 38 tests in 5 suites
passed"**; BookAscentDeclaration · CalloutEmojiPicker · CalloutSwatch ·
DuplicateBookNameDoor · PromoteAndPalette · ShelfModel (the DoorSet and ShelfAndPalette
files' suites) — **"Test run with 26 tests in 6 suites passed"**; 0 issues, 0 skipped.
The mobile target (`VariorumMobile`, generic iOS Simulator) — **BUILD SUCCEEDED** (no
caller of the removed API). Zero instances throughout (`pgrep` clean).

## THE IMPLEMENTER'S AGREE/DISPUTE (round 1)

*The implementer voice (opus-implementer, fresh session, 2026-10-01). Nothing was implemented.
Read in this session, not delegated: CLAUDE.md + its canon, this file, `phase-13i-b-gatherings.md`
whole (the U1–U4 records, the adjudication batch, THE LADDER's F-R1-1 ruling), and every site
below at HEAD 91148af3. No code changed after the reviewed 7cf0dc88, so the findings' line
pointers are approximate rather than stale; current pointers are given where they differ. No
test files written; mechanisms verified by reading and by running the described pin logic
against the source. **Verdicts: 7 AGREE · 1 DISPUTE (F-R1-6 — unreachable).***

### F-R1-1 — AGREE (the deafness is real, exactly as traced)

Every step holds against the source:
- `revertSmartConversion` (`Operations+ReadingConversion.swift:243–254`) writes `deletedAt`
  only; a member row keeps `status='member'`.
- A re-bind materializes the CURRENT assembly only (`:123–136`, skipping a pair with a LIVE row
  via `livePairRow`, `Operations+Reading.swift:582`), so a residue pair absent from the
  assembly at re-bind gets no row.
- A later applying act: `intakeAfterTagging` → `intakeEvent` → `intakePairState`
  (`Operations+Intake.swift:248–267`; `left = SUM(deleted_at IS NOT NULL AND status='member')`
  → `.leftAsMember`) → `IntakeDecision.verdict`'s `.live, .leftAsMember → .nothing`
  (`IntakeDecision.swift:145–147`). The sweeps' any-row `NOT EXISTS` is
  `Operations+Intake.swift:126`.
- The reviewer's pin is buildable as written and is RED on HEAD (the pair keeps its one
  tombstoned row); the control (still matching at re-bind → a fresh live row) is green.
- **The reach is a little wider than the untag route.** ANY route that keeps a residue pair out
  of the assembly at the re-bind deafens it. ARCHIVING is one (the gathering assembly excludes
  archived notes — `ReadingAssembly.swift:339/364/375` — and un-archiving is not an act, F-6).
  A gathering CAP is another (`setReadingMaxPosts` has no kind guard, `Operations+Reading.swift:118`,
  and `assembleReading` honours the cap). The untag route is the plainest and the right pin.

**Fix-shape notes.** The architect's ruling picks the reviewer's shape (a); these are for
whoever builds it:
1. **Shape (b) as worded is not buildable.** An undo residue and a hand-removal are
   byte-identical rows (`status='member'`, `deleted_at` set, nothing else), so `intakePairState`
   cannot tell them apart without a marker, which would be a schema change. That leaves (a).
2. **The existing redo pins cannot catch a status-forgetting redo.**
   `undoingABindLeavesNoLiveRowAndRedoBringsEveryRowBackByID` (`SmartConversionTests.swift:476`)
   and `undoRestoresTheSmartBookExactlyAndRedoPutsTheSameRowsBack` (`:349`) compare IDS only,
   over `liveMemberships`, which reads EVERY status (`:46–56`). Under (a), a redo that revives
   the rows but leaves them `'arrival'` brings her members back as ARRIVALS, and both pins stay
   green. The fix must add a status assertion on the redo (members return as members; the
   waiting arrival returns waiting — `:505` already holds that half).
3. **The new pin should assert the RULED outcome exactly**: a live `status='arrival'` row. The
   reviewer's "arrival or seat" would also pass a wrong fix that resets the pair to fresh and
   SEATS it, overriding the ruling's dismissal class.
4. **A corner the ruling's rationale covers but (a) does not.** She removes A from the bound
   book by hand (a member-class tombstone), adds A back by hand, then undoes the bind. Under
   (a), the undo's arrival-class tombstone sits beside the OLDER member-class one, and
   `intakePairState`'s "any member tombstone ever" still reads `.leftAsMember`. So A stays deaf
   after a re-bind and re-tag, though her latest act on the pair was "add". Closing it means
   ranking the pair by its LATEST tombstone (`ORDER BY deleted_at DESC LIMIT 1`). Outside the
   (a) residue, that reading agrees with "any member tombstone" in every sequence the ops can
   produce: a dismissal can never follow a member tombstone, because no bell rings on a
   `.leftAsMember` pair. Low priority and pinnable; the reviewer decides whether to fold it in.
5. **Sync (read for safety; nothing proposed).** Both repairs that rewrite `reading_post.status`
   read LIVE rows only: R1's rival lookup (`Sync/Repairs.swift:642–650`, `deleted_at IS NULL`)
   and R2's ownership pass (`:938–950`). Tombstoned incoming rows land verbatim
   (`writeResolvedRow`'s `!row.isTombstoned` gate). So a flipped-status tombstone enters no
   repair predicate. The one new cross-device corner: device 1's undo flips a row while device 2
   hand-removes the same row. Server-wins CAS keeps whichever lands first, so her removal can
   come out ranked as a dismissal: the note rings again as an ARRIVAL on a fresh act and is
   never auto-seated. That is self-limiting and her judgment holds; one line in the bundle
   beside P-13ib-U3-3.
6. F-R1-4(b)'s canon clause grows with (a): the redo would carry undo-time STATUSES as well as
   ids.

### F-R1-2 — AGREE

`RuleGrammar.tagIDs` descends `.not` (`RuleGrammar.swift:160`), so `{"not":{"tag":a}}` yields
`{a}`, and `ShelfViewModel.spawnBook` (`:206–214`) adopts it after only a liveness check. The
state is reachable from the shipped editor (the `not` chip on a lone root — U3 capture 02).
`★ ∧ NOT #a` is the same cell. Two notes on the fix:
1. **The reviewer's two fix shapes are not equivalent.** A `positiveTagIDs` walk makes
   `#a ∧ NOT #b` → `{a}` and SETS the auto-tag on a cell her ruling did not name. Her letter is
   "references exactly ONE distinct tag", and that rule references two. A polarity check before
   adopting the sole tag fixes only the broken cell and keeps `#a ∧ NOT #b` unset, which the
   reviewer already called "fine". I recommend the polarity check. Either way, polarity is the
   PARITY of negations: `NOT NOT #a` is positive.
2. **Home.** The derivation is a business rule living in a view model (CLAUDE.md: view models
   hold no business rules). Make it a pure `RuleGrammar` function — e.g.
   `soleOutflowTagID(of:) -> String?` (the sole referenced tag, positive polarity) — and leave
   the view model only the `tagIsLive` check. Then the red-on-old pin is a core unit test, with
   the existing Mac spawn pin as the integration.

### F-R1-3 — AGREE (plus one more cell)

Verified:
- "Create Smart Book" mints a rule-less gathering (`ShelfView.swift:114`).
- The spawn door is offered on EVERY gathering (`:344–347`, no rule check).
- Backfill is guarded by `intakeSweep`'s `case .rule` (`Operations+Intake.swift:118`), and
  `livingBooks` requires a readable non-NULL spec, so the book seats nothing and never collects.
- The false words are `BindCopy.spawnMessage` / `spawned` (`BookOrderAndConversion.swift:213–222`).

**The same class, one more cell: a MALFORMED gathering.** `normalizedRuleSpec` stores
undecodable bytes verbatim (`Operations+Reading.swift:71–74`), so the sibling copies a rule that
runs no intake (P-13ib-5), and "new matches keep joining" is false there too. The honest branch
keys on `RuleGrammar.read(querySpec)` being `.rule`, not on `querySpec != nil`. The sheet
already holds the row (`spawnSource`), so it can branch with no new read. The question half is
the morning bundle's, as THE LADDER section filed it.

### F-R1-4 — AGREE (both letters)

(a) AppSpec §7's `reading_post.status` note (AppSpec line 271) says "dismissing writes a
born-tombstoned row". In fact `dismissArrival` tombstones the STANDING row
(`Operations+Intake.swift:438–447`), and so does `dismissPendingArrivals` (`:455–462`). Under
F-R1-1(a) a third producer of the class appears (an un-bind's flipped rows). So the closeout
wording should name the CLASS rather than one door — e.g. "a tombstoned `arrival`-status row is
a dismissal record: a judged dismissal, finishing's sweep, or an un-bind's residue".

(b) AppSpec §9 (line 460) says "an exact-row `redo` built from do-time pre-images". The bind's
redo reads undo-time captures instead (`Operations+ReadingConversion.swift:190–204`). The intent
holds; the letter needs the clause, and with F-R1-1(a) it should name statuses as well as ids.

### F-R1-5 — AGREE (one count corrected)

No caller in `App/` (the Mac target, `Shared/`, `VariorumMobile/`) passes either parameter
(grep).

**The pins number five, not two:**
- Two die whole: `keepCollectingMintsASecondSmartBookOnTheSameFilter`
  (`SmartConversionTests.swift:212`) and
  `aBlankCollectingNameFallsBackToTheDefaultAndAGivenOneIsUsed` (`:255`).
- Three use the parameter only in passing and keep their real subjects once the argument and
  the collector assertions are dropped: `aFinishedBookRefusesAndWritesNothing` (`:281`),
  `undoRestoresTheSmartBookExactlyAndRedoPutsTheSameRowsBack` (`:318`) and
  `conversionWritesThroughTheOutboxLikeAnyOtherOperation` (`:554`).
- A sixth, `withoutTheOfferNoSecondBookExists` (`:269`), loses its subject; its count half
  already stands in the §19.6 identity pin's "no second row".

**The dead surface is wider than the two parameters:** `SmartConversionResult.collectingReading`,
the `collectingReadingID` arms of `revertSmartConversion` / `reapplySmartConversion`, and the
registration's `collectingID` all go with them.

**Safety:** undo entries are session-scoped and in-memory, so no persisted entry names a
collector. The "(collecting)" siblings already in stores (F-2) are ordinary gatherings this
never touches. The keeps-collecting assertion inside `:212` is pinned elsewhere
(`GatheringRitualTests`, `BindDoorTests`), so nothing is lost.

### F-R1-6 — DISPUTE (unreachable on today's tree)

The mapping is as described: `.alreadyTagged` ignores the designation
(`Operations+Quicknote.swift:75–81`), and the face speaks `filedNote` for it
(`QuickNoteView.swift:487–488`). But no door can reach that state:
- `fileAsQuicknote` has ONE caller across `App/`, `Shared/` and `VariorumMobile/` (grep):
  `QuickNoteMint.file` (`QuickNoteView.swift:474–478`). It files the post that `importPost`
  minted in the SAME serialized runner closure.
- `importPost` writes no tag (`Operations+Import.swift:56–82`).
- The pad's `{#…}` microsyntax applies its tags AFTER the filing returns
  (`QuickNoteView.swift:187–198` — `CaptureMicrosyntax.applyTags` runs on `.filed`), so even a
  typed `{#quicknote}` lands after `fileAsQuicknote` has already answered.
- No re-file door exists, and no remote device can tag a UUID minted inside that closure.

The finding's "re-file of an already-tagged note" sequence therefore cannot happen. No
red-on-old pin can be built through any door, and the hallucination guard binds: record, don't
fix. If the reviewer still wants it as hygiene, the structural shape is
`.alreadyTagged(tagID:, readingID: String?)`, so the face can choose its words honestly. That is
not a behaviour change, so there is nothing to pin. Otherwise, record it for whichever future
door first re-files a note.

### F-R1-7 — AGREE (record for 13i-c, as proposed)

`membershipElsewhere` (`Operations+Intake.swift:271–287`) joins `reading` with no kind filter.
Three refinements:
1. **Reachable through sync, not only in theory.** A stray live MEMBER row on a gathering can
   arise today: device 2 hand-adds to the bound book while device 1's undo turns the row back
   into a gathering, and that undo can't tombstone a row it hasn't seen.
2. **The verdict effect is confined to OWNED books, as the reviewer says.** A plain book reads
   only `ownedElsewhere` (`IntakeDecision.swift:153–155`), which sums `r.owned`, and a gathering
   never carries that flag.
3. **The same stray row also counts as membership in two other readers:** the Pool's exclusion
   (`ShelfQueries.swift:317–319`, no join to `reading` at all) and `readingsContaining`'s member
   leg (`:338–341`, no kind filter). These are F-4's original pair. 13i-c's door enumeration
   should settle `kind='book'` for all three member-row readers together, not this probe alone.

### F-R1-8 — AGREE (nit)

`rn <= ?` with 0 (`ShelfQueries.swift:322`) returns no rows, and both counts are read off rows
(`:267–279`), so the answer is 0/0. Both callers pass 200 (`PoolPostsView.window`; mobile
`listingLimit`, default 200). Because the sibling `bookArrivals(limit: 0)` reads as "the count
alone", the cheapest honest shape is a `precondition(window > 0)` plus a doc line.

*Aside, not a finding:* two `Queries.poolListing` overloads now name two different concepts —
`(db, window:)` for the bookless-notes Pool (`ShelfQueries.swift:258`) and `(db, poolID:)` for
the Snippets scraps area (`PoolAndTray.swift:54`). That naming hazard belongs to 13i-d's
vocabulary sweep.
