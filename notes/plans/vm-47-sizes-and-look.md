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
| 1.5 | The source-scan guard pin (no `tokens.small`, no literal under 13, outside `Spike/`/`Perf/`) | DONE (`bb30a4132`) — `MobilePhoneTypeSourceTests` (3 tests): no Mac type slot, no literal size or caption style under 13, no literal `minimumScaleFactor`; its patterns measured red on `fe85ea6d5` (332 slot reads, 32 sub-13 sites) and clean now; run PENDING the stage |
| 1.6 | Both schemes `build-for-testing` green → READY for the stage → the stage window: suites + walk captures | DONE for the suites (rows 1.6c–1.6d); the walk MOVED to batch 2's seam (row 1.6e) |
| 1.6b | CUTOVER (orchestrator, machinery honesty): the batch-1 implementer ended its turn READY at about 650k tokens of context, every piece committed and both schemes building. The stage window (suites, any reds, the walk) goes to a FRESH closer briefed from this record, not to the long session | the closer adds its rows below |
| 1.6c | The suites, leg 1: the whole phone target (`-only-testing:VariorumMobileTests`, test-without-building from `DerivedData/vm47-b1`, the standing device) | DONE (run by the ORCHESTRATOR under its own claim — the GO reached it while the closer was still reading) — **883 tests in 145 suites, 19 issues including 8 known** (XCTest "Executed 0"; nothing skipped); three reds, each dispositioned in §6: VM-24's caret suite (not this batch's, nothing changed) · `chromeHoldsAtXXXLargeWhileHerWordsKeepGrowing` (a real defect in the UIKit road, FIXED `4ec664f2b`) · `writingKeepsItsShareUnderAKeyboardSizedRegion` (the pin's denominator carried the path line; the pin MOVED to the rule's room, `29f2cbd41`). Both schemes `build-for-testing` green at `29f2cbd41`. **The targeted re-run (orchestrator, 05:26, `DerivedData/vm47-b1` at `29f2cbd41`, the standing device): "Test run with 118 tests in 12 suites passed after 60.571 seconds with 4 known issues", `** TEST EXECUTE SUCCEEDED **` — `chromeHoldsAtXXXLargeWhileHerWordsKeepGrowing()` and `writingKeepsItsShareUnderAKeyboardSizedRegion()` passed; the 4 known issues are P-47-7's two filter-row pins; `MobilePhoneTypeSourceTests` left out (it scans sources batch 2 is editing; green in the 04:40 whole-target run). Batch 1's suites are CLOSED; its walk rides batch 2's.** |
| 1.6d | The suites, leg 2: the Mac's `Shared/Theme` suites (`ThemeTokenTests PaletteDerivationTests NoLiteralColourTests SharedPageStyleTests PaletteReachTests MarkdownPaletteWritersTests HelperWindowThemeTests`) | DONE (orchestrator) — **42 tests in 7 suites passed**, `** TEST EXECUTE SUCCEEDED **`, no red. The red-2 fix touches only `PhoneType.swift`'s `#if os(iOS)` arm, so the Mac leg stands (Mac `build-for-testing` green at `29f2cbd41`) |
| 1.6e | The walk: a dedicated device `vm47-walk` (iPhone 17 Pro, iOS 26.2; created by the closer, never booted; its id lives in the reports, never here), seeded from a fresh install through the app's own doors (a first write lands the Journal and the sample book; the Debug pocket guide gives chapters, a three-take block and a tag; one note to the Trash; a saved version; one comment), driven by a THROWAWAY XCUITest driver kept with its runbook in the gitignored `notes/plans/vm-47-screens/instruments/` (`VM47WalkDriver.swift`, `walk.zsh` — each with a header that says how to build and run it cold, the device, the seed steps and every capture by name; built through the `TK2SpikeUITests` scheme into its own `DerivedData/vm47-walk`; the copy in `VariorumMobileUITests/` exists only for that build; never committed). Core screens × Study/Terminal × light/dark × default/largest (AX5); the rest × Study light default, Terminal dark default, Study light largest | MOVED — the orchestrator's call: **batch 1's suites close here; its walk rides batch 2's seam as ONE walk covering batches 1 and 2** (the queue is long, and a walk at the largest size belongs on the fixed tree). The driver's headless build is GREEN at `29f2cbd41` (`** TEST BUILD SUCCEEDED **`; the bundle carries `VM47Walk/test01_seed · test10_core · test20_rest`; the temporary copy removed, tree clean). The filter row at Display Zoom (320 pt) is NOT capturable (simctl cannot switch Display Zoom on) — recorded as not taken; the geometry pins are its evidence |
| 1.6f | The record close: §6 "Batch 1 — results" (counts, every red and its disposition, what was fixed, what is owned elsewhere); §5 for any new PROVISIONAL; this table flipped | DONE (this commit) for the suites; the walk's findings land with batch 2's walk; the targeted re-run's counts PENDING its stage window. No new PROVISIONAL |
| 1.7 | §6 "Batch 1 — results" written | DONE (this commit) — counts and the walk PENDING the stage window |
| 2 | Controls and targets (VM-50; VM-49's application) | IN-PROGRESS — pieces below (implementer: Opus, 2026-11-19) |
| 2.1 | The shared controls in `Shared/Theme/PhoneControls.swift` (text button, inline act, icon button, chip, field, the one calm button, sheet header, segmented choice on the system control, section header, menu row; the UIKit hit-area button for the overlays) + their geometry tests | DONE (this commit) — `PhoneControls.swift` + `PhoneType`'s `weight:` override + `MobilePhoneControlsTests` (14 tests); phone `build-for-testing` green; Mac build PENDING (running); tests PENDING the stage |
| 2.2 | Adoption, one commit per screen family, retiring each private build with its last user (the five calm buttons, the three fields, the ten sheet headers, the word-row choices) — Shell roots · book sheets · Write masthead · Write sheets · Shell sheets/screens · Protection · the UIKit overlays | IN-PROGRESS — Shell roots DONE (this commit: the Bookcase and Library path lines on the controls — 🗑 icon button, + New Note inline act, Settings a gear icon button (P-47-9), one 44 pt line, Starred's line level with them; the today badge a chip; the Library search on `phoneField`; every root row, the archive row, the scraps picker and the book's rows/doors given `phoneHitArea`; the filter doors and the sort glyph 44 tall, widths kept (P-47-10)); phone `build-for-testing` green. Book sheets DONE (this commit: Book Details and Create Book on the sheet header; Create Book's name a `phoneField`, its kind and its OR/AND on the segmented choice, its Create on the calm button; Book Details' act rows on `PhoneMenuRowStyle`, the rename name and the daily row 44 tall; the segmented choice sizes segments by their words, `PhoneSegmentWidths`; the path-line pin `MobilePathLineGeometryTests` written, red-on-old PENDING the stage). Write masthead DONE (this commit: its four tools are icon buttons — 22 pt glyphs in ink (the seal in the accent while sealed), 44 × 44 hit areas touching, the row kept; the title and the membership chip 44 tall; the five flow chips 44 tall reaching 6 into the old 12 pt gap (words where they were); Unlock Note an inline act; the receipt's Undo/Redo LEFT for VM-61 — a 44 pt row there would deepen the prose's jump on every act). Write sheets DONE (this commit: the sheet header on Tags, More Info, Books, Note Actions, Blocks (its Select door a text button beside Done), Lenses, the edit trace (path title kept muted) — and the Tag manager's; the tag field a `phoneField`; Note Actions' rows the menu row (64 with a detail line); the block list's segments on the segmented choice and its rows 44 tall; every inline act (✕ remove, diverge/remove/open copy, Put back/Delete now, the takes fold, restore/promote/delete, Delete N) on `PhoneInlineActStyle`; the lens rows, suggestion rows, link rows and + rows 44 tall; the leading door words (save/adopt, Refresh/Clear, back to listing) inline acts at 17). Shell sheets/screens DONE (this commit: Settings and Acknowledgments on the sheet header, path titles kept muted; Settings' door words (Protection…, Acknowledgments, Manage Tags, Edit trace…, the DEBUG doors) inline acts at 17 with 44 pt hit areas — the list's shape stays batch 5's; the voice rows and the edit-trace toggle 44 tall; the Trash's Empty Trash, sort, and row acts and the Archive's row acts inline acts; the Trash's seven kinds on FILTER CHIPS (the chip gains a selected state — P-47-11); the tag manager's + new tag 44 tall). NEXT: Protection · the UIKit overlays |
| 2.3 | The 44 pt hit area on every remaining G §2 site where it is a one-line change (`phoneHitArea()`) | NOT-STARTED |
| 2.4 | The path line (Terminal wraps at 402): doors as inline acts / icon buttons with 44 pt hit areas, ONE line at 402 in both voices; red-on-old geometry pin | NOT-STARTED |
| 2.5 | The source pin: the retired private button/field/header builds are gone | NOT-STARTED |
| 2.6 | The walk driver extended for the batch's surfaces; rebuilt headless into `DerivedData/vm47-walk`; both schemes `build-for-testing` green into `DerivedData/vm47-b2` → READY for the stage | NOT-STARTED |
| 2.7 | §6 "Batch 2 — results": each control with its pointer and sizes, the retired builds, the T1–T109 inventory with owners, tests (PENDING), PROVISIONAL calls in §5, self-assessment | NOT-STARTED |
| 2.8 | The stage windows (suites; then the walk, both batches' captures, looked at) — run at the orchestrator's GO | NOT-STARTED |
| 3 | Voice and palette; borders (VM-51, VM-54) | NOT-STARTED |
| 4 | The bottom bar (VM-52) | NOT-STARTED |
| 5 | Settings (VM-53, VM-27) | NOT-STARTED |
| — | The midway cold review, after batch 2 (her word; Fable, fresh) | NOT-STARTED |
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

**Self-assessment (for the cold reviewer).** The layer is one table and two forms over it, so a number
changes in one place; the inks are a rule whose output ships as constants with the rule pinned to them, so
a palette change is loud. The riskiest calls are (1) the filter row's `meta` against the sheet's `chip`,
(2) the overlays' fixed geometry under bigger type (sized by measurement on paper — not yet seen),
(3) the shelf's floor now taking the box's line at the current text size (a real change to her guarantee's
arithmetic, made to keep it in LINES now that the box's text scales), and (4) the masthead row, whose title
is now 24 pt beside four 17 pt icons (VM-148 rebuilds it). The Mac's look cannot have changed:
`VoiceTokens.swift` is untouched, `SharedPageStyle`'s nil arms are byte-identical, and every other
`Shared/` addition is new code the Mac compiles but never renders.
