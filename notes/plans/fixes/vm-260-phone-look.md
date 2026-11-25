# VM-260 — Umbrella: the phone's look — the explicit changes

**STATUS: OPEN — kickoff 2026-11-24 (Pro). `/architect-phase vm-260`; the stage coordinator this window is `nov24`.**
Ticket VM-260 (team VM, project "Mobile — the catch-up & launch") · branch `vm-260-phone-look` ·
worktree `~/dev/variorum-vm-260` · PR: — (opens at the ladder).

## FOR A LATER READER

*(Written at closeout from the settled facts. Until then, the LIVE STATUS table below is the state.)*

## What this run is

Her explicit look changes to the phone, as one runnable umbrella — **no separate design session**, her word
(2026-11-24): "I don't think it needs its own complete session or redesign, I think that the main problem is
everything being too big and somethings not matching the mac's app of having more squares. the icons I mentioned
that need to be changed are also going to help." And: "I think that we can ticket what I've already said about
redesign and I'll just assess from after that umbrella of explicit changes that I've talked about being done,
because I don't know how much I'm just judging what feels like ridiculously oversized icons versus the actual
design of the app."

Her verdict on wave 1's look that opened this (2026-11-22): "I feel like I like the new UI less than theo ld one
in many ways - it feels forgettable and overly crowded. it didn't get the same treatment that the mac got in many
ways - the pills are rounded boxes, it looks like a forgettable phone UI. it used to look more distinct and
principled." On the sizes, from her two side-by-side screenshots of a note with the keyboard up: "the top part is
so huge it takes up half of the area. maybe the minimum icon size was set too high or something like that. I feel
like it really wasn't perfect earlier either but it was smaller and i liked the icons at the top being smaller and
less obtrusive. i didn't like where the toast was going and such though. you can see from looking at these two
images that we moved between extremes."

**What wave 1 gained stays:** real 44-point tap areas (as invisible targets, not drawn sizes), one set of
controls, the library's own colours. **She assesses the whole after this umbrella ships** and rules then whether
more is owed. QUESTIONS #281 (the forty-one wave-1 look calls) is largely overtaken by this umbrella; what it
leaves standing is dispositioned at this run's close.

## The roster (the sub-issue listing of VM-260, read 2026-11-25 — eight members)

| Member | What | Kind · Priority |
|---|---|---|
| VM-253 | The bottom bar stays still when swiping between pages; only the highlighted chip changes | Bug · High |
| VM-265 | A direction on the message line reads in a neutral colour, not the alarm red (ruled: P-55-19 → (b)) | Improvement · Medium |
| VM-255 | Home pages' top line: no page word, a Settings gear, the trash door only on the Library, the Mac's icons for trash and new note | Improvement · High |
| VM-273 | Drawn controls step down phone-wide: smaller glyphs inside the 44-pt targets, squarer shapes like the Mac's | Improvement · High |
| VM-272 | A note's top takes half the screen with the keyboard up: the title row, tools and chips step down (P-47-12's road (b)) | Improvement · High |
| VM-247 | The phone chooses its own look on the device — voice, palette, background, appearance all per-device; the cream background stays an option | Feature · High |
| VM-254 | Text size: a setting to choose it, or a smaller default | Feature · High |
| VM-259 | Library: the top rows give way while scrolling (design first: two or three drawn options, then her pick) | Improvement · High |

