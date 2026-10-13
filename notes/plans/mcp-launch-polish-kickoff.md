# VX-184 — Run: MCP launch polish — kickoff + plan

**Her word, 2026-10-12 night:** every needed/known MCP improvement runs TONIGHT, together, before tomorrow's
launch, and **the run runs all the way through** — her pre-run sitting (below) answered every question this plan
would otherwise stop on. Born from the session that used the door most (her readme editorial session on the Air,
2026-10-11/12). RUN ticket VX-184; members are its sub-issues. Run it with `/run-phase vx-184` (the RUN rule: one
branch `vx-184-mcp-launch-polish`, one PR `VX-184: …`, record `notes/plans/fixes/vx-184-mcp-launch-polish.md`,
members close individually).

## FIRST — release facts (read before anything else)

- **VX-180 is now installed on the Air (build 6518), verified 2026-10-12:** a bridge-free Claude Code
  registration (pointing straight at `/Applications/Variorum.app/Contents/MacOS/variorum-mcp`) passed
  `claude mcp list` (Connected) and a real `claude -p` tool call (`list_books` answered). Her own user-scope entry
  still runs the bridge (`~/.variorum/mcp-discover-bridge.py`) until she re-runs the pane's setup.
- **The Pro's installed build is unverified** — check it the same way before trusting it.
- The launch build must be cut from main AFTER this run merges; the closeout's acceptance includes a bridge-free
  `claude mcp list` + one real tool call against the refreshed install.

## HER PRE-RUN SITTING — the rulings (2026-10-12, the Air; recorded verbatim where quoted)

- **R-VX184-0 — nothing drops:** *"I don't want any of these items dropped particularly. I feel like it's possible
  to build it all in this single run and we should just choose that now."* Every member ships; the order below is
  the build order, never a priority cut.
- **R-VX184-1 — EDIT means as capable as her at the keyboard:** *"We defined Edit as 'as capable as you at the
  keyboard', we need to make that true."* Every ordinary authoring act she has on a note or a book gets a door
  tool at the edit rung (VX-195, VX-196). **Deleting a block's LAST take deletes the block** — *"that's just
  deleting the block at that point, right? and can't AI do that?"* — the same road as `delete_block`, said in the
  receipt and the tool's description; I10 holds because the block goes, never a takeless block.
- **R-VX184-2 — three acts stay hers alone: the Private mark, Seal, Own** — *"Private, Seal, and Own can continue
  being excluded, though the AI should know about them so it can tell a user that they might want that. I'll
  consider in time if seal and own should be added."* The AI-facing docs explain all three (VX-197).
- **R-VX184-3 — the AI's instructions bound rises 2,000 → 3,000 characters** (her pick) — room for the
  organization advice, the new tools, R-VX184-2's awareness and the website line. `MCPSession.instructionsBound`
  and its pin move together.
- **R-VX184-4 — a public MCP guide on stargazing.tech, LIVE BEFORE LAUNCH**, linked by one instructions sentence.
  This repo writes the page's content as a brief for her site agent (the 2026-10-04 privacy/FAQ brief precedent:
  `notes/stargazing-…-brief-<date>.md`); **she carries it to the stargazing agent** — the run never touches that
  repo. The instructions sentence names the URL the brief proposes; the handoff says the link is dead until the
  page is up, and the build MUST NOT ship before it is (a handoff checklist line, first).
- **R-VX185-1 — gatherings:** *"I think that's fine on the gathering isn't marked shared even if each individual
  note is marked shared."* Only a wing grant or the open book icons a gathering.
- **R-VX187-1 — `link_versions`: the AI NAMES the paragraph pairs** (at least one `{block_a, block_b}` across the two
  notes); never positional guessing. One linked pair makes the notes Compare peers (`Queries.versionPeerPosts`).
