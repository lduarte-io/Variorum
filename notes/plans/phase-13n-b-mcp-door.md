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
  **AF-7 AMENDED (architect, 2026-10-09 — at the U2 ladder's F4, before
  dispositions):** the ride-free clause covers READS ONLY. The letter as
  first written let a once WRITE-NEW grant make unlimited SUGGEST-rung
  writes "riding free" below its rung — never the intent. Amended rule:
  a once READ grant is spent by its first content read (unchanged); a
  once WRITE grant (suggest or write-new) is spent by its FIRST WRITE of
  ANY rung it authorizes — content reads on the way ride free, writes
  never do. One write means one write. Pinned both ways at the fix; the
  P-13nb-U1-2 amended-form record carries this second amendment for her
  ratification at the merge.
- **AF-9 — among equal durations, the call spends the LEAST capability
  that suffices (architect, 2026-10-09 — the U2 sanity pass's O2;
  PROVISIONAL class, hers to veto in a word).** F4's fix made WHICH
  once grant is spent matter for the first time, and `best()` broke
  duration ties by smallest id — deterministic but arbitrary: a
  once-write-new grant could be consumed by a suggest-level write while
  a once-suggest grant sat unspent. Ruled: among sufficient grants of
  equal duration class, prefer the LOWEST RUNG that suffices, then the
  NARROWEST scope (note < book < wing), then the smaller id (pure
  determinism last). Standing-before-once is untouched (its pin
  stands). The implementer's option (a), its own lean, accepted; one
  comparator + pins, the ORCHESTRATOR'S OWN small fix (the architect
  mandate's small-code allowance) so round 2's fresh reviewer covers
  it. N1 (four stale "at its own rung" comments) rewords in the same
  pass.
  **Round-2 consequences, stated for her ratification (the U2 ladder
  round 2, R2-F2):** the preference is PER DECISION, so a two-sided act
  (`add_note_to_book`) holding a once NOTE grant beside a once BOOK or
  WING grant now deterministically spends BOTH — the note side picks
  the narrower note grant, the book side the wider one — where the old
  id coin-flip sometimes picked the wide grant for both sides and the
  Set dedupe spent ONE. And on a content READ where a once READ grant
  and a once WRITE grant both reach, the read grant is picked and SPENT
  though the read could have ridden free under the write grant —
  lowest-rung-first's letter. Neither direction over-reaches (each
  spent grant authorized exactly the call made; the burn direction is
  conservative — less capability left standing afterwards).
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

## ARCHITECT RULING ON THE U3 FORK (AF-10, Fable, 2026-10-10 — the glyph/token/grammar + the seven build calls, `96464a79`'s proposal)

- **THE MARKER: `--- next block ---` APPROVED** — the format's own
  marker idiom (the Alternates family), hard-wrap-safe, CommonMark-inert
  (letters inside disqualify thematic break and setext alike, so
  markdown viewers render a plain line), collision-free in practice
  with the escape rule below. The invisible `<!-- -->` alternative
  REJECTED for the implementer's own reason: an invisible structure
  line misleads anyone editing the rendered view, and it breaks the
  marker family.
- **THE TOKEN: `{v:2}` APPROVED** — first on the braced header, legal
  alone, parser-only (NOT CaptureTokens — capture untouched), absent =
  v1 byte-exact, `{v:1}` read as v1, unknown numbers refuse fail-honest
  with the line.
- **THE GRAMMAR APPROVED as proposed** — marker mode iff some block's
  in-place text holds a blank line with non-blank after (leading blanks
  included: every shape v1 misreads); the join
  `\n\n--- next block ---\n\n`; Alternates unchanged; the
  backslash-stacking escape (export exact, never refusing); lenient
  text-after-section parse; exact-inverse pins; the PLAIN export never
  carries marker/brace/section (pinned — her R-13nb-26(a) refinement);
  exportBlock stays a block-level clipboard face (recorded).
