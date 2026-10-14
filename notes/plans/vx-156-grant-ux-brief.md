# VX-156 — the MCP grant UX round: options brief + the sitting agenda

**NOT DONE, by mandate (the record's first line):** no app code · no canon edits · no
`notes/QUESTIONS.md` entry (the agenda below carries every question; numbers mint at the merge
— the next free is **#210**) · no suites, walks, stage claims or app launches (design-only, run on
the Air) · VX-161's content is not in the repo (it was born at her Air round after the
2026-10-11 01:25 board snapshot), so this round cannot size it.

Ticket VX-156 (+ VX-157, VX-158 face implications; agenda items for VX-159, VX-160, VX-163 and
A-4) · branch `vx-156-grant-ux-design` · worktree `~/dev/variorum-grantux` · kickoff
`notes/plans/vx-156-grant-ux-design-kickoff.md` (VX-163 and VX-160 RATIFIED there — designed to,
never re-opened). The drawn states: `notes/plans/vx-156-grant-ux-mockups.html` (section numbers
below say "mockup §N"). The DRAFT phase plan: `notes/plans/phase-13n-c-mcp-launch-readiness-DRAFT.md`.

## LIVE STATUS (SessionResiliencyProtocol — flipped in the same commit as each piece)

| # | Piece | Status |
|---|---|---|
| P0 | Worktree + preflight (read in full, never delegated) + the skeleton | DONE (`209c11f6`) |
| P1 | This brief: per-item options, recommendation and why; chord candidates with the sweep evidence; open questions | DONE (`eacf600b`; amended in the P2 checkpoint — the A-4 pane-line gap found, a sixth VX-163 sentence) |
| P2 | `notes/plans/vx-156-grant-ux-mockups.html` — one self-contained page, Study voice, light and dark, sentence case | DONE (`c7e753c0` + the render-check fixes `a8679ab8`) — §1–§11 per the §16 map; Study tokens verbatim from `VoiceTokens` (light/dark + a forced light/dark pair at §1); tag balance parsed clean, zero external fetches, no all-caps words but the MCP acronym and ruling ids; rendered OFFSCREEN for a check (QuickLook thumbnails of per-section scratchpad copies, light and dark — no browser, no app; the captures stay in the scratchpad), which caught three fixes now in: radio glyphs, the popover truncating the very title it disambiguates, two inherited styles |
| P3 | `notes/plans/phase-13n-c-mcp-launch-readiness-DRAFT.md` — the DRAFT phase plan | DONE (`6356e5a5`) — U1 the grant road · U2 the keyboard and the quiet signals · U3 the wing on the wire; candidates VX-159, the A-4 secret, VX-161; sizing said plainly (launch cut U1 + U2, U3 if the week holds); 13s-a sequencing as three options (S1 recommended) |
| P4 | Final pass: status flipped, PR "VX-156: grant UX design prep" opened | DONE — PR #147 (https://github.com/lduarte-io/Variorum/pull/147), merge waits for her sitting. **ROUND CLOSED (hard stop).** |

## THE SITTING AGENDA (carried verbatim from the kickoff)

- (a) ~~The journal-trait Always question~~ **RATIFIED as VX-163 above** — the
  agenda item becomes: the extra-worded confirm's wording (if any) for granting
  Always on a journal-trait book, presented as drawn options.
