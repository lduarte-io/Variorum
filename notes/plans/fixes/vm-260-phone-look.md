# VM-260 — Umbrella: the phone's look — the explicit changes

**STATUS: OPEN — kickoff 2026-11-24 (Pro). `/architect-phase vm-260`; the stage coordinator this window is `nov24`.**
Ticket VM-260 (team VM, project "Mobile — the catch-up & launch") · branch `vm-260-phone-look` ·
worktree `~/dev/variorum-vm-260` · PR: — (opens at the ladder).

## RESUME HERE (state at the 2026-11-25 ~04:0x compaction; her ask: "prepare for compaction … I'll compact you since you still have batches and a ladder")

**Where the run stands.** Batches 1a and 1b are BUILT: 1a's suites green, its UI test green on the walk device,
its walk run and read — every stop PASS in both voices except **F-1a-W1 (MAJOR, OPEN)**, the bar under the
Library-search keyboard; 1b is READY-FOR-TESTS awaiting its one window (A-260-7). Batch 2's implementer is LIVE
in this worktree, headless (the coordinator's nice-mode was never formally lifted — keep `nice -n 15` on heavy
jobs until nov24 says cleared). Batches 3 and 4 NOT STARTED. Ladder NOT STARTED. Away mode (THE AWAY RULING)
and R-260-7 (the morning install) govern the night.

**Owed at batch 2's boundary, in order:** (1) merge `origin/main` at `1a7b0d444` (PR #28, notes; it contains
`5ca093319`, PR #27 — the run's FINAL gate legs must run on a tree containing #27); (2) the F-1a-W1 fix by
batch 1a's implementer — ONE writer per tree, never two implementers at once; its re-evidence (a contract pin
red on the current tree, the s9 capture re-taken, the keyboard-reveal UI test) folds into the next window;
(3) batch 3 spawns (VM-247 · VM-254 — the Batch 3 section is the brief); (4) the VM-259 options drawn at batch
2's corrected sizes (two or three local HTML mockups under `notes/plans/vm-260/`, committed, NEVER published as
Artifacts) for her morning pick; batch 4 builds only after that pick.

**The stage (nov24):** 1b's full window is queued after VX-1082's revert cycles and VX-1036's window; claim
name `vm-260`; the full protocol is under "What binds every batch". The walk DEVICE is named `vm260-walk` —
recover its UDID with `xcrun simctl list devices | grep vm260-walk`, NEVER commit the id; shut it down between
windows; DELETE it at closeout (`xcrun simctl delete`) and say so to nov24. The walk WORKTREE is
`~/dev/variorum-vm260-walk` (DETACHED at `19b31c4c3`): it holds the UNCOMMITTED throwaway driver
`App/Variorum/VariorumMobileUITests/VM260WalkDriver1a.swift` (the 1b line-walk driver adapts it; the swipe-burst
sync polls `/tmp/vm260-walk-go`) and `DerivedData/vm260-walk1a` — keep until closeout, then
`git worktree remove --force` it. Captures: `notes/plans/vm-260-screens/batch-1a/` (gitignored, KEPT for her
sitting; `s5-note-bar-gone…png` is batch 2's "before" at the note top; `swipe-burst/f04.png` is the mid-swipe
money shot).

**Session-local agent handles** (meaningful only inside this session's continuation; a FRESH session spawns
narrow continuations briefed from this record instead): batch 2's implementer `a0ec19b54b0cfa201` (LIVE),
batch 1a's `a04567e8a4ed418a1` (owes the F-1a-W1 fix), batch 1b's `a6eb5f3c3d1dca464` (done, pending window).

**Then, in order:** the remaining windows via nov24 · the ladder (a FRESH `fable-reviewer` per round,
`notes/REVIEW_PROMPT.md` VERBATIM, zero framing, over the run's whole diff; cap five, a further round only
while the last found a BLOCKER/MAJOR; the cross-model flow — the reviewer makes the final call, the implementer
applies confirmed fixes red-on-old, the next fresh reviewer re-checks; a final round's fixes get the
orchestrator's line-by-line read) · the run MERGE GATE on a tree containing PR #27 (the whole phone target in
one launch read against main's known reds; the gated speed suite ALONE — a skip is never a pass; the Mac suites
covering EVERY changed source file; the keyboard-reveal UI test; the closing walk) · the morning bundle and the
handoff `notes/handoffs/vm-260-handoff.md` with R-260-7's INSTALL BLOCK FIRST (the device .app PRE-BUILT
overnight, headless, no stage; the exact SHA named; the devicectl steps self-contained; the what-to-try-first
list) · closeout per CLAUDE.md and the architect skill: canon deltas (AppSpec §12 — the phone's look
per-device, VM-247 the pointer; SurfaceContracts — the phone-look bullets, the bar's keyboard line, the card,
VM-255's top line, P-55-3's refusal arm and P-47-31/-36 supersessions; `notes/MobileSoul.md`);
`notes/AppSpecRecord.md` dated entry; QUESTIONS at the merge — the #281 dispositions (what stands returns
there), the #277 addendum, #280's P-71-1 retirement (R-260-5), the new PROVISIONALs (P-260-1a, C-275-1, the
size/radii set, the card shape, the draft words and headlines); the MOBILE PARITY line; every ticket the effort
FILED triaged (VM-279 so far); the in-flight row retired; worktrees removed, the walk device deleted, the
branch deleted after the merge; `Tools/canon-size`; her tickets-filed checklist as the session's very last
message.

**The post-compaction kickoff (paste-ready):** *"You are the VM-260 run's orchestrator (architect shape,
session vm-260), resuming after compaction. Before anything: re-read
`notes/plans/fixes/vm-260-phone-look.md` — RESUME HERE and LIVE STATUS first, then the sections a step needs.
The standing rules: you never implement (small ruled adjudication fixes only, never on the editor seam); one
implementer at a time, `opus-implementer` per batch, fresh per batch; every `xcodebuild test` and walk only
inside a GO'd stage window from nov24, claim `vm-260`; rule provisionally (her away ruling) and bundle
her-hands items for the morning sitting; the morning install leads the handoff (R-260-7). Pick up at: the
batch-2 hand-back (adjudicate its size/radii set), then the boundary order RESUME HERE names."*

## FOR A LATER READER

*(Written at closeout from the settled facts. Until then, RESUME HERE and the LIVE STATUS table are the state.)*

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

**Cast change, 2026-11-25 ~08:1x (hers):** *"continue - I hit my fable limit but I have opus credits."* The
orchestrator continues on **Opus 5.5** from the final evidence window onward (same session, same record, same
rules). **The ladder's reviewer is HER call and is held for her:** the plan names `fable-reviewer`; the diff
carries no `Sync/`, custody or `MobileEditorTextView` line (verified per batch), but batch 3 touched
`MobileEditorStyle` (the editor's LOOK file: fonts, grounds, faces; zero text-input lines by grep), which a
reviewer could read as editor-adjacent. The options: (a) wait for Fable credits and run the ladder as planned;
(b) `opus-reviewer`, per CLAUDE.md's no-editor-seam rule, with `MobileEditorStyle` named as a review focus;
(c) Opus rounds now and one Fable round over the final diff when credits return.

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

### Batch 3b — two fixes she called (VM-281 · F-her-1; written 2026-11-25 ~11:2x, orchestrator on Opus)

- **VM-281 — the keyboard after a note's keyboard (R-260-9, sanctioned).** The defect and its evidence are
  the F-1a-W1 block and THE CONSOLIDATED WINDOW's reproduction row: after a keyboard session whose first
  responder wore the editor's 52-pt `inputAccessoryView` (`MobileKeyboardBar`), the next keyboard is reported
  52 pt short by BOTH SwiftUI's avoidance and UIKit's keyboard layout guide, so the band and the bar sit under
  the keyboard's glass. The traced cure (to be re-traced by the implementer, not taken on trust): the editor's
  text view drops its accessory as it resigns, so no stale accessory frame survives into the next keyboard
  session. **This is an editor-seam line** (`MobileEditorTextView` or its accessory host): the implementer
  reads `notes/TEXTKIT2_NOTES.md` at preflight, touches the fewest lines possible, and stays out of the
  text-input path's other behaviour (the typed-Return model, crystallization, the keyboard bar's own
  numbers R22/R25). **The pin is a UI test on the road that REPRODUCED** (the 1a walk's s5→s9 order: a NEW
  note opened with its keyboard up, Back, the Trash, two bar tabs, then the Library search), NOT the
  `testTheBarRidesAboveTheLibrarySearchKeyboard` road, which was HOLLOW on old (the search restored its own
  focus at Back). The oracle is that test's pixel oracle (the bar's doors draw as at rest; their frames end
  above the keys). Its commit is the red-on-old tree. `MobileKeyboardFloor` STAYS (the class guard).
- **F-her-1 — the duplicate "Done" (her finding).** While picking blocks, the Blocks sheet's picking door
  reads **"Cancel"** instead of "Done" — PROVISIONAL (P-260-3b-1; alternatives: (b) the sheet's own Done hides
  while picking, so one Done ends picking and a second closes; (c) one Done that ends picking AND closes).
  Why (a): iOS's own select-mode exit is "Cancel" where leaving drops the picks, which `exitSelection` does;
  no two doors in one header render one word. Pin: in picking mode the sheet header never renders two
  buttons with the same word (red on old). The VoiceOver names stay distinct as they are.
- Evidence: both pins red-on-old in the gate window; the keyboard-reveal class re-run (the editor's text view
  changes); the whole phone target. Review focus added: VM-281's line, read against TEXTKIT2_NOTES and the
  keyboard bar's rulings.

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

### Batch 4a — the roots' tops give way (VM-259 option B, R-260-12; R-260-11) — written 2026-11-25 after her picks

- **The Library:** her pick B, as drawn in `notes/plans/vm-260/vm-259-options.html` §B. At rest the full top
  (the wing line with trash · New Note · gear, the search field, the filter row). Scrolling DOWN past a real
  scroll (not a wobble), the three rows condense into ONE pinned 44-pt slim line: the wing's name small, the
  standing filter as a word ("· All"), a search glyph, the New Note glyph. Any upward nudge, or the slim
  line's search glyph, re-opens the full top (the search glyph also focuses the field). Every door stays
  reachable in both states; every target 44 × 44.
- **Bookcase and Starred:** the same slim line on scroll (their name and their own doors); the Bookcase's
  count line under the wing's name is REMOVED (R-260-11 — no count until shelves; VM-113 carries the
  per-shelf count).
- **Laws that bind:** the paging law and VM-68's listing re-ask discipline untouched (the slim line is
  chrome, never a listing change); one bar, never moving (VM-253); the keyboard floor untouched; the search
  field's VM-47 focus rules intact; no state lives in the view beyond the scroll's own (the slim/full flag is
  derived from scroll offset and direction, P-4).
- **Pins:** the slim line's appearance on a scroll past the threshold and the full top's return on an upward
  nudge (mounted, driven by the scroll position), every door ≥ 44 × 44 in both states, the Bookcase shows no
  count line (red on old), the listing's ask count unchanged by condensing (P1/VM-68). Captures at the gate:
  each root at rest and scrolled, both voices.

### Batch 4b — the note's top (R-260-13; VM-272's continuation) — written 2026-11-25 after her pick

- **As picked** (`notes/plans/vm-260/note-top-options.html`, the "A, as picked" frame): the title on its own
  row on top, more room, CENTRED, wrapping (never truncated); under it ONE row of six icon doors with NO
  separator: copy · find · book · # · the blocks/lens/more-info door · ⋯. **Only that row stays** as she
  scrolls; the title rides away with her text.
- **book:** greyed when the note is in no book; tap opens adding it to a book (today's membership line's
  act); in a book, the same door opens what the line opened. **#:** toggles the note's tags OPEN in place
  (a strip under the row, travelling with it while open — C-13-2) and the same # CLOSES them; adding a tag
  stays reachable from the strip. **The stack door:** a three-item menu, Blocks · Lens · More info (C-13-3),
  each opening what its chip opened. **⋯:** the Note sheet, now headed by TWO easy-tap icons — Seal (the
  seal's act, its accent state when sealed) and the date (the "no date" chip's act; the day when set) —
  above its existing rows (Save a Version, Versions…, Undo/Redo, Delete Note).
- **Laws that bind:** VM-272's chrome-only fence (zero lines in `MobileEditorTextView` or the text-input
  path; the text view keeps riding its own keyboard guide); every door 44 × 44; the sealed note's state still
  reads (the seal moves, its STATE line stays visible where it is today); the rename door on the title
  stays (VM-148's rename-in-place is NOT built here); P-1's capability vocabulary — every moved door keeps
  its registry identity and accessibility name.
- **Pins:** the sticky row (mounted: after a scroll the icon row's frame stays at the top while the title's
  leaves), the title never truncates (a long title wraps — red on old), six doors × 44 in one row without a
  separator, # toggles the strip open and closed, Seal and Date reachable from the Note sheet's head, the
  keyboard-reveal UI test re-run (the Write screen's layout changes). Captures at the gate: at rest, scrolled,
  tags open, the Note sheet — both voices.

Order: 1a → 1b → 2 → 3 → 3b → 4a → 4b. Batch 4's mockups may be drawn (by the orchestrator, as sitting material, or a
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
7. Batch 1a's `selectPage` consolidation: the Protection re-open route's pop is covered by construction only
   (no mounted pin — the bootstrap world is the Protection suites' heavy harness); the reviewer reads that road.

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
- **THE AWAY RULING (2026-11-25, ~03:3x, her words verbatim as relayed by the stage coordinator nov24):** "I'm
  going to sleep overnight, everyone should rule provisionally." From here this is an away run: undefined
  product behavior takes the most spec-defensible option, marked PROVISIONAL and logged for QUESTIONS at the
  merge; anything needing her hands is HELD and bundled for her morning sitting.
- **R-260-7 — THE MORNING INSTALL (her words, 2026-11-25, in session, verbatim):** "I want to have a fresh
  build installed on my phone in the morning though, so leave instructions for that on your handoff." So: the
  handoff's FIRST block is the install — the exact tree it builds from (the merged main tip if the run closed
  overnight, else the branch tip, named by SHA, an interim at her word — the VX-1033 devicectl precedent), a
  device .app PRE-BUILT overnight (headless, no stage) so her morning is install-only, the devicectl steps
  self-contained, and "what to try first" (a note with the keyboard up — her screenshot's frame; the
  Bookcase→Library swipe; a refusal's short line, its ✕ and its reason card; typing low in a note with the
  keyboard up, the standing vm-47 first-try). No schema or migration rides this run, so the install is
  posture-safe either way. On VM-259 she asked tonight whether the drawn options were ready; answered:
  deliberately not — they draw on batch 2's corrected sizes and join the morning bundle if batch 2 lands
  overnight.

**Her words after the install (2026-11-25 ~11:1x, in session, verbatim; her away ruling ENDS here — she is
present):**
> "and give me a command to open the library's top on my air please. also - looks mucuh better. however, in
> no book should be replaced with a book icon that you can tap on to add it to a book, maybe greyed out when
> there's no book. I don't want this whole header to be sticky, it takes up too much room as you scroll. maybe
> just the top bar? I also feel like tags could be replaced with a #, no date could be replaced with a calendar
> icon. i think that the top four icons are actually good, but maybe there should be another four beneath them?
> blcoks and lens and more info could probably go together. or maybe it would be best for the title to get more
> space on top and then there's one row of icons, and just that row of icons is what stays with you as you
> scroll. i think that might be best. there's also a duplicate done [Image #2] and the title is quite cut off
> when it's long - which having a row of icons below it might fix, then the title could be more centered. i do
> actually like the current four icons on the upper right though, it looks clean, so i'll have to see how the
> icon bar looks... and vm-281 can be fixed. we can also just continue moving forward with opus review rounds
> for now and you can make a ticket for a fable round over the whole diff later."

- **R-260-8 — the note's top, her DIRECTION (not yet a pick; she wants to SEE the icon bar first).** Her
  leading idea: **the title gets more room on top (more centred, no longer cut off), ONE row of icons below
  it, and ONLY that icon row stays with her as she scrolls** — never the whole header ("it takes up too much
  room as you scroll"). The icon row's members, from her words: the four current tools (copy, find, seal,
  ⋯ — "they look clean"); "in no book" → a BOOK icon that opens adding the note to a book, greyed when the
  note is in no book; "tags" → "#"; "no date" → a calendar icon; blocks, lens and more info "could probably
  go together" (one door). The alternative she floated: the current top row kept, four more icons beneath
  it. **Next: the orchestrator DRAWS both (local HTML, never published) for her to see; the build follows
  her pick, as batch 4's second half** (the Library's top and the note's top are one question — what stays
  and what gives way when she scrolls). This supersedes VM-148's "both scroll away and a slim bar with the
  title stays" for the sticky part; VM-148's rename-in-place and title quickfill are untouched.
- **R-260-9 — VM-281 SANCTIONED:** "vm-281 can be fixed." The editor-seam line (drop the editor's accessory as
  its text view resigns) is built IN THIS RUN; VM-281 joins as a member.
- **R-260-10 — the ladder's reviewer:** "continue moving forward with opus review rounds for now and you can
  make a ticket for a fable round over the whole diff later." The ladder runs on fresh `opus-reviewer`s;
  **VM-282** carries the owed Fable round over the whole diff (VM-281's editor line and `MobileEditorStyle`
  named). This waives the Fable-review requirement for the editor-seam line for THIS merge, at her word; it
  is not waived for the code.
- **F-her-1 — the duplicate "Done" on the Blocks sheet (her finding, screenshot):** while she picks blocks the
  sheet's header shows "Done" (end picking) beside "Done" (close the sheet). Pre-existing (PR20's picking
  door, `MobileBlockList.swift`; the code itself documents the collision), not this run's regression.

**Her next words (2026-11-25 ~11:3x, in session, verbatim):**
> "i also don't like the "2 books" under Home. we don't have shelves on here yet, but eventually each shelves
> should have the numbers. in the meantime we just don't need numbers of the books i suppose until the shelves
> are added. i also choose this one: B — the slim bar (VM-148's rhyme). i'll look at the top bar options now."

- **R-260-11 — the Bookcase's count line GOES (supersedes R-260-1's "but it should have its count").** No book
  count under the wing's name until the phone has shelves; when shelves come, each shelf carries its own
  number. Built in batch 4 (the Bookcase's top line is batch 4's surface anyway: VM-259's option B gives
  Bookcase and Starred the same slim line). The shelf-count half goes to the phone's shelves ticket as her
  word, not built here.
- **R-260-12 — VM-259 PICKED: option B, the slim bar** (`notes/plans/vm-260/vm-259-options.html` §B):
  scrolling down, the Library's three rows (wing line, search, filters) condense into ONE pinned 44-pt line
  (the wing's name small, the standing filter as a word, a search glyph, New Note); an upward nudge or the
  search glyph re-opens the full top; every door stays reachable; Bookcase and Starred get the same slim line
  (their name and their own doors). It rhymes with the note's top, whose pick (R-260-8, A or B) she is making
  now. **Batch 4 builds both tops together after that pick.**

**Her pick for the note's top (2026-11-25 ~11:4x, in session, verbatim):**
> "ok i like this one better: A — the title on top, one icon row that stays (her leading idea) and that's what
> we should go with. I don't think there should be a verticle line between the options. i'd make sure it's easy
> to click on tags to see them expand and then click on the tag icon so tags close again too. i feel like sealing
> the note can also go in the note's menu (maybe it can stay an easy to click icon at the top of the note menu
> instead of another row). i also think that date could go in the note menu, again it could be an easy to click
> icon at the top."

- **R-260-13 — the note's top: option A, refined.** The title on its own row on top, more room, centred,
  wrapping instead of cut off; ONE icon row beneath it, and ONLY that row stays as she scrolls. Her
  refinements: **no vertical separator** in the row; **#** opens the note's tags in place and the same **#**
  closes them again (an easy toggle, never a sheet she has to dismiss); **the seal and the date move INTO the
  note's ⋯ menu, as easy-to-tap ICONS AT THE MENU'S TOP** (the iOS compact icon group at a menu's head), not
  as menu rows. So the row is: copy · find · book (greyed when the note is in no book; tap to add it to one) ·
  # · the one door for blocks / lens / more info · ⋯. **PROVISIONAL, the orchestrator's (for her eye at the
  captures):** C-13-1 the order (⋯ last, the iOS convention); C-13-2 the open tag strip sits directly under the
  icon row and travels with it while open, so the # that closes it is always in reach; C-13-3 the stack door
  opens a three-item menu (Blocks · Lens · More info). This supersedes VM-148's "a slim bar with the title
  stays" for the sticky part and its "row of chips" for the note's facts; VM-148's rename-in-place and title
  quickfill are untouched.
- **Batch 4 splits into two acceptance units** (one surface each, the sizing rule): **4a** the roots' tops
  (VM-259's slim bar on the Library, the same slim line on Bookcase and Starred, R-260-11's count line gone);
  **4b** the note's top (R-260-13). Sequential, a fresh implementer each, after batch 3b.
