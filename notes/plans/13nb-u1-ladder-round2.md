# 13n-b U1 — ladder round 2 (cold re-review of the round-1 fixes, fable-reviewer, 2026-10-09)

**Scope:** the round-1 fixes — `adf09a48..HEAD`: the five fixes (`995d9cc7` F1, `00a6c943` F2,
`acadef10` F5, `db7d3571` F7, `cb6b8c54` F3), the dispositions (`dca3319b`) and the sanity pass
(`c2bac65e`). Fresh reviewer (round 1 was a different session); the wider branch diff read for
context; anchor `notes/plans/phase-13n-b-mcp-door.md` (read whole) + the round-1 record.
The round-2 diff touches ONLY `Sources/VariorumMCP*`, `Tests/VariorumMCPTests` and the record
file — zero `Sync/`, zero schema, zero Mac-app files, zero editor seam (confirmed by
`git diff --stat adf09a48..HEAD`), so no stage claim and no Mac-suite run was owed this round.

**Verified myself, in this session (not taken from the record):**
- Every changed source file read WHOLE at HEAD (`MCPReadTools`, `MCPGrantAuthority`,
  `MCPToolCatalog`, `MCPServerHost`, `MCPShim`) plus `MCPGrantRule`, `MCPSession`,
  `MCPSocketTransport` and the four new pins; the five fix diffs read commit by commit.
- **All four red-on-old pins re-verified by my own revert run:** `git checkout adf09a48 --
  Sources/VariorumMCP/` with HEAD tests → the four pins fail with 8 issues exactly where the
  findings said (F5 2, F2 1, F1 3, F7 2); tree restored clean, re-run green.
- `swift build` green; `VariorumMCPTests` **23/3**; the grant/schema suites **74/7**;
  `MCPServerTests` alone 14 (10 + the four pins); the WHOLE headless package: core
  **2,511/287** + workbook **40/6**, only the long-standing gated skips — the record's counts
  hold.
- F3's load-bearing mechanism traced to the floor: `AppDatabase.read` →
  `currentWriter().read` → GRDB `DatabasePool.read` on an on-disk store = the READER POOL
  (AppDatabase.swift:180-186, :89), so the split genuinely frees the writer (P2 restored on
  the door's read path); in-memory test stores serialize, which affects nothing pinned.
- P-13nb-U1-13's added fact spot-checked: `MarkdownLink.openableSchemes = ["http","https"]`
  (`App/Variorum/Shared/MarkdownLink.swift:37`) — note text really cannot carry a reachable
  note-id link.

## The five fixes — each re-traced, all CONFIRMED SOUND

- **F1 (`995d9cc7`) — CONFIRMED.** `Standing.searchGrants` (live, non-once) is genuinely the
  ONE standing-reach set: the declaration's `needsStandingReach` lists by it
  (MCPToolCatalog.swift:36), `reachedScopes` builds wing/book/note scopes from it
  (MCPReadTools.swift:396), and BOTH explicit roads (`note_id`, `book_id`) refuse non-standing
  allows through `isStandingAllow` (MCPReadTools.swift:350/361), which treats the open book
  (nil grantID) as standing — correct. The round-1 look-first sweep re-done: every remaining
  `liveGrants` reader is a LISTING (list_books' candidates, `sharedPage`, the non-search
  tools' `isListed`), where once grants belong per P-13nb-U1-2. The once-covered refusal
  deliberately answers the one-answer `notShared` words (no fence words leak; the pin asserts
  the prefix). Red-on-old re-verified myself.
- **F2 (`00a6c943`) — CONFIRMED.** The count reads the same member rows as `bookPage` (live
  members, `kind='post'`), batches the same `mcpNoteFacts`, and counts exactly what the
  per-row `decide` lets `list_notes(book_id:)` emit — archived members counted (listed),
  fenced/version/missing-facts members not, under the open book and every grant shape alike
  (traced per decision branch). Never a parallel SQL fence. Cost per call ∝ the listed books'
  membership — which IS the listing's scope, so P1 holds; the open-book worst case is the
  open book's own "everything readable" scope, and F3 keeps it off the writer. Pagination of
  `list_books` stays the named road if a library ever makes it slow. Red-on-old re-verified.
- **F3 (`cb6b8c54`) — CONFIRMED (architectural, no pin owed — correctly).** The three
  non-consuming tools assemble the WHOLE answer (standing, facts, decide, page, per-note
  filter) in ONE `database.read` snapshot — internally consistent — and `logAfter` writes the
  activity line in a short write after, preserving the old line's exact content (same
  kind/id/nil title/allowed on every path, refusals included; diffed line by line).
  `read_note`/`export_note` keep the one write transaction — the once stamp's atomicity is
  the boundary, and their cost is bounded by the one note. `logAfter` on a store locked
  between snapshot and log throws into `call`'s catch-all (answer discarded — the safe
  direction; the server is detached at lock anyway). The only consumer that asserts an
  activity line (`MCPServerTests.swift:156`) follows `read_note`, which still logs
  in-transaction; the pane's activity face is U3's, unbuilt. BONUS found while diffing: the
  split also fixed a pre-existing log mislabel — `search` called with BOTH `note_id` and
  `book_id` decides note-scoped but the old success log said "book"; the new log matches the
  decision road.
