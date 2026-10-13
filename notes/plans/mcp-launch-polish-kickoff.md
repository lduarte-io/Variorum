# VX-184 — Run: MCP launch polish — kickoff + plan

**Her word, 2026-10-12 night:** every needed/known MCP improvement runs TONIGHT, together, before tomorrow's
launch. Born from the session that used the door most (her readme editorial session on the Air, 2026-10-11/12:
reads, ~40 takes, ~20 comments, lenses, two note mints through a live Claude Code client). RUN ticket VX-184;
members are its sub-issues. Run it with `/run-phase vx-184` (the RUN rule: one branch `vx-184-mcp-launch-polish`,
one PR `VX-184: …`, record `notes/plans/fixes/vx-184-mcp-launch-polish.md`, members close individually).

## FIRST — a release fact, not a ticket (read before anything else)

**The installed app on the Air (build 6497) does NOT carry VX-180.** Checked 2026-10-12 with Claude Code's exact
two-frame opening (`server/discover` then `initialize`) straight at `/Applications/Variorum.app/…/variorum-mcp`:
refused and closed. VX-180 is merged (`5235c096`, ledgers `af0a7747`), but the installed build predates it — her
Air connects today only through the bridge (`~/.variorum/mcp-discover-bridge.py`). **The launch build must be cut
from main at or after `af0a7747`, and this run's closeout refresh is what gets it onto her Macs.** Verify the Pro's
installed build the same way before trusting it. The closeout's acceptance includes that probe passing WITHOUT
the bridge on the refreshed install.

## Members, in order (launch-gating first; the tail is the named fall-out if the night runs short)

| # | ticket | what | gate? |
|---|---|---|---|
| 1 | **VX-181** | Shim with the app closed answers the probe, not the initialize — "Variorum must be open" never shows. VX-180's pre-initialize window applied in the shim's refusal read (`Sources/VariorumMCPSocket/MCPShim.swift`) + the ladder's shared echoable-id predicate (one predicate in `VariorumMCPSocket`, both call sites). | **launch** |
| 2 | **VX-185** | Gatherings never wear the shared-with-AI icon. `Queries.mcpBookReaches` (`MCPShareQueries.swift` ~267) selects `kind = 'book'` only, yet a wing grant / the open book READS that wing's gatherings (R-AIR-12). Fix below. | **launch** |
| 3 | **VX-132** | VariorumMCPTests' socket harness can hang intermittently — give connect/call a time limit. Tonight's suites run on it; a hang costs the night. | reliability |
| 4 | **VX-186** | `read_note` with_ids sends each block's shown text twice (block `text` + the chosen take). | ergonomics |
| 5 | **VX-173** (unparked — DOOR HALF ONLY) | Batch writes: `add_takes` (array of {block_id, label, text}) — and, argued under the same unit, `add_comments` — ONE transaction, ONE client-named undo entry. The human bulk face stays parked (her "where it comes"). | ergonomics |
| 6 | **VX-188** | A client can remove its OWN comment (`delete_comment`, suggest rung). | ergonomics |
| 6b | **VX-190** (added at her word, 2026-10-12) | `remove_tag(note_id, tag)` at the EDIT rung — §9's removeTag, one client-named undo; untagging stays a NON-event for intake (no book evicts). The tag vocabulary itself (rename/delete) stays human-only. | ergonomics |
| 7 | **VX-187** | `link_versions` (a `version_of` link between two notes, write-new on both) so Compare pairs AI-made drafts. | ergonomics — first to fall out |

Units (one implementer session each, strictly sequential — CLAUDE.md's cast): **U1** = #1 + #3 (the socket
road; VX-132 first so U1's own runs can't hang) · **U2** = #2 (the one UI-visible change — its walk) · **U3** =
#4 + #5 + #6 + #6b (the wire's ergonomics) · **U4** = #7. Four units, none phase-sized — inside the sizing guidance;
say so in the record. If time runs short, U4 then U3's #6 fall out first, by name, tickets kept.

## VX-185 — the gatherings icon (her words, and what is ruled)