- **R-VX188-1 — comments:** at EDIT, any comment (edit/delete/restore — VX-195). At SUGGEST, a client deletes only
  ITS OWN, known from a new **local-only** authorship record (the grants family's road: local, never synced, zero
  lockstep — her pick, *"local only record is fine for clarity / for now"*). Absent record (another Mac, an adopted
  library) ⇒ the suggest-rung delete refuses — **as a `rungTooLow`-family refusal, NOT the not-shared shape** — her words for the sentence
  (2026-10-12): **"You don't have permission to delete that comment. Suggest raising your permission level to
  edit."** (RULED, R-VX188-2 — her sentence, "permissions" → "permission" the only edit). Why not the not-shared
  shape (the pre-run review's catch, her ratification): the client can READ the comment — it just got the id — so "doesn't
  exist" would be a lie that trips clients; 13n-c's R2-6 precedent for a reachable thing past your reach. No oracle
  is opened: the refusal reveals only that the comment isn't recorded as this client's).
- **Docs (VX-197), her asks:** the field guide's MCP chapter gets 13s's quality pass (below); it explicitly
  encourages Variorum for ORGANIZATION; its lessons cover every tool this run adds. She confirmed the guide lives
  in the field guide (*"I like the MCP guide being in the field guide, that's solid"*).
- **R-VX184-5 — newest copied setup wins (VX-198):** *"the whole path where you have to deny it and then reset it
  is a bit annoying and cumbersome even for my beta testers"* — a key minted by her Copy setup command press
  re-binds the client's name on first presentation, approval and grants KEPT; the name's previous key then refuses
  with its own sentence ("a newer setup replaced this one — run its setup again"); an unissued key and a bare shim
  refuse as today; Deny unchanged. Supersedes P-VX168-U1-1's rotation road as the everyday path. VX-178 parked as
  superseded.
- **R-VX184-6 — the MCP pane, her pick (VX-199):** the enable switch + status on top; **Waiting above the tabs**
  whenever asks are pending; tabs **Connect · Clients · Shared with AI · Activity**; it opens on Connect while no
  client is approved, else on Clients; every explainer cut to one line with the full text behind an (i) popover.
  Her words: *"just clicking on it, you wouldn't know without scrolling down where the command to set it up is …
  as a settings pane, it has a LOT of text."* Only the MCP pane — her other panes are her separate pass.

## Members and units (strictly sequential, one implementer session per unit)

