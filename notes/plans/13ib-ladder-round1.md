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

## DISPOSITIONS (filled after the cross-model exchange)

*(pending — findings go to the implementer verbatim; its agree/dispute returns here; the
reviewer makes the final call and implements confirmed fixes with their pins.)*
