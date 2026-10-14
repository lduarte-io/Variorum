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
- **HER OVERNIGHT MANDATE (2026-10-14 ~00:55, verbatim):** *"I want you to continue on through the night ending
  in a merge to main - the final merge in of the night can be the only one to do an applications refresh. Rule
  provisionally in my absence and leave me a handoff with any needed information to note down."* So: the run
  goes to its merge tonight; `/Applications` is refreshed only if the stage coordinator names VX-281 the night's
  LAST merge (her same word relayed through the coordinator, ~00:50); a product ambiguity is built to the most
  spec-defensible option, marked PROVISIONAL, and filed in QUESTIONS at the merge (the author-only list in
  CLAUDE.md stays hers); the handoff `notes/handoffs/vx-281-handoff.md` is the run's last act, her checklist on top.
- **The cross-model fix rule — HER PROCESS CHANGE (2026-10-13, now CLAUDE.md "Two reviews"; the history in
  `notes/ProcessHistory.md`):** in the end-of-run Fable round, Fable's findings go to the Opus implementer
  verbatim, its agree/dispute returns to Fable, and Fable makes the final call. The **implementer** then applies
  the confirmed fixes (red-on-old per finding, the suite green). Fable writes a fix itself only for a `Sync/`
  line or a finding it marks FINDER-FIXES (one line saying why), followed by one implementer sanity pass over
  its diff. That round's fixes are the run's last, so no later round reads them: the orchestrator checks each
  one line by line against its finding. *"Fable's budget goes to finding and judging, not typing."*

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
| U1 — the pane in tabs | **UNIT CLOSED — DONE** (2026-10-13 ~22:35 MDT, opus-implementer): VX-199 · VX-205 · VX-232 (FIXED red-first) · VX-245's two MCP sites (`3d00a166`); red on old 4 issues; Mac batch 250/31 (one issue — VX-283's six lint sites); the walk in both voices DONE, dev store restored `cmp`-SAME. 3 PROVISIONALs (P-VX281-U1-1…3) for QUESTIONS at the merge; the cold review is the ladder's. See the U1 UNIT RECORD |
| U2 — the shared icon | **UNIT CLOSED — DONE** (2026-10-14 ~00:20 MDT, opus-implementer): VX-268 — the one icon on every row the ask glyph marks + the ticket's book/gathering and Timeline rows; red first (core 43, Mac 27 issues on the seam), Mac batch 812/149 (one issue — VX-115's standing pin); the walk in both voices DONE, the dev store restored `cmp`-SAME against the original. 5 PROVISIONALs (P-VX281-U2-1…5) for QUESTIONS at the merge; the cold review is the ladder's. See the U2 UNIT RECORD |
| the ladder | ROUNDS 1 + 2 CLOSED; **ROUND 3 — the end-of-run FABLE round — DONE** (~03:30, 0B/0M/0m/2n, recorded below); implementer dispositions written: **F-1 AGREED** (not yet applied), **F-2 DISPUTED** (the receipt is cleared in the same synchronous segment as the menu change — no transient) → back to Fable for the final call; nothing applied until it lands |
| closeout | NOT-STARTED |

## FOR VX-234 (every wording call this run makes, where it renders — posted to VX-234 at close)

*(each unit appends its rows)*

**U1 — the pane in tabs (words AS BUILT; the full texts behind each (i) are UNCHANGED unless a row says so):**

| # | Words (as built) | Where it renders | Note |
|---|---|---|---|
| U1-1 | "Connect" | Settings ▸ MCP, the tab row's first tab (`MCPPaneCopy.connectTab`) | the other three tabs reuse their sections' titles: "Clients" · "Shared with AI" · "Activity"; Connect's own section keeps "Connect a client" (the field guide's lesson 2 says "under Connect a client") |
| U1-2 | "A local MCP server while Variorum is open — nothing is readable until you grant it." | Settings ▸ MCP, under "Enable the MCP server" (`enableSummary`) | (i) → `enableBlurb`, VX-184 round 2's sentence, unchanged |
| U1-3 | "A setup key tells two clients apart — not programs running as you." | the Clients tab, under the client rows (`clientBoundarySummary`) | (i) → L1 (`clientBoundary`), unchanged; the line keeps L1's own caveat so it never promises more |
| U1-4 | "Each copy carries a fresh key, shown as dots; running it again replaces the old setup." | the Connect tab, under the code block (`keySummary`) | (i) → `keyLine`, unchanged; her R-VX184-5 words kept in the line |
| U1-5 | "A standard MCP server over stdio — one program, at this path:" | the Connect tab, above the program's path (`stdioSummary`) | (i) → `stdioLine`, unchanged |
| U1-6 | "Run it in a terminal, then start a new Claude Code session." · "Run it in a terminal, then start a new Codex session." · "Paste it into your client's MCP settings, then restart the client." | the Connect tab, under the code block, per chosen client (`MCPSetupClient.summary`) | (i) → each client's sentence, unchanged except U1-7 |
| U1-7 | "…or give a client that asks for a command the path below, with the environment variable this sets." | Any MCP client's sentence, in its (i) | "above" → "below": the path now sits under the code block (truth of placement, not a re-voicing) |
| U1-8 | "it can add new takes and comments beside your text — it cannot touch a word you wrote" (suggest) · "it can also change, archive and delete what you shared, your own words included" (edit) | the grant sheet's HOW MUCH line (`rungSummary`) — every grant road: Settings ▸ MCP, ⌥⌘A, the note ▾ / row menus, the Library's bulk door, a row's Change… | (i) → `rungDetail`, unchanged (the edit sentence is VX-184 round 2's as-built clause); read and write new already one line (no (i)); the ask sheet's lead keeps the whole sentence |
| U1-9 | "More about this" | the (i)'s tooltip and VoiceOver name, everywhere `ExplainerLine` renders | |
| U1-10 | "Copy setup command" — now the copy ICON's tooltip and VoiceOver name, no longer a button's visible label | the Connect tab's code block, upper right | her R-13nb-5 words, unchanged; the field guide's lesson 2 ("press Copy setup command") is VX-197's to re-say for the icon (OWED) |
| U1-11 | the rung's (i) popover shows the sentence in the line's own fragment form ("it can also change, archive and delete…" — lowercase, no closing period) | the grant sheet's HOW MUCH (i) on suggest and edit (`terminal-07`) | words unchanged (VX-184 round 2's as-built clause); whether the popover should read as a capitalized sentence is hers |

**Ladder round 1's fix pass (words AS BUILT):**