Her report: *"gatherings don't show as being shared with AI right now (the icon doesn't appear on them) even
when you've shared the whole wing with AI. they definitely need to have the shared icon on them even if they're
just a gathering … but if they're shared as part of the wing, that needs to be clear."*

What stands (R-AIR-12, 13n-c): a gathering is **never a grant's own scope or a write's target** — it holds no
notes, only a rule, so its contents move whenever a tag does; grants name notes, books and wings. But a wing
grant (or the open book) **reads** that wing's gatherings. So the bug is the icon telling her less than the door
allows. Build:

- A gathering wears the SAME shared icon whenever an approved client reaches it now through a wing grant or the
  open book (the same `decide` the server consults — never a parallel rule).
- Its popover says WHY in those terms — e.g. "claude-code can read this through the wing “Home”" — the ruled
  why-naming idiom of the book popover. **Change… / Revoke act on the reaching WING grant**, and say so (a wider
  grant's Revoke names the grant it takes — the 13n-c rule). No "share this gathering" door is added.
- Every surface that reads reach treats a gathering the same way (Book Settings' grant row for a gathering, the
  census/listing icons if any).
- Pins: wing grant ⇒ iconed with the wing named · note- or book-only grants ⇒ not iconed (even when every member
  is shared — PROVISIONAL, log it: the alternative "iconed when any member is readable" is hers to choose) · open
  book ⇒ iconed · an archived gathering ⇒ follows the archived-book rule. One walk on the dev store under a held
  stage claim, both voices.

## Notes for the other members

- **VX-186:** argue the shape (drop the block-level duplicate, or replace it with the chosen take's id); keep the
  lens read's `via` coherent; update the tool description + any advice sentence it falsifies (the advice is near
  its 2,000-character cap — measure).
- **VX-173 door half:** one transaction, one undo entry for the whole batch, the grant guard inside it, a sane
  cap on items per call (argue it). Partial failure = the whole call refuses (no half-batches).
- **VX-188:** only the client's OWN comments; anything else answers the one not-shared shape (no oracle). It
  needs comment authorship: if `block_comment` doesn't already record which client wrote it, **STOP and report**
  — a new synced column is a SyncSpec §12 lockstep event and is NOT tonight's.
- **VX-187:** §9's `version_of` edge is BLOCK-to-block; if note-level linking turns out to be a design question,
  **STOP and log it for her** (QUESTIONS) rather than invent.

## Rules binding this run

- Preflight in full (CLAUDE.md's list) + `notes/plans/fixes/vx-180-discover-probe.md` and
  `notes/plans/fixes/vx-168-mcp-client-secret.md` (the handshake + secret records) + the 13n-c plan (R-AIR-12 and
  the reach queries). SyncSpec only if a unit discovers it needs a synced change — then STOP.
- **Cold review: `fable-reviewer`** (the socket/handshake road is the secret's accept path — her protocol, the
  VX-168/VX-180 precedent). One ladder over the whole run's diff, cap three. Pin-before-fix per member, red-on-old
  verified by revert.
- Commits say `Part of VX-184` (and the member id), NO attribution trailers; push after every commit;
  `notes/SessionResiliencyProtocol.md` binds.
- Zero `Sync/`, custody/keychain or editor-seam lines; zero schema (VX-188's stop rule above).
- Stage: every Mac test batch, walk and live round under a held `Tools/stage` claim (the Pro's).
- **Live round** (evidence of kind for U1 and U3): a real Claude Code client against the Debug app on the dev
  store — VX-168 U1 leg 4 / VX-180's round as the precedent — including the shim answering "Variorum must be open"
  with the app closed (VX-181), a batch write landing as one undo, and a 20-block `read_note` without the
  duplicate.
- **Closeout:** the A1 `/Applications` refresh at a zero-instance window **coordinated with her** — never quit or
  kill her running app. After the refresh: the two-frame probe passes WITHOUT the bridge (the FIRST section).
  Her handoff says: re-run the pane's Claude Code setup once on the Air to retire the bridge (and tell the beta
  tester the same), and lists the PROVISIONALs.
