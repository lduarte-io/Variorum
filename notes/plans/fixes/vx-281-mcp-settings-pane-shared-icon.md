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
| U1 — the pane in tabs | **UNIT CLOSED — DONE** (2026-10-13 ~22:35 MDT, opus-implementer): VX-199 · VX-205 · VX-232 (FIXED red-first) · VX-245's two MCP sites (`3d00a166`); red on old 4 issues; Mac batch 250/31 (one issue — VX-283's six lint sites); the walk in both voices DONE, dev store restored `cmp`-SAME. 3 PROVISIONALs (P-VX281-U1-1…3) for QUESTIONS at the merge; the cold review is the ladder's. See the U1 UNIT RECORD |
| U2 — the shared icon | **IN-PROGRESS** (opus-implementer, from 2026-10-13 ~22:30 MDT) — the U2 UNIT RECORD below carries the trace, the site list, the design and the pieces |
| the ladder | NOT-STARTED |
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

*(filled as each host lands — PENDING)*

### LIVE STATUS — U2's pieces (flipped in the same commit as each piece)

| # | Piece | State |
|---|---|---|
| 0 | this record: the trace, the site list, the design | DONE (this commit) |
| 1 | THE SEAM + THE PINS, red-first: the final API with the PRE-FIX BEHAVIOUR behind it (no surface reads reach, no row draws it, the core reads answer nothing) + the core pins + the Mac pins; the core pins RED headless; the seam tree built for testing | IN-PROGRESS — committed (this commit): the seam (`Queries.mcpNoteReaches` / `mcpBookReaches(readingIDs:)` / `mcpWingReaches` answering `[:]`; `LibraryNoteRowExtras.reach` never set, `LibraryCatalogModel.bookReach` + `holdBookReach` empty, `PoolPostsModel` / `BookPanelModel` / `TimelineViewModel` `.reach` + `holdReach` empty, `BookPanelModel.entryIDs(for:)`, `WingsModel.reach` + `watchSharing` empty; `CatalogNoteLine` / `CatalogBookLine` take `reach:` and draw nothing) + **core `MCPRowReachTests` 6 tests — RED on the seam headless: 6/6 failed, 43 issues** (`swift test --filter MCPRowReachTests`, log `vx281-screens/u2/logs/core-pins-seam.log`; every positive leg; the guards — VX-272's empty map, no `container` read — green by nature, each paired with a red control) + Mac `MCPSharedRowsTests` 10 tests (the hosts' holds, the open book, VX-272, the two List lines' faces on the title's baseline). REMAINS: build the seam tree for testing (`DerivedData/vx281-u2-old`); its Mac red run is STAGE WINDOW 1's |
| 2 | THE FIX: the core reads; the icon's calm state; the hosts' held reads and faces; the declarations and their ritual pins | NOT-STARTED |
| 3 | headless finals + the fixed tree built for testing | NOT-STARTED |
| 4 | STAGE WINDOW 1 — red on the seam tree, the Mac batch on the fixed tree | NOT-STARTED |
| 5 | STAGE WINDOW 2 — the walk | NOT-STARTED |
| 6 | close: self-assessment, PROVISIONALs, OWED | NOT-STARTED |

## The ladder

*(round records and every finding's disposition land here before the next round spawns)*

## Closeout

*(results, finals, the ratify list, the MOBILE PARITY line, the merge)*
