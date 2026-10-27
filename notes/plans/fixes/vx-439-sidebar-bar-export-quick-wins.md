# VX-439 — Run: sidebar, bar & export quick wins

**Ticket:** VX-439 (Umbrella, run ticket) · **Project:** v1 release readiness · **Branch:** `vx-439-run-sidebar-bar-export-quick-wins` · **Worktree:** `~/dev/variorum-vx-439` (the Pro) · **PR:** `VX-439: …` (merge commit only)

**STATUS: OPEN — kickoff 2026-10-27, overnight run (architect-phase).** As of L1 (2026-10-27 morning): both batches
built and stage-verified; walks part 1 + 2 done; ladder round 1 done and its L1 fixes built, pushed and headless-green
on the tree merged with VX-548 (`2b33e8bb6`) — PENDING the fix-verify stage window, the evidence slice, then round 2.

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
  - VX-125: DONE as built; W-439-1 OPEN-INTERMITTENT (the walk's grey File ▸ Export Note… in Write — seen once in walk
    part 1, NOT reproduced by the diagnostic slice's AX matrix or its two replays; the timeboxed headless pass did NOT land
    a mechanism — Ledger "B1 W-439-1 timebox"; batch 1 closes without it, the morning bundle carries it). The member as first built: DONE (`a73a7e7f4`) — `.exportNote` "Export Note…" (post scope, `noteScoped`, `.native`) on File ▸ (beside
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
  - VX-552: DONE (`a6afef06a`; the toolbar's door added at L1 M-2, below) — the ONE quick-entry bar (`QuickEntryBar`,
    both hosts: the Bookcase band and the Library bar; ~~"the two doors that mint into the current wing; ⌘N is a menu
    item"~~ — CORRECTED at L1 (M-2): the window toolbar's New Note button mints into the current wing too and is the
    very door her ticket names; ⌘N is the fourth such door, a menu key with no room beside it; books mint into their
    own wing)
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
- Batch 2: BUILT + STAGE-VERIFIED (2026-10-27, claim `vx-439-b2-suites` 05:30–06:09 MDT) — 3,057 tests / 495 suites on
  the merged tree; three reds were the batch's own pins (two rig/observable corrections + batch 1's missed ⌥⌘S chord
  sweep, `0f77f2d95`) and re-ran GREEN; one red, `DestructiveUndoWarningTests.redoNeverAsks`, is PRE-EXISTING ON MAIN
  (same red on `dd469951e`'s own build — ticket proposed); R-O / R-G / R-T each red exactly as named, green restored; the
  export seam (ExportFacesTests 6, PlaintextExportBringInRoadTests 5, U2WordsTests 13) green on the merged tree. Tree
  clean, no instances, stage released (Ledger "B2 STAGE LEG — RESULTS"). Every member's line below reads STAGE-VERIFIED
  (flipped from "PENDING the stage run" at L1, n-4); the walk is the orchestrator's. — implementer session 2 (`opus-implementer`, fresh); preflight read
  (CLAUDE.md + canon, this record whole, SurfaceContracts whole, the resiliency protocol, TEXTKIT2_NOTES §3–4, the
  capability model, VX-283's U2b–U2d drag history). All eight members BUILT and pushed; origin/main (VX-502) merged in at
  `0a30e8b09` (Ledger "B2 — THE SECOND-MERGER STEP"). Headless at the END on the merged tree: core `swift test` 3,439/457
  passed (5 known) + 32/4, MCP 383/71 with the VX-353 timing flake re-run green 3/3; `xcodebuild build-for-testing`
  GREEN (default DerivedData = the fixed tree). **NO REVERT IN FLIGHT** — `git status` clean; the three revert trees are
  pre-built in `scratchpad/b2/dd-r{o,g,t}` (Ledger "B2 — THE NAMED REVERTS"). THE STAGE RUN (RAN 05:30–06:09 MDT —
  the Ledger's "B2 STAGE LEG — RESULTS"; the plan as it was written): `scratchpad/b2/stage.sh` (gitignored; `zsh -n` clean), run from `App/Variorum`: `chunk1`…`chunk5` — the 495
  suites of `scratchpad/b2/stage-suites.txt` (every suite in a test file naming a changed type — the grep rule — ∪ all 11
  of `TutorialWalkTests.swift`'s suites ∪ `ExportFacesTests`, `PlaintextExportBringInRoadTests`, `U2WordsTests` for the
  merged export seam; `NoteExportMenuGateTests` EXCLUDED — batch 1's crashing probe, untouched), 100 suites per
  `test-without-building`, each log's "Test run with N tests" line read (VX-604); then `rev_ro`, `rev_rg`, `rev_rt` on
  their own trees (expected reds named in the Ledger). A shorter fallback if the window is tight: `focused` (197 suites,
  `scratchpad/b2/stage-suites-focused.txt` — the suites over the changed behaviors). Members in order:
  - VX-424: BUILT (batch 2's commit) — STAGE-VERIFIED at the B2 stage leg (the mounted + source-read pins and the R-O/R-G revert cycle).
    INSTRUMENT (`295bf3794`, removed `941728f54`): the rule refuses only DOWN BY ONE; up-drags land on the hovered row's
    top whichever half (Ledger "B2 VX-424 — THE INSTRUMENT"). FIX: each Open row wears `OpenListRowHalves` — an overlay
    INSIDE its gestures and its own drop, two clear shaped halves stacked with no gap, each main's classic
    `dropDestination(for:action:isTargeted:)` (the road her hands use; the end zone's own shape): the UPPER half names
    `Target.before(note)` (the slot before the row), the LOWER `Target.after(note)` (the slot after it); the halves reach
    the list's side margins (`reach: scrollingSectionMargin`, dead room before) and take hits ONLY while this list's own
    drag is in flight (`.allowsHitTesting(state.dragging != nil)` — at rest every row door is exactly as before; a foreign
    drag never meets them). The row's own drop stays UNDER the halves as its floor (`.before(note)`, the pre-VX-424
    landing) — should a half ever not be offered the drag, the row behaves exactly as before, never dead. Pure rule:
    `Hover`/`Target` `.row` → `.before`/`.after`; `gap(.after(i)) = i + 1`; one boundary's two halves name ONE gap, so the
    line never moves crossing it (and the last row's lower half = the end zone). `destination`/`lineTop` unchanged.
    PINS (`OpenListDragTests.swift`): NEW `aDownByOneDropLands`, `anUpwardDropLandsOnTheHalfItIsReleasedOn`,
    `oneBoundarysTwoHalvesDrawOneLine`, door `aDownByOneReleaseLandsWhereTheLineWas` +
    `anUpDragReleasedOnARowsLowerHalfLandsJustBelowIt`, face `eachRowsTwoHalvesAreDropsOnMainsRoadLiveOnlyWhileItsDragIsInFlight`,
    mount `theRowsTwoHalvesSplitItAtItsMidlineAndReachTheListsEdges` + guard `atRestTheHalvesTakeNoClickSoTheRowsDoorsAct`;
    DELIBERATELY EDITED (annotated "VX-424", none deleted): the four pins whose subject was "a row names the slot before
    it" now state the halves (`aRowsUpperHalfNamesTheSlotBeforeIt…` ← `theTargetedRowNamesTheSlotBeforeIt…`,
    `everyDropLandsOnTheSideOfTheRowItsHalfNames` ← `everyDropLandsBeforeTheTargetedRow`,
    `everySlotIsReachedAndOneBoundarysTwoHalvesNameOneSlot` ← `everySlotIsReachedByExactlyOneTarget`,
    `theLineSitsOnTheBoundaryTheHalfNames` ← `theLineSitsAtTheTargetedRowsTop`), `aTargetChangeMovesTheLine` walks halves,
    the own-place pins name four halves, every other `.row(x)` reads `.before(x)` (same slot). RED ON OLD, HEADLESS —
    VERIFIED: a replica (scratchpad `vx424/replica/`: the REAL `SidebarLayout.swift`, `OpenListDrag.swift`, `OpenNotes`
    cut verbatim, a two-method `WorkspaceModel` stub, the Rule + Door suites' 29 bodies transformed mechanically) — the
    fixed tree **1020 checks, 0 failed**; under the named revert **R-H** (`gap(for: .after(i))` → `i`: the pre-VX-424 rule
    exactly, a row's either half naming the slot before it) **402 failed, in exactly the 13 pins that state the halves**
    (the five new direction/flicker pins, the four re-stated, `aTargetChangeMovesTheLine`, both own-place pins, the door's
    boundary-crossing leg) — the down-by-one and the up-drag pins among them. The mount/face pins and their reverts
    R-O (the overlay line removed) / R-G (`.allowsHitTesting(true)`) are the stage's (READY list). build-for-testing GREEN.
    DELIVERY (that AppKit offers a real drag to the halves) has no headless pin and no synthetic road (VX-375): her hand
    check is the evidence — drag a row down one (release on the next row's lower half), up one (the row above's upper
    half), to the end, and watch the line stay put crossing a boundary. SurfaceContracts' Open-list drop sentence owes its
    closeout edit (A-439-15, pointer VX-424 — the orchestrator's).
  - VX-425: BUILT (batch 2's commit) — STAGE-VERIFIED at the B2 stage leg (`SidebarNoteRowMenuTests` + the walk/export/registry suites).
    Feature (no bug pin; registry + source-read + state pins). The Open list's rows and Starred's NOTE rows carry, on
    right-click: [Open beside · Open in New Window · Star] · **Rename…** · **Move to Wing ▸ / Copy to Wing ▸** (from the
    note's OWN wing; drawn only while another wing exists — `WingNoteDoors`, P-2) · **Export Note…** (VX-125's one act,
    this row's note) · [Close · Close All Notes] · **Delete Note…** LAST, set apart by a divider (the one shared confirm
    `NoteDeletion.ask`/`.deleteNoteConfirmDialog`/`fire` — its signal closes the note's Open rows and moves panes off it);
    Starred's note rows the same minus the Open-list acts; a starred BOOK keeps the book row menu. The ✕ is unchanged
    (close-only, "the note itself is untouched"). The recorded "the Open strip does not render Delete" decision is
    REVERSED at her ask (comments rewritten, `SidebarView.contextMenuCapabilities`). REGISTRY: NEW `.renameNote` ("Rename…",
    `.contextMenu`, `always` — the door carries its row; its renderers: the Library's note rows, whose undeclared
    "Rename…" it now is, and the sidebar's) — A-439-16's PROVISIONAL inline-vs-title-field call resolved to the surface's
    EXISTING idiom: the Library's "Rename Note" alert, hoisted ONCE into `Features/Library/NoteRename.swift`
    (`noteRenameAlert`, seeded with the STORED title — R6-3; the write is `LibraryViewModel.rename` → `renameContainer`;
    the Library now presents the same hoisted ask, words unchanged). `.exportNote` gains `.contextMenu`;
    `SidebarView.noteRowMenuCapabilities = [.renameNote, .exportNote]` joins the walk's union (a JUSTIFIED EDIT). The
    wing read: `WingFollow.crossWingIDs` (the other-wing notes' wing ids, bounded by the rows — P1), keyed on the Open +
    starred note rows; `RootView` hands the column its `wings`. DELIBERATE pin edits: `NoteExportTests.theDoorIsDeclaredOnce…`
    (+ `.contextMenu`), `CapabilityRegistryTests.theContextMenusRenderExactlyTheDeclaredContextDoors` (+ the new union line).
    PINS `SidebarNoteRowMenuTests` (6): the declarations; the Open row's order (acts · Close · Close All · Delete, divider
    before Delete; the ✕ unchanged); the shared roads (stored-title seed, own-wing doors, this row's export, the one
    delete ask, the three hosted asks); Starred's note vs book rows; the rename seed + road on a store (stored, never the
    display date; trimmed; blank → NULL); `crossWingIDs`. build-for-testing GREEN.
  - VX-580: BUILT (batch 2's commit) — STAGE-VERIFIED at the B2 stage leg (`SidebarRowLeadsTests` 4, incl. a mounted, live-typing pin).
    A-439-11 as ruled: default ON, NO setting. The sidebar's note rows (the Open list's — title, drag chip, menu words —
    and Starred's NOTE rows) are called by `noteRowLabel` = the note's PRELIMINARY title where it has one, else the name
    every surface gives it. The preliminary title is the LIBRARY's one brain exactly — `NoteCardFace.card(…)` over the
    Library's own bounded opening read (`NoteCards.load`, words only) — for exactly the notes the Library leads with
    words (no stored title, not a `'journal'`-profile daily entry, at least one word; a heading rendered, a long opening
    capped at a word edge, 48 chars); `Features/Library/SidebarRowLeads.read`, ONE bounded read (the rows' container facts,
    then words only for the unnamed ones — a sidebar of named notes reads no words), HELD by a `.task(id: noteRowIDs)`
    observation so her typing renames the row live (row 18's live-title law), the row's marquee truncating it at rest. No
    divergence to unify: the sidebar had no derivation of its own (it showed `DisplayTitle`, the date). DISPLAY ONLY —
    `WorkspaceModel.readTitles`/`DisplayTitle` (the pane line, back chip, View ▸ Open Note rows, exports, the same-note
    refusal) untouched (guard pin); rename still seeds from the STORED title (VX-425). DEBUG oracle
    `SidebarGeometry.openRowLabels`. PROVISIONALs (morning bundle 12): the Library's 48-char lead cap kept (her "maybe
    fewer words than the library shows" — the row's width truncates first at any normal sidebar width); View ▸ Open
    Note's menu rows keep the display name (the ask was "the lefthand bar"). build-for-testing GREEN.
  - VX-589: BUILT (batch 2's commit) — STAGE-VERIFIED at the B2 stage leg (`OpenListStarredFilterTests` 6 + the drag/settings suites).
    A-439-10 as ruled: a LOCAL preference (`UserDefaults` key `openListHidesStarred`, `@AppStorage` — never the synced
    `setting` table), default OFF, the pane named: **Settings ▸ General ▸ "Open notes"**, beside its kindred "Keep open
    notes across launches" (catalog row `hideStarredFromOpen`, "Hide starred notes from Open", searchable by her words
    "starred", "duplication", "tabs"). When on, the Open list DRAWS the strip less every note wearing the union star
    (`SidebarLayout.OpenListStarredFilter.displayed`, the strip's order); DISPLAY ONLY — the strip itself (order, ⌘⇧n keys,
    closing, ⇧⌘W landings, following, the View ▸ Open Note menu) is untouched, so a row returns the moment its note is
    unstarred or the setting turns off. Every Open-list reader of the drawn rows moved to `openListRows` (the fit count,
    the headed-group count, the bottom padding, the section window's current row, the rows, the line, the end zone).
    THE DRAG among the drawn rows: each drop hands the door the drawn rows (`displayed:`); the target and the own place
    are judged among them (where the line was drawn), and the landing names the STRIP's slot right before the drawn row
    at that slot, or right after the last drawn row (`OpenListDrop.stripGap` — the identity with nothing hidden, so every
    VX-288/VX-424 pin still describes the list; headless replica 1147 checks / 0 failed incl. this suite's four pure/door
    pins). The ⌘⇧n badge stays the STRIP's key (so a hidden starred row's number is skipped — honest: the badge says
    what the key does) — PROVISIONAL (bundle 13). The first-row DEBUG oracles key on the DRAWN first row (= ordinal 1 with
    nothing hidden). CONSEQUENTIAL pin edits (VX-139's shape, annotated): General's catalog cap 6 → 7 in
    `SettingsShapeTests.theAppearanceControlIsOnTheShortOpeningPane` and `DiagnosticsPaneTests` (the new row sits BELOW
    keep-open-notes; the short dials still top the pane ~~— the walk captures the pane for the fold~~ — CORRECTED at L1
    (m-4): no capture of General with its seventh row exists; walk part 2's "33-settings-general" shows the MCP pane;
    the live look is owed to the evidence slice); the drop face pins read
    `displayed: rows` (deliberate). PINS `OpenListStarredFilterTests` (6): the preference; the filter; the identity
    mapping (exhaustive 1…6); the hidden-row mapping incl. the drawn own place; the door landing while the hidden note
    stays open; the wiring. build-for-testing GREEN.
  - VX-426: BUILT (batch 2's commit) — STAGE-VERIFIED at the B2 stage leg (`IconTooltipTests` 4 + the touched suites). A-439-17: the sweep
    of every ICON-ONLY door in the sidebar (and its window toolbar) and the note's face (context bar, masthead, both
    bottom bars) — the table below. The one door that said NOTHING on hover was the toolbar's New Note (now "New Note
    (⌘N)", ⌘N's registry words — the toggle beside it says "Toggle Sidebar (⌃⌘S)"). Every other icon-only door already
    had a tooltip, but six of them opened with an explanation rather than the door's NAME (the tester's complaint: the
    copy-like Snippets icon read as copy/paste): each now LEADS with a one-word descriptor, an em dash, then what it
    said (PROVISIONAL bundle 14 — descriptor-led rather than a bare word, so her ruled teaching sentences survive).
    PINS `IconTooltipTests` (4): the masthead icons; the badge + the bars' glyphs; the wiring (both "?" doors, the
    toolbar, every `.iconOnly` masthead door wearing `.help`); a guard over the rows that already named themselves.
    build-for-testing GREEN.

    **VX-426 — THE ICON × TOOLTIP TABLE (class completeness; scope: the sidebar + its toolbar, the note's face).**

    | # | Where · door (glyph) | Tooltip before | After |
    |---|---|---|---|
    | 1 | Toolbar · Toggle sidebar (`sidebar.leading`) | "Toggle Sidebar (⌃⌘S)" | unchanged — names itself |
    | 2 | Toolbar · New note (`square.and.pencil`) | — none — | **"New Note (⌘N)"** (`.newPost`'s `menuTitle()`) |
    | 3 | Starred row · ★ | "Un-star this — it leaves the Starred list; nothing else changes." | unchanged |
    | 4 | Open row · ✕ | "Close this row — the note itself is untouched (…)" | unchanged |
    | 5 | Context bar · ← | "Back to ‹origin› (⌥⌘[)" · grey "Nothing to go back to — …" | unchanged |
    | 6 | Context bar · → | "Forward to ‹destination› (⌥⌘])" · grey "Nothing to go forward to — …" | unchanged |
    | 7 | Context bar · book (`book`) | "Open “‹book›” at this note (⌘-click …)" · "This note is in N books — …" · grey "This note isn't in any book yet" | unchanged (her #55 face) |
    | 8 | Context bar · tray badge (⌫ N) | "N blocks deleted from this note — click to put any of them back" | **"Tray — N blocks deleted from this note; click to put any of them back"** |
    | 9 | Context bar · AI lock (`lock`) | "Private — click to change" | unchanged |
    | 10 | Masthead · book panel (`book.closed`, members only) | "Show this note's book beside the draft — …" | **"Book — this note's book beside the draft: its chapters and notes; click one to open the book there"** |
    | 11 | Masthead · tray (`tray`) | "What this note has set aside: …" | **"Tray — what this note has set aside: …"** |
    | 12 | Masthead · scraps (`square.on.square.dashed`) | "Show the scraps beside the draft — drag one into the page (⌥ carries its whole fan)" | **"Snippets — show them beside the draft; drag one into the page (⌥ carries its whole fan)"** |
    | 13 | Masthead · references (`books.vertical`) | "Show the note's references (sources beside the draft)" | **"References — the note's sources, shown beside the draft"** |
    | 14 | Masthead · tag door (`number`) | "Tag this note — opens a field … (⌘⇧I)" · open "Put the tag field away (⌘⇧I or ⎋)" | unchanged |
    | 15 | Masthead · collapsed stamp (`clock`) | the whole time fact ("‹stamp› — ‹hint›") | unchanged |
    | 16 | Bottom bars (Write's, Takes') · ? | the cheat sheet (key list) | **"Shortcuts & Dictionary (⌘/)" + a newline + the cheat sheet** |
    | 17 | Bottom bars · Aa | "Bold, italics, sizes, lists, links — and whether ⏎ makes new blocks. …" · open "Put the formatting row away — …" | **"Formatting — bold, italics, …"** · open unchanged |

    Not icon-only (the word is on the door, so no row): the sidebar's five area rows and "this note" rail rows (which
    carry "(⌘n)" helps), the Open/Starred titles, the wing indicator, the ⌘⇧n badge (not a door), the note box's doors,
    the sync row's doors, and the bars' commit · takes · history · comments · more · block ▾ · note ▾ · newlines chip ·
    word count. Out of the ruled scope (surfaces, not the sidebar or a note's face): the Library's and the Bookcase's
    mastheads, the Takes board's card glyphs, the panels' own rows.
  - VX-560: BUILT (batch 2's commit) — STAGE-VERIFIED at the B2 stage leg (`BrowserNavKeysTests` 4, incl. a window with a real field).
    A-439-12 as ruled: ⌘← / ⌘→ are Back / Forward ONLY while no text holds the keyboard; inside any editor or field
    they stay line start / end. NOT a menu key equivalent (a key equivalent is resolved before the first responder's
    `keyDown`, so a ⌘← menu item would take line-start from every text view — `PageTurnKeys`' class): the door is
    `Workspace/BrowserNavKeys.swift`'s `BrowserNavKeyMonitor`, `PageTurnKeyMonitor`'s shape (a zero-size view's local
    `keyDown` monitor on RootView's full window, consuming only when it navigates), over the pure
    `BrowserNavKeys.direction` (exactly ⌘ — ⇧⌘← selects, ⌥⌘← pages a fan, ⌃⌘← steps takes; never while
    `PageTurnKeys.textIsFirstResponder` — the app's one "text holds the keyboard" answer, ANY `NSText` or `NSTextField`,
    read-only text views included — the conservative reading of review focus 5). The act is `RootView.navigate` — the
    menu items' own `router.goBack()/goForward()` — or, where the registry says the act cannot go, its declared refusal
    SPOKEN (AppSpec §12 "a door that did nothing speaks"; the `OneWingChord` precedent — PROVISIONAL bundle 15).
    ⌥⌘[ / ⌥⌘] stay the chords and the menus' labels; the registry gains `Capability.alternateShortcutLabel` ("⌘←" on
    `.navigateBack`, "⌘→" on `.navigateForward`), and the helper (⌘/) shows them in a new row. PINS `BrowserNavKeysTests`
    (4): the rule; the registry (alternates, unchanged chords, NO capability's menu key a bare ⌘←/⌘→, the helper shows
    them); the act (back/forward through a ShellRouter, the refusal spoken where nothing waits); the monitor in a window
    (a TextField's editor keeps ⌘← — caret to 0, nothing navigates — and with no text in charge ⌘← back, ⌘→ forward,
    ⇧⌘← nothing; `PagesArrowKeysHostTests`' sendEvent road). build-for-testing GREEN.
  - VX-441: BUILT (batch 2's commit) — STAGE-VERIFIED at the B2 stage leg (`FindReadoutTests` 6, incl. the real editor and the REAL
    finder stepping). THE TRACE FIRST (A-439-13): AppKit's `NSTextFinder` bar CANNOT show a count — nothing in
    `NSTextFinder.h` (macOS 27 SDK), no count or position string in AppKit's `TextFinder.loctable` ("Searching…",
    "find next", "find previous" only), no container/client hook adds text to the system bar, and the only public match
    surface, `incrementalMatchRanges`, exists only under incremental searching, which stays OFF (ruled — TEXTKIT2_NOTES
    §3); the one read-only Sonnet lookup's report + my own header read. So A-439-13's second arm: OUR readout, muted,
    at the Write bar's trailing end just before the quiet receipt slot (all three arrangements), drawn only while the
    find bar is up and the selection IS a match. `Features/Editor/FindReadout.swift`: the needle from the FIND PASTEBOARD,
    where NSTextFinder communicates its words and its options (`NSPasteboardTypeTextFinderOptions` — the header; the
    app's own find seed arms the bar the same way); the count under the Takes bar's MEASURED sameness rule
    (`TakesFindPlan.compareOptions`, non-overlapping stepping) and in its words, "2 of 15" (`TakesFindCopy.position` —
    one vocabulary for the two bars; her "2/15" — PROVISIONAL bundle 16); Ignore Case off honoured (unmeasured,
    PROVISIONAL); Starts With / Full Word / Ends With draw NOTHING rather than a wrong count. P1: the cheap gates first
    (bar up, a non-empty selection) — an empty selection, i.e. every keystroke, reads nothing, not even the pasteboard;
    the whole-note scan runs only when a selection lands EXACTLY on the finder's words ~~(a find step — itself a
    whole-note walk)~~ — RETRACTED at L1 (the ladder's m-2): a find step is NOT a whole-note walk (`NSTextFinder`
    searches forward from the selection to the NEXT match), and as built the readout re-walked the whole note on every
    step (2.6 ms at 100k words, on main); since L1 the count's walk runs once per (the finder's words, the text's
    generation) and a step is a binary search over the cached matches (L1 m-2, below). A non-empty selection while the
    bar is up still reads the find pasteboard once (unchanged; not in the disposition). WIRING, chrome only: the selection delegate (`EditorSurfaceDelegate.textViewDidChangeSelection`)
    calls `refreshFindReadout()` AFTER its unchanged identity work; `TypewriterScrollView` overrides the container's
    `isFindBarVisible` (calls super; reports a change — ⎋/Done change no selection); `EditorViewModel.findReadout`
    (a derived count, never text) + a needle seam a pin injects. ZERO text-storage, layout or identity changes; incremental
    searching untouched (pinned). PINS `FindReadoutTests` (6): the needle; the count + words; the gates (no read on an
    empty selection); the real editor following selection and the container's open/close; the REAL finder's
    `.next` steps followed via the real find pasteboard (saved and restored — the board's discipline); the wiring read.
    Headless replica of the three pure pins (the real `FindReadout.swift` + `TakesFindPlan.swift`): 21 checks, 0 failed.
    build-for-testing GREEN. ~~OPEN at the stage: whether a query typed ONLY into the bar's own field reaches the find
    pasteboard~~ — RESOLVED live at walk part 2: a query typed only into the find bar + one step read "1 of 1" (the
    finder does write the find pasteboard).
  - VX-569: BUILT (batch 2's commit) — STAGE-VERIFIED at the B2 stage leg (`TitleQuickfillTests` 5 incl. 3 mounted key-press pins +
    `MastheadLayoutTests`). THE TRACE FIRST (A-439-14): the "existing first-line quickfill" does NOT exist on the note's
    title — the "first words offered, one tap to adopt" chip lives only on the CAPTURE surfaces (`TitleSuggestionChip`:
    quick entry, the quick note). The masthead's title field (`PostDetailView.PostTitleLabel`) opened an untitled note on
    its stored name ("") with the DATE drawn faintly behind (17y B2 (n)), and Tab — a SwiftUI field's focus key — moved
    the keyboard on and filed the empty draft (a no-op): her 10-20 path ("auto fill in the first line … tab to complete
    it and enter") was BROKEN end to end. Per the ruling, that traced bug first: `Features/Takes/TitleQuickfill.swift` —
    on an UNTITLED note the open field OFFERS the note's first words (the capture chip's brain exactly,
    `NoteCardFace.suggestedTitle` — first line with words, markdown rendered, capped at a word edge, no ellipsis) over ONE
    bounded read (`Queries.leadingBlockTexts`, 3 slots), read when the field opens; then the 10-21 DATE ARM on the same
    road — a note with no words is offered the date it already shows (`DisplayTitle`'s — the same string every untitled
    daily entry reads by). The offer is drawn faint exactly where the date always sat (one place, one font — nothing
    moves); `.onKeyPress(.tab)` on an EMPTY field takes it (the palette's and the wing switcher's `onKeyPress` precedent on
    a `TextField`), any other Tab is Tab; typing replaces it; ⏎ files; ⎋ leaves it untitled. A titled note is offered
    nothing. Nothing is applied for her (her item 4's law). PINS `TitleQuickfillTests` (5): the rule; the bounded read;
    RED ON OLD — the mounted field: Tab takes "Garden plans" from `# Garden plans`, ⏎ files it (old tree: Tab moved on,
    the note stayed untitled); the date arm (Tab + ⏎ names a wordless note by its date); a guard (typed words file, never
    the offer). DELIBERATE edit: `MastheadLayoutTests.theOpenFieldsWordsStayWhereTheTitleRested` mounts a WORDLESS note
    (`blockText: ""` — its offer is the date, the very words it compares; annotated). The red-on-old for the mounted pin
    is the stage's revert cycle (R-T: the `.onKeyPress(.tab)` block removed). build-for-testing GREEN.
- Ladder: ROUND 1 DONE (`opus-reviewer`; findings `vx-439-ladder-round1.md` — 3 MAJOR · 7 MINOR · 5 NIT, no BLOCKER;
  the orchestrator's dispositions in the Ledger); its fixes are L1, below; round 2 (a FRESH `opus-reviewer` over the
  L1 fixes, per her kickoff word — the editor-seam file touches named in the bundle) NOT-STARTED.
- **L1 — THE ROUND-1 FIX SESSION** (`opus-implementer`, fresh, 2026-10-27; scope = the Ledger's "LADDER ROUND 1
  DISPOSITIONS", nothing else). **BUILT — every item dispositioned below; PENDING the fix-verify stage window.**
  **NO REVERT IN FLIGHT** — the revert pre-build (announced at `bf91cd0ba`) ran and restored: tree **A** (every L1
  revert patch but `r-g`) built into `scratchpad/l1/dd-revA`, tree **B** (`r-g` alone) into `scratchpad/l1/dd-revB`
  (each an APFS clone of this worktree's DerivedData, `build-for-testing` GREEN), each restored by `git checkout -- App/`,
  `git status`/`git diff` empty after both. **THE SECOND MERGE (the coordinator's addendum — VX-548 merged first):**
  `git merge origin/main` (main `6def23df0`) — the five shared files (`BookPanelModel`, `SettingsShape`,
  `TutorialSeeder`, `Capability`, `CapabilityRegistry`) auto-merged with DISJOINT hunks, both sides kept (main: the
  MCP "Share a place…"/"Share another place…" verbs + `mcpShareAnotherPlace`, the Book Panel's reading-reach marks,
  the guide's MCP sentences; ours: VX-589's settings row, VX-426's Book door help, VX-602's restore question) — no hunk
  asked a behavioral judgment; none of L1's files was in main's delta (every revert patch still applies) — merge
  commit **`2b33e8bb6`**, pushed. HEADLESS ON THE MERGED TREE: `swift build` GREEN; full `swift test` — core **3,467
  tests / 463 suites passed** (5 known issues, the standing ones), StringsWorkbook **32 / 4 passed**, MCP **412 / 75 with
  ONE failure**, `MCPHarnessTimeLimitTests.aPeerThatNeverAnswersInitializeFailsTheConnectNamedAndBounded` (23.9 s vs
  its 15 s bound, load average ~22 — the VX-353 load class both batches met), re-run alone **GREEN 3 / 1**; the
  skipped lines are the standing gated measurement/integration skips; `xcodebuild build-for-testing` GREEN on the
  merged tree (default DerivedData). THE STAGE PLAN (PENDING the relayed claim line): `zsh scratchpad/l1/stage.sh
  fixed1|fixed2|fixed3` — the **267 suites** of `scratchpad/l1/stage-suites.txt` (every suite in a test file naming a
  type L1 changed — the grep rule, `scratchpad/l1/suites.py`, test subfolders included — ∪ the coordinator's merge
  additions: the capability-registry suite, every Settings* suite + the settings-search readers, all eleven of
  `TutorialWalkTests.swift`'s suites + every seeder-reading suite, the Book Panel suites incl. `BookPanelMCPMarksTests`,
  the export-seam trio `ExportFacesTests`/`PlaintextExportBringInRoadTests`/`U2WordsTests`), 89 per
  `test-without-building`, each log's "Test run with N tests" line read (VX-604) and `NoteExportMenuGateTests` read
  SKIPPED; then `revA` (tree A's patches applied for the run, the nine L1 pin suites on `dd-revA`, restored) and `revB`
  (`r-g` applied, `FindReadoutTests` on `dd-revB`, restored). EXPECTED REDS under A, exactly: `SidebarRowLeadsTests.
  theReadsWordsAreBoundedSeeksNeverAWindowOverTheWholeNote`, `QuickEntryWingLabelTests.theToolbarsNewNoteButtonWearsTheWingLabel`,
  `BrowserNavKeysTests.aWebViewHoldingTheKeyboardKeepsCommandArrow`, `FindReadoutTests.aStepReadsTheCachedCountAndOnlyNewWordsOrNewTextRescan`
  + `theEditorScansOncePerTextAndAnEditRecounts`, `SidebarNoteRowMenuTests.aMoveFromTheRowReasksWhichWingItsDoorsAndIndicatorRead`
  + `theColumnsWingDoorsHandTheReaskAndBothReadsAreKeyedOnIt`, `OpenListDragMountTests.aDragWhoseRowWentAwayLeavesTheRowsDoorsActing`,
  `OpenListDragFaceTests.eachRowsTwoHalvesAreDropsOnMainsRoadLiveOnlyWhileItsDragIsInFlight` (its deliberately edited
  literal), `NoteExportTests.aFailedWriteNamesItsReason` — every other test of those nine suites green (`OpenListDropDoorTests.
  theDragIsInFlightOnlyWhileItsRowIsDrawn` green under A by construction — the predicate exists; the mounted pin is
  m-7's red-on-old). Under B, exactly: `FindReadoutTests.theEditorScansOncePerTextAndAnEditRecounts` (its edit leg).
  Method (the run's own, batch 2's): each fix lands WITH its
  pin and a NAMED behavioral revert (patch gitignored in `scratchpad/l1/reverts/`); app-side pins are red-on-old
  verified at the fix-verify stage window (the reverts applied for the run, restored by `git checkout`), and
  headlessly first wherever a replica is cheap. Items (each flips in its own commit):
  - M-1 (P1 — `SidebarRowLeads` through `Queries.leadingBlockTexts`): DONE (this commit). TRACED (confirmed by
    reading): the column holds `observe { SidebarRowLeads.read }`; every autosave's full-record `container.update`
    (`registerTextChange`) wakes it; for an untitled listed note the words came from `NoteCards.load`, whose
    `ROW_NUMBER() OVER (PARTITION BY …) … WHERE n <= 3` materializes every block of the note (∝ the note, at typing
    rate). FIX: each untitled note's opening is `Queries.leadingBlockTexts(…, blocks: NoteCards.blockWindow)` (the
    flat, plan-pinned read `TitleQuickfill` already uses), each slot cut at `NoteCards.snippetLimit` so the brain sees
    the Library card's exact opening. PIN `SidebarRowLeadsTests.theReadsWordsAreBoundedSeeksNeverAWindowOverTheWholeNote`
    (traces the read's statements: one words statement per untitled note, no `OVER (`, a `LIMIT`, its plan a `SEARCH
    cb USING INDEX idx_cblock_order` with no scan and no full sort). RED ON OLD, HEADLESS — VERIFIED: a replica
    package (scratchpad `l1-m1-replica`: the REAL `SidebarRowLeads.swift` + `LibraryListingReads.swift` over the
    worktree's core, the pin's body transformed mechanically) — the old read **3 of 7 checks failed** (the window,
    no `LIMIT`, the plan's `USE TEMP B-TREE FOR ORDER BY`), the fixed read **7 / 0**; five lead shapes (a heading, a
    capped long line, a wordless note, a checkbox lead, an emphasis lead) read IDENTICAL old vs new
    (`scratchpad/l1/m1-replica-{old,new}.txt`). Named revert **R-M1** (`scratchpad/l1/reverts/r-m1.patch`) for the
    stage. THE OBSERVATION'S NARROWING, EXAMINED — NOT AVAILABLE, recorded rather than invented: the observation
    already tracks exactly the read's own region, column-level (a titled sidebar reads only `container`'s id · title ·
    profile · entry_date · created_at · kind · deleted_at, so `touchContainer`'s two-column stamp never wakes it); what
    wakes it per keystroke is the operations layer's FULL-RECORD `container.update`/`variant.update` in `autosave`,
    which no region (table or column) can tell from a rename — and a rename MUST wake it (an untitled row that gains
    a title must drop its lead). So each wake now costs ∝ the listed rows × 3 slots, flat in every note's length;
    narrowing further would mean a changed-columns update in `registerTextChange` (the operations layer — out of this
    run's seam; it would also quiet several other held reads) — a closeout ticket candidate, the orchestrator's to
    file. The `NoteCards` header's false "a 10,000-block note costs the same" claim stays the closeout ticket the
    disposition named (not this run's).
  - M-2 (the toolbar New Note door's wing label): DONE (this commit) — PROVISIONAL, bundle 18. TRACED (read): the
    toolbar's `ToolbarItem(placement: .navigation)` New Note (`square.and.pencil`, `RootView`) mints through
    `library.createPost()` → `session.wing.currentID`, on every surface; unlabelled. The toolbar idiom carries a text
    item cheaply (one more `.navigation` `ToolbarItem`; `sharedBackgroundVisibility(.hidden)`, macOS 26+, keeps it from
    reading as a glass button), so the VISIBLE label was built rather than the tooltip fallback: right after the
    button, `QuickEntryCopy.wingLabel(wings.currentName)` muted small chrome, `lineLimit(1)`, ≤160 pt, its hover
    `wingHelp` (the bars' one vocabulary; the shell's `WingsModel`, which follows the focused note; Home with one
    wing). The button's own tooltip (VX-426's "New Note (⌘N)") unchanged. Design-row: PIN
    `QuickEntryWingLabelTests.theToolbarsNewNoteButtonWearsTheWingLabel` (source-read, the suite's precedent — red on
    old: no item follows the button); the LOOK is the evidence slice's capture (both voices — the orchestrator's).
    Named revert **R-M2** (`scratchpad/l1/reverts/r-m2.patch`). C-552-1's premise corrected in place (LIVE STATUS
    VX-552, the Ledger's C-552-1 — appended, and the suite's header).
  - m-1 (⌘←/⌘→ learn web-view first responders): DONE (this commit). TRACED (read): `BrowserNavKeyMonitor` consumes
    ⌘← whenever `PageTurnKeys.textIsFirstResponder` is false — first responder neither `NSText` nor `NSTextField`; the
    reference panel's URL pane is a plain interactive `WKWebView()` (`ReferencePanel.WebPane`) in the same window, and
    with a page input focused the first responder is the web view → ⌘← ran `RootView.navigate(.back)` and moved the
    pane off her note. FIX: the app's ONE "text holds the keyboard" answer also says yes for a first responder that IS
    or sits INSIDE a `WKWebView` (an ancestor walk — whichever view WebKit makes first responder); whether the page's
    focus is in an input only the page knows, so a web view holding the keyboard counts (the rule's conservative
    reading, as a read-only text view counts). NOT a generic `NSTextInputClient` test — SwiftUI's own hosting views
    may conform, which would silence ⌘← everywhere. The page-turn monitor reads the same answer, so a web view holding
    the keyboard keeps unmodified ←/→ from turning a leaf too (the reviewer's "can ride the same helper" — one answer,
    not a fork). PIN `BrowserNavKeysTests.aWebViewHoldingTheKeyboardKeepsCommandArrow` (a real `WKWebView` made first
    responder in a window with the monitor: the rule says text; ⌘← and ⌘→ deliver nothing; then with nothing in
    charge ⌘← goes back — non-vacuity). RED ON OLD expected under named revert **R-W**
    (`scratchpad/l1/reverts/r-w.patch` — the rule back to `NSText || NSTextField`): the rule expectation and
    "nothing navigated" fail (`[.back, .forward]` delivered) — PENDING the stage window (a window + WebKit; no headless
    road). build-for-testing GREEN.
  - m-2 (the find readout's match ranges cached per needle × text generation): DONE (this commit). TRACED (read): each
    ⌘G selects the next match → `textViewDidChangeSelection` → `refreshFindReadout` → `FindReadout.face` past its gates
    → `ranges(of:in:)` walked the whole note per step; the record's justification ("a find step — itself a
    whole-note walk") was false and is RETRACTED in place (VX-441's line above; the file header's P1 paragraph says
    the same, rewritten). FIX: `FindReadout.MatchCache` (needle × text generation × ranges), held by the editor's model
    (`findMatchCache`); `face(…, generation:, cache:, scan:)` scans only on a miss and finds the selection's place by
    binary search (`place(of:in:)` — matches ascend, never overlap); the text's generation `findTextGeneration` bumps
    in `storageDidEdit` beside N14's `overlayGeometryGeneration` (every storage CHARACTER edit — typing, projections,
    structural rewrites; an Int, no text read; the delegate filters `.editedCharacters`, so the markdown settle's
    attribute writes never invalidate it). The uncached `face(barVisible:needle:selection:text:)` stays for one-look
    callers (the existing pure pins, unchanged). Zero text-storage/layout/identity behavior changed — one counter line
    in the model's edit report. PINS `FindReadoutTests.aStepReadsTheCachedCountAndOnlyNewWordsOrNewTextRescan` (pure, a
    counting `scan`: six steps → one scan; a new generation → one more, counting the new match "4 of 4"; new words →
    one more; a caret scans nothing) and `theEditorScansOncePerTextAndAnEditRecounts` (the real editor: three steps →
    one scan; typing "the " through the real input path → the next step rescans once and reads "4 of 4"). RED ON OLD,
    HEADLESS for the pure pin — VERIFIED: a replica (scratchpad `l1-m2-replica`: the REAL `FindReadout.swift` +
    `TakesFindPlan.swift`, the four pure pins transformed mechanically) — fixed **34 checks / 0 failed**; under named
    revert **R-C** (the cache bypassed — the pre-m-2 walk per step, `scratchpad/l1/reverts/r-c.patch`) **4 failed,
    exactly the new pin's scan counts** (6 / 7 / 8 / 8), every word still right (`scratchpad/l1/m2-replica-{new,rc}.txt`).
    The editor pin's reds are the stage's: under R-C its scan counts; under named revert **R-G** (the generation bump
    removed, `r-g.patch`) its edit leg (a stale cache: nil, not "4 of 4"; one scan, not two). build-for-testing GREEN.
  - m-3 (the sidebar row menus' wing listings re-ask after an act): DONE (this commit). TRACED (read): `noteRowWingIDs`
    (the row doors' `fromWing`) and the pre-existing indicator's `openRowWings` are ONE-SHOT reads keyed on (rows,
    current wing); a Move to Wing ▸ from a row changes neither (the row stays — F-U5-6; she stands where she stood),
    and the column passed no `onDone` to `WingNoteDoors` nor to `.wingMoveConfirm` — so after the move the row's
    Move/Copy ▸ listed the note's NEW wing as a destination and omitted its old one, and its indicator stayed blank.
    FIX: `wingActGeneration` (`@State`), bumped by ONE method `wingActDone()` that the column hands both doors
    (`WingNoteDoors(…, onDone: wingActDone)`, `.wingMoveConfirm(…, onDone: wingActDone)`); both reads' keys
    (`noteRowsWingKey`, `openWingsKey`) carry it, so the contract "after an act, the one-shot listings re-ask" holds
    for both (the indicator is the same staleness, the reviewer's own note — one re-ask, not two). DEBUG oracles
    `SidebarGeometry.noteRowFromWings` / `openRowWingNames` (each read's last answer) and `noteRowWingActDone` (the
    column's re-ask, as the doors run it). PINS `SidebarNoteRowMenuTests.aMoveFromTheRowReasksWhichWingItsDoorsAndIndicatorRead`
    (mounted, two wings: the door's act — `wings.moveAsk` moves a bookless note at once — then the door's `onDone`; the
    doors now read from Work, list Home only; the indicator names Work; the premises asserted: the row stayed, she
    stands in Home) + `theColumnsWingDoorsHandTheReaskAndBothReadsAreKeyedOnIt` (source-read wiring); the suite gains
    `.serialized` (it mounts a window now). DELIBERATE edit: `theNoteActsRunTheSharedRoads`' `.wingMoveConfirm(…)`
    literal (+ `onDone: wingActDone`, annotated). RED ON OLD expected under named revert **R-D**
    (`scratchpad/l1/reverts/r-d.patch` — the generation out of both keys, the pre-fix reads exactly): both new pins
    red (the reads never re-run; the keys lack it) — PENDING the stage window. build-for-testing GREEN.
  - m-5 (`NoteExportMenuGateTests` disabled, named): DONE (this commit) — hygiene, no bug pin (the disposition's own
    words): the suite's trait list gains `.disabled("never executed — the VX-604 host-crash class; re-enabled by the
    VX-603/604 work")`, and its doc says why (never executed; its one run crashed the host before its first line; kept
    for VX-603/604). The stage window's evidence: the suite reads SKIPPED, never run (the `skipped:` line — Swift
    Testing counts skipped tests in "Test run with N tests"). build-for-testing GREEN.
  - m-7 (CONDITIONAL — pin first; guard only if red on current code): GUARD LANDED (this commit) — the pin RED on the
    current code BY TRACE, its stage run the confirmation. PIN FIRST, on existing API only (so it runs on the
    pre-guard tree unchanged): `OpenListDragMountTests.aDragWhoseRowWentAwayLeavesTheRowsDoorsActing` — a drag begins
    on row 1 (`began`, the payload's own act), row 1 closes with NO session end (`closeNote`), then a click on the new
    first row's ✕ must close that row. RED ON CURRENT CODE, by trace: nothing but `began` / `ended` (a drop) /
    `dragSessionUpdated(.ended)` writes `dragging` (grep of every writer), so it stays latched, and the halves'
    `.allowsHitTesting(state.dragging != nil)` keeps every row's halves live — exactly R-G's condition, whose stage run
    already MEASURED the consequence (the ✕'s click eaten, the row's tap answering). So the cheap guard landed:
    `OpenListDragState.dragInFlight(among:)` (began here AND its row still drawn) is the halves' liveness
    (`rows ?? workspace.openNotes.shown`); the row's own drop under them still lands any drop. PINS: the mounted pin
    above (red-on-old under named revert **R-L**, `scratchpad/l1/reverts/r-l.patch` — the halves back on `dragging !=
    nil` alone, the pre-guard code exactly); `OpenListDragTests.theDragIsInFlightOnlyWhileItsRowIsDrawn` (the
    predicate, pure); DELIBERATE edit of the face pin `eachRowsTwoHalvesAreDropsOnMainsRoadLiveOnlyWhileItsDragIsInFlight`
    (its `allowsHitTesting` literal, annotated) — red under R-L too. **CONTINGENCY, stated now:** should the mounted pin
    read GREEN under R-L at the stage (the premise wrong — something clears the latch, or the click reaches the ✕
    anyway), the finding is HOLLOW: the guard comes out in one commit, the pin stays as a guard, the Ledger says so.
    What stays SPECULATIVE either way is the reviewer's own question (whether AppKit ever withholds `.ended` after the
    source row is removed) — the guard makes the answer not matter. build-for-testing GREEN.
  - m-4 (the honesty half: the settings pins' capture claim): DONE (this commit) — comments only, no pin. Checked by
    eye: `walk-shots-vx439/33-settings-general.png` IS the MCP pane (title "MCP", the server toggle, the clients tab).
    `SettingsShapeTests.theAppearanceControlIsOnTheShortOpeningPane` said "The walk captures the pane." — replaced: no
    such capture exists, the cited one shows MCP, the live look at the fold is OWED to the evidence slice.
    `DiagnosticsPaneTests` never cited a capture (the reviewer's "both pins" was one), but its "the short dials still
    top the pane" is reasoning, not a look — it now says so and names the same owed slice. The record's VX-589 line
    made the same claim and is corrected in place. The live evidence itself (VX-589's toggle, a true General capture,
    VX-569's title-Tab, VX-425's three asks) is the orchestrator's evidence slice — not this session's.
  - n-2 (the export write failure names its reason): DONE (this commit). TRACED (read): `NoteExport.export`'s write
    `catch` spoke `couldNotWrite(fileName:)` and dropped the error, so a full disk, a permission refusal and a vanished
    folder read identically. FIX: `couldNotWrite(fileName:reason:)` appends the system's own sentence
    (`error.localizedDescription`, trimmed, closed with a period if it has none) after the unchanged words ("… the note
    is unchanged; try another folder. The folder “export.md” doesn’t exist."). PIN
    `NoteExportTests.aFailedWriteNamesItsReason` (on the door's existing seam: a destination inside a folder that does
    not exist; the refusal names the file, the system's reason for that very write, and the unchanged note). RED ON
    OLD, HEADLESS — the pin's assertions over the old and new sentences with the real failing write (scratchpad
    `l1-n2`, `scratchpad/l1/n2-replica.txt`): old FAIL (no reason), new PASS; the mounted-free app pin itself runs at the
    stage under named revert **R-N** (`scratchpad/l1/reverts/r-n2.patch`). build-for-testing GREEN.
  - n-4 (LIVE STATUS freshened — the last flip): DONE (this commit) — the STATUS banner, the Ladder and Walks lines,
    batch 2's eight member lines (each "PENDING the stage run" → STAGE-VERIFIED at the B2 leg, under a header that
    already said so), the B2 stage plan's tense, VX-441's resolved typed-query question, and this L1 block's
    revert/merge/headless/stage-plan state — all brought to the truth as of `2b33e8bb6` + this commit.
  - NOT THIS SESSION'S (the brief's NOT-YOURS, restated so nothing reads as dropped): M-3 (the 11 MB of walk captures in
    branch history — her call); m-6 (the canon sweep — closeout work); the evidence slice (VX-589's toggle, a true
    Settings ▸ General capture, VX-569's title-Tab, VX-425's three asks, M-2's toolbar label in both voices — the
    orchestrator's, in the fix-verify window); VX-424's drag delivery (her hand check, bundle 11).
- Walks (orchestrator): part 1 DONE (03:30–03:52, claim `vx-439-b1-walk`) and part 2 DONE (06:11–06:28) — the WALK
  PART 1 / WALK PART 2 sections below; the POST-FIX EVIDENCE SLICE (m-4's live legs + M-2's look) is owed in the
  fix-verify window — NOT-STARTED.

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
11. **VX-424 — the drag fix is unverifiable by any synthetic road** (VX-375): your hand check is its evidence — drag
    an Open row DOWN ONE (release on the next row's lower half), UP ONE (the row above's upper half), to the end, and
    watch the line hold still as the pointer crosses a boundary. If a drop ever fails, the row's own drop under the new
    halves still lands it the old way (before the row) — say so and the halves come out in one commit.
12. **VX-580 — two PROVISIONALs:** the sidebar's first-words title uses the Library's own 48-character cap (the row's
    width cuts it first at any normal sidebar width — your "maybe fewer words"); and View ▸ Open Note's menu still names
    untitled notes by their date (your ask named the left-hand bar). Say the word for either.
13. **VX-589 — the ⌘⇧n badges keep the Open list's real keys** while starred rows are hidden (so the numbers may skip
    one — ⌘⇧2 still opens the hidden starred note). The alternative is renumbering the visible rows, which would make
    ⌘⇧n mean something different from View ▸ Open Note. Say the word for the other. The setting lives in Settings ▸
    General ▸ Open notes, under "Keep open notes across launches".
14. **VX-426 — three PROVISIONALs:** (a) the tooltips LEAD with the icon's name and keep the sentence they had ("Tray —
    what this note has set aside: …") rather than becoming a bare one-word label, so the teaching sentences you ruled
    survive; (b) the masthead's scraps icon's tooltip now says **Snippets** (the area's name everywhere you read it), but
    the icon's own title — and so the tour's and the field guide's "Scraps panel" — still says Scraps (renaming it owes
    the guide re-seed in your window); (c) the tester's "Notes & links" for the references icon is NOT adopted — that
    door is "References" everywhere; renaming it is yours.
15. **VX-560 — two PROVISIONALs:** (a) ⌘← with nowhere to go back to SAYS "Nothing to go back to — this is where you
    started." on the status line (a door that did nothing speaks) rather than doing nothing silently; (b) a read-only
    text surface that holds the keyboard (after a click into a read page) also keeps ⌘← as its own — the same "text
    holds the keyboard" rule the page-turn keys use; ⌥⌘[ still goes back there. Say the word for either.
16. **VX-441 — the readout says "2 of 15"** (the Takes bar's own words for the same count) rather than "2/15"; and it
    shows only while the selection sits ON a match — click elsewhere and it steps aside until the next ⌘G. Say the word
    for "2/15" or for a standing "15 matches".
17. **VX-569 — the title's first-words offer did not exist** on a note's title (only the capture chip did), so this run
    BUILT your 10-20 ask ("auto fill in the first line … tab to complete it and enter") and your 10-21 date arm on it:
    click an untitled note's title, its first line (or, with no words, its date) shows faintly; Tab fills it in; ⏎
    names the note. Typing anything instead is yours, as always. PROVISIONAL — say the word if the offer should look
    different or come from somewhere else.
18. **VX-552 — the window toolbar's New Note button now wears the wing label too** (the ladder's M-2: that button,
    on every surface, mints into the current wing, and it is the door your ticket names — the batch had labelled only
    the two quick-entry bars). A muted "in ‹wing›" sits right after the button, in the bars' words and hover, with no
    glass capsule behind it (it is a label, not a door). PROVISIONAL — say the word if it should instead ride only the
    button's tooltip, or sit somewhere else.
19. (grows)

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
  ‹wing›" at the quick-entry band's trailing edge, from the host's `WingsModel.currentName`. [CORRECTED at L1 (the
  ladder's M-2), appended: the batch's premise that the two quick-entry bars are "the two doors that mint into the
  current wing" was false — the window toolbar's `square.and.pencil` New Note button (every surface,
  `LibraryViewModel.createPost` → `session.wing.currentID`) is one too, and is the door the ticket names; it now wears
  the same label (PROVISIONAL, bundle 18).] **C-602-1** — Help ▸ "Open the
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

- 2026-10-27 **W-439-1 DIAGNOSTIC SLICE (the orchestrator, claim vx-439-b1-diag, 03:45–04:02).** (1) The probe suite
  `NoteExportMenuGateTests` DOES NOT EXECUTE under the runner: "Test run with 0 tests in 1 suite passed" — the suite
  registers and passes empty in 0.001 s, by suite path AND by full test path (the empty-suite false-green the
  resiliency protocol warns on; the implementer owes the probe's runnability before it can pin anything). (2) No
  `NSUserKeyEquivalents` in the global or debug-app domains — the App-Shortcut form of candidate A is OUT. (3) The AX
  matrix, fresh launch, note open via ⌘⇧1: Export Note… / Export Block / Export Library… / Save a Version / Duplicate
  with Tags / Commit Take ALL ENABLED (New Note in This Book correctly false in a note pane). (4) Two reproduction
  roads of part 1's sequence (Bookcase → Walk Book → note via ⌘⇧1; and via the OPEN-ROW CLICK) — NOT reproduced,
  all enabled. VERDICT: **W-439-1 is a STATE-DEPENDENT stale gate, not a constant availability fault** — part 1's
  disabled read (menu open, AX false, ⌥⌘S no-op) stands as evidence; the un-walked differences of part 1's road are
  the candidate triggers: the 820→1240 window RESIZE, the New Book POPOVER episode, the ⌥⌘N mint landing a live
  editor inside the book pane, and the ⌥⌘S press preceding the read. The class smells of the 13b overlay/sink law
  (an equality-gated sink starving — find the INPUT AXIS that fails to re-validate). TIMEBOX (architect's order):
  the implementer gets ONE bounded headless pass to (a) make the probe actually run, and (b) stage the candidate
  triggers in it until the gate goes stale (that staging is then the red-on-old pin). If the mechanism lands: fix +
  pin + fix-verify suites + walk part 2 as planned. If it does not: W-439-1 is recorded OPEN-INTERMITTENT on
  VX-125's ticket (the part-1 AX evidence attached), batch 1 closes without it, batch 2 proceeds, and the morning
  bundle carries it — an unreproduced intermittent must not stall the run all night.
- 2026-10-27 **B1 W-439-1 timebox (the implementer, one headless pass — CLOSED OPEN-INTERMITTENT, no fix, no mechanism).** (a) WHY THE PROBE "NEVER RAN" — read from the diagnostic slice's own xcresults (`DerivedData/…/Logs/Test`, read-only via `xcresulttool`; no stage): the 03:45 run did not run the probe at all — the TEST HOST CRASHED (`EXC_BAD_ACCESS`, stack guard) before the probe's first line. The faulting stack's root is the host app's OWN launch: `AppBootstrap.beginOpening` → `AppBootstrap.finish` → `AppSession.init(database:storeVariant:)` (AppSession.swift:763) reads `@Dependency(\.date)` outside any test's dependency scope → swift-dependencies' `testValue` reports the unimplemented dependency (`_DefaultReporter.reportIssue` → `XCTFail`) → XCTest's fallback handler hands it to Swift Testing's interop (`SwiftTestingInteropRecordHandler.handleIssueRecorded` → `Issue.record`) → with no current test Swift Testing posts it back to the fallback → … 140 frames of that ping-pong until the stack guard. It is the SAME issue every app run logs harmlessly as `⚠︎ Test «unknown» recorded a warning at Date.swift:37:1 … @Dependency(\.date) has no test implementation` (seen in this batch's green runs); in a one-test run it recursed instead. The 03:46 run's empty "0 tests" result carries no detail (its xcresult has no test nodes). So the probe's code was never exercised and is NOT shown faulty; it stays in the tree, unverified. A TEST-HARNESS finding, ticket proposed (Tests & tooling, Bug, Confirmed): "the test host's own launch reads `@Dependency(\.date)` in `AppSession.init`; under a Swift-Testing-only run the unimplemented-dependency report can recurse through XCTest's fallback ↔ Swift Testing's interop until the stack guard and crash the host (the crash log of 2026-10-27 03:45:50)". (b) THE TRIGGER AXES (the resize 820→1240, the New Book popover, the ⌥⌘N book-pane mint, the ⌥⌘S press before the read) could NOT be staged in a headless pass — every one needs the mounted app, which is the stage; and reading cannot find a starving sink here: the menu item and its siblings read one gate the same way (`enabled(_:)` → `commandRouter.isEnabled` → `currentContext()`, every input observable), the gate's rule is pinned green in both contexts, and the AX matrix saw it enabled. No fix is written — no traced mechanism (the hallucination guard). COMMENT-READY LINE FOR VX-125 (the orchestrator posts it): "W-439-1 — walk part 1 (2026-10-27) saw File ▸ Export Note… DISABLED with a note open in Write (AX enabled=false with the menu tracking; ⌥⌘S no-op). Not reproduced: the diagnostic AX matrix on a fresh launch read it (and every sibling File item) ENABLED, and two replays of part 1's road stayed enabled. The gate is right (`noteScoped`, pinned) and reads the same way as its siblings. Open intermittent — untried trigger candidates: the 820→1240 resize, the New Book popover, the ⌥⌘N book-pane mint, a ⌥⌘S press before the menu read. Evidence: the run record's WALK PART 1 + Ledger 'B1 W-439-1 trace'/'timebox'. If you see the item grey again: note what you did just before, and whether Export Block / Save a Version were grey too."
- 2026-10-27 **B2 VX-424 — THE INSTRUMENT, both directions (A-439-15), before any pin or fix.** Two parts.
  (1) HEADLESS, read tonight: a replica over the REAL `Core/Views/SidebarLayout.swift` (gap / destination / lineTop) and
  the REAL `OpenNotes` (cut verbatim; scratchpad `vx424/`), enumerating every dragged row × every hovered row of a 6-row
  list, DOWN and UP. Result: **down hovers 15, refused 5; up hovers 15, refused 0.** Every refusal is DOWN BY ONE (the row
  right below names the dragged row's own lower gap — `gap(for: .row(i)) = i`, `destination` nil at `dragged + 1`);
  down by two lands ONE place down (one short of the pointer's row); and an up-drag never refuses — but it lands on the
  hovered row's TOP whichever half the pointer is in (pointer in r1's LOWER half while dragging r3 up: r3 lands ABOVE r1,
  one place higher than the half it was released on). So the RULE's only "nothing reorders" is down-by-one; her
  up-drag report ("it happens trying to move it up as well") has NO refusal in the rule — an up-drag that does nothing
  must have been released where no drop exists at all: the side margins (the scroll content's padding, outside every
  row), the "Open" header and separator above the first row, or the dragged row's own row (an up-drag of less than a
  row). (2) THE HAND LOG, built: DEBUG-only `OpenListHoverLog` (this commit) — one line per hover change and per release
  with target, direction, dragged index, gap and destination; read with `log stream --level debug --predicate
  'subsystem == "io.lduarte.Variorum.debug" && category == "open-list-drag"'` beside a hand drag. NO synthetic road
  reaches a sidebar drop (VX-375 — the VX-283 main-build control), so nothing tonight can read it; it is removed again
  before the ladder (A-439-15) and stays in history at this commit for any hand session.
- 2026-10-27 **B2 — THE SECOND-MERGER STEP (the coordinator's addendum: VX-502 merged first and shares the export seam).**
  `git fetch origin` + `git merge origin/main` (a MERGE, never a rebase — the branch is pushed): main at `dd469951e`
  (VX-502's PR #192 merge `32fb88ec6`) taken in with NO conflicts (VX-502 touched `Operations+PlaintextExportImport.swift`,
  `Migrations.swift`, the Protection copy doors/words and their pins; batch 2 touched no core file) — merge commit
  **`0a30e8b09`**, pushed; the merged tree is `0a30e8b09`. HEADLESS ON THE MERGED TREE: `swift build` GREEN; the full core
  `swift test` — **3,439 tests / 457 suites passed** (5 known issues, the standing ones; +3 over batch 1's 3,436 — VX-502's
  merged pins) incl. `DocumentFormatRoundTripTests.aLibraryExportReimportsEveryNoteWithItsTitleTagsAndTakes` and the
  serializer/plaintext-export pins; **32 / 4 passed**; the MCP package **383 / 71 with ONE failure**,
  `MCPHarnessTimeLimitTests.aPeerThatNeverAnswersInitializeFailsTheConnectNamedAndBounded` (18.5 s vs its 15 s bound,
  load average ~10 — the VX-353 load class batch 1 also met), re-run alone **GREEN 3/3**; the skipped lines are the 7
  standing gated measurement/integration skips. The Mac-side export pins (`ExportFacesTests`,
  `PlaintextExportBringInRoadTests`, `U2WordsTests`) ride the b2 stage window on the merged tree.
- 2026-10-27 **B2 — THE NAMED REVERTS, before any is applied** (patches gitignored in `scratchpad/b2/reverts/`; each applied
  to the committed tip `39f9e3104`, built with `build-for-testing` into its own DerivedData `scratchpad/b2/dd-r{o,g,t}`
  — seeded by an APFS clone of this worktree's DerivedData — then restored by `git checkout --` of the committed file,
  `git diff` empty after; the stage window then runs `test-without-building` per tree):
  **R-O** (VX-424 — the halves overlay line removed from `openRow`): expect RED exactly
  `OpenListDragFaceTests.eachRowsTwoHalvesAreDropsOnMainsRoadLiveOnlyWhileItsDragIsInFlight` and
  `OpenListDragMountTests.theRowsTwoHalvesSplitItAtItsMidlineAndReachTheListsEdges`, every other test of those two suites
  green. **R-G** (VX-424 — the halves always hit-testable): expect RED exactly the face pin above (its `allowsHitTesting`
  line) and `OpenListDragMountTests.atRestTheHalvesTakeNoClickSoTheRowsDoorsAct` (the ✕'s click lands on a half, which
  only the row's tap answers). **R-T** (VX-569 — the `.onKeyPress(.tab)` block removed): expect RED exactly
  `TitleQuickfillTests.tabTakesTheOfferedFirstLineAndEnterFilesIt` and `aNoteWithNoWordsIsOfferedItsDate` (the old road:
  Tab moves on, the note stays untitled), the rule/read/guard pins green. (VX-424's pure + door reds — R-H — were run
  headless by the replica: 402 of 1020 checks.)
- 2026-10-27 **B2 STAGE LEG — under claim `vx-439-b2-suites` (05:30 MDT, the coordinator's GO).** The five chunks on the
  merged tree (default DerivedData, built at `0a30e8b09`'s code): chunk1 **543 tests / 101 suites**, 1 failing test;
  chunk2 **690 / 99**, 1 failing; chunk3 **677 / 100**, 2 failing; chunk4 **529 / 100** GREEN; chunk5 **618 / 95** GREEN —
  **3,057 tests in 495 suites**, 4 failing tests. The four: (1) `BrowserNavKeysTests.theKeyRunsBackAndForwardOrSpeaksTheDeclaredRefusal`
  — MY pin read the wrong observable (`goBack()` REQUESTS a landing via `pendingSelection`, which a bare router never
  adopts) — corrected to read the request (`0f77f2d95`); (2) `OpenListDragMountTests.atRestTheHalvesTakeNoClickSoTheRowsDoorsAct`
  — MY rig's click map landed ONE ROW LOW (the ✕ closed row 2, the title click opened row 3 — the doors acted, the
  coordinates were off by the titled window's chrome) — re-anchored on the list's own AppKit scroll view (`0f77f2d95`);
  (3) `NoteVersionsPaneTests.theSaveAVersionChordIsTheShiftedTwinOfCommitAndNothingElseTakesIt` — BATCH 1's missed pin:
  its `s`-chord sweep counts 4 since VX-125's ruled ⌥⌘S — updated DELIBERATELY (`0f77f2d95`); (4)
  `DestructiveUndoWarningTests.redoNeverAsks` — 3 issues (the redo did not re-divide: `redoDepth` stays 1, no "Redid"
  receipt). Rebuilt, the five suites re-run (`rerun1`): **36 tests / 5 suites, (1)–(3) GREEN**, (4) RED AGAIN identically —
  NOT explained away: no batch-2 change is on its road (ShellActions' structural undo/redo, the undo stack and the
  divide are untouched by this batch; batch 1's ShellActions edits are the export/⌥⌘N/Help lines), and it was in neither
  batch 1's 152-suite list nor any earlier stage list of this run — PENDING a baseline run on main's own tree (below).
  NO REVERT IN FLIGHT going into the cycles: tree clean at `0f77f2d95`.
- 2026-10-27 **B2 STAGE LEG — the revert cycles, corrected method (announced BEFORE applying).** The first `rev_ro`
  (05:57) on the tree pre-built BEFORE `0f77f2d95` is VOID as evidence: its test bundle carried the old click map (so
  `atRestTheHalves…` read red for the rig's reason), and the face pin reads the LIVE source, which was restored. So each
  cycle now runs with its patch APPLIED in the worktree for the run's whole length (source reads see the revert), on a
  tree rebuilt from `0f77f2d95` + that patch: R-O applied → `build-for-testing` into `dd-ro` → `rev_ro` → `git checkout`
  restore; then R-G the same into `dd-rg`; then R-T into `dd-rt`. Expected reds exactly as named above.
- 2026-10-27 **B2 STAGE LEG — RESULTS (claim `vx-439-b2-suites` 05:30:03 → RELEASED 06:08:47 MDT).**
  **Revert cycles** (each patch applied in the worktree for the run, tree rebuilt from `0f77f2d95` + the patch, restored by
  `git checkout`, `git status`/`git diff` empty after each): **R-O** — 9 tests / 2 suites, RED EXACTLY
  `OpenListDragFaceTests.eachRowsTwoHalvesAreDropsOnMainsRoadLiveOnlyWhileItsDragIsInFlight` (no `.overlay { openRowHalves`)
  and `OpenListDragMountTests.theRowsTwoHalvesSplitItAtItsMidlineAndReachTheListsEdges` (no halves laid out), the other 7
  green (the at-rest click guard green — the rows' doors act with no halves at all). **R-G** — 9 / 2, RED EXACTLY the face
  pin (its `allowsHitTesting(state.dragging != nil)` line) and `OpenListDragMountTests.atRestTheHalvesTakeNoClickSoTheRowsDoorsAct`
  — by the predicted mechanism: the ✕'s click was EATEN (all four rows stayed) and the row's tap answered instead (row 1
  selected). **R-T** — 5 / 1, RED EXACTLY `TitleQuickfillTests.tabTakesTheOfferedFirstLineAndEnterFilesIt` and
  `aNoteWithNoWordsIsOfferedItsDate` (Tab took nothing; the note stayed untitled — the old road), the rule/read/guard pins
  green. GREEN on the fixed tree: those suites in the chunks and `rerun1` (36 / 5, all but `redoNeverAsks`). No other red
  in any cycle. **The export seam on the merged tree** (dedicated runs for the merge ask): `ExportFacesTests` **6 / 1**,
  `PlaintextExportBringInRoadTests` **5 / 1**, `U2WordsTests` **13 / 1** — all GREEN. **`redoNeverAsks` BASELINE**: main's
  own tree (`dd469951e`, a temporary detached worktree built into its own DerivedData, removed after) fails it
  IDENTICALLY — `DestructiveUndoWarningTests` 7 / 1 with `redoNeverAsks` red, 3 issues (`redoDepth` stays 1, no "Redid")
  — so it is PRE-EXISTING ON MAIN, not this run's; ticket proposed (Tests & tooling or Editor, Bug, Confirmed): "the
  structural redo after a confirmed destructive undo doesn't re-apply in `DestructiveUndoWarningTests.redoNeverAsks`
  (red on main `dd469951e`)". Instances: both strict `pgrep` forms EMPTY after. Tree clean at `cc8cb7a32` before this record.

## WALK PART 2 (the orchestrator, 2026-10-27 06:11–06:28 MDT per the STAGE LOG — claimed 06:11:05, ONE +15 renew at 06:21:43, released 06:28:22; this header first said "06:10–07:20, two renews", the orchestrator's wrong clock, corrected at the coordinator's log check; captures `walk-shots-vx439/`, gitignored until the debris sweep)

On the stage-verified tree (Debug rebuild of `728456d1f`). Dev store as found and as left: unlocked, the Oct-20 hold
banner STANDING and untouched, Study voice, MCP off; VX-548's Trash content untouched; prefs diff zero added/removed
keys (only the app's own bookkeeping changed; a routine launch backup landed beside the store).

GREEN, seen live:
- **VX-125** — File ▸ Export Note… driven end-to-end through the REAL save panel: the written file is
  BYTE-IDENTICAL to Copy full text (sha-verified); ⌥⌘S declared on the item (mods=⌥⌘); the door also renders in the
  note ▾ menu. (And the door was ENABLED in Write all session — more VX-603 intermittency evidence.)
- **VX-126** — Export Library…: the tagged note's file leads `{#walk}` + body; an untagged, untitled note's file is
  plain; same-named notes disambiguate (`2026-10-27 F7F7F290.md`); `Readings/Walk Book.md` keeps its old shape.
- **VX-570** — ⌥⌘N inside a GATHERING in INDEX mode (batch 2's unobserved risk): minted through the planner, note
  born wearing #walk, assembled instantly ("2 of 2 in this book").
- **VX-441** — a query typed ONLY into the find bar + one step: the bar's trailing end reads "1 of 1" (the finder
  DOES write the find pasteboard — risk 3 resolved live).
- **VX-560** — in-editor ⌘← kept the view and moved the caret to line start; outside text (Library focused) ⌘←
  navigated BACK to the note.
- **VX-425** — the Open-row context menu complete (Open Beside · Open in New Window · Star — Rename… · Move/Copy to
  Wing ▸ · Export Note… — Close · Close All Notes — Delete Note…); the note ▾ menu carries the same acts.
- **VX-580** — untitled notes' Open rows read their first words ("Walk note one") instead of the date form.
- **VX-426** — AX help sweep: tooltips lead with names ("Tray — …", "Snippets — …", "References — …"), the
  back/forward doors speak live hints, the savepoint field and word-count speak their sentences.
- **The delete roads** — note deletes through the note ▾ door with the 30-day sheet; the plain book's confirm says
  "Deleting a plain book never touches a note"; the gathering's confirm says "No note is touched: a gathering holds
  none" with the button "Delete Gathering"; every receipt spoke.

NOT-REACHED (honest; pins + revert cycles carry the behavior): VX-569's live title-click+Tab (the driver missed the
title field twice; `TitleQuickfillTests` is revert-verified); VX-589's live toggle and the Settings General capture
(the Settings window never took the driver's clicks; the setting is pin-covered); VX-424's drag delivery (no
synthetic road reaches a sidebar drop — VX-375; her hand check is bundle item 11); the Terminal-voice captures
(driver time; VX-552/426 are token-driven).

WALK-FOUND NITS (tickets at the closeout sweep): (1) a GATHERING's Bookcase context menu ends in "Delete Book…"
while its confirm correctly says Delete Gathering — one label, Wording; (2) "+ new chapter" renders on a GATHERING's
navigator foot (gatherings refuse sections at the operation — a door that can never act, P-2; pre-existing, VX-217
era). One transient observation, no ticket: right after Create Gathering, one walk-cap listing showed a second
on-screen window holding the dialog's stale pixels; not present on re-list.

- 2026-10-27 **LADDER ROUND 1 DISPOSITIONS (the orchestrator, same-model ladder — arbitrated against the spec; the
  findings file is `vx-439-ladder-round1.md`, committed at `080e15a08`):**
  **M-1 ACCEPTED, fix in L1** (the P1 invariant outranks everything here; the mechanism is measured): `SidebarRowLeads`
  moves to `Queries.leadingBlockTexts` (flat, already query-plan-pinned) and narrows its observation; red-on-old pin =
  a statement/query-plan test on `SidebarRowLeads.read`. The `NoteCards` false-claim side-finding goes to a closeout
  ticket, not this run.
  **M-2 ACCEPTED narrowly, fix in L1, PROVISIONAL + bundled:** the toolbar's New Note is a third current-wing mint
  door, so her "always" reaches it; L1 adds the muted wing label beside it where the toolbar idiom carries a text item
  cheaply, else the label rides its tooltip and the shape goes to her morning (bundle). C-552-1's two-door premise is
  corrected in the record.
  **M-3 ACKNOWLEDGED — the orchestrator's own error:** the walk captures were swept into the branch by `git add -A`
  record commits (the ignore pattern matched `.walkshots-*/`, not `walk-shots-*/`). The tip is clean as of
  `080e15a08` (untracked + ignored; files kept on disk for her morning look); the ~11 MB in BRANCH HISTORY is hers to
  rule: rewrite the unmerged branch before the PR (one force-with-lease at her word — never autonomous) or accept it
  into main's history. Bundle item.
  **m-1 ACCEPTED, fix in L1** (traced: a WKWebView text input + ⌘← navigates the pane away): the not-while-text rule
  learns web-view first responders; pin red-on-old.
  **m-2 ACCEPTED, fix in L1:** cache the readout's match ranges per (needle, options, text generation); the record's
  "a find step is itself a whole-note walk" justification is retracted in place.
  **m-3 ACCEPTED, fix in L1:** the row menus' wing listing takes the `WingNoteDoors` one-shot re-read contract
  (`onDone`); pin red-on-old (move from the row → reopen menu → fresh list).
  **m-4 PARTIALLY ACCEPTED:** the VX-589 pins' justification text is corrected (the cited capture shows the MCP pane —
  an evidence-honesty fix in the pin comments); the LIVE evidence gaps (VX-589 toggle, VX-569 title-Tab, VX-425's
  three asks, a true Settings General capture) fold into ONE post-fix EVIDENCE SLICE under the fix-verify stage
  window; VX-424's drag delivery stays her morning hand check (bundle 11, unchanged).
  **m-5 ACCEPTED, fix in L1:** `NoteExportMenuGateTests` gains `.disabled("never executed — the VX-604 host-crash
  class; re-enabled by the VX-603/604 work")`.
  **m-6 ACCEPTED AS CLOSEOUT WORK:** the canon sweep list (SurfaceContracts' tour line and keyboard family; MCPSpec's
  one Help-label sentence — applying VX-602's ruled rename exactly, one pointer; the Open-list row menu + hide-starred
  filter lines; Export Note + bulk export as document-format clients) joins the closeout's canon deltas, each a
  contract line + pointer, nothing beyond the rulings.
  **m-7 SPECULATIVE — conditional:** L1 writes the pin FIRST (dragging latched + the dragged row gone ⇒ the halves
  must not be hit-testable); red ⇒ the cheap guard lands; green-on-old ⇒ RECORD-ONLY per the hallucination guard, and
  the finding is noted hollow.
  **n-1 / n-3 / n-5 BUNDLED** (journal-profile title offer; the Library's second export door "Markdown with Takes…"
  beside Export Note — consolidation is her taste call; the one-turn faint-text swap). **n-2 ACCEPTED in L1** (the
  write-failure message names the error). **n-4 ACCEPTED** (LIVE STATUS freshened by L1's record flips).
  **The reviewer's scope note (two editor-seam FILE touches, chrome-only, measured O(1)):** her kickoff word chose the
  Opus reviewer for this run knowing VX-441 was a member; the touches change no storage/layout/identity code. Round 2
  stays Opus per her word; the two lines are NAMED in the morning bundle so she can order a Fable pass if she wants
  one.
