# VX-246 — Run: MCP pane, docs & door fixes — kickoff + plan

**STATUS: IN PROGRESS — VX-246 kicked off 2026-10-13, 21:20 MDT (orchestrator session vx-246, named variorum-84 at kickoff). Its live state is the
run record `notes/plans/fixes/vx-246-mcp-door-fixes-ai-docs.md`: the units, the cast she set at kickoff, LIVE STATUS.
(Written 2026-10-13 at VX-184's re-scope.)**

**SPLIT 2026-10-13 (the release runway, `notes/plans/vx-33-release-runway.md`).** This file now serves TWO runs:
- **VX-281 "Run: MCP settings pane & shared icon"** takes the **U6 section** and the **VX-268 bullet** under HER
  ADDITIONS, and runs now, so the pane can merge early and her MCP-pane wording (VX-234) can follow it.
- **VX-246, retitled "Run: MCP door fixes & AI docs"**, keeps everything else. That is: her other additions;
  VX-275 · VX-276 · VX-279 · VX-280 (minted after this file was written, from VX-184's ladder); VX-277 and
  VX-119 (the same undo rule as VX-276); and the AI-opens-Compare ask.
- **U7 (the docs) stays LAST in VX-246, and starts only after VX-281 has merged**, because the docs describe
  the pane's tabs.
- The runway's VX-246 section carries the suggested unit order.
- Every rule under "Rules binding this run" binds both runs.

## Kickoff message (for `/run-phase vx-246`)

> Run VX-246, "Run: MCP door fixes & AI docs" (retitled twice on 2026-10-13 at her word; the plan file keeps its
> original name because tickets point at it).
>
> **Members:** its 21 sub-issues in Linear, the runway's list (`notes/plans/vx-33-release-runway.md` §3): VX-258 ·
> VX-259 · VX-260 · VX-279 · VX-280 · VX-276 · VX-277 · VX-119 · VX-275 · VX-230 · VX-231 · VX-267 · VX-253 · VX-252 ·
> VX-255 · VX-311 · VX-298 · VX-254 · VX-256 · VX-261 · VX-197 (U7 below). The U6 section and the VX-268 bullet are
> VX-281's, not this run's.
>
> **Coordinates:** one branch `vx-246-mcp-door-fixes-ai-docs`; one PR `VX-246: …` (merge commit); the record
> `notes/plans/fixes/vx-246-mcp-door-fixes-ai-docs.md`, whose THE UNITS table is the build order. Members close
> individually.
>
> **Reading, in order:**
> 1. This file, in full.
> 2. The runway's VX-246 section and its conflict map (§2).
> 3. VX-184's record (`notes/plans/fixes/vx-184-mcp-launch-polish.md`): its U1–U5 UNIT RECORDs say what the door now
>    does, THE LADDER is where most members were found and ruled, and its OWED sections are routed here.
>
> The binding rulings below, and on each member's ticket, are hers, verbatim where quoted. U7 (the docs) runs LAST,
> over the as-built state, after VX-281 merges.
>
> *(The kickoff orchestrator updated this message on 2026-10-13 to match the split: members, branch and record names.
> The earlier text named VX-281's U6 members and the pre-split branch.)*

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
- **VX-268: Library rows never wear the shared-with-AI icon** (notes, books, gatherings; only the Bookcase
  does). Filed by her Air session, joined at her word: *"this other ticket that should be done in the next round
  of mcp work"*. **Bug + Pre-launch:** a gap against VX-271's "one icon everywhere" (13n-c U3 built it on
  Bookcase rows and the in-note indicator only). Every Library row an approved client reaches wears the one
  `MCPSharedIcon` with its hover and popover, in List, Cards and Timeline. Gathering rows follow VX-185's
  truth (VX-184). P1: reach is read in proportion to the rows shown. **Scope audit (2026-10-13, code-level):**
  the waiting-ask icon renders in nine places, the shared icon in two (the Bookcase and the in-note indicator).
  The parity criterion, from her one-family ruling: wherever the waiting-ask icon marks a place, the shared icon
  marks it too. So **the wing switcher's rows (menu + ⌘L sheet) are IN scope.** A shared wing never shows as shared
  there, and nothing tracked it until this audit. **Hers at kickoff:** (1) the Pool rows and the Book Panel's rows
  (recommendation: in, by the same parity) and Blocks-scope rows (recommendation: no); (2) with the open book on,
  every row would wear it, as every Bookcase row does today (recommendation: match the Bookcase).
- **Her bilingual-book agent notes** (`notes/mcp-agent-notes-2026-10-13-bilingual-book.md`, the agent's own
  notes from building 'o ladrão de raios' through the door). Adjudicated 2026-10-13; she asked these to *"ride
  the next fix path"*:
  - **VX-252:** `create_note` returns take ids (+ optional `section_id`).
  - **VX-253:** `save_lens` by take label. **RULED — VX-253 (her word, 2026-10-13: *"I like your 253
    recommendation"*), with her clarification built in: `picks` overrides are applied FIRST, so a block a pick
    covers is never ambiguous; the refusal names only UNCOVERED ambiguous blocks, and the retry passes the same
    rule plus `picks` for exactly those (or the first call does, when the agent already knows):**
    - Three explicit fills, never a magic word: `picks`, `label`, or `pin_chosen: true`. `picks` can ride on
      either rule as per-block overrides.
    - A block with no take of that label shows its chosen take and is listed in `unmatched_blocks`.
    - Two matching takes on one block refuses the whole call, naming the blocks; the agent resolves them
      with `picks`.
    - Labels match exactly as stored, plus one convenience: a client's OWN suggestions match by their own
      part. "english" also matches "claude-code · suggested · english" for claude-code, never another
      client's. Her "english" plus the AI's suggested "english" on one block counts as two matches, so the
      call refuses. Per VX-267 the stored form becomes `<client> · <label>`; the legacy
      `<client> · suggested · <label>` matches too.
  - **VX-267 (Pre-launch) — AI take labels drop "suggested".** Her words, verbatim: *"why do we
    need claude-code * suggested * english. isn't it obvious it's suggested if it's claude? seems like an
    extra word."* Since VX-197, the client prefix appears only on takes an AI adds at suggest, so the name
    already says it. `aiLabel` (13n's P-13n-3, hers to re-voice) becomes `<client>` or `<client> · <label>`.
    Existing takes keep their labels (no migration); VX-253's matcher accepts both forms; U7's descriptions
    and the guide say the new form.
  - **VX-231 (stale Bookcase counts) — her call whether it joins:** possibly the same root cause as VX-230 (a
    face not refreshed after an MCP write; both were seen right after big MCP writes). Filed under 13n for now.
  - **VX-254:** content digests on write replies (stored-text digest per take; the algorithm and byte rule
    stated).
  - **VX-255:** `insert_blocks` into an existing note (a real R-VX184-1 parity gap). **Her lean (2026-10-13,
    verbatim):** *"I somewhat lean towards write new since it is literally writing new (and it can only be
    appeneded at the end, right? reordering isn't possible with write new?)"*. **The split that matches it
    and the house rule** (the catalog: at write new everything new lands at the END — `add_note_to_book` "at its
    end", `create_section` "at the end"; every placing or reordering act is edit — `move_block`,
    `move_note_in_book`, divide, merge): **write new appends new blocks at the note's END only; inserting after a
    specific block, between her existing paragraphs, needs edit.** **RULED — VX-255 (her word, 2026-10-13,
    verbatim):** *"VX-255: agreed, write new lets them add blocks at the end, edit lets them write blocks
    anywhere. I think that's a fair line to draw."*
  - **VX-256:** compact / paged `read_note` (ids-only form and/or block-range paging).
  - **Item 9 → VX-197** (commented): the label split. At SUGGEST, `add_take`/`add_takes` label a take
    `"<client> · suggested[ · <label>]"` (`aiLabel`, 13n's P-13n-3 convention, "hers to re-voice"). At WRITE NEW
    and EDIT, labels are stored exactly as given (`create_note`, `import_document`, `set_take_label` —
    P-VX195-5). **RULED — VX-197 (her word, 2026-10-13, verbatim):** *"it would be a mess to have claude
    code suggested english on every label if you're having claude make a ton of htem."* Keep the split: a
    suggestion is marked as a suggestion inside HER writing, and work she authorized it to write or edit
    keeps clean labels. The fix is every take-writing tool's description saying which applies (U7).
  - **VX-261 (item 5, her word):** a read tool listing the client's OWN recent acts from the activity log —
    recovery after a dropped call, and resuming a long job after the agent's context is lost. Idempotency
    tokens recorded as the heavier road not taken now (a local-only table + plumbing through every creating
    tool, for a rare case); revisit if scripted bulk jobs become common.
  - **VX-262 (item 8) PARKED at her word** — *"make a ticket with the ask but document that it isn't being done
    right now with the reasoning"*: a document-format change (13n-a's ruled format), and VX-253 gives most of
    the benefit without it. NOT in this run.
  - Item 7 is DONE in VX-184 (U4/U5 shipped note/chapter delete, remove-from-book, rename). The
    "automation setup" pane entry is not ticketed (the agent itself said only if bulk jobs become common).
- **VX-184's ladder round 1 (opus-reviewer) — three of HER RULINGS, fixed here** (record:
  `notes/plans/fixes/vx-184-mcp-launch-polish.md` § THE LADDER). Her word on timing: *"it's fine to put it in
  VX-246 - I won't put this release up for everyone, it'll be just for me until the fix goes out."* **→ GATE:
  VX-184's build stays HERS ALONE (no public release) until VX-258 ships.**
  - **VX-258 (re-bind, Pre-launch):** VX-198's re-bind lets ANY fresh key take ANY bound name with
    its approval and grants. Her ruling, verbatim: *"tie keys to their tab and for the general \"Any MCP
    client\" case, we should probably do the re-bind waits for my ok? i don't want everyone who isn't using
    claude or codex to be vulnerable to this. the best protection at each level"*. A Claude Code or Codex tab
    key re-binds only that tool's name, zero clicks; an Any-client key under a bound name re-binds only after
    her OK. The VX-168 impostor pin returns red-first.
  - **VX-259 (book-name oracle, Pre-launch):** `rename_book` + `create_book` check names only
    against books the client can READ. Her words: *"it's fine if an accidental book name duplicate is made -
    there's no schema protection against it and we already ruled that it's ok if that happens."* Her own
    doors keep the full guard.
  - **VX-260 (Pre-launch):** her edit makes an AI's comment hers; a suggest delete then needs edit
    and hears her R-VX188-2 sentence.

## Rules binding this run

- Cast per CLAUDE.md: Fable orchestrates by default (she redirects at kickoff); `opus-implementer` per unit,
  strictly sequential; the cold review is hers to name at kickoff. **Effort: her word during VX-184
  (2026-10-13, verbatim): *"Run everything at max effort - the implementer, reviewer, etc."*** Spawn every
  implementer and reviewer at `effort: max` unless she says otherwise at this kickoff. **Note for that call:** VX-258 changes the
  setup key's accept path (the original reason VX-184's kickoff named Fable), and VX-230 may reach the editor
  seam (Fable by CLAUDE.md). The rest is chrome, docs and wire tools.
- **Sizing:** with her additions this run is well past VX-184's planned U6 + U7. The kickoff sizes it into
  acceptance units (one per implementer session; `notes/PhaseSizingGuidance.md`) and SAYS SO to her. Never
  split or proceed silently.
- Zero `Sync/` and custody/keychain lines. **Schema: ALLOWED if needed — her word (2026-10-13, verbatim):**
  *"the next MCP fix session can have a schema change event if it seems like we need one."* A local-only
  change rides the grants family's road (its own commit, zero lockstep). A SYNCED change is a SyncSpec §12
  lockstep event whose mirror deploy still runs only on her explicit go at the time (CLAUDE.md). Read
  SyncSpec in full BEFORE writing it. U6 makes zero wire changes (the pane is faces); U7 changes only
  `MCPSession.instructions`, tool descriptions and the guide; the added tickets are wire work.
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
