# Phase 13n-b handoff — THE MCP DOOR (for the author; self-contained for a fresh session)

**Written at the overnight closeout, 2026-10-10, under R-13nb-28's mandate.
The one running record is `notes/plans/phase-13n-b-mcp-door.md` (R-13nb-1…28,
AF-1…AF-11, four unit records, eight ladder records, four live rounds); the
ratify bundle is QUESTIONS #209; the deploy window's record is
`notes/plans/13nb-deploy-checklist.md` + SyncSpec §12's marker-13 entry.
You said you'd open a NEW issue to go through everything — point it at this
file and #209.**

## YOUR CHECKLIST (the morning, ~10 minutes)

1. **Mac:** launch Variorum from `/Applications` (replaced overnight at your
   authorization — ⟨FILL: build number, marker 13⟩). Your first sync round
   should run clean; the only schema change is the two Private-mark columns.
2. **Phone:** open Variorum (⟨FILL: installed over wifi overnight / your
   tomorrow-fallback applies — install via Xcode or ask a session to run the
   devicectl road in the deploy checklist⟩). Its first round converges; a
   marker-12 phone visibly refuses to sync until refreshed — that's the §12
   grammar, not a bug.
3. **The both-directions proof:** edit one note on each device; each lands
   on the other at its next round.
4. **Try the door** — the section below. Budget 15 minutes for the first
   round; it's shaped like your fact-check and Percy work.
5. **Open the new issue** for your review round: the ratify bundle is
   QUESTIONS #209 (your taste calls are named there — the "Open ›" wording,
   ⌥⌘O's verb and the chord itself, P-13nb-U4-16's residual, A-4's boundary
   line below).

## HOW TO TEST AND RUN THE DOOR

### What shipped, in one paragraph

Your Mac app now carries an MCP server: any MCP client (Claude Code is the
proven one — every unit's live round drove the real thing) can read and
write your store, but ONLY through grants you give per client and per
place, only while the app is running with the switch on, and only through
the app's own operations — so every AI act lands in your Block History,
speaks on your status seam, and walks back with ⌥⌘Z saying the client's
name. Nothing syncs about the door itself: grants are local to this Mac.
The phone has no door; the only phone-visible change is the Private mark's
two synced columns (faceless there for now — MobileSoul PL-52).

### Turning it on

1. Settings ▸ MCP → the switch ON. (OFF kills the socket — a connected
   client loses the door mid-sentence, by design.)
2. Press **Copy setup command** and paste it into any terminal — it runs
   `claude mcp add -s user …` pointing at the app's embedded shim, so every
   Claude Code session on this Mac can see the server (user scope — you do
   it once).
3. Run `claude` anywhere. The variorum tools are listed once the app is
   running; with zero grants the client can LIST tools but reach nothing.

### Your first round (a suggested script, ~15 minutes)

1. **The ask road:** tell Claude "list my books." It gets nothing — and the
   MCP pane's queue shows the just-in-time ask (asks queue quietly; nothing
   ever interrupts your writing). Grant **read · one book ·
   while-connected** from the queue.
2. **Read:** "summarize the shortest note in ⟨that book⟩." Then: "read my
   journal from last Tuesday" — one uniform *not shared* answer. The fence
   never says WHY (a fenced note and a merely-unshared note answer
   byte-identically — no oracle).
3. **The Private mark:** note ▾ menu → *Private — never shared with AI* on
   some note in the granted book; ask for it — refused the same uniform
   way. (Books have the same mark; gatherings refuse it; privacy wins every
   tie.)
