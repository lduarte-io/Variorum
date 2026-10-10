# 13n-b U1 — ladder round 1 (cold review, fable-reviewer, 2026-10-09)

**Diff reviewed:** `ddf6f824..b9492ced` (the whole effort to date: kickoff → U1 closed → live round).
**Anchor:** `notes/plans/phase-13n-b-mcp-door.md` (read whole, incl. the U1 unit record and live round), the
13n sitting record (R-13n-1…11), the approved mockups, `phase-13n-mcp-door-note.md`,
*[removed for publication]*
**Verified myself:** every new source and test file read in this session; `swift build` green;
`swift test --filter 'MCPGrantRuleTests|MCPGrantOperationsTests|MCPGrantSchemaTests|SyncSchemaTests|MigrationTests'`
→ 74/74; `swift test --filter VariorumMCPTests` → 19/19 (matches the unit record's counts). No stage claim
needed (headless only); no Mac-suite re-run this round (the implementer's 65/65 run is recent and the Mac
surfaces are walk-covered; round 2 can demand one if fixes touch them).

The plan carries no plan-time "Review foci" section. The implementer's self-named look-first spots
(`sharedPage`'s merge, search's post-filter, once-never-in-search, the transport cap + accept stop,
`MCPDoor`'s off-main start) were each traced; results below and in the clean bill.

## Findings (severity-ranked; format: [severity] · where · what · evidence · fix)

### F1 — [MINOR] · `Sources/VariorumMCP/MCPToolCatalog.swift:28-34` + `MCPReadTools.swift:362-405` · `search` is listed for a standing it can never serve (P-2 on the wire broken for once-only clients)

**Evidence (traced):** `MCPToolDeclaration.isListed` lists `search` whenever any live grant covers the read
rung (`needsBookOrWingReach == false`, no duration test). But the handler deliberately excludes once grants
twice over: `reachedScopes` filters `duration != .once` (line 363), and an explicit `note_id` covered only by
a once grant fails `isStandingAllow` (line 319 → the `.notShared` refusal). So a client whose ONLY live grant
is a once note grant sees `search` in `tools/list`, and every call it can make returns `{"passages":[]}` or
the not-shared refusal — a door that can never act as named, exactly the class the walk's finding 4 fixed on
the pane ("while connected" offered to a disconnected client). The plan's own constitution line: "a tool the
grant excludes is not listed to the client (P-2 on the wire: no door that can never act)."
**Pin (red-on-old):** approve a client with ONLY a once note grant; assert `tools/list` omits `search`
(old code lists it). **Fix:** teach the catalog the same restriction the handler enforces — `search` listed
only when a NON-once grant (or the open book) covers the rung; alternatively declare `needsStandingReach` on
the declaration so listing and serving read one rule. (Letting search serve once grants instead would
contradict the recorded deliberate restriction — P-13nb-U1-2's spirit — so the catalog side is the
spec-defensible fix.)

### F2 — [MINOR] · `Sources/VariorumMCP/MCPReadTools.swift:114-121` · `list_books`' per-book `notes` count counts members the fence hides, disclosing a hidden member's existence

**Evidence (traced):** the count subquery (`SELECT COUNT(*) FROM reading_post rp JOIN container c …
rp.status='member' AND c.deleted_at IS NULL`) has no fence leg, while `list_notes(book_id:)` filters every
fenced member per note (the per-row `decide` after `bookPage`). A granted book holding one prose note and one
journal member answers `"notes": 2` while listing exactly one note — the client can subtract and learn a
hidden member exists in that book, ambient, with no ask. The server tests' own fixture shape
(`journalsNeverRideAStandingGrantOrTheOpenBook`: book with `prose` + `entry`) exhibits it. Journals'
posture is per-ask, never ambient (R-13n-4, §9); and "honest counts" is the app's own standing rule — this
count is dishonest in both directions at once (claims 2, shows 1).
**Pin (red-on-old):** a book with one prose + one journal member, book grant; assert `list_books` answers
`notes == 1` (old answers 2). **Fix:** count what the client can list — add the same journal/fence legs to
the count subquery (the `mcpNoteFacts` legs as an EXISTS fragment), or count via the batched facts for the
page. Cost stays ∝ the book.

### F3 — [MINOR, architectural — traced degradation, no pin owed] · `Sources/VariorumMCP/MCPReadTools.swift:61/82/143/313` · every read tool holds the ONE write connection for its whole duration, so a heavy MCP read briefly blocks her own writes

**Evidence (traced):** all five tools run inside `database.write`. For `read_note`/`export_note` the
transaction is load-bearing (the once-grant stamp must be atomic with the read — the file header says so,
and `consumeMCPOnceGrant` + the activity line are the writes). But `list_books`, `list_notes` and `search`
write only the one activity line, and `search` runs the full 13o engine inside the writer — under the open
book, one `searchPassages` pass per live wing plus per-passage `mcpBookFacts` reads (lines 342-351). GRDB
serializes writes: while such a call runs, her keystroke's `autosave` (a `database.write`) queues behind it.
Cost is still ∝ scope/matches (P1 holds), so this is a latency hazard, not a scaling one — but P2's intent
("reads never block writes; WAL + reader pool") is inverted for the door's read path, and the reader pool
sits unused. **Justification for no pin:** architectural; no wrong output exists to pin.
**Fix shape (if taken):** keep `read_note`/`export_note` as they are (atomicity is the boundary); for the
three non-consuming tools, decide + log in a short write transaction and assemble the heavy answer on a
reader — the decision facts are re-read per call anyway, so the split loses nothing the next call wouldn't
re-check. Equally acceptable: record as a deliberate tension with the reasoning in the plan (the write-rung
units will revisit the transaction shape regardless).

### F4 — [NIT] · `Sources/VariorumCore/Domain/MCPGrantRule.swift:220-222` + `MCPGrantAuthority.swift:102-108` · the fenced refusal is distinguishable from not-shared for a probed UUID

**Evidence (traced):** a fenced note with no reaching grant answers `.ask(.fenced(…))` → "That's a journal
entry…", while a plain unshared note answers "…isn't shared…, or doesn't exist." A client holding a known
UUID can tell "live journal entry" from "unshared/missing" — a narrow existence confirmation. Exposure is
nearly vacuous by construction: listings and search NEVER emit fenced ids (verified in `listNotes`'
per-row filter, `reachedScopes`/`passes`, and the e2e pins), so the only wire road to such an id is a prior
per-ask grant on that very note — at which point journal-ness was already deliberately disclosed. Recorded
so the choice is deliberate: the distinct wording is useful to an agent (it teaches "ask the author"), and
U2's just-in-time ask will want the fence reason anyway. If the one-answer doctrine should cover fenced
notes too, the pin is: read_note on a never-granted journal id answers with the not-shared words (red on
old). My lean: keep as built, record the choice in the plan's PROVISIONALs (it is not currently written
down anywhere).

### F5 — [NIT] · `Sources/VariorumMCP/MCPReadTools.swift:131-136, 489-509` · a cursor minted under one listing order is accepted by another

**Evidence (traced):** `PageCursor` is `(key, id)` with no shape tag; a `next_cursor` from
`list_notes(book_id:)` (key = fractional position) replayed against `list_notes(wing_id:)` (key = touched
stamp, DESC) is decoded happily and compared against the wrong column — a garbled page (likely empty), never
a leak (every row still passes the rule per note). An honest client never does this; a confused one gets
confusing emptiness instead of the "not a next_cursor this server returned" refusal the code already has for
undecodable cursors. **Fix (cheap):** prefix the encoded cursor with the listing shape ("b\n"/"r\n") and
refuse a mismatch with the existing message.

### F6 — [NIT] · `Sources/VariorumMCPSocket/MCPSocketRoad.swift:148-158` · the stale-socket replace is probe-then-unlink (TOCTOU) between two same-bundle-id instances

**Evidence (traced):** `listen` connect-probes (live ⇒ `alreadyServed`), else `unlink` + `bind`. Two
instances of the SAME app id starting simultaneously can both probe-fail, and the second's `unlink` orphans
the first's just-bound socket (first keeps a listener no path reaches; clients get the second). Reachability
is deliberately narrow — LaunchServices resists same-id double-launch, the non-racing case is pinned
(`alreadyServed` in `theSocketIsPrivateWhileServingAndGoneAfterStop`), and both instances would be HER dev
builds. Worst outcome is a confused dev walk, not a boundary break (whichever instance serves, the same
grants store rules every call — same container, same store). Record-only; an flock-style lock file would
close it if it ever bites.

### F7 — [MINOR] · `Sources/VariorumMCP/MCPServerHost.swift:119-152` + `MCPSocketTransport.swift:35-48` · no cap on concurrent connections: one thread + one session per accept, unbounded

**Evidence (traced):** the accept loop admits every connection; each `serve` mints an `MCPSession` (its own
SDK `Server` + a dedicated blocking reader `Thread`), with no ceiling anywhere. A runaway or malicious local
client that loops `connect()` grows the app a thread per connection until thread exhaustion kills the app —
the line cap (16 MiB) bounds memory per line but nothing bounds session count. The threat is weak (a hostile
local process has better options — A-4's recorded boundary) but the realistic bug is a client stuck in a
reconnect loop, and the failure mode is the APP dying, not the client. **Pin (red-on-old):** open N (say 64)
connections; assert the server stops accepting past its cap while the first connections still serve (old
code accepts all N). **Fix:** refuse (close immediately) past a small cap of live sessions — Claude Code
uses one or two; 16 is generous.

## Implementer responses / dispositions (round 1)

**FINAL DISPOSITIONS (the reviewer's calls on the implementer's responses — fable-reviewer, 2026-10-09,
the fix pass its own; every bug-class fix carries a red-on-old pin verified before the fix landed, one
commit per fix, suites green after the pass).**

| # | Severity | Response | FINAL disposition |
|---|---|---|---|
| F1 | MINOR | AGREE — catalog-side, ONE shared rule; the once-BOOK-grant search road closes too | **FIXED (995d9cc7)** — `Standing.searchGrants` is THE shared standing-reach set: the declaration's `needsStandingReach` lists by it, `reachedScopes` builds scopes from it, and the `book_id` road now requires `isStandingAllow` exactly like `note_id` (the implementer's refinement accepted — a once book grant no longer serves an eternally empty allowed page). Pin red-on-old: `searchIsNeitherListedNorServedForAOnceOnlyStanding` (3 expectations failed pre-fix). |
| F2 | MINOR | AGREE — count through the same facts and `decide`, never a parallel SQL fence | **FIXED (00a6c943)** — the count reads the same member rows as `bookPage`, batches the same `mcpNoteFacts`, counts what `decide` allows; archived members stay counted (the listing shows them — the implementer's note accepted). Pin red-on-old: `listBooksCountsOnlyTheNotesTheClientCanList` (pre-fix counted the journal member). |
| F3 | MINOR (arch) | AGREE — prefers the FIX over record-as-deliberate | **FIXED (cb6b8c54)** — the reviewer takes the implementer's preference: `read_note`/`export_note` keep the one write transaction (once-stamp atomicity IS the boundary); `list_books`/`list_notes`/`search` assemble the whole answer in ONE read snapshot and log in a short write after (`logAfter`); revocation mid-call honoured next call; every refusal still logged. No pin owed (architectural); the 23 e2e pins hold behavior unchanged. |
| F4 | NIT | AGREE with the lean — keep as built | **RECORDED — PROVISIONAL P-13nb-U1-13** (below; joins the merge QUESTIONS bundle beside P-13nb-U1-1…12). |
| F5 | NIT | AGREE — tag the cursor | **FIXED (acadef10)** — `PageCursor` encodes `(shape, key, id)` ('b' book order / 'r' recency); a crossed replay refuses with the existing stale-cursor words (one constant). Pin red-on-old: `aCursorMintedUnderOneListingOrderIsRefusedByAnother`. |
| F6 | NIT | AGREE — record-only | **RECORDED** — the probe-then-unlink TOCTOU stands as a documented corner: both racers would be her own dev builds over the same container and store, the non-racing case is pinned (`alreadyServed`), and the same grants store rules every call whichever instance serves. The road if it ever bites: an flock'd lock file beside the socket. |
| F7 | MINOR | AGREE — cap 16; refuse with one honest JSON-RPC error, short-lived helper, ~2 s receive timeout | **FIXED (db7d3571)** — `sessionCap = 16`; past it the first request is answered by `MCPShim.refusalResponse` (id echoed, `readFirstLine` made public for this one reuse) then closed, on a helper thread with `SO_RCVTIMEO` 2 s so a silent client never stalls the accept loop (the implementer's refinement accepted whole — a bare close would leave Claude Code saying only "failed"). A closed connection frees its slot. Pin red-on-old: `connectionsPastTheCapAreRefusedWithOneHonestErrorAndSlotsFree` (pre-fix the 17th initialize was served). |

**PROVISIONAL P-13nb-U1-13 (F4's record — for the merge QUESTIONS bundle):** the FENCED refusal is
deliberately distinguishable from not-shared ("That's a journal entry… shared one ask at a time" /
"…marked Private…" vs "…isn't shared…, or doesn't exist"). A client holding a known UUID can therefore
tell "live fenced note" from "unshared/missing". Kept as built because (1) the words carry the
ask-the-author road U2's just-in-time ask formalizes, and (2) the exposure is nearly vacuous by
construction: listings and search never emit fenced ids, and note text cannot carry another note's id
(`MarkdownLink` opens http/https only — the implementer's added fact), so the only roads to a fenced id
are a prior per-ask grant on that very note or an id obtained outside Variorum. If she ever wants the
one-answer doctrine extended to fenced notes, the pin is: read_note on a never-granted journal id answers
with the not-shared words (red on today's build).
*(EXTENDED at the U2 ladder round 1, F5 — fable-reviewer, 2026-10-09: the same class now covers FENCED
BOOKS. U2's book-specific fence words — "That book is a journal. …" / "That book is marked Private —
never shared with AI." — let a client holding a book UUID from a pre-mark listing tell "live fenced
book" from "deleted/unshared" ever after. Same exposure analysis: listings drop a fenced book on the
very next call (pinned — `markingPrivateFencesTheVeryNextCallOfAConnectedClient`), a fenced book never
raises an ask, and the distinct words carry the ask-the-author road. Kept as built; this paragraph is
the one record for both shapes in the merge QUESTIONS bundle.)*

**Fix-pass verification (2026-10-09, headless — no stage needed; zero Mac-app files touched in the
pass):** whole package `swift test` green — core **2,511/287** (the pre-pass baseline held),
**VariorumMCPTests 23/3** (19 + the four new pins), workbook **40/6**; the only skips are the
long-standing gated ones. Commits `995d9cc7 · 00a6c943 · acadef10 · db7d3571 · cb6b8c54`, each pushed.

**For round 2, look first at:** (1) F1's shared rule — `searchGrants` consumers (catalog listing,
`reachedScopes`, both explicit-scope roads) for any road still reading `liveGrants` where standing reach
is meant; (2) F2's count — now ∝ members per listed book (one extra batched facts read per book; confirm
the shape under a wing grant listing many books); (3) F3's split — the three tools' answers now come from
a READ snapshot: confirm no consumer assumed the activity line landed atomically with the answer, and
that `logAfter` on a just-locked store failing loud (it throws out of `call`'s catch-all as the generic
error) is acceptable; (4) F7's helper — the refused fd's lifecycle (closed exactly once, by the helper).

## ROUND 1 — IMPLEMENTER RESPONSES (opus-implementer, 2026-10-09 — every finding re-traced against the code at `b9492ced`; no fix made in this pass)

**Seven AGREE, zero disputes.** Nothing here touches undefined product behaviour, so nothing goes to QUESTIONS from this side.

- **F1 — AGREE.** Confirmed: `isListed` (MCPToolCatalog.swift:28-34) tests only rung and scope kind,
  while `reachedScopes` drops once grants and the `note_id` road requires `isStandingAllow`. Also
  confirmed via `book_id`: a once BOOK grant passes the book decision, but every passage then fails
  `passes` → `isStandingAllow`. So a once-only client's `search` can never return a passage. Agree on the
  catalog side, with ONE rule shared by listing and serving (e.g. a `needsStandingReach` flag, or the
  handler's own once-exclusion as a static the catalog reads), so the two can't drift again. The
  once-never-in-search restriction itself should stand.
- **F2 — AGREE.** Confirmed: the count subquery (MCPReadTools.swift:114-121) has no fence leg, while
  `list_notes(book_id:)` filters per note. The fix should count EXACTLY what `list_notes(book_id:)` would
  emit, through the same facts and `decide`, not a parallel SQL fence that could drift from
  `mcpNoteFacts`. Cost stays ∝ the book (one batched facts read per book). Note: `bookPage` does not
  exclude archived members, so archived members belong in the count too; only fenced ones (and anything
  `decide` refuses) come out.
- **F3 — AGREE; I'd take the fix rather than record it.** The once-stamp atomicity is the only reason
  `read_note`/`export_note` need the writer, and they should keep it. For `list_books`, `list_notes` and
  `search`, assemble the whole answer (standing, facts, `decide`, the page, the per-note filter) in ONE
  `database.read` snapshot, then a short `database.write` for the activity line alone. That keeps every
  decision internally consistent (one snapshot) and frees the writer for her autosave. Search under the
  open book is the real offender. Semantics stay honest: a revocation that lands mid-call is honoured on
  the next call, exactly as the record already states.
- **F4 — AGREE with the reviewer's lean: keep as built, record it as PROVISIONAL.** One added fact: note
  text cannot carry another note's id (`MarkdownLink` opens http/https only; there are no internal
  note-id links). So the only roads to a journal id are a prior per-ask grant on that very note or an id
  obtained outside Variorum. The distinct words carry the "ask the author" road that U2's just-in-time ask
  will use.
- **F5 — AGREE.** A shape-tagged cursor ("b"/"r") refused on mismatch with the existing "not a
  next_cursor this server returned" words is cheap and honest. Severity is right: every row still passes
  `decide`, so a garbled page can never leak.
- **F6 — AGREE, record-only.** The non-racing case is pinned, and both racers would be her own dev
  builds over the same container and store, so the same grants rule every call either way. An flock'd
  lock file is the road if it ever bites.
- **F7 — AGREE.** Confirmed: `serve` (MCPServerHost.swift:144-146) mints a session and a reader thread per
  accept, with no ceiling. A cap of 16 live sessions is generous. **One refinement for the reviewer's
  call (P-2):** past the cap, don't just close. Answer the client's first request with one JSON-RPC error
  ("Variorum is serving its maximum of 16 connections — close another MCP client and reconnect"), then
  close. `MCPShim.refusalResponse(toFirstLine:message:)` already builds exactly that line and VariorumMCP
  already links VariorumMCPSocket. Read the first line on a short-lived helper with a receive timeout
  (e.g. `SO_RCVTIMEO` 2 s), so a silent client can't hold the accept loop. A bare close would leave Claude
  Code saying only "failed".

## ROUND 1 — IMPLEMENTER SANITY PASS (opus-implementer, 2026-10-09, on `dca3319b`)

**PASS.** I read the five fix diffs whole (`995d9cc7`, `00a6c943`, `cb6b8c54`, `acadef10`,
`db7d3571`) plus the four new pins. Ran headless on `dca3319b`: `swift build` green; `VariorumMCPTests`
**23/23** (3 suites); `MCPGrantRuleTests|MCPGrantOperationsTests|MCPGrantSchemaTests|SyncSchemaTests`
**45/45** (4 suites). No core source changed in the pass, so the 2,511/287 core count stands. No Mac
suite needed (no app file touched). Fixed nothing.

The reviewer's look-first list:
1. **Roads still reading `liveGrants` after F1** — every remaining reader is a LISTING, where once grants
   belong (`list_books`' candidate books, `sharedPage`'s candidates — P-13nb-U1-2: a listing never spends
   or excludes a once grant). Every SEARCH road now reads standing reach: `reachedScopes` →
   `searchGrants`; `note_id` and `book_id` → `isStandingAllow`; per-note passages → `isStandingAllow`.
   **Observation O1 (NIT, latent, no wrong output today):** `passes` answers a book/chapter NAME hit with
   `decide(book).isAllowed`, not `isStandingAllow`. I traced every scope shape: wing scopes come only from
   standing wing grants or the open book, book scopes only from standing book grants, and note scopes
   carry no book hits. So a book hit always lies under standing reach, and nothing leaks. But the "one
   standing-reach rule" isn't literally uniform, and a future scope shape could drift. Worth one line in
   round 2 (route it through `isStandingAllow` too), not a fix this round.
2. **F2's count under a wing grant listing many books** — per listed book: one member-id read (∝ its
   members) + one batched `mcpNoteFacts` (∝ its members) + `decide` per member. Total ∝ the reachable
   books' membership, which IS `list_books`' scope, so P1 holds. The constant is heavier than the old
   `COUNT(*)` (the journal EXISTS leg per member), and a wing grant on a large library reads facts for
   every membered note in the wing per call. F3 moved this onto a read snapshot, so it never queues her
   writes. Acceptable as built. Pagination of `list_books` is the road if a library ever makes it slow.
   The count matches `bookPage`'s rows exactly (same `kind = 'post'` filter; archived counted since
   listed; versions have no facts, so neither listed nor counted).
3. **F3's split** — no consumer assumes the activity line lands atomically with a non-consuming answer.
   The only activity read in the suites (`aNewClientIsAPendingRequest…`) follows `read_note`, which
   still logs inside its own transaction; the pane's activity face is U3's, not built. `logAfter` on a
   store that locks between snapshot and log throws, and `call` turns it into the generic "couldn't
   complete" error, discarding the computed answer. That's the safe direction, and the server is stopped
   at lock anyway (`onWillLock` → `detach`), so the window is the race itself. Argument failures still
   throw before either transaction and stay unlogged, as before. `AppDatabase.read` goes through the
   writer's `read`, which is the reader pool on the app's `DatabasePool`, so the split really frees the
   writer.
4. **F7's refused-fd lifecycle** — closed exactly once, by the helper thread. `serve` returns without
   touching the fd, the accept loop never closes it, and `stop()` never sees it, since a refused fd is
   never in `sessions`. `SO_NOSIGPIPE` is set at accept, before `serve`, so the helper's write to a
   vanished client can't signal. The count-then-insert runs in two lock sections, but only the accept
   thread inserts, so the cap can't be overshot. **Observation O2 (NIT, residual of the fix):** the
   refusal HELPERS themselves have no ceiling. Each over-cap connection gets a thread, and `SO_RCVTIMEO`
   bounds each `read`, not the whole line, so a slow-drip client (one byte every <2 s) can hold a helper
   up to the 1 MiB line limit. The realistic bug, a client in a reconnect loop, sends its `initialize` at
   once and frees its helper in milliseconds. A deliberate flood or drip is a hostile local process,
   which A-4's recorded boundary already concedes has better options. If round 2 wants it closed: cap
   concurrent refusal helpers (say 4) and close bare past that, or bound the helper by a wall-clock
   deadline rather than per-read.

## Clean bill (load-bearing things specifically checked and found solid)

- **The boundary is genuinely one pure rule, and it holds.** `MCPGrantRule` read whole: client gate
  (pending/denied/unknown refuse outright), cumulative rungs, scopes against CURRENT facts (a moved note
  refuses today — pinned end-to-end), durations (once spent only by a content read, in-transaction, never
  when a standing grant or the open book also covers — `best` prefers standing, verified), the open book
  read-only for approved clients on unfenced targets only, the fence (per-ask note grants only, never
  "always"; a fenced book reached by NOTHING). The 13,824-world sweep's four invariants restate the boundary
  independently; the suite ran green in this session (74/74 incl. ops/schema).
- **The fence's legs live in ONE place and match R-13nb-1 exactly** (`mcpNoteFacts`/`mcpBookFacts`): own
  `profile='journal'`, live member (status 'member' — arrivals never) of a live reading with profile
  journal/daily; an archived book still fences; a deleted one does not — each pinned. The Private leg is an
  honest `"0"` fragment until the architect's v1_25 (R-13nb-4's slotting honored: ZERO v1_25 content in this
  diff). The version classifier (`archived_at = created_at`) matches the canon spelling used in Trash/Timeline.
- **No existence oracle for plain targets, no content in refusals:** versions, pools, tombstones and
  strangers have no facts and answer exactly as an unshared note (pinned); the refused-note pins assert no
  leaked words; titles reach only the local activity log.
- **Local-only discipline whole:** v1_24 carries no `sync_version`, no triggers, no outbox capture (pinned);
  `SyncSchemaTests`' completeness walk extended with the third family + disjointness pins both ways; ZERO
  lines under `Sources/VariorumCore/Sync/` in the whole diff (AF-4 honored); marker 12 untouched; the
  plaintext export strips rows child-first and lands empty + OFF, source untouched (pinned, and the
  strip-not-drop reasoning — no second recreation road — is sound).
- **Per-call consult inside the call's own transaction:** decide → consume-once → read → log, one
  transaction; revocation/denial land on the very next call; while-connected ends at the client's LAST
  connection and every server start sweeps — each pinned end-to-end over a real socket driven by the SDK's
  own `Client` (19/19 in this session).
- **The shim is what A-2 ruled:** `VariorumMCPSocket` has zero dependencies (Package.swift), the shim target
  links only it; bundle-derived path (Debug shim → dev container by construction); ENOENT/ECONNREFUSED vs
  EPERM/EACCES told apart; the AF-1-as-amended length guard refuses at both ends, never truncates (pinned);
  the first-request refusal echoes the JSON-RPC id; the pump is verbatim (pinned against a real server).
  pbxproj: hardened runtime, NO app-sandbox key, CodeSignOnCopy into Executables (`dstSubfolderSpec = 6`),
  `SKIP_INSTALL`, distinct debug/release shim bundle ids.
- **The transport cannot be ballooned:** blocking reads on a dedicated thread, newline framing, the 16 MiB
  line cap ends the connection (pinned), `SO_NOSIGPIPE` at both accept and connect, plus the shim's own
  `signal(SIGPIPE, SIG_IGN)`.
- **Host lifecycle:** start sweeps while-connected grants; stop closes the listener via the wake pipe
  (bounded 2 s), unlinks the socket, hangs up every session; a second listener refuses `alreadyServed`; the
  socket is 0600 and gone after stop (pinned). `MCPDoor`'s start runs detached off-main with the in-flight
  flag, and a stop-during-start is covered by the `host === fresh` identity check (traced: the stranded
  start's host is stopped on landing). Attach is idempotent per session, runs on EVERY ready before the
  services guard, detaches at lock and quit; a test process never serves; detach never flips her toggle —
  all pinned in `MCPPaneTests`.
- **`sharedPage`'s k-way merge pages exactly** (the implementer's look-first spot): each source is
  keyset-paged past the SAME cursor with the same limit; if any source fills its limit the merged distinct
  set ≥ limit, and if none does every source is exhausted — so `prefix(limit)` is the true global page and
  `count == limit` correctly predicts a next page. Dedup only removes cross-source twins inside the same key
  range. No duplicate, no skip.
- **Defense in depth on every listing:** page queries are a pre-filter only; every row still passes `decide`
  per note before it is emitted (so even a wrong page composition cannot leak — load-bearing for F5's
  severity).
- **P1 on the server:** every tool ∝ its request's scope — keyset pages, candidates ∝ the grants' own reach,
  search ∝ matches; nothing walks the corpus.
- **Registry and faces:** seven `.surface` capabilities declared once, `MCPPane` their only renderer, the
  registry walk extended with the justified-edit annotation; the pane is the eleventh (Diagnostics' pin
  edited consequentially, annotated); rows searchable; R-13n-5's register held inside the pane; R-13nb-5's
  command is `-s user`, shell-quoted (awkward-character pin), shown whole and selectable; `variorum-dev`
  keeps a dev setup out of the real registration. Sentence case throughout the new copy.
- **The SDK pin:** `exact: "0.12.1"`; Package.resolved diffs are pure additions (no existing pin moved);
  Mac-app-only linkage confirmed in pbxproj (only the Variorum target lists the product; the phone target
  untouched); acknowledgements carry the five notices Mac-only with the phone's shared list unchanged
  (pinned).
- **R-13n-1 honored:** nothing assumes the client is external — identity is `clientInfo.name` through the
  same door any embedded client would use.
- **Mobile:** nothing mobile-visible in this diff (iOS target untouched; shared notices list unchanged).
- **The live round's record** (plan file) matches what the code does at every step I could check statically:
  the shim's -32000 refusal text, pending-sees-no-tools, the grant sheet's withheld "while connected", the
  one-answer refusal, quit unlinking the socket.

**Verdict: 0 BLOCKER · 0 MAJOR · 4 MINOR · 3 NIT.** The security boundary itself — the one thing this unit
exists to get right — is solid, pinned from the pure rule through the operations to a real socket session.
The findings are edge-honesty and hardening around it.
