# VX-33 — The release runway (2026-10-13)

**Ticket · Project · Branch:** VX-33 (flagship of the Linear project *v1 release readiness*) · v1 release
readiness · none of its own. This file is a plan of plans: every run below has its own ticket, branch, PR
and record. The visual version for her browser is `vx-33-release-runway.html` beside this file.

**Why it exists — her ask (2026-10-13, verbatim):** *"it's timeee for us to plan and break into appropriate
phases and blocks ALL of the remaining work that needs to be done before release … your job right now is
just to help me get a handle on everything, figure out what can run in parallel / what needs to go in a
particular order (like mcp settings pane redone before i reword settings would be nice), etc. … I want to
focus my efforts on the changes that i have to live with and test out (esp with the MCP since that feature
is new) … giving me just a handful phase numbers to keep track of."*

**How to read it.** Linear holds status. This file holds the order, the parallel lanes, and the overlaps
every run must respect. A run's section below is its kickoff: `/run-phase vx-NNN` reads it together with the
run ticket's sub-issues and CLAUDE.md. Nothing here changes canon or makes a product decision; her rulings
are quoted where they bind, and what is still hers is listed in §6.

**No time predictions.** Her word (2026-10-13): *"let's not make predictions about length of time, coding
time works differently in our new AI world."* This file states order and dependencies only. Sizes (S/M/L,
units) are scope, not durations.

---

## 1. The six numbers

| Run | What it is | Members | Cast (implement / cold review) | Can start |
|---|---|---|---|---|
| **VX-266** Castle & backups | the custody and backup redesign (project + flagship) | the Castle project | Fable leads and writes the `Sync/` lines; Opus implements the rest | after her Castle decisions |
| **VX-246** MCP door fixes & AI docs | the door's security, correctness, wire asks, then the AI's docs last | 21 | Opus / **Fable** | now |
| **VX-281** MCP settings pane & shared icon | the pane in tabs, the code block, the Library's shared icon | 4 | Opus / Opus | now |
| **VX-282** Editor & notes fixes | backspace, the italics flicker, take panel, capture box, comments family | 9 | Opus / **Fable** (editor seam) | now |
| **VX-283** Sidebar & Library polish | the Open list, navigate-away, Library polish, exports, the test reds | 16 | Opus / Opus | now |
| **VX-284** Books, gatherings & tags | her VX-214 follow-ups, tag undo, the book view's doors and Index slice, VX-216 last | 15 | Opus / Opus | now |

Plus **her own track** (§4) and **the release itself** (§5).

**The date.** Her gate (2026-10-13, verbatim): *"I am gating public launch on castle being properly done no
matter how long it takes though."* The Castle work decides the date. The other five runs proceed in
parallel and merge as they finish. Every pre-launch ticket outside Castle has a home in one of them, or on
her own track.

---

## 2. Order and lanes — what waits for what

**Start now (no sitting needed):** VX-246, VX-281, VX-283, VX-282, VX-284. How many run at once is the
coordinator's call: they share one stage. **Castle** starts when her Castle decisions are made.

The dependencies, all of them:
1. **Castle.** Her decisions (the Keychain Access check, then D1–D10 in the second opinion §7) → one merged
   design + `notes/plans/vx-266-castle-backups-prelaunch.md` → phase 1 (headless core) → go/no-go → the
   remaining phases. Castle is THE one `Sync/`-or-custody effort while it runs. No other run may touch
   `Sources/VariorumCore/Sync/`, custody or the Keychain.
2. **VX-281 merges → she rewords the MCP pane** (VX-234). Every other pane can be reworded any time, except
   Protection and Data Safety, which wait for Castle's words (VX-264 changes them).
3. **VX-281 merges, and VX-246's door units are done → VX-246's docs unit (VX-197) runs.** The docs teach
   the final wire and describe the pane's tabs. They run LAST, as the plan file already says.
4. **VX-246's docs → the stargazing MCP guide.** The brief `notes/stargazing-mcp-guide-brief-2026-10-12.md`
   gets its final delta; her site agent publishes `stargazing.tech/variorum/mcp`. A build carrying the
   instructions' link ships only after that page is live (R-VX184-4).
5. **VX-258 (inside VX-246) gates any public build.** Her word: the build stays hers alone until VX-258 ships.
6. **Her tutorial/onboarding session (VX-292)** runs before VX-246 reaches its docs unit, or after VX-246
   merges. Never at the same time: both edit `TutorialSeeder`. Castle's words phase edits the guide's Castle
   lessons too, so rebase onto whichever lands first.