**Riders — SHE TOOK ALL THREE (R-260-4):** VM-256 (tapping Library on the bar opens the Library root, not the
note last open there — the tab road, VM-253's file), VM-275 (a refusal line clears on leaving its note and never
squeezes the list — the message line, VM-265's file), VM-277 (refusals: a much shorter line, dismissable, the
full reason behind a tap or a swipe — the message line's anatomy). All three re-parented as VM-260 sub-issues at
kickoff; the roster is eleven members in five batches.

## The cast

Fable orchestrates (this session) and cold-reviews (`fable-reviewer`, a fresh one per ladder round);
`opus-implementer` at xhigh builds every batch, a fresh session per batch. No fan-outs; at most one Sonnet
subagent, external facts only, read-only. **The orchestrator never implements.** No `Sync/`, custody or editor-seam
line is expected anywhere in this run; if a batch finds it needs one, it STOPS and reports — an editor-seam line
(anything in `MobileEditorTextView` or the text view's core) escalates to a Fable review with TEXTKIT2_NOTES read
at that batch's preflight.

## Binding principles (the 13b constitution, copied verbatim per the architect skill)

- **P-1 — One capability registry.** Every user-facing act is declared exactly once: verb, scope
  (block/take/post/book), per-mode availability rule, its doors (menu / context / bar / shortcut / palette), and
  its refusal copy. Surfaces render their doors FROM the registry; gating is data, never per-view if-statements. A
  registry-walk test asserts every declared door exists and every rendered door is declared. This kills the D3/D4
  class structurally — the capability matrix stays green by construction instead of by audit.
- **P-2 — Fire-and-DO (R115).** A rendered door either performs the act — including any mode-switch choreography,
  done visibly for the user — or delivers the operations layer's real refusal. A door that can never act in its
  context isn't rendered. Lecture-and-redirect is retired.
- **P-3 — One text surface, one liveness authority.** ONE TK2 surface component (live + read modes; one
  measurement brain — the width-gated remeasure; the shared canary) that every pane composes; the live editor
  core's identity machinery (`BlockRangeIndex`, crystallization) becomes its live mode, not a sibling
  implementation. "What text does this pane show, and is it live" is answered by ONE pure, unit-tested authority
  (`PaneTextAuthority`); views never re-derive it. Its invariants stated as code: exactly one live pane; the live
  pane is buffer-authoritative; read panes are projection-authoritative once caught up.
- **P-4 — Broadcasts carry signals, never decisions.** NotificationCenter may announce that something happened
  (mode changed, post opened); no listener derives business state or availability from a broadcast, and no flow's
  correctness depends on broadcast ordering. Cross-feature flows route through composition. (Stage 0's survey
  enumerates today's notification bus; Stage 1 disciplines it.)
- **P-5 — The friction doctrine (R116).** Repeated pushback against a rule marks an under-architected feature. The
  response is never another patch: write the feature's DESIGN MEMO — intended behavior whole, edge cases
  enumerated on paper, refusal wordings, undo story — get the author's rulings on the product-flavored edges, then
  build to the memo. Happy path ships first, but the edges are *decided at design time*, not discovered by the
  author. First two memos owed: **merge** and **the W ceremony**.
- **P-6 — The tutorial is the executable spec (R113).** The guided tutorial flow is the contract for every happy
  path. It stays green — automated where the harness allows, screenshot-walked otherwise — and any change that
  breaks a tutorial step is a regression by definition.
- **P-7 — Find bugs before she does.** Every layer keeps a proactive harness: the ops-layer soaks (exist), the
  board/view-model invariant soak (Stage 1), the registry walk (P-1), the per-batch scripted screenshot
  walkthrough. Red-on-old stays absolute: no bug-class fix without a pin that fails on the pre-fix code.
- **P-8 — Standing law, consolidated.** P1–P3 performance invariants bind the rebuilt layer exactly as they bind
  the substrate (invalidation ∝ realized rows; one live editor; virtualized long views). Overlays, never rendering
  attributes. Chrome `fixedSize` texts always carry a `lineLimit` (the b6dae25 class). `Theme/VoiceControls.swift`
  is THE chrome vocabulary. Complexity lives in the store; restraint lives in the UI.
- **P-9 — No god objects in the frontend either.** A view model mixing board layout, text authority, and gesture
  routing splits by concern (`TakesViewModel` at 890 lines is the standing counterexample). Same hygiene rule as
  the substrate, applied where it was being waived.

*(Application notes for this run: the phone's equivalents hold — `PhoneControls`/`PhoneType`/`PhoneMetrics` are
THE phone chrome vocabulary (P-8's phone form, pinned by the VM-47 source scans: no private control builds, no
literal or system colour); the one message seam stays one brain (`StatusCenter`), the phone's face only changes
ink; P-3 on the phone means the Write screen's chrome never grows a second liveness road.)*

## What binds every batch

- **The contracts:** `notes/SurfaceContracts.md` — "The app" (the phone's sizes/inks/grounds, the bottom bar, the
  phone's Settings, the one message line) and "The Library" (the phone's Library) — read by the implementer at its
  batch's start, never summarized by the orchestrator. The VM-47 record's FOR A LATER READER
  (`notes/plans/vm-47-sizes-and-look.md`) is the map of the files this run re-enters.
- **What stays, pinned:** the 44 × 44 pt invisible tap targets (`phoneHitArea`); the 13 pt type floor in SwiftUI
  AND UIKit; no literal or system colour outside the token layer; no private control builds (the VM-47 source
  scans must stay green); the Mac's look byte-unchanged (`VoiceTokens.swift` and the Mac token pins); P1/P3; the
  one message seam's kinds (VM-265 changes the phone FACE's ink only).
- **The keyboard-reveal UI test** (`VariorumMobileUITests/MobileKeyboardRevealUITests`, scheme `TK2SpikeUITests`,
  a dedicated simulator under a stage claim) RE-RUNS on any change to the band's clip or frame
  (`MobileShellView.body`), the Write screen's layout (`MobileWriteView`) or the editor host's keyboard handling —
  batch 2 changes `MobileWriteView`'s chrome, so batch 2 runs it. No unit target's whole run includes it.
- **Pin before fix, per member.** Bug-class members land red-on-old, verified by revert. Look-class members pin
  what is pinnable (source scans, geometry, ink resolution) and otherwise verify by capture.
- **Stage (the nov24 coordinator's protocol, received at kickoff):** EVERY `xcodebuild test` run (Mac or
  simulator) and every walk needs a HELD `Tools/stage` claim — claim name `vm-260` — and a GO from `nov24`
  first; a FREE stage is never an invitation. REQUEST early (what, minutes); READY as its own ping once able to
  start NOW (keep building headless meanwhile); RELEASE the claim then one result line: executed/passed/failed
  with EVERY failing test named, zero Variorum instances, Problem Reporter, new crash reports counted by time.
  Headless `swift build`/`swift test`, `xcodebuild build` and `build-for-testing` need no stage. Simulators: our
  own device by UDID only, never an every-simulator command; shut it down before RELEASE ("no booted
  simulators" in the line); phone suites have run on the coordinator's named iOS 26.2 device (`<simulator-udid>` — nov24 hands the
  id at the GO); an iOS 27 device first gets intelligencetasksd disabled inside it, then 5 min settle after
  boot, no timing-sensitive run with load in double figures; "Executed 0" or a hung runner is NO VERDICT — one fresh boot, settle, retry once (~8 min
  budget). The queue as of kickoff: vx-1013's ~50-min gate window outranks us when READY; then short before
  long. The Sync/-custody slot is vx-1013's tonight (we need none).
- **Mac legs early (the VM-64 lesson):** this run touches `Shared/Theme/` — the Mac source-scan suites and the
  Mac token pins run at batch 1's gate, not only at the end.
- **Resiliency:** `notes/SessionResiliencyProtocol.md` binds — commit per piece, LIVE STATUS from the first
  commit, push after every commit, synchronous foreground waits only (poll the log, never `tail -f | grep -m1`).
- **Screens:** captures in gitignored `notes/plans/vm-260-screens/` (the `*-screens` convention).

## The batches (each one acceptance unit, one fresh implementer)

### Batch 1a — the bar and the top line (VM-253 · VM-256 · VM-255)

- **VM-253 (Bug):** the bar (`VariorumMobile/Features/Shell/MobileTabBar.swift`) rides the page slide — the
  agent note's suspicion is that it is composed per page by the destination builder. TRACE FIRST, the note is
  not a trace. Fix: the bar drawn once by the shell, outside the paged band; only the highlighted chip changes.
  Pin before fix: the bar is drawn once, outside the paged band — red on old.
- **VM-256 (rider, R-260-5 ruled):** leaving a page returns it to its root, a pushed NOTE included — tap or
  swipe; arriving anywhere always shows the page itself. The quiet savepoint rides the existing leaving occasion
  (the note stops being shown ⇒ `closeAutoCommit`'s own rule; the phone's leaving road already exists — VM-71's
  read-then-write shape). P-71-1 retires with its premise (recorded in R-260-5; the ledger addendum at the
  merge). Pin: a note pushed on a root's stack is gone from it after leaving and returning; the leaving
  savepoint written exactly once.
- **VM-255 (her four changes, verbatim in the ticket; R-260-1/-6 ruled):** the page word leaves the roots' top
  line — the line is the wing's name alone (the wing door; P-55-2 was already unratified); the Bookcase's count
  moves to a quiet muted second line under the wing's name, Bookcase only ("12 books"); the ⋯ becomes a Settings
  gear (S-260-1); the trash door only on the Library; the Mac's trash glyph (monochrome, replacing the 🗑 emoji
  — supersedes P-47-31's (a)) and a writing glyph for new note (the Mac's idiom). Today:
  `Shell/MobileRootMenu.swift` (the ⋯, one item), the 🗑 door on all three roots, "+ New Note" as a 15-pt word.
  The Mac's glyphs are in its sidebar and masthead code — reuse the SYMBOL choices, not the Mac views.
- Evidence: pins red-on-old per member (VM-255's look lines pin what is pinnable — the gear's door, the trash
  door's fence to the Library, the glyph names; the rest by capture); a targeted capture set (the three roots, a
  swipe mid-flight) on a dedicated simulator under a stage claim; the Mac source-scan suites + Mac token pins
  green AT THIS BATCH (the VM-64 lesson — this run touches files both targets compile).

### Batch 1b — the message line (VM-265 · VM-275 · VM-277)

One design pass over the phone's refusal face takes all three (VM-277's ticket says exactly this). The seam's
kinds are untouched everywhere — ink, clearing and anatomy are the FACE's.

- **VM-265 (ruled, P-55-19 → (b)):** a DIRECTION draws in a neutral colour (the phone's muted ink family);
  refusals keep the alarm. Extend `MobileLineDirectionTests`; pin the ink class.
- **VM-275 (Bug; her rule in the ticket):** a refusal raised in a note clears when she leaves that note — only
  the clearing learns about navigation; P-55-3's fade stands otherwise. AND the line never squeezes the list:
  it overlays or reserves without moving rows (the face is already an overlay window — trace why the list
  shrinks; her recording's facts are in the ticket). Pins red-on-old for both halves.
- **VM-277 (her ruling in the ticket, verbatim):** "refusals should be dismissable and they should be much
  shorter. maybe you even have to click on it for the reason (or it's clear that you could swipe upwards for
  the reason on it)". So: a refusal's line carries a SHORT headline (the refusal table gains a short form per
  sentence — propose the mechanism, don't fork the table's one-brain law); a dismissal gesture joins the fade
  (P-55-3 superseded for refusals); the full reason opens on demand — the gesture and its signpost are this
  batch's design call (the implementer proposes, the architect rules, BEFORE building that half — the in-batch
  fork rule). Scoped to the phone's one line; the Mac's toasts are untouched (hers to say later).
- Evidence: pins per member; captures of a refusal (short line, dismissal, the reason opened), a direction, and
  a receipt, both voices; canon notes for the merge — SurfaceContracts' phone-line bullet and the QUESTIONS
  #277 addendum (P-55-3's refusal arm superseded), this run the pointer.

### Batch 2 — the drawn step-down, phone-wide and the note's top (VM-273 · VM-272)

- **VM-273:** the drawn glyph and control sizes step down toward the pre-wave-1 feel INSIDE the unchanged 44-pt
  targets; the rounded pills move toward the Mac's squarer treatment ("more squares"). The pass lands in the
  central files — `Shared/Theme/PhoneType.swift`, `PhoneControls.swift`, `PhoneMetrics.swift` — so it reaches
  every screen, including what wave 2 adds later. Wave 1 drew many controls at or near target size; that is the
  mechanism of "ridiculously oversized icons".
- **VM-272:** the note's top with the keyboard up gives the screen back to writing: the tool glyphs shrink inside
  their targets (P-47-12's road (b) — the tools at 17 pt with only a 44-pt frame — rather than the built (a)'s
  22-pt icon buttons), the title and the rows above the text tighten. The Write screen's CHROME only
  (`MobileWriteView`) — never the text view's core; the full masthead rebuild (slim bar on scroll, rename in
  place) stays VM-148's, wave 4.