- **The seven build calls ALL CONCURRED:** (a) the in-transaction
  guard RUNG-WIDE — the move_block-out-of-a-fenced-note disclosure
  trace is exactly right; defaulted `guardedBy:` nil on her doors,
  redo never carries it; (b) merge_blocks = her ⌘⇧M default with
  `CarryAllMerge` MOVED to core Domain byte-unchanged — the 3C parity
  pattern BINDS: the app keeps its name compiling (typealias/forward)
  so every existing pin passes UNMODIFIED; divide_block = keep-on-top;
  two blocks per call; (c) the cut addressed by text
  (`second_half_starts_with`, exactly-once) — LLMs miscount UTF-16,
  the expectedText precondition class; (d) with_commits newest-first
  with the 100k-char bound + `commit_ids` fetch (≤20); (e) Allow AI
  here as the approved-clients submenu, read·once on THAT note, fenced
  included (per-ask-legal — R-13n-11's letter), unrendered when none
  (P-2), no ellipsis; (f) book/chapter facts only for readable books
  (names stay with grants) + section facts on list_notes rows;
  (g) the brackets as proposed (kind auto, the client's name verbatim,
  the standing dedupe, one undo entry, touch + churn as any text edit).

## ARCHITECT RULING ON THE U4 FORKS (AF-11, Fable, 2026-10-10 — F-1…F-4, `47ed40cd`'s proposals; the full fork text is the U4 UNIT RECORD's)

- **F-1 RULED (a) — the book-rule write MIRRORS her Save; the brief's
  "refuse as hers do" was MY wrong assumption, corrected to the probe
  facts.** Her ops and her Book Settings ▸ Edit… door LAND rule edits
  on a finished book (13i §5's design: intake paused, un-finish
  catches up), so the wire lands exactly where her Save lands and
  refuses exactly where it refuses — MIRROR, NEVER INVENT (the sealed
  case pinned to the app's ACTUAL door behavior, verified not
  assumed). `set_book_rule` = her rule editor's one Save (optional
  rule · outflow · new_matches, one runner turn, ONE client-named undo
  restoring the three fields; existing seats stay — §19's letter);
  tags named by PATH in the stored grammar keys, a missing path minted
  in the book's wing (the apply_tag/import adopt-or-mint precedent);
  legacy terms refuse on write; a malformed stored rule refuses as her
  editor does; the ANSWER says intake is paused when it is. The walk's
  app-words refusal leg rides the refusal that EXISTS (`lockedReading`
  via create_section / file-into-chapter). (b) REJECTED — a wire-only
  finished/sealed refusal is a new validation path, exactly what the
  brief bans; (c) REJECTED — R-13nb-26 f ruled write in U4, her word.
  **The found J8 defect fix APPROVED:** `lockedReading` has no words in
  OpsRefusalCopy (the wire and every table-routed Mac door speak the
  raw enum today) — her ReadingsViewModel generic sentence joins the
  Mac table, red-on-old pin, recorded as a found-defect fix.
- **F-2 RULED (a) — the lines STAY RECEIPTS and the keyboard road
  outlives the fade.** Her R-13nb-23 (a) letter ("write receipts GROW
  a one-press door") is the authority over 18i's buttoned=offer
  inference: AI write lines remain receipts under `receipt_style`,
  carrying "Open ›" in the quiet line and the toast alike; the
  keyboard road is a registry act "Show the AI's last change" —
  session-scoped (the most recent MCP write's target this session,
  the R-13nb-19 session-bounded doctrine's twin), grey when none,
  ALIVE after the line fades and under receipt_style off (a chord
  racing a 6-second fade would be a lying keyboard road). ⌥⌘O
  approved SUBJECT TO the collision sweep (record the sweep). The 18i
  canon nuance rides the closeout delta as a contract line — **RATIFIED
  by the author 2026-10-10, R-13nb-27 (the section at the file's end)**. (b)
  REJECTED — always-toasting AI writes would outshout her own acts,
  anti-calm; (c) REJECTED — a mouse-race chord is no road.
- **F-3 RULED as proposed — show_in_app.** Decided at READ on the
  TARGET note (a client shows only what it may read); NEVER spends a
  once grant (a show discloses and changes nothing — AF-7's ride-free
  reads cover it a fortiori). Targets as proposed: note(+block_id,
  +select words → the 13o find seed verbatim) · takes(note+block) ·
  lens(note+lens_id → focus its column, else append, else the R83
  swap of the LAST when four are full — PROVISIONAL, logged) ·
  book(+section_id → Outline's chapter landing). Frontmost =
  `NSApp.isActive` AND the key window is a FULL window — a note-only/
  quick-note window key REFUSES and never raises another window; not
  frontmost refuses honestly, NEVER queued (the offer door and F-2's
  chord are the deliberate roads back). The pure decision lives in
  VariorumMCP, pinned headless with a fake hook.
- **F-4 CONCURRED (PROVISIONAL as logged) with ONE RIDER.** The
  carriage rides read_note's structured view as explicit params
  (with_tray · with_lineage · include_archived · with_lenses ·
  with_versions + version_id — the AF-5 precedent); book facts on
  list_books rows; include_archived on list_books/list_notes/search
  defaulting archived-OUT (the app's resting facet posture — the two
  deliberate U1 flips land with pins updated as the ritual; a grant's
  REACH is untouched: an archived book still answers under its grant
  when asked). **THE RIDER — lineage beyond the grant is ONE uniform
  stub:** no id, no title, no kind, nothing that distinguishes a
  FENCED far side from a merely unshared one — PINNED byte-identical
  (the U1 one-answer discipline applied to edges; omission would lie
  about the tree's completeness, a distinguishable stub would open an
  oracle).

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
| 4 | U2 — suggest + write new + the grant sheet's rungs + the just-in-time ask + the Private faces (R-13nb-4) | U2 implementer | **CLOSED WHOLE** — built (`5fc30dd9`), live round MET (`aec83fb2`), ladder closed CLEAN at round 2 (R1 0B/1MAJ/1m/3n → 5/5 AGREE → F1+F4 fixed by the reviewer, AF-9 by the architect → sanity PASS → R2 clean bill 0/0/2n disposed in-round; records `13nb-u2-ladder-round{1,2}.md`) |
| 5 | U3 — edit + polish + her live round (+ `with_commits` R-13nb-7, `include_commits` on search R-13nb-10, the set-name tool R-13nb-8, the Allow-AI-here row AF-8; **edit_take carries an in-transaction fence/scope re-check** — the U2 ladder F2's guard, P-13nb-U2-8's sync-twin record) | U3 implementer + orchestrator | **BUILT + LIVE ROUND MET** — unit closed (`146cb7ba`), claims verified (headless rerun by my own hands, fences zero); the real-client round MET (the U3 LIVE ROUND record); ladder NEXT |
| 6 | A-4's honest-boundary line → the closeout author checklist (now incl. the grants-ride-copies note under R-13nb-6) | orchestrator | OPEN — standing |
| 7 | P-13nb-1 (journal predicate) — RATIFIED as R-13nb-1; QUESTIONS entry at merge records the ratification | orchestrator | CLOSED as provisional |
| 8 | THE PRIVATE MARK (R-13nb-4): v1_25 schema commit + Sync/ classifications + mirror artifact 16 — at the U1/U2 seam, Fable's hands | orchestrator | **DONE** (`304b41d1` — marker 13 client-side; headless whole-package green) |
| 9 | The lockstep DEPLOY window (marker 12→13, mirror → both installs) | her + orchestrator | HELD for the closeout window |
| 10 | 13x adoption lands MCP OFF (R-13nb-6) — the one toggle-OFF write on the adoption road | U2 (or U1 if the road is open) | OPEN |
| 11 | Re-verify probe (a) per macOS point release — line joins the closeout ritual note | orchestrator | OPEN — standing |
| 12 | THE FORMAT-SCHEMA SITTING (R-13nb-13; prep `phase-13nb-format-schema-sitting-prep.md`) | HER | **RAN 2026-10-09/10** — all seven ruled (R-13nb-26 a–g) |
| 13 | U3 — the edit-rung spine (brief below) | U3 implementer | **CLOSED WHOLE** — built (`146cb7ba`), live round MET (`127c7726`), ladder closed CLEAN at round 2 (R1 0B/0M/2m/2n → 4/4 AGREE → F1 record-fixed + F2 FIXED by the reviewer `a87fc8ec` with the three-leg red-on-old pin + F3 RECORDED + F4 copy-fixed `ff1da3f7` → sanity PASS → R2 clean bill 0/0/0/1n record-only; records `13nb-u3-ladder-round{1,2}.md`); VX-132 born (the harness hang, sample-traced) |
| 14 | U4 — the carriage + book rules + navigation (brief below) | U4 implementer + orchestrator | **BUILT + CLAIMS VERIFIED** — unit closed (`fce833b1`); forks ruled AF-11 (`aeea9dbf`), built as ruled; verified by my own hands 2026-10-10: whole headless rerun clean (core 2,580/295 · MCP 61/8 · workbook 40/6 — counts matching; the FIRST rerun's SPM summary carried a transient core-target failure note, row 15's second sighting → VX-134, the captured identical rerun clean), fences zero over `f4078d61..HEAD` (Sync/ · Server/ · Persistence/ · custody · editor seam · trailers; the one `lockstepVersion` grep hit is this record's own prose), walk evidence on disk and eyeballed (21 captures + 17 transcripts; 02 and 20 faithful to the record); VX-133 born (the receipt run-count overstating — the implementer's observation, ticketed not scope-grabbed); **LIVE ROUND MET** (the U4 LIVE ROUND record, 2026-10-10 — all five legs, every write walked back); **ladder ROUND 1 CLOSED** (R1 0B/1MAJ/3m/3n → 7/7 AGREE with three refinements adopted → 5 reviewer fixes incl. the F-1 bell override P-13nb-U4-16, all pins red-on-old by revert + 2 record-fixes → sanity PASS with 2 architect copy/record precisions `013c5f41`; record `13nb-u4-ladder-round1.md`); round 2 NEXT |
| 15 | The transient whole-package core-suite failure (unidentified — TWICE: U3 round 1; the U4 verify's first rerun, summary note only, the name swallowed by a piped tail, the captured identical rerun clean) | orchestrator | **TICKETED VX-134** — watch stays at the closeout whole-target run; any next sighting captures the FULL log to a file |

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
  **ITS SYNC TWIN (the U2 ladder's F2, recorded as the disposition):** a
  write tool's DECIDE (a read snapshot) and its ACT (the op's own write)
  are serialized against her gestures and every pane act by the session
  runner — but NOT against the sync engine's apply transaction, so a
  synced Private mark, placement move or tombstone landing between the
  two can let ONE in-flight suggest/write-new act land past a
  just-closed fence or scope. Bounded: additive writes only (the PROOF
  class), labeled, undoable; one in-flight call; the very next call
  refuses. Accepted for U2; **U3's edit rung must NOT inherit the gap**
  — `edit_take` overwrites text, so its op takes an injected
  `(Database) throws -> Void` guard run FIRST inside its own write
  transaction, re-deciding through `MCPGrantRule` on facts read there
  (`expectedText` is already this precondition class); retrofitting the
  eight U2 ops with the same seam is optional at the same touch.
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

- **P-13nb-U1-2's AMENDED FORM (AF-7 + its SECOND AMENDMENT at the U2
  ladder's F4, for the merge bundle):** a once READ grant is spent by its
  first content read (U1's letter, unchanged); a once WRITE grant (suggest
  or write new) is spent by its FIRST WRITE of ANY rung it authorizes —
  the content reads it needs on the way ride free, writes never do. ONE
  WRITE MEANS ONE WRITE, whatever its rung (the first spelling's "at its
  own rung" let a once write-new grant make unlimited suggest-rung writes
  "riding free" — the ladder's F4 named the consequence and the architect
  amended the ruling by letter, `d24e77b6`; pinned both ways, fix commit on
  this branch). Stated edge: a once-suggest grant authorizes ONE write
  (take-plus-lens wants "while connected"). Walked live: Once allowed
  exactly one `create_note`, the second refused and asked again (captures
  08/09 — unchanged under the amendment).
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

## U2 LIVE ROUND (orchestrator, 2026-10-09 — the acceptance's real-client leg; stage held and released)

Fresh branch Debug build (`vx124-u2-liveround`, codesign clean); the real
Claude Code client via the throwaway `-s local` scratch registration
(removed after; her user scope untouched). The round, live:

1. **The grant growth:** claude-code's Change… opened the U2 sheet —
   Read · Suggest · Write new with the mockup sentences and "Edit
   arrives in a later update." (P-2's honesty); the confirm spoke
   "Grant suggest in “o ladrão de raios” always."
2. **HER FACT-CHECK SHAPE, END TO END, with a real client:** the
   suggest client saw EXACTLY the 8 suggest-reachable tools (the 3
   suggest + the 5 read — edit/write-new tools NOT EVEN LISTED: P-2 on
   the wire, stronger than a refusal); `read_note with_ids:true`
   answered 2 blocks with real ids and the pre-existing takes visible;
   `add_take` landed a labeled "en" take beside EACH block;
   `save_lens "english readings — a escola"` collected both; the
   client's own report: "The author's existing 'english' takes were
   left untouched."
3. **The ids-are-the-address doctrine, observed live:** the client
   first tried `list_notes` by book NAME and was refused with the ONE
   answer ("That book isn't shared with this client, or doesn't
   exist."), then self-corrected to the id from `list_books` — names
   never resolve as addresses (R-13nb-8's letter).
4. **THE ⌥⌘Z LEG — the R-13n-6 dream, verbatim on screen:** the Edit
   menu read **"Undo claude-code's lens"**; one press walked the lens
   back and the menu stepped to **"Undo claude-code's take"** (per-act,
   newest first) with **"Redo claude-code's lens"** beside it — the
   redo entries carry the client's name too; the named redo brought
   the lens back whole. Quit unlinked the socket.

**VERDICT: U2's acceptance bar is MET live** — her fact-check shape
with a real client, the suggest fence holding by construction, one
⌥⌘Z walking an AI act back and its named redo returning it. Dev-store
residue: the claude-code suggest grant, two "en" takes on "a escola",
the lens "english readings — a escola" (beside the implementer's
u2-walk residue). **Her two live rulings during the round:** the undo
STACK MECHANISM ratified as-is and the FACE ticketed — R-13nb-19 below.

## SITTING RECORD ADDENDUM

- **R-13nb-19 (2026-10-09, at the live round, verbatim) — THE UNDO
  STACK STANDS AS-IS; THE FACE IS A TICKET.** Her words: *"should we
  make a ticket for some kind of view into recent actions covered by
  this option command Z? seems really powerful to be just a keyboard
  shortcut. not in this phase ofc. i'm fine with it being a simple and
  interleaved session scoped stack though. i think anything else would
  be a mess."* The mechanism (ONE interleaved, session-scoped stack;
  client-named entries for MCP acts) is RATIFIED; the view into recent
  stack entries is **VX-129** (Backlog, Feature) — deliberately not
  this phase's.
  **FIRMED by her next message, verbatim (2026-10-09):** *"yes, agreed,
  we don't want a parallel history system. worth a note that the shape
  of that session bounded simple stack is firm."* — the session-bounded
  simple interleaved stack is a DURABLE design commitment (the
  R-13nb-12 class), not a v1 convenience; no parallel history system,
  ever, by her word.

- **R-13nb-20 (2026-10-09, her evening batch — ONCE's meaning confirmed,
  no write counter).** Her question: *"what does one write mean one
  write mean? like one take only? one bounded session in which writes
  are allowed? … giving different numbers of writes seems weird (like
  not giving the option for specifically 5 writes)."* The answer,
  confirmed as the design: ONCE = one write CALL (one take, one
  comment, one lens, one note mint — or ONE bulk door: an
  import_document is one call, one compound act, however many rows);
  the BOUNDED SESSION she describes IS "while connected" (dies at the
  client's last disconnect — the task-shaped duration, and the ask
  sheet's natural steer for multi-step work); no numbered-writes dial
  exists or will (her instinct ratified — counting writes is the weird
  middle; the session is the honest unit).
- **R-13nb-21 (same message) — CARRIAGE PROFILES ARE LOCAL-ONLY IN v1.**
  Her words: *"agree on the carriage profile being local only in v1."*
  Zero lockstep; the sitting prep's §4 recommendation ratified.
- **R-13nb-22 (same message) — FOUR UNITS RATIFIED.** Her words:
  *"that's fine on the phase growing from three units to four."* The
  cut's CONTENTS stay the sitting's (prep §6).
- **R-13nb-23 (same message) — NAVIGATION RULED.** (a) OFFER BY
  DEFAULT: write receipts grow a one-press door — *"(which opening
  that needs a keyboard shortcut too)"* — the offer must be reachable
  from the keyboard, never mouse-only. (b) THE MOVE DIAL IS IN:
  `show_in_app` switching the pane AND delivering her to the right
  part of the editor — *"I do think that show_in_app switching the
  pane and navigating you to the correct part of the editor is good"*
  — with her etiquette verbatim: *"moving should not be done while you
  aren't at the app, should not be done automatically. I think the
  'open where your agent wants you to see deliberately' is fine to
  stick to."* Delivery mechanics: the EXISTING landing machinery (the
  13o search-passage landing — block id + selected range + the find
  bar armed + the comfort band) is the road; no index detour needed.
  (c) THE CEILING RULE RATIFIED with her one stated exception: *"with
  the exception of navigating the editing carat and pane to somewhere
  in the text, which a human can't really do beyond command F for
  searching but I do think we need"* (mechanically the landing
  machinery is already a human-reachable state, so the exception is
  nearly moot — recorded as spoken). (d) Side-pane opening (*"have my
  agent open this new thing in a side pane"*) is NOT v1 — *"I'd have
  to seriously think about it"*. (e) Compare-preloaded-with-a-version
  is an APP feature first: ticket **VX-130**. (f) Her added want for
  the inventory: navigation to the open takes (a take-board target).
- **R-13nb-24 (same message) — THE ORCHESTRATOR'S CONTEXT IS KEPT.**
  Her words: *"Let's keep your context - I think it's valuable."* This
  session continues as the phase's one orchestrator; no handoff at a
  seam unless forced.
- **R-13nb-25 (2026-10-09, the once-staleness exchange) — THE TIMEOUT
  IS ENDORSED, NOT v1.** Her words: *"a user using a 'once' at a time
  system is probably not expecting that if their agent cancelled their
  actions, that the next time they ask for something no permission
  request is needed at all. I suppose it doesn't need to expire in V1
  but I do think your time out suggestion is good."* Ticket **VX-131**
  (unspent once grants expire after a window, width hers). For now:
  *"unspent grants being visible rows in shared with AI is good and
  enough for now."* AF-9's determinism confirmed necessary either way
  (her observation: the race exists even with time-limited grants).
- **R-13nb-26 (2026-10-09/10 — THE FORMAT-SCHEMA SITTING'S RULINGS,
  run as two question batches; the prep `phase-13nb-format-schema-
  sitting-prep.md` is the option record):**
  **(a) THE BOUNDARY MARKER — separator line, BOTH forms, engaged only
  when needed.** Her condition verbatim: *"people can still export
  markdown & markdown with takes normally, right? in that case,
  separator line, both forms"* — honored by construction: a note whose
  blocks are all single-paragraph exports BYTE-IDENTICAL to today (the
  Q3-ratified byte-pinned default); only a note holding a
  multi-paragraph block exports in marker mode, declared by a
  format-version token in the braced header; the parser keys on the
  token so old files, pastes and plain markdown import exactly as
  today. HER REFINEMENT, same sitting: *"can people export markdown
  with multi paragraph blocks and still just see the markdown? the
  same way they can export without takes?"* — YES by the ratified
  dials: the marker lives ONLY in the Variorum-format (takes-carrying)
  export; the PLAIN export (takes dial off — rendered prose) never
  carries a marker, a brace or an Alternates section, whatever the
  note's block structure; its re-import segments by paragraph exactly
  as today (plain text was never structure-round-trippable, unchanged). **(b) The eight open inventory rows CARRIED as recommended —
  PLUS the date is SETTABLE.** Her words: *"agents should be able to
  set the date on a note - when I bring in old journals, that'll be a
  necessary part of processing if I want an agent to add years of
  previous journals to the right date. agree on the rest."* Shape:
  `entry_date` rides the structured create payload (write-new — the
  import-processing case whole) AND `set_entry_date` on EXISTING notes
  joins the EDIT rung; noted for the U4 ladder: a note newly added to
  a journal book becomes journal-fenced from that moment — creation
  lands, then the fence governs. **(c) Dials, defaults and the
  manifest line RATIFIED as proposed** (Q3). **(d) Versions' restore/
  promote NOT in v1** (Q5) — save + list/read only; a follow-on
  ticket if use wants it. **(e) THE CUT: ratified with LENSES READ
  PULLED INTO U4.** U3 = the edit-rung spine as assigned (+ the
  boundary marker's format work beside either-payload create, +
  entry_date in the create payload); U4 = the carriage (tray + Put
  back, versions list/read + save, lineage + ancestry, archived
  params, lenses list/read, set_entry_date) + (f) + navigation (g).
  Follow-on tickets at closeout: references read, callout carry,
  restore-version, deleted comments. **(f) BOOK RULES: READ AND WRITE,
  U4.** Her pick: *"Write too, in U4"* — book info carries rule/
  outflow/extents facts AND write-new gains set-rule/set-outflow
  (validated by the app's own refusals; the tutor's loop complete).
  **(g) NAVIGATION v1 TARGETS: note-at-block · lens · takes-board ·
  book/chapter** — her pick "those three + book/chapter"; Compare
  targets follow VX-130's app state; the offer door + keyboard road
  and show_in_app with her R-13nb-23 etiquette all ride U4.

---

## THE U3 IMPLEMENTER BRIEF (self-contained; the spawn names this section)

You are the U3 implementer for Variorum phase 13n-b, working in
`~/dev/variorum-vx-124` on branch `vx-124-13n-b` (NEVER the main
checkout). Commits say `Part of VX-124`, no attribution trailer, push
after every commit. `notes/SessionResiliencyProtocol.md` binds you: LIVE
STATUS in the "U3 UNIT RECORD" section below from your first commit,
foreground waits only, at most ONE read-only Sonnet for external facts.
Baseline (U2's ladder close): core 2,541/292 · VariorumMCPTests 33/4 ·
workbook 40/6, headless.

**Read first (never delegated):** this plan file TOP TO BOTTOM — the
SITTING RECORD R-13nb-1…26 (your unit's rulings: R-13n-6/7, R-13nb-7/10,
R-13nb-11, R-13nb-26 a/b/e) and the fork rulings AF-1…AF-9; the memo
`phase-13nb-memo-wire-document.md`; the prep
`phase-13nb-format-schema-sitting-prep.md`; ALL FOUR ladder records
(`13nb-u{1,2}-ladder-round{1,2}.md` — U2's round 1 carries the edit_take
guard line and the F2 class your unit must not inherit); the U1/U2 unit
records. Code: `Domain/MCPGrantRule.swift` (spends/best as amended),
`MCPWriteTools.swift` + `Operations+MCPWrites.swift` (the land shape,
the once-stamp, the undo registration road), `Domain/VariorumDocument.swift`
+ its tests (the byte pins you must keep green), `SearchQueries.swift`
(the facet booleans — R-13o-6's posture), the sections op family
(`Operations+Sections` or grep createSection), `Features/MCP/` (the pane,
the registry declarations).

**What U3 builds — the edit-rung spine:**

1. **`edit_take` (R-13n-7):** requires `expectedText` (stale refuses as
   `bufferChangedSinceGesture`); bracketed by the EIGHTH quiet
   auto-commit occasion — named insurance commits carrying THE CLIENT'S
   NAME ("before claude-code's edit" / "after claude-code's edit"),
   insurance-class, never governed by `savepoint_cadence`, deduped like
   the other occasions; refuses locked takes, sealed posts, fenced
   notes per the rule. THE GUARD (U2's F2 disposition, ledger row 5):
   the op takes an injected `(Database) throws -> Void` guard run FIRST
   inside its own write transaction, re-deciding through `MCPGrantRule`
   — the decide/act gap closed for the edit rung; retrofitting the
   eight U2 ops at the same touch is OPTIONAL (your call, note it).
2. **The structural tools:** `divide_block`, `merge_blocks`,
   `move_block`, `delete_block` (tombstone-only — the tray catches;
   deleteBlock's preconditions ride) — thin projections of the existing
   ops; per-act undo entries named for the client; refusals verbatim;
   scope checks per call; adjacency/validity the ops' own.
3. **`with_commits` on read_note's structured view (R-13nb-7):** the
   commits per take (kind, message, stamps; text with a P1-conscious
   shape — your call, record it); never ambient, never the text form.
4. **`include_commits` on search (R-13nb-10):** the + commits facet's
   wire form, default false, scope-checked per note; U1's
   search-never-reaches-savepoints state flips DELIBERATELY — update
   any pin asserting it as the ritual, never work around it.
5. **Sections (R-13nb-11):** `create_section` + a section arg on
   `add_note_to_book` + section facts riding list_notes and the wire
   document; curated books only, the app's own refusals (smart refuse,
   locked reading freezes structure).
6. **`create_note` EITHER-PAYLOAD (R-13nb-11 G-2 + R-13nb-26 b):** the
   text format OR a wire-document subset — multi-paragraph blocks,
   block names, labeled takes, and `entry_date` (the import-processing
   case; write-new sets dates on notes it MINTS — `set_entry_date` on
   existing notes is U4's, edit rung).
7. **THE BOUNDARY MARKER (R-13nb-26 a + her refinement):** format v2 in
   `Domain/VariorumDocument` — a format-version token in the braced
   header; a separator line between blocks (glyph YOUR proposal,
   hard-wrap-safe, never colliding with prose — record the rationale;
   I may veto); marker mode EMITTED ONLY when a note holds a
   multi-paragraph block — single-paragraph notes export BYTE-IDENTICAL
   to today and every existing byte pin stays green untouched; parsing
   keys on the token (old files/pastes exactly as today); prose that IS
   the marker line escapes or refuses fail-honest with the line number;
   round-trip pins for marker mode (export → parse → serialize
   byte-identical; a multi-paragraph block comes back ONE block). The
   PLAIN export (takes dial off) never carries a marker — pinned.
   `import_document` (wire + file doors) reads v2 for free via the one
   parser.
8. **`set_block_name`** (edit rung; the app op's own guards).
9. **"Allow AI here…"** — the note ⋯ menu's grant row (R-13n-11: shares
   THAT note, read, once — the quick path; the full sheet stays the
   pane's); registry-declared.
10. **The ACTIVITY face:** the pane's activity section over the
    existing log rows (capped, "all N ›" road — R-13n-10); plus a pass
    over U1's capped lists confirming every "all N ›" road opens a real
    full view (the U1 record says what shipped; close any gap).

**Must NOT touch:** `Sources/VariorumCore/Sync/` (ZERO lines this unit —
anything you think needs one comes to me), custody, the editor seam
(`EditorTextView`/`BlockRangeIndex`/`PaneSurface` — the landing/navigation
work is U4's, not yours), `lockstepVersion`, the real store,
`/Applications`, the mirror artifact. The export pin stands (no export
writes a row). Sentence case; app voice outside the MCP room (P-13n-1).

**Acceptance (use-shaped):** the verification bar's EDIT half pinned —
an edit grant's `edit_take` lands bracketed by the named commits (visible
in Block History), stale `expectedText` refuses, a suggest/write-new
grant PROVABLY cannot reach edit_take or the structural tools (the U1/U2
pin discipline); marker round-trip pins + the byte-identity of today's
exports; headless suites green at the unit's end; your pre-flight walk
on the dev-store Debug build (stage claim) covering: an edit under
insurance, one structural act walked back by ⌥⌘Z, a v2 export/import
round trip through the REAL File ▸ Import door. The REAL-client live
round (edit + the W-series equivalent) runs with me after your close.

**Forks:** the in-batch rule as ever — propose before building any half
beyond the recorded rulings; PROVISIONAL-and-log for non-gating
ambiguity; STOP for anything gating.

---

## U3 UNIT RECORD (LIVE STATUS — the implementer owns this section from its first commit)

**UNIT CLOSED by the implementer — NOT DONE: (1) the LIVE acceptance leg
with a REAL client (an edit under insurance + the W-series equivalent over
Claude Code — the orchestrator's, under a held stage claim; my pre-flight
drove the REAL embedded shim with a scripted client, `u3-walk`, never Claude
Code itself); (2) the whole VariorumTests target (only the suites pinning
every app surface the diff touches ran — 151/12 + the post-fix 67/5, listed
in R9); (3) the cold ladder; (4) deliberately not built: filing an EXISTING
member into a chapter on the wire (P-13nb-U3-8 — a U4 candidate),
`exportBlock` (unchanged — AF-10 records it as a block-level clipboard face),
and the guard retrofit on U2's eight ops (optional per the brief — not taken,
P-13nb-U2-8 stands for them).** Session: opus-implementer, 2026-10-09/10, cut
from `03ecb26d`; closed at the commit carrying this record.
Baseline (the brief's): core 2,541/292 · VariorumMCPTests 33/4 · workbook
40/6, headless. **Finals (headless, the whole package, at the unit's end on
`2328f26c`): core 2,563/294 · VariorumMCPTests 45/6 · workbook 40/6** — only
the long-standing gated skips; the Mac app builds on the final tree. Read whole before the first line of code: this plan top to
bottom (R-13nb-1…26, AF-1…AF-9, the U1/U2 records and live rounds), the
13n sitting record, the mockups §1–§10, the wire-document memo, the
format-schema prep, all four ladder records, SessionResiliencyProtocol, and
the orchestrator's handoff `03ecb26d`; the code named in the brief.

### Pieces

| # | Piece | Status |
|---|---|---|
| R0 | This record | DONE (this commit) |
| R1 | THE BOUNDARY-MARKER FORK → orchestrator (glyph + version token + grammar, with rationale) | RULED — AF-10 (`1d3f4913`): `--- next block ---` + `{v:2}` + the grammar approved as proposed; all seven build calls concurred, the rider on (b) binding (the CarryAllMerge move keeps every existing pin passing UNMODIFIED — zero test edits is the parity proof) |
| R2 | Core: the in-transaction GUARD seam on the edit-rung ops + `edit_take`'s op (named insurance brackets, `expectedText`, one undo entry) + set-name / create-section / file-into-chapter acts with client-named undo + state-transition tests | DONE (`d2e86599` seam + `1dc13a1a` acts) — `MCPEditActsTests` 11/11; MUTATION-CHECKED: the guard call removed from `performDeleteBlock` → the guard pin red (3 issues), restored |
| R3 | `CarryAllMerge` moved app → core Domain, byte-unchanged (merge_blocks' keyboard default — the `KeepOnTopDivide` 18c precedent) | DONE (`296c5866`) — same name, public members, zero app-caller and zero test edits (AF-10's rider); the parity suites `FannedDefaultsTests`, `FannedDefaultsBoardTests`, `MergeArrangementTests` GREEN UNMODIFIED at R9 |
| R4 | The EDIT rung on the wire: `edit_take` · `divide_block` · `merge_blocks` · `move_block` · `delete_block` · `set_block_name` (catalog + tools + the guard + receipts) + the PROOF pins (suggest / write new provably cannot reach them) | DONE (`67979514`) — `MCPEditServerTests` 6/6 + the U1 catalog walk and U2 suggest proof updated as the ritual; VariorumMCPTests 39/5. MUTATION-CHECKED (2 breaks, both caught): edit_take's guard dropped → the once grant never spends (2 issues); move's guard deciding the source only → a block escapes into an unshared note (7 issues); restored |
| R5 | `with_commits` on read_note's structured view · `include_commits` on search · sections (`create_section`, a `section_id` arg on `add_note_to_book`, section facts in list_notes + the wire document) | DONE (`b6bf4762`; `create_section` + `section_id` landed in R4 `67979514`) — `MCPReadCarriageTests` 3/3; MUTATION-CHECKED: `includesSavepoints` forced on → the never-without-the-facet pin red; the readable-books filter removed → the unreached book's name leaks, pin red (4 issues); restored |
| R6 | `create_note` EITHER payload (the text format or a wire-document subset — multi-paragraph blocks, names, labeled takes, `entry_date`) | DONE (`95ef94ba`; the op-level date boundary `45f06ec9`) — `text` (U2's plain prose, unchanged) XOR `blocks` (the wire-document subset) + `entry_date` (a real `yyyy-MM-dd` day) on either; core `createStructuredNote` rides 13n-a's `mintDocument` with a same-transaction `finish` (names, date); pins: `MCPEditActsTests` +1, `MCPEditServerTests` +1 |
| R7 | THE BOUNDARY MARKER — format v2 in `Domain/VariorumDocument` (marker mode only when needed; byte pins untouched; round-trip pins; the plain export never carries it) | DONE (`252d08e1` + the wire leg `902f0d30`) — every 13n-a byte pin green UNTOUCHED (77/6); `BoundaryMarkerTests` 9/9 incl. the exact-inverse sweep over >1000 marker-mode notes; `import_document`/`read_note` round-trip v2 byte for byte over the socket (`MCPEditServerTests` +1). MUTATION-CHECKED (3 breaks, all caught): marker mode always on → the v1 byte pins red (11 issues across 3 suites); the escape disabled → 3 issues; the after-boundary strip removed → 11 issues; restored |
| R8 | App faces: the grant sheet's EDIT rung · "Allow AI here" (the note ▾ menu) · the ACTIVITY face + its "all N ›" road · the all-N pass over U1's lists · receipts for the new acts | DONE (`763e3f91`; receipts `1dc13a1a`; walk fixes W-1/W-2 `e7e6b72c`) — `MCPEditFacesTests` 4/4 + the U2 rung pin's ritual update green; walked in both voices (captures 01–16). **The all-N pass:** U1's three capped lists (requests · clients · shared) each already open `MCPFullListSheet` over `allPending`/`allClients`/`allShared` — no gap; the activity road is the fourth on the same sheet |
| R9 | End of unit: headless suites, Mac focused suites (stage), the pre-flight walk (stage, both voices) | DONE — headless finals above. **Mac (stage held, `-only-testing`):** 151 tests / 12 suites — CapabilityRegistryTests, ChordLegibilityTests, CommitBarLayoutTests, DocumentImportDoorTests, FannedDefaultsTests, FannedDefaultsBoardTests, ImportFacesTests, MCPAskAndReceiptTests, MCPEditFacesTests, MCPPaneTests, MergeArrangementTests, PDFExportFaceTests — the ONE red the RULED flip (`PDFExportFaceTests`' takes-markdown expectation: its fixture's first block holds a blank line, so the takes export is v2 now — updated as a justified edit `ff6fc046`; the rendered and PLAIN expectations, and so the PDF, byte-identical), 10/10 after; post-walk-fix run 67/5 (MCPPaneTests, MCPAskAndReceiptTests, MCPEditFacesTests, SettingsShapeTests, CapabilityRegistryTests), 0 skipped. Two self-review fixes after the walk, each red-on-old: `45f06ec9`, `2328f26c` (below). The pre-flight walk below |

### Decisions, forks, PROVISIONALs

**The one fork** (the boundary marker + the seven build calls) went to the
orchestrator before the format work and came back RULED whole as AF-10
(`1d3f4913`); built as ruled. Everything below is within the mandate.

**PROVISIONALs (for the merge QUESTIONS bundle):**

- **P-13nb-U3-1 — `edit_take` addresses ANY live active take of a reachable
  note by `take_id`** (chosen or not) and replaces its WHOLE text (`text` =
  the take's whole new text, `expected_text` = its whole current text);
  archived, locked and sealed refuse (`editableVariant`). Alternatives: (b)
  the chosen take only; (c) a span-replace form (old → new substring) —
  cheaper on the wire for a long take, but a second precondition class.
- **P-13nb-U3-2 — the bracket commits STAY when ⌥⌘Z walks the edit back**
  (I5: undo restores the buffer, never the history): Block History keeps
  "before/after <client>'s edit" over an undone edit — the record of what an
  AI did and she undid is hers. No alternative keeps I5; stated so she sees
  the consequence.
- **P-13nb-U3-3 — a ONCE edit grant is spent by an authorized call that
  changes nothing** (`edit_take` with the buffer's own text, `set_block_name`
  to the current name): the guard runs first and stamps before the op sees
  the no-op; the answer says `changed: false` — no commit, no entry, no
  receipt. A REFUSED act spends nothing (the rollback takes the stamp with
  it — pinned). Alternative: (b) spend only on a landed change (the guard
  would defer its stamp to the op's end).
- **P-13nb-U3-4 — `move_block` decides the DESTINATION note at EDIT too** (a
  block arriving rearranges that note's existing text), never at write new.
  The destination is decided only inside the act's transaction, so its
  refusal raises no ask (the source's does). Alternatives: (b) the
  destination at write new; (c) also raise an ask for the destination.
- **P-13nb-U3-5 — `move_block` refuses a cross-WING move** (in the act's
  transaction: "That note is in another wing — each wing is a separate
  library, so a block can't move between them."). Wings isolate totally (the
  sitting record §9; none of her block doors crosses one, and a block's
  block-tag rows name its wing's vocabulary). Self-review fix `2328f26c`,
  red-on-old. Alternative: (b) allow it with the per-item wing doors'
  tag adoption by path — a new crossing door, hers to rule.
- **P-13nb-U3-6 — `move_block`'s addressing:** exactly one of
  `after_block_id` · `before_block_id` · `note_id` (+ `at`: start | end,
  default end); a same-note target runs `reorder`, a cross-note one
  `moveBlock`; ONE entry "<client>'s move".
- **P-13nb-U3-7 — `create_section` sits at WRITE NEW** (scopes book · wing):
  a chapter adds and changes nothing that exists; it takes the same
  in-transaction guard as the edit acts (`guardBook`). Alternative: (b) edit
  (it reorganizes her book).
- **P-13nb-U3-8 — chapters reach the wire in three places only:**
  `create_section`, `add_note_to_book`'s `section_id` (filing at ADD time,
  carried through undo/redo by the entry's exact rows), and the read facts.
  Filing an EXISTING member into a chapter (`assignPostToSection`) is NOT
  built — a U4 candidate, her word on whether the wire needs it.
- **P-13nb-U3-9 — the structured `create_note`'s takes carry their label AS
  GIVEN** (no "<client> · suggested" stamp — P-13nb-U2-12 marks suggestions
  on HER blocks; a client-minted note is wholly the client's writing).
  Empty-text takes drop (`mintDocument`'s rule); `blocks: []` mints an empty
  note (⌘N's shape, as an empty `text` does). Alternative: (b) stamp the
  client's name on every take the wire mints.
- **P-13nb-U3-10 — `entry_date`** is canonical `yyyy-MM-dd`, validated on the
  wire AND at the op (Phase 9b's day-key boundary — self-review fix
  `45f06ec9`, red-on-old); create-time only (`set_entry_date` on an existing
  note is U4's, edit rung).
- **P-13nb-U3-11 — the commit carriage's field names and units:**
  `with_commits` gives each commit `commit_id · kind · message · created_at ·
  length · text | text_omitted`; the 100k budget counts Swift Characters and
  fills newest-first, STOPPING at the first commit too large for what
  remains — every older text is omitted with it, so the carried texts are
  always a contiguous newest-first prefix, and the omitted ones are fetched
  by `commit_ids` *(CORRECTED at the U3 ladder round 1, F1 — the record
  first said "fills GREEDILY … a later, smaller one may still ride", which
  the code never did and the pin contradicts (`MCPReadCarriageTests`'
  "older ones wait too"); the built prefix rule is the better contract and
  matches the catalog's own sentence, so the record moved to the code, both
  AGREE)*; `include_commits`' savepoint passages carry `commit_id` +
  `saved_at` beside the block address. (AF-10 (d) ruled the shape; the names
  are mine.) *(F3 note, same ladder round, record-only: the one SQL fetches
  every commit's text though only the budget's worth rides — bounded by the
  note's own history, P1 holds; any future two-pass fetch must keep the
  Characters unit deliberately — SQLite `length()` counts code points, and
  the `length` field on OMITTED commits is what forces the full fetch
  today.)*
- **P-13nb-U3-12 — the activity face's caps:** the newest 5 coalesced lines
  over the newest 50 rows; "all N ›" — N is the log's ROW count (≤ the
  store's 500-row cap), the sheet coalesced the same way; a refused call
  names its tool verbatim ("claude-code was refused add_take on “ch 8”" —
  the MCP room's register). Alternatives: (b) N counts lines; (c) a refusal
  in words ("couldn't add a take").
- **P-13nb-U3-13 — the activity coalescing rule:** consecutive rows with one
  client · act · target · outcome read as ONE line with a count, with NO
  time window (the receipts' 120-s window is a bar rule, not the log's); the
  stamp shown is the newest row's.
- **P-13nb-U3-14 — the new acts' words** extend P-13nb-U2-5's family: undo
  labels "<client>'s edit / divide / merge / move / delete / block name /
  chapter"; receipts "edited a take" · "divided a block" · "merged two
  blocks" · "moved a block" · "deleted a block" · "named a block “…”" /
  "cleared a block's name" · "made the chapter “…”"; the import door's new
  refusal "it was written by a newer Variorum (format version N) — update
  Variorum to import it". App voice, 13s-a sweepable.
- **P-13nb-U3-15 — "Allow AI here" offers the APPROVED clients that do not
  already reach the note at read** (a client reaching it at any rung is not
  offered); the receipt "<client> may read this note once." (AF-10 (e) ruled
  the shape; the words are mine).
- **P-13nb-U3-16 — the edit tools carry `destructiveHint: true`** (the MCP
  annotation — every act is undoable and the delete a tombstone, but a
  client's host may confirm before calling: honest about the rung).
  Alternative: false (undoable ⇒ not destructive).
- **P-13nb-U3-17 — the pane's two sentences kept TRUE under edit** (walk
  W-1/W-2): the subtitle "The local MCP server: which clients may connect,
  what each may read and change, and the command that sets up Claude Code."
  and the toggle's "… and AI work lands as takes beside your own — a client
  changes your text only where you grant it edit, with a commit before and
  after every change." Her words to re-voice at 13s-a.

**Decisions within the mandate (recorded as they land):**

- **The guard seam is rung-wide on the edit acts** (AF-10 (a)): every edit
  act is decided TWICE — the snapshot decision speaks refusals and raises
  asks (`spendsAfter: false`), then `guardEdit` re-resolves every touched
  note from the act's own rows INSIDE the act's write transaction, decides
  each at EDIT through the pure rule, and stamps any once grant there,
  atomic with the act (no crash corner on this rung). `guardedBy:` defaults
  nil on her doors; no redo carries it; `deleteBlock` threads it through the
  forward `performDeleteBlock` only.
- **divide/merge are her keyboard's compositions** (`KeepOnTopDivide` /
  `CarryAllMerge` over `divideW` / `mergeCeremony`; the plain ops when
  fanless), relabeled by `registeringUndo(as:)` — `withCompound` over the
  act's own registration, never a second inverse. The fanned divide's
  `measured` guard re-checks the shown take's text in-transaction.
  **AMENDED at the U3 ladder round 1 (F2, the reviewer's fix `a87fc8ec`):**
  the guards now re-verify the WHOLE composition inside the act's
  transaction — divide: the fan's ids AND texts (a parked cut is positional)
  plus the shown take still rendered; merge: both fans' membership and both
  shown takes, on both roads — so a sync apply landing between the outside
  fan read and the act (the only interleaver; the serial body) refuses as
  `bufferChangedSinceGesture` instead of mid-splitting a bystander take at
  its stale parked cut, cutting the wrong rendered take on the single-take
  path, or silently stranding an arrived take on a plain merge. Pinned
  red-on-old through the guardian seam
  (`aCompositionStaleAtTheActRefusesInsteadOfMisShaping`).
- **The "after" commit is stamped +1 ms** so `(created_at, id)` always reads
  before → after in Block History.
- **An AI edit churns like any text edit** (AF-10 (g)): `churnCost` is the
  inserted + deleted UTF-16 units between the common ends — the editor's
  delta's whole-buffer equivalent, ∝ the edit. (So an AI rewrite CAN cross
  her 80% threshold — the suggest takes, P-13nb-U2-7, never do.)
- **Every MCP write registers one undo entry** (P-13nb-U2-4 carried):
  `set_block_name` and `create_section` included, though her own name and
  chapter gestures stay outside the stack.

### The U3 pre-flight walk (dev-store Debug build `DerivedData/vx124-u3`, 2026-10-09 ~21:50–22:45, under my own stage claim — the orchestrator's live real-client round is still owed)

Captures (gitignored): `notes/plans/13n-b-screens/u3/01…16-*.png`; the
scripted client's transcripts `client/out-01…10-*.txt` + the client itself
`client/mcpwalk.py` (spawns the REAL embedded shim over stdio, self-named
`u3-walk`); the real export `files/a letter.md`. Author guard + per-click
guard throughout; her `/Applications` app never running; my instance quit by
identity each time.

- **01** `u3-walk` connects → pending, zero tools (`out-01`). **02** Approve…
  → the sheet's four rungs, Edit's mockup §3 sentence; granted edit on "o
  ladrão de raios", always. `out-02`: the 19 tools listed under edit;
  `out-03`: `list_notes` rows carry `section_id`/`section_name` ("1 o
  semideus"); `out-04`: `read_note with_ids`.
- **Edit under insurance:** `out-05` — `edit_take` on an existing take
  (only "after" — the take's last commit already held its old text: the
  standing dedupe), then the SAME stale read refused in the app's words
  ("The text changed while that gesture was landing — nothing was altered;
  try it again on the current text."), then `read_note with_commits`
  showing the commits. `out-06` — `create_section` "3 cartas" and a
  structured `create_note` "a letter" (a two-paragraph first block, a "pt"
  take) filed under it. `out-07`/`out-08` — the note reads back as v2
  (`{v:2}` + `--- next block ---`); `edit_take` on its never-committed take
  → BOTH brackets; **05** Block History: "after u3-walk's edit" over
  "before u3-walk's edit".
- **A structural act walked back:** `out-08` `divide_block` at "It has been"
  → **03** landed (and the note now reads v1 — no block holds a blank line,
  marker mode follows need); ONE ⌥⌘Z → **04** "Undid: u3-walk's divide".
- **The v2 round trip through the REAL door:** "Markdown with Takes…" wrote
  `files/a letter.md` (`{v:2}`, the marker, the Alternates section) → File ▸
  Import… → **06** the Pool note "a letter", block 1/2 holding BOTH
  paragraphs (one block, as written).
- **Allow AI here:** **07** the note ▾ submenu on the imported note naming
  `u3-walk` → **08** "u3-walk may read this note once."; `out-09` lists it,
  `out-10` reads it once and the second read refuses.
- **The pane:** **09** `u3-walk` "1 shared place"; **10** the Activity section
  (coalesced runs, a refusal named by tool); **11** the "all 77 ›" sheet.
- **Terminal voice:** **12** pane, **13** activity, **14** the grant sheet's
  Edit rung, **15** the Allow AI here submenu. Voice restored to Study.
  **16** the pane after the W-1/W-2 fixes.

**The walk's two findings — both FIXED (`e7e6b72c`), pinned where pinnable:**
1. **W-1** — the pane's subtitle said "what each may read" under write and
   edit rungs → "what each may read and change" (P-13nb-U3-17).
2. **W-2** — the toggle's "no client can overwrite your text" became false
   the moment edit could be granted → says when it can and what guards it
   (P-13nb-U3-17; `MCPAskAndReceiptTests`' U2 pin updated as the ritual).

**LEFT in the dev store (deliberate, harmless):** the `u3-walk` client
(approved; edit on "o ladrão de raios", always; its read·once note grant
spent); the "3 cartas" chapter and the note "a letter" in that book (its
bracket commits); the imported Pool note "a letter"; the edit on the "o
museu" note's take (its "after" commit); one quiet insurance commit holding
stray keystrokes from the walk incident below. `claude-code`'s and
`u2-walk`'s grants untouched. Server ON, voice Study.

### Open items for the orchestrator

- **The live acceptance leg** (an edit under insurance + the W-series
  equivalent with a real Claude Code client): register the Debug shim as U1's
  round did, grant EDIT on a book, have the client `read_note with_ids` →
  `edit_take` (watch Block History for the two named commits) → a
  `divide_block` or `move_block` → ⌥⌘Z once in the app. A stale
  `expected_text` refusal is worth one deliberate call.
- **QUESTIONS at merge:** P-13nb-U3-1…17.
- **For the cold reviewer, where to look first:** (a) the guard ordering in
  `MCPWriteTools+Edit` — snapshot decide (no spend) → the act with
  `guardEdit` in-transaction (spend atomic); is there any edit act whose
  WRITING op does not receive the guard, or a path where a refusal thrown
  inside the guard escapes `land`'s mapping? (b) the fanned compositions in
  `Operations+MCPEdits` read the fan OUTSIDE the transaction
  (`liveActiveFan`, `renderedVariant`): a take added by a sync apply between
  read and act stays on A in lineage (divide-W's parking) or with the
  released sources (merge) — nothing is lost, but the composition can be one
  take short; the `measured` guard re-checks only the shown take's text;
  (c) `editTakeUnderInsurance`'s dedupe (`isDirty`) and its undo's insurance
  pre-image; (d) format v2's escape and `markedText`'s run boundaries, the
  header-only version-token reading; (e) the greedy commit budget
  (P-13nb-U3-11); (f) U2's eight ops still decide-then-act (P-13nb-U2-8,
  unchanged).

### Self-assessment (the implementer's, before the cold review)

- **The edit-half PROOF is real and mutation-checked:** a client holding
  suggest or write new on the whole wing calls every edit tool aimed at her
  takes and blocks; each refuses at the rung, every take, placement, block
  and commit byte-identical after. Nine deliberate breaks across R2/R4/R5/R7,
  nine catches (the table above), plus two self-review fixes red-on-old.
- **What the walk caught that the pins did not:** W-1/W-2 — both copy truths
  no headless pin reads (a sentence true at U2 that U3 made false).
- **What self-review caught after the walk:** a permissive day-key door at
  the op (`45f06ec9`) and a wing crossing (`2328f26c`) — both reachable only
  through the wire's validation or a two-wing grant, both now refused where
  the facts are.
- **Scope held:** zero lines in `Sources/VariorumCore/Sync/`, zero custody,
  zero editor seam (`EditorTextView`/`BlockRangeIndex`/`PaneSurface`
  untouched), zero lockstep (no migration, `lockstepVersion` untouched), the
  export pin intact (no export writes a row), every 13n-a byte pin green
  UNTOUCHED.

### Machinery notes

- **A walk RULE BREACH, recovered:** I typed after a context-menu click
  without a capture proving the menu had opened; it had not, and the
  keystrokes landed in the fixture note being walked. Recovered with ⌥⌘Z ×3
  (the A12 insurance confirm answered "Undo") — the note fully restored, one
  quiet insurance commit holding the stray text (left, above). The rule
  exists for exactly this; every later menu step waited on a capture.
- **Capture geometry:** the displayed captures are scaled 1.38× — screen
  point = window origin + displayed px × 0.69. Clicking by displayed pixels
  missed until that was measured.
- **Quit refused (−128) once:** the just-in-time ask sheet was up; Esc
  ("Don't allow") dismissed it, then quit by identity.
- **A personal notification banner** appeared in one full-screen grab; I
  cropped the window out and deleted the full grab.
- **The first `edit_take` on "o museu" deduped its "before"** (the take's
  last commit held its text) — correct behaviour; the walk used a
  never-committed take on the client's own note to show both brackets.

## U3 LIVE ROUND (orchestrator, 2026-10-09 — the acceptance's real-client leg; stage held and released)

Fresh branch Debug build at `146cb7ba` (`vx124-u3-liveround`, codesign
clean, `io.lduarte.Variorum.debug`); the real Claude Code client via the
throwaway `-s local` scratch registration (removed after; her user scope
untouched). Before the round: the implementer's claims verified — the
whole headless package rerun with my own hands on the final tree (exit 0;
`swift test list` counts 2,563 core · 45 MCP · 40 workbook, matching the
record), ZERO lines in `Sync/` and `Server/` across the unit's whole
range, no migration, no `lockstepVersion` touch, the walk evidence real
on disk (capture 05's brackets read with my own eyes). The round, live:

1. **The edit fence BEFORE the grant:** at suggest, the client listed
   EXACTLY the 8 suggest-reachable tools — no edit tool even named
   (P-2 on the wire, U2's pattern holding at U3).
2. **The grant growth to EDIT:** claude-code's Change… offered all four
   rungs; Edit's sheet sentence read the mockup §3 line ("it can also
   edit takes — with a commit before and after every change, so you can
   always compare and come back"); the confirm spoke "Grant edit in
   “o ladrão de raios” always"; the pane stepped to "3 shared places";
   the Bookcase row wears its "shared with AI" chip. W-1/W-2's amended
   pane copy read true on screen.
3. **`edit_take` through the real client:** read_note `with_ids` → the
   client edited HER "english" take on "a escola" ("far from
   everything" → "remote from everything"); the answer carried
   `changed: true` + `after_commit_id`. Block History showed **"after
   claude-code's edit"** over the prior commit holding the exact
   pre-edit text — the before-bracket DEDUPED correctly against it (the
   standing dedupe; the walk's never-committed take had already shown
   BOTH brackets).
4. **The stale refusal, verbatim:** a deliberate `edit_take` with the
   pre-edit `expected_text` was refused in the app's own words — "The
   text changed while that gesture was landing — nothing was altered;
   try it again on the current text." — and nothing changed.
5. **The structural act and HER veto:** `divide_block` with
   `second_half_starts_with: "longe de tudo"` landed keep-on-top
   (`kept_on_top: 2`, both English takes riding whole — fresh copies,
   0 commits, as copies never carry history); Block History's Came
   from showed the original "kept WHOLE and set aside … the original
   is preserved". ONE ⌥⌘Z: the bar read **"Undid: claude-code's
   divide"**, the note byte-restored to two blocks, the original back
   with its full history (english · 2).
6. **Lifecycle:** quit by identity unlinked the socket; registration
   removed; stage released.

**VERDICT: U3's acceptance bar is MET live** — an edit grant's
`edit_take` landed bracketed and visible in Block History, stale
`expectedText` refused, the suggest fence held by construction (tools
not even listed), a structural act walked back by one client-named
⌥⌘Z. Dev-store residue (deliberate): claude-code's edit-always grant on
"o ladrão de raios" (useful to the ladder and U4), the english take's
edit + its "after claude-code's edit" commit; the divide fully undone.
Round captures: the scratchpad's `u3-liveround/cap-01…13` + client
transcripts `out-s1…s4` (ephemeral; this section is the record). Next:
ladder round 1 (`fable-reviewer`, the cross-model flow).

## THE U4 IMPLEMENTER BRIEF (self-contained; the spawn names this section)

You are the U4 implementer for Variorum phase 13n-b, working in
`~/dev/variorum-vx-124` on branch `vx-124-13n-b` (NEVER the main
checkout). Commits say `Part of VX-124`, no attribution trailer, push
after every commit. `notes/SessionResiliencyProtocol.md` binds you: LIVE
STATUS in the "U4 UNIT RECORD" section below from your first commit,
foreground waits only, at most ONE read-only Sonnet for external facts.
Baseline (U3's ladder close, `205ab828`): core 2,564/294 ·
VariorumMCPTests 45/6 · workbook 40/6, headless. Known and ticketed, not
yours: VX-132 — VariorumMCPTests can hang intermittently (the SDK
client's connect loop spins if a response never arrives, ~1-in-7 worst
case); a run stalled far past ~2 s for that target is killed, noted and
rerun, never chased.

**Read first (never delegated):** this plan file TOP TO BOTTOM — the
SITTING RECORD R-13nb-1…26 (your unit's rulings: R-13nb-14 the keyboard
bar, R-13nb-17 narrow-where-it-counts, R-13nb-18 write-new's reach,
R-13nb-23 NAVIGATION, R-13nb-26 b/d/e/f/g) and the fork rulings
AF-1…AF-10; the memo `phase-13nb-memo-wire-document.md`; the prep
`phase-13nb-format-schema-sitting-prep.md` (§2 the inventory, §6b
navigation); ALL SIX ladder records (`13nb-u{1,2,3}-ladder-round{1,2}.md`
— U3's round 1 carries F2's composition-guard class your unit must not
reintroduce); the U1/U2/U3 unit records and live rounds. Code:
`Domain/MCPGrantRule.swift`, `MCPWriteTools.swift` +
`MCPWriteTools+Edit.swift` + `Operations+MCPWrites.swift` +
`Operations+MCPEdits.swift` (the land shape, the guard seam, the
composition guards), `MCPNoteStructure.swift` (the structured view),
`MCPReadTools.swift`, `MCPToolCatalog.swift`, the Versions op family
(`saveNoteVersion` — `notes/plans/post-13l-polish-round.md` is its
record), the tray reads (`Queries` deleted-blocks/takes families,
`restoreBlock`), the lens queries (`lens`/`lens_choice`), the 13o
landing machinery (`LandingTarget`, the search-passage landing road),
`Features/MCP/` (pane, registry).

**What U4 builds — the carriage + book rules + navigation (R-13nb-26
e/f/g, R-13nb-23):**

1. **THE TRAY on the wire (R-13nb-14's named IN):** read a note's tray
   (deleted blocks and takes, the app's 30-day-clock family) behind an
   explicit call shape; `put_back` on the EDIT rung (the prep §6's cut
   as ratified) — thin projections of the app's own restore ops,
   per-act client-named undo, the composition-guard discipline where a
   restore rearranges existing text.
2. **VERSIONS (R-13nb-18 + R-13nb-26 d):** `save_version` at WRITE NEW
   (the `saveNoteVersion` family — a creative act touching no existing
   text); versions LIST/READ behind explicit call shapes;
   restore/promote NOT in v1 (ruled — a follow-on ticket at closeout).
3. **LINEAGE + ANCESTRY (R-13nb-14's named IN):** read-only edge facts
   (derived_from/version_of) and take-ancestry (parent tree) fields on
   the structured view — explicit call shapes, never ambient on every
   read (R-13nb-7's P1 posture).
4. **ARCHIVED REACH (R-13nb-26 b carrying the inventory):** explicit
   params mirroring the app's facet posture — archived takes on the
   structured view, archived notes/books on list shapes. For SEARCH's
   archived facet: R-13nb-10 left it UI-only and the sitting carried
   the inventory row — build the list/read params as ruled, and treat
   a search `include_archived` as PROVISIONAL (build it to match the
   facet's letter, mark it, log it for the bundle) — it gates nothing.
5. **LENSES LIST/READ (her pull-in, R-13nb-26 e):** list a note's
   lenses, read one (name + the chosen takes per block) — read rung,
   explicit shapes; `save_lens` already exists (U2).
6. **`set_entry_date` (R-13nb-26 b):** EDIT rung, existing notes, the
   op-level day-key validation already landed at `45f06ec9` (reuse it
   — one boundary, one unit).
7. **BOOK RULES READ + WRITE (R-13nb-26 f):** book info carries
   rule/outflow/extents facts (readable books only — AF-10 (f)'s
   letter); WRITE-NEW gains set-rule/set-outflow projections of
   `setReadingRule`-family ops, validated by the app's OWN refusals
   (gatherings/finished/sealed/wrong-kind refuse as hers do; the rule
   grammar's own validation speaks). The ladder watches this power:
   NO new validation paths, no bypass of any app refusal.
8. **FILING AN EXISTING MEMBER INTO A CHAPTER — PROVISIONAL
   (P-13nb-U3-8's U4 candidate):** project `assignPostToSection` at
   WRITE NEW beside `create_section` (P-13nb-U3-7's class — it
   reorganizes, creates nothing; curated books only, the app's own
   refusals). The keyboard bar argues IN; her word was not taken —
   build it, mark PROVISIONAL, log it in the record for the bundle.
9. **NAVIGATION (R-13nb-23 + R-13nb-26 g — her etiquette is LAW):**
   (a) **The OFFER door, the default:** write receipts grow a
   one-press door ("… — Open ›") reachable from the KEYBOARD too (her
   words: "which opening that needs a keyboard shortcut too") — the
   receipt bar's door gets a chord, registry-declared, both voices.
   (b) **`show_in_app(target)`, the move dial:** navigates the open
   app — ONLY while Variorum is frontmost (not merely running — her
   "moving should not be done while you aren't at the app"), NEVER
   automatic (only a client's explicit call), never cross-app
   activation, no window raising; when not frontmost the call refuses
   honestly (or answers as an offer — your call, record it) rather
   than queuing a surprise. (c) **Targets, v1 (her pick):**
   note-at-block (the 13o landing road VERBATIM — block id + selected
   range + the find bar armed + the comfort band; P-4: composition,
   never decision-bearing broadcasts), lens, takes-board (her added
   want — the note's Takes mode at a block), book/chapter. Compare
   targets WAIT for VX-130 (not yours). Side pane NOT v1. (d) **The
   ceiling rule:** every target is a state her own doors reach; the
   caret/landing delivery is her one stated exception, already
   human-reachable via the landing machinery.
10. **Faces:** any new receipts/copy per P-13nb-U3-14's family (app
    voice, sentence case, 13s-a-sweepable); the pane untouched unless
    a new fact needs a face (record if so).

**Must NOT touch:** `Sources/VariorumCore/Sync/` (ZERO lines — anything
you think needs one comes to me), custody, the editor seam FILES
(`EditorTextView`/`BlockRangeIndex`/`PaneSurface` — navigation RIDES the
existing LandingTarget/landing road by composition; if a seam file
itself must change, STOP and fork to me with `notes/TEXTKIT2_NOTES.md`
read), `lockstepVersion`, migrations, the real store, `/Applications`,
the mirror artifact. The export pin stands. The rung is the ONLY read
dial (R-13nb-17): every new reach is an explicit CALL shape, uniform
per rung, never per-client configuration.

**Acceptance (use-shaped):** the carriage pinned end to end (tray
read + put_back lands and undoes client-named; save_version mints the
classifier shape and versions list/read speak it; lineage/ancestry
fields exact; archived params honor the facet posture; lenses read;
set_entry_date validated); book-rule writes land through the app's own
refusals (a gathering/finished/sealed book refuses byte-exactly as her
doors do — pinned); rung proofs updated as the ritual (read/suggest
provably cannot reach the new write tools; the catalog walk current);
navigation: `show_in_app` refuses when the app is not frontmost
(pinned at the decision seam), lands at note-block/lens/takes-board/
book-chapter through the existing road, and the offer door has its
keyboard chord (registry walk green); headless suites green; your
pre-flight walk on the dev-store Debug build (stage claim, both
voices) covering: a tray Put back via wire walked back by ⌥⌘Z, a
save_version visible in Note ▸ Versions, a book-rule write refused on
a finished book IN THE APP'S WORDS, one show_in_app landing at a block
with the app frontmost AND its refusal with the app backgrounded, the
offer door pressed from the keyboard. The REAL-client live round (the
W-series equivalent) runs with me after your close; HER Percy-grade
round is the phase's finale.

**Forks:** the in-batch rule as ever — propose before building any
half beyond the recorded rulings; PROVISIONAL-and-log for non-gating
ambiguity; STOP for anything gating. Watch items the ladder will hold
you to (R-13nb-26 b's rider): a note newly added to a journal book is
journal-fenced FROM THAT MOMENT (creation lands, then the fence
governs — no window); the book-rule write power stays inside the app's
refusals; the etiquette gates are RULINGS, not suggestions.

---

## U4 UNIT RECORD (LIVE STATUS — the implementer owns this section from its first commit)

**UNIT CLOSED by the implementer — NOT DONE: (1) the LIVE acceptance leg
with a REAL client (the W-series equivalent over Claude Code — the
orchestrator's, under a held stage claim; my pre-flight drove the REAL
embedded shim with a scripted client, `u3-walk`, never Claude Code itself);
(2) the whole VariorumTests target (only the 212 tests / 19 suites pinning
every app surface the diff touches ran, listed in S6); (3) the cold ladder;
(4) deliberately not built (ruled out of v1 or named follow-ons): restore /
promote a version on the wire (R-13nb-26 (d)), references read, callout
carry, deleted comments, Compare targets (VX-130), a side-pane show; the
tray's preserved-originals and archived-blocks sections as tray reads
(P-13nb-U4-5 — originals surface through `with_lineage`).** Session:
opus-implementer, 2026-10-10, cut from `f4078d61`; closed at the commit
carrying this record. **Finals (headless, the whole package, on `61f9f48e`):
core 2,580/295 · VariorumMCPTests 61/8 · workbook 40/6** — only the
long-standing gated skips; the Mac app builds (codesign clean). Baseline (the brief's): core 2,564/294 · VariorumMCPTests
45/6 · workbook 40/6, headless. Read whole before the first line of code:
this plan top to bottom (R-13nb-1…26, AF-1…AF-10, the U1/U2/U3 records and
live rounds), the memo, the format-schema prep, all six ladder records, the
13n sitting record, SessionResiliencyProtocol, and the code the brief names
(+ the tray/versions/lens/lineage queries, the restore ops, the rule-editor
door, the landing roads: `ShellRouter.adopt`, `PostDetailView.jump`,
`CommandRouter.pendingTakesLanding`, `TakesViewModel.addLensColumn`,
`BookViewModel.requestReveal/requestChapterReveal`, `StatusCenter`).

### Pieces

| # | Piece | Status |
|---|---|---|
| S0 | This record + the FORK message (below) to the orchestrator | DONE (this commit) — forks F-1…F-4 sent; F-1/F-2/F-3 GATE their halves (book-rule WRITE; the offer door's class + chord; show_in_app's shape), F-4 is non-gating (built PROVISIONAL meanwhile) |
| S1 | Core: `put_back`'s acts (block + take, client-named undo, in-transaction guard), `save_version` relabeled, `set_entry_date` (undo + guard), file-into-chapter (PROVISIONAL), `set_book_rule` (AF-11 F-1) | DONE (`bcc83cb2`) — `MCPCarriageActsTests` 16/16; the four rule/section setters' row work extracted byte-identically (related core suites 215/40 green) |
| S2 | The read carriage on the wire (AF-11 F-4): tray, lineage + ancestry (the uniform-stub rider), archived reach, lenses, versions list/read, book facts on list_books | DONE (this commit) — `MCPCarriageServerTests` 9/9 |
| S3 | The write tools on the wire: put_back · set_entry_date (edit), save_version · file_note_in_chapter · set_book_rule (write new) + rung proofs | DONE (this commit) — the U2 suggest PROOF and the U3 edit-half PROOF grown as the ritual (justified edits); VariorumMCPTests 54/7 |
| S3b | The J8 refusal words (AF-11 F-1 approved): `lockedReading` joins the Mac table (her `ReadingsViewModel`/`DeletionRefusal` sentence) + its put-back twin `blockNotDeleted` joins the shared table ("That block is already back.") | DONE (`2f6cc53d`) — BOTH RED-ON-OLD (`MCPNavigationTests.aFinishedBooksAndAnAlreadyBackBlocksRefusalsSpeakTheAppsWords`: 2 issues on the pre-fix tables — the raw-enum fallback), green after; plus the wire's own words for the op refusals only the connected road meets (`MCPWireRefusalCopy`: postNotInReading · sectionNotFound/NotInReading · invalidTagName — new-door copy, pinned) |
| S4 | Book-rule WRITE (AF-11 F-1) | DONE — folded into S1/S3 |
| S5 | NAVIGATION (AF-11 F-2/F-3) | DONE — server half `68bffde8` (`MCPShowRule` + `show_in_app` + `MCPHostHooks.show` + every receipt's `show` target; `MCPShowServerTests` 5/5); app half `da884d05` + pins `2f6cc53d` (`MCPNavigator`, `MCPDoor.agentShow/openShow/showLastChange`, the Lenses/Takes/Book landings, "Open ›" on the receipt, ⌥⌘O; `MCPNavigationTests` 7/7) |
| S6 | End of unit: headless suites, Mac focused suites (stage), the pre-flight walk (stage, both voices), record final | DONE — headless finals above; **Mac (stage held, `-only-testing`): 212 tests / 19 suites, 0 skipped** — MCPNavigationTests, CapabilityRegistryTests, ChordLegibilityTests, HelperCurrencyTests, MCPPaneTests, MCPAskAndReceiptTests, MCPEditFacesTests, ConfirmationsSettingTests, OpsRefusalTableIntegrityTests, VocabularySweepTests, CommandRoutingTests (+ TakesLandingTests), BookAscentTests, BookOutlineLandingTests, CompareLensesCorrectionTests, ShellDoorOwnershipTests, PaneSplitTests, DoorSetTests, StatusCenterTests, BookViewTests, TrashPurgeDoorsTests, RecoveryDoorsTests, NoteTrayTests, SettingsShapeTests (some names are files holding differently named suites — 19 suites ran); the walk below; one walk fix (W-1, `67e7f2eb`) and one self-review fix (`61f9f48e`, red-on-old) |

### Forks returned to the orchestrator (2026-10-10) — RULED as AF-11 (`aeea9dbf`), built as ruled

- **F-1 — the book-rule WRITE's refusal set (GATES item 7's write half).**
  The brief's premise is that "gatherings/finished/sealed/wrong-kind refuse
  as hers do". Traced: `setReadingQuerySpec`, `setReadingOutflow` and
  `setReadingIntakeSeating` do NOT refuse a finished or sealed book, and her
  Book Settings ▸ Edit… door is open on a finished book (13i §5: a finished
  book's text and rule stay editable; intake pauses and the un-finish
  catches up). Gatherings are unreachable on the wire entirely (no facts —
  P-13nb-U1-4 — so the one `notShared` answer; the outflow op's
  `wrongReadingKind` is never reached). So the only spec-defensible build
  that adds NO validation path is: **(a, RECOMMENDED)** `set_book_rule` =
  her rule editor's ONE Save projected — optional `rule` · `outflow` ·
  `new_matches` in one call, written in her editor's order (dial → outflow →
  rule) in one runner turn, ONE client-named undo entry (restores the three
  fields exactly; seats/bells the rule's intake made STAY — §19, the
  P-13nb-U2-6 precedent); a finished/sealed book's write LANDS as hers does
  and the answer says intake is paused until she reopens it. Tags addressed
  by PATH in the stored grammar's own keys (`and`/`or`/`not`/`tag`/`star`,
  a path where the store holds an id), a missing path minted in the book's
  wing (her editor's make-in-place, apply_tag's precedent); legacy terms
  refuse on write (never offered, #166(d)); a malformed stored rule refuses
  as her editor does. **The walk's "refused on a finished book in the app's
  words" leg** then rides the finished-book refusal that EXISTS —
  `create_section` / file-into-chapter (`lockedReading`) — and on the way I
  found a real J8 defect: `lockedReading` has NO words in `OpsRefusalCopy`,
  so the wire (U3's `create_section` today, and every Mac door routed
  through the table) speaks `Refused: lockedReading(id: "…")`. Fix: the
  Mac table gains the generic sentence her `ReadingsViewModel` already says
  ("This book is finished — reopen it first; if it's sealed, unseal it."),
  red-on-old. **(b)** the wire refuses rule writes on finished/sealed books
  — a NEW validation path the brief forbids; needs her word. **(c)** read
  facts only, write deferred to a ticket.
- **F-2 — the OFFER door's class and its chord (GATES the receipt half).**
  18i's class letter says a message carrying a button is an OFFER (always
  toasts, never governed by her `receipt_style`). R-13nb-23 (a) puts a door
  on the WRITE RECEIPTS. **(a, RECOMMENDED)** they stay RECEIPTS (her setting
  still decides where/whether the line shows — quiet by default) and carry
  the door: the quiet line and the toast both render "Open ›"; the keyboard
  chord is a registry act "Show the AI's last change" that opens the most
  recent MCP write's target THIS SESSION (the receipt's own door, kept after
  the line fades — a 6-second line is a mouse race for a keyboard user, and
  under "off" there is no line at all), grey when none; chord candidate
  ⌥⌘O after a collision sweep (yours to veto). **(b)** they become OFFERS
  (always toast — her quiet default overridden for AI writes). **(c)** the
  chord acts only while the line is on screen.
- **F-3 — show_in_app's shape (GATES the app delivery).** Proposed:
  READ rung (decided on the target at read, never spending a once grant —
  showing discloses and changes nothing), listed whenever any read reach
  exists; targets `note` (+ `block_id`, + optional `select` words → the 13o
  find seed verbatim: selected + find bar armed + comfort band), `takes`
  (note + block → her "see takes" road: `pendingTakesLanding.bloom` +
  `requestMode(.takes)`), `lens` (note + lens id → Lenses mode, the lens's
  column focused if shown, else appended — her "+ Column → lens" door —
  and when the board's four columns are full, the LAST column replaced, her
  R83 swap door; PROVISIONAL), `book` (+ optional `section_id` → Outline's
  chapter landing, `requestChapterReveal`); a target the client cannot read
  answers the one `notShared`. **Not frontmost ⇒ an honest refusal** ("The
  author isn't in Variorum right now — nothing was moved."), never queued;
  frontmost = `NSApp.isActive` AND the key window is a FULL window (a
  note-only or quick-note window key ⇒ refuse rather than raise another
  window — "no window raising"). The pure decision lives in `VariorumMCP`
  (pinned headless with a fake hook); the app answers the hook.
- **F-4 — the read carriage's call shapes (NON-gating, built PROVISIONAL).**
  Every new READ reach rides `read_note`'s structured view as explicit
  parameters (AF-5's precedent; the memo §4's "the lean tool set's five read
  tools" unreopened): `with_tray` (deleted blocks + deleted takes, the
  30-day family), `with_lineage` (direct derived_from/version_of edges per
  block + `parent_take_id` per take; a peer in a note the client cannot read
  carries NO ids — AF-10 (f)'s names-stay-with-grants applied to ids),
  `include_archived` (archived takes, marked), `with_lenses` (every lens:
  id, name, picks per block), `with_versions` (the note's moments) and
  `version_id` (read one moment, decided on its NOTE's grant). Book facts
  (rule/outflow/new matches/extents/finished/sealed/owned) ride
  `list_books` rows. `include_archived` on `list_books`/`list_notes`/
  `search` with the FACET's default — archived OUT unless asked — which
  FLIPS two U1 behaviors deliberately (`list_books` lists archived books
  today, flagged; `list_notes(book_id)` lists archived members today); pins
  updated as the ritual.

### PROVISIONALs (for the merge QUESTIONS bundle)

- **P-13nb-U4-1 — the carriage rides `read_note` params** (AF-11 F-4,
  concurred PROVISIONAL): `include_archived` · `with_tray` · `with_lineage`
  · `with_lenses` · `with_versions` · `version_id`, each implying the
  structured form; none rides the Level 0 text. `version_id` reads a moment
  on its NOTE's grant (asked only after the note is allowed; another note's
  moment refuses "isn't a saved version of this note"); a version itself has
  no facts (the one answer by its own id).
- **P-13nb-U4-2 — the carriage's words** (P-13nb-U2-5's family, 13s-a
  sweepable): undo labels "<client>'s put back / version / date / chapter
  filing / book rule"; receipts "put back a block|a take" · "saved a
  version" · "dated the note <day>" / "cleared the note's date" · "filed a
  note under “…”" / "unfiled a note" · "changed what “<book>” collects";
  the wire's own sentences (`notInTrayWords`, `intakePausedWords`,
  `legacyTermWords`).
- **P-13nb-U4-3 — the two U1 list flips** (AF-11 F-4's deliberate flips):
  `list_books` drops archived books and `list_notes(book_id)` drops
  archived members unless `include_archived` — and `list_books`' count
  follows (the count IS the listing's extent either way); reach untouched
  (an archived note or book answers under its grant by id).
- **P-13nb-U4-4 — search's `include_archived`** = the facet's letter
  (`includingArchived`: living AND archived, each passage marked) — built
  as the brief asked, PROVISIONAL (R-13nb-10 left the archived facet
  UI-only; the sitting carried the inventory row).
- **P-13nb-U4-5 — the tray's reach on the wire** is the LEAVING section
  only (deleted blocks + deleted takes — the brief's "the app's 30-day-clock
  family"); her tray's preserved originals and archived blocks are NOT a
  tray read (a released original of the note DOES surface, with its text,
  as a lineage far side — `with_lineage`). Each list caps at 200 with
  `truncated`.
- **P-13nb-U4-6 — `put_back` refuses what her tray does not offer**: a block
  still deleted must be in its note's tray listing (30 days, no purge
  intent, never a deleted note's cascade victim) — in the act's transaction;
  else "That isn't in the note's tray any more…". An item already back is
  decided on the note it is back in and speaks the op's own "already back".
- **P-13nb-U4-7 — lineage's shape** (AF-11 F-4 + the RIDER): DIRECT live
  edges only (`derived_from` / `derived_into` / `version_of`), the far side
  as the client may know it — a block of this note · a RELEASED ORIGINAL of
  this note (with its text) · a block of one of its saved versions
  (`version_id`) · a block of a note the client can read (`note_id`) · else
  the ONE uniform stub `{"relation": …, "beyond_grant": true}` — no id, no
  title, no kind, no origin_op, no stamp (pinned byte-identical across a
  fenced, an unshared and a scrap far side). Take ancestry mirrors it
  (`parent_take_id`, + `parent_version_id` / `parent_note_id`, else
  `parent_beyond_grant: true`). A dead far side is left out (the lineage
  walks' live-endpoint rule). *Ladder round 1 amendment (F-6, record-fix
  ruled over a liveness filter — the implementer's analysis adopted): the
  live-endpoint rule is LINEAGE's (dead blocks never meet a live edge — the
  delete cascade tombstones edges); ANCESTRY answers by the parent's BLOCK —
  a dead block collapses into the stub (omission would mint a liveness
  oracle on unshared notes, against the F-4 rider's spirit), and a dead take
  on a live block keeps its id — the parent classified by its block AS ANY
  PARENT IS (this note's block → the id, in-family the tray's own `put_back`
  address; a readable note's block → id + `parent_note_id`; a block beyond
  the grant → the stub; the sanity pass's precision, 2026-10-10).*
- **P-13nb-U4-8 — `set_book_rule`'s shape** (AF-11 F-1): one call = her
  Save's three optional fields; the three writes in ONE transaction (her
  Save is three — stricter only in that nothing half-lands); a legacy term
  in the written rule refuses (`legacyTermWords`); an unreadable stored rule
  refuses ANY rule write with her editor's own notice while the dial and the
  outflow still land (*ladder round 1 amendment, F-7 — said exactly: a call
  WITHOUT a rule still lands dial and outflow over the unreadable rule; a
  call CARRYING a rule refuses WHOLE, dial and outflow included — nothing
  half-lands, pinned. Her Save differs in face, not law: it greys the rule
  half and lands dial+outflow because it HAS a face to grey; the wire has
  none, so the honest mirror is the whole-call refusal with her notice —
  `RuleEditing.needsWrite`*);
  undo restores the three columns and never evicts. Verified, not assumed:
  her ops and her Edit… door LAND on a finished AND a sealed book
  (`.editRule` is `always`; no op refuses) — both pinned.
- **P-13nb-U4-9 — `file_note_in_chapter`** (P-13nb-U3-8's U4 candidate,
  built PROVISIONAL): write new, scopes book · wing, the book AND the note
  each decided at write new inside the act's transaction (a note the client
  cannot reach is never reorganized); `section_id: null` unfiles.
- **P-13nb-U4-11 — the lens target's column rule** (AF-11 F-3, logged as
  ruled): the lens's column if one shows it; else a new column (her "+
  Column → lens"); else, four columns full, the LAST column swapped in place
  (her R83 door) — `TakesViewModel.showLens`, pinned.
- **P-13nb-U4-12 — show_in_app's words and shape**: READ rung, listed with
  any read reach, never spending a once grant; a refusal is the whole answer
  (`MCPShowRule.notFrontmostWords` / `otherWindowWords` /
  `unavailableWords` — the MCP room's technical register, 13s-a sweepable);
  frontmost = `NSApp.isActive` AND `NSApp.keyWindow` is a REGISTERED FULL
  window (`WindowRegistry.entry(for:)` — Settings, a note-only or quick-note
  window key ⇒ `frontmostOtherWindow`, refused). The tool's description
  tells the client to call it only when she asks; "never automatic" is
  enforced as "only an explicit client call" (the server cannot know who
  asked).
- **P-13nb-U4-13 — the receipt's door** (AF-11 F-2): the word "Open ›"; the
  line stays a RECEIPT (quiet / toast / off per her setting); on a crowded
  bar a door-carrying line truncates in the MIDDLE so "⌥⌘Z undoes" survives
  (walk W-1); where each act's door goes (`MCPWriteReceipt.show`): a take or
  a put-back take → the note's Takes at the block; a comment, edit, divide,
  merge, move, block name, put-back block → the note at the block; a lens →
  the Lenses board; a note mint, import, tag, version, date, delete → the
  note; a book mint/import, rule → the book; a chapter, a filing, an add to a
  book → the book at that chapter. An `.unplaced` put back has no door.
- **P-13nb-U4-14 — her press raises a window when it must**: a receipt's
  "Open ›" and ⌥⌘O deliver into `WindowRegistry.creationRouter()` (raising
  the full window when a note-only window is key — her creation doors' own
  rule); only the AGENT's show is barred from raising.
- **P-13nb-U4-15 — "Show the AI's Last Change"** (⌥⌘O, AF-11 F-2): menu
  verb in Title Case beside ⌥⌘Z in the Edit menu, the ⌘/ helper row "show
  the AI's last change (what a connected client last wrote)"; app scope,
  `takesAccess: nil` (the app-scope exemption); session-scoped `lastShow`,
  alive after the fade and under receipt style off; with none, the
  unavailable note is spoken.
- **P-13nb-U4-10 — `set_entry_date`** is EDIT (R-13nb-26 (b)), allowed under
  a seal exactly as her own date door (N34's class); `null` un-dates; a
  journal-fenced note refuses per the rule (pinned: the fence governs from
  the moment SHE files the note in a journal book). Watch item, recorded:
  her op never refuses a day another journal entry already holds (the
  notebook rule's converged double-create case) — the wire mirrors it.
- **P-13nb-U4-16 — AN AGENT-WRITTEN RULE BELLS, NEVER BACKFILL-SEATS (the
  ladder round 1 MAJOR, the reviewer's fix — hers to ratify or reverse in a
  word):** `set_book_rule`'s rule write passes `sweepOccasion: .catchUp`
  through her choke point, so its sweep BELLS whatever the book's rule
  history. The trace that forced it: a rule set on a rule-less book was
  BACKFILL and backfill SEATS — matching notes became MEMBERS, a book grant
  reaches members (`MCPGrantRule.reaches`), so a client with write-new on
  one book could expand its OWN read reach to every unshared matching note
  in the wing (two calls past an existing rule: clear, then re-set), and
  the honest member count doubled as a how-many-notes-wear-this-tag oracle.
  Backfill's canonical warrant is "birth = intent" — HER authorship, which
  an agent's call does not carry; the one-note roads (`add_note_to_book`,
  `file_note_in_chapter`) double-decide to prevent exactly this pull. Her
  own Save keeps backfill untouched (pinned both ways); the answer says
  where the matches went (`matches_wait`, unconditional on a landed rule —
  never per-match, no oracle). **The named RESIDUAL (the implementer's,
  recorded for the same bundle):** once an agent-written rule stands with
  the dial at join, HER later applying acts (tagging, starring) seat
  matching notes, and those members then fall inside the book grant's
  reach — her own act under the standing book-grant-reaches-members rule;
  it stays, and the bundle says it.

### Decisions within the mandate (recorded as they land)

- **Every new act takes the in-transaction guard** (AF-10 (a) carried):
  `put_back` re-resolves the item's home on the act's own rows (the tray's
  `last_container_id` while deleted, its placement once back), decides at
  EDIT and checks tray membership there; `save_version` decides the note at
  write new; `set_book_rule` / `file_note_in_chapter` decide the book (and
  the note) at write new — every once grant spent atomically with its act.
- **`restoreBlock` / `restoreVariant` gained a defaulted `guardedBy:`**
  (nil on her doors — the U3 precedent); `performDeleteBlock` /
  `performDeleteVariant` widened private → internal for `put_back`'s
  inverse; `assignPostToSection`, `setReadingQuerySpec`,
  `setReadingOutflow`, `setReadingIntakeSeating` now wrap row functions the
  MCP acts share — byte-identical behavior (their suites green unmodified).
- **The answer encoder refuses a non-JSON value** instead of letting
  `JSONSerialization` raise an Objective-C exception that would take the
  APP down (found when a `Date` reached it in a test — the server's two
  `encode`s now check `isValidJSONObject` first).
- **The harness clock:** `MCPHostHooks.now` (default the wall clock) feeds
  the tray's 30-day window; the server harness passes its world's "now".
- **Navigation is composition over her roads, never a new mechanism**
  (P-4): the note target is `ShellRouter.adopt(_:in:landing:find:)` (the 13o
  passage road verbatim); takes = open the note (the adoption door), wait
  for its detail to register (bounded 2 s), then her see-takes pair
  (`pendingTakesLanding = .bloom` + `requestMode(.takes)`) — a board ALREADY
  mounted consumes the parked landing on its change
  (`TakesViewModel.consumePendingTakesLanding`); lens = the same open + a
  parked, post-stamped `LensLanding` the Lenses board consumes (appear +
  change), cleared by `registerDetail`/`unregisterDetail`/`noteMode` exactly
  as `pendingTakesLanding` is; book/chapter = the adoption door to the book
  + `ShellRouter.pendingBookChapter` handed to `BookView.revealSectionID`,
  which switches to Outline and calls her one chapter-landing door
  (`requestChapterReveal`). No editor-seam file touched
  (`EditorTextView` / `BlockRangeIndex` / `PaneSurface` untouched).
- **⌥⌘O's collision sweep** is recorded where the chord is bound
  (`EditorCommands.keyEquivalent`): free across the table, every
  `.keyboardShortcut(` in `Variorum/` + `Shared/` (no `o` chord at all), the
  `NSMenuItem` keyEquivalents (none), the key overrides, and the system's
  global chords / the Cocoa text bindings.

### The U4 pre-flight walk (dev-store Debug build `DerivedData/vx124-u4`, 2026-10-10 ~01:58–02:50, under my own stage claim — the orchestrator's live real-client round is still owed)

Captures (gitignored): `notes/plans/13n-b-screens/u4/01…20-*.png`; the
scripted client's transcripts `client/out-01…17-*.txt` + the client
`client/mcpwalk.py` (U3's — spawns the REAL embedded shim over stdio; the
walk reused the approved `u3-walk` client and its edit-always grant on "o
ladrão de raios"). Author guard + per-step guard throughout; her
`/Applications` app never running; my instance quit by identity each time
(socket gone after). AX + Screen Recording held by this host (probed first).

- **Study.** **01** "o museu" open. `out-05`: `delete_block` (the middle
  block) → `read_note with_tray` lists it with its text → `put_back` →
  `landed: its_old_place`; **02** the block back in its own place and the
  quiet receipt "u3-walk deleted a block and put back a block · ⌥⌘Z undoes
  Open ›". **03** ONE ⌥⌘Z → "Undid: u3-walk's put back", the block back in
  the tray (⌫1); **04** a second ⌥⌘Z → "Undid: u3-walk's delete", the note
  whole (the walk's restore).
- `out-06`: `save_version` → `with_versions` lists it; **05** Note ▸
  Versions shows the moment ("Oct 10, 2026 at 2:01 AM · 3 blocks"); **06**
  ⌥⌘Z → "Undid: u3-walk's version", the pane empty (restored).
- **show_in_app, frontmost** (`out-07`): **07** posfácio opened in Write
  with "texto de exemplo" SELECTED and the find bar armed — the 13o road.
  **Backgrounded** (Finder frontmost, `out-08`): REFUSED "The author isn't
  at Variorum right now, so nothing was moved — …"; **08** the dev window
  inactive and unmoved.
- **The offer door from the keyboard** (`out-09`): on the Bookcase, the AI's
  `add_take` → **09** "u3-walk made 4 changes · ⌥⌘Z undoes  Open ›"; **09b**
  the line faded; ⌥⌘O → **10** "o museu" in Takes with that block bloomed
  and "u3-walk · suggested · walk" at the fan's end; **11** ⌥⌘Z undid the
  take.
- **The finished-book refusal in the app's words** (her row menu ▸ Finish,
  then `out-10`): `file_note_in_chapter` and `create_section` both REFUSED
  "This book is finished — reopen it first; if it's sealed, unseal it." (the
  J8 fix, live); `set_book_rule` on the same finished book LANDED with
  `intake_paused` said (AF-11 F-1's mirror, live); **13** ⌥⌘Z → "Undid:
  u3-walk's book rule" (`out-11`: rule null again); the book Reopened by her
  menu (restored).
- **More targets**: **14** `show_in_app` book + chapter → the book opened in
  Outline (on this short book every chapter fits the page, so "the chapter
  at the top" cannot be seen — Outline's own landing, pinned upstream);
  `save_lens` then **15** `show_in_app` lens → "abertura" on the Lenses board
  with a "walk lens" column + its receipt; ⌥⌘Z undid the lens.
- **Terminal.** **16** `show_in_app` at a block with "vasos gregos" selected;
  **17** an AI comment's receipt — **W-1 found here**; **18** Bookcase,
  fade, ⌥⌘O → "posfácio" at the block, the AI comment in the gutter; ⌥⌘Z
  undid it; **19** the Edit menu: "Redo u3-walk's comment ⌥⇧⌘Z" and "Show
  the AI's Last Change ⌥⌘O". After the W-1 fix (rebuild, relaunch): **20**
  the same crowded bar reads "u3-walk left…· ⌥⌘Z undoes  Open ›"; undone.
  Voice restored to Study (read back by AX: Study selected).

**The walk's one finding — FIXED (`67e7f2eb`):**
- **W-1** — beside a live selection's word count (Terminal, capture 17) the
  door's width pushed the receipt's tail off the bar: "u3-walk left a
  comment ·… Open ›" — the "⌥⌘Z undoes" the U2 walk's W-2 protects was the
  part truncated. A door-carrying receipt now truncates in the MIDDLE
  (capture 20); door-less receipts keep their tail truncation. Not pinnable
  headless (a rendered width fact).

**LEFT in the dev store (deliberate, harmless):** nothing of the walk's
rows — every write was walked back by ⌥⌘Z and the book reopened; the
`u3-walk` client and its grants as U3 left them; activity lines for the
walk's calls; "abertura"'s Lenses view memory holds the scratch column the
undone lens left (local view state); the Open strip's notes. Server ON,
voice Study.

### Open items for the orchestrator

- **The live acceptance leg** (the W-series equivalent with a real Claude
  Code client): `read_note with_tray` → `put_back` → ⌥⌘Z; `save_version` →
  Note ▸ Versions; a finished book's `create_section` refused in the app's
  words + `set_book_rule` landing with `intake_paused`; `show_in_app` at a
  block with Variorum in front and again with it behind; an AI write, the
  line faded, ⌥⌘O.
- **QUESTIONS at merge:** P-13nb-U4-1…15.
- **An observation, pre-existing (U2's receipt run), not fixed:** the
  coalesced run counts acts she has since UNDONE — capture 09 reads "u3-walk
  made 4 changes" where three of the four had been walked back (an undo
  never resets `MCPDoor.receiptRun`). J8-adjacent copy truth; a one-line
  reset on undo, or a ticket — yours to call.
- **The closeout's canon delta:** AF-11 F-2's 18i nuance (an AI write line
  is a receipt that carries a door).
- **Follow-on tickets at closeout** (R-13nb-26 (d)/(e)): restore/promote a
  version on the wire, references read, callout carry, deleted comments.

### Self-assessment (the implementer's, before the cold review)

- **The carriage reads are pinned end to end and the rider is real:** a
  fenced, an unshared and a scrap far side produce one byte-identical stub
  (mutation-checked: a stub that leaks the block id goes red).
- **Mutation checks (4 breaks, all caught):** `restoreBlock`'s guard call
  removed → the put-back guard pin red (3 issues); the beyond-grant stub
  carrying the far block's id → the rider pin red; `show_in_app` spending a
  once grant → the never-spends pin red (4 issues); `list_books`'
  `include_archived` defaulting true → the U1 flip pin red. Each restored
  from the committed tree.
- **What self-review caught after the walk:** `file_note_in_chapter`'s two
  sequential in-transaction guards spent a once WING grant in the first and
  refused the second — a once write-new wing grant could never file a note
  (`61f9f48e`, red-on-old 2 issues).
- **What the walk caught that no pin could:** W-1 (a rendered width).
- **Scope held:** zero lines in `Sources/VariorumCore/Sync/`, `Server/` or
  `Persistence/` (no migration, `lockstepVersion` untouched), zero custody,
  zero editor-seam files, the export pin intact, zero trailers (all
  re-checked over `f4078d61..HEAD`).

**For the cold reviewer, where to look first:** (a) `MCPWriteTools+Carriage`
— every act's in-transaction guard (`trayGuard`'s home re-resolution on the
act's own rows, `guardBookAndNote`'s union spend) and whether any write
reaches past the rung or the scope; (b) `Operations.setBookRule` against her
Save (`RuleEditorModel.save`): the three writes, their change tests, the ONE
transaction, the adopt-or-mint path resolution, and the undo's raw column
restore (no intake, seats stay); (c) `MCPNoteStructure.lineage`/`parents`/
`farSides` — the far-side classification and the stub's uniformity
(especially versions: `isVersionHistory` per placed far container); (d)
`MCPDoor.agentShow` + `currentStanding` + `MCPNavigator.open`'s bounded wait
(a note that never registers just gives up — the client was already told
"shown"? NO: `agentShow` awaits the delivery and answers `.navigate` after
it, but a timed-out open still answers navigate — worth a look); (e) the
two U1 list flips and the `recencyPage` version fence under
`include_archived`; (f) the receipt door's shape in `QuietReceiptLine`
(idle stays zero-width; the middle truncation only when a door rides).

### Machinery notes

- No session death; no other writer in the worktree except the
  orchestrator's AF-11 ruling commit (`aeea9dbf`, plan file only — pulled
  with my uncommitted core edits stashed and popped cleanly).
- Stage: claimed for the first Mac runs, renewed for the walk (150 min),
  released after the final Mac run. TCC on this host: Accessibility +
  Screen Recording held (probed before the walk); no prompt raised or
  answered.
- Walk lessons: a FULL-SCREEN capture (taken once to see a context menu)
  showed her desktop — deleted at once, never kept; menus are captured with
  `screencapture -R` over the menu's AX frame instead (capture 19). The
  `show_in_app` frontmost leg needs nothing special: a client run from the
  shell does not activate the terminal.

## U4 LIVE ROUND (orchestrator, 2026-10-10 — the acceptance's real-client leg; stage held and released)

Fresh Debug build from HEAD `06386f9e` (`vx124-u4live`, codesign clean,
`io.lduarte.Variorum.debug`); the real Claude Code client via the throwaway
`-s local` scratch registration (removed after; her user scope untouched).
Claims verified before the round (ledger row 14: the clean whole-package
rerun, the fences, the walk evidence). The round, live:

1. **The tray and put back:** `delete_block` (the middle block of "o museu")
   → `read_note with_tray` listed it WITH its text (and the U4 walk's
   residual deleted take, untouched) → `put_back` → `landed:
   its_old_place`; the note read whole on screen. ONE ⌥⌘Z: **"Undid:
   claude-code's put back"** — the block back in the tray (⌫1 on the bar);
   a second: **"Undid: claude-code's delete"** — the note whole again.
2. **The version:** `save_version` → `with_versions` listed the moment;
   Note ▸ Versions showed "Oct 10, 2026 at 2:50 AM · 3 blocks" with its
   preview line; ⌥⌘Z → "Undid: claude-code's version", the pane back to
   "No saved moments yet".
3. **The finished book:** finished by HER row menu (the receipt: "Finished
   “o ladrão de raios” — its table of contents is done; the writing inside
   can still change."). `create_section` REFUSED verbatim **"This book is
   finished — reopen it first; if it's sealed, unseal it."** (the J8 fix
   live through a real client); `list_books` carried the facts (rule null ·
   outflow [] · new_matches join · finished true); `set_book_rule` LANDED
   (`changed: true`, the rule stored) with the intake-paused sentence said
   in the answer (AF-11 F-1's mirror, live). ⌥⌘Z → **"Undid: claude-code's
   book rule"** — and the book STAYED finished (the undo restores the three
   fields, never her finish). Reopened by her menu (Finish's slot read
   Reopen).
4. **show_in_app, frontmost and refused:** with Variorum frontmost, the
   note target with `select: "vasos gregos"` → `{"shown": true}` — landed
   in Write with the words SELECTED and the find bar armed ("2w selected"
   on the bar), the 13o road verbatim. With Finder frontmost, the SAME call
   REFUSED: **"The author isn't at Variorum right now, so nothing was moved
   — showing happens only while Variorum is the app in front. Ask her to
   switch to it, then call again."** — nothing moved, never queued.
5. **The keyboard door past the fade:** `add_comment` landed while the app
   was backgrounded (writes need no frontmost — only showing does); on the
   Bookcase ~8 s later, the line long faded, **⌥⌘O** opened "o museu" at
   the block with the comment in the gutter; ⌥⌘Z → "Undid: claude-code's
   comment".
6. **Lifecycle:** quit by identity (socket gone); registration removed;
   stage released.

**VERDICT: U4's acceptance bar is MET live.** Dev-store residue: NONE of
the round's rows (every write walked back; the book reopened by her door);
the grants exactly as U3 left them; activity lines for the round's calls.
Round captures: the scratchpad's `u4-liveround/cap-00…14` + client
transcripts `out-s1…s5` (ephemeral; this section is the record). One
capture that caught a strip of the dock was deleted at once (the walk
lesson held). Next: the U4 ladder round 1 (`fable-reviewer`, the
cross-model flow verbatim).

## R-13nb-27 — HER RATIFICATION OF THE AF-11 F-2 RECEIPT-DOOR RULING (2026-10-10, mid-U4-ladder)

The author pasted the orchestrator's AF-11 F-2 summary back with the words
**"I ratify this:"**. The ratified paragraph, verbatim as pasted:

> What "write receipts grow a one-press door" means. It's your own ruling's
> letter from the format-schema sitting (R-13nb-23 (a)): those AI-write
> lines gain a press target — "Open ›" — one press and you're looking at
> the thing the AI just changed. The fork it raised (F-2): 18i's classes
> say a message carrying a button is an offer, and offers always toast,
> overriding your quiet default. I ruled the line stays a receipt — your
> setting keeps governing it, it just carries the door now — because
> silently reclassifying every AI write into a toast would trade your calm
> default away. And since a line that fades in six seconds is a mouse race,
> the door also has a keyboard road: "Show the AI's Last Change" (⌥⌘O),
> alive after the fade and even with receipts off. The one canon
> consequence — an AI write line is a receipt that carries a door — is
> queued as an 18i delta for the closeout, yours to ratify.

**What this settles:** the message-CLASS question is RATIFIED canon — an AI
write line is a RECEIPT that carries a door; `receipt_style` governs it;
the session-scoped keyboard road stands. The closeout's 18i delta lands as
a ratified contract line (no longer pending her word at the bundle).
**What stays open for the merge QUESTIONS bundle:** the TASTE details only
— P-13nb-U4-13 (the word "Open ›", per-act targets, middle truncation),
P-13nb-U4-15 (⌥⌘O's verb wording and helper row), and the chord itself
remains subject to her veto as any chord is.

## R-13nb-28 — HER OVERNIGHT MANDATE (2026-10-10, mid-U4-ladder-round-2)

Her words, verbatim: "excellent. continue the phase overnight, ruling
provisionally. Please prepare a handoff with explanations on how to test
and run this for me - I likely won't plan on waking your session again and
will go through everything with a new issue. I did start some bug tests in
the background, but told them to not merge to main - you have the stage for
reinstalling and simply generally, I don'tw ant to disrupt you. if you need
a fourth review you can have one."

**The orchestrator's reading (each leg provisional where her letter is
short, for her confirmation in the new issue):**
- **(a)** The phase CONTINUES overnight under the away-run doctrine:
  PROVISIONAL-and-continue everything short of an author-only hard stop;
  everything genuinely hers is HELD and BUNDLED into the handoff checklist.
- **(b)** The author handoff (`notes/handoffs/phase-13n-b-handoff.md`)
  gains a first-class **HOW TO TEST AND RUN** section — her own road into
  the MCP door (setup, grants, rungs, a suggested first round, the suites)
  — self-contained for a fresh session; her Percy-grade round and the
  ratification bundle ride a NEW issue; this session is not woken again.
- **(c)** Her background bug-test sessions are barred (her word) from
  merging `main`, so the closeout merge is clean to take; the closeout
  merges the PR per the ritual (merge commit) and hard-stops.
- **(d)** "You have the stage for reinstalling": the stage is this
  session's overnight, INCLUDING the install refresh. Read WITH the
  standing lockstep rule (the §12 pair never splits — an install refresh
  never strands her build ahead of the mirror): this authorizes the DEPLOY
  BUNDLE at this window — artifact 16 mirror → installs refresh → the
  SyncSpec §12 record with the marker verified 13 — IF AND ONLY IF the
  mirror road is executable without her hands (credentials already seated
  on this machine). If the mirror needs her hands, BOTH halves stay HELD
  and the handoff carries the exact two-command window for her. PROVISIONAL
  — the conservative reading of a one-word grant over a never-pre-authorized
  event.
- **(e)** The U4 ladder's cap extends to a FOURTH round at the
  orchestrator's discretion (the 13x precedent, her word).

**R-13nb-28 AMENDMENT (her follow-up, same sitting, verbatim):** "you can
also go ahead and replace my application when you're done / deploy - I'd
like to authorize that right now, so you simply use the PAT when it's
time. my phone should be available over wifi, if that doesn't work I'll
install the new one tomorrow."

Leg (d)'s conservative iff-clause is SUPERSEDED by her explicit word: the
deploy bundle is AUTHORIZED NOW for execution when the closeout reaches it
— the artifact 16 mirror (using the PAT seated for that road), the
/Applications replace (A1 safety copy first, zero-instance window,
codesign verify), and the phone's install over wifi, with her named
fallback (she installs tomorrow) making a phone that cannot be reached
overnight an ACCEPTED temporary strand — her word, recorded. The §12
record lands with the marker verified 13 on every side that deployed.
