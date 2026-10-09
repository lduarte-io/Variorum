# Phase 13n-b — the MCP door (Level 2: the server, the grants, the pane)

**STATUS: OPEN — kicked off 2026-10-09.** Ticket **VX-124** (child of VX-25) ·
Project "13n — The MCP door" · Branch `vx-124-13n-b` · Worktree
`~/dev/variorum-vx-124` (the Pro). Shape: `/architect-phase`; three
acceptance units (U1 spine · U2 suggest+write-new · U3 edit+polish), one
implementer session each, one ladder per unit. Cast: Fable orchestrates and
cold-reviews (`fable-reviewer` — the grant boundary is security surface;
`opus-reviewer` only if a round's diff turns out pure chrome, which none of
the three units is expected to be), `opus-implementer` builds, both xhigh.
The binding rulings: `notes/plans/phase-13n-sitting-record-2026-10-09.md`
(R-13n-1…11) + the approved mockups
`notes/plans/13n-sitting-mockups/mcp-door-mockups.html` + the carried canon
*[removed for publication]*

## KICKOFF MESSAGE (for a fresh orchestrator session)

You are kicking off 13n-b, the MCP door's second and larger effort — the
one at whose end a Claude Code session genuinely connects to her library
under a grant she set. Every design question is ALREADY RULED: the binding
record is `notes/plans/phase-13n-sitting-record-2026-10-09.md` (R-13n-1…11)
with the approved mockups `notes/plans/13n-sitting-mockups/mcp-door-mockups.html`
and the standing canon they carry forward (`notes/plans/phase-13n-mcp-door-note.md`
*[removed for publication]*
guardrails). 13n-a (Level 0) is CLOSED and merged — the format and import
ops it built (`Domain/VariorumDocument`, `importDocument`/`importBook`,
`Queries.variorumDocumentText`) are this phase's substrate: `read_note`
speaks the format, `import_document` takes it as payload.

Preflight per CLAUDE.md in full. NO `Sync/` and no custody code is expected
in this diff (grants are a LOCAL-ONLY table; the server sits inside the
unlocked app) — but the GRANT BOUNDARY is security surface, so the cold
reviewer is **fable-reviewer** for U1 at minimum (the orchestrator may use
opus-reviewer for pure-chrome units). Mint the effort's ticket at kickoff
("13n-b — the MCP door", child of VX-25), branch/worktree per the standing
rules, declare surfaces against the in-flight table. `/architect-phase`
shape; THREE acceptance units, one implementer session each, laddered as
ever.

## What this phase builds (the ruled design, restated for building)

**The transport (R-13n-3):** a `variorum-mcp` helper binary in the app
bundle; MCP clients launch it over STDIO; it forwards JSON-RPC to the
running app over a UNIX SOCKET in the app's container (no TCP, no network
service; the socket dies with the app; "Variorum must be open" is the
honest refusal when it isn't). The app is the ONE process touching the
store. Setup is app-initiated: Settings ▸ MCP's "Set up Claude Code" writes
the client config itself (`claude mcp add variorum -- <bundle path>`); a
copyable command is the fallback; Claude Desktop registers the same binary
in its config file. The dependency is RULED IN (R-13n-2): the official MCP
Swift SDK, pinned exact version, license notices in acknowledgements.

