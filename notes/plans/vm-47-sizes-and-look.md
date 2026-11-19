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
voice as the Mac's Settings does. Build (b) — phone-only users exist and need the choice — PROVISIONAL
(P-47-3). The grounds follow the Mac's rule as the sizing sheet draws it (content panes on the paper,
`tokens.surface`; bars, sheets and section bands on the room): PROVISIONAL (P-47-2), built only where it is
the root screens' and sheets' background lines; anything deeper is listed, not built.

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
| 1.1 | The layer in `Shared/Theme/`: the role table (both voices, SwiftUI + UIKit forms, two scaling classes), the two corrected inks (derived, floors pinned over every palette and voice), the metrics constants and the 44 pt hit-area helper; its tests | DONE (this commit) — `PhoneType.swift` · `PhoneInks.swift` · `PhoneMetrics.swift` · `MobilePhoneLayerTests.swift`; phone `build-for-testing` green; tests PENDING the stage; Mac build PENDING |
| 1.2 | Every phone type site reads a role — one commit per screen family (Shell · Write sheets · Takes/Read · Protection · the UIKit overlays) | DONE — Shell `ccd481162` · Write `76e34188c` · Read/Lenses `df8b334d2` · Protection + shared pages `841c9362b` · UIKit overlays (this commit); the shelf screen rides 1.4; the keyboard bar's 14 pt chrome DEFERRED to VM-137 (its bar shape is LK-4/LK-3's); phone `build-for-testing` green; tests PENDING the stage |
| 1.3 | The editor's face (`MobileEditorStyle`, face values only: note body per the sheet) | DONE (this commit) — body = the `noteBody` role (Study Iowan 17, Terminal mono 15) through `UIFontMetrics(.body)`; paragraph gap 14 / 12 and line pitch 27 / 25, both scaling with the body; `MobileVoiceTests` pins moved; the text inset NOT changed; phone `build-for-testing` green; tests PENDING the stage |
| 1.4 | W-024: `MobileShelfLayout` re-derived from the roles; the quick-entry text is the note body; the hint fits; pins moved | NOT-STARTED |
| 1.5 | The source-scan guard pin (no `tokens.small`, no literal under 13, outside `Spike/`/`Perf/`) | NOT-STARTED |
| 1.6 | Both schemes `build-for-testing` green → READY for the stage → the stage window: suites + walk captures | NOT-STARTED |
| 1.7 | §6 "Batch 1 — results" written | NOT-STARTED |
| 2 | Controls and targets (VM-50; VM-49's application) | NOT-STARTED |
| 3 | Voice and palette; borders (VM-51, VM-54) | NOT-STARTED |
| 4 | The bottom bar (VM-52) | NOT-STARTED |
| 5 | Settings (VM-53, VM-27) | NOT-STARTED |
| — | The ladder (Fable, fresh reviewer per round) | NOT-STARTED |
| — | Closeout | NOT-STARTED |

Each batch's implementer adds its own piece rows under its batch line as it starts.

## 5. PROVISIONAL calls and the list for her sitting

| Id | Call | Options | Built | State |
|---|---|---|---|---|
| P-47-1 | The sizing sheet's numbers (type roles, spacing, radii, row heights, the two inks) | as drawn · her own numbers | as drawn | PROVISIONAL — she has seen the sheet in use, not ruled it number by number |
| P-47-2 | Grounds: content panes on the paper, chrome on the room | the Mac's rule as the sheet draws it · every screen on the room, as built today | PENDING (batch 3) | PROVISIONAL |
| P-47-3 | A voice row on the phone that writes the library's voice | no row · a row writing the synced voice | PENDING (batch 3) | PROVISIONAL |

Held for her hands: a build on her phone for the look at true size (no device install runs overnight); her
glance at which Protection door stayed (VM-27); the wording pass over any new line.

## 6. Results, review and closeout

PENDING — each batch's results (counts, commits, walk captures), the touch-target inventory (batch 2), the
ladder's findings and dispositions, the canon deltas, the tickets filed.
