# VM-47 — Run: Sizes and look (mobile catch-up, wave 1, umbrella 1)

**Ticket: VM-47 (team VM) · Project: Mobile — the catch-up & launch · Branch: `vm-47-sizes-and-look` ·
Worktree: `~/dev/variorum-vm-47` (Pro)**

**STATUS: OPEN 2026-11-19** (overnight; `/run-phase vm-47`; the stage coordinator is the session `nov18`).

## FOR A LATER READER

PENDING — written at closeout from the settled facts (the mechanism as settled, what was built with one
pointer per piece, her rulings by id, the evidence lines that matter, the open items). Until then the
sections below are the working record.

---

## 1. Kickoff

Her words at this kickoff (2026-11-19), verbatim: "i want to get everything set up for an overnight
session" · "the whole issue is that i need to use my weekly limit up before tomorrow" · "i want one claude
coordinator named nov18, then i want all the VM in the first wave launched with instructions to talk to stage
coordinator nov18, i want the vx-981 and vx-980 added too. and add the high priority (private eye not shown on
journal) to one of those runs - maybe the MCP run, since it deals with the private mark."

Wave 1's four umbrellas (VM-47, VM-55, VM-64, VM-78) run together, each in its own worktree. An ask that
needs her hands is held and bundled for her next sitting while everything that does not depend on it
continues.

**Her words later the same sitting (2026-11-19), verbatim, in order:**

- On the five batches and the review: "yeah that's fine on the five sequential batches - you can do a midway
  through review it if you prefer. also - up to 5 rounds as long as a major is found." So, for this run: a
  midway cold review is taken after batch 2 (the layer and the controls, before the screens build on them),
  and the ladder runs up to five rounds while a round still finds a MAJOR. CLAUDE.md's standing cap of three
  is unchanged for other runs.
- On the phone: "ok i talked to vm-64 about that and resolved the previous install blocker with vm-55. now,
  i'll plan to have the wave 1 build installed on my phone after the last vm has merged in, by the last one.
  sound good? the phone step is the single wave-1 install after all four runs have merged. whoever is last
  can probably do it overnight over wifi." The install runbook
  (`notes/plans/vm-44/plans/vm-45-install-runbook.md`) needs her at the phone (unlocked and awake for the
  safety copy and the install, Variorum fully quit first), and wifi is untried there. So the last merger
  prepares overnight — a Release device build of merged main, signing verified, main's sync version checked
  against production's — and the install itself is hers to start.
- The two calls put to her (R-47-1, R-47-2 in §5): "grounds - prose should not be on the tint, which is what
  I understood you mean. that sounds good. voice only row - yeah, that's fine. also - agreed, i'll do the
  hands part in the morning."
- Leaving for the night, relayed by the coordinator (her words to it, 04:16): "ok i'm off the mac. variorum
  is closed. i'm leaving for overnight. good luck with everything, tell all my sessions that i'm off, rule
  provisionally in my absence, i'll check in in the morning (which is depressingly soon)."

**Cast (CLAUDE.md's standing rule; she named none at this kickoff):** Fable orchestrates; ONE Opus
implementer per batch (`opus-implementer`), strictly sequential; the cold review is `fable-reviewer`, because
the diff changes the editor's face values (`MobileEditorStyle`) and a default's meaning (the phone's voice).
A fresh reviewer per ladder round, three rounds at most.

**The roster (the sub-issue listing of VM-47, read from Linear at kickoff — eight members):**

| Ticket | Title | Rows | Batch |
|---|---|---|---|
| VM-48 | Text at phone sizes that grows with the system text size | W-001, W-004, W-024 | 1 |
| VM-49 | Room to tap: one spacing scale and 44 pt touch targets | W-002 | 1 (the constants) · 2 (the application) |
| VM-50 | One set of phone controls: buttons, fields, sheet headers and choices | W-003 | 2 |
| VM-51 | The phone wears the library's voice and palette | W-005, W-006 | 3 |
| VM-54 | Borders keep their old colours after a light or dark switch | W-172 | 3 |
| VM-52 | The bottom bar: three words on a chip with real tap areas, on every root and list | W-007, W-009 | 4 |
| VM-53 | Settings as one scrolling, grouped list, reachable from every screen | W-211, W-008, W-213 | 5 |
| VM-27 | The phone's Settings sheet shows two "Protection…" rows stacked | W-217 | 5 |

**Sizing note (PhaseSizingGuidance — guidance to raise):** the umbrella holds more than two phase-sized
units (the app-wide type pass, the controls, the palette). She approved the composition as a run
("22 is fine, composition is fine."), so it runs as five sequential batches, one implementer session each,
one ladder over the whole diff. Raised in the handoff, not split.

## 2. What binds every batch

Read these yourself, in full, before touching code (reading is never delegated):

- `CLAUDE.md` and its loaded canon; `notes/SessionResiliencyProtocol.md` (the checkpoint protocol binds from
  the first commit); `notes/MobileSoul.md` §3–§5.
- `notes/plans/vm-44-mobile-catch-up-plan.md` ("The rules every umbrella inherits");
  `notes/plans/vm-44/plans/sitting-1-rulings.md`; `notes/plans/vm-44/her-words.md`.
- `notes/plans/vm-44/design/sketches/sizing-sheet.html` — the base. Open the file and read its text and
  tables; the role table, the touch rule, the spacing scale and the two corrected inks are the numbers.
- `notes/plans/vm-44/audit/G-visual-metrics.md` — the site inventory (type §1, targets §2, spacing and
  components §4, platform fit §5, Appendix A the per-file line lists).
- The member tickets' own text (quoted in each batch below) and the mockup each names.

Rules:

1. **The Mac must not change.** `Shared/Theme/VoiceTokens.swift` is not edited; every Mac token pin stays
   byte-identical; no Mac view changes its look. A file added under `Shared/` compiles into the Mac — keep
   phone-only UIKit code behind the platform check the folder already uses.
2. **Brains in `Shared/` or Core, faces on the phone** (MobileSoul §3). The phone never forks a brain.
3. **Her rulings govern; where they are silent, nothing is invented.** Write 2–3 options into this file's
   PROVISIONAL list (§5), build the most defensible one (the Mac's own behaviour first, then the sizing
   sheet), mark it PROVISIONAL. The sizing sheet's numbers were seen by her in use and not ruled one by one:
   built as drawn, they are PROVISIONAL as a set (P-47-1).
4. **Copy:** rendered words are short, plain, sentence case, never capitals for emphasis. Reuse the Mac's
   words where a Mac face exists. A new line that is a draft in `notes/plans/vm-44/design/wording-list-*.md`
   ships as drafted and is listed in §5 for her wording pass. Terminal keeps its lowercase chrome (LK-6).
5. **Pin before fix, per member.** Each bug-class change lands with a red-on-old pin verified by revert
   (commit before you revert; name the revert in the LIVE STATUS before starting it). New brains land with
   Swift Testing tests. A pin green on both sides is recorded as hollow, not fixed.
6. **Other runs are live in the same files.** VM-55 (listing call sites, pickers, the message line), VM-64
   (the editor seam, the Library's reads, the capture box) and VM-78 (Shelf files, `MobileWriteView`,
   `MobileEditorViewModel`, book doors) are building now. Keep edits line-level and narrow; never reformat or
   reorder a file; do not rename a symbol another run would also touch unless this record says so.
7. **The editor seam is not this run's.** `MobileEditorTextView.swift`, `MobileEditorViewModel.swift` and
   `Shared/EditorBrain/` change only where a batch below names the exact constant; anything more is recorded
   and left for VM-137 (Writing).
8. **The stage.** `swift build`/`swift test` and `xcodebuild build`/`build-for-testing` run freely. EVERY
   `xcodebuild test` and every simulator boot needs a stage GO, which only the orchestrator obtains from
   `nov18`. So: build, then END YOUR TURN with a report that says "READY for the stage" and gives the exact
   command list (suite TYPE names for `-only-testing`, as a zsh array). Never start a test run, boot a
   simulator, or claim the stage on your own. The orchestrator sends the GO with the claim line; then run in
   the foreground, release, and report executed counts, every failing test by name, the simulator shut down,
   and no Variorum instance left.
9. **Commands.** From `App/Variorum/`: `xcodebuild -scheme VariorumMobile -destination
   'generic/platform=iOS Simulator' -derivedDataPath DerivedData/vm47-bN build-for-testing`; tests run
   `test-without-building` against the standing phone-suite device (iPhone 17 Pro, iOS 26.2), addressed
   by the UDID the orchestrator gives with the GO (never written into the repo), `-only-testing` by suite
   type. Never add a build configuration.
   Core: `swift build`, `swift test --filter Name`. One DerivedData folder per batch; delete the previous
   batch's once yours builds.
10. **The checkpoint protocol.** Commit per coherent piece and push after every commit (plain pushes; no
    trailer of any kind on commits). Keep this batch's LIVE STATUS table (§4) true in the same commit as each
    piece: `DONE (hash)` · `IN-PROGRESS — exactly what remains` · `NOT-STARTED`; unverified claims say
    PENDING. Foreground waits only. Past roughly 400k tokens of context, stop at the next committed seam and
    report what remains.
11. Do not spawn subagents or use the Agent tool, with one exception: you may run at most ONE Sonnet lookup
    subagent at a time (spawn it with `model: "sonnet"`), strictly for external facts — web searches, Apple
    documentation, API signatures/availability. It returns facts and quotes; it never edits files and never
    spawns agents of its own. Never delegate reading of the repo's docs, the phase plan, code, or the diff
    under review — do that reading yourself, in this session.

**Evidence a batch closes on:** its tests green with executed counts, and a simulator walk of the screens it
changed — Study and Terminal, light and dark, the default and the largest text size — captured to
`notes/plans/vm-47-screens/` (gitignored; the `.gitignore` line lands with this record). The
planning walk's method is in `notes/plans/vm-44/atlas/` (`screen-inventory.md`, `walk-findings.md`). Walks
run on a dedicated simulator device the walk creates inside its stage claim and deletes at the run's close,
so the shared suite device keeps its settings.

## 3. The batches

### Batch 1 — the phone layer: type, inks, metrics (VM-48; VM-49's constants)

VM-48, the ticket: "Most of the phone's chrome text is the Mac's small 11.5 pt caption size (241 of 352 type
sites); in Terminal nearly all of it ignores the system text size; and in light mode the muted and faint ink,
and the field fills, are hard to see. The phone needs its own type layer (13 · 15 · 17 · 20 · 24) over the
shared tokens, with readable muted text, without changing the Mac." Her direction: "just use the mac app as
your visual direction. the study mode especially. the sea greeen theme" — the Mac's look at phone-right sizes,
"aside from how everything is weirdly small and spaced".

Build:

1. **The type roles** — one phone layer in `Shared/Theme/`, resolved from the voice, per the sizing sheet's
   table ("How it is expressed: a phone layer over the shared tokens"): `noteBody`, `noteTitle`,
   `screenTitle`, `rowTitle`, `rowPreview`, `meta`, `sectionHeader`, `chip`, `controlInline`, `control`,
   `tab`, `mono`, each with its size, line height, Dynamic Type anchor and cap. Study is the sheet's numbers;
   Terminal takes the same roles in SF Mono with its prose roles two points under Study's (15 · 22 · 18 for
   body, note title, screen title). SwiftUI and UIKit forms of each role, from one table.
2. **Two scaling classes.** Her words scale across the whole range; chrome scales to xxxLarge and holds.
   Nothing on the phone is set below 13 pt.
3. **The two corrected inks** (sheet §D): phone-layer `muted` and `faint`, the voice's own hue taken darker
   until muted clears 4.5:1 and faint 3:1 on every light room the app ships (the sixteen palettes and the two
   Classic rooms), in both voices; dark needs only faint lifted. Pin the floors with a test that computes the
   ratios over every palette and voice. The Mac's `muted`/`faint` are untouched. A selected row's meta line
   takes the ink.
4. **The metrics constants** (VM-49's brain, beside the type layer): the spacing scale 4 · 8 · 12 · 16 · 20 ·
   24 · 32 · 48, the gutter 20, the radii 6 · 12 · capsule, the row minimums 44 · 52 · 64 · 88, the 44 pt
   touch minimum, and one helper that gives a control its 44 × 44 hit area without changing its drawn size.
   Constants and the helper only; applying them is batch 2.
5. **Every phone type site reads a role.** The 352 SwiftUI `.font(` sites and the UIKit font assignments
   (audit G §1.2–1.3, Appendix A) move from `tokens.small/body/title/heading/mono` and literals to the role
   each one IS — the sheet's "Replaces today's" column and role descriptions decide. `Spike/` and `Perf/`
   are out. The Read page follows the sheet's "Reading page" row. The protection glyph literals (28, 30)
   stay. Where a site's role is unclear, choose the smaller of the two candidates and list the site in §5.
6. **The editor's face** (`Write/MobileEditorStyle.swift`, face values only): note body per the sheet
   (Study Iowan 17, line 27, paragraph gap 14; Terminal by the two-under rule), still through
   `UIFontMetrics`. The text inset in `MobileEditorTextView` is NOT changed in this batch.
7. **W-024 — the shelf's layout arithmetic.** `MobileShelfLayout.smallLineHeight = 14` and everything derived
   from it are re-derived from the roles (the sheet: 18 for a meta line, 24 for the quick-entry line), with
   its pins moved in the same commit against the real fonts. The quick-entry box's typed text becomes the
   note body. Its hint must not clip at the new size: prefer a rule that fits or wraps the existing words;
   new hint words only if a draft exists in the wording lists, and then PROVISIONAL. The box's shape and
   behaviour are umbrella 5's (SW-3, SW-4) and do not change here.

Tests: the role table (sizes, anchors, caps, both voices); the ink floors; the metrics; the Mac's token pins
untouched and green; `MobileShelfLayoutTests` re-derived; a guard pin that no phone view file outside
`Spike/` and `Perf/` reads `tokens.small` or sets a literal size under 13 (a source scan, like the repo's
other source pins).

Not in this batch: touch targets on existing controls, the shared controls, palette or voice, the bar,
Settings.

### Batch 2 — one set of phone controls, and room to tap (VM-50; VM-49's application)

VM-50, the ticket: "The phone has five separately built "calm buttons", three field builds, ten hand-rolled
sheet headers, and rows of plain words standing in for segmented choices; the bare 11.5 pt text buttons are
the tiny affordances she named. One shared set of controls replaces them." Agent note: "There is no Picker,
Toggle or List anywhere in the phone app today; prefer the system controls, styled by the layer."
VM-49, the ticket: "103 of its 107 tappable controls are smaller than 44 pt … The phone gets one spacing
scale and a 44 pt minimum for every target." Agent note: "The shared controls (VM-50) carry most of the 103
sites; the screens later umbrellas rebuild adopt the scale as they go."

Build: the shared phone controls on batch 1's layer (sheet §B and §E): the text button (label 17, 64 × 44
minimum), the inline act (15), the icon button (22 pt glyph, 44 × 44), the chip (capsule 32, hit 44), the
field, the calm button (one, replacing the five of audit G §4.4 item 3), the sheet header (title 20, Done
semibold 64 × 44; the ten SwiftUI copies of T72 adopt it), the segmented choice (the system control, styled;
the five word-rows of §4.4 item 7), the section header, the menu row (52 minimum). Then adopt them at every
site audit G §2 lists that is one of these kinds, and give every remaining tappable site in G §2 its 44 pt
hit area through the batch-1 helper where that is a one-line change. The spacing scale replaces one-off
padding values on the lines this batch already touches; the screen gutter becomes 20.