- **F5 (`acadef10`) — CONFIRMED.** `PageCursor` encodes `(shape, key, id)`; the shape check
  runs BEFORE the snapshot and refuses with the one `staleCursorMessage` constant; keys can
  never contain the delimiter (base-62 positions, ISO stamps, UUID ids); both recency roads
  (wing, shared) share the `r` shape correctly. Red-on-old re-verified (the old two-part
  cursor decoded happily cross-order).
- **F7 (`db7d3571`) — CONFIRMED.** `sessionCap = 16`; only the accept thread ever inserts, so
  the two lock sections cannot overshoot; the refused fd is closed EXACTLY ONCE, by the
  helper (the accept loop never closes it, `stop()` never sees it — it is never in
  `sessions`); `SO_NOSIGPIPE` is set at accept before `serve`, so the helper's write to a
  vanished client cannot signal; the refusal echoes the request id via
  `MCPShim.refusalResponse` (readFirstLine's `public` is the one surface change in the socket
  module); a freed slot serves again (pinned). The refusal copy is sentence case.
  Red-on-old re-verified.

## Round-1 dispositions — judged

- **F4 → PROVISIONAL P-13nb-U1-13: STANDS.** The record's two legs both check out against the
  code (listings and search never emit fenced ids — `listNotes`' per-row filter,
  `reachedScopes`/`passes`, the e2e pins; `MarkdownLink` http/https only, verified above).
- **F6 (listen TOCTOU) record-only: STANDS.** Both racers are her own dev builds over the
  same grants store; the non-racing case is pinned; the flock road stays named.

## The sanity pass's two observations — judged (mine to close)

