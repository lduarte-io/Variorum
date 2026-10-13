# VX-246 — Run: MCP pane & AI docs — kickoff + plan

**STATUS: PLANNED, not started (written 2026-10-13 at VX-184's re-scope; she adds items before kickoff).**

## Kickoff message (for `/run-phase vx-246`)

> Run VX-246 "Run: MCP pane & AI docs". Members are its sub-issues in Linear: VX-199 · VX-205 · VX-232 (U6)
> and VX-197 (U7), plus any items the author adds below under **HER ADDITIONS**. One branch
> `vx-246-mcp-pane-and-docs`, one PR `VX-246: …` (merge commit), record `notes/plans/fixes/vx-246-mcp-pane-and-docs.md`,
> members close individually. Read this file in full. Then read VX-184's record
> (`notes/plans/fixes/vx-184-mcp-launch-polish.md`): its U1–U5 UNIT RECORDs say what the door now does, and their
> OWED sections are routed here. The binding rulings below are hers, verbatim where quoted. U7 runs LAST,
> over the as-built state.

## Why this run exists (her words, 2026-10-13)

*"ok I've made the decision that I want you to finish U5 and move U6 & U7 to a new phase … and I'll add a couple
items to that new phase. that will let me get the current MCP changes earlier on my own build so that I can test
them out a bit more and will let me fold in and handle other feedback."* VX-184 shipped U1–U5 (the socket and
key road, the gatherings icon, the door's ergonomics, edit parity inside a note and across the library). This run
carries VX-184's planned U6 and U7 plus whatever her own testing turns up.

**The gap this run closes:** the field guide's MCP chapter and `MCPSession.instructions` don't yet TEACH VX-184's
new tools (batches, comment deletes, `link_versions`, `remove_tag`, the 12 note-edit acts, the 14 library acts).
Each tool's own description is truthful, so nothing the docs say is false; they undersell.

## Binding rulings carried from VX-184's pre-run sitting (`notes/plans/mcp-launch-polish-kickoff.md`)

- **R-VX184-6, the MCP pane, her pick (VX-199):** the enable switch + status on top; **Waiting above the tabs**
  whenever asks are pending; tabs **Connect · Clients · Shared with AI · Activity**; it opens on Connect while no
  client is approved, else on Clients; every explainer cut to one line with the full text behind an (i) popover.
  Her words: *"just clicking on it, you wouldn't know without scrolling down where the command to set it up is …
  as a settings pane, it has a LOT of text."* Only the MCP pane.
- **VX-205, her add (2026-10-12), verbatim:** *"the block that has the code command to be copied should be in one
  of those nice little code blocks you see in UI's everywhere, with the super clear copy icon in the upper right. I
  feel like there's a very standard look for copying commands, we should follow that."* The one declared copy
  act's meaning and the O-4 provider fence stay unchanged. The icon is a second door to the same act, or the
  act's new face; argue the registry shape and keep every existing pin's meaning.
- **R-VX184-2, three acts stay hers alone: Private, Seal, Own.** *"…though the AI should know about them so it
  can tell a user that they might want that."* The AI-facing docs explain all three (VX-197).
- **R-VX184-3, the instructions bound rises 2,000 → 3,000 characters.** `MCPSession.instructionsBound` and its
  pin move together.
- **R-VX184-4, the public MCP guide on stargazing.tech, live before launch**, at the FIXED URL
  `https://stargazing.tech/variorum/mcp`, linked by ONE instructions sentence. **The launch gate travels with
  that sentence:** a build carrying the link must not ship before the page is live. (VX-184's build carries no
  link, so it wasn't gated.)

## The work

### U6: the MCP pane in tabs (VX-199 · VX-205 · VX-232)

- R-VX184-6's layout and VX-205's code block, as above. **Every existing door and pin keeps working:**
  Answer…, ⌥⌘, landing on Waiting, the Change…/Revoke rows, "all N ›", the setup menu's O-4 fence, the
  pending marks, Esc = Don't allow.
- **The edit rung's words (VX-184 U4/U5 OWED):** the grant sheet's edit sentence and the toggle blurb say "with
  a commit before and after every change". Since VX-184 that holds only for take TEXT changes. Bring the
  pane's and the sheet's explainers to the as-built reach (U3's batches/links, U4's 12 note acts, U5's 14
  library acts): one line each, the full text in the (i) popover.
- **VX-232, verify:** the setup segment resets to Claude Code on a voice flip while the receipt keeps the
  Any-client sentence. If the rebuild moots it, say so with the proof (it closes with the run). Otherwise fix
  it red-first.
- **ChromeLineLimitTests:** two of its 8 bare `.fixedSize()` sites are MCP files, `MCPPane.swift` (~412) and
  `MCPGrantSheet.swift` (~285). Fix both in passing to the suite's sanctioned form. **VX-245** (VX-214's
  ticket) lists them as fixed-by-us; post the hash there. Don't touch the other six.
- **The Settings window shell is VX-214's (merged, PR #156):** its content area is **748×520**. The tabbed
  pane must lay out inside it with no clipped tab row and no scroll to reach Connect's code block. Edits to
  `SettingsShape.swift` stay on the MCP rows only. If a reusable explainer-(i) component is minted, tell the
  settings effort its name and home.
- **Wording (her standing mandate):** pane words ship AS BUILT, and a "FOR VX-234" list (every wording call,
  where it renders) is posted to **VX-234**, her pane-wording review. No QUESTIONS entry for pure pane
  wording.
- **Evidence:** the pane suites + faces pins; a Mac batch; **the WALK in BOTH voices**, captured for her review.
  Cover: fresh pane (Connect); an approved client (Clients); Waiting above the tabs with a pending ask; each tab;
  each (i) popover; the code block's copy icon pressed and the clipboard pasted, proving the same copy act;
  Answer… and ⌥⌘, landing on Waiting; a Change…/Revoke row.

### U7: the AI's docs, LAST, a truth pass over the as-built state (VX-197)

1. **The field guide's MCP chapter** (`TutorialSeeder.mcpChapter`; truth suite `TutorialMCPChapterTests`):
   - **13s's quality pass:** sentence case, no shouty caps, the guide's calm, clear voice; nothing that reads
     as AI-written. Lesson 1 says "way in" twice.
   - **Organization, encouraged explicitly:** notes, books, chapters, tags, and books that collect by tag
     rules, as recipes beside her four.
   - **Every tool VX-184 added**, taught in its lesson: batch adds, comment deletes (own at suggest, any at
     edit), `remove_tag`, `link_versions`, the note-edit acts (takes, commits, title, lens), the library acts.
   - **Private / Seal / Own** explained as hers alone (R-VX184-2).
   - **Lesson 7's icon sentence** says "a book or a gathering" (VX-184 U2's carry).
   - **Lesson 3's edit step:** "commits just before and just after" holds for take text changes only (U4's
     OWED).
   - **Build on VX-201's merged guide changes** (VX-204's amended lesson 1, VX-209's guide warning). Never
     overwrite them.
