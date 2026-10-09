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
- **R-13nb-7 (2026-10-09, her evening batch) — COMMITS REACHABLE BY
  EXPLICIT ASK on the connected road.** Her framing that raised it:
  *"when you say history do you mean commits? like the ability to see
  what a commit said? because i feel like granting access to a block
  suggests that."* Ruled: a read grant on a note INCLUDES its commit
  history, reached by name per call — a `with_commits` parameter on
  `read_note`'s structured view (13o's `+ commits` facet posture
  mirrored on the wire). NEVER ambient on every read (P1 on long
  chains; past-text disclosure stays deliberate), NEVER in the Level 0
  text (R-13n-8's file ruling stands — history is lived, not authored),
  NEVER via MCP `search` (the U1 clean-bill line stays deliberate).
  Lands at U3 beside `edit_take`'s insurance brackets (the agent can
  read back its own before/after).
- **R-13nb-8 (2026-10-09, same batch) — BLOCK NAMES: CARRY, AND THE AI
  MAY NAME (edit rung).** Her ask: *"do you think we should allow for
  block naming to facilitate working with AI? like 'in xzy block'"* —
  ruled as CARRY + AI-MAY-NAME: `with_ids` JSON carries `block.name`
  wherever set (U2, one field — "in the xyz block" works
  conversationally; the handle exists since v1_6 and search already
  indexes it); ids stay the ONLY write address (names aren't unique;
  ambiguity at a write boundary is where wrong-target bugs live); PLUS
  a set-name tool on the EDIT rung at U3 (`setBlockName` projected —
  identity-level metadata, no-op-guarded, an agent structuring a book
  may label blocks). Access granularity restated with it: block-level
  ADDRESSING, note-level-and-up ACCESS — no per-block grant, no
  per-block fence, the note is the disclosure unit.
- **R-13nb-18 (2026-10-09, her rung walk-through, verbatim) — WRITE-NEW
  EXPLICITLY INCLUDES THE WHOLE NOTE, THE WHOLE BOOK, AND SAVING A
  VERSION.** Her words: *"I do think making new notes should be allowed
  under write new notes + making a new version of the note and such
  (just making sure explicitly that whole new note and book are
  included)."* Confirmed: `create_note` and `create_book` are
  write-new's (the ruled set already carried them — now explicit at her
  word); NEW by this ruling: **`save_version` (the `saveNoteVersion`
  family) is a WRITE-NEW-rung act** — minting a whole-note version is a
  creative act that touches no existing text (the append-only family
  copy), which is write-new's exact definition; R-13nb-14 had left the
  versions write side to the sitting, now placed. WHEN it ships rides
  the R-13nb-16 staging; the RUNG is settled. Her undo question
  answered at the record: an AI-minted whole note is ONE compound
  structural-undo entry (R-13n-6's bulk-door rule — the inverse
  tombstones everything minted on the stamp; ⇧⌥⌘Z revives exact rows);
  the entry lands on HER app session's one undo stack interleaved with
  her own gestures; the wire deliberately has NO undo tool — ⌥⌘Z is
  her veto, never the agent's instrument; after the app session ends
  the note is an ordinary note and the Trash is the standing net.