**The grant grammar (R-13n-4) — the product:** four cumulative rungs —
**read** (read + search in scope) · **suggest** (new takes at the fan's
end, labeled, never chosen, never locked; comments; save-a-lens — PROVABLY
cannot modify an existing take, test-pinned) · **write new** (+ create
notes, apply tags, build books; `import_document` as the bulk door) ·
**edit** (+ `edit_take` under insurance, structural ops, tombstone-only
delete). Scopes: this note · a book · this wing. Durations: once · while
connected · always. The ONE open-book switch; journals NEVER in a standing
grant and never offered "always" (§9). Grants live in a LOCAL-ONLY table
(never synced — zero lockstep, marker untouched) with faces in Settings ▸
MCP, the book settings sheet, the note ⋯ menu, and a "shared with AI" chip
on granted rows (P-13n-3's wording, hers to re-voice).

**The pane (R-13n-5 + R-13n-10):** Settings ▸ MCP speaks DIRECT AND
TECHNICAL (her register ruling — "it's only for technical people anyway");
a pending client is a "Connection request — Approve… / Deny", never the
Arrivals door idiom; the app-wide faces an AI act produces (receipts,
chips, commit names, take labels) keep the app's voice (P-13n-1). The
clients / shared-with / activity lists MUST stay legible at length — each
section caps its rows with an "all N ›" road (her clutter constraint).
Mockup sections 1–4 are the approved reference, as amended by the rulings.

**The paper trail (R-13n-6/7):** every MCP write is an ordinary operation
registering structural undo per act; multi-block tools register ONE
compound entry. `edit_take` takes `expectedText` (stale reads refuse as
`bufferChangedSinceGesture`) and is bracketed by named commits carrying THE
CLIENT'S NAME ("before claude code's edit" / "after …") — the EIGHTH quiet
auto-commit occasion, insurance-class, never governed by
`savepoint_cadence`. AI takes are labeled with the client (P-13n-3).

**The tool vocabulary (mockup §9, the lean set):** read — `list_books`,
`list_notes`, `read_note` (the Level 0 format), `search` (the 13o engine,
scope-filtered), `export_note`. suggest — `add_take`, `add_comment`,
`save_lens`. write new — `create_note`, `import_document`, `apply_tag`,
`create_book`, `add_note_to_book`. edit — `edit_take`, `divide_block`,
`merge_blocks`, `move_block`, `delete_block`. Tools are thin projections of
the operations layer (P-1's registry thinking applied to the wire); every
refusal speaks to the client exactly as it speaks to her; scope checks run
per call. Nothing can choose a take, hard-delete, or touch keys.

## The units

- **U1 — the spine (fable-reviewer):** the SDK dependency; the socket
  server inside the app; the `variorum-mcp` stdio shim; the grants table +
  the pure grant-check Domain rule; the READ rung end to end (Claude Code
  connects, lists, reads, searches under a grant); the Settings ▸ MCP pane's
  resting shape (toggle, connection requests, clients list, Set up Claude
  Code). Acceptance: a REAL Claude Code session on the dev store reads a
  granted book and is refused past it (the refusal pinned); the verification
  bar's read half (reads never exceed the grant, pinned per tool).
- **U2 — suggest + write new:** the grant sheet (where · how much · how
  long) and the just-in-time ask; `add_take`/`add_comment`/`save_lens` +
  the suggest-rung PROOF (test-pinned: cannot modify an existing take);
  `create_note`/`import_document`/`apply_tag`/`create_book`/
  `add_note_to_book`; receipts + the shared chip; undo per act. Acceptance:
  her fact-check shape live — an agent reads a note, lands takes beside
  every block, saves a lens; one ⌥⌘Z walk.
- **U3 — edit + polish:** `edit_take` with insurance commits + expectedText;
  the structural tools; the open-book switch; journals' per-ask fence; the
  activity list; the list-scalability shapes (R-13n-10); the walk (both
  voices) + her Percy-grade live round over the connection. Acceptance: the
  whole W-series equivalent for the door + the verification bar complete.

## Standing constraints

**⚠️ AMENDED 2026-10-09 by R-13nb-4 (hers, the kickoff-day sitting): the
PRIVATE MARK adds ONE small §12 lockstep event (marker 12→13, two
additive nullable columns, PLAIN) — see the design addendum. The
"zero `Sync/` / zero schema SYNC impact" line below is superseded to that
exact extent (the Sync/ lines are the orchestrator's, AF-4); everything
else holds, the grants family stays local-only.**

Zero `Sync/`; zero schema SYNC impact (the grants table is local-only —
registered like the 13o derived family, subtracted from the completeness
walk, kept out of exports); Claude Code is the must-work first client;
nothing may assume the client is external (the future chat is another
client, R-13n-1); the capability registry declares any new user-facing
doors; P1 binds the server (tool cost ∝ the request's scope, never the
corpus). MOBILE: nothing mobile-visible expected (the server is Mac-hosted;
synced rows arrive on the phone as ordinary rows) — say the line at
closeout.

## Open taste items riding into this phase (from QUESTIONS #207/#208)

P-13n-1 (the register boundary), P-13n-3 (chip + label wording), WA-7
(should Welcome refuse context mints generally — surfaced by 13n-a's drop),
and the Index receipt-footer option set (WA-1's record). None gates U1.

---

## KICKOFF RECORD (orchestrator, 2026-10-09)

Preflight complete (CLAUDE.md's full list + SyncSpec in full — the grants
table is a schema change, local-only class, zero lockstep; TEXTKIT2_NOTES
not required: no editor-seam work in any unit). The in-flight table was
EMPTY at kickoff — no surface overlap to declare against; the row landed
atomically on main (`d8bec78d`). Ticket **VX-124** minted In Progress,
child of VX-25, project "13n — The MCP door". Worktree
`~/dev/variorum-vx-124` cut from `origin/main` at `ddf6f824`, branch
pushed. Stage: headless core work needs no claim; the U1 live round (a
real Claude Code session against the dev-store Debug app) and every
`xcodebuild test` run claim `Tools/stage` as ever.

## The binding principles (the 13b constitution, copied per the architect-phase skill)

- **P-1 — One capability registry.** Every user-facing act is declared
  exactly once: verb, scope (block/take/post/book), per-mode availability
  rule, its doors (menu / context / bar / shortcut / palette), and its
  refusal copy. Surfaces render their doors FROM the registry; gating is
  data, never per-view if-statements. A registry-walk test asserts every
  declared door exists and every rendered door is declared. This kills the
  D3/D4 class structurally — the capability matrix stays green by
  construction instead of by audit.
- **P-2 — Fire-and-DO (R115).** A rendered door either performs the act —
  including any mode-switch choreography, done visibly for the user — or
  delivers the operations layer's real refusal. A door that can never act in
  its context isn't rendered. Lecture-and-redirect is retired.
- **P-3 — One text surface, one liveness authority.** ONE TK2 surface
  component (live + read modes; one measurement brain — the width-gated
  remeasure; the shared canary) that every pane composes; the live editor
  core's identity machinery (`BlockRangeIndex`, crystallization) becomes its
  live mode, not a sibling implementation. "What text does this pane show,
  and is it live" is answered by ONE pure, unit-tested authority
  (`PaneTextAuthority`); views never re-derive it. Its invariants stated as
  code: exactly one live pane; the live pane is buffer-authoritative; read
  panes are projection-authoritative once caught up.
- **P-4 — Broadcasts carry signals, never decisions.** NotificationCenter
  may announce that something happened (mode changed, post opened); no
  listener derives business state or availability from a broadcast, and no
  flow's correctness depends on broadcast ordering. Cross-feature flows
  route through composition. (Stage 0's survey enumerates today's
  notification bus; Stage 1 disciplines it.)
- **P-5 — The friction doctrine (R116).** Repeated pushback against a rule
  marks an under-architected feature. The response is never another patch:
  write the feature's DESIGN MEMO — intended behavior whole, edge cases
  enumerated on paper, refusal wordings, undo story — get the author's
  rulings on the product-flavored edges, then build to the memo. Happy path
  ships first, but the edges are *decided at design time*, not discovered by
  the author. First two memos owed: **merge** and **the W ceremony**.
- **P-6 — The tutorial is the executable spec (R113).** The guided tutorial
  flow is the contract for every happy path. It stays green — automated
  where the harness allows, screenshot-walked otherwise — and any change
  that breaks a tutorial step is a regression by definition.
- **P-7 — Find bugs before she does.** Every layer keeps a proactive
  harness: the ops-layer soaks (exist), the board/view-model invariant soak
  (Stage 1), the registry walk (P-1), the per-batch scripted screenshot
  walkthrough. Red-on-old stays absolute: no bug-class fix without a pin
  that fails on the pre-fix code.
- **P-8 — Standing law, consolidated.** P1–P3 performance invariants bind
  the rebuilt layer exactly as they bind the substrate (invalidation ∝
  realized rows; one live editor; virtualized long views). Overlays, never
  rendering attributes. Chrome `fixedSize` texts always carry a `lineLimit`
  (the b6dae25 class). `Theme/VoiceControls.swift` is THE chrome vocabulary.
  Complexity lives in the store; restraint lives in the UI.
- **P-9 — No god objects in the frontend either.** A view model mixing
  board layout, text authority, and gesture routing splits by concern
  (`TakesViewModel` at 890 lines is the standing counterexample). Same
  hygiene rule as the substrate, applied where it was being waived.

**Constitution applications specific to 13n-b:** the MCP tools are P-1's
registry thinking applied to the wire — each tool declared once (verb,
rung, scope rule, refusal copy), scope-gated by DATA (the one pure grant
rule), never per-tool if-statements; a tool the grant excludes is not
listed to the client (P-2 on the wire: no door that can never act). The
new user-facing doors (the Settings ▸ MCP pane's acts, the note ⋯ menu's
grant rows, the book-sheet row) are registry-declared and walk-covered.
The server renders nothing and owns no text surface (P-3 untouched; AI
writes land as rows and reach open panes through the ordinary observation
roads). No tool result or grant decision rides a broadcast (P-4). P1 binds
the server: every tool's cost ∝ the request's scope, never the corpus.
The MCP pane's lists scale by R-13n-10's shapes, not growing piles (P-8's
restraint). The server module splits by concern — transport · session ·
grant authority · tool projections — never one god server object (P-9).

## SITTING RECORD (13n-b, running — her rulings during the phase, verbatim-faithful)

- **R-13nb-1 (2026-10-09, same-day as kickoff) — P-13nb-1 RATIFIED.** Her
  words: *"I agree - profile journal OR member of alive journal/daily book
  sounds good."* The journal fence's predicate is no longer provisional:
  a note is a journal iff its container `profile='journal'` OR it is a
  live member of a live reading with profile `'journal'` or `'daily'`.
  (The QUESTIONS-at-merge entry for P-13nb-1 becomes a record of this
  ratification, not an open item.)
- **R-13nb-2 (2026-10-09, same message) — the PRIVATE book question,
  raised by her, answers pending the question batch.** Her words: *"I
  almost wonder - should we add a designation or boook setting like
  'Private', so that people can have books that are not shared with AI
  without them having to be journal type? that might be a small sync
  event but the stage is clear for that."* Answered whole at R-13nb-4.
- **R-13nb-3 (2026-10-09, her next message) — the reviewer cast
  CONFIRMED.** Her words: *"Fable reviewer is good"* — `fable-reviewer`
  on every unit's ladder stands as the default this plan's banner states.
- **R-13nb-4 (2026-10-09, the question batches) — THE PRIVATE MARK,
  RULED.** R-13nb-2's question answered whole: **(i)** the mark is a
  SYNCED column — her lean confirmed ("that might be a small sync event
  but the stage is clear for that"); **(ii)** the fence is JOURNAL-CLASS
  (never in a standing grant, never under open-book, excluded from
  scope listings; per-ask only, the ask never offers "always");
  **(iii)** scope is **BOTH, ONE EVENT** — a per-NOTE mark (the
  primitive; her intuition: "it almost makes more sense intuitively to
  me by note") AND a per-BOOK mark (bulk + future arrivals), two nullable
  columns riding one marker-12→13 lockstep event; **(iv)** the word is
  **"Private"** (the row's sub-sentence does the semantic work; 13s-a
  sweeps the copy). Her answer ratified the stated edges with it:
  **privacy wins ties** (membership in ANY live private book fences a
  note everywhere, the journals' precedent); **Private ⊥ Owned** (never
  coupled — ownership is structure, privacy is disclosure); **gatherings
  refuse the mark** (fence-by-rule would be unpredictable; their
  assemblies can never leak a fenced note anyway — the fence is per-note,
  per-call); **fencing takes effect immediately on connected clients**
  (the per-call check). Design addendum below.
- **R-13nb-5 (2026-10-09, same batch) — the SETUP PRESS is "Copy setup
  command".** The probes showed the sandbox can neither execute the
  `claude` CLI nor honestly write `~/.claude.json` (whole-file rewrites
  race a second writer; the file is Claude Code's private state; the
  exact-path entitlement road declined). The press copies
  `claude mcp add -s user variorum -- "<shim path>"` with a receipt, the
  command shown verbatim and selectable beneath; the verb renamed
  honestly per P-2 (technical register, P-13n-1). This supersedes
  R-13n-3's "writes the client config itself" LETTER on probed technical
  grounds — its fallback becomes the primary. The `-s user` correction is
  load-bearing (the CLI defaults to local scope — folder-only).
- **R-13nb-6 (2026-10-09, same batch) — ADOPTION LANDS OFF, GRANTS
  KEPT.** A handed-off/restored library (13x's roads) arrives with the
  MCP server toggle OFF whatever it was; grant rows survive as data and
  resume on the deliberate re-enable — the restore-hold shape applied to
  the door. Plaintext-export rebuilds land empty + OFF by construction
  (the implementer's A-5 exclusion + adoption recreation, approved).

## THE PRIVATE MARK (R-13nb-4) — design addendum (architect, 2026-10-09)

- **Columns:** `container.ai_private_at TEXT` (nullable stamp) +
  `reading.ai_private_at TEXT` (nullable stamp) — the `archived_at`
  class: additive, nullable, constraint-free on the mirror, **PLAIN
  under E2EE** (a bare timestamp; disclosure is structure-only — that
  something is marked, never which or what). NULL = not private.
- **The fence leg (extends R-13nb-1's predicate):** a note is FENCED iff
  it is a journal (R-13nb-1) OR its own `ai_private_at` is set OR it is
  a live member of a live reading whose `ai_private_at` is set. One
  derivation site in Queries; the pure rule consumes the fact. Gatherings
  refuse the mark (`wrongReadingKind`, the Owned/extents/lock pattern);
  a pool is not markable in v1 (restraint; revisit on want).
- **Faces:** the book settings sheet's row and the note ⋯ menu's row,
  each "Private — never shared with AI" (sentence case; app voice —
  P-13n-1's boundary; 13s-a sweeps); the per-ask sheet names the reason
  (the journal sheet's twin, wording sweepable). Registry-declared.
- **The lockstep event:** marker 12→13, ONE additive event, artifact
  `Server/supabase/16_phase13nb_private.sql` authored in-branch; the
  MIRROR DEPLOY runs only at her closeout window (the §12 choreography;
  both installs refresh in the window — the 13i-e shape). No new §7
  repair (plain CAS metadata; NULL reads not-private, pinned).
- **Slotting:** the schema commit (migration `v1_25_private_mark` + the
  Sync/ column classifications + the mirror artifact) is the ARCHITECT'S
  OWN COMMIT at the U1/U2 seam — any line inside
  `Sources/VariorumCore/Sync/` is Fable work (CLAUDE.md), and schema
  precedes the code that uses it. U1 shapes the fence-fact derivation for
  the third leg now (the fact reads false until the columns exist); U2
  builds the faces + wires the leg.
- **Amendment note:** this phase's "zero schema SYNC impact" standing
  constraint is AMENDED by this ruling (hers, 2026-10-09) — one small
  lockstep event, stage clear (the in-flight table carries only this
  effort). Everything else in Standing constraints holds.

## ARCHITECT RULINGS ON THE U1 PROBE FORKS (Fable, 2026-10-09 — on the implementer's probe facts, recorded before the affected halves build)

- **AF-1 — the socket home: APPROVED AS PROPOSED.** The container socket
  keeps R-13n-3's letter and the probes prove it clean (a launchd-vantage
  process with no terminal grants connects 5/5; App-Data TCC gates file
  opens, not socket connects; the A-10 fallback is the road that FAILS —
  a sandboxed listener binds only inside its own container).
  `<container>/Data/mcp.sock`; `bindat`/`connectat` against a dir fd so
  `sun_path`'s 104-byte limit can't bite; the shim distinguishes
  ENOENT/ECONNREFUSED ("Variorum must be open") from EPERM/EACCES (its
  own honest macOS-blocked line); NO fallback location is built. A
  re-verify-probe-(a) line joins the per-macOS-point-release ritual
  (recorded at closeout beside the TEXTKIT2 re-verify).
- **AF-2 — the setup press:** R-13nb-5 above (hers). Build as ruled.
- **AF-3 — adoption carry-over:** R-13nb-6 above (hers). The 13x
  adoption road gains the one toggle-OFF write; the export-rebuild
  recreation as the implementer proposed.
- **AF-4 — the Sync/ boundary, restated for U1:** any line inside
  `Sources/VariorumCore/Sync/` — the local-only registration if it lives
  there, and v1_25's column classifications — is the ORCHESTRATOR'S to
  land (CLAUDE.md's Fable rider). The implementer messages the exact
  lines needed; nothing in that directory is edited by an Opus session.

## ARCHITECT SEAM RULINGS (Fable, 2026-10-09 kickoff — within the mandate, each traced; product-flavored ones marked PROVISIONAL for her)

- **A-1 — Module placement.** The MCP server is a NEW SPM library target
  **`VariorumMCP`** in the core package (new product beside `VariorumCore`),
  depending on `VariorumCore` + the pinned MCP SDK, linked ONLY by the Mac
  app target — iOS never carries the SDK. The GRANTS substrate (tables,
  operations, queries, the pure grant rule) lives in `VariorumCore` proper
  (`Domain`/`Operations`/`Queries`), headless-testable with zero SDK
  dependency. A new test target `VariorumMCPTests` covers the server; the
  per-tool scope pins live there (headless `swift test`, no stage).
  *(Trace: R-13n-3 — the server sits inside the app; CLAUDE.md's layer
  rules; the verification bar wants headless pins.)*
- **A-2 — The shim is a protocol-blind byte pump.** `variorum-mcp` is a
  tiny standalone executable embedded at `Contents/MacOS/` (the mockup §2
  command's path), with ZERO store access and ZERO VariorumCore dependency:
  it forwards newline-delimited JSON-RPC frames stdio↔socket verbatim. It
  derives the socket path from ITS OWN bundle (read `../Info.plist` →
  bundle id → that app's container), so the Debug shim reaches the dev
  store's app and the Release shim the real one BY CONSTRUCTION (the A4
  fence extended to the door). Socket absent/refused ⇒ the honest refusal
  (R-13n-3's "Variorum must be open") spoken as a proper JSON-RPC error to
  `initialize`, then exit. Signed unsandboxed (hardened runtime, no
  app-sandbox entitlement) so a terminal-launched client can run it.
  *(Trace: R-13n-3; the mockup §10 "the app is the only process that ever
  touches the store".)*
- **A-3 — Framing and sessions.** The app is the listener; socket file
  mode 0600, unlinked on server stop. One connection = one MCP session;
  concurrent connections accepted (Claude Code and Desktop may both be
  configured); each session keyed by the client's self-declared
  `clientInfo.name` from `initialize`. Wire framing over the socket IS the
  MCP stdio framing, so the shim stays protocol-blind forever.
- **A-4 — Client identity is self-declared — the ruled honest boundary,
  stated for the reviewer.** §9's line is canon: *a grant gates the DOOR,
  never a specific model* (or process). A local process claiming an
  approved client's name inherits that name's grants; a NEW name gets
  nothing until approved in the pane. The surface this opens eyes-open:
  with the server ON and a standing grant live, a user-level local process
  can read what that grant allows — where pre-13n the at-rest story
  (Castle) kept a cold store unreadable. Mitigations BY the ruled design:
  OFF by default, approval-gated clients, scoped rungs, journals per-ask
  only, every write an ordinary reviewable operation. Peer-credential
  binding (pid → code signature) was CONSIDERED AND SET ASIDE: every
  client arrives through the same shim, so the socket peer's signature is
  always the shim's own — it authenticates nothing. This line rides the
  closeout's author checklist so the boundary is hers once more in words.
- **A-5 — The grants store.** ONE local-only migration (`v1_24_mcp_grants`
  — LOCAL-ONLY class, never synced, zero lockstep, marker 12 untouched):
  `mcp_client` (self-declared name = identity, first/last seen, approval
  state), `mcp_grant` (client, rung, scope kind + scope id, duration,
  created/revoked stamps), `mcp_activity` (the coarse log: client, act,
  target title, stamp — coarse-not-forensic, pruned to a cap). Registered
  as local-only beside the 13o family so the completeness walk subtracts
  them — but NOT in `SyncSchema.derivedTables` if that name's meaning is
  "rebuildable derived index" (grants are not derived; add the honest
  sibling registration the walk consults — implementer confirms the
  walk's exact mechanism and keeps names truthful). EXCLUDED from the
  plaintext export (unlike search — a grants list in an export file serves
  nobody; the 13o fork's keep-the-index reasoning does not carry).
  *(Trace: R-13n-4's "LOCAL-ONLY table"; the plan's Standing constraints.)*
- **A-6 — The open-book switch lives IN the grants store** (a row the same
  pure rule reads in the same transaction), never in the synced `setting`
  table (a Mac-hosted server's boundary state has no business on the
  phone) and never in UserDefaults (it is a security boundary, not a
  convenience). *(Trace: R-13n-4's one deliberate switch; §9.)*
- **A-7 — The pure grant rule.** `Domain/` gains ONE pure decision
  function (grant rows + request facts → allow / ask / refuse-with-reason)
  consulted PER CALL inside the server against the store's CURRENT facts —
  a note moved out of a granted book since the grant refuses today, like
  any stale pointer. THE JOURNAL FENCE is a pure predicate inside it —
  **PROVISIONAL P-13nb-1 (product-flavored, hers):** a note is a journal
  iff its container `profile='journal'` OR it is a live member of a live
  reading with profile `'journal'` or `'daily'` — the broad reading (more
  asks, never fewer; her words ruled only "journals"). Journals never
  match a standing grant, never ride open-book, and their ask never
  offers "always" (R-13n-4, §9 carried).
- **A-8 — Server lifecycle.** The server runs iff the Settings ▸ MCP
  toggle is ON and a store is open and unlocked; it binds at store-open,
  unbinds (and unlinks) at store close/lock/quit. The toggle itself is
  grants-store state (A-6's reasoning). Pending writes from a dying
  connection finish or refuse whole — ordinary transactions; nothing
  half-lands.
- **A-9 — The grant sheet is BORN at U1 with the read rung only.** U1's
  acceptance needs "a grant she set" through the pane, and a throwaway
  granting road would violate P-2's spirit; so U1 ships the real sheet
  (where · how long) with "how much" fixed at read — the only rung that
  exists — and U2 grows the rung picker + the just-in-time ask onto the
  SAME sheet. *(Trace: U1/U2's split in this plan; the mockups §3.)*
- **A-10 — Three sandbox/TCC PROBES run FIRST in U1, and two of them are
  return-to-architect forks** (the in-batch fork rule — the implementer
  proposes with the probe facts, the architect rules before that half is
  built): **(a)** can a terminal-launched unsandboxed process connect to a
  unix socket inside the sandboxed app's container on macOS 27, cleanly
  and repeatably (App-Container TCC is empirically flaky on this machine —
  the memory record)? If not, the fallback location is a socket dir the
  app reaches by a NARROW home-relative temp exception (the `~/.variorum/`
  convention exists; the Sparkle mach exceptions are the entitlements
  precedent) — a deviation from R-13n-3's "in the app's container" LETTER
  (its substance — local socket, no TCP, dies with the app — is
  untouched), recorded with reasons and bundled for her. **(b)** can the
  sandboxed app bind an AF_UNIX listener at its chosen path at all (probe
  both candidate locations). **(c)** what can "Set up Claude Code"
  actually do under sandbox — writing the client's own config
  (`~/.claude.json`-family) is outside the container; if only an
  entitlement widening reaches it, the press's v1 shape is the fork to
  rule (candidates: the narrow exception; primary-copy-with-receipt).
  No lying door ships either way (P-2).

## Environment traps (the standing invariant core — brief-verbatim for the implementer, carried from 13n-a + this phase's own)

Instance checks use `pgrep -fl 'Variorum.app/Contents/MacOS'` AND
discriminate by PATH; treat real-store instances by STORE, not path —
NEVER quit/kill one; no Release builds or /Applications refreshes while
one lives. Mac tests run from `App/Variorum/` with suite-level
`-only-testing` ONLY, and EVERY `xcodebuild test` run (and any walk,
Debug-app launch, or dev-store reset) requires a HELD `Tools/stage` claim;
headless `swift build`/`swift test` on the core package is free. NEVER add
a custom build configuration (anything not named exactly "Debug" builds
the packages Release and strips the DEBUG oracles). Swift Testing's
"passed" count INCLUDES skipped tests — read the `skipped:` lines before
claiming a gated suite ran. zsh `pipestatus`. Walks: `cliclick` +
`Tools/WalkKit/` on the DEV-STORE Debug build only
(`io.lduarte.Variorum.debug`), under the held stage claim; screenshots in
gitignored dirs. Never `git checkout` over uncommitted work; push after
every commit; never force-push. Backups of any real store are WAL-safe
with UTC names into `Backups/safety-copies/` (the A1 rail).
**This phase's own:** a connected MCP client is pointed ONLY at the
dev-store Debug app during build and walk — NEVER at her real store or
the /Applications build; the live-round Claude Code session runs under
the SAME stage claim as the app leg it drives. The MCP SDK pin is EXACT
(0.x churn — R-13n-2); `swift package update` must never move it. The
shim probe and any TCC prompt answered on this machine is recorded in the
unit record (TCC state is machine-state the next session inherits).

## THE LEDGER (running; one row per item, every row owned)

| # | Item | Owner | Status |
|---|---|---|---|
| 1 | U1 — the spine (SDK, socket server, shim, grants table + pure rule, read rung, pane resting shape, grant sheet read-only form) | U1 implementer | IN FLIGHT — SDK landed (`14763773`), probes done, building |
| 2 | U1 probes (a)(b)(c) → architect rulings on the socket home + the setup press | orchestrator | CLOSED — AF-1…AF-4 + R-13nb-5/6 (her batch) |
| 3 | U1 ladder (fable-reviewer) | orchestrator | NOT STARTED |
| 4 | U2 — suggest + write new (+ the Private faces per R-13nb-4) | — | NOT STARTED (brief at U1 close) |
| 5 | U3 — edit + polish + her live round | — | NOT STARTED |
| 6 | A-4's honest-boundary line → the closeout author checklist | orchestrator | OPEN — standing |
| 7 | P-13nb-1 (journal predicate) — RATIFIED as R-13nb-1; QUESTIONS entry at merge records the ratification | orchestrator | CLOSED as provisional |
| 8 | THE PRIVATE MARK (R-13nb-4): v1_25 schema commit + Sync/ classifications + mirror artifact 16 — at the U1/U2 seam, Fable's hands | orchestrator | OPEN — scheduled |
| 9 | The lockstep DEPLOY window (marker 12→13, mirror → both installs) | her + orchestrator | HELD for the closeout window |
| 10 | 13x adoption lands MCP OFF (R-13nb-6) — the one toggle-OFF write on the adoption road | U2 (or U1 if the road is open) | OPEN |
| 11 | Re-verify probe (a) per macOS point release — line joins the closeout ritual note | orchestrator | OPEN — standing |

---

## THE U1 IMPLEMENTER BRIEF (self-contained; the spawn names this section)

You are the U1 implementer for Variorum phase 13n-b, working in
`~/dev/variorum-vx-124` on branch `vx-124-13n-b` (NEVER the main
checkout). Commits say `Part of VX-124`, no attribution trailer, push
after every commit. `notes/SessionResiliencyProtocol.md` binds you:
LIVE STATUS in the UNIT RECORD section below from your first commit,
foreground waits only, no subagents except ONE read-only Sonnet for
external facts (you will need it once — see the SDK step).

**Read first, in this order (reading is never delegated):** this plan
file TOP TO BOTTOM (the kickoff message, the ruled design, the units, the
constraints, the ARCHITECT SEAM RULINGS A-1…A-10, the environment traps);
`notes/plans/phase-13n-sitting-record-2026-10-09.md` (the rulings);
`notes/plans/13n-sitting-mockups/mcp-door-mockups.html` (§1–§4, §9, §10 —
the approved reference; render it or read the source); CLAUDE.md +
*[removed for publication]*
substrate: `Sources/VariorumCore/Domain/VariorumDocument.swift`,
`Queries/Export.swift` (`variorumDocumentText`), `Queries/SearchQueries.swift`
(`searchPassages`/`searchGroups`), `Queries/PostRender.swift`
(`renderedText`), `Persistence/Migrations.swift` (tail — v1_23 is the
latest; the 13o local-only family is your registration precedent),
`Sync/SyncSchema.swift` (`derivedTables` and whatever the completeness
walk consults), `App/Variorum/Variorum/Features/Settings/SettingsShape.swift`
(the pane roster), and the capability registry (grep `Registry` under
`App/Variorum/Shared/` — 13n-a's import door declarations are the fresh
precedent).

**What U1 builds (the plan's unit, expanded by the seam rulings):**

1. **The probes FIRST (A-10):** (a) container-socket reachability from a
   terminal-launched process, (b) sandboxed AF_UNIX bind at both candidate
   locations, (c) the setup press's sandbox reality. Small throwaway
   probes are fine (scratchpad, never committed to the app target). Write
   the facts into the UNIT RECORD and MESSAGE THE ORCHESTRATOR with your
   proposal for the socket home and the setup press BEFORE building those
   two halves; everything below that doesn't depend on them proceeds
   meanwhile.
2. **The SDK dependency (R-13n-2):** `modelcontextprotocol/swift-sdk`,
   pinned `exact:` to the current release — resolve the current version
   tag with your one Sonnet subagent (read-only; or `git ls-remote
   --tags https://github.com/modelcontextprotocol/swift-sdk`). New
   library target `VariorumMCP` + product, Mac-app-only linkage (A-1);
   a new `VariorumMCPTests` test target. License notices (MIT →
   Apache 2.0 per the ruling, plus any NOTICE file) land in the app's
   acknowledgements beside GRDB's (grep the About feature for where).
   The dependency lands in ITS OWN COMMIT before code that uses it.
3. **The grants substrate (A-5/A-6/A-7), schema commit separate:**
   migration `v1_24_mcp_grants` (local-only: `mcp_client`, `mcp_grant`,
   `mcp_activity`, the open-book row's home); the local-only registration
   the completeness walk honors (keep names truthful — these are NOT
   derived); plaintext-export exclusion pinned. Operations (approve/deny
   client, grant, revoke, record-activity, prune) through the operations
   layer with exact state-transition tests; the PURE grant rule in
   `Domain/` (allow/ask/refuse × rungs × scopes × durations × the journal
   fence P-13nb-1 × open-book) tested exhaustively headless — this rule
   is THE security boundary and its tests are the verification bar's
   floor: reads never exceed the grant, journals never match a standing
   grant or open-book, revocation is immediate, "once" is consumed,
   "while connected" dies with the session.
4. **The server (A-1/A-3/A-8):** the socket listener inside the app
   (lifecycle: toggle ON + store unlocked; 0600; unlink on stop);
   MCP sessions over the SDK with stdio framing across the socket;
   `initialize` → client row (first contact = a pending connection
   request, NO access); the READ tools — `list_books`, `list_notes`,
   `read_note` (the Level 0 format via `Queries.variorumDocumentText`),
   `search` (the 13o engine, scope-filtered), `export_note` (rendered
   plain text) — every call through the pure rule, scope-checked per
   call (A-7), refusals in the operations layer's own words, tools the
   grant excludes not listed (P-2 on the wire). Activity rows recorded
   from day one (the FACE is U3's). P1: every tool's cost ∝ its scope.
5. **The shim (A-2):** the byte pump, embedded `Contents/MacOS/`, signed
   unsandboxed, bundle-derived socket path, the honest "Variorum must be
   open" refusal. Build-shape call (Xcode command-line-tool target vs SPM
   executable + copy phase) is yours — record the reasoning; NEVER a
   custom build configuration.
6. **The pane's resting shape (mockups §1–§2 as amended by R-13n-5/10):**
   the new Settings ▸ MCP pane — DIRECT AND TECHNICAL register inside it
   (P-13n-1); toggle (off = shipped default, no popup ever asks);
   connection requests with Approve…/Deny; the clients list; SHARED WITH
   AI list; "Set up Claude Code" + the copyable command (per the A-10(c)
   ruling you'll receive); each list capped with an "all N ›" road from
   birth (R-13n-10). The grant sheet in its U1 form (A-9: where · how
   long; read-only rung). Every new door registry-declared with refusal
   copy; sentence case everywhere (her standing rule); app-wide faces
   keep the app's voice (P-13n-1's boundary).

**What U1 must NOT touch:** `Sync/` (zero lines; the grants family is
local-only), custody/keychain code, the editor seam
(`EditorTextView`/`BlockRangeIndex`/`PaneSurface`), the synced `setting`
table, any export path writing rows (the standing pin), the real store,
`/Applications`. No schema SYNC impact: marker 12 untouched, no mirror
DDL, no lockstep. Nothing may assume the client is external (R-13n-1).

**Acceptance (the plan's, restated):** a REAL Claude Code session on the
dev store reads a granted book and is REFUSED past it — the refusal
pinned; the read half of the verification bar pinned per tool (reads
never exceed the grant). The live-connection leg runs under a held stage
claim with the orchestrator; your own headless pins + a `swift build` +
the core suite for your areas run free. Tests at the END of the unit;
the 13n-a closeout is the baseline (core 2,478/284 + 40/6).

**Forks:** any design fork beyond A-1…A-10 returns to the orchestrator
with a proposal before that half is built (the in-batch fork rule);
PROVISIONAL-and-log for ambiguity that doesn't gate the unit; STOP and
report for anything gating. Her taste items (#207's P-13n-1/3) are
already logged — build to the recorded wording, don't re-open them.

---

## U1 UNIT RECORD (LIVE STATUS — the implementer owns this section from its first commit)

**NOT DONE (kept current; the first line at close):** everything below
not marked DONE. Session: opus-implementer, 2026-10-09, cut from
`2738543d`. Record test: a fresh session with ONLY the repo can finish
U1 from this section.

### Pieces

| # | Piece | Status |
|---|---|---|
| P0 | This record | DONE (`e1e97a74`) |
| P1 | A-10 probes (a)(b)(c) → facts below → orchestrator | DONE (`6f5a3d81`) — RULED: AF-1 (container socket as proposed), R-13nb-5 (Copy setup command), R-13nb-6 (adoption lands OFF) |
| P2 | SDK dependency, own commit (`exact: "0.12.1"`) + `VariorumMCP` / `VariorumMCPTests` targets + license notices | DONE (`14763773` + the pin `9afd3456`); link pin green; the Mac acknowledgements pin's run PENDING (stage) |
| P3 | Schema `v1_24_mcp_grants` (local-only), own commit; registration + export exclusion | DONE (this commit) — the schema suites 74/9 green headless |
| P4 | The pure grant rule (`Domain/MCPGrantRule`) + exhaustive tests | DONE (`f7927a91`) — 12/12 incl. the 13,824-world sweep; mutation-checked (4 boundary breaks each caught: 324 / 2,243 / 2 / 510 issues) |
| P5 | Grant operations + queries (approve/deny/grant/revoke/activity/prune/switches) + state-transition tests | DONE (this commit) — `MCPGrantOperationsTests` 14/14; the fence's three legs in ONE Queries site (`mcpNoteFacts`/`mcpBookFacts`; the Private leg a `"0"` fragment until v1_25) |
| P6 | The server (`VariorumMCP`: transport · session · grant authority · tool projections) + read tools + per-tool scope pins | NOT-STARTED |
| P7 | The `variorum-mcp` shim (byte pump, bundle-derived socket path) | NOT-STARTED — AF-1 ruled: `<container>/Data/mcp.sock`, `bindat`/`connectat`, two distinct refusals |
| P8 | Settings ▸ MCP pane resting shape + the U1 grant sheet (read rung) + registry declarations | NOT-STARTED — R-13nb-5 ruled: "Copy setup command" (`-s user`) |
| P9 | End-of-unit: `swift build`, core suite, `VariorumMCPTests`, Mac focused suites (stage) | PENDING |

### External facts (resolved this session)

- **MCP Swift SDK:** latest tag `0.12.1` (`git ls-remote --tags`,
  2026-10-09). Its manifest (tools 6.1, macOS 13+): the `MCP` library
  LINKS `swift-system` (SystemPackage), `swift-log` (Logging) and
  `mattt/eventsource` (macOS-conditional); the package ALSO declares
  `swift-nio` (conformance executables only — fetched, never linked
  into MCP) and `swift-docc-plugin` on `branch: "main"` (fetched,
  never linked). LICENSE: the MCP project's MIT → Apache-2.0
  transition text + Apache 2.0; no NOTICE file at the tag.
- **Claude Code CLI 2.1.296:** `claude mcp add [options] <name> <command>
  [args...]`; `-s, --scope local|user|project`, **default `local`** —
  a bare `claude mcp add variorum -- …` registers for the CURRENT
  DIRECTORY ONLY; the everywhere form is `-s user`.

### Probe facts (A-10) — run 2026-10-09 on the Pro, macOS 27 (no Variorum instance running throughout; throwaway C probes in the session scratchpad; every artifact removed after — no probe sockets, containers, launchd jobs or dotfiles remain)

**(a) A process outside the app reaching a socket INSIDE the app's container.**
A listener bound `~/Library/Containers/io.lduarte.Variorum.debug/Data/probe-a.sock`
(the REAL Debug app's container, mode 0600). Clients:
- from this Claude shell (inherits the terminal's grants): CONNECT OK.
- as a **launchd job** (`launchctl bootstrap gui/$UID`, ppid 1 — its own
  TCC-responsible process, inheriting NO terminal grants), ad-hoc signed:
  *[removed for publication]*
  5× in one job: **5/5 CONNECT OK**.
- **The control that makes this mean something:** the SAME launchd vantage
  opening a plain FILE in that container
  (`Data/Library/Preferences/io.lduarte.Variorum.debug.plist`, `O_RDONLY`)
  is REFUSED — `errno=1 Operation not permitted`, returned at once (no
  hang that would suggest a pending dialog; no TCC log line was readable).
  So App-Data container protection is LIVE on this machine, and it gates
  file opens but NOT `stat`/`connect` on a socket in the container.
- No TCC prompt was answered by this session (none was observable; the
  screen was not watched — the orchestrator may confirm no "would like to
  access data from other apps" dialog appeared on her screen ~13:47).

**(b) A SANDBOXED process binding an AF_UNIX listener.** Probe = a minimal
`.app` bundle (Info.plist id), team-signed with hardened runtime + ONLY
`com.apple.security.app-sandbox` (an ad-hoc, bundle-less sandboxed tool
SIGTRAPs at sandbox init — exit 133 — so the real helper/app shape was used):
- bind at its container's Data root: **BIND OK + self-connect OK** (no
  `network.server`/`network.client` needed for AF_UNIX).
- bind at `Data/tmp/` (the sandbox's `$TMPDIR` is `<container>/Data/tmp/`): OK.
- bind beside the store (`Data/Library/Application Support/Variorum-dev/…`):
  **path too long — 128 bytes vs `sun_path`'s 104** (103 usable). The
  socket cannot live beside the store under a plain path.
- `~/.variorum-mcp-probe/` with NO exception: `mkdir` EPERM.
- WITH the narrow `temporary-exception.files.home-relative-path.read-write`
  naming that dir: `mkdir` OK, but **`bind()` REFUSED — EPERM**; adding
  `network.server` + `network.client`: **still EPERM**. A sandboxed
  listener can bind ONLY inside its container; A-10's named fallback (a
  home-relative socket dir under a temp exception) does NOT work.
- Path budget (a plain path): Release `…/io.lduarte.Variorum/Data/` + a
  17-char name = 82 bytes for this user; Debug `…/Data/tmp/` + name = 92.

**(c) The setup press under sandbox.** From the plain sandboxed probe:
- read-open `~/.claude.json`: **EPERM**.
- spawn a child to write in `~` (children inherit the sandbox): **EPERM**.
- spawn `~/.local/bin/claude --version`: **EPERM — the sandboxed app
  cannot even EXECUTE the Claude CLI**, so "run `claude mcp add` for her"
  is impossible from the app as built.
- with an exact-path `home-relative-path.read-write` exception naming a
  dotfile (`/.variorum-probe-c.json` as the stand-in): create/open **OK** —
  so a `/.claude.json` exception WOULD let the app write Claude Code's
  config file directly.
- Not probed (screen-touching): an Open-panel (powerbox) pick of
  `~/.claude.json`; opening Terminal with a written `.command` file
  (files a sandboxed app writes are quarantined) or via Apple Events
  (needs the Automation consent prompt + an apple-events exception).

### Decisions, forks, PROVISIONALs

**P3 — the grants store's registration and export (implementer decisions,
within A-5's mandate "the implementer confirms the walk's exact
mechanism and keeps names truthful"):**
- **The completeness walk's mechanism:** `SyncSchemaTests
  .registryMatchesLiveSchemaExactly` asserts schema − synced ==
  `SyncSchema.localOnlyTables ∪ SyncSchema.derivedTables` — a TEST, not
  `Sources/…/Sync/`. The grants family registers as its OWN set,
  `MCPGrantSchema.tables` (Persistence), and the walk subtracts it by name
  with disjointness pins against both other families and the synced set.
  **Zero lines in `Sources/VariorumCore/Sync/`** (AF-4 — nothing to message
  the orchestrator for). Not added to `localOnlyTables` (that set is SYNC
  machinery the export DROPS and 13x's adoption RECREATES — the
  recreation, the classifier's export test and the restore drills all
  read it) and not to `derivedTables` (rebuildable from truth — grants
  are not).
- **The export's exclusion — STRIP, not drop (a change from my probe-time
  message; same outcome, smaller road):** the plaintext export keeps the
  four tables and DELETEs their rows (child-first:
  `MCPGrantSchema.childFirstOrder`, FK order). Dropping them would have
  left a re-opened export whose `grdb_migrations` says v1_24 ran with the
  tables absent — a second recreation road in 13x's adoption code. A
  stripped export lands EMPTY + OFF by construction (no switch row reads
  off) with no change to `LocalMachineryRecreation` or the classifier.
  Pinned: `MCPGrantSchemaTests.thePlaintextExportCarriesTheTablesEmpty`.
- **P4/P5 — the grammar as built (PROVISIONALs for the record; the
orchestrator logs them at merge):**
- **P-13nb-U1-1 — "while connected" = the CLIENT's connection**, not one
  socket: its while-connected grants are revoked when that client's LAST
  live connection closes (two Claude Code windows share one name), and
  every server start sweeps them all (a crash can't leave one standing).
- **P-13nb-U1-2 — a once grant is spent by the first CONTENT read it
  authorizes** (`read_note`/`export_note`), never by a listing, and never
  when a standing grant (or the open book) also covers the call; the stamp
  lands in the same write transaction as the read.
- **P-13nb-U1-3 — the open book is read rung, EVERY wing** ("everything is
  readable"), approved clients only, never a fenced target.
- **P-13nb-U1-4 — grant targets are BOOKS (kind 'book'), not gatherings**,
  in U1; a fenced book (journal trait, the daily Journal, later Private)
  is never a grant scope (the op refuses `mcpGrantScopeFenced`) and never
  listed; scraps groups (pools) and note versions have no facts — every
  tool answers them exactly as an unshared note (no existence oracle).
- **P-13nb-U1-5 — the clients list's "revoke" is a DENY**: every grant
  revoked at once, the client blocked (its next call refuses "denied");
  "Approve…" re-admits it.
- **P-13nb-U1-6 — the caps:** 50 pending requests (the oldest forgotten —
  a pending client holds nothing), 500 activity lines.
- **Membership is canon's:** `status='member'` only (an arrival is never
  membership), live readings only; an ARCHIVED journal book still fences.

**Ledger row 10 (13x adoption lands OFF, R-13nb-6) — U2's.** The
  sealed-pair / backup adoption roads land the WHOLE encrypted file
  (grants and the `server` switch included); the one toggle-OFF write
  belongs on 13x's adoption road (`LibraryAdoption`, which also adopts
  custody) — custody-adjacent code this unit's brief keeps out. U1's
  server reads the switch per launch, so until row 10 lands an adopted
  library with the switch ON would start the server — OFF is the shipped
  default and no store has ever had it ON, so nothing is exposed before
  U2. (Revisit if the orchestrator wants it in U1.)

**FORK A-10 — returned to the orchestrator 2026-10-09 with this proposal
(build of P7's path rule and P8's press waits for the ruling):**
- **Socket home — PROPOSAL: the app's OWN container, R-13n-3's letter kept
  whole.** `<container>/Data/mcp.sock` (the sandboxed app's
  `NSHomeDirectory()`; the shim computes the same from its bundle id and
  the REAL home via `getpwuid`). Both ends use `bindat`/`connectat` with a
  directory fd + the short relative name, so `sun_path`'s 104-byte limit
  can never bite a long username. The shim tells the two failures apart:
  ENOENT/ECONNREFUSED ⇒ "Variorum must be open" (R-13n-3's honest
  refusal); EPERM/EACCES ⇒ a distinct honest refusal naming macOS
  blocking the connection (the probed protection boundary, if a future
  macOS extends App-Data protection to `connect`). No fallback location
  is built (the named one does not work — (b)). Re-verify (a) after each
  macOS point release (a TEXTKIT2-§5-style line for the door).
- **Setup press — PROPOSAL: primary-copy-with-receipt, NO entitlement
  widening.** The press copies `claude mcp add -s user variorum --
  "<this app's own shim path>"` and the pane says so in its own line; the
  command is shown verbatim and selectable beneath. Its verb must not
  claim a setup it does not perform (P-2) — proposed **"Copy setup
  command"** (the pane's technical register). Why not the exception road
  (`/.claude.json` read-write, which works per (c)): Claude Code rewrites
  that file whole and often — a JSON merge by a second process races it
  in both directions — and its layout is Claude Code's private state, not
  a documented interface. `-s user` is a deliberate deviation from the
  mockup's command (default `local` would register Variorum only for the
  folder she ran it in — the external fact above).

### Machinery notes

*(none yet)*
