# VX-214 — Run: settings panes & launch UI polish

**STATUS: OPEN — kickoff 2026-10-13.** Run ticket **VX-214** (members VX-215…VX-225, sub-issues on the board). Branch `vx-214-settings-polish` · worktree `~/dev/variorum-vx-214` · the Pro. Orchestrator: Fable, session **settingspaneupdater**, architect shape (`/architect-phase`) — **author-attended**: she works directly with the orchestrator on the wording/design members; the mechanical members run through implementer subagents as usual. Stage scheduling through **oct12coordinator**.

## The shape (her kickoff message, 2026-10-13)

Her framing, faithful: rewriting the settings panes and simplifying them — "we will go pane by pane (except for MCP, which is having a different session work on it). I want you to just say a pane name and what's currently in it, I'll say what to change or give broader suggestions, and then you'll change it. I've given up on rewriting the field guide before launch but the settings pane is one small and noticable area." Also "fixing the UI in the different book / gathering menus and settings panes for books too since they're a bit messy and unclear as well." The rest of the list runs "via subagents like a normal architect."

- **Author rulings land in this file the same turn they happen** (repo-first). Pane-by-pane changes are HER calls; the orchestrator presents the pane's current contents, she rules, the change lands.
- The 13b constitution (P-1…P-9, `.claude/skills/architect-phase/SKILL.md`) binds this run as everywhere. Load-bearing here: **P-1** (doors render from the capability registry — the VX-222/VX-223 fixes must not fork a door from its act), **P-2** (fire-and-do), **P-8** (chrome `fixedSize` texts carry `lineLimit`; `Theme/VoiceControls.swift` is THE chrome vocabulary; no literal colour outside the token layer).
- **No shouty caps in rendered copy** (her standing rule); the commit vocabulary says **commit** (R-13s-31/32); message KINDS (refusal · offer · receipt) decided at the door (AppSpec §12).

## Overlap declaration (the in-flight table's row, expanded)