- **O1 (`passes` answers a book/chapter NAME hit with `decide(book).isAllowed`, not
  `isStandingAllow`) — RECORD-ONLY, my own trace.** Book-kind passages can only arise in
  `.library` (wing) and `.book` scopes: a `.note` scope's SQL appends `c.id = ?`
  (SearchComposer.swift:322/655), which a reading doc can never match. And the server builds
  wing/book scopes exclusively from standing reach (`searchGrants` wings and books, the open
  book, or the explicit roads' `isStandingAllow` guard) — so every input that reaches
  `passes`' book branch already sits under standing reach, and `decide`'s `best` prefers
  standing, so even a coexisting once grant changes nothing. No leak exists and no pin could
  go red. The uniformity one-liner (route book hits through `isStandingAllow` too) stays the
  named hardening if U2/U3 ever add a scope shape; fixing it now would be a green-both-sides
  fix the ladder's own rule forbids.
- **O2 (refusal helpers have no ceiling) — RECORD-ONLY.** The realistic bug F7 named — a
  client in a reconnect loop — is closed: such a client sends its `initialize` at once and
  its helper lives milliseconds. What remains needs a deliberately SILENT flood (one helper ≤
  ~2 s each) or a 1-byte-per-<2 s drip (one held thread per dripping connection, since
  `SO_RCVTIMEO` bounds each read, not the line) — a deliberate local hostile, the class A-4's
  recorded boundary already concedes has better options. Road if it ever bites: cap
  concurrent helpers (say 4, bare-close past it) or bound the helper by a wall-clock
  deadline. No honest red-on-old pin exists short of a flaky flood test.

## New findings (round 2) — neither BLOCKER nor MAJOR; recorded and disposed

### R2-1 — [NIT, latent — a line for U2's brief] · `Sources/VariorumMCP/MCPReadTools.swift:351` · the synthesized once-covered search refusal hardcodes `offersAlways: true`, fence unread

**Evidence (traced):** `search(note_id:)` on a note covered ONLY by a once grant synthesizes
`.ask(.notShared, offersAlways: true)`. For a FENCED note under a once grant this flag is
wrong by R-13n-4's letter (a fenced target's ask never offers "always") — but in U1 NOTHING
reads `offersAlways` (refusal copy renders words only; the just-in-time ask is U2's), so no
wrong output exists and no pin could go red. The hazard is seeded for U2: an ask sheet that
trusts the decision's flag would offer "always" on a journal. **Disposition: RECORD for U2's
brief** — when the ask lands, the synthesized flag should read the fence
(`offersAlways: facts?.fence == nil`); the book road needs nothing (a fenced book never
produces an allowed decision). Fixing now would be green-both-sides.

### R2-2 — [NIT] · `Sources/VariorumMCP/MCPReadTools.swift:336-337` · `search` accepts `note_id` and `book_id` together, silently note-scoped; `list_notes` refuses the pair

**Evidence (traced):** `list_notes` throws "Pass book_id or wing_id, not both."; `search`'s
if-chain lets `note_id` win with no refusal. Pre-existing (round 1 did not flag it; F3's edit
made the LOG honest about which road won). Harmless — the answer is honest and in-scope either
way. **Disposition: RECORD** — the cheap symmetry (the same not-both refusal) can ride any
later touch of the file; not worth a commit alone.

## Clean bill (load-bearing things specifically checked this round and found solid)

- The four pins are real red-on-old pins — re-verified by my own revert run, not taken on
  faith; all suites green at HEAD; the record's counts (23/3, 74/7, core 2,511/287, 40/6)
  reproduced in this session.
- The one-rule promise F1 made holds everywhere: no serving road reads `liveGrants` where
  standing reach is meant; every remaining `liveGrants` reader is a listing where once
  grants belong (P-13nb-U1-2).
- F2's count equals the listing's extent under every standing shape (book grant, wing grant,
  open book, note-only, once-only) and for every member class (archived counted, fenced
  never, versions/pools/tombstones have no facts so neither listed nor counted).
- F3 preserved the activity line byte-for-byte on every path, kept the once stamp atomic
  with its read, and demonstrably moved the three heavy tools onto the reader pool
  (`DatabasePool.read` traced); argument failures stay unlogged as before.
- F7's refused-fd lifecycle: closed once, by the helper; no path double-closes; the cap
  cannot be overshot (single inserter); `connectedClientNames` drains as sessions end.
- MCP `search` can never reach savepoints or archived rows: `SearchQueryParser.parse` builds
  a query with `includesSavepoints: false` and living visibility — the facets are UI-set
  booleans, never parsed from text (SearchQuery.swift:32-56); so R-13o-6's posture and
  R-13n-8's commits-don't-ride-the-text-form both hold on the wire.
- The round-2 diff keeps the unit's fences whole: zero `Sync/` lines, zero schema, marker
  untouched, zero Mac-app files, zero editor seam; commits carry no attribution trailers and
  each was pushed.
- The fenced-note grammar under the fixes is exactly the ruled one: a while-connected
  per-ask note grant reaches (and may search) the one journal it names; once grants never
  feed search; "always" on a fenced note refuses at the grant op.

**VERDICT: 0 BLOCKER · 0 MAJOR · 0 MINOR · 2 NIT (both record-only). No new BLOCKER/MAJOR —
no round 3 is earned; the ladder closes at round 2 with the fixes CONFIRMED.** The round-1
findings are all honestly dispositioned: five fixed with verified pins, two recorded with
their reasons standing. The boundary the unit exists for is untouched by the fix pass and
remains solid.