- (b) VX-160's crossing-door shape — per-item NOTE move across wings via MCP
  (rung, scope semantics when source and destination wings differ, the per-item
  doors' tag adoption by path). Her use case: the variorum-wing sweep.
- (c) VX-159's addressing problem — per-pairing merge and choose-per-take divide
  on the wire (the `second_half_starts_with` text-addressing precedent).
- (d) A-4 hardening option: a per-client secret minted at approval and embedded
  in the Copy-setup-command config, so the server can map secret → identity.
  Present honestly: it defeats client mislabeling/confusion, NOT same-user
  malware (the config file is same-user-readable); the pane's boundary line
  stays true either way.

**Where each agenda item is answered in this brief:** (a) → §9 (drawn: mockup §8) · (b) → §10
(mockup §9) · (c) → §11 (mockup §10) · (d) → §12 (mockup §11).

### The round's own picks — one nod each (deliverable 2's recommendations, not new questions)

Every VX-156/VX-157 item below has 2–3 options and a recommendation; these are the picks the
build would follow if she nods. A redirect is one word per row.

| § | Item | Recommended | The one-line why |
|---|---|---|---|
| 1 | Searchable pickers on the grant road | **A** — the ONE picker control (`SearchPicker`, R-17y-3) everywhere a place is chosen; the WHERE row gains "A note" through the bounded note feed | R-17y-3 already ruled "every other picker adopts it at its next touch" — this is that touch |
| 2 | Duplicate names | **A** — quiet context on every row + a collision-only distinguishing fact from a fixed ladder (wing → shelf → count → state → made day → made time) | a pure, pinnable rule; never an invented ordinal; reaches the ask sheet and the pane rows too |
| 3 | Grant from the Library | **A** — "Share N notes with AI…" on the bulk bar + "Share with AI…" on note/book row menus + the Book Settings row, all opening THE grant sheet pre-filled (a WHO row added) | one sheet, many doors (P-1); N grants minted on one stamp, shown as one pane row |
| 4 | Share-this-note chord | **⌥⌘A**, derived target (the newest grant she made: its client + rung), while connected if connected else once; no history ⇒ the sheet | no new storage; never "always" by a key; a door that can't guess opens the deliberate road |
| 5 | Pending-ask badge | **A + X** — a quiet "asks" chip on the target's own row/bar; asks WAIT there (the auto-presented sheet retires), answered by her press or in the pane's new Waiting list | her "passive, never raises, never queues UI"; supersedes the still-provisional P-13nb-U2-9 arrival |
| 6 | MCP pane chord | **⌥⌘,** — Settings opened at MCP (at Waiting when asks wait) | Settings' own chord, the ⌥ "deliberate variant" her ceremony chords carry |
| 7 | Wing switching (VX-157) | **A** ⌃⌘W "Switch Wing…" (type to filter); **B** ⌃⌘1…⌃⌘9 direct as her add-on if wanted | one chord that scales to any number of wings; direct digits are positional |
| 8 | VX-158's faces | **A** — a `wing` target on `show_in_app` under the same etiquette; the "Now in …" receipt names the client | one ruled tool, one etiquette, no spontaneous-looking switch |

---

## §1 — Searchable pickers on the grant road (VX-156, item 1)

**Today (traced):** `MCPGrantSheet` (lines 81–108) offers WHERE as a radio pair (a book · a wing)
and then a native `Picker` over `Queries.mcpGrantableBooks` — every live non-fenced book, flat,
sorted by name. Nothing filters it, and the only context a row carries is "— <wing>" for a
non-Home wing (`bookLabel`, line 170). The wing picker is another native `Picker`. The note scope
has no face here at all (P-13nb-U1-11: "Settings holds no note in hand").

**Options:**
- **A (recommended) — the ONE picker control everywhere a place is chosen.** The book row and the
  wing row become `SearchPicker` (the shared control in `Core/Views/SearchPicker.swift`, pure brain
  + face, already rendered by the rule editor, the outflow chooser and the add-to-book door):
  type to filter, ⏎ takes the first match, Esc closes, `createLabel: nil` (a grant never mints a
  place). The row's `annotation` slot carries §2's context. AND the WHERE row gains **"A note"**,
  fed by the existing bounded note feed (`NotePickerSource.corpusNotes` — snippet + day per row,
  wing-scoped) so a note can be granted from Settings by name. Why: R-17y-3 ruled ONE control
  ("every other picker adopts it at its next touch"), its brain is pinned, and P-13nb-U1-11's
  reason for keeping notes out of the sheet ("Settings holds no note") dissolves once a note can be
  searched. Mockup §1.
- **B — an inline filter field above a scrolling radio list, inside the sheet.** Everything stays
  visible without a popover; the sheet grows tall and becomes a second picker idiom beside R-17y-3's.
- **C — keep native pickers, grouped by shelf with section headers.** No search; the length
  problem only moves into submenus (her "this is a disaster" verdict on flat corpus menus, manifest
  row 06, is the precedent against it).

**Fenced places in the picker:** under VX-163, the daily Journal and anything Private are never
offered (P-2 — the op would refuse them); a journal-trait book IS offered (§9 decides the words it
wears). A fenced NOTE picked under "A note" is offered with the honest durations only (once ·
while connected, never always — `MCPGrantRule.reaches`).

## §2 — Duplicate-name disambiguation (VX-156, item 6)

**Today (traced):** two books named "the adventures of sherlock holmes" (her screenshot; the
likeliest source is the sample library restored a second time — same name, same wing) render as two
identical rows, because `bookLabel` adds only a non-Home wing; the ask sheet's title (`MCPAskCopy.title`) and the pane's Shared
with AI rows (`MCPSharedRowView`) have the same blindness, because each names a place by title
alone.

**Options:**
- **A (recommended) — context always, a distinguishing fact on collision.** Every row's annotation
  says what the Bookcase row would (shelf · N notes · finished/owned/sealed/archived marks). When
  two OFFERED rows share a name (case- and diacritic-insensitively — the picker brain's own
  sameness), the pure rule `PlaceLabels.disambiguate` appends the FIRST fact that differs across
  the colliding set, from a fixed ladder: **wing → shelf → note count → state marks → made day →
  made time** ("made 9 Oct" → "made 9 Oct, 21:14"). The made stamp is `reading.created_at`, which
  always differs in practice; the rule never mints an ordinal ("(2)") that would change meaning when
  one is deleted. The same rule labels the ask sheet's title and the pane's shared rows. Pinned
  headless (the collision sets are the tests). Mockup §1b.
- **B — collision-only, no standing context.** Rows look exactly as today unless names collide,
  then "made <day, time>" appears. Smallest change; an un-annotated list of 40 books still gives no
  footing.
- **C — always show the made day on every row.** Uniform, but the made day is the least useful fact
  for the ordinary row (her shelves are what she knows books by).

## §3 — Grant from the Library (VX-156, item 2)

**Today (traced):** the Library already has a ⌘-click pick and a bulk bar ("Tag N notes",
"Untag N notes", "Delete N notes…" — `LibraryCatalogView` lines 673–711); a note row's context
menu (`postRowMenu`) has no AI row; the Bookcase row carries only the "shared with AI" chip; the
Book Settings sheet carries only the Private row, though R-13n-4 named it a grant face. The grant
sheet opens only from the pane, so it always knows its client.

**Options:**
- **A (recommended) — every place-door opens THE grant sheet, pre-filled.** The bulk bar gains
  **"Share N notes with AI…"**; a note row's menu (`postRowMenu`) and the book rows' ONE menu
  table (`BookRowMenuTable` — the Bookcase's and the Library's book rows both render it) gain
  **"Share with AI…"**; the Book Settings sheet gains the R-13n-4 row ("Shared with
  AI: claude-code (read) · Share…"). Each opens the same sheet with WHERE already filled ("these 3
  notes" / "“the lightning thief”") and a new **WHO** row (a `SearchPicker` over approved clients,
  the most recently granted first — the sheet no longer always knows its client when the pane is
  not the opener). Durations shrink to what EVERY picked target can take: if one picked note is
  fenced, "always" is not offered and the sheet says why in one line ("1 of these notes is Private
  — always isn't offered"). One op call mints the N note grants in ONE transaction on ONE stamp;
  the pane's Shared with AI list GROUPS rows minted on one stamp into one row ("3 notes ·
  claude-code · read · while connected" with Revoke covering the three) — grouping by the shared
  `created_at` needs no schema (the exact-stamp doctrine, applied to a local list). Mockup §2.
- **B — a fast submenu, no sheet.** The bulk bar's "Allow AI here ▸ <client>" (the U3 note-menu
  shape, made bulk): read · once on each picked note, one click. Fast, but read · once only — the
  rung and duration choices still need the pane.
- **C — no Library door; the sheet's note picker goes multi-select.** Granting stays a Settings
  act; selection in place (her ask) is not met.

## §4 — The share-this-note chord (VX-156, item 3)

**What "last-used rung" can mean without new storage (traced):** `mcp_grant` keeps every grant
row with `created_at` (revoked rows included — `MCPGrantSchema` lines 63–73), so "the last grant
she made" is DERIVED: the newest grant row whose client is still approved → its client and its
rung. No preference store, nothing synced (the grants family is local-only).

**The act (recommended shape):** with a note open, the chord shares THAT note with the derived
client at the derived rung — **while connected** when that client is connected now, else **once**
(R-13nb-20: the bounded session she described IS while connected; "always" is never minted by a
key — a standing-forever grant deserves the sheet). A fenced note takes the same answer (both
durations are per-ask-legal for a note grant — `MCPGrantRule.reaches`). The receipt (app voice,
P-13n-1) says what was granted and carries a one-press **Revoke ›** door (grants are not on ⌥⌘Z —
the door is her veto, R-13nb-27's receipt-carries-a-door idiom). Mockup §3.
- **No history** (no grant ever made, or every granting client since denied): the chord opens THE
  grant sheet with WHERE = this note — never a guess (P-2: a door that cannot act as named opens
  the deliberate road instead).
- **Already reaching** at that rung or above: a refusal, nothing written — "claude-code already
  reaches this note (read and suggest)."
- **No note open:** grey (the menu item's registry gate).

**Duration options (hers to pick):** **D1 (recommended)** while connected if connected, else once ·
**D2** the newest grant's own duration where legal here (an "always" grant elsewhere would make
the chord mint a standing grant on this note) · **D3** always once (the Allow-AI-here shape, rung
raised).

**Chord options (sweep in §13):** **⌥⌘A (recommended)** — "allow AI", in the ⌥⌘ family that already
holds the AI pair (⌥⌘Z her veto, ⌥⌘O the AI's last change) · **⌥⇧⌘O** — the reverse direction of
⌥⌘O (show what it changed / offer it this) · **none** — reachable only from ⌘K's palette. Menu home:
**Edit**, beside ⌥⌘Z and ⌥⌘O, titled from the registry ("Share This Note with AI"; the menu bar keeps
its shipped Title Case — P-13nb-U4-15's "Show the AI's Last Change").

## §5 — The pending-ask badge (VX-156, item 4)

**Today (traced):** an ask (`MCPAsk` — client, scope kind + id, title, rung, fence) is queued in
memory (`MCPDoor.enqueue`, cap 8) and the FIRST one is presented automatically as a sheet on the
main window (`VariorumApp.swift` lines 86–95, `presentedAsk`) — PROVISIONAL P-13nb-U2-9, still open
in #209 ("Alternative: an offer toast with Review… (calmer, missable)"). Note the closeout handoff
describes this as "asks queue quietly; nothing ever interrupts your writing" — the code presents a
sheet on arrival, so the handoff sentence and the build disagree today (§14, open item 1).

**Where the badge lives (every option):** on the TARGET's own face, where she already looks — a
NOTE ask on its Library/Pool row, its book-TOC row and the open note's bottom bar (beside the note ▾
menu); a BOOK ask on its Bookcase row (beside "shared with AI"); a WING ask on the wing switcher's
row and the masthead's "Bookcase · Home ▾". It counts asks per target (several clients), names
them on hover ("claude-code asks to suggest here"), and her press opens THAT ask's sheet (her
press, so the etiquette is untouched). It never raises a window, never scrolls, never toasts, and
clears when the ask is answered, forgotten (the cap), or the store detaches.

**Face options:** **A (recommended)** a quiet outlined chip "asks" (the "shared with AI" chip's
twin, accent ink) · **B** a bare accent dot beside the title (smallest; meaning learned) · **C** the
chip with the client's name ("claude-code asks") — clearest, widest.

**Arrival options (the part that changes behaviour — hers):**
- **X (recommended) — the badge REPLACES the auto-presented sheet.** Asks wait at their badge and in
  a new **Waiting** section of Settings ▸ MCP (AF-6's optional "pending asks as pane rows on the
  requests idiom", unbuilt at 13n-b, built now); nothing appears by itself. The wire is unchanged
  (the client still hears "Variorum has asked the author — call again once she answers").
  Supersedes P-13nb-U2-9's arrival; makes the handoff's "nothing ever interrupts your writing"
  literally true.
- **Y — badge AND the auto-sheet**, as today plus the badge. Nothing missable; the sheet still
  arrives mid-sentence.
- **Z — the sheet waits for a calm moment** (CalmAsks' "nothing is open" rule — `CalmAsks.swift`)
  and the badge stands meanwhile. Gentler than Y, still self-presenting.

## §6 — The MCP pane chord (VX-156, item 5)

**Today (traced):** Settings opens with ⌘, (SwiftUI's `Settings` scene) at its last pane; the MCP
pane is the eleventh (`SettingsPane.mcp`); ⌘K's palette has "Settings — Appearance & Tags" only.

**Options:** **⌥⌘, (recommended)** — "Settings, the AI room": opens Settings at MCP, scrolled to
Waiting when an ask waits (so it doubles as §5's keyboard road to the asks); ⌥ is the "deliberate
variant" modifier her ceremony chords carry (13j J4/J4b) · **⌃⌘M** — "M for MCP" in the ⌃⌘ family
(⌃⌘S sidebar, ⌃⌘L lock) · **none** — a "Settings — MCP" palette row only. Menu home: the Variorum
app menu, under Settings… ("MCP Settings…"). Registry-declared either way (P-1).

## §7 — Keyboard wing switching (VX-157) — the face with its chord

**Today (traced):** the masthead's "Bookcase · Home ▾" opens `WingSwitcherMenu` — an inline
native picker headed "Wings — each a separate library", then New Wing…, and (on an additional wing)
Rename / Move Everything / Delete. No chord reaches it.

**Options:**
- **A (recommended) — ⌃⌘W "Switch Wing…".** Opens the switcher as the ONE picker control (§1's
  idiom): type to filter, ⏎ switches, Esc closes; the switch speaks the existing "Now in …" receipt
  (her (f) ruling). One chord, any number of wings, nothing positional to remember. Mockup §6.
- **B — ⌃⌘1…⌃⌘9 direct**, by switcher order (Home always ⌃⌘1), the digits drawn beside each row
  in the switcher. Fastest for two or three wings; positional (a reorder moves the chords).
- **C — ⌃⌘] / ⌃⌘[ cycle** next/previous, wrapping. Blind stepping through separate libraries, and
  it sits beside ⌥⌘[ / ⌥⌘] (the pane's back/forward) where it would read as a sibling.

She may take **A + B** (the kickoff's "and/or"); A alone is the recommendation.

## §8 — VX-158, the MCP wing switch on the wire — face implications only

**Reading (stated, since the ticket body is in Linear, not the repo):** VX-158 lets a client move
the app to a WING (the Bookcase re-scoped there), the navigation cousin of `show_in_app`. If the
ticket means something else, only this section changes.

**Options:**
- **A (recommended) — a `wing` target on `show_in_app`.** Same etiquette exactly (`MCPShowRule`:
  frontmost full window only; refuse, never queue; never spends a once grant); decided at READ on
  the wing (`decideWing` — wing-level reach, else the one not-shared answer). The faces: the
  existing "Now in …" receipt names who moved her ("Now in variorum — claude-code showed you this
  wing."), the switcher reflects it, the activity log lists it. Mockup §7.
- **B — a separate `switch_wing` tool.** Same faces; one more tool name for one more act (the lean
  set's "tools are thin projections" reading prefers a target).
- **C — nothing new.** A note or book target in another wing already lands there through her (f)
  "the wing follows the focused note" rule; a bare wing switch is not offered.

## §9 — Agenda (a): VX-163's extra-worded confirm (VX-163)

**The ruled outcome, restated for the faces:** the never-always fence keys on the daily Journal
(its entries per-ask only) and on the Private mark. A journal-TRAIT book is grantable like any book.

**Consequences she should see before the words (traced in the code, each a J8 copy-truth fix the
build owes):**
1. A trait book's notes stop being fenced EVERYWHERE, not only under a grant naming the book: a
   WING grant on its wing and the OPEN BOOK switch reach them too (`MCPGrantRule.reaches` treats an
   unfenced note uniformly). The extra words therefore belong on three doors, not one — the options
   below say where.
2. Six shipped sentences become false or loose and must change: the Settings search blurb for
   the open book ("…journals still ask every time." — `SettingsCatalog` row `mcpOpenBook`), the sheet's wing line
   "everything in <wing> except journals, which always ask" (`MCPPaneCopy.wingDetail`), the open
   book's "journals still ask every time" (`openBookDetail`), the empty-picker line "journals are
   shared one ask at a time" (`noBooks`), the pane's refusal "Journals and Private notes are shared
   one ask at a time, never by a standing grant." (`refusal`, `.mcpGrantScopeFenced`), and the ask
   sheet's "A journal entry. Journals are only ever shared one ask at a time." (`MCPAskCopy.lead`).
   Recommended words: "…except your daily Journal and anything Private, which always ask" — the
   siblings to match ("A daily Journal entry. Your daily Journal is only ever shared one ask at a
   time."). 13s-a sweeps them after, as ever.
3. **The build's trace (VX-163)** — the fence's three journal sites narrow from
   `('journal','daily')` to `'daily'`: `mcpGrantableBooks`' filter, `mcpBookFacts`' journal leg and
   `mcpNoteFacts`' member leg (`MCPGrantQueries.swift` lines 292, 334, 366). **One edge wants her
   word:** a note's OWN `profile='journal'` leg (line 289) — the shape `createOrOpenJournalEntry`
   gives every ⌘J day entry. **Recommended: KEEP it** (a day entry minted by ⌘J stays per-ask
   wherever it is later filed — "its entries", read as the entries the daily door makes; R-13nb-1's
   own posture, "more asks, never fewer"). The alternative: drop it (only membership in the daily
   book fences; a day entry she files elsewhere becomes grantable).

**The wording, drawn (mockup §8):**
- **W0 — no extra words.** The ruling says "optionally"; the trait book reads like any book.
- **W1 (recommended) — the sheet's own confirm carries the words; no second dialog.** Under WHERE,
  one line appears when the chosen place is (or holds) a journal-style book: *"“dream journal”
  keeps date-stamped entries — granting it shares every entry in it, now and later, without
  asking. Your daily Journal and anything Private still ask every time."* The confirm button keeps
  its sentence ("Grant read in “dream journal” always"). The same line appears on a WING grant whose
  wing holds trait books (naming up to two, then "and N more"), and under the open-book switch.
  One press stays one press; the words are where the decision is made.
- **W2 — a second-step alert after the confirm** ("Share a journal-style book?" + the same
  sentence, "Share it" / "Cancel"). Heaviest; most deliberate.

## §10 — Agenda (b): VX-160's crossing door (per-item NOTE move across wings, VX-160)

**Her door, traced (`Operations+WingMove.swift`, `moveNoteToWing`):** ONE transaction — every live
membership of the note in its source wing's books is SEVERED (listed in her confirm; a MEMBER of a
finished or sealed book refuses — `lockedReading` / `readingSealed`); every live tag application on
the note AND its placed blocks re-points BY PATH (adopt, else mint in the destination); the note
and its saved versions take the destination `wing_id`. **It registers NO undo entry** ("moving back
is the symmetric door"). The wire's `move_block` refuses any cross-wing move today (P-13nb-U3-5).

**Rung:**
- **R1 (recommended) — EDIT at the source, WRITE NEW at the destination wing.** Leaving its books
  and its library reorganizes existing things (P-13nb-U3-4's reading of `move_block`); arriving
  rearranges nothing (the note lands in the destination's Pool, bookless — her door's own landing),
  and a tag minted there by path is a write-new act (`apply_tag`'s precedent).
- **R2 — EDIT on both sides.** Stricter; her sweep then needs edit on the destination wing too.
- **R3 — WRITE NEW on both.** Lets a write-new grant sever her book memberships — against
  P-13nb-U3-7's reading of what write new may change.

**Scope semantics when the wings differ (recommended with R1):** the SOURCE is decided per note
through the ordinary rule (any grant reaching the note at edit — note, book or wing scope); the
DESTINATION through `decideWing` at write new on THAT wing — a wing-scope grant (or nothing): a book
grant in the destination wing cannot name where a bookless note lands. Both decided again INSIDE
the act's transaction (AF-10 (a)'s rung-wide guard); a short side raises one ask (source first). A
fenced note moves only under a per-ask note grant at edit (its ask never offers always); with §9's
recommended own-profile leg kept, a ⌘J day entry stays fenced after it moves.

**Tag adoption:** **T1 (recommended) — mirror her door exactly** (adopt-or-mint by path, note and
placed blocks; the answer reports adopted/minted counts, which her op already returns) — AF-11
F-1's "mirror, never invent" · **T2** adopt only, refuse a missing path (a new validation path her
door does not have — AF-11 F-1's rejected class) · **T3** drop unmatched tags (loses applications —
not recommended).

**Undo:** **U1 (recommended) — one client-named entry ("claude-code's wing move")** with an
exact-row inverse: the wing back (note + versions), the severed memberships revived on their exact
stamp, the applications re-pointed back; minted tags stay as vocabulary (P-13nb-U2-6's precedent).
This is P-13nb-U2-4's "every MCP write registers an undo entry" — her own door stays undo-less ·
**U2** no entry; the symmetric move is the road back (her door's posture; breaks U2-4's letter for
this one act).

**The answer and the receipt:** the answer lists the books the note left (her confirm's list), the
tags adopted/minted, and where it landed ("the Pool of “variorum”"); the receipt (app voice): "claude-code moved “parser notes” to “variorum” — it left 2 books · ⌥⌘Z undoes  Open ›".
**Her sweep, drawn (mockup §9):** grants edit · Home · while connected + write new · variorum ·
while connected; the client lists Home, moves each note; the receipt run coalesces ("claude-code
moved 14 notes to “variorum” · ⌥⌘Z undoes"); each move is its own ⌥⌘Z.

## §11 — Agenda (c): VX-159's addressing (per-pairing merge, choose-per-take divide)

**The precedent:** `divide_block` addresses its cut by TEXT (`second_half_starts_with`, exactly
once in the shown take — AF-10 (c): LLMs miscount UTF-16); takes are addressed by `take_id` from
`read_note with_ids`; the composition guard re-verifies the fans in-transaction (the U3 ladder's F2).

**Divide choosing takes (`divideW`):**
- **P1 (recommended) — a preset, plus per-take objects when the preset is "choose per take".**
  `preset`: keep_on_top (today's default) · keep_below · copy_to_both · choose_per_take. For
  choose_per_take, `takes: [{take_id, second_half_starts_with}]` for each MARKED take, or
  `{take_id, rides: "top" | "bottom"}` for a take that goes whole to one side (divide-W's parking,
  spoken plainly); unmarked takes stay on the original as lineage (the ceremony's letter);
  `shown_take_id` anchors each side's chosen take. Every phrase is checked exactly-once inside the
  act's transaction; a take edited since the read refuses the whole act.
- **P2 — the whole first half quoted per take** (`first_half: "<exact text>"`): unambiguous and
  doubles as the precondition; heavy for long takes.
- **P3 — one shared phrase for every take**: cheapest; works only when every take contains it (the
  translation case often won't).

**Merge choosing takes (`mergeCeremony`):** ids already solve the addressing — `pairings:
[{left_take_id, right_take_id, join: "newline" | "space" | "nothing"}]` + `carry: [take_id]`,
with her op's own refusals (zero pairings and zero carries; a take in two pairings). Presets:
bring_every_take (today's `merge_blocks`) · only_the_two_shown · pair_by_hand. The only open shape
is whether presets ride the existing tools (`divide_block` / `merge_blocks` gain a `preset`) — **the
recommendation** — or two new tools (`divide_choosing_takes`, `merge_choosing_takes`).

## §12 — Agenda (d): the A-4 hardening option

**The boundary as built (A-4):** a client is whoever its `initialize` says it is; every client
arrives through the same shim, so the socket peer authenticates nothing; a grant gates what a NAME
can do.

**A found gap, whichever option she picks:** AppSpec §12 ("A-4's honest boundary (client identity is
self-declared and the pane says so)") and the 13n-b handoff both say the pane states this — but no
rendered string anywhere in the MCP faces does (searched `MCPPaneCopy`, `MCPPane`, `MCPGrantSheet`,
`MCPAskSheet`, `PrivateMark`, `SettingsShape`); the line went to the closeout's author checklist
instead (ledger row 6). **Recommended (L1), independent of K0–K2:** the pane gains the line it is
said to have, under Clients — *"A client names itself when it connects. Variorum can't verify the
name: a grant lets whatever connects under that name do what you granted."* (direct and technical —
R-13n-5). Drawn: mockup §11.

**Options (all honest about the limit):**
- **K0 — none.** A-4 stands as ruled; the boundary line stays the whole story.
- **K1 — a per-client secret minted at approval.** Approve… mints a secret for that client name;
  the pane then shows that client's OWN setup command carrying it (`claude mcp add -s user variorum
  -e VARIORUM_MCP_KEY=… -- "<shim>"`); the shim — still MCP-blind — sends it as a one-line preamble
  on the socket before the first frame; the server maps secret → identity and refuses a name that
  arrives without its secret. **Defeats:** two tools both calling themselves "claude-code" (by
  accident or copy-paste), a stray process launching the shim bare. **Does NOT defeat:** same-user
  malware — `~/.claude.json` is readable by any process running as her, so it can read the secret
  and present it. **Costs:** every client is set up twice (the request arrives before any secret
  exists, so after approval she re-runs a per-client command); a local-only column for the secret's
  hash (a local-only migration — zero lockstep, marker untouched); A-2's "protocol-blind byte
  pump" letter becomes "MCP-blind" (the preamble); rotation = revoke and re-approve.
- **K2 — a per-setup secret minted at Copy setup command.** The command she copies already carries
  a fresh secret; the first name that presents it binds to it at approval. One setup step, same
  defeats, same non-defeat.

**Recommendation:** K0 for the launch (a setup-flow change touches every new user's first five
minutes and the shim, this week); if she wants the hardening, **K2** as a named follow-on (fewer
steps than K1, the same protection). Either way the pane's boundary line stays true and is not
reworded to promise more.

## §13 — The chord sweep (the evidence, quoted)

**Swept, 2026-10-11, on `3ae4e72b`:** (1) `EditorCommands.keyEquivalent(for:)` — the authoritative
table; (2) every `.keyboardShortcut(` call site in `App/Variorum/Variorum` and `App/Variorum/Shared`
— outside `EditorCommands.swift` they are `.defaultAction`/`.cancelAction` sheet buttons plus four
scoped chords: `QuickNoteView` ⌘⏎ (the quick-note window) and ⇧⌘N, `PagedReadView` ←/→ unmodified,
`SpreadBookView` ←/→ and ⌥←/⌥→ (focused pane only); (3) every `NSMenuItem` keyEquivalent —
`MarkdownActs`, `CalloutMenu`, `EditorTextView`, `PaneSurface`, all `""`; (4) the key overrides —
`EditorTextView.performKeyEquivalent` (⌘S, plus the non-consuming ⌘Z/⇧⌘Z hint arm),
`EditorTextView`/`PaneSurface` keyDown (⇧⏎ soft newline), `CaptureTextView` (⏎/⇧⏎); (5) the local
monitors — `PageTurnKeys` (unmodified ←/→ only), `CommentPanelKeys` (⌘⏎, Esc), `DivideWSheet`
(plain, ⇧ and ⌥ keys in its own sheet only — it refuses any ⌘ or ⌃ event), `CalmAsks`
(observes, never consumes); (6) the system hot
key table — `GlobalHotKeyCenter.registered = [.quickNote]` (⇧⌘N); (7) the registry's declared chord
labels (`CapabilityRegistry.swift` — every one maps to the table).

**Taken in the app (by letter):** a ⇧⌘A · b ⌘B ⇧⌘B · c ⇧⌘C ⌥⌘C · d ⇧⌘D ⌥⇧⌘D · e ⌘E ⇧⌘E · f ⌘F ⌥⌘F
· g ⌘G ⇧⌘G · i ⌘I ⇧⌘I · j ⌘J · k ⌘K ⇧⌘K · l ⇧⌘L ⌃⌘L · m ⇧⌘M ⌥⇧⌘M · n ⌘N ⇧⌘N · o ⌥⌘O · s ⌘S ⇧⌘S
⌃⌘S · t ⌘T ⇧⌘T ⌥⌘T ⌥⇧⌘T · v ⇧⌘V · z ⌥⌘Z ⌥⇧⌘Z · digits ⌘1–⌘7 (Canvas Debug-only) ⇧⌘1–⇧⌘9 ·
brackets ⌘[ ⌘] ⌥⌘[ ⌥⌘] · ⌘/ · ⇧⌘' · arrows ⌃⌘←→↑↓ ⌥⌘←→ · return ⌘⏎ ⇧⌘⏎ ⌥⌘⏎ ⌥⇧⌘⏎.
**Platform-reserved (left alone):** ⌘, (Settings) ⌘A ⌘C ⌘V ⌘X ⌘Z ⇧⌘Z ⌘Q ⌘W ⌥⌘W ⌘H ⌥⌘H ⌘M ⌥⌘M
⌘P ⌘` ⌃⌘F ⌃⌘Q ⌃⌘D (Look Up) ⌃⌘Space ⌥⌘Space ⌥⌘D ⌥⌘Esc ⌥⇧⌘V.

**The candidates, each verified free in all seven places and not platform-reserved:** **⌥⌘A**
(no ⌥ `a` chord anywhere; ⌘A/⇧⌘A are the only `a` chords) · **⌥⇧⌘O** (the only `o` chord is ⌥⌘O) ·
**⌥⌘,** (the only `,` chord is SwiftUI's ⌘,) · **⌃⌘M** (`m` chords are ⌘M/⌥⌘M system + ⇧⌘M/⌥⇧⌘M) ·
**⌃⌘W** (`w` chords are ⌘W/⌥⌘W system only) · **⌃⌘1…⌃⌘9** (digits carry ⌘ and ⇧⌘ only) ·
**⌃⌘[ / ⌃⌘]** (brackets carry ⌘ and ⌥⌘ only). The build re-runs this sweep at its own tip and
records it beside each binding (the ⌥⌘O precedent at `EditorCommands.swift` line 161).

## §14 — Open items this round found (beyond the agenda)

1. **The ask's arrival: the handoff and the build disagree.** `phase-13n-b-handoff.md` says "asks
   queue quietly; nothing ever interrupts your writing"; the build presents a sheet on arrival
   (P-13nb-U2-9). §5's option X makes the sentence true; options Y/Z mean the handoff sentence
   needs correcting at the next touch.
2. **VX-161** is a candidate the kickoff names without content in the repo — the DRAFT plan lists it
   unsized.
3. **VX-158's reading** (§8) is stated, not confirmed.
4. **The A-4 line the canon says the pane carries is not rendered** (§12's found gap — AppSpec §12
   and the handoff vs the build). §12's L1 closes it; either way the canon sentence or the pane must
   change so they agree.
5. **Adjacent MCP tickets she may want for real users** (named, not proposed): VX-131 (unspent
   once grants time out), VX-133 (the receipt run counts undone acts), and the U2-era ops' guard
   retrofit (P-13nb-U2-8's sync twin, #209). None is in the kickoff's scope.

## §15 — The DRAFT plan's shape (P3 writes it whole)

U1 the grant road (§1, §2, §3 + VX-163/§9) · U2 the keyboard and the quiet signals (§4, §5, §6,
§7) · U3 the wing on the wire (VX-160/§10 + VX-158/§8) · candidates pending her nod: VX-159 (§11),
the A-4 secret (§12), VX-161.

## §16 — Mockup section map

§1 the grant sheet with searchable pickers (+ §1b the duplicate rule before/after) · §2 grant from
the Library · §3 the share chord · §4 the pending-ask badge + the Waiting list · §5 the MCP pane
chord · §6 the wing switcher with its chord · §7 VX-158's faces · §8 VX-163's confirm wordings ·
§9 VX-160's crossing door + her sweep · §10 VX-159's payloads · §11 the A-4 options.
