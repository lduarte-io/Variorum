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
| Merges of main owed: `ba42ddc53` (PR #26, notes) MERGED at `edae67935` · `1a7b0d444` (PR #28, notes — contains `5ca093319`, PR #27, VX-1013 Protection/AppBootstrap) MERGED at `18b01675e`, 2026-11-25, batch 2's boundary — PR #27 verified in-tree (`merge-base --is-ancestor`); the run's FINAL merge-gate legs run on this tree or later | DONE |
| Linear: VM-260 In Progress | DONE |
| Kickoff sitting: six rulings R-260-1…6 recorded | DONE 2026-11-25 |
| nov24 coordinator announced; its protocol folded in above | DONE |
| Riders re-parented under VM-260; batch 1a members In Progress | DONE |
| Batch 1a (VM-253 · VM-256 · VM-255) | SUITES GREEN; UI test GREEN on the walk device (1/1, 71 s — the Castle-locked no-verdict CLOSED); THE WALK RUN AND READ 2026-11-25 (the orchestrator's read; verdicts below) — every stop PASS in both voices EXCEPT **F-1a-W1, MAJOR, OPEN**: with the Library search holding the keyboard the bar sits ghosted UNDER the keyboard instead of riding above it (SurfaceContracts' bar line; capture `s9-search-keyboard`). Suspected mechanism: the shell's one-bar overlay sits at the band's foot and the band ignores the keyboard (the edge-grounds architecture), where the old in-page bars rode each page's keyboard avoidance. FIX OWED by batch 1a's implementer AT BATCH 2'S BOUNDARY (one writer per tree — batch 2 is live in the worktree); its re-evidence = a contract pin (red on the current tree), the s9 capture re-taken, and the keyboard-reveal UI test again (MobileShellView will change) |
| Batch 1b (VM-265 · VM-275 · VM-277 + A-260-1's direction line) | BUILT, READY-FOR-TESTS 2026-11-25 (tip `ca9a8d7be`; adjudications A-260-3…8; the editor-spoken refusals' authored headlines deferred to VM-279, the clip standing in). PENDING: the one window — two red-on-old trees, the tip, the Mac legs, the line's 7-stop walk |
| Batch 2 (VM-273 · VM-272) | BUILT, READY-FOR-TESTS 2026-11-25 (code tip `ae12e4276`, READY `17775aa42`; red-on-old tree `f99f20818` in `vm260-2-rol`; tip bundles `vm260-2`/`-mac`/`-ui` prebuilt; adjudicated A-260-9 — the set accepted PROVISIONAL, VM-280 filed). PENDING: the window |
| Batch 3 (VM-247 · VM-254) | NOT STARTED |
| Batch 4 (VM-259: design → pick → build) | NOT STARTED |
| Ladder · gate · walk | NOT STARTED |
| Closeout (canon deltas, #281 dispositions, #277 leftovers touched by this run, parity row, handoff) | NOT STARTED |

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
  system bar sits above), below 8 → 4. **158 → 136 pt at one chip row** (202 → 180 wrapped).
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