7. **Inside VX-284:** VX-303 (the book's open doors) lands before VX-304 (the Index slice), which rides the
   same landing road. VX-216 is last and author-attended: she joins one sitting on the book and gathering
   menus and settings sheets after the run's other units land, because they touch the same sheets.
8. **Closeouts serialize** (CLAUDE.md): first ready merges first, and the next rebases onto it.

**Shared files to watch** (the conflict map — any two runs here rebase carefully):
- **The navigate-away road** (`.variorumNotesDeleted` → `WorkspaceModel.notesDeleted`): VX-283 (VX-123 routes
  sync applies and `deleteReadingWithNotes` through it; the new Close Note act moves the pane on) and
  VX-246 (VX-275 sends her editor away before a wire delete). Whichever lands second builds on the first's
  road, never a second road.
- **Landing at a block:** VX-284 (VX-303 and VX-304 send book doors through `ShellRouter.adopt(landing:)` →
  `jump`) and VX-283 (Close Note's landing on the next note). Both use the existing roads; neither invents
  a new landing authority.
- **Faces refreshing after writes:** VX-283's VX-122 (one revival signal for the Library) and VX-246's
  VX-231 (stale Bookcase counts after an MCP write) may share a cause. VX-246 checks VX-283's signal before
  inventing its own.
- **`TutorialSeeder`:** VX-246 (docs), VX-292 (hers), VX-266 (Castle's words).
- **Settings:** VX-281 (the MCP pane), VX-284 (VX-240's "Opening your library…" face in the Settings
  scene's `.opening` arm), VX-266 (the Protection / Data Safety ceremonies), VX-234 (her wording).
- **The undo stack:** VX-246 alone (VX-276 + VX-277 + VX-119 are one rule).
- **The markdown face and the editor seam:** VX-282 (VX-290's backspace landing; VX-296's caret-aware
  restyle) and VX-246 (VX-275's flush; VX-230's badge if the trace lands there). All Fable-reviewed; none
  changes another's landing or styling rules without saying so.

**Capacity, said plainly.**
- **The stage.** Five build runs plus Castle's drills share the Pro's stage (`Tools/stage`). The
  coordinator session queues them, and every Mac batch and walk asks it first.
- **Fable.** Three efforts want Fable: Castle (leads), VX-246 (review) and VX-282 (review). If Fable's limits
  bind, Castle gets it first.

---

## 3. The runs — kickoff sections

Rules binding every run (on top of CLAUDE.md):
- **Effort.** Her VX-184 word was "Run everything at max effort". VX-246's plan carries it; for the other
  runs it's her call at kickoff.
- **Stage.** Asks go through the live coordinator session (REQUEST → READY → GO → RELEASE).
- **Commits.** Each names its member and `Part of VX-<run>`, with no attribution trailers, pushed per commit.
- **Every member** is pin-before-fix, red on old.
- **Closeout.** Each run ends with the /Applications refresh at a zero-instance window, unless the
  coordinator folds the refreshes.
- **No release** without her explicit word. She writes the notes.
- **Blocked by a state another session made** (a Castle posture, a lock screen, a held claim): ask that
  session or the coordinator for what's needed, such as the dev-Castle credentials at
  `~/.variorum/dev-castle.env`. Never discard or reset a store to get past it. Her 2026-10-13 example: dev
  runs paused at her Touch ID after another session had put the dev store in Castle, and sessions began
  moving the whole dev store aside when one ask for the passphrase and words was all it took.

### VX-246 — Run: MCP door fixes & AI docs
**Plan:** `notes/plans/mcp-pane-and-docs-kickoff.md` (its U6 section and the VX-268 bullet now belong to
VX-281; everything else stands). **Members:** VX-258 · VX-259 · VX-260 · VX-279 · VX-280 · VX-276 ·
VX-277 · VX-119 · VX-275 · VX-230 · VX-231 · VX-255 · VX-252 · VX-253 · VX-267 · VX-298 · VX-311 · VX-254 ·
VX-256 · VX-261 · VX-197. All pre-launch.

**Her MCP list, accounted for:** every ticket on it is in VX-246 or VX-281, and both run before launch.
Nothing on it is delayed except VX-262 (lenses on import), which stays parked at her word and was never in
the run. VX-245's two MCP sites ride VX-281.

**Suggested unit order** (one implementer session each; the orchestrator re-sizes at kickoff and tells her):
1. **The door's security and correctness:** VX-258 (setup keys tied to their tab; the launch gate), VX-259,
   VX-260, VX-279 (the socket fd reuse), VX-280 (the P1 breach).
2. **The undo class:** VX-276 (a redo after a quiet undo stays quiet), with VX-277 and VX-119 under the same
   rule — one fix in the undo stack, one pin per family.
3. **Her editor vs the wire:**
   - VX-275: flush and navigate-away before a wire delete, on the ONE road.
   - VX-230: the take badge. Her 2026-10-13 evening observation and the lead are on the ticket; it may not
     be MCP-specific at all.
   - VX-231: stale Bookcase counts.
   - Editor seam: read `notes/TEXTKIT2_NOTES.md`.
4. **Wire asks:** VX-255 (insert blocks: write new appends at the end, edit inserts anywhere — ruled),
   VX-252, VX-253 (ruled), VX-267 (labels drop "suggested"), VX-298 (AI opens Compare — all six of her calls
   answered on the ticket, incl. *replace the columns*), and VX-311 (`duplicate_note`, her Duplicate as Version on
   the wire — her pushback: *"the duplicate note tool should be easy?"*).
5. **Agent ergonomics:** VX-254, VX-256, VX-261.
6. **LAST — the AI's docs** (VX-197). This unit starts only after VX-281 has merged and main is merged in.

**Cast:** Opus implements; **Fable** cold-reviews, because VX-258 changes the key's accept path, VX-279 is the
socket road, and VX-275/VX-230 reach the editor seam.

**Evidence:** real-client live rounds per unit (Claude Code; Codex where it matters), Mac batches, the docs'
truth pins.

### VX-281 — Run: MCP settings pane & shared icon
**Plan:** `notes/plans/mcp-pane-and-docs-kickoff.md` — the **U6 section** and the **VX-268 bullet** under
HER ADDITIONS (her kickoff calls are there). **Members:** VX-199 · VX-205 · VX-232 · VX-268, plus the two MCP
sites of VX-245 (`MCPPane.swift:412`, `MCPGrantSheet.swift:285`). Claude Desktop (VX-299) is NOT in this run:
she tries it herself, outside the runs.

**Units:** (1) the pane in tabs with the code block (VX-199/205/232 + the two VX-245 sites), walked in both
voices; (2) the shared icon on every row that wears the ask glyph (VX-268), walked.

**Cast:** Opus / Opus (chrome only: no wire, editor seam, `Sync/` or custody). **Closes with** the FOR-VX-234
wording list posted to VX-234. That list is her pickup for the MCP pane's words.

### VX-282 — Run: Editor & notes fixes
**Members:** VX-290 (backspace) · VX-296 (the italics flicker) · VX-154 · VX-193 · VX-112 · VX-257 · VX-229 ·
VX-183 · VX-182.

**Units:**
1. **VX-290, the empty-block backspace.** Editor seam; its trace, ruling and pins are on the ticket. One
   ReturnKeyTrace pin flips by her report's ruling.
2. **VX-296, the italics flicker** (pre-launch at her word: *"it's a bit too buggy and annoying to
   remain"*). The closer half of the flanking rule refuses a closing `*` with a space before it. Fix (a), the
   recommendation: caret-aware in the live editor only; the grammar and the read pages are untouched.
   Shared markdown face, so both platforms' live editors.
3. **VX-154, the take panel's remaining routed commands.** The panel registration is the worked fix
   (`0deda5b4`, `2e5784ca`).
4. **VX-193 + VX-112, the capture box pair.** VX-193: undo desync, so ⏎ files undone words — the comments
   panel's per-area UndoManager is the precedent. VX-112: the focus re-grab, her "not urgent", judged on her walk.
5. **The comments family left by VX-179:**
   - VX-229 first (the popover leak).
   - VX-257 rides the same release hook.
   - VX-183 (the registry).
   - VX-182 (the purge fence, a query).

**Cast:** Opus / **Fable** (VX-290 is `EditorTextView` + `BlockRangeIndex`; VX-296 restyles the live storage).
Read `notes/TEXTKIT2_NOTES.md`. **Mobile-visible:** VX-296's shared face reaches the phone's live editor too
(say so in the MOBILE PARITY line); VX-290 is Mac-only (the phone has no carve).

### VX-283 — Run: Sidebar & Library polish
**Members:**
- The Open list (her 2026-10-13 asks): VX-285 (height) · VX-286 (scroll bar over ✕) · VX-287 (Close Note)
  · VX-288 (the drag) · VX-289 (multi-select, Close All).
- Navigation: VX-70 (the compact drag chip at the remaining rows, incl. the Open list's) · VX-123
  (navigate-away gaps).
- Library: VX-122 (revivals) · VX-19 (Timeline) · VX-20 (dark heading band) · VX-121 (toasts vs quick entry)
  · VX-175 (the controls row at the 1240-pt default window; pre-launch at her word).
- Exports: VX-125 · VX-126.
- The reds: VX-245 (its six non-MCP sites) · VX-167 (two tests red only in wide parallel runs).

**Units:**
1. **The Open list's layout and closing:** VX-285, VX-286, VX-287, VX-289. **Her ruling on VX-287:** Close
   Note = **⇧⌘W** (⌘W keeps closing the window), landing on **the next note in the list** — *"that way you
   can close them all quickly."* Verify ⇧⌘W is free first.
2. **The drag:** VX-288 — **the light version first** (her ruling) — + VX-70.
3. **Navigate-away and Library revivals:** VX-123, VX-122 — one signal each, on the existing roads.
4. **Library polish:** VX-19, VX-20, VX-121, VX-175.
5. **The exports:** VX-125, VX-126 — the format's one home stays `Domain/VariorumDocument`.
6. **The reds:** VX-245, VX-167.

**Cast:** Opus / Opus. **Pins that change by her ask:** `ShellChromeTests.theOpenStripWindowIsHerSevenAndAHalf`
and the shared-constant pin in `StarredScrollTests` (Starred keeps its 7, her words).

### VX-284 — Run: Books, gatherings & tags
**Members:**
- Gatherings and tags: VX-250 (her copy, NOT terms; closes VX-240) · VX-240 · VX-241 · VX-249 (collecting
  sets the star; pre-launch at her word) · VX-247 (tag-delete undo) · VX-111 (the shared-note notice).
- The honest disabled button: VX-194.
- The book view: **VX-303** (every open door lands in Write at her block — a bug against the deep-link rule,
  her words) · **VX-304** (an "open in Write" door in the left note box in every book mode — her ask: the title's
  "open ↗" is hard to see in a long note — plus Index takes badges, an in-place Takes sheet, "Takes" in Index's box,
  and Outline → Index keeps the block) · VX-291 (the ▸ target) · VX-21 (Book Panel grips) · VX-69 (order
  popover Escape).
- The reds: VX-77 · VX-115.
- Last, with her: VX-216.

**Units:**
1. **VX-250 + VX-241 + VX-249 + VX-194:** one register for the gathering doors' words, the collect door's
   star, and the style fix that makes greying visible app-wide (fold the one-off gathering face back in).
2. **VX-247, tag-delete undo:** one structural entry with an exact-row redo; the bigger restore road stays
   VX-238.
3. **VX-303, the book's open doors:** every door lands in **Write, at her block** — her ruling: *"more
   consistent and useful than the note's last used mode."*
4. **VX-304, the Index slice** (after VX-303, on the same landing road).
5. **The book view's small fixes and reds:** VX-291, VX-21, VX-69, VX-77, VX-115, VX-111.
6. **LAST, author-attended — VX-216,** the clarity pass on the book and gathering menus and settings sheets.
   She can pull it out to run alone.

**Cast:** Opus / Opus. The rest of the book view (landing inside Outline, Index → Outline at block level,
the full Index bar) is **VX-300, after launch** at her word.

### VX-266 — Castle & backups (project; flagship)
**Records:** `notes/plans/vx-266/` on branch `vx-266-castle-backups-before-launch` (worktree
`~/dev/variorum-vx-266`). The second opinion owns the design, and she is working with the Castle session
directly. Nothing builds before the plan file `notes/plans/vx-266-castle-backups-prelaunch.md` exists.

**Castle-adjacent tickets** for the Castle work to place:
- VX-113 (the changed-elsewhere passphrase refusal; her #205 ruling, pre-launch). It's the one pre-launch
  ticket outside every run; its refusal is the follow's, which Castle rebuilds.
- VX-81 (a macOS 27.0.1 crash in the re-key reopen; Backlog).
- VX-152 (the lock path's reentrancy; Backlog).
- VX-100 / VX-101 (Open Library's double passphrase ask and backups location; Backlog).
- VM-15 (a sibling phone that hasn't followed into Castle; pre-launch-labelled on the VM board).

---

## 4. Her own track

| What | When | Ticket |
|---|---|---|
| Castle decisions, with the Castle session | now — they decide the date | VX-266 |
| Settings wording, Editor through Acknowledgments | any time; **MCP pane after VX-281 merges**; Protection + Data Safety after Castle's words | VX-234 |
| Tutorial & onboarding changes (the Air session) | before VX-246's docs unit, or after VX-246 merges | VX-292 |
| VX-216's menus clarity sitting | when VX-284's other units have landed | VX-216 |
| Claude Desktop: try it herself, then decide on a guide paragraph | outside every run | VX-299 |
| Her readme and letter text | before launch, if the launch carries them | VX-105 |
| The MCP guide page + the privacy page (her site agent) | after VX-246's docs (MCP); any time (privacy) | VX-197 · VX-294 |
| The release notes (she writes them) | at release | — |
| The QUESTIONS #218 bundle (VX-184's provisionals) | **answered 2026-10-13** — all ratified as built | — |

---

## 5. The release — VX-33's gates

The launch build ships at her explicit word only, after:
1. Every pre-launch run has merged.
2. Castle is properly done — her gate, *"no matter how long it takes"*.
3. VX-258 has shipped.
4. The MCP guide page is live (R-VX184-4).
5. The privacy page is live (VX-294, a canon v1 gate).
6. A clean install on a Mac with none of her accounts or machine state runs (the canon v1 row's acceptance).
7. Her release notes are written.

The road is the proven one (memory: Variorum release publishing): bump the version, `Tools/Release/release.sh`
at a zero-instance window with no commits during it, then DMG first and appcast second on the site.

---

## 6. Her calls

**Answered (2026-10-13 evening; each is on its ticket in her words):**
- Close Note = **⇧⌘W**, landing on the next note (VX-287).
- VX-303 is pre-launch and lands in **Write** at the block.
- The book view's smallest version is pre-launch (VX-304); the rest waits until after launch (VX-300).
- Pre-launch: **VX-175 yes, VX-249 yes, VX-296 yes; VX-138 no** (she only wanted to know it was saved).
- The planner's additions (VX-277, VX-119, VX-241) are approved: *"your additions are fine."*
- Claude Desktop is her own try, outside the runs (VX-299).
- Code blocks (VX-295) and the held markdown mode (VX-293) come later.
- Public launch is gated on Castle being properly done, however long it takes.

**Answered later the same evening** (each on its ticket in her words):
- VX-288: the light drag version first.
- VX-268: her calls — Pool and Book Panel rows in, Blocks-scope rows out, the open book matches the Bookcase.
- VX-298: any two notes her picker offers; "related blocks only" off when there's no shared lineage; up to three
  peers; `link_versions`' "Open ›" opens Compare; **replace the columns**. `duplicate_note` is pre-launch too
  (VX-311, her pushback).
- VX-296: fix (a), caret-aware in the live editor only.
- **QUESTIONS #218:** every provisional ratified as built. Named pairs aligning Compare rows → VX-315 (after
  launch). An icon on AI-made commits, with no name in them → VX-316 (after launch). The capacity count is
  accepted: a capped book's `max_notes` counts fenced notes, so an AI can infer how many hidden notes there are.
  The wording items → her VX-234 pass.
- VX-304 gains the left-box "open in Write" door in every book mode (her ask).
- After launch: VX-312, ⌘1–⌘6 working from the caret inside a book (her ask).

**Still open:** VX-113's home, for the Castle session to place. Nothing else is waiting on her.

---

## 7. After launch — logged, not scheduled

- VX-300: the rest of the book view, made equal to the note's editor. Landing inside Outline and the full
  Index bar get a Fable review.
- VX-297: Library Cards beachballs on a fast scroll. Heavy cards built in bulk and big page landings
  mid-fling are the likely causes; relates to VX-17.
- VX-295: multi-line code blocks, and VX-293 (18e, whether a markdown mode exists at all).
- VX-138: the stack fan style without the chosen take.
- VX-312: ⌘1–⌘6 open the caret's note in that mode from inside a book.
- VX-315: named block pairs line Compare rows up.
- VX-316: an icon on AI-made commits (with the AI's name kept out of the commit's name).
- VX-248: the live-pane root fix.
- VX-244 / VX-242: the Takes and Lenses edges.
- VX-238: restoring a deleted tag (design first).
- VX-251: the 15-star limit.
- VX-236: the Settings titlebar bleed trace.
- VX-262: lenses on import.
- VX-226, VX-17, VX-219 (the colour picker, hers), and the Hardening backlog.