4. **Suggest:** grow the grant (the pane row's Change…) to **suggest**.
   "Add an alternate, tighter take on the second paragraph." It lands at
   the fan's end labeled "claude-code · suggested" — your text untouched,
   your chosen take still chosen. One ⌥⌘Z: "Undid: claude-code's take."
5. **Edit:** grow to **edit**. Let it edit a take — then open Block
   History: the edit is BRACKETED ("before claude-code's edit" / "after
   claude-code's edit" — the eighth auto-commit occasion, so you can always
   compare and come back). Ask it to edit the same take again after YOU
   type in it mid-flight and it refuses with the stale-text sentence.
6. **The receipt door:** after any AI write, the quiet line carries
   **Open ›**. Let the line fade, go somewhere else, press **⌥⌘O** ("Show
   the AI's Last Change", in the Edit menu) — you land at the thing it
   changed. This is R-13nb-27, which you ratified.
7. **show_in_app:** "show me that note at the phrase ⟨…⟩" — Write mode,
   words selected, find bar armed. Background Variorum and ask again — an
   honest refusal, nothing moves, nothing queues (your etiquette as law).
8. **Book rules:** "make ⟨book⟩ collect notes tagged #⟨tag⟩." The rule
   lands exactly as your own Save would — but matching notes WAIT AT
   ARRIVALS: an agent's rule write never makes members by itself (the
   ladder's one MAJOR, closed structurally — P-13nb-U4-16; the answer says
   it). On a finished book the write lands with "intake paused" said.
9. **The activity pane** (Settings ▸ MCP): every call, every refusal,
   every grant — the session's ledger.

### The four rungs (each includes everything below it)

- **read** — structured reads (notes, takes, books, lenses, versions,
  lineage, tray, search) within the grant's scope; `show_in_app`.
- **suggest** — new takes and comments ONLY (labeled, never chosen, your
  text untouched). The edit tools aren't even LISTED at this rung.
- **write new** — new notes/books/chapters/versions/tags, `save_version`,
  `file_note_in_chapter`, `set_book_rule`, imports in format v2.
- **edit** — `edit_take` (bracketed), divide/merge, `put_back`,
  `set_entry_date`, names/labels. The top of the ladder.

Scopes: a note · a book · a wing. Durations: **once** (exactly one write
call, spent inside the act's own transaction) or **while-connected** (the
task session). The rung is the ONLY read dial (R-13nb-17).

### The rails you can watch hold

- ⌥⌘Z after any AI act names the client, act by act; redo is client-named
  too. Nothing an AI does is outside the undo story.
- Journal-class notes and Private-marked things answer only a per-ask NOTE
  grant — never a book or wing grant, never silently.
- A once grant never stretches: one write call, atomically.
- `set_book_rule` can't grow the client's own reach (the bell).
- The app's words are the wire's words: refusals come from your own
  refusal tables (the J8 fix made `lockedReading` speak your sentence).
- A-4, the honest boundary: client identity is SELF-DECLARED (a client
  says "I am claude-code"); the pane says so. Grants gate what a NAME can
  do; they cannot authenticate the name. This is the recorded limit of the
  design — worth two minutes of your judgment at the review.

### Running the suites

- **Headless (free, no stage):** `cd ~/dev/variorum && swift test` — core
  2,580/295 · VariorumMCPTests 65/8 · workbook 40/6. Known: VX-132 (the MCP
  socket harness can hang intermittently — ctrl-C and re-run); VX-134 (a
  transient whole-package core failure, twice seen, never reproduced —
  capture the full log if you meet it).
- **Mac suites (need the stage):** `Tools/stage claim …`, then
  `xcodebuild -scheme Variorum -destination 'platform=macOS' test
  -only-testing VariorumTests/MCPNavigationTests` (and friends:
  MCPPaneTests, MCPAskAndReceiptTests, MCPEditFacesTests). The WHOLE
  VariorumTests target at this closeout: ⟨FILL: final count⟩ — the one
  standing red is VX-115 (a stale pin on main since 13o, ticketed, not this
  phase's), plus VX-149 (redoNeverAsks fails under the whole target only;
  green in isolation — order-sensitivity recorded).
- **The dev store vs yours:** everything above runs against YOUR real
  store once you use the installed app — that's the point of your round.
  The suites and any session walks use the fenced dev store
  (`io.lduarte.Variorum.debug`).

## STATE AT CLOSE (the facts)

- **The ladder:** four units; every unit's ladder closed CLEAN at round 2
  (cross-model flow verbatim; U2's MAJOR: the Private-mark fold
  classifiers; U4's MAJOR: the rule-write reach expansion → the bell).
  Four real-client live rounds, all MET.
- **Headless finals:** core 2,580/295 · VariorumMCPTests 65/8 · workbook
  40/6 (re-proven by the round-2 reviewer's own run, re-confirmed at the
  tip).
- **The whole-target run:** found four reds; triaged — VX-115 (known, not
  ours), VX-149 (ticketed, isolation-green), and two fixed in-branch (the
  status-vocabulary sweep's `.speak(` doors renamed classed — one ours, two
  13n-a residue; the stamp-phase pin's justified update after U1's shim
  embed). ⟨FILL: re-run final count⟩.
- **The deploy:** ⟨FILL: window facts — marker 13 verified, grant sweep,
  /Applications build, phone install or fallback⟩.
- **Merged:** ⟨FILL: PR number + merge commit⟩. Canon landed: AppSpec §7
  (Private columns + grants family), §12 (THE MCP DOOR line; the KIND
  line's R-13nb-27 amendment), §14; MobileSoul PL-52; QUESTIONS #209;
  SyncSpec §12's marker-13 entry.
- **Tickets:** VX-124 Done at the merge. Born this phase: VX-127…134,
  VX-145 (restore/promote a version on the wire) · VX-146 (references
  read) · VX-147 (callout carry) · VX-148 (deleted comments read) ·
  VX-149. The U2-ops guard retrofit note rides #209.
- **13s-a is NEXT** (the last phase before 🚀): plan + kickoff at
  `notes/plans/phase-13s-a-revoicing.md` — the re-voicing, now carrying
  the 13n copy sweep and the field guide's MCP chapter.

## HELD FOR YOU (nothing improvised around)

- The #209 taste calls (words, chord, truncation).
- P-13nb-U4-16's residual: under a join dial YOUR tagging acts still seat
  matches into a book-granted client's reach — read as standing, yours to
  confirm.
- A-4's boundary line (above).
- The standing ritual line: re-verify the U1 socket probe per macOS point
  release (joins TEXTKIT2_NOTES' cadence).
- VX-115 stands red on main until its own fix; VX-134/149 are watch
  tickets with capture instructions.