- **R-260-14 — the as-picked frame RATIFIED, no further checkpoint (her words, 2026-11-25 ~11:5x, verbatim):**
  "yeah i like this: A, as picked (R-260-13) — what batch 4b builds move forwward with that. I don't need to
  check further - i'll wait and see what it's like once it's installed on my phone." So C-13-1 (⋯ last), C-13-2
  (the open tag strip travels with the row) and C-13-3 (the stack door's three-item menu) stand as drawn, no
  longer PROVISIONAL. No design sitting precedes 4a or 4b; **her judgment is the next phone install**, which
  follows 4b (a fresh signed device build at that tip, installed at her word like R-260-7's).

## Adjudications (the orchestrator's, repo-first)

- **A-260-1 (on batch 1a's P-260-1a, 2026-11-25).** The built arm (a) STANDS — a note or book asked for on a page
  she has since left is made and kept, never opened, no page hijacked (P-3 and R-260-5 both hold) — but SILENT
  does not: a thing made-but-not-opened is "an outcome other than the one she asked for", and the seam's own law
  gives that a DIRECTION line naming where it landed (SurfaceContracts, the phone line). The one line call lands
  in BATCH 1b (the message-line batch, where the direction ink is being built anyway), door-side, no new seam
  kind. P-260-1a still goes to QUESTIONS at the merge for her ratify, the line noted as the built shape.
- **A-260-2 (batch 1a's C-255-1…3): accepted** — the count inside the wing door's 44-pt box, Terminal's "~/"
  prefix kept, each glyph keeping the tone of the door it replaced. The Protection re-open route's pop being
  covered by construction only (no mounted pin) is accepted and added to the review foci.
- **A-260-3 (batch 1b's seam fact, 2026-11-25): `StatusCenter.Item.isDirection` ACCEPTED.** The face cannot tell
  a direction from a refusal any other way without matching words, and string-matching the seam's sentences is
  banned; a typed, defaulted fact set only by the seam's EXISTING `direct(_:)` door is the minimal mechanism,
  with the kinds and the slot rule untouched, no Mac reader, and the Mac's landing pinned unchanged
  (`VM61MacStatusSeamPinTests`). PROCEDURAL note, recorded: the brief said stop-and-propose for any seam-side
  line — the implementer built it instead; the one-revert fence and the pins made acceptance cheap, but the
  stop-and-propose rule stands for the rest of the run.
- **A-260-4 (the VM-277 proposal): RULED, build it.** (a) accepted — headline and sentence answered from the
  SAME switch arm so they cannot drift; a refusal with no authored headline clips to one line with "…" until her
  wording pass (the headline list joins the closeout's Wording bundle). (b) accepted — a 44 × 44 ✕ plus a flick
  down; P-55-3 superseded for refusals exactly as the ticket says. (c) accepted — tap anywhere on the line, the
  "›" signpost after the headline. (d) accepted — the line grows upward into the reason card; the seam gains
  `hold(_:)` (a lifetime door, not a kind; the seam owns the clock) under the same Mac fence: no Mac reader, the
  VM61 pin extended. Closes on ✕, flick down, leaving the note, or a newer message. (e) accepted PROVISIONAL —
  the line becomes a floating card clear of the bar and the screen's sides (the Mac toast's idiom), which is
  also VM-275 half 2's cure; it supersedes the full-width flush band (P-47-36's "grows by lines" survives on the
  card) — captured for her at the walk, the canon line at the merge if she keeps it.
- **A-260-5 (VM-275 half 2): the literal claim is HOLLOW, with its mechanism recorded.** No row ever moved: the
  line's face was a full-width band flush on the bar in the bar's own ground, so a 3–4 line refusal read as the
  bar growing ~100 pt. The guard `theListNeverMovesWhileTheLineShows` is predicted green on BOTH trees (the
  window confirms); the cure is (e)'s card, not a row fix — the hallucination guard's record-don't-fix, with the
  look fixed for the look's reason.
- **A-260-6 (C-275-1): accepted** — a direction raised in the note clears on leaving it, exactly as a refusal
  does; offers and removals keep their fade.
- **A-260-7 (the batch's evidence shape):** ONE window at batch 1b's close runs everything — the red-on-old
  trees are frozen commits in their own DerivedData so they cannot go stale; the tip legs (P, M) run once on the
  final 1b tip; the line's walk covers the whole line, VM-277 included. A-260-1's draft direction words ("That
  note didn't open because you'd moved on — it's in the Library.") stay DRAFTS for her wording pass.
- **A-260-8 (the editor-spoken refusals, 2026-11-25): wiring DEFERRED to VM-279 (Low).** The sites the fence kept
  this run out of — `CrossBlockRefusal`'s nine causes, `MobileStructural`'s two, `MobileComments` and
  `MobileTakesController` through the editor model's `report` — keep the plain sentence through the ruled "…"
  clip, so the RULED BEHAVIOR (short line, dismissable, reason on demand) already holds on them; what's missing
  is authored headlines: one expression per site plus nine short forms, in editor-family files VM-271 will
  rework. Verified by the orchestrator: the final 1b diff touches no editor-family file. The new seam spellings
  (`refusalHeadline`, `refuse(headline:sentence:)`, `holdForReading(_:)`) are fenced off the Mac by the VM61 scan.
- **A-260-9 (batch 2's hand-back, 2026-11-25): the step-down ACCEPTED AS BUILT, PROVISIONAL as one set
  (P-260-2a…2d with C-273-1 and C-272-1), her judgment of the whole riding the captures at the morning sitting
  (the P-47-1 pattern).** Grounds, each spot-checked against the diff (05f7ded32..ae12e4276), not the claims:
  chrome one notch under her words is R-260-2's "smaller default" applied to batch 2's chrome-only scope; every
  invisible target byte-unchanged (review focus 1) and one real defect fixed under her report — the note-top
  chips were 44 tall only, now a 44 × 44 floor; the 13-pt floor and LK-5's bar words held; the radii trace to
  the Mac's own two (`QuietFill.corner` 4, the toast's 8 — S-260-3 satisfied); no fenced file touched
  (`Sources/`, `VoiceTokens`, `StatusCenter`, `MobileKeyboardBar`, the editor family — verified empty diff).
  The note title's 24 → 20 stands as VM-272's scope with batch 3 counting its one-notch default from today's
  set (the batch's own flag). The segmented choice (P-47-30's fence, hers) and the per-site radii stand
  RECORDED, not patched. The SUSPECTED field-answering item is ticketed — **VM-280** (Bug · Suspected · Low) —
  so it outlives this record's working sections. The red-on-old predictions remain the window's to prove;
  acceptance here is of the design set and the diff's discipline, not the evidence.
- **A-260-11 (batch 3's hand-back, 2026-11-25): ACCEPTED AS BUILT, PROVISIONAL as its own calls declare
  (P-260-3a…3e, C-247-1, C-254-1/-2), her judgment riding the W3 captures and the morning sitting.** Grounds,
  spot-checked against the diff (dae368b4e..54c0d1cc8), not the claims: the fences hold (`Sources/`,
  `StatusCenter`, `VoiceTokens`, `ThemeStore` — verified empty diff); `MobileEditorStyle`'s diff is fonts,
  grounds and faces only, zero text-input lines (verified by grep over the diff) — the look file, not the
  seam; the shared-file lines accepted — `PhoneType`'s `@Entry` rides the established `phoneFieldPrompt`
  pattern, and the per-device store rides Appearance's own road, the `ThemeStore` kept bound for everything
  else; VM-254's one-notch default correctly counts the note title's 24 → 20 as already taken (batch 2's
  flag honored). R3's red-on-old was ESTABLISHED in the consolidated window (all four pins, 19 issues);
  P3 + M3 run as their own queued window and U3 is already green, so what acceptance still waits on is
  those two legs plus her eyes.
- **A-260-12 (batch 2's RECONCILE hand-back, 2026-11-25): both reconciles ACCEPTED.** R1: the field's 39 was
  the drawing (a text field's own view is 23 pt, not the 18-pt line the arithmetic counted — the air is now
  4 + 4 so the designed 36 binds) AND the pin's probe (a combined accessibility element reports the drawing,
  not the invisible target; the standing layout pin `theFieldIsAtLeastFortyFourTallAndGrowsWithItsText` was
  green in P all along, so the 44 never left). The VM-280 datapoint (the touch-taking view ≈ 23 pt) is on
  that ticket's trail — it STRENGTHENS the suspicion. R2: the 9 uncounted points were real air on BOTH trees
  (safeAreaInset's default 8 + the baseline-hung title row), so the fix takes the air out rather than moving
  the law; the cap's move 140 → 137 is a TIGHTENING with the mechanism stated and the pin still red on old
  (167 measured) — the honest direction. C-272-2 (the tools centre on the title, no longer its baseline)
  joins her capture bundle, PROVISIONAL with the set. Re-evidence bundles prebuilt on `2d4670d18`
  (`vm260-2r`, `-mac`, `-ui`); the phone bundle carries batch 3's code, so ONE window leg serves P3 and the
  reconcile pins together.
- **A-260-13 (batch 1b's RECONCILE hand-back, 2026-11-25): both harness fixes ACCEPTED, with the honesty flip
  they force.** Finding 1: the system Back's accessibility activation never worked mounted on EITHER tree —
  so R1's red on `aRefusalRaisedInANoteClearsWhenSheLeavesIt` was the HARNESS's red, not the defect's, and
  **VM-275 half 1's red-on-old is NOT YET established**; the corrected old tree `vm260-1b-rol-r`
  (`ea3f95831` + only the new Back step, verified by diff) now carries that burden — the amended window's
  R1r leg, predicted red AT THE PIN'S OWN ASSERTION, green on the three guards. The new step takes the
  Back's own act (the note's stack pops its top screen), meaning unchanged. Finding 2: the card pin had
  reset its own frame reading and said the next line in one turn, so the unchanged card never reported again
  — each class now stands in its own fresh window; the law unchanged. The implementer's stop condition is
  ADOPTED as the window's: a red at "the note's stack" or "the note left" is a harness red again — stop and
  report, never dispose the pin. Diff verified: the two pin files and the record only.
- **A-260-14 (batch 3's RECONCILE hand-back, 2026-11-25, orchestrator on Opus): H1 ACCEPTED, H2 REFUTED; the
  fix ACCEPTED.** The orchestrator's own H2 (a cross-suite race) is refuted on two independent grounds the
  orchestrator checked: the test is synchronous `@MainActor` code over a main-actor face (nothing can
  interleave), and a stray face would read 1.75 off, not the 0.25 the window's own log expansion shows
  (verified in `/tmp/vm260-win2/P3.log`: `… - 14 * 1.125) → 0.25`). The mechanism: `UIFontMetrics.scaledFont`
  does not keep a fractional size while `scaledValue` (the SwiftUI form) does, so VM-254's fractional step
  sizes (27 of 100 role × voice × step cases) split the two type forms by up to half a point. That is a real
  product mismatch, not a harness one, and it was invisible at the default size because every table size is
  a whole point. The fix is ONE line (`PhoneType.spec` rounds the scaled size before the floor; verified by
  diff, plus comment-only lines in `MobileLook.swift`), the default byte-unchanged. The new
  `theTwoFormsAgreeAtEveryStep` is the mechanism's own pin, with its falsification condition written in
  (green on the pre-fix tree ⇒ H1 refuted, the fix does not ship), adopted as the gate's rule. P-260-3a's
  amended whole-point table (halves round up; two steps coinciding where the floor meets the small end)
  joins her bundle. Red-on-old tree `defecf3a9` (`vm260-3r-rol`); tip `78ed5b4bb` (`vm260-2r`, `-mac`
  rebuilt); the R-b3r leg and the re-run tip legs ride the merge gate.
- **A-260-10 (the F-1a-W1 fix's hand-back, 2026-11-25): trace and fix ACCEPTED; the orchestrator's suspected
  mechanism stands REFUTED by the captures' own pixels.** The trace is the stronger kind of evidence — two
  independent captures of the same field on the same device class, the 52.0-pt gap equal to
  `MobileKeyboardBar.barHeight` exactly, and the page's rows cut at the bar's hairline (which falsifies the
  band-ignores-keyboard story: the page's own reserved place sits 52 low too). The finding reclassifies: the
  defect PREDATES this run (inferred — the stale avoidance after an accessory keyboard; wave 1's in-page bars
  would have stood in the same place), exposed only by the walk's s5→s9 keyboard order. It stays MAJOR and
  stays this run's to fix — the bar under the keyboard is the look's break, and SurfaceContracts' bar line
  binds. C-W1-1 accepted: the guide as a FLOOR under SwiftUI's avoidance is the least-reach correction (zero
  wherever the avoidance is right); (c) — dropping the editor's accessory at resign — is the editor seam,
  correctly not taken, and is the NEXT road (Fable-reviewed, its own ticket) only if the window shows the guide
  carries the stale 52 as well. C-W1-2/-3 accepted. The UI-test pin accepted with its stated reason (no
  mounted pin can make a real keyboard after a real accessory keyboard); its red-on-old runs in the window on
  `vm260-w1-rol`, with the implementer's falsification conditions standing as written (leg 1 red ⇒ mechanism
  wrong; leg 2 green on old ⇒ hollow on this road, record not claim). WATCH, carried to the window: the one
  message line reads the keyboard from its own notifications — if the stale 52 lives in the notification
  frame, the line could sit 52 low on that keyboard (1b's surface; stop 6 checks opportunistically; a confirm
  is a ticket, not this run's silent fix). The speed-suite note (one extra shell body evaluation per keyboard
  show/hide outside a note) is read at the gate.

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
| Merges of main owed: `ba42ddc53` (PR #26, notes) MERGED at `edae67935` · `1a7b0d444` (PR #28, notes — contains `5ca093319`, PR #27, VX-1013 Protection/AppBootstrap) MERGED at `18b01675e`, 2026-11-25, batch 2's boundary — PR #27 verified in-tree (`merge-base --is-ancestor`); the run's FINAL merge-gate legs run on this tree or later · **`9a6868836` (PR #29, VX-1082 — Mac editor, search, deletion doors, book faces + Core `SearchQueries`, which compiles into the phone) DUE at batch 3b's boundary, before 4a**; trial-merges clean, no shared code files (nov24); the merge gate's phone and Mac legs run on a tree containing it | OPEN |
| Linear: VM-260 In Progress | DONE |
| Kickoff sitting: six rulings R-260-1…6 recorded | DONE 2026-11-25 |
| nov24 coordinator announced; its protocol folded in above | DONE |
| Riders re-parented under VM-260; batch 1a members In Progress | DONE |
| Batch 1a (VM-253 · VM-256 · VM-255) | SUITES GREEN; UI test GREEN; the walk READ (verdicts below). F-1a-W1 after THE CONSOLIDATED WINDOW (section below): the defect REPRODUCED red-on-old behaviorally on the original walk road; the pin's own road HOLLOW (leg 2 green on old — the search restores its focus at Back); the tip's floor fix does NOT cure the original road (UIKit's guide carries the stale 52 — the F-1a-W1 NOT KNOWN answered); the floor STAYS as the class guard (U 2/2 and U3 2/2 GREEN, P's floor guards green — no regression); the CURE is an editor-seam line, **VM-281** (Bug · Confirmed · High · Needs Lillian). CLOSED for this run as guarded-not-cured |
| Batch 1b (VM-265 · VM-275 · VM-277 + A-260-1's direction line) | BUILT (tip `ca9a8d7be`; A-260-3…8) and WINDOW-RUN 2026-11-25: R1 the 13 predicted reds ALL present and `theListNeverMovesWhileTheLineShows` GREEN on old (A-260-5's hollow CONFIRMED); R2 exactly the 5 predicted reds, guard green; the LIVE line walk green at stops 1/2/3/4/6/7 in both passes (clock holds >6 s, ✕ and flick dismiss, leaves-with-its-note, Undo, card above keyboard), stop 5 inconclusive (driver race; semantics pinned green in P). RECONCILED 2026-11-25 (A-260-13; commits `39e608327` + `d3356f04e`): the leave step now pops the note's stack (Back's own act — the activation road never worked mounted), the card pin reads each class's first geometry in its own window; **VM-275 half 1's red-on-old moved to the corrected old tree `vm260-1b-rol-r`** (the amended window's R1r leg — red at the pin's own assertion predicted; a red at the walk step is a harness red again: stop and report). The trio rebuilt at `d3356f04e`; these pins' first green will be their first ever, said plainly; **FINAL WINDOW 2026-11-25 (09:53–10:14): R1r RED at the pin's OWN assertion (`:170`, `session.status.current == nil`), the three guards GREEN → VM-275 half 1 NOW FAILS CORRECTLY ON THE OLD CODE; on the tip the leave family and the card pin are GREEN, their first greens ever.** DONE pending the ladder |
| Batch 2 (VM-273 · VM-272) | BUILT (code tip `ae12e4276`; A-260-9; VM-280) and WINDOW-RUN 2026-11-25: R red-on-old ESTABLISHED (every predicted red present, note-top doors Study-only exactly as predicted, all guards green); M GREEN (100/100, the 4 declared known). RECONCILED 2026-11-25 (A-260-12; commits `e39903b7d` + `2d4670d18`): the field draws 36 as designed and its pin reads the layout frame (the 44 was always there); the note top is exact at 136 (the 9 pt was invisible air on both trees), the cap TIGHTENED to 137, C-272-2 to her bundle; re-evidence bundles `vm260-2r{,-mac,-ui}` prebuilt, predicted green, riding the P3 window. Captures banked (18 before + 18 after, `batch-2/`); two throwaway-driver defects (voice carryover — the after run lacks Study shots; a centre-tap fallback opened a full note) — retakes fold into the gate window; **FINAL WINDOW: both reconciles GREEN on the tip: the field box 37.3 in a 44 frame (its own view 22, the VM-280 datapoint), the note top 136.0 in both voices; U 2/2 GREEN on `vm260-2r-ui`.** DONE pending the ladder |
| Batch 3 (VM-247 · VM-254) | BUILT 2026-11-25 (code tip `54c0d1cc8`, record `5bbff189f`; adjudicated A-260-11); R3 red-on-old ESTABLISHED in the window (all 4 pins red as predicted, 19 issues); P3 + M3 queued as their own window (nov24, at VX-1082's SEAM or after); W3 captures fold into the gate window; U3 already GREEN (2/2, this window); **FINAL WINDOW: M3 GREEN (53/53 in 9 suites, the 4 declared known); P3 ONE unexpected red, `MobileTextSizeTests.theEditorFaceTakesTheStep` (`:145`, the UIKit row preview at the Larger step ≠ 14 × 1.125), owed to this batch's implementer, traced headless (hypotheses in the final-window section)** |
| Batch 4 (VM-259 + the note's top + R-260-11) | BOTH PICKS IN: VM-259 B, the slim bar (R-260-12); the note's top A as picked, ratified with no further checkpoint (R-260-13, R-260-14); the Bookcase count line goes (R-260-11). 4a then 4b after batch 3b and the main merge; her judgment is the phone install after 4b |
| Her phone (R-260-7) | INSTALLED 2026-11-25 ~11:0x at her word (*"install the build on my phone now"*): the signed device build at code tip `78ed5b4bb` (`DerivedData/vm260-device`, Release-iphoneos), `devicectl` to her iPhone 17 Pro, same bundle id (her store carried over). Her assessment on the phone is the run's real close |
| Ladder · gate · walk | NOT STARTED |
| Closeout (canon deltas, #281 dispositions, #277 leftovers touched by this run, parity row, handoff) | NOT STARTED |

## THE CONSOLIDATED WINDOW — results (2026-11-25, claim `vm-260` 04:55–06:01:14; the GO device `vm260-suites` iOS 26.2, DELETED at close; the UI legs on `vm260-walk`)

One window ran batches 1b and 2's full evidence, F-1a-W1's re-evidence, and (added mid-window; nov24 cut it at the
boundary when VX-1082's merge-gating window came READY) batch 3's R3. All bundles prebuilt; the window compiled nothing.

| Leg | Result |
|---|---|
| M — Mac union, tip bundle `vm260-2-mac` | GREEN: 100/100 in 19 suites, 55.9 s, exactly the 4 declared `IndexTierMetricsTests` known issues |
| R — batch 2 red-on-old (`f99f20818`) | AS PREDICTED: reds `theChromeSitsOneNotchUnderHerWords`, `theCornersAreTheMacsTwo`, `theDrawingsSitWellInsideTheirTargets` (both voices), `theNoteTopGivesTheScreenBackToWriting` (both voices), `everyDoorOnTheNoteTopAnswersAcrossFortyFour` STUDY ONLY (Terminal green); every guard green |
| R1 — 1b tranche 1 (`ea3f95831`) | the 13 predicted reds ALL present; `theListNeverMovesWhileTheLineShows` GREEN → **A-260-5's hollow CONFIRMED**; two predicted-green guards (`aLineSaidBeforeTheNoteOpenedOutlivesItsLeaving`, `aRemovalSaidInTheNoteOutlivesItsLeaving`) failed at their shared WALK STEP (`MobileRefusalLeavesItsNoteTests.swift:110` `back?.accessibilityActivate()`, `:115`), never reaching their assertion — harness, owed to 1b's implementer |
| R2 — VM-277 red-on-old (`c8bfa668f`) | EXACTLY as predicted: the 5 reds, the guard green |
| R-W1 — the F-1a-W1 pin on old (`c4081441c`) | **PASSED on old — hollow on its road** (the pre-written rule applied): the REVEAL lines show that at Back the search restored its own focus and took the keyboard back, which is not s9's state |
| THE REPRODUCTION (added) | the ORIGINAL 1a walk road (driver `VM260WalkDriver1a`): OLD app (`vm260-walk1a`) — **s9 REPRODUCED**, the bar's three doors ghosted under the keyboard's glass, the list cut at the hairline beneath it; TIP app (`vm260-walkB`) — **STILL UNDER on the same road**. The F-1a-W1 NOT KNOWN is answered: UIKit's keyboard layout guide carries the stale 52 as well, so the lift-only floor sees no shortfall there. The floor STAYS (class guard; no regression anywhere); the cure is the editor-seam line — **VM-281** filed (Needs Lillian). Shots kept in the window's result bundles (`/tmp/vm260-win/W1aold-shots`, `W1anew-shots` → copied beside the batch-2 captures) |
| P — the tip (`dae368b4e`), whole phone target, one launch | 1275 tests / 228 suites, 22 issues = the 6 known + 16 unexpected in 7 tests: (1) `theDrawingsSitWellInsideTheirTargets` — the FIELD measures box 39 (law ≤ 38.5) and frame 39 (law ≥ 43.5), both voices (PERF: `field (363.0, 39.0) in (363.0, 39.0)`) — batch 2's implementer owes the reconcile (a drawn 39 vs the designed 36, and where the 44 frame went; VM-280-adjacent); (2) `theNoteTopGivesTheScreenBackToWriting` — chrome measured 145.0 / 144.3 vs the cap 140 (PERF lines in the log; the 136 arithmetic missed ~9 pt) — batch 2's implementer; (3) `theNoteInWriteIsOnThePaper` (source scan) — the Write ground spelling moved; batch 3's ruling ALREADY moved this pin the same night (its P3 proves it); (4) `theLineIsACardClearOfTheBarAndTheSides` — mounted `lineFrame` nil (harness; the LIVE card is right — walk capture s1); (5–7) the leave-note family (`aRefusalRaisedInANoteClearsWhenSheLeavesIt` + the two outlive guards) — all on the `:110` walk step; the LIVE walk proves the behavior (stop 4 green both passes). The F-1a-W1 floor guards rode green (`MobileKeyboardFloorRuleTests` 6, `MobileKeyboardFloorShellTests` 1) |
| U / U3 — keyboard-reveal, walk device | U (tip bundle `vm260-2-ui`): 2/2 GREEN. U3 (`vm260-3-ui`): 2/2 GREEN |
| The line walk (driver `VM260WalkDriver1b`, tip app) | both passes: s1 card anatomy RIGHT live (one-line alarm sentence, ›, 44-pt ✕, card clear of sides, above the editor's bar — capture s1); s2 the reason card HOLDS past 6.5 s; s3 ✕ and flick-down both dismiss; s4 a refusal LEAVES WITH ITS NOTE; s6 removal + Undo; s7 the card above the keyboard (line bottom 479 vs keys 583). Stop 5 (the made-not-opened direction) INCONCLUSIVE live — the driver's race lost to the open; the semantics are pinned green in P (`aNoteMadeAfterSheLeftThePageSaysWhereItLanded`). NOTE: both passes ran in Terminal (voice carryover from the capture runs — the driver defect below) |
| R3 — batch 3 red-on-old (`2e03a6811`) | all 4 pins RED as predicted (19 issues); P3 + M3 cut at nov24's boundary call, re-queued as their own window |
| Captures | `batch-2/before` (the `vm260-2-rol` app) and `batch-2/after` (the tip app), 18 shots each, named; the line walk's 14 in `batch-1b/`. TWO THROWAWAY-DRIVER DEFECTS, mine: (a) the device keeps the voice between runs, so the AFTER run's "Study" pass ran in Terminal — no Study after-shots; (b) the New Note road's centre-tap fallback opened an existing note, so the after run's refusal-card stop shows a full note (it doubles as a clean Terminal note-top after-frame). The c8 s9-road also never opened the lesson (`typeText` flake — an AutoFill pill ate the search text). RETAKES fold into the gate window's closing walk with the driver fixed (reset the voice at pass start; verify the typed text; verify the opened note is empty) |

Teardown verified at release (nov24's stamp 06:01:14): both devices shut down, `vm260-suites` DELETED, zero booted
sims, zero Variorum instances. Crash reports in the window by time: `swiftpm-testing-helper` 05:13:41 and 05:14:07
(during the red legs — expected-red exits), `ListRender` 05:59:30 (during the walk re-runs); none named Variorum.

**What the window leaves OPEN (each owed before the ladder):** the two batch-2 pin reconciles (the field's 39/39,
the note top's 145); 1b's harness step and the card pin's mounted road; P3 + M3 (queued); the capture retakes at the
gate. **VM-281** (the keyboard cure, editor seam) and **VM-280** (the field's answering height) wait on her.


## THE FINAL EVIDENCE WINDOW — results (2026-11-25, claim `vm-260` 09:53–~10:14; orchestrator on Opus 5.5 per the cast change; device `vm260-suites2` iOS 26.2, DELETED at close; the UI leg on `vm260-walk`)

| Leg | Result |
|---|---|
| M3 (`vm260-2r-mac`, the nine Mac types) | GREEN: 53 tests / 9 suites, 49 s, exactly `IndexTierMetricsTests`' 4 declared known issues |
| R1r (`vm260-1b-rol-r` = `ea3f95831` + the new Back step) | **AS PREDICTED, the stop rule NOT triggered:** `aRefusalRaisedInANoteClearsWhenSheLeavesIt` RED at its OWN assertion (`MobileRefusalLeavesItsNoteTests.swift:170`, `session.status.current == nil`; the walk step passed); `aLineSaidBeforeTheNoteOpenedOutlivesItsLeaving`, `aRemovalSaidInTheNoteOutlivesItsLeaving`, `theListNeverMovesWhileTheLineShows` GREEN. **VM-275 half 1 NOW FAILS CORRECTLY ON THE OLD CODE** |
| P3 + the reconciles (`vm260-2r`, code tip `d3356f04e`, whole phone target, one launch) | 1,293 tests / 232 suites, 847 s, 7 issues = main's 6 known (`MobileFilterRowGeometryTests` ×4, `MobileTrashTests` ×2) + **ONE unexpected: `MobileTextSizeTests.theEditorFaceTakesTheStep`** (`:145`, `abs(MobileEditorStyle.face.font(.rowPreview).pointSize - 14 * 1.125) < 0.01` failed; the lines before it, the body at 18 and its family, passed). Every reconcile GREEN: `PERF[sim] VM-273 drawn …`: the field `(362.0, 37.33) in (362.0, 44.0)`, its own view `(338.0, 22.0)` (VM-280); `PERF[sim] VM-272 note top`: chrome **136.0** in BOTH voices (text at 190.0, safe top 54.0); the leave family and the card pin green (their first greens) |
| U (`vm260-2r-ui`, `vm260-walk`) | 2/2 GREEN: `testAMidNoteTapRisesAboveTheKeyboard` 66 s, `testTheBarRidesAboveTheLibrarySearchKeyboard` 91 s |

Teardown verified: both devices shut down, `vm260-suites2` DELETED, 0 booted sims, 0 Variorum instances, 0 Problem
Reporter, NO crash report since 09:50. Released to nov24 with the full line.

**The one red, two hypotheses (the orchestrator's read, headless; NOT yet a mechanism, which the implementer
traces):** (H1) a deterministic size-path miss: the UIKit row preview at Larger runs `PhoneType.uiFont` →
`spec(…, wordsScale:)` → `UIFontMetrics(.subheadline).scaledFont`, and something on that road (the
scaling class, a rounding, the trait collection) lands off 15.75; (H2) **a cross-suite race on global state:**
`MobileEditorStyle`'s face is static, `.serialized` orders tests only WITHIN a suite, and TEN test files adopt
the face (`MobileEditorTestSupport`, `MobileHerWordsDefaultTests`, `MobileLibraryLookTests`, `MobileLivenessTests`,
`MobileNoteTopTests`, `MobilePhoneOwnLookFenceTests`, `MobilePhoneOwnLookTests`, `MobileShellTests`,
`MobileTextSizeTests`, `MobileVoiceTests`), so another suite's `adopt` can land between this test's `adopt` and its
read. H2 would be a TEST-ISOLATION defect (the app's face is main-actor single-writer), but it would also
threaten every face-reading pin. The implementer settles which.


## BATCH 1a — record (VM-253 · VM-256 · VM-255; implementer: Opus, 2026-11-25)

**What this batch did NOT do (kept current):** the WALK is not done (a separate leg, a later GO — captures PENDING);
the keyboard-reveal UI test has NO VERDICT (the window's device opens its library behind a Castle passphrase — see the
suites block); no line in `Sources/`, `Sync/`, custody, `MobileEditorTextView` or the text-input path; `Shared/`
untouched; the one message line untouched (batch 1b's). The suites leg RAN (2026-11-25, 01:16–01:40): every red-on-old
as predicted, the whole phone target and the Mac legs green — the block "Batch 1a — the suites" below.

### LIVE STATUS

| Piece | State |
|---|---|
| 0. Preflight (CLAUDE.md + canon, this record's binding sections, the resiliency protocol, SurfaceContracts' phone bullets, the VM-47 FOR A LATER READER, the three tickets' bodies); the screens folder made gitignored | DONE (`5f70297f4`, `2c0ebf985`) |
| 1. VM-253 — the trace; the pins on the pre-fix tree (and the held-drag seam they need) | DONE (`b05c45bb0`) — `MobileTabBarStaysStillTests` (3 tests) + `MobileShellView(heldDrag:)`; phone `build-for-testing` green on this tree; red on old CONFIRMED (R1), green on the tip (P) |
| 2. VM-253 — the fix: the bar drawn once by the shell, outside the paged band | DONE (`219a945d1`) — phone `build-for-testing` green; the moved pins (`MobileNavigationTests` copies 3 → 1, `MobileTabBarTests` route rule) GREEN (P) |
| 3. VM-256 — the trace; the pins on the pre-fix tree | DONE (`9edeb6993`) — `MobilePageLeavingTests` (2 tests); phone `build-for-testing` green on this tree; red on old CONFIRMED (R2), green on the tip (P) |
| 4. VM-256 — the fix: every page change returns the page left to its root; a push never lands on a page not showing | DONE (`8d7fc32cb`) — phone `build-for-testing` green; the moved pins GREEN (P) |
| 5. VM-255 — the top line: the wing's name alone, the Bookcase's count under it, the gear, the trash on the Library only, the Mac's glyphs; pins | DONE (`f8aa3f6f4`; the self-review fix `74a3a7149`) — phone `build-for-testing` green; red on old CONFIRMED (R3; the glyph pin statically), the suites GREEN (P) |
| 6a. The red-on-old trees built headless (no stage), each into its own DerivedData: VM-253 at `b05c45bb0` → `DerivedData/vm260-1a-rol253`; VM-256 at `9edeb6993` → `…-rol256`; VM-255 at `8d7fc32cb` + the two pin files from `f8aa3f6f4` → `…-rol255` | DONE — all three `TEST BUILD SUCCEEDED`; the worktree is back on `vm-260-phone-look`, clean (the two copied files removed before the switch) |
| 6. Phone + Mac `build-for-testing` green on the tip (`74a3a7149`); READY-FOR-TESTS | DONE (`1b19aba7f`) — phone `DerivedData/vm260-1a`, Mac `…-mac`, the keyboard-reveal UI bundle `…-ui`; the run list below |
| 7. The suites — each pin red on old (`test-without-building` against the prebuilt pre-fix trees of 6a: the revert is the commit itself, the worktree never sits reverted), then the tip's suites | DONE 2026-11-25 (claim `vm-260`) — R1/R2/R3 as predicted; the whole phone target 1,235 in 218 suites PASSED; the Mac legs 53 in 9 PASSED; the UI test NO VERDICT (device locked); follow-through fixes `19b31c4c3` |
| 8. The walk: the three roots and a swipe mid-flight, both voices | PENDING (a separate leg, a later GO) |


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
  pushed, at the same frames. RED on old as predicted (6 issues: three copies of each door at rest, more on the pushed list); GREEN on the tip.
- `midSwipeTheBarHasNotMoved` — the band held 160 pt toward the Library: the Library's "All" door is on the window
  (the band moved) and every bar door is on the window once, at its resting frame, the chip still on the Bookcase.
  RED on old as predicted (a door on the window twice; the frames moved); GREEN on the tip.
- `aPageChangeMovesOnlyTheChip` — a guard (green on both by construction: at rest the old copies coincide; the motion
  was mid-flight). GREEN on old and on the tip, as predicted.

**The fix (piece 2).** `MobileShellView.body` lays the ONE bar over the band's foot (`.overlay(alignment: .bottom)` on
the band's frame, before its clip — inside the frame, so it rides above a keyboard exactly as a page's foot did) while
`barOnScreen`; only `current` (the chip) follows `tab`. Every root and pushed list keeps the bar's PLACE at its foot
(`MobileTabBarSpace`: the bar itself, `.hidden()`, `.accessibilityHidden(true)`, untouchable — the same height by
construction, so no page's layout moved). Where the bar stands is a pure rule over the visible stack's TOP screen
(`MobileTabBarPlace.stands(over:versionsListingShowing:)`): a root or a list yes; Versions while its listing shows
(the one route whose screen must say — `versionsListingSpace` counts it); a note, Read, Protection no. To read the top
screen the three stacks became TYPED (`[MobileRoute]`, every screen already was one), so a push from a root to a list
never drops the bar for a frame. VM-47's per-list bar count (`listBarsShowing`, `listBar`) retired with the copies.

Moved pins: `MobileNavigationTests.theTabBarCarriesThreeDoorsAndEachOneMovesTheBand` (copies 3 → 1);
`MobileTabBarTests.theRouteRuleIsTheDestinationBuilders` (the lists keep `barSpace`; Versions
`versionsListingSpace(owner)`); new `MobileTabBarTests.theOneBarStandsOverRootsAndListsOnly` (the pure rule).

**A consequence, recorded (no ruling needed unless she objects at the walk):** a push into a NOTE takes the bar away at
the push (the route says so at once) — the page sliding out keeps its empty reserved place at its foot; before, its
own copy slid out with it. A pop back to a root or list brings the bar back at the pop. Captured at the walk.


### VM-256 — a page she leaves returns to its root (R-260-5)

**Traced mechanism.** Her report names no road, so the trace walked every road that changes a page or fills a stack.
The BAR road already held the law on her wave-1 build: the bar shows only on roots and lists, a tab from a list
returns the stack it leaves to its root (`tabSelected` → `popToRoot(leaving)`, P-47-19), and a swipe starts only on a
root (`pagingAllowed`). Two roads did not:
1. **A note asked for, landing after she left the page.** Every door that mints and then opens — the Library's and the
   Bookcase's New Note, Today, a created book, a diverged copy — pushes when its mint returns, onto the stack it was
   asked from (`libraryPath.append`, `shelfPath.append`, `push(_:in:)`), whatever page shows by then. A lagging runner
   (VM-64's lags) is the window: New Note, nothing happens, Bookcase — the note is pushed onto the HIDDEN Library stack,
   mounts, registers with the liveness authority and takes the pen while hidden (the authority's own forbidden state),
   and it is what Library shows when she returns. This is the road that produces her sentence on this tree.
2. **A page change that is not the bar's** — `adoptProtectionRequest` calls `selectPage(.shelf)` directly, so the page
   left kept whatever stood on it (the bar's pop lived in `tabSelected`, not in the one page road).

**Pins** (`VariorumMobileTests/MobilePageLeavingTests`):
- `aNoteAskedForOnAPageSheLeftNeverStandsThere` — the Library's New Note then Bookcase in ONE turn (the door only
  spawns its mint, so the page changes before it lands — the lag's window made deterministic, no store hold): no editor
  registered and none live on the hidden page; the minted note kept; Library by the bar shows its root ("All" on the
  window). RED on old as predicted (5 issues: an editor registered AND live on the hidden Library page; on return the note stood where the Library should be — no bar, no root); GREEN on the tip.
- `leavingAPageClosesItsNoteAndSavepointsItOnce` — the ruling's sentence on the bar road: a note with unsaved words
  opened from the Library, Versions over it, Bookcase by the bar → the note closes, exactly ONE quiet leaving
  savepoint (`commit_point.kind = 'auto'`), Library shows its root, still one. A GUARD, expected GREEN on old (the bar
  road already popped) — recorded as such, not as a red. GREEN on old and on the tip, as predicted.
- The Protection-ask road (2) is not mounted in a pin (a bootstrap world is the Protection suites' heavy harness); it
  is covered by construction — the pop moves INTO `selectPage`, the one page road every road takes.

**The fix (piece 4), two halves, both structural.** (1) The pop moved INTO `MobileShellView.selectPage` — the one road
every page change takes (a tab, a swipe, the wing landing, the Protection ask's adoption): the stack being left returns
to its root, unanimated, before `tab` moves. A note on it closes exactly as Back closes it — its screen's `onDisappear`
road (teardown → `AppSession.savepointOnLeaving` → the hold given back) IS the existing leaving occasion; no new
operation, no new ask. `tabSelected` keeps only the current tab's animated pop. (2) The one push door
`push(_:in:)` refuses when the owning stack's page is not the one showing, and every stack write in the roots' wiring
now goes through it (the Starred, Bookcase and Library closures used `…Path.append` directly). With both, a hidden page
always stands at its root, so arriving anywhere — a tap, or a swipe revealing the neighbour mid-flight — shows the page
itself.

**PROVISIONAL P-260-1a (for QUESTIONS at the merge — the push door's face).** A note (or book) asked for on a page she
has since left is MADE and kept — it lists where it lives — and NOT opened; nothing is said. Built: (a) as described —
the only arm that keeps P-3 (no editor mounts or takes the pen on a page she cannot see) and R-260-5 (a page she left
stands at its root). Alternatives: (b) follow it — the page changes back to where it was asked and opens it (yanks her
from the page she chose); (c) open it on the page she is on now (a note born in the Library opening on the Bookcase's
stack). The window is a mint's latency, so the case is rare outside a lag.

Moved pins (P-71-1 retired by R-260-5): `MobileLeavingSavesOnceTests.aTabSwitchFilesTheBoxOnceAndLeavesTheHiddenNoteOpen`
→ `aTabSwitchFilesTheBoxOnceAndClosesTheNoteOnThePageItLeaves` (selectPage's new order: the screen leaves, the box
files, the pen is handed on — the box's note one savepoint, the note on the page left one leaving savepoint holding her
text, its screen out of the authority); `MobileProtectionScreenTests.theReopensAskIsAdoptedOnceAndPushesTheScreen`
(the typed write `shelfPath = [.protection]`). The liveness authority's own two-stack pins (`MobileLivenessTests`,
`MobileNoteOpenOnceTests`) drive the authority's brain, which still governs any state, and stay unchanged.

**Canon owed at the merge (not this batch's to write):** SurfaceContracts' phone-bar bullet (P-47-19's sentence becomes
every road's law; the bar drawn once), the QUESTIONS #280 addendum retiring P-71-1 (R-260-5, this run the pointer), and
P-260-1a into QUESTIONS.


### VM-255 — the roots' top line (her four changes; R-260-1, R-260-6; S-260-1, S-260-2)

**As built.**
- **The wing's name alone** (`MobileWingTitle.components(wing:)`, `doorParts(_:wing:)`; `MobileWingPath(detail:)`):
  Study "Home", Terminal "~/home" — the voice's own path grammar over the one word (the Terminal prefix kept: it is the
  voice's, not the page's). The page word left all three roots.
- **The Bookcase's count**, a quiet second line UNDER the name in the phone's muted ink (`MobileShelfFaces.bookCount`,
  "12 books", voiced), INSIDE the wing door's own 44 pt box — so the line does not grow at the default size, and the
  count rides the door (its accessibility value: "Home, 12 books"; a tap on it opens the wings list).
- **The gear** (`MobileSettingsGear.swift`, moved from `MobileRootMenu.swift`): a plain Button on
  `PhoneIconButtonStyle`, glyph `gearshape` in the accent (the ⋯'s tone), label "Settings", one press = the shell's
  Settings door; none without a shell (P-2). It replaces the ⋯ outright (S-260-1).
- **The trash door on the Library only** — `MobileShelfView.onOpenTrash` and the shell's wiring of it are gone.
- **The Mac's glyphs** (S-260-2 — symbols, never views): trash `trash` (the Mac Library masthead's
  `MastheadDoor.trash.icon`), New Note `square.and.pencil` (the Mac toolbar's `Button("New Note", systemImage:)`), the
  gear `gearshape` (the Mac's settings doors). Each is an icon button (44 × 44 target, the layer's icon size — batch 2
  steps the size down centrally); tones kept from the doors they replace: trash muted, New Note accent, gear accent.
- **The empty Library's line** named the door by its word ("+ New Note starts one.") — a word the root's door no longer
  wears. It now SHOWS the door's glyph inline ("[✎] starts one.", `MobileEmptyStoreCopy.noNotesDoorTail`) and SPEAKS
  "New Note starts one." (`noNotesDoor`, derived from `MobileNewNoteDoor.spokenName`) — the copy doctrine's own rule
  (a door's name derived, never retyped). PROVISIONAL with the rest of that copy (its header: her voice pass).
- Unchanged: a book's own "+ New Note" foot row (`MobileBookView.newNoteDoorTitle` — not a root's top line).

**Pins** (look-class: what is pinnable; the look itself is the walk's).
- `MobileTopLineTests.onlyTheLibrarysTopLineCarriesTheTrash` — mounted shell: no trash door on the Bookcase or Starred,
  one on the Library. RED on old as predicted; GREEN on the tip.
- `MobileTopLineTests.theLineIsTheWingsNameAloneAndTheBookcaseCountsUnderIt` — mounted shell, each root: the wing
  door's value is the count on the Bookcase ("2 books") and nothing elsewhere, the door one 44 pt line, no page word
  across its band. RED on old as predicted (the page word on all three lines); GREEN on the tip.
- `MobileTopLineTests.theGlyphsAreTheMacsSymbols` — source: the phone draws `trash`, `square.and.pencil`, `gearshape`
  through its declarations; the Mac's sources state the same three; each is a real symbol; no 🗑 in the phone's code.
  GREEN on the tip. Its R3 run is NOT an old-tree verdict: the pin reads the WORKING TREE's sources at run time, so under the old build it read the tip's — and its one red there (the emoji walk) was a real tip finding, fixed in `19b31c4c3` (the suites block). Its old-tree red is shown statically: `8d7fc32cb` holds no `trashSymbol`, no `square.and.pencil`, no `MobileSettingsGear.swift`, and the emoji's escape.
- `MobileSettingsGearTests` (moved from `MobileRootMenuTests`): every root's gear 44 × 44 on its line, its act the
  shell's door, no "More" beside it; no shell, no gear; `theShellsRootsCarryTheGearAndTheMenuIsGone` (RED on old: three
  "More", no "Settings" door); `theGearOpensSettingsThroughTheWholeShell` (RED on old: no gear to press); the note's ⋯
  road unchanged. The four RED on old as predicted; the two guards green; all GREEN on the tip.
- These two new files use only symbols both trees declare (plus literals), so the red-on-old run drops them into the
  pre-VM-255 tree (`8d7fc32cb`) unchanged.

**Pins moved with the ruling** (each says MOVED and why): `MobilePathLineGeometryTests` (rewritten: the Bookcase's line
is the name with its count inside the 44 and two doors, no trash; the Library's the name and three doors — every door
44 × 44 on the door's line, 402/430, both voices); `MobileWingDoorTests` (the letters: two pieces; each root's door
value; the plain line); `MobileWingsTests.theTopLineIsTheWingsNameAlone`; `MobileEmptyStoreTests.
theEmptyLibraryNamesTheRealDoor`; `MobileDeletionTests.theShelfCarriesNoTrashDoor` (was `…CarriesTheSameTrashDoor`);
`MobileTabBarTests` (`aPushedListWears…`, `theMessageLineClears…` through the Library's Trash; `aWingLanding…` through a
book's contents on the Bookcase's stack); `MobileScreenEdgeGroundsTests.onAPushedListThePaperRunsUp…` (the Library's
Trash).

**Calls made (for the record; none gates the core):**
- C-255-1 — the count rides INSIDE the wing door's 44 pt box (the line does not grow; a tap on the count opens the wings
  list). Alternative: a separate line under the 44 pt row (the top grows by one 13 pt line, against "everything too
  big").
- C-255-2 — the Terminal prefix "~/" stays before the wing's name (the voice's path grammar; R-260-1 removed the page).
- C-255-3 — the glyph doors keep the tones of the doors they replace (trash muted; New Note and gear accent).

**Canon owed at the merge (the merging session's, two-file shape):** SurfaceContracts "The app" — the phone's bottom
bar bullet (drawn once by the shell; every road returns the page left to its root, R-260-5), the phone's Settings
bullet ("It opens from the ⋯ menu all three roots carry" → the gear), and "The Bookcase and books" wing-switcher phone
paragraph ("The Bookcase root's top line reads the wing's name, "Bookcase" and the count…" → the name alone, the count
a muted line under it on the Bookcase, the trash on the Library only, P-47-27's ⋯ last → the gear last); QUESTIONS
#281's P-47-9, P-47-22, P-47-27, P-47-31 answered by this member.


**Self-review finding (fixed, pinned).** With the page word gone, a root's plain line for a wing whose name is not
yet read drew Terminal's bare prefix "~/" (`tokens.path([])`); it now draws nothing (`MobileWingPath`'s plain branch).
Pin: `MobileWingDoorGeometryTests.anUnreadNameDrawsNoBarePrefix` — red on `f8aa3f6f4` by construction (that tree drew
"~/"), GREEN on the tip (leg P).

### READY-FOR-TESTS (the stage window's commands — RAN 2026-11-25; the results are the suites block below)

All from `App/Variorum/`, zsh, `test-without-building` against the bundles already built (nothing builds in the
window); `UDID` = the device the GO names (iOS 26.2), booted fresh inside the claim, settled, shut down before release.
Plans: `P=DerivedData/<folder>/Build/Products/VariorumMobile_VariorumMobile_iphonesimulator27.1-arm64-x86_64.xctestrun`.

**R — red on old (each pin's pre-fix tree, expected RED where named):**
- R1 `rol253`: `-only-testing:VariorumMobileTests/MobileTabBarStaysStillTests` — RED: `theBarIsDrawnOnceByTheShell`,
  `midSwipeTheBarHasNotMoved`; green (guard): `aPageChangeMovesOnlyTheChip`.
- R2 `rol256`: `-only-testing:VariorumMobileTests/MobilePageLeavingTests` — RED: `aNoteAskedForOnAPageSheLeftNeverStandsThere`;
  green (guard, the bar road already popped): `leavingAPageClosesItsNoteAndSavepointsItOnce`.
- R3 `rol255`: `-only-testing:VariorumMobileTests/MobileTopLineTests -only-testing:VariorumMobileTests/MobileSettingsGearTests`
  — RED: `onlyTheLibrarysTopLineCarriesTheTrash`, `theLineIsTheWingsNameAloneAndTheBookcaseCountsUnderIt`,
  `theGlyphsAreTheMacsSymbols`, `everyRootCarriesTheGearOnItsTopLine`, `theShellsRootsCarryTheGearAndTheMenuIsGone`,
  `theGearOpensSettingsThroughTheWholeShell`; green on both: `noShellNoGear`, `aNotesActionsOpenSettingsThroughTheWholeShell`.

**P — the tip, the whole phone target, one launch** (`vm260-1a`): `-only-testing:VariorumMobileTests` — read against
main's known reds. (The shell and all three roots changed; every suite that mounts the shell or a root is in it.)

**M — the Mac legs** (`DerivedData/vm260-1a-mac/Build/Products/Variorum_Variorum_macosx27.0-arm64.xctestrun`,
`-destination 'platform=macOS'`): `-only-testing:VariorumTests/<type>` for ThemeTokenTests NoLiteralColourTests
PaletteDerivationTests BadgeFamilySplitTests DataSafetySearchIndexTests OneInputPathTests
OneRefreshAuthorityCompositionTests DeadVocabularyTests IndexTierMetricsTests (the token pins and every Mac suite that
walks the whole phone tree; `Shared/` and the Mac's sources are byte-unchanged by this batch).

**U — optional, the keyboard-reveal UI test** (`DerivedData/vm260-1a-ui`, scheme TK2SpikeUITests' plan,
`-only-testing:VariorumMobileUITests/MobileKeyboardRevealUITests`, a dedicated simulator): `MobileShellView.body`
changed — the one bar's overlay sits in the band's chain, inside its frame and before its clip, neither moved — so the
rule's letter ("any change to the band's clip or frame") is arguably not met; run it here if the window allows, else
batch 2's run covers it.

**W — the walk** (the Debug phone app from `vm260-1a` on the same simulator, ~20 min, captures to
`notes/plans/vm-260-screens/batch-1a/`, Study and Terminal, light): the three roots at rest (the name alone, the
Bookcase's count line, the Library's trash · glyph · gear, Starred's gear); a swipe held mid-flight Bookcase → Library
(the bar unmoved, two pages showing above it); a push to a list (the Library's Trash — the bar unmoved) and into a note
(the bar gone); the gear opening Settings; the empty Library's glyph line.


### Batch 1a — the suites (the GO window, 2026-11-25 01:11–01:41; claim `vm-260`; the coordinator's iPhone 17 Pro, iOS 26.2 — its id is not recorded)

Booted fresh 01:11, settled ~5 min. Load at R1's start 23.5 (another session's headless Mac `build-for-testing` plus
the simulator's post-boot `trustd`); R1–R3 are not timing-sensitive, so they ran; by R2 the load was ~2 and stayed low
for P. **Runner exit:** after each Swift Testing result `xcodebuild` lingered without exiting (R1: over 5 min); each
verdict line was already complete, so each lingering runner (this session's) was stopped. XCTest's half of every phone
run reads "Executed 0" — expected (these are Swift Testing suites), not a no-verdict.

| Run | Tree | Result | As predicted? |
|---|---|---|---|
| R1 `MobileTabBarStaysStillTests` | `b05c45bb0` (pre-fix) | 3 tests: 2 FAILED (8 issues) — `theBarIsDrawnOnceByTheShell` (6), `midSwipeTheBarHasNotMoved` (2); `aPageChangeMovesOnlyTheChip` passed | YES |
| R2 `MobilePageLeavingTests` | `9edeb6993` (pre-fix) | 2 tests: 1 FAILED (5 issues) — `aNoteAskedForOnAPageSheLeftNeverStandsThere` (editor registered and live on the hidden page; the note where the Library should be); `leavingAPageClosesItsNoteAndSavepointsItOnce` passed | YES |
| R3 `MobileTopLineTests` + `MobileSettingsGearTests` | `8d7fc32cb` + the two pin files | 8 tests: 6 FAILED (13 issues) — `onlyTheLibrarysTopLineCarriesTheTrash`, `theLineIsTheWingsNameAloneAndTheBookcaseCountsUnderIt`, `theGlyphsAreTheMacsSymbols`, `everyRootCarriesTheGearOnItsTopLine`, `theShellsRootsCarryTheGearAndTheMenuIsGone`, `theGearOpensSettingsThroughTheWholeShell`; `noShellNoGear`, `aNotesActionsOpenSettingsThroughTheWholeShell` passed | YES (the glyph pin's old-tree red is static — see its pin line) |
| P — the whole phone target, one launch | tip `74a3a7149` | **1,235 tests in 218 suites PASSED** after 800 s, 6 known issues (pre-existing: `MobileFilterRowGeometryTests`' two Display-Zoom pins × 2, `MobileTrashTests`' empty-tree diagnostic × 2); the gated speed suite skipped (as every whole-target run) | — |
| M — the Mac legs (ThemeTokenTests NoLiteralColourTests PaletteDerivationTests BadgeFamilySplitTests DataSafetySearchIndexTests OneInputPathTests OneRefreshAuthorityCompositionTests DeadVocabularyTests IndexTierMetricsTests) | tip | **53 tests in 9 suites PASSED**, 4 known issues (`IndexTierMetricsTests`' declared `overTwoBlankLines` cases, Mac-only, untouched) | — |
| U — `MobileKeyboardRevealUITests` | tip | **NO VERDICT** — 1 test, failed at its PRECONDITION ("the shell is up (its bar's Bookcase door)") after ~50 s: the device's library opens behind a Castle passphrase screen ("Open your library" — one diagnostic launch and capture, kept locally), which the test's lobby helper does not pass and this session has no passphrase for. Not retried (a retry meets the same lock). | — |

**Found in the window, fixed after it (`19b31c4c3`, both VM-255 follow-through):**
1. **The pocket guide's Trash line** (`MobileTutorialSeeder`, lesson 3) still said "the 🗑 sits on the Library's top line
   and on the Shelf's" — stale twice since VM-255 (the emoji; the Bookcase's door retired). Now "the trash icon sits on
   the Library's top line." (wording PROVISIONAL with the guide's copy, her voice pass). Caught by
   `theGlyphsAreTheMacsSymbols`' emoji walk. During P the fix was on disk but not yet built: the source pin read the
   fixed text and passed; no test reads the compiled guide text. Rebuilt green after.
2. **The keyboard-reveal UI test reached Settings through the ⋯ ("More")**, which VM-255 retired — it would have failed
   at that step on an open library too. It now presses the gear ("Settings"). UI bundle rebuilt green; NOT run.

**Owed:** the keyboard-reveal UI test on a device whose library opens (batch 2 runs it — it changes `MobileWriteView` —
or the next window on an unlocked device); the walk (a separate leg).

**Left as found:** the simulator shut down; no runner, no booted simulator; no new Variorum crash report. Logs in
`App/Variorum/DerivedData/vm260-1a-{R1,R2,R3,P,M,U}.log` (gitignored); the UI run's result bundle in Xcode's default
DerivedData.


### F-1a-W1 — the bar under the Library search's keyboard (MAJOR, the walk's; fixed at batch 2's boundary; implementer: Opus, a fresh session, 2026-11-25)

**What this fix did NOT do (kept current):** NO test has run — the stage is coordinated above this session, so the
pin's red, the fix's green and the keyboard-reveal re-run are all PENDING the window; the s9 re-capture is the window's;
no line in `Sources/`, `Sync/`, custody, `MobileEditorTextView`, `MobileKeyboardBar`, the text-input path or
`MobileWriteView`; the one-bar overlay (VM-253) is NOT changed in kind — the traced mechanism is not the overlay's.

#### LIVE STATUS

| Piece | State |
|---|---|
| W1.0 Preflight (CLAUDE.md + canon; this record's binding sections, BATCH 1a in full, BATCH 2; SurfaceContracts' bar line; the resiliency protocol) and the trace (the captures' pixels; the walk's log; one Sonnet lookup for external facts, read-only) | DONE (this commit) — the mechanism below |
| W1.1 The pin — `MobileKeyboardRevealUITests.testTheBarRidesAboveTheLibrarySearchKeyboard` (the UI test; the defect needs a real keyboard and a real keyboard session before it, which no mounted unit pin can make); its commit IS the red-on-old tree | DONE (`c4081441c`) — the run PENDING the window |
| W1.2 The red-on-old tree's UI bundle built headless into `DerivedData/vm260-w1-rol` (APFS clone of `vm260-2-ui`, incremental, `nice -n 15`) | DONE — `TEST BUILD SUCCEEDED` at `c4081441c` |
| W1.3 The fix — the band's foot never below UIKit's keyboard layout guide (`MobileKeyboardFloor`), with its rule pin and a mounted wiring pin | DONE (`dae368b4e`) — the pins PENDING the window |
| W1.4 The tip bundles rebuilt on the fixed tip (`vm260-2`, `vm260-2-mac`, `vm260-2-ui`), `nice -n 15`, incremental; batch 2's READY block updated | DONE — all three `TEST BUILD SUCCEEDED` at code tip `dae368b4e` (the batch-2 build logs kept as `vm260-2{,-mac,-ui}-build-b2.log`); no warning in the changed files |
| W1.5 The window — the pin red on the red-on-old tree, green on the tip; the keyboard-reveal test on the tip; the s9 re-capture | PENDING (the GO) — the legs are in batch 2's READY block (R-W1, P, U, W) |

#### The traced mechanism (from the captures' own pixels — not the suspected one)

Measured off the PNGs (converted to bitmaps in the session scratchpad; points = pixels ÷ 3):
- **s9** (batch 1a's tip, the walk): the keyboard's glass begins at **y 539.0**; its keys' tops at **591.0**; the one bar's
  hairline at **535.0**, so the bar stands **535–591** — under the keyboard's candidate strip (539–583) and the key
  plane's top air, the glass blurring it. The Library's rows are cut AT the bar's hairline.
- **VM-47's final-tree `c4-library-search`** (main's tree before this run; the same iPhone 17 Pro on iOS 26.2; the same
  field, "swipe" typed): the bar's hairline at **483.0**, the bar **483–539**, standing exactly on the glass's top.
- **The difference is 52.0 pt — the note editor's keyboard bar's height** (`MobileKeyboardBar.barHeight`, the editor's
  `inputAccessoryView`, "measured to 52" in its own comment; the keyboard-reveal run on the walk device logged the
  accessory's top at 486.67 over the glass at 539 — 52.3).
- **The walk's order:** s5 opened a NEW note with its keyboard up (the 52-pt bar riding it), Back, the Trash, two tabs,
  then s9 tapped the search — **the first keyboard after a keyboard that wore an accessory.** Every correct capture
  (VM-47's c4, c2's capture box, the reveal test's own search) reached the field with no accessory keyboard before it.

**Not the overlay.** The suspected mechanism (the one bar at the band's foot while the band ignores the keyboard, the old
in-page bars having ridden each page's avoidance) is refuted by the same capture: the Library page's rows run down to the
bar's hairline, so the page's own foot — its reserved place, `MobileTabBarSpace` — stands exactly under the one bar, 52 pt
low as well. Had the band alone missed the keyboard, the page would end at the glass with the room's ground showing
through its empty reserved place above the bar; it does not. The page and the band take ONE keyboard avoidance — the
root's SwiftUI keyboard safe area (nothing above the band ignores the `.keyboard` region) — and that avoidance came out
52 pt SHORT. So the bar VM-47 drew inside each page would have stood at the same 535–591 (INFERRED — no capture of
main's tree in this order exists); the defect predates this run and is not VM-253's.

**The mechanism, as far as the evidence reaches:** after a keyboard session whose first responder wore an
`inputAccessoryView` (the note editor's 52-pt bar), the NEXT keyboard's SwiftUI avoidance is short by that accessory's
height, so the shell's band — and every page and the bar on it — keeps its foot on the keys, under the candidate strip.
External facts (one Sonnet lookup, forum reports only — no Apple documentation found): Apple Developer Forums thread
802159 (iOS 26, FB20386257) — after a WebView's keyboard (which wears the form-assistant accessory), a SwiftUI
`TextField`'s keyboard leaves the bottom controls covered; it recovers once the keyboard is dismissed and reopened; the
reporter suspected a stale saved input-accessory frame; a DTS engineer suspected a known issue. Thread 801685 (iOS
26.0.x) — the keyboard notification's frame omitted a panel attached to the keyboard's top, and `keyboardLayoutGuide`
reported it (the posted workaround); Apple's own page for `keyboardFrameEndUserInfoKey` recommends
`UIKeyboardLayoutGuide`. **NOT KNOWN:** which layer carries the stale 52 — UIKit's reported frame or SwiftUI's own
avoidance; the window answers it (below).

#### The pin (`c4081441c` — the red-on-old tree is that commit; its UI bundle `DerivedData/vm260-w1-rol`)

`VariorumMobileUITests/MobileKeyboardRevealUITests.testTheBarRidesAboveTheLibrarySearchKeyboard` — a second test in
the keyboard-reveal class (its `-only-testing:` line now runs both; the first test is byte-unchanged). A UI test because
the defect needs a REAL keyboard after a real keyboard that wore an accessory; the unit host raises none reliably, and
the stale avoidance is the system's state, not the shell's.
- **The oracle is the screen's own pixels:** at rest (the Library's root, no keyboard) each of the bar's three doors is
  read — its frame and its drawing; with the search holding the keyboard each door must draw EXACTLY as at rest (at most
  a tenth of its ink pixels differing, a channel by more than 24 of 255 — the walk's s9 drew the words blurred under the
  candidate strip's glass, nearly every ink pixel differing), and its frame must end above the keyboard's keys
  (`app.keyboards.firstMatch.frame.minY` — XCUITest's keyboard element is the key plane, 583 on this phone; s9's bar
  ended at 591). Premises: each resting door draws at least 40 ink pixels; the note's keyboard wears the editor's bar
  (`kbar.block` on screen).
- **Leg 1 — the control:** the search's keyboard with no keyboard before it (VM-47's c4 shape). Predicted GREEN on BOTH
  trees.
- **Leg 2 — the finding:** the lesson opened from the search, a tap mid-note (the editor's keyboard with its 52-pt bar),
  Back with the keyboard up (the walk's road from s5), then the search's keyboard (tapped, or its focus restored at
  Back — either is the first keyboard after the note's) — and again with the field emptied inside that keyboard (the
  walk's s9 frame). **Predicted RED on `c4081441c`** (each door's pixels differing, each frame ending on the keys —
  ~52 pt low), GREEN on the fixed tip.
- The pin's text is byte-identical on the red-on-old tree and the fixed tip (`git diff c4081441c dae368b4e --
  App/Variorum/VariorumMobileUITests/` is empty). One residual in its road: after Back it taps the search only when no
  keyboard is up (a keyboard still up there is the search's own focus restored); a note's keyboard still sinking 2.1 s
  after the Back tap would leave it waiting on no keyboard — a FAIL "no software keyboard rose", never a pass.
- Nothing is written: a search typed and emptied, a caret placed in the lesson (its words untouched — no leaving
  savepoint), the keyboard dropped by a page change at the end. Screenshots kept as attachments: "BAR at rest",
  "BAR leg 1", "BAR leg 2", "BAR leg 2, emptied" — **leg 2's are the s9 re-capture in Study light** (export them with
  the result bundle).
- **If leg 1 is RED on old too,** the "after an accessory" mechanism is wrong (the shortfall is not tied to the note's
  keyboard) — report it, the fix still answers any shortfall the guide sees. **If leg 2 is GREEN on old,** the test's road
  did not reproduce the walk's state: the row is HOLLOW on this road (record it, do not claim the fix).

#### The fix (`dae368b4e`)

**The band's foot never stands below UIKit's keyboard layout guide.** `VariorumMobile/Features/Shell/MobileKeyboardFloor.swift`:
- **The rule** (`MobileKeyboardFloor.lift(bandFoot:reading:noteShowing:)`, pure): the band rises by however far its foot
  (SwiftUI's own avoidance, `proxy.frame(in: .global).maxY`) stands below the guide's top — zero with no keyboard, zero
  while the band's foot is at its RESTING foot (SwiftUI sees no keyboard — a keyboard leaving: its avoidance drops first
  and the probe's nil arrives a turn later, so the band never meets the old floor), zero with the foot at or above the
  keyboard (the floor never lowers the band), zero within 2 pt (rounding between the readings), zero while a NOTE is the
  visible top screen (its text view rides the same guide itself — `MobileWriteSurfaceView` — and its screen ignores the
  keyboard region). **Wherever SwiftUI's avoidance already reaches the keyboard the lift is zero and nothing moves:** the
  fix changes the layout only in the short case.
- **The probe** (`MobileKeyboardFloorProbe`): a `UIView` filling the window behind the band (`.background`,
  `.ignoresSafeArea()`, untouchable, unheard), a hidden marker pinned to its own `keyboardLayoutGuide`; it reads the
  guide's top and the window's resting foot (`window.bounds.maxY − window.safeAreaInsets.bottom`) in window points on
  each keyboard notification (signals only — P-4: the measurement is the guide's frame) and on its layout, and hands the
  shell a CHANGED reading always a turn later (never inside a SwiftUI update — a field resigning during one posts its
  hide there). While a note shows it hands no new reading (so a note's keyboard never re-renders the shell); a nil (the
  keyboard gone) is always handed on.
- **The shell** (`MobileShellView`): `@State keyboardReading` from the probe (written with a 0.25 s ease — the lift
  animates in the short case only); the band's `ZStack` framed `proxy.size.height − lift` at the reader's top, so the
  pages, the one bar over the foot and the clip rise TOGETHER (the bar still covers exactly its reserved place); what the
  lift leaves below is the shell's edge grounds (the bar's room when the bar stands), behind the keyboard's glass —
  SurfaceContracts' edge line holds ("nothing a page lays out or scrolls runs under … the keyboard bar"). A test seam
  `heldKeyboard:` (the `heldDrag:` precedent; nil in the app).
- **Pins of the fix's own parts** (`VariorumMobileTests/MobileKeyboardFloorTests.swift`; the types are the fix's, so
  these are GUARDS, not red-on-old claims): `MobileKeyboardFloorRuleTests` (six — no keyboard, the walk's 591/539 → 52,
  an avoidance that reaches the keyboard moves nothing, a band at rest meets no floor, rounding, a note left alone);
  `MobileKeyboardFloorShellTests.theBarRidesOnTheKeyboardTopHandedIn` (mounted shell, 393 × 852: a held reading at 600
  with the resting foot below the band → every bar door ENDS at 600, same size and x, the top line unmoved; a band at
  rest with the same reading → the bar unmoved). Prints `PERF[sim] F-1a-W1 …`.
- **Untouched:** the one-bar overlay's kind and place (VM-253), `MobileTabBar`/`MobileTabBarSpace`, every page, the
  editor family, `MobileKeyboardBar`, `MobileWriteView`, the text-input path, `Shared/`, `Sources/`. **Pins moved: none.**

**Calls made (none gates the core; for the record):**
- **C-W1-1 — the floor is UIKit's keyboard layout guide**, consulted as a FLOOR under SwiftUI's own avoidance (the
  correction applies only to a shortfall). Alternatives: (b) the guide as the band's ONE avoidance
  (`.ignoresSafeArea(.keyboard)` on the band + the guide's overlap as its padding) — one authority, but it changes every
  keyboard's timing and the note's road, which the keyboard-reveal test guards; (c) remove the stale source in the
  editor — drop the editor's `inputAccessoryView` as its text view resigns — the editor seam, not this fix's to touch.
- **C-W1-2 — a note is left alone** (its own guide-pinned text view).
- **C-W1-3 — the lift eases in 0.25 s** (the short case only; the keyboard's own curve is SwiftUI's and not readable
  from the guide).

**NOT KNOWN until the window — and what each answer means:** whether UIKit's keyboard layout guide carries the TRUE top
on the keyboard after an accessory keyboard (Apple recommends it; a forum report shows it right where the notification
frame was wrong — thread 801685), or the same stale 52. If leg 2 is GREEN on the tip, the guide is right and the fix
holds. If leg 2 stays RED on the tip with the bar still ending at 591 (no lift) while the mounted wiring pin is green,
the guide is stale too: the next road is C-W1-1 (c) — the editor seam, a Fable-reviewed change — and the record says so.

**Not done here, for the window and the later reader:** (1) the same mechanism reaches the BOOKCASE's capture box (the
contract's other half) when its keyboard is the first after a note's — the fix is band-wide, so it answers there too; a
capture stop is proposed below. (2) The one message line tracks the keyboard from its own notifications
(`MobileMessageLineController.adoptKeyboard`); if the stale 52 lives in UIKit's notification frame, the line would sit
52 pt low over the bar on that same keyboard — batch 1b's surface, unverified, not touched; a capture stop is proposed.
(3) Main's tree (before this run) is INFERRED to show the defect too (the in-page bar stood where the reserved place
stands); no main-tree run is owed by this fix.


## BATCH 1b — record (VM-265 · VM-275 · VM-277 · A-260-1's direction line; implementer: Opus, 2026-11-25)

**What this batch did NOT do (kept current):** NO suite has run (the stage is coordinated above this session — every
test claim below is PENDING until the one window at this batch's close, A-260-7); the walk and its captures are not
done; VM-277's headline does NOT yet reach the refusals spoken from the editor's own files (`MobileEditorViewModel`,
`MobileStructural` — the gate's cross-block route, her recording's join refusal among them): those keep handing the
plain sentence and draw through the ruled one-line clip (owner and road below); no line in `Sources/`, `Sync/`, custody,
`MobileEditorTextView` or the text-input path; the Mac's seam face and words untouched.

### LIVE STATUS

| Piece | State |
|---|---|
| 0. Preflight (CLAUDE.md + canon; this record's binding sections, A-260-1, batch 1a's record; the resiliency protocol; SurfaceContracts "The app" incl. the status-seam bullet; the VM-55 FOR A LATER READER + its batch 2 brief; QUESTIONS #277; the three tickets' bodies) | DONE (`f85e9fb54`) |
| 1. The pins on the pre-fix tree, with the one zero-behaviour seam they need (the face's ink choice as a pure rule, `MobileMessageLineModel.ink(for:)`) | DONE (`eb677c6a8`, compile fixes `ea3f95831` — **`ea3f95831` IS the red-on-old tree**) |
| 2. The red-on-old tree built headless | DONE — `DerivedData/vm260-1b-rol` from `ea3f95831` (a clone of `vm260-1a`, built incrementally): `TEST BUILD SUCCEEDED` |
| 3. VM-265 — a direction draws in the muted ink | DONE (`fc51f0f8e`) — phone `build-for-testing` green on the tip; the suites PENDING |
| 4. VM-275 half 1 — a refusal raised in a note clears when she leaves it | DONE (`f3c310ef3`) — compiles; the suites PENDING |
| 5. VM-275 half 2 — the squeeze, traced | TRACED: no row moves (a guard pin, expected GREEN on both trees ⇒ the literal mechanism HOLLOW — PENDING its run); what she saw is the line's face, whose cure is VM-277's anatomy — carried in the proposal below, NOT built |
| 6. A-260-1 — the push door's made-but-not-opened outcome speaks a direction | DONE (`982390ada`) — compiles; the suites PENDING |
| 7. VM-277 — the proposal (stop-and-propose) | DONE (`68dc4b946`) — RULED A-260-4 (build as proposed); `isDirection` ACCEPTED A-260-3; half 2 HOLLOW A-260-5; C-275-1 accepted A-260-6 |
| 8. Tranche 1's bundles and run list | DONE (`469dcae16`) — superseded by 14 |
| 9. VM-277 pins on the pre-fix tree (+ the face's `lineFrame` seam) | DONE (`7199d7d9a`, compile fix `c8bfa668f` — **`c8bfa668f` IS VM-277's red-on-old tree**); built `DerivedData/vm260-1b-rol277` |
| 10. VM-277 seam: `Item.refusalHeadline`, `refuse(headline:sentence:)`, `holdForReading(_:)`; the VM-61 fence extended; the seam's pins | DONE (`a7bcd326f`, its own commit ahead of the code) |
| 11. VM-277 (a): the refusal table answers `RefusalWords` from each arm; 27 DRAFT headlines | DONE (`fe24082f8`) |
| 12. VM-277 (b)–(e): the card, the refusal's one line with "›", the reason card held, the ✕ and the flick | DONE (`e81e3df68`) |
| 13. VM-277 (a) wired: ten models' refusal slots carry the pair; membership and lenses speak it; the fix's own pins | DONE (`aac68d986`, pin margin `ca9a8d7be`) |
| 14. The full batch's bundles: phone tip `vm260-1b` (`ca9a8d7be`), Mac tip `vm260-1b-mac` (`aac68d986` — the later commit is phone-test-only), red-on-old `vm260-1b-rol` + `vm260-1b-rol277`; READY-FOR-TESTS | DONE — all incremental, under `nice -n 15` (the quiet window) |
| 15. The suites at the ONE window (R1, R2, P, M) | PENDING |
| 16. The walk — the whole line (A-260-7) | PENDING |


### VM-265 — a direction reads in a neutral ink (P-55-19 → (b))

**Traced mechanism.** A direction rides the refusal CLASS at the seam on purpose (always drawn — P-55-7/P-55-11): every
phone direction door said `MobileLine.say(…, as: .refusal)` → `StatusCenter.refuse` → an `Item(kind: .refusal)`, and the
face inked by kind alone (`.refusal → tokens.alarm`). The item carried no fact that told the face a direction from a
refusal, so a line such as "Already collected — …" or "Entry saved. Your daily journal book is finished…" drew in the
alarm red.

**The fix, as built.** The ruled option's own shape — "a new item fact and a face arm":
- `StatusCenter.Item.isDirection` (defaulted false), set by the seam's EXISTING `direct(_:)` door alone (it delivers
  exactly what it delivered — the same trim, guard, slot and clock — with the fact set). **The seam's kinds and slot
  rule are untouched; this is the batch's one line of `Shared/StatusCenter.swift`.** The Mac's face never reads the fact
  (its toast inks by kind), so the Mac's words and face are unchanged; `VM61MacStatusSeamPinTests`' forbidden words are
  not touched (the Mac legs re-run it — PENDING).
- The phone's line vocabulary gains `MobileLine.Class.direction` → `status.direct`.
- The face's ink is one pure rule, `MobileMessageLineModel.ink(for:)` (`.refusal` → muted when `isDirection`, else the
  alarm; an offer her ink; a receipt the muted) — the role the face resolves against the library's look.
- Every direction door speaks `.direction`: the Trash's put back (`MobileTrashModel`), the tray's and the Block
  History's put backs and restores (`report(direction:)` — a refusal stays a refusal first), the lens's archived pick
  (`MobileLenses`), the collect-by-tagging and "Already collected" (`MobileMembership.collect` — P-55-7's own example and
  the ticket's), the Today door's unfiled entry (`MobileShelfViewModel.openToday`), the copy that could not follow the
  screen (`MobileNoteClipboard.Outcome.copiedSavedTakes`), and A-260-1's new line.

**Pins.** `MobileLineDirectionTests`: every direction door's existing pin also asks the face's ink rule (`expectMutedInk`,
9 sites in 8 tests) — RED ON OLD predicted for all 8 (the alarm); new `aDirectionReadsMutedAndARefusalKeepsTheAlarm`
(the seam's `direct` beside `refuse`, an offer, a removal) — RED ON OLD predicted (one issue: the direction); new
`theTodayDoorsUnfiledEntryReadsMuted` (a finished Journal, the entry opened not filed) — RED ON OLD predicted;
`theDirectionsAreTheLandingsThatAreNotItsPlace` unchanged (green on both). `MobileNoteClipboardTests.
aCalloutNoteKeepsTheStoredRoadEvenWhilePeeking` gains the ink check — RED ON OLD predicted. MOVED with the ruling:
`MobileLineShowRuleTests.theCopyOutcomesSayTheirClass` (`.copiedSavedTakes.line` is `.direction`, was `.refusal`).
All PENDING the GO.

### VM-275 — a refusal leaves with its note; the line never squeezes the list

**Half 1 — traced mechanism.** The line's item lives in the seam (`StatusCenter.current`) until its 6 s clock or a newer
message. The note screen's leaving road (`MobileWriteScreen`'s `onDisappear`: teardown, the leaving savepoint, the hold
given back — and since VM-256 every page change takes it) withdrew only what the note's own UNDO DOOR said
(`MobileLine.withdrawNoteLine(of:)` → `withdraw(owner:)`); a refusal carries no owner, so a refusal raised in the note
rode on over the Library for the rest of its clock (her recording: about 5 s of 8.5 — the 8.5 is her repeated
backspaces re-raising the refusal, each re-arming the clock).

**Half 1 — the fix.** The clearing rides that SAME leaving road — no second navigation observer: the screen notes which
line was showing as it arrived (`lineWhenShown`, written on appear), and on disappear `MobileLine.leaveNote(session:
lineWhenShown:)` clears the line when the pure `MobileLine.clearsOnLeavingNote` says so — a refusal-class line raised
while the note showed. Kept: a line from before the note opened (the Today door's direction is said just before its
note is pushed), a removal (the note's delete pops the screen while its Put back line stands), an offer. P-55-3's fade
otherwise stands. The edit in `MobileWriteView.swift` is two calls on the screen's appear/disappear — no layout, nothing
in `MobileWriteView` (the editor host), `MobileEditorTextView` or the text-input path.
- **PROVISIONAL C-275-1 — a DIRECTION raised in the note clears on leaving too** (it rides the refusal class; a direction
  about the note — "Already collected", a copy that could not follow the screen, a put back that landed elsewhere — is
  stale once she has left it). Alternative: only refusals proper clear, a direction keeps its fade.

**Half 2 — traced mechanism: the rows never move.** The line is its own passthrough window over the scene
(`MobileMessageLineHost`), raised ONCE when the shell joins its window — never per message — and nothing in the app's
window reads the line: a whole-tree search finds no reader of `status.current`/`spoken`/`lineItem` outside the face. So
no row can move or shrink when a line shows. What reads as "shrinking the list to make room above the tab bar" is the
line's FACE: a full-width band on the bar's own ground (the room) under the bar's own hairline, standing flush on the
bar — so the bar appears to GROW over the list's foot — and the join refusal she saw is three to four lines at 15 pt,
about 100 pt, more than a Library row (88 pt). The cure is the face's anatomy, which is VM-277's design pass (one
short line, and a shape that reads as an overlay — fork (e) of the proposal below), so it is proposed there and NOT
built here.
- Pin: `MobileRefusalLeavesItsNoteTests.theListNeverMovesWhileTheLineShows` — a GUARD, expected GREEN on both trees:
  Library rows' frames at rest, with a four-line refusal showing, and after it went, all equal. Green on old disposes the
  half's literal mechanism (rows squeezed) as **HOLLOW** (PENDING its run). The pin measures the app's window, which is
  the claim: whether the hosted surface also raised the overlay window does not change it (the overlay is a separate
  window raised once, never per line).

**Pins** (`MobileRefusalLeavesItsNoteTests`): `aRefusalRaisedInANoteClearsWhenSheLeavesIt` — the note's real Copy door
on a note with no words refuses; Back; the line is gone — RED ON OLD predicted; `aLineSaidBeforeTheNoteOpenedOutlivesItsLeaving`
and `aRemovalSaidInTheNoteOutlivesItsLeaving` — GUARDS, green on both predicted; `theClearingRuleClearsOnlyTheNotesOwnRefusals`
(the pure rule; added with the fix, tip only); the half-2 guard above. All PENDING the GO.

### A-260-1 — a note made but not opened says where it landed

**As built.** The one push door's refused branch (`MobileShellView.push(_:in:)` — the owning page is not showing) now
says `MobilePushLanding.direction(for: route)` as `.direction`: a note — "That note didn't open because you'd moved on
— it's in the Library."; a book — "…it's on the Bookcase." The room words are the bar's own (`MobileTabBar.word`,
derived). Every note lists in the Library and every book on the Bookcase, so the line is true whichever door asked
(the door knows the route, nothing of the mint — a Today entry may have stood already, so it never says "new"). The
other routes (a book's Read, the Trash, Archived, Versions, Protection) are never made by the door that asks for them
and say nothing. No Undo, never a refusal, no new seam kind. **The words are DRAFT — PROVISIONAL for her pass** (with
P-260-1a at the merge).

**Pins** (`MobilePushLandingDirectionTests`): `aNoteMadeAfterSheLeftThePageSaysWhereItLanded` (batch 1a's one-turn
window: Library's New Note then Bookcase; the mint lands, nothing opens, the line names the Library, muted, no Undo) —
RED ON OLD predicted (nothing said); `aNoteMadeWhereSheStandsOpensAndSaysNothing` — a GUARD, green on both predicted;
`theWordsNameTheRoomAndOnlyMadeThingsSpeak` (the pure copy; tip only). All PENDING the GO.


### Batch 1b — the VM-277 proposal (stop-and-propose; WAITING on the architect's ruling — nothing below is built)

Her ruling (2026-11-24, verbatim in the ticket): "refusals should be dismissable and they should be much shorter. maybe
you even have to click on it for the reason (or it's clear that you could swipe upwards for the reason on it)". The
fences this proposal keeps: the refusal tables stay THE words (no fork, no string matching on sentences); the seam's
kinds and slot rule untouched; the Mac's toasts untouched (hers to say later); `PhoneControls`/`PhoneType`/
`PhoneMetrics` only; every target 44 × 44; the 13 pt floor. **Two forks below need a seam-side line (an Item fact, a
clock hold); each states its case — the architect rules whether it may land.**

**What the phone's line says today, by source** (the inventory the mechanism must cover): the shared table
`OpsRefusalCopy` (≈ 67 operation-error rows; most one line, a handful two — the purge row, the chosen-take row);
`CrossBlockRefusal` (already TWO parts: `causeClause` + `roadClause` — the join refusal of her recording is
"This keystroke can't join these two blocks." + "Merge the blocks deliberately instead (··· → Merge with Previous),
which brings every take along."); `SealedNoteCopy` (two parts: state + verb); `DeletionRefusal`; and model-local
sentences (the copy door's "This note has no text to copy.", the keystroke fence's "Another structural change is still
landing.", the lens and history copy, the plain fallback "That couldn't be done."). Most fit one line at 15 pt on a
393-pt phone; the long ones are a known few.

**(a) The short form — how a refusal gets a headline without forking the one brain.**
- **(a1) RECOMMENDED — headline and reason from the ONE composer.** A composer answers a two-part value
  (`RefusalWords(headline:sentence:)`) from the SAME switch arm that answers its sentence today, so a row's two halves
  can never drift; the sentence stays the row's existing literal, byte for byte, and is what the Mac keeps reading
  (`sentence(for:)` = `.sentence`). Where a composer already builds from parts, the headline IS its first part — no new
  words: `CrossBlockRefusal.causeClause` ("This keystroke can't join these two blocks."), `SealedNoteCopy`'s state
  clause. Rows longer than one line get a DRAFT headline (her wording pass — e.g. the purge row "Only the Trash deletes
  for good."); a row with no headline draws as (a3) below. The phone's door hands the pair; the seam carries the full
  sentence as `text` (every reader unchanged — VoiceOver, pins, `spoken`) plus ONE defaulted Item fact, `headline`,
  which only the phone's face reads (VM-265's `isDirection` precedent). *Why first:* the one-brain law holds literally
  (the headline lives in its sentence's own arm), nothing is matched on words, the Mac is byte-identical, and the
  cost is bounded to the long rows. *Seam case:* the face can draw only what the item carries; deriving a headline from
  the sentence would be string matching. A pin walks the composers: every row whose sentence exceeds one line at the
  default size has a headline that fits one.
- **(a2) The door names its act as the headline; the table's sentence is the reason** ("Can't join these blocks." /
  "Can't delete this take."). No table change; but ≈ 80 phone refusal sites each gain an act line — a second vocabulary
  beside the table, the drift class the table exists to end.
- **(a3) The same sentence, clamped to ONE line ("…"), the whole behind the tap.** No table change, no seam fact, no
  copy — but the cut falls wherever the width says ("This keystroke can't join these two blo…"), which reads broken
  rather than short, and less fits at larger text sizes. **Kept as (a1)'s per-row fallback**, so she gets one line
  everywhere on day one while headlines land row by row.

**(b) The dismissal gesture** (joins the fade — P-55-3's refusal arm superseded).
- **(b1) RECOMMENDED — a ✕ at the line's trailing end plus a flick DOWN on the line.** The ✕ is the signpost (she
  never has to discover a gesture; VoiceOver and Switch Control reach it): `xmark` on `PhoneIconButtonStyle`, the
  muted, a 44 × 44 target. The flick down — toward the bar or keyboard the line sits on — is the fast road and the
  natural opposite of (c)'s "up for more".
- (b2) The ✕ alone — simplest, one more drawn door, no gesture.
- (b3) A sideways swipe — rejected: the band pages sideways just above the bar, and the two would read alike.

**(c) The reason on demand — the gesture and its signpost.**
- **(c1) RECOMMENDED — a TAP anywhere on the line opens the reason; the signpost is a disclosure "›" right after the
  headline** (her first suggestion, "click on it for the reason"; the iOS disclosure idiom — "more behind this" — at no
  fixed width, so the headline keeps its room). The line's whole frame then takes a touch while a refusal with a reason
  shows (today only its door does — the passthrough rule widens for that line alone; the rows beneath it are covered for
  its life, 44 pt, and it is dismissable). VoiceOver: the element's label is the headline, its hint "Double-tap for the
  reason", custom actions Why and Dismiss; the arrival announcement reads the FULL sentence, so a VoiceOver reader is
  never made to take the extra step.
- (c2) A pull UP on the line, signposted by a small grabber capsule on its top edge (the system sheet's grabber — "it's
  clear that you could swipe upwards", her parenthesis), with the tap as its accessible twin. Pairs symmetrically with
  (b1)'s flick down; costs a drawn grabber and a gesture to learn.
- (c3) Both (c1) and (c2): the tap, and the pull up for those who try it — no grabber drawn.

**(d) What the opened reason looks like, and how it closes.**
- **(d1) RECOMMENDED — the line grows upward in place into a card**: the headline (semibold) on top, the full sentence
  under it in the line's own 15 pt words (wrapping, scrolling past a cap of about a third of the screen), the ✕ staying
  top-right. **While open, the fade's clock holds** (she is reading); it closes on the ✕, a flick down, a tap on the
  headline, leaving the note (VM-275 — `leaveNote` clears it), or a newer message replacing it. *Seam case:* the clock
  lives in the seam (`StatusCenter.place`'s one dismiss task), so holding it is one seam door — `hold(_ id:)`, cancelling
  the item's clock while it is `current`; no kind or slot change, the Mac never calls it (added to the VM-61 scan's
  forbidden words). The face-only alternative — the face keeps drawing an opened item after the seam's clock clears it —
  splits "what is on screen" from `status.spoken` and cannot tell a fade from VM-275's clear, so it is not recommended.
- (d2) A system sheet at a medium detent (headline as title, the sentence as body) — heavy, and the line's window never
  becomes key, so the sheet would have to present from the main window (a feature-to-shell route for a one-line read).
- (d3) A callout balloon above the line — (d1) drawn differently; no gain.

**(e) The line's shape — VM-275 half 2's cure, carried here because it is the same face.**
- **(e1) RECOMMENDED — a floating card clear of the bar** (the Mac toast's own idiom, in phone tokens): inset `s8` from
  the screen's sides and `s8` above the bar or keyboard, the room's ground under a hairline stroke all round, corner
  `PhoneMetrics.Radius.standard` (so batch 2's squarer step reaches it centrally), the words still aligned at the 20 pt
  gutter (8 outside + 12 inside). It reads as something passing over the list, never as the bar grown; with (a)'s one
  line it covers 44 pt of the list, not ~100. No shadow (a literal colour; the phone's scans forbid one).
- (e2) Keep today's full-width band flush on the bar — (a) alone shrinks it to one line, but it still reads as the bar's
  own chrome.

**Scope calls inside the proposal (for the ruling):** the new anatomy applies to REFUSALS; a DIRECTION gets (b)'s
dismissal and (e)'s shape but keeps its whole sentence (it is information, not a complaint — PROVISIONAL); removals
(words + Undo) and offers keep today's anatomy and fade, in (e)'s shape. Canon at the merge (unchanged from the plan):
SurfaceContracts' phone-line bullet and the QUESTIONS #277 addendum (P-55-3's refusal arm superseded), this run the
pointer.

**If ruled as recommended, the build is:** the `RefusalWords` value in `Shared/` and the composers' second column
(CrossBlockRefusal and SealedNoteCopy free, the long `OpsRefusalCopy`/`DeletionRefusal` rows DRAFT); the Item fact and
`hold(_:)` (one seam commit ahead of the code, its case recorded); the face (headline + "›" + ✕, the card, the
expanded reason, the widened touch rule); the pins (the composers' headline walk, the face's geometry — one 44 pt line,
each door 44 × 44, the card clear of the bar and sides — the touch rule, the clock hold, VM-275's clear of an opened
reason); captures of a refusal (the line, the reason opened, dismissed), a direction and a receipt, both voices.


### VM-277 — as built (ruled A-260-4; PROVISIONAL (e) and every DRAFT word for her pass)

**(a) The short form, from one arm.** `Shared/RefusalWords.swift` — a sentence and an optional headline.
`OpsRefusalCopy.refusal(for:roads:)` is the table's one switch, each arm answering `RefusalWords`; `words(for:roads:)`
forwards `.sentence`, so the Mac, the MCP door and every String reader read byte-identical sentences. 27 DRAFT
headlines sit on the long rows, in their own arms. Every row is one clause of at most 36 characters, pinned by a source walk. **The headline list
for the closeout's Wording bundle is exactly those 27 `headline:` literals in `Shared/OpsRefusalTable.swift`, plus the
rows still unauthored (they clip).** `OpsRefusalCopy.refusalWords(for:roads:)` is the phone's never-a-dump road as a pair.
The seam: `refuse(headline:sentence:)` → `Item.refusalHeadline`, read by the phone's face alone (`text` stays the whole
sentence for VoiceOver, pins and `spoken`). The phone: `MobileLine.refuse(_ words:)`. **Wired:** ten models' refusal
slots (`MobileBookViewModel`, `MobileLibraryViewModel`, `MobileCreateBook`, `MobileScraps`, `MobileTagManager`,
`MobileBookDetails`, `MobileShelfViewModel` — `lastError`; `MobileReferences`, `MobileNoteTags`, `MobileBlockList` —
`status`) keep their String slot as a computed read of a stored pair (`lastRefusal`/`statusRefusal`), so every pin that
reads them is unchanged, and their 30 table assignments hand the pair; `MobileMembership` and `MobileLenses` speak it
through a `refuse(_:)` twin of their own `say`.
- **NOT wired — fenced, with its owner:** the editor's own files speak table and cross-block sentences as plain strings
  (`MobileEditorViewModel` — 9 table sites and the gate's cross-block route, her recording's join refusal among them;
  `MobileStructural` — 2; `MobileComments` and `MobileTakesController` speak through the editor model's `report`). The
  brief fences the text-input path and the editor seam, so they draw through the ruled clip: one line, "›", the whole
  sentence on the tap, the ✕. Wiring each is one expression at its call. For the join refusal: a pair composed from
  `CrossBlockRefusal`'s cause and road, whose nine causes need short forms. **Owner: the editor-seam work under a Fable
  review (VM-271's core), or an orchestrator exception at the merge.** For the ticket list at closeout.
- The Settings sheet's own notes (`tutorialNote`, `perfNote`) are in-sheet text, not the line — untouched.

**(b) Dismissal.** A 44 × 44 ✕ (`xmark`, `PhoneIconButtonStyle`, the muted; spoken "Dismiss") plus a flick down
(`MobileMessageLineModel.dismisses` — 24 pt of travel or a 64 pt throw; never up), on refusals and directions. P-55-3's
refusal arm superseded (canon at the merge). Removals and offers keep their door and their fade.

**(c) The reason on demand.** The whole one-line refusal is a button: its headline (or its sentence clipped with "…"),
then "›" (`U+203A`, the muted); spoken as the headline, hint "Double-tap for the reason." (DRAFT), a Dismiss custom
action. The arrival announcement reads the WHOLE sentence.

**(d) The reason card.** The tap opens the card upward: the headline (semibold, the refusal's ink) over the whole
sentence (her ink), or the sentence alone where unauthored; the ✕ top-right. The tap calls `holdForReading(id)`, so the
seam's clock stops for that item. It closes on the ✕, a flick down, leaving the note (`MobileLine.leaveNote` → `clear()`),
or a newer message (the face drops an open reason whose line is no longer the one showing). The reason wraps to at most
eight lines (the table's longest is about four); no scroll was built (recorded against the proposal's "scrolling past a
cap").

**(e) The card — PROVISIONAL** (VM-275 half 2's cure). Every line floats `cardMargin` (8) clear of the screen's sides
and of what it stands on — the bar, the keyboard, the home indicator. It is the room's ground with a hairline all
round, corner `PhoneMetrics.Radius.standard` (batch 2's squarer step reaches it centrally), the words still at the 20 pt
gutter (8 + 12). No shadow (a literal colour). A dismissable line's whole card takes a touch (the tap, the ✕, the
flick); any other line only its door (`takesTouch(at:doorFrame:lineFrame:showing:)`).

**Pins.** Red-on-old tree `c8bfa668f` (`MobileRefusalLineTests`): `aLongRefusalTakesOneLine`,
`aRefusalCarriesItsDismissDoorAcrossFortyFour`, `aTapOpensTheReasonAndItStaysWhileSheReads`,
`theLineIsACardClearOfTheBarAndTheSides` (both voices), `aDirectionIsDismissableAndReadsWhole` — RED ON OLD predicted;
`aRemovalAndAnOfferKeepTheirDoorsAndNoDismiss` — a GUARD, green on both. The fix's own (tip only):
`aHeadlineIsTheLineAndItsSentenceTheReason`, `theTableAnswersBothHalvesFromOneArm`,
`everyAuthoredHeadlineIsOneShortClause`, `theAnatomyIsTheItemsFacts`, `theFlickDownDismissesAndANudgeDoesNot`,
`theWholeCardTakesATouchOnlyForALineSheCanDismiss`; the seam's `MobileRefusalSeamTests` (3); the Mac's
`VM61MacStatusSeamPinTests` scan now forbids `refusalHeadline`, `refuse(headline:` and `holdForReading`. One pin MOVED
with (e): `MobileMessageLineFaceTests.theLinesActAnswersAcrossFortyFourOnAFortyFourLine` (the foot less `cardMargin`).
The reason-hold pin runs a 250 ms clock read at 600 ms on the red-on-old tree (it fails at the missing door before any
timing) and 500 ms read at 1.2 s at the tip (margin under load). All PENDING the window.

**Canon owed at the merge** (the merging session's, two-file shape): SurfaceContracts' phone-line bullet — a refusal's
one short line with its reason behind a tap, the ✕ and the flick, the card clear of the bar and sides, a direction's
muted ink and ✕, a refusal raised in a note clearing as she leaves it. Plus the QUESTIONS #277 addendum: P-55-3's
refusal arm superseded, P-55-19 → (b) built, C-275-1, A-260-1's line, P-260-1a. This run is the pointer.


### Batch 1b — RECONCILE (the consolidated window's two harness findings; implementer: Opus, the 1b session resumed, 2026-11-25)

The window (its section above) ran this batch's legs: R1's 13 reds all present, R2 exactly as predicted, A-260-5's
hollow CONFIRMED by `theListNeverMovesWhileTheLineShows`, and the LIVE line walk green at every stop that was reached
(the card, the reason held past 6.5 s, both dismissals, leaving with its note, the removal's Undo, the card above the
keyboard). TWO of this batch's pins had broken HARNESS roads; the product was right. Both are reconciled here. No test
has run on the reconciled tree — the re-evidence rides the next window.

**Finding 1 — the leave-the-note step (`MobileRefusalLeavesItsNoteTests.swift:110`, `:115`).** The step pressed the
system Back by `accessibilityActivate()` on its bar button, a road the mounted harness never delivered, on EITHER tree.
So `aRefusalRaisedInANoteClearsWhenSheLeavesIt`, `aLineSaidBeforeTheNoteOpenedOutlivesItsLeaving` and
`aRemovalSaidInTheNoteOutlivesItsLeaving` never reached their own assertion anywhere. **Said plainly: none of them has
ever been green, and the first's red in R1 was the harness's, not her defect's — so VM-275 half 1's red-on-old is NOT
yet established.** Fix (`39e608327`): the step takes the Back's own act. The note's stack — the one navigation
controller holding a pushed screen (`stackHoldingAPushedScreen(under:)`) — pops its top screen, exactly what the
system Back performs, and the note's leaving road (`onDisappear`) runs as it does for her. The pins' meaning is
unchanged: she leaves the note by Back. Their first green is the next window's, and their first ever.

**Finding 2 — `theLineIsACardClearOfTheBarAndTheSides` read a nil frame on the tip.** The probe did not miss the card,
and the keyboard floor is not involved: this pin hosts the line's face in a window of its own, not the shell. The pin
reset its own reading. It drew a refusal and then, in ONE turn, cleared the line, set `lineFrame` to nil and said a
removal. SwiftUI saw a single card whose content changed while its frame did not (both 44 tall in the same place), so
the frame probe (`onGeometryChange`) had no change to report and the nil stood. On the rol277 tree the same nil
followed iteration 1's real reds, which were the predicted kind. Fix (`d3356f04e`): each class — a refusal, a removal,
in each voice — stands in its own fresh window and model, so the card's FIRST geometry is what is read (the road
`aLongRefusalTakesOneLine` reads, green on the tip in the window). The law is unchanged.

**The bundles** (incremental, `nice -n 15`, all `TEST BUILD SUCCEEDED` on code tip `d3356f04e`):
- the `vm260-2r` trio rebuilt IN PLACE on the new tip (it already carried batches 2 and 3): phone
  `DerivedData/vm260-2r`, Mac `DerivedData/vm260-2r-mac`, UI `DerivedData/vm260-2r-ui`;
- **the corrected old tree for VM-275 half 1 — DONE:** `ea3f95831` with ONLY the reconciled Back
  step dropped into its pin file → `DerivedData/vm260-1b-rol-r` (an APFS clone of `vm260-1b-rol`). Built by checking
  out `ea3f95831` in this worktree, writing that one file, building, then `git checkout vm-260-phone-look`. Everything
  is committed before the checkout, so the branch restores clean. `TEST BUILD SUCCEEDED`; the worktree was restored to
  `vm-260-phone-look` at `e4b512df0` and verified clean. (The variant differs from `ea3f95831`'s file by the Back step
  alone — the helper and its three `try` calls; checked by diff before the build.)

**Predicted at the next window:**
- **R1r — red on old, VM-275 half 1, for the real reason** (`vm260-1b-rol-r`):
  `-only-testing:VariorumMobileTests/MobileRefusalLeavesItsNoteTests`.
  - RED: `aRefusalRaisedInANoteClearsWhenSheLeavesIt`, at its OWN assertion ("the refusal raised in the note left with
    the note — still showing: This note has no text to copy.").
  - GREEN: `aLineSaidBeforeTheNoteOpenedOutlivesItsLeaving`, `aRemovalSaidInTheNoteOutlivesItsLeaving`,
    `theListNeverMovesWhileTheLineShows`.
  - A red at "the note's stack" or "the note left" is a harness red again: STOP and report.
- **On the tip** (`vm260-2r`, or the whole phone target, which holds them):
  `-only-testing:VariorumMobileTests/MobileRefusalLeavesItsNoteTests -only-testing:VariorumMobileTests/MobileRefusalLineTests`
  — ALL GREEN predicted: the five leave/list pins and the twelve line pins, the card pin over both classes × both
  voices.

### Batch 1b — READY-FOR-TESTS (the FULL batch, both tranches — ONE window runs everything, A-260-7)

All from `App/Variorum/`, zsh, `test-without-building` against the bundles already built (nothing builds in the window);
`UDID` = the device the GO names (iOS 26.2), booted fresh inside the claim, settled, shut down before release. Phone plan:
`DerivedData/<folder>/Build/Products/VariorumMobile_VariorumMobile_iphonesimulator27.1-arm64-x86_64.xctestrun`,
`-destination "platform=iOS Simulator,id=$UDID"`.

**R1 — red on old, tranche 1** (`vm260-1b-rol`, tree `ea3f95831`):
`-only-testing:VariorumMobileTests/MobileLineDirectionTests -only-testing:VariorumMobileTests/MobileNoteClipboardTests
-only-testing:VariorumMobileTests/MobileRefusalLeavesItsNoteTests -only-testing:VariorumMobileTests/MobilePushLandingDirectionTests`
- Predicted RED (13): VM-265 — `MobileLineDirectionTests`: `aDirectionReadsMutedAndARefusalKeepsTheAlarm`,
  `theTodayDoorsUnfiledEntryReadsMuted`, `theTrashsArchivedTakeSpeaksAndItsFanTwinDoesNot`,
  `theTraysArchivedTakeSpeaksAndItsFanTwinDoesNot`, `theBlockHistorysArchivedTakeSpeaksAndItsFanTwinDoesNot`,
  `aLensPickThatComesBackArchivedSpeaksAndItsFanTwinDoesNot`, `aBlockPutBackAtTheEndOfItsNoteSpeaks`,
  `aBlockPutBackWithItsNoteGoneSpeaks`, `theTraysEndLandingsSpeakAndItsBesideLandingDoesNot`,
  `aCollectByTaggingSpeaksAndJoiningABookDoesNot` (each on its ink line alone); `MobileNoteClipboardTests.
  aCalloutNoteKeepsTheStoredRoadEvenWhilePeeking` (its ink line). VM-275 — `aRefusalRaisedInANoteClearsWhenSheLeavesIt`.
  A-260-1 — `aNoteMadeAfterSheLeftThePageSaysWhereItLanded`.
- Predicted GREEN: `theDirectionsAreTheLandingsThatAreNotItsPlace`; every other `MobileNoteClipboardTests` test; the
  guards `aLineSaidBeforeTheNoteOpenedOutlivesItsLeaving`, `aRemovalSaidInTheNoteOutlivesItsLeaving`,
  `aNoteMadeWhereSheStandsOpensAndSaysNothing`; and **`theListNeverMovesWhileTheLineShows` — green here confirms
  A-260-5 (VM-275 half 2 hollow)**. A red there means the trace is wrong: STOP and report.

**R2 — red on old, VM-277** (`vm260-1b-rol277`, tree `c8bfa668f`): `-only-testing:VariorumMobileTests/MobileRefusalLineTests`
- Predicted RED (5): `aLongRefusalTakesOneLine`, `aRefusalCarriesItsDismissDoorAcrossFortyFour`,
  `aTapOpensTheReasonAndItStaysWhileSheReads`, `theLineIsACardClearOfTheBarAndTheSides`, `aDirectionIsDismissableAndReadsWhole`.
- Predicted GREEN (1): `aRemovalAndAnOfferKeepTheirDoorsAndNoDismiss` (a guard).

**P — the tip, the whole phone target, one launch** (`vm260-1b`, tip `ca9a8d7be`): `-only-testing:VariorumMobileTests`
— read against main's known reds (batch 1a's run: 6 known issues, all pre-existing — `MobileFilterRowGeometryTests`' two
Display-Zoom pins × 2, `MobileTrashTests`' empty-tree diagnostic × 2). It holds every new and moved pin above
(`MobileRefusalLineTests` 12, `MobileRefusalSeamTests` 3, `MobileRefusalLeavesItsNoteTests` 5,
`MobilePushLandingDirectionTests` 3, `MobileLineDirectionTests` 13) and every suite that mounts the shell, a note or the
line, plus the ten rewired models' suites.

**M — the Mac legs** (`DerivedData/vm260-1b-mac/Build/Products/Variorum_Variorum_macosx27.0-arm64.xctestrun`,
`-destination 'platform=macOS'`): `-only-testing:VariorumTests/<type>` for:
- the seam — VM61MacStatusSeamPinTests StatusCenterTests StatusSeamVocabularyTests StatusToastPlacementRuleTests
  StatusToastPlacementShellTests WordsBandSurfaceTests;
- the refusal table, whose arms now answer pairs (the sentences must read byte-identical) — OpsRefusalTableIntegrityTests
  RefusalTableConvergenceTests VM62MacRefusalWordsPinTests MCPWireRefusalSweepTests;
- batch 1a's nine — ThemeTokenTests NoLiteralColourTests PaletteDerivationTests BadgeFamilySplitTests
  DataSafetySearchIndexTests OneInputPathTests OneRefreshAuthorityCompositionTests DeadVocabularyTests
  IndexTierMetricsTests (the token pins and every Mac suite that walks the phone tree).

Expected green, except `IndexTierMetricsTests`' 4 declared known issues.

**U — not owed:** the keyboard-reveal UI test's trigger is the Write screen's LAYOUT. This batch's `MobileWriteView.swift`
edit is two calls on the note screen's appear/disappear. The line is its own window, so its card above the keyboard
moves no page. Batch 2 runs it.

**W — the walk of the whole line** (A-260-7; the Debug phone app built from the tip on the same simulator, under the same
claim or its own; captures to `notes/plans/vm-260-screens/batch-1b/`; Study and Terminal, light; stop list):
1. A refusal in a note: an empty note's Copy (copy icon) → the one-line card, "›" and ✕ — capture.
2. A tap on it: the reason card, the whole sentence — capture. Wait past six seconds — still there.
3. The ✕ closes it. Raise it again, then flick it down — gone.
4. A refusal raised in a note, then Back: the Library with no line (VM-275) — capture.
5. A direction, muted, with its ✕ — the Trash's Put back of an archived take, or A-260-1's line (Library ▸ New Note,
   then Bookcase at once) — capture.
6. A removal's line with Undo (delete a note from its ⋯ — "Note moved to the Trash." with Undo), the card clear of the
   bar — capture.
7. With the keyboard up in a note, a refusal's card sits above the keyboard — capture.



## BATCH 2 — record (VM-273 · VM-272; implementer: Opus, 2026-11-25)

**What this batch did NOT do (kept current):** NO suite has run — the stage is coordinated above this session (the quiet
window), so every test claim below is PENDING its window; no capture is taken (the window's stops are listed at the
READY block); no line in `Sources/`, `Sync/`, custody, `MobileEditorTextView`, the text-input path or the keyboard bar
(`MobileKeyboardBar` keeps its own ruled numbers, R22/R25); `VoiceTokens.swift` untouched; `Shared/StatusCenter.swift`
untouched; her words' sizes untouched except the note title (VM-272's — flagged for batch 3 below); the segmented
choice's drawing untouched (a remainder, below); no masthead rebuild (VM-148's).

### LIVE STATUS

| Piece | State |
|---|---|
| 0. Preflight (CLAUDE.md + canon; this record's binding sections, R-260-2, S-260-2/-3, the adjudications, batches 1a and 1b; the resiliency protocol; SurfaceContracts "The app" in full and the Library's phone bullet; the VM-47 FOR A LATER READER and §5's P-47-1, P-47-12, P-47-21; the sizing sheet; LK-5 in the VM-44 rulings) | DONE (this commit) |
| 1. The pins on the pre-fix tree — VM-273's drawn sizes, radii and chrome roles; VM-272's note top | DONE (`cdc471fd2`, compile fix — two local helpers main-actor — in the next commit: **that commit IS the red-on-old tree**; two new files, only symbols both trees declare) |
| 2. The red-on-old tree built headless (`DerivedData/vm260-2-rol`, an APFS clone of `vm260-1b`, incremental, `nice -n 15`) | DONE — `TEST BUILD SUCCEEDED` on the compile-fix commit's tree |
| 3. VM-273 — the central step-down (`PhoneType` chrome roles and the note title's role, `PhoneControls` glyph · chip · box, `PhoneMetrics` radii, the bar's chip corner) + its consequence (`MobileBookDetails`' designated row off the faint) + the pins it moved | DONE (this commit) — phone `build-for-testing` green on it (`DerivedData/vm260-2`, incremental, `nice -n 15`); the suites PENDING |
| 4. VM-272 — the note's top (`MobileWriteView`'s chrome only: the rows' gaps and air, the chips' 44 × 44 floor; the title's role and the tools' glyph come through piece 3) | DONE (this commit) — compiled in piece 3's bundle (`vm260-2`); zero lines in `MobileEditorTextView` or the text-input path; the suites PENDING |
| 5. Pins MOVED with the rulings | DONE (`b4611e748`, with piece 3) — listed below |
| 6. Tip bundles (`vm260-2`, `vm260-2-mac`, `vm260-2-ui`) and READY-FOR-TESTS | DONE (this commit) — all three `TEST BUILD SUCCEEDED` on code tip `ae12e4276` (APFS clones of `vm260-2-rol`, `vm260-1b-mac`, `vm260-1a-ui`; incremental; `nice -n 15`); the run list below. (Machinery note: the "Calls made" block below was on disk uncommitted when the orchestrator committed the record, so it rode `935bb5aa2` — content as written.) |
| 7. The window — red-on-old, the whole phone target, the Mac legs, the keyboard-reveal UI test, the captures | PENDING (the GO) |

### The traced mechanism — "ridiculously oversized icons", "the top part is so huge it takes up half of the area"

The targets were never what she saw: `phoneHitArea` and the 44-pt frames are invisible. What she saw is that wave 1
drew most controls at or near the size of their targets (the sizing sheet's §B/§E, built as drawn, P-47-1):
- **the icon button** drew a 22-pt glyph in ink inside its 44 (`PhoneControlMetrics.iconGlyph`) — on the note's top the
  four tools went from pre-wave-1's 11.5-pt faint glyphs to 22-pt ink ones, about twice the size (P-47-12 built (a));
- **the chip** drew a 32-pt capsule inside its 44; **the calm button and the field** drew their box at the full 44 —
  the target and the drawing the same size; the **segmented choice** is the system's track stretched to 44;
- **chrome words** went from 11.5 to 17 (`control`) and 15 (`chip`, `controlInline`), the same sizes as her own words
  (17 body, 15 previews), so nothing on a screen reads as quieter than her writing;
- **corners**: 12 on every box and capsules on every chip, where the Mac's chips are 4 ("very subtle and square",
  `QuietFill.corner`) and its toast, cards and fields 8;
- **the note's top** (`MobileWriteScreen.masthead`) stacks three rows of 44-pt targets — the title with its four tools,
  the membership line, the chip flow — and puts 26 pt of padding on top of them (10 above, 4 + 4 between, 8 below)
  under a 24-pt title: **158 pt at one chip row** (202 when the chips wrap), against pre-wave-1's ≈ 82 (a 21-pt title,
  11.5-pt glyphs and chips on 14-pt lines). Under the system bar's back button, with the keyboard up, that is her
  "about half".
- And one real defect under it: the note-top chips are 44 TALL only (`mastheadChipHitArea` pads 6 each side), so in
  Study "tags" (≈ 43 wide at 15 pt) and "lens" (≈ 41) already answer under 44 across — and a step-down alone would take
  them to ≈ 40 and ≈ 38. The fix gives every chip a 44 × 44 floor.

### The step-down as built — P-260-2a, PROVISIONAL as a set (the P-47-1 pattern; she judges the whole)

The principle: **chrome sits one notch under her words** (17 body → 15 controls; 15 previews → 13 chips and inline
acts), on the same five-size scale, the 13-pt floor holding; **drawings sit inside their targets** (a box 36 in a 44,
a glyph 17 in a 44, a chip 24 in a 44); **corners are the Mac's two** (4 for chips, 8 for boxes). Every target is
exactly what it was.

**Type — the chrome roles (`Shared/Theme/PhoneType.swift`; Study and Terminal alike, chrome is never "two under"):**

| Role | Old (size / pitch, anchor) | New | What reads it |
|---|---|---|---|
| `control` | 17 / 22, `.body` | **15 / 20, `.subheadline`** | text buttons (Done, Cancel), the calm button, menu-row labels, a field's typed text (P-47-14), standalone door words (+ New Book, Archived) |
| `controlInline` | 15 / 20, `.subheadline` | **13 / 18, `.footnote`** | inline acts (Put back, Edit, Undo), the one message line's words (P-47-8) |
| `chip` | 15 / 20 medium, `.subheadline` | **13 / 18 medium, `.footnote`** | chips, the note's facts on its top, the segmented choice's words |
| `tab` | 17 / 22 | 17 / 22 — **unchanged: LK-5 is her ruling** ("three words at 17 pt … 56 pt targets") | the bottom bar |
| `meta`, `sectionHeader` | 13 / 18 | 13 / 18 — unchanged (the floor) | stamps, counts, paths, section heads |
| `noteTitle` (VM-272) | Study 24 / 30 `.title2`; Terminal 22 / 28 | **Study 20 / 25 `.title3`; Terminal 18 / 23** (pre-wave-1: 21 and 19) | the note's title on its top — the role's only reader |
| her other words (`noteBody`, `screenTitle`, `rowTitle`, `rowPreview`, `mono`) | — | unchanged — batch 3's (R-260-2) | — |

**Glyphs and shapes (`Shared/Theme/PhoneControls.swift`):**

| Control | Old drawing | New drawing | Target (unchanged) |
|---|---|---|---|
| Icon button (the note's tools, trash, New Note, the gear, the line's ✕) | 22-pt glyph | **17-pt glyph** (P-47-12's road (b)); chrome scaling kept (follows `.body` to xxxLarge, holds) | 44 × 44 |
| Menu row's glyph | 22 pt, a 22-pt column | **17 pt**, a 17-pt column | the row's 44 / 52 / 64 |
| Chip (Today, the Trash's kinds) | 32-pt capsule, 12 each side, 15 medium | **24 tall, corner 4, 8 each side, 13 medium** | 44 × 44 |
| Calm button | its box 44 tall, corner 12, 17 | **box 36 (grows with its words), corner 8, 15** — the box sits inside the target | at least 64 × 44 |
| Field | its box 44 tall, corner 12, typed 17 | **box 36 (grows with its text), corner 8, typed 15**, inside a 44 frame | the frame 44 (the text field's own answering region is untouched) |
| The bar's chip | corner 12 | **corner 4** (the Bookcase strip's near-square chip, S-260-3); its padding, words (17) and cells (56) unchanged | 56-pt cells |
| The line's card (batch 1b) | corner 12 | corner 8, by construction (`Radius.standard`) | unchanged |

**Radii (`Shared/Theme/PhoneMetrics.swift`) — the Mac's own two:**

| Radius | Old | New | The Mac's source | Wears it |
|---|---|---|---|---|
| `small` | 6 | **4** | `QuietFill.corner` (her "very subtle and square") | chips, the bar's chip, small marks |
| `standard` | 12 | **8** | `StatusToast` 8, its cards and fields 8 (its calm button 7) | fields, the calm button, cards, the line's card |
| capsule | the chip | **none** — no capsule is left in the controls | — | — |

**Unchanged on purpose:** every target (the 44 × 44 floor, the text button's 64 wide, the bar's 56, the menu rows'
44 / 52 / 64, the sheet header's 56, the Library rows' 88); the spacing scale and the 20-pt gutter; the inks; her words.

**Remainders, recorded:** (1) the **segmented choice** keeps the system's track at its 44-pt height and the system's
corner — shrinking the drawing needs a UIKit hit-area container around a system control, and squaring the track is a
hand-built control (P-47-30's fence, hers); its words step down with `chip`. Not on her three capture stops (Settings,
Create Book, the block list). (2) Hand-built radii outside the central files (the quick-entry box 8, the Read page 12,
Protection's cards 10, the overlays' sheets 22, the take cards 10) are left as they stand — moving them is per-site,
not this pass.

### VM-272 — the note's top as built (P-47-12's road (b); `MobileWriteView` chrome only)

- **The title** reads `noteTitle` at its new 20 (Terminal 18).
- **The four tools** are the icon button — 17-pt glyphs in their ink (copy, find, ⋯ in ink; the seal in ink, the
  accent when sealed) with only the 44 × 44 frame, centres 44 apart (road (b), the central style).
- **The chips** read `chip` at 13; each chip's hit area is now at least **44 × 44** (it was 44 tall only).
- **The rows sit on one another**: the gaps 4 → 0, the air above 10 → 0 (the title row's own 44 carries its air, the
  system bar sits above), below 8 → 4. **158 → 136 pt at one chip row** (202 → 180 wrapped) — as MEASURED, 167 → 136:
  the reconcile (R2, below) found `safeAreaInset`'s default 8 and a baseline point on both trees, and took them out.
- **What is left is the targets themselves** — three rows of 44. More room is VM-148's road (the mockup P-47-20
  describes: the tools in the top row beside the back button, the chips in one sideways row) — not built here.
- **For batch 3 (R-260-2):** the note title already stepped 24 → 20 here; its one-notch default drop should read
  today's set as including that.

### Pins (all PENDING the window)

**VM-273 — `VariorumMobileTests/MobileDrawnStepDownTests.swift`** (three suites):
- `MobileDrawnStepDownTableTests.theChromeSitsOneNotchUnderHerWords` — the table above: `control` 15 / 20
  `.subheadline`, `controlInline` 13 / 18 `.footnote`, `chip` 13 / 18 medium `.footnote`, `tab` 17 (LK-5), `meta` and
  `sectionHeader` 13, `noteTitle` 20 / 25 `.title3` (Terminal 18 / 23), her other words unchanged, chrome never "two
  under" in Terminal. **RED ON OLD predicted** (control 17, controlInline 15, chip 15, noteTitle 24 / 22).
- `…theNewThirteensNeverDipUnderTheFloor` — `chip` and `controlInline` at xSmall … Large, SwiftUI and UIKit forms,
  both voices, ≥ 13. A GUARD (green on both: the floor already held 15 pt roles there).
- `…theCornersAreTheMacsTwo` — `Radius.small` 4, `Radius.standard` 8, the bar's chip on `Radius.small`. **RED ON OLD
  predicted** (6, 12; the bar's chip on 12).
- `MobileDrawnStepDownRenderedTests.theDrawingsSitWellInsideTheirTargets(voice:)` — Study and Terminal light, read as
  pixels off a real scene window (`MobileRenderedPixels`): the icon button's glyph draws within 1 pt of a bare 17-pt
  symbol's ink box; the chip's shape ≤ 26 tall and its corner pixel (2.5, 2.5) filled — near-square, where a capsule
  leaves it bare; the calm button's box and the field's box ≤ 38.5 tall; each in its target (44 × 44; 64 × 44; the
  field's frame 44). **RED ON OLD predicted** (the 22-pt glyph; the 32-pt capsule and its bare corner; the 44-pt
  boxes). Prints `PERF[sim] VM-273 drawn …` with every measured box for the record.
- `MobileDrawnStepDownTargetTests.everyControlAnswersAcrossItsWholeTarget(voice:size:)` — **THE REVIEW FOCUS, a GUARD**
  (green on both): the sheet header's Done, a text button, the calm button ≥ 64 × 44; an inline act, an icon button, a
  fact chip and a filter chip ≥ 44 × 44; a menu row with a glyph ≥ 52 across its width — both voices, at Large and at
  xSmall.

**VM-272 — `VariorumMobileTests/MobileNoteTopTests.swift`** (the app's `MobileWriteScreen` with the model it drove,
402 × 874, both voices):
- `theNoteTopGivesTheScreenBackToWriting(voice:)` — the chrome between the safe area's top and the text view's top is
  ≤ 140 (three 44-pt rows + 8) and ≥ 131.5 (the three rows stay). **RED ON OLD predicted** (≈ 158). Prints
  `PERF[sim] VM-272 note top …`.
- `everyDoorOnTheNoteTopAnswersAcrossFortyFour(voice:)` — the title (Rename Note), the four tools, the membership
  line and the five chips, each ≥ 44 × 44. **RED ON OLD predicted in Study only** ("Tags" ≈ 43 and "Lenses" ≈ 41 wide —
  measured with the Mac's system fonts: "tags" 31, "lens" 29 at 15 medium, plus the 6 + 6 reach); green in Terminal
  (mono "tags" 38 + 12). Prints every door's size.
- `theToolsAreOneRowOfFortyFourSquareTargets(voice:)` — a GUARD (green on both): the four tools 44 × 44, one row,
  centres 44 apart, the last ending at the gutter.

### Pins MOVED with the rulings

Each moved because the ruled change moved what it holds (batch 1a's pattern); none loosened past its new number.
- `MobilePhoneLayerTests.theStudyTableIsTheSheetsAsDrawn` — `chip` and `controlInline` 13 / 18 `.footnote`, `control`
  15 / 20 `.subheadline`, `noteTitle` 20 / 25 `.title3` (the table IS the change).
- `MobilePhoneLayerTests.terminalIsTheSameRolesInMonoWithItsProseTwoUnder` — Terminal's note title 22 → 18 (still two
  under Study's).
- `MobilePhoneMetricsTests.theConstantsAreTheSheets` — the radii 6 / 12 → 4 / 8.
- `MobilePhoneControlsTests.theIconButtonIsAFortyFourSquareAroundATwentyTwoPointGlyph` → `…SeventeenPointGlyph` — the
  constant 17, the glyph's frame bounds 12–24 (were 16–30); the 44 × 44 and centres 44 apart unchanged.
- `MobilePhoneControlsTests.theChipIsAThirtyTwoCapsuleInAFortyFourHitArea` → `…TwentyFourNearSquareInAFortyFourHitArea`
  — 24 tall, 8 to each side (were 32, 12); the 44 × 44 unchanged.
- `MobilePhoneControlsTests.theInlineActAnswersAcrossFortyFourWithoutMovingItsWord` — the 13-pt word's drawn height
  12–24 (was 15–30 for 15 pt); the 44 × 44 unchanged.
- `MobilePhoneControlsTests.theFieldIsAtLeastFortyFourTallAndGrowsWithItsText` — comment only (15 → 21 at xxxLarge);
  its assertions derive from the role and still hold: the field's FRAME is ≥ 44 at every size.
- `MobileFaintOnDoorsSourceTests.fullSizeRoles` — the "17 pt or more" role set is READ FROM THE TABLE (it listed
  `control` when control was 17). With control at 15 the rule found one site: `MobileBookDetails`' designated "Use as
  Daily Journal" read in the faint — **C-273-1: it now reads in the corrected muted** (a 15-pt word needs 4.5:1; still
  apart from the live accent, the "daily ✓" beside it).

### Calls made in the batch (for the record and the merge's QUESTIONS; none gates the core)

- **P-260-2a — the step-down as a set** (the tables above): chrome one notch under her words; the drawings inside their
  targets (glyph 17, chip 24 near-square, boxes 36); the Mac's two corners (4, 8). Alternatives: (b) the glyphs and
  shapes alone, the chrome words at the sheet's 17 / 15 (smaller drawings, the same loud words); (c) two notches for
  the chrome (control 13 — then every chrome word sits at the floor, and a text button reads like a stamp).
- **P-260-2b — the note title at 20** (VM-272; Terminal 18): the scale's own step, equal by value to a sheet's title.
  Alternatives: 22 (Terminal 20 — off the five-size scale); leave 24 for batch 3's one-notch drop to take.
- **P-260-2c — the bar keeps LK-5's 17-pt words and its chip's padding**; only its corner moves (4). Her ruling holds
  the words; whether the chip itself should tighten is hers at the captures.
- **P-260-2d — the boxes draw 36** (field, calm button): the iOS search field's own height; the frame stays 44.
  Alternative: keep the boxes 44 (a field is a writing surface) with only the corner moving.
- **C-273-1 — the designated daily row reads in the corrected muted** (above).
- **C-272-1 — the masthead's air retires into its rows' 44s** (0 above, 0 between, 4 below). Alternative: keep 4 above
  under the system bar (140 pt).

### For a later reader of the whole run (not this batch's to do)

- **The note's top is now its targets:** three rows of 44. More room is VM-148's road — the tools in the top row beside
  the back button and the chips in one sideways row, as the note-write mockup draws (P-47-20's description) — or a
  membership line folded into the chip flow (D2's "reads alone" is PROVISIONAL for her sitting).
- **SUSPECTED, not verified (no touch-injection pin exists for it):** a SwiftUI `TextField` answers a touch across its
  own text frame, not its padded box, so `phoneField`'s "at least 44 tall" has been a drawn 44 since wave 1, not an
  answering one; the step-down neither widens nor narrows what answers. If confirmed (a pointer-injection tap 4 pt
  inside the box's top edge), it is a 44-pt-law ticket for every field (focus on a tap anywhere in the frame).

### Batch 2 — READY-FOR-TESTS (nothing builds in the window; every bundle is prebuilt, `nice -n 15`, incremental)

**UPDATED at the F-1a-W1 fix (2026-11-25):** the tip is code **`dae368b4e`** — batch 2's code, `origin/main` merged at
`1a7b0d444` (PR #28, carrying PR #27), and the F-1a-W1 fix; all three tip bundles (`vm260-2`, `vm260-2-mac`,
`vm260-2-ui`) were REBUILT on it (`TEST BUILD SUCCEEDED` each; incremental, `nice -n 15`). The window gains F-1a-W1's
legs: **R-W1** below, its guard suites in **P**, its UI test in **U**, and the s9 re-capture in **W**.

All from `App/Variorum/`, zsh, `test-without-building`; `UDID` = the device the GO names (iOS 26.2), booted fresh
inside the claim, settled, shut down before release. Phone plan:
`P(folder)=DerivedData/<folder>/Build/Products/VariorumMobile_VariorumMobile_iphonesimulator27.1-arm64-x86_64.xctestrun`,
`-destination "platform=iOS Simulator,id=$UDID"`.

**R — red on old** (`vm260-2-rol`, tree `f99f20818` — the pins over the pre-fix app):
`-only-testing:VariorumMobileTests/MobileDrawnStepDownTableTests -only-testing:VariorumMobileTests/MobileDrawnStepDownRenderedTests
-only-testing:VariorumMobileTests/MobileDrawnStepDownTargetTests -only-testing:VariorumMobileTests/MobileNoteTopTests`
- Predicted RED: `theChromeSitsOneNotchUnderHerWords`, `theCornersAreTheMacsTwo`,
  `theDrawingsSitWellInsideTheirTargets` (both voices), `theNoteTopGivesTheScreenBackToWriting` (both voices),
  `everyDoorOnTheNoteTopAnswersAcrossFortyFour` (**Study only**).
- Predicted GREEN (guards): `theNewThirteensNeverDipUnderTheFloor`, `everyControlAnswersAcrossItsWholeTarget` (all
  four cases), `everyDoorOnTheNoteTopAnswersAcrossFortyFour` (Terminal), `theToolsAreOneRowOfFortyFourSquareTargets`
  (both). A RED guard on old means a target was already under its law there — report it, it is a finding.
- Read the `PERF[sim] VM-273 drawn …` and `VM-272 note top …` lines into this record (the measured boxes and heights).

**R-W1 — F-1a-W1's red on old** (a UI test: `DerivedData/vm260-w1-rol/Build/Products/TK2SpikeUITests_TK2SpikeUITests_iphonesimulator27.1-arm64-x86_64.xctestrun`,
tree `c4081441c` — the pin over the pre-fix app; on the WALK device, whose library opens — `xcrun simctl list devices |
grep vm260-walk`; the same device as U): `-only-testing:VariorumMobileUITests/MobileKeyboardRevealUITests/testTheBarRidesAboveTheLibrarySearchKeyboard`
(~2 min).
- Predicted RED: LEG 2 and LEG 2 emptied — for each bar door "does not draw as it does at rest" and "ends at y ≈ 591, on
  the keyboard's keys (their top 583)" (≈ 12 issues). Predicted GREEN: LEG 1 (the control).
- Read the `REVEAL` lines (every door's frames, ink and differing counts, the keyboard's frame) into the F-1a-W1 block,
  and export the "BAR …" attachments to `notes/plans/vm-260-screens/batch-2/w1-rol/`.
- LEG 1 RED as well ⇒ the shortfall is not tied to the note's keyboard: report it (the fix still answers any shortfall
  the guide sees). LEG 2 GREEN ⇒ the test's road did not reproduce the walk's state: HOLLOW on this road, recorded.

**P — the tip, the whole phone target, one launch** (`vm260-2`, code tip `dae368b4e`): `-only-testing:VariorumMobileTests`,
read against main's known reds (batch 1a's run: 6 known issues — `MobileFilterRowGeometryTests`' two Display-Zoom pins × 2,
`MobileTrashTests`' empty-tree diagnostic × 2). It holds this batch's pins, the moved pins, and every suite that mounts a
control, a root, a note or the line (the tip also carries batch 1b's code and pins). Predicted: green but those six.
F-1a-W1's two guard suites ride here: `MobileKeyboardFloorRuleTests` (6) and `MobileKeyboardFloorShellTests` (1 — the
mounted shell lifting the bar to a held keyboard top; it prints `PERF[sim] F-1a-W1 …`), predicted green; every suite
that mounts the shell now carries the floor's probe in its background — inert with no keyboard (no reading, no lift).
The likeliest place for a surprise is a geometry pin elsewhere that measured a 17- or 15-pt chrome word's width or a
22-pt glyph — such a red is a pin the ruling moved only if it holds a drawn number; a TARGET under 44 is a regression.

**M — the Mac legs** (`DerivedData/vm260-2-mac/Build/Products/Variorum_Variorum_macosx27.0-arm64.xctestrun`,
`-destination 'platform=macOS'`): `-only-testing:VariorumTests/<type>` for ThemeTokenTests NoLiteralColourTests
PaletteDerivationTests BadgeFamilySplitTests DataSafetySearchIndexTests OneInputPathTests
OneRefreshAuthorityCompositionTests DeadVocabularyTests IndexTierMetricsTests (the token pins and every Mac suite that
walks the phone tree — this batch changes `Shared/Theme/Phone*.swift`, which the Mac compiles and never renders;
`VoiceTokens.swift` untouched). If batch 1b's M leg runs in the same window it may run on this bundle instead (it
carries 1b's code). Expected green but `IndexTierMetricsTests`' 4 declared known issues. (Rebuilt at `dae368b4e`: it now
carries PR #27's `Shared/Protection/` changes from the main merge; the F-1a-W1 fix touches no `Shared/` file — its new
phone file is walked by the scans that read the phone tree.)

**U — the keyboard-reveal UI test** (OWED — this batch changes `MobileWriteView`'s layout, and F-1a-W1 changes
`MobileShellView.body`'s band frame): `DerivedData/vm260-2-ui` (rebuilt at `dae368b4e`), scheme TK2SpikeUITests' plan,
`-only-testing:VariorumMobileUITests/MobileKeyboardRevealUITests` — the class now holds TWO tests (~4 min), on a device
whose library opens (the walk device — batch 1a's no-verdict was a Castle-locked device). Expected green, both:
`testAMidNoteTapRisesAboveTheKeyboard` (the masthead is the screen's top inset; the reveal road is the text view's; the
keyboard floor leaves a note alone) and `testTheBarRidesAboveTheLibrarySearchKeyboard` (all three legs — the fix; if LEG
2 stays RED with the bar still ending at ≈ 591 the keyboard guide carries the stale 52 too: the F-1a-W1 block's "NOT
KNOWN" paragraph names the next road). Export its "BAR …" attachments to `notes/plans/vm-260-screens/batch-2/w1-tip/` —
LEG 2's are the s9 re-capture in Study light.

**W — the captures** (the window's job, both voices, light; to `notes/plans/vm-260-screens/batch-2/`). BEFORE: the
Debug phone app from `vm260-2-rol` (its app is the pre-fix app); AFTER: the app from `vm260-2`. The same three stops
in each, at her screenshot's framing:
1. **A note with the keyboard up** — a note in a book with a few paragraphs, a tap in its lower half (her screenshot's
   frame: the back button, the title row with its four tools, the membership line, the chips, her text, the keyboard).
2. **The Bookcase root** — the top line (name, count, New Note, gear), the book rows with the Today chip, the quick
   entry, the bar.
3. **The Library** — the top line (trash, New Note, gear), the search field, the filter row, rows, the bar.
And, after only (the step-down's other faces): Settings (menu rows at 15, the segmented choices — the remainder), the
Trash's kind chips (near-square), a calm button (Create Book), a refusal's card (corner 8).

**F-1a-W1's capture stops** (BEFORE from `vm260-2-rol`, which predates the fix too; AFTER from `vm260-2`; both voices,
light):
4. **The s9 re-capture** — the walk's own road: a note opened with its keyboard up (the editor's bar riding it), Back with
   the keyboard up, then the Library's search tapped: BEFORE shows the bar under the candidate strip's glass (s9), AFTER
   the bar standing on the keyboard's top, the list ending at the bar's hairline.
5. **The same road ending on the Bookcase's capture box** (after only) — the contract's other half; the fix is band-wide.
6. **If a line is on screen in stop 4** (any message the road raised), its place over the bar — the one line tracks the
   keyboard from its own notifications (`MobileMessageLineController`) and is NOT touched by this fix; a line standing
   52 pt low there is batch 1b's finding, not F-1a-W1's.


### Batch 2 — RECONCILE (the consolidated window's two tip reds; implementer: Opus, the batch-2 session resumed, 2026-11-25)

The window (its section above): red-on-old ESTABLISHED as predicted, M green, U green; on the tip two of this batch's
pins red. Each settled from the window's own `PERF[sim]` lines (`/tmp/vm260-win/R.log`, `P.log`). No test has run on
the reconciled tree — the re-evidence rides the next window (P3 + M3's, or the gate's). Batch 3's tree is underneath
(`PhoneType`'s words scale, `MobileLook`, the editor face): nothing of it is touched beyond the two pieces below.

**Piece R1 — the field: (a) AND (c), never (b).** The window: `field (363.0, 39.0) in (363.0, 39.0)` both voices — the
box 39 and the "frame" 39.
- *(a) the drawn box really was 39.* A text field's own view is TALLER than its text's line: 39 − 8 − 8 = **23 pt** for
  a 15-pt `control` field, where my arithmetic counted the 18-pt line (18 + 16 = 34 → the 36 floor). So 8 + 8 of air
  drew 39 and the 36 floor never bound. **The drawing moves to the design, not the law:** the field's air above and
  below is now the scale's 4 (`PhoneControlMetrics.fieldVerticalPadding`): 23 + 8 = 31, the 36 floor binds, the box
  draws 36 at the default size — the calm button's box (it measured 37.33 in the window: 36 and the edge's outer half)
  — and still grows with its text above that. P-260-2d unchanged.
- *(c) the "frame" was the probe's error.* The pin read the field's target as the accessibility frame of an
  `.accessibilityElement(children: .ignore)` container — and a combined element reports what its children DRAW (the
  box), never the invisible `.frame(minHeight: 44)` around them. The 44 layout frame was there all along:
  `MobilePhoneControlsTests.theFieldIsAtLeastFortyFourTallAndGrowsWithItsText` measures the layout and was GREEN in the
  window's P. The pin now reads the field's layout frame (`onGeometryChange`, global — `FieldFrameProbe`), and prints
  the text field's own view size for VM-280.
- *(b) not the case:* no target moved; the field's frame is ≥ 44 (pinned green on the tip).
- **VM-280 trail (the field's answering height, Suspected):** the window's numbers are the first measured datapoint —
  the field's own view (the thing that takes the touch) is **23 pt tall** at the default size (39 − 16), inside a 39
  box (now 36) inside a 44 frame. If VM-280 is right, a phone field answers across about 23 pt, not 44 — the gap is the
  frame's 21, not the box's. The reconciled pin's `PERF[sim] VM-273 drawn …` line now prints that view's size
  directly, so the next window confirms it with no extra run.
- MOVED (the ruling's own number): `MobilePhoneControlsTests.theFieldIsAtLeastFortyFourTallAndGrowsWithItsText` — its
  "holds its text's line" floor reads `2 × fieldVerticalPadding` (was `2 × 8`); its 44 floor and its growth
  assertions unchanged.
- **Predicted at the next window:** `theDrawingsSitWellInsideTheirTargets` GREEN both voices — the field's box ≈ 37.3
  (36 + the edge's outer half, the calm button's measured shape), its frame 44, the text field's own view 23 tall;
  `theFieldIsAtLeastFortyFourTallAndGrowsWithItsText` GREEN (the frame 44 at every chrome size; her words' field at AX5
  grows: its own view ≥ its line, + 8); every other field pin untouched (the placeholder's pixel pin reads inside the
  text field's own view). Build: `DerivedData/vm260-2r` (an APFS clone of `vm260-3`, incremental, `nice -n 15`) — `TEST BUILD SUCCEEDED`.

**Piece R2 — the note's top: the 9 pt was air, on both trees; taken out (C-272-1 means it), the cap tightened to the
exact arithmetic.** The window: tip `chrome 145.0` (Study) / `144.33` (Terminal), the title row at (20, 54, 44, 44) —
it starts at the safe area's top, so nothing sits above it; and the OLD tree's line, `chrome 167.0` / `166.33` with the
title row at y 64 (its 10 above). My arithmetic said 158 → 136; both trees measured exactly **9.0 pt more in Study and
8.33 in Terminal** — so the miss was never this batch's change (167 − 145 = 22 = the padding it removed, to the point).
The split, from the two voices' difference:
- **8 pt fixed — `safeAreaInset`'s default spacing.** `.safeAreaInset(edge: .top) { masthead }` takes `spacing: nil`,
  the system's default gap between the inset and the content: 8 pt of air between the last chip row and her text,
  under the masthead's own 8 (now 4) — invisible in the source, counted by neither number. (The bar's place already
  spells it out for the same reason: `.safeAreaInset(edge: .bottom, spacing: 0) { barSpace }`.) Now `spacing: 0`.
- **1.0 / 0.33 pt font-dependent — the title row on the title's baseline.** `HStack(alignment: .firstTextBaseline)`
  aligned the four tools' glyph baselines to the title's, so the 44-pt tool targets hung below the title's 44 (Iowan
  20: 1.0; SF Mono 18: 0.33) — the only row whose height depends on a font (the membership line and the chip row are a
  13-pt word inside a 44 frame). Now `alignment: .center`: every door on the row is a 44 target, so the row is 44
  exactly, the glyphs centred on the title's line. **C-272-2 (PROVISIONAL, with the set):** the title and its tools
  align by centre, not baseline — a point's difference in where the glyphs sit, her eye's at the captures.
- **Predicted at the next window:** `theNoteTopGivesTheScreenBackToWriting` GREEN both voices at **136.0** (44 + 44 + 44
  + 4, no font in the sum); its cap MOVED 140 → **137** (`3 × 44 + mastheadBottom + 1`) — the layout is now exact, so
  the pin states the design to the point; it stays red on old (167, measured). `everyDoorOnTheNoteTopAnswersAcrossFortyFour`
  and `theToolsAreOneRowOfFortyFourSquareTargets` GREEN (unchanged targets; the tools' centres still 44 apart, one row).
  The keyboard-reveal UI test (U) owes a re-run on this tree — the Write screen's layout moved (8 pt more page): its law
  is relative (the tapped line rises above the keyboard bar), so GREEN is predicted.
- The VM-272 "as built" line above ("158 → 136") reads, measured: **167 → 136** at one chip row.

**The reconcile's re-evidence (the next window — P3 + M3's or the gate's; nothing builds in it):** bundles on code tip
`2d4670d18`, each an APFS clone of batch 3's, incremental, `nice -n 15`, all `TEST BUILD SUCCEEDED` — phone
`DerivedData/vm260-2r` (it carries batch 3's code, so it can serve P3 as well), Mac `DerivedData/vm260-2r-mac`, the UI
test `DerivedData/vm260-2r-ui`.
- `-only-testing:VariorumMobileTests/MobileDrawnStepDownRenderedTests -only-testing:VariorumMobileTests/MobileNoteTopTests
  -only-testing:VariorumMobileTests/MobilePhoneControlsTests` — predicted ALL GREEN; read the two `PERF[sim]` lines into
  this block (the field's box ≈ 37.3 in a 44 frame with its own view's size — VM-280's datapoint; the note top 136.0
  in both voices). Or the whole phone target on `vm260-2r`, which holds them.
- The keyboard-reveal UI test on `vm260-2r-ui` (`-only-testing:VariorumMobileUITests/MobileKeyboardRevealUITests`, the
  walk device) — predicted GREEN.
- The Mac legs on `vm260-2r-mac` (R1's constant is in `Shared/Theme/PhoneControls.swift`, which the Mac compiles) —
  predicted GREEN as M was (the 4 declared `IndexTierMetricsTests` known issues).

## BATCH 3 — record (VM-247 · VM-254; implementer: Opus, a fresh session, 2026-11-25)

**What this batch did NOT do (kept current):** NO suite has run — the stage is coordinated above this session, so every
test claim below is PENDING its window; no capture is taken (the window's stops are listed at the READY block); no
line in `Sources/`, `Sync/`, custody, `MobileEditorTextView`, the text-input path, `MobileKeyboardBar`,
`Shared/StatusCenter.swift` or `Shared/Theme/VoiceTokens.swift`; `Shared/Theme/ThemeStore.swift` untouched (the phone
still binds it and simply stops taking the look from it); the synced `setting` rows untouched and never written by the
phone's Look; the Mac's sources untouched; no canon edited (the deltas are drafted for the closeout below);
`notes/QUESTIONS.md` not touched (the calls P-260-3a…3e, C-247-1, C-254-1/-2 are listed for the merge's QUESTIONS); the
orchestrator's own LIVE STATUS table not flipped (its row is the orchestrator's). Machinery: the harness moved two long
`xcodebuild` runs to its background after 180 s; each was waited on in the foreground by polling its log, never left
running across a turn.

### LIVE STATUS

| Piece | State |
|---|---|
| 0. Preflight (CLAUDE.md + canon; this record's binding sections — What binds every batch, the 13b constitution, her kickoff rulings R-260-2/-3, the adjudications incl. A-260-3's procedural note and A-260-9's flag, the Batch 3 section, the BATCH 2 record; SurfaceContracts "The app" in full incl. the phone's Settings bullet; the resiliency protocol; QUESTIONS #281 and its addendum (P-47-16's "the cream background stays an option"); the VM-47 record's P-47-15/-16/-17/-24/-25/-26 rows; TEXTKIT2_NOTES §3) | DONE (this commit) |
| 1. The pins on the pre-fix tree — VM-247's fence (a Look change writes no row; a library's look moves the phone nothing) and VM-254's default (her words one notch under today's, the editor's body with them) | DONE (`2e03a6811` — **that commit IS the red-on-old tree**; two new files, only symbols both trees declare: `MobilePhoneOwnLookFenceTests`, `MobileHerWordsDefaultTests`) |
| 2. The red-on-old tree built headless (`DerivedData/vm260-3-rol`, an APFS clone of `vm260-2`, incremental, `nice -n 15`) | DONE — `TEST BUILD SUCCEEDED` at `2e03a6811` |
| 3. VM-247 — this phone's own look (voice · palette · background · appearance on the device; the router's overlay; the editor face's ground; Settings ▸ Look's rows) | DONE (this commit) — phone `build-for-testing` green on it (`DerivedData/vm260-3`, an APFS clone of `vm260-3-rol`, incremental, `nice -n 15`); the suites PENDING; the pins it moves are piece 5's |
| 4. VM-254 — the text-size row and the smaller default (the type layer's table and its words scale; the editor face's body; the environment at the roots) | DONE (this commit) — phone `build-for-testing` green on it (`vm260-3`, incremental, `nice -n 15`); the suites PENDING; the pins it moves are piece 5's |
| 5. Pins MOVED with the rulings + the tip's new pins | DONE (`8d088be03`; the faint rule's box-hint move in the READY commit) — listed below; compiled in `vm260-3` |
| 6. Tip bundles (`vm260-3`, `vm260-3-mac`, `vm260-3-ui`) and READY-FOR-TESTS | DONE (this commit) — all three `TEST BUILD SUCCEEDED` on this commit's code (APFS clones of `vm260-3-rol`, `vm260-2-mac`, `vm260-2-ui`; incremental; `nice -n 15`); the run list below |
| 7. The window — red-on-old, the whole phone target, the Mac legs, the keyboard-reveal UI test, the captures | PENDING (the GO) |

### VM-247 — the traced mechanism: why a look chosen on either device moved the other

The phone's whole look funnels through ONE seam, the shell router (`MobileShellRouter`, VM-51): it binds the open
library's `ThemeStore` (the Mac's, hoisted to `Shared/`) and answers `settings` = the store's landed
`Queries.ThemeSettings`; `tokens(dark:)` resolves every chrome surface from it (the shelf, the Library, the bar, the
masthead, Settings, the message line), and the store's landing seam (`onLanded` → `adoptLanded`) hands the same value
to the UIKit editor face (`MobileEditorStyle.adopt`) and restyles every registered editor. The store observes the
synced `setting` table (`theme_voice`, `theme_palette`, `theme_tint`, `theme_accent_tint`), so a change made on the Mac
— or landed by a sync apply — re-voiced and re-coloured the phone; and Settings ▸ Look ▸ Voice (R-47-2) called
`ThemeStore.setVoice` → `Operations.setThemeVoice`, an upsert of the synced `theme_voice` row with its outbox row, so the
phone's choice moved the Mac. The lobby wore a fixed placeholder (P-47-15). Appearance alone was already the device's
(`MobileAppearanceController`, VM-53 — `AppearanceChoiceRule`'s road: one key in this device's defaults).

### VM-247 — as built (`AppearanceChoiceRule`'s road; nothing in `Sources/`, `Shared/` or the Mac)

- **The choice and its owner** — `VariorumMobile/Features/Shell/MobileLook.swift` (phone target only, no shared type):
  `MobileLookChoice` {voice, palette, ground} kept in THIS device's defaults under three keys (`phoneLookVoice`,
  `phoneLookPalette`, `phoneLookBackground` — beside VM-53's `appearanceChoice`; deliberately not the retired VM-51 key,
  so an old phone-local voice is never read, R-260-3's "no seed"); a strange value reads as that choice's fresh default
  (`AppearanceChoice.remembered`'s posture). `MobileLookController` is `MobileAppearanceController`'s twin — one owner,
  `set…` remembers and then tells the router; **memory-only under a test runner's host** (VX-604's posture: the suites
  share the dev-store app's `.standard`, and a choice one suite makes must never reach the next).
- **The fresh default (her R-260-3, "Sea-glass default")** — `MobileLookChoice.fresh` = `Queries.ThemeSettings
  .unsetStoreVoice` / `.unsetStorePalette` (Study under the sea-glass — the same constants the unset library reads, so
  they cannot drift) on the paper. No copy from the library: a library's synced purple simply stops being worn.
- **The overlay** — the router's `settings` = `look.choice.over(theme?.settings ?? MobileEditorStyle.settings)`: the
  library's landed settings with the phone's voice and palette in their place and the custom seeds cleared (the phone
  offers no custom palette, and a seed changed on the Mac must never read as a look that moved here); every other
  setting stays the library's (the phone reads none today). The store is still bound and still lands — it is the
  library's OTHER settings' road — so `Shared/Theme/ThemeStore.swift` and every synced-settings read path are untouched.
- **Where the look reaches the editors** — one private `wear(_:)`: `MobileEditorStyle.adopt(choice.over(library),
  ground:)`, and when the face moved, `editors.applyVoiceChangeEverywhere()` (the existing LK2 flip road — attributes
  only, O(open note), at a deliberate settings press). Called by `adoptLanded` (a library landing — under the phone's
  look it moves no face) and by `lookMoved` (the controller's change hook).
- **The voice door** — `setVoice` writes the phone's voice (`look.setVoice`); `ThemeStore.setVoice` is no longer called
  from the phone. No phone road writes a `setting` row for Look.
- **The cream (P-47-16's road (b) as her choice; her words: "I also did like the cream background color option. that
  should stay as an option for the phone")** — `MobileNoteGround` {paper, cream}: the paper is `tokens.surface` (road
  (a), as built since the VM-47 run's piece 3.10), the cream the VOICE's own room under every palette
  (`ReadingPageTokens.room` — the palette-less road the Read page's cream page sits on: Study `#FAF8F3`, Terminal
  `#F6F6F1`, R51's black in dark). It is the NOTE's ground in Write — P-47-16's own scope — worn by the screen, its
  masthead (P-47-17: one ground) and its edge strips (`MobileWriteScreen.noteGround`, the one SwiftUI rule
  `MobileNoteGround.color`), and by the editor (`MobileEditorStyle.Face.paper` → `room` under the cream — the text view's
  one line `backgroundColor = face.paper` untouched).
- **Settings ▸ Look** — Voice (the phone's), **Colour palette** (the Mac's label; the system menu of the Mac's palettes
  in the Mac's words, a checkmark on the chosen), **Background** (Paper · Cream), Appearance (unchanged).
- **The lobby** wears the phone's look (`lockedTokens` → the router's tokens) — no library needed to ask.
- **The walk's palette seam** (`MobileWalkLaunch`, DEBUG) now chooses the phone's palette through the controller — the
  library's palette is no longer worn, so writing it would show nothing.

### VM-254 — the traced mechanism: "the phone's text looks big to her"

Every type site on the phone reads one of twelve roles from one table (`Shared/Theme/PhoneType.swift`, VM-48) through
`phoneType(_:_:)` (SwiftUI) or `PhoneType.uiFont` (UIKit); her words' roles were the sizing sheet's as drawn — the
note's body Iowan 17 on 27 (Terminal 15), a screen's title 20, a row's title 17, its preview 15 — a notch above the
pre-wave-1 phone, whose note body was the Mac's own Iowan 16 (`VoiceTokens.studyLight.body`; Terminal 14). The editor's
face builds the note's body from the same table's `noteBody` (`MobileEditorStyle.Face.init`, once per voice). Batch 2
stepped the chrome a notch under those words and the note's title 24 → 20 (VM-272); nothing let her choose a size: the
only lever was the system's text size, which moves the chrome too.

### VM-254 — as built (P-260-3a/3b, PROVISIONAL as a set)

- **The smaller default lives in the table** (`PhoneType.studySpec`): her words one notch under wave 1's set — the
  note's body **16 / 25**, a screen's title **19 / 24**, a row's title **16 / 21**, its preview **14 / 19**; the
  note's title keeps the **20 / 25** its notch already took (VM-272, the batch-2 flag); each pitch moved with its size
  (×16/17, rounded). Terminal stays two under — **14 / 23, 18 / 23, 17 / 22, 14 / 19** — and **never under the floor**:
  a row's preview, which two-under would put at 12, holds **13 / 18** (wave 1's Terminal value), its pitch moving with
  its size. The chrome is batch 2's, untouched, still one notch under her words in Study (control 15 < body 16; chip 13
  < preview 14). The twelve words (`mono`, 17) are not hers to size.
- **The setting** — five steps on this device (`MobileTextSize`, kept beside the look's other choices under
  `phoneLookTextSize`): **Smaller · Small · Default · Large · Larger** = the note's body in Study at the system's default
  size **14 · 15 · 16 · 17 · 18** — a words scale of 14/16 · 15/16 · 1 · 17/16 · 18/16; "Large" is wave 1's set back.
  It scales exactly the roles that follow the text size (`PhoneTypeRole.followsTextSize`: the note's body, both titles,
  a row's title and preview), size and pitch alike, on top of the system's text size, never under the floor
  (`PhoneType.spec(_:voice:wordsScale:)`, one function every form reads).
- **How it reaches every surface** — SwiftUI: one environment value, `EnvironmentValues.phoneWordsScale` (an `@Entry`
  in the type layer's own file, `PhoneControls.phoneFieldPrompt`'s precedent; 1 wherever nothing set it — every hosted
  surface and the Mac), read by `PhoneTypeModifier` and set by the shell at its outermost (`MobileShellView` — both
  pages, every pushed screen and every sheet it presents) and by the app around the lobby (`VariorumMobileApp`; that
  file's diff is the wrapping `Group` and one line — `git diff -w`). UIKit: the editor face carries the scale
  (`MobileEditorStyle.Face.scaled` rebuilds only the note's body; `font(_:)` hands it to every UIKit role site — the
  comments sheet's draft field, the take browser's and History's titles), adopted with the look by the router's one
  `wear` (`adopt(_:ground:wordsScale:)`), and an open note re-bases its font through the existing flip road
  (`applyVoiceChangeEverywhere` — attributes only, O(open note), at a deliberate Settings press; nothing in the editor
  seam). A book's Read page follows the setting too (`PhoneReadingModifier`) but keeps its own table at the default
  (P-260-3b).
- **Settings ▸ Look ▸ Text size** — the five words as the system segmented control (every Settings choice's control).

### Pins (all PENDING the window)

**Red on old — the pre-fix tree `2e03a6811`, bundle `DerivedData/vm260-3-rol`** (only symbols both trees declare):
- `MobilePhoneOwnLookFenceTests.thePhonesVoiceDoorWritesNoSettingRowAndNoOutboxRow` — a bound router, an open editor;
  `router.setVoice(.terminal)`; the chrome, the face and the open editor's storage move; the `setting` rows and the
  `setting` outbox rows are byte-unchanged. **RED ON OLD predicted** (2 issues: the `theme_voice` row and its outbox row
  — R-47-2's road wrote both; the movement half passes on old, through the landing).
- `MobilePhoneOwnLookFenceTests.aLookWrittenToTheLibraryMovesThePhoneNothing` — the Mac's operations write Terminal under
  lavender; a witness `ThemeStore` and the router's own store both land it; the router, its tokens (both appearances),
  the face and the open editor still wear Study under the sea-glass. **RED ON OLD predicted** (≈ 6 issues: the voice,
  the palette, the tokens ×2, the face, the editor's font).
- `MobileHerWordsDefaultTests.herWordsSitOneNotchUnderTodaysSet` — the table's her-words roles at 16 / 25 · 20 / 25 ·
  19 / 24 · 16 / 21 · 14 / 19, Terminal 14 / 23 · 18 / 23 · 17 / 22 · 14 / 19 · 13 / 18, the chrome unmoved, the twelve
  words 17. **RED ON OLD predicted** (7 issues: Study's body, screen title, row title, preview; Terminal's body, screen
  title, row title — the note's title and Terminal's preview already hold on old).
- `MobileHerWordsDefaultTests.theNoteInWriteTakesTheSmallerBody` — the editor's body Terminal 14 on 23, Study 16 on 25.
  **RED ON OLD predicted** (4 issues).

**The tip's own — new behaviour, GUARDS** (green on the tip predicted; their symbols are new, so no red-on-old run):
- `MobilePhoneOwnLookTests` (9): `noPhoneSourceWritesTheLibrarysLook` (a source guard: no phone file calls the library's
  look setters or their operations — the walk seam included) · `theLookIsKeptInThisDevicesDefaults` (fresh = Study · sea-glass · paper · default; the
  four keys; a fresh owner reads them back; strange values and `custom` read the default; the inert owner remembers
  nothing; never the retired key) · `theOverlayTakesOnlyTheLook` · `everyLookChoiceWritesNoSettingRowAndMovesTheFace`
  (palette, background, text size, voice — no row, no outbox row; the accent, the ground, the body, the voice each
  move) · `theCreamIsTheVoicesOwnRoomNeverThePalettes` (the SwiftUI rule and the editor face agree, both voices, light
  and dark, two palettes; a real text view's ground) · `aNoteInWriteWearsTheCreamSheChose(dark:)` ×2 (a real scene
  window, the shell, the Today door into Write: the editor's margin and the four edge points within 0.012 of the cream,
  which is > 0.02 from the paper — Study light's cream is `#FAF8F3` against `#FFFFFF`, so the pin's tolerance is tight
  on purpose) · `theLookGroupDrivesThePhonesOwnChoices` (the segments exist; Cream, Large, Terminal drive the phone's
  owner and are remembered in its defaults; the palette's door under the Mac's label names the sea-glass and answers
  ≥ 44 tall across the row) · `thePaletteMenuOffersEveryPresetOnce` · `thePaletteWordsAreTheMacsOwn` (a source pin on
  the Mac's `PaletteCopy.swift`, P-47-24's precedent).
- `MobileTextSizeTests` (5): `theFiveStepsScaleHerWordsOnly` · `nothingIsEverBelowThirteenPointsAtAnyStep` (12
  categories × 5 steps × 2 voices × 12 roles, both forms) · `aStepReachesHerWordsOnAMountedScreenAndNotTheChrome` (a row
  title's line grows at Larger and shrinks at Smaller, a control's word within 0.5 — prints `PERF[sim] VM-254 mounted
  lines …`) · `theEditorFaceTakesTheStep` · `aStepChosenOnThePhoneRebasesAnOpenNote` (attributes only; no `setting` row).

### Pins MOVED with the rulings (each because the ruled change moved what it holds; none loosened past its new number)

- `MobileShellTests.theVoiceDoorWritesTheLibraryAndTheLandingReachesTheOpenSurface` → `…theVoiceDoorIsThePhonesAndReaches
  TheOpenSurface` — the door moves the phone's voice and the open surface in the same turn; `theme_voice` is nil (it
  asserted the library's row written — VM-247 reverses exactly that).
- `MobileLibraryLookTests.aLookWrittenElsewhereReachesThePhoneAndItsOpenEditor` → `aLookChosenOnThePhoneReachesItsChrome
  ItsFaceAndAnOpenEditor` — the same coverage (chrome, face, open editor, the markdown link, `.default`'s byte-identical
  road) driven by the phone's own doors; its inverse is the fence pin. `thePlaceholderIsWhatAnEmptyLibraryReads`: with
  no library bound the router reports the fresh look over the face's settings (it reported the face's own). The suite's
  header and `aFreshLibraryWearsStudyUnderTheSeaGlass`'s doc say why that one still holds (R-260-3's constants).
- `MobileLivenessTests.aVoiceFlipReachesEveryRegisteredEditor` — the flip is the phone's look moving
  (`router.setVoice`), not a library landing (`adoptLanded` now lays the phone's look over whatever lands, so its
  second flip would move nothing).
- `MobileLookSourceTests.theNoteInWriteIsOnThePaper` — Write's three grounds read the one note-ground rule
  (`noteGround`), no `tokens.surface` ground of their own and no room but the rule's; the editor's line unchanged.
- `MobilePhoneLayerTests.theStudyTableIsTheSheetsAsDrawn` (her words' new table) and
  `…terminalIsTheSameRolesInMonoWithItsProseTwoUnder` (14 · 18 · 17; two under, never under the floor — the preview
  13 / 18).
- `MobileDrawnStepDownTableTests.theChromeSitsOneNotchUnderHerWords` — its "her other words are batch 3's to move" line
  now holds batch 3's numbers.
- `MobileVoiceTests.surfaceWriteValuesFollowTheLiveVoice` — Terminal 14 on 23, Study 16 on 25 (the gaps 12 / 14 kept).
- `MobileFaintOnDoorsTests` (the sibling rule, `wordOffenders`) — **the quick-entry box's hint**, drawn in the faint at
  `noteBody`, rode the rule's full-size exemption at 17; at 16 the rule's letter would flag it. It is the box's
  PLACEHOLDER (sheet §D: placeholders need 3:1, the faint's own use; the faint clears 3:1 on every shipped ground), so the
  rule names that one site by its one function (`isTheBoxsHint`) — C-254-1 below. Predicted RED on the tip without the
  move.
- `MobileSettingsListTests.theGroupsAndTheTwoChoices` — wording of its doc and one message only (the voice is the
  phone's); its assertions unchanged and green on both.

### Calls made in the batch (for the record and the merge's QUESTIONS; none gates the core)

- **P-260-3a — her words' default and steps as a set** (VM-254): the default one notch under wave 1's set (16 · 20 · 19 ·
  16 · 14, the note's title's notch already taken), Terminal two under and never under the floor; five steps = the
  note's body 14 · 15 · 16 · 17 · 18 (a words scale of 14/16 … 18/16; "Large" is wave 1's set back); the words
  "Smaller · Small · Default · Large · Larger" DRAFT. Alternatives: (b) the default on the five-size scale's own notch
  (body 15, row title 15, preview 13, screen title 17 — her words would then equal the chrome, against batch 2's
  "chrome one notch under her words"); (c) steps of the five-size scale itself (13 · 15 · 17 · 20 · 24 for the body —
  coarse jumps); (d) a slider.
- **P-260-3b — the reach of the setting**: the five her-words roles everywhere (the shell, every sheet, the lobby, the
  editor and its UIKit faces); a book's Read page follows the SETTING but keeps its own table at the default (R2's
  voice-independent page — 17); the twelve words (`mono`) never. Alternatives: (b) the Read page takes the default drop
  too (body 16, the Mac's page); (c) the Read page outside the setting.
- **P-260-3c — the palette row's shape and words**: the system menu (16 presets — more than a segmented control holds;
  the Library sort door's idiom), its door the row under the Mac's label "Colour palette" naming the chosen palette; the
  Mac's words for every palette; the Mac's two one-swatch groups (Default · Classic) folded into one untitled first
  section; "Your own" (custom hex) NOT offered on the phone. Alternatives: (b) a sheet of rows with the Mac's swatches;
  (c) a horizontal swatch strip (the Mac's); (d) offer Custom with a hex field.
- **P-260-3d — the cream's reach**: the NOTE's ground in Write (P-47-16's own scope — the screen, its masthead, its edge
  strips, the editor), the voice's own room through the palette-less road; the lists stay on the paper. Words
  "Background: Paper · Cream" DRAFT ("Cream" is hers). Alternatives: (b) every place her words sit (the roots' lists, a
  book's contents, Archived, the Trash, Versions) on the cream too; (c) in dark, the voice's own unhued paper rather than
  R51's black room.
- **P-260-3e — the look's storage and fresh default**: four keys in this device's defaults (`phoneLookVoice`,
  `phoneLookPalette`, `phoneLookBackground`, `phoneLookTextSize`), memory-only under a test host; the fresh default her
  R-260-3's (Study, sea-glass, paper, default size); the library's synced look rows untouched and still landed (the
  router keeps its store for the library's other settings); the lobby wears the phone's look. Alternative: unbind the
  phone's `ThemeStore` entirely (it reads no other setting today) — one fewer observation, but a road a later phone
  setting would have to rebuild.
- **C-247-1 — the walk's palette seam** (`MobileWalkLaunch`, DEBUG) now chooses the phone's palette through the owner
  (remembered in the walk device's defaults — a walk that uses it should end by choosing the sea-glass again, or the
  device keeps the palette).
- **C-254-1 — the box's hint keeps the faint as a placeholder** (the moved faint rule above). Alternative: the hint in
  the corrected muted (darker, 4.5:1 — a look change her placeholder never asked for).
- **C-254-2 — the lobby's environment**: `VariorumMobileApp`'s state switch is wrapped in one `Group` to carry the words
  scale (its diff is that and one line — read it with `git diff -w`).

### Canon owed at closeout (drafts — the orchestrator's to land, two-file shape, VM-247 / VM-254 the pointers)

- **AppSpec §12, The app** — after "appearance (follow system, light, dark) is a local preference": "On the phone the
  voice, the palette, the note's background and her words' size are the device's own as well, never the library's
  (VM-247, VM-254)."
- **SurfaceContracts, The app — the first bullet's phone sentences** replace "On the phone the voice and palette are the
  library's own … (PROVISIONAL P-47-15)" with: "**On the phone the whole look is this device's own** — the voice, the
  colour palette (every preset; no custom hex), the note's background (the paper, or the cream: the voice's own room
  under every palette — P-47-16's road (b)), her words' size and light · dark · follow the system — kept in its defaults
  and never the `setting` table, so a look chosen on either device moves the other nothing; a phone that has chosen
  nothing wears Study under the sea-glass on the paper (R-260-3; VM-247)."
- **SurfaceContracts, the phone's sizes** — "Study 13 · 15 · 17 · 20 · 24" gains: "her words' roles one notch under wave
  1's set by default (the note's body 16, a screen's title 19, a row's title 16, its preview 14, the note's title 20),
  and a text-size setting on the device (five steps, 14–18 on the note's body) scales those roles only — never the
  chrome, the twelve words or the floor (VM-254; PROVISIONAL P-260-3a/3b)."
- **SurfaceContracts, the phone's Settings** — Look becomes "Voice: Terminal | Study · Colour palette (the system menu,
  the Mac's words) · Background: Paper | Cream · Appearance: Follow system | Light | Dark · Text size: Smaller | Small |
  Default | Large | Larger" — every Look row this device's own (VM-247, VM-254).
- **`notes/MobileSoul.md`** — the look's per-device row (MOBILE PARITY: the Mac's look stays library-wide; the phone's is
  its own — a deliberate divergence at her word).

### Batch 3 — READY-FOR-TESTS (nothing builds in the window; every bundle is prebuilt, `nice -n 15`, incremental)

All from `App/Variorum/`, zsh, `test-without-building`; `UDID` = the device the GO names (iOS 26.2), booted fresh inside
the claim, settled, shut down before release. Phone plan:
`P(folder)=DerivedData/<folder>/Build/Products/VariorumMobile_VariorumMobile_iphonesimulator27.1-arm64-x86_64.xctestrun`,
`-destination "platform=iOS Simulator,id=$UDID"`. The code tip is THIS commit (the bundles were built from its tree).

**R3 — red on old** (`vm260-3-rol`, tree `2e03a6811`):
`-only-testing:VariorumMobileTests/MobilePhoneOwnLookFenceTests -only-testing:VariorumMobileTests/MobileHerWordsDefaultTests`
- Predicted RED, all four: `thePhonesVoiceDoorWritesNoSettingRowAndNoOutboxRow` (2 issues),
  `aLookWrittenToTheLibraryMovesThePhoneNothing` (≈ 6), `herWordsSitOneNotchUnderTodaysSet` (7),
  `theNoteInWriteTakesTheSmallerBody` (4). A GREEN one on old means its road is hollow there — report it.

**P3 — the tip, the whole phone target, one launch** (`vm260-3`): `-only-testing:VariorumMobileTests`, read against
main's known reds (6 known issues — `MobileFilterRowGeometryTests`' two Display-Zoom pins × 2, `MobileTrashTests`'
empty-tree diagnostic × 2). It holds the four pins above (green), the 14 new guards, the moved pins, and every suite that
mounts the shell, a root, a note, Settings or a row — the tip carries batches 1a · 1b · 2, F-1a-W1 and batch 3. Predicted:
green but those six. **The likeliest surprises, in order:** (1) a geometry pin elsewhere that measured her words at 17 /
15 (a row's height or a title's width) — a pin the ruling moved only if it holds a drawn number of her words; a TARGET
under 44 or a floor under 13 is a regression; (2) `aNoteInWriteWearsTheCreamSheChose` (light) — its 0.012 tolerance
between the cream `#FAF8F3` and the paper `#FFFFFF` is tight by necessity; a render off by more than 3/255 is the pin's
problem, not the cream's — read its printed colours; (3) `theLookGroupDrivesThePhonesOwnChoices`' palette door — it
finds the Menu by label AND value; if SwiftUI exposes the menu's value differently, the issue text says what it saw.

**M3 — the Mac legs** (`DerivedData/vm260-3-mac/Build/Products/Variorum_Variorum_macosx27.0-arm64.xctestrun`,
`-destination 'platform=macOS'`): `-only-testing:VariorumTests/<type>` for ThemeTokenTests NoLiteralColourTests
PaletteDerivationTests BadgeFamilySplitTests DataSafetySearchIndexTests OneInputPathTests
OneRefreshAuthorityCompositionTests DeadVocabularyTests IndexTierMetricsTests (this batch changes
`Shared/Theme/PhoneType.swift`, which the Mac compiles and never renders: a table, a defaulted parameter and one
`@Entry`; `VoiceTokens.swift`, `ThemeStore.swift` and the Mac's own sources untouched). Expected green but
`IndexTierMetricsTests`' 4 declared known issues. (If batch 2's M leg runs in the same window it may run here instead —
this bundle carries batch 2's code.)

**U3 — the keyboard-reveal UI test** (`DerivedData/vm260-3-ui`, scheme TK2SpikeUITests' plan,
`-only-testing:VariorumMobileUITests/MobileKeyboardRevealUITests`, both tests, ~4 min, on the walk device whose library
opens): OWED — the note's body font changed (17 → 16) under the mid-note tap and `MobileWriteView`'s grounds moved to the
note-ground rule; nothing in the band, the editor host or the keyboard road changed. Expected green, both. If
`testAMidNoteTapRisesAboveTheKeyboard`'s tap lands below the shorter text (the note's lines are ~6 % shorter), that is
the test's seeded note running out of lines at its tap point, not the reveal — its printed frames say which.

**W3 — the captures** (the Debug phone app from `vm260-3`, both voices, light unless named, to
`notes/plans/vm-260-screens/batch-3/`; BEFORE where named from `vm260-3-rol`, whose app is the pre-fix app):
1. **Settings ▸ Look** — the five rows (Voice · Colour palette · Background · Appearance · Text size), both voices; and
   the palette menu OPEN (its sections, the checkmark).
2. **The cream** — a note in Write on Paper and on Cream, Study light and dark, Terminal light (the masthead, her text,
   the edge strips; with the keyboard up once).
3. **Her words' size** — the same note and the Library at Smaller · Default · Larger (Study light), and BEFORE/AFTER the
   default (the note and the Library from `vm260-3-rol` against `vm260-3`, both at the system's default size).
4. **A palette chosen on the phone** — the Bookcase under two palettes (sea-glass and one bold) — the screen recolours.
5. **At the end, put the walk device back**: Settings ▸ Look to Study · Sea glass · Paper · Follow system · Default (the
   choices persist in the device's defaults).


### Batch 3 — RECONCILE (the final evidence window's one red; implementer: Opus, the batch-3 session resumed, 2026-11-25)

**What this reconcile does NOT do:** no test runs (the re-evidence rides the run's merge gate); nothing outside
`Shared/Theme/PhoneType.swift`'s words-scale line, `MobileTextSizeTests` and this record (and the docs naming the
steps); no `Sources/`, editor family or text-input path; no other batch's file.

#### LIVE STATUS

| Piece | State |
|---|---|
| T. The trace, from the window's own log (`/tmp/vm260-win2/P3.log`) | DONE (this commit) — below |
| 1. The pins on the current tree (the red-on-old for this reconcile): the two forms agree at every step; every step a whole point; the face's row preview printed and compared with the SwiftUI form | DONE (`defecf3a9` — **that commit IS the reconcile's red-on-old tree**) |
| 2. The red-on-old bundle `DerivedData/vm260-3r-rol` (an APFS clone of `vm260-2r`, incremental, `nice -n 15`) | DONE — `TEST BUILD SUCCEEDED` at `defecf3a9` |
| 3. The fix: a step's size is a whole point | DONE (`78ed5b4bb`) |
| 4. `vm260-2r` rebuilt on the new tip; the re-evidence's run list | DONE (this commit) — `vm260-2r` and `vm260-2r-mac` rebuilt in place at `78ed5b4bb` (`TEST BUILD SUCCEEDED` each; incremental; `nice -n 15`); the run list below |

#### The trace — H1, a deterministic size-path miss; H2 refuted

The window's failure line, expanded by Swift Testing: `abs(MobileEditorStyle.face.font(.rowPreview).pointSize - 14 *
1.125) → 0.25`. So the face's UIKit row preview at Larger read **15.5 or 16.0**, never 15.75 — and the two lines
before it in the same test passed: the note's body at **18.0** in Iowan Old Style, built by the same face's `scaled`.
- **H2 is refuted by the test's shape and by the number.** `theEditorFaceTakesTheStep` is a synchronous `@MainActor`
  test (no `await` anywhere in it; it ran in 0.008 s), and `MobileEditorStyle`'s live face is main-actor state
  (compiler-enforced), so nothing — no other suite, no other task — can run between its `adopt` and its read. And a
  face another suite had adopted would carry another scale: the default's row preview is 14 (|Δ| = 1.75), not 0.25.
- **H1, traced.** The face's UIKit roles resolve through `PhoneType.uiFont(role, voice:, wordsScale:)` →
  `spec(…, wordsScale:)` → **15.75** for the row preview at Larger (14 × 18/16) → `UIFontMetrics(forTextStyle:
  .subheadline).scaledFont(for: Iowan 15.75)` at the host's default text size. The SwiftUI form of the same role reads
  `PhoneType.pointSize` → `UIFontMetrics.scaledValue(for: 15.75)` = 15.75. **`scaledFont` does not return a fractional
  size unchanged**: a whole-point base passes through it untouched at the default text size (the note's body at 18,
  and every table size — `atTheDefaultSizeEveryRoleIsItsTableSize` pins them, green), while 15.75 came back 0.25 away.
  The same API was measured before landing a third of a point off `scaledValue` (VM-47, `4ec664f2b`: at xxxLarge, for
  the `.footnote` and `.body` anchors, scaledFont 1/3 pt BELOW scaledValue — consistent with scaledFont snapping to a
  whole point; inferred, the grid not measured). So the defect is in this batch's design, not the test: VM-254's steps
  produced **fractional** sizes for every role whose table size × the step is not a whole number — 27 of the 100 (5
  roles × 2 voices × 4 non-default steps; the default is the table) — and at each of them the UIKit form (the editor's
  UIKit roles, the comments sheet's draft, the take browser's and History's titles, Terminal's note body in the editor)
  lands on a different size from the SwiftUI form of the same role, up to half a point. Which grid UIKit snaps to (a
  whole point, or a half) is printed by the pin below: 27 disagreements if a whole point, 25 if a half (Study's note
  title at 17.5 and 22.5 would then agree).
- **The fix's road (P-260-3a amended, not a new design):** a step's size is a WHOLE POINT — `spec(…, wordsScale:)`
  rounds the scaled size to the nearest point before the floor, the pitch moving with the size. A whole-point base
  passes through both forms unchanged at the default text size, so the two forms agree at every step, and the setting's
  numbers are the scale's own kind (whole points, as every size in the sheet). Away from the default text size the UIKit
  form keeps the pre-existing third-of-a-point gap VM-47 measured (not this batch's; unchanged).

#### The pins (the reconcile's; all PENDING the merge gate)

In `MobileTextSizeTests`, on the pre-fix tree `defecf3a9` (bundle `vm260-3r-rol`):
- `everyStepIsAWholePoint` — every role that follows the text size, at every step, both voices, is a whole number of
  points. **RED on the pre-fix tree: exactly 27 issues** (pure arithmetic — Study: note title and screen title at four
  steps each, row preview at three; Terminal: note body and row title at three each, note title and screen title at
  four each, row preview at two). Prints `PERF[sim] VM-254 fractional step sizes — 27: …`.
- `theTwoFormsAgreeAtEveryStep` — at the default text size, `PhoneType.uiFont`'s size equals `PhoneType.pointSize`'s for
  every step, voice and role. **RED on the pre-fix tree at the fractional sizes: 27 issues if UIKit snaps to a whole
  point, 25 if to a half** (Study's note title at 17.5 and 22.5 would then agree). Prints `PERF[sim] VM-254 the two
  forms at the default text size — N disagree: …` with each pair, which settles the grid. **This is the mechanism's
  own pin**; a GREEN here on the pre-fix tree would refute H1 (then the 0.25 is something else — report it, do not
  ship the fix on faith).
- `theEditorFaceTakesTheStep` (MOVED at its line 145): the face's row preview at Larger equals the SwiftUI form's size
  and is 16; prints `PERF[sim] VM-254 the face's row preview at Larger — UIKit …, SwiftUI …, the step's spec …`. **RED on
  the pre-fix tree: 1 issue (UIKit ≠ 15.75) if UIKit read 16, 2 if it read 15.5.**

On the tip `78ed5b4bb` (bundle `vm260-2r`): all three GREEN, and `theFiveStepsScaleHerWordsOnly` (MOVED to the rounded
rule — its expected size is now `max(13, (table × step).rounded())`) GREEN. Unchanged and still green:
`nothingIsEverBelowThirteenPointsAtAnyStep`, `aStepReachesHerWordsOnAMountedScreenAndNotTheChrome` (a row's title in
Study is a whole point at every step already: 14 · 16 · 18 — its printed 19.33 / 22.0 / 24.67 line heights stand),
`aStepChosenOnThePhoneRebasesAnOpenNote` (18), `MobilePhoneOwnLookTests.everyLookChoiceWritesNoSettingRowAndMovesTheFace`
(18), `MobileHerWordsDefaultTests` (the default IS the table — no rounding reaches it).

#### The fix (`78ed5b4bb`)

`PhoneType.spec(_:voice:wordsScale:)`: `size = max(floorSize, (table.size * wordsScale).rounded())` (was without
`.rounded()`); the pitch still moves with the size (`table.lineHeight × size / table.size`). The default (scale 1) is
untouched — the table is returned as it stands. Docs: `PhoneType`'s header and `spec`, `MobileTextSize`'s.

**P-260-3a, amended (the step values, Study / Terminal, at the system's default text size — Smaller · Small · Default ·
Large · Larger):** note body 14 · 15 · 16 · 17 · 18 / 13 · 13 · 14 · 15 · 16; note title 18 · 19 · 20 · 21 · 23 / 16 · 17
· 18 · 19 · 20; screen title 17 · 18 · 19 · 20 · 21 / 15 · 16 · 17 · 18 · 19; row title 14 · 15 · 16 · 17 · 18 / 13 · 13
· 14 · 15 · 16; row preview 13 · 13 · 14 · 15 · 16 / 13 · 13 · 13 · 14 · 15. Where the floor meets a step two steps
read the same (Terminal's body and row title at Smaller and Small; the row preview at the two smallest, and Terminal's
at three) — the floor's own consequence, recorded. Halves round up (17.5 → 18, 22.5 → 23).

#### Run list for the merge gate (nothing builds in the window; `nice -n 15`, incremental)

- **R-b3r — red on the pre-fix tree** (`DerivedData/vm260-3r-rol`, tree `defecf3a9`):
  `-only-testing:VariorumMobileTests/MobileTextSizeTests` — predicted RED: `everyStepIsAWholePoint` (27),
  `theTwoFormsAgreeAtEveryStep` (27 or 25 — read its PERF line), `theEditorFaceTakesTheStep` (1 or 2); GREEN:
  `theFiveStepsScaleHerWordsOnly` (the old rule, as it was), `nothingIsEverBelowThirteenPointsAtAnyStep`,
  `aStepReachesHerWordsOnAMountedScreenAndNotTheChrome`, `aStepChosenOnThePhoneRebasesAnOpenNote`.
- **The tip** (`DerivedData/vm260-2r`, code tip `78ed5b4bb`): the gate's whole phone target carries it — predicted green
  but main's 6 known issues; `MobileTextSizeTests` all 7 green. The Mac legs (`DerivedData/vm260-2r-mac`, rebuilt at
  the same tip — `PhoneType.swift` is shared and compiled there, one `.rounded()` and comments) predicted as M3: green
  but `IndexTierMetricsTests`' 4 declared. The UI bundle is untouched by this reconcile (no default size moved: the
  default is the table, unrounded and unchanged), so U3's green stands.


## BATCH 3b — record (VM-281 · F-her-1; implementer: Opus, a fresh session, 2026-11-25)

**What this batch did NOT do (kept current):** NO test has run — the stage is coordinated through nov24 and this
batch's evidence rides the run's merge gate, so every red and green below is PENDING; no walk and no capture (the
gate's); no line in `Sources/`, `Sync/`, custody, `StatusCenter`, `VoiceTokens`, `MobileKeyboardBar` (its numbers
R22/R25 untouched), the typed-Return model, crystallization or `BlockRangeIndex`; `MobileKeyboardFloor` STAYS (the
class guard); the throwaway walk driver (`~/dev/variorum-vm260-walk/…/VM260WalkDriver1a.swift`) was read, never
copied into the tree.

### LIVE STATUS

| Piece | State |
|---|---|
| 0. Preflight (CLAUDE.md + canon; this record's binding sections, Batch 3b, F-1a-W1, the two windows; SurfaceContracts "The app" and the note's editor bullets; TEXTKIT2_NOTES in full; the resiliency protocol) and the two traces (below) | DONE (this commit) |
| 1. VM-281's pin — a UI test on the road that REPRODUCED (the 1a walk's order): `MobileKeyboardRevealUITests.testTheBarRidesAboveTheSearchKeyboardOnTheWalksRoad` | DONE (this commit; compiled at piece 3) — the run PENDING the gate |
| 2. F-her-1's pin (+ the behaviour-neutral rename of the picking door's word static, so the pin's text is byte-identical on both trees): `MobileBlockSelectionTests.whilePickingTheHeaderNeverDrawsOneWordOnTwoDoors`; `doneSelectingTitle` → `pickingExitTitle` (still "Done" here) | DONE (this commit — **this commit IS the red-on-old tree for BOTH pins**) — the run PENDING the gate |
| 3. The red-on-old bundles at piece 2's commit: the UI bundle `vm260-3b-rol-ui` (APFS clone of `vm260-2r-ui`) and the unit bundle `vm260-3b-rol` (clone of `vm260-2r`), incremental, `nice -n 15` | NOT-STARTED |
| 4. VM-281's fix — the editor drops its keyboard bar as it resigns and puts it back as it becomes first responder | NOT-STARTED |
| 5. F-her-1's fix — the picking door reads "Cancel" (PROVISIONAL P-260-3b-1) | NOT-STARTED |
| 6. The trio rebuilt on the tip (`vm260-2r`, `vm260-2r-mac`, `vm260-2r-ui`), incremental, `nice -n 15`; READY-FOR-TESTS | NOT-STARTED |

### VM-281 — the traced mechanism (re-traced in this session; the F-1a-W1 trace re-read, not adopted on trust)

**What the pixels and logs say the 52 is** (read this session: the reproduction's captures
`/tmp/vm260-win/W1aold-shots` s5 and s9, and the hollow pin's log `/tmp/vm260-win/RW1.log`):
- The note's keyboard (s5, and RW1's note leg): the editor's bar stands **487–539** (its ⋯ cell at y 496.67, 29 tall),
  the keyboard's candidate strip **539–583**, its key plane from **583** — XCUITest's keyboard element reads
  `(0, 583, 402, 233)` on the note's keyboard AND the search's alike, so the two keyboards are the same keyboard.
- The search's keyboard on the walk's road (s9): the band's foot — the one bar's bottom — at **591**: 52 below the
  keyboard's true top (539), and 8 below the key plane's top (583). **So the shortfall is the accessory's 52, not a
  lost candidate strip** (a keyboard reported without its suggestion bar — the shape Apple forum thread 798087
  reports on iOS 26 — would put the foot at 583, 44 short). Both readers SwiftUI's avoidance and UIKit's keyboard
  layout guide carry it (the consolidated window's reproduction row: the floor fix does not lift the band on this
  road).

**What our code does on the road** (read this session):
- The accessory is installed ONCE, at construction — `MobileEditorTextView.make()` → `applyVoiceChrome()` →
  `inputAccessoryView = keyboardBarController.makeBar()` — re-installed only at a voice switch, and **never removed
  for the text view's life**.
- The road: the Library's New Note glyph → `onOpen(.note(id, focus: true))` → `MobileEditorViewModel.arrive(focus:
  true)` → `textView.becomeFirstResponder()` — the keyboard rises wearing the 52-pt bar (s5). **Back:** SwiftUI's
  NavigationStack pops the Write screen while the editor still holds the keyboard, and **nothing of ours resigns it
  first** — `standDown()` runs only on a tab switch or a liveness grant (`MobileLivenessAuthority`), the Write
  screen's `.onDisappear` runs after the pop, the text view's `willMove(toWindow:)` only records the page's place.
  UIKit takes that keyboard down itself, with the bar still installed in the input views it holds. The Trash and
  two tabs follow with no keyboard; the search's tap is the first FRESH keyboard since.
- The two roads compared: the hollow pin road (the search field held the keyboard when the lesson was pushed, so at
  Back UIKit restored the Library's own input views — `MobileLibraryView.searchField`'s comment names that
  restoration) judged GREEN on old; the walk's road (no responder on the Library when the note was pushed; the
  note's keyboard taken down at Back; a fresh keyboard three screens later) RED on old. **The stale 52 shows on a
  fresh presentation after a keyboard UIKit took down while it wore the accessory**; a restore did not show it.

**External facts (fetched this session; forum reports, no Apple document):** Apple Developer Forums thread 802159
(FB20386257, iOS 26.0, device and simulator): a focused text input that wears an input accessory (a web view's form
bar) dismissed with its screen while its keyboard is up; then "tapping any `TextField` causes the keyboard to cover
bottom controls … Insets are ignored until the keyboard is dismissed and reopened"; the DTS answer: "I suspect this
may be related to a known issue"; the reporter's later hypothesis: "saved keyboard calculation inputAccessoryView
frame"; no workaround posted and no fix reported through its last post (Feb 2026). Our shape exactly, on the native
side. Apple's `reloadInputViews()` page: it updates the custom input and accessory views **when the object is the
first responder** — UIKit reads a responder's input views at its becoming first responder and at that call, nowhere
else.

**NOT KNOWN (UIKit's private layer; no in-process probe without a run):** which UIKit object keeps the stale accessory
frame, and WHEN it is captured — **(S)** as the responder resigns and its keyboard is taken down, or **(P)** earlier, as
the navigation transition sets the disappearing screen's input views aside before the responder resigns.

**The cure (the fewest lines; an editor-seam line):** the editor's text view **drops its keyboard bar as it resigns** —
`inputAccessoryView = nil` and `reloadInputViews()` while it is still the first responder, then `super` — so the input
views UIKit takes down never carry the bar; and it **puts the bar back as it becomes first responder** (before `super`,
where UIKit reads it). Under (S) this cures the road; under (P) the capture precedes the resign and the pin stays RED on
the tip — and then the next road is NOT another try here: a hook before the transition's will-disappear does not exist
for a text view under SwiftUI's pop, so the cure would be the accessory host's rework (VM-271's) — STOP and report.

### F-her-1 — the traced mechanism

`MobileBlockListSheet.body` → `PhoneSheetHeader(title: "Blocks", done: …)`, whose closing act renders its default
`doneWord`, `tokens.chromeLabel("Done")`; its trailing slot carries PR20's toggle, `Button(tokens.chromeLabel(
model.isSelecting ? MobileBlockSelectionCopy.doneSelectingTitle /* "Done" */ : selectTitle /* "Select" */))`. So in
picking mode the header renders two buttons with the one word "Done" (one ends picking, one closes the sheet). The code
documents the collision itself — the toggle's explicit VoiceOver names exist because of it. Pre-existing (PR20), not
this run's regression.