- **R-13nb-16 (2026-10-09, her answer to the sizing flag, verbatim) —
  ALL ON THE PLAN; LAUNCH BUILDS A CHOSEN SUBSET.** Her words: *"that's
  fine on the sizing rule - we can choose what gets built for launch
  and it doesn't necessarily have to be every single thing, but they
  should be on the *plan*, and I do hope to get as many of them done as
  possible."* The staged proposal is ratified as the vehicle: the
  format-schema sitting designs the WHOLE keyboard-bar inventory (every
  carriage named, nothing left to folklore); the launch cut is hers at
  the sitting; the un-cut remainder lands as NAMED follow-on tickets on
  the plan, never vagueness (the S4-16 condition's spirit).
- **R-13nb-17 (2026-10-09, same message, verbatim) — NARROW WHERE IT
  COUNTS: THE RUNG IS THE ONLY READ DIAL.** Her words: *"this is also
  why I like our limited rules - read, write takes, write everything.
  it means that we aren't allowing users a lot of choice in what's
  read (aside from private or not, sharing note or not). it would be a
  nightmare to let some ai read deleted takes and other ai's not to,
  but that's not even in question. keep that in mind too - the surface
  is still narrow where it counts in a lot of ways and should be kept
  that way."* THE DOCTRINE: the grant sheet's dials stay EXACTLY where
  · how much · how long, plus the Private mark — NO read-carriage
  knobs, ever. Within a granted scope, read reach is UNIFORM per rung:
  when versions, the tray, ancestry and commits land on the wire
  (R-13nb-14), they land identically for every granted reader — the
  explicit per-call parameters (with_commits, include_commits and kin)
  are CALL shapes, never per-client configuration. R-13nb-15's
  carriage profiles are FILE-side only, restated. (Her compression
  "read, write takes, write everything" is recorded as spoken; the
  ruled four-rung grammar — read · suggest · write new · edit,
  R-13n-4 — stands untouched, her words speaking its spirit of
  coarseness, not a re-count. CONFIRMED by her next message, verbatim:
  *"yes, my phrasing was praising the coarseness, not recounting the
  rings. … i'm happy with those four though."*)
- **R-13nb-15 (2026-10-09, her follow-on design direction, verbatim) —
  THE FILE FORMAT GAINS CARRIAGE SETTINGS.** Her words: *"what this is
  revealing to me is that the file format is probably going to need to
  have settings that users can save + are remembered - like: does trash
  come along? do unplaced blocks come along? and users can choose their
  default for export. for markdown export, does xyz come along. do we
  have sqlite export format and a markdown format, etc. but we'll make
  it more frictionless with opinionated defaults and saved settings /
  preferences (or even a way to save + name setting sets, for if you
  send files to different audiences)."* Direction-strength for the
  format-schema sitting: the file side is parameterized by CARRIAGE
  PROFILES — a dial set (trash · unplaced blocks · commits · comments ·
  names · versions · …) with opinionated per-format defaults,
  remembered preferences, and optionally NAMED profile sets per
  audience. The sitting designs: the dial set, the defaults per format,
  the export TAXONOMY (today's roads named so each format has one job —
  the Level 0 text · the no-lock-in plaintext SQLite export · the 13x
  sealed transfer pair · 13m's shareable edition), and WHERE profiles
  live — with one constraint flagged now: NAMED sets carry user prose,
  and `setting.value` is classified PLAIN under the "enum semantics, no
  prose" promise (AppSpec §7), so named profiles need their own small
  synced table (name encrypted) or a local-only home — a §12-relevant
  shape question the sitting must answer, never improvised. The WIRE
  stays profile-free (R-13nb-14's keyboard bar: rungs and grants are
  its only dials).
- **R-13nb-14 (2026-10-09, her answer striking Tier C — THE KEYBOARD
  BAR, verbatim):** *"Why is any of this being excluded? the goal is for
  an AI to fully empower you with variorum - lot of people will never
  even understand that take ancestry is a thing, won't know how to use
  whole note versions (which are super helpful for editions of a design
  document), etc. … every core variorum use case and concept needs to
  be built into the mcp. these exclusions are huge. the mcp also needs
  access to a note's tray of deleted things. The MCP should be as
  useful as the user at the keyboard - even if we make file format
  decisions like your trash isn't carried over (which is fair for a
  file sharing choice maybe, I haven't decided), the bar for AI is
  higher."* **THE DOCTRINE:** within a grant's scope and rung, the wire
  exposes the FULL model — the capability bar is the user at the
  keyboard; an EXCLUSION needs affirmative justification (the fence, or
  a feature she herself calls underbaked), never the other way around.
  The memo's Tier C restraint frame is RETIRED. Named IN by this
  ruling: take ancestry, whole-note VERSIONS (list/read; the write side
  is the sitting's), lineage, THE TRAY (a note's deleted things —
  read, and Put back on the fitting rung). Named OUT at her own word:
  block-level tags ("an underbaked idea that I've never even seen /
  used") — the verified mechanics recorded for her: block tags ARE
  exposed today (the Snippets/Pool faces + the search's Blocks scope)
  and a block tag NEVER pulls a note into a gathering (assembly and
  intake read post_tag only); her hide-the-faces question is ticket
  **VX-128** (Needs Lillian). ARCHIVED clarified (the facet = archived
  NOTES in the Library search): its wire reach is the sitting's option
  set under this doctrine. The FILE format may stay more conservative
  (her words — "fair for a file sharing choice maybe, I haven't
  decided"): wire ⊇ keyboard, file ⊆ — the sitting designs both
  carriages. **Sizing consequence, said plainly at the record:** this
  doctrine grows the tool surface well past the ruled lean set; the
  format-schema sitting's prep carries a STAGED proposal (what ships in
  13n-b's U3 pre-launch vs what follows as its own effort) — hers to
  cut at the sitting, never split silently.
- **R-13nb-11 (2026-10-09, the wire-document memo's batches) — THE MEMO
  EDGES RULED.** G-1 chapters: (a) READ + WRITE — section facts ride the
  wire document and list_notes; `create_section` + a section arg on
  `add_note_to_book` at U3 (curated books only, the app's own refusals).
  G-2 write fidelity: (a) `create_note` accepts EITHER payload — the
  text format OR a wire-document subset (multi-paragraph blocks, names,
  labeled takes) through the same ordinary ops; the FILE doors stay
  text-only, `import_document` included (it IS the file format's door —
  one format, one meaning, whichever door a file enters by).
  G-4: the wire OMITS `floating_notes` (a faceless substrate field —
  no surface renders it; her clarifying question answered with the code
  fact) — ticket **VX-127** records face-or-retire for her backlog.
  Tier C's ratification: pending her word (and partly reshaped by
  R-13nb-13 below — the FILE-side items may move into the pulled-forward
  format sitting).
- **R-13nb-12 (2026-10-09, her evening message) — NOTE-LEVEL-AND-UP
  ACCESS IS DURABLE.** Her words: *"I like note level and up access by
  the way - way more sane and manageable and not planning to ever
  change that."* The granularity doctrine (block-level ADDRESSING,
  note-level-and-up ACCESS; no per-block grant, no per-block fence; the
  note is the disclosure unit) is ratified as a standing design
  commitment, not a v1 convenience.
- **R-13nb-13 (2026-10-09, same message) — DO NOT CONTORT; PULL THE
  FORMAT DESIGN FORWARD IF NEEDED.** Her words: *"these latest
  questions make me even more sure that we should NOT be contorting the
  variorum data to fit this limited markdown import / export model. If
  we need to pull forward the variorum file format design to do this
  stage properly, we can do that. even if it's just the design sitting
  without building it."* The architect's proposed execution shape
  (hers to pick, the question batch): a NARROW format-SCHEMA sitting
  pulled forward from 13m — scoped to the DATA SHAPE only (what a
  full-fidelity note/book serialization carries: blocks with real
  boundaries, takes, commits, comments, names, callouts; the id policy
  per R-13nb-9), producing a binding format-design record that the
  13n-b WIRE DOCUMENT conforms to as its wire serialization — one
  schema, two serializations, zero rework at 13m; 13m keeps its
  sharing/publishing/renderer halves. The FILE serialization's BUILD
  stays 13m's ("even if it's just the design sitting without building
  it" — her letter).
- **R-13nb-10 (2026-10-09, minutes after R-13nb-7 — her correction,
  verbatim) — MCP SEARCH REACHES COMMITS BEHIND THE EXPLICIT
  PARAMETER.** Her words: *"why can AI not search commits? seems wrong
  to me, annoying to have to do a search yourself bc it's searching
  commits too. the platform should be AI empowered for ppl who want
  that."* R-13nb-7's "NEVER via MCP search" arm is SUPERSEDED — it was
  the architect's carry-forward of U1's as-built state, not her ruling.
  The amended shape: `search` gains `include_commits` (default false) —
  the `+ commits` facet's WIRE FORM, honoring R-VX83's letter exactly
  (a savepoint never lists without the facet; the parameter IS the
  facet, per call, explicit) — scope-checked per note through the same
  grant road as passages, P1 ∝ matches. Lands at U3 beside
  `with_commits`; U1's search-never-reaches-savepoints state flips
  DELIBERATELY there (any pin asserting it is updated as the ritual,
  not worked around). R-13nb-7's other arms stand: never ambient on
  reads, never in the Level 0 text. The ARCHIVED facet stays UI-only
  (unchanged — she named commits; one word from her flips it the same
  way if wanted).
- **R-13nb-9 (2026-10-09, her rider, verbatim) — IDS ARE LIVE, THE
  EVENTUAL FORMAT IS CAREFUL.** Her words: *"I definitely think that
  the eventual format should be very careful about block id - even
  just a merge changes the id, so it's better live."* The doctrine
  recorded: block ids are EPHEMERAL under structural ops (a merge
  mints a fresh block and releases its sources; divide mints
  successors), so ids belong to the LIVE wire (`with_ids` reads,
  per-call revalidation — a stale id refuses honestly and a re-read is
  the recovery), never to the text format — and **13m's full-fidelity
  variorum edition must weigh this when it designs id carriage** (a
  file's ids go stale the moment she merges; this line is 13m's
  pointer, recorded here at her word).

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
  **AF-1 AMENDED (architect, 2026-10-09 — the implementer's finding
  `c3e39ec2`, P-13nb-U1-7 ACCEPTED AS RULED):** `bindat`/`connectat` are
  not public API on the macOS 27 SDK (no header declares them;
  `pthread_fchdir_np` is private too), so the mechanism half of this
  ruling is replaced: both ends use the plain absolute container path,
  LENGTH-GUARDED against `sun_path` (fits usernames to 36 chars Debug /
  42 Release; hers is 13). Past the guard the server refuses to start
  and the shim speaks its own honest "path too long" line — never a
  truncated path, never a silent bite. The alternatives (a process-wide
  `chdir` in the app; an undocumented oversized `sun_len`) were judged
  worse and the architect concurs: global cwd state in a multi-threaded
  app and undocumented kernel behavior are both costlier than an honest
  refusal on a near-impossible input. AF-1's INTENT (the limit can never
  bite silently) stands; its letter (can't bite at all) is retired.
- **AF-2 — the setup press:** R-13nb-5 above (hers). Build as ruled.
- **AF-3 — adoption carry-over:** R-13nb-6 above (hers). The 13x
  adoption road gains the one toggle-OFF write; the export-rebuild
  recreation as the implementer proposed.
- **AF-4 — the Sync/ boundary, restated for U1:** any line inside
  `Sources/VariorumCore/Sync/` — the local-only registration if it lives
  there, and v1_25's column classifications — is the ORCHESTRATOR'S to
  land (CLAUDE.md's Fable rider). The implementer messages the exact
  lines needed; nothing in that directory is edited by an Opus session.

## ARCHITECT RULINGS ON THE U2 FORKS (Fable, 2026-10-09 — on the U2 implementer's proposals, `90797596`; recorded before the affected halves build)

- **AF-5 — block addressing: proposal (a) APPROVED.** `read_note` gains
  the optional `with_ids: true`, answering the structured JSON
  (note_id, title, blocks with block_id / shown-take text / takes with
  take_id·label·chosen / comments); the DEFAULT answer stays the Level 0
  text BYTE-FOR-BYTE (the mockup §9 contract's "blocks, takes, comments"
  reading). (b) index+expected_text rejected (P-13n-4 makes indices
  unspeakable for multi-paragraph blocks; her mid-session divide shifts
  them); (c) a sixth tool rejected (the lean set is ruled; ids divorced
  from the text they address). Riders: the ids are the REAL row UUIDs so
  every later write revalidates per call against current facts (a block
  released or re-homed since the read refuses through the ordinary
  checks); the JSON form passes the same per-note fence/decide filter as
  the text form (same facts, same rule — pinned); P1 ∝ the note, as the
  text form.
- **AF-6 — the just-in-time ask NEVER BLOCKS: proposal APPROVED.** The
  latency-oracle trace is correct (a blocked call answers instantly for
  a missing id and hangs for a real one — an existence oracle in time;
  and it holds the client's tool timeout hostage to her attention). The
  call answers at once; the app queues the ask (in memory, deduped per
  client·target·rung, capped), the mockup §4 sheet serves them one at a
  time; her answer mints the grant through the ordinary ops; `notShared`
  keeps the ONE answer byte-unchanged on the wire (the client can never
  tell whether an ask was raised — no oracle); `rungTooLow` and `fenced`
  (targets the client legitimately knows exist) gain the said sentence
  ("Variorum has asked the author — call again once she answers." —
  copy 13s-a-sweepable). "Always" never offered on a fenced target
  (R2-1's fix rides here); "while connected" only to a connected client
  (U1's rule carried). In-memory is accepted (a dropped ask costs the
  client one re-ask next session). OPTIONAL, implementer's call this
  unit or U3's: pending asks also visible as pane rows on the requests
  idiom. PROVISIONAL class for the merge bundle: the queue shape and the
  ask-on-unshared-existing-target behavior (an ask IS queued while the
  wire stays silent — her sheet names a note the client could not list;
  informative to her, invisible to the client).
- **AF-7 — "once" spends AT ITS OWN RUNG: proposal APPROVED.** A once
  grant is consumed by the first call at the grant's OWN rung that it
  authorizes — read: the first content read (P-13nb-U1-2's letter,
  unchanged for read grants); suggest/write new: the FIRST WRITE, with
  the lower-rung reads it needs on the way riding free. One line in
  `MCPGrantRule.decide`, pinned both ways (the ride-free read does not
  consume; the first write does; the second write refuses). This AMENDS
  P-13nb-U1-2 for the write rungs — the provisional's record gains the
  amended form for the merge QUESTIONS bundle. Stated edge, honest in
  the record: a once-suggest grant authorizes ONE write — a take-plus-
  lens flow wants "while connected", and the ask sheet's durations
  already offer exactly that.
- **AF-8 — scope confirmations.** The note ⋯ menu's GRANT row ("Allow
  AI here…" — R-13n-11's connected share-a-note) is U3's, as the U1
  not-done list recorded; U2 carries only the Private row there. And the
  mandate decision noted in `90797596` — MCP writes on the session's
  OperationsRunner with the session's UndoStack — is CONCURRED with
  explicitly: it is R-13n-6's letter (MCP writes ARE ordinary
  operations) and the serialization the one-collector compound machinery
  requires; reads stay on the reader pool as U1 built them. The U2
  ladder watches the latency class (a bulk MCP import serializes with
  her gestures exactly as her own File ▸ Import does — same cost, same
  class; P1/P2 eyes on anything beyond it).

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
| 1 | U1 — the spine (SDK, socket server, shim, grants table + pure rule, read rung, pane resting shape, grant sheet read-only form) | U1 implementer | **CLOSED** — built (`c2a84bd3`), live round MET (`b9492ced`), ladder closed clean |
| 2 | U1 probes (a)(b)(c) → architect rulings on the socket home + the setup press | orchestrator | CLOSED — AF-1…AF-4 + R-13nb-5/6 (her batch) |
| 3 | U1 ladder (fable-reviewer) | orchestrator | **CLOSED at round 2** — R1 0B/0M/4m/3n, 7/7 AGREE, 5 FIXED by the reviewer (pins revert-verified twice), 2 RECORDED; sanity pass PASS (O1/O2 record-only); R2 CLEAN BILL (0/0/0/2n record-only). Records: `13nb-u1-ladder-round{1,2}.md` |
| 4 | U2 — suggest + write new + the grant sheet's rungs + the just-in-time ask + the Private faces (R-13nb-4) | U2 implementer | BRIEFED — spawning (the brief below) |
| 5 | U3 — edit + polish + her live round (+ `with_commits` R-13nb-7, `include_commits` on search R-13nb-10, the set-name tool R-13nb-8, the Allow-AI-here row AF-8) | — | NOT STARTED |
| 6 | A-4's honest-boundary line → the closeout author checklist (now incl. the grants-ride-copies note under R-13nb-6) | orchestrator | OPEN — standing |
| 7 | P-13nb-1 (journal predicate) — RATIFIED as R-13nb-1; QUESTIONS entry at merge records the ratification | orchestrator | CLOSED as provisional |
| 8 | THE PRIVATE MARK (R-13nb-4): v1_25 schema commit + Sync/ classifications + mirror artifact 16 — at the U1/U2 seam, Fable's hands | orchestrator | **DONE** (`304b41d1` — marker 13 client-side; headless whole-package green) |
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

**UNIT CLOSED by the implementer — NOT DONE: (1) the LIVE Claude Code
round (the acceptance's real-client leg — the orchestrator's, under a held
stage claim; my pre-flight drove the real embedded shim with a scripted
client, never Claude Code itself); (2) ledger row 10 (13x adoption lands
MCP OFF — U2's, ruled); (3) the ACTIVITY face (U3's — the log is written);
(4) the note scope's face (the note ⋯ menu — U2/U3; the grammar and ops
carry note grants already); (5) a Developer-ID release export of the shim
(untested — rides 13r's nested-code re-sign); (6) the whole VariorumTests
target (only the five touched suites ran).** Session: opus-implementer,
2026-10-09, cut from `2738543d`; closed at `a3edf260` + this record.

### Pieces

| # | Piece | Status |
|---|---|---|
| P0 | This record | DONE (`e1e97a74`) |
| P1 | A-10 probes (a)(b)(c) → facts below → orchestrator | DONE (`6f5a3d81`) — RULED: AF-1 (container socket as proposed), R-13nb-5 (Copy setup command), R-13nb-6 (adoption lands OFF) |
| P2 | SDK dependency, own commit (`exact: "0.12.1"`) + `VariorumMCP` / `VariorumMCPTests` targets + license notices | DONE (`14763773` + the pin `9afd3456`); link pin green; the Mac acknowledgements pin's run PENDING (stage) |
| P3 | Schema `v1_24_mcp_grants` (local-only), own commit; registration + export exclusion | DONE (this commit) — the schema suites 74/9 green headless |
| P4 | The pure grant rule (`Domain/MCPGrantRule`) + exhaustive tests | DONE (`f7927a91`) — 12/12 incl. the 13,824-world sweep; mutation-checked (4 boundary breaks each caught: 324 / 2,243 / 2 / 510 issues) |
| P5 | Grant operations + queries (approve/deny/grant/revoke/activity/prune/switches) + state-transition tests | DONE (this commit) — `MCPGrantOperationsTests` 14/14; the fence's three legs in ONE Queries site (`mcpNoteFacts`/`mcpBookFacts`; the Private leg a `"0"` fragment until v1_25) |
| P6 | The server (`VariorumMCP`: transport · session · grant authority · tool projections) + read tools + per-tool scope pins | DONE (`c3e39ec2` + pins `bab7e30c`) — `MCPServerTests` 10/10 end to end over a real socket with the SDK's own Client; `MCPShimTests` 8/8; mutation-checked (4 server breaks, each caught) |
| P7 | The `variorum-mcp` shim (byte pump, bundle-derived socket path) | DONE (this commit) — Xcode command-line-tool target `variorum-mcp` (sources `App/Variorum/VariorumMCPShim/main.swift`, links the `VariorumMCPSocket` product), embedded by the app's "Embed MCP Shim" copy phase (Executables = `Contents/MacOS`, CodeSignOnCopy) + a target dependency; hardened runtime, NO sandbox entitlement, team-signed; `codesign --verify --deep --strict` passes; the real embedded Debug shim answers `initialize` with "Variorum must be open" when nothing listens |
| P8 | Settings ▸ MCP pane resting shape + the U1 grant sheet (read rung) + registry declarations | DONE (`4b3ec357` + the walk's fixes, this commit) — Mac `MCPPaneTests` + the four touched suites 65/65 under the stage (0 skipped); the pre-flight WALK below on the dev-store Debug build, both voices |
| P9 | End-of-unit: `swift build`, core suite, `VariorumMCPTests`, Mac focused suites (stage) | DONE — headless `swift test`, the whole package: core **2,511/287** (baseline 2,478/284 + 33 tests / 3 suites: `MCPGrantSchemaTests` 5, `MCPGrantRuleTests` 13, `MCPGrantOperationsTests` 15), `VariorumMCPTests` **19/3**, workbook **40/6**; the only skips are the long-standing gated ones. Mac (stage held, `-only-testing`): `MCPPaneTests` + `DiagnosticsPaneTests` + `CapabilityRegistryTests` + `SettingsShapeTests` + `AcknowledgmentsCopyTests` **65/65, 0 skipped** (re-run after the self-review fixes `a3edf260`) |

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

**AF-1's MECHANISM — a deviation, reported to the orchestrator
(non-gating):** `bindat`/`connectat` (and the per-thread
`pthread_fchdir_np`) are NOT public API on the macOS 27 SDK — no header
declares them, so a shipping app cannot call them. Both ends therefore use
the plain ABSOLUTE path, length-guarded: `<home>/Library/Containers/<bundle
id>/Data/mcp.sock` must fit `sun_path`'s 103 bytes, which leaves a user name
up to 36 characters (Debug) / 42 (Release); past that the server refuses to
start and the shim speaks a distinct honest line (`pathTooLong`) — never a
truncated path. The ruling's intent (the limit can't silently bite) holds;
its letter (it can't bite at all) does not. PROVISIONAL P-13nb-U1-7.

**P7 — the shim's build shape (the brief's call, recorded):** an Xcode
COMMAND-LINE-TOOL target, not an SPM executable + script phase. Xcode
signs and embeds it natively (a Copy Files phase to Executables with
CodeSignOnCopy, a target dependency so `xcodebuild -scheme Variorum`
builds it first), it inherits the two standard configurations (no custom
configuration — the Debug/Release letter holds), and its behaviour lives
in the SPM library `VariorumMCPSocket` so it tests headless; the target's
`main.swift` only launches it. A script phase would have rebuilt the
package outside Xcode's configuration and signed by hand. Bundle ids
(the signing identifiers' source): `io.lduarte.Variorum.debug.mcp-shim` /
`io.lduarte.Variorum.mcp-shim`; `SKIP_INSTALL = YES` (an archive carries
it inside the app only). Developer ID distribution re-signs nested code at
export (13r's road) — the shim rides that like any nested binary; noted
for the release run, untested here.

**P8 — the pane as built (PROVISIONALs for the record):**
- **P-13nb-U1-8 — the list caps:** requests 3, clients 5, shared 5, each
  with its "all N ›" road (a scrollable sheet) — R-13n-10's shape.
- **P-13nb-U1-9 — the pane's place:** MCP sits between Tags and
  Protection (the eleventh pane); 13r's ruled Diagnostics placement is
  untouched (the pane-count pin moved 10 → 11, annotated).
- **P-13nb-U1-10 — the Debug build registers as `variorum-dev`** in
  Claude Code (`claude mcp add -s user variorum-dev -- …`), the Release
  build as `variorum` — so a dev setup never replaces the real one in the
  client's config (the A4 fence carried to the client's registration).
- **P-13nb-U1-11 — the sheet's WHERE is "a book · a wing"** in U1:
  Settings holds no note, so the note scope's face is the note ⋯ menu's
  (R-13n-4's faces; U2/U3). The grammar and the ops support note grants
  already (pinned).
- **P-13nb-U1-12 — the toggle's sentence, U1-true:** the mockup's "can
  read and write here … AI work lands as takes beside your own" reads
  "can read here … no client can overwrite your text" until the write
  rungs land (U2 restores the mockup's words).
- **The pane does NOT show ACTIVITY** (U3's face per the brief); the log
  is written from day one.

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

### The U1 pre-flight walk (dev-store Debug build, 2026-10-09 ~14:47–15:00, under my own stage claim — the orchestrator's live Claude Code round is still owed)

Captures (gitignored): `notes/plans/13n-b-screens/u1/01…14-*.png`. The
client was a scripted MCP session through the REAL embedded shim
(`…/Debug/Variorum.app/Contents/MacOS/variorum-mcp`, spawned over stdio
exactly as Claude Code spawns it), self-named `u1-walk`.
- **01** Study, at rest: OFF, no socket file. **02** toggle ON → the REAL
  sandboxed app bound `~/Library/Containers/io.lduarte.Variorum.debug/Data/
  mcp.sock` (`srw-------`), status "running · socket in the app container
  …". **03** the shim's `initialize` → answered; `tools/list` → `[]`;
  `read_note` → the pending refusal in its words; the pane shows
  "Connection request — u1-walk · First seen now. No access until
  approved." with Approve… / Deny. **04** Approve… → the U1 sheet (where ·
  read · how long; the confirm "Grant read in “o ladrão de raios”
  always"). **05** granted: the client row ("reads 1 shared place",
  Change… / Revoke) and the shared row (book chip, "u1-walk · read ·
  always"). Through the shim: `list_books` → that ONE book; `list_notes`
  → its 4 notes; `list_notes(wing_id: "")` → REFUSED ("That wing isn't
  shared …"); `read_note` → the Level 0 document; `export_note` → the
  plain prose; `search "semideus"` → the book's passages, matches **marked**.
- **REFUSED PAST IT with a REAL outside note:** the open book ON (**08**)
  listed a field-guide note (`140F5B58…`); `export_note` read it; the open
  book OFF (**09**) → the very next call REFUSED ("That note isn't shared
  with this client, or doesn't exist."). **10** Revoke on the shared row →
  `tools/list` `[]` and the book's own note REFUSED on the next call.
- Quit (⌘Q, my instance) → the socket file GONE (A-8). Relaunch with the
  toggle still ON → the server bound at store-open by itself.
- **Terminal voice** (**11** pane, **12** the sheet's wing scope — "everything
  in Home except journals, which always ask", **13** Home granted, **14**
  the copy receipt): a Home-wing grant → `list_books` all three books,
  `list_notes(wing_id: "")` paged with a `next_cursor`, `search
  "passphrase"` → field-guide passages.
- Restored: the Home grant revoked, the server OFF (socket gone), the voice
  back to Study, my instance quit. LEFT in the dev store: the `u1-walk`
  client row (approved, nothing shared) and its activity lines — a record,
  harmless; the live round's client arrives under its own name.

**The walk's four findings — all FIXED in this commit:**
1. The setup command was CLIPPED at three lines on the Debug build's long
   DerivedData path ("…/Cont…") — not verbatim (R-13nb-5). Now up to ten
   lines; capture 14 shows it whole. (**06** is the before.)
2. The copy RECEIPT rendered at the form's foot, below the fold — the press
   looked silent. `MCPDoor.Note` now carries a place: the receipt renders
   under its button, a refusal under the server toggle. Pinned.
3. "No clients yet" read wrong beside a waiting request → "None yet — a
   client is listed here once you approve or deny its connection request."
4. "While connected" was offered to a client NOT connected — a door that
   cannot act as named (P-2). The sheet now offers it only while the client
   is connected (`MCPGrantSheet.durations(connected:)`, pinned), with a quiet
   line saying so.

### Open items for the orchestrator (the merge / the ladder)

- **The live round** (the acceptance's real-client leg): a Claude Code
  session against the dev-store Debug app reads a granted book and is
  refused past it. Setup: Settings ▸ MCP ▸ Copy setup command registers
  `variorum-dev` at USER scope in her `~/.claude.json` (P-13nb-U1-10); for
  a throwaway registration run the copied command with `-s local` in a
  scratch folder instead (the CLI's local scope is that folder only), and
  `claude mcp remove variorum-dev` after. The client arrives as a
  connection request named by Claude Code's own `clientInfo.name`.
- **QUESTIONS at merge** — the PROVISIONALs above: P-13nb-U1-1 … -12 (the
  grammar's edges, the caps, the pane's place, the Debug registration
  name, the U1 sheet's scopes, the U1-true sentence, the AF-1 length
  guard), plus R-13nb-1's ratification record.
- **The closeout ritual line** (ledger row 11): re-verify probe (a) — a
  launchd-vantage process connecting into the app's container — after each
  macOS point release.
- **A-4's honest boundary** (ledger row 6) holds as built: any local
  process that names itself as an approved client inherits its grants.
- **Not built, deliberately:** a notarized Release shim run; a
  `Tools/WalkKit` helper for the scripted MCP client (mine lives in the
  session scratchpad — `mcpclient.py`, 40 lines; the live round uses
  Claude Code itself).

### Self-assessment (the implementer's, before the cold review)

- **The boundary is one pure function, tested hard.** `MCPGrantRule`
  decides every call against facts read in the call's own write
  transaction; its sweep covers 13,824 single-grant worlds against four
  stated invariants, and four deliberate boundary breaks were each caught
  (rule and server mutation checks recorded above). The server adds no
  decision of its own — the catalog's listing rule is a courtesy, every
  tool re-asks the rule.
- **Where I'd look first, as the reviewer:** (a) `MCPReadTools.sharedPage`'s
  multi-source merge (each source keyset-paged by the same cursor, merged
  and cut — I believe it pages exactly, but it is the subtlest code);
  (b) `search`'s post-filter (a full page of out-of-scope hits returns few
  passages with `truncated: true` — honest but thin); (c) a once grant is
  never shown by search (a deliberate restriction — P-13nb-U1-2's spirit);
  (d) the transport's 16 MiB line cap and the host's accept loop on stop;
  (e) `MCPDoor`'s off-main start and its in-flight guard (the one place
  with concurrency choreography in the app half).
- **What the walk caught that the pins did not:** four pane defects (the
  clipped command, the receipt below the fold, a wrong-sounding empty
  line, "while connected" offered to an unconnected client) — all fixed
  and pinned where pinnable. The headless and socket-level pins caught
  nothing the walk later contradicted.
- **Scope held:** zero lines in `Sources/VariorumCore/Sync/`, zero
  custody/keychain code, zero editor seam, zero synced-schema change
  (marker 12), the export never writes a row (it strips a copy), the SDK
  linked by the Mac app alone.

### Machinery notes

- The orchestrator committed into this same worktree three times mid-unit
  (`e3a77016`, `763ee91d`, then `5454fc25`); each was a clean, deliberate
  plan-file commit (never a twin implementer) — I pulled with
  `--autostash` and kept my commits to my own paths.
- No session death. One mis-claim in a commit message (`14763773` named a
  pin its edit had not landed) was corrected by the next commit
  (`9afd3456`).
- TCC on this machine: this session's host holds Accessibility and Screen
  Recording (checked before the walk); no TCC prompt was raised or
  answered by any probe or walk step.

## U1 LIVE ROUND (orchestrator, 2026-10-09 — the acceptance's real-client leg; stage held and released)

Run on the dev-store Debug build (fresh branch build `vx124-u1-liveround`,
codesign clean) with a REAL Claude Code client (`claude -p`, throwaway
`-s local` registration in a scratch folder, removed after; her
`~/.claude.json` user scope untouched). Every step live, in order:

1. **The honest refusal, through the real client:** with the server off,
   `claude mcp list` rendered the shim's refusal VERBATIM — "-32000:
   Variorum must be open: its MCP server is not running. Open Variorum,
   turn on Settings ▸ MCP ▸ Enable the MCP server, then reconnect."
2. **The toggle:** Settings ▸ MCP read the R-13n-5 register at rest;
   enabling it bound `Data/mcp.sock` (srw------- 0600) in the container.
3. **Pending reads nothing:** the first Claude Code contact saw ZERO
   variorum-dev tools; the pane showed "Connection request — claude-code
   · First seen 5 seconds ago. No access until approved."
4. **The grant sheet (A-9's U1 form):** Approve… offered where (book —
   "o ladrão de raios" — / wing), read-only with "Suggest, write new and
   edit arrive in a later update.", once/always — and "while connected"
   correctly WITHHELD from a disconnected client (the walk fix, live).
   Confirm spoke the grant in words: "Grant read in “o ladrão de raios”
   always."
5. **Reads within the grant:** a second real session saw the five read
   tools; `list_books` returned ONLY the granted book; `list_notes` its
   four notes; `read_note` spoke the Level 0 format (microsyntax header +
   Alternates sections); `search "semideus"` returned passages from the
   granted book only (incl. its own chapter heading — in-scope).
6. **Refused past it:** the open `list_notes` returned the grant's
   extent and NOTHING outside (no leak); a foreign-id `read_note` got the
   ONE answer, verbatim: "That note isn't shared with this client, or
   doesn't exist. The author can share it from Variorum ▸ Settings ▸
   MCP." — unshared and missing indistinguishable, no existence oracle;
   no road exists to name an outside note by title.
7. **Lifecycle:** quit unlinked the socket; the pane's Shared with AI
   row read "o ladrão de raios · book · claude-code · read · always".

**VERDICT: U1's acceptance bar is MET live** — a real Claude Code session
on the dev store read a granted book and was refused past it; the refusal
is pinned in `MCPServerTests` (the implementer's ten end-to-end pins).
Dev-store residue left deliberately: the approved `claude-code` client +
its always-read grant (useful to the ladder and U2's walks). The
orchestrator's round report: the scratch folder's `round-report.txt`
(ephemeral; this section is the record). Next: ladder round 1
(`fable-reviewer`).

---

## THE U2 IMPLEMENTER BRIEF (self-contained; the spawn names this section)

You are the U2 implementer for Variorum phase 13n-b, working in
`~/dev/variorum-vx-124` on branch `vx-124-13n-b` (NEVER the main
checkout). Commits say `Part of VX-124`, no attribution trailer, push
after every commit. `notes/SessionResiliencyProtocol.md` binds you: LIVE
STATUS in the "U2 UNIT RECORD" section below from your first commit,
foreground waits only, at most ONE read-only Sonnet for external facts
(you likely need none). Baseline (the v1_25 commit's run, `304b41d1`):
core 2,511/287 · VariorumMCPTests 23/3 · workbook 40/6, headless.

**Read first (never delegated):** this plan file TOP TO BOTTOM — the
ruled design, ARCHITECT SEAM RULINGS A-1…A-10, the SITTING RECORD
R-13nb-1…6, THE PRIVATE MARK design addendum, the environment traps;
the sitting record file (R-13n-1…11, esp. R-13n-4/6 and P-13n-1/3); the
mockups (§3 the grant sheet, §4 the just-in-time ask, §5 AI in the fan,
§7 the grant in context); both ladder records
(`13nb-u1-ladder-round{1,2}.md` — U1's shapes and the standing NITs).
Code: `Domain/MCPGrantRule.swift`, `Queries/MCPGrantQueries.swift`
(`mcpNoteFacts` — the fence's one derivation site, its Private leg a 0
fragment awaiting your wiring), `Operations/Operations+MCPGrants.swift`,
`Sources/VariorumMCP/` (the catalog/tools/authority split),
`Features/MCP/` (the pane + U1 grant sheet), and the structural-undo
registration road (how her own gestures register — AppSpec §9's
structural undo block; find the ONE road and use it).

**What U2 builds:**

1. **The fence's third leg, wired + pinned:** `mcpNoteFacts`' Private
   fragment reads the v1_25 columns (own `ai_private_at`, and any LIVE
   membership in a LIVE reading with `ai_private_at` set). Pins: NULL
   reads not-private; a note in a private AND a granted book is fenced
   (privacy wins ties); marking while a client is connected fences the
   very next call; archived private books still fence (the journal leg's
   precedent).
2. **The mark's operations + faces (R-13nb-4):** set/clear ops for note
   and book (no-op-guarded identity-level metadata; gatherings refuse
   `wrongReadingKind`; allowed under a seal — protective, not authoring
   — PROVISIONAL, log it); the book settings sheet row and the note ⋯
   menu row, "Private — never shared with AI" (app voice, sentence case,
   registry-declared); the ask sheet's private wording (the journal
   sentence's twin, sweepable at 13s-a).
3. **The SUGGEST rung:** `add_take` (fan's END, labeled per P-13n-3's
   convention + the client's own label, never chosen, never locked),
   `add_comment`, `save_lens`. THE PROOF PIN (the verification bar's
   heart): a suggest grant PROVABLY cannot modify an existing take —
   pinned like any refusal, plus the mutation-check discipline U1 set.
4. **The WRITE-NEW rung:** `create_note`, `import_document` (payload =
   the Level 0 format through `Domain/VariorumDocument` + the 13n-a
   import ops; ONE compound undo entry — R-13n-6), `apply_tag` (the ONE
   application road so living books hear it), `create_book`,
   `add_note_to_book` (through `addPostToReading`'s gates — ownership
   refusals speak to the client as to her). Scope discipline: creative
   acts land INSIDE the grant's scope only (a book grant creates in that
   book; a wing grant in that wing); every refusal is the operations
   layer's own.
5. **Undo per act (R-13n-6):** every MCP write registers structural
   undo exactly as her gestures do — one entry per act, the bulk door
   compound; ⌥⌘Z in the app walks an AI session back. Her words carried:
   "undoing AI writing … in a single command."
6. **The grant sheet grows rungs (A-9's growth):** read · suggest ·
   write new with the mockup §3 sentences (the EDIT row arrives with U3
   — a rung the server can't serve isn't offered, P-2); the just-in-time
   ask sheet (mockup §4: once · while connected · always · don't allow;
   "while connected" only for a connected client — U1's rule carried;
   a FENCED target never offers "always" — and fix R2-1 here:
   `offersAlways: facts?.fence == nil` at MCPReadTools.swift:351).
7. **Receipts + the shared chip:** quiet receipts in the app's voice for
   AI acts (P-13n-1's boundary; e.g. the mockup §5 line), the
   "shared with AI" chip on granted book rows + the note face
   (P-13n-3's wording, hers to re-voice at 13s-a).
8. **Ledger row 10 — adoption lands OFF (R-13nb-6):** the one
   toggle-OFF write on the 13x adoption road (grants kept; the
   export-rebuild already lands empty+OFF). If ANY line falls inside
   `Sources/VariorumCore/Sync/`, STOP and message me the exact lines
   (AF-4) — expected home is the adoption/binding seam outside Sync/.
9. **R2-2 (optional, rides a touch):** if your rung work touches
   `search`'s argument parsing, align the paired-ids refusal with
   `list_notes`; otherwise leave recorded.

**Must NOT touch:** `Sources/VariorumCore/Sync/` (AF-4 — mine),
custody/keychain, the editor seam, the real store, `/Applications`, the
mirror artifact (16 is written; the deploy is HERS). The marker is
already 13 client-side — do not touch `lockstepVersion`. Nothing may
assume the client is external (R-13n-1). The export pin stands.

**Acceptance (use-shaped, the plan's):** her fact-check shape LIVE on
the dev store — a real client reads a granted note, lands a take beside
every block (labeled, never chosen), saves a lens; ONE ⌥⌘Z press in the
app walks the last act back (and the bulk import undoes in one). Plus
the suggest PROOF pin and the Private pins above. The live leg runs
with me under a held stage claim — your walk drives the scripted client
as U1's did; tests at the unit's END.

**Forks:** anything beyond the recorded rulings returns to me with a
proposal before building that half; PROVISIONAL-and-log for non-gating
ambiguity; STOP for anything gating.

---

## U2 UNIT RECORD (LIVE STATUS — the implementer owns this section from its first commit)

**UNIT CLOSED by the implementer — NOT DONE: (1) the LIVE acceptance leg
with a REAL client (her fact-check shape over Claude Code + the ⌥⌘Z walk —
the orchestrator's, under a held stage claim; my pre-flight drove the REAL
embedded shim with a scripted client, `u2-walk`, never Claude Code itself);
(2) the whole VariorumTests target (only the 27 suites in every file the diff
touches ran); (3) the U3 items AF-8 and R-13nb-7/8/10 assign there (the
"Allow AI here…" row, `with_commits`, `include_commits`, the set-name tool) —
the structured serializer and search's argument parsing are left open for
them; (4) the pre-existing red `BookCollectingDoorsTests
.theSettingsDoorIsOneActOnBothRoads` (13o U3's `90c081c4` added
`.searchThisBook` to `BookView.surfaceCapabilities`; the pin was never
updated; both files untouched by U2 — an orchestrator item / ticket, not
fixed out of scope).** Session: opus-implementer, 2026-10-09, cut from
`b6815271`; closed at the commit carrying this record.

### Pieces

| # | Piece | Status |
|---|---|---|
| Q0 | This record | DONE (`90797596`); forks RULED by the architect (AF-5…AF-8, `d290b090`) |
| Q1 | The fence's third leg wired (`privateLegForNote`/`ForBook` read v1_25) + pins (NULL not-private; private+granted book fenced; mark fences the next decision; archived private book fences) | DONE (this commit) — `MCPPrivateMarkTests` 6/6; RED-ON-OLD verified: with the legs back at `"0"` the suite fails 4 tests / 10 issues, green after; U1's placeholder assertion retired (justified edit). The end-to-end "next call on a connected client" pin rides Q6 (`MCPServerTests`) |
| Q2 | The Private mark's ops (`setNotePrivate` / `setBookPrivate`; gatherings and scraps refuse; allowed under a seal — PROVISIONAL) + state-transition tests | DONE (this commit) — no-op-guarded, no touch, synced (outbox), no undo entry |
| Q3 | The Private faces (book settings row, note ⋯ row, registry-declared) + the ask's private wording | DONE (`b83e7c60`; Mac green — see Q10; walked, captures 10–16, 23) — `.markNotePrivate` (`.bottomBar`, both bars' note ▾, NOTE contexts, beside Copy full text: the toggle + "Private through “…”" when a Private book holds it + the note's "Shared with AI: …" line) and `.markBookPrivate` (the Book Settings sheet's State row + caption, books only); shared pieces in `Core/Views/PrivateMark.swift`; the ask sheet's Private lead (the journal sentence's twin); the stamp stays OFF the `Reading`/`Container` models (no stale model write can clear it) |
| Q4 | Ledger row 10 — adoption lands MCP OFF (R-13nb-6) | DONE (this commit) — `landMCPAfterAdoption(holdStamp:)` keyed on the 13x RESTORE HOLD both adoption doors write (fresh stamp per adoption): an unacknowledged hold writes `server` OFF + records the stamp in ONE transaction; the same hold again changes nothing (her re-enable stands); a new adoption lands OFF again; grants/clients/open book untouched. The door asks it at attach BEFORE its grants observation starts (no stale "on" snapshot can start a server); a failed landing keeps the server down. Zero lines in the 13x road itself, zero `Sync/`, zero custody. Headless `MCPAdoptionLandingTests` 2/2; Mac pin `anAdoptedLibraryLandsOffBeforeItCouldServeAndHerReEnableServes` GREEN (its first run tripped AF-1's length guard on the test's own nested socket path — fixed in the test, `20e319ad`) |
| Q5 | The core write ops with per-act undo (add take · comment · lens · create note · import · apply tag · create book · add note to book) + tests | DONE (this commit) — `Operations+MCPWrites.swift`: each act ONE transaction (the import book: one compound) + ONE entry labeled "<client>'s <act>", exact-row inverse + redo (quiet on divergence, throwing on resolvable refusals); the suggest acts INSERT only (no UPDATE on `variant`/`container_block`). `mintDocument`/`applyDocumentTags` widened private→internal (the one mint road reused). `MCPWriteActsTests` 12/12 |
| Q6 | The server's write tools over the SESSION runner + the SUGGEST PROOF pin (+ mutation checks) | DONE (`296e9c86` + `0f5f406c` + this commit) — `MCPWriteTools` (8 tools, one serial body per call on the injected executor), `MCPWriteSupport`, the catalog's `scopes` rule, `read_note with_ids` (AF-5), asks on content reads and write refusals (AF-6), AF-7 wired, R2-1 + R2-2 fixed. `MCPWriteServerTests` 9 + U1's 23 = **VariorumMCPTests 32/4**. **THE PROOF MUTATION-CHECKED (4 breaks):** (1) `addTake` also edits her other takes → caught (snapshot); (2) `saveLens` moves the chosen pointer → **NOT caught by the first draft** (it picked only already-chosen takes, so the move was a no-op) → the pin now picks her NON-chosen take → caught; (3) the block acts decided at `.read` instead of their rung → caught (the write-new door accepted under suggest; the once grant not spent); (4) `addTake` makes itself chosen → caught (snapshot + the fact-check shape's rendered text). Every mutation restored from the committed tree (`git checkout --`) |
| Q7 | The grant sheet's rungs (read · suggest · write new) | DONE (`b83e7c60`; walked, captures 03, 21) — the radio picker with the mockup §3 sentences, the confirm naming the rung ("Grant suggest in “…” while connected"), "Edit arrives in a later update."; the pane's toggle sentence restored to mockup §1 verbatim (P-13nb-U1-12 retired) |
| Q8 | The just-in-time ask (sheet + the R2-1 fix) | DONE (`b83e7c60` + W-3 `b81868cc`; walked, captures 08/09/11/16/17/22) — `MCPDoor`'s in-memory queue (deduped per client · target · rung, cap 8 — the oldest WAITING ask forgotten, never the one on screen), `MCPAskSheet` on the main WindowGroup (one at a time; Once · While connected [connected only] · Always [unfenced only] · Don't allow = its cancel action; the answer mints the grant through `grantMCPAccess`), `.mcpAnswerAsk` declared + walked; R2-1 fixed in Q6 |
| Q9 | Receipts (app voice) + the "shared with AI" chip | DONE (core reads `081792a5`; faces `b83e7c60`; W-1/W-2 `508136d4`; walked, captures 01/05a/06/07/09/12/18/19/22) — `MCPReceiptCopy.line` (a run of one client's acts on one target within 120 s coalesces: "claude-code added 2 takes and saved the lens “fact check” · ⌥⌘Z undoes"; past a 72-char budget the run speaks as a count so the undo hint is never truncated — W-2), spoken by `MCPDoor.speak` as quiet receipts; the Bookcase row's "shared with AI" chip from `mcpReachableBookIDs` (one-shot with the row aggregates) |
| Q10 | End of unit: headless suites, Mac focused suites (stage), the pre-flight walk (stage), record final | DONE — headless whole package: core **2,534/291** (baseline 2,511/287 + 23 tests / 4 suites: `MCPPrivateMarkTests` 6, `MCPAdoptionLandingTests` 2, `MCPWriteActsTests` 12, `MCPGrantInContextTests` 2, + the AF-7 rule test in `MCPGrantRuleTests`), **VariorumMCPTests 32/4** (U1's 23 + `MCPWriteServerTests` 9), workbook **40/6**; only the long-standing gated skips. Mac (stage held, `-only-testing`, every suite in every file the diff touches): **179 tests / 27 suites, 0 skipped, ONE red — pre-existing and outside U2** (the BookView pin, banner item 4); `MCPPaneTests` + `MCPAskAndReceiptTests` 19/19 after the walk fixes. The pre-flight walk below (23 captures + the client transcripts) |

### Forks returned to the orchestrator (2026-10-09) — RULED as AF-5…AF-8 (`d290b090`), built as ruled

- **F-1 — block addressing.** `read_note` speaks the Level 0 format, which
  carries NO ids, so `add_take`/`add_comment`/`save_lens` have no way to name
  a block or a take. PROPOSAL: `read_note` gains an optional `with_ids: true`
  answering JSON — `{note_id, title, blocks: [{block_id, text (the shown
  take), takes: [{take_id, label, chosen, text}], comments: [{id, text}]}]}`
  (the mockup §9 contract already says read_note returns "blocks, takes,
  comments"); the default answer stays the Level 0 text byte-for-byte.
  Alternatives: (b) address by block INDEX + `expected_text` (fragile — a
  multi-paragraph block is not expressible in the format, P-13n-4, and a
  divide by her mid-session shifts indices); (c) a new `list_blocks` tool (a
  sixth read tool beyond the ruled lean set).
- **F-2 — the just-in-time ask's call semantics.** PROPOSAL: the call NEVER
  blocks — it answers at once, and for an approved client asking past its
  grant on an EXISTING target the app queues an ask (in memory, deduped per
  client · target · rung, capped), presented as the mockup §4 sheet on the
  main window one at a time; her answer mints the grant (once · while
  connected [connected clients only] · always [never on a fenced target] ·
  don't allow = nothing). On the wire: `notShared` keeps the one-answer
  words unchanged (no existence oracle — the client cannot tell an ask was
  raised); `rungTooLow` and `fenced` (whose existence the client already
  knows) gain "Variorum has asked the author — call again once she answers."
  Why not blocking (TCC-literal): a blocked call is a LATENCY existence
  oracle (missing ids answer instantly, real ones hang), and it holds the
  client's tool timeout hostage to her attention.
- **F-3 — "once" on the write rungs.** U1's P-13nb-U1-2 spends a once grant
  on the first CONTENT READ. Carried literally to writes, a "suggest, once"
  grant is spent by the read the client needs before it can suggest — a door
  that cannot act as named. PROPOSAL: a once grant is spent by the first call
  AT ITS OWN RUNG it authorizes (read: a content read; suggest/write new: the
  first write); lower-rung calls under it (the reading it needs on the way)
  ride free. One line in `MCPGrantRule.decide`, pinned. Alternative: spend on
  any content-bearing call, reads included (literal; makes once-at-suggest
  nearly useless).
- **Scope question (not a fork):** the note ⋯ menu's GRANT row ("Allow AI
  here…", R-13n-11's share-a-note) is not in U2's item list (only the Private
  row is) — read as U3's unless told otherwise.

### PROVISIONALs (for the merge QUESTIONS bundle)

- **P-13nb-U2-1 — the mark is ALLOWED under a seal, on a finished, sealed
  or archived book, and on an archived note.** It protects rather than
  authors (withholding a note from AI writes no word of it). Alternative:
  refuse under a seal (the comment/label letter).
- **P-13nb-U2-2 — the mark does NOT ride a copy.** A copy is a new note
  (the Owned/seal precedent: copies are born open and unowned); the copy
  doors are several (`copyPost`, the ownership family copy, versions, the
  wing copy) with no one choke point. A copy filed into a Private book is
  fenced by membership anyway. Alternative: every copy door carries the
  stamp (the safe direction for disclosure; four sites).
- **P-13nb-U2-3 — a grant on a target that becomes Private stays as DATA**
  (inert while marked — `reaches` never matches a fenced book, and only a
  per-ask note grant reaches a fenced note); clearing the mark reopens it
  (pinned). The faces must not call such a grant "shared" while it is inert.

- **P-13nb-U2-4 — EVERY MCP write registers an undo entry, the comment,
  tag, lens and book acts included** (her own gestures for those stay
  outside the stack, AppSpec §9) — R-13n-6's "every MCP write" read
  literally; separate entry points, her doors unchanged.
- **P-13nb-U2-5 — the undo labels** read "<client>'s take / comment / lens
  / note / import / book import / tag / book / add to a book" ("Undo
  claude-code's take", "Undid: claude-code's take") — app voice, 13s-a
  sweepable (P-13n-1's boundary).
- **P-13nb-U2-6 — undoing an AI tag removes the APPLICATION only**: a seat
  the tagging caused in a living book stays (un-tag is a non-event for
  intake, §19), and a tag the act minted stays as vocabulary (13n-a's
  precedent).
- **P-13nb-U2-7 — an AI take is PARENTLESS** (a fresh text, not a branch
  of hers) and fan growth's conventions ride: no touch, no churn — an AI
  session never reshuffles her library's sort.

- **P-13nb-U2-8 — a CRASH between a landed write and its once stamp**
  leaves the once grant unspent (one more write possible); the content
  reads keep U1's one-transaction stamp. Inside the serial body nothing
  else can interleave, and a spend never flips a landed act's answer.
- **P-13nb-U2-9 — the ask queue's shape** (AF-6 marks it PROVISIONAL):
  in memory, deduped per client · target · rung, cap 8 (the oldest waiting
  ask forgotten — never the one on screen); the sheet ARRIVES on the main
  window (the mockup's "arrives as a quiet sheet in the TCC shape"), one at
  a time; with several main windows open each presents it (the
  library-open sheet's standing class). Alternative: an offer toast with
  Review… (calmer, missable). And AF-6's other provisional: an ask IS raised
  on an existing-but-unshared note while the wire stays the one answer.
- **P-13nb-U2-10 — the receipt run** (AMENDED by the walk's W-2): one
  client's acts on one target within 120 s speak as one coalesced line in
  the mockup §5 shape (no "in “title”" clause — the first build's clause
  pushed the undo hint off the bar); past a 72-character budget (measured at
  the walk's 1380-pt window; the bar's width varies, so approximate) the run
  speaks as a count: "<client> made N changes · ⌥⌘Z undoes".
- **P-13nb-U2-11 — the "shared with AI" chip is HONEST under every grant
  shape**: a book chips when any approved client can reach it now (a book
  grant, a wing grant on its wing, or the open book — never a journal or a
  Private book), not only under a grant naming it. The note's face is the
  note ▾ menu's "Shared with AI: <client> (<reach>)" line.
- **P-13nb-U2-12 — the AI take label**: "<client> · suggested", then
  " · <its own label>" when it gives one (P-13n-3's convention, the client's
  name verbatim — "claude-code", never a brand rewrite).

- **P-13nb-U1-2's AMENDED FORM (AF-7, for the merge bundle):** a once
  grant is spent by the first content-bearing call AT ITS OWN RUNG it
  authorizes — read: the first content read (U1's letter); suggest / write
  new: the first WRITE; lower-rung calls under it ride free. Stated edge: a
  once-suggest grant authorizes ONE write (take-plus-lens wants "while
  connected"). Walked live: Once allowed exactly one `create_note`, the
  second refused and asked again (captures 08/09).
- **P-13nb-U2-13 — the ask sheet uses SYSTEM buttons** (walk W-3): it
  presents at the WindowGroup level where no session theme reaches (the
  library-open sheet's precedent); the voice's chrome is the grant sheet's
  and the pane's, not this sheet's.

### Decisions within the mandate (recorded as they land)

- **MCP writes run on the SESSION's `OperationsRunner` with the session's
  `UndoStack`** — the one road her gestures use. Not optional: `withCompound`
  holds ONE collector, so an MCP compound collecting concurrently with one of
  her gestures would swallow her entry (or trip the no-nesting precondition);
  the runner is the serialization guard the stack requires. The host gains an
  injected executor (the app's runner; a serial actor in tests); reads stay on
  the reader pool as U1 built them.
- **R-13nb-8's U2 half + R-13nb-9 built** (`4ee882f7`): `with_ids` carries a
  block's `name` where set (metadata only — ids stay the one write address);
  the tool description says ids are live (her merges/divides mint new blocks;
  a stale id refuses; a re-read recovers).
- **The stamp stays OFF the models.** `ai_private_at` is read and written by
  SQL only (`Queries.isNotePrivate`/`isBookPrivate`, the two ops) — GRDB's
  `update` writes only encoded columns, so no stale `Container`/`Reading`
  can ever clear a mark, and no copy road silently starts carrying it.

### The U2 pre-flight walk (dev-store Debug build `DerivedData/vx124-u2`, 2026-10-09 ~17:10–18:00, under my own stage claim — the orchestrator's live real-client round is still owed)

Captures (gitignored): `notes/plans/13n-b-screens/u2/01…23-*.png`; the
scripted client's transcripts + the 60-line client itself:
`notes/plans/13n-b-screens/u2/client/` (`mcpwalk.py` spawns the REAL embedded
shim over stdio exactly as Claude Code does; self-named `u2-walk`). Author
guard + per-click guard (`Tools/WalkKit/click.sh`) throughout; her
`/Applications` app never running; my instance quit by identity each time.

- **01** Study Bookcase: "shared with AI" on "o ladrão de raios" (the live
  round's standing `claude-code` read grant). **02** the pane running, the
  toggle sentence mockup §1 verbatim. `u2-walk` connects → pending, ZERO
  tools, reads nothing. **03** Approve… → the sheet's three rungs; Suggest →
  the mockup sentence + "Grant suggest in “o ladrão de raios” always".
- **Her fact-check shape (headless client, real shim):** `list_books` → the
  one book; `read_note with_ids` → 3 blocks, live ids; `add_take` ×3
  (label "fact check"); `save_lens` "fact check". **04** Takes, expand all:
  "u2-walk · suggested · fact check" at each fan's END, her "✓ chosen"
  untouched.
- **05a (W-2 before)** a coalesced receipt truncated, the "⌥⌘Z undoes"
  clause lost. **06** ONE ⌥⌘Z → "Undid: u2-walk's take" — the client re-read
  confirms exactly that take gone; **07** two more presses walk back the
  comment, then "Undid: u2-walk's lens" (the earlier takes stand).
- **The ask:** `create_note` past the suggest grant answered in 0.32 s —
  "This client may only read and suggest here. Variorum has asked the author
  — call again once she answers." — and **08 (W-3 before)** the sheet
  arrived: "u2-walk asks to write new in “o ladrão de raios”", Once ·
  Always · Don't allow ("While connected" withheld — disconnected). Once →
  **09** "Allowed u2-walk: write new in “o ladrão de raios” once."; the retry
  landed the note at the book's end; the SECOND write refused and asked
  again (AF-7 live); Don't allow → nothing more landed.
- **Private:** **10** the note ▾ menu: "Private — never shared with AI"
  beside Copy full text, under it "Shared with AI: claude-code (read),
  u2-walk (read and suggest)". Marking it → the client's VERY NEXT
  `read_note`/`add_take` refused with the Private words, `search` dropped the
  note's passages; **11** the Private ask (Once only), **12** "Marked Private
  — no AI client can read this note.", **13** ✓ and the shared line gone;
  cleared → the client reads again. **14/15** Book Settings' State row + its
  caption, checked → `list_books` empty, members fenced; **16** the book's
  chip GONE (honest) and the queued ask presented once the sheet closed;
  cleared → lists again.
- **The bulk door:** `import_document` of a whole book into Home → the ONE
  answer on the wire ("That wing isn't shared…") while **17** her sheet asks
  "u2-walk asks to write new in the Home wing" (AF-6's provisional,
  visible); Once → **18** "percy worksheets · 3 notes · 1 ch" + "u2-walk
  imported the book “percy worksheets” (3 notes) · ⌥⌘Z undoes" (whole);
  **19** ONE ⌥⌘Z → the book gone, "Undid: u2-walk's book import".
- **Terminal voice:** **20** the pane (W-1 fixed), **21** the sheet's Write
  new sentence + "Grant write new in “…” always", **22** the ask with system
  buttons (W-3 fixed) over the chip in mono, **23** the note menu. Voice
  restored to Study.

**The walk's three findings — all FIXED and pinned where pinnable:**
1. **W-1** — the client row said "reads 1 shared place" for a suggest
   grant → rung-agnostic "1 shared place" (`508136d4`).
2. **W-2** — the coalesced receipt truncated and lost "⌥⌘Z undoes" → the
   mockup's shape without the title clause + the count fallback past 72
   chars (`508136d4`; pinned in `MCPAskAndReceiptTests`).
3. **W-3** — the ask sheet's buttons in the mono fallback face (no theme at
   the WindowGroup level) → system buttons (`b81868cc`).

**LEFT in the dev store (deliberate, harmless):** the `u2-walk` client
(approved; suggest on "o ladrão de raios", always); the three "u2-walk ·
suggested · fact check" takes on "abertura"; the note "lesson 1 — questions"
in that book. `claude-code`'s always-read grant untouched (the live round's
client). Server ON, voice Study.

### Open items for the orchestrator

- **The live acceptance leg** (her fact-check shape with a real Claude Code
  client + the ⌥⌘Z walk): register the Debug shim (`-s local` in a scratch
  folder, as U1's round), approve suggest on a book, have the client
  `read_note with_ids` → `add_take` per block → `save_lens`; press ⌥⌘Z once
  in the app. The Takes view + the receipt are where to look.
- **QUESTIONS at merge:** P-13nb-U2-1…13 + P-13nb-U1-2's amended form.
- **The pre-existing red** (banner item 4) — a one-line pin update, not U2's.
- **Not built, deliberately:** pane rows for pending asks (AF-6 optional —
  U3's if wanted); the "Allow AI here…" row (AF-8, U3).
- **Rulings that landed DURING this unit and were not routed to it**
  (R-13nb-11…18 + the wire-document memo `67536839`; the orchestrator's
  last direction to me: "everything else is U3's"). One touches what U2
  built: **R-13nb-11 G-2** — `create_note` accepts EITHER payload (the text
  format OR a wire-document subset). U2's `create_note` takes PLAIN PROSE
  through the bulk rule (`Operations.createNote` →
  `SegmentationRules.bulkSegments`); the Level 0 text goes through
  `import_document`, and the wire-document subset awaits the format-schema
  sitting (R-13nb-13). For U3's brief: the op seam is ready
  (`Operations.importNote(_:in:undoLabel:)` already mints a parsed
  `VariorumDocument` into a book or a wing under one entry — an
  either-payload `create_note` is an argument-parsing change over it).
  R-13nb-18's `save_version` (write-new rung, staging-timed) and its "the
  wire has NO undo tool" both agree with what is built (no undo tool exists).

### Self-assessment (the implementer's, before the cold review)

- **The suggest PROOF is real and mutation-checked** — and the check earned
  its keep: the first draft of the pin could not see a lens that moved the
  chosen pointer (it only picked takes already chosen). Four deliberate
  breaks, four catches after the fix.
- **Where I'd look first, as the reviewer:** (a) `MCPWriteTools`' serial
  body — decide on a reader snapshot, act through the runner's ops, spend
  AFTER the act, log; especially `noteIntoBook`'s shared-once-grant spend
  and `land`'s `try? spend` (P-13nb-U2-8's corner); (b) the undo halves in
  `Operations+MCPWrites` (`revertAddedMembership`'s arrival restore,
  `reapplySavedLens`' exact-stamp choice revival, `reapplyAppliedTag`'s twin
  guard); (c) `MCPDoor`'s adoption landing ordering (the observation starts
  only after the OFF write) and its ask queue (`enqueue`'s cap never drops
  index 0); (d) the scope discipline — can any write land outside the grant
  (a note into an ungranted book, an unreachable note pulled into a granted
  one, a take on a block of another note)? (e) the ask-on-unshared-existing
  behaviour (AF-6's provisional) — no wire oracle, but her sheet names a
  note the client could not list.
- **What the walk caught that the pins did not:** W-1/W-2/W-3 — all three
  are rendering facts (copy accuracy, bar width, the theme environment at
  the WindowGroup level) no headless pin sees.
- **Scope held:** zero lines in `Sources/VariorumCore/Sync/`, zero custody,
  zero editor seam, zero lockstep (marker 13 untouched), zero changes to the
  13x adoption road itself (row 10 lands at the door's attach, keyed on the
  hold that road already writes), the export pin intact.

### Machinery notes

- The orchestrator committed into this worktree mid-unit (the fork rulings
  `d290b090`, the sitting records `508d3f6b`/`ae5dd44f`) — pulled, read, kept
  to my own paths. No session death. The stage was claimed once (120 min)
  and released at the end; TCC on this host: Accessibility + Screen
  Recording held (checked before the walk); no prompt raised or answered.
- One harness lesson: `click.sh`'s author guard refuses a click within 2 s
  of my own previous synthetic event (HID idle) — a "lost" click mid-walk was
  the guard, not the app.
