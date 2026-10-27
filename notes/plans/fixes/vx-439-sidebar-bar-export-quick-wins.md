# VX-439 — Run: sidebar, bar & export quick wins

**Ticket:** VX-439 (Umbrella, run ticket) · **Project:** v1 release readiness · **Branch:** `vx-439-run-sidebar-bar-export-quick-wins` · **Worktree:** `~/dev/variorum-vx-439` (the Pro) · **PR:** `VX-439: …` (merge commit only)

**STATUS: OPEN — kickoff 2026-10-27, overnight run (architect-phase).**

---

## Kickoff (her words, verbatim — 2026-10-27)

> "vx-439 — overnight protocol: run autonomously, provisional-and-continue, bundle every question for my morning. Two implementer batches; the Opus reviewer is fine (no editor seam — the takes cluster moved to VX-601). My rulings are all on the tickets (VX-332 yes, VX-126 option A, VX-602's words). Mind the concurrency note: VX-502 shares the export seam — second merger rebases. Stage claims through tonight's coordinator. No release without my word. coordinator is oct26coordinator"

**The overnight protocol applied:** PROVISIONAL-and-continue on every ambiguity that doesn't gate a member's core; anything genuinely needing her (taste calls, deploys, releases, adjudication she reserved) is HELD and bundled into THE MORNING BUNDLE section below — never improvised around, never dropped. No release, no `/Applications` refresh, without her word. The offered riders VX-373 and VX-409 are NOT adopted (17 members is a full run; noted in the morning bundle).

**Cast (her kickoff word):** Fable orchestrates (this session); `opus-implementer` per batch (fresh session each, xhigh); **`opus-reviewer`** for the ladder (her explicit call — no editor seam in this run; the takes cluster moved to VX-601). Cross-model rules do NOT apply (same-model Opus implement/review ⇒ the orchestrator arbitrates disputes against the spec).

**Concurrency (her kickoff + the run ticket):** runs alongside **VX-502** (`~/dev/variorum-vx-502`), which changes the import acceptance rule in the same document-format home that VX-125/VX-126 touch (`Domain/VariorumDocument`, `Queries.variorumDocumentText`, the import/export pins). **Whichever merges second rebases and re-runs the export/import pins before its PR.** Also alongside VX-548 (MCP run; disjoint surfaces except possibly the Book Panel header file — watch at merge). Closeouts serialize.

