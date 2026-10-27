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

- Batch 1: IN-PROGRESS — implementer session 1 (`opus-implementer`, 2026-10-27). Required reading DONE (CLAUDE.md + canon,
  this record top→brief, SurfaceContracts whole, the resiliency protocol, the 13n-a document-format record, the capability
  registry + `EditorCommands`). Every member SURVEYED against the tree before code; TWO FORKS returned to the architect
  (Ledger, 2026-10-27 "B1 fork F-554" and "B1 fork F-568"); no code written yet; no revert in flight.
  - VX-125: NOT-STARTED — settled design: `.exportNote` (File ▸ Export Note…, ⌘K, both `note ▾` menus), chord **⌥⌘S**
    (⇧⌘E is Extract's — B1 call C-125-1 below), one act `NoteExport` (flush → `Queries.variorumDocumentText` → save panel
    `<display title>.md` → write; reads only).
  - VX-126: NOT-STARTED — settled design: `bulkExportManifest`'s per-NOTE files through `variorumDocumentText` (option A);
    Pools/ and Readings/ unchanged (call C-126-1); the deliberate byte-pin updates; a library→re-import round-trip pin.
  - VX-554: HELD on fork F-554 (the door the ticket asks for already exists — see the Ledger).
  - VX-570: NOT-STARTED — settled design: `.newNoteInBook` ⌥⌘N (File menu + ⌘K; the book foot's and Outline flow's
    "+ new note"/"+ new entry" declared as its `.surface` renderers), gated on a new `focusedPaneShowsBook` context fact,
    delivered to the focused pane's `BookView` as a one-shot request that runs the SAME act its foot door runs (book →
    `newPostInReading`, journal-trait book → `newEntry`, gathering → `newPostInGathering`); refusals speak the op's words
    (call C-570-1).
  - VX-553: NOT-STARTED — settled design: the foot's order as data (`BookFootDoors`), restore last and set apart.
  - VX-552: NOT-STARTED — settled design: `QuickEntryBar` (both hosts — Bookcase + Library) wears the current wing's name
    as a muted label, from the host's `WingsModel.currentName` (call C-552-1: shown with one wing too — "always").
  - VX-332: NOT-STARTED — settled design: every autofocus mount takes the waiting/never-steal opening road; the one-shot
    `QuickEntryOpeningFocus` claim retires; the bar stands down while a tour runs; `aNavigationBack…KeepsTheBarsRaiseAsItWas`
    updated deliberately (it pins the old behavior); red-on-old pin = a navigation back puts the caret in the box.
  - VX-568: HELD on fork F-568 (the mechanism in her voice is not the app's — see the Ledger).
  - VX-602: NOT-STARTED — settled design: "Restore Field Guide…", "Take the Onboarding Tutorial", and (call C-602-1)
    "Open the Field Guide"; guide CONTENT speaks the old name three times — FLAGGED, not edited (morning bundle 3).
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
4. (grows)

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
