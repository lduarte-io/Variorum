# VX-281 — Run: MCP settings pane & shared icon — the run record

**STATUS: OPEN — kickoff 2026-10-13 evening (orchestrator session variorum-75, Opus 5.5).**

**Ticket · branch · worktree · PR:** VX-281 (a RUN; its sub-issues are the members) ·
`vx-281-run-mcp-settings-pane-shared-icon` · `~/dev/variorum-vx-281` on the Pro · one PR `VX-281: …`, merge
commit only. **Plan:** `notes/plans/mcp-pane-and-docs-kickoff.md` — its **U6 section**, its **"Binding rulings
carried from VX-184's pre-run sitting"**, its **"Rules binding this run"**, and the **VX-268 bullet** under HER
ADDITIONS. **Runway:** `notes/plans/vx-33-release-runway.md` §2 (order, lanes, the shared-files map) and §3
(the rules binding every run + the VX-281 section).

**Why it exists:** split out of VX-246 on 2026-10-13 so the MCP pane merges early. Her Settings wording pass
(VX-234) wants the pane rebuilt first: *"mcp settings pane redone before i reword settings would be nice"*.
VX-246's docs unit (VX-197) waits on THIS run's merge, because the docs describe the pane's tabs.

## Members

| Ticket | What | Unit |
|---|---|---|
| VX-199 | the MCP pane in tabs (R-VX184-6, her pick) + the edit rung's explainers at the as-built reach + the 748×520 fit | U1 |
| VX-205 | the setup command in a standard code block with a copy icon, upper right | U1 |
| VX-232 | verify: a voice flip resets the setup segment to Claude Code while the receipt keeps the Any-client sentence — mooted by the rebuild (proof), else fixed red-first | U1 |
| VX-245 (two sites only — VX-214's ticket) | `MCPPane.swift` (~412) and `MCPGrantSheet.swift` (~285) bare `.fixedSize()` → the lint's sanctioned form; hash posted on VX-245; the other six sites untouched | U1 |
| VX-268 | the ONE shared icon (`MCPSharedIcon`) wherever the waiting-ask glyph (`MCPAskGlyph`) marks a place | U2 |

## Her rulings binding this run (verbatim where quoted)

- **R-VX184-6, the pane (VX-199):** the enable switch + status on top; **Waiting above the tabs** whenever asks
  are pending; tabs **Connect · Clients · Shared with AI · Activity**; opens on Connect while no client is
  approved, else on Clients (remembered per session); every explainer cut to one line with the full text behind
  an (i) popover. *"just clicking on it, you wouldn't know without scrolling down where the command to set it up
  is … as a settings pane, it has a LOT of text."* Only the MCP pane.
- **VX-205:** *"the block that has the code command to be copied should be in one of those nice little code
  blocks you see in UI's everywhere, with the super clear copy icon in the upper right. I feel like there's a
  very standard look for copying commands, we should follow that."* The one declared copy act's meaning and the
  O-4 provider fence stay unchanged.
- **VX-268's kickoff calls (her word 2026-10-13, "VX-268: agree with your suggestions"; on the ticket):**
  **Pool rows and the Book Panel's rows: IN** (parity — wherever the waiting-ask glyph marks a place, the shared
  icon marks it too). **Blocks-scope rows: NO** (the note's own indicator already says it). **The open book:
  match the Bookcase** (with the open book on, every row it reaches wears the icon). The wing switcher's rows
  (menu + ⌘L sheet) are IN by the same parity (the scope audit on the ticket).
- **Wording:** pane words ship AS BUILT; every wording call goes on the **FOR VX-234** list below (where it
  renders), posted to VX-234 at close. No QUESTIONS entry for pure pane wording. Sentence case, no shouty caps.
- **The cast and effort — HER KICKOFF REDIRECT (2026-10-13 evening, verbatim):** *"you're running as the
  orchestrator Opus at Max thinking - run implementers on xhigh and Opus cold review on Max. Run a fable cold
  review when you need to if you do & at the end of the phase if you didn't need that."* So: implementers
  `opus-implementer` at **xhigh**; ladder rounds `opus-reviewer` at **max**; a **Fable** cold review
  (`fable-reviewer`) whenever the diff earns one (an editor-seam, custody, `Sync/` or default's-meaning line),
  and otherwise ONE Fable cold review at the end of the run. (This supersedes the plan file's "max for every
  implementer" for this run.)

## The kickoff message (each implementer session receives this, plus its unit line)

> You are an implementer on **VX-281 "Run: MCP settings pane & shared icon"** for Variorum. Work ONLY in the
> worktree **`<home>/dev/variorum-vx-281`** (branch `vx-281-run-mcp-settings-pane-shared-icon`);
> never commit from `~/dev/variorum`. This record, `notes/plans/fixes/vx-281-mcp-settings-pane-shared-icon.md`,
> is the run's memory: keep its LIVE STATUS current from your first commit.
>
> **Read first, yourself, in full:** this record; `notes/plans/mcp-pane-and-docs-kickoff.md` (U6, the binding
> rulings, the rules, the VX-268 bullet — the rest of that file is VX-246's and not yours);
> `notes/plans/vx-33-release-runway.md` §2–§3; `notes/SessionResiliencyProtocol.md`; the pane's as-built
> history — `notes/plans/phase-13n-c-mcp-launch-readiness.md` (§3's U3 and U6 rows, the UX-walk dispositions
> that touch the pane: W-UX-2 approve-alone, W-UX-19 Change… beside Revoke) and
> `notes/plans/fixes/vx-184-mcp-launch-polish.md` (lines ~95–110, the U6 constraints; the U1 OWED 3c that is
> VX-232); AppSpec §12's THE MCP DOOR line (auto-loaded). Then the code you will change, and its tests.
> The walk lessons live in `~/.claude/projects/-<home>-dev-variorum/memory/walk-driving-lessons.md`.
>
> **The rules:** pin-before-fix per member (a bug-class change lands with a red-on-old pin, verified by revert;
> a pin green on both sides is recorded, not fixed); every existing door and pin keeps working (Answer…, ⌥⌘,
> landing on Waiting, Change…/Revoke rows, "all N ›", the setup menu's O-4 fence, the pending marks, Esc =
> Don't allow); chrome only — **zero** `Sync/`, custody/keychain, editor-seam, schema or MCP-wire lines (the
> wire is VX-246's lane; if you find you must edit a file in its lane, stop and report before committing);
> `SettingsShape.swift` edits stay on the MCP rows only; commits name the member + `Part of VX-281`, NO
> attribution trailers, pushed after every commit; synchronous foreground waits only.
>
> **The stage:** headless `swift build`/`swift test` and `xcodebuild build`/`build-for-testing` never need it.
> EVERY `xcodebuild test`, Debug launch, walk and dev-store change does. You never claim it on your own: when
> you need it, commit + push + flip the record, then END YOUR TURN with a block headed **STAGE REQUEST**
> (what — test batch / walk —, the `-only-testing` suites or the walk's script, minutes, a claim name). The
> orchestrator relays it to the stage coordinator and resumes you with the exact claim line to run. Release the
> claim the moment you finish and report the result. The dev store is in Standard, unlocked: leave it that way
> (any Castle credential comes only from `~/.variorum/dev-castle.env`). Close a What's New sheet with its own
> button after any Debug launch. Never touch the real store, `/Applications`, or a running real-store instance.
> **The closeout's Mac run covers every suite that exercises a changed SOURCE file** — grep the tests for the
> changed types.

## The units (sized at kickoff; one implementer session each, strictly sequential)

- **U1 — the pane in tabs (VX-199 · VX-205 · VX-232 · the two VX-245 sites).** R-VX184-6's layout; the code
  block with the copy icon (argue the registry shape: a second door to the ONE declared copy act, or the act's
  new face — every existing pin keeps its meaning); the edit rung's explainers in the pane AND the grant sheet
  brought to the as-built reach (since VX-184, "a commit before and after every change" holds for take TEXT
  changes only — U3's batches/links, U4's 12 note acts, U5's 14 library acts), one line each with the full text
  in the (i) popover; VX-232 verified (mooted with proof, else fixed red-first); the two `.fixedSize()` sites to
  the lint's form; the whole pane inside VX-214's 748×520 content area with no clipped tab row and no scroll to
  reach Connect's code block. If a reusable explainer-(i) component is minted, record its name and home here
  (the settings effort reuses it). **Evidence:** the pane suites + faces pins; a Mac batch; **the WALK in BOTH
  voices** — fresh pane (Connect); an approved client (Clients); Waiting above the tabs with a pending ask; each
  tab; each (i) popover; the copy icon pressed and the clipboard pasted, proving the same copy act; Answer… and
  ⌥⌘, landing on Waiting; a Change…/Revoke row.
- **U2 — the shared icon wherever the ask glyph is (VX-268).** Every place `MCPAskGlyph` marks also wears the
  ONE `MCPSharedIcon` with its hover and popover (who · how far · why · Change… · Revoke): the Library's note,
  book and gathering rows in List, Cards and Timeline; the Pool rows; the Book Panel's rows; the wing switcher's
  rows (menu + ⌘L sheet). NOT Blocks-scope rows. The open book matches the Bookcase. Reach comes through the ONE
  rule (`Queries.mcpNoteReach` / `mcpBookReach`, gatherings by VX-185's `decideGathering` truth); P1 — reach is
  read in proportion to the rows shown, never the corpus; VX-272 — renders only with ≥1 approved client.
  **Evidence:** pins red-first; a Mac batch; the walk.
- **Then:** the ladder — Opus cold review at max (REVIEW_PROMPT verbatim, a fresh reviewer per round), then the
  end-of-run Fable cold review (her redirect above), then the closeout. The run's last implementer applies the
  agreed fixes.

## LIVE STATUS

| Piece | State |
|---|---|
| kickoff: worktree, branch, in-flight row (main 94f0a2fb), tickets In Progress, this record | DONE (orchestrator) |
| U1 — the pane in tabs | NOT-STARTED |
| U2 — the shared icon | NOT-STARTED |
| the ladder | NOT-STARTED |
| closeout | NOT-STARTED |

## FOR VX-234 (every wording call this run makes, where it renders — posted to VX-234 at close)

*(empty — each unit appends its rows)*

## Unit records

*(each unit writes its own section here: pieces with hashes, traces, pins with red-on-old proof, PROVISIONALs,
the walk, OWED)*

## The ladder

*(round records and every finding's disposition land here before the next round spawns)*

## Closeout

*(results, finals, the ratify list, the MOBILE PARITY line, the merge)*
