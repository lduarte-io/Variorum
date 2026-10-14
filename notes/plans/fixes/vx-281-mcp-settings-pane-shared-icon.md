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
| U1 — the pane in tabs | IN-PROGRESS (opus-implementer) — the U1 UNIT RECORD below holds the design, traces and pieces |
| U2 — the shared icon | NOT-STARTED |
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

## Unit records

*(each unit writes its own section here: pieces with hashes, traces, pins with red-on-old proof, PROVISIONALs,
the walk, OWED)*

## U1 UNIT RECORD — the pane in tabs: VX-199 · VX-205 · VX-232 · VX-245's two MCP sites (opus-implementer, 2026-10-13 evening)

**State: IN PROGRESS.** *(This line becomes "what this unit did NOT do", said first, at the unit's close.)* **No revert
is in flight unless a line below says so.**

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
| 11 | STAGE WINDOW 2 — the walk in both voices | NOT-STARTED |
| 12 | close: self-assessment, PROVISIONALs, OWED | NOT-STARTED |

## The ladder

*(round records and every finding's disposition land here before the next round spawns)*

## Closeout

*(results, finals, the ratify list, the MOBILE PARITY line, the merge)*
