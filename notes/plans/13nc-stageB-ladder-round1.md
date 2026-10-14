# 13n-c Stage B (U2–U5): ladder round 1 (cold review, opus-reviewer, 2026-10-11)

**Reviewer model:** Opus 5.5 (`claude-opus-5-5`), xhigh. The prompt was `notes/REVIEW_PROMPT.md` verbatim with
PHASE = 13n-c, plus a mechanics-only note (worktree, range `99d739e9..065526ce`, plan path, stage rule, VX-132).
The reviewer stayed read-only; the orchestrator landed this record from its report.

**Result:** 0 BLOCKER · 1 MAJOR · 6 MINOR · 7 NIT · 2 SPECULATIVE. It concurs with the routed orchestrator
findings O-1, O-2 and O-3.

**Flow:** same-model (Opus reviews Opus), so the orchestrator arbitrates against the spec (CLAUDE.md). The fix
implementer gets these dispositions and O-1…O-3. Round 2 is a fresh reviewer over the fix range.

## Findings and dispositions

| # | Sev | Where | Finding (short) | Disposition |
|---|---|---|---|---|
| B1 | MAJOR | `TutorialSeeder.swift:2490` (MCP lesson 1) | "What you share stays on this Mac" is false: `read_note`/`search`/`export_note` hand text to the client, which sends it to its model provider. Only the grants are local. | **ACCEPT — fix + pin.** It is a disclosure at the privacy boundary (F-17's class; P-6 "every sentence true"). Fix: "Your grants stay on this Mac — they never sync to your other devices." Also add one honest sentence: a client sends what it reads to wherever it sends its work, for most clients the company running its model. That keeps her "honest, not scary" standard; wording PROVISIONAL P-13nc-SB-1, her copy pass. Pin: lesson 1 claims grants stay local and never claims shared content does (red on the current text). Check the same claim in `MCPSession.instructions` and the pane copy. |
| B2 | MINOR | `MCPAskQueue.swift:58`, `MCPDoor.durations(for:)`, `MCPPaneCopy.reachLine` | A waiting ask is answered on its ARRIVAL-time fence snapshot. A Private mark since then leaves Always offered, and the press refuses (dead door, P-2). A deduped re-raise keeps the stale payload, and a deleted target still lists. | **ACCEPT — fix + pins.** Arrival X made asks wait for hours, so the snapshot is now a real hazard. Fix: when the sheet opens, derive its offered durations and reach line from current facts (`mcpNoteFacts`/`mcpBookFacts`, the one derivation site, never re-derived). A deduped re-raise refreshes the payload and keeps the stamp. An ask whose target is gone is forgotten; one whose book is now fenced says so honestly. Pins as the reviewer named them, red-on-old by revert. FABLE-OWED: extends F-15. |
| B3 | MINOR | `MCPShareQueries.swift:86`, `MCPPaneCopy.groupMembers`, the shared-group views | A bulk act's members beyond the first three are named nowhere; "all N ›" shows the same three. This breaks R-13n-10 and makes lesson 6's "lists everything shared" untrue. | **ACCEPT — fix + pin.** "and N more ›" opens the act's member list: one bounded read of that act's titles, ∝ the act and never the corpus. Add per-member Revoke if it fits the idiom, else record why not. Pin: the act's road lists every member (red today). |
| B4 | MINOR | `BookSettingsSheet.swift:252` `showsGrantRow` | A second fence derivation inside a face (profile/isPrivate) rather than the fence's own fragments. Architectural: equivalent today, so a pin is green on both sides. | **ACCEPT — architectural, no red-on-old possible (said plainly).** Plan §2 binds "no parallel fence". Hold `mcpFencedBookIDs` membership (or `mcpBookFacts(...).fence != nil`) in `BookSettingsModel` and gate on it. Add a parity pin against `mcpFencedBookIDs`. |
| B5 | MINOR | `LibraryCatalogView.swift:1227-1234` | The Library row's Share with AI… comes from a menu that is not a declared context-menu renderer. The registry walk stays green only through the other renderers, and lesson 5 names this door. | **ACCEPT — fix + pin.** Declare `LibraryCatalogView.contextMenuCapabilities` (≥ `.mcpShareHere`) into the walk's union, or pin `postRowMenu`'s doors, whichever matches the registry's idiom. Red-on-old: deleting the door turns the new pin red. |
| B6 | MINOR | `EditorCommands.swift:475`, `CapabilityRegistry.swift:2317` | ⌘L "Switch Wing…" is enabled with ONE wing; its only outcome is close. The masthead already applies P-2 to that case. | **ACCEPT — fix + pin, PROVISIONAL P-13nc-SB-2.** With one wing the item is unavailable (P-2: never draw a door that does nothing), with the registry's unavailable note naming New Wing… in the masthead ▾. Pin: one-wing `WingsModel` ⇒ `.switchWing` unavailable (red today). |
| B7 | MINOR | `SettingsShape.swift:113` | The MCP pane's searchable description still says "the command that sets up Claude Code". | **ACCEPT — fix + copy pin**, wording per the reviewer's proposal. |
| B8 | NIT | `SearchPicker.swift:473` | In a sourced panel the empty-state text can never show; "Nothing matches." appears before typing, and during the first async load. | **ACCEPT** — a `loaded` flag. Pin the brain's empty-vs-no-match state. |
| B9 | NIT | `MCPPaneCopy.swift:682/684` | "Any answer below grants it…" is false for Don't allow. | **ACCEPT — minimal truth fix** (e.g. "Allowing grants it…"); the voice stays her copy pass (P-13nc-U2-4). |
| B10 | NIT | `TutorialSeeder.swift:2597-2598`, `:2495` | Two overclaims: Activity is "every call" (it is coarse and capped at 500), and ⌥⌘Z "every act" (the undo is session-scoped). | **ACCEPT** — "recent calls" / "in this session" (or equivalent true words), pinned in `TutorialMCPChapterTests`. |
| B11 | NIT | `MCPGrantQueries.swift:703`, `MCPDoor.allShared()`/`liveGrantCount` | Dead code left by the retirements; a stale doc comment. | **ACCEPT** — delete the unused members. Keep `mcpReachableBookIDs` only as the documented parity oracle, its doc corrected. |
| B12 | NIT | ledger §6 | ⌥⌘A's mint road (a keystroke granting at a rung taken from history, revoked rows counting) has no FABLE-OWED row. | **ACCEPT** — F-18 written now by the orchestrator. |
| B13 | NIT | `MCPGrantAuthority.swift:143`, `MCPToolCatalog.swift:240/456/539/610/673-674`, `MCPShowTool.swift:58` | O-2's scope: gendered pronouns also ship on the wire outside the advice (13n-b strings). | **ACCEPT — O-2 widened.** Every client-facing wire string becomes neutral ("the author"/"they"). The pin sweeps the advice, every tool description and every refusal/ask sentence the server can emit. |
| B14 | NIT | ledger row 7 | The cap-test red ("Unable to parse empty data") is a watch item with no ticket. | **ACCEPT** — folded into VX-132 by a ticket comment (the orchestrator, now); the ledger row points there. |
| S-1 | SPEC | `WingSwitcherKeyCatcher` | A fast ⌘L-L-release before the sheet is key may not commit. | **WALK ITEM** (held walk list); no headless pin possible. |
| S-2 | SPEC | `MCPPane.landAtWaiting` | Whether `scrollTo` finds a Section id inside a grouped Form on macOS. | **WALK ITEM**; the fixer may make it robust (an id on a row rather than the Section) if the change is clearly safer, recorded either way. |

**Orchestrator findings riding the same fix pass** (the plan's O-1…O-3, held back from the cold reviewer):
- **O-1:** the pending-ask glyph and the shared icon are near-twins. Pick a pending glyph that differs by silhouette, not fill; PROVISIONAL.
- **O-2:** pronouns, widened by B13.
- **O-3:** the ⌘/ helper's MCP row describes the glyph by role.

## Clean bill (the reviewer's, summarized; the full list was in its report)

- Fence and process: zero `Sync/`, `Persistence/`, migration, editor-seam or custody lines; zero trailers.
- Headless finals reproduced: core 2,619/299 · MCP 76/10 · workbook 40/6.
- Mac: 119 tests / 9 suites green under a held claim.
- Core ops: the bulk grant and Change…-as-replace are one transaction, all-or-nothing, same-client only; revoke validates before it writes.
- `reach` reads `decide`'s own allow without spending; the inert reads go through the rule.
- `mcpFencedBookIDs` is the exact complement of the offered set.
- Wake rate: the held observations never wake on autosave columns. P1 holds (∝ books / per keystroke bounded).
- Arrival X: no scene self-presents an ask; answer-once and deny-forgets are held.
- The ⌘L monitor is window-scoped.
- VX-272's gates hold at every door.
- The advice's bound, tool names, format markers, F5 and R2-8 are honored.
- The setup menu: the Claude Code command is byte-unchanged; the JSON escaping is correct.
- `PlaceLabels`' uniqueness holds; `SearchPicker`'s flat path is unchanged; `WingSwitcherMenu`'s acts are all reachable.
