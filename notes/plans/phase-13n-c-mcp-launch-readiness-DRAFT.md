# Phase 13n-c — MCP launch readiness (DRAFT PENDING THE SITTING)

**STATUS: DRAFT — written 2026-10-11 by the VX-156 design-prep round, on branch
`vx-156-grant-ux-design`. Not a kickoff: it becomes one only after her sitting rules the agenda
(a)–(d) and nods or redirects the round's picks (the brief's table). The phase NAME is hers to keep
or change; master-plan sequencing against 13s-a is hers (§6). Nothing here is ruled beyond
R-AIR-1 and R-AIR-2 (both ratified at her Air round, recorded in
`notes/plans/vx-156-grant-ux-design-kickoff.md`).**

The design record this plan builds to: `notes/plans/vx-156-grant-ux-brief.md` (per item: options,
the recommendation, the why, the chord sweep) + the drawn states
`notes/plans/vx-156-grant-ux-mockups.html`. The door it hardens: `notes/plans/phase-13n-b-mcp-door.md`
(R-13nb-1…28, AF-1…AF-11, the four unit records).

## KICKOFF MESSAGE (draft — live at her word)

You are kicking off 13n-c, the round that makes the MCP door ready for REAL USERS at launch — her
stated intent for this week. 13n-b (VX-124) shipped the door and closed on 2026-10-10; her first
real-store round on the Air (2026-10-11) found the frictions this phase answers and ratified two
rulings: **R-AIR-1** (journal-trait books may hold standing grants; the never-always fence keys on
the daily Journal and the Private mark) and **R-AIR-2** (the per-item cross-wing NOTE move ships on
the wire). The design was prepared ahead of you — read the brief and the mockups whole, then the
sitting's rulings (recorded in this file's SITTING RECORD once she has ruled). Preflight per
CLAUDE.md in full, plus `notes/plans/phase-13n-b-mcp-door.md` (the grant boundary's rulings and the
four unit records). No `Sync/`, no schema, no custody and no editor seam are expected (§5 says
where each could appear and what to do). Mint the phase ticket at kickoff (child of VX-25, project
"13n — The MCP door"), branch/worktree per the standing rules, declare surfaces against the
in-flight table (VX-143 holds the Air's slot — §5's overlap note). Shape: the author picks at
kickoff; the units below assume `/architect-phase` (design is done; the units are builds with
use-shaped evidence).

## 1. What this phase is

The launch-readiness round for the MCP door. Three kinds of work, one theme — *a real user can find,
grant, watch and undo the door without reading a manual*:

- **The grant road** (VX-156 + VX-163): choosing places by search with names told apart, granting
  from where the notes are, and R-AIR-1's fence change with the words that make it honest.
- **The keyboard and the quiet signals** (VX-156 + VX-157): share-this-note, the pane and the wing
  switcher from the keyboard; asks that wait quietly on what they name.
- **The wing on the wire** (VX-160 + VX-158): her variorum-wing sweep made possible, and an agent's
  wing switch under her etiquette.

## 2. Scope

| Item | Ticket | Status in this draft | Brief § |
|---|---|---|---|
| Searchable pickers on the grant road | VX-156 (1) | IN | §1 |
| Grant from the Library (+ the Book Settings grant row) | VX-156 (2) | IN | §3 |
| Share-this-note chord at the last-used rung | VX-156 (3) | IN | §4 |
| The pending-ask badge (+ the arrival fork) | VX-156 (4) | IN | §5 |
| The MCP pane chord | VX-156 (5) | IN | §6 |
| Duplicate-name disambiguation | VX-156 (6) | IN | §2 |
| Keyboard wing switching | VX-157 | IN | §7 |
| The MCP wing switch on the wire | VX-158 | IN | §8 |
| The per-item cross-wing note move on the wire (R-AIR-2) | VX-160 | IN — its shape is agenda (b) | §10 |
| Journal-trait books grantable (R-AIR-1) | VX-163 | IN — its words are agenda (a) | §9 |
| The pane's A-4 boundary line (L1 — the canon says the pane has it; the build does not) | — (found by the prep round) | IN at her nod (a copy-truth fix) | §12 |
| Per-pairing merge / choose-per-take divide on the wire | VX-159 | CANDIDATE — agenda (c) | §11 |
| VX-161 | VX-161 | CANDIDATE — content in Linear, not in the repo; unsized | — |
| The A-4 per-client/per-setup secret (K1/K2) | (mint at her nod) | CANDIDATE — agenda (d); the prep recommends K0 for launch | §12 |
| Adjacent, NOT proposed: VX-131 (once-grant timeout) · VX-133 (receipt run counts undone acts) · the U2-era ops' guard retrofit (P-13nb-U2-8, #209) | — | named so the omission is deliberate | brief §14 |