**Stage (the coordinator's protocol, 2026-10-27 — binding; supersedes any self-claiming):** tonight's coordinator (session **oct26coordinator**) holds the stage between grants; a free stage is NEVER an invitation and nobody self-claims or polls. Only stage traffic goes to the coordinator; ladder traffic stays in this run; SUBAGENTS RELAY THROUGH THE ORCHESTRATOR — an implementer never messages the coordinator. The flow: the orchestrator sends REQUEST (what / minutes / claim name) early; when a session is actually built (`build-for-testing` done) and able to start NOW, the orchestrator sends READY; a **GO from the coordinator carries the exact claim line to run** — only then is the stage claimed, with exactly that line; at the end `Tools/stage release`, and the orchestrator sends one result line (green/red; for a walk, the dev store's state left behind). Implementers: finish everything headless (`swift build` / `swift test` / `xcodebuild build-for-testing` never need the stage; EVERY `xcodebuild test` does), then report READY-for-stage to the orchestrator and WAIT for the claim line by message. Instance checks use the strict forms `pgrep -lx Variorum` and `pgrep -lf "MacOS/Variorum$"` (the loose form matches builds). After every Debug launch, dismiss a What's New sheet if one shows. Walks: the dev store stays unlocked and reachable; this run's walks change NO credential and NO posture; if Debug prefs are touched, export first and at restore re-export and diff (`defaults import` merges). Merges go through the coordinator, not peer to peer.

---

## Binding principles — the 13b constitution (P-1…P-9, carried verbatim per the architect-phase skill)

- **P-1 — One capability registry.** Every user-facing act is declared exactly once: verb, scope (block/take/post/book), per-mode availability rule, its doors (menu / context / bar / shortcut / palette), and its refusal copy. Surfaces render their doors FROM the registry; gating is data, never per-view if-statements. A registry-walk test asserts every declared door exists and every rendered door is declared. This kills the D3/D4 class structurally — the capability matrix stays green by construction instead of by audit.
- **P-2 — Fire-and-DO (R115).** A rendered door either performs the act — including any mode-switch choreography, done visibly for the user — or delivers the operations layer's real refusal. A door that can never act in its context isn't rendered. Lecture-and-redirect is retired.
- **P-3 — One text surface, one liveness authority.** ONE TK2 surface component (live + read modes; one measurement brain — the width-gated remeasure; the shared canary) that every pane composes; the live editor core's identity machinery (`BlockRangeIndex`, crystallization) becomes its live mode, not a sibling implementation. "What text does this pane show, and is it live" is answered by ONE pure, unit-tested authority (`PaneTextAuthority`); views never re-derive it. Its invariants stated as code: exactly one live pane; the live pane is buffer-authoritative; read panes are projection-authoritative once caught up.
- **P-4 — Broadcasts carry signals, never decisions.** NotificationCenter may announce that something happened (mode changed, post opened); no listener derives business state or availability from a broadcast, and no flow's correctness depends on broadcast ordering. Cross-feature flows route through composition. (Stage 0's survey enumerates today's notification bus; Stage 1 disciplines it.)
- **P-5 — The friction doctrine (R116).** Repeated pushback against a rule marks an under-architected feature. The response is never another patch: write the feature's DESIGN MEMO — intended behavior whole, edge cases enumerated on paper, refusal wordings, undo story — get the author's rulings on the product-flavored edges, then build to the memo. Happy path ships first, but the edges are *decided at design time*, not discovered by the author. First two memos owed: **merge** and **the W ceremony**.
- **P-6 — The tutorial is the executable spec (R113).** The guided tutorial flow is the contract for every happy path. It stays green — automated where the harness allows, screenshot-walked otherwise — and any change that breaks a tutorial step is a regression by definition.
- **P-7 — Find bugs before she does.** Every layer keeps a proactive harness: the ops-layer soaks (exist), the board/view-model invariant soak (Stage 1), the registry walk (P-1), the per-batch scripted screenshot walkthrough. Red-on-old stays absolute: no bug-class fix without a pin that fails on the pre-fix code.
- **P-8 — Standing law, consolidated.** P1–P3 performance invariants bind the rebuilt layer exactly as they bind the substrate (invalidation ∝ realized rows; one live editor; virtualized long views). Overlays, never rendering attributes. Chrome `fixedSize` texts always carry a `lineLimit` (the b6dae25 class). `Theme/VoiceControls.swift` is THE chrome vocabulary. Complexity lives in the store; restraint lives in the UI.
- **P-9 — No god objects in the frontend either.** A view model mixing board layout, text authority, and gesture routing splits by concern (`TakesViewModel` at 890 lines is the standing counterexample). Same hygiene rule as the substrate, applied where it was being waived.

Application notes that bind here: P-1's scope is the ROUTED vocabulary grown incrementally (inline-only doors declare `.surface`, never mis-filed `.contextMenu`); P-3's two deliberate surface kinds stand (this run must NOT absorb or fork `EditorTextView`/`PaneSurface` machinery — VX-441 and VX-569 are chrome beside the editor, not seam work); storage-coupled code stays feature-side.

---

## The members (17, post-split — the Takes/editor cluster is VX-601's)

| # | Ticket | What | Batch | Kind |
|---|---|---|---|---|
| 1 | VX-125 | File ▸ Export Note… as markdown (Variorum simple format) + keyboard shortcut — pre-launch | 1 | Feature |
| 2 | VX-126 | Export Library writes the format header — **option A ruled** — pre-launch | 1 | Feature |
| 3 | VX-554 | Gatherings need a New Note button — pre-launch | 1 | Improvement |
| 4 | VX-570 | A keyboard command for a new note inside the current book | 1 | Improvement |
| 5 | VX-553 | "Restore deleted chapter" moved away from between the two mint doors — pre-launch | 1 | Improvement |
| 6 | VX-552 | The wing you're in always visible beside the New Note button — pre-launch | 1 | Improvement |
| 7 | VX-332 | Bookcase quick-entry focus on EVERY return — **ruled YES, option (b)** | 1 | Improvement |
| 8 | VX-568 | Quick entry's new-note prompt: normal cursor blink, not fade | 1 | Improvement |
| 9 | VX-602 | Help menu wording: field guide / onboarding tutorial — pre-launch, Wording | 1 | Improvement |
| 10 | VX-424 | Open list drag-to-reorder: floating card, nothing reorders — **"fix tonight"**, probe BOTH directions | 2 | Bug |
| 11 | VX-425 | Sidebar note rows: context menu (Rename · Delete · Close · Move/Copy to Wing · Export) — pre-launch, widened 2026-10-26 | 2 | Improvement |
| 12 | VX-580 | Sidebar preliminary titles for untitled notes, default on — pre-launch | 2 | Improvement |
| 13 | VX-589 | A setting to hide starred notes from the Open list | 2 | Improvement |
| 14 | VX-426 | Icon chrome hover tooltips (1–2 word descriptors) — pre-launch | 2 | Improvement |
| 15 | VX-560 | ⌘← / ⌘→ back and forward outside text views | 2 | Improvement |
| 16 | VX-441 | Write find & replace: a match counter that follows you (2/15) | 2 | Improvement |
| 17 | VX-569 | Fresh empty note: Tab from body to title offers the date fill-in | 2 | Improvement |

Riders offered on the run ticket but NOT adopted (no room at 17 members): VX-373, VX-409 — in the morning bundle.

---

## Her rulings on the tickets (verbatim-faithful; the build follows these)

- **VX-332 (2026-10-27):** "RULED: YES — focus on every return." Every Bookcase mount asks for quick-entry focus (P-U6-2's option (b), R102's wording), yielding when something else holds the keyboard and standing down during the tour (the W-U1a-1 lesson).
- **VX-126 (2026-10-27):** "The takes-carrying-bodies choice is MADE: **option A** — each per-note file in the bulk export is byte-identical to Copy full text (header + the takes-carrying body; plain-markdown-identical wherever a note has no fans). The header-only/plain-bodies alternative is declined." Per-post `exportPost` consumers that predate the header stay as they are.
- **VX-602 (her CLEAN checklist, 2026-10-26):** "what's under the help menu is SO confusing. 'Restore Tutorial' should be restore field guide. take the tour should be the onboarding tutorial still. it's just confusing."
- **VX-424 (her triage 2026-10-18):** "fix tonight" (High). "I swear it happens trying to move it up as well — so there might be a bit more to that one." → instrument BOTH directions (log gap/destination per hover) before pinning; cover up-drags in the pin.
- **VX-425 (widened at her word, 2026-10-26):** the row menu also carries Move to Wing / Copy to Wing and Export — her "empowered note sidebar." Multi-select is VX-344 (NOT in this run).
- **VX-580 (her 10-21 note):** "I NEED to make showing a preliminary title on the lefthand bar the default - maybe fewer words than the library shows, but agh. I suppose that could be a setting too." Default on; a setting is optional.
- **VX-589 (her 10-20 note, twice):** "ability to not see in Open what is already in Starred"; "it would be nice if there was a *setting* where you could choose to not have items that are starred show in the Open tabs. i'm noticing a lot of duplication there."
- **VX-560 (her scope call):** outside a text view only — inside the editor ⌘←/⌘→ stay line start/end. ⌥⌘[ / ⌥⌘] remain.
- **VX-569 (her 10-21 + 10-20 notes):** "in a fresh note with no words, going to the title and tab should make the title fill-in-able with the date so that you can enter it, as a match to the quickfill title option." The first-line quickfill exists; verify the click-in + Tab-accept path works as she describes and add the empty-note date arm.
- **VX-554 (design note on the ticket):** a gathering holds nothing, so the minted note presumably lands bookless and wears the rule's tag(s) so the gathering assembles it — the kickoff names the exact shape (named below, A-439-3).
- **VX-125 (2026-10-09 + 2026-10-26):** "I do want a per note export in markdown with variorum simple format - that's a super obvious part of V1…" — writes exactly what Copy full text emits; registry-declared; gets a keyboard shortcut ("keyboard shortcut for saving note" — she confirmed she most likely meant export).
- **VX-552 (her ask, 2026-10-26):** the focused wing's name should always sit next to the New Note door, so a new note's landing place is never a surprise.
- **VX-553 (her words, 2026-10-26):** "'restore deleted chapter' can NOT be in between new note and new chapter at the bottom of a book — that's so annoying, def the wrong place for it."
- **VX-570 (her 10-21 note):** "command for new note within a book" — ⌘N mints into the Library; from inside a book there's no keyboard way to mint a member.
- **VX-441 (her ask 2026-10-18):** "a # of matches in find and replace within write as you go down that count — so you can see if you're 2/3, 2/15, etc."
- **VX-568 (her 2026-10-22 note):** "I don't like the fading in and out flickering of new note on the bookcase - it should just be a nice normal cursor blink."
- **VX-426 (beta tester via her 10-20 note; her word 2026-10-18: pre-release):** descriptors like "Notes & Links", "Snippets", "Tray" — "every time I see the 'Snippets' button my brain thinks it's a copy/paste tool and becomes fearful to press it."

---

## Architect rulings for this run (A-439-N; PROVISIONAL where product-flavored — all bundled for her morning)

- **A-439-1 (VX-125, PROVISIONAL):** the door is **File ▸ Export Note…**, registry-declared with shortcut **⇧⌘E** unless the registry shows it taken (then the implementer picks the nearest free export-shaped chord and records it here). Save panel defaults to `<title>.md`. Available on any shown note (export is read-only; archived and sealed notes export fine). Also declared in ⌘K and the note menus where the capability registry's door families naturally carry it.
- **A-439-2 (VX-126):** built exactly as her option A: the library export's per-note writer calls the one serializer road Copy full text uses (`Queries.variorumDocumentText`); the byte pins on the library-export shapes are updated DELIBERATELY (the commit says so), and a new round-trip pin exports a library, re-imports the files, and proves titles, tags and takes ride whole. Per-post `exportPost` consumers predating the header: untouched.
- **A-439-3 (VX-554 — the shape, named at kickoff as the ticket asked):** the gathering face gets a **New Note** door rendered from the capability registry, wired to the ONE planner authority the existing gathering mint and collect doors share (SurfaceContracts: "one planner authority shared with the mint"). The minted note lands bookless in the gathering's wing wearing the rule-satisfying tags/star so the gathering assembles it; a rule the planner cannot satisfy (`#a AND NOT #a`) greys the door exactly as the existing mint door greys. No new operation; no intake special-casing (the applying act does the work). PROVISIONAL only on placement: match the curated book face's New Note placement.
- **A-439-4 (VX-570, PROVISIONAL):** **⌥⌘N — "New Note in This Book"**, registry-declared, available when a book context is focused (book surfaces and a membered note's book context); it mints through the existing add road so the gate speaks its real refusals (finished, at capacity → the operations layer's words). On a gathering it routes to A-439-3's planner door. Not rendered where no book context exists (P-2).
- **A-439-5 (VX-553, PROVISIONAL):** the book foot keeps **New note · New chapter** adjacent; **Restore deleted chapter** moves out of the everyday path — after the mint pair, visually separated, or into the book's overflow/settings door if one is the surface's existing idiom. The implementer picks whichever placement matches the surface's existing idiom and records the choice here; the door itself, its wording and behavior are untouched.
- **A-439-6 (VX-552, PROVISIONAL):** the focused wing's name renders as a quiet, muted label immediately beside the primary New Note door (the Bookcase quick-entry band's and/or the toolbar's — the implementer traces where New Note doors live and covers the primary ones), through the existing wing-follow state (no new observation machinery). Styling from `Theme/VoiceControls` tokens; never a literal colour.
- **A-439-7 (VX-332):** built exactly as ruled — every Bookcase mount asks; yields when anything else in the window holds the keyboard; stands down during the tour. The SurfaceContracts line ("arriving back at the Bookcase later is unchanged, QUESTIONS #224") changes at closeout with the pointer VX-332.
- **A-439-8 (VX-568, PROVISIONAL):** the prompt's fade in/out animation is removed; focused quick entry shows the system caret's normal blink; unfocused shows the static prompt. (With VX-332, the band will be focused on most arrivals.)
- **A-439-9 (VX-602, PROVISIONAL wording):** Help menu door renames — "Restore Tutorial" → **"Restore Field Guide"**; "Take the Tour" → **"Take the Onboarding Tutorial"** (her words name the tour "the onboarding tutorial"; menu-item capitalization follows the menu's existing convention). Scope is the Help MENU's doors and any registry labels naming them; if the field guide's own seeded CONTENT speaks the old names, do NOT edit the content — flag it here for the morning bundle (a content edit stales the real store's seeded guide and owes the A1 re-seed, which is held for her window).
- **A-439-10 (VX-589, PROVISIONAL):** a LOCAL preference (the Open list is per-device and view-only, like appearance), default OFF, toggled in the Settings pane where the sidebar's kindred toggles live (the implementer names the pane here). When on, a note with the union star shows in Starred only; the Open list filter is display-only (closing/follow semantics untouched; rows return when unstarred or the setting flips).
- **A-439-11 (VX-580, PROVISIONAL):** default ON with NO new setting (her "a setting is optional" — the lightest build): untitled note rows derive their preliminary title through the Library's one derivation brain, truncated naturally by row width. If the sidebar and Library derivations have diverged, unify on the Library's.
- **A-439-12 (VX-560, PROVISIONAL):** ⌘← / ⌘→ fire back/forward only while the first responder is not a text-input view; inside any editor or field the system line-start/line-end behavior is untouched. ⌥⌘[ / ⌥⌘] remain and stay the labels shown in menus; the registry carries the alternates. (⌘[ / ⌘] stay indent — the keyboard family's standing law.)
- **A-439-13 (VX-441):** trace FIRST whether NSTextFinder's native "X of N" counter can be fed by our finder-client hooks (that may be the whole fix); only if the system bar cannot show it, draw our own muted readout at the bottom bar's trailing end (the status seam's home) while the find bar is active. No change to `EditorTextView`'s text/layout machinery — chrome and client-protocol methods only. Read `notes/TEXTKIT2_NOTES.md` §3–4 before touching those files.
- **A-439-14 (VX-569, PROVISIONAL):** the empty-note date arm offers the SAME date string the daily-entry title convention uses, through the existing quickfill accept gesture (Tab to accept, typing to dismiss). First verify the existing first-line quickfill's click-in + Tab path works as her 10-20 note describes; if it is broken, that is a traced bug fixed first (with a pin), then the date arm lands on it.
- **A-439-15 (VX-424):** instrument both drag directions BEFORE the fix (temporary logging of gap/destination per hover, removed before the ladder); the pin covers down-by-one AND an up-drag case; the fix follows the scout's shape (half-row before/after targets or `DropInfo.location` against row height) flowing through `OpenListDragState.Target` / `SidebarLayout.OpenListDrop`; the before/after targets of one boundary must resolve to the same gap (no line flicker). The SurfaceContracts Open-list drop sentence changes at closeout to describe the half-row targets, pointer VX-424.
- **A-439-16 (VX-425):** the row menu renders from the registry (the `.surface`/`.contextMenu` door cases as the registry's idiom has them): **Rename** (inline row edit writing through the title operation — PROVISIONAL on inline vs. focusing the note's title field; implementer picks the surface's existing idiom), **Delete note** (routes through her Delete door's one road, confirm included), **Close** (the contract's exact row semantics: on the shown note like ⇧⌘W, else remove the row), **Move to Wing / Copy to Wing** (the existing capabilities' doors re-rendered here), **Export** (VX-125's capability). Single-row only (multi-select is VX-344's).
- **A-439-17 (VX-426, PROVISIONAL):** every icon-only door in the sidebar and note-face chrome wears `.help` with a 1–2 word descriptor, sourced from the registry's verb/label where the door is registry-rendered (one vocabulary), hand-named otherwise; sentence case per her caps rule except surface proper names ("Snippets", "Tray", "Notes & links"). The sweep enumerates every icon-only door it found and its tooltip in this file (the class-completeness table).

Anything a batch finds itself needing that would CHANGE a §9 operation's semantics, relax an invariant, or touch `Sync/`/custody: STOP that member, record here, move on (the morning bundle).

---

## BATCH 1 BRIEF — export, books & Bookcase (one implementer session)

**Members:** VX-125, VX-126, VX-554, VX-570, VX-553, VX-552, VX-332, VX-568, VX-602 — in that order (export seam first: VX-502 shares it, and VX-425 in batch 2 reuses VX-125's capability).

**Required reading before any code (never delegated):** `CLAUDE.md` + its auto-loaded canon; this file TOP TO HERE plus this brief; `notes/SurfaceContracts.md` in full; `notes/SessionResiliencyProtocol.md`; `notes/plans/phase-13n-a-document-format.md` (the document format's record) for VX-125/126; the capability-registry area (`App/Variorum/Variorum/Registry/CapabilityRegistry.swift`) before declaring any door.

**Per member:** work to the ruling (hers verbatim above; A-439-N where I ruled). PIN-BEFORE-FIX PER MEMBER: a bug-class change lands with a red-on-old pin verified by behavioral revert; a feature lands with its state-transition/registry/round-trip tests; VX-126's byte-pin updates are deliberate and say so in the commit. One commit (or a few) per member, message `Part of VX-<member>: <traced mechanism + the pin>`; push after every commit. No attribution trailers on commits (her standing rule).

**Specific cautions:**
- VX-125/126: the format's one home stays `Domain/VariorumCore`'s `VariorumDocument`; no export path ever writes a row. Do not change the import acceptance rule — VX-502 owns that seam tonight. If `Domain/VariorumDocument` itself needs more than a consumer-side call, STOP and report (seam contention).
- VX-332: the quick-entry bar yields to any keyboard holder and the tour (W-U1a-1: never steal). The pin: a mount-focus test on the Bookcase return path, red on old.
- VX-602: menu labels only; if guide CONTENT speaks the old names, flag — don't edit (A-439-9).
- VX-554/570: the gate refusals are the operations layer's real words (P-2) — no new refusal copy without the registry's declaration.
- Settings/registry work: never a literal colour; chrome `fixedSize` texts carry `lineLimit`.

**Tests at the END of the batch (never the start):** `swift test` on the core package headless (free, no stage); then `xcodebuild build-for-testing` from `App/Variorum/` (headless, no stage); then REPORT READY-FOR-STAGE to the orchestrator naming the suite list (every suite that exercises a changed SOURCE file — grep the tests for the changed types — plus `TutorialWalkTests`, P-6) and WAIT for the orchestrator's message carrying the coordinator's exact claim line. Then: run the claim line verbatim → the Mac suites with suite-level `-only-testing` → `Tools/stage release` → report green/red per suite to the orchestrator. Confirm the "Test run with N tests" line; Swift Testing counts skipped tests — read the `skipped:` lines before claiming a gated suite ran. Never claim the stage without the relayed GO line; a free stage is not an invitation.

**Checkpoint protocol (binding from the first commit):** LIVE STATUS section below updated in the same commit as each piece (`DONE (hash)` / `IN-PROGRESS — what remains` / `NOT-STARTED`); records before final verification marked PENDING; synchronous foreground waits only (poll logs with `grep -q '<EXIT LINE>' && break; sleep 5` loops — `tail -f | grep -m1` hangs after the line lands); never spawn subagents except at most ONE read-only Sonnet for external facts; commit before any revert; no `git checkout` over uncommitted work; push after every commit; never force-push.

**Environment traps (verbatim core):** instance checks use the strict forms `pgrep -lx Variorum` and `pgrep -lf "MacOS/Variorum$"` AND discriminate by PATH (the test host matches mid-run; the loose form matches builds); treat real-store instances by STORE, not path — NEVER quit/kill one; no Release builds or `/Applications` refreshes (held for her word regardless); `xcodebuild build-for-testing` compiles without the runner; Mac tests from `App/Variorum/`, suite-level `-only-testing` only; zsh `pipestatus`; NEVER add a custom build configuration (anything not named exactly "Debug" builds the packages Release and strips the DEBUG oracles); suites flash the test host's windows — hence the stage claim; screenshots in gitignored dirs; backups (if a store is ever touched — it should not be in this batch) A1 into `Backups/safety-copies/`.

---

## BATCH 2 BRIEF — sidebar & bar (one FRESH implementer session)

**Members:** VX-424 (first — instrument, pin, fix), VX-425, VX-580, VX-589, VX-426, VX-560, VX-441, VX-569.

**Required reading before any code:** same list as batch 1, PLUS `notes/TEXTKIT2_NOTES.md` §3–4 (VX-441 and VX-569 touch chrome beside `EditorTextView` / the title field — NO text-storage, layout or identity machinery changes; if a member seems to need one, STOP that member and record here), and VX-424's mechanism trace (below).

**VX-424's traced mechanism (the 2026-10-18 read-only scout, from the ticket):** the card-styled chip (`DragTitleChip`, `Core/Views/DragChipCanvas.swift:85-109`) is the one intended preview and draws on EVERY drag; the "weird card, no reorder" case is the drop being REFUSED — the gap rule in `Core/Views/SidebarLayout.swift:626-642`: `gap(for: .row(i)) = i` (hovering a row always means "insert before"), `destination` nil when `gap == dragged || gap == dragged + 1`. Consequence: dragging DOWN by one place always fails; side margins/headers/separators are dead zones (`SidebarView.swift:864`; the sidebar-wide `.onDrop` at `:392` deliberately ignores this token). Her report widens it: up-drags too — so instrument both directions before pinning (A-439-15). Fix shape: half-row before/after drop targets or `DropInfo.location` against row height, through `OpenListDragState.Target`, `SidebarLayout.OpenListDrop.gap`/`lineTop` (`SidebarLayout.swift:604-664`, `Features/Library/OpenListDrag.swift`, row attachment `SidebarView.swift:1135`). The pinned gap/destination/lineTop rules have tests to UPDATE deliberately; the before/after targets of one boundary must resolve to the same gap or the line flickers.

**Per member / pins / commits / checkpoint / environment / tests:** exactly as batch 1's sections (read them — they bind this batch identically). VX-425's Export item routes to VX-125's capability (batch 1 lands first). The VX-426 sweep records its class-completeness table (icon × tooltip) in this file.

---

## Review foci (written at plan time, for the cold reviewer — per REVIEW_PROMPT's foci rule)

1. VX-126/VX-125: is the export byte-identical to Copy full text per note (option A), with the round-trip proven by test, and is `Domain/VariorumDocument` still the format's ONE home with no import-acceptance change (VX-502's seam)?
2. VX-424: does the pin cover BOTH directions? Do the half-row targets resolve one boundary to one gap (no flicker)? Were the old pinned gap/destination/lineTop tests updated deliberately rather than deleted?
3. Registry discipline (P-1/P-2): is every new door declared once and rendered from the registry; is every refusal the operations layer's; is any door rendered where it can never act?
4. VX-332: can the quick-entry focus ask ever steal from a field, a sheet, or the tour?
5. VX-560: can ⌘←/⌘→ ever reach a first responder that is a text view?
6. VX-589/VX-580: do the sidebar filters/titles stay display-only (no view-model copies of persisted text; P3 untouched)?
7. No literal colours outside the token layer; `fixedSize` texts carry `lineLimit`.
8. VX-441: zero changes to text-storage/layout/identity machinery; chrome and finder-client protocol only.

---

## LIVE STATUS (the running record — updated per piece, in the same commit)

- Batch 1: BUILT + STAGE-VERIFIED (2026-10-27 03:15–03:28 MDT, claim `vx-439-b1-suites`) — implementer session 1 (`opus-implementer`, 2026-10-27). Seven members DONE
  (VX-125 · 126 · 570 · 553 · 552 · 332 · 602); VX-554 Done at her word (no code); VX-568 parked out of the run at her
  word. Headless at the END, on `61c6dd7eb`: core WHOLE PACKAGE `swift test` — 3,436 tests / 457 suites passed (5 known
  issues, the standing ones) + 32 / 4 passed + the MCP package 383 / 71 with ONE failure,
  `MCPHarnessTimeLimitTests.aPeerThatNeverAnswersInitializeFailsTheConnectNamedAndBounded` (19.3 s vs its 15 s bound,
  load average 25 — the VX-353 load class), re-run alone GREEN 3/3; the skipped lines are the 7 standing gated
  measurement/integration skips. `xcodebuild build-for-testing` GREEN. No revert in flight; the one Mac red-on-old run
  owed (VX-332) has its behavioral revert staged as `scratchpad/b1-revert/vx-332.patch` (gitignored, in the tree:
  the `.task` back to `focusRequest += 1`). STAGE RUN (DONE — results below): `xcodebuild -scheme Variorum
  -destination 'platform=macOS' test-without-building` with `-only-testing:VariorumTests/<suite>` for these 1
  suites (every suite over a changed source file, by grep of the changed types, plus all of `TutorialWalkTests`' suites;
  the exact command is `scratchpad/b1-revert/stage-command.txt`): AcknowledgmentsCopyTests. Then the VX-332 red-on-old run:
  `git apply scratchpad/b1-revert/vx-332.patch` → build → `-only-testing:VariorumTests/QuickEntryOpeningScopeTests` RED
  expected on `aNavigationBackToTheBookcasePutsTheCaretInItsQuickEntry` → `git checkout -- App/Variorum/Variorum/
  Features/Shelf/QuickEntryBar.swift` → rebuild → GREEN.
  STAGE RESULTS: the 152-suite run on `c790ecd76` — "Test run with 821 tests in 152 suites" with ONE failing test, 2
  issues: `ExportFacesTests.bulkExportGestureWritesTheWholeLibrary`, the VX-126 byte pin the batch's grep missed → updated
  DELIBERATELY (`36b98b750`), its suite re-run GREEN 6/6; 0 skipped lines; the only warnings are the test host's own
  launch-time `@Dependency(\.date)` noise (pre-existing, no test of ours). The VX-332 revert cycle: RED on the faithful
  revert, GREEN restored (12/12 over the four focus suites) — see VX-332's line. Tree clean at `36b98b750` (status and diff
  empty); no Variorum instance left (strict `pgrep` forms empty); stage released.
  - VX-125: W-439-1 IN-PROGRESS (the walk's defect — File ▸ Export Note… grey in Write; Ledger "B1 W-439-1 trace"): the
    mechanism is NOT yet traced — a registry-level pin is green on BOTH sides (hollow); the discriminating hosted probe
    `NoteExportMenuGateTests` is BUILT (build-for-testing green), owed a stage run with the walk's AX sibling reads; no
    fix lands until the mechanism is seen. The member as first built: DONE (`a73a7e7f4`) — `.exportNote` "Export Note…" (post scope, `noteScoped`, `.native`) on File ▸ (beside
    Export Library…, ⌥⌘S — C-125-1's sweep in the registry row), ⌘K, and both `note ▾` menus (Write's in NOTE contexts
    only, Takes'); one act `Core/Views/NoteExport` (flush → ONE read of `Queries.variorumDocumentText` + the display
    brain's name → save panel `<name>.md` → atomic write → receipt "Exported “x.md”."; a cancel says nothing; an empty
    note refuses before the panel); the helper's ⌥⌘S row; `ShellActions.noteOnScreen` lifted out of `duplicateNote`
    unchanged (the two share it). Pins `NoteExportTests` (6: byte-identical to Copy full text + re-import + no row; the
    default name; cancel; empty refusal; archived + sealed export; the declaration/chord/renderers) — build-for-testing
    GREEN; the suite GREEN at the stage window (below). (The record flip rode one commit late — a stale-read edit miss.)
  - VX-126: DONE (`9637e5be2`) — `Queries.bulkExportManifest`'s per-NOTE files are `variorumDocumentText` (option
    A — Copy full text's text, header + takes-carrying body); `Pools/` + `Readings/` byte-unchanged (C-126-1); the
    insurance export reads the same manifest. DELIBERATE byte-pin updates: `ExportProjectionTests.
    bulkExportManifestIsTotalOverLivePosts` (the two titled files gain `{t:"…"}`), `Phase13SurfaceQueryTests.
    readingAndBulkExportBodiesCarryTheMapping` (the same). New pin `DocumentFormatRoundTripTests.
    aLibraryExportReimportsEveryNoteWithItsTitleTagsAndTakes` (every note file == Copy full text; each re-imports
    through the door's own read with its title, tags and every take, re-exporting to its file's bytes; pools/readings
    plain). Core 4 suites GREEN headless (whole package GREEN at batch end). A FOURTH, app-side byte pin the batch's grep
    missed (`ExportFacesTests.bulkExportGestureWritesTheWholeLibrary` reads the written files back) went red at the stage
    run (2 issues — the titled files' new header) and was updated DELIBERATELY (`36b98b750`; 6/6 green). RED ON OLD, verified: the one-line
    behavioral revert (the note files back to `exportPost`) turned the new pin red with 13 issues (no header, tags lost,
    titles from the file name, takes dropped); restored by `git checkout` of the committed file (no revert in flight).
  - VX-554: DONE at her word (2026-10-27, in-session — the Ledger): no code; R-439-F554's disposition stands.
  - VX-570: DONE (`6da767d65`) — `.newNoteInBook` "New Note in This Book" ⌥⌘N (book scope; File ▸ beside New
    Note, ⌘K; the book foot's and Outline flow's "+ new note"/"+ new entry" declared as its `.surface` renderers at
    last), gated on the new `CapabilityContext.focusedPaneShowsBook` (wired in `RootView.wireWorkspace` to the key
    window's focused selection); `ShellActions.newNoteInThisBook` parks a `ShellRouter.BookMintRequest` (a fresh token
    per press) that `RootView` hands to the LIVE pane's `BookView` only; the book takes it once and runs its ONE mint act
    `mint(_:reveal:)` — which every foot/flow door now calls too — choosing by the pure `BookView.footMint(for:)`
    (gathering → planner, journal trait → entry, else note; C-570-1); refusals land on the book's own line (the
    operations layer's words, as the foot's do). R118: a NAMED exemption beside `.openBookAtNote` (a book-surface act,
    no post mode); the walk's sampled contexts gain the book-focus context (both JUSTIFIED EDITS, commented). Helper row
    ⌥⌘N. Pins `NewNoteInBookTests` (7: declaration/chord/grey-without-a-book; the foot-act choice; the request is the
    focused book's, a place speaks the note; a book mints a focused member; a gathering mints the planner's tagged note
    and holds nothing; a finished book refuses in the op's words and mints nothing) — build-for-testing GREEN; the
    suite GREEN at the stage window (below).
  - VX-553: DONE (`822122592`) — a BOOK's navigator foot renders from ONE ordered table, `BookFootDoors.book
    (journalTrait:finished:hasDeletedChapters:)`: "+ new chapter", then "+ new entry"/"+ new note" (none on a finished
    book — Round 3's rule), then "restore deleted chapter" (only while one waits) LAST, set apart by `recoveryGap` (6 pt
    over the foot's row gap). A-439-5's pick: "after, set apart" — the foot has no overflow/settings door that holds
    chapter acts. Each door's words, act and condition unchanged (`footDoor(_:)`, one case per door). Design row: pin
    `BookFootDoorsTests` (2: the order per state; restore never between the mint pair, always last, gap > 0) + the
    walk's capture (the orchestrator's) — build-for-testing GREEN; the suite GREEN at the stage window (below).
  - VX-552: DONE (`a6afef06a`) — the ONE quick-entry bar (`QuickEntryBar`, both hosts: the Bookcase band and the
    Library bar — the two doors that mint into the current wing; ⌘N is a menu item and books mint into their own wing)
    wears "in ‹wing›" at the box's trailing edge on its first line (muted small chrome, `lineLimit(1)`, ≤180 pt, the
    hover the whole fact), visible while she types; the name is the host's own `WingsModel.currentName` (the app's one
    wing, which follows the focused note — no new observation), Home when no wings model is handed; shown with ONE wing
    too (C-552-1). Design row: pin `QuickEntryWingLabelTests` (2: the words; both hosts compose the bar with the wing —
    source-read, the `theLibraryNoteRowMenuRendersItsDeclaredDoors` precedent) + the walk's capture (the
    orchestrator's, both voices) — build-for-testing GREEN; the suite GREEN at the stage window (below).
  - VX-332: DONE (`1c7b74f7b`) — TRACED MECHANISM (the VX-282 record's O-U6-1, confirmed by reading): the bar's
    `.task` took the waiting road (`armOpeningFocus` — `CaptureOpeningFocus`: wait for the window, take only a free
    keyboard) ONLY for the shell's first Bookcase mount (VX-326's one-shot `QuickEntryOpeningFocus` claim); every later
    mount raised the counted `focusRequest`, which `takeFocus` drops when the box is not yet in its window — the
    navigation-back shape — so a return never got the caret. FIX: every autofocus mount takes the waiting road; the claim
    type, its RootView state and its ShelfView/QuickEntryBar params RETIRE; a running tour stands the mount down
    (`QuickEntryBar.standsDown` ← `ShelfView.tourRunning` ← `RootView` `tourSlot.engine != nil` — W-U1a-1). The counted
    raise stays the explicit asks' (padding tap, title chip). Pins `QuickEntryOpeningScopeTests` (3): RED-ON-OLD
    `aNavigationBackToTheBookcasePutsTheCaretInItsQuickEntry` (the DELIBERATE update of
    `aNavigationBackToTheBookcaseKeepsTheBarsRaiseAsItWas`, which pinned the old road; `theClaimIsTrueExactlyOnce`
    retired with its type); GUARDS `aMountNeverTakesTheKeyboardFromAField`, `aMountDuringATourStandsDown` (+ its
    no-tour non-vacuity). build-for-testing GREEN. RED ON OLD, VERIFIED at the stage window: a FAITHFUL behavioral revert
    (the first mount takes the opening road, every later one the counted raise — VX-326's claim road exactly,
    `scratchpad/b1-revert/vx-332-faithful.patch`) left the launch cell GREEN and turned the navigation-back cells RED (3
    issues: no opening ask on the return, the counted raise taken, the caret NOT in the second box) — the ticket's
    mechanism reproduced; the no-tour non-vacuity cell of the stand-down pin went red with it (a later mount); the
    never-steal guard stayed green (a guard). (A first, cruder revert — every mount on the counted raise — also failed
    the launch cell, so the faithful one is the evidence.) Restored by `git checkout` of the committed file; GREEN after
    (the four focus suites 12/12).
  - VX-568: PARKED OUT OF THE RUN at her word (2026-10-27) — see Ledger
  - VX-602: DONE (`61c6dd7eb`) — the Help menu names each thing once: `.restoreTutorial`'s verb "Restore Field
    Guide…"; `TourOfferCopy.menuTitle` (the `.takeTour` verb) "Take the Onboarding Tutorial", its help-road sentence
    following ("Run it any time from Help ▸ Take the Onboarding Tutorial."); the undeclared field-guide door "Open the
    Field Guide" (C-602-1) from one constant (`Features/Help/HelpMenuCopy`) for the menu and its ⌘K twin; the two
    sentences that NAME the restore door follow it (its failure refusal reads the registry verb; the confirm's question
    "Restore the field guide?"). NOT re-worded (flagged, morning bundle 10): the confirm's detail ("This replaces the
    tutorial with a fresh copy…") and the receipt ("The tutorial is fresh — …"), which describe the object rather than
    name the door; the guide's seeded CONTENT (three lessons, bundle 3 — A-439-9). Pins `HelpMenuNamingTests` (4: the
    names, "tutorial" on one door only; the naming sentences; the old literals gone from menu/palette/registry; the
    guide content deliberately unchanged) + `TourOfferLineTests` DELIBERATE update (the title + sentence) —
    build-for-testing GREEN; the suite GREEN at the stage window (below).
- Batch 2: NOT-STARTED
- Ladder: NOT-STARTED
- Walks (orchestrator, per batch): NOT-STARTED

## THE MORNING BUNDLE (held for her — grows as the night runs)

1. Riders VX-373 and VX-409 were offered on the run ticket "if the run has room" — not adopted at 17 members; say the word and they ride the next sweep.
2. Every A-439-N PROVISIONAL above (1, 3–6, 8–12, 14, 16, 17) — built as ruled, reviewable at her pass.
3. **VX-602 — the field guide's own CONTENT still says "Help ▸ Restore Tutorial…" three times** (A-439-9: flagged, not
   edited — a content edit stales her real store's seeded guide and owes the A1 re-seed): `TutorialSeeder.swift` ~618
   (the welcome lesson: "Help ▸ Restore Tutorial… replaces the whole book…"), ~1411 (the Trash practice: "…Help ▸ Restore
   Tutorial… rebuilds the whole book."), ~1975 (the tags lesson: "That is exactly how Help ▸ Restore Tutorial… finds what
   to replace."). Her call: re-word the three lines + the re-seed in her window, or leave them.
4. Resolved live — VX-554 Done at her word (the door exists since VX-217; the ticket was stale).
5. Resolved live — VX-568 parked out of the run at her word (the trace is on the ticket).
6. **C-125-1 — Export Note…'s chord is ⌥⌘S** (⇧⌘E is Extract's; your words were "keyboard shortcut for saving note").
   It sits beside ⌘S-commits — cheap to re-chord if that reads wrong.
7. **C-126-1 — option A also reaches the scheduled plain-text insurance export** (same manifest): its per-note files gain
   the header + takes too, making the insurance round-trippable whole. Pools/ and Readings/ byte-unchanged.
8. **C-570-1 — ⌥⌘N's context is "the focused pane shows a book"** (any book mode; journal books mint entries; gatherings
   mint through the planner). A member note open in Write does NOT count (which book would it mean?) — say the word if you
   want it widened to the focused note's book.
9. **C-602-1 — the naming pass also renames Help ▸ "Open the Tutorial" → "Open the Field Guide"** (+ its ⌘K twin), since
   it opens the field guide and would otherwise sit confusingly beside "Take the Onboarding Tutorial".
10. **VX-602 — two neighbouring sentences still say "tutorial" for the field guide** (not door names, so not re-worded
    under A-439-9's menu-labels scope): the restore confirm's detail ("This replaces the tutorial with a fresh copy: …") and
    its receipt ("The tutorial is fresh — “the field guide” is on your Bookcase."). Say the word and they follow the door.
11. (grows)

## Ledger (findings, decisions, deaths, dispositions — append-only)

- 2026-10-27 kickoff: worktree seated at `aeee4d1e3`'s main; in-flight row pushed; VX-502 and VX-548 live in parallel (surfaces checked — export seam shared with VX-502, second merger rebases).
- 2026-10-27 **B1 fork F-554 (VX-554 — returned to the architect; the member is HELD).** TRACE (read, tree `c2e13f7e2`):
  the door the ticket says is missing EXISTS. VX-217 (merged with VX-214, 2026-10-13; in every build since 0.9.x) drew a
  gathering's New Note door exactly where the curated book's stands, through exactly the authority A-439-3 names: the
  navigator foot ("+ new chapter" then "+ new note" — `BookView.swift` ~956–1006) and the Outline flow's end ("+ new note
  in this gathering" — ~1856–1873), both `GatheringNoteDoor` over `Operations.newPostInGathering`, whose outcome the face
  reads from the ONE planner (`Queries.gatheringMintOutcome` → `GatheringMint`) the collect door shares; registry-declared
  `.newNoteInGathering` (`.surface`, `BookView.surfaceCapabilities`); ALWAYS drawn, greyed with the op's own reason where a
  mint can't land (R-VX214-3). The navigator (and so the foot) shows in Outline, Book and Read; only INDEX steps the
  navigator aside — and Index carries NO mint door on either kind (a curated book's Index has none either). So "match the
  curated book face's New Note placement" is already true on every face. What she could have met: (i) a gathering in
  Index; (ii) a greyed door (faint ink — e.g. a legacy finished gathering, a dead-tag or legacy-term rule) read as absent;
  (iii) no keyboard road (⌘N mints into the Library). PROPOSAL: (1) DISMISS AS ALREADY BUILT for the face (no pin can be
  red-on-old: the door is on the old tree) — the orchestrator's walk captures a gathering's foot + flow end in both voices
  as the evidence; (2) VX-570's ⌥⌘N, already ruled to route a gathering to this planner (A-439-4), is the one new door —
  a keyboard New Note from EVERY gathering face, Index included; (3) her morning bundle asks where she looked (if Index,
  a foot door there for BOTH kinds is a new placement no ruling makes). Alternatives: (b) add an Index-column mint door for
  both kinds now (unruled placement); (c) make the greyed door louder (contradicts R-VX214-3's faint-ink face).
- 2026-10-27 **B1 fork F-568 (VX-568 — returned to the architect; the member is HELD).** TRACE (read): the quick entry's
  prompt has NO fade animation anywhere in the app — no `withAnimation`/`.animation`/`repeatForever` reaches
  `QuickEntryBar` or `ShelfView` (the one `repeatForever` in `Theme/` is `MarqueeText`'s hover scroll). The only app-drawn
  blink is the TERMINAL voice's block cursor (`QuickEntryBar.swift` ~263–274: an 8×16 accent bar, opacity toggled HARD
  every 550 ms, drawn only while the box does NOT hold the caret — `showsBlockCursor` is false in Study). Her store is in
  STUDY (VX-346's report: "flashes Terminal … before settling into Study"), where nothing app-drawn blinks at all. What
  does move in Study is the SYSTEM caret: since VX-326 (merged 2026-10-14, eight days before her 10-22 note) the box takes
  the keyboard at launch, so AppKit's insertion indicator blinks at the box's first-line origin — exactly where the faint
  placeholder "new note — just start typing…" begins (`QuickEntryBar.placeholderOrigin` = the box's first-line origin, by
  VX-179 U3's rule). On macOS 14+ that indicator is `NSTextInsertionIndicator` (automatic mode "blinks and animates";
  `.visible` "disables animations" — Apple docs, via a read-only external-facts lookup; no source states the blink is a
  fade, none offers a public hard-blink switch; FB17103305: TK2 ignored `shouldDrawInsertionPoint` until macOS 27). So the
  likeliest reading of "the fading in and out flickering of new note" is the SYSTEM caret's animated blink sitting on the
  first letters of the placeholder — and VX-332 (focus on every return) will put it there on EVERY Bookcase arrival.
  A-439-8 as written ("remove the prompt's fade; the system caret's normal blink") has nothing app-made to remove in
  Study. OPTIONS: (a) build A-439-8's letter: the Terminal block cursor stops blinking (static prompt unfocused) — Study
  unchanged, so it likely misses her complaint; (b) the capture box (NOT the editor seam — `CaptureNSTextView` is a plain
  TK2 NSTextView) draws its OWN hard on/off caret (accent bar at the caret rect, the system's on/off cadence, the system
  indicator hidden via `shouldDrawInsertionPoint` false — reported honored on macOS 27) — her "nice normal cursor blink"
  literally, pinned by a pure blink-phase rule + a geometry oracle, owing a walk on 27.0.1 in both voices; (c) leave the
  caret and move the collision: the placeholder steps aside (hidden, or shifted past the caret) while the caret is in the
  EMPTY box. RECOMMEND: (b) if the architect accepts the platform risk, else (a)+(c); in every case a walk capture of the
  live caret in Study is the real evidence and her morning look decides.
- 2026-10-27 **B1 implementer calls (decided — the architect may veto in the same ruling):** **C-125-1** — ⇧⌘E is TAKEN
  (Extract Selection, `EditorCommands.keyEquivalent`); ⌥⌘E / ⇧⌥⌘E read as ⌥-variants of ⌘E (Use Selection for Find) and
  ⌘⇧E (Extract) — the convention the `.moveSelectionToTake` sweep already refused; **⌥⌘S** chosen: her own words for the
  door were "keyboard shortcut for saving note", it is the ⌥ "deliberate variant" of ⌘S (save this note OUT, as a file),
  and the sweep finds it free (`s` chords: ⌘S, ⌘⇧S, ⌃⌘S; `EditorTextView.performKeyEquivalent` matches bare ⌘S only).
  **C-126-1** — option A binds the per-NOTE files; `Pools/` (scraps areas, never a note — Copy full text has no door on
  one) and `Readings/` (a per-post `exportPost` consumer predating the header) stay byte-unchanged; the scheduled
  plain-text insurance export (`MarkdownInsurance`) reads the SAME manifest, so it gains the header + takes too ("bulk
  exports round-trip whole") — named for her bundle. **C-570-1** — ⌥⌘N on a JOURNAL-TRAIT book runs that book's foot
  door ("+ new entry" — `newEntry`), on a gathering the gathering door, else "+ new note": the key is the foot's act, never
  a second one; a finished book REFUSES in the op's words (the foot hides its door there; the key speaks). The context
  fact is "the focused pane shows a book" (any mode — the note box's book context included); a note pane in Write is not a
  book context (which book would it mean?). **C-552-1** — the label shows with ONE wing too (her "always"); a muted "in
  ‹wing›" at the quick-entry band's trailing edge, from the host's `WingsModel.currentName`. **C-602-1** — Help ▸ "Open the
  Tutorial" opens the FIELD GUIDE (the same book "Restore Tutorial" restores), so the naming pass renames it "Open the
  Field Guide" too (and ⌘K's twin row); without it the menu would read "Open the Tutorial" beside "Take the Onboarding
  Tutorial" — the exact confusion she named.
- 2026-10-27 **ARCHITECT RULING on the B1 forks (the orchestrator, against the record and TEXTKIT2_NOTES; both bundled for her morning):**
  **R-439-F554 — VX-554 is RECORD-ONLY, the proposal adopted whole.** (1) The face door exists on the old tree (VX-217),
  so no pin can be red-on-old — the hallucination guard's "record it, don't fix it" applies; the member lands NO code.
  The orchestrator's batch-1 walk captures the evidence: a gathering's navigator foot and Outline flow end in BOTH voices,
  Index on both kinds (no mint door, matching the curated book), and the navigator-collapsed state (a candidate for what
  she met). (2) VX-570's ⌥⌘N is the one new door and reaches every gathering face, Index included (A-439-4 + C-570-1).
  (3) Linear: VX-554 → Needs Lillian with the trace; the morning bundle asks where she looked. NOT built tonight: an
  Index-column mint door (a placement no ruling makes) and a louder greyed face (contradicts R-VX214-3) — hers to order.
  **R-439-F568 — VX-568: no custom caret tonight; probe first, then only a SUPPORTED knob, else record-only.**
  Option (b) is REFUSED for this run: TEXTKIT2_NOTES §3 names custom insertion-point drawing a TK1-fallback trigger class
  ("design around it or accept the system caret"), and the FB note the trace found (TK2 ignored `shouldDrawInsertionPoint`
  until macOS 27) makes the hide-the-system-caret half rest on a ONE-point-release-old behavior — a flip either way at
  27.x leaves two carets or none. A cosmetic preference does not buy that risk overnight without her eye. Instead:
  (1) PROBE FOCUS CHURN, bounded — instrument the capture box's first-responder acquisitions/resignations and the
  indicator's appearance while idling on the Bookcase and across window key/occlusion changes. The indicator ANIMATES IN
  on every focus gain, so repeated focus toggling would read exactly as "fading in and out flickering" and would be a BUG:
  if churn shows, THAT is the member's traced mechanism — fix it with a red-on-old pin and stop there. (2) If no churn:
  look for a SUPPORTED, documented knob that plain-ifies the system indicator's blink (NSTextInsertionIndicator display
  mode / automatic-mode options) reachable WITHOUT private API; subview enumeration is legal only as a DEBUG probe, and a
  shipped mechanism may use it only if nothing documented exists AND it degrades to default behavior when the subview
  isn't found (the degradation pinned). (3) If neither lands: BUILD NOTHING for VX-568 — Needs Lillian with the full
  trace and the options priced ((a) Terminal-only no-op for her store; (b) with its platform risk; (c) placeholder
  stepping aside, which bends the text-alignment instinct and hides teaching exactly when a fresh store looks). Terminal's
  block cursor stays untouched in every arm; A-439-8's "remove the fade" premise is RETIRED (nothing app-made fades).
  The walk captures the live Study caret either way.
  **The C-calls are all CONFIRMED** (C-125-1 ⌥⌘S · C-126-1 incl. the insurance export gaining header+takes · C-570-1
  incl. the Write-pane exclusion · C-552-1 · C-602-1), each named in the morning bundle for her veto.
- 2026-10-27 HER LIVE RULING (in-session): VX-554 Done at her word — 'gathering does have a new note door - that ticket must've been stale. it can be marked complete.' The walk's F-554 evidence duty and bundle item 4's question are retired; R-439-F554's no-code disposition stands. On VX-568 she asked what the issue is (her 10-22 note quoted back to her); R-439-F568 unchanged pending her reply.
- 2026-10-27 HER LIVE RULING (in-session) on VX-568: "oh. i'm talking about the cursor itself - yeah, it is what mac os uses probably, it's just what the cursor looks like in the new note line. it's a subtle issue - just remove it from this run and leave it parked for later for my reconsideration at a later point. doesn't need to be this run." VX-568 is OUT of this run (no churn probe, no knob work — none was started; nothing instrumented); Linear Parked with the trace (the orchestrator's). R-439-F568 is retired with it.
- 2026-10-27 B1 STAGE LEG (03:15–03:28 MDT, `vx-439-b1-suites`): the prepared command first packed all 152 suites into ONE `-only-testing:` flag (zsh does not word-split an unquoted variable — the coordinator caught it); rebuilt as one flag per suite. Run 1: 821 tests / 152 suites, 1 failing test (`ExportFacesTests.bulkExportGestureWritesTheWholeLibrary`, VX-126's missed app-side byte pin — fixed deliberately, `36b98b750`, 6/6). VX-332 red-on-old: a crude revert (every mount on the counted raise) also broke the launch cell, so a FAITHFUL revert (VX-326's one-shot road) was run — launch green, navigation-back red (3 issues), restored green. Tree clean, no instances, released.

## WALK PART 1 (the orchestrator, 2026-10-27 03:30–03:52 MDT, claim vx-439-b1-walk; captures `walk-shots-vx439/`, gitignored)

Dev store as found: an ACCOUNT-LESS RESTORED library held as of Oct 20 (VX-522's banner sentence), EMPTY (no books, no
notes), Study voice, dark. The hold banner, the words band card, and every sync/Castle/key door UNTOUCHED (the
coordinator's constraint for VX-502's walk). Walk content minted through the app's own doors: one tagged bookless note
("{#walk}" microsyntax — tag chip applied ✓), "Walk Book" + one ⌥⌘N member. Left in place for walk part 2.

GREEN, seen live:
- **VX-332** — ⌥⌘[ back to the Bookcase, typed immediately with no click: the text landed in the quick-entry box,
  caret visible (capture 03). Launch focus intact (the mint leg typed straight into the box).
- **VX-552** — "in Home" at the band's trailing edge on the Bookcase host (captures 02/03); at 820 pt the placeholder
  elides and the label sits clear — no collision (capture 04). Library host deferred to part 2.
- **VX-553** — the book foot reads "+ new chapter" / "+ new note" adjacent; no restore row between (capture 07a; a
  fresh book holds no deleted chapter — the order pin carries the arrangement).
- **VX-570** — ⌥⌘N inside Walk Book minted a member (book · 1 note, live caret in the new block; capture 07). In a
  Write note pane the menu item reads disabled — C-570-1's context rule behaving.
- **VX-602** — the Help menu enumerates "Open the Field Guide · Take the Onboarding Tutorial · Restore Field Guide…"
  (AX read); File carries "New Note in This Book" and "Export Note…" beside "Export Library…".
- VX-554's captures: MOOT — she closed the ticket live ("that ticket must've been stale").

**W-439-1 — DEFECT (walk-caught, to the B1 implementer): File ▸ Export Note… is DISABLED with a note open in Write.**
Proven live with the File menu OPEN (AX `enabled` = false while the menu tracked; ⌥⌘S no-ops; the chord itself is
declared right — AXMenuItemCmdChar S, mods ⌥⌘). Her ask is precisely a per-note export of the open note, so the
primary context is dead. Mechanism to trace implementer-side (suspect: the capability's availability rule reads a
context fact the Write pane never sets). REQUIRED: a red-on-old pin asserting `.exportNote` is AVAILABLE in the
open-note/Write context, then the fix, then walk part 2 re-runs the export legs (Export Note ⌥⌘S → save panel →
file bytes vs Copy full text; Export Library headers; the gathering leg, unwalked in part 1).

Walk part 2 owes: the export legs, the gathering ⌥⌘N/Index leg, VX-552 on the Library host, cleanup of the minted
walk content, and the voice note (store found and left in Study/dark; no voice flip was needed in part 1 — part 2
captures Terminal where visual).
- 2026-10-27 **B1 W-439-1 trace (the implementer, headless — NOT yet a mechanism; no fix written, per the hallucination guard).** What reading PROVES: (1) the gate is right — `.exportNote` is `noteScoped` (`writeEditorAttached || takesBoardAttached || mode != nil`), and `NoteExportTests.theDoorIsDeclaredOnce…` already asserts `.act` in `CapabilityContext(mode: .write)` and with only an attached editor; it ran GREEN at the stage, so a registry-level pin is green on BOTH sides (hollow) and cannot be the red-on-old the order asks for. (2) The menu item reads exactly the same gate as its siblings (`.disabled(!enabled(.exportNote))` → `session.commandRouter.isEnabled` → `currentContext()`), the wiring is the registry's one idiom, and the router's facts are all observable (`activeMode`, `editorRouter.active`). (3) This app's `CommandGroup` items DO track live state elsewhere (⌥⌘Z's title/enablement in `after: .undoRedo`; ⌥⌘N in `replacing: .newItem` — the walk saw it act in a book and grey in Write), so a blanket "CommandGroup items are stale" (Apple forums thread 667768, an external lookup) does not explain one grey item. TWO candidate mechanisms remain, neither provable headlessly: (A) a ⌥⌘S-specific failure — a Swift Forums report (macOS 13.5, unresolved) has ⌥⌘S failing on a `CommandGroup` "Save As…" item beside a ⌘S item while ⌘S, ⇧⌘S and other ⌥⌘ letters worked; our File menu carries ⌘S (Commit Take) beside ⌥⌘S; a global App Shortcut on ⌥⌘S was the forum's suspect; (B) a stale `after: .importExport` group (its other items gate on `session == nil`, so the group may be re-evaluated only rarely — Export Block as Markdown… shares it and would be grey too). DISCRIMINATING EVIDENCE OWED, one short stage slice: (i) `-only-testing:VariorumTests/NoteExportMenuGateTests` (mounts the real shell, opens a note the shell's road, reads `isEnabled(.exportNote)` and `.saveNoteVersion` as the menu does — RED ⇒ a context bug, its message prints mode/editor; GREEN ⇒ the menu surface); (ii) the walk's AX reads in the same Write state: File ▸ Export Block as Markdown… (same group, `writeEditor` gate), Save a Version… (⌘⇧S, `after: .newItem`), Duplicate with Tags (`noteScoped`, `after: .newItem`), and `defaults read -g NSUserKeyEquivalents` + the app domain's (a global ⌥⌘S App Shortcut). Fix by outcome: probe RED → trace the context; Export Block grey too → (B), move Export Note into the `after: .newItem` note group beside Save a Version (the same doors' group; chord kept); only Export Note grey → (A), a chord change, which is HER call over C-125-1 (proposal: ⌃⌘E or ⇧⌥⌘E). The pin then is the walk's AX read (a menu item cannot be pinned headlessly — the row-67 precedent).
