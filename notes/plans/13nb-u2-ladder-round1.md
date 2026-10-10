# 13n-b U2 — ladder round 1 (cold review, fable-reviewer, 2026-10-09)

**Diff reviewed:** `a601a985..HEAD` (aec83fb2) — everything since U1's ladder closed: the U2 unit
(the Private fence leg + ops/faces, the suggest and write-new rungs, the just-in-time ask, per-act
undo, receipts/chips, adoption-lands-OFF) AND the orchestrator's v1_25 schema commit (`304b41d1` —
the SyncSpec §12 lockstep event, marker 12→13, mirror artifact 16, deploy HELD).
**Anchor:** `notes/plans/phase-13n-b-mcp-door.md` read whole (the sitting record R-13nb-1…19, the
architect rulings AF-1…AF-8, THE PRIVATE MARK addendum, the U2 unit record and live round), both U1
ladder records, the wire-document memo, **SyncSpec read IN FULL** (the diff touches `Sync/` and a
migration), CLAUDE.md + auto-loaded canon. The plan carries no plan-time "Review foci" section; the
implementer's self-named look-first spots were each traced (results below and in the clean bill).

**Verified myself, in this session (not taken from the record):**
- Every new/changed source and test file read at HEAD: `Operations+PrivateMark`, `Operations+MCPWrites`
  (whole), `Operations+MCPGrants` (the landing), `MCPGrantQueries` (both fact forms + the new faces
  reads), `MCPGrantRule`, `Migrations` v1_25, `Sync/SyncSchema`, `Server/supabase/16` (diffed against
  15's shape line by line), `MCPWriteTools` (whole), `MCPWriteSupport`, `MCPNoteStructure`,
  `MCPToolCatalog`, `MCPGrantAuthority`, `MCPSession`/`MCPServerHost` diffs, `MCPReadTools` diff
  (with_ids, R2-1, R2-2), `MCPDoor`, `MCPAskSheet`, `MCPGrantSheet`, `MCPPaneCopy`, `PrivateMark`,
  `BookSettingsSheet`, `ShelfView(+Model)`, both bottom bars, the registry, `VariorumApp`, and the six
  new/changed test files.
- `swift build` green; targeted suites 174/12 green; **the whole headless package reproduced the unit
  record's counts exactly: core 2,534/291 · VariorumMCPTests 32/4 · workbook 40/6**, only the
  long-standing gated skips.
- **Both load-bearing red-on-old pins re-verified by my own revert runs:** the Private leg back at
  `"0"` → `MCPPrivateMarkTests` fails with **10 issues** exactly where the fence pins sit; AF-7's
  `spends` back at the old expression → the explicit pin fails (2 issues) AND the 13,824-world sweep's
  invariant 3 fails across shapes. Tree restored clean after each run.
- Commit hygiene: `Sources/VariorumCore/Sync/` touched by exactly ONE commit (`304b41d1`, the
  orchestrator's — AF-4 honored; zero implementer lines); zero attribution trailers; branch in sync
  with origin. No Mac-suite re-run this round (no stage claim owed: the implementer's 179/27 run is
  recent, the Mac surfaces walk-covered with 23 captures; round 2 can demand one if fixes touch them).

## Findings (severity-ranked; format: [severity] · where · what · evidence · fix)

### F1 — [MAJOR] · `Sources/VariorumCore/Sync/SeededFurnitureDedupe.swift:521-545, 697-712` + `SampleLibraryDedupe.swift:804-812, 876-884` · the two §7 fold/dedupe classifier families cannot see the new `ai_private_at` columns, so a fold can silently retire HER Private mark

**Evidence (traced):** both repair families classify a copy by EXPLICIT column enumeration and their
ruled letter is "HER ENGAGEMENT always keeps both, and any doubt keeps both" / "any act of hers makes
the pair differ and both survive". `SeededFurnitureDedupe.guideVerdict` reads
`starred, locked, sealed_at, owned, archived_at, word_target, max_posts, grouping_tag_id, sort_field,
sort_dir, shelf_id, hide_owned, intake_seating, auto_tag_ids, query_spec` — `ai_private_at` is not
read; `noteVerdict` reads `title, locked, archived_at, entry_date, floating_notes` + the star list —
not read; `SampleLibraryDedupe`'s book-shape read (`locked, word_target, max_posts, grouping_tag_id,
sort_field, sort_dir`) and its per-note engagement read (`title, locked, archived_at, entry_date,
floating_notes, deleted_at`) — not read. I verified by grep that NOTHING outside
`MCPGrantQueries`/`Operations+PrivateMark` reads the column, so no other leg covers it. Mechanism:
she marks seed furniture (the field guide book, the seeded quicknote, a starred note) or a
sample-library copy **Private** (`setBookPrivate` allows any book, archived/finished included — the
field guide qualifies); a fresh install on a second Mac seeds its own copy and signs in; the fold
fires at the pull occasion; her marked-but-otherwise-unengaged copy reads as "the seed's own" /
"pristine" because the mark is invisible; both copies fold to the smallest id — random UUIDs, so
~half the time the UNMARKED fresh copy keeps and her marked copy tombstones. **The converged library
carries NO mark: a disclosure fence she deliberately set is silently cleared**, and the book/note is
again reachable by any standing grant or the open book on every device. This violates the fold
rules' own ruled letter (SyncSpec §7, the 17y B-DEDUPE entry and R-pre13u-8's err-toward-edited
doctrine) — `archived_at`, the mark's own disclosure class, IS read as engagement at every one of
these sites, which is the precedent the new column missed. The v1_25 commit's "no new §7 repair
(plain CAS metadata)" claim is correct for the MERGE matrix but did not cover the two
column-enumerating classifier families.
**Pin (red-on-old):** two seed's-own field-guide copies (the `TutorialFurnitureFoldTests` /
`SampleLibraryDedupe` fixtures exist); set `ai_private_at` on the copy with the LARGER id; run the
fold; assert BOTH copies survive (old code folds the pair and the kept copy reads
`ai_private_at IS NULL`). Same shape for `noteVerdict` and the sample-library pristine check.
**Fix:** one engagement/seed's-own leg per classifier — `ai_private_at IS NOT NULL ⇒ engaged` (not
the seed's own) in `guideVerdict`, `noteVerdict`, and `SampleLibraryDedupe`'s book + note reads
(`gatheringIsSeedsOwn` optionally too, as pure defense — gatherings refuse the mark operations-side).
These are `Sources/VariorumCore/Sync/` lines — **Fable's hands (AF-4), the reviewer's own in the fix
pass**, with the mark counted as engagement BEFORE the deploy window makes marks real synced data.

### F2 — [MINOR, architectural — traced degradation, no pin owed] · `Sources/VariorumMCP/MCPWriteTools.swift:288-330, 431-451` · a write tool's DECIDE and ACT run in separate transactions, serialized against her gestures but not against sync apply

**Evidence (traced):** `onBlock` resolves the block's note in one `database.read` (line 288);
`onNote`/`into`/`inWing` read standing + facts and decide in another `database.read` (line 313); the
act then lands in the ops' own `database.write` inside `land`. The whole body is one serial unit on
the session's `OperationsRunner` (AF-8), and I verified every app-side writer that matters — her
gestures, the pane's approve/deny/grant/revoke (`MCPDoor.act` → `runner.run`), the ask sheet's
answer, both Private faces — rides that same runner, so none can interleave. **The sync engine's
apply transaction does not** (it writes the store directly): a Private mark, a placement move, or a
tombstone arriving BY SYNC between the decide-read and the act-write lets one in-flight suggest /
write-new act land on a target the fence or the scope had just closed (e.g. `add_take` lands on a
note whose `ai_private_at` landed from her other Mac a millisecond after the decision was read; or
on a block a synced `moveBlock` just re-homed into an ungranted note — the ops re-check liveness and
locks, never scope or fence, by design). U1's read path holds decide + read atomic in ONE write
transaction (its clean-bill line); the write path silently weakens that per-call atomicity to
runner-serialization. Degradation bounded: suggest/write-new acts are additive (the PROOF class — no
existing text reachable), labeled, undoable; the window is one in-flight call; the very next call
refuses — the ruling's "fencing takes effect immediately on connected clients (the per-call check)"
is honored at call granularity, raced only within one call by a concurrent sync round.
**Justification for no pin:** no seam exists to deterministically interleave a sync apply between the
two transactions of one serial body — an honest test would be a timing flake. **Fix shape (either is
acceptable):** record it as the write path's deliberate tension beside P-13nb-U2-8 (the crash corner
is already recorded; this is its sync twin), or re-verify the fence/scope facts INSIDE the act's
write transaction (the ops take an injected precondition closure — heavier, and the layering cost
("ops decide nothing about clients") is real; recording is the spec-defensible floor).

### F3 — [NIT] · `Sources/VariorumMCP/MCPWriteTools.swift:436-439` · a throwing activity log AFTER a landed act answers the client "couldn't complete" — a landed write reported as failed invites a retry-duplicate

**Evidence (traced):** `land` runs the act, spends (`try? spend` — swallowed, recorded as
P-13nb-U2-8's class), then `try log(...)` in its own `database.write`; a log that throws (store
dying mid-call — the only realistic reader, since the act's own write just succeeded) propagates
out of `perform` → `call`'s generic catch → `isError: true` while the take/note/book HAS landed and
its undo entry is registered. The client retries and lands a duplicate (additive, labeled, undoable
— never text damage). U1's F3 disposition accepted the mirror class for READS, where discarding the
answer is the safe direction; for writes the direction inverts, but the window is the same
store-death race and the server detaches at lock. **Record-only** (no honest deterministic pin short
of a fault-injecting database stub); if ever closed, the shape is: log inside a `try?` for the
SUCCESS path only (a landed act's answer should not be hostage to its log line), refusal logs
keeping `try`.

### F4 — [NIT, record] · `notes/plans/phase-13n-b-mcp-door.md` (P-13nb-U1-2's amended form) + `MCPGrantRule.spends` · the built AF-7 semantics let a once write-new grant make UNLIMITED lower-rung writes — pinned, but the consequence is not stated in the record her QUESTIONS bundle will carry

**Evidence (traced):** `spends` requires `rung == grant.rung`, so under a once WRITE-NEW grant every
suggest-rung WRITE (`add_take`, `add_comment`, `save_lens`) is non-consuming and rides free, without
bound — pinned explicitly (`aOnceWriteGrantLetsTheReadsItNeedRideFreeAndIsSpentByItsFirstWrite`,
MCPGrantRuleTests:237-238: "a lower-rung write rides free under a once write-new grant"). AF-7's
ruling text names only "the lower-rung READS it needs on the way riding free", and the amended
provisional's stated edge covers only "a once-suggest grant authorizes ONE write". The
implementation is the ruling's heading read literally ("consumed by the first call at the grant's
OWN rung") and I judge it as-ruled — but a user granting "write new · once" plausibly expects ONE
act, not one write-new act plus unbounded suggestions. **Fix:** one sentence in P-13nb-U1-2's
amended form (the merge QUESTIONS bundle) stating the consequence plainly, so her ratification is
informed. No code change this round.

### F5 — [NIT, record] · `Sources/VariorumMCP/MCPGrantAuthority.swift:118-131` · the fenced-BOOK refusal words join P-13nb-U1-13's distinguishable-from-not-shared class; the provisional's record speaks only of notes

**Evidence (traced):** U2 adds book-specific fence words ("That book is a journal. …" / "That book
is marked Private — never shared with AI."), while an unknown/unshared book answers the one
`notShared` sentence — so a client holding a book UUID from a pre-mark listing can tell "live
fenced book" from "deleted/unshared" ever after. Same exposure analysis as U1's F4: listings never
emit fenced book ids (pinned — `list_books` drops a Private book on the next call, verified in
`markingPrivateFencesTheVeryNextCallOfAConnectedClient`), so the only road to such an id is a
listing that predated the mark. The ask-the-author road justifies the distinct words exactly as it
did for notes. **Fix:** extend P-13nb-U1-13's recorded text to books (one line); no code change.

## Implementer responses / dispositions (round 1)

**FINAL DISPOSITIONS (the reviewer's calls on the implementer's responses — fable-reviewer,
2026-10-09, the fix pass its own; 5/5 AGREE received at `30f9a07e`, zero disputes; the AF-7
AMENDMENT `d24e77b6` reruled F4 before dispositions. Every bug-class fix carries a red-on-old pin
verified BEFORE the fix landed, one commit per fix, pushed; suites green after the pass.)**

| # | Severity | Response | FINAL disposition |
|---|---|---|---|
| F1 | MAJOR | AGREE (+ the keeper refinement) | **FIXED (`15933ab4`)** — one engagement/edited leg per classifier, `archived_at`'s exact precedent: `guideVerdict` + `noteVerdict` + the gathering candidates read (pure defense — the ops refuse the mark there; a carrying row is a doubt, and doubt keeps both) in `SeededFurnitureDedupe`, and the book-shape + per-note reads in `SampleLibraryDedupe` — where the mark counts as EDITED, so the MARKED copy is the KEEPER (the implementer's refinement accepted: the right copy, not just both-survive). Four pins RED-ON-OLD verified before the fix (8 issues on the unfixed classifiers — `fenceStands` failing proved the mark itself died; the sample arm kept the WRONG copy): `herPrivateMarkKeepsBothCopiesOnEveryGrain` · `aMarkedGatheringRowKeepsBothAsDefense` · `herPrivateMarkOnTheBookIsEngagementAndTheMarkedCopyIsTheKeeper` · `herPrivateMarkOnAMemberNoteProtectsTheCopyToo`. All fold suites green after (63/6). Sync/ lines the reviewer's own (AF-4); landed BEFORE the deploy window. |
| F2 | MINOR (arch) | AGREE — record for U2, guard U3 | **RECORDED as P-13nb-U2-8's SYNC TWIN** (the plan's provisional gains the paragraph: the decide/act split is raced only by the sync apply transaction; one in-flight additive call; the very next call refuses) **+ the U3 guard line on ledger row 5**: `edit_take`'s op takes an injected `(Database) throws -> Void` guard run FIRST inside its own write transaction, re-deciding through `MCPGrantRule` on facts read there (`expectedText` is already this precondition class) — the edit rung never inherits the gap; retrofitting the eight U2 ops is optional at the same touch. |
| F3 | NIT | AGREE — record-only, trace sharpened | **RECORDED** — with the implementer's sharpening adopted: the success log sits inside `land`'s `do`, so a log throw after a landed act ALSO falls into the generic catch, which re-logs the landed act as `allowed: false` — the activity line actively lies, on top of the client's retry-duplicate hazard. Same store-death race; no honest deterministic pin without a fault-injecting stub (the ladder's own rule). The named road if ever closed: the success log out of the `do` as `try?`, refusal logs keeping `try`. |
| F4 | NIT → fix (reruled by `d24e77b6`) | AGREE — small fix owed under the amendment | **FIXED (`d60c3ad6`)** — `spends` now reads `once ∧ consumes ∧ (grant.rung == .read ? rung == .read : rung >= .suggest)`: a once WRITE grant is spent by its FIRST WRITE of ANY rung it authorizes; reads ride free, writes never do ("one write means one write"). `decideWing`/`noteIntoBook` share `spends` and follow. Pins red-on-old verified before the fix: the flipped explicit pin, the sweep's invariant 3 restated to the amended biconditional (both directions — red across shapes on the old line), and the new e2e `aOnceWriteNewGrantIsSpentByItsFirstWriteOfAnyRung` (read rides free → `add_take` lands and spends → `create_note` refuses). The once-SUGGEST e2e pin unaffected. P-13nb-U1-2's amended form in the plan carries the second-amendment wording for her ratification at the merge. |
| F5 | NIT | AGREE | **RECORDED** — P-13nb-U1-13's paragraph in the U1 round-1 record EXTENDED to fenced books (dated, marked as the U2 ladder's F5): one record for both shapes in the merge QUESTIONS bundle; no code change. |

**O1 (the implementer's adjacent observation at F1 — the reviewer's call): RECORD-ONLY, AS
DESIGNED, my own trace.** The OWNED-exclusivity repair (SyncSpec §7, 13i-a R2) tombstones a later
plain-side membership beside a standing owned claim; when that membership was in a PRIVATE book, the
note's book-route fence drops with it (its own mark untouched by any repair). Judged correct: the
tombstoned membership is one the ownership rules FORBADE — the repair converges to what the doors
would have done knowing the truth (the door would have refused the add: no membership, no fence),
and a fence kept alive by a dead membership would be a ghost no surface could explain. The boundary,
stated: **the book-route fence is exactly as durable as the live membership that carries it; the
note's OWN mark is the durable primitive, and no repair touches it.** If she ever wants a belt, the
shape is a new ruled behavior (stamp the note's own mark when a repair severs its private-book
membership) — hers to ask for, never improvised here. No QUESTIONS entry owed (a composition of two
ruled behaviors, not undefined product behavior).

**Fix-pass verification (2026-10-09, headless — no stage needed; zero Mac-app files touched in the
pass):** whole package `swift test` green — core **2,538/291** (the pre-pass 2,534 + the four F1
pins), **VariorumMCPTests 33/4** (32 + the AF-7 e2e pin), workbook **40/6**; only the long-standing
gated skips. Fix commits `15933ab4` (F1) · `d60c3ad6` (F4) + this records commit, each pushed.

**For round 2, look first at:** (1) F1's legs — each classifier reads `ai_private_at` in the SAME
SELECT its checks consume (five sites: the gathering candidates, `guideVerdict`, `noteVerdict`, the
sample book-shape read, the sample per-note read), and the pool grain genuinely needs no leg (pools
are unmarkable in v1 — the design addendum's restraint); (2) F4's shared `spends` — its three
consumers (`decide`, `decideWing`, `noteIntoBook`'s two-sided spend) under the amended rule, and
whether any surviving pin or comment still encodes the OLD "at its own rung" reading; (3) the F1
pins' fixtures — the marked copy carries NO other engagement, so the pins really isolate the mark;
(4) the record edits — P-13nb-U2-8's sync twin, P-13nb-U1-2's second-amendment wording,
P-13nb-U1-13's books extension, ledger row 5's edit_take guard line.

## Clean bill (load-bearing things specifically checked and found solid)

- **The lockstep event is exactly §12's shape:** v1_25 is two additive nullable TEXT columns, no
  backfill; `SyncSchema` classifies both PLAIN with the archived_at disclosure reasoning (sets, so
  column order is irrelevant to the serializer — verified `SyncEncryption` iterates
  `encryptedColumns` only and the completeness walk is set-based); `lockstepVersion` 13 with the
  history comment; the DDL pin (`AuthRLSDDLTests`) gains 16; **mirror artifact 16 diffed against 15
  line by line** — the re-run guard (marker ≥13 OR either column present refuses; <12 demands 15
  first; the override naming), ONE transaction, bare `add column` (no constraint — §2's dumb
  mirror), the marker as the LAST statement, verification queries. No RPC/allowlist/registry change
  needed (table-level; plain columns) — verified against 15's precedent. The deploy is HELD (ledger
  row 9). "No new §7 repair" is right for the MERGE matrix (plain CAS metadata, server-wins —
  nothing to add); the classifier families are F1.
- **The fence's third leg lives in ONE derivation site and is exactly R-13nb-4:** `privateLegForNote`
  / `ForBook` interpolated into the single AND batch `mcpNoteFacts`, `mcpBookFacts`, and
  `mcpGrantableBooks` (the sheet never offers a Private book; the grant op refuses
  `mcpGrantScopeFenced` — pinned). Own stamp · live member (status 'member', arrivals never) of a
  live reading carrying one · archived private book still fences · deleted one does not · NULL reads
  not-private · privacy wins ties over the journal leg — each pinned, and the whole set re-verified
  red-on-old by my own revert run (10 issues with the legs at "0"). The mark stays OFF the
  `Container`/`Reading` models, so no stale model write can clear it and no copy road silently
  carries it (grep-verified: no other reader/writer of the column exists).
- **The Private ops are the identity-metadata conventions exactly:** no-op-guarded (no outbox row on
  a no-op — pinned), no touch/churn (pinned — marking never reshuffles the library), synced through
  the outbox (pinned), no undo entry, gatherings refuse `wrongReadingKind`, pools
  `wrongContainerKind`, allowed under seal/finished/sealed/archived as recorded PROVISIONAL
  P-13nb-U2-1.
- **The suggest PROOF is real:** `addTake`/`addComment`/`saveLens` are INSERT-only by construction —
  I read all three ops whole; none issues an UPDATE against `variant` or `container_block`; the take
  is parentless, fan's END, never chosen/default/locked, labeled "<client> · suggested[ · own]"
  (P-13nb-U2-12). The e2e PROOF pin snapshots her takes + every placement + every block + every
  commit byte-for-byte across EVERY tool that names a note/block/take (the completeness assertion
  pins the tool set), and its lens deliberately picks her NON-chosen take (the mutation check that
  earned its keep). The suggest client's `tools/list` is exactly the 8 reachable tools (pinned +
  the live round).
- **Scope discipline holds at every write door:** creative acts decide on the BOOK or WING at
  writeNew (`into`/`inWing`); `add_note_to_book` double-decides note AND book at writeNew before
  anything lands (no pull-in escalation — pinned end to end with the one-answer refusal);
  `onBlock` resolves the block's CURRENT live placement's note and decides there (a released/pool/
  stranger block answers as unshared — no oracle); lens picks resolve ONLY among this note's placed
  blocks (no take-id oracle; two takes of one block refuse; archived take refused by the op);
  a note minted into a book lands in the book's own wing through `addPostToReading`'s full gate set
  (capacity, ownership consult — whose refusal reaches the client through the words hook, pinned).
- **AF-7 as built matches the ruling's letter and is pinned both ways** (ride-free lower-rung read;
  first own-rung write spends; second refuses; wing writes spend a once wing grant; a shared once
  grant covering note+book spends ONCE — the Set dedupe), re-verified red-on-old by my own revert
  run; the spend lands AFTER the act (a refused act never spends) inside the serial body; the
  `try? spend` crash corner is recorded (P-13nb-U2-8). F4 is record-wording only.
- **The just-in-time ask never blocks and never becomes an oracle:** the refusal answers at once;
  `notShared` is byte-identical whether or not an ask was queued (pinned: missing == unshared);
  the asked sentence rides only `rungTooLow`/`fenced`; a fenced BOOK never raises an ask; a missing
  target raises nothing; `offersAlways` reads the fence (R2-1's fix landed, both in `MCPAsk` and the
  search synthesized path); the queue dedupes per client·target·rung, caps at 8 never dropping the
  one on screen (pinned); "while connected" only to a connected client; a stale unfenced ask racing
  a fresh mark is caught by the grant op's own fence guard (always-on-fenced refuses — U1's pin).
- **Undo per act is R-13n-6's letter:** one labeled entry per act on the SESSION's stack through the
  runner (AF-8 — `OperationsRunner: MCPWriteExecutor`, the one-collector compound safe); exact-row
  inverses and redos (take: tombstone with chosen/I10 guards, resolvable refusal keeps the entry —
  pinned; lens: trigger-cascaded choices revived on the exact stamp; membership: a seated arrival
  returns to the door with its position, a fresh row tombstones, redo re-seats with the ownership
  revival pass; tag: application only, intake seat stays, minted vocabulary stays; note/book: the
  13n-a stamp-keyed container/book inverses, memberships and applications cascading and returning
  with the note). The bulk import is ONE compound entry (pinned; walked; the live round's ⌥⌘Z leg).
- **Adoption lands OFF (R-13nb-6, ledger row 10):** `landMCPAfterAdoption` writes server-OFF + the
  hold-stamp ack in ONE transaction; the same hold is a no-op afterwards (her re-enable stands); a
  new hold lands OFF again; grants/clients/open-book untouched — pinned headless both ways. The door
  sequences the landing BEFORE its grants observation starts (no stale ON snapshot can start a
  server; `started == 0` pinned on the Mac), a failed landing keeps the server down, detach resets;
  `VariorumApp` really passes `bootstrap.liveStoreURL`. Zero lines in the 13x road itself.
- **read_note with_ids (AF-5):** same transaction, same decision, same once stamp as the text form
  (pinned, fence words byte-identical, the once spend shared); the shown-take rule matches AppSpec
  §7's fallback exactly (chosen while live+active+on this block, else default, else fan's first);
  active takes only; block `name` rides where set and never as an address (R-13nb-8/9 — the catalog
  description carries the ids-are-live doctrine verbatim); cost ∝ the note (three statements).
- **The catalog's `scopes` refactor preserves U1's listing semantics exactly** (list_books book/wing;
  search keeps `needsStandingReach` through `searchGrants`), and the new tools' scope sets are
  right (create_note/import book+wing; create_book wing-only — "a book grant can't make a book",
  pinned); declared ⇔ handled holds across BOTH handlers, disjoint, no edit rung declared (P-2).
- **Faces:** `markNotePrivate`/`markBookPrivate`/`mcpAnswerAsk` registry-declared with the walk
  extended (justified edits annotated); the gathering sheet never renders the book row (kind
  check + op refusal, P-2); the note row draws only a state loaded for THIS note; the ask sheet's
  system buttons are W-3's recorded fix with the library-open sheet's precedent; receipts coalesce
  per client·target in a 120 s window with the W-2 count fallback so "⌥⌘Z undoes" never truncates
  away (pinned); the chip reads `mcpReachableBookIDs` — the SAME pure rule per book × client, never
  a parallel SQL fence, honest under book/wing grants and the open book, never a journal or Private
  book (pinned); `mcpNoteSharing` answers each approved client's highest rung through `decide`.
- **P1/P2 on the door:** every write tool parses arguments BEFORE the executor; decisions read on
  the reader pool; the serial body is the same latency class as her own File ▸ Import (AF-8's
  stated watch); nothing walks the corpus.
- **The counts reproduce:** core 2,534/291 (+23/4 over the v1_25 baseline, as recorded) ·
  VariorumMCPTests 32/4 · workbook 40/6, gated skips only — my own runs.
- **Hygiene:** zero implementer lines in `Sync/` (AF-4), zero custody, zero editor seam, the export
  pin untouched, no trailers, every commit pushed; R-13n-1 holds (nothing assumes the client is
  external); MOBILE: nothing mobile-visible (the columns arrive on the phone as ordinary rows; the
  §12 refusal grammar covers the marker-12 phone until her window).

**VERDICT: 0 BLOCKER · 1 MAJOR · 2 MINOR-class (1 MINOR architectural) · 3 NIT (F3 record-only,
F4/F5 record-wording).** The U2 boundary itself — the suggest proof, the scope discipline, the
fence's third leg, AF-7, the ask's no-oracle grammar, the per-act undo — is solid and pinned from
the pure rule through the ops to a real socket session; F1 is the one real defect, and it sits in
the lockstep event's blast radius (the §7 classifier families), not in the unit's own code.

## ROUND 1 — IMPLEMENTER RESPONSES (opus-implementer, 2026-10-09 — every finding re-traced against the code at `d24e77b6`; no fix made in this pass)

**Five AGREE, zero disputes.** Nothing here is undefined product behaviour, so nothing is flagged.

- **F1 [MAJOR] — AGREE, severity right.** Re-traced: `guideVerdict`
  (`SeededFurnitureDedupe.swift:518-544`) and `noteVerdict` (`:699-712`)
  enumerate their columns, and `ai_private_at` is in neither; the same holds
  for `SampleLibraryDedupe`'s book read (`:801-815`) and per-note read
  (`:873-884`). Grep confirms the only readers of the column are
  `MCPGrantQueries` and `Operations+PrivateMark` (plus the migration and
  `SyncSchema`). The mechanism holds: the fold keeps the SMALLEST id
  (`SeededFurnitureDedupe.swift:250`) and the both-pristine sample-library
  arm does the same, so a mark-only copy with the larger id is tombstoned
  and the converged library carries no mark. That is a disclosure fence
  silently cleared, against the "her engagement keeps both" letter —
  `archived_at`, the same disclosure class, is engagement at every one of
  these sites. I missed this because my "zero `Sync/`" boundary kept me out
  of those files, and the v1_25 "no new §7 repair" line spoke only to the
  merge matrix. Agree with the fix (one engaged/edited leg per classifier:
  `guideVerdict`, `noteVerdict`, both `SampleLibraryDedupe` reads,
  optionally `gatheringIsSeedsOwn` as defence), landing BEFORE the deploy
  window, in the reviewer's hands (AF-4). In the sample-library arm,
  counting the mark as EDITED also gives the right keeper ("exactly one
  edited → the EDITED copy kept"), not just both-survive. **One adjacent
  observation for the reviewer's call (O1, no fix lean):** the
  membership-moving repairs move the fence's BOOK route with them. The
  OWNED-exclusivity repair can tombstone a later plain-side membership; if
  that membership was in a Private book, the note stops being fenced
  through it. That is "the fence reads current membership" applied to a
  membership the ownership rules forbade, and the note's OWN mark is never
  touched by any repair. I judge it as designed, but name it so the
  boundary is stated.
- **F2 [MINOR, architectural] — AGREE.** Re-traced: `onBlock` reads the
  note (`MCPWriteTools.swift:288`), `onNote`/`into`/`inWing` decide on a
  `database.read`, and the act opens its own write inside `land`. Every
  app-side writer rides the runner, but the sync engine's apply transaction
  does not, so a synced mark, move or tombstone can land between the two.
  Lean: **record for U2** beside P-13nb-U2-8 as its sync twin (additive,
  labeled, undoable; one in-flight call; the next call refuses). But
  **U3's edit rung should NOT inherit the gap.** `edit_take` overwrites a
  take (under insurance), so a write past a just-closed fence costs more.
  The injected-precondition shape the reviewer named fits there without
  breaking "ops decide nothing about clients": the op takes a
  `(Database) throws -> Void` guard, runs it first inside its own
  transaction, and the guard re-decides through `MCPGrantRule` on facts
  read in that transaction. `edit_take`'s `expectedText` is already an
  in-transaction precondition of the same family. Suggest that line for
  U3's brief; retrofitting the eight U2 ops is optional at the same time.
- **F3 [NIT] — AGREE, record-only.** One detail sharpens the trace: the
  success-path `try log(...)` sits INSIDE `land`'s `do`
  (`MCPWriteTools.swift:438`). A throw there falls into `land`'s own generic
  `catch`, which logs again as `allowed: false` — so if that second log
  succeeds, the activity line records a LANDED act as refused, on top of
  the client's error. Same store-death race and same class; no honest
  deterministic pin without a fault-injecting stub, so recording follows
  the ladder's rule. If it is ever closed: move the success log OUT of the
  act's `do` and make it `try?`, keeping `try` on the refusal logs.
- **F4 [NIT → reruled by the AF-7 amendment `d24e77b6`] — AGREE, a
  small fix is owed under the amended letter.** The built
  `spends(grant, rung, consumes) = once ∧ consumes ∧ rung == grant.rung`
  (`MCPGrantRule.swift:238-240`) is exactly the hole: under a once
  WRITE-NEW grant, a suggest-rung write rides free, unbounded, and the pin
  asserts it (`MCPGrantRuleTests.swift:237-238`). The amended rule in one
  line: `once ∧ consumes ∧ (grant.rung == .read ? rung == .read : rung >= .suggest)`
  — a read grant is spent by its content read, a write grant by its first
  write of any rung, and reads ride free under a write grant. Pins, both
  ways, for whoever makes the fix:
  - flip the explicit pin's line 237-238: a suggest write under a once
    write-new grant SPENDS it (`consumesOnce: true`);
  - a content read under a once write-new grant still does NOT spend;
  - restate the sweep's invariant 3 to the amended biconditional (with
    `grantID == g.id`): `consumesOnce ⇔ consumes ∧ once ∧ live ∧ (g.rung == .read ? asked == .read : asked >= .suggest)`
    — it should go red on the current expression;
  - optionally an end-to-end leg in `MCPWriteServerTests`: under a once
    write-new book grant, `add_take` lands and the following `create_note`
    refuses.

  `decideWing` and `noteIntoBook` share `spends`, so they follow
  automatically. My e2e once-suggest pin is unaffected. The record's
  P-13nb-U1-2 amended form, and my unit record's stated edge ("a
  once-suggest grant authorizes ONE write"), need the second-amendment
  wording: a once write grant authorizes ONE write, whatever its rung.
- **F5 [NIT, record] — AGREE.** The book-specific fence words I added
  ("That book is a journal. …" / "That book is marked Private — never
  shared with AI.") make a fenced book distinguishable from an
  unshared/missing one for a client holding a pre-mark id. Same exposure
  analysis as U1's F4 (listings drop the book on the next call — pinned).
  Extend P-13nb-U1-13's text to books; no code change.

## ROUND 1 — IMPLEMENTER SANITY PASS (opus-implementer, 2026-10-09, on `87236904`)

**PASS — with one comment-accuracy NIT (N1) and one new observation (O2) for round 2's framing.**
I read both fix diffs whole (`15933ab4` F1, `d60c3ad6` F4) and the records commit `87236904`. I fixed
nothing. What I ran, all headless:
- **The whole package, `swift test` on `87236904`:** core **2,538/291**, VariorumMCPTests **33/4**,
  workbook **40/6**, gated skips only. This reproduces the reviewer's counts.
- **An independent red-on-old run.** I exported the `87236904` tree to a scratch directory outside the
  repo. There I swapped the three fixed files for their pre-fix versions: `15933ab4^`'s two classifiers
  and `d60c3ad6^`'s `MCPGrantRule.swift`. Then I ran the seven pins. **All seven are red:**
  - F1, four of four: 2 + 1 + 6 + 6 issues.
  - F4, three of three: the explicit pin 1 issue, the sweep's invariant 3 30 issues, the e2e 1 issue.
  - The once-SUGGEST e2e pin is green on both sides, as expected.

  I then deleted the scratch tree. Nothing in the worktree was touched.
- **A scratch-only probe** of `best()`'s tie-break (O2 below), in the same scratch tree and never committed.

The reviewer's look-first list:
1. **F1's legs: confirmed.** At all five sites the SELECT carries `ai_private_at`, and the check
   consumes that same row:
   - the gathering candidates' row → `gatheringIsSeedsOwn` (:354);
   - `guideVerdict` (:528 → :544);
   - `noteVerdict` (:713 → :722);
   - the sample book-shape read (:805 → :819);
   - the sample per-note read (:882 → :893).

   The pool grain needs no leg of its own. It routes through `noteVerdict` ("One note's (or pool's)
   verdict"), so it carries the leg anyway, as defense. Pools are also unmarkable: `setNotePrivate` →
   `livePost` refuses `wrongContainerKind`.
2. **F4's shared `spends()`: confirmed.**
   - It has two call sites, `decide` (:219) and `decideWing` (:262).
   - The MCP layer never re-derives spending. Every write and read tool consumes the decision's
     `consumesOnce`: `MCPWriteTools` :319/:384/:410, `noteIntoBook`'s Set-deduped two-sided spend, and
     `MCPReadTools` :82–90.
   - A read under a once write grant rides free (`rung == .read`, `grant.rung ≥ .suggest` → false).
   - `best()` prefers standing grants over once grants (pinned: `aStandingGrantCoversFirst…`), so a
     once grant is never spent where a standing grant suffices.
   - No surviving pin encodes the old reading. The rule pins, the sweep and both e2e pins all read the
     amended rule.
   - **N1 [NIT, comment accuracy — my own U2 comments].** Four comments still say "at its own rung":
     - `MCPWriteTools.swift:17` — the struct doc, "AF-7: spent by its first write at its own rung";
     - `MCPWriteTools.swift:305` — `onNote`'s doc;
     - `MCPGrantAuthority.swift:58` — the book `decide`'s `consumes` doc;
     - `MCPWriteServerTests.swift:16` — the file header.

     Behavior follows `spends()`, so these are wording only. The plan's AF-7 heading ("spends AT ITS
     OWN RUNG: proposal APPROVED") and my F-3 fork text are history with the amendment printed
     directly beneath them, so they are fine as they stand. **Suggested:** a one-pass rewording at the
     next touch, to "spent by its first write of any rung it authorizes".
   - **O2 [observation — a new consequence of F4; undefined behavior, so it goes to the coordinator].**
     `best()` breaks a tie between grants of equal duration by smallest id, never by rung or scope.
     - *Before the amendment*, the tie-break never decided what got spent at mismatched rungs, because
       a higher-rung once grant did not spend on a lower-rung write. That was F4's hole.
     - *Now* it decides. With a live once-suggest on a note and a live once-write-new on its book, a
       suggest-rung write spends whichever grant has the smaller UUID.
     - *The scratch probe:* with ids `a-writenew` / `b-suggest`, `decide` answers
       `allow(grantID: "a-writenew", consumesOnce: true)`. The write-new is spent and the narrower
       once-suggest survives. Swap the id order and the suggest is spent.
     - *From her side:* the choice is deterministic across devices but arbitrary.
     - *Reachable:* two just-in-time asks she answered "Once" at different rungs or scopes.
     - *Bounded:* there is no over-reach either way, since each spend allows exactly one write that the
       spent grant authorized. The cost is losing a write-new grant where a suggest grant would have done.

     Options:
     - (a) among equal durations, prefer the lowest sufficient rung, then the narrowest scope (spend the
       least capability that suffices);
     - (b) prefer the highest rung (spend the most capability — the privacy-conservative reading);
     - (c) keep smallest-id and record it.

     **My lean is (a).** It is one comparator change in `best()`: `decide` and `decideWing` call it on
     `sufficient` only, and the open-book branch filters out once grants, so it is unaffected. It would
     be pinned by a two-once-grants `decide` case. It is product-shaped, so the framing is yours.
3. **The F1 fixtures isolate the mark: confirmed, statically and dynamically.**
   - *Statically:* `setNotePrivate` and `setBookPrivate` write only `ai_private_at` + `updated_at`. No
     classifier reads `updated_at`: the only `updated_at` hits in both files are the classifiers' own
     tombstone/rewrite UPDATEs. The gathering pin's raw UPDATE writes `ai_private_at` alone.
   - *Dynamically:* the red-on-old run shows every marked copy folding on the old classifiers.
   - *One shading, not a defect:* `herPrivateMarkKeepsBothCopiesOnEveryGrain` marks the smaller-id side
     (A). On old code the marked copies won the toss, so its `marksStand` assertions were green there;
     its red comes from the two count assertions. The "the mark itself dies" consequence is carried by
     the two sample pins: there B, the larger-id side, marks, and `fenceStands` is red on old. The class
     is covered.
4. **The record edits: all four present and accurate.**
   - P-13nb-U2-8's sync twin matches my F2 response, including the `edit_take` guard.
   - Ledger row 5 carries the guard line.
   - P-13nb-U1-2's amended form carries the "one write means one write" wording.
   - P-13nb-U1-13's books extension is in the U1 round-1 record. I checked its claims:
     - "(pinned — `markingPrivateFencesTheVeryNextCallOfAConnectedClient`)": that pin's last leg asserts
       `list_books` comes back empty after `setBookPrivate`.
     - "a fenced book never raises an ask": this matches the built guard (`MCPGrantAuthority.swift:186`).