The three hand-built UIKit overlays (takes, comments, block history) keep their structure (native sheets are
VM-152's): their Done and row acts get 44 pt hit areas only. The formatting strip's 28 pt acts are her ruled
exception (R22/R25; LK-3 is VM-139's). The note's masthead is rebuilt by VM-148: its icons and chips get hit
areas here, not a new layout. The editor's text inset (15 → 20) is one constant in `MobileEditorTextView`;
change it only if it is exactly that, with its pin, and say so in the report — otherwise record it for
VM-137.

**Carried in from batch 1 (orchestrator, at the batch-1 seam):**

- *The path line wraps in Terminal.* Batch 1 set the Shelf's and Library's path-line doors ("+ New Note",
  "Settings", the 🗑) at the 17 pt control role; beside the 13 pt path, Terminal's mono line needs about
  437 pt and wraps at 402 and 430 pt (Study fits), which made the chrome above the books 23 pt taller. The
  sheet's own words are "Inline acts inside a row: 15". Resolve it in this batch's control adoption: the
  path line's doors are inline acts (15) or icon buttons with 44 pt hit areas, the line stays ONE line at
  402 pt in both voices, and a geometry pin holds that. Settings leaves the path line in batch 5 (the ⋯
  menu); do not move it now.
- *Batch 1's two fixes are PENDING their re-run* (the UIKit chrome's hold at xxxLarge, `4ec664f2b`; the
  keyboard-sized shelf pin, `29f2cbd41`). The orchestrator runs that re-run in a short stage window while
  this batch builds; if it comes back red the orchestrator hands the red to this batch's implementer.
- *One walk covers batches 1 and 2.* The driver and runbook are in
  `notes/plans/vm-47-screens/instruments/` (gitignored: `VM47WalkDriver.swift`, `walk.zsh`, each with a
  cold-use header), built into `DerivedData/vm47-walk`, for the device `vm47-walk`. This batch's implementer
  extends the driver for the surfaces it changes (new accessibility identifiers, the sheet header, the
  segmented choice) and runs the walk in its own stage window at the batch's end: the core screens in all
  eight combinations of Study/Terminal × light/dark × default/largest (AX5), the rest at Study light
  default, Terminal dark default and Study light largest — the list is in §6 "Batch 1 — results".
- *The keyboard bar's 14 pt chrome* stays as it is (VM-138/VM-139 own the bar's shape and glyph sizes); its
  three resting cells are already 62 × 48.

Close with the honest inventory: a table in §6 of every G §2 site (T1–T109) — adopted a shared control ·
given a 44 pt hit area · left, and which open ticket owns it. No site is left without an owner.

Tests: each control's hit area and minimum size (geometry tests in the style of
`MobileFilterRowGeometryTests`), the sheet header, the choice control's selection contract; a source pin
that the retired private button/field/header builds are gone.

### Batch 3 — the library's voice and palette; borders that follow the switch (VM-51, VM-54)

VM-51, the ticket: "The phone always shows the Classic colours while her Mac shows sea-glass, and it defaults
to Terminal on its own unsynced switch while a fresh Mac library opens in Study." Her ruling (LK-1, LK-2):
"follow the library but if the phone has dark mode on, that shouldn't change what your mac is like (the
device dark mode)" — voice and palette follow the synced library; light or dark stays each device's own.
Agent notes: hoist `ThemeStore` to `Shared/` (QUESTIONS #199; `PaletteDerivation` is already shared); every
token read moves from the palette-less two-parameter resolver to the Mac's settings road
(`VoiceTokens.resolve(settings:dark:)`); the ★ reads the star token, not accent; QUESTIONS #195 MINOR 3 (the
unsynchronised `MobileEditorStyle.voice` global) is closed by the same move.

Build: the hoist (the Mac keeps its behaviour and its tests byte-for-byte; a move, not a rewrite); the phone
resolves voice, palette and tint from the library's synced settings, observed, so a change made on the Mac
arrives on the phone; a store with no palette wears the sea-glass (AppSpec §12); `MobileVoicePreference`
retires — the phone keeps no voice of its own. Whether the phone shows a voice row that writes the library's
voice is left to the build by the ticket: options (a) no row, (b) a row that writes the library's synced
voice as the Mac's Settings does. Build (b) — RULED (R-47-2): "voice only row - yeah, that's fine." The
grounds follow the Mac's rule as the sizing sheet draws it (content panes on the paper, `tokens.surface`;
bars, sheets and section bands on the room) — RULED (R-47-1): "grounds - prose should not be on the tint".
The ruling's test is her prose: wherever her words are read or written (the note in Write, a book's Read
page, list rows and previews, take cards) the ground is the paper, in light and in dark, under every
palette. Build it at the screens' and sheets' background lines; a surface where that is more than a
background line is listed in §6 with its owner, not rebuilt here.

VM-54, the ticket: "The borders on take cards, the takes pill and the comment draft resolve their colour
once and have no hook for an appearance change, so switching between light and dark probably leaves them in
the old colours (inferred from code, not yet seen)." Check first, on the simulator, with the orchestrator's
stage window: if the borders do follow the flip, record the finding as hollow with the capture and change
nothing. If they do not: the fix with a red-on-old pin (the sites: `MobileTakesBrowserView.swift:709, 904` ·
`MobileTakesChrome.swift:460` · `MobileCommentsSheetView.swift:215` at audit time).

Tests: the hoisted store's existing Mac tests green unmoved; the phone's resolution (a settings change
re-resolves; no palette → sea-glass; dark stays local); the star token; the retired preference's key no
longer read (and an old stored value ignored without a crash).

This batch needs the Mac suites that cover `Shared/Theme` and `ThemeStore` in its stage window as well as
the phone's.

**Carried in (orchestrator, at the batch-2 seam):**

- *What is under you.* Batches 1 and 2 and the midway review's fix pass are in the tree: the type roles
  (`PhoneType`), the two phone inks (`PhoneInks`, read as `tokens.phone.muted/faint`; their floors are
  computed over every palette and voice, so they stand under a palette as they are), the metrics
  (`PhoneMetrics`) and the shared controls (`PhoneControls`). §6 holds each batch's results; the midway
  review and its dispositions are `notes/plans/vm-47-ladder-midway.md`. Build screens' grounds and the voice
  row on those controls; add no private button, field or header (a source pin holds that).
- *Build products.* Yours is `App/Variorum/DerivedData/vm47-b3`. Do not build into or delete
  `DerivedData/vm47-b2` (the fix pass's re-run reads it) or `DerivedData/vm47-walk` (batches 1 and 2's walk
  reads it) until the orchestrator says each is finished. For this batch's own walk, extend a COPY of the
  driver and build it into `DerivedData/vm47-walk3`.
- *The fix pass's stage window is pending* (the 13 pt floor in `PhoneType.uiFont`, `8bea26402`, its
  red-on-old in a snapshot). The orchestrator runs it and hands this batch's implementer the result lines to
  record in `notes/plans/vm-47-ladder-midway.md` §2 and §4's M rows.
- *The voice row's place.* Settings is rebuilt in batch 5. Here the existing two voice rows in
  `Shell/MobileSettingsView.swift` simply become the door that writes the library's voice (R-47-2), through
  the same operation or setting write the Mac's Settings uses; no new row design.
- *Other runs' files.* VM-55 is hoisting the status seam and the wing state through `Shared/AppSession.swift`,
  `Shared/AppBootstrap.swift` and `Shared/WingState.swift` tonight. If the theme store's wiring needs a line
  in one of those, keep it to that line and name the file and line in the report, so the merge can be
  planned.
- *The Mac suites this batch owes at its window:* every Mac test type that constructs or reads the hoisted
  theme store (grep the Mac tests for it and list the types), beside the seven theme types. The whole Mac
  target runs at the merge gate.

### Batch 4 — the bottom bar (VM-52)

The ticket: "The bar is three 11.5 pt words about 14 pt tall, the inactive ones faint, and it disappears on
every pushed screen, so changing room means backing out first. Pushed screens also keep an empty system bar
with a back chevron above the app's own masthead." Her ruling (LK-5): "Words on a chip" — three words at
17 pt (Starred · Bookcase · Library), the current one on a chip, 56 pt targets; shown on roots and lists,
hidden inside a note ("Roots and lists, not notes"). The Shelf is called Bookcase (SW-1). Mockup:
`notes/plans/vm-44/design/mockups/home-wings-capture.html` (the bar). W-009 is inferred from code: look on
the simulator first; fix what is seen. Files: `Shell/MobileShellView.swift`, `Shell/MobileShellBand.swift`,
`Shell/MobileShellRouter.swift` — narrow edits; the lock's relock landing and the wing band live there too.
Face only.

### Batch 5 — Settings (VM-53, VM-27)

VM-53, the ticket: "Settings is a fixed stack that cannot scroll, nearly every row is a 14 pt tall word, and
only the Shelf has a door to it (Library, Starred and Write have none). It becomes a scrolling, grouped list,
reachable from every root and from a note, with a light · dark · follow-the-system choice for this phone."
Her ruling: light or dark stays each device's own (LK-1, LK-2). Mockups:
`notes/plans/vm-44/design/mockups/lock-and-protection.html` (S1–S3) and `home-wings-capture.html` (the ⋯
menu on a root: one menu on all three roots, carrying Settings; later umbrellas add their doors to it). This
ticket is the list's shape and its doors; the writing and document rows are W-212's.

VM-27, her report: the sync row's own Protection… door renders directly above the standing Protection… row,
so the sheet says the same word twice whenever the sync row is in a doored paused state (locked / not-yet).
Trace which door stays (the ticket's lean: the standing row, since on the phone it is always on the same
sheet); pin red-on-old; her glance is owed on which one stayed (held for her sitting).

## 4. LIVE STATUS