| unit | members | what |
|---|---|---|
| **U1** | VX-132 → VX-181 → VX-198 | The socket and key road. VX-132 first (the harness gets connect/call time limits, so the night's runs can't hang). VX-181: the shim with the app closed answers the probe AND reads on to the initialize, so "Variorum must be open" reaches the user; one shared echoable-id predicate in `VariorumMCPSocket` for both call sites (VX-180's NIT). Also here: an over-cap message answers a JSON-RPC error before closing where the read loop can do it cleanly (argue it; PROVISIONAL if not) — today 1 MiB opening frames / 16 MiB after admission end the connection silently. **Boundary pins (her 2026-10-12 ask — the size check the Air session didn't finish):** in the headless harness, a message just under each cap is admitted and served, and one just over is answered or closed as built; plus a realistic large write (a `create_note` of a 300-block, ~200 KB document) round-trips through the real shim in the live round. An over-`lineLimit` opening frame has no parseable id mid-line, so its answer, if built, is an error with `id: null` (legal JSON-RPC). **VX-198** (R-VX184-5): the newest-copy re-bind in `MCPSetupKeyRule`/`admitMCPConnection` + its faces (the setup sentence "Running it again replaces the old setup", the Deny confirm, the replaced-key refusal sentence); the VX-168 drill's impostor leg re-pinned to the new rule. **Acceptance on the WIRE, not the client's display** (the pre-run review's point): the shim's refusal answering the initialize is captured on the wire; what Claude Code chooses to display is RECORDED AS FOUND, never the pass/fail. |
| **U2** | VX-185 | Gatherings wear the shared icon (below). The one walk. |
| **U3** | VX-186 · VX-173 (door half) · VX-188 · VX-190 · VX-187 | The wire's ergonomics: `read_note` with_ids stops sending each shown text twice (argue the shape; keep `via` coherent) · `add_takes` + `add_comments` batches (one transaction, one undo entry, all-or-nothing, an item cap argued and STATED in each tool's description, over-cap refuses naming it) · suggest-rung delete of a client's own comment (R-VX188-1's local record) · `remove_tag` at edit (§9's removeTag; untagging stays a non-event for intake) · `link_versions` per R-VX187-1 (write new on both notes). |
| **U4** | VX-195 | Edit parity inside a note (R-VX184-1): comments — edit/delete/restore any; takes — delete (the last take ⇒ the block, R-VX184-1), archive, label, lock/unlock; commits — restore (insured first, as her restore is), rename a message; the note — rename its title, delete a saved lens. |
| **U5** | VX-196 | Edit parity across the library (her picks): at edit on the book/wing — take a note out of a book (Release on an owned book), reorder notes and chapters, rename/delete a chapter, rename a book, finish/unfinish, archive/unarchive, delete a book (the daily Journal archives, never deletes — its guards stand); at edit on the note — delete (Trash, 30 days) and archive/unarchive. Private/Seal/Own excluded (R-VX184-2). |
| **U6** | VX-199 | The MCP pane per R-VX184-6 — every existing door and pin kept working (Answer…, ⌥⌘, landing on Waiting, Change…/Revoke rows, "all N ›", the setup menu's O-4 fence); the walk in both voices, captured for her morning review. |
| **U7** | VX-197 | The AI's docs, written LAST so they describe what was built (below). **NEVER a fall-out (the pre-run review's point):** whatever else ships, U7's truth pass runs over the AS-BUILT state — the instructions, the guide chapter and the website brief's DELTA describe exactly what merged, so neither the public page nor the in-app advice overstates the app on launch day. |

**Sizing, said plainly (per `notes/PhaseSizingGuidance.md`):** seven units, none phase-sized, one implementer session
each — inside the guidance, but the largest RUN to date; U4/U5 are many small tools on one proven pattern
(VX-168 U2's: each tool = an existing §9 op + the grant guard inside its transaction + ONE client-named undo entry
where her own door has one; an act her door makes undo-less stays undo-less and its description says so).

## VX-185 — the gatherings icon

Her report: *"gatherings don't show as being shared with AI right now (the icon doesn't appear on them) even when
you've shared the whole wing with AI. they definitely need to have the shared icon on them even if they're just a
gathering … but if they're shared as part of the wing, that needs to be clear."* Cause: `Queries.mcpBookReaches`
(`MCPShareQueries.swift` ~267) selects `kind = 'book'` only, yet a wing grant / the open book READS that wing's
gatherings (R-AIR-12 — which stands: a gathering is never a grant's own scope; direct gathering sharing is VX-189,
post-launch). Build: the same icon whenever an approved client reaches the gathering through a wing grant or the
open book (the one `decide`, never a parallel rule); the popover says why ("claude-code can read this through the
wing “Home”"); Change…/Revoke act on that wing grant and say so; every reach surface treats gatherings the same.
Pins: wing ⇒ iconed, wing named · note/book-only grants ⇒ not (R-VX185-1) · open book ⇒ iconed · archived follows
the archived-book rule. One walk, dev store, held claim, both voices.

## VX-197 — the AI's docs (U6)

1. **The field guide's "AI & the MCP door" chapter** (`TutorialSeeder.mcpChapter`, its truth suite
   `TutorialMCPChapterTests`):
   - **13s's quality pass:** sentence case everywhere, no capitalized word for emphasis mid-sentence (her
     standing "no shouty caps" rule), the field guide's calm, professional, clear voice; plain sentences, nothing
     that reads as AI-written (no stacked em-dash asides, no throat-clearing, no inflated adjectives). Known item:
     lesson 1 says "way in" twice.
   - **Organization, encouraged explicitly:** an AI can put things into notes and books for you, file notes into
     chapters, tag notes, and make books that collect by tag rules — worked as recipes beside her existing four.
   - **Every new tool this run adds**, taught in the lesson it belongs to (batch adds, deleting comments, takes and
     commits, removing a tag, linking versions, the library acts).
   - **Private / Seal / Own explained** as hers alone — what each does and why an AI might suggest it (R-VX184-2).
   - Any sentence a unit falsified (e.g. the connection-limit sentence, the edit rung's description).
2. **The AI's instructions** (`MCPSession.instructions`, bound now 3,000 — R-VX184-3): the organization advice,
   R-VX184-2's awareness, the edit rung's new reach, and ONE sentence linking the website guide (R-VX184-4).
   Provider-neutral (O-4's fence) and truth-pinned as today. Tool descriptions carry their own caps and acts.
3. **The stargazing.tech MCP guide** (R-VX184-4): ALREADY BRIEFED to her site agent the same night, written from
   this plan's rulings — `notes/stargazing-mcp-guide-brief-2026-10-12.md` — at the FIXED URL
   `https://stargazing.tech/variorum/mcp` (the instructions sentence uses exactly that). The page describes acts,
   not tool names, for what this run builds. U6's job: check the brief against what was BUILT and write a short
   DELTA (any fact the build changed, plus the final tool-name list) at the end of the brief file, for her to
   carry to the site agent in the morning.
4. **Re-seed note for her handoff:** her existing library gains the updated chapter only via Help ▸ Restore
   Tutorial… (it tombstones the old guide into the Trash and mints a fresh one — say so).

## Rules binding this run

- **VX-173's disposition:** re-scoped to the DOOR half (built in U3, closes at the merge); the human bulk face is
  its own parked ticket, **VX-200** — nothing evaporates.
- **Stage contention (the pre-run review's point):** VX-179 is mid-run on the same Pro stage. While the
  oct12coordinator session is live, every stage ask from this run goes through its REQUEST → READY → GO → RELEASE
  protocol; no priority claim is assumed for VX-184 — VX-180's priority ended with its merge. If the coordinator
  has closed, the plain `Tools/stage` claim rules apply.
- **The canon deltas owed at the merge (listed now, VX-168-style):** AppSpec §12's THE MCP DOOR line — the
  instructions bound "≤2,000" → "≤3,000" (R-VX184-3); the edit rung's new act families (R-VX184-1, the last-take
  rule) and the three hers-alone acts (R-VX184-2); the suggest rung's own-comment delete and its local record
  (§7's grants family gains it); `link_versions`, `remove_tag`, the batch tools, `read_note`'s new shape; the
  shim's VX-181 window; A-4's boundary amended for newest-copy-wins (R-VX184-5); the pane's tabs (R-VX184-6);
  the gatherings-icon line (R-VX185-1). QUESTIONS entry for every PROVISIONAL incl. P-VX184-1.

- Preflight in full (CLAUDE.md's list) + `notes/plans/fixes/vx-180-discover-probe.md`,
  `notes/plans/fixes/vx-168-mcp-client-secret.md` (the handshake/secret records and U2's edit-act pattern) + the
  13n-c plan (R-AIR-12, the reach queries, the chapter's U5/U6 records).
- **Cold review: `fable-reviewer`** (the socket road is the secret's accept path; the permission core grows). One
  ladder over the whole run's diff, cap three. Pin-before-fix per member, red-on-old verified by revert.
- Commits say `Part of VX-184` (and the member id), NO attribution trailers; push after every commit;
  `notes/SessionResiliencyProtocol.md` binds.
- **Zero `Sync/`, custody/keychain or editor-seam lines; zero SYNCED schema.** The one schema change allowed is
  R-VX188-1's local-only authorship record, on the grants family's road (`MCPGrantSchema`, its own commit, no
  `sync_version`, no trigger, export strips it; marker 13 untouched). Anything that would need a synced change:
  STOP that member, log it for her, continue the rest.
- Stage: every Mac test batch, walk and live round under a held `Tools/stage` claim (the Pro's).
- **Live rounds** (evidence of kind): U1 — a real Claude Code client against the Debug app on the dev store,
  including "Variorum must be open" with the app closed; U3 — a batch write landing as one undo, a 20-block
  `read_note` without the duplicate, `link_versions` making Compare pair the two notes; U4/U5 — one real client
  turn exercising a representative act of each family, ⌥⌘Z walking each back.
- **Closeout:** the A1 `/Applications` refresh at a zero-instance window **coordinated with her** — never quit or
  kill her running app. After it: a bridge-free `claude mcp list` + one real call. Her handoff leads with: (1) the
  stargazing brief to carry to the site agent BEFORE the build ships; (2) re-run the pane's Claude Code setup on
  the Air to retire the bridge (and tell the beta tester the same); (3) Help ▸ Restore Tutorial… for the new
  chapter; (4) the PROVISIONALs.
