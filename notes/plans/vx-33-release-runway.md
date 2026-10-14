# VX-33 — The release runway (2026-10-13)

**Ticket · Project · Branch:** VX-33 (flagship of the Linear project *v1 release readiness*) · v1 release
readiness · none of its own. This file is a plan of plans: every run below has its own ticket, branch, PR
and record. The visual version for her browser is `vx-33-release-runway.html` beside this file.

**Why it exists — her ask (2026-10-13, verbatim):** *"it's timeee for us to plan and break into appropriate
phases and blocks ALL of the remaining work that needs to be done before release … your job right now is
just to help me get a handle on everything, figure out what can run in parallel / what needs to go in a
particular order (like mcp settings pane redone before i reword settings would be nice), etc. … I want to
focus my efforts on the changes that i have to live with and test out (esp with the MCP since that feature
is new) … i do still want to get this released in the next couple of days … giving me just a handful phase
numbers to keep track of."*

**How to read it.** Linear holds status. This file holds the order, the parallel lanes, and the overlaps
every run must respect. A run's section below is its kickoff: `/run-phase vx-NNN` reads it together with the
run ticket's sub-issues and CLAUDE.md. Nothing here changes canon or makes a product decision; anything that
needs her word is listed in §6.

---

## 1. The six numbers

| Run | What it is | Members | Cast (implement / cold review) | Can start |
|---|---|---|---|---|
| **VX-266** Castle & backups | the custody and backup redesign (project + flagship) | 17 | Fable leads and writes the `Sync/` lines; Opus implements the rest | after her decisions (§2) |
| **VX-246** MCP door fixes & AI docs | the door's security, correctness, wire asks, then the AI's docs last | 20 | Opus / **Fable** | now |
| **VX-281** MCP settings pane & shared icon | the pane in tabs, the code block, the Library's shared icon | 4 | Opus / Opus | now |
| **VX-282** Editor & notes fixes | backspace, take panel, capture box, comments family | 8 | Opus / **Fable** (editor seam) | now |
| **VX-283** Sidebar & Library polish | the Open list, navigate-away, Library polish, exports | 14 | Opus / Opus | now |
| **VX-284** Books, gatherings & tags | her VX-214 follow-ups, tag undo, the book view's small fixes, VX-216 last | 12 | Opus / Opus | now |

Plus **her own track** (§4) and **the release itself** (§5).

**The honest timeline.**
- **Everything except Castle** can close in about two days if the five runs start tonight. Each is one to
  six units, and units run one implementer session at a time. They share one stage, so walks and Mac test runs
  queue through the coordinator.