2. **`MCPSession.instructions`** (bound 3,000, R-VX184-3): the organization advice, R-VX184-2's awareness, the
   edit rung's new reach, and ONE sentence linking `https://stargazing.tech/variorum/mcp` (exactly that URL).
   Provider-neutral (O-4) and truth-pinned. **`edit_take`'s 13n-b description** over-promises the "before"
   commit, which is deduped when unchanged; Claude Code caught the same class live on `restore_commit` in
   VX-184 U4. Fix it to the truth.
3. **The stargazing brief** (`notes/stargazing-mcp-guide-brief-2026-10-12.md`): VX-184's closeout appends a
   delta for U1–U5's as-built facts. This run appends a FURTHER delta for anything its pane/docs change on the
   page, and leaves the file reading as ONE send-ready message (she carries it to her site agent). **VX-148**
   is honest there: deleted comments aren't readable on the wire, so `restore_comment` works on ids the client
   holds.
4. **Re-seed note for her handoff:** her library gains the updated chapter only via Help ▸ Restore Tutorial…
   (it tombstones the old guide into the Trash and mints a fresh one; say so).

## HER ADDITIONS

*(She adds items here or as sub-issues of VX-246 before kickoff. Whatever she adds is binding on the kickoff.)*

- **VX-230: the first take badge misdrawn after an MCP write** (Bug, Pre-launch). Her word, 2026-10-13:
  *"I want that fix added to the upcoming session."* The symptom, her words: the first take icon is *"either
  present when it shouldn't be or a filled in black circle"*. Her new observation: *"I found that going into
  takes mode and expanding and closing it fixed it, which makes it seem even more like a chrome issue."* The
  ticket also carries her earlier real-store sighting ('o ladrão de raios', block 1, caret on it) and VX-184
  U1's darker ⑂2 on a single-take block. **Lead:** a Takes expand/collapse clearing it points at a STALE badge
  face (the badge's decoration not invalidated when an MCP write lands), not wrong store data. Trace that
  invalidation road and pin it red-first. **If the trace reaches the editor seam** (`EditorTextView`, the
  decoration layer), read `notes/TEXTKIT2_NOTES.md` first, and the review is Fable's (CLAUDE.md).
- **Her bilingual-book agent notes** (`notes/mcp-agent-notes-2026-10-13-bilingual-book.md`, the agent's own
  notes from building 'o ladrão de raios' through the door). Adjudicated 2026-10-13; she asked these to *"ride
  the next fix path"*:
  - **VX-252:** `create_note` returns take ids (+ optional `section_id`).
  - **VX-253:** `save_lens` by take label. Design calls are in the ticket: no magic label value, a duplicate
    label on one block, and the client-prefixed `aiLabel` vs the as-given `create_note` label.
  - **VX-254:** content digests on write replies (stored-text digest per take; the algorithm and byte rule
    stated).
  - **VX-255:** `insert_blocks` into an existing note (a real R-VX184-1 parity gap). **The rung is HER CALL:**
    EDIT vs WRITE NEW. Orchestrator lean: EDIT, since it changes what her note reads and every other act
    that changes an existing note's content sits at edit. Write new would be defensible only as "adds, never
    alters".
  - **VX-256:** compact / paged `read_note` (ids-only form and/or block-range paging).
  - **Item 9 → VX-197** (commented): the `add_take` vs `create_note` label inconsistency; U7's descriptions
    say which applies.
  - **Held for her assessment (not minted):** item 5 (idempotency tokens; the orchestrator proposes a
    cheaper road) and item 8 (lenses on import; a document-format change). See the chat record of
    2026-10-13.
  - Item 7 is DONE in VX-184 (U4/U5 shipped note/chapter delete, remove-from-book, rename). The
    "automation setup" pane entry is not ticketed (the agent itself said only if bulk jobs become common).

## Rules binding this run

- Cast per CLAUDE.md: Fable orchestrates by default (she redirects at kickoff); `opus-implementer` per unit,
  strictly sequential; the cold review is hers to name at kickoff. The diff is chrome + docs, no `Sync/`,
  custody or editor seam, so `opus-reviewer` qualifies.
- Zero `Sync/`, custody/keychain or editor-seam lines; zero schema; zero wire changes in U6 (the pane is
  faces). U7 changes only `MCPSession.instructions`, tool descriptions and the guide.
- Stage: every Mac batch and walk under a held `Tools/stage` claim (or the coordinator session's protocol, if
  one is live). **Dev store under Castle posture:** a lock screen unlocks from `~/.variorum/dev-castle.env`
  (source it; her standing rule, CLAUDE.md). Never invent new values, never write them anywhere. The What's
  New sheet may greet a Debug launch: close it with its own button.
- Commits name the member + `Part of VX-246`, NO attribution trailers, push per commit;
  `notes/SessionResiliencyProtocol.md` binds.
- **Canon deltas owed at THIS run's merge** (moved here from VX-184): AppSpec §12 THE MCP DOOR line, with the
  instructions bound "≤2,000" → "≤3,000" (R-VX184-3), the pane's tabs (R-VX184-6), and the docs' as-built
  teaching. QUESTIONS entry for every PROVISIONAL.
- **Closeout:** the /Applications refresh; the handoff leads with carrying the stargazing brief to her site
  agent, BEFORE any build carrying the instructions link ships.