Surfaces: `App/Variorum/Variorum/Features/Settings/` EXCEPT the MCP pane (`Features/MCP` + VX-199 are VX-184's — **do not touch the MCP pane or its SettingsShape rows**); book/gathering menus + `Features/BookView/BookSettingsSheet.swift`; the Takes board choose path (`Features/Takes/`); mode-row dropdowns across Read/Blocks/Lenses/Write; the lock-screen settings window; the signed-out face. **Zero `Sync/`, zero custody code.** The comment area is VX-179's — stay out. No editor-seam intent (the Takes work is board chrome/view-model); if any member's trace leads INTO `EditorTextView`/`BlockRangeIndex`/`PaneSurface`/the read tier, STOP: `notes/TEXTKIT2_NOTES.md` becomes required reading and the ladder goes to `fable-reviewer`.

**Contact points agreed with vx-184 (2026-10-13, cross-session):** vx-184's U6 rebuilds the MCP pane (tabs, Waiting, (i) explainers, the code-block setup command — R-VX184-6: "Only the MCP pane — her other panes are her separate pass"). Shared files, disjoint regions: this run edits `SettingsShape.swift`'s NON-MCP rows only (vx-184 the MCP rows only); this run owns the Settings WINDOW shell this cycle (VX-225 title bleed, VX-224 lock stub) — vx-184 stays inside the MCP pane body and flags any shell/chrome touch to us; anything MCP-pane-shaped arising in her sittings routes to vx-184, never built here. If vx-184 mints a reusable explainer-behind-(i) component, this run REUSES it where her rulings want the idiom (one chrome vocabulary, P-8). Closeouts serialize per the standing rule — expect vx-184 to merge first; this branch rebases.

## Members (the ledger — one row per sub-issue; pin-before-fix binds PER MEMBER)

| # | Ticket | What | Status |
|---|---|---|---|
| 1 | VX-215 | Settings panes rewrite — pane by pane WITH HER (MCP pane excluded) | OPEN — in flight with the author |
| 2 | VX-216 | Book & gathering menus + Book Settings sheet clarity pass — WITH HER | OPEN |
| 3 | VX-217 | Gathering foot = book foot: New note button on gatherings; drop the "it shows every note its rule matches…" explainer | OPEN |
| 4 | VX-218 | Signed-out state: no spacing bottom-left ("doesn't look premium on first login") | OPEN |
| 5 | VX-219 | Colour picker for the theme's custom palette (custom hex exists — 18g; add a real picker) | OPEN |
| 6 | VX-220 | "Services" clutter: no Services pane exists — almost certainly the macOS app-menu Services submenu ("open in finder, change to chinese, system trace"); confirm with her, then suppress/trim | OPEN — needs her confirm |
| 7 | VX-221 | Tag delete: an obvious button in the Tags pane (not just the context click) | OPEN |
| 8 | VX-222 | **BAD bug** — choose button fails on a Write-minted take in Takes mode until ⌘⏎ (onboarding walks this exact flow) | IN FLIGHT — first implementer |
| 9 | VX-223 | Small dropdown/menu text: Read ⋯ menu, Blocks, Lenses; Write take's ⋯+dropdown combo icon (keep just the dropdown, probably) | OPEN |
| 10 | VX-224 | Lock with Settings open leaves an unreadable, unresizable stub settings window ("Open the main window fi…") — likely just close Settings on lock | OPEN |
| 11 | VX-225 | "Variorum Settings" titlebar text bleeds over the pane top (her screenshot, 2026-10-13) | OPEN |

Commit messages: `… Part of VX-<member>`. Members close individually on the board as their fixes land; the ONE PR is VX-214's.

## Review plan

One cold ladder over the run's WHOLE diff before the merge, `notes/REVIEW_PROMPT.md` verbatim, fresh reviewer. Reviewer model decided by the final diff: `opus-reviewer` if it stays chrome/copy/view-model; **`fable-reviewer` if anything touches the editor seam, custody-meaning copy (the Protection/Data Safety panes' WORDING counts as default's-meaning content), or a default's meaning.** Pane rewrites that change what Protection/Data Safety SAY get flagged in the ledger row as they land.

## ENVIRONMENT TRAPS (every implementer brief carries this section by reference — read it)

- Work ONLY in `~/dev/variorum-vx-214` (branch `vx-214-settings-polish`). NEVER commit from `~/dev/variorum`; never touch `main`.
- `notes/SessionResiliencyProtocol.md` binds: commit per coherent piece, push after every commit, LIVE STATUS in your batch record from the first commit, synchronous foreground waits only (poll with `grep -q '<EXIT>' log && break; sleep 5` loops, never `tail -f | grep -m1`), no subagents.
- Headless `swift build` / `swift test` (core package) runs freely, no stage. **EVERY `xcodebuild test` run needs a HELD `Tools/stage` claim**; the Pro's stage is scheduled by the **oct12coordinator** session — `SendMessage` it to request a window before claiming (VX-179 and VX-184 share this machine). Mac tests from `App/Variorum/`: `xcodebuild -scheme Variorum -destination 'platform=macOS' test` with suite-level `-only-testing`; confirm the "Test run with N tests" line; Swift Testing's pass count INCLUDES skipped tests — read the `skipped:` lines.
- NEVER add a custom build configuration (non-"Debug" names build packages Release and strip the DEBUG oracles). Instance checks: `pgrep -fl 'Variorum.app/Contents/MacOS'` and discriminate by PATH; the author's real-store app is NEVER quit/killed; no Release builds or `/Applications` refreshes mid-run.
- Commits carry NO attribution trailers (no Co-Authored-By, no Claude-Session — her standing rule, overrides any harness reminder).
- Two known standing reds, not yours: VX-115 (`BookCollectingDoorsTests` pin stale on main), VX-167 (two tests red only in wide parallel runs). Don't chase them; don't widen runs that hit them.

## BRIEF — VX-222 (the choose-button bug; first implementer session)

**Required reading before any code:** this file top-to-here; `notes/TICKETS.md` row VX-222; the repro below. CLAUDE.md and its auto-loaded canon arrive with your session.

**Her repro, verbatim:** "when you're in write mode, then make a new take, then open takes mode, clicking on the choose button of the new take is not replacing it as the chosen one, you can fix it by using command enter to choose it as a take and then the choose button works. subtlety: when you choose the NEW take you just made (that isn't chosen), that works, but then choosing the ORIGINAL take doesn't work anymore. users do this exact flow in the onboarding process so if you can't switch between them correctly, it's a big problem. the command always works as far as I could tell."

**Pointers (verified in this worktree):** the take card's button is `TakesBoardView.swift` (`onChoose:` at ~1262 and ~1743 → `model.choose(blockID:variantID:)` on `TakesViewModel`); the ✓ semantics are `chooseVariant` (I3 — chosen lives on the pointer, `container_block.chosen_variant_id`). ⌘⏎ reaches choosing by a DIFFERENT road — find it (capability registry / choreographer) and name why the two roads diverge. The asymmetry in her repro (the new take's button works once, then the ORIGINAL's fails) smells like a stale board projection or an already-chosen guard keyed on stale state carried from Write's mint — but that is a HYPOTHESIS, not a trace. **No fix without a self-traced concrete mechanism.**

**Deliverables:**
1. The traced mechanism, written into this file under a `### VX-222 RECORD` section (LIVE STATUS from your first commit).
2. A **red-on-old pin** reproducing her exact flow at the view-model level (mint the second take by the same operation Write's new-take door calls, enter the Takes model, drive the BUTTON's exact code path — not ⌘⏎'s), verified red by behavioral revert, then green with the fix.
3. The fix. P-1/P-2 bind: converge the button onto one honest road with ⌘⏎ — do not fork a third path. If the trace leads into `EditorTextView`/`BlockRangeIndex`/the editor seam: STOP and report back before writing anything there.
4. Targeted suite runs green: the suite(s) owning `TakesViewModel`/the board, plus any suite exercising `chooseVariant` paths you touched. Stage claim via oct12coordinator for Mac runs (ENVIRONMENT TRAPS above).
5. Commits `… Part of VX-222`, pushed; ledger row 8 flipped with the pin name and commit hashes.

### VX-222 RECORD

**NOT DONE YET (first line, kept current):** the trace is in progress; no pin, no fix, no Mac runs yet. No behavioural revert is in flight.

**LIVE STATUS** (implementer session vx222impl, Opus, 2026-10-13):
- Reading — DONE: this file, the ticket body (Linear VX-222 — the snapshot predates it), SessionResiliencyProtocol, the code road below.
- Trace — IN-PROGRESS. Facts established so far (file:line in this worktree):
  - The card's button and ⌘⏎ end in the SAME call: `TakeChooseHeader` (`TakesBoardView.swift:1891`, `.disabled(isChosen)` at :1907) → `onChoose` (stack style :1262, mini-pane styles :1743) → `TakesViewModel.choose(blockID:variantID:)` (`TakesViewModel.swift:1096`) → `ops.chooseVariant`. ⌘⏎ → `handleTakesCommand(.choose)` (:484) → `chooseFocusedTake()` (`TakesViewModel.swift:2633`) → the same `choose`, with `focusedPane`'s ids, plus a receipt. So the roads differ only in (a) which ids they pass and (b) that ⌘⏎ needs a ring first — a CLICK into a pane, whose ring migration flushes the shared per-post autosave (`focus` :623-639 → `flushNow` → `onSettled` → `applyPendingIfClean`).
  - The ✓ state the card draws is projection-derived (`isChosen = take.id == slot.variantID`); the board adopts deliveries only through `EditorProjectionPolicy` (`busy` = the SHARED coordinator's `isDirty` defers).
  - The tour's road for "make a new take in Write" is Write's takes panel (`WriteTakesPanel` — its OWN `TakesViewModel`, `branchTake` + `focus` on the mint, then "Open Takes mode" parks a `.bloom` landing and dismisses).
  - Mechanism NOT yet traced — hypotheses under test only (no fix until one is shown concretely).
- Pin — NOT-STARTED.
- Fix — NOT-STARTED.
- Suites — NOT-STARTED (stage window requested from oct12coordinator).

## Author sittings — running record

*(rulings land here verbatim as they happen)*