- Evidence: before/after captures at her three screenshot sites (a note with the keyboard up, the Bookcase root,
  the Library), both voices; the keyboard-reveal UI test on the final tree; the whole phone target; the Mac legs.
  Her side-by-side screenshots are the reference: the target is the pre-wave-1 feel's SIZES with wave 1's
  mechanisms.

### Batch 3 — the phone's own look (VM-247 · VM-254)

- **VM-247:** the whole of Settings ▸ Look becomes this phone's own — voice, palette, background, appearance —
  stored on the device like Appearance already is (`AppearanceChoiceRule`'s road), never reading or writing the
  library's synced look. A Palette row joins Settings ▸ Look; **the cream background stays an option** (P-47-16's
  road (b) becomes a phone choice). Her words: "I don't like that the theme syncs between mac and phone either
  it's annoying." · "the voice should also be per device." What the phone wears before any choice: her kickoff
  ruling below. The Mac is untouched; the synced `setting` rows are untouched (the phone just stops reading them
  for Look).
- **VM-254:** per her kickoff ruling below (the options were: a text-size row in Settings ▸ Look; a smaller
  default set; both; her words — scale her words only or the chrome too). The type layer is roles in one table
  (`PhoneType.swift`), so it lands in one place. The 13-pt floor and 44-pt targets stay.