- **Castle as designed** is one design sitting and then six phases in a row (the second opinion's §6). The
  phases can't overlap: they depend on each other, and only one `Sync/`-or-custody effort may run at a time.
  At roughly a day per phase (the migration phase is the riskiest, and the earlier custody build took twelve
  implementer sessions), that's close to a week after her decisions.
- **So Castle sets the launch date, not the other runs.** The go/no-go after Castle's headless first phase is
  the designed moment to take the smaller "middle road" (proposal §12, about three phases) if the date matters
  more. That choice is hers.
- If the date is fixed at a couple of days, the only other road is shipping before Castle's redesign. Her own
  reason for doing it before launch argues against that: *"I don't want this mess to propogate once I have
  users in every conceivable configuration and state with backups in every conceivable configuration and
  state."*

---

## 2. Order and lanes — what waits for what

**Start tonight (no sitting needed):** VX-246, VX-281, VX-283. **Next, or tonight if the coordinator says the
stage can take it:** VX-282, VX-284. **Castle** starts when §2's Castle steps are done.

The dependencies, all of them:
1. **Castle.** Her two-minute Keychain Access check → her rulings D1–D10 (the second opinion §7) → one merged
   design + `notes/plans/vx-266-castle-backups-prelaunch.md` → phase 1 (headless core, no stage) → go/no-go →
   phases 2–6. Castle is THE one `Sync/`-or-custody effort while it runs. No other run may touch
   `Sources/VariorumCore/Sync/`, custody or the Keychain.
2. **VX-281 merges → she rewords the MCP pane** (VX-234). Every other pane can be reworded any time, except
   Protection and Data Safety, which wait for Castle's words phase (VX-264 changes them).
3. **VX-281 merges, and VX-246's door units are done → VX-246's docs unit (VX-197) runs.** The docs teach
   the final wire and describe the pane's tabs. They run LAST, as the plan file already says.
4. **VX-246's docs → the stargazing MCP guide.** The brief `notes/stargazing-mcp-guide-brief-2026-10-12.md`
   gets its final delta; her site agent publishes `stargazing.tech/variorum/mcp`. A build carrying the
   instructions' link ships only after that page is live (R-VX184-4).
5. **VX-258 (inside VX-246) gates any public build.** Her word: the build stays hers alone until VX-258 ships.
6. **Her tutorial/onboarding session (VX-292)** runs before VX-246 reaches its docs unit, or after VX-246
   merges. Never at the same time: both edit `TutorialSeeder`. Castle's words phase edits the guide's Castle
   lessons too, so rebase onto whichever lands first.
7. **VX-284's last unit (VX-216)** is author-attended. She joins one sitting on the book and gathering menus
   and settings sheets after the run's other units land, because they touch the same sheets.
8. **Closeouts serialize** (CLAUDE.md): first ready merges first, and the next rebases onto it.

**Shared files to watch** (the conflict map — any two runs here rebase carefully):
- **The navigate-away road** (`.variorumNotesDeleted` → `WorkspaceModel.notesDeleted`): VX-283 (VX-123 routes
  sync applies and `deleteReadingWithNotes` through it; the new Close Note act moves the pane on) and
  VX-246 (VX-275 sends her editor away before a wire delete). Whichever lands second builds on the first's
  road, never a second road.
- **Faces refreshing after writes:** VX-283's VX-122 (one revival signal for the Library) and VX-246's
  VX-231 (stale Bookcase counts after an MCP write) may share a cause. VX-246 checks VX-283's signal before
  inventing its own.
- **`TutorialSeeder`:** VX-246 (docs), VX-292 (hers), VX-266 (Castle's words).
- **Settings:** VX-281 (the MCP pane), VX-284 (VX-240's "Opening your library…" face in the Settings
  scene's `.opening` arm), VX-266 (the Protection / Data Safety ceremonies), VX-234 (her wording).
- **The undo stack:** VX-246 alone (VX-276 + VX-277 + VX-119 are one rule).
- **The editor seam:** VX-282 (backspace) and VX-246 (VX-275's flush, VX-230's badge if the trace lands there)
  both get Fable reviews; neither may change the other's landing rules without saying so.

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

### VX-246 — Run: MCP door fixes & AI docs
**Plan:** `notes/plans/mcp-pane-and-docs-kickoff.md` (its U6 section and the VX-268 bullet now belong to
VX-281; everything else stands). **Members:** VX-258 · VX-259 · VX-260 · VX-279 · VX-280 · VX-276 ·
VX-277 · VX-119 · VX-275 · VX-230 · VX-231 · VX-255 · VX-252 · VX-253 · VX-267 · VX-298 · VX-254 · VX-256 ·
VX-261 · VX-197.

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
   VX-252, VX-253 (ruled), VX-267 (labels drop "suggested"), and VX-298 (AI opens Compare — her six
   calls are on the ticket).
5. **Agent ergonomics** (not pre-launch, in the run at her word): VX-254, VX-256, VX-261.
6. **LAST — the AI's docs** (VX-197). This unit starts only after VX-281 has merged and main is merged in.

**Cast:** Opus implements; **Fable** cold-reviews, because VX-258 changes the key's accept path, VX-279 is the
socket road, and VX-275/VX-230 reach the editor seam.

**Evidence:** real-client live rounds per unit (Claude Code; Codex where it matters), Mac batches, the docs'
truth pins.

### VX-281 — Run: MCP settings pane & shared icon
**Plan:** `notes/plans/mcp-pane-and-docs-kickoff.md` — the **U6 section** and the **VX-268 bullet** under
HER ADDITIONS (her kickoff calls are there). **Members:** VX-199 · VX-205 · VX-232 · VX-268, plus the two MCP
sites of VX-245 (`MCPPane.swift:412`, `MCPGrantSheet.swift:285`). **VX-299 (Claude Desktop) joins if she
picks (b) or (c):** the live round first, then the setup tab; post Desktop's client name to VX-258 so
VX-246's re-bind table knows it.

**Units:** (1) the pane in tabs with the code block (VX-199/205/232 + the two VX-245 sites), walked in both
voices; (2) the shared icon on every row that wears the ask glyph (VX-268), walked.

**Cast:** Opus / Opus (chrome only: no wire, editor seam, `Sync/` or custody). **Closes with** the FOR-VX-234
wording list posted to VX-234. That list is her pickup for the MCP pane's words.

### VX-282 — Run: Editor & notes fixes
**Members:** VX-290 (backspace) · VX-154 · VX-193 · VX-112 · VX-257 · VX-229 · VX-183 · VX-182.

**Units:**
1. **VX-290, the empty-block backspace.** Editor seam; its trace, ruling and pins are on the ticket. One
   ReturnKeyTrace pin flips by her report's ruling.
2. **VX-154, the take panel's remaining routed commands.** The panel registration is the worked fix
   (`0deda5b4`, `2e5784ca`).
3. **VX-193 + VX-112, the capture box pair.** VX-193: undo desync, so ⏎ files undone words — the comments
   panel's per-area UndoManager is the precedent. VX-112: the focus re-grab, her "not urgent", judged on her walk.
4. **The comments family left by VX-179:**
   - VX-229 first (the popover leak).
   - VX-257 rides the same release hook.
   - VX-183 (the registry).
   - VX-182 (the purge fence, a query).

**Cast:** Opus / **Fable** (VX-290 is `EditorTextView` + `BlockRangeIndex`). Read `notes/TEXTKIT2_NOTES.md`.
**Nothing mobile-visible** (the phone has no carve).

### VX-283 — Run: Sidebar & Library polish
**Members:**
- The Open list (her 2026-10-13 asks): VX-285 (height) · VX-286 (scroll bar over ✕) · VX-287 (Close Note)
  · VX-288 (the drag) · VX-289 (multi-select, Close All).
- Navigation: VX-70 (the compact drag chip at the remaining rows, incl. the Open list's) · VX-123
  (navigate-away gaps).
- Library: VX-122 (revivals) · VX-19 (Timeline) · VX-20 (dark heading band) · VX-121 (toasts vs quick entry).
- Exports: VX-125 · VX-126.
- VX-245 (its six non-MCP sites).

**Units:**
1. **The Open list's layout and closing:** VX-285, VX-286, VX-287, VX-289. **Her two calls on VX-287 come
   first:** the chord, and where the pane lands.
2. **The drag:** VX-288 (build shape S, then her walk decides on M) + VX-70.
3. **Navigate-away and Library revivals:** VX-123, VX-122 — one signal each, on the existing roads.
4. **Library polish and the reds:** VX-19, VX-20, VX-121, VX-245.
5. **The exports:** VX-125, VX-126 — the format's one home stays `Domain/VariorumDocument`.

**Cast:** Opus / Opus. **Pins that change by her ask:** `ShellChromeTests.theOpenStripWindowIsHerSevenAndAHalf`
and the shared-constant pin in `StarredScrollTests` (Starred keeps its 7, her words).

### VX-284 — Run: Books, gatherings & tags
**Members:**
- Gatherings and tags: VX-250 (her copy, NOT terms; closes VX-240) · VX-240 · VX-241 (the planner's
  addition) · VX-247 (tag-delete undo) · VX-111 (the shared-note notice).
- The honest disabled button: VX-194.
- The book view: VX-291 (the ▸ target) · VX-21 (Book Panel grips) · VX-69 (order popover Escape).
- The reds: VX-77 · VX-115.
- Last, with her: VX-216.

**Units:**
1. **VX-250 + VX-241 + VX-194:** one register for the gathering doors' words, and the style fix that makes
   greying visible app-wide (fold the one-off gathering face back in).
2. **VX-247, tag-delete undo:** one structural entry with an exact-row redo; the bigger restore road stays
   VX-238.
3. **The book view's small fixes and reds:** VX-291, VX-21, VX-69, VX-77, VX-115, VX-111.
4. **LAST, author-attended — VX-216,** the clarity pass on the book and gathering menus and settings sheets.
   She can pull it out to run alone.

**Cast:** Opus / Opus.

### VX-266 — Castle & backups (project; flagship)
**Records:** `notes/plans/vx-266/` on branch `vx-266-castle-backups-before-launch` (worktree
`~/dev/variorum-vx-266`): the design proposal, cold read 1, the second opinion (which now owns the design),
its cold read, and the Apple facts.

**Next, in order:**
1. Her Keychain Access check.
2. Her rulings D1–D10 (each recorded with her words on the ticket the second opinion names).
3. One merged design.
4. The plan file `notes/plans/vx-266-castle-backups-prelaunch.md`.
5. Six phases, with a go/no-go after the first.

Nothing builds before the plan file exists. **Castle-adjacent tickets** for the sitting to place:
- VX-113 (the changed-elsewhere passphrase refusal; her #205 ruling, pre-launch).
- VX-81 (a macOS 27.0.1 crash in the re-key reopen; Backlog).
- VX-152 (the lock path's reentrancy; Backlog).
- VX-100 / VX-101 (Open Library's double passphrase ask and backups location; Backlog).
- VM-15 (a sibling phone that hasn't followed into Castle; pre-launch-labelled on the VM board).

---

## 4. Her own track

| What | When | Ticket |
|---|---|---|
| Castle: the Keychain check + D1–D10 | **first — it gates the long pole** | VX-266 |
| Settings wording, Editor through Acknowledgments | any time; **MCP pane after VX-281 merges**; Protection + Data Safety after Castle's words | VX-234 |
| Tutorial & onboarding changes (the Air session) | before VX-246's docs unit, or after VX-246 merges | VX-292 |
| VX-216's menus clarity sitting | when VX-284's other units have landed | VX-216 |
| Her readme and letter text | before launch, if the launch carries them | VX-105 |
| The MCP guide page + the privacy page (her site agent) | after VX-246's docs (MCP); any time (privacy) | VX-197 · VX-294 |
| The release notes (she writes them) | at release | — |
| The QUESTIONS #218 bundle (VX-184's provisionals) | before VX-246's kickoff, ideally | — |

---

## 5. The release — VX-33's gates

The launch build ships at her explicit word only, after:
1. Every pre-launch run has merged.
2. Castle has merged, or she has taken its cut line at the go/no-go.
3. VX-258 has shipped.
4. The MCP guide page is live (R-VX184-4).
5. The privacy page is live (VX-294, a canon v1 gate).
6. A clean install on a Mac with none of her accounts or machine state runs (the canon v1 row's acceptance).
7. Her release notes are written.

The road is the proven one (memory: Variorum release publishing): bump the version, `Tools/Release/release.sh`
at a zero-instance window with no commits during it, then DMG first and appcast second on the site.

---

## 6. Her calls

**Before the runs reach them:**
- **VX-287, the Close Note chord:** ⌘W = Close Note with ⇧⌘W = Close Window (the Safari/Xcode convention;
  costs on the ticket), or ⌃⌘W. Also: where the pane lands after a close (recommended: the next row, else
  the previous, else the Library).
- **VX-288, the drag:** shape S first and her walk decides on M (recommended), or M from the start.
- **VX-268's kickoff calls** (on the ticket): the Pool and Book Panel rows (recommended in), Blocks-scope rows
  (recommended no), and the open book (recommended: match the Bookcase).
- **VX-298, AI opens Compare** (six calls on the ticket). Recommended:
  - any two notes her picker would offer, with no link required;
  - open with "related blocks only" off when the notes share no lineage;
  - up to three peers;
  - `link_versions`' "Open ›" opens Compare.
  
  Undecided: replace the open columns or fill the empty ones. A `duplicate_note` tool would be its own
  ticket after launch.
- **VX-299, Claude Desktop:** never tested, with no known blocker; the Any-client setup is already the
  shape Desktop's config reads. (a) Out for launch, (b) verify live (about an hour, with her OK to edit
  her Claude config) plus a docs paragraph, or (c) verify plus a Desktop setup tab (about half a day).
  Recommended: (b) at least.
- **VX-300, editing from the book view without losing her place** (her report, 2026-10-13):
  - "Open in editor" lands at the note's top.
  - Index ↔ Outline and "view in outline" forget the position.
  - Index offers no block tools and no takes.
  
  Canon already allows the core fix (R-18l-1: deep links keep their targets). The size and a minimum
  slice come from a read-only trace that was still running when this was written; the result lands on
  the ticket. Then she decides pre-launch: likely a minimum slice riding VX-284 (the book surfaces),
  or its own run.

**Pre-launch, yes or no** (none is labelled Pre-launch until she says so):
- **VX-175, the Library controls row at the default 1240-pt window:** the search field squeezes and the info
  panel is pushed off-window at the app's own default size. Recommended **yes** (first impression), riding VX-283.
- **VX-249, collecting an existing note sets the star:** small; rides VX-284 with VX-250 if yes.
- **VX-138, a stack fan style that doesn't repeat the chosen take** (her 2026-10-10 ask; today in 13q
  Delight): one FanStyle option; would ride VX-282 if yes.
- **VX-248, the live-pane root fix:** recommended **after launch**. VX-222 and VX-227 already closed every
  reachable case, and this bends P-3 in the editor seam right before launch.
- **VX-244 / VX-242, the Takes/Lenses edges:** recommended after launch (VX-216 may fold VX-244 in).
- **VX-295, multi-line code blocks:** phase-sized (two units: editor seam, a format change, both platforms),
  with eight design questions on the ticket. **After launch**, as she said for a big one, and designed after
  her markdown-mode question in **VX-293** (18e, held), which it depends on.
- **VX-296, the italics flip:** she needs to say which one she saw. (a) Typing: emphasis doesn't nest (bold
  inside italics drops the italics; `**` flickers through italic). (b) Clicking between blocks: the live block
  shows dimmed markers and blocks at rest hide them, which is intended; 18e's fade is the designed fix.
  Recommended after launch unless (a) bites her daily.
- **The planner's additions, hers to veto:** VX-277 and VX-119 (into VX-246, same rule as VX-276); VX-241
  (into VX-284, same sentence as VX-250).

**Answered by the record** (no call needed):
- VX-217, the gathering foot's New note: **done** (VX-214, in 0.9.5).
- VX-227: done, as she said.
- VX-138 is her "stack without the chosen take" idea, recorded 2026-10-10.
- Mobile is not in the v1 launch (canon: `notes/release-and-v1-strategy.md`, *"it is NOT in the v1 launch"*).
  VM-15 stays on the VM board for Castle's sitting to weigh.

---

## 7. After launch — logged, not scheduled

- VX-297: Library Cards beachballs on a fast scroll. Heavy cards built in bulk and big page landings mid-fling
  are the likely causes. Diagnosis takes one session; relates to VX-17.
- VX-296: the italics flip, unless her answer moves it up.
- VX-295: multi-line code blocks, and VX-293 (18e, whether a markdown mode exists at all).
- VX-238: restoring a deleted tag (design first).
- VX-251: the 15-star limit.
- VX-236: the Settings titlebar bleed trace.
- VX-262: lenses on import.
- VX-226, VX-17, VX-219 (the colour picker, hers), and the Hardening backlog.