## 3. The units (acceptance units — `notes/PhaseSizingGuidance.md`)

### U1 — The grant road (VX-156 items 1, 2, 6 · VX-163 · L1)

**Builds (to the brief's picks; adjust to her rulings):**
1. **Core, pure:** `PlaceLabels.disambiguate` (the duplicate ladder: wing → shelf → note count →
   state → made day → made time; collision set = case- and diacritic-insensitive equal names among
   the OFFERED rows) — Swift Testing, exhaustive collision cases.
2. **Core, the fence (VX-163):** the three journal sites narrow from `('journal','daily')` to
   `'daily'` — `Queries.mcpGrantableBooks`, `mcpBookFacts`, `mcpNoteFacts`' member leg
   (`MCPGrantQueries.swift`); the note's own `profile='journal'` leg per her word on the ⌘J edge
   (the brief recommends KEEP). Pins: a trait book is grantable and its notes reach under a book
   grant, a wing grant and the open book; the daily Journal's entries stay fenced under every
   standing grant; Private still wins ties; a ⌘J entry filed into a trait book follows her edge
   ruling. These are ruled-behaviour pins (not a bug class), and the existing fence pins that
   assert the old trait leg are updated as the ritual, each named in the record.
3. **Core, the bulk grant:** N note grants minted in ONE transaction on ONE stamp (one op call),
   with state-transition tests; refusals are the existing ones (a fenced note never takes
   "always"; a missing note refuses the whole act or lands the rest — the build's PROVISIONAL,
   logged).
4. **The sheet:** a WHO row (`SearchPicker` over approved clients, the most recently granted
   first) when the opener is not the pane; WHERE as `SearchPicker` (book, wing) and the note feed
   (`NotePickerSource.corpusNotes`) for "A note"; durations shrunk to what every picked target can
   take, with the one-line why; the confirm says the place with its disambiguator; the R-AIR-1
   words (agenda (a)'s pick) on the book, wing and open-book doors; the six sentences the brief's
   §9 lists, re-worded.
5. **The doors into it:** the Library bulk bar's "Share N notes with AI…", `postRowMenu`'s and
   `BookRowMenuTable`'s "Share with AI…", the Book Settings grant row — each registry-declared
   (P-1), walked by the registry test.
6. **The pane:** Shared with AI groups rows minted on one stamp; the ask sheet's title and the
   shared rows wear the disambiguator; L1's line under Clients (at her nod).

**Evidence (use-shaped):** the orchestrator's walk on the dev-store Debug build, both voices — two
same-named books told apart and the right one granted; a note granted from Settings by search;
three notes granted from the Library in one act and revoked in one; a trait book granted with the
words showing; then a REAL Claude Code live round — the trait book's notes readable under the book
grant, a daily Journal entry still answering the uniform not-shared shape, a Private note likewise.
Headless suites green; the Mac suites touching the sheet, the pane, the Library and the registry
(`MCPPaneTests`, `MCPEditFacesTests`, `MCPAskAndReceiptTests`, `CapabilityRegistryTests`, the
Library selection suites) under a held stage claim.
**Cold review:** `fable-reviewer` — the fence classifier is the security boundary (R-13nb-3's cast).

### U2 — The keyboard and the quiet signals (VX-156 items 3, 4, 5 · VX-157)

**Builds:**
1. **The share chord** (agenda pick: ⌥⌘A, D1): the target derived from `mcp_grant` (the newest
   grant row of a still-approved client → client + rung; no new storage); while connected if
   connected, else once; never always; no history ⇒ the sheet with WHERE = this note; already
   reaching ⇒ the refusal; the receipt with **Revoke ›**. Edit menu, beside ⌥⌘Z/⌥⌘O.
2. **The badge** (face A): an observable projection of `MCPDoor.asks` keyed by target (note · book
   · wing), drawn on the Library/Pool rows, the book-TOC rows, the bottom bars' note ▾ (Write's and
   Takes'), the Bookcase rows, the wing switcher's rows and the masthead; hover names the client(s);
   her press opens that ask's sheet.
3. **The arrival** (her X/Y/Z): under X the WindowGroup-level `.sheet(item:)` that presents
   `presentedAsk` (`VariorumApp.swift`) retires and Settings ▸ MCP gains **Waiting** (Answer… per
   row, its "all N ›" road) — the wire unchanged. Under Y/Z the sheet stays (Z gates it on the
   calm-asks "nothing is open" rule) and the handoff's "nothing ever interrupts your writing"
   sentence is corrected at this touch.
4. **The pane chord** (⌥⌘,): a settings route that opens Settings at MCP (at Waiting when an ask
   waits); the app menu's "MCP Settings…".
5. **The wing chord** (VX-157, ⌃⌘W; + ⌃⌘1…⌃⌘9 if she picks B): the switcher as the one picker
   control; the existing "Now in …" receipt speaks.
6. **Registry:** every new door declared once (verb, scope, availability, refusal copy), every
   chord bound in `EditorCommands.keyEquivalent` with the collision sweep re-run AT THE TIP and
   recorded beside the binding (the ⌥⌘O precedent).

**Evidence:** the walk, both voices — the chord on a note with history, without history, and where
the client already reaches; a real client's ask arriving while she types (under X: nothing appears;
the badge does), answered from the badge and again from Waiting; ⌥⌘, landing at Waiting; ⌃⌘W
switching wings with the receipt. The ask leg with a REAL Claude Code client.
**Cold review:** `opus-reviewer` (chrome and `MCPDoor` state; no fence, custody or seam change) —
`fable-reviewer` if the build finds the arrival change touching the grant rule.

### U3 — The wing on the wire (VX-160 · VX-158)

**Builds (to agenda (b)'s ruling; the brief recommends R1 · T1 · U1):**
1. **Core:** an MCP act over her `moveNoteToWing` — the in-transaction guard (the SOURCE note
   decided at edit through the ordinary rule; the DESTINATION through `decideWing` at write new on
   that wing; once grants spent atomically), her refusals mirrored byte-for-byte (same wing, dead
   wing, a member of a finished or sealed book — `WingCopy.frozen`'s words), and ONE client-named
   undo entry with an exact-row inverse (wing back for the note and its versions, severed
   memberships revived on their exact stamp, applications re-pointed back; minted tags stay as
   vocabulary) plus its exact-row redo. State-transition tests for every leg; her own door stays
   as it is (no undo entry).
2. **Server:** `move_note_to_wing` (name provisional) on the EDIT rung's catalog; the answer lists
   the books left, the tags adopted/minted and where it landed; the receipt and the activity phrase;
   `move_block`'s cross-wing refusal (P-13nb-U3-5) stays.
3. **VX-158** (agenda pick A): `show_in_app` gains the `wing` target — `MCPShowRule` unchanged,
   decided at read with `decideWing`, never spending a once grant; the "Now in …" receipt names the
   client.
4. **Rung proofs grown as the ritual:** read/suggest/write-new provably cannot move a note across
   wings; a book grant cannot name a destination; a fenced note moves only under a per-ask note
   grant — each pinned and mutation-checked (the 13n-b discipline).

**Evidence:** `VariorumMCPTests` pins + the core state-transition suite headless; then a REAL
Claude Code live round on the dev store in her sweep's shape — two wing grants, several notes moved
from Home into a second wing, one ⌥⌘Z walking one move back with its memberships and tags restored,
a finished book's member refused in her words, `show_in_app` to the wing with Variorum in front and
refused with it behind.
**Cold review:** `fable-reviewer` (the grant boundary + a new inverse over a cross-library move).

### Candidates — each its own unit if she takes it

- **VX-159 — the ceremonies on the wire** (agenda (c); the brief recommends P1 + presets on the
  existing tools): `divide_block`/`merge_blocks` gain `preset` and the per-take payloads; the U3
  composition-guard class (13n-b's U3 ladder F2) binds every per-take phrase in-transaction. Wire
  unit; `fable-reviewer`; a live round dividing a fanned block per take and pairing a merge.
- **The A-4 secret (K1/K2)** (agenda (d); the brief recommends K0 for launch, K2 if wanted): a
  local-only column (a LOCAL-ONLY migration — zero lockstep, marker untouched, the v1_24 family's
  registration road), the shim's one-line preamble (A-2's "protocol-blind" letter becomes
  "MCP-blind" — say so in the record), the setup command carrying the secret, the server mapping
  secret → identity. Its evidence is a DRILL: a fresh client set up end to end; two tools under one
  name told apart; a bare shim launch refused. Not custody (no store key moves), but the shim and
  every new user's first five minutes change — `fable-reviewer`.
- **VX-161** — unsized here; the orchestrator reads its one-liner in Linear at kickoff.

## 4. Sizing — said plainly (guidance to raise, R-cor-13)

- **U1–U3 are acceptance units, none phase-sized** (no new mode or board, no token pass, no lockstep
  event, no posture) — three units under one theme sits inside the guidance's two-phase-sized-units
  line.
- **With both candidates taken it is five units** — more than this week holds beside 13s-a, which
  is still to run before launch and is copy- and sitting-heavy. This draft says so rather than
  splitting silently.
- **Time, honestly:** 13n-b ran four larger units through implementer → own-hands verify → live
  round → a two-round ladder in about a day and a night. U1 and U2 here are each smaller than any of
  those; U3 is about U4-of-13n-b's size. A fair reading: U1 + U2 in a day, U3 in half a day to a day,
  each candidate another half day or more.
- **The recommended launch cut:** **U1 + U2** (her real-store frictions — the indistinguishable
  rows above all, since a grant to the wrong book is a disclosure error, not a cosmetic one) **+ U3
  if the week holds** (R-AIR-2 is ratified and "belongs to the NEXT build group"). **Falls out to
  named follow-ons:** VX-159, the A-4 secret, VX-161 — unless she pulls one in.

## 5. Constraints (standing, restated for this phase)

- **`Sync/`: zero.** Grants are local-only; R-AIR-1 changes a local fence DERIVATION (Queries), no
  synced column; VX-160 rides her existing op plus a new inverse in Operations. Marker 13
  untouched; no lockstep event.
- **Schema: none** in U1–U3 (the one-stamp grouping reads the existing `mcp_grant.created_at`). The
  A-4 candidate alone would add a LOCAL-ONLY column — its own commit ahead of the code, as ever.
- **Editor seam: none expected.** The badge on the bottom bars is chrome beside the note ▾ menu;
  if any piece would need `EditorTextView` / `BlockRangeIndex` / `PaneSurface`, stop and fork with
  `notes/TEXTKIT2_NOTES.md` read.
- **Custody: none** (the A-4 candidate changes the shim and setup, not custody — flagged anyway).
- **Overlap:** VX-143 (in flight on the Air) touches the Takes board, the sidebar note box, Read
  hover hints and Touch ID; its VX-135 (Write's take menu) may touch `CommitBar.swift`, where U2's
  badge rides the note ▾ menu — check at kickoff; closeouts serialize.
- **Etiquette is law (R-13nb-23/26g):** nothing an agent does raises a window, steals focus or
  queues UI; `show_in_app`'s wing target inherits `MCPShowRule` whole.
- **The rung is the only read dial (R-13nb-17)** — no new read knobs; every new reach is a call
  shape, uniform per rung.
- **Copy:** the pane and its sheets direct and technical (R-13n-5); chips, badges, receipts in the
  app's voice (P-13n-1); sentence case, no capitals for emphasis; every new string 13s-a-sweepable.
- **Stage:** the Air is explicit-say-so; walks, Mac suites and live rounds run on the Pro under a
  held `Tools/stage` claim; headless core work runs free.
- **Baselines (13n-b's closeout):** core 2,580/295 · VariorumMCPTests 65/8 · workbook 40/6
  headless; the whole VariorumTests target 4,212/687 (standing reds VX-115 and VX-149).
- **MOBILE PARITY:** nothing mobile-visible — grants never sync, the phone has no door, R-AIR-1
  changes no synced row. Say the line at closeout.

## 6. Sequencing against 13s-a (hers to rule)

- **S1 (recommended) — 13n-c's launch cut, then 13s-a, then 🚀.** 13s-a's hand-in 6 already
  sweeps 13n's copy and writes the field guide's MCP chapter; running after 13n-c, it sweeps the
  new chords, badge and sheet words once and teaches them once (R-13n-9's own reasoning, her words:
  "good reason to do it after since this'll add to the field guide").
- **S2 — in parallel worktrees, closeouts serialized.** Faster on paper; 13s-a would re-voice MCP
  strings 13n-c is rewriting, so the second to merge re-sweeps the first's.
- **S3 — 13s-a first, 13n-c after launch.** The launch ships 13n-b's faces as they are — against
  her "ready for real users at launch".

## 7. The sitting this plan waits on

Agenda (a)–(d) as carried in the brief, plus one nod per pick in the brief's table, plus: the ⌘J
edge (§9 of the brief), L1 (§12), the launch cut (§4 above) and the sequencing (§6). Rulings land
in a SITTING RECORD section below, verbatim-faithful, before U1's brief is written; anything left
PROVISIONAL is logged at the merge from **#210** (the next free QUESTIONS number at drafting).

## 8. THE LEDGER (draft — every row owned)

| # | Item | Owner | Status |
|---|---|---|---|
| 1 | The sitting: agenda (a)–(d) + the picks + the launch cut + the sequencing | HER | PENDING |
| 2 | U1 — the grant road (VX-156 1/2/6 · VX-163 · L1) | U1 implementer | NOT-STARTED — waits on row 1 |
| 3 | U2 — the keyboard and the quiet signals (VX-156 3/4/5 · VX-157) | U2 implementer | NOT-STARTED — waits on row 1 |
| 4 | U3 — the wing on the wire (VX-160 · VX-158) | U3 implementer | NOT-STARTED — waits on row 1 (agenda (b)) |
| 5 | VX-159 — ceremonies on the wire | HER (take or defer) | CANDIDATE |
| 6 | A-4 secret (K1/K2) | HER (take or defer) | CANDIDATE |
| 7 | VX-161 | HER / orchestrator (read the ticket) | CANDIDATE — unsized |
| 8 | The 13n-b handoff's ask-arrival sentence vs the build (brief §14 item 1) | U2 (whichever arrival she picks) | OPEN |
| 9 | AppSpec §12's "the pane says so" vs the build (brief §12's found gap) | U1 (L1) or the closeout's canon line | OPEN |

## SITTING RECORD (empty until she rules)

## U1 / U2 / U3 BRIEFS AND UNIT RECORDS (written just-in-time, after the sitting)