| Batch | Piece | State |
|---|---|---|
| 0 | Kickoff: worktree, branch, in-flight row (main `635f7b93f`), VM-47 In Progress, announced to nov18 | DONE |
| 1 | The phone layer: type, inks, metrics (VM-48; VM-49's constants) | IN-PROGRESS — pieces below |
| 1.1 | The layer in `Shared/Theme/`: the role table (both voices, SwiftUI + UIKit forms, two scaling classes), the two corrected inks (derived, floors pinned over every palette and voice), the metrics constants and the 44 pt hit-area helper; its tests | DONE (`f5e21610d`, amended `340603f56`) — `PhoneType.swift` · `PhoneInks.swift` · `PhoneMetrics.swift` · `MobilePhoneLayerTests.swift`; phone `build-for-testing` green; tests PENDING the stage |
| 1.2 | Every phone type site reads a role — one commit per screen family (Shell · Write sheets · Takes/Read · Protection · the UIKit overlays) | DONE — Shell `ccd481162` · Write `76e34188c` · Read/Lenses `df8b334d2` · Protection + shared pages `841c9362b` · UIKit overlays `7cd8b866f`; the shelf screen rides 1.4; the keyboard bar's 14 pt chrome DEFERRED to VM-137 (its bar shape is LK-4/LK-3's); phone `build-for-testing` green; tests PENDING the stage |
| 1.3 | The editor's face (`MobileEditorStyle`, face values only: note body per the sheet) | DONE (`575bb8677`) — body = the `noteBody` role (Study Iowan 17, Terminal mono 15) through `UIFontMetrics(.body)`; paragraph gap 14 / 12 and line pitch 27 / 25, both scaling with the body; `MobileVoiceTests` pins moved; the text inset NOT changed; phone `build-for-testing` green; tests PENDING the stage |
| 1.4 | W-024: `MobileShelfLayout` re-derived from the roles; the quick-entry text is the note body; the hint fits; pins moved | DONE (`6b02c806c`; the filter row's floor and its pins `c1e80f315`) — `quickEntryLineHeight` 24 + `metaLineHeight` 18 replace `smallLineHeight` 14; `bookRowHeight` 44, `writingBoxChromeHeight` 60, both derived on the page; the floor and the collapsed box take the box's line AT THE CURRENT TEXT SIZE (`split(…, lineHeight:)`); the box types `noteBody` on its 24 pt line; the hint shows the longest of its own cuts that fits (P-47-6); the shelf's sites read roles; `MobileShelfLayoutTests` moved + 3 new pins; phone `build-for-testing` green; tests PENDING the stage |
| 1.5 | The source-scan guard pin (no `tokens.small`, no literal under 13, outside `Spike/`/`Perf/`) | DONE (`bb30a4132`) — `MobilePhoneTypeSourceTests` (3 tests): no Mac type slot, no literal size or caption style under 13, no literal `minimumScaleFactor`; its patterns measured red on `fe85ea6d5` (332 slot reads, 32 sub-13 sites) and clean now; GREEN (the 04:40 whole-target run, and again in batch 2's phone leg, row 2.8c) |
| 1.6 | Both schemes `build-for-testing` green → READY for the stage → the stage window: suites + walk captures | DONE for the suites (rows 1.6c–1.6d); the walk MOVED to batch 2's seam (row 1.6e) |
| 1.6b | CUTOVER (orchestrator, machinery honesty): the batch-1 implementer ended its turn READY at about 650k tokens of context, every piece committed and both schemes building. The stage window (suites, any reds, the walk) goes to a FRESH closer briefed from this record, not to the long session | the closer adds its rows below |
| 1.6c | The suites, leg 1: the whole phone target (`-only-testing:VariorumMobileTests`, test-without-building from `DerivedData/vm47-b1`, the standing device) | DONE (run by the ORCHESTRATOR under its own claim — the GO reached it while the closer was still reading) — **883 tests in 145 suites, 19 issues including 8 known** (XCTest "Executed 0"; nothing skipped); three reds, each dispositioned in §6: VM-24's caret suite (not this batch's, nothing changed) · `chromeHoldsAtXXXLargeWhileHerWordsKeepGrowing` (a real defect in the UIKit road, FIXED `4ec664f2b`) · `writingKeepsItsShareUnderAKeyboardSizedRegion` (the pin's denominator carried the path line; the pin MOVED to the rule's room, `29f2cbd41`). Both schemes `build-for-testing` green at `29f2cbd41`. **The targeted re-run (orchestrator, 05:26, `DerivedData/vm47-b1` at `29f2cbd41`, the standing device): "Test run with 118 tests in 12 suites passed after 60.571 seconds with 4 known issues", `** TEST EXECUTE SUCCEEDED **` — `chromeHoldsAtXXXLargeWhileHerWordsKeepGrowing()` and `writingKeepsItsShareUnderAKeyboardSizedRegion()` passed; the 4 known issues are P-47-7's two filter-row pins; `MobilePhoneTypeSourceTests` left out (it scans sources batch 2 is editing; green in the 04:40 whole-target run). Batch 1's suites are CLOSED; its walk rides batch 2's.** |
| 1.6d | The suites, leg 2: the Mac's `Shared/Theme` suites (`ThemeTokenTests PaletteDerivationTests NoLiteralColourTests SharedPageStyleTests PaletteReachTests MarkdownPaletteWritersTests HelperWindowThemeTests`) | DONE (orchestrator) — **42 tests in 7 suites passed**, `** TEST EXECUTE SUCCEEDED **`, no red. The red-2 fix touches only `PhoneType.swift`'s `#if os(iOS)` arm, so the Mac leg stands (Mac `build-for-testing` green at `29f2cbd41`) |
| 1.6e | The walk: a dedicated device `vm47-walk` (iPhone 17 Pro, iOS 26.2; created by the closer, never booted; its id lives in the reports, never here), seeded from a fresh install through the app's own doors (a first write lands the Journal and the sample book; the Debug pocket guide gives chapters, a three-take block and a tag; one note to the Trash; a saved version; one comment), driven by a THROWAWAY XCUITest driver kept with its runbook in the gitignored `notes/plans/vm-47-screens/instruments/` (`VM47WalkDriver.swift`, `walk.zsh` — each with a header that says how to build and run it cold, the device, the seed steps and every capture by name; built through the `TK2SpikeUITests` scheme into its own `DerivedData/vm47-walk`; the copy in `VariorumMobileUITests/` exists only for that build; never committed). Core screens × Study/Terminal × light/dark × default/largest (AX5); the rest × Study light default, Terminal dark default, Study light largest | MOVED — the orchestrator's call: **batch 1's suites close here; its walk rides batch 2's seam as ONE walk covering batches 1 and 2** (the queue is long, and a walk at the largest size belongs on the fixed tree). The driver's headless build is GREEN at `29f2cbd41` (`** TEST BUILD SUCCEEDED **`; the bundle carries `VM47Walk/test01_seed · test10_core · test20_rest`; the temporary copy removed, tree clean). The filter row at Display Zoom (320 pt) is NOT capturable (simctl cannot switch Display Zoom on) — recorded as not taken; the geometry pins are its evidence |
| 1.6f | The record close: §6 "Batch 1 — results" (counts, every red and its disposition, what was fixed, what is owned elsewhere); §5 for any new PROVISIONAL; this table flipped | DONE (this commit) for the suites; the walk's findings land with batch 2's walk; the targeted re-run's counts PENDING its stage window. No new PROVISIONAL |
| 1.7 | §6 "Batch 1 — results" written | DONE (this commit) — counts and the walk PENDING the stage window |
| 2 | Controls and targets (VM-50; VM-49's application) | IN-PROGRESS — pieces below (implementer: Opus, 2026-11-19) |
| 2.1 | The shared controls in `Shared/Theme/PhoneControls.swift` (text button, inline act, icon button, chip, field, the one calm button, sheet header, segmented choice on the system control, section header, menu row; the UIKit hit-area button for the overlays) + their geometry tests | DONE (this commit) — `PhoneControls.swift` + `PhoneType`'s `weight:` override + `MobilePhoneControlsTests` (14 tests); phone `build-for-testing` green; Mac build PENDING (running); tests PENDING the stage |
| 2.2 | Adoption, one commit per screen family, retiring each private build with its last user (the five calm buttons, the three fields, the ten sheet headers, the word-row choices) — Shell roots · book sheets · Write masthead · Write sheets · Shell sheets/screens · Protection · the UIKit overlays | IN-PROGRESS — Shell roots DONE (this commit: the Bookcase and Library path lines on the controls — 🗑 icon button, + New Note inline act, Settings a gear icon button (P-47-9), one 44 pt line, Starred's line level with them; the today badge a chip; the Library search on `phoneField`; every root row, the archive row, the scraps picker and the book's rows/doors given `phoneHitArea`; the filter doors and the sort glyph 44 tall, widths kept (P-47-10)); phone `build-for-testing` green. Book sheets DONE (this commit: Book Details and Create Book on the sheet header; Create Book's name a `phoneField`, its kind and its OR/AND on the segmented choice, its Create on the calm button; Book Details' act rows on `PhoneMenuRowStyle`, the rename name and the daily row 44 tall; the segmented choice sizes segments by their words, `PhoneSegmentWidths`; the path-line pin `MobilePathLineGeometryTests` written, red-on-old PENDING the stage). Write masthead DONE (this commit: its four tools are icon buttons — 22 pt glyphs in ink (the seal in the accent while sealed), 44 × 44 hit areas touching, the row kept; the title and the membership chip 44 tall; the five flow chips 44 tall reaching 6 into the old 12 pt gap (words where they were); Unlock Note an inline act; the receipt's Undo/Redo LEFT for VM-61 — a 44 pt row there would deepen the prose's jump on every act). Write sheets DONE (this commit: the sheet header on Tags, More Info, Books, Note Actions, Blocks (its Select door a text button beside Done), Lenses, the edit trace (path title kept muted) — and the Tag manager's; the tag field a `phoneField`; Note Actions' rows the menu row (64 with a detail line); the block list's segments on the segmented choice and its rows 44 tall; every inline act (✕ remove, diverge/remove/open copy, Put back/Delete now, the takes fold, restore/promote/delete, Delete N) on `PhoneInlineActStyle`; the lens rows, suggestion rows, link rows and + rows 44 tall; the leading door words (save/adopt, Refresh/Clear, back to listing) inline acts at 17). Shell sheets/screens DONE (this commit: Settings and Acknowledgments on the sheet header, path titles kept muted; Settings' door words (Protection…, Acknowledgments, Manage Tags, Edit trace…, the DEBUG doors) inline acts at 17 with 44 pt hit areas — the list's shape stays batch 5's; the voice rows and the edit-trace toggle 44 tall; the Trash's Empty Trash, sort, and row acts and the Archive's row acts inline acts; the Trash's seven kinds on FILTER CHIPS (the chip gains a selected state — P-47-11); the tag manager's + new tag 44 tall). Protection DONE (this commit: `MobileRoadButton` and the library-missing Start door on THE calm button; the lock face's two fields and the shared pages' `pageFieldChrome` on `phoneField` (the private `field` card retired); `PageDoor`'s styled arms on the controls — .act/.destructive the calm button (destructive in the alarm, replacing the literal red), .bordered the calm button's edge alone, .borderless/.inlineAct the inline act at 17 — the Mac's nil arms untouched; the words disclosure an inline act; both protection door builders inline acts at 17; the gate's radio rows 44 tall). the UIKit overlays DONE (this commit: Done, Branch/Blank, Turn takes into blocks, the cards' ✓/⋯, Add/Save, Cancel, the comments' Edit/Delete/Restore and the history act are `PhoneHitAreaButton` — 44 × 44 within each button's superview; structure untouched); the fourth field build (`mobileSecretFieldChrome`) on `phoneField`. ALL FAMILIES DONE; phone `build-for-testing` green; Mac green at `a77374d8a` |
| 2.3 | The 44 pt hit area on every remaining G §2 site where it is a one-line change (`phoneHitArea()`) | DONE — inside each family's commit; the per-site outcome is §6's T1–T109 table |
| 2.4 | The path line (Terminal wraps at 402): doors as inline acts / icon buttons with 44 pt hit areas, ONE line at 402 in both voices; red-on-old geometry pin | DONE (`47ee432fc` the fix, `0b2df787f` the pin `MobilePathLineGeometryTests`) — red-on-old PROVEN in a snapshot (row 2.8d): 22 issues on the old code, green on the fixed tree |
| 2.5 | The source pin: the retired private button/field/header builds are gone | DONE (this commit) — `MobilePhoneControlsSourceTests`; its patterns measured by script red on `751765baf` (11 · 4 · 5 · 13 · 4), clean now; GREEN in the phone leg (row 2.8c) |
| 2.6 | The walk driver extended for the batch's surfaces; rebuilt headless into `DerivedData/vm47-walk`; both schemes `build-for-testing` green into `DerivedData/vm47-b2` → READY for the stage | DONE — the driver gains r05b (Create Book's kind segment) and r07b (the Blocks sheet's segment) and its header names batch 2's surfaces per capture; `walk_build` green at `09fba8983` (copy removed, tree clean); phone `build-for-testing` green at `09fba8983`, Mac green at `a77374d8a` (no `Shared/` change since); `DerivedData/vm47-b1` deleted at the orchestrator's word |
| 2.7 | §6 "Batch 2 — results": each control with its pointer and sizes, the retired builds, the T1–T109 inventory with owners, tests (PENDING), PROVISIONAL calls in §5, self-assessment | DONE (this commit) — counts filled at the closer's rows 2.8c–2.8d and §6; P-47-9…14 in §5 |
| 2.8 | The stage windows (suites; then the walk, both batches' captures, looked at) — run at the orchestrator's GO | DONE for the suites and the red-on-old (rows 2.8c, 2.8d); the walk is row 2.8e |
| 2.8b | CUTOVER (orchestrator, machinery honesty): the batch-2 implementer ended its turn READY at about 530k tokens of context, every piece committed (`776f665be`, then main merged in at `057c7cd87` — notes and the coordinator skill only, no app code) and both schemes building. The stage work — the walk, the path line's red-on-old, any red the suites turn up, the record's close — goes to a FRESH closer briefed from this record (no design latitude: verify, look, fix narrowly what the evidence proves broken, record) | DONE — the closer read §1–§6, CLAUDE.md, the resiliency protocol, the sizing sheet §A–§E, the layer and controls code, the seven named test files and the walk instruments, and added the rows below |
| 2.8c | The suites window: the whole phone target + the Mac theme suites — run by the ORCHESTRATOR under its own claim; every red handed to the closer by name with its log | DONE — **phone leg** (the orchestrator, from `DerivedData/vm47-b2` at `09fba8983`): "Test run with 900 tests in 148 suites failed after 510.176 seconds with 12 issues (including 8 known issues)", XCTest "Executed 0"; the 8 known = the four pre-existing (the empty-accessibility-tree diagnosis ×2, the fanned-divide lesson ×2) + P-47-7's four filter-row marks. Reds, each dispositioned (§6): (1) VM-24's caret suite — pre-existing, not this run's, nothing changed; (2) `MobilePhoneControlsTests.theFieldIsAtLeastFortyFourTallAndGrowsWithItsText()` :202 (44.0 at xxxLarge) — the test's premise, fixed test-only `7762aef3b`; (3) `MobilePhoneControlsTests.theSheetHeaderPutsDoneEightFromTheEdgeOnAFiftySixRow()` :61 ("no element labelled tags") — the test's lookup, fixed test-only `a37789cb9`. **Mac leg** (the orchestrator, the seven theme types from `vm47-b2` at `09fba8983`): "Test run with 42 tests in 7 suites passed after 16.983 seconds", `** TEST EXECUTE SUCCEEDED **` — the Mac's token pins byte-identical. **After the fixes:** phone `build-for-testing` into `vm47-b2` GREEN at `557664d3b` (`** TEST BUILD SUCCEEDED **` — the two test-only fixes compile; no `Shared/` change, so the Mac build stands). The targeted re-run `rerun=(MobilePhoneControlsTests)` is PENDING its stage window |
| 2.8d | The path line's red-on-old (`47ee432fc`'s pin, `MobilePathLineGeometryTests`) — **in a SNAPSHOT, so this run's worktree never sits reverted** (the orchestrator's change of road, replacing the in-tree revert): a detached worktree `~/dev/variorum-vm-47-rol` at `09fba8983` (never committed in); there `git checkout 91d406593 --` `MobileShelfView.swift` + `MobileLibraryView.swift` (they changed only in `47ee432fc` since — a clean revert of exactly the fix; the trash door's icon button, `MobileRecoveryDoors.swift`, is NOT reverted, so its 44 × 44 stays green and the red rides the path's wrap and the two word doors' ~22 pt height); `build-for-testing` for the phone scheme into the snapshot's own `App/Variorum/DerivedData/vm47-rol` (headless); then, in a short stage window the orchestrator obtains, only `-only-testing:VariorumMobileTests/MobilePathLineGeometryTests` from that snapshot — expect RED; the snapshot is removed after | DONE — **PROVEN red on old, green on new.** The snapshot (`09fba8983` + the two files from `91d406593`, staged there only, never committed; 39 + 50 lines, `47ee432fc`'s own counts) built GREEN into `vm47-rol`; the orchestrator ran the one type on the standing device: "Test run with 2 tests in 1 suite failed after 6.874 seconds with 22 issues" — `theBookcasePathLineIsOneLineAtFourHundredTwoInBothVoices()` 18 issues (`path.height < 26` :86 ×3, the 44 × 44 bound :93 ×8, on-the-path's-line :96 ×7), `theLibraryPathLineDoorsAnswerAcrossFortyFour()` 4 issues (:128 ×2, :129 ×2); both green on the fixed tree in the 06:26 whole-target run. The snapshot is REMOVED (`git worktree remove --force`; the worktree list no longer holds it); **this run's worktree carried no revert at any point** |
| 2.8e | The walk (batches 1 + 2's ONE walk): device `vm47-walk` (iPhone 17 Pro, iOS 26.2, never booted), the driver built at `09fba8983` into `DerivedData/vm47-walk` (the app code is identical at `057c7cd87`); the seed; the core five × Study/Terminal × light/dark × default/AX5; the rest × Study light default, Terminal dark default, Study light AX5; every capture looked at against the sheet | NOT-STARTED — READY. Planned: 123 captures (seed 3 · core 6 × 8 = 48 · rest 24 × 3 = 72). The runbook `walk.zsh` (gitignored) gained a 30 s settle after boot, a per-run capture count, and exact-name instance checks (`pgrep -x`) in `walk_close`; the driver needed no change (every label and identifier it drives checked against the code at `057c7cd87`) |
| 2.8f | The record close: §6 "Batch 1 — results" and "Batch 2 — results" PENDING slots filled (counts, each red and its disposition, the red-on-old line, the walk screen by screen, what was fixed, what is owned elsewhere and by which ticket); §5 for any new PROVISIONAL; these rows flipped | IN-PROGRESS — DONE: the suites' counts, the three reds and their dispositions, the red-on-old lines, rows 2.4–2.8d flipped, P-47-14 in §5 (this commit). REMAINING: the targeted re-run's counts (`MobilePhoneControlsTests`), the walk's captures and findings screen by screen (row 2.8e), then this row |
| 2.9 | Batch 2's remaining evidence: the walk (row 2.8e) runs from `DerivedData/vm47-walk` when its stage slot comes (the orchestrator runs the capture lines); the captures are read at the batch-3 seam | PENDING the stage |
| 3 | Voice and palette; borders (VM-51, VM-54) | IN-PROGRESS — pieces below (implementer: Opus, 2026-11-19; build products `DerivedData/vm47-b3`, walk `DerivedData/vm47-walk3`) |
| 3.1 | The hoist: `ThemeStore` moves `Variorum/Theme/` → `Shared/Theme/` (a move; the two Mac-only adoptions — `EditorTypography.adopt`, the receipt style into `session.status` — behind `#if os(macOS)`); Mac `build-for-testing` green | DONE (this commit) — `git mv` to `Shared/Theme/ThemeStore.swift` (history kept); the header says what moved; `EditorTypography.adopt` and `session.status.receiptStyle` behind `#if os(macOS)` (both Mac-only types/members); nothing else changed. Mac AND phone `build-for-testing` into `vm47-b3` GREEN (`** TEST BUILD SUCCEEDED **` each); the Mac suites PENDING the stage |
| 3.2 | The phone's resolution road: the shell router holds the library's theme (the hoisted store, bound per session, started by the shell); the five palette-less sites read `VoiceTokens.resolve(settings:dark:)`; `MobileEditorStyle`'s UIKit face resolves voice + palette + tint from the landed settings with ONE main-actor writer (QUESTIONS #195 MINOR 3); light/dark stays the device's | DONE (this commit, with 3.3 — the voice door's source and its write are one seam) — `ThemeStore` gains `onLanded` (the phone's landing seam; nil on the Mac) and `init(session:placeholder:)` (default = the Mac's); `MobileShellRouter` holds the store (`bindTheme(session:)`, `settings`, `voice`, `tokens(dark:)`, `adoptLanded(_:)`, `placeholder`); the shell binds and `.task`-starts it; the five sites: `VariorumMobileApp.lockedTokens` (the placeholder, P-47-15), `MobileShellView.tokens`, `MobileWriteScreen.tokens` (the global write and `fallbackVoice` gone), `MobileSettingsView.tokens`, `MobileEditorStyle` (`adopt(_:)` + `Face.applying(palette:tint:)`; storage `@MainActor`; `Face.room` the voice's own room, P-47-16); tests moved (`MobileShellTests`, `MobileLivenessTests`, `MobileVoiceTests`, `withEditorWorld`, three router constructors) + new `MobileLibraryLookTests` (7); phone `build-for-testing` GREEN; Mac: the APP target compiled with no error, then the build was STOPPED in the test target at the coordinator's QUIET (another run's merge gate); after "QUIET over" (08:33) BOTH schemes `build-for-testing` into `vm47-b3` GREEN at `c87407b93` (`** TEST BUILD SUCCEEDED **` each — the three new suites compile); tests PENDING the stage |
| 3.3 | `MobileVoicePreference` retires (an old stored value ignored); the two Settings voice rows write the library's voice through `ThemeStore.setVoice` (R-47-2) | DONE (this commit, with 3.2) — `VariorumMobile/Theme/MobileVoicePreference.swift` deleted (nothing reads the key; a source pin holds it); `MobileShellRouter.setVoice` → `theme.setVoice` (the Mac Settings' write, `Operations.setThemeVoice`); the rows' mark reads the landed library voice |
| 3.4 | The grounds (R-47-1): her words on the paper (`tokens.surface`), bars/sheets/section bands on the room — at the screens' and sheets' background lines; the rest listed with owners | DONE (this commit) — the roots' list regions (`MobileStarredView`, `MobileShelfView` books + box, `MobileLibraryView` rows/search) `.background(tokens.surface)`; the pushed lists' grounds (`MobileBookView`, `MobileArchiveView`, `MobileTrashView`, `MobileVersions`) `tokens.surface`, their report bands still the room; Read's room around the cream page `ReadingPageTokens.room` (the Mac's R-13u-10); Write's screen ground and masthead the editor's own ground (`ReadingPageTokens.room` — P-47-16); sheets unchanged on the room; what is more than a background line listed in §6 with owners. Source pin `MobileLookSourceTests` (4): patterns measured RED on `ea738c49f` (10 of 10 checks fail) and GREEN now (0 of 10). Phone APP target builds incrementally GREEN (QUIET: the test target's build waits) |
| 3.5 | The ★ reads `tokens.star` | DONE (this commit) — `MobileStarredView`'s ★ (the phone's only one); pinned by `MobileLookSourceTests.everyStarReadsTheStarToken` (red on old: the accent) |
| 3.6 | VM-54: the border trace and verdict in §6; if the code does not re-resolve, the fix + a trait-driving pin, red-on-old in a snapshot worktree | IN-PROGRESS — DONE: the trace and verdict (§6 "Batch 3 — results": NOT hollow by the code), the fix (`MobileTraitBorder` + the four sites) and the pin `MobileBorderTraitTests` (4) (this commit; the phone APP target builds incrementally green). REMAINING: the pin's compile (the test target's build waits for QUIET); its red-on-old in a SNAPSHOT worktree — MADE: `~/dev/variorum-vm-47-rol3`, detached at `b395f03e8` (re-made there from `72ae64daa` so it is the reviewed tree), the three view files checked out from `af487bfe7` and staged there only (they changed only in `1c3621719` since — a clean revert of exactly the fix: 7 lines in, 19 out; `MobileTraitBorder` stays, unused there; the pin's test file is the fixed tree's); its phone `build-for-testing` into its own `App/Variorum/DerivedData/vm47-rol3` waits for QUIET; then the orchestrator runs `MobileBorderTraitTests` from it — expect RED; the snapshot removed after. THIS worktree carries no revert. The on-screen check rides the walk |
| 3.7 | Tests: the phone's resolution (a settings change re-resolves; no palette → sea-glass; dark stays local; the old key ignored), the star, the grounds, a phone no-literal-colour twin if it is a small source scan | DONE (written, `987e9edc5` … `5b5d7b9be`) — `MobileLibraryLookTests` (7), `MobileLookSourceTests` (4, incl. the phone's no-literal-colour twin — none existed), `MobileBorderTraitTests` (4); moved pins in §6. COMPILE of the test target and every count PENDING (QUIET, then the stage) |
| 3.8 | The walk driver COPY extended (voice row, palette, grounds, ★, the VM-54 flip) → `DerivedData/vm47-walk3`; both schemes `build-for-testing` into `DerivedData/vm47-b3` → READY for the stage | IN-PROGRESS — DONE: the instruments (gitignored `notes/plans/vm-47-screens/instruments/VM47Walk3Driver.swift` + `walk3.zsh`, each with a cold-use header: the voice set through the Settings row, the second palette through the launch environment, `test25_voice`, `test30_flip` with the runbook's flip watcher; captures to `vm-47-screens/b3/`, device `vm47-walk3` created and deleted inside the window); the walk's palette seam in the Debug app (`MobileWalkLaunch`, DEBUG only — `VARIORUM_WALK_PALETTE` → `setThemePalette` at the shell's start) (this commit; phone APP target incremental build GREEN). REMAINING, held by the coordinator's QUIET: `walk_build` into `vm47-walk3`; both schemes' full `build-for-testing` into `vm47-b3`; then READY |
| 3.9 | §6 "Batch 3 — results" (hoist, road, retired preference, grounds by screen, star, VM-54 trace + verdict, tests PENDING, PROVISIONALs in §5, self-assessment) | DONE for the code (this commit) — counts, the red-on-old line, the walk's findings PENDING their windows |
| 4 | The bottom bar (VM-52) | NOT-STARTED |
| 5 | Settings (VM-53, VM-27) | NOT-STARTED |
| — | The midway cold review, after batch 2 (her word; Fable, fresh) | CLOSED (the fix pass's window ran 08:35–08:39, rows M.5–M.6) — FINDINGS IN — 0 BLOCKER · 1 MAJOR · 2 MINOR · 2 NIT, verbatim in `notes/plans/vm-47-ladder-midway.md` §1, with a clean bill. The MAJOR: `PhoneType.uiFont` has no 13 pt floor. NEXT: the implementer's agree/dispute → the reviewer's final call → the implementer applies (red-on-old pin) → a short stage re-run; the ladder's round 1 re-checks. The `MobilePhoneControlsTests` re-run ran green at 06:56 (13 tests in 1 suite, both fixed tests green by name); the walk (row 2.8e) is still queued |
| M.1 | The implementer's answers (all five AGREE) and the reviewer's final calls (all five CONFIRMED; M-1 with its two precisions) — `vm-47-ladder-midway.md` §2, §2a, §2b | DONE (`347869d52`, `594052b88`) |
| M.2 | M-1: the 13 pt floor in `PhoneType.uiFont` (`#if os(iOS)` arm, BOTH scaling classes: a resolved font under `floorSize` returns `baseUIFont(…, pointSize: floorSize)`); its pin, the UIKit twin of `nothingIsEverBelowThirteenPoints` in `MobilePhoneTypeTests` (every role × both voices × all twelve settings) | DONE (this commit) — `uiFont` = the class's scaled font (`scaledUIFont`, unchanged) then the floor; the pin `theUIKitFormIsNeverBelowThirteenPointsEither()`; build M.4, red-on-old M.5, run M.6 PENDING |
| M.3 | m-1 + m-2 comments (`MobileEditorStyle.baseParagraphStyle`, `PhoneSegmentedChoice`'s contract); the two VM-137 lines in batch 1's "Recorded and left" (`Face.body` at xSmall in Terminal; the launch-cached paragraph scale) | DONE (this commit) — comments only (no code, no rendered word); the two lines under batch 1's "Recorded and left" |
| M.4 | Both schemes `build-for-testing` into `DerivedData/vm47-b2` (`vm47-walk` untouched) | DONE — phone and Mac both `** TEST BUILD SUCCEEDED **` at `514fa1ef6` |
| M.5 | M-1's red-on-old, in a SNAPSHOT (this worktree never reverted): a detached `~/dev/variorum-vm-47-rol` at the fix commit, `App/Variorum/Shared/Theme/PhoneType.swift` ALONE checked out from the commit before the fix (the pin's test file stays the fixed tree's), phone `build-for-testing` into its own `App/Variorum/DerivedData/vm47-rol`; the orchestrator runs `MobilePhoneTypeTests` from it — the new pin expected RED; the snapshot removed after | DONE — **PROVEN red on old** (08:35–08:39): "Test run with 10 tests in 1 suite failed after 0.069 seconds with 20 issues" — `theUIKitFormIsNeverBelowThirteenPointsEither()` all 20 (`MobilePhoneLayerTests.swift:115`), the other nine passed; the snapshot removed by the orchestrator (`vm-47-ladder-midway.md` §3) |
| M.6 | The window (the orchestrator's): (a) the snapshot run; (b) `rerun=(MobilePhoneTypeTests MobilePhoneControlsTests MobileTakesBrowserTests MobileTakesBrowserSurfaceTests MobileBlockHistoryTests MobileCommentDraftTests)` + the seven Mac theme types from `vm47-b2`; results recorded in §2's "What changed" | DONE (08:35–08:39) — (a) red on old (row M.5); (b) "Test run with 75 tests in 6 suites passed after 20.379 seconds", the pin green; (c) Mac, six theme types (minus `NoLiteralColourTests`, a source scan run while batch 3 edited): "Test run with 40 tests in 6 suites passed after 2.925 seconds". **The fix pass is CLOSED**; ladder round 1 re-checks it (`vm-47-ladder-midway.md` §3). `DerivedData/vm47-b2` deleted |
| — | The ladder (Fable, fresh reviewer per round; up to five rounds while a round finds a MAJOR — her word) | NOT-STARTED |
| — | Closeout | NOT-STARTED |

Each batch's implementer adds its own piece rows under its batch line as it starts.

## 5. PROVISIONAL calls and the list for her sitting

| Id | Call | Options | Built | State |
|---|---|---|---|---|
| P-47-1 | The sizing sheet's numbers (type roles, spacing, radii, row heights, the two inks) | as drawn · her own numbers | as drawn | PROVISIONAL — she has seen the sheet in use, not ruled it number by number |
| R-47-1 (was P-47-2) | Grounds: her prose never sits on the tint — notes and lists on the paper, bars and sheets on the room | the Mac's rule as the sheet draws it · every screen on the room, as built today | PENDING (batch 3) | **RULED 2026-11-19** — "grounds - prose should not be on the tint, which is what I understood you mean. that sounds good." |
| R-47-2 (was P-47-3) | A voice row on the phone that writes the library's voice | no row · a row writing the synced voice | PENDING (batch 3) | **RULED 2026-11-19** — "voice only row - yeah, that's fine." |
| P-47-4 | Terminal's "prose roles two points under Study's" — which roles, and the line pitch | (a) every prose-family role (body, note title, screen title, row title, row preview), size AND pitch two under: 15/25 · 22/28 · 18/23 · 15/20 · 13/18 · (b) sizes two under, pitches kept proportional (15/24 · 22/28 · 18/23 · 15/19 · 13/17) · (c) only the three roles the brief names two under, rows at Study's sizes | (a) — one rule, and a Terminal line keeps Study's leading; row preview lands on the meta pitch (13/18) | PROVISIONAL (batch 1) |
| P-47-5 | The dark `faint` | (a) the every-palette floor the brief states — Study #766F5F, Terminal #6B7168 · (b) the sheet's #736C5D as drawn (computed over the sea-glass family only; 2.91:1 on teal & rust's dark card) | (a); the rule reproduces the sheet's light inks exactly (#6A6359, #8B7F6A) and leaves dark `muted` unchanged in both voices | PROVISIONAL (batch 1) |
| P-47-6 | The quick-entry hint at the note-body size (42 characters; Terminal 380 pt at 15 pt mono against a 338 pt box) | (a) the longest of the hint's own cuts that fits — the hint, "new note — just start typing", "new note" (no new words) · (b) let it wrap (breaks her one-line-at-rest ruling) · (c) new shorter words — the sheet draws "New note", but no wording-list draft exists, so that waits for her wording pass | (a) | PROVISIONAL (batch 1); the capture box's rebuild (SW-3/SW-4, umbrella 5) may replace it |
| P-47-7 | The Library/Archive filter row's five words | (a) `meta` 13, the floor: one unshrunk row at 375 and 402 pt in both voices and 320 pt in Study; Terminal at 320 pt (Display Zoom) cannot hold five 13 pt mono words + the glyph + the 20 pt gutters, so the last words truncate (no word below 13 pt) · (b) `chip` 15, the sheet's named role for filters: shrinks at 375 Terminal and 320 Study, overflows Terminal 320 · (c) scroll or wrap the row — against her #92(b) | (a); the Terminal-320 gap is a named `withKnownIssue` in two pins, owned by VM-50 (batch 2's segmented choice replaces the row) | PROVISIONAL (batch 1) |
| P-47-8 | Role judgment calls (the brief's "the smaller of the two candidates") | listed per family in §6 "Batch 1 — results", the role-map table | the smaller candidate each time | PROVISIONAL (batch 1) |
| P-47-9 | The Bookcase path line's doors, so the line holds ONE line at 402 pt in both voices (Terminal needed ≈437 pt with two 17 pt word doors) | (a) 🗑 an icon button, + New Note an inline act (15, its word kept), Settings an icon button (a gear, "Settings" its spoken label) — ≈390 pt in Terminal at 402 · (b) all three icons (fits 375 too; loses the + New Note word, a ruled P33 door) · (c) words at 15 and the path text truncating (keeps every door word; cuts her count at 402) | (a); at 375 pt Terminal the path text, the line's one flexible member, truncates rather than wrap | PROVISIONAL (batch 2); Settings leaves the line for the roots' ⋯ menu at VM-53 (batch 5) |
| P-47-10 | The Library/Archive filter row (her #92(b): one visible row, no scroll, the sort shrinks to a glyph) | (a) keep the five word doors and the sort glyph, each 44 pt TALL, widths their words' · (b) the system segmented control — wider per word (segment padding, and the system truncates a word it cannot fit — the lookup's fact), so Terminal no longer fits at 375 pt and her #92(b) breaks · (c) filter chips in a row that scrolls (the library mockup's rooms as chips — but scrolling is what #92(b) declined) | (a); the row's rebuild (the rooms as chips, the sort beside the field) is VM-93 / VM-90's, and the Terminal-320 known issue (P-47-7) moves with it | PROVISIONAL (batch 2) |
| P-47-11 | The Trash's seven kinds (All · Notes · Books · Blocks · Takes · Snippet groups · Originals) | (a) filter chips in their scrolling row — the sheet's chip is "filters … one row that scrolls sideways"; the chosen one on the wash in her ink, the others edged in the take line, muted · (b) the segmented choice — seven words cannot share 362 pt without truncating · (c) a Menu — not a door a pin can drive (§15's trap (b)) | (a); the chip gained a `selected` state for it | PROVISIONAL (batch 2) |
| P-47-12 | The masthead (VM-148 rebuilds it): "hit areas on its icons and chips only" | (a) the four tools as the icon button (22 pt glyph in ink, 44 × 44, centres 44 apart — the sheet's §B for exactly T39–T42), the row kept; the chips 44 tall in the same flow, their hit areas reaching 6 into the old 12 pt gaps · (b) the tools' glyphs left at 17 in faint with only a 44 pt frame · (c) the chips as 32 pt capsules (the sheet's chip — VM-148's one sideways row) | (a); the title row now gives its title 54 pt less (four 44 pt tools); the masthead grows by the chips' rows | PROVISIONAL (batch 2) |
| P-47-13 | Sheet headers whose title was a muted path (Settings, Acknowledgments, the edit trace) and Create Book's Cancel | the shared header with the path title kept muted and Cancel in Done's place (semibold) · the header's ink title everywhere · Cancel at regular weight | the first: the words on screen are unchanged | PROVISIONAL (batch 2) |
| P-47-15 | What the phone wears before a library answers — the lobby (no library open: the lock, the words card, the library-missing face) and the shell's first frame before its theme store's first emission | (a) the Mac's storeless placeholder, R1's Terminal in the voice's own colours (`VoiceTokens.fallback` — the Mac's `StoreLockView`) · (b) what a library that has chosen nothing reads — Study under the sea-glass (`unsetStoreVoice`/`unsetStorePalette`, AppSpec §12) · (c) a device cache of the last library's look (a new local key — against "the phone keeps no voice of its own") | (b) — `MobileShellRouter.placeholder`, pinned equal to an empty library's own read; (a) would draw the wrong voice for a frame at every launch and unlock of a Study library (the store's first emission lands a frame after the shell's first render), and the lobby would wear a look no library of hers wears | PROVISIONAL (batch 3) — hers: whether the lobby follows the Mac's Terminal placeholder |
| P-47-16 | The ground under the note in WRITE — R-47-1 says her prose is never on the tint and the brief says "the paper", but the editor's ground is one line in `MobileEditorTextView.applyVoiceChrome` (`backgroundColor = face.room`), a file this run may not edit | (a) the voice's OWN room under every palette (the Mac's `ReadingPageTokens.room` precedent, R-13u-10: the room under her words kept off the palette) — never the tint; Write looks exactly as before the palette arrived · (b) the library's room — the sea-glass tint under her words, against R-47-1 · (c) edit the fenced line to `face.surface` (the paper) — breaks the run's editor-seam fence | (a) — `Face.room` stays the voice's own room (`applying(palette:tint:)` never replaces it); the Write screen's ground and masthead wear the same (`ReadingPageTokens.room`), so the page is one ground; the palette reaches Write's accent, caret, takes and comment chrome. The paper (three lines: the text view's background + the screen's two) is **VM-137's** (the editor seam) | PROVISIONAL (batch 3) |
| P-47-14 | The role of a field's typed text (a tag, a book's name, a search, a passphrase) — the sheet names its two scaling classes (her words: full range; chrome: holds at xxxLarge) and places field text in neither | (a) as built — the `control` role, chrome: it grows to xxxLarge (17 → 23 pt) and holds, so a one-line field stays 44 pt at every size (a 23 pt line + 8 + 8 ≈ 43.4 fits the floor) · (b) her words' class — what she types into a field scales across the whole range like the sheet's "her words", so fields grow past 44 at the accessibility sizes | (a); the control is unchanged (`phoneField`'s `role:` already carries either); the batch-2 field pin first assumed (b) and was corrected to (a)'s arithmetic (`7762aef3b`) | PROVISIONAL (batch 2, the closer) — hers: which class a field's text is |

Held for her hands: the wave-1 install on her phone (one install from merged main, after all four runs,
prepared by the last merger; the hands part is hers in the morning) — it is where she judges P-47-1's
numbers at true size; her glance at which Protection door stayed (VM-27); the wording pass over any new
line.

## 6. Results, review and closeout

PENDING — each batch's results (counts, commits, walk captures), the touch-target inventory (batch 2), the
ladder's findings and dispositions, the canon deltas, the tickets filed.

### Batch 1 — results (implementer: Opus, 2026-11-19)

**Not done in this batch, first:** (1) the WALK — moved by the orchestrator to batch 2's seam, as one walk
covering batches 1 and 2 on the fixed tree (its driver is built and ready, §6 "Stage window" below); (2) the
targeted re-run of the two red-fixes and the layer is PENDING its own short stage window; (3) the filter row
at Display Zoom (320 pt) cannot be captured on a simulator — not taken; (4) the keyboard bar's 14 pt chrome
(`MobileKeyboardBar`, eight `face.chrome` reads) is left for VM-137 — the sheet says the bar's shape and its
22 pt glyphs are LK-4/LK-3's, its 48 pt row holds, and 14 is above the floor. Nothing else in the batch's
seven items is left.

**What was built, one pointer per piece.**

| Piece | Where | What |
|---|---|---|
| The role table | `Shared/Theme/PhoneType.swift` — `PhoneTypeRole`, `PhoneTypeSpec`, `PhoneType.spec(_:voice:)` | The sheet's twelve roles as drawn for Study (size, line pitch, Dynamic Type anchor, weight, family); Terminal in SF Mono with its prose roles two under, size and pitch (P-47-4). Platform-neutral. |
| Two scaling classes + the floor | `PhoneType.pointSize(_:at:)`, `PhoneTypeRole.scaling`, `PhoneType.floorSize` | Her words (`noteBody`, `noteTitle`, `screenTitle`, `rowTitle`, `rowPreview`, `mono`) follow their anchor across the whole range; chrome follows it to xxxLarge and holds; nothing below 13 at any setting. |
| SwiftUI form | `View.phoneType(_:_:)` (+ `shrinkingToFloor:`, `linePitch:`) over `PhoneTypeModifier` | Reads the environment's text size, resolves the role (cached per role · voice · size), applies the font and the role's line pitch. Compiles on the Mac (the shared pages' phone arms read it); only the phone renders it. |
| UIKit form | `PhoneType.uiFont(_:voice:compatibleWith:)`; `MobileEditorStyle.Face.font(_:)` | `UIFontMetrics` scaling with `maximumPointSize` at the xxxLarge size for chrome. |
| Read page | `View.phoneReading(_:)` / `phoneReading(size:weight:pitch:)`; `FlowParagraph.readingSize/Weight/Pitch` (`MobileReadPage.swift`) | The sheet's reading row: serif 17 on 27, titles 25 and 21, all scaling; headings 27 · 23 · 20 from the body. |
| The two corrected inks | `Shared/Theme/PhoneInks.swift` — `PhoneInks.value` (shipped), `PhoneInks.derive` (the rule, the oracle), `PhoneInks.grounds`, `VoiceTokens.phone` | The voice's hue taken darker until `muted` clears 4.5:1 and `faint` 3:1 on every shipped ground (16 palettes' rooms, papers, cards; both Classic rooms; the voice's own paper and card). Light: Terminal #61655F / #7E8376, Study #6A6359 / #8B7F6A (the sheet's exactly). Dark: `muted` unchanged; `faint` Terminal #6B7168, Study #766F5F (P-47-5). The Mac's `muted`/`faint` untouched. A picked block-list row's ⑂ takes the ink. |
| Metrics (VM-49's constants) | `Shared/Theme/PhoneMetrics.swift` — `PhoneMetrics.Space`, `.spacingScale`, `.gutter`, `.Radius`, `.RowHeight`, `.touchMinimum`, `.hitArea(for:)`, `.hitOutset(for:)`; `View.phoneHitArea(alignment:)` | Constants and the one helper only; applying them is batch 2. |
| Every type site | 325 SwiftUI sites in 29 files + 19 on the shelf (piece 1.4) + 38 UIKit sites in 5 files | Moved from `tokens.small/body/title/heading/mono` and literals to roles; `tokens.muted/faint` → `tokens.phone.muted/faint` (186 reads); the UIKit face's `muted` is the corrected ink (the markdown marker keeps the voice's own — the editor's markdown face is VM-137's). Kept: the five protection glyph literals (28, 30); the unvoiced store-failure frame's system styles (its `.caption` lifted to `.footnote`); the callout emoji glyph (13) and the emoji picker's system styles. |
| The shared pages' phone arms | `Shared/Theme/SharedPageStyle.swift` | Styled arms only (sentences `rowPreview`, captions `meta`, headings `sectionHeader`, doors and fields `control`, muted → the phone ink); the nil arms — the Mac's — byte-identical. |
| The editor's face | `MobileEditorStyle.Face.init`, `.baseParagraphStyle`, `.paragraphGap(_:)` | Body = `noteBody` (Study Iowan 17, Terminal mono 15) through `UIFontMetrics(.body)`; paragraph gap 14 / 12 and line pitch 27 / 25, both scaling with the body. The text inset is unchanged. |
| W-024 | `MobileShelfLayout.quickEntryLineHeight` (24), `.metaLineHeight` (18), `.bookRowHeight` (44 = 22 + 2 × 11), `.writingBoxChromeHeight` (60 = 2 × 10 + 6 + 18 + 8 + 8); `split(…, lineHeight:)`, `minimumWritingHeight(lineHeight:)`, `collapsedWritingHeight(lineHeight:)`; `MobileShelfLayout.quickEntryLineHeight(voice:typeSize:)` (`MobileQuickNote.swift`); `MobileQuickNoteCopy.hintFits` | The box types `noteBody` on its 24 pt line; her six-line floor is six lines of the box's text at the CURRENT text size (the box's line now scales); the hint shows the longest of its own cuts that fits (P-47-6). The box's shape and behaviour are unchanged. |
| The guard | `VariorumMobileTests/MobilePhoneTypeSourceTests.swift` | No Mac type slot, no literal size or caption style under 13, no literal `minimumScaleFactor`, over every phone file outside `Spike/` and `Features/Perf/`. |

**The role map — what each family of sites took, and the judgment calls (P-47-8).**

| Kind of site | Role | Judgment |
|---|---|---|
| Error, receipt, status, empty-state, truncation and explainer lines; dates, counts, paths in rows | `meta` | — |
| Root path lines (`~/shelf · 6 books`, Library, Starred) | `meta` | the sheet's "root screen title" is 24, but these are `tokens.small` paths carrying a count — the "Replaces" column puts every `tokens.small` site on a chrome role; smaller candidate |
| Sheet titles; pushed-screen headers (Trash, Archived, Versions, Protection, the version reader, Book Details, the edit trace); the three overlays' headers | `screenTitle` | the sheet names Trash and Versions here |
| A note's masthead title | `noteTitle` | — |
| Book, note, tag, lens, reference and version rows' names | `rowTitle` | a book's name in Book Details: `rowTitle` over `screenTitle` (smaller) |
| A block's words in the block list, the tray's previews, scraps, a comment's words | `rowPreview` | a comment's words: `rowPreview` over `noteBody` (smaller) |
| Ruled sentences on the lock, protection, library-missing and shared account pages | `rowPreview` | `rowPreview` (15, the voice's body face — the Mac reads them in its body; the lock mockup draws 15) over `noteBody` (17); the posture line and the warning line (semibold before) `rowTitle` |
| Section labels (Settings' groups, "Add to a book", "Apply a tag", tray sections, chapter labels, the takes footer and archived header, Block History's section and take headers, the Read page's chapter caption) | `sectionHeader` | the take header: `sectionHeader` over `rowTitle` (smaller) |
| The note's fact chips; choice words (Create Book's kind, OR/AND, the Trash kinds, the block list's segments); the today badge | `chip` | the Library/Archive filter row is `meta` (P-47-7) |
| Text buttons (Done, Cancel, + new note, + new book, Settings, Protection…, Acknowledgments, the note-actions rows, Create Book, the debug doors); the masthead's four icons; the trash glyph door; menu rows | `control` | masthead icons: `control` 17 now (the sheet's 22 pt glyph comes with batch 2's icon button) |
| Acts inside a row (Put back, Delete now, Unarchive, Open note, Restore, diverge, remove, ✕ remove, Edit/Delete on a comment, Unlock, Undo/Redo on the receipt, the takes footer's two buttons, Block History's act) | `controlInline` | the Trash sort door and the scraps pool picker: `controlInline` over `control` (smaller); the box's `open ↵` door `controlInline` |
| Typed text in fields (Library search, tag field, book name, passphrase, twelve-words entry, the shared pages' fields) | `control` | a field's text is a control's; the quick-entry box and the comment draft hold her prose: `noteBody` |
| The twelve words and their numbers | `mono` | the numbers ride the words' face and baseline |
| The ★ beside a starred name, the ✓ in pickers and the voice rows, the block list's pick mark, the ⑂ fan marker, the takes badge and pill text, the comment marker ●n | `meta` | the sheet's block markers are 13 semibold with an 18 pt glyph, NT-10's cluster (VM-192) |
| The edit trace's lines (were `.footnote`/`.caption2` mono); the licence text (was 10 pt mono) | `meta` | smaller of `meta`/`mono` |
| A version's words in the version reader | `noteBody` | — |

**Tests (all PENDING the stage window — counts filled in when run).** New: `MobilePhoneTypeTests` (9),
`MobilePhoneInkTests` (8), `MobilePhoneMetricsTests` (3), `MobilePhoneTypeSourceTests` (3), and in
`MobileShelfLayoutTests` `theFloorIsInLinesOfTheBoxsTextAtAnySize`, `theHintsCutsAreTheHintsOwnWords`,
`theHintFitsItsLineInBothVoices` (×2 widths). Moved with the change they pin: `MobileVoiceTests.
surfaceWriteValuesFollowTheLiveVoice` (the editor face), `MobileReadTests.headingsScaleSerifAndBodyIsThePageSerif`
(the reading row), `MobileShelfLayoutTests` (`theWritingFloorOutranksTheBooks`, `theWritingLineCapFollowsTheRoom`,
`theLineCapFitsInsideItsOwnRegion`, `theFloorIsSixRealLinesOfWriting`; `smallFontLineHeightMatchesTheConstant`
→ `theBoxLinesMatchTheRealFonts`), `MobileFilterRowGeometryTests` (`theChromeFontDoesNotScale…` →
`theChromeScalesToXXXLargeAndThenHolds`; the two no-shrink pins carry the Terminal-320 known issue, VM-50).
The Mac's token pins (`ThemeTokenTests`, `PaletteDerivationTests`, `NoLiteralColourTests`, `SharedPageStyleTests`)
are untouched (their run: below, green). Red-on-old: the type pass is a design row — its evidence is the walk; the
guard's patterns were run over the pre-batch tree `fe85ea6d5` (332 Mac type-slot reads and 32 sub-13 sites)
and over this tree (none).

**The stage window (closer: a fresh Opus session, 2026-11-19; machinery note: the orchestrator ran both suite
legs itself under its own claim, the GO having arrived while the closer was still reading; the closer
dispositioned the reds, fixed, rebuilt, and built the walk driver).**

- **Leg 1, the whole phone target** (`-only-testing:VariorumMobileTests`, test-without-building from
  `DerivedData/vm47-b1` at `efe246473`): "Test run with **883 tests in 145 suites** failed after 494.9 s with
  **19 issues (including 8 known issues)**"; XCTest "Executed 0"; no test skipped. The 8 known issues: the
  empty-accessibility-tree diagnosis (`MobileTrashTests`) ×2 and the fanned-divide lesson (`MobileTutorialWalkTests`)
  ×2, both pre-existing; `noFilterDoorIsShrunkToFitEvenAtDisplayZoom` ×2 and
  `theRealLibrarysRowFitsWithoutShrinkingAtDisplayZoom` ×2, this batch's P-47-7 marks (the Terminal-320 row,
  VM-50). The 11 real issues are three tests:
  1. **`MobileMarkdownCaretTests.aReplaceThroughTheInputRoadAtARescuePointKeepsTheSurfaceInStep(_:)`** — 2 of 3
     cases (`"hi"`, `"hello there"`), `model.desyncRecoveryCount == 0` at :215. **NOT THIS BATCH'S — nothing
     changed.** It is VM-24 on the board ("red on the iOS 26.2 simulator (pre-existing; cause untraced)"), owned
     by another run tonight. How we know it predates batch 1: VM-8 unit 2 recorded it red on the pre-batch face
     (`7e9cdf3fb`, 2026-10-25, "the one pre-existing red suite, VM-24's caret suite") and green later the same
     day (`b1e32f66d`): it was red, and intermittent, before batch 1's font change existed. Not proven
     independent of the editor's font; not caused by this batch.
  2. **`MobilePhoneTypeTests.chromeHoldsAtXXXLargeWhileHerWordsKeepGrowing()`** — 8 issues at :135,
     `abs(uiLargest - uiHold) < 0.01`, measured 0.333 for `meta`, `sectionHeader`, `control`, `tab` in both
     voices (`chip` and `controlInline` held). **A REAL DEFECT in the layer's UIKit road — FIXED `4ec664f2b`.**
     Mechanism: `PhoneType.uiFont` capped a chrome role at `UIFontMetrics.scaledValue(for:)` at xxxLarge while
     the font itself comes from `scaledFont(for:)`; for the `.footnote` and `.body` anchors `scaledFont` lands a
     third of a point under `scaledValue` at xxxLarge, so every accessibility size drew the UIKit chrome
     (the overlays' and keyboard-face reads through `Face.font(_:)`) 1/3 pt larger than xxxLarge — it kept
     growing past the hold. The cap is now `scaledFont`'s own size at xxxLarge, so xxxLarge and above are one
     font. The failing test is its red-on-old; its green is PENDING the targeted re-run. (The SwiftUI form's
     rule, `pointSize(_:at:)`, uses `scaledValue` on both sides and held; it can sit 1/3 pt above the UIKit form
     at xxxLarge and above — recorded, not visible, not changed.)
  3. **`MobileShelfRenderedLayoutTests.writingKeepsItsShareUnderAKeyboardSizedRegion()`** — 1 issue at :593,
     `regions.writing.height / 596 >= 0.42`, measured 242.3 / 596 = 40.7%. **THE PIN'S DENOMINATOR, NOT THE
     RULE — the pin MOVED `29f2cbd41`.** Mechanism: `MobileShelfLayout.split` still gives the writing region
     exactly half of the books+writing room (the share cap binds — 14 books want 660 pt, the row cap is 396,
     half the room 242.3); what moved is the room, because the chrome above it (safe area + the path line)
     grew 88 → 111.3 pt at 430 pt wide (batch 5's own record: 254 of 596 = 42.6%, region 508). Batch 1 set the
     path line in the phone's roles (its `+ New Note` and `Settings` doors at the 17 pt `control` size). The
     0.42 was batch 5's 42.6% less a margin, taken against the WHOLE 596 pt surface, so it pinned the path
     line's height as much as R27's share. The pin now asserts the rule itself — writing ≥ half of
     (books + writing) − 1 pt (pre-batch 254 of 508, now 242.3 of 484.7); the floor, stays-on-screen and
     books-yielded assertions are unchanged; the 932 pt pin (`theWritingRegionIsGenerousOnARealShelf`, ≥ 0.42 of
     the screen and ≥ 400 pt) is unchanged and green at 45.6%. Its green re-run is PENDING with the others.
     **A finding the red exposed, owned elsewhere:** the path line grew 23 pt, more than one line's growth.
     Computed: in Terminal its 13 pt mono path ("~/shelf · 14 books", ≈157 pt) beside two 17 pt mono doors
     (≈102 + 82 pt), three 16 pt gaps and the 20 pt gutters needs ≈437 pt — more than 430 and 402 — so the
     path text wraps to a second line (Study, proportional, fits at ≈363 pt). The walk is to confirm it (the
     Terminal core captures c1/c2); its owner is **VM-53 (batch 5)**, whose roots' ⋯ menu takes `Settings` off
     the path line — no narrow batch-1 fix keeps every word on one line without a design choice.
- **Leg 2, the Mac's `Shared/Theme` suites** (the seven types, from `DerivedData/vm47-b1`): "**42 tests in 7
  suites passed**", `** TEST EXECUTE SUCCEEDED **` — the Mac's token pins byte-identical as ruled (§2 rule 1).
  The red-2 fix is inside `PhoneType.swift`'s `#if os(iOS)` arm, so the Mac leg stands.
- **After the fixes:** both schemes `build-for-testing` green at `29f2cbd41` (`DerivedData/vm47-b1`).
- **The targeted re-run — DONE, GREEN** (the orchestrator, 05:26, from `DerivedData/vm47-b1` at `29f2cbd41`): "Test run with 118 tests in 12 suites passed after 60.571 seconds with 4 known issues", `** TEST EXECUTE SUCCEEDED **`; both fixes' tests passed; the 4 known issues are P-47-7's two filter-row pins; `MobilePhoneTypeSourceTests` was left out (it scans the sources batch 2 edits; green at 04:40). Batch 1's suites are closed; `DerivedData/vm47-b1` deleted. The list run was `rerun=(MobilePhoneTypeTests MobilePhoneInkTests
  MobilePhoneMetricsTests MobilePhoneTypeSourceTests MobileShelfLayoutBrainTests MobileShelfRenderedLayoutTests
  MobileShelfTodayDoorTests MobileFilterRowGeometryTests MobileVoiceTests MobileTakesBrowserTests
  MobileTakesBrowserSurfaceTests MobileBlockHistoryTests MobileCommentDraftTests)` — the two fixed suites, the
  rest of the layer, and the UIKit overlays that read the fixed `uiFont`.

**Walk captures:** MOVED to batch 2's seam — ONE walk covering batches 1 and 2 on the fixed tree (the
orchestrator's call; the stage queue is long). Ready for it: the device `vm47-walk` (iPhone 17 Pro, iOS 26.2,
created, never booted) and the driver + runbook in the gitignored `notes/plans/vm-47-screens/instruments/`
(`VM47WalkDriver.swift`, `walk.zsh` — each says how to build and run it cold, the seed steps and every capture by
name); the driver's headless build is GREEN at `29f2cbd41`. The list it captures: the core set (Bookcase at rest ·
Bookcase with the box focused · Library rows + filter row · Library search typed + results · a note in Write) ×
Study/Terminal × light/dark × default/largest (AX5, the orchestrator's word); the rest (Starred, a book's
contents, Book Details, Read, Create Book, the Tags · membership · More Info · Blocks · Lenses sheets, Note Actions,
Versions, the Takes · Block History · Comments overlays, Trash, Archived, Settings, Protection) × Study light
default, Terminal dark default, Study light largest. Not capturable: the filter row at Display Zoom (320 pt).

**Recorded and left, each with an owner.**
- The keyboard bar's 14 pt chrome — VM-137 (LK-4/LK-3).
- The three UIKit overlays keep fixed frames (Done 24 tall, rows 20–84): their fonts now follow the text size at
  layout, so above roughly xxxLarge a label can outgrow its frame — VM-152 (native sheets) and batch 2's hit areas.
- Settings is a non-scrolling stack; at the new sizes and large text it can clip — VM-53 (batch 5).
- The shelf box's chrome estimate (60) is at the default size; at xxxLarge its meta row is ~5 pt taller than
  the estimate — small, recorded; the box's rebuild (umbrella 5) re-derives it.
- The Read page's page meta keeps the page's own ink (#C2BCB0, ~1.9:1 on its cream paper): the page is
  voice-independent and the corrected inks are the voice's — for her look pass.
- The markdown marker in the editor keeps the voice's own `muted` — VM-137 (the editor's markdown face).
- The Bookcase path line in Terminal (13 pt path + two 17 pt mono doors ≈ 437 pt) is computed to wrap to two
  lines at 402 and 430 pt — VM-53 (batch 5: `Settings` moves into the roots' ⋯ menu); the walk confirms it.
- Terminal at 320 pt cannot hold the five filter words at the floor (P-47-7) — VM-50.
- `Face.body` (`MobileEditorStyle`) has no 13 pt floor: Terminal's note body in the editor draws ≈ 12.4 pt at the
  xSmall text setting (`UIFontMetrics(.body)`, 15 × 14/17; Study clears at 14, and Small clears in both). A floor
  there needs a fixed font, which the editor's text view (`adjustsFontForContentSizeCategory`, an untouched file)
  could not re-scale when she raises the size mid-run — VM-137, the editor's text-size road (the midway review's
  M-1, confirmed recorded, not fixed; the UIKit chrome's floor IS fixed, `8bea26402`).
- `baseParagraphStyle`'s scale is the body's at launch (the faces are `static let`, resolved once per process): a
  mid-run text-size change re-scales the drawn body through the text view while the paragraph gap and the line air
  stay at the launch scale until relaunch — the staleness the pre-batch constants had (they never scaled); the
  comment now says so. VM-137, the text view's trait-change road (the midway review's m-1).

**Self-assessment (for the cold reviewer).** The layer is one table and two forms over it, so a number
changes in one place; the inks are a rule whose output ships as constants with the rule pinned to them, so
a palette change is loud. The riskiest calls are (1) the filter row's `meta` against the sheet's `chip`,
(2) the overlays' fixed geometry under bigger type (sized by measurement on paper — not yet seen),
(3) the shelf's floor now taking the box's line at the current text size (a real change to her guarantee's
arithmetic, made to keep it in LINES now that the box's text scales), and (4) the masthead row, whose title
is now 24 pt beside four 17 pt icons (VM-148 rebuilds it). The Mac's look cannot have changed:
`VoiceTokens.swift` is untouched, `SharedPageStyle`'s nil arms are byte-identical, and every other
`Shared/` addition is new code the Mac compiles but never renders.

### Batch 2 — results (implementer: Opus, 2026-11-19)

**Not done in this batch, first:** (1) the WALK (both batches' captures, §4 row 2.8e) is PENDING its GO, and
the targeted re-run of the two test-only fixes (`MobilePhoneControlsTests`) is PENDING its window — the suites
themselves and the path line's red-on-old are DONE (below); (2) the editor's text inset is NOT changed — it is not
"15 → 20": the inset is 15 pt plus the container's 5 pt fragment padding, so the visible margin is already the
20 pt gutter (`MobileEditorTextView.swift:953`'s own comment); a 20 there would draw 25. Recorded for VM-137;
the file is untouched; (3) the overlays' own comment draft field (T65), the history rows' fixed heights (T71)
and the take card's body (T63) are left with their owners (the overlays keep their structure); (4) the Library
filter row is NOT on the segmented choice (P-47-10), so P-47-7's Terminal-320 known issue stays, re-owned to
VM-93.

**The controls — one pointer each (`Shared/Theme/PhoneControls.swift`), sizes as the sheet draws them (P-47-1).**

| Control | Symbol | Sizes |
|---|---|---|
| Text button | `PhoneTextButtonStyle(tokens:tone:closing:)` | label `control` 17 in the accent (`closing` = semibold, the Done); 12 inside each side; at least 64 × 44 |
| Inline act | `PhoneInlineActStyle(tokens:tone:role:alignment:)` | label `controlInline` 15 (or `control` 17 for a standalone door word) drawn at its own size; `phoneHitArea` 44 × 44 at least; `alignment` keeps a short word on its row's edge |
| Icon button | `PhoneIconButtonStyle(tokens:tone:)` + `PhoneGlyphModifier` / `PhoneControlGlyph.pointSize` | a 22 pt glyph (chrome: follows `.body` to xxxLarge, holds) in ink; 44 × 44, neighbours touch |
| Chip | `PhoneChipStyle(tokens:selected:)` | `chip` 15 medium; 32 pt capsule, 12 side padding, in a 44 pt hit area; a fact chip = the wash + the accent; a filter chip = the wash + ink when chosen, no fill + the take-line edge + corrected muted when not (P-47-11) |
| Field | `View.phoneField(_:role:)` | paper (`surface`), the take line as edge, radius 12, 12 inside, 8 above/below, at least 44 tall; typed text `control` 17 |
| The calm button | `PhoneCalmButtonStyle(tokens:tone:fullWidth:filled:)` | paper fill + take-line edge (`filled: false` = the edge alone), radius 12, 12 inside, label `control` 17, at least 64 × 44; `fullWidth` spans the sheet |
| Sheet header | `PhoneSheetHeader(_:tokens:titleInk:doneWord:done:)` (+ a `trailing:` form) | title `screenTitle` 20 at the gutter; Done the text button, semibold, its hit area 8 from the edge (it reaches 12 into the sheet's 20 pt gutter); row at least 56; Done's label is the site's own voiced word (no re-label) |
| Segmented choice | `PhoneSegmentedChoice(_:selection:tokens:word:select:)` over `PhoneSegmentedControl` (iOS) and `PhoneSegmentWidths` (pure) | the system `UISegmentedControl`; words `chip` 15 medium (UIKit form, the text size's), the chosen in ink on the paper, the others corrected muted; at least 44 tall; segments sized by their words (+12 each side, the rest shared; shrunk evenly when they cannot fit); one spoken element per segment — the PLAIN word, the button trait, `.selected` — activatable |
| Section header | `PhoneSectionHeader(_:tokens:)` | `sectionHeader` 13 semibold, corrected muted, 24 above, 8 below (built and pinned; adopted nowhere yet — no G §2 site is one; the screens adopt it as their umbrellas rebuild them) |
| Menu row | `PhoneMenuRow(_:detail:glyph:tone:tokens:action:)` and `PhoneMenuRowStyle(minHeight:)` | at least 44 (one line) / 52 (with a glyph) / 64 (with a detail line); glyph 22 in the accent, 12, label `control` 17 in ink (alarm when removing), detail `meta` 13 corrected muted; the whole row one target |
| The overlays' UIKit hit area | `PhoneHitAreaButton` (iOS) | a `UIButton` whose touch region reaches `PhoneMetrics.hitOutset` past its frame (44 × 44 at least) — its frame and drawing untouched |
| (The layer) | `View.phoneType(_:_:weight:)` in `PhoneType.swift` | the closing act's semibold, size and scaling still the role's |

**The private builds retired, each with its last user:** the five calm buttons — `PageDoor`'s `.act` arm
(`SharedPageStyle`), `MobileRoadButton`'s body (the struct stays as a thin label wrapper — other code names it),
the library-missing Start door, Create Book's button, the today badge (now the chip, sheet §E's Today door);
the fields — the Library search, the tag field and Create Book's name (v8 h12 surface r8), `pageFieldChrome`'s
styled arm, the lock face's two fields and its private `field` card, and a fourth build the audit did not count,
`mobileSecretFieldChrome` (all now `phoneField`); the ten SwiftUI sheet headers of T72 plus Book Details' and
Create Book's (twelve, all `PhoneSheetHeader`); the word-row choices — Create Book's kind, OR/AND and the block
list's segments (the segmented choice) and the Trash's kinds (filter chips, P-47-11); the fifth row, the Library
filter row, stays words (P-47-10). Held by `MobilePhoneControlsSourceTests` (below).

**The inventory — every G §2 site (T1–T109).** ADOPTED = on a shared control · HIT AREA = given 44 pt through
`phoneHitArea` / a 44 pt frame / `PhoneHitAreaButton` · OK = already ≥ 44 × 44 · LEFT = with the open ticket
that owns it (owners from `notes/TICKETS.md` and `notes/plans/vm-44/plans/minted/`).

| ID | Site | Outcome |
|---|---|---|
| T1 | Tab bar | LEFT — VM-52 (this run's batch 4) |
| T2 | 🗑 trash door (Shelf, Library) | ADOPTED — icon button |
| T3 | Shelf + New Note | ADOPTED — inline act (15) |
| T4 | Shelf Settings | ADOPTED — icon button, the gear (P-47-9) |
| T5 | Shelf book row | HIT AREA (row already 44 by `bookRowHeight`) |
| T6 | ✎ today badge | ADOPTED — chip |
| T7 | + New Book row | HIT AREA |
| T8 | today fallback row | HIT AREA |
| T9 | book row long-press | system menu — n/a (visible doors: VM-86; the book menu: VM-115) |
| T10 | quick-note box at rest | LEFT — VM-74 (the capture box at the foot) |
| T11 | quick-note open ↵ | LEFT — VM-73 (File and Open) — inside the box's measured chrome (`writingBoxChromeHeight`), not a one-line change |
| T12 | Starred row | HIT AREA |
| T13 | Library + New Note | ADOPTED — inline act |
| T14 | Library search field | ADOPTED — field |
| T15 | filter doors ×5 | HIT AREA — 44 tall, word-wide (P-47-10); the full 44 × 44 and the row: LEFT — VM-93 |
| T16 | sort glyph | HIT AREA — 44 tall, glyph-wide (#92(b)'s budget); full: LEFT — VM-90 |
| T17 | Library note row | HIT AREA |
| T18 | Library book row | HIT AREA |
| T19 | search hit row | HIT AREA |
| T20 | Archived row | HIT AREA |
| T21 | scraps pool picker (`Menu`) | HIT AREA (on the Menu's label) |
| T22 | + new scrap | HIT AREA |
| T23 | book nav bar details · read | OK (system) |
| T24 | book contents note row | HIT AREA |
| T25 | + New Note / + New Chapter rows | HIT AREA |
| T26 | Book Details Done | ADOPTED — sheet header |
| T27 | book name (rename) | HIT AREA |
| T28 | Finish / Reopen | ADOPTED — menu row |
| T29 | Use as Daily Journal | HIT AREA (its disabled read — the ✓ — kept, so not the dimming row style) |
| T30 | Delete Book… / Archive | ADOPTED — menu row |
| T31 | Create Book close | ADOPTED — sheet header (Cancel, P-47-13) |
| T32 | book-name field | ADOPTED — field |
| T33 | kind doors | ADOPTED — segmented choice |
| T34 | tag picker rows | HIT AREA |
| T35 | OR / AND | ADOPTED — segmented choice |
| T36 | Create Book | ADOPTED — calm button, full width |
| T37 | Read page body | OK |
| T38 | Write title (rename) | HIT AREA |
| T39–T42 | masthead copy · find · lock · ⋯ | ADOPTED — icon buttons (P-47-12); the masthead's rebuild: VM-148 |
| T43 | membership chip | HIT AREA (44 tall) |
| T44–T48 | date · tags · more info · blocks · lens chips | HIT AREA (44 tall, reaching 6 into the old gaps — P-47-12); capsules and one row: LEFT — VM-148 |
| T49 | Unlock Note | ADOPTED — inline act |
| T50 | receipt Undo / Redo | LEFT — VM-61 (the one message line at the foot; a 44 pt row in the masthead would deepen the prose's jump on every act) |
| T51 | ⑂ fan badge | LEFT — VM-188 (the visible badge) / VM-195 (the marks' cluster in a 44 pt hit area); a gutter button's region over the text is the editor's touch road |
| T52 | ●n comment marker | LEFT — VM-195 |
| T53, T54 | takes pill ‹ › ✓ | LEFT — VM-188 (the pill at the foot) |
| T55 | keyboard bar resting trio | OK |
| T56 | formatting strip ×11 | her ruled exception (R22/R25) — VM-139 |
| T57 | Takes Done | HIT AREA (`PhoneHitAreaButton`) |
| T58 | Branch this one / Blank | HIT AREA |
| T59 | Turn takes into blocks | HIT AREA |
| T60, T61 | take card ✓ / ⋯ | HIT AREA (within the card's bounds) |
| T62 | archived card ⋯ | HIT AREA |
| T63 | take card body | LEFT — VM-152 (native sheets) / VM-189 |
| T64 | Comments Done | HIT AREA |
| T65 | comment draft field | LEFT — VM-14 (the field above the keyboard) / VM-193 |
| T66 | Add / Save | HIT AREA |
| T67 | Cancel (editing) | HIT AREA |
| T68 | per-comment Edit / Delete / Restore; the deleted fold | HIT AREA |
| T69 | Block history Done | HIT AREA |
| T70 | history row act | HIT AREA |
| T71 | history rows (fixed 30–34) | LEFT — VM-41 (History and lineage as one sheet) / VM-152 |
| T72 | the ten SwiftUI sheets' Done | ADOPTED — sheet header (Tags, More Info, Books, Note Actions, Blocks, Lenses, Tag manager, Acknowledgments, the edit trace, Settings) |
| T73 | Tags type field | ADOPTED — field |
| T74 | ✕ remove | ADOPTED — inline act |
| T75 | suggestion rows | HIT AREA |
| T76 | link row | HIT AREA |
| T77 | + add a link | HIT AREA |
| T78 | diverge / remove | ADOPTED — inline act |
| T79 | open copy | ADOPTED — inline act |
| T80 | + book rows | HIT AREA |
| T81 | Note Actions rows | ADOPTED — menu row (64, a detail line) |
| T82 | Select / Done picking | ADOPTED — text button, in the sheet header's trailing slot |
| T83 | block list segments | ADOPTED — segmented choice |
| T84 | Delete N | ADOPTED — inline act (alarm) |
| T85 | block list rows | HIT AREA (44 tall; they carried no padding); reorder and the bulk bar: VM-149 |
| T86 | tray takes fold | ADOPTED — inline act |
| T87 | tray Put back / Delete now | ADOPTED — inline acts; their separation (opposite sides or the remover behind a menu, sheet §B): LEFT — VM-153 |
| T88 | Lenses "the note" row | HIT AREA |
| T89 | lens rows | HIT AREA |
| T90 | restore · save · save into · adopt | ADOPTED — inline acts (the save doors at 17) |
| T91 | Versions back to listing | ADOPTED — inline act (17) |
| T92 | version row | OK (and a hit area) |
| T93 | restore / promote / delete | ADOPTED — inline acts |
| T94 | Trash sort | ADOPTED — inline act |
| T95 | Empty Trash | ADOPTED — inline act (alarm, 17) |
| T96 | Trash kind doors | ADOPTED — filter chips (P-47-11) |
| T97 | Trash row Put back · Delete now · Open note | ADOPTED — inline acts; their separation: LEFT — VM-100 (the Trash's rows and Select) |
| T98 | Archive row Unarchive · Open note | ADOPTED — inline acts |
| T99 | Settings voice rows | HIT AREA |
| T100 | Settings doors (Protection…, Acknowledgments, Manage Tags, edit trace, DEBUG rows) | ADOPTED — inline acts at 17; the record toggle HIT AREA; the list's shape: VM-53 (batch 5) |
| T101 | Settings sync row doors (`PageDoor`) | ADOPTED — calm button / inline act (the phone arms) |
| T102 | Tag manager + new tag | HIT AREA |
| T103 | Tag manager rows (long-press only) | LEFT — VM-86 (every act a visible door) / VM-101 |
| T104 | `MobileRoadButton` | ADOPTED — calm button |
| T105 | passphrase / twelve-words fields | ADOPTED — field |
| T106 | use the twelve words | ADOPTED — inline act |
| T107 | Protection screen doors | ADOPTED — inline acts (17) |
| T108 | gate radio rows | HIT AREA |
| T109 | library-missing Start | ADOPTED — calm button |

Tally: 107 sites + T72's ten — no site without an owner. LEFT: T1, T10, T11, T50, T51, T52, T53, T54, T63, T65,
T71, T103, plus the widths of T15/T16 and the layouts of T44–T48, T87, T97.

**The path line (the batch-1 carry-in), traced and fixed.** Mechanism: in Terminal every glyph is SF Mono; the
path "~/shelf · 14 books" (≈157 pt at 13) beside the 🗑, "+ new note" and "settings" at 17 (≈102 + 82) with three
16 pt gaps and the 20 pt gutters needs ≈437 pt — over 402 and 430 — so the path text, the HStack's one flexible
member, wrapped (+23 pt of chrome). Fix: the doors are the controls with touching 44 pt hit areas (🗑 and the
gear icon buttons, + New Note an inline act at 15) — ≈390 pt in Terminal at 402; the line is centred, 44 tall,
4 pt under the safe area (its drawn path text where it was); Starred's line takes the same 44 pt so the three
roots start level as the band pages. Pin: `MobilePathLineGeometryTests` (the path text one line, every door
44 × 44 on the path's line, after it, inside the surface — Terminal and Study, 402 and 430; and the Library's
twin). **Red-on-old: PROVEN** (the closer, 2026-11-19; §4 row 2.8d). Run in a detached SNAPSHOT so this run's
worktree never sat reverted — `09fba8983` with `MobileShelfView.swift` / `MobileLibraryView.swift` checked out from
`91d406593` (they changed only in `47ee432fc` since), built into its own `DerivedData/vm47-rol`, the one type run
by the orchestrator on the standing device: "Test run with 2 tests in 1 suite failed after 6.874 seconds with 22
issues". The Bookcase case, 18 issues: the path line two lines tall (33.3 pt against the < 26 bound, :86) in
Terminal at 402 and 430 — and in Study at 402, which the true pre-fix tree fit: the snapshot keeps the fixed tree's
44-wide 🗑 icon button (`MobileRecoveryDoors.swift`, not reverted) beside the old 17 pt word doors; the word doors
20.3 pt tall in Study and, in Terminal, wrapped to two lines themselves (63–74 × 42.7 pt) (:93 ×8); and off the path's
line (:96 ×7). The Library case, 4 issues: its New Note door 20.3 pt tall in both voices (:128) and off the line
(:129). Both cases green on the fixed tree (the phone leg). The snapshot was removed after.

**Tests — RUN (the orchestrator's windows; the closer dispositioned the reds).** Phone leg, the whole target
from `DerivedData/vm47-b2` at `09fba8983`: "Test run with **900 tests in 148 suites** failed after 510.176 seconds
with **12 issues (including 8 known issues)**", XCTest "Executed 0"; the 8 known are the four pre-existing (the
empty-accessibility-tree diagnosis ×2, the fanned-divide lesson ×2) and P-47-7's four filter-row marks. Mac leg,
the seven theme types from `vm47-b2`: "Test run with **42 tests in 7 suites passed** after 16.983 seconds",
`** TEST EXECUTE SUCCEEDED **` — the Mac's token pins byte-identical. Three reds, each dispositioned:
1. **`MobileMarkdownCaretTests.aReplaceThroughTheInputRoadAtARescuePointKeepsTheSurfaceInStep(_:)`** — VM-24,
   pre-existing (batch 1's record traces its history); NOT THIS RUN'S — nothing changed.
2. **`MobilePhoneControlsTests.theFieldIsAtLeastFortyFourTallAndGrowsWithItsText()`** — :202, `probe.size.height
   > 44` at xxxLarge, measured 44.0. **THE TEST'S PREMISE — fixed test-only, `7762aef3b`.** Mechanism: a field's
   typed text is the `control` role, chrome, which grows with the text size to xxxLarge (17 → 23 pt) and holds; a
   23 pt SF line (≈ 27.4) with the field's 8 above and 8 below is ≈ 43.4, inside the 44 floor — so a control field
   is exactly 44 at every size, holding its grown text without clipping it. `> 44` was unreachable by the layer's
   own numbers; the control is not failing to grow. All seven phone field sites are one-line `control` fields.
   The pin now holds: ≥ 44 and ≥ the text's line + 16 at Large, xxxLarge and AX5; the same height at AX5 as at
   xxxLarge (chrome holds); a field given her words' role (`noteBody`) growing past 44 at AX5; a wrapping field
   growing by its lines (a floor, no ceiling). Which class a field's typed text belongs to is put to her as
   **P-47-14** (§5); the control is unchanged.
3. **`MobilePhoneControlsTests.theSheetHeaderPutsDoneEightFromTheEdgeOnAFiftySixRow()`** — :61, "no element
   labelled tags: ["Tags", "done", "content"]". **THE TEST'S LOOKUP — fixed test-only, `a37789cb9`.** Mechanism:
   the case built `PhoneSheetHeader("Tags", …)` with a raw title and looked it up voiced (`chromeLabel` → "tags" in
   Terminal). The header draws and speaks its title exactly as handed — by design, since Settings,
   Acknowledgments and the edit trace hand it a `path` title that must not be re-voiced — and all twelve sites
   hand it `chromeLabel(…)` or `path(…)`, as the pre-batch headers spoke them. Done was found ("done") and passed
   its 8-from-the-edge and 56 pt row checks in Terminal before the title lookup. The case now builds the title
   voiced.
After the fixes: phone `build-for-testing` into `vm47-b2` GREEN at `557664d3b` (no `Shared/` change; the Mac build
stands). The targeted re-run `rerun=(MobilePhoneControlsTests)` is PENDING its window. The new and touched suites
named below were green in the phone leg apart from those two cases.

New: `MobilePhoneControlsTests` (14 — each control's hit area and
minimum, the header's 56 row and its Done 8 from the edge, the header's Done driven by its voiced word, the
segmented choice's selection contract in both voices, the section header's air, the menu row's three floors,
the UIKit button's region), `MobilePathLineGeometryTests` (2), `MobilePhoneControlsSourceTests` (2 — its
patterns measured by script over the pre-batch tree `751765baf`: 11 Done literals, 4 field insets, 5 calm
paddings (2 the allowed cards), 13 paper shapes (2 the allowed cards), 4 word rows; clean now). Suites the
batch's changes touch and that must stay green: `MobileFilterRowGeometryTests` and `MobileFilterTests` (the
filter doors now 44 tall), `MobileBlockListTests` and `MobileNoteTrayTests` (the segments are the segmented
choice — driven by their plain words through the new elements), `MobileShelfLayoutTests` /
`MobileShelfRenderedLayoutTests` / `MobileShelfTodayDoorTests` (the path line now 44 tall; the today chip),
`MobileQuickNoteTests`, `MobileNavigationTests`, `MobileTrashTests`, the protection suites, the takes/comments/
history suites (the overlays' buttons are the hit-area subclass), and on the Mac `SharedPageStyleTests` (the nil
arms untouched).

**Recorded and left, each with an owner.**
- The editor's text inset — not changed (see the first paragraph) — VM-137.
- The filter row at 320 pt Terminal (P-47-7's known issue) — VM-93, with P-47-10.
- The receipt's Undo/Redo still 20 pt tall in the masthead — VM-61.
- The masthead's title now has 54 pt less beside four 44 pt tools; copy and seal move into the ⋯ at VM-148.
- A remover beside a restorer on the same row (Trash, tray) — VM-100, VM-153 (sheet §B's rule).
- The section header is built but not yet adopted anywhere (no G §2 site is one) — each screen's umbrella.
- The sheets' grabber and detents (sheet §E's "real sheets with detents") — VM-152.

**Self-assessment (for the cold reviewer, against the sheet and audit G).** The controls are one file, styles
over batch 1's roles and metrics, so a size changes in one place. The riskiest calls: (1) the segmented choice is
the system control with its accessibility replaced by my own per-segment elements (needed so a segment speaks its
plain word and a pin can drive it; the lookup confirmed an override must list every segment, which it does) and
its segment widths set by me from the words — the suites and the walk are its first real look; (2) the filter
row kept as words (P-47-10) against the brief's list of five word rows — argued from her #92(b) and the system
control's truncation; (3) the masthead's tools moved to 22 pt glyphs in ink inside a row kept as built
(P-47-12), which tightens the title; (4) the overlays' hit areas cannot reach outside a button's superview, so a
card's ✓/⋯ gain only what the card's own bounds allow; (5) `PageDoor`'s destructive arm now wears the voice's
alarm instead of the literal red — the phone arm only; the Mac's nil arm is byte-identical. The Mac's look cannot
have changed: `VoiceTokens.swift` is untouched, `SharedPageStyle`'s nil arms are unchanged, and the new Shared
code is SwiftUI the Mac compiles but never renders (the UIKit pieces behind `os(iOS)`).

### Batch 3 — results (implementer: Opus, 2026-11-19)

**Not done in this batch, first:** (1) the note in WRITE is not on the paper — its ground is one line in
`MobileEditorTextView.applyVoiceChrome` (`backgroundColor = face.room`), a file this run may not edit; Write wears the
VOICE's own room instead (never the palette's tint — her R-47-1 words hold), PROVISIONAL P-47-16, the paper owned by
VM-137 (three lines: that one and `MobileWriteView`'s two ground lines); (2) the full builds, the suites, VM-54's
red-on-old and the walk are PENDING — the stage coordinator's QUIET (another run's merge gate) held every full
`build-for-testing` from mid-batch, so this batch closes its code with the phone APP target building incrementally
green and the Mac APP target compiled, and the rest waits for "QUIET over" and the stage window (§4 rows 3.6–3.8);
(3) rows inside SHEETS that carry her words (the Blocks sheet's block previews, the tray's previews) and the three
UIKit overlays' sheet grounds are left with owners (below) — more than a background line each.

**The hoist (3.1, `dc9a5fd05`).** `ThemeStore` moved whole, by `git mv`, from `Variorum/Theme/` to
`Shared/Theme/ThemeStore.swift`: the observation (`Queries.themeSettings`), the settings → tokens road
(`tokens(dark:)`, `tokens(for:)`), every setter (`setVoice`, `setThemePalette`, …), `editingIndicator(of:)` — all
byte for byte. Stayed behind `#if os(macOS)`: `EditorTypography.adopt(value)` (a Mac-only type) and
`session.status.receiptStyle = …` (`AppSession.status` is Mac-only). Two ADDITIVE members came with the phone road
(3.2, `987e9edc5`): `onLanded` (the phone's landing seam — nil on the Mac, so the Mac's loop is unchanged) and
`init(session:placeholder:)` (default `Queries.ThemeSettings()` — every Mac call site is unchanged). `VoiceTokens.swift`
is not edited; no Mac view or test changed. (Its doc comment on `resolve(settings:dark:)` still says "the phone's
voice is LOCAL (LK2), so its road is the four-parameter form … never this" — now stale; the file is fenced, so it is
recorded here for the next pass that may touch it.)

**The resolution road (3.2 + 3.3, `987e9edc5`) — one pointer per site.**

| Site | Before | Now |
|---|---|---|
| `VariorumMobileApp.lockedTokens` (the lobby: lock, words card, library-missing) | `.resolve(voice: MobileVoicePreference.current(), …)` | `.resolve(settings: MobileShellRouter.placeholder, …)` — what a library that has chosen nothing reads, Study under the sea-glass (P-47-15) |
| `MobileShellView.tokens` (the three roots, every pushed screen and sheet it hands tokens to) | `.resolve(voice: router.voice, …)` | `router.tokens(dark:)` = `VoiceTokens.resolve(settings: router.settings, dark:)`; the shell binds the store (`router.bindTheme(session:)` in its initializer, idempotent per session) and starts it (`.task`) |
| `MobileWriteScreen.tokens` (the masthead and Write's sheets) | `.resolve(voice: router?.voice ?? fallbackVoice, …)`, and the initializer WROTE `MobileEditorStyle.voice` | `router?.tokens(dark:) ?? .resolve(settings: MobileEditorStyle.settings, …)`; the write and `fallbackVoice` are gone |
| `MobileSettingsView.tokens` | `.resolve(voice: router.voice, …)` | `router.tokens(dark:)` |
| `MobileEditorStyle.Face` (the UIKit editor, the keyboard bar, the takes chrome and pill, the three overlays, the block decor) | per-voice static faces over `.resolve(voice:dark:)`, chosen by an unsynchronised global voice | the voice's static face with the palette laid over its seven palette slots (`Face.applying(palette:tint:)` — surface, line, accent, card, take tint, take line, the markdown link) through the four-parameter resolver, resolved once per landed palette for both appearances; every other slot is the voice face's own object |

Light or dark is the device's: the appearance is the `dark:` argument the device's scheme supplies to every road
(SwiftUI's `colorScheme`; UIKit's dynamic colours), never a setting the phone reads or writes (LK-2). A change made
on the Mac (or arriving by sync) lands through the store's observation and reaches the chrome (observed) and the
editor (`MobileShellRouter.adoptLanded` → `MobileEditorStyle.adopt` → `editors.applyVoiceChangeEverywhere()` when
the face moved).

**QUESTIONS #195 MINOR 3, closed — how.** The review's hazard was `MobileEditorStyle.voice`, a `nonisolated(unsafe)`
global written from three places and claimed "main-thread" only in a comment. Now: (1) the storage is `@MainActor`
— the claim is compiler-enforced, and the phone app compiled with every reader main-actor; (2) the app has ONE
writer, `MobileEditorStyle.adopt(_:)`, called only where the library's settings land (the router's theme seam) — the
Write screen's init write and the router's init write are deleted; (3) the face is no longer a "third home" of
voice state with its own truth: it is a cache of the LIBRARY's landed settings, the one truth. The residual, said
plainly: `voice`'s setter survives as the harness door the suites use (~40 test sites), and the suites still share the
process-global look — a test that sets a look, awaits, and reads can interleave with another suite at the await (a
logical, not a data, race). The editor worlds (`withEditorWorld`) now reset the WHOLE look (voice and palette) at
start, and every look-switching test restores in a `defer`. Making the editor face per-editor (injected, no global)
needs the fenced editor files — VM-137's.

**The retired preference (3.3).** `VariorumMobile/Theme/MobileVoicePreference.swift` is deleted. Nothing in the
phone reads its key (`io.lduarte.variorum.mobile.themeVoice`), so a value a device stored under it is simply never
read — no migration, no crash road (pinned by a source scan, `MobileLibraryLookTests.theRetiredVoicePreferenceIsReadNowhere`;
a suite never writes the test host's defaults, which are the Debug app's). The two Settings voice rows keep their
words; a press calls `router.setVoice`, which runs `ThemeStore.setVoice` → `Operations.setThemeVoice` — the Mac
Settings' own write (`AppSettingsView`'s Picker and RootView's palette commands call the same setter); the row's ✓
reads the library's voice as it LANDED, so a voice chosen on the Mac shows here.

**The grounds (3.4, `af487bfe7`) — screen by screen.** The rule as built: where her words are listed or read, the
ground is the paper (`tokens.surface` — the voice's own white in light, the palette's hued paper in dark); bars,
sheets and bands stay on the room.

| Screen | Paper | Room |
|---|---|---|
| Bookcase (root) | the books region and the capture box (`MobileShelfView`, the region's `.background(tokens.surface)`) | the path line, the status lines, the tab bar |
| Library (root) | the rows, previews, search passages, the books and scraps listings, the Archived row (the scroll region) | the path line, the search field's surround, the filter row, the status lines, the tab bar |
| Starred (root) | the starred rows | the path line, the error line, the tab bar |
| A book's contents (pushed) | the whole page (`MobileBookView` ground) | — (its system bar region shows the page's ground; the bar is VM-52's, batch 4) |
| Archived, Trash (pushed) | the whole page | the report band at the foot |
| Versions (pushed) | the listing and the reader | the verbs band and the report band |
| Read (pushed) | the cream page itself (voice-independent, R2 — unchanged) | the room around it is the VOICE's own (`ReadingPageTokens.room`, the Mac's R-13u-10: never the palette's) |
| Write (pushed) | — | the editor, the screen and the masthead all wear the voice's OWN room (P-47-16 — never the tint; the paper is VM-137's) |
| Every SwiftUI sheet (Settings, Create Book, Book Details, Tags, Books, More Info, Blocks, Lenses, Note Actions, the tag manager, Acknowledgments, the edit trace) and Protection | — | unchanged, on the room (the sheet's rule) |
| The three UIKit overlays (takes, comments, block history) | unchanged: the take cards on `card`, the comments and history rows on the overlay's `surface` — her words already on the paper family | the "sheets on the room" half: VM-152 (native sheets) |

Listed and left, with owners: the note in Write on the paper — VM-137 (P-47-16); the Blocks sheet's block previews
— VM-149 (the blocks list); the tray's previews in the same sheet — VM-153; the three UIKit overlays' grounds —
VM-152; a peeked take card wears the take tint (R13's takes register — a palette slot, so under a palette it is the
palette's light tint) — kept as R13's ruled register, for her look pass; the pushed screens' system bar region (it
shows the page's paper) — VM-52 (batch 4).

**The star (3.5, `af487bfe7`).** The starred rows' ★ (`MobileStarredView`, the phone's only star glyph) reads
`tokens.star` (blue in every voice) instead of `tokens.accent`.

**The walk's palette seam (3.8, `242c48951`) — an instrument, recorded.** `MobileWalkLaunch` (DEBUG only): when the
UI-test driver hands `VARIORUM_WALK_PALETTE` in the launch environment, the shell writes that palette into the open
library through `Operations.setThemePalette` before its store starts. The phone has no palette door and the walk's
simulator library syncs with nothing; no words, no key of its own, compiled out of Release.

**Tests (written; counts PENDING the stage).** New: `MobileLibraryLookTests` (7 — a fresh library wears Study under
the sea-glass, chrome and face; a look written elsewhere reaches the phone and its OPEN editor, and `.default`
returns the voice's static face; light or dark stays the device's and resolving writes nothing; the placeholder IS
an empty library's read; `adopt` moves the face only when the look moves and shares the voice's colour objects; the
editor's ground is never the palette's tint, over every palette × voice × appearance; the retired preference is read
nowhere), `MobileLookSourceTests` (4 — the grounds and Read/Write's room, the star, the phone's no-literal-colour
twin), `MobileBorderTraitTests` (4, VM-54). Moved: `MobileShellTests.theVoiceDoorWritesTheLibraryAndTheLandingReachesTheOpenSurface`
(was `theVoiceFlipReachesPreferenceStyleAndTheOpenSurface`), `MobileLivenessTests.aVoiceFlipReachesEveryRegisteredEditor`
(drives the landing seam), `MobileVoiceTests` (the preference pin retired; the face baseline resets the whole look),
`withEditorWorld`, and three router constructors (`MobileFilterTests`, `MobileVersionsTests`,
`MobileProtectionScreenTests`). Red-on-old: the grounds and star source patterns measured over `ea738c49f` — 10 of 10
checks fail there, 0 of 10 now; the no-literal-colour twin is a new guard (green on old as on new — it finds only
the canary it allows); `MobileLibraryLookTests` pins new behaviour (a fresh library read Terminal Classic before).

**The Mac suites this batch owes** (every Mac test type that constructs or reads the hoisted store — by name or
through `withAdoptedTheme` — plus the seven theme types; 119 types, computed by a scan of `VariorumTests/` for
`ThemeStore` per test type, whole files where the store is used by a file-level helper, and the callers of
`withAdoptedTheme`): handed to the orchestrator as a zsh array in the READY report. The whole Mac target runs at the
merge gate.

**For `notes/QUESTIONS.md` at the merge (this branch does not edit it):** #199 — the `ThemeStore` hoist, deferred
2026-08-31, LANDED here (`dc9a5fd05`); #195 MINOR 3 — CLOSED (`987e9edc5`, `90228e98a`): main-actor storage, one app
writer where the library's settings land; the residual (the suites share the process-global look across awaits)
stated above, owned with the editor seam (VM-137). P-47-15 and P-47-16 (§5) are this batch's new PROVISIONAL calls.

**Self-assessment (for the cold reviewer).** The road is the Mac's own, reused: the hoisted store, the settings →
tokens road, the Mac Settings' voice write — the phone adds a landing seam (`onLanded`), a placeholder, and the UIKit
face's adoption. The riskiest calls: (1) **Write is not on the paper** (P-47-16) — the editor's ground lives in a
fenced file, so Write wears the voice's own room; her words are never on the tint, but the sheet's paper is not
there, and a reader of R-47-1's "the note in Write … the paper" will see the gap; (2) **the placeholder** (P-47-15)
diverges from the Mac's storeless Terminal on purpose, to avoid a wrong-voice frame at every launch; (3) **the global
look** is still a process global (main-actor now, one app writer) because the fenced editor files read it statically
— the tests' shared-global residual is stated, not removed; (4) **a pure palette change re-bases open editors'
storage** (`applyVoiceChange` — attributes only, O(open note), at a rare deliberate act), where the Mac takes a
cheaper colour-only road; the phone's editor files are fenced and the road is the LK2 flip's, already pinned; (5) **the
grounds are background lines**: the roots' list regions, not whole screens, so the bars keep the room — under the
sea-glass the roots read as a tinted band, a white page, a tinted bar, as the sizing sheet draws; the walk is its
first look; (6) a **window before the first landing**: a Write screen opened before the theme store's first emission
(a few milliseconds after the shell's first render — no tap can land there) would wear the editor face's previous
look. The Mac cannot have changed: `VoiceTokens.swift` is untouched; `ThemeStore` moved whole with two additive
members whose defaults are the Mac's; no Mac view or test file changed.

**VM-54 — the trace and the verdict (code; the on-screen check rides this batch's walk window).**

- *The four sites, as they stood at `ea738c49f`.* `MobileTakesCardView.apply` (`MobileTakesBrowserView.swift:709`):
  `layer.borderColor = (card.isChosen ? face.chosenMark : face.line).resolvedColor(with: traitCollection).cgColor`.
  `MobileArchivedTakeCardView.apply` (`:904`): `face.line` the same way. `MobileTakesPillView.apply`
  (`MobileTakesChrome.swift:460`): `face.takeLine` the same way. `MobileCommentsSheetView.layoutChrome`
  (`MobileCommentsSheetView.swift:215`): `draftField.layer.borderColor = face.line.resolvedColor(with:
  traitCollection).cgColor`.
- *The mechanism.* Each takes a DYNAMIC `UIColor` from the face and resolves it into `CALayer.borderColor`, a
  fixed `CGColor`, for the appearance of that moment. On a light/dark change UIKit re-resolves a view's own
  `UIColor` properties (the cards' `backgroundColor`, the labels' `textColor`), never a layer's colour. None of the
  four views registers for trait changes (no `registerForTraitChanges`, no `traitCollectionDidChange` in any of the
  three files), and none of the four `apply`/`layoutChrome` calls runs from a trait change: the takes browser's and
  the comments sheet's `render()` run only on their controllers' `onChanged` (a model change —
  `MobileEditorTextView.swift:291–301`), and the pill's `apply` runs inside `refreshChrome` (a scroll tick, an edit,
  a peek) only while the pill's block is near the viewport (`MobileTakesChrome.swift:285–301`). The setting call is
  never inside a layout method of the view whose trait it reads, so iOS's automatic trait tracking does not cover
  it either. So: flip the appearance with a take card, the pill or the comment draft on screen, and each edge keeps
  the old appearance's colour until the next model render — the pill's until the next scroll or edit near it.
- *Verdict from the code: NOT hollow.* Fixed: one helper, `MobileTraitBorder` (`VariorumMobile/Features/Write/
  MobileTraitBorder.swift`), keeps the dynamic colour and re-resolves it at every change of the view's
  user-interface style (`registerForTraitChanges([UITraitUserInterfaceStyle.self])`) and at each `set`; the four
  sites call `border.set(…)` instead of freezing a `CGColor`. Pin: `MobileBorderTraitTests` (4) — each view hosted in
  a real window overridden light, applied, then the window flipped dark and its traits propagated; the layer's
  border must read the colour's dark value. Red-on-old: PENDING its snapshot build (QUIET) and stage window. The
  on-screen check (the flip with a take card, the pill and the comment draft visible): PENDING the walk.