- Evidence: pins — the per-device store (a Look change writes no `setting` row, no outbox row; a synced look
  change moves the phone nothing); captures of Settings ▸ Look and the cream room; the whole phone target.
- **Canon owed at closeout:** AppSpec §12's "appearance is local while voice and palette are library-wide" gains
  the phone's exception; SurfaceContracts "The app" (the phone bullet rewritten); `notes/MobileSoul.md`. Applied
  at the merge in the two-file shape, VM-247 the pointer.

### Batch 4 — the Library's top gives way (VM-259)

- **Design first:** two or three drawn options (local HTML mockups beside real captures; never published) for how
  the Library's top — the header, the search field, the filter row — gives way as she scrolls and comes back; her
  pick at a checkpoint sitting; then the build. Her words: "the top row should also collapse while I'm scrolling -
  I'm open to ideas on how that should happen… the app just feels like it's fighting for space". VM-148 already
  draws "a slim bar once you scroll" for the note's top (wave 4) — at least one option should rhyme with it. The
  same question applies to the Bookcase and Starred where their tops are tall — the options say what they'd do
  there; building beyond the Library is her call at the pick.
- Evidence: her pick recorded verbatim; scroll captures before/after; the paging law untouched (the listing's
  re-ask discipline, VM-68's contract).

Order: 1a → 1b → 2 → 3 → 4. Batch 4's mockups may be drawn (by the orchestrator, as sitting material, or a
design-only implementer) while an earlier batch builds, so her pick is ready when its build slot arrives — but
only one implementer session runs at a time. VM-254's text-size row waits for batch 2's chrome step-down to
land first, so its "one notch smaller" default is judged against the corrected chrome.

