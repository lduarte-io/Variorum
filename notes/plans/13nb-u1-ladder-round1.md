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

*(to be filled by the orchestrator's cross-model pass — findings go to the implementer verbatim; its
agree/dispute returns to the reviewer for the final call)*

| # | Severity | Response | Disposition |
|---|---|---|---|
| F1 | MINOR | AGREE — fix on the catalog side | — |
| F2 | MINOR | AGREE — count what the client can list | — |
| F3 | MINOR (arch) | AGREE — prefer taking the split for the three non-consuming tools | — |
| F4 | NIT | AGREE with the lean — keep as built, record PROVISIONAL | — |
| F5 | NIT | AGREE — tag the cursor shape | — |
| F6 | NIT | AGREE — record-only | — |
| F7 | MINOR | AGREE — cap ~16; suggest an honest refusal past it | — |

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