| # | Words (as built) | Where it renders | Note |
|---|---|---|---|
| R1-4w | "Connect a client" (title — the Connect section's existing words) · "The setup for your MCP client, ready to copy: a command for a terminal, or settings to paste into the client." (blurb, NEW) | Settings search results (the `mcpConnect` catalog row); the title also heads the Connect tab's section, now drawn from the catalog | the blurb is new words — hers to reword; it names no provider (O-4) |
| R1-8w | the next step said twice after a copy: "Run it in a terminal, then start a new Claude Code session." (the line) and "Copied. Run it in a terminal, then start a new Claude Code session." (the receipt) — likewise Codex's and Any MCP client's | the Connect tab, under the code block, after a copy | now ONE sentence in code (the receipt = "Copied. " + the line); whether the line should hide while the receipt shows, or the receipt say only "Copied.", is hers |

**Ladder round 2's fix pass (words AS BUILT):**

| # | Words (as built) | Where it renders | Note |
|---|---|---|---|
| R2-3w | "Clients" (title — the Clients tab's own label) · "Every client you've approved or denied: whether it's connected now, how many grants it holds, and Change… or Deny… for each." (blurb, NEW) | Settings search results (the `mcpClients` catalog row, PROVISIONAL P-VX281-R2-1 (b)); the title is the tab's label | the blurb is new words — hers to reword; it names no provider (O-4) |

**U2 — the shared icon (VX-268): no new words.** The icon, its hover and its popover are 13n-c's, unchanged; the ▾ menu's row mark is an image. One taste note for her pass: the icon reads large beside the Book Panel's small type (`vx281-screens/u2/walk/s16`).

## Unit records

*(each unit writes its own section here: pieces with hashes, traces, pins with red-on-old proof, PROVISIONALs,
the walk, OWED)*

## U1 UNIT RECORD — the pane in tabs: VX-199 · VX-205 · VX-232 · VX-245's two MCP sites (opus-implementer, 2026-10-13 evening)

### UNIT CLOSED (2026-10-13 ~22:35 MDT — the U1 implementer, Opus `claude-opus-5-5`)

**What this unit did NOT do (said first):**
1. **Only the RUNG line of the grant sheet is cut to one line + (i)**, as the brief named. The sheet's other multi-line quiet lines stay as they were: the approval lead, WHERE's wing/book detail, the fenced-books note, the duration whys. R-VX184-6 is "only the MCP pane", and the sheet's other lines are VX-234's to judge (OWED 5).
2. **The field guide is untouched** (`TutorialSeeder` is VX-197's lane). Lesson 2's "under Connect a client, choose yours … Then press Copy setup command" stays TRUE: the section title is kept, and the icon's name IS that verb. But it does not yet teach the tabs or the copy icon (OWED 2).
3. **`ChromeLineLimitTests` stays red** on VX-283's six non-MCP sites (VX-245's remainder; not this run's).
4. **No cold review yet** (the ladder's). No `notes/QUESTIONS.md` or canon edit (merge-time — OWED 3, 4).
5. **The (i) popovers were walked by click only.** No keyboard road was tested to open one; the walk lessons say keys never reach a popover anyway.
6. **The clipboard was saved and restored as TEXT** (`pbpaste`/`pbcopy`, 3,822 bytes). Non-text clipboard flavours, if she had any, were not preserved.

Everything else in the U1 row is DONE and evidenced:
- VX-232 pinned red on old and fixed.
- The tabbed pane and the code block are built, pinned and walked in both voices.
- VX-245's two sites are fixed (`3d00a166`).
- The walk ended with the dev store, the prefs and the clipboard restored, and the stage released.

Zero `Sync/`, custody/keychain, editor-seam, schema, `Sources/`, MCP-wire, `SettingsShape.swift` or `TutorialSeeder` lines. Path diff `07340a97..HEAD`:
- `App/Variorum/Variorum/Core/Views/ExplainerLine.swift`
- `Features/MCP/{MCPDoor,MCPGrantSheet,MCPPane,MCPPaneCopy,MCPSetupMenu}.swift`
- `Features/Settings/AppSettingsView.swift` (one closure + a comment)
- two new test files, `.gitignore`, and this record

**Read in full before code (never delegated):** this record; `notes/plans/mcp-pane-and-docs-kickoff.md` (the U6
section, the binding rulings, the rules, the VX-268 bullet); `notes/plans/vx-33-release-runway.md` §2–§3;
`notes/SessionResiliencyProtocol.md`; `notes/plans/phase-13n-c-mcp-launch-readiness.md` §3 (U3, U6) and the
UX-walk dispositions + the fix-pass rows that touch the pane (W-UX-2, W-UX-4, W-UX-8, W-UX-10, W-UX-16, W-UX-18,
W-UX-19, UXR1-2, UXR1-6); `notes/plans/fixes/vx-184-mcp-launch-polish.md` (the cross-run lines ~95–110, U1's OWED 3c
= VX-232, U4's risk 2 and the round-2 FOR VX-234 consent sentences); `notes/plans/mcp-launch-polish-kickoff.md`
(R-VX184-6 as she ruled it); the four tickets (VX-199, VX-205, VX-232, VX-245) on the board; the walk lessons. Code:
`Features/MCP/` whole (`MCPPane`, `MCPPaneCopy`, `MCPGrantSheet`, `MCPDoor`'s note/copy/settings-request road),
`Features/Settings/{AppSettingsView,SettingsShape,SettingsSceneContent}`, `Registry/CapabilityRegistry`'s MCP
rows, `Shared/Theme/VoiceTokens`, `Theme/VoiceControls`; tests `MCPPaneTests`, `MCPSetupMenuTests`,
`MCPAsksWaitTests` (the ⌥⌘, pins), `MCPAskAndReceiptTests` (the rung truth pins), `MCPGrantSheetTests` (VX-272/L1),
`MCPSetupKeyFacesTests`, `TutorialMCPChapterTests` (lesson 2's and 7's pane-word pins), `ChromeLineLimitTests`,
`NoLiteralColourTests`, `Tests/VariorumMCPTests/MCPProviderNeutralityTests` (the O-4 fences).

**Surfaces (chrome only):** `Features/MCP/{MCPPane,MCPPaneCopy,MCPGrantSheet,MCPDoor}.swift`, a new
`Features/MCP/MCPSetupMenu.swift` (the setup menu moved out of `MCPPane.swift`, rebuilt as the code block), a new
`Core/Views/ExplainerLine.swift`, `Features/Settings/AppSettingsView.swift` (the search's landing on the open-book
row's tab — one closure), tests. **Zero** `Sync/`, custody/keychain, editor-seam, schema, `Sources/` or MCP-wire
lines; `SettingsShape.swift` untouched; `TutorialSeeder` untouched (VX-197's lane — see OWED).

### The traces (made before any code — the hallucination guard)

- **VX-232 (bug class) — the mechanism, traced:** `MCPPane` held the setup menu's choice as VIEW state
  (`@State private var setupClient: MCPSetupClient = .claudeCode`, `MCPPane.swift:38`), while the copy act's receipt
  lives on the DOOR (`MCPDoor.note`, place `.connect`, set by `copySetupCommand(for:)` at `MCPDoor.swift:493`), which
  is app-lived. Anything that remounts the pane — switching to General to flip the voice and back (VX-184 U1's live
  round did exactly that), another pane, closing Settings — re-runs `@State`'s initial value: the segment comes back
  as Claude Code, the receipt still reads `copiedJSONReceipt` ("Copied. Paste it into your client's MCP
  settings…"), and the menu's own `.onChange(of: client)` never fires (an initial value is not a change). Inputs: Any
  MCP client chosen → copied → the pane remounted. Wrong state: segment = Claude Code under the Any-client receipt —
  the exact lie `clearConnectNote`'s doc names ("a 'Copied … Claude Code' caption under Codex's text would be a
  lie"). **Not mooted by tabs alone** — a tabbed pane with the same `@State` would reset the same way — so it is
  FIXED, red-first: the choice moves onto the door beside the receipt it explains (`MCPDoor.setupClient`, session-
  lived like the tab memory R-VX184-6 asks for), choosing another client clears the receipt in the door
  (`chooseSetupClient`), and a copy makes its client the chosen one, so the receipt always names the shown client.
- **VX-245 (lint class):** `ChromeLineLimitTests.everyBareFixedSizeStatesItsLinePolicy` lists
  `MCPPane.swift:412` (the setup segment's `.fixedSize()`) and `MCPGrantSheet.swift:285` (HOW LONG's segmented
  picker) — no `lineLimit(` within the four lines above either. A segmented control's labels are one line by
  nature, so the sanctioned form is `.lineLimit(1)` stated at the site.
- **VX-199 / VX-205 (design rows — a geometry oracle + the walk, not red-on-old):** today's pane is ONE grouped
  form of eight sections with the setup at the very bottom (her "you wouldn't know without scrolling down where the
  command to set it up is"), five explainers running 2–6 lines.

### The design (settled at kickoff; each call said, PROVISIONALs listed below)

1. **The pane (R-VX184-6):** one grouped form, top to bottom — the server section (the switch, its status, ONE
   explainer line with (i)), **Waiting** (whenever an ask waits — unchanged rows, Answer…, "all N ›", its caption,
   ⌥⌘,'s anchor), **Connection requests** (whenever one waits — see P-VX281-U1-1), then the **tab row** (a segmented
   control: Connect · Clients · Shared with AI · Activity) heading the chosen tab's content. Connect = the setup
   (its section keeps the title "Connect a client", so the field guide's "under Connect a client" stays true);
   Clients = the clients, their "all N ›", L1 as one line with (i); Shared with AI = the act rows (Change… · Revoke
   unchanged), "all N ›", then the Open book switch; Activity = the coarse log and its "all N ›".
2. **The opening tab (R-VX184-6):** a pure rule — her pick this session, else Connect while no client is approved,
   else Clients (`MCPPaneTab.opening`). Her pick is remembered on the door (app-lived — "per session" read as this
   app session; never stored), so it survives pane switches and Settings closing.
3. **The (i) component:** `ExplainerLine` (`Core/Views/ExplainerLine.swift` — Mac chrome's shared home, for the
   settings effort to reuse): one line, never wrapping, and an (i) whose popover holds the whole text; no (i) when
   the line already is the whole text. Token-free (semantic styles only), so any Settings pane can use it.
4. **The code block (VX-205):** the docs-site idiom — a rounded block on the voice's `codeTint`, a header strip
   holding the client choice (Claude Code · Codex · Any MCP client, the same segmented menu) on the left and THE copy
   icon (`doc.on.doc`, a ✓ for a moment after a copy lands) in the upper right, then the setup text in mono, masked
   key as before. **Registry shape — the act's NEW FACE, not a second door:** `.mcpCopySetupCommand` stays ONE
   act on ONE surface; the icon IS its door, its verb ("Copy setup command", her R-13nb-5 words, pinned) rendered as
   the icon's help and accessibility label, so P-1's declared ⇔ rendered holds and every pin keeps its meaning (the
   verb, `surfaceCapabilities`, the copy's key mint and receipt, the O-4 fence, the guide's "press Copy setup
   command" pin). A visible "Copy setup command" button beside the icon would be two doors to one act on one surface —
   exactly what her "very standard look" leaves out.
5. **The explainers cut to one line** (pane: the server blurb, L1, the key line, the stdio line, each client's
   sentence; the grant sheet: HOW MUCH's rung line, where the edit rung's line is the brief's named case). The
   full texts are UNCHANGED and live in the popovers — every truth pin on them stands. **The edit rung's truth was
   already brought to the as-built reach by VX-184's ladder round 2** ("…change, archive and delete what you
   shared, your own words included — when it rewrites a take, the take's words before and after are kept as
   commits…" — `MCPPaneCopy.rungDetail(.edit)` and `enableBlurb`, pinned in
   `MCPAskAndReceiptTests.theGrantSheetOffersTheServedRungsWithTheMockupsSentences`); this unit re-checks it against
   the shipped catalog and gives it the one-line form.
6. **The search's landing:** a Settings search finding the open-book row now opens the pane ON the Shared with AI
   tab (the row lives there) — `rowIDsRendered`'s contract (the search never names a row the pane does not show)
   kept through the tabs.

### Pieces (LIVE STATUS — flipped in the same commit as each piece)

| # | Piece | State |
|---|---|---|
| 1 | this record opened (traces, design) | DONE (`05b5977b`) |
| 2 | VX-232's red-on-old pin + the geometry oracle, committed on the OLD pane; the old tree built for the red run | DONE (`341e8991`, `98a74f96`) — `MCPPaneTabsTests` (`aRemountedPaneShowsTheClientItsCopyReceiptNames`, `aFreshPaneOpensOnConnectWithItsCodeBlockInSight(voice:)`); the OLD tree built from `98a74f96` (old pane + the two pins) into `DerivedData/vx281-u1-old` (`** TEST BUILD SUCCEEDED **`) — the red run is STAGE WINDOW 1's (PENDING) |
| 3 | VX-245 — the two MCP `.fixedSize()` sites to `.lineLimit(1)` | DONE (`3d00a166` — the hash for VX-245) — the lint's rule replicated over the source (`scratchpad/u1/lint.py`, the suite's exact rule: a code line's bare `.fixedSize()` needs `lineLimit(` within the four lines above or on its line): **old tree `98a74f96` → 89 sites, 8 offenders** (exactly VX-245's list, `MCPPane.swift:412` and `MCPGrantSheet.swift:285` among them); **this commit → 89 sites, 6 offenders** — `SearchPicker.swift:503`, `TakesShowFaces.swift:185`, `LibraryBulkRow.swift:93/101/109/113`, all VX-283's, untouched. The suite stays red on those six (recorded, not this run's); the Mac run reads it at STAGE WINDOW 1 (PENDING) |
| 4 | `ExplainerLine` + the one-line summaries (`MCPPaneCopy`) + FOR VX-234 rows | DONE (`acf0a305`; compiled at piece 7's build) — `Core/Views/ExplainerLine.swift` (the reusable component: its NAME and HOME for the settings effort); `MCPPaneCopy.{enableSummary, clientBoundarySummary, keySummary, stdioSummary, rungSummary(_:scope:), connectTab}`, `MCPSetupClient.summary` (inside its O-4 fence: 64 lines of the 120 allowed; the other fence 109), Any MCP client's "path above" → "below"; FOR VX-234 rows U1-1…U1-10 |
| 5 | VX-232's fix — the door holds the setup choice and the tab memory | DONE (`d20115de` + `542204c8` — `MCPPaneTab` missed the first commit (an edit refused on a stale read), landed in the second; compiled at piece 7's build) — `MCPDoor.setupClient` (observable, session-lived) + `chooseSetupClient(_:)` (clears a `.connect` receipt on a change; a `.top` refusal stays); `copySetupCommand(for:)` makes its client the chosen one, so the receipt always names the shown client; `MCPDoor.paneTab` (her pick, `@ObservationIgnored` — read at mount); `MCPPaneTab` (the four, `opening(remembered:approvedCount:)`, `holding(findingLead:)`) at the head of `MCPPane.swift`. The pane still binds its own `@State` until piece 7 rewires it |
| 6 | VX-205 — the setup menu as the code block (`MCPSetupMenu.swift`) | DONE (`230be089`, with piece 7) — `MCPSetupMenu` moved out of `MCPPane.swift` (same init: `door`, `client` binding, `tokens` — the capture harness's call compiles unchanged) and rebuilt: `MCPSetupCodeBlock` (header strip: the client menu, `controlSize(.small)`, left · THE copy icon `doc.on.doc` → `checkmark` for 1.6 s after a copy LANDS, upper right, `VoicedButtonStyle`, help + accessibility name = the registry verb; a hairline; the setup text in 11-pt mono on `tokens.codeTint` with a `tokens.line` stroke — no literal colour), then the chosen client's line (its sentence behind (i)), the receipt, the key's line, the door's line + the path; the menu's own `.onChange` retired (the door clears the receipt on a choice) |
| 7 | VX-199 — the tabbed pane + the search's landing | DONE (`230be089`) — `MCPPane`: the server section (switch · status · `ExplainerLine` · the `.top` caption), Waiting (unchanged rows/caption/anchor/revalidation), Connection requests (above the tabs — P-VX281-U1-1), then `switch tab` over four tab bodies, each led by `tabRow` (a centred segmented control as the first section's header; a pick writes `door.paneTab`); `init(door:)` opens by `MCPPaneTab.opening(remembered: door.paneTab, approvedCount: door.snapshot.approvedCount)`; Connect binds the menu to the door (`setupClient` / `chooseSetupClient`); `AppSettingsView`'s search `onOpen` sets `mcp.paneTab` from `MCPPaneTab.holding(findingLead:)` (the open-book row → Shared with AI). `build-for-testing` on `DerivedData/vx281-u1`: `** TEST BUILD SUCCEEDED **`, no warning in a touched file (the one hit is `PromoteTagsSheet`'s standing `spec(paths:joinAll:)` isolation warning, line shifted by this edit) |
| 8 | the grant sheet's rung line with (i) | DONE (`55f39cbd`) — HOW MUCH's quiet line → `ExplainerLine(line: rungSummary(rung, scope:), detail: rungDetail(rung, scope:))` on every grant road; read and write new carry no (i) (their line IS the sentence); the ask sheet's lead keeps the whole sentence (`MCPAskCopy.lead`, untouched) |
| 9 | the pins (pure rules, the one-line fits, the registry shape) + the capture harness; the new tree built | DONE (`014f10ba`) — `MCPPaneTabsTests` grows seven: `theTabsAreHerFourInHerOrder`, `thePaneOpensOnConnectUntilAClientIsApprovedAndKeepsHerPick`, `herPickedTabIsRememberedAcrossTheSettingsWindow` (mount; drives the tab row's own AppKit action), `aSearchForTheOpenBookLandsOnItsTab`, `everyPaneExplainerIsOneLineWithTheWholeTextBehindItsInfo` (SwiftUI-measured `.caption` ≤ 420 pt), `theGrantSheetsRungLineIsOneLineAndTheEditLineStaysAsBuilt` (≤ 520 pt; the edit line the as-built clause's head, no book/chapter/"every change" at any scope), `theCopyIconIsTheOneCopyActsNewFace`, `theChoiceAndTheReceiptMoveTogetherOnTheDoor`; `MCPPaneTabsCaptureTests` (gated `VARIORUM_CAPTURE=vx281-u1`: the whole 748×520 Settings content at MCP — fresh/Connect light+dark, each tab in use with a request and two asks above, Clients with nothing waiting, the grant sheet on edit — both voices). `build-for-testing` on `DerivedData/vx281-u1`: `** TEST BUILD SUCCEEDED **`, zero warnings in a touched file. Headless: `MCPProviderNeutralityTests` 2/2 green (the O-4 fences 109 and 64 lines); the replicated P-8 lint 90 sites / the six VX-283 offenders; no literal colour in the new files |
| 10 | STAGE WINDOW 1 — the Mac batch, the red-on-old runs on the old tree, the captures | DONE (claim `vx281-u1`, 22:04:47–22:09, handed over from `coord-for-vx281` by the coordinator's exact line; `guard.sh --author` OK, no Variorum instance before or after; released at once) — **(a) RED ON OLD** (`DerivedData/vx281-u1-old`, built from `98a74f96` — the old pane + the pins; log `vx281-screens/u1/logs/a-red-on-old.log`): 2 tests / 1 suite, **4 issues** — `aRemountedPaneShowsTheClientItsCopyReceiptNames` RED ×2: *"shown Claude Code, receipt “Copied. Paste it into your client's MCP settings, then restart the client.”"* and *"shown → .claudeCode"* (VX-232's mechanism, exactly as traced); `aFreshPaneOpensOnConnectWithItsCodeBlockInSight` RED in BOTH voices (`tabRow(in: host)` nil — no tab row). **(b) THE BATCH** (`DerivedData/vx281-u1`, HEAD's sources; `logs/b-batch.log`): **250 tests / 31 suites, ONE issue** — `ChromeLineLimitTests.everyBareFixedSizeStatesItsLinePolicy`, its offenders EXACTLY VX-283's six (`SearchPicker.swift:503`, `TakesShowFaces.swift:185`, `LibraryBulkRow.swift:93/101/109/113` — VX-245's remainder, known red, not this run's; both MCP sites gone). Every other suite green, the new `MCPPaneTabsTests` 9 tests / 10 cases all green (the two red-on-old pins GREEN on the new tree; the mounted tab-row press — the control's own AppKit action — writes `door.paneTab`). Log noise seen, not ours: `DiagnosticsPaneTests`' standing "Accessing State… without being installed" lines. **(c) THE CAPTURES** (`TEST_RUNNER_VARIORUM_CAPTURE=vx281-u1`; 1/1 passed, 16 PNGs → `vx281-screens/u1/cap1/`, read): the FRESH pane opens on Connect in all four (Study/Terminal × light/dark) — the switch, status and one explainer line with its (i) on top, the tab row whole and centred, "Connect a client", the code block (client menu left, copy icon upper right, the Debug command four lines) fully in sight above the fold, then the client's line, the key's line, the door's line and the path; the grant sheet's HOW MUCH reads "it can also change, archive and delete what you shared, your own words included ⓘ" on one line. **A HARNESS BUG (mine):** the ten in-use captures never requested the MCP pane, so they show Settings ▸ General — fixed in this commit (`requestSettings()` in both in-use doors); they re-shoot at window 2's head |
| 11 | STAGE WINDOW 2 — the walk in both voices | DONE (claim `vx281-u1-walk`, 22:12:56–22:29:35 MDT; the plan as recorded, executed in full) — THE WALK section below; captures `notes/plans/vx281-screens/u1/walk/` (44 PNGs, gitignored) |
| 12 | close: self-assessment, PROVISIONALs, OWED | DONE (this commit) — **UNIT CLOSED** |

### THE WALK (STAGE WINDOW 2 — 2026-10-13 22:12:56–22:29:35 MDT, claim `vx281-u1-walk`)

**Setup.** The Debug build is `DerivedData/vx281-u1` (HEAD `083d9798`'s app sources; only test files changed after `a3870f12`).
- Guards: `guard.sh --author` OK; no Variorum instance before, during or after. Her app was absent throughout, so `/Applications` and her real store were never touched.
- The in-use captures were re-shot first with the fixed harness (`cap2/`, 16 PNGs, read).
- **A1 prestage** went to `…/Variorum-dev/Backups/safety-copies/vx281-u1-prestage-20261014T041422Z/`. All five files were `cmp`-SAME at copy: sqlite `9bb8eef87116`, wal `6bb824c1fbef`, shm `550ce673553d`, key files `3af4704371ff` / `7e12a1b85890`.
- The Debug prefs were exported (1,580 lines) and her clipboard saved as text.
- The dev store opened **Standard, unlocked**, in Study. No What's New sheet.
- **No system popup appeared at any step.**

**The client.** `walk/client.py` is a scripted MCP stdio client through the Debug shim. It ran with the key a copy-icon press had just minted; keys are masked in every log. No `claude mcp` registration was made.

**Captures.** All in `notes/plans/vx281-screens/u1/walk/` (gitignored); every one was read.

| Row (the brief's list) | Study | Terminal |
|---|---|---|
| ⌥⌘, opens Settings AT MCP; with approved clients it opens on CLIENTS | `study-01` | — |
| Each tab | `study-04` Shared (Change… · Revoke rows), `-04b` its foot (the five rows, Open book switch + its line), `-05` Activity ("all 136 ›"), `-06` Connect (the code block in sight, no scroll) | `terminal-15` Shared, `-17` Clients, `-18` Activity, `-20` Connect |
| Each (i) popover | `study-02b` server (whole on screen — it runs past the window's right edge, as macOS popovers do; `study-02` is the window-only capture that clips it), `-03` L1 (whole), `-07` the client line, `-08` the key line, `-09` the stdio line | `terminal-19` server; `terminal-07` the grant sheet's EDIT rung — its whole as-built sentence |
| The copy icon pressed + the clipboard pasted (THE SAME ACT) | `study-10`/`-10-crop` (✓ in the upper right, the receipt under the block). Pasted: the Claude Code command with a fresh `vmk1_` key, exactly the remove-then-add form. Then `-11`/`-12`: Any MCP client chosen (the receipt cleared), copied (✓); the paste PARSED as JSON — `mcpServers.variorum-dev`, the shim path, `args: []`, `env.VARIORUM_MCP_KEY` a fresh key | `terminal-20` (✓); the paste matched the Claude Code command exactly |
| **VX-232 LIVE** | — | `terminal-01`: General's voice flipped to Terminal. `-02`: back on MCP, the pane (REMOUNTED) shows her remembered tab, Connect, and the menu STILL on Any MCP client. `-03`: the receipt beneath it is Any MCP client's own ("Copied. Paste it into your client's MCP settings, then restart the client."). The Study flip back (`study-13`) kept Claude Code, the then-chosen client, the same way |
| A connection request ABOVE the tabs (P-VX281-U1-1) | — | `terminal-04`: "Connection request — vx281-walk · First seen now. No access until approved. · Approve… · Deny", above the tabs, in sight from Connect |
| The approval sheet | — | `terminal-05`: "Nothing yet" picked. `-06`: A wing → Home, Edit — HOW MUCH as ONE line + (i). `-08`: Read · Always. `-09`: approved, the request gone |
| Waiting ABOVE the tabs with a pending ask | `study-13` | `terminal-10`: the client's `add_take` past its read grant answered `rungTooLow` + "Variorum has asked the author" on the wire, and "vx281-walk asks to suggest in “seeing, answering, undoing” · now · Answer…" waits above the tabs |
| Answer… → the ask's sheet; Esc = Don't allow | `study-16` | `terminal-11` (the sheet: Once · Always · Don't allow, the suggest rung's lead); `-12` Esc (System Events) — the ask answered, Waiting gone |
| ⌥⌘, LANDING on Waiting | — | A fresh ask raised with the pane scrolled down (`terminal-13`). Settings closed (⌘W). ⌥⌘, → the window re-opened ON MCP, scrolled so Waiting leads, on her remembered tab (`-14`) |
| A Change…/Revoke row | `study-14`; `-15` Change… → "Change access — vx281-walk · Confirming replaces the grant you opened this from." pre-filled Home · Read · Always → Esc | `terminal-15`/`-16`, the same |
| The FRESH pane (Connect) | `study-18`: the Deny… confirm ("Deny vx281-walk? … Its grant is revoked now…"); `-19`: all five approved clients denied (each confirm's title read by accessibility before its Deny was pressed); the app quit by identity and relaunched → ⌥⌘, → `-20` opens on CONNECT | `terminal-21` (General → Terminal → MCP, the same session, no pick made): opens on CONNECT |

**Two driving slips, said plainly. Neither wrote the store.**
1. Three (i) presses landed while the pane was still on Shared with AI (I had re-opened it for the scroll). They fell on its foot: the Open book row's label, near its switch, and its quiet line. The three captures show the switch still OFF and nothing opened. The captures were discarded and re-shot on Connect.
2. Four Deny confirms in one loop never fired. `keys.sh`'s guard refused them, because HID idle was under 2 s after my own click, and the loop swallowed the exit. The claude-code confirm stood open meanwhile, so nothing else was touched. Redone one by one with checked exits.

**Walker facts** (for `Tools/WalkKit/README.md`'s owner; not written there from this branch):
- `guard.sh` needs `Tools/WalkKit/wl2` COMPILED. A fresh worktree lacks it, and the guard then silently skips its window check. Build it with `swiftc -O -o Tools/WalkKit/wl2 Tools/WalkKit/wl2.swift`.
- Our OWN clicks reset HID idle. Space guarded steps at least 2.5 s apart, and CHECK each helper's exit code.
- A SwiftUI `.alert`'s buttons have no AX `name`, only a `description`. Press them with `click (first button of sheet 1 of window 1 whose description is "Deny")`.
- `walk-scroll` must point INSIDE the Settings window (200…948 × 33…585 on this machine).

**Cleanup.**
- Quit by identity; no instance left.
- The store folder's file set was unchanged. The main sqlite and both key files were untouched. The walk's writes lived in the WAL, so the wal and shm were restored from the prestage, and **all five files are `cmp`-SAME with the prestage**.
- The Debug prefs were re-imported. A fresh export is **identical** to the pre-walk export (the walk had moved `IdleCommitSweepMark`, the Settings window frame and the backup log; the launches only logged "upToDate", with no backup written or pruned).
- **Her clipboard was restored** (text, `cmp`-SAME).
- The stage was **released at 22:29:35**.
- **POSTURE AS LEFT:** the dev store Standard, unlocked, byte-identical to its pre-walk state (the voice back to Study by that restore).

### VX-232 — the verdict, with its proof

**FIXED, red-first. Not "mooted":** a tabbed pane keeping the menu's choice in `@State` would have reset exactly the same way.
- **Mechanism:** see the trace above.
- **Pin:** `MCPPaneTabsTests.aRemountedPaneShowsTheClientItsCopyReceiptNames`. On the OLD tree it was RED with 2 issues: "shown Claude Code, receipt 'Copied. Paste it into your client's MCP settings…'" and "shown → .claudeCode". On the new tree it is GREEN.
- **Companion pure pin:** `theChoiceAndTheReceiptMoveTogetherOnTheDoor`.
- **Live on screen:** `terminal-02`/`-03`.

**The fix:**
- the choice moves onto the door (`MCPDoor.setupClient`);
- `chooseSetupClient` clears a receipt that names another client;
- a copy makes its client the chosen one.

The ticket closes with the run.

### VX-205 — the registry shape (argued; the design section's item 4)

**The act's NEW FACE, never a second door.**
- `.mcpCopySetupCommand` stays ONE act (doors `[.surface]`), declared once in `MCPPane.surfaceCapabilities`.
- Its verb ("Copy setup command", her R-13nb-5 words) renders as the icon's help tag and VoiceOver name, so P-1's declared ⇔ rendered holds.
- The copy itself is byte-unchanged (`copySetupCommand(for:)`: the key minted, the clipboard, the receipt at `.connect`). The live paste proved it in both voices.
- The O-4 fences hold (headless sweep green). The guide's pin "press Copy setup command" still reads true of the icon's name.
- Pinned: `theCopyIconIsTheOneCopyActsNewFace`.

### PROVISIONALs (non-wording; the orchestrator files them in QUESTIONS at the merge)

- **P-VX281-U1-1 — connection requests sit ABOVE the tabs, beside Waiting.** R-VX184-6 places Waiting above the tabs and names the tabs; it does not place the requests. Options:
  - **(a) Above the tabs (BUILT).** A request waits on her answer as an ask does. The setup flow's next step (her client connecting) then shows right where she copied the command (`terminal-04`), never hidden behind Clients.
  - **(b) At the head of Clients,** with the tab's label carrying the pending count.
  - **(c) At the head of Clients, nothing more.**
- **P-VX281-U1-2 — "remembered per session" = this app run.** Her pick lives on the app-lived door (`MCPDoor.paneTab`, and the setup choice beside it). It survives the pane switching, Settings closing and a lock. It is cleared only by quitting. Never stored, never synced. Options:
  - **(a) The app run (BUILT).**
  - **(b) The library session** (cleared at lock/unlock — `detach`).
  - **(c) Persisted per Mac** (a local preference).
- **P-VX281-U1-3 — the tab row heads the chosen tab's content INSIDE the one scrolling form.** The pane keeps the grouped-form idiom of every other Settings pane, and ⌥⌘,'s scroll-to-Waiting stays meaningful. A long tab (Shared with AI's five rows plus the Open book) scrolls the tab row away (`study-04b`). Options:
  - **(a) In the form (BUILT).**
  - **(b) A pinned tab bar** with only the tab's content scrolling — Waiting and requests would then sit in a fixed band above it.

### FOR VX-234 — rows this unit adds beyond U1-1…U1-10

U1-11 is listed in the FOR VX-234 section above.

### SELF-ASSESSMENT

**Against her ruling (R-VX184-6):**
- Switch + status on top: yes.
- Waiting above the tabs whenever asks wait: yes, walked in both voices.
- The four tabs in her order: yes.
- Opens on Connect while no client is approved, else on Clients: walked (`study-01`, `study-20`, `terminal-21`).
- Remembered per session: walked (`terminal-02`/`-14`) and pinned.
- Every explainer one line + (i) in the pane: server, L1, client line, key line, stdio line — each measured ≤ 420 pt in SwiftUI's own `.caption` and walked.
- Only the MCP pane: no other pane's row touched.

**Against VX-205:**
- The standard look: a code block, the client choice in its header, THE copy icon upper right, ✓ after a copy.
- The one act's meaning and the O-4 fence: unchanged.

**Against the fit (VX-214's 748×520):**
- The geometry oracle passes in both voices, light and dark (captured).
- The tab row is whole and centred; Connect's code block is wholly in sight without a scroll on a fresh pane.
- With Waiting or a request above, the block's head stays in sight (`terminal-10`, `study-13`).

**Risks I see:**
1. `MCPPane.init` reads `door.snapshot.approvedCount` at mount. A pane mounted in the instant after unlock, before the snapshot lands, opens on Connect even when clients exist. That is an edge; her pick still wins once made.
2. `copySetupCommand(for:)` now sets the menu's choice. From the pane it is a no-op (the press copies the shown client); only direct callers (tests) change it.
3. The tab row scrolls with long tabs (P-VX281-U1-3).
4. The rung popover repeats the line's fragment form (lowercase, no closing period) — on the FOR VX-234 list (U1-11).
5. `herPickedTabIsRememberedAcrossTheSettingsWindow` drives the tab row through AppKit's own `sendAction`. It is proven green on macOS 27, but it is a harness assumption a future SwiftUI could break.

**The trace discipline:** VX-232 was traced before code, and the pin was red on old exactly as traced. VX-245 is lint-class: its own red-to-green over the source (8 → 6 offenders). The design rows carry a geometry oracle (also red on old: no tab row) and the walk.

### OWED (for the orchestrator)

1. **Post `3d00a166` on VX-245** (its two MCP sites; the other six stay VX-283's).
2. **VX-197 (U7, the docs).**
   - The field guide's lesson 2 should teach the tabs and the copy icon. Today: "under Connect a client, choose yours … Then press Copy setup command" — true, since the section title is kept and the verb is the icon's name, but it describes no tabs.
   - Lesson 7's "under Waiting in Settings ▸ MCP" and "under Activity" stay true.
   - Anything that says where in the pane a thing sits should name its tab: requests and Waiting above the tabs; the Open book in Shared with AI.
3. **QUESTIONS at the merge:** P-VX281-U1-1 / -2 / -3 (options above).
4. **Canon at the merge** (the kickoff plan's list): AppSpec §12 THE MCP DOOR line gains the pane's tabs (R-VX184-6), the code block's copy icon as the act's face, and the explainers behind (i). MOBILE PARITY: **nothing mobile-visible** (the pane is Mac-only).
5. **For VX-234 / the settings effort:**
   - **`ExplainerLine`** lives at `App/Variorum/Variorum/Core/Views/ExplainerLine.swift`: token-free, one line plus an (i) whose popover holds the whole text, and no (i) when the line already IS the whole text. Its name and home are for reuse.
   - The grant sheet's other multi-line quiet lines are not cut (NOT-DONE 1) — hers to weigh with the wording pass.
6. **The cold review** (the run's ladder). The map:
   - `MCPPane.swift` (the tabbed form; `MCPPaneTab`);
   - `MCPSetupMenu.swift` (the code block; the door binding);
   - `MCPDoor.swift`'s session memory + `copySetupCommand` change;
   - `MCPPaneCopy.swift`'s summaries (the O-4 fence at 64/120 lines);
   - `MCPGrantSheet.swift`'s rung line;
   - `ExplainerLine.swift`;
   - `AppSettingsView.swift`'s search landing;
   - the pins in `MCPPaneTabsTests` and the harness `MCPPaneTabsCaptureTests`.

## U2 UNIT RECORD — the shared icon wherever the ask glyph is: VX-268 (opus-implementer, 2026-10-13 night)

Implementer: Opus (`claude-opus-5-5`), fresh session, HEAD at start `afb7deb4`. **No revert is in flight** unless a
line below says so.

### UNIT CLOSED (2026-10-14 ~00:20 MDT — the U2 implementer, Opus `claude-opus-5-5`)

**What this unit did NOT do (said first):**
1. **The Blocks-scope rows were not walked with a row on screen.** The fixture holds no named block and no
   block-level tag, so the Blocks scope listed "Nothing matches." (`s07`). Their evidence is the code: `blockLine` is
   untouched and draws no icon, as her call says.
2. **The Terminal note-row popover click missed** (`t05` — no popover drew). The popover's Terminal face is walked on
   ⌘L's row (`t03`); the Study note-row popover is `s03`.
3. **Light appearance only** (no dark). The icon's tint is the voice's accent token, in both voices.
4. **Not staged on the dev store:** a waiting ask beside the shared icon on one row, and a wing menu row carrying
   both. The order is code (shared, then the ask glyph — the Bookcase's), and the menu's one-mark rule is pinned
   (`MCPSharedRowsRulesTests`).
5. **Hover tooltips were not captured.** A tooltip is not drawn into a capture, and its words are the existing
   icon's (`MCPShareCopy.iconHelp`, unchanged).
6. **The autosave-rate re-run of a note hold** (with live reach — the P1 table above) was argued and pinned headless
   (statements don't grow with rows; nothing reads `container` without reach), not measured live.
7. **Nothing written to `notes/QUESTIONS.md` or canon** (merge-time — OWED), **and no cold review yet** (the run's ladder).

Everything else in the U2 row is DONE and evidenced:
- **The trace.** Written to the line before any code.
- **The seam + pins, red first.** Core 6/6 red (43 issues) headless; Mac 9/9 red (27 issues) on the seam tree.
- **The fix, green.**
  - Core 30/4 with the existing reach suites; headless finals MCP 212/41 · core 2,788/320 · workbook 40/6.
  - The Mac batch: 812 tests / 149 suites, the one issue VX-115's standing pin.
- **THE WALK in both voices** (below):
  - every site wears the icon where an approved client reaches it;
  - bare where it must be (the "elsewhere" wing row, the "every draft" gathering, the Private notes);
  - Change… opens over ⌘L; Revoke is held;
  - the open book matches the Bookcase;
  - no icon anywhere once every client is denied.
- **The dev store restored `cmp`-SAME against the ORIGINAL copy.** Prefs identical, clipboard SAME.

**Commits (branch `vx-281-run-mcp-settings-pane-shared-icon`):**
- `c281f6b2` the record opens
- `68cc4ab1` the seam + the pins (red-first)
- `c3946402` the fix
- `de1f4a1d` compiled + headless finals + window 1's plan
- `9cd3d42a` the P1 table corrected
- `3e31f78b` window 2's plan
- `fe1afac7` window 1 recorded
- this commit (the walk + the close)

**Surfaces, by path:**
- core — `Sources/VariorumCore/Queries/MCPShareQueries.swift` only;
- app — `Core/Views/{MCPRowReach (new), MCPSharedIcon, MCPShareRoad, WingsModel, WingSwitcherMenu, WingSwitcherSheet}`,
  `Features/Library/{LibraryCatalogView, LibraryCatalogModel, LibraryCatalogPaging}`, `Features/Pool/PoolPostsView`,
  `Features/BookView/{BookPanelModel, BookPanelView}`, `Features/Timeline/TimelineView`, `RootView` (one `.task`);
- tests — `Tests/VariorumCoreTests/MCPRowReachTests` (new), `VariorumTests/{MCPSharedRowsTests,
  MCPSharedRowsRulesTests}` (new), and the ritual edits in `BookPanelTests` and `CapabilityRegistryTests`.

Zero lines in: `Sync/`, custody/keychain, the editor seam, schema, the MCP wire (`Sources/VariorumMCP`),
`Domain/MCPGrantRule.swift`, `SettingsShape.swift`, `TutorialSeeder`.

**Read in full before code (never delegated):** this record whole (incl. the U1 UNIT RECORD and its walker facts);
`notes/plans/mcp-pane-and-docs-kickoff.md` (the U6 section, the binding rulings, the rules, the VX-268 bullet);
`notes/plans/vx-33-release-runway.md` §2–§3; `notes/SessionResiliencyProtocol.md`; the 13n-c plan's rulings list
(VX-271 · VX-164 · VX-272 · VX-273), §3 U3 + U4, the U3 and U4 UNIT RECORDs (the icon's birth, the glyph's nine
hosts, P-13nc-U3-7's gate split, P-13nc-U4-3's menu-row mark), the PROVISIONALs list; VX-184's U2 UNIT RECORD
(VX-185 — `decideGathering`, R-VX185-1, the archived-book rule, the 1,024-case agreement pin); the VX-268 ticket and
its kickoff comment on the board (her calls, verbatim in "Her rulings" above — and the ticket's own audit line:
*"The note's own bars need nothing (the in-note indicator already carries the shared icon there)."*); the walk
lessons. Code: `Queries/MCPShareQueries.swift` whole, `Queries/MCPGrantQueries.swift` (the facts, the fence
fragments, clients, grants), `Domain/MCPGrantRule.swift` whole (`decide`, `reach` ×2, `decideWing`,
`decideGathering`, `reaches`, `best`); app — `MCPSharedIcon`, `MCPAskGlyph`, `MCPAskBoard`, `MCPShareRoad`,
`MCPNoteIndicator`, `ShelfView`/`ShelfViewModel` (the Bookcase host), `LibraryCatalogView` +
`LibraryCatalogModel` + `LibraryCatalogPaging` + `LibrarySearchSheet` (the near-window hold, the row slices),
`TimelineView`, `PoolPostsView`, `BookPanelView` + `BookPanelModel`, `WingsModel`, `WingSwitcherMenu`,
`WingSwitcherSheet`, `RootView`'s road + switcher host, `BookSettingsSheet`'s nested grant host, the registry's
`.mcpShowSharing`/`.mcpChangeGrant`; the suites `MCPGatheringReachTests`, `MCPGatheringIconTests`,
`LibraryRowAlignmentTests`, `LibraryInfiniteScrollTests`' harness, `CapabilityRegistryTests`' `.surface` walk.

### The trace (VX-268 — bug class; made before any code)

**Inputs → wrong output.** An APPROVED client reaches a note (its own note grant, a book grant on a book it is a
member of, a wing grant on its wing) or the open book is ON; the note is listed in the Library (List, Cards, the
answer sheet, Timeline), the Pool, or a Book Panel. Or a client holds a wing grant on a wing (or the open book is on)
and the wing is listed in the switcher (its ▾ menu, ⌘L). **No row wears the icon.** Her report, verbatim on the
ticket: *"claude-code reaches two books, the Bookcase wears the icon on both, and the Library shows nothing on those
books or on their notes."*

**The mechanism, to the line.** The ONE icon (`MCPSharedIcon`) has exactly two hosts, each fed by its own held read:
`ShelfView.shelfRow` (~l.696, `ShelfViewModel.aiReach` ← `Queries.mcpBookReaches`) and `MCPNoteIndicator` (l.88,
`Queries.mcpNoteReach`). Every other place the ask glyph marks carries the glyph alone and NO reach read:
- the Library's note rows — the List line `CatalogNoteLine` (`LibraryCatalogView.swift:1441`, built by `postRow`
  :1179 — also the answer sheet's note heads) and the Cards card (`noteCard`, :1065). The model's near-window hold
  observes `Queries.ownershipFacts` only (`LibraryCatalogPaging.swift:184–207`);
- the Library's BOOK and GATHERING rows (`CatalogBookLine`, :1338) wear neither mark (the ticket names them);
- the Timeline's rows (`TimelineView.row`) wear neither (U4: "not built … the Library's Timeline rows"; the ticket
  names Timeline);
- the Pool's rows (`PoolPostsView.swift:420`; the model reads tags and snippets only);
- the Book Panel's note rows (`BookPanelView.swift:278`; the model holds the table of contents only);
- the ⌘L sheet's wing rows (`WingSwitcherSheet.swift:283`) and the ▾ menu's wing rows (`WingSwitcherMenu.swift:178`,
  the pending symbol as the row's image); `WingsModel` reads `Queries.wings` only.

And the core has no read these rows could use at their scale: `mcpNoteReach(db, noteID:)` is SINGULAR (one facts read
per note — per row); `mcpBookReaches(db)` decides EVERY live reading of every wing (the Bookcase's class, not a
listing's); and nothing reads a WING's reach at all — `decideWing` has no read-off.

**Not the cause, checked:** the icon and its popover are place-blind (`MCPReachPopover` renders a reach's rung,
duration, why, Change… on the reach's grant, Revoke); the one rule already answers every place correctly through
the singular reads. The gap is the rows' reads and their faces, nothing in the rule.

### The site list — the parity re-audit (code, `afb7deb4`)

The ask glyph (`MCPAskGlyph`) is rendered at nine hosts. Against each, this unit's call:

| # | Host (the ask glyph's line) | The shared icon | Why |
|---|---|---|---|
| 1 | the in-note indicator (`MCPNoteIndicator.swift:90`) | ALREADY THERE (13n-c U3) | unchanged |
| 2 | the Bookcase rows (`ShelfView.swift:702`) | ALREADY THERE (13n-c U3, VX-185) | unchanged |
| 3 | the Library — note rows in List (`:1441`), Cards (`:1065`) and the answer sheet's heads (List's line) | **IN** | the ticket |
| 3b | the Library — BOOK and GATHERING rows (`CatalogBookLine`; List, the capped region, the answer sheet) | **IN** | the ticket names them (no ask glyph there) |
| 3c | the Library — Timeline rows | **IN** | the ticket names Timeline (no ask glyph there) |
| 4 | the Pool rows (`PoolPostsView.swift:420`) | **IN** | her kickoff call |
| 5 | the Book Panel's note rows (`BookPanelView.swift:278`) | **IN** | her kickoff call |
| 6 | the wing switcher's ⌘L sheet rows (`WingSwitcherSheet.swift:283`) | **IN** — the icon with hover + popover | the ticket ("a shared wing never shows as shared there") |
| 7 | the wing switcher's ▾ menu rows (`WingSwitcherMenu.swift:178`) | **IN** — as the row's MARK (a menu row hosts no popover; the ask glyph is a mark there too, P-13nc-U4-3) | the ticket; P-VX281-U2-1 |
| 8 | the commit bar's note ▾ (`CommitBar.swift:781`) | OUT | the ticket's own audit: *"The note's own bars need nothing (the in-note indicator already carries the shared icon there)."* |
| 9 | the Takes bottom bar's note ▾ (`TakesBottomBar.swift:405`) | OUT | the same line |
| — | the masthead wing WORD's `.anyWing` glyph (`WingSwitcherMenu.swift:97/125`) | OUT | it marks every wing's asks, not one place — no place-parity; P-VX281-U2-2 |
| — | the Library's Blocks-scope rows | OUT | her kickoff call ("the note's own indicator already says it") |

### The design (each call said; PROVISIONALs listed below)

1. **Core — three batched reads on the ONE road, in `Queries/MCPShareQueries.swift` only** (the share faces' reads;
   zero lines in `Domain/MCPGrantRule.swift`, the wire, `Sync/`, the schema):
   - `mcpNoteReaches(_:noteIDs:)` — the batched twin of `mcpNoteReach`: the approved clients and their grants read
     ONCE, the notes' facts in ONE batched read (`mcpNoteFacts(noteIDs:)` — two statements for the page), every id
     decided by the SAME read off `decide` (`placeReach`). Pinned to agree with the singular for every id.
   - `mcpBookReaches(_:readingIDs:)` — the existing map, given the listed ids (nil = every live reading, the
     Bookcase's call byte-unchanged): books through `decide`, gatherings through `decideGathering` (VX-185).
   - `mcpWingReaches(_:)` — Home and the live wings, each read off `decideWing` exactly as `MCPGrantRule.reach` is
     read off `decide` (from the top rung down; `.allow(grantID)` names the grant, nil the open book) — a new
     `MCPReachPlace.wing` beside `.note` / `.book` / `.gathering`; its own wing grant is the place's own (no why).
   - One shared gate, `mcpReachStandings`: no approved client (VX-272), or no approved client holding a live grant
     with the open book off ⇒ nil, and not one `container` row is read.
2. **The icon's calm state draws NO view** (`MCPSharedIcon` with no reaches — the ask glyph's own rule), so every
   host writes it once, unguarded.
3. **The hosts, each with a HELD read ∝ what it shows (P1 — said per site in "P1, per site" below)**, each placing
   the icon right after the row's name and before the ask glyph (the Bookcase's order).
4. **The open book matches the Bookcase** — by construction: every read decides through the rule, and the rule
   reaches every unfenced place under the open book.
5. **The gate is the Bookcase's** (P-VX281-U2-3): a row wears the icon while an approved client reaches it, the
   server switch aside.
6. **Declarations (P-1's declared ⇔ rendered):** `LibraryCatalogView`, `TimelineView`, `PoolPostsView`,
   `BookPanelView` and `WingSwitcherSheet` add `MCPSharedIcon.surfaceCapabilities`; the ▾ menu does NOT (a menu
   row's mark is no door — its press switches the wing, as it always has).

### P1, per site (how each read scales)

Every read is one of the three core reads (one rule), HELD by the host while it shows, and re-aimed only when the
rows it shows change. **The cost the house rule names** (`AppDatabase.observe`): a NOTE read touches `container`,
which every autosave rewrites whole, so a host's note hold re-runs at autosave rate while it is on screen — ONE
bounded batch, and ONLY while an approved client holds a live grant or the open book is on (`mcpReachStandings`
stops the read at the grants store otherwise, so `container` is never in its region — pinned headless:
`noApprovedClientMeansNoReachAndTheNotesAreNeverRead`). Correctness wins over a named-region hold here: a note marked
Private, moved to another wing or trashed changes only `container`, and the icon must leave at once (a privacy
affordance that lags is a surprise). The batch is two statements however many rows (pinned:
`theBatchedReadsStatementsDoNotGrowWithTheRows` — 2 rows and 40 rows run the same statements).

| Host | Read | Scales with | Wakes at autosave? |
|---|---|---|---|
| the Library's note rows (List, Cards, the answer sheet's heads) | `mcpNoteReaches` over the NEAR WINDOW (`nearNoteIDs` — the pages around what is on screen, ≤ 3 × 80), beside the owned-by facts, re-aimed at page boundaries | the window, never the listing (however deep she scrolls) | only with live reach — and then also while it sits in a split pane beside a note being edited (list surfaces mount whole in every pane — `RootView.paneDetail`): one window batch per autosave. NEW cost on this host: its owned-by hold reads no `container` |
| the Library's book + gathering rows | `mcpBookReaches(readingIDs:)` over `listedBookIDs` | the listed books (the Library lists its wing's books whole — the Bookcase's own class) | never (`reading`, `wing`, the grants store) |
| the Timeline's rows | `mcpNoteReaches` over the LOADED rows | the pages she loaded (each "Load More" is her act — the order of the Timeline's own reads) | only with live reach (a split pane beside an editor included) |
| the Pool's rows | `mcpNoteReaches` over `drawnIDs` | the Pool's own window (200 loose, + the tucked run while shown) | only with live reach (its listing already re-reads `container` per autosave over the same window) |
| the Book Panel's rows | `mcpNoteReaches` over the panel's entries | the panel's own window (`entryWindow` = 300) — the panel's snapshot already re-runs per autosave over the same window | only with live reach (the one host beside an editor — one batch per autosave, the snapshot's own class) |
| the wing switcher (⌘L's rows, the ▾ menu) | `mcpWingReaches` | the wings × the approved clients | never (no `container`, no `reading`) |

### LIVE STATUS — U2's pieces (flipped in the same commit as each piece)

| # | Piece | State |
|---|---|---|
| 0 | this record: the trace, the site list, the design | DONE (this commit) |
| 1 | THE SEAM + THE PINS, red-first: the final API with the PRE-FIX BEHAVIOUR behind it (no surface reads reach, no row draws it, the core reads answer nothing) + the core pins + the Mac pins; the core pins RED headless; the seam tree built for testing | DONE (`68cc4ab1`): the seam (`Queries.mcpNoteReaches` / `mcpBookReaches(readingIDs:)` / `mcpWingReaches` answering `[:]`; `LibraryNoteRowExtras.reach` never set, `LibraryCatalogModel.bookReach` + `holdBookReach` empty, `PoolPostsModel` / `BookPanelModel` / `TimelineViewModel` `.reach` + `holdReach` empty, `BookPanelModel.entryIDs(for:)`, `WingsModel.reach` + `watchSharing` empty; `CatalogNoteLine` / `CatalogBookLine` take `reach:` and draw nothing) + **core `MCPRowReachTests` 6 tests — RED on the seam headless: 6/6 failed, 43 issues** (`swift test --filter MCPRowReachTests`, log `vx281-screens/u2/logs/core-pins-seam.log`; every positive leg; the guards — VX-272's empty map, no `container` read — green by nature, each paired with a red control) + Mac `MCPSharedRowsTests` 10 tests (the hosts' holds, the open book, VX-272, the two List lines' faces on the title's baseline). the seam tree BUILT for testing — `DerivedData/vx281-u2-old` from `68cc4ab1` (`** TEST BUILD SUCCEEDED **`, `logs/build-seam.log`; an APFS clone of U1's build for speed — its stale-path warnings name U1's directory, which the build refused to touch; the products are fresh in their own directory). DONE but for the Mac red run, which is STAGE WINDOW 1's |
| 2 | THE FIX: the core reads; the icon's calm state; the hosts' held reads and faces; the declarations and their ritual pins | DONE (`c3946402`; COMPILED — `DerivedData/vx281-u2`, `** TEST BUILD SUCCEEDED **`, `logs/build-fixed.log`, no new warning in a touched file — the two seen are pre-existing lines, identical in the seam build): core `mcpReachStandings` + the three reads + `MCPReachPlace.wing` (read off `decideWing`) — **core GREEN headless: `MCPRowReachTests` 6/6 + `MCPShareTests` + `MCPGatheringReach*` = 30 tests / 4 suites** (`logs/core-pins-fixed.log`; two PIN-AUTHORING errors found by the first green run and fixed in the pins, not the code: line 115 forgot codex's Home wing grant still reaches the note — now asserts claude-code LEAVES and codex stays; the wing agreement iterated a deleted wing, which has no row — now iterates the live wings); app: `MCPSharedIcon`'s calm state = no view, `MCPRowReach.hold` (Core/Views), the Library's near-window reach hold + listed-book hold + row faces (List line, card, book line), Pool / Book Panel / Timeline holds + faces, `WingsModel.watchSharing` (RootView task), ⌘L's row icon + `MCPShareRoad.openingHere` + the nested grant sheet, the ▾ menu's `rowMark`, the declarations; ritual pins `BookPanelTests` (exact set) + `CapabilityRegistryTests` (the walk's Timeline line); new design suite `MCPSharedRowsRulesTests` (3: the calm icon takes no width or spacing; the menu row's one mark; every host declares the icon's acts, the menu none) |
| 3 | headless finals + the fixed tree built for testing | DONE (this commit) — the whole package `swift test` on the fixed tree: **`VariorumMCPTests` 212/41 · core 2,788/320 (VX-184's 2,782/319 + `MCPRowReachTests` 6/1) · workbook 40/6 — 0 failures**; skips = the standing gated nine (read, `logs/headless-finals.log`) |
| 4 | STAGE WINDOW 1 — red on the seam tree, the Mac batch on the fixed tree | **DONE** (claim `vx281-u2`, 23:49:18–23:55:20 MDT, handed over from `coord-for-vx281` by the coordinator's exact line; `guard.sh --author` OK before each run, no Variorum instance before or after; released the moment (b) ended, before anything else). **(a) RED ON THE SEAM** (`DerivedData/vx281-u2-old`, built from `68cc4ab1`; `logs/a-red-on-seam.log`): **9 tests / 1 suite — ALL 9 RED, 27 issues** — the Library's note + book holds (8), the open book (8), the Pool (1), the Book Panel (2), the Timeline (1), the wings (2), VX-272 (3 — its control legs; the guard green as stated), and both faces (1 each — the shared probe nil: no icon drawn). The seam tree then DELETED (the coordinator's leave; disk). **(b) THE BATCH ON THE FIXED TREE** (`DerivedData/vx281-u2`, `9cd3d42a`'s sources; `logs/b-batch.log`): **812 tests / 149 suites, ONE issue — VX-115's standing `BookCollectingDoorsTests.theSettingsDoorIsOneActOnBothRoads`** (`BookView.surfaceCapabilities == [.openBookSettings]`, red on main since 13o U3 — not this unit's). Every other test green: **`MCPSharedRowsTests` 9/9 and `MCPSharedRowsRulesTests` 3/3 GREEN** (the same nine red on the seam, green here), the two ritual pins (`BookPanelTests`' exact set, `CapabilityRegistryTests`' `.surface` walk) green, VX-185's `MCPGatheringIconTests` and 13n-c's `MCPShareFacesTests` green, the Library's alignment/paging/infinite-scroll suites green (VX-167's order-dependent pair NOT met). Skips read: the gated capture harnesses (13n-c U1–U4, VX-281 U1) and the opt-in rigs (the List-face rig, the singleton-window oracles) only. **Nothing to fix.** |
| 5 | STAGE WINDOW 2 — the walk | **DONE** (claim `vx281-u2-walk`, 23:56:51–00:14:25 MDT, handed over from `coord-for-vx281` by the coordinator's exact line; guards clean at every step, no system popup) — THE WALK below; 57 captures in `notes/plans/vx281-screens/u2/walk/` (gitignored), every one read; the dev store restored `cmp`-SAME against the ORIGINAL copy, the prefs identical, the clipboard SAME |
| 6 | close: self-assessment, PROVISIONALs, OWED | DONE (this commit) — **UNIT CLOSED** (the banner atop this record) |

### THE WALK (STAGE WINDOW 2 — 2026-10-13 23:56:51 → 2026-10-14 00:14:25 MDT, claim `vx281-u2-walk`)

**Setup:**
- The Debug app is built from `DerivedData/vx281-u2` (pid 25045), light appearance (staged by the local pref).
- **The ORIGINAL safety copy:** `…/safety-copies/vx281-u2-prestage-20261014T055702Z/` — five files, each `cmp`-SAME
  (sqlite `9bb8eef87116`, wal `c5beb92c1cf8`, shm `7ce060b13cfa`, key files `3af4704371ff` / `7e12a1b85890`).
- **The staging script's own copy:** `…/scale-prestage-20261014T055709Z/`, then the fixture,
  `notes=30,long=1,books=20,shelves=3,wing=2`.
- The dev store opened **Standard, unlocked**, in Study, with no What's New sheet.
- **Four approved clients** (`s00`: claude-code, u1-walk, u2-walk, u3-walk), so the coordinator's no-client road was
  not needed.

**The legs:**

| Leg | Study | Terminal | Seen |
|---|---|---|---|
| W1 — the Bookcase (the control) | `s01` | `t16` (after W13) | every book and the Home gatherings wear it (Study); bare once no client is approved (Terminal) |
| W2 — the Library, List, Home | `s02`, `s03`/`s03b` | `t04` | every BOOK row and NOTE row wears it right after the title, on its line. The popover, per client: "read, suggest, write new and edit · always", "through the Home wing grant", Change… · "Revoke the Home wing grant" |
| W3 — Cards | `s04` | `t06`/`t06b` | every card wears it after its lead |
| W4 — Timeline | `s05` | `t07` | every row wears it, across wings (the Timeline's stamp lenses aren't wing-scoped): the drafts via their note grants, the lexer/grammar via variorum's wing grant — and **"a private parser note" BARE** (the Private fence) |
| W5 — the answer sheet ("river") | `s06` | — | the book rows and the note heads wear it — and **"Fixture 0000 — on the river at dusk" BARE** (the fixture marks its first note Private, `ScaleFixture.swift:336` — the fence, a second time) |
| W5b — Blocks scope | `s07` | — | "Nothing matches." (no block rows in this fixture — NOT-DONE 1) |
| W6 — ⌘L | `s08`, `s09`, `s10`, `s10b`/`s10c` | `t02`, `t03` | rows: Home and variorum WEAR it, **"elsewhere" BARE** (P-VX281-U2-4). variorum's popover: "read, suggest and write new · always", no why, Change… · Revoke. **Change… opened THE grant sheet OVER the switcher** ("Change access — claude-code", "Confirming replaces the grant you opened this from.", A wing · variorum · Write new · Always); **Cancel** → the switcher back, nothing written |
| W7 — the ▾ menu | `s11` | — | Home and variorum carry the shared MARK, "elsewhere" plain |
| W8 — "elsewhere" | `s12`, `s13` | `t01`/`t01b` | "Now in “elsewhere”." Both drafts wear it ("read · always", no why, plain Revoke); "the drafts book" wears it; **"every draft" (the gathering) BARE** — R-VX185-1 |
| W12 — Revoke, held | `s14` | — | claude-code's Revoke on "a draft about doors" → the popover re-opened with NO refresh: claude-code now "read · always · through “the drafts book”" with "Revoke the grant on “the drafts book”" — the book grant still reaches the note |
| W9 — the Book Panel | `s15`, `s16` | `t08`/`t08b` | "the drafts book"'s two rows wear it; the in-note indicator's icon top right |
| W10 — the Pool | `s17`/`s17b` (variorum, tucked), `s18`/`s18b` (Home) | `t09`/`t09b` | the lexer and the grammar wear it, **"a private parser note" BARE**; Home's tucked and loose rows wear it |
| W11 — the open book | `s19`, `s20`, `s21`/`s21b`, `s22`, `s23`, `s24`, `s25`/`s25b` | — | Open book ON → **"every draft" WEARS it**, its popover per client "read · always · through the open book · The open book is switched in Settings ▸ MCP."; ⌘L's "elsewhere" now wears it. Open book OFF → "every draft" bare again (held) |
| W13 — VX-272 | — | `t10`, `t11`, `t12`, `t13`, `t14`, `t15`, `t16` | Settings ▸ MCP ▸ Clients → each client's Deny… (every confirm read by accessibility first: "Deny claude-code? … Its 7 grants are revoked now…", then u3-, u2-, u1-walk) → **no icon anywhere**: ⌘L's rows, the Library's Timeline (the same rows `t07` showed iconed), the Bookcase |

**Driving slips, said plainly. None wrote the store:**
1. **A popover's Escape closed the ⌘L switcher with it.** The follow-on "home" ⏎ then landed nowhere (`t04`'s first
   capture still showed "elsewhere"; the search and quick-entry fields were empty). Re-done with ⌘L.
2. **A Library click hit Home's taller sidebar** (its Starred section) and opened the "quicknotes" gathering
   (`t15`'s first capture). It was a navigation only. Re-done.
3. **The Terminal note-row icon click missed** (NOT-DONE 2).

**Observed, not this unit's** (each for the orchestrator to weigh):
- The Pool's tucked run stays shown across a wing switch (`s18`) — the model is RootView's, and it tucks only when the
  page disappears.
- The field guide's card text still says only "On the Bookcase, a small icon beside a book means a client can reach
  it" (`s04`) → VX-197's truth pass.
- The icon reads large beside the Book Panel's small type (`s16`) — the ONE icon's own size (W-UX-7's
  `rowScale`) — a taste note for her.

**Cleanup:**
- Quit by identity; no instance left.
- `restore.sh` reported "Restored (verified)", and then **all five store files were `cmp`-SAME against the ORIGINAL
  copy** (the very first). The store folder held the same five files; the launch wrote no new backup; no socket left.
- **The Debug prefs:** `defaults import` MERGES, so one key the walk created survived it
  (`currentBlock.<pane id>` — the opened draft's caret memory). I deleted it, and a fresh export is **IDENTICAL** to
  the pre-walk export (`appearanceChoice` back to `system`).
- **Her clipboard was restored** (text, `cmp`-SAME).
- **POSTURE AS LEFT:** the dev store is **Standard, unlocked**, Study, byte-identical to its pre-walk state; no
  Variorum instance.
- **Stage RELEASED** at 00:14:25.

### PROVISIONALs (non-wording; the orchestrator files them in QUESTIONS at the merge)

- **P-VX281-U2-1 — a wing's ▾ menu row carries ONE mark, and a waiting ask outranks the shared icon.** A menu row
  hosts one image and no popover; the icon's door on a wing is ⌘L's row. (`WingSwitcherMenu.rowMark`, pinned.) Options:
  - **(a) The ask's mark wins (BUILT).**
  - (b) The shared mark wins.
  - (c) The menu shows neither — ⌘L only.
- **P-VX281-U2-2 — the masthead wing WORD wears no shared icon.** The word's ask glyph marks every wing's asks
  (`.anyWing`), not one place, so there is no place-parity; the ticket names the switcher's ROWS. Options:
  - **(a) Rows only (BUILT).**
  - (b) The word also wears the CURRENT wing's shared icon.
- **P-VX281-U2-3 — rows take the Bookcase's gate.** A row wears the icon while an approved client reaches it, server
  switch aside (P-13nc-U3-7's split carried). With the server OFF, rows show standing reach while the in-note
  indicator hides. Options:
  - **(a) The Bookcase's gate (BUILT).**
  - (b) Rows (and the Bookcase) hide while the server is off.
- **P-VX281-U2-4 — a wing row's reach is `decideWing`'s:** a wing grant on it (its rung and duration) or the open book
  (read). Note or book grants inside a wing never icon the wing — R-VX185-1's reading, one level up; walked: "elsewhere"
  bare under its note and book grants (`s08`). Options:
  - **(a) `decideWing` (BUILT).**
  - (b) Any grant reaching anything in the wing icons it.
- **P-VX281-U2-5 — ⌘L's Change… opens THE grant sheet OVER the switcher,** the nested-host precedent (Book Settings
  T-U3-7, U4's asks); walked (`s10`, `s10b`). Options:
  - **(a) Over the switcher (BUILT).**
  - (b) Close the switcher, then open it on the window.

**Argued, not provisional:**
- **Note holds read `container`, so they re-run per autosave while reach is live.** Correct the moment a note is
  marked Private, moved or trashed (the P1 table). A named-region hold would leave a "shared" icon on a note just
  marked Private.
- **The row's order** is the Bookcase's: name, the shared icon, then the ask glyph.

### SELF-ASSESSMENT

**Against VX-268 and her kickoff calls:**
- Every place the ask glyph marks a place now wears the ONE icon with its hover and popover: the Library's note rows
  (List, Cards, the answer sheet), the Pool's rows, the Book Panel's rows, and ⌘L's rows (the menu's rows as a mark).
- So do the ticket's own additions: the Library's book and gathering rows, and Timeline.
- **Her calls held:**
  - Pool and Book Panel rows are IN; Blocks-scope rows are OUT.
  - **The open book matches the Bookcase** (W11 — the same rule, so the same answer).
  - With no approved client, nothing (W13).
- **Reach comes only through the one rule:**
  - notes through `decide` (pinned id-for-id against the singular read);
  - books and gatherings through each kind's rule (pinned against the Bookcase's own map);
  - wings read off `decideWing` (pinned against it at every rung).
- **Bare where it must be:** the fence held live four times (two Private notes, the Private-member Pool row, the
  Timeline), as did R-VX185-1 (the gathering) and P-4 (the wing row).

**Against the spec and the seams:** zero `Sync/`, custody, editor seam, schema, wire or `MCPGrantRule` lines.
Chrome plus core reads, with Swift Testing state pins. P1:
- every read is sized to what its host shows;
- the batch's statements don't grow with the rows (pinned);
- with no live reach, no note is read at all (pinned).

**Risks I see:**
1. **The autosave-rate re-run of the note holds while reach is live.** This is new cost on the Library, Pool and
   Timeline when one sits beside an editor in a split pane: one bounded batch per autosave. It is argued, not
   measured.
2. **⌘L's nested grant sheet:** macOS hides the switcher while the grant sheet is up and re-shows it after (its window
   id changed). The walk saw it come back intact, but it is AppKit's behaviour, not ours.
3. **The Timeline's hold** is sized to the rows she loaded (her own "Load More" pages), not to a window.
4. **The icon's size in the Book Panel's small type** — a taste note for her.

**The trace discipline:** the bug was traced to the line before code. The pins were red first, on a seam that carried
the old behaviour (core 43 issues, Mac 27), then green on the fix. Two pin-authoring errors are recorded as such.

### OWED (for the orchestrator)

1. **The cold review** — Opus at max, then the end-of-run Fable round (her redirect). The map:
   - `MCPShareQueries.swift` — `mcpReachStandings`, the three reads, `MCPReachPlace.wing`/`wingReach`. Is anything
     read off a rule other than its kind's own? Does any read touch `container` without reach?
   - `LibraryCatalogPaging.holdNearFacts` / `LibraryCatalogModel.landReach` — the slices, the near window.
   - `MCPRowReach.hold` and the four hosts' `.task(id:)` re-aims.
   - `MCPSharedIcon`'s calm state.
   - `WingSwitcherSheet`'s nested grant sheet; `MCPShareRoad.openingHere`.
   - `WingSwitcherMenu.rowMark`.
   - The declarations and the two ritual pin edits.
2. **QUESTIONS at the merge:** P-VX281-U2-1…5 (options above).
3. **Canon at the merge** — AppSpec §12, THE MCP DOOR line (or the Bookcase icon line). The ONE shared icon marks:
   - every Library row an approved client reaches — notes, books and gatherings, in List, Cards, the answer sheet
     and Timeline;
   - the Pool's and the Book Panel's rows;
   - the wing switcher's rows (⌘L with its popover; the ▾ menu as a mark);
   - by the one rule, with the Bookcase's gate.

   Not marked: Blocks-scope rows and the note's own bars. MOBILE PARITY: **nothing mobile-visible.**
4. **VX-197 (U7, the docs):** field-guide lesson 7 (and the card text `s04` shows), "a small icon beside a book
   means a client can reach it", should say the icon marks notes, books, gatherings and wings wherever they're listed.
5. **A follow-up to weigh (not filed from the branch):** the Book Panel's collapsed one-note chapter row stands for a
   note but wears NEITHER glyph (the ask glyph never sat there either) — parity for both, if wanted.
6. **`DerivedData/vx281-u2` is DELETED** at this close (3.2 GB). Nothing needs it: any later Mac run builds the
   reviewed tip fresh.

### STAGE WINDOW 1 — the plan (runs ONLY under the claim the orchestrator relays — expected `vx281-u2`, ~30 min)

0. **Guards, every time:** `Tools/WalkKit/guard.sh --author` (her `/Applications/Variorum.app` absent — if present,
   STOP and report); `pgrep -fl 'Variorum.app/Contents/MacOS'` empty; the claim held. No Debug launch in this window.
1. **RED ON THE SEAM TREE** (`DerivedData/vx281-u2-old`, built from `68cc4ab1`): `xcodebuild test-without-building
   -scheme Variorum -destination 'platform=macOS' -derivedDataPath DerivedData/vx281-u2-old
   -only-testing:VariorumTests/MCPSharedRowsTests` → expected **9 tests, all RED** (every host's settle times out;
   VX-272's guard green with its control red; both faces' `#require` on the shared probe nil). Log
   `logs/a-red-on-seam.log`.
2. **THE BATCH ON THE FIXED TREE** (`DerivedData/vx281-u2`, HEAD's sources): `test-without-building` with
   `-only-testing:VariorumTests/<Suite>` for the **149 suites** that exercise a changed source file (derived by
   script — every test file naming a changed type; the list: `logs/batch-suites.txt`) → `MCPSharedRowsTests` 9 and
   `MCPSharedRowsRulesTests` 3 GREEN, the ritual pins green. Standing reds named if met (not this unit's): VX-115's
   `BookCollectingDoorsTests.theSettingsDoorIsOneActOnBothRoads`; VX-167's order-dependent pair
   (`LibraryInfiniteScrollTests.aPageLandingReDrawsNoRowAlreadyBuilt`, `DestructiveUndoWarningTests.redoNeverAsks` —
   the latter is not in this set). Log `logs/b-batch.log`; `skipped:` lines read (the gated capture harnesses and
   rigs skip).
3. Release the claim at once; record the counts; a red that is this unit's is fixed before window 2 (the walk).

### STAGE WINDOW 2 — the walk: the plan (runs ONLY under the claim the orchestrator relays — expected `vx281-u2-walk`, ~65 min; AFTER window 1 is green)

**The build:** `DerivedData/vx281-u2/Build/Products/Debug/Variorum.app` (`io.lduarte.Variorum.debug`, HEAD's app
sources). **Captures:** `notes/plans/vx281-screens/u2/walk/` (gitignored), region or window-id captures, every one
READ. **Driving (the walk lessons + U1's walker facts):** every click through `Tools/WalkKit/click.sh <devpid> x y`,
every key through `Tools/WalkKit/keys.sh <devpid> '<System Events>'` (never cliclick keys — and Escape reaches a
popover only this way); guarded steps ≥ 2.5 s apart, every helper's exit code CHECKED; row y re-read from a fresh
capture after every voice flip; an alert's buttons pressed by their AX `description`; quit ONLY by identity
(`tell application id "io.lduarte.Variorum.debug" to quit`), then `pgrep -fl 'Variorum.app/Contents/MacOS'`. A
SYSTEM popup or dialog that Variorum itself can't dismiss (a permission prompt, a Keychain ask) = STOP: capture its
exact text, keep the claim, report — never click through it.

**Setup (S0–S6):**
- **S0 — guards:** `Tools/WalkKit/guard.sh --author` OK (her `/Applications/Variorum.app` absent — present ⇒ STOP,
  never quit it); `pgrep -fl 'Variorum.app/Contents/MacOS'` empty; the claim held; `Tools/WalkKit/wl2` compiled in
  this worktree (it is — U1's fact: without it the guard silently skips its window check).
- **S1 — helpers** into the scratchpad: `swiftc -O` of `capture-windows.swift` and `scroll.swift`.
- **S2 — saves:** the Debug prefs `defaults export io.lduarte.Variorum.debug <scratch>/prefs-before.plist` (and its
  `appearanceChoice` noted); her clipboard as text (`pbpaste > <scratch>/clip-before.txt`); and MY OWN A1 prestage
  copy of the dev store (every `variorum.sqlite*` + `variorum-keys-*.json` →
  `…/Variorum-dev/Backups/safety-copies/vx281-u2-prestage-<ts>/`, each `cmp`-verified) — the fallback restore
  source if anything happens before the staging script runs.
- **S3 — light appearance:** if `appearanceChoice` is not `light`, `defaults write io.lduarte.Variorum.debug
  appearanceChoice light` (a LOCAL pref; S2's export puts it back).
- **S4 — the staging:** `Tools/ScaleFixture/stage.sh notes=30,long=1,books=20,shelves=3,wing=2
  <home>/dev/variorum-vx-281/DerivedData/vx281-u2` — its OWN A1 copy (every store file + the key
  files → `…/safety-copies/scale-prestage-<ts>/`, `cmp`-verified; the dir printed and recorded), then the Debug app
  launched with the fixture (VX-185's world, minted once in ~1 min, `ScaleFixture: minted …` in the log via
  `/usr/bin/log`): Home's 30 notes and 20 books on 3 shelves; the wing **"variorum"** (gathering "parser things",
  "the lexer", "the grammar", the PRIVATE "a private parser note", the archived pair) with, for EVERY approved client,
  edit · Home · always + write new · variorum · always; the control wing **"elsewhere"** (gathering "every draft",
  book "the drafts book", "a draft about rivers" / "a draft about doors" in it) with read · always note grants on
  both notes and a book grant on the book — NO wing grant there.
- **S5 — first look:** the What's New sheet, if any, closed with its own button; the dev store opened **Standard,
  unlocked** (a lock screen ⇒ STOP and report — no credential is used in this walk); the voice read (Study
  expected). Settings ▸ MCP ▸ Clients: at least ONE approved client (the fixture's grants need one — the dev store
  carried four after VX-184's walk). **None ⇒ THE WAY ROUND (the coordinator's decision, 2026-10-13 23:48 — never a
  stop):** quit by identity; `restore.sh` S4's dir (back to the original); a FRESH verified safety copy; launch the
  dev build plainly; Settings ▸ MCP ▸ Connect ▸ Any MCP client's copy icon (the key into the env — the clipboard is
  already saved); U1's scripted client (copied to `vx281-screens/u2/walk/client.py` with its `SHIM` pointed at
  `DerivedData/vx281-u2`'s `variorum-mcp` — U1's tree is gone) connects as `vx281-u2-walk` with a `list_notes`; the
  request Approve… with "Nothing yet"; quit; `stage.sh` AGAIN (its own new A1) so the fixture grants that client;
  walk. **At cleanup, restore to S2's ORIGINAL copy** (the very first — remove the WAL/shm, copy back, `cmp` each),
  and the posture as left is proven `cmp`-SAME against THAT copy.
- **S6 — the clients named** (Clients tab capture `s00`) — the popovers below list each.

**THE WALK — Study (light). Every site, wearing the icon where a client reaches it, BARE where it must:**

| Leg | Do | Expect (capture) |
|---|---|---|
| W1 — the Bookcase (unchanged host, the control) | Home's Bookcase | every book + the Home gatherings wear the icon (Home wing grant) (`s01`) |
| W2 — the Library, List, Home | sidebar Library; scope All; mode List | every NOTE row wears the icon right after its title (before any ask glyph); the BOOK and GATHERING rows wear it after the name (`s02`). Click a note row's icon → the popover: "Shared with" · each client "edit · always" · "through the Home wing grant" · Change… · "Revoke the Home wing grant" (`s03`); Escape (keys.sh) closes it |
| W3 — Cards | mode Cards | every card wears it after its lead (`s04`) |
| W4 — Timeline | mode Timeline | every row wears it after its title (`s05`) |
| W5 — the answer sheet | a word from a card's preview typed in the Library field | the note heads and the book rows wear it (`s06`) |
| W5b — Blocks scope (OUT, her call) | scope Blocks with the same word | the BLOCK lines (passages) wear NO icon — only a note head, itself a note row, does (`s07`); the field cleared |
| W6 — ⌘L | keys.sh ⌘L | the rows: Home WEARS it, "variorum" WEARS it, **"elsewhere" BARE** (note + book grants inside a wing never share the wing — P-VX281-U2-4) (`s08`). Click "variorum"'s icon → its popover: "write new · always", NO why (its own grant), Change… · Revoke (`s09`). **Change… → THE grant sheet OVER the switcher** ("Change access — ‹client›", "Confirming replaces the grant you opened this from.", WHERE a wing · variorum, write new · always) (`s10`) → **Cancel** (nothing written) → the switcher still up → Escape closes it |
| W7 — the ▾ menu | the Bookcase masthead's wing ▾ | the rows Home and variorum carry the shared MARK, "elsewhere" plain (`s11`); Escape |
| W8 — "elsewhere" in the Library | ⌘L → type "else" → Return ("Now in “elsewhere”"); Library, List | "a draft about rivers" / "a draft about doors" WEAR it — popover "read · always", NO why, plain "Revoke" (`s12`, `s13`); "the drafts book" WEARS it; **"every draft" (the gathering) BARE** — R-VX185-1 (`s12`) |
| W9 — the Book Panel | open "a draft about rivers"; open its Book Panel (the book TOC, found from the capture) | both rows of "the drafts book" WEAR it (`s14`) |
| W10 — the Pool | ⌘L → "variorum"; sidebar Pool; masthead "show" (the tucked run) | "the lexer" and "the grammar" WEAR it; **"a private parser note" BARE** (Private — the fence) (`s15`); then ⌘L → Home: the Pool's loose rows WEAR it (`s16`) |
| W11 — the open book | ⌘L → "elsewhere"; ⌥⌘, → Settings ▸ MCP ▸ Shared with AI ▸ the Open book ON (`s17`); back to the Library | **"every draft" now WEARS it**, its popover "read · always" · "through the open book" · "The open book is switched in Settings ▸ MCP." (`s18`); ⌘L: "elsewhere" now WEARS it (`s19`); the Open book OFF → "every draft" BARE again (`s20`) |
| W12 — Revoke from a row (held) | "a draft about doors"'s icon → the first client's "Revoke" | the popover re-opened lists one client fewer, with no refresh (`s21`) |

**THE WALK — Terminal (light)** — the voice switched in Settings ▸ General (a synced setting the restore puts
back); the icon's tint is the voice's accent, so the faces again: W2 (List + the popover — `t01`, `t02`), W3 (Cards
— `t03`), W4 (Timeline — `t04`), W6 (⌘L, the bare "elsewhere", the popover — `t05`, `t06`), W8 + W9 ("elsewhere" in
the Library, the Book Panel — `t07`, `t08`), W10 (the Pool — `t09`).

**W13 — VX-272, last (Terminal):** Settings ▸ MCP ▸ Clients ▸ **Deny…** each approved client (each confirm's title
read by accessibility before its Deny is pressed by description) → the Library List, Cards, ⌘L and the Bookcase:
**no icon anywhere** (`t10`, `t11`, `t12`) — the ≥1-approved-client rule, live.

**Cleanup (C1–C6):**
- **C1:** quit the dev instance by identity; `pgrep` empty.
- **C2:** `Tools/ScaleFixture/restore.sh "<S4's scale-prestage dir>"` → "Restored (verified)" (it removes the
  fixture-era WAL first, copies back, `cmp`s every file); then each restored file `cmp`ed against S2's own prestage
  copy too — every one SAME. This puts back the fixture, the grants, the denials, the open-book flips, the voice and
  every act.
- **C3 — prefs:** `defaults import io.lduarte.Variorum.debug <scratch>/prefs-before.plist`, a fresh export diffed
  against it — **identical** (the walk moves the window frames, `wing.current`, the backup log, `IdleCommitSweepMark`;
  the appearance pref goes back with it).
- **C4 — clipboard:** `pbcopy < clip-before.txt`, then `pbpaste | cmp - clip-before.txt` — SAME. (This walk copies
  nothing; the save is insurance.)
- **C5 — POSTURE AS LEFT:** the dev store's files `cmp`-SAME with the prestage, so it is exactly as S5 saw it —
  **Standard, unlocked**, Study. No relaunch to "check" (a launch writes a WAL and a backup — it would un-SAME what
  was just verified). Her clipboard and the Debug prefs restored. No Variorum instance left.
- **C6:** the claim RELEASED at once; the record's U2 rows flipped with the counts, the captures listed, the one-line
  result for the coordinator.

## The ladder

*(round records and every finding's disposition land here before the next round spawns)*

### ROUND 1 — Opus cold review at max (fresh `opus-reviewer`, REVIEW_PROMPT verbatim, PHASE=VX-281), 2026-10-14 ~00:20

**Diff reviewed:** `a9ebe0a4..0e907a24`. **Tally: 1 BLOCKER · 0 MAJOR · 5 MINOR · 3 NIT.** The reviewer's findings, verbatim
(its clean bill follows them). Dispositions land in the table under them BEFORE round 2 spawns.

**R1-1 [BLOCKER] · `App/Variorum/Variorum/Features/Timeline/TimelineView.swift:206` (also `:78`, `:99–124`)**
- **What's wrong:** the Timeline's shared-icon hold watches reach for every row she has loaded, not the rows on screen. The set grows with each Load More press, and the whole batch re-runs on every `container` write while any client can reach anything.
- **How it happens:** the `.task(id: model.items.map(\.postID)) { await model.holdReach(model.items.map(\.postID)) }` call hands the hold all of `items`. `loadMore()` adds 50 rows per press; in the stamp lenses those rows come from every wing (walk W4); in `.library` it re-reads a growing top-N (`limit = items.count + pageSize`, `:104`). If any approved client holds a live grant, or the open book is on, `mcpReachStandings` (`MCPShareQueries.swift:400`) lets `mcpNoteReaches` read `mcpNoteFacts`, which reads `container`. `container` is rewritten as a whole row on every autosave (`registerTextChange`, `Operations+Variant.swift:626`), and by every MCP write and sync apply. `AppDatabase.observe` tracks whole tables (`:239–249`), so each such write re-runs one batch over every loaded row while the Timeline is mounted (list surfaces mount whole in a split pane beside an editor, `RootView.paneDetail`). After k presses, each write costs the facts of 50(k+1) notes plus one rule read per note per approved client — set by how far she paged, up to every note.
- **What it breaks:** the unit's acceptance line "P1: reach is read in proportion to the rows shown" (kickoff plan `:135`, record `:113`); the house rule at `AppDatabase.swift:243–247` ("A held observation's fetch must itself be viewport-shaped … Observing an unbounded projection is a P1 violation waiting for a keystroke"); the record's own claims "every read is sized to what its host shows" (`:711`) and "one bounded batch per autosave" (`:717`), which its risk 3 (`:721`) contradicts. Every other new note hold is bounded (Library ≤ 3 × 80, Pool ≤ 200 + the windowed tucked run, Book Panel ≤ 300).
- **Pin (red on the tip):** make the id choice a seam, e.g. `TimelineViewModel.reachIDs`, the view's `.task(id:)` reading it; on the tip it answers `items.map(\.postID)`. Load ≥ 6 pages over a store of ≥ 300 notes; assert `reachIDs.count` stays under a fixed bound (the visible window ± a page) however many pages are loaded.
- **Fix:** hold reach over a window of the visible rows — rows report appear/disappear, the Library's pure `window(visible:count:)` decides the window, the hold re-aims only when the window crosses a page; rows outside keep their last answer, as the Library's do.

**R1-2 [MINOR] · `App/Variorum/Variorum/Core/Views/WingSwitcherSheet.swift:239–240` (also `:228`, `:304`)**
- Escape to dismiss a row's reach popover closes the whole ⌘L switcher. This run adds the first popover inside the sheet (`MCPSharedIcon` at `:304`); the sheet's `WingSwitcherKeyCatcher` acts on every Escape whose `event.window` is the sheet's window and calls `close()`; the popover holds only plain buttons and the switcher's field keeps focus (`.task { fieldFocused = true }`, `:228`), so the popover doesn't become key and her Escape reaches the sheet — the switcher closes, the popover with it, her typed filter lost (U4-6b only passes keys through for a nested sheet, its own key window). The record's walk saw exactly this ("A popover's Escape closed the ⌘L switcher with it", `:634`) and filed it as a driving slip; the key-window step is inferred.
- **Pin:** a pure seam for the sheet's Escape decision with a row popover up (dismiss the popover, keep the switcher) — red on the tip. **Fix:** tell the sheet when a row popover is presented (an optional `isPresented` binding on `MCPSharedIcon`, or a preference) and have `.escape` dismiss the popover first; or let the popover's content take key so its own Escape closes it.

**R1-3 [MINOR] · `App/Variorum/Variorum/Features/MCP/MCPDoor.swift:512–524` (also `:210`, `MCPSetupMenu.swift:48–51`)**
- VX-232's "the receipt always names the shown client" (record `:214`) fails if she switches client while a copy is in flight: `copySetupCommand(for:)` sets `setupClient = client` (`:513`) before `await runner.run { mintMCPSetupKey }` (`:520`); a `chooseSetupClient` (`:210`) during the mint (writer busy with a sync round, an import, an MCP batch) chooses the new client and clears the receipt; the copy then lands the old client's text on the clipboard and the old client's receipt (`:524`) — the menu shows the new client under the old receipt, and the ✓ flashes (`MCPSetupMenu.swift:51` compares against `copying.copiedReceipt`).
- **Pin (red on the tip):** `let copy = Task { await door.copySetupCommand(for: .anyClient, to: pb) }` · yield until suspended at its write · `door.chooseSetupClient(.claudeCode)` · `await copy.value` · `#expect(door.note == nil || door.note?.text == door.setupClient.copiedReceipt)`.
- **Fix:** after the await, land the receipt only if `setupClient == client` (else nothing or a neutral "Copied."); gate the ✓ the same way. **Related nit:** the default argument `for client: MCPSetupClient = .claudeCode` now quietly switches the menu for any caller relying on it — drop the default or default to `setupClient`.

**R1-4 [MINOR] · `App/Variorum/Variorum/Features/MCP/MCPPane.swift:71–73` (also `AppSettingsView.swift:337–338`, `SettingsShape.swift:316–320`)**
- A Settings search for the setup's own words no longer lands on the setup: the setup words ("setup", "connect", "codex", "json", "stdio", "claude code") are keywords on the `mcpServer` catalog row (13n-c U5: "so the search finds the pane by those words too"); that finding's lead is `enableTitle`, for which `MCPPaneTab.holding` answers nil, so `onOpen` leaves `paneTab` alone and the pane opens by its normal rule — on Clients once any client is approved. With Claude Code approved, searching "codex" to add a second client lands on Clients with the Codex setup behind the Connect tab — re-opening through the search the problem R-VX184-6 fixed. Where setup words should land is not ruled; if Connect isn't taken as obvious, a QUESTIONS entry.
- **Pin (pure, red on the tip):** the MCP finding from `SettingsSearch.findings(matching: "codex", in: SettingsSearch.settingsEntries)` lands on `.connect`. **Fix:** an `mcpConnect` catalog row ("Connect a client") carrying the setup words, rendering on Connect, `holding` answering `.connect` (SettingsShape's MCP rows only).

**R1-5 [MINOR] · record U2 self-assessment (`:695–697`) against the U2 walk (`:616–631`)**
- "every place … now wears the ONE icon with its hover and popover" has no proof for four hosts: the walk opened the popover only from the Library's List rows and ⌘L's rows; Cards (W3), Timeline (W4), Book Panel (W9) and Pool (W10) captured the icon only; no Mac pin presses the icon there; two hosts nest the icon's button inside a row-wide `Button(.plain)` — the Timeline inside a `List` (`TimelineView.swift:177–183`) and the Book Panel row (`BookPanelView.swift:272–293`) — and U3's synthetic probe proved the inner click only for the Bookcase row. Speculative as a defect (a click could open the note instead of the popover); certain as an evidence gap.
- **Fix:** one icon click per host in a walk, both voices, or a synthetic-click mount pin in U3's shape.

**R1-6 [MINOR] · `Sources/VariorumCore/Queries/MCPShareQueries.swift:270–284` against `:400–408`**
- The reach gate exists twice: the Bookcase's `mcpBookReaches(_ db:)` keeps its own gate (approved clients, open book, any live grant) while `mcpReachStandings` holds the same logic for every row read; the record's design (`:550–551`, "nil = every live reading, the Bookcase's call byte-unchanged") describes one function with an optional id list, two shipped. A future gate change (e.g. P-VX281-U2-3's option (b)) must be made twice or the Bookcase and the Library's book rows disagree. Cleanliness only; no pin could be red on old.
- **Fix:** build the Bookcase's map on `mcpReachStandings` + the shared `reaches(…)`, or one function taking `readingIDs: [String]?`.

**R1-7 [NIT] · `MCPShareQueries.swift:331–343`** — `MCPReachPlace.wingReach` is a pure rule living in `Queries`; its two twins live in `Domain/MCPGrantRule.swift` with pure grid pins; CLAUDE.md puts pure rules in Domain. The record left `MCPGrantRule` untouched on purpose (another run's lane). **Fix:** move it beside its twins with a pure pin once that lane allows.

**R1-8 [NIT] · `MCPPaneCopy.swift:1028–1033` against `:539`, `:636–637`** — each client's one-line summary is its copy receipt minus "Copied. "; after a copy the Connect tab shows the same next step twice on adjacent lines, one sentence in two constants. **Fix:** onto FOR VX-234 beside U1-6; derive one constant from the other.

**R1-9 [NIT · SPECULATIVE] · `Core/Views/MCPSharedIcon.swift:59`, `:75`** — the empty state now lives inside the icon; in hosts that don't guard it (Cards, Pool, Timeline, Book Panel, ⌘L) the view and its `@State shown` survive the reach emptying. If reach empties while the popover is up without `close()` running (an AI act spends a once grant, moves the note to another wing, removes it from the granting book), the button and popover vanish with `shown` still true; if SwiftUI doesn't write `false` back, the popover would present itself when reach returns — breaking never-present-yourself (R-13nb-23/26g). Before VX-268 both hosts guarded the whole view. Unconfirmed; a mount pin (reach set, emptied, restored with `shown` set) would settle it. **Defensive fix:** `.onChange(of: reaches.isEmpty) { _, empty in if empty { shown = false } }`.

**The reviewer's clean bill (condensed):** not Fable's round (no `Sync/`, `Server/`, `Persistence/`, custody, editor
seam, `Sources/VariorumMCP`, `MCPGrantRule`, `SettingsShape` or `TutorialSeeder` lines; no default changes
meaning) · one rule per kind (notes/books off `decide`, gatherings off `decideGathering`, wings off `decideWing`;
probes spend no once grant; single and batched reads share `placeReach`; re-ran `MCPRowReachTests|MCPGatheringReach|MCPShareTests`
30/4 green) · VX-272 holds (`mcpReachStandings` stops at the client/switch/grant tables, SQL-trace pinned; book and
wing reads never touch `container`) · icons update at once (every decided fact is inside the held fetch's tables) ·
the Library/Pool/Book Panel holds bounded, cancelled cleanly, equality-guarded · an empty icon draws nothing, List
baselines kept · P-1 declared ⇔ rendered on the five hosts · VX-232's mechanism traced and red on old · VX-205 one
declared act, O-4 sweep covers the new file · R-VX184-6 layout, the opening rule pure and pinned, ⌥⌘,'s landing,
the open-book search landing · no rendered "every change" left · VX-245's sites and the new pickers state
`.lineLimit(1)` · no trailers, no rewrites · no plan-time review foci; the implementer's review maps (U1 OWED 6,
U2 OWED 1) all answered.

**Round 1 dispositions** *(same-model: the implementer agrees/disputes; the orchestrator arbitrates against the spec)*

| # | Sev | Disposition | What changed (hash) |
|---|---|---|---|
| R1-1 | BLOCKER | **AGREED.** Traced to the line: `TimelineView.swift:206` hands `holdReach` every loaded id; `loadMore` grows `items` 50 per press (keyset lenses) or re-reads a growing top-N (`.library`, `:104`); once any approved client holds a live grant or the open book is on, `mcpReachStandings` lets `mcpNoteReaches` read `mcpNoteFacts` → `container`, which every autosave rewrites, and `AppDatabase.observe` re-runs a held fetch on ANY write to a tracked table (`AppDatabase.swift:238–247` — "a held observation's fetch must itself be viewport-shaped"). So one batch over 50(k+1) notes per autosave while the Timeline is mounted — against U2's own acceptance line (plan `:135`, "P1: reach is read in proportion to the rows shown"). **Fix:** the Library's pure near-window rule moves to the shared home (`Core/Views/NearWindow.swift` — ONE rule, two callers; `LibraryCatalogModel.window(visible:count:)` delegates, its pins untouched); the Timeline's rows report appear/disappear, the window (its own 50-row pages) decides `reachIDs`, the hold re-aims only when the window crosses a page, rows outside keep their last answer (the Library's `landReach` shape). **Pin (red on old):** the seam `TimelineViewModel.reachIDs` (answering every loaded id on the old tree) — a model leg (7 pages over 360 notes, rows appearing deep in the list) and a MOUNTED leg (the real `List` scrolled to its end: the window stays bounded AND the rows on screen hold their reach — so the List's own appear/disappear reports are proven, not assumed). | **FIXED.** pin + seam `506a9853` · fix `df2a00e6` (pins hardened `f66a3f95`). **Red on old** (window R1, `a-red-on-old.log`): both legs RED — the model leg 4 issues (a fresh listing held 350 > 100; rows 280–299 on screen held 350 > 200; the top never left; back at the top 350 > 200), the mounted leg 2 (scrolled to the end, 350 held > 200; the top still held). **Green** on the fixed tree in the 138-suite batch — the mounted leg proves the real `List`'s appear/disappear reports move the window |
| R1-2 | MINOR | **AGREED.** Traced: `WingSwitcherKeyCatcher`'s monitor answers every Esc whose `event.window` is the sheet's window by `close()` (`:239–240`); U2's row popover (`:304`) holds plain buttons and the field keeps focus (`:228`), so the sheet's window stays key and takes the Esc. U2's walk saw exactly this (`:634`, recorded as a driving slip — it was this defect). macOS's own rule (Esc dismisses the topmost transient, never the window under it) and this sheet's own precedent (the nested ask sheet keeps its own Esc, `:111–113`) make it a defect, not a product call. **Fix:** a PURE Escape decision (`WingSwitcherKeys.escape(rowPopoverShown:)` → dismiss the popover · close the switcher) — never window-key behaviour; the sheet knows which row's popover is up through an optional `isPresented` binding on `MCPSharedIcon` (every other host keeps the icon's own state). **Pin (red on old):** the pure decision on its seam + a MOUNTED leg: a row's icon clicked open, the catcher's Esc delivered — on old the switcher's `close` fires. | **FIXED.** pins + seam `32b6a6de` · fix `b2679827` (final). **Red on old** (window R1): the pure pin (1 issue) and the mount leg (3 — the first Esc closed the switcher). **On the fix:** the pure pin GREEN; the mount leg read red at `:438` in window R1's batch — the switcher STAYED (correct) but the test's "gone" check, the popover content's disappear record, never dropped. A follow-up (`06aad3f8`) traced it to the sheet's untracked Binding read and moved the read into the row's rendering, and switched the pin's "gone" check to AppKit's (no visible popover window). **STAGE WINDOW R1b settled it HOLLOW:** with AppKit's check the Escape leg is GREEN on the first-fix tree (`b2679827`'s sheet) — the popover does leave; the red was the probe's. The follow-up's code half is REVERTED (`2daba70a` — `WingSwitcherSheet.swift` back to `f66a3f95`'s bytes); its AppKit check stays in the pin; the probe's `up` doc now says it is reliable for "went up" only. Final: `MCPSharedIconClickTests` 7/7 GREEN on the final sources (R1b) |
| R1-3 | MINOR | **AGREED.** Traced: `copySetupCommand(for:)` sets `setupClient` (`:513`) then suspends in the mint (`:520`); a `chooseSetupClient` in that window changes the menu and clears nothing (the receipt is not yet there); the copy then lands the OLD client's receipt (`:524`) under the NEW client's menu, and the ✓ (`MCPSetupMenu.swift:51` — the same receipt test) flashes. VX-232's invariant (the receipt names the shown client) breaks. **Fix:** the receipt lands only while the shown client is still the copied one; the clipboard still takes the copied client's text (her press completes, so the end state is exactly the ruled sequential order — a copy, then a choice that clears its receipt; nothing invented); the ✓ asks the door the same question (`MCPDoor.copyLanded(for:)`). The default argument is DROPPED (every caller names its client); the two test calls that leaned on it name `.claudeCode`, and "the default is Claude Code's" is re-pinned as a fresh door's `setupClient` (its meaning kept). **Pin (red on old):** the reviewer's, verbatim in shape. | **FIXED.** pin `5d9eba63` · fix `2d3a14b6` (+ the ✓ companion). **Red on old** (2 issues: the Any-client receipt under Claude Code; the ✓'s question answered yes). **Green** on the fixed tree; the companion `theCopyIconsCheckIsTheCopyThatLandedUnderTheShownClient` green |
| R1-4 | MINOR | **AGREED — derived from R-VX184-6, not new behaviour** (the setup LIVES on Connect, so a search for its words lands there). Traced: "codex" matches only `mcpServer` (a keyword, rank 3); its lead `enableTitle` → `MCPPaneTab.holding` nil → `onOpen` leaves `paneTab` → the pane opens by its rule: Clients once a client is approved (or her last pick). **Fix (SettingsShape's MCP rows only):** an `mcpConnect` catalog row whose title IS the Connect section's own words ("Connect a client", now rendered there from the catalog), carrying the setup menu's words moved off `mcpServer` (connect · codex · setup · json · stdio · claude code — the provider names stay on `mcpServer`, O-4's search vocabulary); `holding` → `.connect`; `rowIDsRendered[.mcp]` gains it (two exact-array pins edited, the ritual). Its blurb is new words → FOR VX-234. **Pin (pure, red on old):** "codex", "setup", "json", "stdio", "claude code" each land on `.connect`. | **FIXED.** pin `78f1962b` · fix `fea6b543`. **Red on old** (`holding(findingLead:) == .connect` failed — the setup words landed on no tab). **Green** on the fixed tree; `SettingsShapeTests`' declared⇔rendered pins and the two edited exact-array pins green in the batch |
| R1-5 | MINOR | **AGREED (an evidence gap).** **Fix:** synthetic-click mount pins per host in U3's shape — Cards, Timeline, Book Panel, Pool — through a DEBUG anchor on the icon (its window frame) and a DEBUG popover-shown record: a click on the icon presents the popover and never fires the row's open (the card's tap, the Timeline row's `Button` inside its `List`, the Book Panel row's `Button`, the Pool card's tap). A red there is a DEFECT and is fixed red-first. | **EVIDENCE GAP CLOSED — no defect.** pins + harness `5a5fbeb4` (hardened `f66a3f95`). All four host clicks — Cards, the Timeline (a row `Button` inside its `List`), the Book Panel (a row `Button`), the Pool (a tap-to-open card) — GREEN on BOTH trees: the click presents the popover and never fires the row's open |
| R1-6 | MINOR | **AGREED (cleanliness — no red-on-old possible).** Traced: the Bookcase's `mcpBookReaches(_ db:)` (`:270–284`) repeats `mcpReachStandings` (`:400–408`) line for line, so a gate change (e.g. P-VX281-U2-3(b)) would have to be made twice. **Fix:** ONE function, `mcpBookReaches(_:readingIDs: [String]? = nil)` (nil = every live reading — the record's own design text, `:550–551`), on `mcpReachStandings` + the shared `reaches(…)`; answers byte-identical (the Bookcase-agreement pins hold). | **FIXED (cleanliness).** `e2267b24` — headless 30/4 GREEN; on the Mac the Bookcase / Library / gathering-icon suites green in the 138-suite batch |
| R1-7 | NIT | **AGREED.** A pure rule outside Domain is a CLAUDE.md deviation. **Fix:** `wingReach` moves beside its twins as `MCPGrantRule.reach(grants:openBook:wing:)` in a NEW Domain file (`Domain/MCPGrantRule+Wing.swift`) — `MCPGrantRule.swift` itself untouched (VX-246's lane) — with a pure grid pin (every rung × wing grant / other wing / note grant / revoked / open book agrees with `decideWing`); `MCPReachPlace.wing` reads it. | **FIXED (cleanliness).** `d0ec20e3` — new `Domain/MCPGrantRule+Wing.swift` + pure `MCPWingReachRuleTests` (2 tests, a 60-case grid); headless 49/7 GREEN; the wing suites green in the batch |
| R1-8 | NIT | **AGREED.** Traced: each `copiedReceipt` is its client's `summary` with "Copied. " in front — one sentence in two constants, and after a copy the Connect tab says the next step twice on adjacent lines. **Fix:** each receipt DERIVES from its summary ("Copied. " + summary — byte-identical strings, every pin unchanged); the twice-said next step goes on FOR VX-234 (U1-12, hers to word). | **FIXED (cleanliness).** `a8851322` — byte-identical strings; O-4 sweep 2/2 GREEN headless; every receipt pin green in the batch; FOR VX-234 rows R1-4w · R1-8w |
| R1-9 | NIT | **AGREED TO TEST — the pin decides** (orchestrator's rule). A mounted leg: reach set → the icon clicked → the popover up → reach emptied → reach restored. Red on old (the popover presents itself again) ⇒ fixed (`.onDisappear` on the icon's button resets `shown` — the reviewer's `.onChange` cannot live on an icon whose calm state draws no view); green on old ⇒ **HOLLOW**, not fixed. | **DISMISSED AS HOLLOW.** pin `6b784fa5` GREEN on the old tree (window R1): her press presented the popover once; the reach emptied and returned; it never presented itself again — SwiftUI writes the state back itself. Not fixed; the held patch discarded (never committed) |

### ROUND 1 — THE FIX PASS (a fresh opus-implementer, `claude-opus-5-5`, 2026-10-14; HEAD at start `52977935`)

**No revert is in flight.** The R1-9 fix is held as a PATCH (never applied to the branch) until its red run decides.

**What this pass did NOT do (said first):** nothing Mac-side is RUN yet — every Mac red/green claim above is PENDING STAGE WINDOW R1; R1-6/R1-7/R1-8 are verified headless only (their Mac suites ride the window's batch); no walk (the orchestrator's call for R1-5: mount pins in U3's shape, not a walk).

**Pieces (one finding per commit, pins + seams first, then the fixes):**

| # | Piece | State |
|---|---|---|
| 1 | dispositions written (8 AGREED, R1-9 to its pin, none disputed) | DONE `347af99c` |
| 2 | the pins + the seams carrying the OLD behaviour: R1-1 `506a9853` · R1-5 `5a5fbeb4` · R1-9 `6b784fa5` · R1-2 `32b6a6de` · R1-3 `5d9eba63` · R1-4 `78f1962b` | DONE; the RED-ON-OLD tree built from `78f1962b` → `DerivedData/vx281-r1-old` (`** TEST BUILD SUCCEEDED **`, no warning in a touched file — `logs/build-old.log`) |
| 3 | the fixes: R1-1 `df2a00e6` · R1-2 `b2679827` · R1-3 `2d3a14b6` · R1-4 `fea6b543` · R1-6 `e2267b24` · R1-7 `d0ec20e3` · R1-8 `a8851322` | DONE; the FIXED tree built from `a8851322` → `DerivedData/vx281-r1-new` (`** TEST BUILD SUCCEEDED **`, the only warnings in touched files are two pre-existing lines, shifted — `logs/build-new.log`) |
| 4 | R1-9's fix as a patch on `a8851322` → `DerivedData/vx281-r1-n9` (built, then the patch reverted; the tree clean) | DONE (`logs/build-n9.log`, `** TEST BUILD SUCCEEDED **`) |
| 4b | the pins HARDENED against a host's own `.task` (`f66a3f95` — test files only: the Timeline mount leg loads her pages after the mount settles; the click helper re-reads the icon's frame after a settle) and **all three trees REBUILT**: **old** = `78f1962b`'s sources + `f66a3f95`'s two hardened pin files, built from a temporary detached worktree at `78f1962b` (`<scratchpad>/r1/oldtree` — the old-tree run goes FROM there; removed after the window) → `DerivedData/vx281-r1-old`; **new** = `f66a3f95` → `DerivedData/vx281-r1-new`; **n9** = `f66a3f95` + R1-9's patch → `DerivedData/vx281-r1-n9` (patch reverted, the tree clean). All `** TEST BUILD SUCCEEDED **` | DONE |
| 5 | STAGE WINDOW R1 — red on old, R1-9's call, the batch | **DONE** (claim `vx281-r1fix`, 01:36:39–01:43:28 MDT, handed over from `coord-for-vx281` by the coordinator's exact line; `guard.sh --author` OK before each run, no Variorum instance before or after; released the moment the batch ended). **(a) RED ON OLD** (`a-red-on-old.log`): 21 tests / 3 suites — RED exactly as designed: R1-1 2/2, R1-2 2/2, R1-3, R1-4; GREEN: R1-5's four host clicks, **R1-9 (⇒ HOLLOW)**, U1's nine `MCPPaneTabsTests`. **(b) THE BATCH** on `vx281-r1-new` (R1-9 hollow ⇒ not n9; `b-batch.log`): **914 tests / 138 suites, 3 issues** — VX-115's standing `BookCollectingDoorsTests.theSettingsDoorIsOneActOnBothRoads`; `ChromeLineLimitTests.everyBareFixedSizeStatesItsLinePolicy` with EXACTLY VX-283's six sites (`SearchPicker.swift:503`, `TakesShowFaces.swift:185`, `LibraryBulkRow.swift:93/101/109/113`); and ONE of ours — `MCPSharedIconClickTests.escapeOverARowsPopoverLeavesTheSwitcherUp` at `:438` (the switcher stayed; the popover did not leave — see R1-2's row). Every other test green, every new pin green. VX-167's order-dependent pair NOT met. **A driving slip, said:** the first batch invocation passed the 138 `-only-testing` flags as ONE zsh word (an unquoted `$ARGS` — zsh does not word-split) and ran nothing (`** TEST EXECUTE SUCCEEDED **` with no tests); re-run at once with a proper argument array |
| 6 | the verdicts into the dispositions table; R1-9 recorded HOLLOW (the patch discarded); trees: `vx281-r1-n9` DELETED; `vx281-r1-old` re-aimed as the FIRST-FIX tree for R1b | DONE (this commit) |
| 7 | R1-2's follow-up `06aad3f8` (the row reads `popoverRow` while rendering; the AppKit "gone" oracle) built: **fixed** = `06aad3f8` → `vx281-r1-new` (incremental, `build-new2.log`); **first-fix** = `06aad3f8` with `WingSwitcherSheet.swift` at `f66a3f95` (the temporary worktree, re-aimed) → `vx281-r1-old` (`build-firstfix.log`). Both `** TEST BUILD SUCCEEDED **` | DONE |
| 8 | STAGE WINDOW R1b — the follow-up's red on the first-fix tree + its seven suites | **DONE** (claim `vx281-r1b`, 01:50:43–01:52:07 MDT, handed over from `coord-for-vx281` by the coordinator's exact line; guards OK, no instance before or after; released the moment step 2 ended). **(1)** `MCPSharedIconClickTests` on the FIRST-FIX tree (`c-followup-red.log`): **7/7 GREEN** — the Escape leg passes on AppKit's check, so the follow-up's code change is HOLLOW. **(2)** The seven suites naming the changed types, run on that same tree — whose sources ARE the final HEAD's (the follow-up's test half kept, its code half reverted): **76 tests / 7 suites, ALL GREEN** (`d-followup-green.log`; the skips are the gated capture harnesses) |
| 9 | close: the follow-up's code half reverted (`2daba70a`); the probe's `up` doc corrected (comment only, DEBUG — this commit); the scratch worktree removed (`git worktree remove`); `vx281-r1-old` and `vx281-r1-new` deleted (disk 53 GiB free); **ROUND 1 CLOSED** | DONE |

**Final sources vs. the runs:** HEAD's app and core sources equal `f66a3f95`'s (the tree window R1's 138-suite batch ran — 914 tests, every one green but VX-115's and VX-283's standing reds and the probe-red leg) except `MCPSharedIconClickTests.swift`'s AppKit check and the probe's doc comment; that suite, with every suite naming the switcher and the icon, ran green on the final sources at R1b.

**Self-assessment (round 1's fix pass):**
- Every agreed finding is fixed or closed with its evidence of kind: red-first pins for the four bug-class rows, mount pins for the evidence gap, headless pins for the cleanliness moves, and the hollow one recorded unfixed.
- One trace of mine did NOT hold: R1-2's follow-up mechanism (an untracked Binding read). The red-on-old discipline caught it — green on the first-fix tree — and the code was reverted. The lesson for the reviewer: `MCPSharedIconProbe.up` reports appearances only; "gone" is AppKit's.
- Seams and lanes: zero `Sync/`, custody, editor-seam, schema or MCP-wire lines; `MCPGrantRule.swift` untouched (R1-7's new Domain file sits beside it); `SettingsShape.swift` edits on its MCP rows only.
- Risks I see:
  1. `TimelineView.swift` and `LibraryCatalogPaging.swift` are shared with VX-283's Timeline work — rebase carefully.
  2. R1-4: a search for "client" now lands on Connect (no Clients catalog row exists to land on).
  3. The DEBUG icon probe adds an AppKit anchor view behind every icon in DEBUG builds; Release draws exactly what it drew.


**R1-9's held fix (apply with `git apply` if — and only if — its pin is red on `vx281-r1-old`):**

```diff
--- a/App/Variorum/Variorum/Core/Views/MCPSharedIcon.swift
+++ b/App/Variorum/Variorum/Core/Views/MCPSharedIcon.swift
@@ -102,6 +102,15 @@ struct MCPSharedIcon: View {
                 .sharedIconPopoverProbe(reaches)
             }
             .sharedIconAnchorProbe()
+            // VX-281 ladder R1-9: the calm state is no view, so the icon (and
+            // its `shown`) outlives an empty spell of reach — an AI act that
+            // spends a once grant, moves the note, takes it out of the
+            // granting book. When the button leaves with its popover up, the
+            // popover's state goes with it, so the reach returning never
+            // presents the popover by itself (R-13nb-23/26g: only her press).
+            .onDisappear {
+                if presented.wrappedValue { presented.wrappedValue = false }
+            }
         }
     }
 }
```

**Design notes the reviewer should see:**
- **R1-1:** the window's rule is ONE function now (`NearWindow.pages`, `Core/Views/` — the shared home); the Library's `window(visible:count:)` is a one-line delegate (its `LibraryPagingModelTests` pins untouched). The Timeline uses its own 50-row pages. VX-283 (VX-19, the Timeline) shares `TimelineView.swift` — a rebase-carefully file.
- **R1-2:** `MCPSharedIcon` gained an optional `isPresented` binding (last memberwise parameter, default nil — every other host unchanged). ⌘L's Home row id is `""`, so the sheet tracks `popoverRow: String?` (an empty string is a row).
- **R1-3:** a mid-copy choice still puts the copied client's setup on the clipboard — the end state of the RULED sequence (a copy, then a choice that clears its receipt); nothing invented. The `.claudeCode` default argument is gone.
- **R1-4:** the catalog gained `mcpConnect` (its title the Connect section's own words, now drawn from the catalog there); the setup words moved off `mcpServer` (connect · codex · setup · json · stdio · claude code; the provider names stay, O-4). A search for "client" now lands on Connect too (the new row's LEAD contains the word and outranks `mcpServer`'s keyword) — the Clients tab has no catalog row of its own, so there is no better landing to choose; said here for the reviewer.
- **R1-5's harness** is DEBUG-only (`MCPSharedIconProbe`: an AppKit anchor behind the icon's button with `hitTest → nil`, and a popover appear/disappear record keyed by the first client's name); Release draws exactly what it drew.

### STAGE WINDOW R1 — the plan (runs ONLY under the claim the orchestrator relays — expected `vx281-r1fix`, ~35 min)

0. **Guards, every time:** `Tools/WalkKit/guard.sh --author` (her `/Applications/Variorum.app` absent — if present, STOP and report); `pgrep -fl 'Variorum.app/Contents/MacOS'` empty; the claim held. No Debug launch, no dev-store touch (every suite here runs on in-memory stores).
1. **RED ON OLD** (`DerivedData/vx281-r1-old` — the seams + pins, run FROM the temporary worktree's `App/Variorum`, the project it was built from): `xcodebuild test-without-building -scheme Variorum -destination 'platform=macOS' -derivedDataPath <home>/dev/variorum-vx-281/DerivedData/vx281-r1-old -only-testing:VariorumTests/TimelineReachWindowTests -only-testing:VariorumTests/MCPSharedIconClickTests -only-testing:VariorumTests/MCPPaneTabsTests` → log `logs/a-red-on-old.log`. **Expected:** TimelineReachWindowTests 2/2 RED (R1-1); MCPSharedIconClickTests — the Esc pure pin and the Esc mount pin RED (R1-2), the four host clicks GREEN (R1-5 — a red is a defect), the R1-9 pin RED or GREEN (it decides); MCPPaneTabsTests — `aChoiceMadeWhileACopyIsInFlightNeverLandsTheOldClientsReceipt` RED (R1-3), `aSearchForTheSetupsWordsLandsOnConnect` RED (R1-4), U1's nine GREEN.
2. **R1-9's call:** red ⇒ the batch runs on `vx281-r1-n9`; green ⇒ HOLLOW, the batch runs on `vx281-r1-new`.
3. **THE BATCH** (the chosen fixed tree): `test-without-building … -only-testing:VariorumTests/<Suite>` for the **138 suites** in `notes/plans/vx281-screens/r1/batch-suites.txt` (gitignored, on this machine — every test file naming a changed type: the icon and its probe, `NearWindow`, the switcher, the Book Panel, the Timeline, the Library model/view, `MCPDoor`/the pane/the setup menu/the copy, the Settings catalog/search/view, the three reach reads, and the icon's hosts — plus `ChromeLineLimitTests` and `NoLiteralColourTests`, which sweep every source) → log `logs/b-batch.log`. **Standing reds, not ours (named if met):** VX-115's `BookCollectingDoorsTests.theSettingsDoorIsOneActOnBothRoads`; VX-167's order-dependent `LibraryInfiniteScrollTests` pair; `ChromeLineLimitTests`' six VX-283 sites.
4. Release the claim at once; then the record — the verdicts per finding (red-on-old proven, green on fixed), R1-9's commit or HOLLOW, the counts.

### STAGE WINDOW R1b — the plan (expected claim `vx281-r1b`, ~10 min)

0. **Guards:** `Tools/WalkKit/guard.sh --author`; `pgrep -fl 'Variorum.app/Contents/MacOS'` empty; the claim held. No launch, no dev store.
1. **The follow-up's red on the FIRST fix** — from the temporary worktree's `App/Variorum` (`<scratchpad>/r1/oldtree`, now `06aad3f8` with `WingSwitcherSheet.swift` at `f66a3f95`): `xcodebuild test-without-building -scheme Variorum -destination 'platform=macOS' -derivedDataPath <home>/dev/variorum-vx-281/DerivedData/vx281-r1-old -only-testing:VariorumTests/MCPSharedIconClickTests` → `logs/c-followup-red.log`. Expected: ONLY `escapeOverARowsPopoverLeavesTheSwitcherUp` RED on the AppKit oracle (the popover window still visible) — the mechanism confirmed. If it is GREEN there, the R1 red was the probe's: the follow-up's code change is HOLLOW and is reverted (`git revert` of its source lines, the oracle kept).
2. **The fixed tree** (`vx281-r1-new`, `06aad3f8`): the seven suites naming the changed types — `CapabilityRegistryTests`, `MCPAsksWaitCaptureTests`, `MCPShareFacesCaptureTests`, `MCPShareFacesTests`, `MCPSharedIconClickTests`, `MCPSharedRowsRulesTests`, `WingSwitcherChordTests` → `logs/d-followup-green.log`. Expected all green (the capture harnesses skip without their env var).
3. Release at once; record; remove the worktree (`git worktree remove`) and delete both r1 trees.

### ROUND 2 — Opus cold review at max (a FRESH `opus-reviewer`, REVIEW_PROMPT verbatim, PHASE=VX-281), 2026-10-14 ~02:30

**Tip reviewed:** `65332645` (the diff `a9ebe0a4..HEAD` whole; round 1's fixes `0e907a24..HEAD` line by line against
R1-1…R1-9). **Tally: 0 BLOCKER · 0 MAJOR · 1 MINOR · 4 NIT** — no new BLOCKER/MAJOR, so the ladder owes no round 3 on
its own account; the end-of-run Fable round (her redirect) follows these fixes as the run's final round. The
reviewer's findings, condensed faithfully:

**R2-1 [MINOR] · `Features/Library/LibraryCatalogView.swift:279–280` (lifecycle), `:205–219` (the mode switch) ·
`LibraryCatalogPaging.swift:180–211` · `LibraryCatalogModel.swift:605–609`, `:689`**
- In Timeline mode the Library keeps a reach hold over rows it does not draw. `LibraryCatalogView` stays mounted
  in Timeline mode (its body swaps its content to `TimelineView`), so `.onAppear { holdNearFacts() }` /
  `.onDisappear { stopHoldingFacts() }` never end the hold; `search()` → `read()` loads `noteHits` whatever the
  mode and re-arms `holdNearFacts()` after every read (`:689`); `holdNearFacts()` starts `reachHold` over up to
  4 × 80 notes with no mode check. With live reach, `mcpNoteFacts` reads `container`, rewritten per autosave
  (`Operations+Variant.swift:626`) — so the Library in Timeline mode in a split pane beside an editor runs TWO
  note-reach batches per autosave, one of them (≤ 320 notes) drawn nowhere.
- Breaks U2's acceptance line ("reach is read in proportion to the rows shown", plan `:135`, record `:120`),
  `AppDatabase.observe`'s rule ("UI layers hold observations for on-screen projections only (P3)", `:248`), and
  the record's own claim (`:725`). Before this run the same lifecycle held only `ownershipFacts` (never woken by
  an autosave). Bounded, hence MINOR — R1-1's own scenario, which R1-1's pins (TimelineView mounted alone) could
  not see.
- **Pin (red on the tip):** an approved client, the open book on, > 80 notes; `await model.search();
  model.holdNearFacts()`; List mode → `#expect(model.reachHold != nil)`; switch to `.timeline` (the fix's mode road,
  or mount `LibraryCatalogView` and switch its picker) → `#expect(model.reachHold == nil)`.
- **Fix:** make the near-window reach hold mode-aware — hold only where note rows are drawn (List, Cards, the
  answer sheet); re-aim on a mode change through the existing `.onChange(of: model.mode)` / `.task(id:)`
  (entering Timeline cancels, leaving re-holds). The ownership hold may follow the same gate; the listed-books
  hold (`:272`) outlives its rows too but never wakes at autosave rate (optional).

**R2-2 [NIT · SPECULATIVE] · `Core/Views/WingSwitcherSheet.swift:196`, `:262`, `:300–302`, `:330–340` ·
`Core/Views/MCPSharedIcon.swift:83–105` · `VariorumTests/MCPSharedIconClickTests.swift:365–386`**
- R1-2 hoisted the row popover's state into `popoverRow`; one road out is unpinned: her typed filter removing the
  row whose popover is up (the field keeps focus, so she can type). `ForEach(model.brain.visible)` drops the row
  and its presenting icon; if SwiftUI doesn't write `false` back through the binding on that teardown,
  `popoverRow` stays set → the next Esc is `.dismissRowPopover` and visibly does nothing, and clearing the filter
  brings the row back with `isPresented` already true. R1-9's road (reach emptied while the popover is up) turns
  on the same unknown, and R1-9's HOLLOW pin counts presentations only (`presentations(of:) == 1`, `:384`) — it
  cannot tell "SwiftUI wrote false back" from "`shown` stayed true and SwiftUI doesn't present on re-insertion"
  (the second leaves a dead first click). STAGE WINDOW R1b already found SwiftUI doesn't report a dismissed
  popover's content leaving, so write-back on teardown is not a safe assumption.
- **Pin (decides it either way):** (a) extend R1-9's pin — after the reach returns, ONE click must present
  (`presentations == 2`); (b) in `escapeOverARowsPopoverLeavesTheSwitcherUp`'s rig: click Home's icon open,
  `type("zzz")`, settle, `catcher.onKey?(.escape)` → `closes.count == 1`, `type("")` → no visible popover window.
  Green → hollow; red → fix: clear `popoverRow` when the presenter leaves (e.g. `.onChange(of: model.brain.query)`),
  or decide Esc from `popoverRow` only while that row is visible and reached; for the icon's own `shown`, R1-9's
  held `.onDisappear` patch.

**R2-3 [NIT] · `Features/Settings/SettingsShape.swift:318–331`, `:435–444` · `MCPPaneTabsTests.swift:231–245`**
- R1-4's landing depends on rank ties and catalog order. **"claude"** (her client's name, the setup's first word):
  `mcpServer` matches keyword "claude", `mcpConnect` keyword "claude code", both rank 3; ties break by catalog
  order with `mcpServer` first → the lead is "Enable the MCP server", `holding` nil, the pane opens on Clients once
  a client is approved; R1-4's pin omits "claude". **"client":** "Connect a client" contains it (rank 2),
  outranking `mcpServer`/`mcpWaiting` (rank 3) → lands on Connect while the clients are listed on Clients (the
  implementer's risk 2). Both rows still appear (ranking, not a lost road); which tab each word opens is a
  product call no ruling makes.
- **Fix:** add "claude" to the pin; list `mcpConnect` before `mcpServer` so ties go to Connect (or record
  "claude"'s landing as hers); for "client", a Clients catalog row with `holding → .clients`, or a PROVISIONAL /
  FOR VX-234 line.

**R2-4 [NIT] · `Core/Views/MCPSharedIcon.swift:123–155`** — the DEBUG probe's statics grow without bound in every
DEBUG build (`makeNSView` appends an `Anchor` per icon mount incl. recycled List rows; `presented` appends per
presentation; only `frames(in:)` prunes, only in the click pins). **Fix:** prune dead anchors on append (or
`NSHashTable.weakObjects()`), clear `presented` per pin; optionally move the ~80-line harness to its own file.

**R2-5 [NIT] · leftovers from round 1's moves** — `MCPSetupMenuTests.swift:88` + `MCPPaneCopy.swift:539–542`: after
R1-8 `MCPPaneCopy.copiedReceipt` is a test-only alias of `MCPSetupClient.claudeCode.copiedReceipt` and the pin
compares a value with itself (fix: point the pins at the client's receipt, drop the alias).
`MCPSharedRowsTests.swift:12–16`, `:238`: after R1-1 the header and `theTimelinesLoadedRowsHoldTheirReach` still
describe the Timeline holding "its loaded rows" (fix: re-word to the window).

**The reviewer's clean bill (condensed):** not Fable's mandatory scope (no `Sync/`, `Server/`, `Persistence/`,
custody, editor seam, schema, `Sources/VariorumMCP`, `MCPGrantRule.swift`, `TutorialSeeder`; no default changes
meaning; `SettingsShape` edits on the MCP rows only) · R1-1…R1-9 re-checked sound (R1-1's window bounded to 4
pages with stale-window guards; R1-2's final sheet byte-equal to `f66a3f95`; R1-3's guard + `copyLanded`; R1-4's
row and ritual; R1-5's four clicks; R1-6's one gate with the Bookcase unchanged; R1-7's 60-case grid; R1-8
byte-identical; R1-9 never applied) · one rule per kind, batched and singular reads share `placeReach`, probes
spend no once grant, VX-272 SQL-trace pinned · the autosave-rate argument holds for the Book Panel and Pool
(their own listings already read `container`) · U1 matches R-VX184-6 · headless on the tip: VariorumMCPTests
212/41, core 2,790/321, workbook 40/6, reach suites 32/5, O-4 sweep 2/2 · a replica of the P-8 lint leaves exactly
VX-283's six offenders · no literal colour, no trailers, no rewrites · the record's red/green claims match its logs.

**The orchestrator's rulings on R2-3 (her overnight mandate — "rule provisionally in my absence"):**
- **"claude" lands on Connect — DERIVED, not provisional.** It is a setup word of exactly R1-4's class (her
  client's name heads the Claude Code setup line), so R1-4's rule covers it: list `mcpConnect` before `mcpServer`
  so the tie goes to Connect, and add "claude" to the pin.
- **"client" / "clients" lands on Clients — PROVISIONAL P-VX281-R2-1.** Options: (a) Connect, as built (the row
  "Connect a client" contains the word); (b) **a Clients catalog row whose `holding` answers `.clients`, ordered so
  "client"/"clients" reach it — built**, because the word names her tab and the client list lives there, while
  every setup word still lands on Connect; (c) no landing for the word (the pane's normal opening rule). The new
  row's title/blurb ride FOR VX-234. Hers to reverse.

**Round 2 dispositions** *(same-model: the implementer agrees/disputes; the orchestrator arbitrates against the spec)*

| # | Sev | Disposition | What changed (hash) |
|---|---|---|---|
| R2-1 | MINOR | **AGREED.** Traced to the line. `LibraryCatalogView`'s body swaps its content to `TimelineView` in Timeline mode (`:205–213`) but the view stays MOUNTED, so its `.onAppear { holdNearFacts() }` / `.onDisappear { stopHoldingFacts() }` (`:279–280`) never end the near-window hold. Three roads re-arm it while the Timeline shows: `read()` calls `holdNearFacts()` after every read whatever the mode (`LibraryCatalogModel.swift:689`); the List rows' disappear reports move the window (`applyWindow` → `holdNearFacts`, `LibraryCatalogPaging.swift:167–172`); and `holdNearFacts()` itself has no mode check (`:180`). With live reach, `mcpNoteReaches` reads `mcpNoteFacts` → `container`, which every autosave rewrites, so a hold over up to 4 × 80 notes that NO row draws re-runs per autosave beside the Timeline's own window. That breaks U2's acceptance line (plan `:135`, "reach is read in proportion to the rows shown") and `AppDatabase.observe`'s "UI layers hold observations for on-screen projections only (P3)" (`AppDatabase.swift:248`). Bounded, so MINOR. **Fix:** the near window's held facts follow where note rows are DRAWN. `holdNearFacts()` holds only in a mode that draws them (List, Cards, the answer sheet — a pure `drawsNoteRows(_:)`: never Timeline), and `modeChanged()` — the view's existing `.onChange(of: model.mode)` road — re-aims: entering Timeline ends the holds, leaving re-holds them. The owned-by hold follows the same gate (the reviewer's "may": both observe the same drawn rows under one guard; it never woke at autosave rate, so for it this is tidiness, said here). The listed-books hold stays as it is (never wakes at autosave rate; the reviewer's optional). **Pin (red on the tip):** a model leg (an approved client, the open book on: List holds → Timeline through `modeChanged()` ends both holds → a re-read in Timeline does not re-arm them → Cards re-holds and the reach lands) and a MOUNTED leg (the real `LibraryCatalogView`, its mode written as the picker writes it: the onChange road proven, not mirrored). | **FIXED.** pin `18f25d9a` (+ compile fix `90ec0d3b`) · fix `06f0c9d9`. **Red on old** (window `vx281-r2fix`, `a-red-on-old.log`): the model leg 3 issues (`:214` reach held under the Timeline, `:215` owned-by held, `:219` a re-read re-armed them), the MOUNTED leg 2 (`:253` the real view's mode switch ended nothing, `:256` still held). **Green** on the fixed tree in the 91-suite batch, both legs |
| R2-2 | NIT | **AGREED TO TEST — the pins decide** (the orchestrator's rule). Traced: R1-2 hoisted the row popover's state into the sheet's `@State popoverRow`, which the row's `MCPSharedIcon` reads and writes through a `Binding` (`WingSwitcherSheet.swift:330–340`). Her typed filter drops the row from `ForEach(model.brain.visible)` (`:300–302`) while the field keeps focus; whether SwiftUI calls that binding's `set(false)` as the presenter tears down is UNKNOWN, and STAGE WINDOW R1b already showed SwiftUI does not report a dismissed popover's content leaving. If it does not: the next Esc is `.dismissRowPopover` and visibly does nothing, and clearing the filter brings the row back with its popover's state already true. R1-9's pin counts presentations only (`presentations(of:) == 1`), so it cannot tell "false written back" from "`shown` stuck true, and SwiftUI does not present on re-insertion" (a dead first click). **Pins:** (a) R1-9's pin extended — after the reach returns, ONE click presents (`presentations == 2`); (b) ⌘L — Home's popover open → filter "zzz" (the row leaves) → filter "" (the row is back, and no popover presents itself) → filter "zzz" → Esc closes the switcher (`closes == 1`) → filter "" → no popover. **Red ⇒** the smallest fix the red demands: R1-9's held `.onDisappear` on the icon's button (its state leaves with its presenter; for ⌘L that writes `popoverRow` back through the binding) — built as a PATCH tree, applied only on a red. **Green ⇒** HOLLOW, recorded, unfixed. | **DISMISSED AS HOLLOW.** pins `f137cf20` GREEN on the old tree (window `vx281-r2fix`): (a) her first click after the reach returned presented the popover (`presentations == 2`) — SwiftUI writes the icon's `shown` back; (b) ⌘L — the row filtered away and back came back calm (no self-presentation), and Esc with the row filtered away closed the switcher — SwiftUI writes `false` back through `popoverRow`'s binding as the row tears down. Not fixed; R1-9's `.onDisappear` patch (the built `vx281-r2-n22` tree) discarded, never committed. The pins stay as guards (green in the batch) |
| R2-3 | NIT | **AGREED, as ruled** (the orchestrator's rulings above). Traced: `SettingsSearch.findings` ranks lead == > prefix > contains > keyword > detail and breaks ties by catalog order (`SettingsShape.swift:435–444`). **"claude"** matches `mcpServer`'s keyword "claude" and `mcpConnect`'s "claude code" at rank 3; `mcpServer` comes first → lead "Enable the MCP server" → `holding` nil → the pane opens by its rule (Clients once a client is approved). **"client"**: "Connect a client" contains it (rank 2) → Connect, while the client list lives on Clients; **"clients"** finds no MCP row at all today. **Fix (SettingsShape's MCP rows only):** `mcpConnect` moves AHEAD of `mcpServer`, so a tie goes to the setup — R1-4's rule (DERIVED); a new `mcpClients` row titled the Clients tab's own label (`MCPPaneCopy.clientsSection`, "Clients" — the tab renders it), whose lead outranks "Connect a client" for "client" (prefix, rank 1 vs 2) and IS "clients" (rank 0); `MCPPaneTab.holding` → `.clients`; `rowIDsRendered[.mcp]` gains it (the two exact-array pins edited — the ritual). Its keywords carry no setup word, so every setup word still lands on Connect. **PROVISIONAL P-VX281-R2-1 (b)** (the ruling's own options). Its blurb is new words → FOR VX-234. **Pin (red on old):** "claude" joins the setup words landing on Connect; "client" and "clients" land on Clients; "server" still lands on no tab. | **FIXED.** pins `b52ab180` · fix `1e4a44bc`. **Red on old**: `aSearchForTheSetupsWordsLandsOnConnect` (`:243` — "claude" landed on no tab) and `aSearchForClientsLandsOnTheClientsTab` (`:264` — "client" landed on Connect; `:260` — "clients" found no MCP row). **Green** on the fixed tree in the batch, with `SettingsShapeTests`' declared⇔rendered pins and the two edited exact-array pins. PROVISIONAL P-VX281-R2-1 (b) for QUESTIONS at the merge |
| R2-4 | NIT | **AGREED (cleanliness, DEBUG-only — no pin can be red on old).** Traced: `MCPSharedIconAnchor.makeNSView` appends an `Anchor` per icon mount (`MCPSharedIcon.swift:154` — every recycled List row, every host remount), and `sharedIconPopoverProbe`'s `onAppear` appends a name per presentation (`:179`); only `frames(in:)` prunes, and only the click pins call it, so in a DEBUG app session both grow with use. **Fix:** dead anchors are pruned on append (∝ the icons alive), and the presentations become a COUNT per client name (∝ the distinct names — bounded in a DEBUG app run too, which clearing per pin alone would not give); `presentations(of:)` keeps its meaning, so every pin reads as before. Still DEBUG-only. The optional move to its own file is not taken (the smaller diff). | **FIXED (cleanliness).** `713d3890` — every probe-reading pin (`MCPSharedIconClickTests` 9/9) green in the batch |
| R2-5 | NIT | **AGREED (cleanliness).** (1) After R1-8, `MCPPaneCopy.copiedReceipt` IS `MCPSetupClient.claudeCode.copiedReceipt` (`MCPPaneCopy.swift:539–542`), read only by two tests; `MCPSetupMenuTests.swift:88` compares the value with itself. **Fix:** the alias is dropped, `MCPPaneTests.swift:91` reads the client's own receipt, and the self-comparison goes (the client's receipts stay pinned by the copy pins, `MCPSetupMenuTests.swift:180/186`). (2) `MCPSharedRowsTests.swift:12–16` and `:238` still say the Timeline holds "its loaded rows". **Fix:** re-worded to the window, and the test holds `model.reachIDs` (what the view holds since R1-1), renamed `theTimelinesWindowedRowsHoldTheirReach`. | **FIXED (cleanliness).** `e55440e4` — `MCPSetupMenuTests`, `MCPPaneTests` and the renamed `theTimelinesWindowedRowsHoldTheirReach` green in the batch; the O-4 sweep 2/2 green headless |

### ROUND 2 — THE FIX PASS (a fresh opus-implementer, `claude-opus-5-5`, 2026-10-14; HEAD at start `5e145a46`)

**No revert is in flight.** R2-2's fix (if its pins go red) is held as a PATCH, never applied to the branch until its red run decides.

**What this pass did NOT do (said first):** no walk (none of the five findings is a face; the R2-1 mounted leg proves the real view's road). R2-4/R2-5 are cleanliness with no red-on-old possible — verified by build, by their suites in the batch and (R2-5's O-4 fence) headless. The optional move of the DEBUG probe to its own file (R2-4) was not taken. **ROUND 2 CLOSED** (03:02 MDT): R2-1 and R2-3 FIXED red-first, R2-2 HOLLOW, R2-4 and R2-5 FIXED (cleanliness).

| # | Piece | State |
|---|---|---|
| 1 | dispositions written (R2-1/R2-3/R2-4/R2-5 AGREED, R2-2 to its pins, none disputed) | DONE (this commit) |
| 2 | the pins, red-first: R2-1 · R2-2 (a)+(b) · R2-3 | DONE — R2-1 `18f25d9a` (+ compile fix `90ec0d3b`: the model leg's helper made main-actor isolated) · R2-2 `f137cf20` · R2-3 `b52ab180` |
| 3 | the OLD tree (the tip + the pins) built for testing → `DerivedData/vx281-r2-old` | DONE — built from `90ec0d3b` in `DerivedData/vx281-r2` (`** TEST BUILD SUCCEEDED **`, `logs/build-old.log` under `notes/plans/vx281-screens/r2/`, gitignored), then APFS-cloned to `DerivedData/vx281-r2-old` (the xctestrun's products are `__TESTROOT__`-relative, so the clone runs as built); `vx281-r2` goes on as the incremental NEW tree. The only warnings in a touched file are round 1's own (`MCPSharedIconClickTests.swift:446–447`, the R1-2 pin's nested `popoverGone`) |
| 4 | the fixes: R2-1 · R2-3 · R2-4 · R2-5 (one commit each) | DONE — R2-1 `06f0c9d9` · R2-3 `1e4a44bc` · R2-4 `713d3890` · R2-5 `e55440e4`. Headless: `MCPProviderNeutralityTests` 2/2 GREEN (the O-4 fences after the alias left one); the search's ranking replicated over the five MCP rows in a script — every setup word → Connect, "claude" → Connect, "client"/"clients"/"approve"/"deny" → Clients, "server"/"mcp"/"grant" → the switch, "open book" → the open book ("ai" → Waiting, as before: its lead contains the letters) |
| 5 | the NEW tree built; R2-2's patch tree built (the patch reverted after) | DONE — NEW from `e55440e4` (incremental in the OLD tree's own directory, `build-new.log`) → cloned to `DerivedData/vx281-r2-new`; then R2-2's patch (R1-9's held `.onDisappear`, saved as `notes/plans/vx281-screens/r2/r22-ondisappear.patch`) applied, built (`build-n22.log`) → `DerivedData/vx281-r2-n22`, and the patch REVERTED (the tree clean at `e55440e4`). All `** TEST BUILD SUCCEEDED **`; no new warning in a touched file (the three seen in recompiled files — `LibraryCatalogPaging.swift:218`'s GRDB import-visibility line from 2026-10-05, `LibraryCatalogView.swift:1561`, `AppSettingsView.swift:1236`'s standing `spec(paths:joinAll:)` — are pre-existing lines; `MCPSharedIconClickTests.swift:446–447` are round 1's) |
| 6 | STAGE WINDOW `vx281-r2fix` — red on old, R2-2's call, the batch | **DONE** (claim `vx281-r2fix`, 02:56:37–03:01:42 MDT, handed over from `coord-for-vx281` by the coordinator's exact line; `guard.sh --author` OK before each run, no Variorum instance before or after; released the moment the batch ended, before any recording). **(1) RED ON OLD** (`vx281-r2-old`, `a-red-on-old.log`): 33 tests / 3 suites, **8 issues — exactly the four bug pins**: R2-1's model leg (3) and mounted leg (2), R2-3's two (3); **R2-2's two pins GREEN ⇒ HOLLOW**; every other test green. **(2)** R2-2 hollow ⇒ the patch tree unused, the patch discarded. **(3) THE BATCH** on `vx281-r2-new` (`e55440e4`'s sources, `b-batch.log`): **657 tests / 91 suites, ONE issue — `ChromeLineLimitTests.everyBareFixedSizeStatesItsLinePolicy` with EXACTLY VX-283's six sites** (`SearchPicker.swift:503`, `TakesShowFaces.swift:185`, `LibraryBulkRow.swift:93/101/109/113` — standing, not ours). Every new and edited pin green; VX-167's `LibraryInfiniteScrollTests` pair green this time (not met); VX-115's pin not in this set. Skips read: the gated capture harnesses and the opt-in rigs only. **(4)** the three trees DELETED (disk 46 GiB free) |

**PROVISIONAL built this pass:** **P-VX281-R2-1 (b)** — "client"/"clients" land on the Clients tab through a new `mcpClients` catalog row (the orchestrator's ruling; options (a) Connect as built · (b) a Clients row — BUILT · (c) no landing; recorded under ROUND 2 above). For QUESTIONS at the merge.

**Batch suites (91):** every test file naming a type this pass changed — `LibraryCatalogModel`, `LibraryCatalogView`, `SettingsCatalog`/`SettingsSearch`/`SettingsPane`/`SettingsRow`, `AppSettingsView`, `MCPPane`/`MCPPaneTab`/`MCPPaneCopy`, `MCPSharedIcon`/`MCPSharedIconProbe`/`MCPReachPopover`, `MCPSetupClient` — plus the five changed test files and `ChromeLineLimitTests` + `NoLiteralColourTests` (they sweep every source); derived by script into `notes/plans/vx281-screens/r2/batch-suites.txt` (gitignored, on this machine).

### STAGE WINDOW `vx281-r2fix` — the plan (runs ONLY under the claim the orchestrator relays; ~25 min)

Every run goes through `notes/plans/vx281-screens/r2/run.sh <tree> <log> <suites…|@batch>` (a bash ARRAY of `-only-testing` flags — round 1's zsh word-splitting slip cannot recur), which prints the counts and every failed test.

0. **Guards, every time:** `Tools/WalkKit/guard.sh --author` (her `/Applications/Variorum.app` not RUNNING — running ⇒ STOP and report, never quit it); `pgrep -fl 'Variorum.app/Contents/MacOS'` empty (at request time a VX-246 Debug instance from `~/dev/variorum-vx-246`'s tree was up — another session's, the coordinator's to clear); the claim held. No Debug launch, no dev-store touch (every suite runs on in-memory stores).
1. **RED ON OLD** (`vx281-r2-old`, built from `90ec0d3b` — the tip + the pins): `run.sh vx281-r2-old a-red-on-old MCPSharedRowsTests MCPSharedIconClickTests MCPPaneTabsTests`. **Expected:** R2-1's two pins RED (`theLibrarysNearHoldFollowsTheRowsItDrawsAndNeverHoldsUnderTheTimeline`, `theLibraryViewEndsItsNoteHoldsWhenItShowsTheTimeline`); R2-3's two RED (`aSearchForTheSetupsWordsLandsOnConnect` on "claude", `aSearchForClientsLandsOnTheClientsTab`); R2-2's two DECIDE (`anIconWhoseReachLeavesAndReturnsNeverPresentsItsPopoverByItself`'s (a) leg, `aRowFilteredAwayWithItsPopoverUpLeavesNoPopoverStateBehind`); every other test GREEN.
2. **R2-2's call:** RED ⇒ `run.sh vx281-r2-n22 c-r22-patched MCPSharedIconClickTests` (expected all GREEN), the patch is committed (`git apply notes/plans/vx281-screens/r2/r22-ondisappear.patch`, `R2-2: …`), and the batch runs on `vx281-r2-n22`. GREEN ⇒ **HOLLOW**, the patch discarded, the batch runs on `vx281-r2-new`.
3. **THE BATCH:** `run.sh <tree> b-batch @batch` (the 91 suites). **Standing reds, not ours (named if met):** VX-115's `BookCollectingDoorsTests.theSettingsDoorIsOneActOnBothRoads` (not in this set); VX-167's order-dependent `LibraryInfiniteScrollTests` pair; `ChromeLineLimitTests`' six VX-283 sites.
4. **Release the claim at once**; then the record — the verdicts per finding, the counts; delete the three trees.

### ROUND 3 — THE END-OF-RUN FABLE COLD REVIEW (a fresh `fable-reviewer`, REVIEW_PROMPT verbatim, PHASE=VX-281), 2026-10-14 ~03:30

**Her redirect's Fable round** (no diff line earned an earlier one: the run touches no `Sync/`, custody, editor seam,
schema or default's meaning). **Diff reviewed:** `a9ebe0a4..6ee71aa4` whole, round 2's four un-re-reviewed fixes
line by line against their findings. **Tally: 0 BLOCKER · 0 MAJOR · 0 MINOR · 2 NIT** — "No new round is owed on
this account; neither NIT needs a pin (both are cleanliness — no red-on-old test exists for either)." This is the
run's FINAL round (the ladder's third, the cap): its fixes are read by no later round, so the orchestrator checks
each line by line against its finding (her 2026-10-13 rule). The findings, verbatim:

**F-1 [NIT] · `App/Variorum/Variorum/Features/MCP/MCPSetupMenu.swift:148–154`** · Overlapping ✓ flashes cut the
second one short · `flash()` sets `copied = true` and spawns an unkeyed 1.6 s sleep that sets it `false`; a second
copy inside the window spawns a second sleep, and the FIRST timer's expiry clears the second copy's ✓ after as
little as a frame (press at t=0, again at t=1.5 → the ✓ drops at t=1.6, not t=3.1). Cosmetic, traced, unpinnable
in any non-flaky way · Fix: a generation counter (`flashGeneration += 1; let g = …; after the sleep, if
flashGeneration == g { copied = false }`).

**F-2 [NIT] · `App/Variorum/Variorum/Features/MCP/MCPDoor.swift:520` (`copySetupCommand(for:)`)** · A direct caller
naming a client other than the shown one leaves the OLD client's receipt standing under the NEW menu choice for
the mint's duration · `if setupClient != client { setupClient = client }` changes the menu without clearing a
standing `.connect` receipt (`chooseSetupClient` would); until the awaited mint returns and the end-state guard
lands the new receipt, the pane shows exactly the VX-232 lie, transiently. Unreachable from any shipped face (the
pane's icon always copies the shown client; only tests call with another) — a hazard for a future caller, not a
live bug · Fix: route the change through `chooseSetupClient(client)` (keeps the no-op guard; clears a stale
receipt), end-state guard unchanged.

**Investigated and FALSIFIED by the reviewer (recorded so nobody re-chases it):** a candidate MINOR — the Settings
search landing writing `mcp?.paneTab` (`AppSettingsView.swift:341`) while the MCP pane is already shown, with
`paneTab` `@ObservationIgnored` and read only at `MCPPane.init` (`MCPPane.swift:108`). The mechanism does not
complete: while a query is typed, `detail` swaps `paneBody` for `SettingsResultsPane` (`:331–344`, a different
branch, so `MCPPane`'s identity dies), and `onOpen` sets `query = ""` before `pane = finding.pane`, so the pane
always REMOUNTS through its init and adopts the just-written tab. The read-at-mount design is sound.

**The reviewer's clean bill (condensed):** the lanes — zero `Sync/`, custody/keychain, editor-seam, schema,
`Server/`, `Persistence/`, `Sources/VariorumMCP` lines; `MCPGrantRule.swift` untouched (R1-7's new
`MCPGrantRule+Wing.swift` read-off faithful to `decideWing`); `SettingsShape.swift` edits only the two new MCP rows
+ the keyword move; no default changed meaning · round 2's fixes line by line (R2-1's pure exhaustive
`drawsNoteRows` gating every re-arming road, the mounted pin on the real view, the answer sheet never un-held;
R2-3's ranks verified in code, every landing as ruled, title==label pinned; R2-4 bounded, DEBUG-only, Release
byte-equal; R2-5 no stale references) · round 2's evidence re-verified from its logs (8 issues exactly; R2-2's
pins green, no patch committed; 657/91 with VX-283's six) and `git diff e55440e4..HEAD` excluding notes EMPTY ·
one rule, one gate (`mcpReachStandings` nil before any `container`/`reading` read; shared `placeReach`;
non-consuming probes; re-ran `MCPRowReachTests` + `MCPWingReachRuleTests` 8/8, O-4 2/2) · P1 (every hold sized to
its host; the SQL-trace pins read; the autosave-rate wake bounded and equality-guarded; listed-books and wing
holds never touch `container`) · R1's fixes sound at the tip · U1 against R-VX184-6 / VX-205 / VX-232 (every old
section re-homed — the removals diffed against the tabs; the fit pins measure every line) · faces and
declarations (the calm icon is no view; icon before the ask glyph; the menu's one-mark rule; every host declares
`surfaceCapabilities`) · hygiene (no trailers across 63 commits; no literal colour; sentence case; SyncSpec §5
read tolerance; the PROVISIONALs and FOR VX-234 rows complete; the closeout's OWED correctly deferred to the
merge).

**Round 3 dispositions** *(cross-model, her 2026-10-13 rule: the implementer agrees/disputes; Fable's call is
final; the implementer applies; the orchestrator checks each fix line by line)*

| # | Sev | Disposition | What changed (hash) | Orchestrator's line-by-line check |
|---|---|---|---|---|
| F-1 | NIT | **AGREED.** Traced: the copy icon stays enabled while its ✓ stands (`MCPSetupMenu.swift:116–117`: `Task { if await copy() { flash() } }`), and `flash()` (`:148–154`) sets `copied = true` then spawns an UNKEYED 1.6 s sleep that writes `false`. A second landed copy inside the window starts a second sleep, but the FIRST one's expiry still writes `false` — press at t=0 and t=1.5, the ✓ drops at t=1.6, 0.1 s into the second flash. Cosmetic; no non-flaky pin (wall-clock overlap). **Fix (as proposed):** a generation counter — each flash takes the next generation, and only the latest one's expiry clears the ✓. NOT YET APPLIED — held with F-2's dispute (the brief: a dispute stops the pass) | | |
| F-2 | NIT | **DISPUTED — the mechanism does not complete.** Traced: `MCPDoor` is `@MainActor` (`:29–31`), and in `copySetupCommand(for:)` the menu's change (`:521`) and `clearConnectNote()` (`:526`) run in ONE synchronous main-actor segment — between them only `guard let runner` (a stored property, `:116`; no `await`). The first suspension is the mint's `await runner.run` (`:528`), and by then the old client's `.connect` receipt is ALREADY cleared, so no render — and no reader of the door — can see the new menu choice under the old receipt. The runner-nil branch (`:522–524`) overwrites the note with `setupNeedsLibrary` (client-agnostic) in the same segment. So the "transient VX-232 lie for the mint's duration" never exists, even for the hypothetical direct caller; the end state is already the end-state guard's (`:532`). Routing `:521` through `chooseSetupClient(client)` would be behaviour-identical (its clear is the same `clearConnectNote()`, and `:526` clears again) — a one-road tidiness at most, not a fix. **Back to Fable for the final call:** if Fable still wants the routing as pure cleanliness, I apply exactly the proposed shape. (A deterministic pin exists in R1-3's shape — copy another client in a Task, yield to the mint's suspension, read `door.note` — and would be GREEN on the tip, i.e. HOLLOW; not run, since this pass takes no stage window.) | | |

## Closeout

*(results, finals, the ratify list, the MOBILE PARITY line, the merge)*