## The ladder and the gate

One ladder over the run's whole diff at the end (fresh `fable-reviewer` per round, `notes/REVIEW_PROMPT.md`
verbatim, zero framing); up to five rounds, a further round only while the last found a BLOCKER/MAJOR. The merge
gate: the whole phone target (one launch, counts read against main's known reds); the speed suite alone
(`TEST_RUNNER_VM66_PERF=1` — a whole-target run skips it and a skip is never read as a pass); the Mac suites that
exercise every changed SOURCE file (the `Shared/Theme/` scans and token pins at minimum); the keyboard-reveal UI
test if batch 2 touched `MobileWriteView` (it will); the closing walk on a dedicated simulator, both voices. The
umbrella's real close is HERS — she assesses the whole on her phone after it ships; the handoff bundles the
install and the #281 dispositions.

## Review foci (written at plan time)

1. The 44-pt targets after the step-down: every control still answers at 44 × 44 even where its drawn size fell
   (the wave-1 scans bind; a shrunk glyph must not shrink its hit area).
2. The Mac untouched: `VoiceTokens.swift`, the Mac token pins, the Mac source scans — `Shared/Theme/` is read by
   both platforms.
3. VM-247's fence: no Look read reaches the synced settings; no Look write produces an outbox row; the seed rule
   exactly as ruled.
4. VM-253/VM-256: the tab road's pop law (P-47-19) after the bar moves out of the paged band.
5. VM-272 stays chrome: zero lines in `MobileEditorTextView` or the text-input path; the keyboard-reveal test
   green on the final tree.
6. The message line: kinds decided at the seam, ink decided at the face; no string-matching on sentences.

## Her rulings at kickoff (2026-11-24/25; each a pick from a question-tool batch, her typed words quoted where she typed)

- **R-260-1 — VM-255's top line.** Her typed answer: "bookcase shouldn't have its count on the same line, but it
  should have its count". So: the line shows the wing's name alone (the wing door) on every root; the Bookcase
  keeps its count OFF the line.
- **R-260-2 — VM-254's shape.** Her pick: "Setting + smaller default" — a text-size row in Settings ▸ Look
  (about five steps) scaling HER WORDS only, AND the default drops one notch from today's set; the chrome stays
  fixed (batch 2 owns chrome sizes). The exact step values are the implementer's to propose, PROVISIONAL as a
  set (the P-47-1 pattern); the 13-pt floor stands.
- **R-260-3 — VM-247's seed.** Her pick: "Sea-glass default" — the phone starts at the app's own fresh default,
  Study under the sea-glass, until she picks; the library's synced look is simply no longer read on the phone,
  so the synced purple goes away on update. No seed-from-library copy.
- **R-260-4 — the riders.** Her pick: VM-256, VM-275 AND VM-277 all ride.
- **R-260-5 — VM-256's leaving semantics.** Her pick: "Note closes on leaving" — the uniform law: leaving a page
  (tap or swipe) returns it to its root, a pushed NOTE included, so arriving anywhere always shows the page
  itself; the quiet savepoint fires when the note stops being shown (the existing `closeAutoCommit` occasion —
  no new operation). **P-71-1 ("switching tabs is not leaving a note") retires with its premise** — the note no
  longer stays open hidden; the QUESTIONS #280 addendum lands at the merge, this run the pointer.
- **R-260-6 — VM-255's count placement.** Her pick: "Muted line under the wing name" — a quiet second line in
  the phone's muted ink ("12 books"), under the wing's name, the Bookcase only.

## Scope calls made at kickoff (the orchestrator's; each on the ratify list)

- **S-260-1 — the gear displaces nothing built:** wave 1's ⋯ holds ONE item (Settings); wave 2's "wing management
  behind a ⋯" is a mockup, not built. So VM-255's gear replaces the ⋯ outright, and wave 2's home-page doors find
  their home when VM-72/VM-80 build (their design, not this run's). PROVISIONAL.
- **S-260-2 — VM-255's trash/new-note glyphs** reuse the Mac's SF Symbol choices (one vocabulary), drawn at the
  phone's stepped-down icon sizes; no new glyph language is invented.
- **S-260-3 — the squarer shapes** take the Mac's corner idiom (the near-square light-wash chip family the
  Bookcase strip already uses as reference) as the target; exact radii are batch 2's to propose in its record,
  captured for her assessment, PROVISIONAL as a set (the P-47-1 pattern).

## LIVE STATUS (the orchestrator's; flipped as state changes)

| What | State |
|---|---|
| Preflight (canon, master plan, TICKETS, QUESTIONS #277/#281, SurfaceContracts in full, resiliency protocol, vm-47/vm-55/vx-1033 FOR A LATER READER, vm-44 plan, MobileSoul) | DONE 2026-11-24 |
| Workspace: branch `vm-260-phone-look`, worktree `~/dev/variorum-vm-260`, in-flight row (main `6e36f3c95`) | DONE |
| Linear: VM-260 In Progress | DONE |
| Kickoff sitting: six rulings R-260-1…6 recorded | DONE 2026-11-25 |
| nov24 coordinator announced; its protocol folded in above | DONE |
| Riders re-parented under VM-260; batch 1a members In Progress | DONE |
| Batch 1a (VM-253 · VM-256 · VM-255) | NOT STARTED |
| Batch 1b (VM-265 · VM-275 · VM-277) | NOT STARTED |
| Batch 2 (VM-273 · VM-272) | NOT STARTED |
| Batch 3 (VM-247 · VM-254) | NOT STARTED |
| Batch 4 (VM-259: design → pick → build) | NOT STARTED |
| Ladder · gate · walk | NOT STARTED |
| Closeout (canon deltas, #281 dispositions, #277 leftovers touched by this run, parity row, handoff) | NOT STARTED |

## BATCH 1a — record (VM-253 · VM-256 · VM-255; implementer: Opus, 2026-11-25)

**What this batch did NOT do (kept current):** no test has been RUN yet — every result below is PENDING until the
stage GO; no walk yet (captures PENDING); no line in `Sources/`, `Sync/`, custody, `MobileEditorTextView` or the
text-input path; `Shared/` untouched; the one message line untouched (batch 1b's).

### LIVE STATUS

| Piece | State |
|---|---|
| 0. Preflight (CLAUDE.md + canon, this record's binding sections, the resiliency protocol, SurfaceContracts' phone bullets, the VM-47 FOR A LATER READER, the three tickets' bodies); the screens folder made gitignored | DONE (this commit) |
| 1. VM-253 — the trace; the pins on the pre-fix tree (and the held-drag seam they need) | DONE (this commit) — `MobileTabBarStaysStillTests` (3 tests) + `MobileShellView(heldDrag:)`; phone `build-for-testing` green on this tree; red-on-old PENDING (the stage) |
| 2. VM-253 — the fix: the bar drawn once by the shell, outside the paged band | NOT-STARTED |
| 3. VM-256 — the trace; the pins on the pre-fix tree | NOT-STARTED |
| 4. VM-256 — the fix: every page change returns the page left to its root; a push never lands on a page not showing | NOT-STARTED |
| 5. VM-255 — the top line: the wing's name alone, the Bookcase's count under it, the gear, the trash on the Library only, the Mac's glyphs; pins | NOT-STARTED |
| 6. Phone + Mac `build-for-testing` green; READY-FOR-TESTS | NOT-STARTED |
| 7. The suites (each pin red on old by behavioural revert, then the batch's suites green) | PENDING (needs the stage GO) |
| 8. The walk: the three roots and a swipe mid-flight, both voices | PENDING (needs the stage GO) |


### VM-253 — the bar rides the page slide

**Traced mechanism.** The bar was never the shell's: each root drew its own copy at the foot of its VStack
(`tabBar()` in `MobileStarredView`, `MobileShelfView`, `MobileLibraryView`; the shell handed each `{ tabBar }`), and
each root sits inside `MobileShellView.page(_:width:)`, whose `.offset(x:)` moves the whole page by the band's live
drag and by the settle's animation of `tab` — so a swipe slid the Bookcase's copy out and the Library's copy in, two
half-bars meeting at the seam (a pushed list wore a fourth copy inside its stack, `listBar`).

**The seam the pins need.** `MobileShellView(heldDrag:)` — a band drag held at an offset, zero in the app (the
`MobileWriteScreen(editor:)` test-seam precedent), clamped by the band's own rule: a real `DragGesture` is not
drivable in process, and mid-flight is where the defect lives. Committed with the pins, so the pre-fix tree for the
red-on-old run is exactly this commit.

**Pins** (`VariorumMobileTests/MobileTabBarStaysStillTests`):
- `theBarIsDrawnOnceByTheShell` — one copy of each bar door in the whole walk, at rest and with the Library's Trash
  pushed, at the same frames. Expected RED on old: three copies at rest, four with the list. PENDING.
- `midSwipeTheBarHasNotMoved` — the band held 160 pt toward the Library: the Library's "All" door is on the window
  (the band moved) and every bar door is on the window once, at its resting frame, the chip still on the Bookcase.
  Expected RED on old: "Bookcase" on the window twice, "Library" and "Starred" 160 pt off. PENDING.
- `aPageChangeMovesOnlyTheChip` — a guard (green on both by construction: at rest the old copies coincide; the motion
  was mid-flight). PENDING.
