# VM-47 — Run: Sizes and look (mobile catch-up, wave 1, umbrella 1)

**Ticket: VM-47 (team VM) · Project: Mobile — the catch-up & launch · Branch: `vm-47-sizes-and-look` ·
Worktree: `~/dev/variorum-vm-47` (Pro)**

**STATUS: OPEN** — begun 2026-11-19 overnight (`/run-phase vm-47`; the stage coordinator is the session `nov18`);
this banner as of 2026-11-20, the final record pass. All code is in: five batches, VM-55's re-land, the walk's two fix
batches, W-A1 redone, and main merged in twice — through `64fde83b0` at batch 7b (`3d55b51f6`). The midway review and
ladder rounds 1–4 are closed with no MAJOR open (round 4: one NIT, this banner — confirmed and discharged by its
rewrite; round 4 is also the narrow read of the W-A1 redo and of batch 7b that round 3 left owed). The walk is driven
and read in four capture sets, its fixes are in, and the post-merge window on the final tree ran green (row W.11).
**Owed before the merge:** the merge gate — the whole phone target with VM-64's speed suite as its own leg, and the
whole Mac target —, then the PR and its merge. **After it:** the ledgers on main (from
`notes/plans/vm-47-closeout-drafts.md`), the cleanup, and the wave-1 phone build's preparation (this run merges last of
the four; the install itself is hers).

## FOR A LATER READER

*Rewritten at the final record pass (2026-11-20) from the settled facts, before the merge. The slots left —
`‹PENDING: …›` — are the merge's own (the merge gate's results, the PR, its merge commit) and the wave-1 phone build.
Everything below this section is the night's working record.*

**What the run was.** The mobile catch-up's wave 1, umbrella 1: the phone takes the Mac's look at phone-right sizes.
Eight members — VM-48 · VM-49 · VM-50 · VM-51 · VM-52 · VM-53 · VM-54 · VM-27 — in five batches, then three re-lands
(VM-55's branch, batch 6; main with VX-981 and VM-78, batch 7; main with VM-64, batch 7b), two batches of the walk's
fixes and the screen-edge fix redone (W-A1). No `Sources/`,
`Sync/`, custody, schema or operation line; the Mac's look is unchanged (`VoiceTokens.swift` untouched, every Mac
token pin green). PR ‹PENDING: number›, merge commit ‹PENDING: SHA›.

**As built, one pointer per piece** (paths under `App/Variorum/`):
- *Type (VM-48).* `Shared/Theme/PhoneType.swift`: twelve roles from one table (13 · 15 · 17 · 20 · 24; Terminal's
  prose roles two points under, P-47-4), a SwiftUI form (`.phoneType`) and a UIKit one (`PhoneType.uiFont`); her
  words grow across the whole text-size range, chrome to xxxLarge and holds, nothing under 13 pt (`f5e21610d`; the
  sites `ccd481162` … `7cd8b866f`; the editor's face `575bb8677`; the shelf's arithmetic `6b02c806c`).
- *Inks, room to tap, controls (VM-49, VM-50).* `Shared/Theme/PhoneInks.swift` (`tokens.phone.muted` / `.faint`,
  clearing 4.5:1 and 3:1 on every shipped ground), `PhoneMetrics.swift` (the spacing scale, the 20 pt gutter,
  `phoneHitArea`), `PhoneControls.swift` (text button, inline act, icon button, chip, field, the one calm button,
  sheet header, segmented choice, section header, menu row, `PhoneHitAreaButton`).
- *Voice and palette (VM-51).* `ThemeStore` moved whole to `Shared/Theme/ThemeStore.swift` (`dc9a5fd05`), held by
  `MobileShellRouter`; every phone read takes `VoiceTokens.resolve(settings:dark:)` (`987e9edc5`); the phone's own
  voice preference is deleted; the grounds `af487bfe7` and the note in Write on the paper `4cca58a8e` (R-47-1).
- *The bar (VM-52).* `VariorumMobile/Features/Shell/MobileTabBar.swift` (`9c76b335c`), on the roots and pushed lists.
- *Settings (VM-53).* `Shell/MobileSettingsView.swift`, one grouped list that scrolls (`70368f6dc`); the appearance
  choice `Shared/Theme/AppearanceChoiceRule.swift` + `Shell/MobileAppearance.swift` (`a83c586f3`, this device's
  defaults); the ⋯ menu `Shell/MobileRootMenu.swift` and the note's door (`e622cbbb9`).
- *The screen's edges (W-A1, as redone).* The shell's band keeps main's `.clipped()` (`Shell/MobileShellView.swift`),
  so nothing a page lays out or scrolls passes the safe area; the strips beyond the band — under the status bar, over
  the home indicator, behind the keyboard bar and its corners — are painted by the shell, behind the band, in the
  showing page's DECLARED top and bottom grounds (`Shell/MobileEdgeGrounds.swift`: each page's
  `.mobileEdgeGrounds(top:bottom:)`, the board's pure rule, the painted layer — `5daf61efd`; what each page declares is
  §6 "W-A1 redone"'s table).

**The mechanisms, as settled — each pin red on the old code, green on the new:**
- *The Terminal path line wrapped:* a 13 pt mono path beside two 17 pt mono word doors wanted ≈ 437 pt at 402 —
  `47ee432fc`; `MobilePathLineGeometryTests` (22 issues on old).
- *UIKit had no 13 pt floor* (midway M-1): `PhoneType.uiFont` floored neither scaling class — `8bea26402`;
  `theUIKitFormIsNeverBelowThirteenPointsEither` (20 on old). Batch 1's held chrome also grew ⅓ pt past xxxLarge —
  `4ec664f2b`.
- *VM-54's borders* froze a dynamic colour into `CALayer.borderColor` with no trait hook — `1c3621719`
  (`MobileTraitBorder`); `MobileBorderTraitTests` (5 on old).
- *VM-27's one door:* one closure fed both the sync row's door and the standing row — `9c9aa4b6c` (the sync row in
  Settings is handed none; the standing row stays); `MobileSettingsProtectionDoorTests` (2 on old).
- *The screen-edge grounds* (W-A1, REDONE): the band's `.clipped()` cut every page's `ignoresSafeArea()` ground at the
  safe area. The first fix (`67525b499`, `MobileBandClip`, a clip free above and below) let each page's CONTENT out
  with its ground; the redo (`5daf61efd`) puts main's clip back and has the shell paint the strips. Pins:
  `MobileScreenEdgeGroundsTests` (its three first-fix pins unchanged, four new) and `MobileEdgeGroundsBoardTests`
  (`9f0dc1229`), red where meant on the first fix and on main's band (row W.11 (3)–(4)). The committed UI test
  `VariorumMobileUITests/MobileKeyboardRevealUITests` (`b1e345be0`; scheme `TK2SpikeUITests`, a dedicated simulator
  under a stage claim) holds the keyboard reveal: red on the first fix, green on the final tree (row W.11 (6)–(7)).
  **Re-run it** on any change to the band's clip or frame (`MobileShellView.body`), the Write screen's layout
  (`MobileWriteView`) or the editor host's keyboard handling (`MobileEditorTextView`), and with the per-release
  device checks (TEXTKIT2 §5) — no unit target's whole run includes it. Given back by design: the Read page's last
  line is cut at the band's foot again, as on main (P-47-43), and the strips are one colour across the width that
  switches at once in a push or a pop (P-47-44).
- *The hidden page's keyboard* (W-C2): the tab road's unanimated pop uncovers the Library and the framework hands
  its search the keyboard back — `05afd4b34` (`mobilePageShowing`); `MobileHiddenPageKeyboardTests`.
- The walk's other fixes: W-A3 `d974162f4` (its pin moved to the layout origin, `c72e65201`) · W-A9 `36987c78e` ·
  W-A10 `7734f0f05` · W-B1/W-C3 `a21110f9d` · W-B3 `71ccdd4fc` · W-B4 `fb649d6a8` · W-C7 `c7b6f0459` · the Account
  sheet's header and placeholders `2345a713a`, `c64f23782`.

**W-E4, in three lines.** With the first edge fix, a tap in the lower half of a note with the software keyboard up no
longer scrolled the note (0 pt, where main moves it 146 pt in Study and 118 in Terminal): the caret and a typed letter
stayed under the keyboard bar — seen at the re-capture, proved on the first fix's app by the orchestrator's settling
capture (`e4-before/`). The band's clip was the one line on that road that differed from main, so the redo put it
back; the UI test and the final tree's captures show main's reveal again (walk §4g G1–G2), and the same redo removed
W-E3 (her prose behind the keyboard bar) and W-F1 (under the status bar on a scrolled page).

**Both merges of main.** `4866c7fb8` (main `a09d6a025`: VX-981 and VM-78) — four phone files hunk by hunk by VM-78's
round-4 map, its governing rule ("the styling is VM-47's") over its quoted pre-walk inks; one join pin (`9147929f7`)
and one path this run had broken (`3c960718a`, a Mac test reading `ThemeStore.swift` at its old place). `3d55b51f6`
(main `64fde83b0`: VM-64) — four conflicted files (`.gitignore`, `VariorumMobileApp.swift`, `MobileSettingsView.swift`,
`MobileLibraryView.swift`) by VM-64's maps; its timing readout and its Settings door put on this run's layer, every
word VM-64's; two of its tests drive the tab by "Bookcase" (`9fcf7b7a2`); this run's source rules scan `Features/Perf/`
except files exempted by name (`MobileSourceRuleScope`, `d78853d8e`).

**Her rulings** (verbatim in §1 and §5): **R-47-1** — "grounds - prose should not be on the tint, which is what I
understood you mean. that sounds good." · **R-47-2** — "voice only row - yeah, that's fine." · **R-47-3** — her pick
"Bookcase (Recommended)" (the Bookcase root's top line says Bookcase). The run's shape: "yeah that's fine on the five
sequential batches - you can do a midway through review it if you prefer. also - up to 5 rounds as long as a major
is found." Built on the wave's LK-1/LK-2, LK-5, LK-6 and SW-1 (`notes/plans/vm-44/plans/sitting-1-rulings.md`).

**The evidence that matters.** Ladder (a fresh Fable reviewer each round, B/M/m/N): midway 0/1/2/2 · round 1 0/0/1/4
· round 2 0/0/0/2 · round 3 0/0/1/2 · round 4 0/0/0/1 (round 4 also the narrow read of the redo and of batch 7b). On
the tree with VM-55 re-landed: the whole phone target 1,045 tests in 179 suites (the one red main's VM-24 caret pin),
a targeted Mac leg 565 tests in 114 suites green. The post-merge window on the final tree (code `d78853d8e`, row
W.11): the phone 581 tests in 98 suites green, VM-64's speed suite alone 13 green, the three snapshots red as their
fixes require, the keyboard UI test red on the first fix and green on the final tree, the Mac 118 tests in 21 suites
green. The walk, in four capture sets read by fresh readers against the sizing sheet (`notes/plans/vm-47-walk.md`):
parts A and B, 283 of 285 (`final/` — eleven of this run's defects, ten fixed with pins, one put to her, P-47-30); the
re-capture after the first fixes, 164 of 166 (`recapture/` — every fix showed, and W-E4, W-E3, W-F1 were caught);
the settling capture of W-E4 on the first fix (`e4-before/`); the final tree, 119 of 119 (`final-tree/` — every fix
shows, the keyboard reveal main's again at 146 / 118 pt, no regression, no new finding). The merge gate: ‹PENDING:
the whole phone target with the speed suite as its own leg · the whole Mac target›.

**Open items.**
- Forty-one PROVISIONAL calls (P-47-1, P-47-4 … P-47-27, P-47-29 … P-47-44; §5): QUESTIONS #281 (the bundle, landed on
  main at the merge), her checklist `notes/handoffs/vm-47-handoff.md`; MOBILE PARITY row PL-80.
- Never seen in any capture or mounted test: the Account sheet's restyled header and placeholders and VM-64's timing
  readout on this run's layer (her phone is their first sight); VM-27's doored sync states (the pin only); the lobby
  (P-47-15); the filter row at 320 pt; the painted strips mid-push or mid-pop (P-47-44).
- The first thing to try on her phone: typing in the lower half of a note with the keyboard up (what the redo
  protects). The walk's captures are KEPT until her sitting (§5, "Held for her hands").
- Filed: VM-247 (a palette row on the phone), VM-248 (an unscoped database read in a phone test opens the simulator
  app's own store), VM-249 (Settings from a pushed list, a book's Read page and Protection — hers). The remainders on
  their owners, commented at the ticket pass: §6 "Closeout" and the handoff.
- The wave-1 phone install is this run's to prepare as the last mobile merger: ‹PENDING: the build and its block›.

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
- After the usage limit, about 11:50: "continue - I hit my limit, I have more now. I'm telling all sessions the same
  thing."
- At 14:10: "ok - seems like you have a decent amount left. I want you to prepare for compaction and give me a kickoff
  prompt to send you post compaction." (The orchestrator's handoff, `notes/plans/vm-47-orchestrator-handoff.md`, is
  that preparation.)
- **R-47-3, the Bookcase root's page word (was P-47-28; §5).** Asked first in chat at 13:50, answered by the question tool
  at 14:38. The question: "On the phone's home screen, the top line reads "Home · Shelf · 14 books" (in Terminal:
  "~/home/shelf · 14 books"), while the bottom bar's tab for that same screen now says "Bookcase" (your ruling: Starred ·
  Bookcase · Library). Should the top line's word change from "Shelf" to "Bookcase" too?" Her answer, the option she
  chose: "Bookcase (Recommended)" — "The top line says Bookcase, matching the tab, your swipe names and the Mac."

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
- *Batch 1's two fixes were PENDING their re-run* (the UIKit chrome's hold at xxxLarge, `4ec664f2b`; the
  keyboard-sized shelf pin, `29f2cbd41`). The orchestrator runs that re-run in a short stage window while
  this batch builds; if it comes back red the orchestrator hands the red to this batch's implementer.
  **RUN since, green (row 1.6c):** "Test run with 118 tests in 12 suites passed … with 4 known issues".
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

**Piece 3.10 — the note in Write on the paper (orchestrator, at the batch-3 seam; a NAMED exception to
rule 7).** Batch 3 left Write on the voice's own room (P-47-16) because the editor's ground is one line in a
fenced file. That keeps her prose off the tint, but it is not the paper: the lists are on `#FFFFFF`, Write on
Study's own `#FAF8F3`, and in dark the lists are on the palette's paper while Write is on black. R-47-1's
test is "wherever her words are read or written the ground is the paper", the sizing sheet draws Write on the
paper, and the Mac's own editor reads its paper (`EditorView.swift`, `scrollView.backgroundColor =
chrome.paper`). So this piece is authorized, and it is exactly this and no more:

- `Write/MobileEditorTextView.swift`, `applyVoiceChrome`: the ONE line `backgroundColor = face.room` reads a
  new face value for the paper instead (`tokens.surface` as the settings road resolves it, palette and all).
  No other line of that file changes; `MobileEditorViewModel.swift` and `Shared/EditorBrain/` stay untouched.
- `Write/MobileEditorStyle.swift` gains that face value; the face's `room` stays what the overlays, sheets and
  bars read (they sit on the room).
- `Write/MobileWriteView.swift`: the two ground lines batch 3 named follow, so the screen ground and the
  editor agree; the masthead stays chrome, on the room.
- A pin that the editor's ground is the paper in both voices, light and dark, under the sea-glass and one
  other palette, and that an overlay still reads the room; the grounds' source pin (`MobileLookSourceTests`)
  extended to Write. Check by eye in the walk that the caret, the selection wash, the take tint, a callout's
  wash and the comment mark read correctly on the paper in light and in dark.
- P-47-16 is rewritten to say what is built (the paper, by this one line) and the option left (the voice's
  own room). The ladder's Fable reviewer reads the line as editor-seam class.

**The stage work for batch 3 goes to a fresh closer** (the batch-3 implementer ended READY at about 675k
tokens of context, every piece committed). Main was merged in at this seam (`40352bde2`: the search run's Mac
and Core files; nothing under `Shared/` or `VariorumMobile/`), so the products are rebuilt before any window.
**One walk now covers batches 1, 2 and 3**: batch 3's driver (`VM47Walk3Driver.swift`, `walk3.zsh`, device
`vm47-walk3`) captures the same core and wider screens as the batches-1-and-2 walk, now under the palette
she will actually see, so the older walk (device `vm47-walk`, `DerivedData/vm47-walk`) is retired unrun and
removed.

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

**Carried in to batch 5 (orchestrator, at the batch-4 seam):**

- *What is under you.* Batches 1–4 are in the tree: the type roles, the two inks, the metrics and the shared
  controls (`Shared/Theme/Phone*.swift`), the library's voice and palette through the hoisted theme store
  (`Shared/Theme/ThemeStore.swift`, held by `MobileShellRouter`), the grounds (her words on the paper, bars
  and sheets on the room), and the bottom bar (`Shell/MobileTabBar.swift`), which now also shows on pushed
  lists. §6 holds each batch's results. Settings is built on the shared controls only: the sheet header, the
  section header, the menu row, the segmented choice, the calm button; no private builds (a source pin holds
  that), and system controls styled by the layer where one fits (the ticket's agent note).
- *The voice rows.* Batch 3 made the two existing voice rows write the library's voice (R-47-2). They move
  into the new list as one choice; their words stay.
- *Light · dark · follow the system* is this phone's own preference and never syncs (AppSpec §12: "appearance
  (follow system, light, dark) is a local preference"; her ruling LK-1/LK-2). Use the Mac's own brain and
  storage shape for it if it is or can be shared without changing the Mac; say what you found. The choice
  must reach the UIKit editor and the overlays as well as SwiftUI (batch 3's `MobileTraitBorder` is how the
  borders follow a flip).
- *The doors.* Batch 2 left Settings as a gear on the Bookcase's path line (P-47-9); this batch moves it into
  ONE ⋯ menu that all three roots carry, and gives a note its own door to Settings (the note's actions).
  Another run (VM-55) is putting an interim wing door on each root's path line tonight and merges before us:
  keep the ⋯ menu's edit on each root to the fewest lines, do not touch the wing door's lines or the path
  line's paddings, and name every line range you change in the three root views and `MobileShellView.swift`.
- *VM-27.* Trace which Protection door stays before changing anything; the pin is red on old in a snapshot
  worktree, never by reverting this worktree.
- *Build products and the walk.* Yours is `App/Variorum/DerivedData/vm47-b5`. Do not build into or delete
  `vm47-b3`, `vm47-b4`, `vm47-walk3`, `vm47-walk4`, or the snapshot and gate worktrees beside this one
  (`~/dev/variorum-vm-47-rol3`, `~/dev/variorum-vm-47-gate*`). **One walk covers batches 4 and 5**: batch 4's
  driver and runbook (`notes/plans/vm-47-screens/instruments/VM47Walk4Driver.swift`, `walk4.zsh`, gitignored,
  73 captures of the bar) were built and not run; extend a COPY into a batch-5 driver that keeps batch 4's
  captures and adds Settings (the list scrolled top to bottom in Study and Terminal, light and dark, default
  and AX5; the ⋯ menu on each root; the door from a note; the appearance choice flipped; the Protection row
  in the sync row's doored state if the seeded store can reach it), built into `DerivedData/vm47-walk5`, in
  two parts with a seam and a time guard as batch 3's runbook does.
- *While you build,* a closer is finishing batch 3's stage work and writes its walk findings into its own
  file (`notes/plans/vm-47-walk-b3.md`); it does not edit code while you are live. Defects it finds, and any
  red from batch 4's first suite run, come to a fix batch after yours.

### Batch 6 — the re-land of VM-55 (Wings underneath)

VM-55 merges to `main` before this run (the stage coordinator's order). Its branch and this one edit the same
phone files line by line: this run moved every type, ink, spacing and control site; VM-55 changed the same
files' error and receipt lines (the one message line, refusals in words), scoped every listing to the wing,
fixed the pickers, and put an interim wing door on each root's path line. A trial merge at its tip
`49e795bb6` conflicts in 23 files, all under `App/Variorum/VariorumMobile/Features/`: `Read/MobileReadView` ·
`Shell/` `MobileArchiveView`, `MobileBookDetails`, `MobileBookView`, `MobileCreateBook`, `MobileLibraryView`,
`MobileQuickNote`, `MobileScraps`, `MobileShelfView`, `MobileShellView`, `MobileStarredView`,
`MobileTagManager`, `MobileTrashView` · `Takes/` `MobileBlockHistorySheetView`, `MobileLenses` · `Write/`
`MobileBlockList`, `MobileMembership`, `MobileNoteActions`, `MobileNoteTags`, `MobileNoteTray`,
`MobileReferences`, `MobileVersions`, `MobileWriteView`. It also adds `Shell/MobileLine.swift`,
`MobileMessageLine.swift`, `MobileWing.swift`, `MobileWingDoor.swift` and seven brains under `Shared/`.

**The road.** The re-land starts before VM-55's PR lands, by merging its branch tip
(`origin/vm-55-wings-underneath`) into this branch; its code is at its merge gate, so the tip is expected to
stand. When its PR merges, `origin/main` is merged in on top (a small merge: its gate's record commits and
main's ledgers). If its tip moves first, the orchestrator says so and the new commits are merged the same
way. One implementer session; this is a batch of its own, nothing else rides it.

**The rule for every conflict: both runs' intent survives.** From VM-55: its behaviour, its expressions, its
words, its new views and parameters (which line a refusal speaks on, which wing a listing reads, which tag a
picker offers). From this run: how the line is DRAWN — the type role (`.phoneType`), the phone inks
(`tokens.phone.muted/faint`), the spacing scale and gutter, the shared controls and hit areas, the grounds
(her words on the paper, bars and sheets on the room), the bar. Neither side's hunk is taken whole where the
other also changed the line; read both sides of every conflict and write the line that carries both. Never
resolve by file (`--ours`/`--theirs`).

**VM-55's new faces wear this run's layer.** Its new and changed phone code still reads the Mac's type slots
and the voice's own small inks in places (it was written on main). This run's source guards scan the whole
phone tree and will go red on them: `MobilePhoneTypeSourceTests` (no `tokens.small/body/title/heading/mono`,
nothing under 13 pt, no literal `minimumScaleFactor`), `MobilePhoneControlsSourceTests` (no private button,
field or header builds), `MobileLookSourceTests` (grounds, the ★'s token, no literal colour). Bring each such
site onto the role it IS (batch 1's role map in §6 is the precedent; the smaller candidate where unclear,
listed), the wing door and the message line included. The message line is a receipt/refusal line: the
sizing sheet's "Receipt line" (words 15, the act 15 semibold in the accent, a 44 pt hit area) is its
anatomy if VM-55's own sizes are the old caption's; VM-55's WORDS and timing do not change.

**Where the two runs meet by design, each a decision written in §6 with both runs' pins green afterwards:**

1. *The roots' path lines.* VM-55's wing door makes the path line 44 pt tall where the wing's name is a
   door, and its pins (`MobileWingDoorGeometryTests`, `MobileWingDoorShellTests`) assume the roots'
   pre-VM-47 paddings (14 above, 6 below). This run changed the same lines: batch 2's doors (inline act,
   icon buttons, one line at 402 pt in both voices — `MobilePathLineGeometryTests`) and batch 5's ⋯ menu.
   Find the numbers under which BOTH hold: the wing door a 44 pt target, the line one line at 402 pt in
   both voices, this run's doors 44 pt, the ⋯ menu present on all three roots. If VM-55's pins hold
   literal paddings that this run's scale changed, the pin moves to the rule it protects (as this run's
   keyboard-share pin did), with the reason in the commit — never a silent overwrite of VM-55's pins. If
   the numbers genuinely cannot both hold, STOP on that point, write the options in §5 as a question for
   her, build the option that keeps every target at 44 pt, and say so.
2. *The bar and the message line.* VM-55 attached its `.onGeometryChange` to the old `tabBar` body and keyed
   its `chromeInset` to `pagingAllowed ? tabBarHeight : 0`. The bar is now `MobileTabBar` and also shows on
   pushed lists: re-attach the measurement to `MobileTabBar`, and key the inset to "a bar is on screen"
   (the shell's own rule from batch 4), so the message line clears the bar on a pushed list too.
3. *The tab's word.* The tab is "Bookcase" (her LK-5 and SW-1). Tests that drive it by "Shelf" move to
   "Bookcase" with the reason stated (VM-55's `MobileWingDoorTests` and any other). The root's own path
   word: read what the merged Bookcase root's path line now says in both voices. If the root still titles
   itself "Shelf" while its tab says "Bookcase", that is one screen under two names; her rulings name the
   page Bookcase, so the path word follows (a rendered-word change: list it in §6's new lines) — unless
   VM-55's wing door has already changed that line's words, in which case keep VM-55's words and record
   what the line says.
4. *The wing landing.* Batch 4's tab road returns the stack being left to its root (P-47-19), which VM-55's
   wing landing relies on; confirm from VM-55's code that the two agree, and pin it if no pin of either run
   holds it.

**Hard lines.** No production behaviour of VM-55 changes; no word of VM-55's changes except item 3's.
`Shared/Theme/VoiceTokens.swift`, `MobileEditorTextView.swift`, `MobileEditorViewModel.swift`,
`Shared/EditorBrain/`, everything under `Sources/` and VM-55's `Shared/` brains are not edited (a brain that
needs a line to compile against this run's API is named in the report first). The Mac's look does not
change. The merge commit's message lists the 23 files and each design decision in a line.

**Builds and evidence.** `App/Variorum/DerivedData/vm47-b6`, one build at a time, never during a QUIET
window the orchestrator relays; `vm47-b5` and the snapshot `~/dev/variorum-vm-47-rol5` are not touched
(a pending stage window reads them). When both schemes' `build-for-testing` are green: READY with the whole
phone target, the Mac list (the theme-store types of §6 "Batch 3 — results", batch 5's fifteen, and VM-55's
Mac pin types `VM56MacWingScopePinTests`, `VM61MacStatusSeamPinTests`, `VM62MacRefusalWordsPinTests`,
`VM63MacWingBrainsHoistPinTests`, `WingPaletteDoorsTests`, each verified as a suite type), and the list of
decisions for §6 "Batch 6 — results". The whole Mac target and the run's one walk follow on this tree.

### One walk for the whole run

At the stage coordinator's ask and the orchestrator's decision (2026-11-19, 10:50), ONE walk in two parts stands for
ALL FIVE batches, superseding batch 3's two-part walk (rows 3.14–3.15) and the batches-4-and-5 walk (rows 4.4, 5.5).
It runs on the tree that holds VM-55's merge re-landed and the ladder's fixes, requested together with the whole
phone and whole Mac targets for that tree; its findings are read by the ladder's next round. The walk builds
`DerivedData/vm47-walk3` and `vm47-walk5` were removed unrun, and no walk device exists. The two drivers and runbooks
(`VM47Walk3Driver.swift` + `walk3.zsh`, `VM47Walk5Driver.swift` + `walk5.zsh`, gitignored in
`notes/plans/vm-47-screens/instruments/`) stay as the sources for one unified driver.

**The walk's brief (orchestrator, at the batch-6 seam).** It runs on the re-landed tree (code `b20b04fad`,
VM-55 merged in), so it is also the first look at the two runs together. One driver, built from the existing
instruments (the oldest pair, `VM47WalkDriver.swift` + `walk.zsh`, are batches 1 and 2's and are superseded by
batch 3's; batch 4's and batch 5's each extend a copy), a dedicated device `vm47-walk` that the runbook
creates and deletes, captures to `notes/plans/vm-47-screens/final/` (gitignored), two parts with a seam and a
time guard, each ending with the device shut down:

- *Part A (about 35 minutes):* create, boot, the seed; the core screens under the sea-glass in all eight
  combinations of Study/Terminal × light/dark × default/AX5 — the Bookcase root at rest and with the capture
  box focused (the path line with the wing door, the ⋯, the bar), the Library (rows on the paper, the filter
  row, search), a note in Write (masthead, chips, prose on the paper; at the default size the paper checks:
  the take tint, a callout's wash with the comment mark, the caret, the selection wash).
- *Part B (about 40 minutes), most important first:* the second palette (`teal_rust`) core in Study light
  and dark; Settings (the list top to bottom, the voice choice flipped, the appearance choice set to light,
  dark and back to follow-the-system, the ⋯ menu on each root, the door from a note); the bar on a pushed
  list and a tab tapped from it, a note and a Read page without it; VM-55's faces on this run's layer (the
  wing door's sheet, the one message line after a removal with its Undo, clearing the bar on a root and on a
  pushed list); VM-54's flip (take cards, the pill, the comment draft) once per voice; then the wider pass
  at Study light default, Terminal dark default and Study light AX5 (Starred, a book's contents, Book
  Details, Create Book with its segmented choice, the Tags, membership, More Info, Blocks and Lenses sheets,
  Note Actions and Versions, the Takes, Comments and Block History overlays, a book's Read page, Trash with
  its chips, Archived, the Protection screen).

Every capture is read by the walker against the sizing sheet; the findings land in
`notes/plans/vm-47-walk.md` (committed), each a defect of this run (fixed narrowly, with a test where one can
hold it, and re-captured), a defect another ticket owns (named), or a question for her (§5).

## 4. LIVE STATUS

| Batch | Piece | State |
|---|---|---|
| 0 | Kickoff: worktree, branch, in-flight row (main `635f7b93f`), VM-47 In Progress, announced to nov18 | DONE |
| 1 | The phone layer: type, inks, metrics (VM-48; VM-49's constants) | IN-PROGRESS — the code and its suites DONE (rows 1.1–1.6d, the targeted re-run green); REMAINING: its walk, now the run's one walk (§3, "One walk for the whole run"), PENDING — pieces below — **SINCE ANSWERED (the final record pass):** the run's one walk DONE — parts A and B (rows W.3–W.6), the re-capture (row W.9) and the final-tree captures (row W.11 (9)), every set read (`notes/plans/vm-47-walk.md` §4–§4h) |
| 1.1 | The layer in `Shared/Theme/`: the role table (both voices, SwiftUI + UIKit forms, two scaling classes), the two corrected inks (derived, floors pinned over every palette and voice), the metrics constants and the 44 pt hit-area helper; its tests | DONE (`f5e21610d`, amended `340603f56`) — `PhoneType.swift` · `PhoneInks.swift` · `PhoneMetrics.swift` · `MobilePhoneLayerTests.swift`; phone `build-for-testing` green; tests RUN (row 1.6c): one red, `chromeHoldsAtXXXLargeWhileHerWordsKeepGrowing`, FIXED `4ec664f2b` and green in the targeted re-run (row 1.6c) |
| 1.2 | Every phone type site reads a role — one commit per screen family (Shell · Write sheets · Takes/Read · Protection · the UIKit overlays) | DONE — Shell `ccd481162` · Write `76e34188c` · Read/Lenses `df8b334d2` · Protection + shared pages `841c9362b` · UIKit overlays `7cd8b866f`; the shelf screen rides 1.4; the keyboard bar's 14 pt chrome DEFERRED to VM-137 (its bar shape is LK-4/LK-3's); phone `build-for-testing` green; tests RUN (row 1.6c — the whole target; its three reds dispositioned there) |
| 1.3 | The editor's face (`MobileEditorStyle`, face values only: note body per the sheet) | DONE (`575bb8677`) — body = the `noteBody` role (Study Iowan 17, Terminal mono 15) through `UIFontMetrics(.body)`; paragraph gap 14 / 12 and line pitch 27 / 25, both scaling with the body; `MobileVoiceTests` pins moved; the text inset NOT changed; phone `build-for-testing` green; tests RUN (row 1.6c; `MobileVoiceTests` also in the targeted re-run, green) |
| 1.4 | W-024: `MobileShelfLayout` re-derived from the roles; the quick-entry text is the note body; the hint fits; pins moved | DONE (`6b02c806c`; the filter row's floor and its pins `c1e80f315`) — `quickEntryLineHeight` 24 + `metaLineHeight` 18 replace `smallLineHeight` 14; `bookRowHeight` 44, `writingBoxChromeHeight` 60, both derived on the page; the floor and the collapsed box take the box's line AT THE CURRENT TEXT SIZE (`split(…, lineHeight:)`); the box types `noteBody` on its 24 pt line; the hint shows the longest of its own cuts that fits (P-47-6); the shelf's sites read roles; `MobileShelfLayoutTests` moved + 3 new pins; phone `build-for-testing` green; tests RUN (row 1.6c): one red, `writingKeepsItsShareUnderAKeyboardSizedRegion`, the pin MOVED `29f2cbd41` and green in the targeted re-run (row 1.6c) |
| 1.5 | The source-scan guard pin (no `tokens.small`, no literal under 13, outside `Spike/`/`Perf/`) | DONE (`bb30a4132`) — `MobilePhoneTypeSourceTests` (3 tests): no Mac type slot, no literal size or caption style under 13, no literal `minimumScaleFactor`; its patterns measured red on `fe85ea6d5` (332 slot reads, 32 sub-13 sites) and clean now; GREEN (the 04:40 whole-target run, and again in batch 2's phone leg, row 2.8c) |
| 1.6 | Both schemes `build-for-testing` green → READY for the stage → the stage window: suites + walk captures | DONE for the suites (rows 1.6c–1.6d); the walk MOVED to batch 2's seam (row 1.6e), and since into the run's one walk (§3), PENDING — **SINCE ANSWERED (the final record pass):** the run's one walk DONE — parts A and B (rows W.3–W.6), the re-capture (row W.9) and the final-tree captures (row W.11 (9)), every set read (`notes/plans/vm-47-walk.md` §4–§4h) |
| 1.6b | CUTOVER (orchestrator, machinery honesty): the batch-1 implementer ended its turn READY at about 650k tokens of context, every piece committed and both schemes building. The stage window (suites, any reds, the walk) goes to a FRESH closer briefed from this record, not to the long session | the closer adds its rows below |
| 1.6c | The suites, leg 1: the whole phone target (`-only-testing:VariorumMobileTests`, test-without-building from `DerivedData/vm47-b1`, the standing device) | DONE (run by the ORCHESTRATOR under its own claim — the GO reached it while the closer was still reading) — **883 tests in 145 suites, 19 issues including 8 known** (XCTest "Executed 0"; nothing skipped); three reds, each dispositioned in §6: VM-24's caret suite (not this batch's, nothing changed) · `chromeHoldsAtXXXLargeWhileHerWordsKeepGrowing` (a real defect in the UIKit road, FIXED `4ec664f2b`) · `writingKeepsItsShareUnderAKeyboardSizedRegion` (the pin's denominator carried the path line; the pin MOVED to the rule's room, `29f2cbd41`). Both schemes `build-for-testing` green at `29f2cbd41`. **The targeted re-run (orchestrator, 05:26, `DerivedData/vm47-b1` at `29f2cbd41`, the standing device): "Test run with 118 tests in 12 suites passed after 60.571 seconds with 4 known issues", `** TEST EXECUTE SUCCEEDED **` — `chromeHoldsAtXXXLargeWhileHerWordsKeepGrowing()` and `writingKeepsItsShareUnderAKeyboardSizedRegion()` passed; the 4 known issues are P-47-7's two filter-row pins; `MobilePhoneTypeSourceTests` left out (it scans sources batch 2 is editing; green in the 04:40 whole-target run). Batch 1's suites are CLOSED; its walk rides batch 2's.** |
| 1.6d | The suites, leg 2: the Mac's `Shared/Theme` suites (`ThemeTokenTests PaletteDerivationTests NoLiteralColourTests SharedPageStyleTests PaletteReachTests MarkdownPaletteWritersTests HelperWindowThemeTests`) | DONE (orchestrator) — **42 tests in 7 suites passed**, `** TEST EXECUTE SUCCEEDED **`, no red. The red-2 fix touches only `PhoneType.swift`'s `#if os(iOS)` arm, so the Mac leg stands (Mac `build-for-testing` green at `29f2cbd41`) |
| 1.6e | The walk: a dedicated device `vm47-walk` (iPhone 17 Pro, iOS 26.2; created by the closer, never booted; its id lives in the reports, never here), seeded from a fresh install through the app's own doors (a first write lands the Journal and the sample book; the Debug pocket guide gives chapters, a three-take block and a tag; one note to the Trash; a saved version; one comment), driven by a THROWAWAY XCUITest driver kept with its runbook in the gitignored `notes/plans/vm-47-screens/instruments/` (`VM47WalkDriver.swift`, `walk.zsh` — each with a header that says how to build and run it cold, the device, the seed steps and every capture by name; built through the `TK2SpikeUITests` scheme into its own `DerivedData/vm47-walk`; the copy in `VariorumMobileUITests/` exists only for that build; never committed). Core screens × Study/Terminal × light/dark × default/largest (AX5); the rest × Study light default, Terminal dark default, Study light largest | MOVED — the orchestrator's call: **batch 1's suites close here; its walk rides batch 2's seam as ONE walk covering batches 1 and 2** (the queue is long, and a walk at the largest size belongs on the fixed tree). The driver's headless build is GREEN at `29f2cbd41` (`** TEST BUILD SUCCEEDED **`; the bundle carries `VM47Walk/test01_seed · test10_core · test20_rest`; the temporary copy removed, tree clean). The filter row at Display Zoom (320 pt) is NOT capturable (simctl cannot switch Display Zoom on) — recorded as not taken; the geometry pins are its evidence. **SUPERSEDED in turn:** the batches-1-and-2 walk was retired unrun at the batch-3 seam, its device and DerivedData removed (row 2.9), and the run's one walk (§3) now carries batch 1's captures, PENDING — **SINCE ANSWERED (the final record pass):** the run's one walk DONE — parts A and B (rows W.3–W.6), the re-capture (row W.9) and the final-tree captures (row W.11 (9)), every set read (`notes/plans/vm-47-walk.md` §4–§4h) |
| 1.6f | The record close: §6 "Batch 1 — results" (counts, every red and its disposition, what was fixed, what is owned elsewhere); §5 for any new PROVISIONAL; this table flipped | DONE (this commit) for the suites; the walk's findings land with the run's one walk (§3; batch 2's walk was superseded, row 2.9), PENDING; the targeted re-run's counts RECORDED (row 1.6c: 118 tests in 12 suites passed, 4 known issues). No new PROVISIONAL — **SINCE ANSWERED (the final record pass):** the run's one walk DONE — parts A and B (rows W.3–W.6), the re-capture (row W.9) and the final-tree captures (row W.11 (9)), every set read (`notes/plans/vm-47-walk.md` §4–§4h) |
| 1.7 | §6 "Batch 1 — results" written | DONE (this commit) — the counts since filled (§6 "The stage window", rows 1.6c–1.6d); the walk PENDING in the run's one walk (§3) — **SINCE ANSWERED (the final record pass):** the run's one walk DONE — parts A and B (rows W.3–W.6), the re-capture (row W.9) and the final-tree captures (row W.11 (9)), every set read (`notes/plans/vm-47-walk.md` §4–§4h) |
| 2 | Controls and targets (VM-50; VM-49's application) | IN-PROGRESS — the code, its suites, the re-run of the two test-only fixes and the path line's red-on-old DONE (rows 2.1–2.8d); REMAINING: its walk, now the run's one walk (§3), PENDING — pieces below (implementer: Opus, 2026-11-19) — **SINCE ANSWERED (the final record pass):** the run's one walk DONE — parts A and B (rows W.3–W.6), the re-capture (row W.9) and the final-tree captures (row W.11 (9)), every set read (`notes/plans/vm-47-walk.md` §4–§4h) |
| 2.1 | The shared controls in `Shared/Theme/PhoneControls.swift` (text button, inline act, icon button, chip, field, the one calm button, sheet header, segmented choice on the system control, section header, menu row; the UIKit hit-area button for the overlays) + their geometry tests | DONE (this commit) — `PhoneControls.swift` + `PhoneType`'s `weight:` override + `MobilePhoneControlsTests` (14 tests); phone `build-for-testing` green; Mac build GREEN (at `a77374d8a`, rows 2.2 and 2.6); tests RUN (row 2.8c): two cases red — the field's premise and the header's lookup — fixed test-only (`7762aef3b`, `a37789cb9`); the re-run green, "Test run with 13 tests in 1 suite passed" (06:56, row 2.8c) |
| 2.2 | Adoption, one commit per screen family, retiring each private build with its last user (the five calm buttons, the three fields, the ten sheet headers, the word-row choices) — Shell roots · book sheets · Write masthead · Write sheets · Shell sheets/screens · Protection · the UIKit overlays | DONE (every family; see the row's end) — Shell roots DONE (this commit: the Bookcase and Library path lines on the controls — 🗑 icon button, + New Note inline act, Settings a gear icon button (P-47-9), one 44 pt line, Starred's line level with them; the today badge a chip; the Library search on `phoneField`; every root row, the archive row, the scraps picker and the book's rows/doors given `phoneHitArea`; the filter doors and the sort glyph 44 tall, widths kept (P-47-10)); phone `build-for-testing` green. Book sheets DONE (this commit: Book Details and Create Book on the sheet header; Create Book's name a `phoneField`, its kind and its OR/AND on the segmented choice, its Create on the calm button; Book Details' act rows on `PhoneMenuRowStyle`, the rename name and the daily row 44 tall; the segmented choice sizes segments by their words, `PhoneSegmentWidths`; the path-line pin `MobilePathLineGeometryTests` written, red-on-old since PROVEN, row 2.8d). Write masthead DONE (this commit: its four tools are icon buttons — 22 pt glyphs in ink (the seal in the accent while sealed), 44 × 44 hit areas touching, the row kept; the title and the membership chip 44 tall; the five flow chips 44 tall reaching 6 into the old 12 pt gap (words where they were); Unlock Note an inline act; the receipt's Undo/Redo LEFT for VM-61 — a 44 pt row there would deepen the prose's jump on every act). Write sheets DONE (this commit: the sheet header on Tags, More Info, Books, Note Actions, Blocks (its Select door a text button beside Done), Lenses, the edit trace (path title kept muted) — and the Tag manager's; the tag field a `phoneField`; Note Actions' rows the menu row (64 with a detail line); the block list's segments on the segmented choice and its rows 44 tall; every inline act (✕ remove, diverge/remove/open copy, Put back/Delete now, the takes fold, restore/promote/delete, Delete N) on `PhoneInlineActStyle`; the lens rows, suggestion rows, link rows and + rows 44 tall; the leading door words (save/adopt, Refresh/Clear, back to listing) inline acts at 17). Shell sheets/screens DONE (this commit: Settings and Acknowledgments on the sheet header, path titles kept muted; Settings' door words (Protection…, Acknowledgments, Manage Tags, Edit trace…, the DEBUG doors) inline acts at 17 with 44 pt hit areas — the list's shape stays batch 5's; the voice rows and the edit-trace toggle 44 tall; the Trash's Empty Trash, sort, and row acts and the Archive's row acts inline acts; the Trash's seven kinds on FILTER CHIPS (the chip gains a selected state — P-47-11); the tag manager's + new tag 44 tall). Protection DONE (this commit: `MobileRoadButton` and the library-missing Start door on THE calm button; the lock face's two fields and the shared pages' `pageFieldChrome` on `phoneField` (the private `field` card retired); `PageDoor`'s styled arms on the controls — .act/.destructive the calm button (destructive in the alarm, replacing the literal red), .bordered the calm button's edge alone, .borderless/.inlineAct the inline act at 17 — the Mac's nil arms untouched; the words disclosure an inline act; both protection door builders inline acts at 17; the gate's radio rows 44 tall). the UIKit overlays DONE (this commit: Done, Branch/Blank, Turn takes into blocks, the cards' ✓/⋯, Add/Save, Cancel, the comments' Edit/Delete/Restore and the history act are `PhoneHitAreaButton` — 44 × 44 within each button's superview; structure untouched); the fourth field build (`mobileSecretFieldChrome`) on `phoneField`. ALL FAMILIES DONE; phone `build-for-testing` green; Mac green at `a77374d8a` |
| 2.3 | The 44 pt hit area on every remaining G §2 site where it is a one-line change (`phoneHitArea()`) | DONE — inside each family's commit; the per-site outcome is §6's T1–T109 table |
| 2.4 | The path line (Terminal wraps at 402): doors as inline acts / icon buttons with 44 pt hit areas, ONE line at 402 in both voices; red-on-old geometry pin | DONE (`47ee432fc` the fix, `0b2df787f` the pin `MobilePathLineGeometryTests`) — red-on-old PROVEN in a snapshot (row 2.8d): 22 issues on the old code, green on the fixed tree |
| 2.5 | The source pin: the retired private button/field/header builds are gone | DONE (this commit) — `MobilePhoneControlsSourceTests`; its patterns measured by script red on `751765baf` (11 · 4 · 5 · 13 · 4), clean now; GREEN in the phone leg (row 2.8c) |
| 2.6 | The walk driver extended for the batch's surfaces; rebuilt headless into `DerivedData/vm47-walk`; both schemes `build-for-testing` green into `DerivedData/vm47-b2` → READY for the stage | DONE — the driver gains r05b (Create Book's kind segment) and r07b (the Blocks sheet's segment) and its header names batch 2's surfaces per capture; `walk_build` green at `09fba8983` (copy removed, tree clean); phone `build-for-testing` green at `09fba8983`, Mac green at `a77374d8a` (no `Shared/` change since); `DerivedData/vm47-b1` deleted at the orchestrator's word |
| 2.7 | §6 "Batch 2 — results": each control with its pointer and sizes, the retired builds, the T1–T109 inventory with owners, tests (PENDING), PROVISIONAL calls in §5, self-assessment | DONE (this commit) — counts filled at the closer's rows 2.8c–2.8d and §6; P-47-9…14 in §5 |
| 2.8 | The stage windows (suites; then the walk, both batches' captures, looked at) — run at the orchestrator's GO | DONE for the suites and the red-on-old (rows 2.8c, 2.8d); the walk is row 2.8e — SUPERSEDED (row 2.9), now the run's one walk (§3), PENDING — **SINCE ANSWERED (the final record pass):** the run's one walk DONE — parts A and B (rows W.3–W.6), the re-capture (row W.9) and the final-tree captures (row W.11 (9)), every set read (`notes/plans/vm-47-walk.md` §4–§4h) |
| 2.8b | CUTOVER (orchestrator, machinery honesty): the batch-2 implementer ended its turn READY at about 530k tokens of context, every piece committed (`776f665be`, then main merged in at `057c7cd87` — notes and the coordinator skill only, no app code) and both schemes building. The stage work — the walk, the path line's red-on-old, any red the suites turn up, the record's close — goes to a FRESH closer briefed from this record (no design latitude: verify, look, fix narrowly what the evidence proves broken, record) | DONE — the closer read §1–§6, CLAUDE.md, the resiliency protocol, the sizing sheet §A–§E, the layer and controls code, the seven named test files and the walk instruments, and added the rows below |
| 2.8c | The suites window: the whole phone target + the Mac theme suites — run by the ORCHESTRATOR under its own claim; every red handed to the closer by name with its log | DONE — **phone leg** (the orchestrator, from `DerivedData/vm47-b2` at `09fba8983`): "Test run with 900 tests in 148 suites failed after 510.176 seconds with 12 issues (including 8 known issues)", XCTest "Executed 0"; the 8 known = the four pre-existing (the empty-accessibility-tree diagnosis ×2, the fanned-divide lesson ×2) + P-47-7's four filter-row marks. Reds, each dispositioned (§6): (1) VM-24's caret suite — pre-existing, not this run's, nothing changed; (2) `MobilePhoneControlsTests.theFieldIsAtLeastFortyFourTallAndGrowsWithItsText()` :202 (44.0 at xxxLarge) — the test's premise, fixed test-only `7762aef3b`; (3) `MobilePhoneControlsTests.theSheetHeaderPutsDoneEightFromTheEdgeOnAFiftySixRow()` :61 ("no element labelled tags") — the test's lookup, fixed test-only `a37789cb9`. **Mac leg** (the orchestrator, the seven theme types from `vm47-b2` at `09fba8983`): "Test run with 42 tests in 7 suites passed after 16.983 seconds", `** TEST EXECUTE SUCCEEDED **` — the Mac's token pins byte-identical. **After the fixes:** phone `build-for-testing` into `vm47-b2` GREEN at `557664d3b` (`** TEST BUILD SUCCEEDED **` — the two test-only fixes compile; no `Shared/` change, so the Mac build stands). The targeted re-run `rerun=(MobilePhoneControlsTests)` RAN at 06:56: "Test run with 13 tests in 1 suite passed after 17.405 seconds", both fixed tests green by name (`vm-47-ladder-midway.md`, the note after §2b; the midway row below) |
| 2.8d | The path line's red-on-old (`47ee432fc`'s pin, `MobilePathLineGeometryTests`) — **in a SNAPSHOT, so this run's worktree never sits reverted** (the orchestrator's change of road, replacing the in-tree revert): a detached worktree `~/dev/variorum-vm-47-rol` at `09fba8983` (never committed in); there `git checkout 91d406593 --` `MobileShelfView.swift` + `MobileLibraryView.swift` (they changed only in `47ee432fc` since — a clean revert of exactly the fix; the trash door's icon button, `MobileRecoveryDoors.swift`, is NOT reverted, so its 44 × 44 stays green and the red rides the path's wrap and the two word doors' ~22 pt height); `build-for-testing` for the phone scheme into the snapshot's own `App/Variorum/DerivedData/vm47-rol` (headless); then, in a short stage window the orchestrator obtains, only `-only-testing:VariorumMobileTests/MobilePathLineGeometryTests` from that snapshot — expect RED; the snapshot is removed after | DONE — **PROVEN red on old, green on new.** The snapshot (`09fba8983` + the two files from `91d406593`, staged there only, never committed; 39 + 50 lines, `47ee432fc`'s own counts) built GREEN into `vm47-rol`; the orchestrator ran the one type on the standing device: "Test run with 2 tests in 1 suite failed after 6.874 seconds with 22 issues" — `theBookcasePathLineIsOneLineAtFourHundredTwoInBothVoices()` 18 issues (`path.height < 26` :86 ×3, the 44 × 44 bound :93 ×8, on-the-path's-line :96 ×7), `theLibraryPathLineDoorsAnswerAcrossFortyFour()` 4 issues (:128 ×2, :129 ×2); both green on the fixed tree in the 06:26 whole-target run. The snapshot is REMOVED (`git worktree remove --force`; the worktree list no longer holds it); **this run's worktree carried no revert at any point** |
| 2.8e | The walk (batches 1 + 2's ONE walk): device `vm47-walk` (iPhone 17 Pro, iOS 26.2, never booted), the driver built at `09fba8983` into `DerivedData/vm47-walk` (the app code is identical at `057c7cd87`); the seed; the core five × Study/Terminal × light/dark × default/AX5; the rest × Study light default, Terminal dark default, Study light AX5; every capture looked at against the sheet | SUPERSEDED unrun (row 2.9; then the run's one walk, §3) — it had been READY. Planned: 123 captures (seed 3 · core 6 × 8 = 48 · rest 24 × 3 = 72). The runbook `walk.zsh` (gitignored) gained a 30 s settle after boot, a per-run capture count, and exact-name instance checks (`pgrep -x`) in `walk_close`; the driver needed no change (every label and identifier it drives checked against the code at `057c7cd87`) |
| 2.8f | The record close: §6 "Batch 1 — results" and "Batch 2 — results" PENDING slots filled (counts, each red and its disposition, the red-on-old line, the walk screen by screen, what was fixed, what is owned elsewhere and by which ticket); §5 for any new PROVISIONAL; these rows flipped | DONE for what ran — the suites' counts, the three reds and their dispositions, the red-on-old lines, rows 2.4–2.8d flipped, P-47-14 in §5 (this commit). REMAINING when written: the targeted re-run's counts (`MobilePhoneControlsTests`) — since RUN green (row 2.8c: 13 tests in 1 suite, 06:56); the walk's captures and findings screen by screen (row 2.8e) — SUPERSEDED with it (row 2.9; the run's one walk, §3) |
| 2.9 | Batch 2's remaining evidence: the walk — CHANGED at the batch-3 seam: ONE walk covers batches 1, 2 and 3, on batch 3's driver and tree (rows under batch 3); the batches-1-and-2 walk on the `09fba8983` build is retired unrun, its device and DerivedData removed | SUPERSEDED by batch 3's walk, itself superseded by the run's one walk (§3, row 3.14), PENDING — **SINCE ANSWERED (the final record pass):** the run's one walk DONE — parts A and B (rows W.3–W.6), the re-capture (row W.9) and the final-tree captures (row W.11 (9)), every set read (`notes/plans/vm-47-walk.md` §4–§4h) |
| 3 | Voice and palette; borders (VM-51, VM-54) | IN-PROGRESS — the code (3.1–3.8, piece 3.10), the rebuilds (3.11), the suites (3.12) and VM-54's red-on-old (3.13) DONE; REMAINING: its walk, SUPERSEDED by the run's one walk (§3, "One walk for the whole run"), PENDING — pieces below (implementer: Opus, 2026-11-19; the closer from row 3.9b; build products `DerivedData/vm47-b3`) — **SINCE ANSWERED (the final record pass):** the run's one walk DONE — parts A and B (rows W.3–W.6), the re-capture (row W.9) and the final-tree captures (row W.11 (9)), every set read (`notes/plans/vm-47-walk.md` §4–§4h) |
| 3.1 | The hoist: `ThemeStore` moves `Variorum/Theme/` → `Shared/Theme/` (a move; the two Mac-only adoptions — `EditorTypography.adopt`, the receipt style into `session.status` — behind `#if os(macOS)`); Mac `build-for-testing` green | DONE (this commit) — `git mv` to `Shared/Theme/ThemeStore.swift` (history kept); the header says what moved; `EditorTypography.adopt` and `session.status.receiptStyle` behind `#if os(macOS)` (both Mac-only types/members); nothing else changed. Mac AND phone `build-for-testing` into `vm47-b3` GREEN (`** TEST BUILD SUCCEEDED **` each); the Mac suites RUN (row 3.12): "Test run with 511 tests in 102 suites passed … with 4 known issues", the seven theme types among them |
| 3.2 | The phone's resolution road: the shell router holds the library's theme (the hoisted store, bound per session, started by the shell); the five palette-less sites read `VoiceTokens.resolve(settings:dark:)`; `MobileEditorStyle`'s UIKit face resolves voice + palette + tint from the landed settings with ONE main-actor writer (QUESTIONS #195 MINOR 3); light/dark stays the device's | DONE (this commit, with 3.3 — the voice door's source and its write are one seam) — `ThemeStore` gains `onLanded` (the phone's landing seam; nil on the Mac) and `init(session:placeholder:)` (default = the Mac's); `MobileShellRouter` holds the store (`bindTheme(session:)`, `settings`, `voice`, `tokens(dark:)`, `adoptLanded(_:)`, `placeholder`); the shell binds and `.task`-starts it; the five sites: `VariorumMobileApp.lockedTokens` (the placeholder, P-47-15), `MobileShellView.tokens`, `MobileWriteScreen.tokens` (the global write and `fallbackVoice` gone), `MobileSettingsView.tokens`, `MobileEditorStyle` (`adopt(_:)` + `Face.applying(palette:tint:)`; storage `@MainActor`; `Face.room` the voice's own room, P-47-16); tests moved (`MobileShellTests`, `MobileLivenessTests`, `MobileVoiceTests`, `withEditorWorld`, three router constructors) + new `MobileLibraryLookTests` (7); phone `build-for-testing` GREEN; Mac: the APP target compiled with no error, then the build was STOPPED in the test target at the coordinator's QUIET (another run's merge gate); after "QUIET over" (08:33) BOTH schemes `build-for-testing` into `vm47-b3` GREEN at `c87407b93` (`** TEST BUILD SUCCEEDED **` each — the three new suites compile); tests RUN (row 3.12): every batch-3 suite green; the one red the change brought, `MobileNavigationTests`' tab-door premise (a fresh library now wears Study), fixed test-only `8eb727f2e` (`vm-47-walk-b3.md`, "The navigation red") |
| 3.3 | `MobileVoicePreference` retires (an old stored value ignored); the two Settings voice rows write the library's voice through `ThemeStore.setVoice` (R-47-2) | DONE (this commit, with 3.2) — `VariorumMobile/Theme/MobileVoicePreference.swift` deleted (nothing reads the key; a source pin holds it); `MobileShellRouter.setVoice` → `theme.setVoice` (the Mac Settings' write, `Operations.setThemeVoice`); the rows' mark reads the landed library voice |
| 3.4 | The grounds (R-47-1): her words on the paper (`tokens.surface`), bars/sheets/section bands on the room — at the screens' and sheets' background lines; the rest listed with owners | DONE (this commit) — the roots' list regions (`MobileStarredView`, `MobileShelfView` books + box, `MobileLibraryView` rows/search) `.background(tokens.surface)`; the pushed lists' grounds (`MobileBookView`, `MobileArchiveView`, `MobileTrashView`, `MobileVersions`) `tokens.surface`, their report bands still the room; Read's room around the cream page `ReadingPageTokens.room` (the Mac's R-13u-10); Write's screen ground and masthead the editor's own ground (`ReadingPageTokens.room` — P-47-16); sheets unchanged on the room; what is more than a background line listed in §6 with owners. Source pin `MobileLookSourceTests` (4): patterns measured RED on `ea738c49f` (10 of 10 checks fail) and GREEN now (0 of 10). Phone APP target builds incrementally GREEN (QUIET: the test target's build waits) |
| 3.5 | The ★ reads `tokens.star` | DONE (this commit) — `MobileStarredView`'s ★ (the phone's only one); pinned by `MobileLookSourceTests.everyStarReadsTheStarToken` (red on old: the accent) |
| 3.6 | VM-54: the border trace and verdict in §6; if the code does not re-resolve, the fix + a trait-driving pin, red-on-old in a snapshot worktree | DONE (rows 3.12–3.13 answer what remained) — DONE: the trace and verdict (§6 "Batch 3 — results": NOT hollow by the code), the fix (`MobileTraitBorder` + the four sites) and the pin `MobileBorderTraitTests` (4) (this commit; the phone APP target builds incrementally green). REMAINING when written (each since done): the pin's compile (the test target's build waits for QUIET — GREEN at `c87407b93`, row 3.2); its red-on-old in a SNAPSHOT worktree — MADE: `~/dev/variorum-vm-47-rol3`, detached at `b395f03e8` (re-made there from `72ae64daa` so it is the reviewed tree), the three view files checked out from `af487bfe7` and staged there only (they changed only in `1c3621719` since — a clean revert of exactly the fix: 7 lines in, 19 out; `MobileTraitBorder` stays, unused there; the pin's test file is the fixed tree's); its phone `build-for-testing` into its own `App/Variorum/DerivedData/vm47-rol3` is GREEN (`** TEST BUILD SUCCEEDED **`); NEXT, at the orchestrator's window: `MobileBorderTraitTests` from it — expect RED; then the snapshot removed — RUN (row 3.13): RED on old, "Test run with 4 tests in 1 suite failed after 0.337 seconds with 5 issues", all four GREEN on the fixed tree (row 3.12); the snapshot removed. THIS worktree carries no revert. The on-screen check rides the run's one walk (§3), PENDING — **SINCE ANSWERED (the final record pass):** the run's one walk DONE — parts A and B (rows W.3–W.6), the re-capture (row W.9) and the final-tree captures (row W.11 (9)), every set read (`notes/plans/vm-47-walk.md` §4–§4h) |
| 3.7 | Tests: the phone's resolution (a settings change re-resolves; no palette → sea-glass; dark stays local; the old key ignored), the star, the grounds, a phone no-literal-colour twin if it is a small source scan | DONE (written, `987e9edc5` … `5b5d7b9be`) — `MobileLibraryLookTests` (7), `MobileLookSourceTests` (4, incl. the phone's no-literal-colour twin — none existed), `MobileBorderTraitTests` (4); moved pins in §6. COMPILE of the test target and every count PENDING (QUIET, then the stage) when written — since COMPILED (GREEN at `c87407b93`, row 3.2) and RUN (row 3.12): every batch-3 suite green (`vm-47-walk-b3.md`); VM-54's red on old (row 3.13) |
| 3.8 | The walk driver COPY extended (voice row, palette, grounds, ★, the VM-54 flip) → `DerivedData/vm47-walk3`; both schemes `build-for-testing` into `DerivedData/vm47-b3` → READY for the stage | DONE — DONE: the instruments (gitignored `notes/plans/vm-47-screens/instruments/VM47Walk3Driver.swift` + `walk3.zsh`, each with a cold-use header: the voice set through the Settings row, the second palette through the launch environment, `test25_voice`, `test30_flip` with the runbook's flip watcher; captures to `vm-47-screens/b3/`, device `vm47-walk3` created and deleted inside the window); the walk's palette seam in the Debug app (`MobileWalkLaunch`, DEBUG only — `VARIORUM_WALK_PALETTE` → `setThemePalette` at the shell's start) (this commit; phone APP target incremental build GREEN). AFTER "QUIET over": both schemes' `build-for-testing` into `vm47-b3` GREEN at `c87407b93`; `walk_build` into `vm47-walk3` GREEN (`** TEST BUILD SUCCEEDED **`; the bundle carries `VM47Walk3/test01_seed · test10_core · test20_rest · test25_voice · test30_flip`; the copy removed, tree clean); `vm47-b2` deleted at the coordinator's word. **READY for the stage** — the window's lines are in the READY report (the phone target, the 119 Mac types, VM-54's snapshot run, the walk). Since RUN: the suites (row 3.12; the Mac list recomputed to 102 types, row 3.11) and VM-54's snapshot (row 3.13); the walk SUPERSEDED (row 3.14; `vm47-walk3` removed unrun) |
| 3.9 | §6 "Batch 3 — results" (hoist, road, retired preference, grounds by screen, star, VM-54 trace + verdict, tests PENDING, PROVISIONALs in §5, self-assessment) | DONE for the code (this commit) — counts and the red-on-old line since RUN (rows 3.12–3.13; §6 now carries them); the walk's findings PENDING the run's one walk (§3) — **SINCE ANSWERED (the final record pass):** the run's one walk DONE — parts A and B (rows W.3–W.6), the re-capture (row W.9) and the final-tree captures (row W.11 (9)), every set read (`notes/plans/vm-47-walk.md` §4–§4h) |
| 3.9b | CUTOVER (orchestrator, machinery honesty): the batch-3 implementer ended its turn READY at about 675k tokens of context, every piece committed; main merged in at `40352bde2` (the search run's Mac and Core files; nothing under `Shared/` or `VariorumMobile/`). What remains — piece 3.10, the rebuilds on the merged tree, the stage windows, the record's close — goes to a FRESH closer briefed from this record (no design latitude outside 3.10) | DONE — the closer read §1–§6, CLAUDE.md, the resiliency protocol, the sizing sheet's grounds and §A–§E, the theme layer, `MobileEditorStyle`, the fenced line, `MobileWriteView`'s grounds, the router's theme seam, the Mac's `EditorView`/`PostDetailView` grounds, the three look suites and both walk instruments, and added the rows below |
| 3.10 | Piece 3.10 — the note in Write on the paper (the record's named exception to rule 7): the face's paper value; the ONE line in `MobileEditorTextView.applyVoiceChrome`; `MobileWriteView`'s two ground lines; the pin; the source pin extended to Write; P-47-16 rewritten | DONE (this commit) — `Face.paper` (= `surface`, computed: the Mac's own `EditorSurfaceChrome.paper` = `NSColor(tokens.surface)`; no second stored value — the face already carried the paper as `surface`, which the overlays' sheets and the keyboard bar read); `backgroundColor = face.room` → `face.paper` (the file's ONE changed line; its stale doc comment two lines up left, recorded for VM-137); the screen ground and the masthead `tokens.surface` (the helper `groundUnderHerWords` removed; the masthead reading is P-47-17); pins: `MobileLibraryLookTests.theEditorsGroundIsThePaper` (a real text view's background over both voices × light/dark × sea-glass and teal & rust — replaces `theEditorsGroundIsNeverThePalettesTint`), `MobileLookSourceTests.theNoteInWriteIsOnThePaper` (its patterns measured by script: 5 of 7 checks fail on `76b85bdae`, 0 of 7 now — the two Read checks are batch 3's and hold on both); P-47-16 rewritten, P-47-17 new. Builds GREEN (row 3.11); counts RUN (row 3.12): both pins green (`vm-47-walk-b3.md`) |
| 3.11 | The rebuilds on the merged tree, headless: phone + Mac `build-for-testing` into `DerivedData/vm47-b3`; the walk driver into `DerivedData/vm47-walk3` (AFTER 3.10 — the walk's app is built there); the runbook split into part A and part B (the coordinator's word) | DONE — at `4cca58a8e`: phone `** TEST BUILD SUCCEEDED **` (09:01–09:02), Mac `** TEST BUILD SUCCEEDED **` (09:02–09:06), the walk driver `** TEST BUILD SUCCEEDED **` (09:12; five tests in the bundle; tree clean); the runbook split (`walk_part_a` 67 captures · `walk_part_b` 115) with a time guard, the second palette's raw value fixed (`teal_rust` — the old name would have walked the sea-glass twice), the paper check and the Trash chip added (§6, "The walk"); the Mac list RECOMPUTED (102 types, each verified a declared test type — §6) |
| 3.12 | The suites window — the whole phone target + the Mac's theme-store types — run by the ORCHESTRATOR under its own claim; every red handed to the closer by name with its log | DONE — **phone** (the orchestrator, 09:50–10:01, from a gate snapshot at `54cbcb9e5`, the merged tree): "Test run with 916 tests in 151 suites failed after 515.539 seconds with 12 issues (including 8 known issues)"; reds: VM-24's caret test (2 of its 3 cases — main's, not this run's) and `MobileNavigationTests.theTabBarCarriesThreeDoorsAndEachOneMovesTheBand()` (:221, :229; deterministic, the same two alone) — a test premise batch 3 changed by design, traced in `notes/plans/vm-47-walk-b3.md` (in Study a root's path line reads its own door's word), fixed test-only in `8eb727f2e` (buttons only); the 8 known: the four pre-existing + P-47-7's four. **Mac** (the orchestrator, 10:38–10:53, the same snapshot, the 102 types of §6): "Test run with 511 tests in 102 suites passed after 836.278 seconds with 4 known issues", none failed, no host relaunch; skipped by their own opt-in gates: 10 suites, 24 tests (the capture harnesses and the two opt-in measuring suites); the 4 known issues pre-existing (`theBookIndexsLivePaneIsItsReadTierLineForLine`, `theReadEditLivePaneIsItsReadTierLineForLine`, both voices); `TakesEntryBandTests` and all seven theme types passed. The gate snapshot is removed |
| 3.13 | VM-54's red-on-old — run by the ORCHESTRATOR from the existing snapshot `~/dev/variorum-vm-47-rol3` (built, row 3.6) | DONE — **PROVEN red on old** (10:04): "Test run with 4 tests in 1 suite failed after 0.337 seconds with 5 issues" — `aTakeCardsEdgeFollowsTheFlip()` (2), `anArchivedCardsEdgeFollowsTheFlip()`, `theTakesPillsEdgeFollowsTheFlip()`, `theCommentDraftsEdgeFollowsTheFlip()`; all four GREEN on the fixed tree inside the whole-target run (row 3.12). The snapshot is removed |
| 3.14 | The walk — ONE walk for batches 1, 2 and 3 on device `vm47-walk3`, in two parts with a seam between (each about 30 minutes; part A ends with the device SHUT DOWN, its seeded library kept; part B ends with `walk_close` and the device's deletion): A = create, boot, the seed, the core screens under the sea-glass × Study/Terminal × light/dark × default/AX5; B = boot, the core under teal & rust (Study light, Study dark, default), the wider pass × sea-glass Study light default · Terminal dark default · Study light AX5, the voice row once per voice, VM-54's flip once per voice; every capture looked at against the sheet | SUPERSEDED — the run's one walk (§3, "One walk for the whole run"); the walk build `vm47-walk3` removed unrun, no device was ever made |
| 3.15 | The record close: §6 "Batch 3 — results" PENDING slots filled (counts, each red and its disposition, VM-54's red-on-old line, the walk screen by screen); one line each under batches 1 and 2's results that their walk is this one; §5 for any new PROVISIONAL; these rows flipped | SUPERSEDED with the walk (§3, "One walk for the whole run"): batch 3's §6 close (its PENDING slots, the walk's findings, one line each under batches 1 and 2) goes with the run's one walk; the suites' and red-on-old lines are rows 3.12–3.13 — **SINCE ANSWERED (the final record pass):** the run's one walk DONE — parts A and B (rows W.3–W.6), the re-capture (row W.9) and the final-tree captures (row W.11 (9)), every set read (`notes/plans/vm-47-walk.md` §4–§4h) |
| 4 | The bottom bar (VM-52) | its first suite run DONE (row 4.6); the whole phone target RUN on the re-landed tree, at baseline (row 6.9), and a targeted Mac leg of 114 types RUN green (row 6.10); the whole Mac target PENDING — it runs once, as the merge gate; its walk SUPERSEDED by the run's one walk (§3), PENDING — pieces below (implementer: Opus, 2026-11-19; build products `DerivedData/vm47-b4`); W-009 DEFERRED with owners (P-47-20) — **SINCE ANSWERED (the final record pass):** the run's one walk DONE — parts A and B (rows W.3–W.6), the re-capture (row W.9) and the final-tree captures (row W.11 (9)), every set read (`notes/plans/vm-47-walk.md` §4–§4h) |
| 4.0 | Reading: §1–§6, CLAUDE.md + canon, the resiliency protocol, MobileSoul §3–§5, the catch-up plan's rules, sitting-1 rulings (LK-5, SW-1, LK-6), her words, the sizing sheet (B, C, E's tab bar), audit G (T1, §3.3, §4.5, §5.5, §5.7), audit A (A3, §2, §4), the mockup's bar and its build notes (and the book, trash and note mockups' top rows), the shell, band, router, every pushed screen's navigation lines, the layer, the controls, the shell's and the shelf's tests; the sibling branches' shell diffs read (VM-55's message line keys its inset to the bar; VM-55 and VM-64 tests drive the tab by the word "Shelf") | DONE |
| 4.1 | The bar's face, `Features/Shell/MobileTabBar.swift` (new): Starred · Bookcase · Library at the `tab` role (17, chrome — holds at xxxLarge), the current word semibold in ink on a chip (the wash, radius 12), the others regular in the corrected muted; each cell a third of the width and at least 56 tall (LK-5's 56 pt target — the whole cell answers); the chip's side padding 16 → 8 → 4 by a pure fit rule, the word shrinking to the floor only when even 4 cannot fit (320 pt at xxxLarge in Terminal); the bar on the room to the home indicator, the hairline above; the shell's `tabBar` reads it; Shelf → Bookcase in the word and the spoken label (SW-1), `MobileNavigationTests` moved with the reason; pins `MobileTabBarTests` (geometry + the fit rule) | DONE (`9c76b335c` the face, `35fc0a461` the pins) — `MobileTabBar.swift` (`MobileTabBar`, `MobileTabBarMetrics`); `PhoneType`'s one additive form `phoneType(_:_:weight:shrinkingToFloor:)`; the shell's `tabBar` reads it; `MobileNavigationTests` moved to "Bookcase"; `MobileTabBarTests` (10). Phone and Mac `build-for-testing` into `vm47-b4` GREEN at `35fc0a461`; counts — the first suite run (row 4.6): `MobileTabBarTests` passed, `MobileNavigationTests`' two issues the snapshot's (it predates `8eb727f2e`); the whole phone target RUN on the re-landed tree, at baseline (row 6.9); the whole Mac target PENDING — it runs once, as the merge gate |
| 4.2 | Where it shows: on the three roots (as today) and on every pushed LIST (a book's contents, Trash, Archived, Versions' listing — the shell's destination builder); hidden inside a note (Write), on a book's Read page, in Versions' reader and on Protection (PROVISIONAL P-47-18 — the words' hold); a tab tap from a pushed list returns to that root (the left stack pops to its root, so a hidden stack is always at its root — the invariant VM-55's wing landing relies on; PROVISIONAL P-47-19); pins on the mounted shell | DONE (`9c76b335c` the code, `35fc0a461` the pins) — the destination builder's three list lines + `MobileVersionsScreen`'s `listingBar`; `tabSelected` + `popToRoot`; P-47-18 and P-47-19 in §5; counts — the first suite run (row 4.6): `MobileTabBarTests` (the mounted-shell pins) passed; the whole phone target RUN on the re-landed tree, at baseline (row 6.9); the whole Mac target PENDING — it runs once, as the merge gate |
| 4.3 | W-009 — the pushed screens' top edge: each screen's system bar traced from the code (table in §6), then the fix (design PENDING the external facts on iOS 26's hidden-bar swipe-back) | DONE (the trace, this commit) — §6's table: every pushed screen's top edge from the code; the fix DEFERRED with owners (P-47-20: the system bar kept — the back door and both swipe-backs; the mockups keep that row) — the external facts from one Sonnet lookup (read-only); the walk captures every top edge |
| 4.4 | Both schemes `build-for-testing` into `DerivedData/vm47-b4` (the Mac only if `Shared/` changed); the walk's capture list; READY for the stage | DONE — phone and Mac `build-for-testing` into `DerivedData/vm47-b4` GREEN at `35fc0a461`; the walk driver + runbook (gitignored `VM47Walk4Driver.swift`, `walk4.zsh` — `test40_bar`, 73 captures into `b4/`, device `vm47-walk4`) built GREEN into `DerivedData/vm47-walk4` from this tree; READY for the stage (the window's lines are §6 "Batch 4 — results") — its first suite run since RUN (row 4.6); **the walk itself SUPERSEDED** by the run's one walk (§3, "One walk for the whole run") |
| 4.5 | §6 "Batch 4 — results" (the bar with pointers and sizes, where it shows and why, each pushed screen's top edge before/after, the `MobileShellView.swift` line ranges changed, tests PENDING, PROVISIONALs in §5, self-assessment) | DONE (this commit) — §6 "Batch 4 — results"; P-47-18…21 in §5. Counts: the first suite run's are row 4.6's; the whole phone target's RUN on the re-landed tree, at baseline (row 6.9); the whole Mac target's PENDING — it runs once, as the merge gate; the walk's findings (the run's one walk, §3) PENDING; the optional red-on-old NOT RUN — dropped (VM-52's bar is a design change her ruling settles, not a bug-class fix; its geometry pins stand as its evidence) — **SINCE ANSWERED (the final record pass):** the run's one walk DONE — parts A and B (rows W.3–W.6), the re-capture (row W.9) and the final-tree captures (row W.11 (9)), every set read (`notes/plans/vm-47-walk.md` §4–§4h) |
| 4.6 | Batch 4's first suite run — run by the ORCHESTRATOR | DONE (10:33–10:36, from a gate snapshot at `148dd741b`, since removed): "Test run with 117 tests in 12 suites failed after 140.396 seconds with 2 issues" — the only red the navigation test's two known issues at `MobileNavigationTests.swift:224` and `:232` (the snapshot predates `8eb727f2e`, the test-only fix; trace in `notes/plans/vm-47-walk-b3.md`); `MobileTabBarTests` and the other ten suites passed |
| 5 | Settings (VM-53, VM-27) | READY for the stage — the short piece RUN (row 5.7: one red, the VM-27 pin's harness, fixed in row R1.3; VM-27's red-on-old since PROVEN, row R1.5: green on the fixed tree, red on the snapshot, 13:32–13:35); the whole phone target RUN on the re-landed tree, at baseline (row 6.9), and a targeted Mac leg of 114 types RUN green (row 6.10); the whole Mac target PENDING — it runs once, as the merge gate; its walk SUPERSEDED by the run's one walk (§3), PENDING — pieces below; the window's lines are §6 "Batch 5 — results" ("The stage window") (implementer: Opus, 2026-11-19; build products `DerivedData/vm47-b5`; NO revert is in flight in this worktree at any point — VM-27's red-on-old is a detached snapshot) — **SINCE ANSWERED (the final record pass):** the run's one walk DONE — parts A and B (rows W.3–W.6), the re-capture (row W.9) and the final-tree captures (row W.11 (9)), every set read (`notes/plans/vm-47-walk.md` §4–§4h) |
| 5.0 | Reading: §1–§6, CLAUDE.md + canon, the resiliency protocol, MobileSoul §3–§5, the catch-up plan's rules, sitting-1 rulings (LK-1, LK-2, the lock-and-protection table), her words, the sizing sheet (B, C, E), audit G (§5.11, T99–T101), audit D (§3 item 5, §3.5, §4(d), D-38), audit A (A5, H3), CastleRules in full, the lock-and-protection mockup's S1–S3 + build notes, the home mockup's ⋯ menu (frame 34) + build notes, wording list 2's Settings drafts; the code (Settings, the sync row and its door, `SharedPageStyle`, the Protection entry, the tag manager, Acknowledgments, the edit trace, the three roots' path lines, the shell, `MobileNoteActions`, `ThemeStore`, the router, `PhoneControls`, the Mac's `AppearanceChoice` and its tests) and the suites around them | DONE |
| 5.1 | VM-27: the trace (which door stays and why), the pin `MobileSettingsProtectionDoorTests` (Settings mounted over the phone's own bootstrap with its account section, real services whose sync row is in a doored paused state: exactly ONE "Protection…" door, and it opens the screen), the fix as its own commit, the moved source pin; the red-on-old snapshot `~/dev/variorum-vm-47-rol5` built | IN-PROGRESS — DONE: the pin (`aea9a30d9`), the fix + the moved source pin (`9c9aa4b6c`: the sync row in Settings is handed NO Protection door — `.environment(\.protectionPaneDoor, nil)`; the standing row stays, gated on the same `protectionDoor`, so it stands whenever the row's door could; a doored paused state says its sentence alone — the shared face's P-2 arm); phone `build-for-testing` into `vm47-b5` GREEN at `9c9aa4b6c`. The snapshot — CHANGED to the final tree: `~/dev/variorum-vm-47-rol5` detached at `32f9c605e`, the fix's ONE line reverted there only (staged, never committed), built GREEN into its own `App/Variorum/DerivedData/vm47-rol5`; its first run NOT PROVEN (row 5.7 (b): the pin's harness let the round's database read fall through and the host stopped); the re-run, expected RED in both cases, owed on the corrected pin (rows R1.3, R1.5). (Coordinator hand-off, own commit `8eb727f2e`: `MobileNavigationTests`' selection helper counts only buttons — recorded under batch 4's results.) |
| 5.2 | The list's shape on the shared controls: the sheet header over ONE scrolling list; groups under section headers (the drafts' group names) on the room, rows on the paper with hairlines from the gutter; every row a menu row (whole row answering, ≥ the sheet's minimum) or a labelled segmented choice; the sync row's styled arm on the controls (its 11.5 pt doors); the voice rows → one segmented choice, words kept | DONE (this commit; tests PENDING) — `MobileSettingsView`: the header over ONE `ScrollView`; `MobileSettingsGroup` (the section name on the room, rows full width on the paper, a hairline between rows from the gutter, none left behind by an absent row); groups Library (the sync row · Protection…) · Look (Voice: Terminal \| Study · Appearance: Follow system \| Light \| Dark — both `PhoneSegmentedChoice`) · Tags (Manage Tags) · Help (Acknowledgments) · Diagnostics (Record edit trace — the system switch · Edit trace…) · DEBUG: Tutorial (dev store) · Performance (dev store) · TK2 Spike; every door a `PhoneMenuRow` (≥ 44, the gutter INSIDE the target — `PhoneMenuRow`'s additive `inset:`); the sync row's styled arm (`Shared/SyncStatusViews.swift`): its doors inline acts at 17 with 44 pt hit areas, its own line the `meta` role (both were the Mac's 11.5 pt slot) — the Mac's nil arm byte-identical. Phone `build-for-testing` GREEN |
| 5.3 | The appearance choice (VM-53 / LK-1, LK-2): the Mac's brain shared (`AppearanceChoice`'s pure enum hoisted to `Shared/Theme/`, the Mac's AppKit mapping and controller left in its file); the phone's owner (`UserDefaults`, never the `setting` table) applied at the windows (reaches SwiftUI, the UIKit editor and overlays, sheets, the lobby); the Settings row; tests | DONE (code `a83c586f3`; tests PENDING) — the brain shared — `AppearanceChoice`'s pure enum moved to `Shared/Theme/AppearanceChoiceRule.swift` (cases, key `appearanceChoice`, the remembered rule byte for byte; + `isDark(system:)` and the iOS twin `userInterfaceStyle`), the Mac's file keeps its AppKit `appearanceName` (now an extension) and its owner, so its `NSAppearance(named:)` line stays where the Mac's pin looks; the phone's owner `MobileAppearanceController` (`VariorumMobile/Features/Shell/MobileAppearance.swift`: this device's `UserDefaults`, applied as each window's `overrideUserInterfaceStyle` on change and as each window becomes visible; inert in a test host) held by `MobileShellRouter.appearance`; the lobby's tokens read it (`VariorumMobileApp.lockedTokens`, one expression). Phone `build-for-testing` GREEN; the Settings row rode 5.2's commit (`70368f6dc`). Tests (this commit; counts PENDING): `MobileAppearanceTests` (7) — the UIKit twin and the key, `isDark(system:)`, remembered on this device + a strange value, a change reaching the window's SwiftUI and UIKit, a window shown after the choice wearing it and the watch ending with its owner, never the `setting` table (a contract pin, hollow by construction — the owner holds no store), the test host's owner inert; `MobileSettingsListTests` (5 + 1 parameterized) — scrolls at AX5 (red on old: no scroll view), whole-row doors ≥ 44 at Large and AX5, the sync row's doors ≥ 44 (red on old: 11.5 pt words), the groups and the two choices (a segment drives the phone's owner), the appearance words the Mac's own (its row's source). Mac `build-for-testing` into `vm47-b5` GREEN at `70368f6dc` (every `Shared/` change of the batch; nothing under `Shared/` since) |
| 5.4 | The doors: ONE ⋯ menu on all three roots carrying Settings (the Bookcase's gear retires into it); a note's own door (the note's ⋯ sheet); Protection opens on the visible stack now that Settings opens from every root and a note; tests; the shared-risk files' line ranges recorded | DONE (this commit; tests PENDING) — `MobileRootMenu.swift` (new: the shell's door `MobileSettingsDoor` in the environment, the ⋯ `MobileRootMenu` — a system `Menu`, its items as data, PROVISIONAL P-47-22); ONE line on each root's path line (the Bookcase's gear and its `onSettings` retire into it; the gear's `MobileSettingsDoor.symbol` enum removed from `MobileTodayDoor.swift`); the shell injects the door (one line) and drops the shelf's `onSettings`; `openProtection` and the DEBUG guide door push on the VISIBLE stack (P-47-23); the note's ⋯ sheet (`MobileNoteActions.swift`) gains a Settings row that opens the shell's sheet once its own has gone (`onDisappear`), `actRow`'s detail optional. Tests: `MobileRootMenuTests` (5) new; `MobilePathLineGeometryTests` and `MobileProtectionScreenTests.settingsOpensTheScreenOnlyWhereItCanAct` moved with their reasons; six suites drop the retired `onSettings:` argument. Line ranges in the shared-risk files (pre-batch-5 `9438f7b27` → this commit): `MobileShellView.swift` 50–52 → 50–52 (the protection route's doc) · 226 → removed (`onSettings:`) · after 272 → 272–273 (the door's injection) · 308–311 → 309–312 (the DEBUG guide door's doc) · 320 → 321 (its push) · 551–552 → 552–555 (`openProtection`'s doc) · 555 → 558–559 (its push); `MobileShelfView.swift` 70 → removed (`onSettings`) · 235 → 234 and 240–244 → 239–243 (the path line's doc) · 266–272 → 265 (the gear → the ⋯ line); `MobileLibraryView.swift` after 227 → 228 (the ⋯ line); `MobileStarredView.swift` 94–95 → 94–95 (doc) · after 104 → 105 (the ⋯ line). No path-line padding, wing-door line, swipe, `selectPage` or `pagingAllowed` line touched; nothing reordered or renamed. Phone `build-for-testing` GREEN |
| 5.5 | Builds (phone + Mac `build-for-testing` into `vm47-b5`; the snapshot into its own DerivedData); the walk driver (a copy of batch 4's, extended for Settings) into `vm47-walk5`; READY for the stage | DONE — phone GREEN at `32f9c605e`; Mac GREEN at `70368f6dc` (no `Shared/` or Mac change after it); the snapshot GREEN; the walk driver (gitignored `VM47Walk5Driver.swift` + `walk5.zsh` — two parts, 73 + 62 = 135 captures into `b5/`, device `vm47-walk5`) built GREEN into `vm47-walk5`; one build at a time (the coordinator's LOAD note); the warm-start repair is §6's machinery note; **the walk itself SUPERSEDED** by the run's one walk (§3, "One walk for the whole run"); `vm47-walk5` removed unrun |
| 5.6 | §6 "Batch 5 — results" + the new PROVISIONALs in §5 | DONE (this commit) — P-47-22…26 in §5, the palette row held for the orchestrator to ticket; the short piece's counts RUN (row 5.7); the red-on-old line since RUN (row R1.5: VM-27 PROVEN); the whole phone target RUN on the re-landed tree, at baseline (row 6.9), and a targeted Mac leg of 114 types RUN green (row 6.10); the whole Mac target PENDING — it runs once, as the merge gate; the walk's findings PENDING the run's one walk (§3) — **SINCE ANSWERED (the final record pass):** the run's one walk DONE — parts A and B (rows W.3–W.6), the re-capture (row W.9) and the final-tree captures (row W.11 (9)), every set read (`notes/plans/vm-47-walk.md` §4–§4h) |
| 5.6b | CUTOVER (orchestrator, machinery honesty): the batch-5 implementer ended READY at about 713k tokens of context, every piece committed; its stage work is run by the orchestrator | DONE |
| 5.7 | The short piece — fourteen phone types, VM-27's red-on-old from `~/dev/variorum-vm-47-rol5`, fifteen Mac types — run by the ORCHESTRATOR | RUN (12:02–12:10, the standing device; logs in the orchestrator's session scratchpad) — **(a)** the fourteen phone types from `vm47-b5` (the tree at `32f9c605e`): "Test run with 80 tests in 14 suites failed after 71.618 seconds with 1 issue"; thirteen suites passed — `MobileSettingsListTests`, `MobileAppearanceTests`, `MobileRootMenuTests`, `MobileNavigationTests` (`theTabBarCarriesThreeDoorsAndEachOneMovesTheBand()` GREEN: `8eb727f2e` verified), `MobileProtectionCompositionTests`, `MobilePathLineGeometryTests`, `MobileTabBarTests`, `MobileShellTests`, `MobileLookSourceTests`, `MobilePhoneControlsSourceTests`, `MobilePhoneTypeSourceTests`, `MobileSharedPageStyleTests`, `MobileLibraryLookTests`; ONE red, the VM-27 pin's `joined → nil` case: "@Dependency(\.database) has no test implementation, but was accessed from a test context" (recorded at `AppDatabase+Dependency.swift:188`, the read `SyncEngine.swift:68`) — a HARNESS defect, traced in §6 "Batch 5 — results" ("The pin's unscoped round") and fixed in row R1.3; the `joined → false` case passed. **(b)** VM-27's red-on-old from the snapshot: NOT PROVEN — the same unscoped read fell through to the live default, whose open of the simulator test host's own store failed ("sqlcipher_page_cipher: hmac check failed for pgno=1") and stopped the host (`AppDatabase+Dependency.swift:19`, fatal error); the relaunch executed 0 tests; no "two Protection…" failure was reached. Re-run owed on the corrected pin from a re-made snapshot (row R1.5) — since RUN and PROVEN there (13:32–13:35: green on the fixed tree, red on the snapshot, both cases); the stray store removed. **(c)** the fifteen Mac types from `vm47-b5`: "Test run with 84 tests in 15 suites passed after 16.489 seconds" |
| 6 | The re-land of VM-55 (its branch tip merged in ahead of its PR; 23 conflict files; its new faces on this run's layer; the path lines, the bar and message line, the tab's word, the wing landing) | READY for the stage — the code and pins DONE (6.1–6.6), both schemes GREEN into `vm47-b6` (6.7), §6 written (6.8); the whole phone target RUN at baseline (row 6.9, 14:06–14:18); the Mac list RUN green (row 6.10), then the whole Mac target (PENDING — it runs once, as the merge gate) and the run's one walk; R-47-3's word since (row R-47-3). Earlier: **the merge is COMMITTED: `0ff256975`** (VM-55's tip `49e795bb6` into `5bc1174fd`; all 23 conflicts resolved file by file, the phone scheme `build-for-testing` into `DerivedData/vm47-b6` GREEN on the merge tree before the commit). The per-file log kept while it was open is the gitignored `notes/plans/vm-47-screens/b6-reland-log.md` (§6 "Batch 6 — results" carries it). NEXT: pieces 6.2–6.6 (drafted in the gitignored `notes/plans/vm-47-screens/b6-drafts/`, dry-run on copies), then the builds and §6. Pieces below (implementer: Opus, 2026-11-19; build products `DerivedData/vm47-b6`; NO revert is in flight in this worktree) — **SINCE ANSWERED:** the run's one walk DONE (rows W.3–W.6, W.9, W.11 (9)); the whole Mac target still runs once, as the merge gate |
| 6.0 | Reading: §1–§6 (batch 1's role map, batch 2's controls and path-line fix, batch 3's grounds, batch 4's bar and "For the re-land", batch 5's doors and line ranges), CLAUDE.md + canon, the resiliency protocol, the sizing sheet §A–§E (the receipt line), VM-55's record whole (`notes/plans/fixes/vm-55-wings-underneath.md` on its branch: batches 1, 2a, 2b, 3, 4, the walk, round 1), this run's layer (`PhoneType`, `PhoneInks`, `PhoneMetrics`, `PhoneControls`, `MobileTabBar`, `MobileRootMenu`) and the guards | DONE |
| 6.1 | The merge: the 23 conflict files resolved one by one so both runs' intent survives (VM-55's behaviour, words, views and parameters; this run's roles, inks, spacing, controls, grounds, bar), never by file; VM-55's auto-merged lines in those files onto the layer; compile fixes; then the merge commit (its message lists the 23 files and each decision) | DONE (`0ff256975`) — 23 resolved (the log's table, carried into §6); one compile fix beyond them (VM-55's `MobileWingDoorTests` drops batch 5's retired `onSettings:`); meeting 2's shell lines in the merge (the bar measured on `MobileTabBar`; the lift keyed to `barOnScreen`); phone `build-for-testing` into `vm47-b6` GREEN at the merge tree (`** TEST BUILD SUCCEEDED **`, 0 errors) |
| 6.2 | VM-55's new faces on this run's layer (`MobileMessageLine` — the sizing sheet's receipt line; `MobileWingDoor` — the door and the list sheet; any other new phone view), so the three source scans (`MobilePhoneTypeSourceTests`, `MobilePhoneControlsSourceTests`, `MobileLookSourceTests`) are clean over the merged tree — measured before and after by their own patterns | DONE (this commit) — `MobileWingPath` (the door's title and the plain line `meta`, one line, the corrected muted; the door's target the hit-area helper's 44 on the line's own box — the 14/6 hand-back and `MobileWingDoorMetrics`' two padding constants gone); `MobileWingListSheet` on `PhoneSheetHeader`, the gutter, a row's name `control` in ink and its ✓ `meta`; `MobileMessageLine` as the sizing sheet's receipt line (words `controlInline` 15 with 12 above and below, the removal in `tokens.phone.muted`, the act `PhoneInlineActStyle(weight: .semibold)` across 44 × 44, the line 44 at the gutter) in the library's look (the model's `look:`, the shell passes `router.tokens(dark:)`); `PhoneInlineActStyle` gains an additive `weight:`; one stale `ThemeStore` comment. The scans' mirrors over the tree: BEFORE 8 slot reads · 0 sub-13 · 1 control signature · 0 look (+ 4 voice-ink reads); AFTER 0 · 0 · 0 · 0 (+ 0). Phone `build-for-testing` into `vm47-b6` GREEN |
| 6.3 | Meeting 1 — the roots' path lines: the wing door a 44 pt target, the line ONE line at 402 pt in both voices, this run's doors 44 pt, the ⋯ on all three roots; VM-55's pins moved to the rule they protect where they hold this run's old literals (reason in the commit) | DONE (this commit) — the numbers measured with the real fonts: Terminal's "~/home/shelf  ·  14 books" wants ≈ 438 pt beside the three doors and the gutters (≈ 422 with one book), Study's "Home · Shelf  ·  14 books" ≈ 376 — so at 402 in Terminal the path truncates at its tail (P-47-9's rule): every target 44, one line, the ⋯ on all three roots (PROVISIONAL P-47-27, §5). VM-55's pins hold the rule, not the paddings, so none moved; NEW `MobilePathLineGeometryTests.theBookcaseLineWithItsWingDoorHoldsOneLineAndEveryTarget` (402 and 430 × both voices, 14 books: the wing door ≥ 44 × 44 and never taller, the three doors ≥ 44 × 44 on its line, after it, inside, + New Note's word whole, the door fires); RUN in the whole phone target (row 6.9): its suite passed |
| 6.4 | Meeting 2 — the bar and the message line: VM-55's measurement re-attached to `MobileTabBar`; the line's lift keyed to "a bar is on screen" (roots and pushed lists) | DONE (the shell's lines in the merge `0ff256975`; the pins this commit) — VM-55's measurement re-attached to `MobileTabBar` (the `tabBar` property); the lift is `barOnScreen` = a root (`pagingAllowed`) OR a pushed list on the visible stack showing its bar (`listBar(owner)`, counted per stack by its own appear/disappear — `listBarsShowing`); NEW `MobileTabBarTests.theMessageLineClearsTheBarWhereverABarIsOnScreen` (the line's model through the shell's host probe: a root ≥ 56, the pushed Trash ≥ 56 — red on the old rule by construction — a note 0); MOVED `theRouteRuleIsTheDestinationBuilders` to the counted form (the rule it holds unchanged); RUN in the whole phone target (row 6.9): `MobileTabBarTests` passed |
| 6.5 | Meeting 3 — the tab's word: tests that drive the tab by "Shelf" move to "Bookcase" (reason stated); the Bookcase root's path word read in both voices and recorded | DONE (this commit) — VM-55's `MobileWingDoorShellTests.fromTheLibraryAPickLandsOnTheWingsBookcase` MOVED: `elements(selected: "Shelf")` → "Bookcase" (LK-5, SW-1 — the tab's word; the fact unchanged); no other test of either run drives the tab by "Shelf" (grep — `MobileWingsTests:189–190` and `MobileWingDoorTests:263, 394–395` are the PATH word). The root's path word: VM-55's door changed that line's words (P-55-2), so they stand — the merged Bookcase root reads "Home · Shelf · N books" (Study) / "~/home/shelf · N books" (Terminal) under a tab that says Bookcase; put to her as P-47-28 (§5) |
| 6.6 | Meeting 4 — the wing landing: batch 4's tab road (P-47-19) against VM-55's landing, confirmed from the code; pinned if no pin of either run holds it | DONE (this commit) — the two agree (VM-55's landing is `selectPage(.shelf)` and touches no stack, P-55-14; batch 4's tab road returns the stack being left to its root first, P-47-19; the door is drawn only on a root); no pin of either run held the pair: NEW `MobileTabBarTests.aWingLandingAfterAListWasLeftShowsTheBookcaseItself` (the Trash pushed on the Bookcase's stack, Library by its tab, the wing door, Work: the landing is Work's Bookcase ROOT, no Trash); RUN in the whole phone target (row 6.9): `MobileTabBarTests` passed |
| 6.7 | Builds — after the orchestrator's "QUIET over": phone, then Mac, `build-for-testing` into `DerivedData/vm47-b6`, one at a time | DONE — after "QUIET over" (13:32), one at a time, into `vm47-b6`: phone GREEN on the merge tree (before its commit), after 6.2, and after the pins (`b20b04fad`); Mac GREEN at `b20b04fad` (`Shared/Theme/` changed: `PhoneInlineActStyle`'s additive `weight:`, one `ThemeStore` comment). `origin/main` `eb18888db` (VM-55's PR #13) merged in at `e72323130` — notes and ledgers only, so the products stand. `vm47-b5` deleted |
| 6.8 | §6 "Batch 6 — results" (the tip, the merge commit, the 23 files, the four decisions, the faces and roles, every moved pin, the scans' before/after, the builds, the stage lines); READY for the stage | DONE (this commit) — §6 "Batch 6 — results"; P-47-27, P-47-28 (and P-47-8's batch-6 rows) in §5; READY for the stage (the lines are §6's) |
| 6.9 | The whole phone target on the re-landed tree (both runs' tests on one tree for the first time) — run by the ORCHESTRATOR under its own stage claim, from `DerivedData/vm47-b6` at `b20b04fad`, on the standing suite device | DONE — RUN 14:06–14:18 (the stage released 14:18:14), at baseline: 1,045 tests in 179 suites, one host launch; the only red is VM-24's caret test (`MobileMarkdownCaretTests.aReplaceThroughTheInputRoadAtARescuePointKeepsTheSurfaceInStep`, 2 of 3 cases — main's baseline); 8 known issues — the four standing ones and this run's four filter-row marks (P-47-7); VM-55's wing-door suites and this run's path-line suite pass on one tree, and so do the message line's, the wing landing's, the tab bar's, the Protection door's, Settings', the appearance choice's and the bottom bar's; the standing simulator's test-host container lists `Variorum-dev` only (the orchestrator's handoff, "UPDATE 14:35"). The tree since moved by R-47-3 (its row): the suites that read the Bookcase root's line were re-run in a short window — GREEN (row R-47-3, 16:11–16:14) |
| 6.10 | The targeted Mac leg on the re-landed tree — the 114 types of §6 "Batch 6 — results" (batch 3's 102 theme-store types, batch 5's eight, VM-55's four Mac pins), run by the ORCHESTRATOR under its own stage claim, `test-without-building` from `DerivedData/vm47-b6`'s Mac products (`b20b04fad`; what moved in the tree since is `MobileShelfView.swift` and four phone test files — nothing the Mac target compiles) | DONE — RUN 14:51–15:06 (the stage released 15:06:42), GREEN: "Test run with 565 tests in 114 suites passed after 825.229 seconds with 4 known issues", `** TEST EXECUTE SUCCEEDED **`, one host launch, no restart; no red against main's Mac baseline. None of the 114 dropped: the result bundle holds 114 suites and every listed type carries at least one test case; 104 suites passed, 10 skipped by their own opt-in gates (the capture harnesses and the two opt-in measuring suites — 24 tests), 541 tests passed. Batch 5's eight: `AppearanceChoiceTests` 4 · `SyncLockedRowTests` 6 · `SyncProgressRowTests` 8 · `SyncRetryingRowTests` 5 · `SyncOutOfDateFaceTests` 7 · `SyncStalledRowTests` 2 · `NotOnYetWordsTests` 5 · `HostedSyncTierFaceTests` 5. VM-55's four Mac pins: `VM56MacWingScopePinTests` 2 · `VM61MacStatusSeamPinTests` 4 · `VM62MacRefusalWordsPinTests` 4 · `VM63MacWingBrainsHoistPinTests` 2. `TakesEntryBandTests` 11, `WingPaletteDoorsTests` 10 and the seven theme types (`ThemeTokenTests` 9, `PaletteDerivationTests` 16, `NoLiteralColourTests` 2, `SharedPageStyleTests` 1, `PaletteReachTests` 8, `MarkdownPaletteWritersTests` 3, `HelperWindowThemeTests` 3) passed. The 4 known issues are pre-existing (`theBookIndexsLivePaneIsItsReadTierLineForLine` ×2, `theReadEditLivePaneIsItsReadTierLineForLine` ×2). No instance left, no Problem Reporter, no new crash report. The whole Mac target runs once, as the merge gate |
| R-47-3 | Her ruling (2026-11-19, the question tool): the Bookcase root's own path line says "Bookcase", matching its tab (was P-47-28). Implementer: Opus, 2026-11-19; no revert in flight in this worktree. Pieces: (1) the word — `MobileShelfView`'s `MobileWingPath(page:)`, nothing else; (2) the pins that read the line's words moved, the reason stated, + the new assertion; (3) the walk app and the driver rebuilt into `DerivedData/vm47-walk` (`walk_build`) and the phone unit tests compiled there; (4) the walk's instruments and `vm-47-walk.md`; (5) the record (§1, §4, §5, §6) | DONE — **the short window RAN GREEN** (the orchestrator, 16:11–16:14, the standing device, `test-without-building` from `DerivedData/vm47-walk` at `864ef813b`'s code): "Test run with 65 tests in 9 suites passed after 107.389 seconds", `** TEST EXECUTE SUCCEEDED **`, one host launch, no known issue, no red — the nine types `MobilePathLineGeometryTests` `MobileRootMenuTests` `MobileWingDoorTests` `MobileWingDoorGeometryTests` `MobileWingStandTests` `MobileWingDoorShellTests` `MobileTabBarTests` `MobileNavigationTests` `MobileShelfRenderedLayoutTests`; the pin `theBookcasePathLineIsOneLineAtFourHundredTwoInBothVoices()` ran and passed with its literal assertion, and so did the three moved VM-55 pins (`theShelfRootsDoor()`, `theLineReadsTheSameWithItsDoor()`, `thePathLineLeadsWithTheWing()`) and `everyRootCarriesTheMenuOnItsPathLine()`; the device's test-host container lists `Variorum-dev` only. Pieces: (1) the word DONE (`50635a674`); (2) the pins DONE (this commit): MOVED, the ruling the stated reason in each — `MobilePathLineGeometryTests.theBookcasePathLineIsOneLineAtFourHundredTwoInBothVoices` (its path lookup `tokens.path(["Shelf"])` → `["Bookcase"]`), `MobileRootMenuTests.everyRootCarriesTheMenuOnItsPathLine` (the same), VM-55's `MobileWingDoorGeometryTests.theShelfRootsDoor` (`root:` and the door's `value:` "Shelf  ·  0 books" → "Bookcase  ·  0 books"), VM-55's `MobileWingDoorTests.theLineReadsTheSameWithItsDoor` (its Shelf example's page) and VM-55's `MobileWingStandTests.thePathLineLeadsWithTheWing` (`MobileWingsTests.swift`: "Work · Shelf" / "~/work/shelf" → "Work · Bookcase" / "~/work/bookcase"); NEW, the pin: in `theBookcasePathLineIsOneLineAtFourHundredTwoInBothVoices`, the root's own line begins "Bookcase  ·  " in Study and "~/bookcase  ·  " in Terminal, literal (red on old by construction: "Shelf  ·  …" / "~/shelf  ·  …"); no assertion weakened; the counts PENDING a short stage window (`864ef813b`); (3) the builds DONE (this commit) — headless, one at a time, into `App/Variorum/DerivedData/vm47-walk` only (`vm47-b6` untouched): `walk_build` (the runbook's — the walk app and the UI-test bundle with the driver, from this tree) 14:47:04–14:47:25 `** TEST BUILD SUCCEEDED **`, `MobileShelfView.swift` recompiled, the bundle carries `VM47FinalWalk` (404 symbols), the driver's temporary copy in `VariorumMobileUITests/` removed and the tree clean; then `xcodebuild build-for-testing -scheme VariorumMobile -destination 'generic/platform=iOS Simulator' -derivedDataPath DerivedData/vm47-walk` (the phone UNIT tests — `walk_build` builds `TK2SpikeUITests`, whose one testable is the UI-test bundle) 14:47:42–14:48:27 `** TEST BUILD SUCCEEDED **`, the four moved test files compiled, no warning in them; no test run, no simulator, no stage (`bde05a7d8`); (4) the walk DONE (this commit) — the gitignored instruments needed no change: `VM47FinalWalkDriver.swift` finds the tab by its button label "Bookcase" (`label ==[c]`, the wing door's label is the wing's name) and the Bookcase's rows by the identifier `shelf.booksRegion` (unchanged), and reads no path-line words; `walkfinal.zsh` names no page word; `notes/plans/vm-47-walk.md`: the header's tree (+ `50635a674`), §2's questions (P-47-28 → "the line reads Bookcase (R-47-3)", P-47-27's Study edge), §3's c1 row (the line's words and "the line reads Bookcase (R-47-3)"), §4's list of calls shown (R-47-3 as built); its verdicts, result blocks and findings untouched (`4cad6d6c3`); (5) the record DONE (this commit) — §1 her three later items (≈11:50, 14:10, the ruling), §4 rows 6.9 (the whole phone target on the re-landed tree, DONE) and 6, 6.3, 6.4, 6.6 flipped, §5 (R-47-3 was P-47-28; P-47-27's clause), §6 "Batch 6 — results" (the phone result where it said PENDING; meeting 3's ruling and what it changed, with every other "shelf" read and left; the changed word among the new rendered lines). **The suites that read the line PENDING a short stage window** (from `DerivedData/vm47-walk`, which now holds the phone unit tests too: `MobilePathLineGeometryTests MobileRootMenuTests MobileWingDoorTests MobileWingDoorGeometryTests MobileWingStandTests`) |
| 7 | The re-land of MAIN (VX-981's and VM-78's merges; this run merges last of four, VM-64 after): `origin/main` merged in so both runs' intent survives in every file — the four conflict files by round 4's map (`notes/plans/fixes/vm-78-ladder-round4.md`, "The map, final"), the three lines no hunk shows restyled onto this run's roles, every both-touched auto-merged file read for a clean-merge that is wrong; this run's six source rules and main's guards measured over the merged tree; both schemes' `build-for-testing` into `DerivedData/vm47-fix`. Implementer: Opus, 2026-11-19; no revert in flight in this worktree; while the merge is OPEN its per-file log is the gitignored `notes/plans/vm-47-screens/b7-reland-log.md` | READY for the stage — the merge `4866c7fb8` (main `a09d6a025`), the new pin `9147929f7`, both schemes GREEN into `vm47-fix`, the rules 0 over the merged tree (measured by script), §6 written; the windows (§6 "Batch 7 — results", "The stage window": the phone array before the gate, the Mac leg, then the whole targets) are the orchestrator's, PENDING — **SINCE RUN:** the targeted window (row 7.7: the phone's 64 types green, the Mac's 25 with the one red traced and fixed) and the post-merge window on the final tree (row W.11) |
| 7.0 | Reading: CLAUDE.md, the resiliency protocol, this record §2, batch 6's rows and §6 "Batch 6 — results" whole, the walk's fixes (part A, batch 2); on main the round-4 map (lines 651–733) and its final calls, VM-78's FOR A LATER READER and its batch-A/merge-in sections for the four files; `git fetch`; main's tip `a09d6a025`, 273 commits ahead, 145 files; the trial merge — EXACTLY the four expected conflicts (`Shell/MobileBookDetails`, `Shell/MobileCreateBook`, `Write/MobileMembership`, `Write/MobileWriteView`) | DONE |
| 7.1 | The merge (`git merge origin/main`, no fast-forward): the four files hunk by hunk by the map; each resolved file read whole; the per-file log | DONE (`4866c7fb8`, parents `c75e4229b` + main `a09d6a025`) — the four files resolved hunk by hunk by the map, each read whole after; the per-file log is the merge commit's message (and the gitignored `vm-47-screens/b7-reland-log.md`). One call the map's quoted inks do not settle, settled by its own rule ("the styling is VM-47's"): where the map quotes this run's PRE-walk inks (the faint on the date chip's empty arm, the kind mark, the finish caption, the pause sentence), this run's LATEST styling stands (the corrected muted, W-A9 / W-B1-W-C3) — measured: the map's literal inks red this run's two faint rules on 4 lines |
| 7.2 | The lines no hunk shows (the map's three: the Unarchive row's two `.font(…)`, the Diverge button's `.font(tokens.small)`), restyled onto this run's roles; every auto-merged file BOTH runs touched under `App/Variorum/` read for a clean-merge that is wrong, each put on this run's layer (styling only) | DONE (in the merge `4866c7fb8`) — the map's three restyled (the Unarchive verb → `control`, its pause sentence → `meta` + the corrected muted, its button → `PhoneMenuRowStyle`; Diverge → `PhoneInlineActStyle(tone: .muted)` inside its `if`) + `MobileCreateBook`'s `kindWord` deleted ("Smart Book", G2); the both-touched auto-merged files (`MobileLibraryView`, `MobileShelfView`, `MobileTrashView` and three test files) read whole — nothing wrong, nothing changed; every styling line main added to phone code is in the four files |
| 7.3 | The rules, measured by script over the merged tree (before at the raw merge, after): this run's six rule suites + main's two guard tests; `MobileMembershipSheetFaceTests` checked by reading | DONE — ported verbatim to the gitignored `vm-47-screens/b7-drafts/rules.swift` (validated against the record's counts at `273bcec51` / `fe85ea6d5`); RAW MERGE (the hunks only): type slots 3 (the map's three), both faint rules 1, G2 1, all else 0; THIS TREE: all 18 tests' patterns 0; `MobileMembershipSheetFaceTests` checked by reading — every assertion holds on the merged sheet (§6) |
| 7.4 | The tests that move (a premise the join changes), each to the fact it protects, reason in the commit; new pins only where the join made a fact no pin holds | DONE — NO test moved: no premise of either run's tests changes in the join (read: this run's chip, Trash and Book Details hosts; VM-78's hosted Book Details and membership tests — labels and hints, which this run's styles never change); ONE new pin for the one fact the join made that no pin held — `MobileBookDetailsJoinRowsTests.anArchivedBooksRowsEachAnswerTheMenuRowsFloor` (`9147929f7`; its red-on-old PENDING a snapshot, recipe in §6) — **SINCE RUN:** red on the raw-merge snapshot in both voices (row W.11 (5): "the Unarchive row answers 22.0 pt tall, under the menu row's 44.0") and green on the final tree (row W.11 (1)) |
| 7.5 | Builds into `DerivedData/vm47-fix`, one at a time, never in a QUIET window: phone `build-for-testing` → commit the merge (its message carries the log) and push → Mac `build-for-testing` | DONE — phone GREEN on the merge tree before its commit (20:11:52–20:12:54); the merge committed and pushed (`4866c7fb8`); Mac GREEN at `4866c7fb8` (20:13:45–20:17:03, `** TEST BUILD SUCCEEDED **`, 0 errors); phone GREEN again with the new pin (20:18:12–20:18:27, two compile errors in the new file fixed first); no QUIET window met |
| 7.6 | The record: §6 "Batch 7 — results" (the log, the restyled lines, the auto-merged files, the moved tests, the rules' table, the builds, "The stage window" with the two zsh arrays); §5 for any PROVISIONAL; these rows flipped | DONE (this commit) — §6 "Batch 7 — results" (the merge, the four files, the three restyled lines and their roles, the auto-merged files, the rules' before/after table, the moved tests (none) and the new pin, the builds, "The stage window" with the two zsh arrays, the ranked risks); no new PROVISIONAL |
| 7.7 | The targeted window's one red (the orchestrator's, on the re-landed tree): `BadgeFamilySplitTests.theWindowsHandTheSyncedSwitchToTheRoad` reads `ThemeStore.swift`'s SOURCE at the Mac app's old path — traced, fixed test-only, and the class swept (every source path a test names, and every test naming a file this run moved, split or deleted) | DONE — the trace: THIS RUN broke it, at batch 3's hoist (`dc9a5fd05`, 2026-11-19), of a test on main since VX-934 (`d44e207e7`, 2026-11-08) that batch 3's Mac leg never ran (it reads the store's source, never constructs it); the fix `3c960718a` (the path follows the file to `Shared/Theme/ThemeStore.swift`, the two strings unchanged, both stand at its :70 and :72); the sweep's table in §6 (one other finding, recorded and left: the hoisted-brain register can't take `ThemeStore`); Mac `build-for-testing` into `vm47-fix` GREEN (21:54:49–21:55:44); no phone test file changed; the re-run is the orchestrator's (§6) |
| 7b | The SECOND and LAST re-land of MAIN (VM-64's merge `982405967`, PR #16, with its ledger `151d8a80f` and a board snapshot — main's tip `64fde83b0`; this run merges last of the wave): `origin/main` merged in so both runs' intent survives in every file — the four conflict files by the coordinator's two maps (VM-64's for `MobileLibraryView.swift`, word for word, in the gitignored `vm-47-screens/b7b-maps.md`; its seven items written out in §6 "Batch 7b — results"), never by picking a side per file. Implementer: Opus, 2026-11-19 night; no revert in flight in this worktree | DONE — the code and the record (rows 7b.0–7b.6); every test run is the orchestrator's window, PENDING (§6 "Batch 7b — results", "The stage window") — **SINCE RUN:** every leg of its stage window, in the post-merge window on the final tree (row W.11) |
| 7b.0 | Reading (phase 1, read-only while the W-A1 redo was live in this worktree): CLAUDE.md, the resiliency protocol, the maps, VM-64's record on main (FOR A LATER READER; batch 1 — the readout; batch 5 — the Library's paging; the gated speed suite's run line), this record §2, §6 "Batch 7 — results" whole, the walk's fixes (part A, batch 2), §4's W.10 rows; the trial (`git merge-tree`) and each conflicted file on both sides | DONE |
| 7b.1 | The merge (`git merge origin/main`, a merge commit): the four files hunk by hunk by the maps (`.gitignore`; `MobileSettingsView.swift`; `VariorumMobileApp.swift`; `MobileLibraryView.swift` — the seven items checked one by one, and this run's own lines: the placeholder initializer, the search's focus release, the page's edge-ground declaration); each resolved file read whole; the per-file log | DONE (`3d55b51f6`, parents `7fa3b76a3` + main `64fde83b0`) — four conflicts, exactly the trial's and the maps': `.gitignore` both lines; `VariorumMobileApp.swift` VM-64's `init()` (the timing layer before the bootstrap) above this run's lobby comment, the scene-phase lines auto-merged and checked; `MobileSettingsView.swift` this run's grouped list, VM-64's Timing… door re-made as the Diagnostics group's menu row (diff3: the door is main's only change in the hunk); `MobileLibraryView.swift` this run's edge-ground declaration then VM-64's one hold task — the seven items each checked, with their lines in §6; this run's own lines stand; each resolved file read whole; the log in the merge message |
| 7b.2 | The both-changed files that merged clean (the map's nine; computed: exactly those nine + the four) read for a clean merge that is wrong; VM-64's new phone faces (the readout `MobileTimingView`, its door) on this run's layer — styling only, its words and behaviour untouched ("Commits per leaving", "Commit tries" kept) | DONE (in `3d55b51f6`) — the both-changed set computed = the map's nine + the four; each clean file's `git diff HEAD` is exactly main's line set (by script) and was read: nothing wrong, nothing changed; VM-64's readout `MobileTimingView` put on the layer in the edit trace's shape (header, `meta` lines, inline acts; words untouched, "Commits per leaving" / "Commit tries" kept); its door above; P-47-8 extended (§5) |
| 7b.3 | The rules, measured by the ported script over the merged tree (raw merge → after): this run's rule suites and main's two guards; the path sweep; `MobileLibraryPagingTests`' four named tests read against the merged view | DONE — the port brought up to R3-n1 (`1306a9f07`): raw merge 0 → 0 as written; with the `Features/Perf/` exemption lifted (a measurement) 8 → 0, all in the readout; main's two guards 0; the path sweep (UI tests added): no source path missing by accident; the four paging pins read against the merged view — one walks the tab by "Shelf" (7b.4) |
| 7b.4 | Tests that move (a premise the join changes), each with its reason; never an assertion weakened | DONE (`9fcf7b7a2`) — `MobileLibraryPagingTests.aWingSwitchedWhileTheLibraryIsAwayIsHonouredOnTheReturn` and `MobileHerPathsPerfTests.typingInTheBoxWakesTheOffScreenLibrary` drive the tab by this tree's word, "Bookcase" (MOVED from "Shelf"; assertions unchanged); `MobileSettingsListTests.everyDoorIsAWholeRowAtLeastFortyFourTall` holds "Open the timing readout" too |
| 7b.5 | Builds into `DerivedData/vm47-fix`, one at a time: phone `build-for-testing` → commit the merge (its message carries the log) and push → Mac → `TK2SpikeUITests` | DONE — phone GREEN on the merge tree before its commit (23:59:34–00:00:47), the merge committed and pushed; Mac GREEN at `3d55b51f6` (00:01:50–00:04:16); phone again with the moved tests GREEN (00:05:01–00:05:18); `TK2SpikeUITests` GREEN (00:05:28–00:05:39); no compile error to fix |
| 7b.6 | The record: §6 "Batch 7b — results" (the log, the seven items with their lines, the both-changed files, the restyled faces, the rules' table, the builds, "The stage window" — the phone array, the speed suite's own line, the Mac types); §5 for any PROVISIONAL; these rows flipped | DONE (this commit) — §6 "Batch 7b — results" (the log, the seven items with their lines, the both-changed files, the restyled readout, the rules' table, the builds, the stage window: the phone array, the speed suite's own line, the Mac types, the risks); P-47-8 extended; no new PROVISIONAL |
| 7b.7 | The orchestrator's call on the guard scope: this run's source rules no longer skip `Features/Perf/` whole — VM-64's Release readout is scanned; the exemption fails safe (a file there is scanned unless named with its reason); test-only, no pattern changed | DONE (`d78853d8e`) — `MobileSourceRuleScope`, asked by the six rule suites: `Spike/` as a folder + `Features/Perf/MobilePerfFixtureSeeder.swift` by name; scanned now: `MobileTimingView.swift`, `MobileTiming.swift`; measured raw merge 8 → this tree 0; phone `build-for-testing` incremental GREEN (00:13:53–00:14:11); the record's three lines in §6 "Batch 7b — results" |
| W | The run's ONE walk (two parts, device `vm47-walk`, the unified driver) and its findings in `notes/plans/vm-47-walk.md`; on the re-landed tree beside the whole phone target and a targeted Mac leg (114 types), both run by the orchestrator | IN-PROGRESS — the walker (Opus, 2026-11-19) — pieces W.0–W.8 below; NO app source is edited by the walker before the orchestrator's "tree is free" (a whole-phone suite reads this tree's phone sources) — **SINCE DONE:** pieces W.0–W.11 (the walk, its two fix batches, W-A1 redone, the re-capture and the final-tree captures, each set read); the findings file closed at the final record pass (row W.8) |
| W.0 | Reading: CLAUDE.md + canon, the resiliency protocol, this record §1–§6 (each batch's "results" and its asks of the walk), the sizing sheet (grounds, §A–§E, the token values), every instrument in `vm-47-screens/instruments/` end to end, the app's faces as they stand after the re-land (the shell, the bar, the ⋯, the wing door and its list, the one message line, the three roots, Settings, the walk seam, Write's masthead, the note's ⋯), and every label and identifier the old drivers look up checked against that code | DONE |
| W.1 | The unified driver + runbook, gitignored in `vm-47-screens/instruments/`: `VM47FinalWalkDriver.swift` (class `VM47FinalWalk`) and `walkfinal.zsh` (device `vm47-walk`, iPhone 17 Pro, iOS 26.2, created by part A, kept shut down across the seam, deleted at part B's end; captures into `vm-47-screens/final/` as `<palette>-<voice>-<appearance>-<size>--<step>.png`; `walk_part_a` / `walk_part_b` each honouring `WALK_DEADLINE=HH:MM` with a three-minute close; soft MISSING / NOT-HITTABLE logging; the count after every run; exact-name instance checks) | DONE (this commit; the instruments themselves are gitignored) — the driver typechecks standalone in Swift 6 mode against the simulator SDK's XCTest (`swiftc -typecheck`, from the scratchpad: no xcodebuild, nothing under `App/`; a planted error is caught, so the check is real); the runbook's step runner dry-run on stubbed steps (the pause, the call budget, the time guard's NOT CAPTURED skips). Expected captures: part A 99 (seed 3 · 4 default combinations × 14 · 4 AX5 × 10), part B 182 (teal & rust core 2 × 14 · Settings' flows 2 × 16 · the bar's roads and VM-55's faces 2 × 19 · VM-54's flip 2 × 6 · the wider pass 3 × 24). The plan changes it makes are listed in `notes/plans/vm-47-walk.md` ("How the walk runs") and the turn's report: a part runs as repeated FOREGROUND calls under ten minutes, resumable from a progress file (the harness's command limit); part A also shoots Settings top to bottom and the ⋯ menu in all eight combinations (Settings is opened anyway to write the voice); the seed stars a note and a book (no instrument starred anything, so Starred's ★ had nothing to show); the old `dismissEditorMenu` tap would now open Rename (it lands on today's masthead title) — replaced by a tap inside the prose; the search field is emptied before each query. **Machinery honesty:** the runner's second dry run lost its `walk_create` stub and CREATED a real simulator device, `vm47-dryrun-nonexistent` (never booted), while the orchestrator's suite held the standing device; it was deleted by name a minute later (`simctl delete`), the standing device untouched, no other device created. Baseline before any walk: the newest crash report is `VariorumMobile-2026-11-19-120544.ips` (row 5.7's stray-store stop) |
| W.2 | The driver's build into `App/Variorum/DerivedData/vm47-walk` (headless; the temporary copy in `VariorumMobileUITests/` removed straight after; one build at a time; `vm47-b6` untouched) | DONE — after the orchestrator's "tree is free" (the whole phone target in: 1045 tests in 179 suites, the one red VM-24's): cold, 14:11–14:19, `** TEST BUILD SUCCEEDED **`; the bundle carries `VM47FinalWalk/test01_seed · test10_core · test20_rest · test30_flip · test40_shell · test50_settings`; the copy removed, the tree clean; `vm47-b6` not touched. No estimate changed (the build is not inside a part) |
| W.3 | Part A — create, boot, the seed, the core under the sea-glass × Study/Terminal × light/dark × default/AX5, the paper check at the default size; the device SHUT DOWN at its end | DONE — DRIVEN BY THE ORCHESTRATOR with the runbook's own calls (the walker stood down at 600k tokens and was not woken), 16:15–16:43 under its stage claim (one renew; released 16:43:31): **99 captures of 99**, all eight combinations, no step skipped for time. The device `vm47-walk` was created inside the claim and is SHUT DOWN with its seeded library kept; its app container's Application Support lists `Variorum-dev` only; no Problem Reporter, no new crash report. The eight core runs (`test10_core`) each PASSED with no miss in the walk log (14 captures at the default size, 10 at AX5; 152–171 s and 106–108 s). The SEED (`test01_seed`, 197 s) had misses, all its own: the note meant for the Trash was not found in the Library, the walk note's and the pocket guide's stars were not set, the comment's submit was tapped by its centre — iOS's first-use "slide to type" keyboard card covered the keyboard on the fresh simulator (capture s2 shows it; gone by the first core run). They feed part B only: a re-seed step (`test02_reseed`, idempotent) is added to the gitignored driver and runs first in part B. One machine fact: under a load average of 20–40 the seed's xcodebuild sat five minutes after its test had passed; the runbook now stops waiting at the suite's own verdict line. The captures are READ by a fresh reader into `notes/plans/vm-47-walk.md` (row W.4) |
| W.4 | Part A's captures READ, screen by screen, into `notes/plans/vm-47-walk.md` | CHANGED (the orchestrator, at "tree is free"): the walker DRIVES and does not read; the screen-by-screen reading goes to a FRESH READER briefed from `notes/plans/vm-47-walk.md`, which now names every capture's file, what it shows and what to check (§3 there) — DONE (a fresh reader, 16:45–17:10): all 99 looked at full size, grounds and inks by pixel, sizes measured; `notes/plans/vm-47-walk.md` §4 rows 1–9 and §6 W-A1 … W-A13 with the eight-combination table. This run's defects: W-A1 (the grounds stop at the safe area), W-A3 (Terminal's marker column at AX5), W-A9 (the faint on doors' words under 17 pt), W-A10 (the search placeholder's system grey) — rows W.7a–W.7g. Questions for her: W-A2, W-A5, W-A6, W-A7, W-A8. Other tickets': W-A4 (VM-218), W-A11 (VM-93), W-A12 (VM-89), W-A13 (VM-188 / VM-195). Not judged for want of evidence: the take peek (c6 identical to c5) and the caret (c8) — re-shot in the re-capture |
| W.5 | Part B — the second palette, Settings, the bar's roads, VM-55's faces, VM-54's flip, the wider pass × three combinations; `walk_close` deletes the device | DONE — DRIVEN BY THE ORCHESTRATOR, 17:05–17:54 under its stage claim (55 minutes, no renew; released 17:54:04): **184 captures of 186** (283 of 285 in all), every step run, none skipped for time; all twelve driver tests passed. The device `vm47-walk` is SHUT DOWN and KEPT with its library (the coordinator's change: a short re-capture runs on it after main is merged in; `walk_close` deletes it then); its app container lists `Variorum-dev` only; no Problem Reporter, no new crash report. The RE-SEED (`test02_reseed`, the first step, read before the rest ran): the walk note named and starred, one note in the Trash, the pocket guide starred (it is born starred — the seed's "miss" was the driver expecting "Star" where the menu says "Unstar"), the lesson's saved version present; the comment could NOT be added — the app's own defect, not the seed's: with the keyboard up the comments overlay's draft field and Add button sit at y 784 under a keyboard whose top is at y 583 (the walk log's EVIDENCE line; open ticket VM-14). The seed's real mistake, found by the driver's fixer: a note made through the capture box is UNTITLED, its Library row shows its date and search matches no body text, so looking a box note up by its words can never find it — the driver now names its notes. The TWO missing captures: `m3-after-undo` in both combinations of the bar's-roads test ("MISSING the line's Undo" — the driver did not find the message line's Undo on its way back; m1 and m2 were captured); re-shot in the re-capture. Counts by set: teal & rust core 14 + 14; the re-seed 4; Settings' flows 16 + 16; the bar's roads, the wing door and the message line 18 + 18; the border flip 6 + 6; the wider pass 24 + 24 + 24. READ by fresh readers in sets into `notes/plans/vm-47-walk.md` (row W.6) |
| W.6 | Part B's captures READ into `notes/plans/vm-47-walk.md` | CHANGED as W.4: the fresh reader's — DONE (three fresh readers in sets, 17:55–19:05 — one reader's context cannot hold 184 captures): `notes/plans/vm-47-walk.md` §4b (the second palette, Settings' flows, the border flip; 76), §4c (the bar's roads, VM-55's faces, the wider pass in Study light; 60), §4d (the wider pass in Terminal dark and at AX5; 48), and §6 W-B1 … W-B5, W-C1 … W-C8, W-D1 … W-D3. The second palette, R-47-2's voice flip, the appearance choice, Settings from the Library and from a note, Protection, VM-54's flip, the bar on pushed lists, the tab roads, no bar where none belongs, the wing list and the message line above the bar all MATCH; Terminal dark has no new finding; at AX5 her words grow and the chrome holds. This run's defects (row W.7's second batch): W-B1 and W-C3 (the faint on sentences and headers), W-B3 ("Delete Note…" in the system's red), W-B4 (a doubled hairline), W-C2 (a hidden page's search field takes the keyboard back after a tab tap from a pushed list), W-C4 (the segmented choice's unchosen words on the system's track), W-C7 (a system-grey divider). Questions for her: W-B2, W-C1, W-C5, W-C6, W-C8, W-D3. Other tickets': W-B5 (VM-152), W-D1 and W-D2 (VM-218). The missing `m3` settled as the driver's timing (the line lives six seconds) |
| W.7 | This run's defects fixed narrowly (after each part's claim is released and the orchestrator says the tree is the walker's), a commit per fix with the mechanism, a test where one holds; the re-capture list | IN-PROGRESS — part A's four (W-A1, W-A3, W-A9, W-A10) fixed with their pins and recorded (rows W.7a–W.7f), both builds and the red-on-old snapshot green (W.7e); REMAINING: the orchestrator's test windows (W.7g) and the re-capture, then part B's own findings — **SINCE DONE:** both fix batches built and run (rows W.7e, W.7g, W.7q), the re-capture driven and read (row W.9), W-A1 redone after it (row W.10), and every pin green on the final tree (row W.11) |
| W.7a | W-A1 — the grounds stop at the safe area: the band's `.clipped()` (`MobileShellView.body`) cut every page's `ignoresSafeArea()` ground at the safe-area frame; replaced by a sideways-only clip (`MobileBandClip`, two band-heights free above and below); pin `MobileScreenEdgeGroundsTests` (rendered pixels of the real shell in a scene window with a sentinel host colour: the status-bar and home-indicator strips are the room on a root and the paper in a note, light and dark; a guard that nothing is drawn past the band's width) + the render helper `MobileRenderedPixels.swift` | DONE (`67525b499`) — code and pin WRITTEN; build PENDING (FREE TO BUILD); pin red-on-old and green-on-new PENDING (the orchestrator's window) — **SINCE RUN:** red on old and green on new (row W.7g); the fix itself was REDONE after the re-capture (row W.10 — it had let each page's content out with its ground: W-E3, W-E4, W-F1) |
| W.7b | W-A3 — Terminal's reserved marker column (`MobileShelfView.bookRow`, the invisible "› ") was set in `rowTitle` (her words' class, full range), so it grew to ≈55 pt at AX5; now `meta` (chrome, holds at xxxLarge — batch 1's role map for markers; the wing list's ✓ column is the same construct on `meta`); the same construct swept on the other roots and lists (only the shelf reserves an invisible column); pin `MobileShelfMarkerColumnTests` (the name's first ink on the rendered Terminal shelf: AX5 no further right than xxxLarge) | DONE (`d974162f4`) — code and pin WRITTEN; build and runs PENDING — **SINCE RUN:** built (row W.7e) and run (row W.7g: red on the snapshot, green on the fixed tree); its one red traced and the pin moved (rows W.7h, W.7q) |
| W.7c | W-A9 — the corrected faint on live doors' words under 17 pt: batch 1's one-for-one `tokens.faint` → `tokens.phone.faint` kept the faint on words the sheet moved up to the corrected muted. Fixed (13 sites): the filter row's unchosen words; the masthead's chips take the sheet's two chip inks (empty → corrected muted, set date/tags/more-info → ink; the active lens keeps the accent); the swept door words in the same class — Note Actions' detail lines, Book Details' three detail lines, the link row's "opens", Starred's "note"/"book", Create Book's tag paths, the Account sheet's unchosen tab words (`Shared/AuthViews.swift`, styled phone arm only). Left, listed in §6: glyphs, the placeholder, a disabled 17 pt door, and the faint on words that are not doors (outside the class). PROVISIONAL P-47-29 (the membership and blocks chips' inks unchanged). Pins `MobileFaintOnDoorsTests` (a source rule over every phone view and shared phone arm, measured 13 → 0 on the trees before and after; the rendered ink of the filter row's words and the empty chips ≥ 4.5:1) | DONE (`36987c78e`) — code and pins WRITTEN; build and runs PENDING — **SINCE RUN:** built (row W.7e) and run (row W.7g: red on the snapshot, green on the fixed tree) |
| W.7d | W-A10 — the fields' placeholder in the system's grey: `phoneField` sets the typed text's role and ink, but a field built `TextField(title, text:)` hands its title to iOS as the placeholder in the system's grey (1.72:1), and no modifier outside the field reaches it. Fixed in the layer: `TextField(phonePlaceholder:text:tokens:)` (the words as label AND as a `prompt:` in the corrected faint) at the three sites that build a phone field (the Library search, the tag field, Create Book's name); `phoneField` hands the ink down (`phoneFieldPrompt`) and the shared `PeekableSecretField` reads it on iOS only (every passphrase and twelve-words field on the phone; the Mac's constructors unchanged under `#if os(iOS)`). Not covered, listed in §6: the Account sheet's seven fields (`Shared/AuthViews.swift`, constructors the Mac shares), the system alerts' fields, the comment draft (UIKit, VM-152). Pins `MobileFieldPlaceholderTests` (rendered placeholder ink ≥ 3:1 on the Library search, both voices, light and dark, and on a secret field; a source rule — every phone field under `phoneField` is built with its placeholder, measured 3 → 0) | DONE (`7734f0f05`) — code and pins WRITTEN; build and runs PENDING — **SINCE RUN:** built (row W.7e) and run (row W.7g: red on the snapshot, green on the fixed tree) |
| W.7e | Builds (phone, then Mac if `Shared/` changed) into `DerivedData/vm47-fix`; the red-on-old snapshot `~/dev/variorum-vm-47-rolw` (`DerivedData/vm47-rolw`) | DONE — FREE TO BUILD at 17:54: the phone `build-for-testing` at `a5c08e9f5` into `vm47-fix` — `** TEST BUILD SUCCEEDED **` (no warning in a changed file); the Mac scheme into `vm47-fix` — `** TEST BUILD SUCCEEDED **`, 0 errors; the snapshot `~/dev/variorum-vm-47-rolw`, detached at `a5c08e9f5`, the 14 app/Shared files the four fixes changed checked out from `273bcec51` and STAGED (never committed) — its staged diff compared byte for byte with `git diff a5c08e9f5 273bcec51` over those files: IDENTICAL (the fixes reversed, nothing else; no test file reverted) — phone `build-for-testing` into its own `App/Variorum/DerivedData/vm47-rolw`: `** TEST BUILD SUCCEEDED **`. This worktree was never reverted |
| W.7f | §6's "The walk's fixes (part A)" block; one FIXED line under each of the four in `vm-47-walk.md` §6; P-47-29 in §5 | DONE (this commit) — written before any build; its build and run lines PENDING (W.7e, W.7g) — **SINCE FILLED:** rows W.7e and W.7g |
| W.7g | The test windows (the orchestrator's, under its claim): the fixed tree's list and the snapshot's list | RUN (the orchestrator, 18:18–18:28, the standing device booted once for both phone legs; logs in its session scratchpad) — **(1) the snapshot** (the pre-fix tree, `vm47-rolw`), the six pin types: "Test run with 10 tests in 6 suites failed after 35.675 seconds with 55 issues", one launch — every pin RED on old: `onARootTheRoomRunsToBothEdges(dark:)` and `inANoteThePaperRunsToBothEdges(dark:)` (both cases each, 12 issues each), `atAX5TheNameStartsWhereItDoesAtXXXLarge()` (the name starts at 84.3 pt at AX5 against 54.0 at xxxLarge), `noDoorsWordsUnderSeventeenPointsWearTheFaint()`, `theFilterRowsUnchosenWordsClearTheFloor(voice:dark:)` (four cases, 16 issues), `theMastheadsEmptyChipsClearTheFloor(dark:)` (two, 6), `theLibrarySearchsPlaceholderClearsTheFloor(voice:dark:)` (four), `aSecretFieldsPlaceholderClearsTheFloor(dark:)` (two), `everyPhoneFieldIsBuiltWithItsPlaceholder()`; the guard `theBandStillDrawsNothingPastItsOwnWidth()` GREEN on old, as designed. **(2) the fixed tree** (`vm47-fix` at `a5c08e9f5`), 52 phone types: "Test run with 290 tests in 52 suites failed after 347.975 seconds with 5 issues (including 4 known issues)", one launch — the four known are P-47-7's filter-row marks; GREEN on new: W-A1's four cases and the guard, W-A9's source rule and rendered cases, W-A10's rendered cases and source rule, and every other suite (the shell, the bar, navigation, the wing door's, the message line's seven, the shelf and filter-row geometry, the path line, the three source scans, Protection's eight). **ONE RED on new:** `MobileShelfMarkerColumnTests.atAX5TheNameStartsWhereItDoesAtXXXLarge()` — the name starts at 53.3 pt at AX5 against 51.3 at xxxLarge, and the pin allows 1 pt: the fix took the growth from 30 pt to 2 pt; whether the last 2 pt is the larger name's own glyph bearing or a residue in the column is a TRACE owed (the next implementer), then the pin or the fix moves and the type is re-run alone, on both trees — W-A3 is NOT closed. **(3) the Mac** (`vm47-fix`), nine types: "Test run with 36 tests in 9 suites passed after 17.955 seconds". The standing device's test-host container lists `Variorum-dev` only; no Problem Reporter, no new crash report. The snapshot worktree is kept for W-A3's re-run |
| W.7h | Walk fixes batch 2, piece 1 — W-A3's pin red on the fixed tree: trace the last 2 pt (the name's own glyph bearing, or a column residue), then move the pin to what it protects or finish the fix | DONE (this commit) — HOLLOW AS A FIX, the PIN moved: the residue is the first glyph's left side bearing (SF Mono Semibold 'l', 0.089 em, CoreText) growing with the name's full-range size — the pre-fix tree's readings give the two drawn sizes (≈ 19.4 / ≈ 42.3 pt) and 0.089 em × 22.9 = 2.04 pt, the whole 2.0; the column itself is level (chrome held). `MobileShelfMarkerColumnTests` now compares the name's LAYOUT ORIGIN (first ink less the glyph's bearing at the resolved size): red on old by ≈ 28 pt, level on new; no production line changed; build and both runs PENDING (W.7q) — **SINCE RUN:** built and run (row W.7q: red on the snapshot, green on the fixed tree), and green again on the final tree (row W.11 (1)) |
| W.7i | Pieces 2 + 8 — W-B1 and W-C3, ONE sweep: the corrected faint on sentences, headers and non-door words under 17 pt → the corrected muted; one source rule over every faint read (what may stay: glyphs, placeholders, edges, a disabled 17 pt door); a rendered case for the Trash's promise | DONE (this commit) — 19 sites → `tokens.phone.muted` (W-B1's three: the Trash's and the Archive's promise, the empty Bookcase's sign-in line; W-C3's: "Apply a tag", a tag's path, "Add to a book", "Editing here…", "smart", the tray's explainer and its two row meta lines, Versions' explainer and the reader's meta; the same class, not captured: the file row's note, the Library's empty-store sign-in line, the box's hold note and its status word, a nested tag's path in the tag manager, Settings' "Starting…"); left by the sheet: the ○ pick mark (a glyph), the box's hint and dashed edge, the disabled 17 pt "Use as Daily Journal", the two field placeholders; pins `MobileFaintCarriesNoWordsSourceTests` (measured by a verbatim port: 19 sites at `c72e65201`, 0 after) and `MobileFaintOnDoorsRenderedTests.theTrashsPromiseClearsTheFloor` (both voices × light/dark ≥ 4.5:1); build and runs PENDING (W.7q) — **SINCE RUN:** built and run (row W.7q: red on the snapshot, green on the fixed tree), and green again on the final tree (row W.11 (1)) |
| W.7j | Piece 3 — W-B3: Delete Note… in the system red → the alarm; the sweep for system colours standing where a token belongs; the no-literal-colour twin extended to a hue passed as an argument and to UIKit/semantic system colours; a rendered case for the row | DONE (this commit) — `deleteRow`'s `tint: .red` → `tokens.alarm` (role `.destructive` kept); the sweep found no other system colour standing where a plain token belongs in the phone tree or Shared's phone arms (left, each with its reason in §6: the canary, the store-opening frame, the callout swatch's edge in a system menu, the shared pages' warning orange — no warning token, a question for her —, the secret field's eye `.secondary` — hierarchical over the field's ink —, system alerts' and context menus' destructive buttons); pins `MobileLookSourceTests.noPhoneViewPaintsALiteralColour` extended (measured by a port: 1 offender at `a21110f9d` — `MobileNoteActions` `: .red` —, 0 after; two forms allowed with decisions) and `MobileNoteActionsAlarmTests` (the row drawn in the alarm, both voices × light/dark); build and runs PENDING (W.7q) — **SINCE RUN:** built and run (row W.7q: red on the snapshot, green on the fixed tree), and green again on the final tree (row W.11 (1)) |
| W.7k | Piece 4 — W-B4: the doubled hairline above Settings in the note's ⋯ sheet; a mounted pin (no two hairlines without a row between, with and without an undo row) | DONE (this commit) — `settingsRow`'s own divider draws only when an undo or redo row renders above it (the group divider after Versions… serves otherwise); left, never on screen: with NO settings door (outside a shell — harness and preview only) the Versions divider and Delete's still meet; pin `MobileNoteActionsHairlineTests.betweenTwoRowsThereIsOneHairline` (the mounted sheet's drawn hairlines, one per gap between consecutive rows, empty stack and with an undo row — red on old in the first: two between Versions… and Settings); build and runs PENDING (W.7q) — **SINCE RUN:** built and run (row W.7q: red on the snapshot, green on the fixed tree), and green again on the final tree (row W.11 (1)) |
| W.7l | Piece 5 — the Account sheet's styled header on the layer's roles (its tabs `tokens.heading`, its Close `tokens.small`); the sweep of `Shared/`'s phone arms for Mac type slots; `MobilePhoneTypeSourceTests` extended to them | DONE (this commit) — the styled header's tab words → `.phoneType(.tab, …)` (the current one semibold — the sheet's tab grammar), its Close → the sheet header's own closing control (`PhoneTextButtonStyle(closing: true)`: 17 semibold accent, 64 × 44), its word kept; `PhoneSheetHeader` itself does not fit (its title is a header Text, the tabs are doors with the selection trait — CF-14's mechanism kept); the Mac's arm byte-identical; swept: no other read of a Mac type slot in any of `Shared/`'s phone arms (in fact none anywhere in `Shared/` outside the token layer); pin `MobilePhoneTypeSourceTests.noSharedPhoneArmReadsTheMacsTypeSlots` (a slot read through `SharedPageStyle` — nil on the Mac by construction — is a phone read; measured: 2 at `05afd4b34`, 0 after); no rendered floor case (no phone harness mounts the Account sheet — it needs `AppServices`); phone build GREEN; the Mac build HELD for QUIET (W.7q) |
| W.7m | Piece 6 — the Account sheet's seven placeholders in the corrected faint on the phone's arm only (the Mac's constructors unchanged); W-A10's source rule extended to `Shared/AuthViews.swift` | DONE (this commit) — CAN be done that narrowly: two private helpers in `AccountView` (`pagePlainField` / `pageSecureField`) give the field its `prompt:` in the corrected faint on the styled arm only (`#if os(iOS)` + `pageStyle`); every other arm — the Mac, and the phone with no style — is the call site's former construction exactly (`TextField(label, text:)`; `SecureField(titleKey, text:)` with the title as the `LocalizedStringKey` the literal resolved to — no `prompt:` is passed on the Mac); all seven fields route through them (`emailField` through `pagePlainField`); pin `MobileFieldPlaceholderSourceTests.theAccountSheetsFieldsGiveTheirPlaceholderOnThePhone` (measured: 5 raw sites + `emailField`'s raw field at `2345a713a`, none after); no rendered case (no phone harness mounts the Account sheet); phone build GREEN; the Mac build HELD for QUIET (W.7q) |
| W.7n | Piece 7 — W-C2: a hidden page's search field takes the keyboard back after the tab road's pop; trace the restoring agent, fix at the cause; a mounted pin through the shell | DONE (this commit) — traced: the Library's search is a plain `TextField` with NO focus binding; a push over the root covers it (the keyboard goes); the tab road's unanimated pop (`tabSelected` → `popToRoot`) uncovers the root while its page slides away and the framework restores the uncovered screen's first responder (UIKit's navigation restoration or SwiftUI's own — not distinguishable from source, and the fix does not depend on which); fix: the shell's `page(_:)` sets `mobilePageShowing` (tab == owner) and the Library's search (`@FocusState`) gives the keyboard back whenever it holds it while hidden, and on leaving the screen — a Back on screen keeps its restoration; what the search holds, VM-55's landing and the band untouched; pin `MobileHiddenPageKeyboardTests.theTabRoadLeavesNoKeyboardOnAHiddenPage` (search focused → the Trash pushed → "Bookcase" in its bar → no first responder in the window, the bar at its foot); phone build GREEN; runs PENDING (W.7q) — if the snapshot shows it green on old, the harness does not reproduce the restoration and the walk's re-capture carries the evidence — **SINCE RUN:** built and run (row W.7q: red on the snapshot, green on the fixed tree), and green again on the final tree (row W.11 (1)) |
| W.7o | Piece 9 — W-C4: the segmented choice's unchosen words under 4.5:1 on the system's track; trace what the control allows per instance; fix narrowly or write up a PROVISIONAL | DONE (record only, no code) — the track is the system's own translucent drawing; per instance only `backgroundColor` (composited under the control's own grey layer — not the colour set) or `setBackgroundImage` (replaces the system's drawing; on iOS 26 reported to break the glass selection) — a hand-built control in effect; no other public road (the lookup's facts, §6); not built — PROVISIONAL P-47-30 for her (§5): as built · the unchosen words in ink · a token track by a hand-built control |
| W.7p | Piece 10 — W-C7: the Lenses sheet's bare `Divider()`; the sweep of bare dividers; a source rule | DONE (this commit) — `MobileLenses` (the divider above the save doors) → `Divider().overlay(tokens.line)`; swept: 13 `Divider()`s in the phone tree — 11 already wear the line (Settings' row dividers carry it on the next line), the tag manager's long-press menu divider is the system menu's own separator (exempt), the Lenses one fixed; Shared's `PageDivider` wears `style.tokens.line` on its phone arm (the Mac's nil arm stays `Divider()`); pin `MobileLookSourceTests.everyPhoneDividerWearsTheLine` (exempts a divider inside `.contextMenu`/`Menu` — system-drawn; measured by a port: 1 offender at `fb649d6a8`, 0 after); build and runs PENDING (W.7q) — **SINCE RUN:** built and run (row W.7q: red on the snapshot, green on the fixed tree), and green again on the final tree (row W.11 (1)) |
| W.7q | Builds (phone into `vm47-fix`; the Mac into `vm47-fix` once QUIET is over — `Shared/` changes) and the snapshot `~/dev/variorum-vm-47-rolw` re-made at this batch's head with both fix batches' app/Shared files reverted, built into `vm47-rolw` | DONE — the phone build GREEN at `c64f23782`; the Mac build and the snapshot's re-make and build run BY THE ORCHESTRATOR after QUIET (its word: it took them over); THE WINDOW (the orchestrator's): the snapshot — all twelve pin types RED on old as predicted, `theTabRoadLeavesNoKeyboardOnAHiddenPage` included (the harness DOES reproduce the keyboard's return), the marker pin's origin 80.6 against 52.2; the fixed tree at `70320b2bb` — 64 of 65 suites green, the marker pin level (49.55 / 49.58), the Mac's ten green; ONE RED: `MobileFaintOnDoorsSourceTests.noDoorsWordsUnderSeventeenPointsWearTheFaint` → `Shared/AuthViews.swift:469` (piece 6's placeholder, read as a door's word) — traced and fixed test-only (row W.7s); the snapshot worktree removed after the window |
| W.7r | The record: §6 "The walk's fixes (batch 2)", §5's PROVISIONAL rows, one line under each finding in `vm-47-walk.md` §6 | DONE (`e67e8f13c`, `5a4bce5b6`, this commit; the walk file's lines `b25ca04a7` — the set-3 reader's commit carried four of them — and `1526bb0fb`) |
| W.7s | The window's one red: the first batch's door rule flags `pagePlainField`'s placeholder | DONE (this commit) — traced: `insideADoor` takes any enclosing block whose opening line holds "label:" for a door (a `label:` closure), and `pagePlainField(_ label: String, …)`'s signature holds it; no role (`Text(label)`), no glyph, no edge — so the placeholder's faint read as a door's word; fixed (b), test-only: the door rule gains the sibling's placeholder exemption (a line holding "prompt"); measured by a verbatim port: 13 sites at `273bcec51` with and without it, 1 at `70320b2bb` without it (`AuthViews.swift:469`), 0 with it; production untouched (no Mac build owed); `theAccountSheetsFieldsGiveTheirPlaceholderOnThePhone` (7 fields, 0 offenders) and `everyPhoneFieldIsBuiltWithItsPlaceholder` (the phone tree, unchanged) hold by their own patterns; phone `build-for-testing` into `vm47-fix` GREEN; the re-run rides the orchestrator's next window |
| W.8 | The record: the findings file closed; §5 for any new question; this row flipped | DONE (the final record pass, implementer: Opus, 2026-11-20; no capture taken, nothing built or run) — §5: P-47-42 (W-E2, the dark take tint), P-47-43 and P-47-44 (the W-A1 redo's two give-backs) added; P-47-29 and P-47-38 brought to what the re-captures show; W-E3 and W-F1 need no row (the redo removed them); "Held for her hands" brought current. The walk file: its FOR A LATER READER written, its §5 result blocks pointed at rows W.3, W.5, W.9 and W.11, its header's tree line naming the four capture sets |
| W.9 | The RE-CAPTURE (part C of the walk) on the fixed, re-landed tree — the fixes' re-shoots, the four conflict screens after main's merge, the evidence gaps (the message line's Undo, the take peek, the caret, the pill) — on the kept device `vm47-walk`, into the gitignored `notes/plans/vm-47-screens/recapture/` (parts A and B stay in `final/`) | DRIVEN BY THE ORCHESTRATOR, 21:49–22:28 under its stage claim (45 minutes, no renew; released 22:28:07), the walk app rebuilt at 20:22 on the merged tree's app code (`4866c7fb8`): **164 captures of 166**, every step run, none dropped for time, all eleven driver tests passed — the core in four combinations (Study light 16, Terminal dark 16, Terminal light AX5 10, Study dark 16), the bar's roads ×2 (19 + 19), the wider pass ×2 (23 + 23), Settings' flows 16, the border flip 6. The message line's Undo was PRESSED IN TIME in both combinations ("UNDO pressed 2.0 s after the removal") and `m3-after-undo` is captured; the take's peek state was CAUGHT in the three default-size core runs and in the flip (the pill up, the shot 0.9 s after the flip — the phone has no held mid-drag peek: a take flips when the swipe ends); the caret is shot three times per run. The TWO missing: `r05b-create-book-smart` in both wider passes — the driver looked for the kind segment by its old label "Smart Book", and the merged tree says "Gathering" (the driver's stale label; re-shot in the final-tree pass). The two Account-sheet steps were skipped beforehand: a dev store's sync row has no Account door, so that sheet stays unseen by any capture (§5, "Held for her hands"). The device is SHUT DOWN and KEPT; its app container lists `Variorum-dev` only; no Problem Reporter, no new crash report. READ by two fresh readers into `notes/plans/vm-47-walk.md` §4e and §4f — PENDING — **READ SINCE** by two fresh readers: §4e (`9a39e7a97`) and its findings (`47c5e2b05`; W-E4's trace `7c1e3f1d6`), §4f (`227572cab`) and its findings (`c24521641`) — every fix in its brief shown, three new: W-E4 (this run's, from W-A1's first fix), W-E3 and W-F1 (the same fix's), all three removed by the redo (row W.10) |
| W.10 | W-A1 REDONE (implementer: Opus, 2026-11-19 night) — the band's `.clipped()` back exactly as on main and `MobileBandClip` deleted, so W-E3, W-E4 and W-F1 cannot come from this run; W-A1's result given back by the SHELL painting the strips beyond the band, behind it, in each page's DECLARED edge grounds (§6, "W-A1 redone") | DONE (`5daf61efd`, `9f0dc1229`, `b1e345be0`; the record this commit) — both builds green; the test windows, the red-on-old snapshots and the re-captures PENDING (the orchestrator's — §6 "W-A1 redone": the matrix, the recipe, the zsh array, the UI test's line, the captures owed); merged into by `3d55b51f6` (main `64fde83b0`) with every line of the redo standing (read after the merge) — **SINCE RUN:** the windows, the snapshots and the UI test (row W.11 (1), (3)–(4), (6)–(7)); the re-captures (row W.11 (9)) |
| W.10a | Reading: CLAUDE.md, the resiliency protocol, `vm-47-walk.md` §6 (W-A1, W-E3, W-E4 with its TRACE, W-F1) and §4e/§4f's W-A1 rows; this record §6 (W-A1's block, batch 3's grounds table, batch 4's bar); the shell whole, every page's ground line, `67525b499`, main's line; the walk driver (read-only, for the UI test's helpers); one Sonnet lookup (XCUITest screenshot/attachment/keyboard APIs; preference propagation and appear/disappear across `NavigationStack` — the latter two undocumented) | DONE |
| W.10b | The code: `Features/Shell/MobileEdgeGrounds.swift` (new — the declaration, the shell's board and its pure rule, the environment entries, the page modifier, the painted layer); `MobileShellView` (main's `.clipped()` and comment back, `MobileBandClip` gone; the board held; the layer as the band's `.background`; the board and stack set per band page; the root marked, every destination marked not); the ten pages' declarations (Bookcase, Library, Starred · a book's contents, Trash, Archived, Versions · Read · Write · Protection) | DONE (`5daf61efd`) — BUILT GREEN (row W.10f) |
| W.10c | The pins: `MobileScreenEdgeGroundsTests` extended (its three pins unchanged) — a pushed list's grounds; a scrolled Read page's words never under the status bar; the Read page's words stop at the band's foot; the Read page's room at both strips; the board's rule (`MobileEdgeGroundsBoardTests`) | DONE (`9f0dc1229`) — built green (row W.10f); RUN PENDING (the orchestrator's window; the matrix in §6 "W-A1 redone") — **SINCE RUN:** row W.11 (1) green, (3)–(4) red where the matrix means it |
| W.10d | The keyboard reveal's committed UI test, `VariorumMobileUITests/MobileKeyboardRevealUITests` (the orchestrator's added piece): a long lesson tapped below the keyboard bar's top, the software keyboard proven up, one letter typed, the screen read above the bar for it; cleanup | DONE (this commit) — the bundle built green (row W.10f); RUN PENDING (the orchestrator's, a dedicated simulator under its claim) — **SINCE RUN:** row W.11 (6) red on the first fix, (7) green on the final tree |
| W.10e | The record: §6 "W-A1 redone" (why, the mechanism, the pins and their matrix, what each page declares, the snapshot recipe, the UI test's run line, the re-captures owed); one line under W-A1, W-E3, W-E4, W-F1 in `vm-47-walk.md` §6 | DONE (this commit) — §6's block sits before "Closeout"; §5 untouched (the orchestrator's call once the captures are in) |
| W.10f | After "QUIET over": the phone `build-for-testing` and the UI-test bundle's (`TK2SpikeUITests`) into `DerivedData/vm47-fix`, incremental, one at a time (no `Shared/` file changes, so no Mac build) | DONE (after QUIET's end, 23:39) — the phone `build-for-testing` at `9f0dc1229` + the UI test `** TEST BUILD SUCCEEDED **`; the `TK2SpikeUITests` bundle `** TEST BUILD SUCCEEDED **`; no warning in any file this redo touched |
| W.11 | THE POST-MERGE WINDOW on the final tree (code `d78853d8e`: both merges of main in, W-A1 redone) — run by the ORCHESTRATOR under its stage claim, 00:17–01:06 on 2026-11-20 (released 01:06:25), `test-without-building` from `DerivedData/vm47-fix` and the three snapshots; logs in its session scratchpad | DONE — every leg as the matrices say. **(1) the phone, 98 types:** "Test run with 581 tests in 98 suites passed after 555.170 seconds with 6 known issues" (P-47-7's four filter-row marks and `MobileTrashTests`' standing two); VM-64's four paging tests green by name (`theTwoHundredAndFirstNoteIsReachableByScrolling`, `theBooklessDoorListsEveryLooseNote`, `aNoteMintedWhileTheLibraryIsAwayIsListedWhenSheReturns`, `aWingSwitchedWhileTheLibraryIsAwayIsHonouredOnTheReturn`), the redo's edge pins, the hidden-page keyboard pin, the join pin, the six rule suites with R3-n1's narrowed rule and 7b.7's widened walk. **(2) VM-64's speed suite ALONE** (`TEST_RUNNER_VM66_PERF=1`): "Test run with 13 tests in 1 suite passed after 130.084 seconds". **(3) snapshot A — the first fix** (`b1e345be0` with the redo reversed): 7 tests, 5 issues — RED: `aScrolledPagesWordsStayOutOfTheStatusBar` (both cases), `aPagesWordsStopAtTheBandsFoot` (both), `onTheReadPageItsOwnRoomFillsBothStrips` in DARK only (in light the cream page that ran to the edge is within the pin's tolerance of Read's own room, so the light case passes there — the matrix's "red ×2" was one too many); GREEN: the root, note and pushed-list ground pins and the sideways guard. **(4) snapshot B — main's band** (the redo with its painted layer removed): 14 tests, 60 issues — RED: the root, note, pushed-list and Read ground pins (both cases each); GREEN: the two no-content pins, the guard, the board's seven. **(5) snapshot C — the raw-merge Unarchive row:** the join pin RED in both voices ("the Unarchive row answers 22.0 pt tall, under the menu row's 44.0"). **(6) the keyboard-reveal UI test on the first fix** (snapshot A's app, the walk device): FAILED as meant — the tap at (201, 583), the keyboard bar's top at 486.7, the letter typed by the keyboard's key, "typed S0→S1 no pixel differs"; the lesson restored. **(7) the same UI test on the final tree:** PASSED — "typed S0→S1 2640 px differ, x 213.3…296.3, y 463.3…483.3": the typed letter and its line are above the bar; the editor's frame after the tap ends at the bar's top (160.7 tall from 326.3) where on the first fix it ran 52 pt under it. **(8) the Mac, 21 types:** "Test run with 118 tests in 21 suites passed after 38.345 seconds" — `DeadVocabularyTests` 4, `BadgeFamilySplitTests` 6 (the path red of the earlier window, fixed), `MarkdownPaletteWritersTests` 3, the three VM-55 pin types. **(9) the final-tree captures** (`walk_part_d`, the kept device, into the gitignored `notes/plans/vm-47-screens/final-tree/`): **119 of 119**, no miss — the caret step in both voices (the green side of the 23:43 settling capture: in Study light the note scrolls, the typed letter and the caret stand on the line just above the keyboard bar, nothing of her prose shows behind the keyboard — read by the orchestrator at once), Settings' flows with VM-64's Timing door, the core in three combinations, the wider pass with `r05b` under "Gathering", the bar's roads (the Undo pressed 2.0 s after the removal). READ since by two fresh readers: §4g (`515baf202`) and its findings (`4d6d2b9f0`), §4h (`3f6ebf8de`) and its findings (`8de6debd2`) — every fix shows, the keyboard reveal is main's again, no regression, no new finding. The standing device's test-host container lists `Variorum-dev` only; the walk device's lists `Variorum-dev` and `Timing` (VM-64's readout's own folder, written by the final tree's app); the device is shut down and KEPT; no Problem Reporter, no new crash report; the three snapshot worktrees removed after this row |
| — | The midway cold review, after batch 2 (her word; Fable, fresh) | CLOSED (the fix pass's window ran 08:35–08:39, rows M.5–M.6) — FINDINGS IN — 0 BLOCKER · 1 MAJOR · 2 MINOR · 2 NIT, verbatim in `notes/plans/vm-47-ladder-midway.md` §1, with a clean bill. The MAJOR: `PhoneType.uiFont` has no 13 pt floor. NEXT: the implementer's agree/dispute → the reviewer's final call → the implementer applies (red-on-old pin) → a short stage re-run; the ladder's round 1 re-checks — each step since DONE (rows M.1–M.6), and round 1 found the fix pass APPLIED AS CONFIRMED (`vm-47-ladder-round1.md` §1). The `MobilePhoneControlsTests` re-run ran green at 06:56 (13 tests in 1 suite, both fixed tests green by name); the walk (row 2.8e) was then still queued — since SUPERSEDED (row 2.9; the run's one walk, §3) |
| M.1 | The implementer's answers (all five AGREE) and the reviewer's final calls (all five CONFIRMED; M-1 with its two precisions) — `vm-47-ladder-midway.md` §2, §2a, §2b | DONE (`347869d52`, `594052b88`) |
| M.2 | M-1: the 13 pt floor in `PhoneType.uiFont` (`#if os(iOS)` arm, BOTH scaling classes: a resolved font under `floorSize` returns `baseUIFont(…, pointSize: floorSize)`); its pin, the UIKit twin of `nothingIsEverBelowThirteenPoints` in `MobilePhoneTypeTests` (every role × both voices × all twelve settings) | DONE (this commit) — `uiFont` = the class's scaled font (`scaledUIFont`, unchanged) then the floor; the pin `theUIKitFormIsNeverBelowThirteenPointsEither()`; build M.4, red-on-old M.5, run M.6 — each since DONE (rows M.4–M.6) |
| M.3 | m-1 + m-2 comments (`MobileEditorStyle.baseParagraphStyle`, `PhoneSegmentedChoice`'s contract); the two VM-137 lines in batch 1's "Recorded and left" (`Face.body` at xSmall in Terminal; the launch-cached paragraph scale) | DONE (this commit) — comments only (no code, no rendered word); the two lines under batch 1's "Recorded and left" |
| M.4 | Both schemes `build-for-testing` into `DerivedData/vm47-b2` (`vm47-walk` untouched) | DONE — phone and Mac both `** TEST BUILD SUCCEEDED **` at `514fa1ef6` |
| M.5 | M-1's red-on-old, in a SNAPSHOT (this worktree never reverted): a detached `~/dev/variorum-vm-47-rol` at the fix commit, `App/Variorum/Shared/Theme/PhoneType.swift` ALONE checked out from the commit before the fix (the pin's test file stays the fixed tree's), phone `build-for-testing` into its own `App/Variorum/DerivedData/vm47-rol`; the orchestrator runs `MobilePhoneTypeTests` from it — the new pin expected RED; the snapshot removed after | DONE — **PROVEN red on old** (08:35–08:39): "Test run with 10 tests in 1 suite failed after 0.069 seconds with 20 issues" — `theUIKitFormIsNeverBelowThirteenPointsEither()` all 20 (`MobilePhoneLayerTests.swift:115`), the other nine passed; the snapshot removed by the orchestrator (`vm-47-ladder-midway.md` §3) |
| M.6 | The window (the orchestrator's): (a) the snapshot run; (b) `rerun=(MobilePhoneTypeTests MobilePhoneControlsTests MobileTakesBrowserTests MobileTakesBrowserSurfaceTests MobileBlockHistoryTests MobileCommentDraftTests)` + the seven Mac theme types from `vm47-b2`; results recorded in §2's "What changed" | DONE (08:35–08:39) — (a) red on old (row M.5); (b) "Test run with 75 tests in 6 suites passed after 20.379 seconds", the pin green; (c) Mac, six theme types (minus `NoLiteralColourTests`, a source scan run while batch 3 edited): "Test run with 40 tests in 6 suites passed after 2.925 seconds". **The fix pass is CLOSED**; ladder round 1 re-checks it (`vm-47-ladder-midway.md` §3). `DerivedData/vm47-b2` deleted |
| — | The ladder (Fable, fresh reviewer per round; up to five rounds while a round finds a MAJOR — her word) | ROUND 1 FINDINGS IN — 0 BLOCKER · 0 MAJOR · 1 MINOR · 4 NIT, verbatim in `notes/plans/vm-47-ladder-round1.md`; dispositions DONE (the implementer's answers in its §2/§2a, `fbcbf9774`: four AGREE, one DISPUTE; the reviewer's final calls in its §2b, `ac6dd3907`, and §2's table: the MINOR and three NITs CONFIRMED, one NIT DISMISSED — no MAJOR, so no round is earned by her rule; the fix pass is row R1.1). A round 2 (fresh reviewer) will read what enters after round 1 — VM-55's merge re-landed, the walk's fixes and round 1's — before the run closes — **SINCE:** rounds 2, 3 and 4 taken for new ground and CLOSED (rows R2, R3, R4), no MAJOR in any round |
| R1.1 | R1 fix pass: the two doc-comment sentences (R1-m1 on `MobileShellRouter.bindTheme`, R1-n1 on `MobileRootMenu.items(settings:)`) — comments only, the words §2a gives and §2b confirmed; one commit; an incremental phone `build-for-testing` into `DerivedData/vm47-b5` as the compile check (no test run, no stage) | DONE (`dc55d1a3b`) — the two sentences word for word as §2a gives them (10 comment lines in, 1 out; no code line); `vm-47-ladder-round1.md` §2's "What changed" column carries the hash; the compile check is row R1.5's build |
| R1.2 | The record's stale slots brought into line (implementer: Opus, the fix pass, 2026-11-19): every PENDING / NOT-STARTED / IN-PROGRESS / READY / expect-RED slot that a run since answers flipped to its result with its source row (§3's batch-2 carry-in, §4 rows 1–5 and their pieces, the midway and ladder rows, §6 batches 1–5); what has not run left PENDING — batch 5's short piece (row 5.7), the whole phone and whole Mac targets for batches 4 and 5 (after VM-55's re-land), the run's one walk; then §5's rows checked against what was built (R-47-1, R-47-2, P-47-7, P-47-9, P-47-16 brought into line) | DONE (`4aa15eb3a`; §5 `51880a178`) |
| R1.3 | Piece A — the VM-27 pin's harness (test-only): the sync chain the pin composes reads `\.database` through the ambient dependency, which a TEST bootstrap never installs, so the round's read fell through to the live default (row 5.7 (a)/(b)); bind the library's own database around the chain, add a guard that the round counted THIS library's outbox; what the unscoped round did and did not do, in §6 | DONE (this commit) — the trace and the three answers in §6 "Batch 5 — results" ("The pin's unscoped round"); the harness: the chain inside `$0.database = session.database`, the outer scope's in-memory fence, the outbox-count guard (a planted note); test-only, no production line; phone `build-for-testing` into `vm47-b5` GREEN (`** TEST BUILD SUCCEEDED **`); the run PENDING the stage (the READY lines) — **SINCE RUN:** row R1.5 (green on the fix, red on the snapshot) |
| R1.4 | Piece C — small text items: the two known-issue strings in `MobileFilterRowGeometryTests.swift` name VM-93; `vm-47-walk-b3.md`'s Mac leg and navigation fix marked; row 5.2's stray pipe characters escaped; §5 in id order; batch 4's optional red-on-old marked NOT RUN — dropped | DONE (this commit) — the two strings at `MobileFilterRowGeometryTests.swift:347, :553` say "VM-93 (the Library's rooms) owns it" (strings only: no assertion changed; the two comments above them, :318 and :550, still name VM-50 — left, strings only as briefed); `vm-47-walk-b3.md`: the Mac leg RUN (row 3.12's figures), the navigation fix APPLIED (`8eb727f2e`) and VERIFIED (row 5.7 (a)); row 5.2's three pipes escaped; §5 in id order (P-47-14 moved above P-47-15, its text unchanged); batch 4's optional red-on-old NOT RUN — dropped (rows 4.5, §6 batch 4) |
| R1.5 | Piece D — the phone `build-for-testing` into `vm47-b5`; the snapshot `~/dev/variorum-vm-47-rol5` REMOVED and RE-MADE detached at this branch's new head with ONLY the VM-27 fix's one line reverted in `MobileSettingsView.swift` (Settings hands the sync row its Protection door again — the line `9c9aa4b6c` changed), staged there only, never committed, built into its own `App/Variorum/DerivedData/vm47-rol5`; its diff read to be exactly that one line. THIS worktree carries no revert at any point | DONE — the phone `build-for-testing` into `vm47-b5` at `0f167176f` GREEN (`** TEST BUILD SUCCEEDED **`; pieces A–C compiled). The snapshot `~/dev/variorum-vm-47-rol5` REMOVED and RE-MADE detached at `4a78a2515` (this branch's code; the commits after it are records only), ONLY `MobileSettingsView.swift:251` reverted there — `.environment(\.protectionPaneDoor, nil)` → `.environment(\.protectionPaneDoor, protectionDoor.map { open in ProtectionPaneDoor { open() } })` — staged, never committed; its staged diff READ: one line out, one line in, that line alone; its build products carried over from the old snapshot (moved aside and back to the same path), and its phone `build-for-testing` into its own `App/Variorum/DerivedData/vm47-rol5` GREEN, compiling its own reverted `MobileSettingsView.swift` and the corrected pin. THIS worktree clean throughout. The two runs PENDING the stage (the READY lines: `MobileSettingsProtectionDoorTests` from `vm47-b5`, expected GREEN in both cases; the same type from the snapshot, expected RED with two "Protection…" elements in both cases and no host stop); **RUN (the orchestrator, 13:32–13:35, the standing device): GREEN on `vm47-b5` at `0f167176f` — "Test run with 1 test in 1 suite passed after 2.801 seconds", no dependency issue, one host launch; RED on the snapshot — "…failed after 2.850 seconds with 2 issues", both cases at `MobileSettingsProtectionDoorTests.swift:139` (`doors.count == 1`), no host crash — VM-27 PROVEN; the snapshot removed; the stray store from row 5.7 removed from the standing device's test-host container at the coordinator's word; `DerivedData/vm47-b5` deleted (nothing reads it)** |
| R2 | Ladder round 2 (a fresh Fable reviewer, `notes/REVIEW_PROMPT.md` verbatim; the whole run's diff after the VM-55 re-land, the R1 fix pass and R-47-3; read-only under the QUIET window) | FINDINGS IN — `notes/plans/vm-47-ladder-round2.md`: 0 BLOCKER · 0 MAJOR · 0 MINOR · 2 NIT (`84f16a5c2`); the implementer's answers written (its §2a and the table's implementer column, `f1dfb26f8`: R2-n1 AGREE, hollow, nothing changed; R2-n2 AGREE, no action, the mechanism corrected); the reviewer's final calls IN (its §2b, `0113676bb`: R2-n1 CONFIRMED hollow — no code, no pin, the coverage correction adopted, a zero-code walk-reader rider; R2-n2 AMENDED on the mechanism, the one doc-comment sentence taken); the confirmed pass APPLIED — the sentence on the face pin's doc comment (`075bd384e`), the rider in `notes/plans/vm-47-walk.md` §2 and the Check cells of c5, s08, s14 and b6 (`f5b3de184`), and §2's table filled (this commit). **ROUND 2 CLOSED** — no MAJOR, so no further round is earned by her rule; the comment's compile rides the next build; the round file's owed-evidence list (its §1) stands and gates the closeout — **SINCE ANSWERED** but the merge gate: the walk and its reads (rows W.3–W.6, W.9, W.11 (9)), the windows (rows 7.7, W.11) |
| R3 | Ladder round 3 (a fresh Fable reviewer, `notes/REVIEW_PROMPT.md` verbatim; the whole run's diff after the walk's fixes and the re-land of main, on the tree at `ce9a1e099`; read-only) | FINDINGS IN — `notes/plans/vm-47-ladder-round3.md`: 0 BLOCKER · 0 MAJOR · 1 MINOR · 2 NIT (`be385dbae`); the implementer's answers written (its §2a and the table's implementer column, `2d2a6d66f`: R3-m1 AGREE — the walk's questions checked id by id; R3-n1 AGREE on the breadth with one correction (comments are blanked before the match; identifiers and string literals exempt), the narrowest match `prompt:` or `\.phoneFieldPrompt` at both rules, the test NOT changed pending the call; R3-n2 AGREE, no action); §5's rows landed for R3-m1 (`16f9664b0`: P-47-27 extended with W-A2's measurements; P-47-31 … P-47-41 new — W-A5, W-A6, W-A7, W-A8, W-B2, W-C1, W-C5, W-C6, W-C8, W-D3 and batch 2 piece 3's warning orange; the Account sheet's first sight under "Held for her hands"); the reviewer's final calls IN (its §2b, `4c0f9761e`: R3-m1 CONFIRMED and DISCHARGED by the landed rows, nothing further; R3-n1 AMENDED on the mechanism, CONFIRMED on the breadth, the narrowing TAKEN at both rules; R3-n2 CONFIRMED, no action and no ignore line); the confirmed pass APPLIED — R3-n1 test-only (`1306a9f07`: `prompt:` or `\.phoneFieldPrompt`, case-sensitive, at both rules, the two comments updated; a verbatim port of both rules over this tree counts 0 offenders for each with the old match and with the new, the same four placeholder lines exempt — `Shared/AuthViews.swift:469`, `:486`, `Shared/Theme/PhoneControls.swift:310`, `:337`), the phone `build-for-testing` into `DerivedData/vm47-fix` incremental (only that test file compiled) `** TEST BUILD SUCCEEDED **`, and §2's table filled (this commit). **ROUND 3 CLOSED** — no MAJOR, so no further round is earned by her rule; the narrowed rule's re-run rides the next stage window (with `MobileFaintOnDoorsSourceTests`' owed re-run); at the closeout's ticket pass the two "noted" look items go to their owning tickets (Book Details' detail lines beside their labels → VM-218; the system toolbar's "Details · Read" in the system's label colour → the pushed screens' top-edge owner under P-47-20, VM-122 for a book's contents and Read); the round file's owed-evidence list (its §1) stands and gates the closeout — **SINCE ANSWERED** but the merge gate: the narrowed rule and `MobileFaintOnDoorsSourceTests` green in the post-merge window (row W.11 (1)), the re-capture and the final-tree captures read (rows W.9, W.11 (9)); the two noted items commented on VM-218 and VM-122 at the ticket pass (§6 "Closeout") |
| R4 | Ladder round 4 (a fresh Fable reviewer, `notes/REVIEW_PROMPT.md` verbatim; the whole run's diff on the final tree at `d9235c09c`, code tip `d78853d8e`; read-only; taken for new ground — the W-A1 redo and batch 7b — and the narrow read of batch 7b that round 3's §3 left owed) | FINDINGS IN — `notes/plans/vm-47-ladder-round4.md`: 0 BLOCKER · 0 MAJOR · 0 MINOR · 1 NIT (`d5da04616`) — R4-n1, the record's STATUS banner stale; the redo and the second merge of main read in depth and found sound; the implementer's answer (its §2a, `8dbea836b`: AGREE — stale in five clauses, not one) with the fix, the banner rewritten; the reviewer's final call IN (its §2b, `935c34196`: CONFIRMED, the five-clause amendment adopted, DISCHARGED by the rewritten banner; one residual of the same class named — row W.11's "READ … PENDING" — flipped at the final record pass). **ROUND 4 CLOSED** — no MAJOR, so no further round is earned by her rule; its owed evidence is now the merge gate alone |
| — | Closeout | IN-PROGRESS — the documents written (§6 "Closeout"; `notes/plans/vm-47-closeout-drafts.md`; `notes/handoffs/vm-47-handoff.md`) and brought to the truth at the final record pass (implementer: Opus, 2026-11-20 — no code, no build, no run), with this run's canon lines applied on the branch (`notes/SurfaceContracts.md`, `notes/MobileSoul.md` PL-80 — `71cae0706`; `Tools/canon-size` 143606 total, headroom 6394, in the handoff `9a9f935e5`). LEFT: the merge gate (the whole phone target with VM-64's speed suite as its own leg, the whole Mac target), the PR and its merge, the ledgers on main from the drafts, the cleanup (the walk's captures HELD until her sitting), the wave-1 phone build's preparation |
| G.1 | The merge gate's one red beyond main's baseline — `MobileBoxOpenTimingTests.anOpenThatFilesIsStillTimed` (VM-64's guard) in the whole phone target (1193 tests, 209 suites), at `:98` and `:101`; green alone 3 of 3 and beside `MobileBorderTraitTests` 8 of 8: trace it by reading, a deterministic pin red on the tree as it is, the narrowest test-only fix (implementer: Opus, 2026-11-20; nothing built or run by the implementer) | PREPARED — the window owed. Traced (§6 "The gate's one red"): a frame-later paint mark that an earlier test's editor scheduled — a one-shot display link nothing cancels at a test's end — fired inside the guard's wait for the filing and closed the Open's span on the wrong paint. The pin `aPaintMarkAnEarlierRenderLeftCannotEndTheOpen` (`07190ee14`, red by design) and the fix, `freshSpans` draining every pending mark before a span (`bb0e2285d`); test-only, one file. OWED: the suite at `07190ee14` (expect the pin alone red, at its two named expectations), the suite at `bb0e2285d` (expect green), the borders suite beside it, then the whole phone target |

Each batch's implementer adds its own piece rows under its batch line as it starts.

## 5. PROVISIONAL calls and the list for her sitting

| Id | Call | Options | Built | State |
|---|---|---|---|---|
| P-47-1 | The sizing sheet's numbers (type roles, spacing, radii, row heights, the two inks) | as drawn · her own numbers | as drawn | PROVISIONAL — she has seen the sheet in use, not ruled it number by number |
| R-47-1 (was P-47-2) | Grounds: her prose never sits on the tint — notes and lists on the paper, bars and sheets on the room | the Mac's rule as the sheet draws it · every screen on the room, as built today | BUILT (batch 3): her words on the paper at the screens' background lines, bars and sheets on the room (3.4, `af487bfe7` — §6 "Batch 3 — results", the grounds table), and the note in Write on the paper (piece 3.10, `4cca58a8e`; P-47-16, P-47-17) | **RULED 2026-11-19** — "grounds - prose should not be on the tint, which is what I understood you mean. that sounds good." |
| R-47-2 (was P-47-3) | A voice row on the phone that writes the library's voice | no row · a row writing the synced voice | BUILT (batch 3): the two Settings voice rows write the library's voice through `ThemeStore.setVoice` → `Operations.setThemeVoice`, the Mac Settings' own write (3.3, `987e9edc5`); batch 5 made them one segmented choice, words kept (5.2, `70368f6dc`) | **RULED 2026-11-19** — "voice only row - yeah, that's fine." |
| P-47-4 | Terminal's "prose roles two points under Study's" — which roles, and the line pitch | (a) every prose-family role (body, note title, screen title, row title, row preview), size AND pitch two under: 15/25 · 22/28 · 18/23 · 15/20 · 13/18 · (b) sizes two under, pitches kept proportional (15/24 · 22/28 · 18/23 · 15/19 · 13/17) · (c) only the three roles the brief names two under, rows at Study's sizes | (a) — one rule, and a Terminal line keeps Study's leading; row preview lands on the meta pitch (13/18) | PROVISIONAL (batch 1) |
| P-47-5 | The dark `faint` | (a) the every-palette floor the brief states — Study #766F5F, Terminal #6B7168 · (b) the sheet's #736C5D as drawn (computed over the sea-glass family only; 2.91:1 on teal & rust's dark card) | (a); the rule reproduces the sheet's light inks exactly (#6A6359, #8B7F6A) and leaves dark `muted` unchanged in both voices | PROVISIONAL (batch 1) |
| P-47-6 | The quick-entry hint at the note-body size (42 characters; Terminal 380 pt at 15 pt mono against a 338 pt box) | (a) the longest of the hint's own cuts that fits — the hint, "new note — just start typing", "new note" (no new words) · (b) let it wrap (breaks her one-line-at-rest ruling) · (c) new shorter words — the sheet draws "New note", but no wording-list draft exists, so that waits for her wording pass | (a) | PROVISIONAL (batch 1); the capture box's rebuild (SW-3/SW-4, umbrella 5) may replace it |
| P-47-7 | The Library/Archive filter row's five words | (a) `meta` 13, the floor: one unshrunk row at 375 and 402 pt in both voices and 320 pt in Study; Terminal at 320 pt (Display Zoom) cannot hold five 13 pt mono words + the glyph + the 20 pt gutters, so the last words truncate (no word below 13 pt) · (b) `chip` 15, the sheet's named role for filters: shrinks at 375 Terminal and 320 Study, overflows Terminal 320 · (c) scroll or wrap the row — against her #92(b) | (a); the Terminal-320 gap is a named `withKnownIssue` in two pins, owned by VM-50 (batch 2's segmented choice replaces the row) — at batch 1; batch 2 kept the row as words (P-47-10), so the known issue stays and is re-owned to VM-93 (§6 "Batch 2 — results", "Not done" (4)) | PROVISIONAL (batch 1) |
| P-47-8 | Role judgment calls (the brief's "the smaller of the two candidates") | listed per family in §6 "Batch 1 — results", the role-map table; batch 6 adds VM-55's faces: the wing door's title `meta` (a root path line), the wing list's row name `control` over `rowTitle` (the same 17 — a menu row's label, sheet §E) and its ✓ `meta` (a picker's ✓), the one line's words `controlInline` 15 (the sheet's receipt line) over batch 1's `meta` for receipt lines; batch 7b adds VM-64's timing readout (`MobileTimingView`), in its sibling's shape (the edit trace, `MobileEditTraceView`): the readout's text `meta` 13 over `mono` 17 (`mono` is the twelve words' role, her words' class; the edit trace's diagnostic lines already read `meta` — in Study that face is SF Pro, not monospaced, and the report never aligns columns: two lines per entry, a two-space indent), its three acts the inline act at `control`, its header the shared sheet header | the smaller candidate each time (batch 6: the sheet's own receipt-line number where it names one; batch 7b: the sibling sheet's roles) | PROVISIONAL (batch 1; batch 6's and 7b's rows added) |
| P-47-9 | The Bookcase path line's doors, so the line holds ONE line at 402 pt in both voices (Terminal needed ≈437 pt with two 17 pt word doors) | (a) 🗑 an icon button, + New Note an inline act (15, its word kept), Settings an icon button (a gear, "Settings" its spoken label) — ≈390 pt in Terminal at 402 · (b) all three icons (fits 375 too; loses the + New Note word, a ruled P33 door) · (c) words at 15 and the path text truncating (keeps every door word; cuts her count at 402) | (a); at 375 pt Terminal the path text, the line's one flexible member, truncates rather than wrap | PROVISIONAL (batch 2); Settings LEFT the line in batch 5 — the gear retired into the roots' ⋯ menu (VM-53, `e622cbbb9`; P-47-22) |
| P-47-10 | The Library/Archive filter row (her #92(b): one visible row, no scroll, the sort shrinks to a glyph) | (a) keep the five word doors and the sort glyph, each 44 pt TALL, widths their words' · (b) the system segmented control — wider per word (segment padding, and the system truncates a word it cannot fit — the lookup's fact), so Terminal no longer fits at 375 pt and her #92(b) breaks · (c) filter chips in a row that scrolls (the library mockup's rooms as chips — but scrolling is what #92(b) declined) | (a); the row's rebuild (the rooms as chips, the sort beside the field) is VM-93 / VM-90's, and the Terminal-320 known issue (P-47-7) moves with it | PROVISIONAL (batch 2) |
| P-47-11 | The Trash's seven kinds (All · Notes · Books · Blocks · Takes · Snippet groups · Originals) | (a) filter chips in their scrolling row — the sheet's chip is "filters … one row that scrolls sideways"; the chosen one on the wash in her ink, the others edged in the take line, muted · (b) the segmented choice — seven words cannot share 362 pt without truncating · (c) a Menu — not a door a pin can drive (§15's trap (b)) | (a); the chip gained a `selected` state for it | PROVISIONAL (batch 2) |
| P-47-12 | The masthead (VM-148 rebuilds it): "hit areas on its icons and chips only" | (a) the four tools as the icon button (22 pt glyph in ink, 44 × 44, centres 44 apart — the sheet's §B for exactly T39–T42), the row kept; the chips 44 tall in the same flow, their hit areas reaching 6 into the old 12 pt gaps · (b) the tools' glyphs left at 17 in faint with only a 44 pt frame · (c) the chips as 32 pt capsules (the sheet's chip — VM-148's one sideways row) | (a); the title row now gives its title 54 pt less (four 44 pt tools); the masthead grows by the chips' rows | PROVISIONAL (batch 2) |
| P-47-13 | Sheet headers whose title was a muted path (Settings, Acknowledgments, the edit trace) and Create Book's Cancel | the shared header with the path title kept muted and Cancel in Done's place (semibold) · the header's ink title everywhere · Cancel at regular weight | the first: the words on screen are unchanged | PROVISIONAL (batch 2) |
| P-47-14 | The role of a field's typed text (a tag, a book's name, a search, a passphrase) — the sheet names its two scaling classes (her words: full range; chrome: holds at xxxLarge) and places field text in neither | (a) as built — the `control` role, chrome: it grows to xxxLarge (17 → 23 pt) and holds, so a one-line field stays 44 pt at every size (a 23 pt line + 8 + 8 ≈ 43.4 fits the floor) · (b) her words' class — what she types into a field scales across the whole range like the sheet's "her words", so fields grow past 44 at the accessibility sizes | (a); the control is unchanged (`phoneField`'s `role:` already carries either); the batch-2 field pin first assumed (b) and was corrected to (a)'s arithmetic (`7762aef3b`) | PROVISIONAL (batch 2, the closer) — hers: which class a field's text is |
| P-47-15 | What the phone wears before a library answers — the lobby (no library open: the lock, the words card, the library-missing face) and the shell's first frame before its theme store's first emission | (a) the Mac's storeless placeholder, R1's Terminal in the voice's own colours (`VoiceTokens.fallback` — the Mac's `StoreLockView`) · (b) what a library that has chosen nothing reads — Study under the sea-glass (`unsetStoreVoice`/`unsetStorePalette`, AppSpec §12) · (c) a device cache of the last library's look (a new local key — against "the phone keeps no voice of its own") | (b) — `MobileShellRouter.placeholder`, pinned equal to an empty library's own read; (a) would draw the wrong voice for a frame at every launch and unlock of a Study library (the store's first emission lands a frame after the shell's first render), and the lobby would wear a look no library of hers wears | PROVISIONAL (batch 3) — hers: whether the lobby follows the Mac's Terminal placeholder |
| P-47-16 | The ground under the note in WRITE — R-47-1 ("prose should not be on the tint"), whose test is the paper wherever her words are written; the editor's ground is one line in the fenced `MobileEditorTextView.applyVoiceChrome` | (a) the PAPER — `tokens.surface` as the settings road resolves it (the voice's own paper in light, the palette's hued paper in dark, R51's room staying black): the Mac's editor (`EditorSurfaceChrome.paper`) and the sheet's note body · (b) the voice's OWN room under every palette (the Mac's `ReadingPageTokens.room` precedent, R-13u-10) — never the tint, but not the paper; batch 3's first build · (c) the library's room — the tint under her words, against R-47-1 | (a), by piece 3.10 (the record's authorized exception to rule 7): `Face.paper` (= `surface`, the Mac's name for it), the text view's background reads it (ONE line), the Write screen's ground and masthead `tokens.surface`; the option left is (b) | PROVISIONAL (batch 3, piece 3.10) — the walk's look at the caret, the selection wash, the take tint, a callout's wash and the comment mark on the paper is row 3.14 — SUPERSEDED: it rides the run's one walk (§3), PENDING |
| P-47-17 | Write's masthead ground (her title, the four tools, the chips — one view with one background) — piece 3.10's text says both "the two ground lines batch 3 named follow, so the screen ground and the editor agree" and "the masthead stays chrome, on the room" | (a) the PAPER, one ground with the page and the editor — the Mac's note masthead (`PostDetailView`, `.background(tokens.surface)`) and the sizing sheet's note title (drawn on the paper; R-47-1's test: her words on the paper) · (b) the library's room (chrome on the room) — puts her title on the tint in light · (c) the title on the paper and the tools on the room — needs the masthead's rebuild (VM-148: the title on its own row) | (a) — the Mac's behaviour first, then the sheet (§2 rule 3); (b) is one line (`MobileWriteView`'s masthead `.background`) | PROVISIONAL (batch 3, piece 3.10, the closer) — the orchestrator's read of its own clause, then hers |
| P-47-18 | Where the bar shows beyond her ruling's two words ("Roots and lists, not notes") — the pushed screens that are neither a list nor a note | (a) the three roots and the pushed LISTS only (a book's contents, Trash, Archived, Versions' listing); none on a book's Read page or Versions' reader (her words read full-screen — "not notes" read as "not where her words are the page"), none on Protection (a settings page; while new twelve words are held it gives no way off but her close — `navigationBarBackButtonHidden` — and a tab would be one) · (b) every pushed screen that is not Write (Read, the reader and Protection included) — the literal "not notes" · (c) Protection with the bar except while words are held | (a) — the calmer screens, and the words' hold unbroken. Settings' own pushed screens (the tag manager, Acknowledgments, the edit trace) live inside the Settings SHEET, which covers the bar in every option | PROVISIONAL (batch 4) — hers: whether Read and Protection carry it |
| P-47-19 | A tab tapped from a pushed list — "returns to that root" — and what happens to the stack she leaves | (a) the stack being left returns to ITS root (unanimated, as its page slides away), then the page changes; the current tab from a pushed list pops to its root — so a hidden stack always stands at its root (the band never reveals a pushed screen; VM-55's wing landing relies on the same) · (b) the system tab bar's memory: each stack keeps its place, a tap on the current tab pops to its root — a swipe could then land on a pushed screen where the band is masked, and a note under a list (Versions over its note) stays mounted out of sight | (a), `MobileShellView.tabSelected`; a note under a list closes exactly as Back would close it (its leaving savepoint included) | PROVISIONAL (batch 4) |
| P-47-20 | W-009 — "an empty system bar with a back chevron above the app's own masthead" (inferred from code; not yet seen) | (a) KEEP the system bar on every pushed screen — it is the back door, the edge swipe-back and iOS 26's content swipe-back; every later mockup keeps that row (a book, the Trash, the note: a 48–52 pt top row with the round back button and the screen's own doors, the title below in the app's type), so what is "empty" is the row's trailing side, which each screen's own umbrella fills as its mockup draws it · (b) hide the system bar on the back-only screens and put a back icon button in each screen's own header — six screen files (three being edited tonight by VM-55 and VM-78), and with the bar hidden the edge swipe-back has historically stopped (no source confirms iOS 26 changed it; the content swipe with a hidden bar is unconfirmed — the lookup, §6) · (c) the screen's title in the system bar (`navigationTitle`, inline or `inlineLarge`) and the app's own title line dropped — the system's type, not the voice's, and a per-screen edit | (a) — nothing in this batch changes a pushed screen's top edge; the trace is §6's table with an owner per screen (VM-148 Write · VM-122 a book's contents and Read · VM-100 Trash/Archived · VM-110 Protection · Versions: VM-147's umbrella), and the walk captures every top edge (b4, b6, b7, b9, b14, b15) for her look | PROVISIONAL (batch 4) — W-009 DEFERRED with owners |
| P-47-21 | The bar's drawn numbers (built against the mockup, which is not a pixel contract; with P-47-1) | as built: cells a third × at least 56 (LK-5), growing with the words to ~60 at xxxLarge and holding (the mockup's large frame draws 64); the word at the `tab` role (17, SF Pro / SF Mono, chrome); the chip 8 above and below the word, 16 to each side stepping to 8 then 4 where the cell is narrow (the mockup: 8 × 16, and 8 × 9 in its large frame), radius 12 (the layer's standard — the mockup draws 9; the layer has 6 · 12 · capsule), the wash, the word semibold in her ink; the others regular in the corrected muted (the sheet's "others corrected muted"; the mockup's meta ink); the hairline in the palette's line; the room to the home indicator · the bar stays above the keyboard while the capture box or the Library search is focused, as before — the mockup's "the bar leaves while the keyboard is up" is the capture box's row (VM-73), not built here | as listed | PROVISIONAL (batch 4) — her look at the walk's b1–b5 |
| P-47-22 | The ⋯ menu on a root (VM-53; the home mockup's frame 34, "one menu on all three roots", carrying Settings today) | (a) the system `Menu` — the pull-down the mockup draws, anchored at the ⋯; its rows cannot be driven by the in-process harness (`MobileSurfaceDriver`'s measured header), so the pins hold the door on each root and the items as data and the walk drives the real menu · (b) a sheet of menu rows — the note's ⋯ grammar (`MobileNoteActionsSheet`), drivable in process, but one sheet in front of Settings while Settings is its only row · (c) the ⋯ opening Settings directly until a second item exists — a ⋯ that promises a menu and is a door | (a), `MobileRootMenu.swift`; its glyph in the accent (the gear's tone, whose place it takes), spoken "More" | PROVISIONAL (batch 5) — her look at part B's s5-01/05/06 |
| P-47-23 | Where Protection opens now that Settings opens from every root and from a note (it was pushed on the SHELF's stack because Settings was the shelf's own door — P-VM8-2) | (a) pushed on the VISIBLE stack — where she is; Back returns her there (over a note when she came from one) · (b) the shelf's stack after a tab change — the stack she leaves popped to its root (P-47-19's invariant), so a note she came from closes · (c) pushed INSIDE the Settings sheet, as the lock mockup's S1 draws ("Protection… pushes section D inside this sheet, so Done returns her to where she was") — a navigation stack in the sheet, and the re-key reopen's adoption (F-U1-3) re-homed with it | (a) — `MobileShellView.openProtection` (and the DEBUG pocket-guide door, the same road); the reopen's adoption keeps the shelf's stack (a fresh shell after a reopen) | PROVISIONAL (batch 5) — (c) is the mockup's and the larger change |
| P-47-24 | The appearance row's words (VM-53 — the brief: "the Mac's own words for the same rows") | (a) the Mac's own row (`AppearanceChoiceRow`): "Appearance" · "Follow system" · "Light" · "Dark", and NO line beneath it — her 2026-10-13 General ruling on the Mac ("no explanation beneath") · (b) the wording list's drafts (lock-and-protection S1, first-run E1): "System" for the first segment, and "Light or dark is for this iPhone only." under the row (with "Voice and palette belong to your library, so they change on every device." under the voice) | (a); a phone pin holds the three words to the Mac row's source (`MobileSettingsListTests.theAppearanceWordsAreTheMacsOwn`) | PROVISIONAL (batch 5) — her wording pass |
| P-47-25 | The list's names (VM-53): the group names where a row had none, and the voice choice's label | the group names as drafted — "Library" (the sync row, Protection…), "Look" (Voice, Appearance), "Help" (Acknowledgments) — beside today's "Tags" and "Diagnostics"; the voice choice keeps today's word "Voice" (also the draft) where the Mac's ruled word for the same control is "Theme" (her 2026-10-13 General ruling) · or "Theme" for the voice · or today's section words ("Voice", "Sync") as group names | the drafts, and "Voice" | PROVISIONAL (batch 5) — her wording pass |
| P-47-26 | The list's drawn parts and numbers (built against the mockup, which is not a pixel contract; with P-47-1) | as built: a door is the menu row (`PhoneMenuRow`, label 17 in ink, the whole row one target, ≥ 44 — sheet §C's one-line menu row) with no chevron and no trailing value (the mockup draws 52 pt rows with "›" and values like "Castle" and "Study" — values the phone does not hold today); a choice is the label on its own line over the system segmented control (three words and a label do not share a line at 402 pt in Terminal); the sync row's doors are inline acts at 17 in a row under its line (the mockup's single trailing act); the edit trace's on/off is the system switch (it was a text button whose words flipped to "Recording edit trace — tap to stop" — those words retire); no foot line ("Variorum for iPhone" is drafted, not built) | as listed | PROVISIONAL (batch 5) — her look at part B |
| P-47-27 | The roots' path line with VM-55's wing door (batch 6, meeting 1) — in Terminal at 402 pt the words cannot all sit beside the three doors once a wing's name leads (measured with the real fonts: "~/home/shelf  ·  14 books" wants ≈ 438 pt with the 🗑, + New Note and ⋯ and the gutters; "~/home/shelf  ·  1 book" ≈ 422; Study fits "Home · Shelf  ·  14 books" at ≈ 376 and passes 402 only with a long wing name; since R-47-3 the page word is "Bookcase", three characters longer in Terminal, so the tail truncation bites earlier — "~/home/bookcase  ·  14 books" ≈ 463, "~/home/bookcase  ·  1 book" ≈ 446, and Study's "Home · Bookcase  ·  14 books" ≈ 403, at the edge at 402 — measured with the Mac's system fonts, which reproduce the figures above to the point). **The walk saw it (W-A2; captures `*--c1-bookcase-rest` in all eight part A combinations, `*--c3-library-rows` at Terminal AX5, and part B's `seaglass-study-light-default--s05-voice-flipped-bookcase`):** Study at the default size reads "Home · Bookcase  ·  3 books" whole (13.2 pt), ending at 191.3 pt against the 🗑's 44 pt frame at ≈ 212.8 — about 5.5 pt to spare beyond the 16 pt spacer, so a two-digit count (≈ 7–8 pt more at 13 pt) would cut the tail; this store holds 3 books, so the two-digit case was not seen. Study at AX5 (17.6 pt): "Home · Bookcase..." — the whole count gone. Terminal at the default size: "~/home/bookcase  ·…" — the count gone, a lone "·" left before the ellipsis. Terminal at AX5: "~/home/book…" — the page word itself cut, and the Library's line there "~/home/libr…". No "Shelf" anywhere (R-47-3 holds); every target stays on one 48 pt line | (a) ONE 44 pt line, every target 44 × 44 (the wing door's, VM-55's pin; the three doors', this run's), the path text truncating at its TAIL where it cannot fit — P-47-9's rule (it already truncated at 375 pt in Terminal), so the count goes first and the wing's name last · (b) truncate the MIDDLE of the path (keeps the door's name and the count, cuts the page word) — one modifier · (c) let the path wrap to a second line in Terminal (batch 2's fix reversed: the chrome above her books grows by a line) · (d) + New Note as a glyph door, freeing ≈ 50 pt (loses P33's word) | (a) — `MobileWingPath` draws one `meta` line with `lineLimit(1)`; pinned by `MobilePathLineGeometryTests.theBookcaseLineWithItsWingDoorHoldsOneLineAndEveryTarget` (402 and 430, both voices, 14 books: every target 44 × 44, none grows the line, + New Note's word whole) and VM-55's `MobileWingDoorGeometryTests` | PROVISIONAL (batch 6) — hers: which part of the line gives way (the walk captures it — it did: W-A2's measurements, in this row's Call, extended at the ladder's round 3, R3-m1; no fix since changed the line) |
| R-47-3 (was P-47-28) | The Bookcase root's page word (batch 6, meeting 3) — the merged root's path line said "Home · Shelf · N books" (Study) / "~/home/shelf · N books" (Terminal), while its tab says "Bookcase" (LK-5, SW-1): one screen under two names | (a) keep VM-55's words — its wing door changed this line's words (P-55-2: the wing's name leads, the page word kept until wave 2's band), and the brief keeps them where it did · (b) the page word follows the tab: "Home · Bookcase · N books" / "~/home/bookcase · N books" — one word at the Shelf root's `MobileWingPath(page:)` (and VM-55's pins that name the line's letters) · (c) leave the line to wave 2's band (VM-72), which replaces it whole | BUILT (b), R-47-3 (§4 row R-47-3): `MobileShelfView` hands `MobileWingPath` the page "Bookcase" (`50635a674`) — Study "Home · Bookcase  ·  N books", Terminal "~/home/bookcase  ·  N books" (the voice's own path grammar, `VoiceTokens` untouched), the wing's name still the door and its spoken value the line's rest ("Bookcase  ·  N books"); no other screen's words, no identifier or file renamed; the pins that read the line moved with the ruling as the reason and a literal pin added (`864ef813b`); the walk app rebuilt on it; the line is three characters longer in Terminal (P-47-27) | **RULED 2026-11-19** (asked in chat 13:50; answered by the question tool 14:38) — her answer, the option she chose: "Bookcase (Recommended)" — "The top line says Bookcase, matching the tab, your swipe names and the Mac." (the question verbatim in §1) |
| P-47-29 | The masthead chips' inks after W-A9 (the walk's fixes, part A) — the sheet's chip has two inks (§A/§B: a set chip in ink, an empty one in the corrected muted); the masthead's chips are still bare words in a wrapping flow (their capsule is VM-148's) | (a) the four chips whose ink already changed with their state take the sheet's two inks: date, tags and more info set → ink, empty → the corrected muted; the lens empty → the corrected muted (active keeps the accent, a fallback the alarm); the membership chip (the corrected muted for one book, the accent for several) and the blocks chip (the corrected muted, no state) unchanged · (b) the membership chip's one-book state to ink too ("in the pocket guide" is a set fact; one more ink argument) · (c) only the empty chips to the corrected muted, the set ones left muted — then set and empty read the same ink and differ by their words alone | (a); the edit stays on the four ink arguments the finding named (`MobileWriteView` is another branch's file too), and VM-148's rebuild settles every chip's capsule and ink at once | PROVISIONAL (the walk's fixes, part A) — her look at the re-captured c5, which shows (walk §4e E9; the final tree as before, §4g G11): in the seeded lesson only the tags chip is set, so "#pocket guide" alone reads in ink (15.40:1 in Study light; 13.91 Study dark, 12.56 Terminal dark), while the empty date, more info and lens read in the corrected muted (5.93:1; 5.34, 5.46), and the blocks chip and the one-book membership line stay muted by (a)'s design — four of the five chip words and the membership line read one muted |
| P-47-30 | The segmented choice's unchosen words on the system's track (the walk's W-C4: the corrected muted at 15 pt reads 4.44:1 on the track over the room in light, 4.06 / 4.15:1 over the dark paper — under §D's 4.5:1) — the track is iOS's own drawing, and iOS 26 draws it in its new design | (a) as built — the system's track, the words 0.06–0.44 under the floor · (b) the unchosen words in her ink (one attribute per instance; chosen and unchosen then differ by the paper thumb and the weight alone, against the chosen/unchosen ink grammar of the bar and the chips) · (c) a token-coloured track — a hand-built control (`setBackgroundImage` replaces the system's drawing per instance and is reported to break iOS 26's glass selection; `backgroundColor` composites under the control's own grey layer and does not move the contrast reliably) | (a) — nothing changed (the brief: neither a global appearance nor a hand-built control is built without her) | PROVISIONAL (the walk's fixes, batch 2, piece 9) — hers; captures r05, r05b, r07, r07b, k1 |
| P-47-31 | The trash door on every root's path line is a colour emoji (from the walk, W-A5): 🗑 is Apple's colour emoji U+1F5D1 in its own grey-blue metal, 22.7 pt tall at the default size and 28.7 at AX5, beside the accent "+ New Note" and ⋯; the muted tone cannot tint it, where the sheet's §B icon button is a "22 pt glyph in ink". Captures: `*--c1-bookcase-rest`, `*--c3-library-rows`, `*--c4-library-search*` and `*--k0-bookcase-menu-open` in all eight part A combinations; the same beside a rust accent under teal & rust | (a) keep the emoji · (b) a monochrome glyph (an SF Symbol trash) taking the muted tone or ink, its spoken label unchanged | as built: (a) — `MobileRecoveryDoors.trashGlyph` (U+1F5D1) in `PhoneIconButtonStyle(tone: .muted)`, P-47-9 (a)'s "🗑 an icon button"; no later fix changed what the captures show | PROVISIONAL (the walk) — hers |
| P-47-32 | With the quick-entry box focused at AX5, no book is left on screen (from the walk, W-A6): the box fills the region from the path line (110 pt) to ≈ 433 pt, and not one book row, nor "+ New Book", is visible; at the default size the three rows and "+ New Book" stay. Captures: `seaglass-*-ax5--c2-bookcase-box-focused` (4) | (a) as built · (b) cap the floor's line height at xxxLarge, as chrome holds, so books keep at least a row · (c) the floor yields one book row at the accessibility sizes | as built: (a) — R27 (the writing floor outranks the books) as W-024 built it: the six-line floor counts lines of the box's text at the CURRENT size, so at AX5 it takes everything; no later fix changed what the captures show | PROVISIONAL (the walk) — hers |
| P-47-33 | The fields' caret is the system blue (from the walk, W-A7; the sheet names no caret colour): the quick-entry box's and the Library search's caret are iOS's default tint (#0088FF light, #0091FF dark; #7FC3FF mid-blink), while the editor's caret IS the accent (teal & rust's c8: #EBCFC9 = #AE4028 at 25% over white, #76554B = #E08D7B at 50% over the dark paper), its selection handles are the accent (#3B6A59 / #90C1AF, c9), and the run tints the system switch with the accent; under a rust accent the mismatch is starker. Captures: `*--c2-bookcase-box-focused` and `*--c4-library-search` (part A's eight combinations; teal & rust's c2 and c4), `seaglass-study-light-default--s2-seeded-library`, `teal_rust-study-{light,dark}-default--c8-caret`, `*--c9-selection` | (a) tint the fields with the accent (`.tint(tokens.accent)` in `phoneField`, `Shared/Theme/PhoneControls.swift`, and on the box's field) · (b) leave the system blue | as built: (b) — no tint on `phoneField` or on the box's field; no later fix changed the caret (W-A10's fix changed the placeholder's ink only) | PROVISIONAL (the walk) — hers |
| P-47-34 | Terminal's Settings sheet title breaks after "~/" at AX5 (from the walk, W-A8; the header's ink and Cancel's weight are P-47-13's — this is the path title's line at the largest size): "~/" alone on the first line, "settings" (≈ 46 pt mono) on the second, the header ≈ 140 pt tall, "done" 23 pt centred beside it, nothing cut; Study's "Settings" at AX5 (≈ 50 pt) holds one line. Captures: `seaglass-terminal-{light,dark}-ax5--k1-settings-top`, `--k2-settings-swiped-1` and `--k3-settings-swiped-2` (6) | (a) as built · (b) a path-shaped sheet title holds at xxxLarge like chrome · (c) one line with tail truncation | as built: (a) — the sheet puts `screenTitle` in her words' class (no cap), and P-47-13 keeps the path title muted in the shared header; no later fix changed what the captures show | PROVISIONAL (the walk) — hers; beside P-47-13 |
| P-47-35 | On teal & rust's dark paper a callout's blue wash is 1.05:1 — the frame reads by hue alone (from the walk, W-B2): the wash #14202B behind the block on the paper #0C1D1B; the same wash is 1.08:1 on sea-glass's dark paper #0F1A16, was 1.27:1 on the black room the note sat on before R-47-1, and is 1.14:1 on white in light; the frame is found by its blue against the teal and by its 💡, and the text over it stays readable (12.91:1). Captures: `teal_rust-study-dark-default--c7-callout-comment` (and `--c8-caret`, `--c9-selection`, where the callout's top shows) | (a) as built — the Mac's exact washes, quiet by design · (b) the dark washes stepped away from the paper until they clear a floor against every shipped palette's dark paper (the phone inks' rule, applied to the five washes), Mac and phone alike · (c) a hairline edge on a callout frame in dark only | as built: (a) — `MobileCallout.color` is "the Mac palette's exact hexes", voice- and palette-independent (not this run's token); what moved is the ground: this run put her prose on the hued paper (P-47-16), which brought the paper's hue up to the wash. The Mac's editor sits on the same paper, so the Mac should read the same (inferred, not checked); no later fix changed what the captures show | PROVISIONAL (the walk) — hers (under (b) a Mac-and-phone call) |
| P-47-36 | The one message line wraps to two lines: 63 pt, not one 44 pt line (from the walk, W-C1): "Note moved to the Trash — 30 days to put it back." at 15 pt fills 21–308 pt on its first line and wraps "it back." to a second (Terminal's mono wraps "to put it back." the same); with Undo's column (x 315–381) the line runs 721–784 = 63 pt, where the sheet's §E receipt line is "One line, 44 tall, at the foot of the screen". Its place above the bar, its ground, hairline, inks and Undo match. Captures: `seaglass-study-light-default--m1-line-library-root`, `--m2-line-over-trash-bar`, and the same two in `seaglass-terminal-dark-default--` | (a) as built — the line grows by lines (63 pt for this receipt) · (b) one line, tail-truncated (cuts "30 days to put it back.", the promise) · (c) shorter receipt words in her wording pass, so the common receipts fit one 44 pt line at 15 pt with Undo | as built: (a) — `MobileMessageLine.swift`'s words take up to four lines (`.lineLimit(4)`) and grow in height on purpose ("one line of them is the line's 44, and several keep clear of its edges"); P-47-8 put them on `controlInline` 15, the sheet's own number; the words are VM-61's (VM-55), and this run changes no rendered word; no later fix changed the line (W-A1's fix changed only the strip under the bar) | PROVISIONAL (the walk) — hers |
| P-47-37 | The disabled calm button reads 1.65:1 (from the walk, W-C5): Create Book's "Create Book" before a name is drawn as the whole control at 35% — in Study light the fill #EEF5F3 on the room, the edge nearly gone, the word #B0C4BD, 1.65:1; in Terminal dark the word #364942 on its #050908 fill, 2.09:1; at AX5 1.65:1 at ≈ 23 pt. The sheet's §D lists "disabled words" among the corrected faint's uses (3.37–3.93:1): quieter, still readable. Captures: `seaglass-study-light-default--r05-create-book`, `--r05b-create-book-smart`, and the same two in `seaglass-terminal-dark-default--` and `seaglass-study-light-ax5--` | (a) as built — the Mac's 35% dim, one rule for every control · (b) the sheet's ink — a disabled control's word in the corrected faint at full opacity, its shape kept · (c) show the act only when it can act | as built: (a) — `PhoneControlMetrics.opacity` (`Shared/Theme/PhoneControls.swift`, batch 2, the shared pages' precedent: 0.35 when disabled); no later fix changed what the captures show | PROVISIONAL (the walk) — hers |
| P-47-38 | The tag field's hint is cut mid-word at 17 pt (from the walk, W-C6; P-47-6 settled the same case for the quick-entry box's hint): "type a tag — ↩ applies it (“/” nests: life/go…" — the prompt "type a tag — ⏎ applies it (“/” nests: life/goals)" tail-truncated at the field's end (32–362 pt) at the field's 17 pt (P-47-14); Terminal dark cuts it earlier, at "(“/”…"; at AX5 it read whole — the system field shrank its placeholder to ≈ 16.5 pt, below the field's own AX5 size. Captures: `seaglass-study-light-default--r06-tags-sheet`, `seaglass-terminal-dark-default--r06-tags-sheet`, `seaglass-study-light-ax5--r06-tags-sheet` | (a) as built (tail cut) · (b) P-47-6's rule here ("type a tag — ⏎ applies it") · (c) new words in her wording pass | as built: (a) — the words unchanged (`MobileNoteTags.swift`). After these captures, W-A10's fix (`7734f0f05`) built the field's prompt through `TextField(phonePlaceholder:…)` in the corrected faint, so the captured ink is gone; whether the tail cut stands as captured, and whether the AX5 shrink survives the prompt road, is NOT SEEN — the re-capture of r06 (W-A10's list, row W.8) shows it. **Re-captured since** (`recapture/` r06 in Study light and Terminal dark at the default size, walk §4f F19; the final tree's Study light r06 as before, §4h): the tail cut stands as captured, at the same size and place — "type a tag — ↩ applies it (“/” nests: life/go…" (Terminal "…(“/”…") —, only its ink changed (the prompt's corrected faint); the AX5 shrink is still NOT SEEN (no AX5 re-capture of r06) | PROVISIONAL (the walk) — hers; beside P-47-6 |
| P-47-39 | Terminal lowercases her words on some screens and not others (from the walk, W-C8): in Versions' rows the moment's meta reads "4 blocks · “takes are for trying; choosing is deciding. the take with the ✓ ”" where her note says "Takes are for trying; CHOOSING is deciding. The take with the ✓" — her capitals gone in the listing and the reader; Starred's names read "walk note" where the Library says "Walk note"; the Trash's rows keep her capitals ("A note for the message line"), as do the Blocks previews, the take cards, Block History's commit row and the Read page — so her names read two ways inside one voice, screen by screen. Study keeps them everywhere. (The same voice grammar lowercases the app's own sentences on Book Details, Note Actions, the Trash, More Info, Lenses and Create Book, while Protection's keep their capitals — set 1's note, not filed.) Captures: `seaglass-terminal-dark-default--b8-versions-listing-bar`, `--b9-versions-reader-no-bar`, `--r10-versions`, `--r01-starred`, `--r14-trash` | (a) as built — Terminal's chrome casing over the whole line · (b) the chrome pieces lowercased and her quoted words left as written · (c) no excerpt in Terminal's meta | as built: (a), predating the run — `MobileVersions.swift` runs `rowMeta` (which quotes her preview) through `tokens.chromeLabel` at both sites; `MobileStarredView.swift` runs the name through it, as the Mac sidebar's Terminal `rowTitle` does; `MobileTrashView` draws the title without it. No later fix changed what the captures show; the Versions screen's owner is VM-147's umbrella (P-47-20's list) | PROVISIONAL (the walk) — hers |
| P-47-40 | At AX5 Protection's two state lines grow as her words do, beside doors held at ≈ 23 (from the walk, W-D3; P-47-8's role map placed them): "You're in Standard." ≈ 47 pt and "This library doesn't sync." ≈ 43 pt, each wrapping to two lines in Iowan (×2.75 and ×2.9 their default 17 and 15), while on the same page the explainers hold at 17.6 (meta), the doors at ≈ 23 (control), and "Sign in to turn on sync." — the very next line — at 17.6. At the default size the page reads as built (17 · 15 · 13), and Terminal dark's as built. These lines are the app's, not hers. Captures: `seaglass-study-light-ax5--r17-protection`, `--r17b-protection-scrolled` (twins `seaglass-study-light-default--r17-protection`, `--r17b-protection-scrolled`) | (a) as built — at the largest sizes her library's state reads loudest on the page · (b) the app's own state lines and ruled sentences hold at xxxLarge like chrome, their faces and default sizes unchanged (a hold at the sites, `.dynamicTypeSize(...DynamicTypeSize.xxxLarge)`, or a chrome-class twin of the two roles) · (c) the posture line keeps its full range (it names her library's state) and the sync sentence takes `meta` like the line under it | as built: (a) — the posture line on `rowTitle` (`MobileProtectionDoors.swift`) and the ruled sentences on `rowPreview` (`MobileProtectionScreen.swift`'s `line(_:ink:)`), full-range roles, P-47-8's PROVISIONAL judgment; the same rows of the role map cover the lock, library-missing and shared-account pages' sentences (not walked); no later fix changed what the captures show | PROVISIONAL (the walk) — hers; beside P-47-8 |
| P-47-41 | The shared pages' warning words on the phone are the system orange (from the walk's fixes, batch 2, piece 3 — §6): every warning caption a shared page draws on the phone's styled arm (`pageCaptionWarning`, the `meta` 13 role) wears `Color.orange`, about 2.2:1 on the paper in light (the record's figure), under §D's 4.5:1 for words under 17 pt. Where it shows: the sync row's paused states (keys locked, keys replaced, an account mismatch, stalled; in Debug, the prod test road's refusal), the Account sheet's warnings (the short-password refusal, "The two password entries don't match yet.", the delete-account explanation, a subscription note) and the auth-shaped error's guidance; the 15 pt `pageWarning` has no call site today. No capture shows it: the walk's dev store's sync row says "Sync off (dev store)" in the plain caption, and the walk never opens the Account sheet | the options are mine (the record wrote none): (a) as built — the system orange, the seam's recorded choice (no warning token exists; its comment: "honesty outranks palette") · (b) a warning ink in the phone layer, beside the corrected muted and faint, derived to clear §D's floor in every palette and appearance, the Mac's arm unchanged — a new phone token · (c) the alarm — the error's ink, so a paused state would read as an error, which the sync row's own comments keep apart ("never the error red") | as built: (a) — `Shared/Theme/SharedPageStyle.swift` (`pageWarning`, `pageCaptionWarning`), left by piece 3's sweep with its reason; the Mac's arm is `.foregroundStyle(.orange)`; no later fix changed it | PROVISIONAL (the walk's fixes) — hers |
| P-47-42 | In dark a peeked take's tint is a shade DARKER than the paper: 1.03:1 (from the re-capture, W-E2 — the peek was first caught there): the take tint #0D1713 behind the peeked take on the dark paper #0F1A16, a band the eye barely finds; what marks the peek is its 2.3 pt left edge in the take line #254137 (1.60:1); her words over it read 13.91 / 12.56:1. In light #E8F2EE on #FFFFFF, 1.14:1, the edge 1.54:1. **The same cause as P-47-35:** the values are the sizing sheet's own dark pair (`--takeTint:#0D1713`, `--paper:#0F1A16`) and the shared tokens'; what moved is the ground — P-47-16 put her prose on the hued dark paper, where on the black room the note sat on before R-47-1 the same tint read 1.15:1 LIGHTER than its ground. Captures: `seaglass-study-dark-default--c6-note-peek-take-tint` and `seaglass-terminal-dark-default--c6-note-peek-take-tint` (in `recapture/` and `final-tree/`), the fade frame `seaglass-study-light-default--f6-pill-dark` | (a) as built — the sheet's values, the edge as the marker · (b) the dark take tint stepped lighter than the dark paper (the take card's #15261F reads 1.13:1 above it), so a peek reads as a raised band as the take cards do · (c) a heavier edge in dark only | as built: (a) — the take tint and the take line are the shared tokens'; no later fix changed them (the final tree as before, walk §4g G13); whether the Mac's editor shows the same pairing is not seen (inferred from the shared tokens) | PROVISIONAL (the re-capture) — hers; beside P-47-35 (the same cause) |
| P-47-43 | The Read page's last visible line is cut at the band's foot again — the W-A1 redo's first give-back, by design (§6 "W-A1 redone", "What the painted layer cannot do", 2): the cream page is scroll content, so it ends at the band's foot (840.0 pt), exactly as on main — at rest its last line ("its lesson promises, that is a bug in the") shows 12.0 of its 16.3 pt, its descenders gone, and the next line is not drawn; the strip below is the Read page's own room. The first fix had let the page run on to the screen's foot with both lines whole (the re-capture's F7). Any page whose content scrolls to the foot is cut at the band's edge the same way, as on main. Captures: `final-tree/seaglass-study-light-default--b5-book-read-no-bar` (= `--r04-book-read`; walk §4h H3), its first-fix twin in `recapture/`, main's look in `final/` | (a) as built — main's look: the page ends at the safe area's foot, the room below · (b) the first fix's look on the Read page alone — its cream page running on behind the home indicator to the screen's foot; it needs that page's content let past the band's clip at the foot, the road the redo closed, so it would want its own pin beside the keyboard UI test | as built: (a) — main's `.clipped()` on the band (`MobileShellView.body`, restored by `5daf61efd`) and the Read page's declared room at both strips (`MobileEdgeGrounds`); pinned by `MobileScreenEdgeGroundsTests.aPagesWordsStopAtTheBandsFoot` and `onTheReadPageItsOwnRoomFillsBothStrips` | PROVISIONAL (the W-A1 redo) — hers |
| P-47-44 | The painted edge strips are one colour across the width and switch at once in a push or a pop — the W-A1 redo's second give-back, by design (§6 "W-A1 redone", "What the painted layer cannot do", 1): during a push or pop between pages whose grounds differ (a root's room and a list's or a note's paper) a strip takes the arriving page's ground at its first appearance (a push), or the root's as the path empties (a pop to the root), and does not slide with the pages — for the slide's ≈ 0.35 s the part of a strip above the outgoing page wears the incoming page's ground; never the window's white or black, a band neighbour's, or a page that has left. The first fix had each page's ground slide with it. (A cancelled interactive swipe-back between two pushed screens may leave the lower screen's grounds in the strips while the upper one shows — a strip colour, never content; approximation 3, unpinnable in process.) Captures: none — no capture is caught mid-push, mid-pop or in a cancelled swipe-back (walk §4g, §4h, "What I could not judge"); her look is on the phone | (a) as built — one ground per strip, switched at the push's first appearance or as the pop empties the path · (b) a crossfade between the two grounds over the slide (not built: it would show a third colour neither page wears) · (c) each page's ground sliding with it, as the first fix drew — which needs each page's ground drawn past the band again with its content held inside, a road the redo closed | as built: (a) — `MobileEdgeGroundsBoard.showing` (pure, pinned in `MobileEdgeGroundsBoardTests`) and `MobileEdgeGroundsLayer` (`Features/Shell/MobileEdgeGrounds.swift`, `5daf61efd`) | PROVISIONAL (the W-A1 redo) — hers, best judged on the phone |

W-E3 (her prose behind the keyboard bar) and W-F1 (her prose under the status bar on a scrolled page) need no row: both
came from W-A1's first fix, and the redo removed them (walk §4g G3, §4h H4 and H9). W-E1 (the takes pill over the next
block's first line) is VM-188's, commented there — not a row.

Held for her hands: the wave-1 install on her phone (one install from merged main, after all four runs, prepared by
the last merger — this run; the hands part is hers) — it is where she judges P-47-1's numbers at true size, and where
she first tries **typing in the lower half of a note with the keyboard up**, the road the W-A1 redo protects (the
note scrolls the line she taps above the keyboard bar, and a typed letter shows there); her glance at which Protection
door stayed (VM-27 — the standing row; batch 5's §6); the wording pass over any new line (batch 5's are listed in its
§6, "Every new rendered line"). **Two faces this run restyled have never been seen in any capture or mounted test**, so
her phone is their first sight: the Account sheet's header and seven placeholders (the walk's second fix batch, pieces 5
and 6 — a dev store's sync row has no Account door, and no phone harness mounts the sheet, which needs `AppServices`;
Settings ▸ the sync row ▸ Account, or Protection's sign-in road) and VM-64's timing readout (Settings ▸ Diagnostics ▸
Timing…, put on this run's layer at batch 7b — no capture opens its sheet). **The walk's captures are KEPT until her
sitting** (the orchestrator's call: the standing rule deletes a merged run's walk evidence, and the handoff's questions
point at them); after the merge they sit in the main checkout's gitignored `notes/plans/vm-47-screens/` — `final/`
(the walk), `recapture/` (after the first fixes), `e4-before/` (the keyboard defect on the first fix), `final-tree/`
(the tree that merged) — until she says "delete the screens". The palette row on the phone is filed as VM-247 (the
lock mockup's S1 draws "Palette · Sea-glass ›" in Look; W-005 was wearing the palette, done by VM-51); not built here.

## 6. Results, review and closeout

WRITTEN below — each batch's results (counts, commits) and the touch-target inventory (batch 2); the ladder's
findings and dispositions are `notes/plans/vm-47-ladder-midway.md` and `notes/plans/vm-47-ladder-round1.md`.
PENDING — the walk captures (the run's one walk, §3), the canon deltas, the tickets filed.

### Batch 1 — results (implementer: Opus, 2026-11-19)

**Not done in this batch, first:** (1) the WALK — moved by the orchestrator to batch 2's seam, as one walk
covering batches 1 and 2 on the fixed tree (its driver is built and ready, §6 "Stage window" below) — since
SUPERSEDED unrun (row 2.9), now the run's one walk (§3), PENDING; (2) ~~the
targeted re-run of the two red-fixes and the layer is PENDING its own short stage window~~ — RUN, green (row
1.6c; "The targeted re-run — DONE" below); (3) the filter row
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

**Tests (RUN — the counts are "The stage window" below and §4 rows 1.6c–1.6d).** New: `MobilePhoneTypeTests` (9),
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
     font. The failing test is its red-on-old; its green: the targeted re-run (below) — passed. (The SwiftUI form's
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
     the screen and ≥ 400 pt) is unchanged and green at 45.6%. Its re-run: green, with the others (the targeted re-run, below).
     **A finding the red exposed, owned elsewhere:** the path line grew 23 pt, more than one line's growth.
     Computed: in Terminal its 13 pt mono path ("~/shelf · 14 books", ≈157 pt) beside two 17 pt mono doors
     (≈102 + 82 pt), three 16 pt gaps and the 20 pt gutters needs ≈437 pt — more than 430 and 402 — so the
     path text wraps to a second line (Study, proportional, fits at ≈363 pt). The walk is to confirm it (the
     Terminal core captures c1/c2); its owner is **VM-53 (batch 5)**, whose roots' ⋯ menu takes `Settings` off
     the path line — no narrow batch-1 fix keeps every word on one line without a design choice. *(Since: carried
     into batch 2 at the batch-1 seam (§3) and FIXED there — row 2.4, `47ee432fc`; red on old proven, row 2.8d.)*
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
orchestrator's call; the stage queue is long). **SUPERSEDED since:** that walk was retired unrun at the batch-3
seam, its device and DerivedData removed (row 2.9), and the run's one walk (§3, "One walk for the whole run") now
carries batch 1's captures — PENDING. Ready for it then: the device `vm47-walk` (iPhone 17 Pro, iOS 26.2,
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
  *(Since: carried into batch 2 (§3) and FIXED there — row 2.4, `47ee432fc`; red on old proven, row 2.8d.)*
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

**Not done in this batch, first:** (1) ~~the WALK (both batches' captures, §4 row 2.8e) is PENDING its GO, and
the targeted re-run of the two test-only fixes (`MobilePhoneControlsTests`) is PENDING its window~~ — the walk
SUPERSEDED unrun (row 2.9), now the run's one walk (§3), PENDING; the re-run RAN green at 06:56 (13 tests in 1
suite, row 2.8c) — the suites themselves and the path line's red-on-old are DONE (below); (2) the editor's text inset is NOT changed — it is not
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
stands). The targeted re-run `rerun=(MobilePhoneControlsTests)` RAN at 06:56: "Test run with 13 tests in 1 suite
passed after 17.405 seconds", both fixed tests green by name (§4 row 2.8c; `vm-47-ladder-midway.md`, the note
after §2b). The new and touched suites
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

**Not done in this batch, first:** (1) ~~the note in WRITE is not on the paper~~ — SUPERSEDED at the batch-3 seam by
piece 3.10 (the record's authorized exception: the fenced line reads the face's paper; "Piece 3.10" below), P-47-16
rewritten; (2) ~~the suites, VM-54's red-on-old and the walk
are PENDING the stage window (§4 rows 3.6–3.8)~~ — the suites RUN (row 3.12) and VM-54's red-on-old PROVEN (row
3.13); the walk SUPERSEDED by the run's one walk (§3), PENDING. When written: every build is green (both schemes into `vm47-b3` at `c87407b93`,
the snapshot into `vm47-rol3`, the driver into `vm47-walk3`), after the coordinator's QUIET (another run's merge
gate) held the full builds from mid-batch to 08:33;
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
| Write (pushed) | the editor, the screen and the masthead — piece 3.10 (P-47-16, P-47-17); before it, batch 3 had put all three on the voice's own room | — (the overlays' sheets: the three UIKit overlays' row below) |
| Every SwiftUI sheet (Settings, Create Book, Book Details, Tags, Books, More Info, Blocks, Lenses, Note Actions, the tag manager, Acknowledgments, the edit trace) and Protection | — | unchanged, on the room (the sheet's rule) |
| The three UIKit overlays (takes, comments, block history) | unchanged: the take cards on `card`, the comments and history rows on the overlay's `surface` — her words already on the paper family | the "sheets on the room" half: VM-152 (native sheets) |

Listed and left, with owners: (the note in Write on the paper — DONE by piece 3.10, no longer VM-137's); the Blocks sheet's block previews
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

**Tests (written; RUN — §4 rows 3.12–3.13, "The suites, run" below).** New: `MobileLibraryLookTests` (7 — a fresh library wears Study under
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

**The suites, run** (the orchestrator's windows, from a gate snapshot at `54cbcb9e5`, the merged tree with piece
3.10; §4 rows 3.12–3.13; the trace file `notes/plans/vm-47-walk-b3.md`). *Phone, the whole target:* "Test run with
916 tests in 151 suites failed after 515.539 seconds with 12 issues (including 8 known issues)" — the 8 known the four
pre-existing and P-47-7's four; every batch-3 suite green, piece 3.10's two pins and VM-54's four included; two reds,
neither a product regression: VM-24's caret test (2 of its 3 cases — main's, not this run's) and
`MobileNavigationTests.theTabBarCarriesThreeDoorsAndEachOneMovesTheBand()` (:221, :229 — the test's premise, which
batch 3 changed by design: in Study a root's path line reads its own door's word), fixed test-only in `8eb727f2e`
(buttons only). *Mac, the 102 types below:* "Test run with 511 tests in 102 suites passed after 836.278 seconds with 4
known issues", none failed; 10 suites (24 tests) skipped by their own opt-in gates; the 4 known issues pre-existing.
*VM-54's red-on-old* (the snapshot `~/dev/variorum-vm-47-rol3`): "Test run with 4 tests in 1 suite failed after 0.337
seconds with 5 issues", all four green on the fixed tree. Both snapshots are removed.

**The Mac suites this batch owes** (recomputed by the closer at `4cca58a8e`, on the merged tree — the implementer's
119-type list lived only in its READY report, never in the repo, so it is replaced here rather than trusted unseen).
The rule: every Mac test type whose own body names `ThemeStore`, or calls a global helper whose body does (transitively;
a `private` helper counts only in its own file: `withAdoptedTheme`, and the file-private `mount`/`mountedBoard`,
`mountBar`, `mountBook` (BookNoteBoxDoorsTests' — OwnershipBadgeTests' own `mountBook` builds no store),
`mountCompare`/`mountTakes`, `withMastheadBook`), or uses one of the nine non-suite rigs that build a store
(`DebugOracleWindowRig`, `DoorBoxHost`, `NoteBoxOracleHost`, `OpenListDragHost`, `OpenListOracleHost`,
`SavepointFieldRig`, `SectionWindowHost`, `SidebarFieldHost`, `StarredOracleHost`), plus the seven theme types. **102
types**, each checked by grep to be declared exactly once as a `struct`/`class` in `App/Variorum/VariorumTests/` with
`@Test`s in its body (all Swift Testing suites; no nested suite, no file name standing in for a type). The
difference from 119 is the rule's grain (types, not whole files: the files that name the store hold 148 test types).
```zsh
mac=(BlockHistoryCommitsCaptureTests BlockHistoryHostTests BlockHistoryPaneTests BlocksArrivalMeasureTests
BookCarryLiveBlockTests BookEditHereRiderTests BookFoldDisclosureTests BookIndexCarryAnchorTests
BookIndexCarryBlockTests BookIndexTakesTests BookIndexToOutlineBlockLandingTests BookIndexToOutlineCarryTests
BookLeavingSavepointTests BookMastheadMountedTests BookNoteBoxOpenDoorTests BookOpenDoorMountTests
BookPanelDragGateTests BookPanelOpenNoteMarkTests CanvasArrivalTests ChromeMinHeightTests CommitBarLayoutTests
CompareCommentGutterTests CompareLensesAlignmentTests CompareToggleIdentityTests CurrentBlockContinuityTests
DebugOracleSingletonWindowTests DebugOracleTwoWindowTests IndexClickCaretTests IndexTierMetricsTests
InlineEditorWidthReflowTests LandingOffsetTests LibraryControlsGeometryTests LibraryListFaceRigTests
LibraryListFaceTests LibraryPanelHostTests LibrarySearchLandingTests MCPAsksWaitCaptureTests
MCPGrantSheetCaptureTests MCPGrantSheetU2CaptureTests MCPPaneTabsCaptureTests MCPPaneTabsTests
MCPShareFacesCaptureTests MastheadLayoutTests MastheadStampTests ModeSwitchCarryTests ModeSwitchFeelTests
NewNoteInBookTests NoteBoxCompositionTests NoteBoxGeometryTests NoteOpenLandingTests NoteVersionsPaneTests
OpenListDragMountTests OpenListLayoutMountTests OutlineRoomTests OutsideWriteLivePaneTests PagesArrowKeysHostTests
PostDetailRoutingTests PostRescueFaceTests QuickEntryOpeningScopeTests ReadArrivalMeasureTests ReadLandingTests
ReadModeTests ReadNoteHeightsCalibrationTests ReadNoteLandingTests ReadingFlowEstimateMeasureTests
ReadingFlowLandingTests RestoreLandingRewriteHopTests RestoreLandingTests SavepointCommitDoorTests
SearchEmptyAnswerSentenceTests SideColumnTests SidebarNoteBoxDoorFacesTests SidebarNoteRowMenuTests
SidebarRowLeadsTests SidebarSearchFieldPlaceTests SidebarSectionWindowMountTests SidebarSmokeTests
SnippetsLandingTests StarredScrollMountTests StatusCenterTests SurfaceSizeMemoryTests TakesCommentGutterTests
TakesEntryBandTests TitleQuickfillTests TourClosingCardTests TrayPanelMoveTests TutorialMCPChapterCaptureTests
VX176LibraryTintTests VX343WhatsNewCaptureTests VX347CommitLeavesMountTests VX349ListHeaderRestTests
VX350SearchToggleMountTests VX895SearchFacetHeaderTests VersionDoorsTests WingPaletteDoorsTests ThemeTokenTests
PaletteDerivationTests NoLiteralColourTests SharedPageStyleTests PaletteReachTests MarkdownPaletteWritersTests
HelperWindowThemeTests)
```
The whole Mac target runs at the merge gate.

**For `notes/QUESTIONS.md` at the merge (this branch does not edit it):** #199 — the `ThemeStore` hoist, deferred
2026-08-31, LANDED here (`dc9a5fd05`); #195 MINOR 3 — CLOSED (`987e9edc5`, `90228e98a`): main-actor storage, one app
writer where the library's settings land; the residual (the suites share the process-global look across awaits)
stated above, owned with the editor seam (VM-137). P-47-15 and P-47-16 (§5) are this batch's new PROVISIONAL calls.

**Self-assessment (for the cold reviewer).** The road is the Mac's own, reused: the hoisted store, the settings →
tokens road, the Mac Settings' voice write — the phone adds a landing seam (`onLanded`), a placeholder, and the UIKit
face's adoption. The riskiest calls: (1) ~~**Write is not on the paper**~~ — closed by piece 3.10 (P-47-16 rewritten); (2) **the placeholder** (P-47-15)
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

**Piece 3.10 — the note in Write on the paper (the closer, `4cca58a8e`; the record's authorized exception to rule
7).** The face already carried the paper: `Face.surface`, re-derived under a palette through the same four-parameter
resolver the settings road calls (`applying(palette:tint:)`), so it is `tokens.surface` as the settings road resolves
it in every voice, appearance and palette, `.default` included; the overlays' three sheets
(`MobileTakesBrowserView.swift:299`, `MobileCommentsSheetView.swift:195`, `MobileBlockHistorySheetView.swift:172`)
and the keyboard bar (`MobileKeyboardBar.swift:516`) read it. So the face's new value is a NAME, not a second
truth: `var paper: UIColor { surface }` — the Mac's own `EditorSurfaceChrome.paper` (`EditorTypography.swift:345`,
`NSColor(tokens.surface)`, the Mac editor's scroll-view background, `EditorView.swift:535`). The fenced file
changes by exactly ONE line: `MobileEditorTextView.applyVoiceChrome`'s `backgroundColor = face.room` →
`face.paper` (its doc comment two lines up still says "the room background" — left, since no other line of that
file may change; for VM-137's next touch). A landed look re-runs `applyVoiceChrome` through
`MobileEditorViewModel.applyVoiceChange`, so the ground follows a palette or voice landing on an open note.
`MobileWriteView`: the screen's ground `.background(tokens.surface.ignoresSafeArea())` and the masthead
`.background(tokens.surface)`; the helper `groundUnderHerWords` is gone. The masthead's reading is P-47-17: the
piece's text says the masthead "stays chrome, on the room", but the masthead is ONE view holding her title with the
tools and chips, the Mac's note masthead sits on `tokens.surface` (`PostDetailView`), and the sheet draws the note
title on the paper — so it is on the paper, PROVISIONAL, and (b) is one line. `Face.room` is untouched (the voice's
own room; a palette never replaces it) and is now read by no editor view.
*A brief premise that was not true in the code:* "an overlay still reads the room" — the three overlays' sheets and
the keyboard bar read `face.surface` (the paper), before this piece and after it; nothing but the editor's one line
ever read `face.room`. So the pin holds what the clause protects instead: the face's `room` slot stays the voice's own
under every palette (`theEditorsGroundIsThePaper`'s third expectation, and `adoptionMovesTheFaceOnlyWhenTheLookMoves`),
and the overlays' grounds did not move. "Sheets on the room" for the overlays stays VM-152's (the grounds table).
*Pins:* `MobileLibraryLookTests.theEditorsGroundIsThePaper` (replaces `theEditorsGroundIsNeverThePalettesTint`) — a
real `MobileEditorTextView.make()`'s own `backgroundColor`, after each adopted look and `applyVoiceChrome()`, over
Study and Terminal × sea-glass and teal & rust × light and dark: equal to `tokens.surface` on the settings road, never
`tokens.room`, the face's room still the voice's own (red on old by construction: the old line drew the voice's room,
Study light `#FAF8F3` against the paper `#FFFFFF`); `MobileLookSourceTests.theNoteInWriteIsOnThePaper` (the screen,
the masthead and the fenced line on the paper; no room under her words in Write) beside
`theReadPageNeverSitsOnThePalettesRoom` (Read unchanged) — the patterns measured by script: 5 of 7 checks fail on
`76b85bdae`, 0 of 7 now. Counts: RUN (row 3.12) — both pins green; the eye check on the paper (caret, selection
wash, take tint, a callout's wash, the comment mark — light and dark) PENDING the run's one walk (§3; row 3.14
SUPERSEDED).

**The walk — trimmed by the closer to two ~30-minute parts (row 3.14; the instruments are gitignored).**
**SUPERSEDED** by §3's "One walk for the whole run" (row 3.14): the build `vm47-walk3` was removed unrun and no device
was ever made; the driver and runbook stay as a source for the run's one driver (§3). As written then:
`notes/plans/vm-47-screens/instruments/walk3.zsh` (its header is the runbook: `walk_build`, then `WALK_DEADLINE=HH:MM
walk_part_a`, the seam, `WALK_DEADLINE=HH:MM walk_part_b`) and `VM47Walk3Driver.swift`. PART A (67 captures): create
and boot `vm47-walk3`, the seed (3), the core under the sea-glass × Study/Terminal × light/dark × default/AX5 (8 × 6),
and at the default size piece 3.10's paper check (4 × 4: c6 the take tint, c7 a callout's wash and the comment mark,
c8 the caret, c9 the selection wash); the device then SHUT DOWN, its seeded library kept. PART B (115): boot; the core
under teal & rust, Study light and dark, default, with the paper check (2 × 10); the wider pass at sea-glass Study light
default (25 — every screen batches 1 and 2 listed: Starred, a book's contents, Book Details, Read, Create Book and its
segmented choice, Tags, membership, More Info, Blocks and its segment, Lenses, Note Actions, Versions, the Takes,
Block History and Comments overlays, Trash and a filter chip pressed, Archived, Settings, Protection); VM-54's flip once
per voice (2 × 6); the voice row once per voice (2 × 4); the wider pass at sea-glass Terminal dark default (25) and at
sea-glass Study light AX5 (25); `walk_close` (the device deleted). 182 in all. A time guard (`walk_step`) skips a
step that will not fit before the claim's end with three minutes left for the close, and logs it NOT CAPTURED; step
timings land in `b3/logs/timings.txt`. **An instrument defect found and fixed before any run:** the runbook named the
second palette `tealAndRust` (the Swift case), but the Debug walk seam reads `ThemePalette(rawValue:)` — the raw value
is `teal_rust` — and silently writes nothing for an unknown value, so every "other palette" capture would have been
the sea-glass again. The driver rebuilt into `DerivedData/vm47-walk3` at `4cca58a8e` (`** TEST BUILD SUCCEEDED **`;
the bundle carries `test01_seed · test10_core · test20_rest · test25_voice · test30_flip`; the walked app's binary
built after piece 3.10's sources; the copy removed, the tree clean).

**VM-54 — the trace and the verdict (code; the on-screen check rides the run's one walk, §3).**

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
  border must read the colour's dark value. Red-on-old: PROVEN (row 3.13) — "Test run with 4 tests in 1 suite
  failed after 0.337 seconds with 5 issues" in the snapshot, all four green on the fixed tree (row 3.12): **FIXED with
  its pin.** The on-screen check (the flip with a take card, the pill and the comment draft visible): PENDING the run's
  one walk (§3).

### Batch 4 — results (implementer: Opus, 2026-11-19)

**Not done in this batch, first:** (1) **W-009's fix — DEFERRED with owners (P-47-20).** No pushed screen's top edge
changes: keeping the system bar keeps the back door and both swipe-backs, every later mockup keeps that row with the
screen's own doors in it, and the fix that removes it (hide the bar, a back door in each screen's header) touches six
screen files three runs are editing tonight and has historically cost the edge swipe-back. The trace is below; the walk
captures every top edge for her look. (2) ~~The suites, the optional red-on-old run and the walk are PENDING the stage.~~
The first suite run RAN (§4 row 4.6: 117 tests in 12 suites, the only red the navigation test's two issues — the
snapshot predates `8eb727f2e`); the whole phone and whole Mac targets PENDING (on the tree after VM-55's merge is
re-landed); the optional red-on-old NOT RUN — dropped (VM-52's bar is a design change her ruling settles, not a bug-class
fix; its geometry pins stand as its evidence); the walk SUPERSEDED by the run's one walk (§3), PENDING.
(3) The mockup's "the bar leaves while the keyboard is up" is the capture box's row (VM-73); not built (P-47-21).
(4) VM-55's message line keys its lift to the roots (`pagingAllowed ? tabBarHeight : 0`); with the bar now on pushed
lists too, the re-land must key it to "a bar is on screen" (below, "For the re-land").

**The bar — one pointer per piece** (`9c76b335c`; numbers PROVISIONAL with P-47-1, P-47-21).

| Piece | Where | What |
|---|---|---|
| The face | `VariorumMobile/Features/Shell/MobileTabBar.swift` — `MobileTabBar` | Starred · Bookcase · Library (`MobileTabBar.word` — SW-1's Bookcase; Starred is `MobileStarsModel.pageName`), in band order (`MobileShellBand.pages`); the words at the `tab` role (17 pt, chrome: follows the text size to xxxLarge and holds; never under 13); the current one semibold in her ink on a chip (the palette's wash, radius 12, 8 above and below the word); the others regular in the corrected muted (`tokens.phone.muted` — they were faint); each a `Button` speaking its plain word with `.isSelected` when current |
| The targets | `MobileTabBarMetrics.target` (56), `.cellVertical` (8); `phoneHitArea()` | each cell a third of the bar and at least 56 tall — the whole cell answers (LK-5; sheet §B); the cell is the chip plus 8 above and below, so it grows with the words to ≈ 60 at xxxLarge and holds |
| The fit | `MobileTabBarMetrics.chipSide(wordWidth:cellWidth:)`, `.wordWidth(_:voice:at:)`, `.chipSides` (16 · 8 · 4) | the chip's sides are the widest of 16, 8, 4 that let the word (measured semibold, its widest face) fit its cell at the current text size; only where even 4 cannot — 320 pt Display Zoom at the larger sizes — does the word shrink, never below the floor (`phoneType(_:_:weight:shrinkingToFloor:)`) |
| The ground | `MobileTabBar.body` | the room, reaching past the home indicator (`ignoresSafeArea(.container, edges: .bottom)` — on a pushed list the page under it is the paper); the hairline above in the palette's line |
| The layer's one addition | `Shared/Theme/PhoneType.swift` — `phoneType(_:_:weight:shrinkingToFloor:)` | additive: a site's own weight on a label that may shrink to the floor (the two existing forms each took one). The Mac compiles it and never calls it |
| The shell reads it | `MobileShellView.tabBar` | `MobileTabBar(current: tab, tokens: tokens, select: { tabSelected($0) })`; the private `tabDoor` is gone |

**Where it shows, and why** (`9c76b335c`; the destination builder decides, so a note pushed over a list covers the bar
— hidden inside a note by construction, never by a flag).

| Screen | Bar | Why |
|---|---|---|
| Starred · Bookcase · Library (roots) | yes — each root draws it at its foot, as before | her ruling: roots |
| A book's contents (`.book`) | yes — `.safeAreaInset(edge: .bottom, spacing: 0) { tabBar }` | a list |
| Trash (`.trash`), Archived (`.archive`) | yes — the same line | lists; the bar sits under their report bands |
| Versions (`.versions`) | the LISTING only — `MobileVersionsScreen(…, listingBar: AnyView(tabBar))`, shown while `model.reading == nil` | the listing is a list; a moment read is her words |
| Write (`.note`) | no | her ruling: "not notes" |
| A book's Read page (`.bookRead`) | no | her words read full-screen (P-47-18) |
| Protection (`.protection`) | no | not a root or a list; while new words are held it gives no way off but her close, and a tab would be one (P-47-18) |
| Settings and every sheet | — | sheets cover the bar (unchanged) |

**The tab road** (`MobileShellView.tabSelected`, `popToRoot(_:animated:)`; P-47-19). A tap on the CURRENT tab from a
pushed list pops that stack to its root (animated — the system's tab grammar). A tap on ANOTHER tab first returns the
stack being left to its root (unanimated — the slide is the motion), then changes the page through `selectPage`, the
one road a swipe also takes (the liveness hand-off, A5-8's leaving-files-it rule, the settle — all unchanged). So a
hidden stack always stands at its root, as it did when the bar showed on roots only: the band never reveals a pushed
screen, and VM-55's wing landing ("the landing always shows the Bookcase itself") stays true.

**W-009 — each pushed screen's top edge, from the code** (unchanged by this batch; P-47-20; the walk's captures named).

| Screen | The system bar today (code) | Under it (the app's own) | Owner of the top row |
|---|---|---|---|
| A book's contents | inline, no title; the back door + **Details + Read** (`MobileBookView` `.toolbar`, trailing) — NOT empty: the a-book mockup's own shape | the book's name (`screenTitle`) | VM-122 ("its doors in the top bar") · b6 |
| Read | inline, no title, no items — the back door alone | the cream page, the book's title on it | VM-122 · b7 |
| Write | no navigation-bar line at all (the default bar, no title) — the back door alone | the masthead: title + four tools, then the chips (`safeAreaInset(edge: .top)`) | VM-148 ("a slim bar once you scroll"; the note-write mockup's top bar: back + tools) · b9 |
| Trash | inline — the back door alone | "~/trash" (`screenTitle`, muted) + sort + Empty Trash; the 30-day note | VM-100 (trash-archive-tags §1) · b4 |
| Archived | inline — the back door alone | "~/archived" + its promise | VM-99/VM-100 (§2) · b14 |
| Versions | inline — the back door alone | "~/versions" header; the reader's "‹ Versions" door | VM-147's umbrella (Note ▸ Versions; no member names its top row — to be placed at that kickoff) · b10, b11 |
| Protection | inline — the back door alone, hidden while new words are held | its sections | VM-110 · b15 |

The external facts behind keeping the bar (a Sonnet lookup, read-only, sources in its report): a hidden navigation bar
has historically disabled the edge swipe-back (`interactivePopGestureRecognizer`; Apple forum threads 2022–2024), and
no source confirms iOS 26 changed that; iOS 26's content-area swipe-back (`interactiveContentPopGestureRecognizer`,
WWDC25 284) is unconfirmed with the bar hidden; iOS 26's bar is transparent by default with the back button on its own
glass, and Apple's guidance is to remove custom bar backgrounds (`toolbarBackground`) — so the bar region's ground
was left as the system draws it.

**`MobileShellView.swift` — the lines this batch changed** (pre-batch `54cbcb9e5` line numbers → this branch's):
11–15 → 11–16 (the header comment's bar sentence) · after 468 → 469–470 (the book's bar line) · after 487 → 491 (the
Trash's) · after 491 → 496 (the Archive's) · 496 → 501–505 (the Versions constructor with `listingBar`) · after 497 →
507–510 (P-47-18's comment on the Protection route) · 578–624 → 591–642 (the `tabBar` property's body and its doc
comment; `tabDoor` removed; `tabSelected` and `popToRoot` added). No path line, swipe, relock landing, `selectPage` or
`pagingAllowed` line was touched; nothing was reordered or renamed.

**For the re-land (VM-55 merges first; read-only reads of the sibling branches):**
- VM-55 adds `.onGeometryChange(for: CGFloat.self) { $0.size.height } action: { tabBarHeight = $0 }` at the end of the
  OLD `tabBar` body — re-attach it to `MobileTabBar(…)` in the new `tabBar`; and its `MobileMessageLineHost(…,
  chromeInset: pagingAllowed ? tabBarHeight : 0)` assumes the bar shows on roots only — with the bar on pushed lists
  it should lift wherever a bar is on screen (a pushed list's bar is the same height; a note's screen has none).
- Tests on sibling branches that drive the tab by the word **"Shelf"** must move to **"Bookcase"**: VM-55
  `MobileWingDoorTests.swift:383` (`root: "Shelf"` — if it names the tab) and `:503` (`elements(selected: "Shelf")`);
  VM-64 `MobileHerPathsPerfTests.swift:789` (`activate("Shelf")`); and on every branch `MobileNavigationTests`
  (moved here). The path line's own "Shelf" word (`tokens.path(["Shelf"])`, and VM-55's `page: "Shelf"`) is NOT the
  tab and is untouched.
- Batch 3's walk driver (`VM47Walk3Driver.swift`, gitignored) drives `goTab("Shelf")` — right for the app it was
  built against (`4cca58a8e`); batch 4's copy drives "Bookcase".
- `MobileVersions.swift`: VM-55 removes the `.safeAreaInset(edge: .bottom) { reportLine }` line this batch's listing
  bar sits after (adjacent lines; the bar line stays).

**Tests (written; the first suite run is §4 row 4.6's — "Test run with 117 tests in 12 suites failed after 140.396
seconds with 2 issues", the two the navigation test's at `MobileNavigationTests.swift:224` and `:232` (the gate
snapshot `148dd741b` predates the test-only fix `8eb727f2e`), `MobileTabBarTests` and the other ten suites passed;
the whole target PENDING, after VM-55's re-land).** New, `VariorumMobileTests/MobileTabBarTests.swift` (10):
`theFitKeepsEveryWordWholeOnEveryShippedWidth` (375 · 393 · 402 · 430 · 440 × both voices × xSmall · Large · xxxLarge ·
AX5 — every word fits unshrunk; 16 pt sides at the default size on 402) · `theFitRuleTakesTheWidestSideThatFits` ·
`atDisplayZoomAWordShrinksNoFurtherThanTheFloorAndStillFits` (320 pt: a word that cannot hold its size fits at 13 pt
with 4 pt sides; the shrinking cases are printed) · `theBarHasThreeCellsAThirdWideAndFiftySixTall` (both voices, 402
and 375, Large/xxxLarge/AX5: ≥ 56 tall, a third wide, one row in band order, the selection, buttons; AX5 = xxxLarge) ·
`eachDoorCallsTheTabRoadWithItsOwnPage` · `onTheMountedShellTheDoorsAreFiftySixTallAndAThirdOfTheScreen` (**red on
old** for "Starred" and "Library": the pre-batch doors were the words' own frames) ·
`aPushedListWearsTheBarAndATabTapReturnsToThatRoot` (the Trash) · `insideANoteTheBarIsGoneAndTheVersionsListingWearsIt`
(Write: no door on screen; Versions' listing: the bar; a tab from it closes the note under it — the liveness authority
empties) · `theVersionsReaderDoesNotWearTheBar` · `theRouteRuleIsTheDestinationBuilders` (source: the list arms carry the
bar; `bookRead`, `note`, `protection` do not). Moved: `MobileNavigationTests.theTabBarCarriesThreeDoorsAndEachOneMovesTheBand`
— "Shelf" → "Bookcase" (SW-1; the page is still `.shelf`) *(and corrected at batch 5, `8eb727f2e`, test-only, at
the coordinator's hand-off: its selection helper now counts only BUTTONS labelled with the tab's word — since batch 3 the
harness shell wears Study, where the Starred and Library path lines read the bare word, a fourth non-door element; the
trace is `notes/plans/vm-47-walk-b3.md`, "The navigation red"; its run rides batch 5's phone window — RUN GREEN, §4 row
5.7 (a): the fix verified)*. Untouched and expected green: `MobileShelfLayoutTests` /
`MobileShelfRenderedLayoutTests` / `MobilePathLineGeometryTests` / `MobileShelfTodayDoorTests` host the roots with
`tabBar: { EmptyView() }`, so the bar's new height (≈ 40 → 56 at the default size) never enters their arithmetic; on
a device the shelf's measured region is that much smaller and `MobileShelfLayout`'s floor guarantee — pinned over
regions from 60 pt up — holds; the brain is unchanged (W-024's arithmetic needed no re-derivation).
The source pins stay clean: no `minimumScaleFactor(` in a phone file (the shrink is the layer's `shrinkingToFloor`), no
literal size, no private control build.

**Builds — GREEN (headless, no stage):** phone `build-for-testing` into `DerivedData/vm47-b4` at `35fc0a461`
(`** TEST BUILD SUCCEEDED **`); Mac `build-for-testing` into `vm47-b4` at `35fc0a461` (`** TEST BUILD SUCCEEDED **`
— `Shared/` changed by one additive extension); the walk driver (`walk4.zsh` `walk_build`) into
`DerivedData/vm47-walk4` from this tree (`** TEST BUILD SUCCEEDED **`; the temporary copy removed; tree clean).

**The stage window (READY — the orchestrator's GO):** *(since: the first suite run RAN, §4 row 4.6; the whole
targets run on the tree after VM-55's re-land, PENDING; the walk below SUPERSEDED by §3's one walk, row 4.4)*
- Phone, the whole target: from `App/Variorum/`, `xcodebuild test-without-building -scheme VariorumMobile -destination
  'id=<the standing device>' -derivedDataPath DerivedData/vm47-b4 -only-testing:VariorumMobileTests`.
- Mac (`Shared/Theme/PhoneType.swift` changed): `mac=(ThemeTokenTests PaletteDerivationTests NoLiteralColourTests
  SharedPageStyleTests PaletteReachTests MarkdownPaletteWritersTests HelperWindowThemeTests)` from `vm47-b4` (no Mac
  code or Mac test reads the phone layer — grep).
- **NOT RUN — dropped** (VM-52's bar is a design change her ruling settles, not a bug-class fix; its geometry pins stand
  as its evidence; no `rol4` snapshot stands in the worktree list). As offered: Red-on-old (optional — W-007 is a design row her ruling settles, so the geometry oracle is its evidence; offered
  because it is cheap): a detached snapshot `~/dev/variorum-vm-47-rol4` at this branch's head, `git checkout 54cbcb9e5 --
  App/Variorum/VariorumMobile/Features/Shell/MobileShellView.swift` (staged there only — `MobileTabBar.swift` and
  `MobileVersions.swift`' default parameter keep the test target compiling), phone `build-for-testing` into its own
  `App/Variorum/DerivedData/vm47-rol4`, then `-only-testing:VariorumMobileTests/MobileTabBarTests
  -only-testing:VariorumMobileTests/MobileNavigationTests`. Expected RED: the mounted-shell doors (≈ 20 tall,
  word-wide; no "Bookcase"), the pushed Trash (no bar), the Versions listing (no bar), the route rule (source), and
  `MobileNavigationTests` (no "Bookcase"); expected GREEN: the fit, the bar alone, the reader. Then remove the snapshot.
- The walk (`notes/plans/vm-47-screens/instruments/walk4.zsh`, gitignored; its header is the runbook): `source` it,
  then `WALK_DEADLINE=HH:MM walk_bar` — device `vm47-walk4` created, seeded and deleted inside the claim; 73 captures
  into `notes/plans/vm-47-screens/b4/`: under the sea-glass, all eight of Study/Terminal × light/dark × default/AX5 —
  b1 Bookcase · b2 Starred · b3 Library, each with the bar · b4 the Trash with the bar and its top edge · b5 Library
  tapped from the Trash; and at Study light default, Terminal dark default and Study light AX5 also — b6 a book's
  contents and its top edge · b7 its Read page (no bar) · b8 Bookcase tapped from the book · b9 a note in Write (no bar;
  the empty system bar above the masthead) · b10 Versions' listing (the bar) · b11 a moment read (no bar) · b12
  Bookcase tapped from Versions · b13 the Library after (its root) · b14 Archived (the bar) · b15 Protection (no bar).
  What to look at: the three words whole at AX5 in Terminal; the chip on the current word; the inactive words
  readable (corrected muted); the bar on the room against a paper page (b4, b6, b14); the hairline; no bar in b7, b9,
  b11, b15; b5/b8/b12/b13 land on roots; and each pushed screen's top edge for P-47-20.

**PROVISIONAL calls added (§5):** P-47-18 (where the bar shows beyond the ruling: none on Read, the Versions reader,
Protection), P-47-19 (a tab from a pushed list returns the left stack to its root), P-47-20 (W-009: the system bar kept;
DEFERRED with owners), P-47-21 (the bar's drawn numbers; the keyboard rule left to VM-73). No QUESTIONS edit on this
branch (the merge carries §5).

**Self-assessment (for the cold reviewer).** The bar is one view over the layer — the `tab` role, the spacing scale's
steps, the standard radius, the hit-area helper — so its numbers live in one place, and where it shows is decided by
the destination builder rather than a flag, so "hidden inside a note" cannot drift: a note pushed over a list covers
the list's bar. The riskiest calls: (1) **W-009 deferred** — the ticket names it, and this batch changes no top edge;
the case for keeping the bar is the back gestures and the mockups' own top rows, and the walk shows her what is there;
(2) **P-47-19's pop on leaving** happens in the same render as the page's settle, so the leaving page shows its root
while it slides away — the walk's b5/b12 capture after the settle, not during; if it reads badly the option is to pop
when the settle completes; (3) the **mounted-shell pins** rest on the harness walking raw subviews (the offscreen roots
are in every walk, so a door counts only on the window) and on UIKit removing a covered root's view from the window
after a push — if it ever kept it, the "inside a note" absence check would go red (a false red, never a false green);
(4) **the fit** measures a word with UIKit's font at the role's resolved size while SwiftUI draws it — the same faces
(SF Pro / SF Mono / the system font at a size), so the two agree, and the bar's first frame (before its width is
measured) takes the widest sides, which the second pass corrects; (5) **the taller bar** gives the shelf's measured
region ≈ 16 pt less at the default size (and above the keyboard, where the bar still rides) — the floor guarantee is the
brain's and holds; the mockup's "the bar leaves while the keyboard is up" is VM-73's. The Mac cannot have changed:
`VoiceTokens.swift` is untouched and the one `Shared/` change is an additive extension the Mac never calls.

### Batch 5 — results (implementer: Opus, 2026-11-19)

**Not done in this batch, first:** (1) the suites, VM-27's red-on-old run and the walk are PENDING the stage (the lines
are "The stage window" below; every build is green) — the short piece since RUN (§4 row 5.7: its one red the VM-27 pin's
harness, fixed in row R1.3); still PENDING: VM-27's red-on-old re-run (row R1.5), the whole phone and whole Mac targets on
the tree after VM-55's re-land, and the walk, now the run's one walk (§3). (2) The sync row's DOORED states (VM-27's locked and not-yet)
cannot be walked: the walk's dev store never syncs (A4), so the mounted pin `MobileSettingsProtectionDoorTests` is that
evidence; part B logs it NOT REACHABLE. (3) Rows whose features do not exist on the phone yet are not built (the brief):
the palette chooser (no owner — §5, for the orchestrator to ticket), the dial and Lock now (VM-25), leaving Castle
(VM-109), the writing and document settings (VM-11, W-212), crash reports (VM-220), What's new (VM-221), the tour and
the pocket guide's Help rows (VM-215, VM-211), Settings search (W-215, after v1). (4) The edit trace's two rows still
ship in Release — W-214 is VM-13's (the experiment retires at its close); this batch only groups them. (5) The ⋯ menu's
own rows cannot be driven in process (P-47-22) — the walk's part B is their look.

**VM-27 — the trace, and which door stayed.** *Mechanism* (`MobileSettingsView` at `9438f7b27`): ONE closure,
`protectionDoor` (the shell's road, the app's services, and an account section on the open library — P-2), fed TWO
renderers on the sheet: the sync row, through `.environment(\.protectionPaneDoor, protectionDoor.map { … })`, which made
`SyncRowFace.face(canOpenProtection: true)` mint its *Protection…* door for the keys refusal (`.keysLocked`, and
`.notOnYet` over a library that has not joined); and the standing row directly below, `if let protectionDoor { … }`.
One gate, so whenever the row's door rendered the standing row did too: the word twice, stacked. *Which stayed:* the
STANDING row — on the phone it is on this sheet in every state the row's door could render (the same gate) and in every
other state too, so it is the door that never leaves; the lock mockup's build note says the same ("One Protection row,
always: the sync row's door and the standing button must never both render"). *The fix* (`9c9aa4b6c`): Settings hands
the sync row NO door (`.environment(\.protectionPaneDoor, nil)`), so a doored paused state says its sentence alone —
the shared face's own P-2 arm, already pinned on the Mac (`SyncLockedRowTests.withNoProtectionPaneTheLockedRowSaysTheSentenceAlone`).
No word changed (CastleRules read in full: nothing here says anything about encryption, backups, the words or the
passphrase); no protection behaviour changed; the Mac's sidebar row keeps its door (its composition is untouched).
*The pin* (`aea9a30d9`, before the fix): `MobileSettingsProtectionDoorTests` — the sheet mounted over the PHONE'S OWN
bootstrap on a planted road (its account section made), real `AppServices` over its session whose chain refuses for keys
(`UnenrolledKeyProvider`; the transport is never reached), one round run; the locked face (record fact unknown) and the
not-yet face (`librarySyncsWithAnAccount` false): exactly ONE element says "Protection…", and pressing it opens the
screen. *Red on old:* a detached snapshot `~/dev/variorum-vm-47-rol5` at `32f9c605e` with the fix's ONE line reverted
there only (staged, never committed — the sync row handed `protectionDoor.map { … }` again), built GREEN into its own
`App/Variorum/DerivedData/vm47-rol5`; run PENDING (expected: both cases RED, two "Protection…" elements). This worktree
never carried a revert. Her glance at which door stayed is held (§5). *First run (§4 row 5.7 (b)): NOT PROVEN* — the
pin's harness let the round's database read fall through to the live default and the host stopped before any
"Protection…" check (next paragraph); the harness fixed (row R1.3), the snapshot re-made on the corrected pin (row R1.5),
the re-run owed. **PROVEN (the orchestrator's window, 13:32–13:35, the standing device; row R1.5):** on the fixed tree
(`vm47-b5` at `0f167176f`) `MobileSettingsProtectionDoorTests` ran both cases and passed — "Test run with 1 test in 1
suite passed after 2.801 seconds", no "has no test implementation" issue, one host launch; on the snapshot with the
fix's one line reverted it failed as intended — "…failed after 2.850 seconds with 2 issues", both cases at
`MobileSettingsProtectionDoorTests.swift:139` (`doors.count == 1`), no host crash. **VM-27 FIXED with its pin.** The
snapshot `~/dev/variorum-vm-47-rol5` is removed.

**The pin's unscoped round — what it did and did not do** (the short piece, §4 row 5.7 (a) and (b); established from
the code and the two logs, `b5-phone-targeted.log` and `b5-rol5.log` in the orchestrator's session scratchpad, and from
the simulator's file times; the fix is row R1.3).
- *The mechanism.* The pin composes a real chain (`SyncSession.configure` → `SyncEngine` → `SyncScheduler`) over the
  library its TEST bootstrap opened. The engine reads `\.database` ambiently (`SyncEngine.swift:68`): the property
  wrapper takes the scope where `configure` built it, merged with the scope its round runs in (the scheduler's
  `loopTask`, `SyncScheduler.swift:157`, inheriting the trigger's task-locals — the scheduler's own header, :21–23). The
  app makes the open library that ambient value (`AppDatabase.install`, `AppBootstrap.swift:476–477`); a test bootstrap
  skips the install by design (`isTestBootstrap`, `AppBootstrap.swift:163–167`), and the first harness bound only the
  date and the uuid. So the round's one database read resolved the dependency's default: swift-dependencies' default
  `testValue` records "has no test implementation" and returns the live value (`DependencyKey.swift:167–186` in the
  package checkout), and `AppDatabase.liveValue` (`AppDatabase+Dependency.swift:15–21`) opens `Application
  Support/Variorum/variorum.sqlite` — the `.real` home — inside the TEST HOST's own app container on the standing
  simulator (leg (b)'s log prints the full path; not repeated here, it carries the device's id).
- *1. No network request was made — the keys refusal stopped the round before any transport use.* The order,
  `SyncScheduler.runOneRound` (`SyncScheduler.swift:212–334`): the janitor's ledger pass (:239–257) runs only when a
  janitor exists, and `SyncSession.configure` makes one only for a transport with the purge surface
  (`SyncSession.swift:211–212`) — the pin's `UnreachedTransport` has none; then `engine.pull` (:263) → `pullRound`
  (`SyncEngine.swift:578–591`): `refuseIfAccountMismatched()` (:582; no account binding composed, so it returns at
  :154), then `roundCrypto()` (:585) — `UnenrolledKeyProvider` throws and the engine refuses `encryptionKeysUnavailable`
  (:195–200) BEFORE the device identity (:590) and the schema lockstep check (:591, whose `transport.schemaVersion()`,
  :956, would be the first transport call); `engine.push()` (:266) never runs, since the pull threw; then the catch
  (:309–328) and `outboxCount()` (:329). The `UnreachedTransport` is an in-process actor that makes no network call, but
  it is no guard: reached, it answers empty or rejected, silently — it neither fails nor records. No other road could
  connect: a real transport is composed only by `AppServices.connectSyncIfAllowed` (`AppServices.swift:518–546`), reached
  from `start()` and the sign-in roads, none of which the pin calls, and its `AuthSession` holds an in-memory store with
  no session and an `http` that throws "no network". The live store the read opened plays no part in the transport. The
  log: between the road's last line (12:04:25.195) and the `joined → false` case's start the only lines are the
  dependency issue (`b5-phone-targeted.log` lines 178–192); the round logs nothing of its own, so the log cannot show
  the order — the code does.
- *2. What was written.* The ROUND wrote nothing: on the keys-refusal path its only statement against `database` is
  `outboxCount()`'s `SELECT COUNT(*) FROM sync_outbox` (`SyncEngine.swift:184–188`) — a read; the rest sets the status
  in memory and publishes it (:329–333). A round's writes — `sync_state`, the outbox, the pull stage
  (`SyncEngine.swift:596` onward), the push — sit past the refusal and never ran. **But resolving the read wrote:**
  `liveValue` OPENS the store, and the open writes — the folder is made if missing (`AppDatabase+Dependency.swift:107`),
  the key is the test process's own (`StoreKeyCustody.processEphemeral`, one key minted per process,
  `StoreKey.swift:125–128`), and `AppDatabase.onDisk` runs the migrator on the file (`AppDatabase.swift:31–34`). The
  simulator shows what it did: the test host's app container (`io.lduarte.VariorumMobile`; the container's folder dated Oct 25)
  holds `Library/Application Support/Variorum/variorum.sqlite`, the folder and the file both BORN at 12:04:25 — the
  second of leg (a)'s unscoped read (log line 181) — 577,536 bytes, last modified 12:05:24, the second leg (b)'s open
  failed ("hmac check failed for pgno=1", `b5-rol5.log` lines 53–56: a new process, a new key, against leg (a)'s
  file). So leg (a) CREATED a new encrypted store, migrated, in the simulator test host's container — a write, made by
  the open, not by the round. Nothing else was reached: no store on the Mac, no dev store, her real store, any account —
  the file is inside the simulator's app container. Two things the logs and the disk cannot show: the path leg (b)'s log
  prints names a data-container id that does not exist on the device now (the file it failed on is the one above, by
  its modification time); and nothing records why. ~~**The file still stands**: any later unscoped read in a test process
  on that device would meet it and stop the host as leg (b) did — removing it is a device act left for the orchestrator.~~
  **REMOVED** (after the 13:32–13:35 window, the device shut down, at the stage coordinator's word): the stray store in
  the standing simulator's test-host container (`Library/Application Support/Variorum/variorum.sqlite`, born 12:04:25);
  the simulator's own `Variorum-dev` was not touched, and the corrected harness created nothing new there.
- *The `joined → false` case.* Its round reached :329 too (its precondition reads the status the scheduler publishes
  only at :333, after :329, and it passed) and read the same live store with no second issue: the dependency library's
  cache keys a resolved value by the Swift Testing test's id (`DependencyValues.swift:475–488` in the package checkout),
  one id for both arguments of a parameterized test, so the second read reused the first's value, and `liveValue` is a
  `static let` (one open per process). One issue in the log, two reads, one open.
- *Other ambient readers.* The scheduler's own `@Dependency(\.database)` (`SyncScheduler.swift:105`) is never read in
  that file; `Operations` (`Operations.swift:16`) is reached by no act the pin made; the sheet's one database read
  (`MobileSettingsView.restoreGuideDoor`) answers a press the pin never made and reads `session.database` explicitly. No
  other test in either run recorded the issue (each test resolves afresh and would report its own).
- *3. The corrected harness (row R1.3).* The chain now runs inside `withDependencies { $0.database = session.database }`:
  the engine `configure` builds there captures it, and the round's Task inherits it from the trigger
  (`SyncSession.triggerSync`'s Task, created inside the scope). The outer scope binds a throwaway in-memory FENCE
  (`AppDatabase.inMemory()`), so a read that ever escapes the inner scope meets the fence, never the live default (the
  wrapper merges its captured scope with the current one, the current's values winning — `Dependency.swift:73, 183` and
  `DependencyValues.swift:409–413` in the checkout). THE GUARD: a note is planted in the library first, and the pin
  asserts the round's published `pendingPushCount` — `runOneRound`'s own `outboxCount()` read — equals this library's
  outbox count read beside it, which a fresh store (the fence, or a live default) cannot equal. *This run's other tests:*
  the only other test this run added or changed that builds real `AppServices`, a `SyncSession` or a scheduler is
  `MobileSettingsListTests.theSyncRowsDoorsAnswerAcrossFortyFour` (`MobileSettingsListTests.swift:101`) — inside
  `withEditorWorld`, which binds `$0.database = db` (`MobileEditorTestSupport.swift:52–53`), and it composes no chain (no
  `configure`, no `start()`, signed out), so no engine or scheduler exists there; no file this run changed under
  `VariorumTests/` builds one (a grep over the run's changed test files). Across the phone suites the VM-27 pin is the
  one test bootstrap paired with a sync chain (grep).

**The list (VM-53) — groups and rows, one pointer each** (`70368f6dc`; `MobileSettingsView.swift`).

| Group (its name) | Rows | Built on |
|---|---|---|
| — the header | `~/settings` / "Settings" · Done | `PhoneSheetHeader` (unchanged, P-47-13), outside the scroll |
| Library (draft) | the sync row · Protection… (when it can act) | `SyncStatusRow`'s phone arm (its doors now inline acts at 17 with 44 pt hit areas, its line the `meta` role — `Shared/SyncStatusViews.swift`; they were the Mac's 11.5 pt slot); `PhoneMenuRow` |
| Look (draft) | Voice: Terminal \| Study · Appearance: Follow system \| Light \| Dark | `PhoneSegmentedChoice` ×2 under a `control` label (`choiceRow`) |
| Tags | Manage Tags | `PhoneMenuRow` |
| Help (draft) | Acknowledgments | `PhoneMenuRow` |
| Diagnostics | Record edit trace (the system switch) · Edit trace… | `Toggle` tinted with the accent; `PhoneMenuRow` |
| DEBUG: Tutorial (dev store) | Open the pocket guide · Restore the pocket guide… · its outcome line | `PhoneMenuRow`; a `meta` line |
| DEBUG: Performance (dev store) | Seed the 100k fixture · its outcome line | `PhoneMenuRow`; a `meta` line |
| DEBUG: (unnamed) | TK2 Spike | `PhoneMenuRow` |

The shape: the header stays put; under it ONE `ScrollView`; `MobileSettingsGroup` (phone-local composition, not a
control) draws the section name (`PhoneSectionHeader` — 24 above, 8 below, at the gutter) on the room, then the rows
full width on the paper with a hairline between rows from the gutter (`Group(subviews:)`, so a row the caller does not
render — a door that cannot act — leaves no hairline). Every door is a `PhoneMenuRow` with the gutter INSIDE its target
(the control's one additive parameter, `inset:` — default 0, so no existing use moves), so the whole row answers edge to
edge at ≥ 44; the list grows with the text size and scrolls (the mockup's S1 at the largest text). Today's rows only,
grouped; nothing renamed but the section words the drafts replace (P-47-25).

**The appearance choice (VM-53, W-213; LK-1/LK-2) — brain, storage, reach.**
- *The brain is the Mac's, shared* (`a83c586f3`): `AppearanceChoice`'s pure enum moved from the Mac's
  `Variorum/Theme/AppearanceChoice.swift` to `Shared/Theme/AppearanceChoiceRule.swift` — its three cases, its key and its
  remembered rule byte for byte; the phone's two additions are `isDark(system:)` and the iOS twin `userInterfaceStyle`.
  The Mac's file keeps its AppKit half (`appearanceName`, now an extension) beside its one owner, so its
  `NSAppearance(named:)` line stays exactly where the Mac's pin (`MarkdownPaletteWritersTests.appearanceIsAppWide`)
  looks; the Mac's behaviour and tests are unchanged (Mac `build-for-testing` green at `70368f6dc`; its types are in the
  window's Mac list). A whole-file move (batch 3's `ThemeStore` precedent) was weighed and set aside on reading that
  pin: it would have taken the AppKit line out of the folder the pin walks and turned it red.
- *Storage:* this device's `UserDefaults`, key `appearanceChoice` (the Mac's key, in the phone's own domain) — never the
  `setting` table; the owner holds no store at all.
- *The owner:* `MobileAppearanceController` (`VariorumMobile/Features/Shell/MobileAppearance.swift`), held app-lived by
  `MobileShellRouter.appearance` (so the lobby wears it before a library opens). It writes each window's
  `overrideUserInterfaceStyle` — on a change, to every window of the app's connected scenes, and to each window AS IT
  BECOMES VISIBLE (`UIWindow.didBecomeVisibleNotification`, delivered on the posting thread), so a launch's first frame
  is drawn in the choice. Inert in a test runner's host (a scratch domain, no window — VX-604's posture).
- *What it reaches:* everything in the window — the SwiftUI chrome (every `@Environment(\.colorScheme)` reader), the
  UIKit editor and the three overlays (their dynamic colours; `MobileTraitBorder`'s trait registration, VM-54), every
  sheet, alert and menu presented there, the keyboard, the status bar; and the lobby, whose tokens are resolved at the
  app's root where no window override is seen — `VariorumMobileApp.lockedTokens` reads
  `appearance.choice.isDark(system:)` (one expression).
- *What it does not reach:* the launch screen (the system's, before any window); the Mac (nothing syncs); the library's
  voice and palette (the library's, R-47-2/LK-1).
- *The row:* Look ▸ Appearance, the Mac's words (P-47-24).

**The doors** (`e622cbbb9`) — `VariorumMobile/Features/Shell/MobileRootMenu.swift` (new): the shell's Settings door
(`MobileSettingsDoor`) handed down through the environment (the `ProtectionPaneDoor` precedent) and the ⋯
(`MobileRootMenu`: a system `Menu`, its items as data, P-47-22). ONE line on each root's path line; the Bookcase's
gear and its `onSettings` parameter retire into it (the gear's `MobileSettingsDoor.symbol` enum removed from
`MobileTodayDoor.swift`). A note's own door: the note's ⋯ sheet (`MobileNoteActions.swift`) gains a Settings row that
closes that sheet and asks the shell for Settings once it has gone (`onDisappear`), so two presentations never overlap;
Done returns her to the note. Protection (and the DEBUG pocket-guide door) now open on the VISIBLE stack (P-47-23).
*The four shared-risk files — line ranges changed* (pre-batch-5 `9438f7b27` → `e622cbbb9`):
`MobileShellView.swift` 50–52 → 50–52 (the protection route's doc) · 226 → removed (`onSettings:`) · after 272 → 272–273
(the door's injection) · 308–311 → 309–312 (the DEBUG guide door's doc) · 320 → 321 (its push) · 551–552 → 552–555
(`openProtection`'s doc) · 555 → 558–559 (its push); `MobileShelfView.swift` 70 → removed (`onSettings`) · 235 → 234
and 240–244 → 239–243 (the path line's doc) · 266–272 → 265 (the gear → the ⋯ line); `MobileLibraryView.swift` after
227 → 228 (the ⋯ line); `MobileStarredView.swift` 94–95 → 94–95 (its doc) · after 104 → 105 (the ⋯ line). No path-line
padding, wing-door line, swipe, `selectPage` or `pagingAllowed` line was touched; nothing reordered or renamed. *For the
re-land:* VM-55's interim wing door shares these path lines — the ⋯ is the line's last member on each root; any new
`MobileShelfView(…, onSettings: …)` construction on a sibling branch drops that argument (the parameter is gone).

**Every new rendered line** (for her wording pass): group names "Library", "Look", "Help" (drafts, wording list 2,
lock-and-protection S1); the appearance row "Appearance" · "Follow system" · "Light" · "Dark" (the Mac's own,
`AppearanceChoiceRow`); the ⋯'s spoken name "More" (VoiceOver only, iOS's word for a ⋯); the note sheet's "Settings"
row (today's word, a new place) and the ⋯ menu's "Settings" item (the same). Retired: the "Sync" and the "Voice" section
words (Voice is now the choice's label), "Recording edit trace — tap to stop" (the switch says it). Kept: Terminal ·
Study, Protection…, Manage Tags, Acknowledgments, Diagnostics, Record edit trace, Edit trace…, Starting…, the DEBUG doors.

**Tests — written; the short piece RUN (§4 row 5.7): the four new suites below green but for the VM-27 pin's
`joined → nil` case (its harness — row R1.3); of the moved ones `MobilePathLineGeometryTests` and `MobileNavigationTests`
green, the rest ride the whole target, PENDING after VM-55's re-land with the Mac's.** New:
`MobileSettingsProtectionDoorTests` (1 test × 2 cases, VM-27 — red on old in the snapshot, NOT PROVEN at its first run,
the re-run owed, row R1.5); `MobileSettingsListTests` (5 tests, 6 cases — scrolls at AX5, red on old by
construction: the old sheet had no scroll view; whole-row doors at Large and AX5, red on old: word-wide targets; the
sync row's doors ≥ 44, red on old: 11.5 pt words; the groups and the two choices — a segment drives the phone's owner;
the appearance words held to the Mac's row); `MobileAppearanceTests` (7 — the UIKit twin and the key, `isDark`, remembered
on this device, a change reaching the window's SwiftUI and UIKit, a window shown after the choice wearing it, never the
`setting` table — a contract pin, hollow by construction (the owner holds no store), the test host's owner inert);
`MobileRootMenuTests` (5 — the items, the ⋯ on each root in both voices, none without a shell, the mounted shell's three
⋯ and no gear, a note's door through the whole shell — red on old: no row). Moved, each with its reason in place:
`MobileProtectionScreenTests.settingsOpensTheScreenOnlyWhereItCanAct` (VM-27: it held the doubled door; VM-53: Protection
on the visible stack); `MobilePathLineGeometryTests` (both cases: the gear → the ⋯); six suites drop the retired
`onSettings:` argument (`MobileDeletionTests`, `MobileEmptyStoreTests`, `MobilePathLineGeometryTests`,
`MobileNavigationTests`, `MobileShelfTodayDoorTests`, `MobileShelfLayoutTests`); the coordinator's hand-off
`MobileNavigationTests` (`8eb727f2e`, recorded under batch 4).

**Builds — GREEN (headless, no stage):** phone `build-for-testing` into `DerivedData/vm47-b5` at `32f9c605e`
(`** TEST BUILD SUCCEEDED **`); Mac `build-for-testing` into `vm47-b5` at `70368f6dc` — every `Shared/` change of the
batch (nothing under `Shared/` or the Mac target changed after it); the VM-27 snapshot into its own `vm47-rol5`; the walk
driver (`walk5.zsh` `walk_build`) into `DerivedData/vm47-walk5` from this tree (the copy removed; tree clean).
*Machinery note:* `vm47-b5` was warm-started as an APFS clone of `vm47-b4`; when the coordinator removed `vm47-b4` the
clone's package state still named `vm47-b4`'s artifacts and one build failed on them. Repaired by pointing
`SourcePackages/workspace-state.json` at `vm47-b5`'s own copies and dropping the cached build descriptions; build
outputs had always gone to `vm47-b5` (only `vm47-b4`'s artifacts were read), so nothing was ever written into
`vm47-b4`. `vm47-walk5` and the snapshot's packages were seeded the same way, their paths rewritten to their own.

**The stage window (READY — the orchestrator's GO):** *(since: the short piece RUN, §4 row 5.7 — VM-27's red-on-old
NOT PROVEN, its re-run on the corrected pin owed, row R1.5; the whole targets run on the tree after VM-55's re-land,
PENDING; the walk below SUPERSEDED by §3's one walk — `vm47-walk5`
removed unrun, row 5.5)*
- Phone, the whole target: from `App/Variorum/`, `xcodebuild test-without-building -scheme VariorumMobile -destination
  'id=<the standing device>' -derivedDataPath DerivedData/vm47-b5 -only-testing:VariorumMobileTests`.
- Mac (`Shared/` changed — the rule, `PhoneControls`, the sync row's phone arm; and the Mac's own `AppearanceChoice.swift`):
  ```zsh
  mac=(ThemeTokenTests PaletteDerivationTests NoLiteralColourTests SharedPageStyleTests PaletteReachTests
  MarkdownPaletteWritersTests HelperWindowThemeTests AppearanceChoiceTests SyncLockedRowTests SyncProgressRowTests
  SyncRetryingRowTests SyncOutOfDateFaceTests SyncStalledRowTests NotOnYetWordsTests HostedSyncTierFaceTests)
  ```
  from `DerivedData/vm47-b5` (each checked to be declared exactly once as a suite type in `VariorumTests/`).
- VM-27's red-on-old: from `~/dev/variorum-vm-47-rol5/App/Variorum`, `xcodebuild test-without-building -scheme
  VariorumMobile -destination 'id=<the standing device>' -derivedDataPath DerivedData/vm47-rol5
  -only-testing:VariorumMobileTests/MobileSettingsProtectionDoorTests` — expected RED: both cases of
  `aDooredSyncRowLeavesExactlyOneProtectionDoor(joined:)` (two "Protection…" elements); then
  `git worktree remove --force ~/dev/variorum-vm-47-rol5`.
- The walk (`notes/plans/vm-47-screens/instruments/walk5.zsh`, gitignored; its header is the runbook — ONE walk for
  batches 4 and 5, two parts with a seam): `source` it, then `WALK_DEADLINE=HH:MM walk_part_a` (device `vm47-walk5`
  created, booted, seeded; batch 4's bar walk, 73 captures into `notes/plans/vm-47-screens/b5/`; ends SHUT DOWN, its
  library kept) and, in a later claim, `WALK_DEADLINE=HH:MM walk_part_b` (boots it; batch 5's Settings walk, 62 captures;
  `walk_close` deletes the device) — 135 in all. What to look at in part B: the list at AX5 in Terminal (nothing clipped,
  it scrolls — s5-02…04); every row's ground on the paper and the names on the room; the ONE Protection door; the ⋯ open
  on each root (s5-01, 05, 06); Settings over a note and Done back on it (s5-08…10); the flipped appearance reaching the
  sheet, the Bookcase and the UIKit editor (s5-11…13) and Follow system again (s5-14).

**PROVISIONAL calls added (§5):** P-47-22 (the ⋯ is the system menu), P-47-23 (Protection on the visible stack), P-47-24
(the appearance row in the Mac's words, no line beneath), P-47-25 (the group names; "Voice" kept), P-47-26 (the list's
drawn parts and numbers). No QUESTIONS edit on this branch (the merge carries §5).

**Self-assessment (for the cold reviewer).** VM-27 is one line with a mounted, behaviour-red pin; the risk there is only
the pin's world (a real services chain refusing for keys) — the Mac's suites build the same refusal the same way. The
riskiest calls: (1) **the appearance owner writes UIKit windows** rather than SwiftUI's `preferredColorScheme` — the
Mac's F-9 reasoning carried over; its first-frame claim rests on `didBecomeVisibleNotification` being delivered during
the window's showing, which `aWindowShownAfterTheChoiceWearsItAndTheWatchEndsWithItsOwner` pins (if UIKit delivers it
later, that pin goes red and the claim must be re-said); (2) **the brain's move edits a Mac file** — the enum's
declaration left it for an extension; behaviour byte-identical and the Mac's pins in the window's list; (3) **the ⋯ is
the system menu** whose rows no in-process pin can drive (P-47-22) — the items are data, the door is mounted, the walk
is the real look; (4) **the note's door asks for Settings from `onDisappear`** of the note's sheet so the two sheets never
overlap — `aNotesActionsOpenSettingsThroughTheWholeShell` drives the whole road; (5) **Protection now lands on the
visible stack** (P-47-23) — the reopen's adoption still uses the shelf's, so after a re-keying act she lands on the
Bookcase as before; (6) **`PhoneMenuRow` and the sync row's phone arm are `Shared/`** — additive (`inset:` defaults to 0;
the nil arm of the sync row byte-identical), and the Mac never renders either. The Mac's look cannot have changed:
`VoiceTokens.swift` is untouched, no Mac view's source changed, and the Mac file that changed lost only a declaration
that now lives in `Shared/`.

### Batch 6 — results (implementer: Opus, 2026-11-19)

**Not done in this batch, first:** (1) no test of any kind ran here — every suite (the whole phone target from
`DerivedData/vm47-b6`, the Mac list below) is PENDING the orchestrator's stage window, and so is the run's one walk (§3)
— *since:* the whole phone target RUN by the orchestrator 14:06–14:18 at `b20b04fad`, at baseline (§4 row 6.9: 1,045
tests in 179 suites, one host launch, the only red VM-24's caret test, 2 of 3 cases; 8 known issues); the Mac list PENDING;
(2) ~~`origin/main` merged on top~~ — DONE: VM-55's PR landed mid-batch and `origin/main` `eb18888db` was merged in at
`e72323130` (notes and ledgers only, no conflict); (3) no red-on-old was run: the four meetings are design decisions with pins that hold the
joint invariant, and meeting 2's lift pin is red on the old rule by construction (below); (4) nothing of VM-55's
behaviour or words changed but the tab's word in one of its pins (meeting 3) — the Bookcase root's PATH word stays VM-55's
"Shelf" and is put to her (P-47-28) — *since RULED:* R-47-3, the word follows the tab (meeting 3 below); (5) the path line's Terminal truncation with a wing name is PROVISIONAL (P-47-27).

**The merge.** `git merge --no-ff origin/vm-55-wings-underneath` at VM-55's tip **`49e795bb6`** (fetched 2026-11-19),
into this branch at `5bc1174fd`; merge base `9a78628ea` (main). The merge commit: **`0ff256975`** (parents `5bc1174fd`, `49e795bb6`). 23 files conflicted,
all phone faces (the brief's list exactly); VM-55's other 67 files merged clean (its seven `Shared/` brains, the moved Mac
wing files, its new phone views, tests and records — the two runs' `Shared/` and Mac file sets are disjoint). While the
merge was open its log was the gitignored `notes/plans/vm-47-screens/b6-reland-log.md`; what it says is below.

**The 23 files — what each resolution is** (the rule: VM-55's behaviour, words, views and parameters; this run's drawing):

| # | File | Resolution |
|---|---|---|
| 1 | `Read/MobileReadView` | VM-55's removal of the book's error slot (VM-61) — this run had only re-typed it |
| 2 | `Shell/MobileArchiveView` | VM-55's retirement of the report band; this run's ground comment ("the report band below stays on the room") made true |
| 3 | `Shell/MobileBookDetails` | the sheet's error slot removed (VM-55) |
| 4 | `Shell/MobileBookView` | both slots onto the one line (VM-55) — the doors' refusal and the header's error |
| 5 | `Shell/MobileCreateBook` | the sheet's error slot removed (VM-55) |
| 6 | `Shell/MobileLibraryView` | **more than mechanical:** this run's paper ground KEPT on the list + VM-55's three slot removals; the path line is this run's 44 pt line (center, spacing 0, `Spacer(minLength: 16)`, 🗑 · + New Note · ⋯) with VM-55's `MobileWingPath` in place of the plain `Text` |
| 7 | `Shell/MobileQuickNote` | the box's error line removed (VM-55); her words stay in the box |
| 8 | `Shell/MobileScraps` | the section's error line removed (VM-55) |
| 9 | `Shell/MobileShelfView` | **more than mechanical:** VM-55's slot removals; this run's path line with `MobileWingPath(page: "Shelf", trailing: "  ·  N books")`; the line's doc comment names the wing as drawn |
| 10 | `Shell/MobileShellView` | **more than mechanical:** both tasks (the library's theme; the held wings read); this run's tab road kept, VM-55's bar measurement re-attached to `MobileTabBar`; the line's lift keyed to a bar on screen (meeting 2) |
| 11 | `Shell/MobileStarredView` | **more than mechanical:** this run's paper ground and 44 pt line, VM-55's slot removal and `MobileWingPath` |
| 12 | `Shell/MobileTagManager` | **more than mechanical:** the shared `PhoneSheetHeader` (VM-50) carrying VM-55's wing-naming title (`model.title`, "Tags — in ‹wing›"); the error slot removed |
| 13 | `Shell/MobileTrashView` | VM-55's retirement of the report band; this run's ground comment made true |
| 14 | `Takes/MobileBlockHistorySheetView` | the overlay's status label stood down (VM-55) |
| 15 | `Takes/MobileLenses` | the sheet's status line removed (VM-55) |
| 16 | `Write/MobileBlockList` | the sheet's status line removed (VM-55) |
| 17 | `Write/MobileMembership` | the sheet's status line removed (VM-55) |
| 18 | `Write/MobileNoteActions` | the `reportLine` retired (VM-55); this run's batch-5 Settings row stands |
| 19 | `Write/MobileNoteTags` | the sheet's status line removed (VM-55) |
| 20 | `Write/MobileNoteTray` | the tray's status line removed (VM-55) |
| 21 | `Write/MobileReferences` | the sheet's status line removed (VM-55) |
| 22 | `Write/MobileVersions` | **more than mechanical:** this run's listing bar kept (VM-52), VM-55's report band removed; the ground comment made true |
| 23 | `Write/MobileWriteView` | the masthead's receipt row and its Undo/Redo onto the one line (VM-55 — batch 2 had left T50 for VM-61); piece 3.10's grounds untouched |

Beyond the 23, inside the merge: VM-55's `MobileWingDoorTests` drops the `onSettings:` argument batch 5 retired (compile
only, no assertion).

**VM-55's new faces on this run's layer (piece 6.2, `1f9781ab8`; its pins `b20b04fad`) — the role each site took.**

| Site | Before (VM-55, main's tokens) | Now |
|---|---|---|
| `MobileWingPath` — the door's title (an `AttributedString`: lead · the wing's name · the rest) | `tokens.small`, lead/rest `tokens.muted`, the name `tokens.accent`; the target the line's 14/6 paddings handed back by negative padding to reach 44 | `meta` (the root path line's role, batch 1's map), lead/rest `tokens.phone.muted`, the name in the accent; ONE line (`lineLimit(1)`); the target the hit-area helper's 44 on the leading edge — the line is already this run's one 44 pt line, so nothing is handed back and the line does not grow |
| `MobileWingPath` — the plain line (no door wired) | `tokens.small`, `tokens.muted` | `meta`, `tokens.phone.muted`, one line — the line batch 2 drew |
| `MobileWingDoorMetrics` | `minimumSide` 44 + the roots' paddings 14 / 6 | `minimumSide = PhoneMetrics.touchMinimum`; the two paddings removed (they named a layout that is gone; nothing else read them) |
| `MobileWingListSheet` — the header | a hand-built HStack: title `tokens.title`, Done `tokens.small` (the controls pin's "Done literal") | `PhoneSheetHeader` (VM-50) with VM-55's words, the Mac's ▾ list header; Done the closing act, 64 × 44 |
| `MobileWingListSheet` — a row | ✓ and the name `tokens.body`; 44 tall | the name a menu row's label, `control` 17 in her ink (sheet §E; P-47-8: `control` over `rowTitle`, the same size); the ✓ `meta` in the accent (batch 1's picker ✓); 44 tall; the sheet padded by the gutter |
| `MobileMessageLine` — the words | `tokens.small`; refusal alarm · removal `tokens.muted` · offer ink | the receipt line (sheet §E): `controlInline` 15, chrome; refusal alarm · removal `tokens.phone.muted` · offer ink; 12 above and below, so one line of words is the line's 44 |
| `MobileMessageLine` — the act (Undo) | `tokens.small` in the accent, a bare `.plain` button (≈ 14 pt tall) | `PhoneInlineActStyle(weight: .semibold)` — 15 semibold in the accent across a 44 × 44 hit area (the control gains an additive `weight:`) |
| `MobileMessageLine` — the line | padding 20 / 8, spacing 10 | `minHeight: 44`, the gutter, spacing 12; the room and the hairline unchanged |
| `MobileMessageLine` — its look | `VoiceTokens.resolve(voice:dark:)` — the palette-less road (the voice's bare colours) | the library's look: the model takes `look:` and the shell hands `router.tokens(dark:)` (VM-51's settings road); a harness with no look keeps the voice's own |

VM-55's words, classes, timing and placement are untouched (the line's `footOffset`, `takesTouch`, the probe's scene
edges, every door's class and words).

**The source scans — before and after** (each suite's own patterns run by script over the tree; the mirror validated
against the recorded counts: 332 slot reads and 32 sub-13 sites on `fe85ea6d5`, 33 control signatures on `751765baf`):

| Scan | The merged tree, before 6.2 | After 6.2 |
|---|---|---|
| `MobilePhoneTypeSourceTests` — Mac type slots | 8: `MobileMessageLine.swift:142, 156`; `MobileWingDoor.swift:163, 186, 235, 240, 266, 270` | 0 |
| `MobilePhoneTypeSourceTests` — sub-13 / caption / scale factor | 0 | 0 |
| `MobilePhoneControlsSourceTests` | 1: `MobileWingDoor.swift:239` (a sheet's own Done) | 0 |
| `MobileLookSourceTests` (grounds, ★, literal colour) | 0 | 0 |
| the voice's own small inks (`tokens.muted/faint` — the layer's rule, not a scan) | 4: `MobileWingDoor.swift:187, 197, 201`, `MobileMessageLine.swift:189` | 0 |

**Where the two runs meet — the four decisions.**

1. **The roots' path lines.** What I found: VM-55's door assumed the roots' pre-VM-47 line (11.5 pt text, 14 above, 6
   below) and handed those paddings back so its 44 pt target covered the line; this run's line is ONE 44 pt line whose
   doors are 44 pt controls (batch 2) with the ⋯ (batch 5). VM-55's pins hold the RULE, not the paddings (target ≥ 44 ×
   44, below the status bar, not into what is drawn under the line, a real control; the value), so none of them moved.
   Built: the door's target is the line's own 44 (the hit-area helper), the title `meta` on one line; the paddings and
   their hand-back are gone. The numbers measured with the real fonts: in Terminal at 402 the Bookcase's
   "~/home/shelf  ·  14 books" wants ≈ 438 pt beside the doors (≈ 422 with one book), Study's ≈ 376 — so at 402 in
   Terminal the words cannot all fit once a wing's name leads, and the path truncates at its tail (P-47-9's rule): every
   target stays 44, the line stays one line, the ⋯ is on all three roots. Put to her as **P-47-27** (§5) with the other
   roads. Pinned: `MobilePathLineGeometryTests.theBookcaseLineWithItsWingDoorHoldsOneLineAndEveryTarget` (new — 402 and
   430, both voices, 14 books: the wing door ≥ 44 × 44 and never taller, the three doors ≥ 44 × 44 on its line, after it,
   inside; + New Note's word whole; the door fires) beside VM-55's `MobileWingDoorGeometryTests` (unmoved) and batch 2's
   two cases (unmoved — they host the plain line). Commit `0cf6596a6`.
2. **The bar and the message line.** VM-55's `.onGeometryChange` rode the old `tabBar` body (it auto-merged INTO
   `tabSelected`); re-attached to `MobileTabBar` in the `tabBar` property. VM-55's lift `pagingAllowed ? tabBarHeight : 0`
   was the roots' rule; the bar now also rides pushed lists (VM-52), so the lift is `barOnScreen`: `pagingAllowed` (a
   root) OR a pushed list on the visible stack showing its own bar — `listBar(owner)`, the same bar counted per stack by
   its own `onAppear`/`onDisappear` (`listBarsShowing`), so a note pushed over a list, a pop, or the Versions reader
   replacing its listing drops the lift to the safe area's foot. Pinned:
   `MobileTabBarTests.theMessageLineClearsTheBarWhereverABarIsOnScreen` (new — the line's own model read through the
   shell's host probe: a root ≥ 56, the pushed Trash ≥ 56 — red on the old rule by construction, `pagingAllowed` false
   there — a note 0). This run's `theRouteRuleIsTheDestinationBuilders` MOVED to the counted form (`listBar(owner)`): the
   rule it holds is unchanged. Commits: the shell's lines in the merge `0ff256975`; the pins `3204f42fd`.
3. **The tab's word.** The tab is "Bookcase" (LK-5, SW-1). VM-55's `MobileWingDoorShellTests` (`MobileWingDoorTests.swift`)
   drove the landing's check by "Shelf" → MOVED to "Bookcase" (the fact unchanged: the Shelf page's door is chosen). No
   other test of either run drives the tab by "Shelf" (grep: `MobileWingsTests:189–190` and `MobileWingDoorTests:263, 394–395`
   are the PATH word, not the tab). The root's own path word: VM-55's door changed that line's words (the wing's name
   leads — P-55-2), so its words stand: the merged Bookcase root reads **"Home · Shelf · N books"** (Study) and
   **"~/home/shelf · N books"** (Terminal) under a tab that says Bookcase — recorded, and put to her as **P-47-28** (§5). Commit `a511366b4`.
   *Since RULED — R-47-3 (her answer by the question tool, 14:38: "Bookcase (Recommended)" — "The top line says Bookcase,
   matching the tab, your swipe names and the Mac."; §1, §5).* What it changed (§4 row R-47-3): the one word —
   `MobileShelfView` hands `MobileWingPath` the page "Bookcase" (`50635a674`), so the root reads **"Home · Bookcase  ·  N
   books"** (Study) and **"~/home/bookcase  ·  N books"** (Terminal), the wing's name still the door and its spoken value
   the line's rest, "Bookcase  ·  N books"; nothing renamed (`MobileShelfView`, `MobileTab.shelf`, "the shelf" in comments
   and identifiers stay). The pins that read the line moved with the ruling as the reason (`864ef813b`): this run's
   `MobilePathLineGeometryTests` and `MobileRootMenuTests` (each found the line by `tokens.path(["Shelf"])`), VM-55's
   `MobileWingDoorGeometryTests.theShelfRootsDoor` (the door's value), `MobileWingDoorTests.theLineReadsTheSameWithItsDoor`
   and `MobileWingStandTests.thePathLineLeadsWithTheWing` (the Shelf example's page); NEW, R-47-3's pin, in
   `MobilePathLineGeometryTests.theBookcasePathLineIsOneLineAtFourHundredTwoInBothVoices`: the root's own line begins
   "Bookcase  ·  " in Study and "~/bookcase  ·  " in Terminal, literal, red on the old word by construction. The line is
   three characters longer in Terminal, so P-47-27's tail truncation bites earlier (§5's figures); the path-line pins hold
   by the same rule (one line, every door 44 × 44), none loosened. The walk expects the new word (`vm-47-walk.md`,
   `4cad6d6c3`). The suites that read the line: PENDING a short stage window. **Every other "shelf" the phone draws or
   speaks, read and left:** this page's NAME elsewhere — none: the tab is already "Bookcase" (`MobileTabBar.word`), the
   swipe band speaks no page names of its own (its pages are the tab's words), the empty shelf's lines
   (`MobileEmptyStoreCopy.noBooks`, `.signIn`) name no page, and no root carries a page label of its own. *Unsure, so
   left and listed:* the book row's long-press door "Pin to Shelf Top" / "Unpin from Shelf Top"
   (`MobileShelfFaces.pinDoorTitle`, the Mac's former words, pinned by `MobileBooksTests`) — "Shelf Top" names a place on
   this page; the Bookcase's rows are VM-112's to rebuild. *Another surface's words, left:* the pocket guide's seeded
   prose (`MobileTutorialSeeder`: "a book on your shelf", "The SHELF is home", "on the shelf's top line", "on the
   Shelf's") — note text, VM-212's rewrite; the DEBUG guide door's note "The pocket guide is on your shelf."
   (`MobileSettingsView`) — Settings' words, VM-211's door. *The Bookcase's shelves sense (a `shelf` row), right as it
   is:* the shared refusal sentences "That shelf isn't there any more…", "A shelf needs a name.", "…can't be a shelf's
   mark…", "That book has moved to another shelf…" (`OpsRefusalTable`). *Not rendered:* the accessibility identifiers
   `shelf.booksRegion` / `shelf.writingRegion`, `MobileTab.shelf`, type and file names, comments (one now dated:
   `OpsRefusalTable.swift`'s "the phone's area is still "Shelf" until its catch-up" — a `Shared/` comment, left), the
   perf fixture's word list.
4. **The wing landing.** VM-55's landing is `selectPage(.shelf)` and touches no stack (P-55-14), relying on the Shelf's
   stack standing at its root while hidden; batch 4's tab road keeps exactly that (P-47-19 — a tab from a pushed list
   returns the stack being left to its root first), and the wing door is drawn only on a root. The two agree. No pin of
   either run held the pair, so: `MobileTabBarTests.aWingLandingAfterAListWasLeftShowsTheBookcaseItself` (new — the Trash
   pushed on the Bookcase's stack, Library by its tab, the wing door, Work picked: the landing is Work's Bookcase ROOT, no
   Trash, Work's door on screen; `3204f42fd`). The one edge both records name stands: a STANDING shell adopting a Protection request
   selects the Shelf without popping the stack it leaves (P-55-14's edge; reachable only after a re-keying act).

**Every pin of either run that moved, with the reason:** VM-55's `MobileWingDoorShellTests.fromTheLibraryAPickLandsOnTheWingsBookcase`
— "Shelf" → "Bookcase" (meeting 3); VM-55's `MobileWingDoorGeometryTests.theShelfRootsDoor` — the `onSettings:` argument
dropped (batch 5's retired parameter; compile only); this run's `MobileTabBarTests.theRouteRuleIsTheDestinationBuilders` —
`{ tabBar }` → `{ listBar(owner) }` (meeting 2's counted bar; the rule unchanged); this run's
`MobilePhoneControlsTests.theInlineActAnswersAcrossFortyFourWithoutMovingItsWord` — gains a weighted act (the control's
new `weight:`). No pin's assertion was weakened.

**New tests (5) and one new case — RUN in the whole phone target (§4 row 6.9), all passed (its one red is VM-24's):** `MobilePathLineGeometryTests.theBookcaseLineWithItsWingDoorHoldsOneLineAndEveryTarget`,
`MobileTabBarTests.theMessageLineClearsTheBarWhereverABarIsOnScreen`, `MobileTabBarTests.aWingLandingAfterAListWasLeftShowsTheBookcaseItself`,
and the new suite `MobileMessageLineFaceTests` (`theLinesActAnswersAcrossFortyFourOnAFortyFourLine` — red on VM-55's face
by construction, its act a ≈ 14 pt word; `theLineWearsTheLibrarysLook`); the added case: the weighted inline act in `MobilePhoneControlsTests.theInlineActAnswersAcrossFortyFourWithoutMovingItsWord`.

**Builds — GREEN (headless, no stage), into `App/Variorum/DerivedData/vm47-b6`, one at a time, after the coordinator's
"QUIET over" (13:32):** phone on the merge tree before its commit (`** TEST BUILD SUCCEEDED **`, 0 errors — the merge was
committed only then), again after piece 6.2 and after the pins (`b20b04fad` — the code of every later commit); Mac at
`b20b04fad` (`** TEST BUILD SUCCEEDED **`, 0 errors; `Shared/Theme/` changed). `origin/main` (`eb18888db` — VM-55's PR
#13 landed) was merged in after (`e72323130`): notes and ledgers only (`git diff --stat HEAD...origin/main -- App Sources
Tests Server` empty), no conflict, so the products stand. `DerivedData/vm47-b5` deleted at the orchestrator's word.

**The stage lines (READY — the orchestrator's GO; nothing here has run):**
- Phone, the whole target: from `App/Variorum/`, `xcodebuild test-without-building -scheme VariorumMobile -destination
  'id=<the standing device>' -derivedDataPath DerivedData/vm47-b6 -only-testing:VariorumMobileTests`. Expected from main:
  VM-24's caret test (2 of 3 cases) and the declared known issues (`MobileTrashTests` ×2, `MobileTutorialWalkTests` ×2,
  P-47-7's four filter-row marks). Batch 6's own to call out: `MobilePathLineGeometryTests`, `MobileTabBarTests`,
  `MobileMessageLineFaceTests`, `MobilePhoneControlsTests`, `MobileWingDoorTests` (its four types:
  `MobileWingDoorTests`, `MobileWingDoorGeometryTests`, `MobileWingListSheetTests`, `MobileWingDoorShellTests`),
  `MobileMessageLineTests`' types (`MobileLineShowRuleTests`, `MobileMessageLineGeometryTests`,
  `MobileMessageLineSceneTests`, `MobileMessageLineHostTests`, `MobileMessageLineInsetTests`, `MobileLineDoorTests`),
  `MobileUndoDoorTests`, the three source guards and VM-55's `MobileNoRawErrorPinTests` / `MobileErrorLogPrivacyPinTests`.
  **RUN** by the orchestrator under its own claim, 14:06–14:18, from `vm47-b6` at `b20b04fad` on the standing device: 1,045
  tests in 179 suites, one host launch; the only red VM-24's caret test (2 of 3 cases), as expected; 8 known issues (the
  four standing, P-47-7's four); every suite called out above passed; the test-host container lists `Variorum-dev` only
  (§4 row 6.9).
- Mac — the theme-store types of batch 3 (102), batch 5's fifteen, VM-55's four Mac pins (`WingPaletteDoorsTests` is
  already among the 102): 114 types, each checked declared exactly once as a suite type in `VariorumTests/`:
  ```zsh
mac=(BlockHistoryCommitsCaptureTests BlockHistoryHostTests BlockHistoryPaneTests BlocksArrivalMeasureTests
BookCarryLiveBlockTests BookEditHereRiderTests BookFoldDisclosureTests BookIndexCarryAnchorTests
BookIndexCarryBlockTests BookIndexTakesTests BookIndexToOutlineBlockLandingTests BookIndexToOutlineCarryTests
BookLeavingSavepointTests BookMastheadMountedTests BookNoteBoxOpenDoorTests BookOpenDoorMountTests
BookPanelDragGateTests BookPanelOpenNoteMarkTests CanvasArrivalTests ChromeMinHeightTests CommitBarLayoutTests
CompareCommentGutterTests CompareLensesAlignmentTests CompareToggleIdentityTests CurrentBlockContinuityTests
DebugOracleSingletonWindowTests DebugOracleTwoWindowTests IndexClickCaretTests IndexTierMetricsTests
InlineEditorWidthReflowTests LandingOffsetTests LibraryControlsGeometryTests LibraryListFaceRigTests
LibraryListFaceTests LibraryPanelHostTests LibrarySearchLandingTests MCPAsksWaitCaptureTests MCPGrantSheetCaptureTests
MCPGrantSheetU2CaptureTests MCPPaneTabsCaptureTests MCPPaneTabsTests MCPShareFacesCaptureTests MastheadLayoutTests
MastheadStampTests ModeSwitchCarryTests ModeSwitchFeelTests NewNoteInBookTests NoteBoxCompositionTests
NoteBoxGeometryTests NoteOpenLandingTests NoteVersionsPaneTests OpenListDragMountTests OpenListLayoutMountTests
OutlineRoomTests OutsideWriteLivePaneTests PagesArrowKeysHostTests PostDetailRoutingTests PostRescueFaceTests
QuickEntryOpeningScopeTests ReadArrivalMeasureTests ReadLandingTests ReadModeTests ReadNoteHeightsCalibrationTests
ReadNoteLandingTests ReadingFlowEstimateMeasureTests ReadingFlowLandingTests RestoreLandingRewriteHopTests
RestoreLandingTests SavepointCommitDoorTests SearchEmptyAnswerSentenceTests SideColumnTests
SidebarNoteBoxDoorFacesTests SidebarNoteRowMenuTests SidebarRowLeadsTests SidebarSearchFieldPlaceTests
SidebarSectionWindowMountTests SidebarSmokeTests SnippetsLandingTests StarredScrollMountTests StatusCenterTests
SurfaceSizeMemoryTests TakesCommentGutterTests TakesEntryBandTests TitleQuickfillTests TourClosingCardTests
TrayPanelMoveTests TutorialMCPChapterCaptureTests VX176LibraryTintTests VX343WhatsNewCaptureTests
VX347CommitLeavesMountTests VX349ListHeaderRestTests VX350SearchToggleMountTests VX895SearchFacetHeaderTests
VersionDoorsTests WingPaletteDoorsTests ThemeTokenTests PaletteDerivationTests NoLiteralColourTests
SharedPageStyleTests PaletteReachTests MarkdownPaletteWritersTests HelperWindowThemeTests AppearanceChoiceTests
SyncLockedRowTests SyncProgressRowTests SyncRetryingRowTests SyncOutOfDateFaceTests SyncStalledRowTests
NotOnYetWordsTests HostedSyncTierFaceTests VM56MacWingScopePinTests VM61MacStatusSeamPinTests
VM62MacRefusalWordsPinTests VM63MacWingBrainsHoistPinTests)
  ```
  from `App/Variorum/`: `xcodebuild test-without-building -scheme Variorum -destination 'platform=macOS'
  -derivedDataPath DerivedData/vm47-b6 $(for t in $mac; do print -- "-only-testing:VariorumTests/$t"; done)`.
- The whole Mac target and the run's one walk follow on this tree (§3).

**New rendered lines:** none at the batch. (The wing list's header, rows and Done keep VM-55's words; the receipt line
keeps VM-55's; the Bookcase root's path word was VM-55's — P-47-28 asked.) *Since, by R-47-3 (her ruling):* the Bookcase
root's path line says **"Home · Bookcase  ·  N books"** (Study) / **"~/home/bookcase  ·  N books"** (Terminal), and its
wing door speaks "Bookcase  ·  N books" as its value — a changed word, not a new line: the tab's own word, which she ruled.

**Recorded, not fixed (owners):** the line over a SHEET on a pushed list lifts by the bar under the sheet (VM-55's own
root behaviour, now on lists too — the sheet covers the bar); a standing shell's Protection adoption can leave a hidden
stack off its root (P-55-14's edge — VM-110 / VM-80); the empty-wing lines that assume Home (P-55-16 — VM-72).

**Self-assessment (for the cold reviewer).** The resolutions are mostly VM-55 retiring a per-screen slot that this run
had only re-typed — the slot goes, VM-55's comment stays. The places where both intents were written into one line are
the three roots' path lines, the shell, the tag manager's header and Versions' insets. The riskiest calls: (1) the
**bar-on-screen count** rests on SwiftUI firing `onAppear`/`onDisappear` for a list's bar as a note is pushed over it and
as it is popped (the same UIKit fact batch 4's mounted pins rest on) — a missed disappear would leave the line lifted
inside a note, which the new pin reds; (2) the **path line's truncation** in Terminal (P-47-27) is real at 402 pt — her
look at the walk decides it; (3) the **message line's 44 pt act** makes the line taller (≈ 30 → 44) and its foot is VM-55's
placement exactly, so VM-55's host and inset pins' bounds hold with nothing to spare (the act's foot IS the bar's top);
(4) the line's **look** is read through a closure in its own window's body — observation tracks it as the shell's own
reads do.

### The walk's fixes (part A) — results (implementer: Opus, 2026-11-19)

**Not done, first:** nothing of the four is unbuilt; what is OWED is the evidence — the builds into
`DerivedData/vm47-fix`, the red-on-old snapshot (`~/dev/variorum-vm-47-rolw`, `DerivedData/vm47-rolw`) and the test
windows (the orchestrator's) are PENDING until "FREE TO BUILD" (§4 rows W.7e, W.7g); every "red on old" below is the
pins' design and, for the source rules, measured by script over the trees — the rendered pins' red and green are PENDING
their runs. Not fixed and named for the orchestrator (outside the four findings' classes, or another unit): (1) the faint
on words that are NOT doors (the class W-A9's sweep did not take — listed under W-A9); (2) `Shared/AuthViews.swift`'s
styled Account header still reads the Mac's type slots — its tab words `tokens.heading` and its Close `tokens.small`
(11.5 pt on the phone, under the 13 pt floor) — batch 1's type pass scanned `VariorumMobile/` only, so this shared phone
arm escaped it (its ink is fixed here, its sizes are not: no size changes in this pass); (3) the Account sheet's seven
fields keep iOS's placeholder grey (W-A10, below).

**W-A1 — the grounds stop at the safe area.** *Mechanism, traced:* `MobileShellView.body` is a `GeometryReader` whose
frame is the safe area; its `ZStack` of the three pages took `.frame(width:height:)` at that size and then `.clipped()`.
Every page paints its own ground with `ignoresSafeArea()` — the roots' room (`MobileShelfView`/`MobileLibraryView`/
`MobileStarredView`), the bar's room "down past the home indicator" (`MobileTabBar.body`), the note's paper
(`MobileWriteScreen.body`), the pushed lists' paper (book, Trash, Archived, Versions), Read's room, Protection's room — and
the clip cut each at the safe-area frame, so the status bar's strip, the home indicator's strip and (keyboard up) the band
behind the keyboard's bar and its rounded corners showed the window's own background: white in light, black in dark (which
is why the dark roots passed by coincidence and the dark note did not). The lobby faces are outside the shell
(`VariorumMobileApp`'s other states) and were never clipped. *Fix:* `.clipShape(MobileBandClip())` — a rectangle whose
sides are the band's own (a neighbour one width away still never shows; the drag is untouched) and whose top and bottom
reach two band-heights past the band (more than the status bar, the home indicator or a keyboard ever take from a
portrait phone — the only orientation shipped). Nothing is laid out differently; the message line's own window,
`footOffset` and lift are untouched. *What the fix rests on, said plainly:* that each page's `ignoresSafeArea()` ground
really extends past the band's frame once nothing cuts it — the pin is what proves it. *Pin:*
`MobileScreenEdgeGroundsTests` — the real shell in a window of the test host's SCENE (the device's own insets), its host
in a sentinel colour, rendered (`MobileRenderedPixels.swift`): `onARootTheRoomRunsToBothEdges(dark:)` (the Bookcase's
status-bar and home-indicator strips are the room, light and dark), `inANoteThePaperRunsToBothEdges(dark:)` (a note
opened by the Today door: both strips are the paper), each first reading a pixel inside the safe area that both trees
draw alike (so a dead render or a wrong token fails as itself); `theBandStillDrawsNothingPastItsOwnWidth` (a GUARD for
the kept half: with side insets nothing is drawn beside the band — green before and after; red only for a fix that drops
the sideways clip). Red on old: the sentinel shows in both strips, every case, both appearances — PENDING the snapshot
run. *Swept:* every surface inside the band is the same construct and is covered by the one clip; nothing outside it was
clipped. *Left:* the keyboard bar's own ground (VM-137 owns the bar) — if c8's band behind it is still bare after the
re-capture, that is the bar's.

**W-A3 — Terminal's marker column eats the names at AX5.** *Mechanism, traced:* `MobileShelfView.bookRow` reserves the
voice's selection marker ("› ", Terminal only — Study's is empty) at `.opacity(0)` before each name, so the names align;
batch 1 set it in `rowTitle`, her words' class (full range), so at AX5 the two characters took ≈ 55 pt and the names
read "jo…", "the…", "the…". *Fix:* the column takes `meta` — the layer's own rule: batch 1's role map (P-47-8) puts every
marker (the ★, the ✓ in pickers, the pick marks, ⑂) on `meta`, chrome that holds at xxxLarge, and the wing list's
reserved ✓ column (`MobileWingDoor.wingRow`) is the same construct on `meta`. Chosen over `rowTitle` capped at xxxLarge
because a capped her-words role is no role the layer has. The one visible cost: at the default size Terminal's column
narrows from the 15 pt mono pair to the 13 pt one (≈ 2 pt — names start ≈ 45 pt instead of 47.5). *Swept:* no other root
or list reserves an invisible column — Starred's ★, the block list's ◉/○ and ⑂, and the wing list's ✓ are already
`meta`; Lenses' "› " rides inside the row's own name text (it marks the active row and grows with it, as her words do);
the Library, a book's contents, the Trash and Archived carry no marker column. Noted, another class: Create Book's tag
rows draw their ✓ (`meta`) in a fixed 14 pt frame, narrower than the glyph past the default size (a frame too narrow, not
a column too wide — not touched). *Pin:* `MobileShelfMarkerColumnTests.atAX5TheNameStartsWhereItDoesAtXXXLarge` — the
rendered Terminal shelf with one book; where the name's first ink falls: at AX5 no further right than at xxxLarge
(and at the default no further right than at xxxLarge). Red on old by ≈ 30 pt (the column grew from ≈ 24 to ≈ 55) —
PENDING the snapshot run.

**W-A9 — the corrected faint on doors' words under 17 pt.** *Mechanism, traced:* batch 1 moved `tokens.faint` to
`tokens.phone.faint` one for one; the doors whose words had worn the OLD faint kept the faint's role while sheet §D moved
them up a step ("Words under 17 pt need 4.5:1"; the phone's faint is "glyphs, placeholders, disabled words only").
*Fix — inks only, no size, no word:* the Library/Archive filter row's unchosen words → the corrected muted
(`MobileListingFilters.swift`); the masthead's chips → the sheet's two chip inks (empty date, tags, more info and lens →
the corrected muted; set date, tags and more info → ink; the active lens keeps the accent and a fallback the alarm) — the
edit confined to those four ink arguments in `MobileWriteView` (PROVISIONAL P-47-29: the membership and blocks chips
unchanged). *The sweep — every tappable word under 17 pt in the faint, all fixed where the sheet is unambiguous:*
Note Actions' detail lines (`MobileNoteActions.actRow` — sheet §E's menu row detail is the corrected muted, as the shared
`PhoneMenuRow`'s is); Book Details' three detail lines (archive, delete, finish rows); the link row's "opens"
(`MobileReferences`); Starred's "note"/"book" (`MobileStarredView` — the walk's r01 check expected the faint; by §D it is
the corrected muted now); Create Book's tag paths (`MobileCreateBook.tagRow`); the Account sheet's unchosen tab words
(`Shared/AuthViews.swift`, the styled phone arm only — they wore the voice's OLD faint, 1.9:1). *Left, with the reason:*
glyphs (the block list's ◉/○ — 3:1 is a glyph's floor); the box's hint and its dashed edge (a placeholder, an edge); a
disabled 17 pt door ("Use as Daily Journal" in Book Details); and the faint on words that are NOT doors — outside this
class, though §D's floor and "faint never carries a sentence" cover them too, offered to the orchestrator as one more pass
or a ticket: the applied tag's path and the "Apply a tag" header (`MobileNoteTags`), the sentence, "smart" and the
"Add to a book" header (`MobileMembership` — §A draws that very header in the corrected muted), the file row's note
(`MobileReferences`), the Versions explainer and a moment's meta (`MobileVersions`), the tray's explainer and row meta
(`MobileNoteTray`), the Library's and the Bookcase's empty-state sign-in lines, the box's boundary note and status word
(`MobileQuickNote`), the Archive's promise and the Trash's window note, a nested tag's path in the tag manager, and
Settings' "Starting…". *Pins:* `MobileFaintOnDoorsSourceTests.noDoorsWordsUnderSeventeenPointsWearTheFaint` — a source
rule over every phone view and every shared page's styled arm (a faint read inside a `Button`'s or a `label:` block, on a
role under 17 pt, a glyph-only mark allowed): its patterns measured by script — 13 sites on the tree before (`d974162f4`),
none after; `MobileFaintOnDoorsRenderedTests` — the rendered ink, off the real surfaces' pixels, of each unchosen filter
word (`theFilterRowsUnchosenWordsClearTheFloor`, both voices × light/dark) and each empty masthead chip
(`theMastheadsEmptyChipsClearTheFloor`, light/dark; the set date chip reads above them) at ≥ 4.5:1 — red on old
(3.3–4.2:1) PENDING the snapshot run.

**W-A10 — the search field's placeholder is the system's grey.** *Mechanism, traced:* `phoneField` sets the typed
text's role and ink, but a field built `TextField(title, text:)` hands its title to iOS as the placeholder, drawn in
iOS's placeholder grey; no modifier outside a field reaches it — the prompt is the only public road (the lookup's facts:
`TextField(_:text:prompt:)`, iOS 15+; Apple documents no placeholder-colour modifier). *Fix, in the control's layer:*
`TextField(phonePlaceholder:text:tokens:)` (`Shared/Theme/PhoneControls.swift`) — the words as the field's label
(VoiceOver unchanged) AND as its `prompt:` in the corrected faint; `phoneField` also hands that ink down
(`EnvironmentValues.phoneFieldPrompt`), and the shared `PeekableSecretField` reads it on iOS only (its Mac constructors
unchanged under `#if os(iOS)`). *Each field:* the Library search — covered; the note's tag field — covered; Create
Book's name — covered; every passphrase and twelve-words field on the phone (the lobby's passphrase and words, the
Protection screen's and the protection doors' set, change, reset, check, crossing and look-inside fields — all
`PeekableSecretField` under `phoneField`) — covered; the quick-entry box — already its own hint in the corrected faint;
the comment draft — not this control (a UIKit overlay whose placeholder label reads the corrected muted, VM-152 / VM-189);
the system alerts' fields (rename, entry date, add a link, new chapter, new scrap, new tag, rename book, lens names) —
the system's own alert, not the phone layer; **the Account sheet's seven fields (`Shared/AuthViews.swift`: sign-in
email and password, sign-up email, password and confirm, delete-account password and phrase) — NOT covered**: they are
built by constructors the Mac shares, and giving them a prompt changes the Mac's field construction (`prompt: nil` is
not documented as identical on macOS) — left for a pass with a Mac leg. *Pins:*
`MobileFieldPlaceholderRenderedTests` — the placeholder's rendered ink against the field's own paper, ≥ 3:1, on the
Library search (`theLibrarySearchsPlaceholderClearsTheFloor`, both voices × light/dark) and on a secret field under
`phoneField` (`aSecretFieldsPlaceholderClearsTheFloor`, light/dark) — red on old (1.7–2.5:1) PENDING the snapshot run;
`MobileFieldPlaceholderSourceTests.everyPhoneFieldIsBuiltWithItsPlaceholder` — measured by script: 3 offenders before
(the search, the tag field, Create Book's name), none after.

**The builds** (§4 row W.7e): phone and Mac `build-for-testing` at `a5c08e9f5` into `DerivedData/vm47-fix`, both
`** TEST BUILD SUCCEEDED **`; the snapshot `~/dev/variorum-vm-47-rolw` (detached at `a5c08e9f5`, the 14 app/Shared files
reverted to `273bcec51` and staged — its diff byte-identical to the fixes reversed) built into its own
`DerivedData/vm47-rolw`, `** TEST BUILD SUCCEEDED **`.

**The windows — READY for the stage, PENDING (row W.7g).** The fixed tree, from `vm47-fix` (`-only-testing` by type,
`VariorumMobileTests/<type>`): the six new pins' types — `MobileScreenEdgeGroundsTests MobileShelfMarkerColumnTests
MobileFaintOnDoorsSourceTests MobileFaintOnDoorsRenderedTests MobileFieldPlaceholderRenderedTests
MobileFieldPlaceholderSourceTests` — and every existing suite these changes could move: the shell, the bar, the band and
its mounts (`MobileTabBarTests MobileShellTests MobileNavigationTests MobileRootMenuTests MobileFilterTests
MobileVersionsTests MobileWingDoorTests MobileWingDoorGeometryTests MobileWingDoorShellTests MobileWingListSheetTests`),
the message line (`MobileMessageLineFaceTests MobileLineDoorTests MobileLineShowRuleTests MobileMessageLineGeometryTests
MobileMessageLineHostTests MobileMessageLineInsetTests MobileMessageLineSceneTests`), the shelf and the Library
(`MobileShelfLayoutBrainTests MobileShelfRenderedLayoutTests MobileFilterRowGeometryTests MobilePathLineGeometryTests
MobileLibraryLookTests MobileStarsTests`), the look, controls and type layer (`MobileLookSourceTests
MobilePhoneTypeSourceTests MobilePhoneControlsSourceTests MobilePhoneControlsTests MobilePhoneTypeTests
MobilePhoneInkTests MobilePhoneMetricsTests`), Write's masthead and its sheets (`MobileUndoDoorTests
MobileWriteScrollAuthorityTests MobileReferencesTests MobileNoteTagsTests MobileTagManagerTests MobileBookCreateTests
MobileBookDetailsTests`), and the secret fields (`MobileProtectionCheckTests MobileProtectionCrossingsTests
MobileProtectionPassphraseTests MobileProtectionRoadTests MobileSettingsProtectionDoorTests
MobileProtectionCompositionTests MobileProtectionAccountSectionTests MobileLobbyE6LineTests MobilePreDesignFaceTests`).
The Mac (`Shared/` changed: `PhoneControls`, `PeekableSecretField`, `AuthViews`), from `vm47-fix`:
`VariorumTests/{WordsFieldsConcealTests, PassphraseFloorRoadTests, NoLiteralColourTests, TutorialProtectionRecoveryTests,
SignUpPresentationTests, HostedSyncTierFaceTests, AlertCancelSweepTests, SharedPageStyleTests, ThemeTokenTests}`. The
snapshot, from `vm47-rolw`, the six new pins' types — expected RED: `MobileScreenEdgeGroundsTests`'s two root and two
note cases (the sentinel #FF00FF in the status-bar and home-indicator strips, three points each), its sideways guard
GREEN (it holds the kept half); `MobileShelfMarkerColumnTests.atAX5TheNameStartsWhereItDoesAtXXXLarge` (the name ≈ 30 pt
further right at AX5); `MobileFaintOnDoorsSourceTests` (the 13 sites); `MobileFaintOnDoorsRenderedTests`, all six cases
(the four unchosen filter words at 3.3–4.2:1 in each voice and appearance; the three empty chips at ≈ 3.6–3.9:1 — the set
chip's ordering check holds there too); `MobileFieldPlaceholderRenderedTests`, all six cases (1.7–2.5:1);
`MobileFieldPlaceholderSourceTests` (the 3 sites). Any other red there is a finding to read, not noise.

### The walk's fixes (batch 2) — results (implementer: Opus, 2026-11-19)

**Not done, first:** no test was run and no simulator booted (every window is the orchestrator's); the Mac
`build-for-testing` and the snapshot's re-make and build were HELD by the QUIET window (another run's whole Mac target
on the stage) — PENDING, row W.7q; no rendered floor case for the Account sheet (no phone harness mounts it — it needs
`AppServices`); piece 9 (W-C4) changed NO code — it is a call for her (P-47-30). Ten pieces: the brief's six, then four
more by message (W-C2, W-C3 — landed with piece 2 —, W-C4, W-C7). Every pattern-pin's red-on-old was measured by a
verbatim port of its rule over the tree before the piece; every rendered pin's red and green is PENDING the windows.

**Piece 1 — W-A3's pin still red on the fixed tree (51.3 → 53.3 pt).** *Traced:* between xxxLarge and AX5 the marker
column (`meta`, chrome, held), the row's 8 + 12 pt insets and the 8 pt spacing are identical; the NAME is her words
(`rowTitle`, full range) and keeps growing, and its first glyph's left side bearing grows with it — SF Mono Semibold's
"l" sits 0.0894 em right of its origin (CoreText on the Mac's SF Mono; 0.618 em advance). The pre-fix tree's own
readings (54.0 → 84.3 pt, marker and name both `rowTitle`) fix the two drawn sizes (≈ 19.4 and ≈ 42.3 pt): 0.0894 em ×
22.9 pt = 2.04 pt, the whole 2.0; the five readings (large, xxxLarge, AX5 × both trees) fit one model to 0.05 pt. So the
residue is NOT the column: the pin measured the name's INK where it meant the column's edge. *The pin moved, not
loosened:* `MobileShelfMarkerColumnTests.atAX5TheNameStartsWhereItDoesAtXXXLarge` now subtracts the first glyph's
bearing in the role's own face at the size the row resolves (`PhoneType.resolved` / `baseUIFont`, CoreText glyph
bounds) and compares the name's LAYOUT ORIGIN — AX5 no further right than xxxLarge + 1 pt (the pixel grid). Red on old
by ≈ 28 pt (the column's own growth), level on new. No production line changed (`c72e65201`, compile fix `084f9e066`).

**Pieces 2 + 8 — W-B1 and W-C3: the faint on sentences, headers and labels, ONE sweep (`a21110f9d`).** *Mechanism:*
batch 1's one-for-one `tokens.faint` → `tokens.phone.faint`; W-A9 moved the DOORS' words up, the rest kept the faint.
*Every faint read in the phone tree and `Shared/`'s phone arms, decided by the sheet (§D: "Words under 17 pt need
4.5:1 … Faint never carries a sentence she has to read"; the faint is "glyphs, placeholders, disabled words only"; §A
draws meta lines, explainers and section headers in the corrected muted):* FIXED → `tokens.phone.muted` (19): the
Trash's promise (`MobileTrashView`), the Archive's promise (`MobileArchiveView`), the empty Bookcase's sign-in line
(`MobileShelfView`), the empty Library's sign-in line (`MobileLibraryView`), "Apply a tag" and an applied tag's path
(`MobileNoteTags`), "Add to a book", "Editing here edits the note everywhere it appears." and "smart" (`MobileMembership`
— three named lines of another branch's file), the tray's explainer and its two rows' meta lines (`MobileNoteTray`),
Versions' explainer and the reader's meta line (`MobileVersions`), the file row's note (`MobileReferences`), the box's
hold note and its status word "typing…/saving…" (`MobileQuickNote`), a nested tag's path (`MobileTagManager`),
Settings' "Starting…" (`MobileSettingsView` — one named line). The two status words are words she reads, not a field's
placeholder (the sheet's placeholders are a field's prompt — §D's swatch is the box's "New note", §E's "Hint"), not
disabled and not glyphs. LEFT, by the sheet: the block list's ○ (a glyph, 3:1), the box's hint (a placeholder, 17 pt)
and its dashed edge (an edge), the disabled 17 pt "Use as Daily Journal" (`MobileBookDetails`), the fields' two
placeholder inks (`PhoneControls`). *Pins:* `MobileFaintCarriesNoWordsSourceTests.theFaintCarriesNoWordsUnderSeventeenPoints`
— every faint read that is not an edge/fill, a glyph-only `Text`, a placeholder (`prompt`) or a role at 17 pt or more
(the role found above the read, else just below — a group's role) is the class; measured: 19 sites at `c72e65201`, 0
after (the first batch's door rule is kept beside it); `MobileFaintOnDoorsRenderedTests.theTrashsPromiseClearsTheFloor`
— the promise line's rendered ink ≥ 4.5:1 on the Trash's paper, both voices × light/dark (red on old: the faint,
3.93:1 Study light).

**Piece 3 — W-B3: "Delete Note…" in the system red (`71ccdd4fc`).** *Mechanism:* `MobileNoteActionsSheet.deleteRow`
handed `actRow` a literal `tint: .red`; the phone's no-literal-colour pin looks for `.tint(.red)` and the other modifier
forms, not a hue passed to a parameter. *Fix:* `tint: tokens.alarm` (role `.destructive` kept). *The sweep — every
system colour in the phone tree and `Shared/`'s phone arms:* none other stands where a plain token belongs. Left, each
with its reason: the TK2 fallback canary (`MobileWriteView`, deliberate); the store's opening frame
`Color(.systemBackground)` (`MobileStoreFailureView` — drawn before any library is open, so no library's tokens exist;
the failure face beside it is the deliberately unstyled recovery surface); the callout swatch's `UIColor.separator`
edge (`MobileCallout` — an image in the SYSTEM's menu, edged against that menu's own ground); the shared pages' warning
`Color.orange` on the styled arm (`SharedPageStyle.pageWarning` / `pageCaptionWarning` — no warning token exists, the
seam's own comment records the choice; system orange at 13–15 pt is ≈ 2.2:1 on the paper, under §D's floor — **a
question for her**, not a plain token: the alarm is the error's ink, and a warning ink is a new token); the secret
field's eye glyph `.foregroundStyle(.secondary)` (`PeekableSecretField` — hierarchical: inside `phoneField` it is the
field's ink at the secondary level, not the system's grey; the Mac's arm must stay `.secondary`); system alerts' and
long-press menus' destructive buttons (system-drawn). *Pins:* `MobileLookSourceTests.noPhoneViewPaintsALiteralColour`
extended — a hue passed to a parameter (`: .red`, `? .red`, `= .red`, at an identifier edge) and the UIKit/semantic
system colours (`UIColor.system…`, `Color(.system…`, `UIColor.label`/`secondaryLabel`/…, `separator`, `link`,
`Color.accentColor`), two forms allowed with their decisions (the opening frame, the swatch edge); measured: 1 offender
at `a21110f9d`, 0 after; `MobileNoteActionsAlarmTests.deleteNoteIsDrawnInTheAlarm` — the mounted sheet's Delete Note
row holds a pixel within 0.06 of `tokens.alarm`, both voices × light/dark (red on old: the title is the system red and
the detail line the corrected muted, neither near the alarm).

**Piece 4 — W-B4: two hairlines above Settings (`fb649d6a8`).** *Mechanism:* the body's `VStack(spacing: 14)` draws a
divider after `versionsRow`, then `undoRow`/`redoRow` (nothing while the stack is empty), then `settingsRow`, which
opened with its own divider (VM-53, this run). *Fix:* `settingsRow`'s divider draws only when an undo or redo row
renders above it. Left, never on screen: with no settings door (outside a shell — harness and preview only) the
Versions divider and Delete's still meet. *Pin:* `MobileNoteActionsHairlineTests.betweenTwoRowsThereIsOneHairline` — the
mounted sheet rendered; in each gap between consecutive rows exactly one hairline (runs of non-room pixels in one
column), with the stack empty and with an "Undo Delete Block" row; red on old in the empty state (two between Versions…
and Settings).

**Piece 5 — the Account sheet's styled header on the Mac's type slots (`2345a713a`).** *Mechanism:* `AccountView.header`'s
styled arm set the tab words in `style.tokens.heading` and Close in `style.tokens.small` (11.5 pt on the phone); batch
1's guard walks `VariorumMobile/` only. *Fix (the styled arm only; the Mac's arm byte-identical):* the tab words on the
`tab` role, the current one semibold (the sheet's tab grammar), ink/muted unchanged; Close takes the sheet header's own
closing control (`PhoneTextButtonStyle(closing: true)`: 17 semibold in the accent, a 64 × 44 target), its word kept.
`PhoneSheetHeader` itself does not fit: its title is a header `Text`, while these tabs are doors carrying the selection
trait (CF-14's mechanism kept). *Swept:* no other read of a Mac type slot in any phone arm of `Shared/` (none anywhere
in `Shared/` outside the token layer). *Pin:* `MobilePhoneTypeSourceTests.noSharedPhoneArmReadsTheMacsTypeSlots` — a type
slot read through `SharedPageStyle` (`style.tokens` / `pageStyle?.tokens`; nil on the Mac by construction, so such a
read IS a phone read); measured: 2 at `05afd4b34`, 0 after.

**Piece 6 — the Account sheet's seven placeholders (`c64f23782`).** It CAN be done without changing what the Mac
constructs: two private helpers in `AccountView` — `pagePlainField(_:text:)` and `pageSecureField(_:text:)` — build the
field with `prompt: Text(words).foregroundStyle(style.tokens.phone.faint)` on the styled arm only (`#if os(iOS)` and a
style present); every other arm is the call site's former construction exactly (`TextField(label, text:)`;
`SecureField(titleKey, text:)` with the title as the `LocalizedStringKey` the call site's literal resolved to — no
`prompt:` is ever passed on the Mac, which was the first batch's concern). All seven route through them (`emailField`
through `pagePlainField`). *Pin:* `MobileFieldPlaceholderSourceTests.theAccountSheetsFieldsGiveTheirPlaceholderOnThePhone`
— every Account field under `.pageFieldChrome` is built by a prompting helper and `emailField` builds through
`pagePlainField`; measured: five raw constructors plus `emailField`'s at `2345a713a`, none after.

**Piece 7 — W-C2: a hidden page's search takes the keyboard back (`05afd4b34`).** *Traced:* the Library's search is a
plain `TextField` with NO focus binding of its own; a push over the root (her hit, the Trash) covers it and the keyboard
goes; the tab road (`MobileShellView.tabSelected` → `popToRoot(leaving, animated: false)`, P-47-19) uncovers the root
while its page slides away, and the framework restores the uncovered screen's first responder — the search — so the
hidden Library holds the keyboard over the Bookcase (the bar lifts with it), and its caret is back on return. Which
layer restores (UIKit's navigation or SwiftUI's focus) is not visible from source; the fix does not depend on it. A
plain Back to the Library restores the same way ON screen — a road she sees, kept. *Fix:* the shell's `page(_:)` sets
`EnvironmentValues.mobilePageShowing` (tab == owner; true outside a shell), and the search (`@FocusState`) gives the
keyboard back whenever it holds it while its page is hidden, and when its page leaves the screen. What the search
holds, VM-55's landing and the band are untouched. A possible cost to look for in the re-capture: the hidden field may
take the keyboard for one update before giving it back (a keyboard flicker rather than a keyboard left up). *Pin:*
`MobileHiddenPageKeyboardTests.theTabRoadLeavesNoKeyboardOnAHiddenPage` — the mounted shell in a scene window: the
Library's search focused, the Trash pushed over it, "Bookcase" in that list's bar; then nothing in the window is first
responder and the Bookcase's bar sits at its foot. Red on old IF the harness reproduces the restoration (the walk did);
a green-on-old result would mean the harness does not, and the re-capture carries the evidence.

**Piece 10 — W-C7: the Lenses sheet's bare divider (`c7b6f0459`).** `MobileLenses`' divider above the save doors →
`Divider().overlay(tokens.line)`. *Swept:* 13 `Divider()`s in the phone tree — 11 already wear the line (Settings' row
dividers on their next line), the tag manager's long-press menu divider is the system menu's own separator (exempt),
this one fixed; `Shared/`'s `PageDivider` wears `style.tokens.line` on its phone arm. *Pin:*
`MobileLookSourceTests.everyPhoneDividerWearsTheLine` (exempt: a divider inside `.contextMenu`/`Menu`); measured: 1 at
`fb649d6a8`, 0 after.

**Piece 9 — W-C4: the segmented choice's unchosen words on the system's track (NO CODE — P-47-30).** *Traced:*
`PhoneSegmentedControlBridge.updateUIView` (`Shared/Theme/PhoneControls.swift`) styles the system `UISegmentedControl`
per instance: the words' font and inks (`setTitleTextAttributes`, unchosen the corrected muted, chosen her ink), the
thumb (`selectedSegmentTintColor` = the paper); the TRACK is the system's own drawing, a translucent fill over whatever
is behind it — so the corrected muted reads 4.44:1 on it over the room in light and 4.06 / 4.15:1 over the dark paper,
under §D's 4.5:1 for 15 pt words. *What the control lets one instance set for its track* (the lookup's facts, developer
forums, no Apple statement except for iOS 26): `backgroundColor` does not give the colour set — the control still lays
its own grey layer over it ("Even if you set a clear color, there will be a grey layer"), so it cannot be relied on to
move the contrast; `setBackgroundImage(_:for:barMetrics:)` replaces the system's drawing (with divider images for every
state) — the iOS 12 look by hand, and on iOS 26 a poster reports it "kills liquid glass selection"; an Apple DTS
engineer: "from iOS 26, UISegmentedControl now draws its track and selection using the new design instead of a flat
color fill"; no other public per-instance track API (the rest are private-subview hacks). So the only exact roads are a
hand-built control or a global appearance — neither built, by the brief. The one per-instance road that IS sure — the
unchosen words in ink (one attribute) — changes the chosen/unchosen ink grammar the run built, a look call: hers.
Written up as P-47-30 (§5); the code is as it was.

**The builds** (§4 row W.7q): the phone `build-for-testing` into `DerivedData/vm47-fix`, incremental, after each code
piece — the last at `c64f23782`: `** TEST BUILD SUCCEEDED **` (no warning in a changed file; every commit since is
records only). HELD by the QUIET window, PENDING: the Mac scheme into `vm47-fix` (`Shared/AuthViews.swift` changed);
the snapshot `~/dev/variorum-vm-47-rolw` re-made at this batch's head with all 23 app/Shared files the two fix batches
changed checked out from `273bcec51` and staged (never committed; the tests the fixed tree's), built into its own
`DerivedData/vm47-rolw`.

**The windows — PENDING (the orchestrator's).** The fixed tree, from `vm47-fix`: the new and moved pins
(`MobileShelfMarkerColumnTests MobileFaintCarriesNoWordsSourceTests MobileFaintOnDoorsRenderedTests MobileLookSourceTests
MobileNoteActionsAlarmTests MobileNoteActionsHairlineTests MobilePhoneTypeSourceTests MobileFieldPlaceholderSourceTests
MobileHiddenPageKeyboardTests`), the first batch's six, and every suite these changes could move (the faint sweep's
screens, the note's sheet, Lenses, the shell and the Library's search, the Account sheet's seam, the controls) — the
exact array is in the batch's hand-back and the orchestrator's window record. The snapshot, from `vm47-rolw`, the pins —
expected RED: the marker column's origin ≈ 28 pt further right at AX5; both faint source rules (the first batch's 13
door sites; the sibling's sites); every rendered faint case, the Trash's promise's four included; the literal-colour
rule (`: .red`) and the divider rule (Lenses); Delete Note's four alarm cases; the hairline case with the stack empty
(the undo-row case GREEN — a guard); the shared-arm type rule (2); both field source rules; the first batch's grounds
and placeholder cases; the hidden-page keyboard case (if the harness reproduces the restoration). GREEN on both, by
design: the grounds' sideways guard, `MobileLookSourceTests`' grounds/Read/star tests, `MobilePhoneTypeSourceTests`'
other three tests.

**Re-capture** (the walk's own ids): s4b, b1, r14, r14b, b12, r15 (the promises); r06, r06b, r07b, b8 / r10, b9 (W-C3);
both `s12-note-actions-settings-row` and r09 (W-B3, W-B4); r08 (W-C7); b8–b11 in both combinations (W-C2 — and look for
a one-frame keyboard flicker at b10); the Account sheet has no capture (the walk never opens it — Settings ▸ Sync ▸
Account in both voices would be its evidence). W-A3's list stands (no code changed). W-C4: none (no code).

**PROVISIONAL:** P-47-30 (§5, piece 9). No other new call: every fixed site's ink is the sheet's own (§A/§D), and
piece 5's two type choices are the sheet's tab grammar and the layer's closing control.

**The window's result (the orchestrator's, as it gave it) and its one red.** The snapshot: all twelve pin types RED on
old, as predicted — `theTabRoadLeavesNoKeyboardOnAHiddenPage` included (the harness DOES reproduce the keyboard's
return, so the pin is not hollow), the marker pin's origin 80.6 against 52.2. The fixed tree at `70320b2bb`: 64 of 65
suites green, the marker pin level (49.55 / 49.58 pt), the Mac's ten green. The one red:
`MobileFaintOnDoorsSourceTests.noDoorsWordsUnderSeventeenPointsWearTheFaint` → `Shared/AuthViews.swift:469`, piece 6's
`pagePlainField` placeholder. *Traced:* the first batch's door rule (`insideADoor`) takes any enclosing block whose
opening line holds "label:" for a door — meant for a `Button`'s or a `Menu`'s `label:` closure — and the helper's own
signature, `pagePlainField(_ label: String, text:)`, holds it; the read has no role (`Text(label)`), no glyph, no
edge, so the placeholder's corrected faint — the faint's own use by the sheet — read as a door's word.
(`pageSecureField`'s signature names its parameter `titleKey`, so it was never flagged.) *Fixed the cleaner way, (b),
test-only:* the door rule gains the sibling rule's placeholder exemption — a faint read on a line holding "prompt"
(`prompt:`, `phoneFieldPrompt`) is a field's placeholder, never a door's word. Chosen over (a) — building the plain
helper through `TextField(phonePlaceholder:text:tokens:)` — because the layer has no secure twin, so an inline faint
would stay in `AuthViews.swift` either way, and because (a) would change production code to step round a rule's
misreading where the rule's own class already excludes placeholders (its header: the faint is for "glyphs,
placeholders and disabled words only"). The "label:"-in-a-signature reading is left in the rule (now harmless for
placeholders; a door's word inside such a function would still be caught). Measured by a verbatim port: 13 sites at
`273bcec51` with and without the exemption (the same 13 the first batch recorded), 1 at `70320b2bb` without it, 0 with
it. Production untouched, so no Mac build is owed; the two field rules hold by their own patterns (7 Account fields, 0
offenders; the phone tree unchanged). Phone `build-for-testing` into `vm47-fix`: `** TEST BUILD SUCCEEDED **`. The
re-run of `MobileFaintOnDoorsSourceTests` rides the orchestrator's next window.

### Batch 7 — results: the re-land of main (implementer: Opus, 2026-11-19)

**Not done in this batch, first:** no test of any kind ran here, no simulator was booted and the stage was never
claimed — every suite (the arrays below, then the whole-target gate) is the orchestrator's window, PENDING;
the new pin's red-on-old is PENDING too (a snapshot recipe below). Nothing of VM-64 is in this batch (its own
small merge of main reaches this branch by message, later). No guard was edited; no hard-line file was resolved
by hand (none conflicted).

**The merge.** `git merge --no-ff origin/main` at main's tip **`a09d6a025`** ("board snapshot"; VX-981's PR and
VM-78's PR #15 `f909d6714` with its closeout ledgers), into this branch at `c75e4229b` (batch 7's first, a
LIVE STATUS commit); merge base `eb18888db`; 273 commits, 145 files. The merge commit: **`4866c7fb8`** (parents
`c75e4229b`, `a09d6a025`); its message carries the per-file log (kept while the merge was open in the gitignored
`notes/plans/vm-47-screens/b7-reland-log.md`). Four content conflicts — exactly the trial's
(`git merge-tree --write-tree`) and the map's. The other 141 files merged clean: VX-981's Mac MCP door and
Core/`VariorumMCP` sources, VM-78's phone models (`MobileShelfFaces`, `MobileShelfViewModel`, `MobileTrashModel`,
`MobileUndoDoor`, `MobileBlockHistory`, `MobileTutorialSeeder`, `MobileEditorViewModel`), its `Shared/` words
(`BookStateCopy`, `ArrivalsCopy`, `CollectReceiptCopy`, `RecoveryCopy`, `StructuralUndoCopy`, `ShelfOrder`,
`BookcaseBoard`), both runs' tests, the ledgers and canon (main's text; this branch never edited them).

**The rule** (VM-78's round-4 map, `notes/plans/fixes/vm-78-ladder-round4.md` "The map, final", read as written):
in every hunk the READS and WORDS are VM-78's and the STYLING this run's. **One call the map's quoted text does
not settle, settled by its own governing sentence** ("The styling is VM-47's in every file"): the map was drawn
on this run's trial tree before the walk's fixes, so where it quotes an ink it quotes this run's PRE-walk ink —
the faint on the date chip's empty arm, on the gathering's kind mark, on the finish caption and on the pause
sentence. The walk moved each of those to the corrected muted (W-A9, `a5c08e9f5`; W-B1/W-C3, `a21110f9d`) and two
of this run's rules hold that move; the resolution takes this run's LATEST styling. Measured: the map's literal
inks red `MobileFaintOnDoorsSourceTests` on 3 lines and `MobileFaintCarriesNoWordsSourceTests` on 4. Not a
PROVISIONAL (no product choice — the styling is this run's by the map's rule, and the latest is the one its
guards hold).

**The four files — the decisions** (in full: the merge message):

| File | Hunks | What stands |
|---|---|---|
| `Write/MobileWriteView.swift` | 1 (`dateChip`) | VM-84's `let day = Self.dateChipDay(model)` — the OBSERVED `entryDate`, never `header` — in this run's `.phoneType(.chip)` and W-A9's chip inks (set: ink; empty: the corrected muted); `day` used; the seed and `dateChipDay` kept; no `.header?.entryDate` in the file |
| `Shell/MobileCreateBook.swift` | 2 + one function | `kindRow` is this run's `PhoneSegmentedChoice` speaking VM-83's `MobileCreateBookModel.kindLabel` ("Gathering"); this run's `kindWord` ("Smart Book", outside the hunk) DELETED; the no-tags line VM-83's `noTagsLine` on `meta` in the corrected muted |
| `Write/MobileMembership.swift` | 2 + one restyle | a member row's name VM-21's `memberRowName` ("(archived)") on `rowTitle`; its mark VM-83's `kindMark` ("gathering") on `meta` in the corrected muted; Diverge stays inside VM-81's `if rowCarriesDiverge(book)`, restyled there (below); the add rows and the collect line VM-78's |
| `Shell/MobileBookDetails.swift` | 4 + one restyle | `deleteRow(_ kind:)`: VM-83's `deleteDoorTitle(for: kind)` (title and label) and R2-N1's hint on `control` + `PhoneMenuRowStyle`; `finishRow`: VM-81's row whole inside `if let act = finishRowAct(for:)` (`requestFinish` / `setFinished(false)`, the hoisted verbs, `finishCaption` at three lines, label and hint) on `control` / `meta` in the corrected muted, `PhoneMenuRowStyle()` on the Button inside the `if let`; the Unarchive row restyled (below) |

**The three lines no hunk shows — restyled, roles named.** (1) The Unarchive row's verb, `.font(tokens.body)` →
`.phoneType(.control, tokens)`: it is a menu row's label (sheet §E: "the label `control` 17"; batch 1's map,
P-47-8, `control` over `rowTitle` for a door's word), the role its three siblings on the same sheet wear (Finish,
Archive, Delete). (2) Its pause sentence, `.font(tokens.small)` + `tokens.faint` → `.phoneType(.meta, tokens)` +
`tokens.phone.muted`: the menu row's detail line (§E: "`meta` 13 in the corrected muted"; W-A9's rule — a door's
words under 17 pt never wear the faint), its three-line cap kept. Its `.buttonStyle(.plain)` → `PhoneMenuRowStyle()`
(the map's restyle; its siblings' row, the 44 pt floor). (3) The Diverge button, `.font(tokens.small)` +
`.foregroundStyle(tokens.muted)` + `.buttonStyle(.plain)` → `.buttonStyle(PhoneInlineActStyle(tokens: tokens,
tone: .muted))` — the inline act (`controlInline` 15, a 44 × 44 hit area), batch 2's own style for this same
button and its Remove neighbour — on the Button INSIDE the `if`; the `if` stays. No read or word of either side
was put back to quiet a scan.

**Auto-merged files both runs touched, read whole** (`comm` of the two runs' `--name-only` diffs under
`App/Variorum/`): `Shell/MobileLibraryView` (main: three comments), `Shell/MobileShelfView` (main: the row's act
table drawn in the system long-press menu, the kind-aware delete confirm and its held title), `Shell/MobileTrashView`
(main: VM-33's empty line only after the listing answers, drawn through this run's `emptyLine`; the gathering's
empty-name word), `MobileDeletionTests`, `MobileLivenessTests`, `MobileShellTests` — each a clean join, NOTHING
changed in any of them. Every styling line main added to phone code (a grep of its `+` lines for fields,
dividers, buttons, fonts, styles, inks, paddings, frames, colours) sits in the four files above; main's other
phone files and its `Shared/` files draw nothing.

**The rules — before and after** (each suite's own patterns, ported verbatim to the gitignored
`notes/plans/vm-47-screens/b7-drafts/rules.swift`; the port validated against the record's counts — at
`273bcec51` the door rule 13, the field rule 3, the Account rule 6, the shared-arm type rule 2, the divider 1, the
literal colour 1; at `fe85ea6d5` the sub-13 rule 32; the type-slot rule there 328 by the test's own Swift
`Regex`, whose `\b` is the Unicode word boundary, where the record's 332 was an ASCII grep — the merged tree is 0
by both). "Raw merge" = the four files' hunks resolved by the map, nothing outside them; outputs
`vm-47-screens/b7-scans-before.txt`, `b7-scans-after-7.1.txt`:

| Rule (suite · test) | Raw merge | This tree |
|---|---|---|
| `MobilePhoneTypeSourceTests` · Mac type slots | 3 — `MobileMembership.swift:350` (Diverge), `MobileBookDetails.swift:549`, `:554` (Unarchive) | 0 |
| `MobilePhoneTypeSourceTests` · shared phone arms · sub-13 / caption / scale factor · the walk | 0 · 0 · ok | 0 · 0 · ok |
| `MobilePhoneControlsSourceTests` (both) | 0 | 0 |
| `MobileLookSourceTests` (all six: grounds, Read, Write on the paper incl. `backgroundColor = face.paper`, ★, literal colour, dividers) | 0 | 0 |
| `MobileFaintOnDoorsSourceTests` | 1 — `MobileBookDetails.swift:555` (the pause sentence) | 0 |
| `MobileFaintCarriesNoWordsSourceTests` | 1 — the same line | 0 |
| `MobileFieldPlaceholderSourceTests` (both) | 0 | 0 |
| main's `MobileNoteEntryDateTests.noPhoneFaceReadsTheEditorsUnobservedHeaderDate` (G1) | 0 (3 on this branch's pre-merge tip) | 0 |
| main's `MobileGatheringWordTests.noPhoneStringLiteralSaysSmart` (G2) | 1 — `MobileCreateBook.swift`: "Smart Book" (`kindWord`) (5 on the pre-merge tip) | 0, both exemptions matched once |

**`MobileMembershipSheetFaceTests` (mounted), checked by reading against the merged sheet:** the archived book's row
draws `Text(tokens.chromeLabel(memberRowName(for:)))` — "Old projects (archived)" under `.studyLight`
(`chromeLabel` lowercases only in Terminal); the gathering's row draws "Quotes" and the mark `kindMark` →
`MobileShelfFaces.gatheringWord`, "gathering"; no literal or drawn word says "smart"; Diverge is drawn inside
`if rowCarriesDiverge(book)` — the book's row only — through `PhoneInlineActStyle`, whose body draws the Button's
one label once, so "diverge" appears exactly once; the premise (`books` = "Old projects", "Quotes") is the model's,
untouched. Every assertion holds by reading; its run is the window's.

**The tests that move: NONE.** Read for a premise the join changes: this run's tests that host what VM-78
changed — `MobileFaintOnDoorsRenderedTests.theMastheadsEmptyChipsClearTheFloor` (the set date chip — it now reads
the observed `entryDate`, which a Today note carries: the premise holds, more robustly), `MobileTabBarTests`' three
Trash walks (they find the Trash by `emptyTrashLine` after `settle(40)`; VM-33 draws it only once the listing
answers, and VM-78's own `anEmptyTrashSaysSoOnceTheListingAnswers` holds that `settle(40)` is enough — the premise
holds), `MobileDeletionTests` (merged with VM-78's own `deleteDoorTitle(for:)` edit); VM-78's tests that host what
this run restyled — `MobileFinishConfirmTests`, `MobileBookStateRowTests`, `MobileGatheringWordTests`,
`MobileMembershipSheetFaceTests` find doors by accessibility label and hint, which no style of this run changes
(`PhoneMenuRowStyle` and `PhoneInlineActStyle` wrap the label, never re-label it). No assertion was touched.

**One new pin, where the join made a fact no pin of either run holds:** `MobileBookDetailsJoinRowsTests.
anArchivedBooksRowsEachAnswerTheMenuRowsFloor` (new file `VariorumMobileTests/MobileBookDetailsJoinRowsTests.swift`,
both voices): on an archived book's Book Details, the Finish, Unarchive and Delete Book… rows each answer at least
the menu row's 44 pt floor. Why: VM-78's Unarchive row met this run's layer only in the join, by a hand restyle
no hunk showed; the type scan and the faint rules hold its role and its ink, nothing held its target. Red on the
raw merge by construction (a `.plain` button answers at its word's own line); its red-on-old is PENDING a
snapshot: this tree with `unarchiveRow`'s four styling lines put back to the raw merge's (`.font(tokens.body)`,
`.font(tokens.small)`, `tokens.faint`, `.buttonStyle(.plain)`), phone `build-for-testing`, the one type.

**Builds** (headless, one at a time, into `App/Variorum/DerivedData/vm47-fix`, no QUIET window open):
- Phone `build-for-testing` (`-scheme VariorumMobile -destination 'generic/platform=iOS Simulator'`), on the merge
  tree BEFORE its commit: 20:11:52–20:12:54, `** TEST BUILD SUCCEEDED **`, 0 errors, no warning in the four files
  (the four, `MobileBookFixesTests`, `MobileMembershipTests`, `MobileUndoDoor(Tests)` and Core's `UndoStack`
  among the compiled sources) — then the merge committed (`4866c7fb8`) and pushed. No compile error to fix: the
  map's resolutions compiled as written.
- Mac `build-for-testing` (`-scheme Variorum -destination 'platform=macOS'`) at `4866c7fb8`: 20:13:45–20:17:03,
  `** TEST BUILD SUCCEEDED **`, 0 errors (VX-981's Mac and Core changes beside this run's `Shared/` theme layer).
- Phone again with the new pin (`9147929f7`): two compile errors in the new file only, each fixed before its
  commit (a `+`-joined `#expect` comment — the macro wants one literal; `accessibilityFrame` needs `import UIKit`
  under `MemberImportVisibility`), then 20:18:12–20:18:27 `** TEST BUILD SUCCEEDED **`, no warning in the file.
  The Mac scheme does not compile the phone test target, so no Mac rebuild is owed for it.
- Logs: the gitignored `notes/plans/vm-47-screens/b7-phone-build1.log`, `b7-mac-build1.log`, `b7-phone-build3.log`.

**The stage window (the orchestrator's — nothing here has run):**
From `App/Variorum/`, `test-without-building -derivedDataPath DerivedData/vm47-fix` at `9147929f7` (the code of
every later commit — records only), `-only-testing` by type; every type below checked declared exactly once as a
suite type in its target.

(a) The phone, BEFORE the whole-target gate — main's three guards, this run's six rules, the new pin, every suite
of the four conflict files and of the both-touched auto-merged files, the shell, bar and message line, VM-78's
suites over these faces (64 types):
```zsh
phone=(MobileNoteEntryDateTests MobileGatheringWordTests MobileMembershipSheetFaceTests
MobilePhoneTypeSourceTests MobilePhoneControlsSourceTests MobileLookSourceTests MobileFaintOnDoorsSourceTests
MobileFaintCarriesNoWordsSourceTests MobileFieldPlaceholderSourceTests MobileBookDetailsJoinRowsTests
MobileFinishConfirmTests MobileBookStateRowTests MobileArchivedStarredBookTests MobileShelfOrderTests
MobileShelfRowActsTests MobileCollectReceiptTests MobileBookDetailsTests MobileBookCreateTests
MobileBookNameGuardTests MobileMembershipTests MobileNoteRenameTests MobileDeletionTests
MobileRefusalSentencePinTests MobileNoRawErrorPinTests MobileErrorLogPrivacyPinTests MobileLineDirectionTests
MobileFaintOnDoorsRenderedTests MobileFieldPlaceholderRenderedTests MobileWriteScrollAuthorityTests
MobileUndoDoorTests MobileUndoWarningWordsTests MobileNoteActionsAlarmTests MobileNoteActionsHairlineTests
MobileTrashTests MobileShellTests MobileLivenessTests MobileTabBarTests MobileNavigationTests MobileRootMenuTests
MobilePathLineGeometryTests MobileShelfMarkerColumnTests MobileShelfLayoutBrainTests MobileShelfRenderedLayoutTests
MobileLibraryLookTests MobileFilterRowGeometryTests MobileFilterTests MobileStarsTests MobileMessageLineFaceTests
MobileLineShowRuleTests MobileMessageLineGeometryTests MobileMessageLineHostTests MobileMessageLineInsetTests
MobileMessageLineSceneTests MobileLineDoorTests MobileWingDoorTests MobileWingDoorGeometryTests
MobileWingListSheetTests MobileWingDoorShellTests MobileWingStandTests MobilePhoneControlsTests
MobileScreenEdgeGroundsTests MobileHiddenPageKeyboardTests MobileBlockHistoryTests MobileWalkTests)
```
`xcodebuild test-without-building -scheme VariorumMobile -destination 'id=<the standing device>'
-derivedDataPath DerivedData/vm47-fix $(for t in $phone; do print -- "-only-testing:VariorumMobileTests/$t"; done)`.
Expected: all green, with the declared known issues only — `MobileTrashTests`' empty-tree diagnostic
(`anEmptyAccessibilityTreeIsDiagnosedRatherThanReadAsAnAbsentDoor`, ×2 in batch 6's run) and P-47-7's four
filter-row marks (`MobileFilterRowGeometryTests`); main's tutorial pair was unwrapped by VM-3 and is not in this
list. VM-24's caret test is not in the list (the gate carries it). Any other red is a finding to read.
The new pin's red-on-old (optional, by the brief's rule for a new pin): a snapshot of this tree with
`MobileBookDetails.swift`'s `unarchiveRow` set back to the raw merge's four styling lines (`.font(tokens.body)`;
`.font(tokens.small)` + `.foregroundStyle(tokens.faint)`; `.buttonStyle(.plain)`), phone `build-for-testing` into
its own folder, `-only-testing:VariorumMobileTests/MobileBookDetailsJoinRowsTests` — expected RED on the Unarchive
row in both voices (Finish and Delete green: they wear the menu row on both trees).

(b) The Mac, beyond the gate's whole target — the targeted leg for the join (this run's theme layer under
VX-981's new and changed Mac faces for the first time; VM-55's Mac pins; VM-78's Mac word pins) (25 types):
```zsh
mac=(ThemeTokenTests PaletteDerivationTests NoLiteralColourTests SharedPageStyleTests PaletteReachTests
MarkdownPaletteWritersTests HelperWindowThemeTests AppearanceChoiceTests VX176LibraryTintTests WingPaletteDoorsTests
BadgeFamilySplitTests PrivateMarkFaceTests JournalPrivateFaceTests MCPShowOfferFacesTests MCPDoorErgonomicsFacesTests
MCPWingFacesTests ShelfModelTests PromoteAndPaletteTests UndoWarningWordsTests DeadVocabularyTests
GatheringKindWordTests VM56MacWingScopePinTests VM61MacStatusSeamPinTests VM62MacRefusalWordsPinTests
VM63MacWingBrainsHoistPinTests)
```
`xcodebuild test-without-building -scheme Variorum -destination 'platform=macOS' -derivedDataPath
DerivedData/vm47-fix $(for t in $mac; do print -- "-only-testing:VariorumTests/$t"; done)`. Then the gate: the
whole phone target and the whole Mac target on this tree.

**PROVISIONAL:** none new. **Self-assessment — the risks in the join, ranked:**
1. **The map's quoted inks vs this run's latest** (the one place the resolution departs from the map's literal
   text): taken by the map's own governing rule and measured (the literal inks red two of this run's rules on 4
   lines). A reader who holds the map's text over its rule would call these four lines wrong; they are the walk's
   fixes, kept.
2. **VM-33's Trash timing under this run's shell walks.** `MobileTabBarTests`' three Trash walks find the Trash by
   `emptyTrashLine` after `settle(40)`; on the merged tree that line draws only once the listing answers. VM-78's own
   hosted Trash holds `settle(40)` as enough, but through the shell's push the first value may land later — if one
   of those three reds on "the Trash arrived", it is timing in the test's premise, and the move is to wait for the
   line (the fact it protects), never to drop the check.
3. **VM-78's hosted Book Details and membership tests under this run's styles for the first time**
   (`MobileFinishConfirmTests`' two hosted cases, `theBookDetailsRowsSpeakTheirCaptionsAsHints`,
   `MobileMembershipSheetFaceTests`, `bookDetailsDeleteLineNamesAGathering`). They find doors by label and hint, which
   `PhoneMenuRowStyle` and `PhoneInlineActStyle` do not touch (one label, `opacity` only), so they should hold; they
   have never run on this styling.
4. **The Unarchive row's new height.** `PhoneMenuRowStyle` gives the row a 44 pt floor and full width; with a living
   book's three-line pause sentence the row is taller than before — a look change on a VM-78 row, by this run's
   layer, the walk has not seen (the run's one walk predates the join).
5. **The Mac**: compiled green; VX-981's new Mac faces have never run beside this run's hoisted `ThemeStore` —
   the targeted leg (b) and the gate's whole Mac target are the evidence.


**The targeted window's one red, and the class (row 7.7).** *The window (the orchestrator's, on the re-landed tree,
as relayed):* the phone leg ALL GREEN — 373 tests in 64 suites, main's two guards, `MobileMembershipSheetFaceTests`,
this run's rule suites and the join pin (both cases) among them; the Mac leg 161 tests in 25 suites, ONE red:
`BadgeFamilySplitTests.theWindowsHandTheSyncedSwitchToTheRoad()` (`BadgeFamilySplitTests.swift:164`) — "The file
"ThemeStore.swift" couldn't be opened because there is no such file". *The trace:* its line 177 read the theme
store's SOURCE from the Mac app's folder, `Variorum/Theme/ThemeStore.swift`; that line has stood since VX-934
(`d44e207e7`, 2026-11-08 — on main before this run's base); this run's batch 3 moved the file to
`App/Variorum/Shared/Theme/` (`dc9a5fd05`, VM-51's hoist, 2026-11-19 07:29). So THIS RUN broke it, not the join:
the red has stood since batch 3, and batch 3's Mac leg (the types that construct or read the hoisted store) never
held it because this test reads the store's source and never constructs it; batch 6's 114 types did not include
it either; main's only change to the file (VX-1007, `:345`) is elsewhere. The two strings the assertion wants stand
in the moved file (`ThemeStore.swift:70` `try Queries.themeSettings(db)`, `:72` `settings = value`). *The fix*
(`3c960718a`, test-only): the store's source is read where it lives — `#filePath` → `App/Variorum` → `Shared/Theme/
ThemeStore.swift`, the way `FollowDoneNoticeTests` reaches `Shared/`; the assertion and its strings unchanged.

*The class — every source path a test opens or names, checked by script over this merged tree* (the gitignored
`notes/plans/vm-47-screens/b7-drafts/paths.py`; both app test targets and the core package's `Tests/`): 858 string
literals that look like paths; 629 name a source file or folder (bare `.swift` names, which the walks match by
file name, and paths with a `/`); 591 resolve; the 38 that do not are each read: 6 are DELIBERATE ABSENCE checks —
a test asserting a retired file stays gone (`SignInFlow.swift`, `SyncCredentialsStore.swift`,
`FollowingSessionProvider.swift`, `Features/Shelf/WingSwitcherMenu.swift`, `Variorum/ProtectionStatusRow.swift`,
`Variorum/Features/Protection/LibraryWordsCard.swift`); 6 are present but written with a leading slash the
script's suffix test does not resolve (`/Features/Write/MobileEditorViewModel.swift`, `/Spike/` ×3,
`/Features/Perf/` ×2); and 26 are test fixtures, URLs, a file extension, a package name (`GRDB.swift`) or a
planted file, none a source path. **No test names a path that is missing by accident.** *Then every file THIS RUN
moved, split or deleted* (`git diff --name-status --diff-filter=RD -M origin/main...HEAD` + the record's list), each
test that names it or walks the folder it left:

| What moved | The test | Verdict |
|---|---|---|
| `ThemeStore.swift` → `Shared/Theme/` | `BadgeFamilySplitTests:177` (reads its source) | WRONG — fixed, `3c960718a` |
| the same | `VM61MacStatusSeamPinTests` / `VM62MacRefusalWordsPinTests` (walk `Variorum/` + the `hoistedMacBrains` register, "the next hoist adds its file") | HOLDS today: neither rule's patterns hit `ThemeStore` (no `status.removal(` / `.withdraw(owner:` / `status.placement =` / `.phoneLine`, no `OpsRefusalCopy`/`DeletionRefusal`/`VersionActs` road), so the move took no matched line out of the walk. NOT ADDED to the register: `VM63MacWingBrainsHoistPinTests` holds every listed brain fork-free (no `#if os(`, no SwiftUI), and `ThemeStore` forks by design (batch 3's `#if os(macOS)` arm, `import SwiftUI`), so adding it would red VM-55's guard, and changing that guard is not this batch's. Recorded, left: a later edit to `ThemeStore`'s Mac arm is no longer seen by those two walks |
| the same | `MarkdownPaletteWritersTests` arms one and two (walk `Variorum/` for the markdown palette's writers and builders) | HOLDS, correctly: `ThemeStore` never wrote `MarkdownStyling.palette` nor built a palette (checked on main's copy before the move); `Shared/` holds those words in doc comments only |
| the same | the other Mac walks that read `Variorum/` only (`ChromeLineLimitTests`, `DeadVocabularyTests`, `GlyphRainTests`, `TourTests`, `MCPIconTwinsTests`, `MCPAsksWaitTests`, `MakeMineRoadTests`, `WordsBandTests`) — every literal and regex pattern in the 29 walking test files matched against the moved code | HOLDS: no pattern hits a code line of `ThemeStore` (it holds no string literal and no view) beyond common words |
| `AppearanceChoice`'s pure enum → `Shared/Theme/AppearanceChoiceRule.swift` | `MarkdownPaletteWritersTests.appearanceIsAppWide` (`:109` — the named appearances only in `Theme/AppearanceChoice.swift`; no `preferredColorScheme(` / `.environment(\.colorScheme` override) | HOLDS, and WHY it passes: it walks `Variorum/` only, and the one `NSAppearance.init(named:)` stayed in the Mac's `Theme/AppearanceChoice.swift` (`:108`, `NSApp.appearance`); the split moved only the AppKit-free half (the cases, the key, `remembered`, `isDark`, the phone's `userInterfaceStyle` behind `#if os(iOS)`), which holds none of the patterns. Checked across `Shared/`, `Variorum/` and `VariorumMobile/`: no other named appearance, no colour-scheme override; the phone's window override (`MobileAppearance.swift`) is not compiled into the Mac. The rule never walked `Shared/` (that gap predates this run) |
| the same | `AppearanceChoiceTests`, `MobileSettingsListTests.theAppearanceWordsAreTheMacsOwn` (reads `Variorum/Features/Settings/AppearanceChoiceRow.swift`) | HOLDS: the row file is where it was, and its three `Text("…").tag(AppearanceChoice.…)` match the phone's words ("Follow system", "Light", "Dark") |
| `VariorumMobile/Theme/MobileVoicePreference.swift` deleted | `MobileLibraryLookTests.theRetiredVoicePreferenceIsReadNowhere` (walks `VariorumMobile/`) | HOLDS: the walk covers the folder the file was in; grep: no code line anywhere (`Shared/`, `Variorum/`, `VariorumMobile/`) reads `mobile.themeVoice` or `MobileVoicePreference` |
| the private builds this run retired (the 11 names gone from the product: `fallbackVoice`, `joinDoor`, `kindDoor`, `lineBottomPadding`, `lineTopPadding`, `MobileVoicePreference`, `onSettings`, `smallLineHeight`, `storedVoice`, `tabDoor`, `voiceRow`) | every test naming one | HOLDS: the only test hits are the absence scan above and a doc comment (`MobileShelfLayoutTests:484`); the inline builds batch 2 retired are held by `MobilePhoneControlsSourceTests`' signatures, measured 0 at 7.3 |
| this run's own path lists (`MobilePhoneControlsSourceTests`' `Shared/Theme/SharedPageStyle.swift` and `allowedCards`, the faint rules' `Theme/PhoneInks.swift`) | — | HOLD: each path exists |

*Build:* Mac `build-for-testing` into `DerivedData/vm47-fix` at `3c960718a`, 21:54:49–21:55:44, `** TEST BUILD
SUCCEEDED **`, `BadgeFamilySplitTests.swift` recompiled, no warning in it (log `vm-47-screens/b7-mac-build2.log`).
No phone test file changed, so no phone build is owed. *To re-run* (the orchestrator's window, from
`DerivedData/vm47-fix`): the Mac — `-only-testing:VariorumTests/BadgeFamilySplitTests` (the red's suite, all its
cases), and with it the two whose walks the sweep read as holding: `VariorumTests/MarkdownPaletteWritersTests`
`VariorumTests/VM61MacStatusSeamPinTests` `VariorumTests/VM62MacRefusalWordsPinTests`
`VariorumTests/VM63MacWingBrainsHoistPinTests` (all five green in the window except the red; the re-run is the
fix's evidence); the phone — none.

### W-A1 redone — the band's clip restored, the grounds painted by the shell (implementer: Opus, 2026-11-19 night)

**Not done, first:** no test was run (every run is the orchestrator's — "The windows" below), no re-capture was shot (owed —
"The re-captures owed"), no Mac build (no `Shared/` file changed). `MobileTabBar.swift`, `MobileEditorTextView.swift`,
`MobileEditorViewModel.swift`, `MobileKeyboardBar.swift` and `Shared/` are untouched. Pieces: `5daf61efd` (the code),
`9f0dc1229` (the pins), `b1e345be0` (the UI test; both builds green), §4 rows W.10–W.10f.

**Why.** The first fix (`67525b499`) gave W-A1 its result by letting each page's own ground run past the band —
`.clipShape(MobileBandClip())`, a clip free above and below — and with the grounds it let every page's CONTENT out:
- **W-E4** (the serious one): with the software keyboard up, a mid-note tap no longer moves the note above the keyboard —
  0 pt where main moved it 146 pt (Study) / 118 pt (Terminal), on three roads, both voices. The orchestrator's settling
  capture on the first fix's app, Study light: the editor's frame (0, 283, 402 × 557) before the tap at (201, 561.5),
  402 × 256 after it (ending at 539) — so the text view DOES shorten to the keyboard; what is missing is the scroll that
  brings the caret's line into it; the keyboard's frame (0, 583, 402 × 233), the bar's block cell at 496.7; no caret above
  the bar; a typed "x" lands in the text (it grew by one) and nowhere on the visible page.
- **W-E3**: her prose ran behind the keyboard bar's glass cells and was cut at the keyboard's top.
- **W-F1**: on a scrolled page (a book's Read page) her words ran up under the status bar.
Still inferred, not traced: how the band's clip feeds UIKit's caret reveal (the guess stands — over hosted UIKit content
`.clipped()` is a clipping ancestor at the band's frame, which shrinks to the keyboard bar's top, where the shape clip was a
mask that marked nothing as covered). The redo does not need that road traced: it puts the one line back, and the UI test
holds the road itself.

**What makes the reveal main's again (by reading; the proof is the UI test).** Main's band is `GeometryReader { ZStack { the
three pages } .frame(…) .clipped() .contentShape(…) .coordinateSpace(…) .simultaneousGesture(…) }`; the redo's band is that,
line for line — `git diff origin/main -- …/MobileShellView.swift` shows no change from the `.frame(width:height:)` line
through the gesture, the clip's comment included. What the redo adds sits outside the clipped subtree or moves nothing:
(1) a `.background` on the `GeometryReader` — behind the band, never inside its clip, and a background never changes the
size of the view it backs, so the band's frame (the safe area, shrinking to the keyboard bar's top) is main's; (2) three
environment values per band page and one on each stack's root and each destination — values, no views; (3) one
`.mobileEdgeGrounds` modifier per page — appear/disappear/change hooks, no view and no frame. The band's clip is the one line
on the reveal's road that differed between main and the first fix (the trace: nothing else on that road moved), and it is
main's again.

**The painting** (`App/Variorum/VariorumMobile/Features/Shell/MobileEdgeGrounds.swift` — its header is the full statement).
- *Who declares:* each page, in its own body, `.mobileEdgeGrounds(top:bottom:)` — a page knows its ground; the shell never
  guesses one from the route. A no-op outside a shell (harness mounts, previews).
- *The road:* an environment board, `MobileEdgeGroundsBoard` (held by the shell as `@State`; the board and the band page set
  per page in `page(_:)`; "at root" set true on each stack's root and false, explicitly, on every destination in `stack(…)`) —
  declared at a page's appearance, revised when its grounds change, withdrawn at its disappearance. NOT a SwiftUI preference,
  by design: a preference's reduce sees every mounted page of all three stacks — both band neighbours, and a root still
  mounted under a pushed screen — with no order SwiftUI documents between a stack's root and its destinations, and whether a
  custom preference crosses a `NavigationStack`'s per-screen hosting at all is undocumented (the lookup: nothing from Apple,
  only iOS 13-era `NavigationView` reports). The orchestrator's brief named a preference; this is the deviation, and why.
- *Who paints:* the shell — `MobileEdgeGroundsLayer`, the band's `.background` (`MobileShellView.body`): its top half the
  showing page's top ground carried up past the status bar, its bottom half the bottom ground carried down past the home
  indicator and the keyboard (`ignoresSafeArea(.all, edges: .top / .bottom)` — never the sides, so the guard pin holds); the
  halves split at the band's middle, inside the band at any portrait keyboard height; no hit testing, hidden from
  accessibility.
- *What wins* (`MobileEdgeGroundsBoard.showing`, pure, pinned in `MobileEdgeGroundsBoardTests`): only the CURRENT band page's
  stack (`tab`); while that stack stands at its root (`pagingAllowed`) its root's declaration; otherwise its NEWEST pushed
  screen still declared, and the root's until a freshly pushed screen has declared; nothing declared: the room.
  - a push: the arriving screen from its first appearance; a pop to the root: the root as the path empties (before the
    popped screen's disappearance); a pop between pushed screens: the one below at the popped screen's disappearance;
  - a tab change from a pushed list: the leaving stack pops to its root unanimated, then the band slides — both pages are
    roots; a band swipe: only roots page (the root-surfaces-only rule; a hidden stack always stands at its root,
    P-47-19); every root declares the room at both edges, so neither shows a mismatch;
  - a sheet over a page: the strips belong to the presenting screen, dimmed with it by the system.
- *The bottom strip and the bar:* wherever a bar stands at the foot (`barOnScreen` — VM-55's re-land's own fact: a root, or
  a pushed list wearing its bar) the bottom strip is the bar's ground, `tokens.room` — the bar draws its room inside the band
  down to the band's foot (`MobileTabBar.body`, unchanged; clipped there as on main) and the painted strip continues it from
  the foot to the screen's edge. One token on both sides of the band's edge: no seam; one hairline, the bar's own at its top.
- *With a keyboard up:* the band ends at the keyboard bar's top (main's); behind the bar's glass cells, the keyboard's
  rounded corners and the keyboard is the painted bottom strip — Write's paper in a note; the room on a root (the bar rides
  above the keyboard there); nothing of her prose is drawn behind the bar.

**What each page declares** (top / bottom):

| Page | Top | Bottom |
|---|---|---|
| Bookcase · Library · Starred (roots) | the room (the path line's band) | the room (the bar's — the shell paints the bar's room while it stands) |
| A book's contents · Trash · Archived (pushed lists) | the paper (`tokens.surface`, the whole page) | the paper (under its bar, the shell's bar room shows) |
| Versions | the paper | the listing's paper (under its bar: the room); while a moment is read, the room — the reader's verbs band sits on the room at the foot |
| A book's Read page | the voice's own room (`ReadingPageTokens.room`, never the palette's) | the same |
| Write (and its three UIKit overlays, inside it) | the paper | the paper |
| Protection | the room | the room |
| anything undeclared | the room (the shell's fallback) | the room |

**What the painted layer cannot do, said plainly.**
1. *One colour per strip across the width.* During a push or a pop between pages whose grounds differ (a root's room and a
   list's or a note's paper), the strip takes the arriving page's ground at its first appearance (a push) or the root's as the
   path empties (a pop to the root), and does not slide with the pages: for the slide's ≈ 0.35 s the part of the strip above
   the outgoing page wears the incoming page's ground. The first fix had each page's ground slide with it. It is never the
   window's white or black, never a band neighbour's, never a page that has left the stack. (A crossfade was not built — it
   would show a third colour neither page wears.)
2. *The Read page's foot.* The cream page is scroll content, so it ends at the band's foot again — its last visible line cut
   at the band's edge (≈ 840 pt), exactly as on main (the twins' "the card flat at 840, its line cut mid-glyph"); the
   re-capture's F7 ("no line is cut") is given back by design, and the strip below is the Read page's room. Any page whose
   content scrolls to the foot is cut at the band's edge the same way (as on main).
3. *A cancelled interactive swipe-back between two PUSHED screens* (Versions over its note; a note over a book's contents):
   SwiftUI documents no appear/disappear sequence for it (the lookup — nothing reliable). If the screen below re-appears at
   the swipe's start and no disappearance follows the cancel, the strips wear the lower screen's grounds while the upper one
   shows — a wrong colour in a strip, never content. Between a root and a pushed screen it cannot happen (the root wins only
   while the path is empty). The bar's own `listBarsShowing` count (VM-55's re-land) rests on the same pairing.

**The pins and their matrix.** `MobileScreenEdgeGroundsTests` (its three first-fix pins byte-for-byte unchanged — only the
file's header was brought up to the redo) + `MobileEdgeGroundsBoardTests` (new). The no-content pins read a strip as ONE
ground: no pixel more than 0.03 a channel from the strip's commonest colour (the walk's faintest ghost under the status bar
was ≈ 0.12); each first proves her words ARE right inside the band's edge (ink ≥ 3:1 there), so none can pass on an empty
page. The Read page is reached through the shell's own doors — the long book's Bookcase row, then the contents' Read door in
the navigation bar, driven by each road a bar door answers to in turn (accessibility activation, the control's actions, the
bar item's action) with the arrival proven every time: a door that cannot be driven in process fails the pin by its own
message, never passes it. Columns: the FIRST FIX = 3c960718a's app code; the REDO = `b1e345be0`; MAIN'S BAND = the redo with
its painted layer removed — the band byte-for-byte main's (main's own tree cannot host these pins: they read this run's
settings → tokens road, `router.tokens(dark:)`, which main does not have).

| Pin | First fix | Redo | Main's band |
|---|---|---|---|
| `onARootTheRoomRunsToBothEdges(dark:)` ×2 (unchanged) | green | green | **RED** (the sentinel) |
| `inANoteThePaperRunsToBothEdges(dark:)` ×2 (unchanged) | green | green | **RED** |
| `theBandStillDrawsNothingPastItsOwnWidth` (unchanged, the guard) | green | green | green |
| `onAPushedListThePaperRunsUpAndTheBarsRoomDown(dark:)` ×2 (new — the Trash; back on the root, no stale paper) | green | green | **RED** |
| `onTheReadPageItsOwnRoomFillsBothStrips(dark:)` ×2 (new — what Read declares) | **RED** (the foot: the cream page and her lines ran on) | green | **RED** |
| `aScrolledPagesWordsStayOutOfTheStatusBar(dark:)` ×2 (new — W-F1) | **RED** | green | green |
| `aPagesWordsStopAtTheBandsFoot(dark:)` ×2 (new — the band clips its content at its foot) | **RED** | green | green |
| `MobileEdgeGroundsBoardTests` (7, new — the rule) | — (no board there; removed from that snapshot) | green | green |
| `MobileKeyboardRevealUITests` (the UI test, below) | **RED** | green | green |

All PENDING the orchestrator's runs. (The "band clips its content" check the brief offered as mounted or rendered is the
rendered one: `aPagesWordsStopAtTheBandsFoot` at the foot and `aScrolledPagesWordsStayOutOfTheStatusBar` at the top.)

**The snapshot recipe** (each a detached worktree, never this one; its own DerivedData; staged there, never committed):
```zsh
# THE FIRST FIX — the redo's tests over 3c960718a's app code (the only app commits since are the redo's three):
git -C ~/dev/variorum-vm-47 worktree add --detach ~/dev/variorum-vm-47-rolx b1e345be0
cd ~/dev/variorum-vm-47-rolx
git checkout 3c960718a -- App/Variorum/VariorumMobile        # the shell's clipShape line, MobileBandClip, the pages as they were
git rm -q App/Variorum/VariorumMobile/Features/Shell/MobileEdgeGrounds.swift \
          App/Variorum/VariorumMobileTests/MobileEdgeGroundsBoardTests.swift
git diff --cached --stat     # expect: MobileShellView + the ten pages reverted, the two files removed — nothing else
cd App/Variorum && xcodebuild build-for-testing -project Variorum.xcodeproj -scheme VariorumMobile \
  -destination 'generic/platform=iOS Simulator' -derivedDataPath DerivedData/vm47-rolx
# the UI test's red needs the same tree's app: also
xcodebuild build-for-testing -project Variorum.xcodeproj -scheme TK2SpikeUITests \
  -destination 'generic/platform=iOS Simulator' -derivedDataPath DerivedData/vm47-rolx
# MAIN'S BAND — the redo with its layer removed (a second snapshot, or the first reset to b1e345be0):
git -C ~/dev/variorum-vm-47 worktree add --detach ~/dev/variorum-vm-47-rolm b1e345be0
cd ~/dev/variorum-vm-47-rolm && python3 - <<'PY'
p = 'App/Variorum/VariorumMobile/Features/Shell/MobileShellView.swift'
s = open(p).read()
a = s.index("        // VM-47 (the walk's W-A1, redone): the strips BEYOND the band")
b = s.index("        // VM-61: the one message line — its own overlay window over this")
open(p, 'w').write(s[:a] + s[b:])
PY
git diff --stat              # expect: MobileShellView.swift, 13 lines out (the comment and the .background block)
cd App/Variorum && xcodebuild build-for-testing -project Variorum.xcodeproj -scheme VariorumMobile \
  -destination 'generic/platform=iOS Simulator' -derivedDataPath DerivedData/vm47-rolm
```
On each: `-only-testing:VariorumMobileTests/MobileScreenEdgeGroundsTests` (and on main's band `…/MobileEdgeGroundsBoardTests`);
the UI test from the first fix's snapshot with the line below and `-derivedDataPath DerivedData/vm47-rolx`. Remove both
snapshots after (`git worktree remove`).

**The UI test — `App/Variorum/VariorumMobileUITests/MobileKeyboardRevealUITests.swift`** (`b1e345be0`; the orchestrator's
added piece). One method, `testAMidNoteTapRisesAboveTheKeyboard`, self-contained (the walk driver's proven helpers copied in,
not depended on): the hardware keyboard detached at its start, the lobby's once-shown cards passed (the twelve words never
captured), the pocket guide opened through Settings' Debug door (seeded when missing), its long lesson "swipe & choose" by the
Library's search; the editor tapped at its centre. PREMISE asserted: the tap's y below the keyboard bar's top (the bar's
block cell's top less its 10 pt of air, never below the keyboard's own top — ≈ 486.7 on the orchestrator's frames, against
the tap's 561.5); one re-tap 40 pt below the bar's top if not; else INCONCLUSIVE. A software keyboard with a real height is
asserted (else FAIL "no software keyboard" — never a pass). THE FACT, from the screen's own pixels (XCUITest cannot read a
caret rect; the pixel scale is measured, pixels ÷ points, never assumed): S0 once the keyboard has settled, S0b 0.6 s later
with nothing typed (the control), S1 after ONE letter (the keyboard's own key, else `typeText`); only the band from the
editor's top to the bar's top is read; S1 must differ from BOTH S0 and S0b there by at least a glyph (≥ 30 px spanning
≥ 4 pt — a caret's blink is 1.7 pt), while the control may differ by no more than a caret (≤ 3 pt wide) and the band's top
60 pt may not differ between S0 and S1 at all (a page that changes by itself or moved fails as INCONCLUSIVE). It cannot pass
when the letter is hidden: under the keyboard nothing above the bar changes, so both differences are empty — RED. The three
screenshots and the frames and difference rows are kept as attachments (and printed "REVEAL …"). Cleanup runs BEFORE the
assertions: the letter deleted when proven landed (the text grew by one) — one unproven delete, said so, when the text
cannot be read — the lesson's text checked back as it was, the keyboard dropped by a drag (never Return), Back.
- Run (from `App/Variorum/`, under a held stage claim, on a DEDICATED simulator, never the shared suite device):
  `xcodebuild test-without-building -project Variorum.xcodeproj -scheme TK2SpikeUITests -destination 'id=<the dedicated
  simulator>' -derivedDataPath DerivedData/vm47-fix -only-testing:VariorumMobileUITests/MobileKeyboardRevealUITests`
- Red recipe: the first fix's snapshot above (its app is what the UI-test scheme builds and launches).
- **Re-run it** on any change to the shell band's clip or frame (`MobileShellView.body`), the Write screen's layout
  (`MobileWriteView`), or the editor host's keyboard handling (`MobileEditorTextView`), and with the per-release device
  checks (TEXTKIT2_NOTES §5). It is not part of the unit targets' whole-run gates.

**The windows (READY — the orchestrator's; from `DerivedData/vm47-fix`, built at `b1e345be0`).** Phone,
`-only-testing:VariorumMobileTests/<type>` for each of:
```zsh
phone=(MobileScreenEdgeGroundsTests MobileEdgeGroundsBoardTests
  MobileShellTests MobileTabBarTests MobileNavigationTests MobileRootMenuTests MobileFilterTests MobileVersionsTests
  MobileStarsTests MobileLivenessTests MobileVoiceTests
  MobileMessageLineFaceTests MobileLineDoorTests MobileLineShowRuleTests MobileMessageLineGeometryTests
  MobileMessageLineHostTests MobileMessageLineInsetTests MobileMessageLineSceneTests
  MobileWingDoorTests MobileWingDoorGeometryTests MobileWingDoorShellTests MobileWingListSheetTests MobileWingListingTests
  MobileShelfLayoutBrainTests MobileShelfRenderedLayoutTests MobileShelfTodayDoorTests MobileShelfMarkerColumnTests
  MobilePathLineGeometryTests MobileFilterRowGeometryTests MobileLibraryLookTests MobileLibraryTests MobileTrashTests
  MobileReadTests MobileWriteLatchTests MobileWriteScrollAuthorityTests MobileHiddenPageKeyboardTests
  MobileLookSourceTests MobilePhoneTypeSourceTests MobilePhoneControlsSourceTests
  MobileFaintOnDoorsSourceTests MobileFieldPlaceholderSourceTests MobileFaintOnDoorsRenderedTests
  MobileProtectionCompositionTests MobileProtectionReceiptsTests)
```
(`MobileLookSourceTests`, `MobilePhoneTypeSourceTests`, `MobilePhoneControlsSourceTests` are the three source rules; the
redo's lines were written against `MobileLookSourceTests`' grounds patterns — no pushed page gains a room ground line, Read
keeps `ReadingPageTokens.room(` and no `.background(tokens.room`, Write no room. `MobileProtectionCompositionTests` and
`MobileProtectionReceiptsTests` hold source rules over the shell's file; `MobileTabBarTests.theRouteRuleIsTheDestinationBuilders`
reads the destination builder, which the redo did not touch.) Then the UI test, the line above. No Mac run: no `Shared/` file
changed.

**The re-captures owed** (the walk's kept device, both voices where the surface has a face, light and dark): the roots — c1
(the Bookcase), c3 (the Library), r01 (Starred) — their status-bar and home-indicator strips the room; a pushed list — b1 (the
Trash), b4 (a book's contents), r15 (Archived) — the paper above, the bar's room below, one hairline; Write — c5 at rest (the
paper at both strips) and c8/c9 with the keyboard up (the paper behind the keyboard bar's cells and the keyboard's corners,
NO prose behind the bar — W-E3 — and the caret above the bar — W-E4, which the UI test also holds); the Read page — b5/r04 at
rest (its room above and below; the cream page cut at the band's foot, as on main) and r04b scrolled (nothing of her words in
the status bar's strip — W-F1); the Versions reader — b9 (the room under its verbs band); Protection — b13/s03b (the room at
both strips); a sheet over a root — w1 or r05 (the dimmed room in the strips); and one push and one pop caught mid-slide
(the strip's switch, approximation 1) if the driver can catch it.

**Risks, as I see them.**
1. *The Read door in process.* No suite before these pins drove a navigation-bar door in the unit-test host; the helper tries
   three roads and proves arrival each time — if all three fail in the host, the three Read pins fail by their own message
   ("the Read page did not arrive …"), never pass; the remedy would be a different road to the page, not a looser pin.
2. *The first fix's red for the no-content pins rests on `drawHierarchy` drawing the scroll's content beyond the band as the
   screen did* (F7, F8 were screen captures). If the host renders the iOS 26 scroll-edge effect stronger than the screen, the
   status-bar pin's red on the first fix could be weaker; the foot pin does not pass under that effect (no edge effect at the
   foot of a bar-less page).
3. *The UI test's "page moved" guard* could fail as INCONCLUSIVE on the redo if typing at a caret flush with the band's foot
   made UIKit scroll again by a few points (Terminal's reveal lands the caret's line exactly at the bar's top). It would say so
   in its own words, with the rows; it cannot pass falsely.
4. *Approximation 3* (a cancelled swipe-back between two pushed screens) is unpinnable in process and undocumented; a strip
   colour only.
5. *The keyboard bar's top* is read from its block cell (`kbar.block`) less 10 pt; if VM-137 moves the bar's cells, the
   test's band edge moves with them (it reads the frame live), but the 10 pt of air is a constant of today's bar.

### Batch 7b — results: the second and last re-land of main (implementer: Opus, 2026-11-19 night)

**Not done in this batch, first:** no test of any kind ran here, no simulator was booted and the stage was never
claimed — every suite below is the orchestrator's window, PENDING. The moved tests' and the one added door's red is
reasoned, not run. No guard was edited; no hard-line file was resolved by hand (none conflicted; the merged tree equals
main's under `Sources/`, `Server/`, `Shared/EditorBrain/`, `VoiceTokens.swift`, `MobileEditorViewModel.swift`, the
shared ledgers, canon and the skills, and differs from main in `MobileEditorTextView.swift` by exactly this run's one
authorized line, `backgroundColor = face.paper` at `applyVoiceChrome`). Phase 1 (the reading and the trial) was done
read-only while the W-A1 redo was live in this worktree; the merge began at the orchestrator's "MERGE NOW", on a clean
tree after `git pull --rebase`.

**The merge.** `git merge --no-ff origin/main` at main's tip **`64fde83b0`** ("board snapshot", over VM-64's ledgers
`151d8a80f` — notes only — over VM-64's merge `982405967`, PR #16), into this branch at `7fa3b76a3` (7b's LIVE STATUS,
over the W-A1 redo's `b1e345be0`); merge base `a09d6a025`; 188 commits. The merge commit: **`3d55b51f6`** (parents
`7fa3b76a3`, `64fde83b0`); its message is the per-file log (kept while the merge was open in the gitignored
`notes/plans/vm-47-screens/b7b-reland-log.md`). Four content conflicts — exactly the trial's (`git merge-tree
--write-tree`, re-run on the current tips after the W-A1 redo landed: no change) and the coordinator's maps' (the
gitignored `vm-47-screens/b7b-maps.md`; VM-64's map for `MobileLibraryView.swift` relayed word for word). The rule, the
maps': this run's styling, VM-64's reads, calls, tasks and words; no modifier unwrapped or dropped. The other 78 files
merged clean (VM-64's Core timing layer, `StructuralFlightFence`, `Operations+Variant`, `OwnerIdentity`, `Migrations`
v1_38, `IdleCommit`, `LibraryPaging`, `ShelfQueries`; `Shared/` `AppBootstrap`, `AppServices`, `AppSession`,
`AppTiming`, `AutosaveCoordinator`, `SyncSession`; its phone models and tests; the ledgers and canon — main's text).

**The four files — the decisions.**

| File | Hunks | What stands |
|---|---|---|
| `.gitignore` | 1 | both lines, each with its comment: this run's `notes/plans/vm-47-screens/`, then VM-64's `notes/plans/vm64-screens/` |
| `VariorumMobileApp.swift` | 1 | VM-64's `init()` (`:57`–`:60`) — `MobileTiming.start()` (`:58`) BEFORE `_bootstrap = State(initialValue: AppBootstrap())`, so `bootstrap` is declared unassigned (`:29`) — above this run's lobby doc comment and `lockedTokens` (VM-51, P-47-15). Auto-merged and checked: on background `MobileTiming.appLeaving()` (`:270`), `let leaving = mobileScenePhaseChanged(…)` (`:271`), and `Task { await leaving.value; MobileTiming.saveNow() }` (`:275`–`:279`) |
| `Shell/MobileSettingsView.swift` | 1 | this run's grouped list (VM-53) whole. The hunk's other side is the old flat stack, whose ONLY change on main — checked by a diff3 of base vs main inside the hunk — is the Timing… door; re-made inside the Diagnostics group after "Edit trace…", in that door's own shape: `PhoneMenuRow(tokens.chromeLabel(MobileTimingCopy.door), tokens:, inset: PhoneMetrics.gutter) { timingPresented = true }` + `.accessibilityLabel("Open the timing readout")` (`:402`–`:405`) — its word and label VM-64's, its hairline the group's, its ink the group's rows' (ink; main drew it in the accent beside the edit trace's accent door, which this run moved to the row in batch 5). Auto-merged: `@State private var timingPresented` (`:67`) and `.sheet(isPresented: $timingPresented) { MobileTimingView(tokens: tokens) }` (`:203`–`:205`) |
| `Shell/MobileLibraryView.swift` | 1 | this run's W-A1-redo declaration `.mobileEdgeGrounds(top: tokens.room, bottom: tokens.room)` (`:133`), then VM-64's one hold task (`:139`); the two old tasks do not come back. `git diff HEAD` of the file after the merge is exactly main's VM-68 lines |

**VM-64's seven items in `MobileLibraryView.swift`, each where it stands in the merged file** (written out here because
the maps file is gitignored):
1. **The on-screen fact.** The stored property `var isOnScreen: Bool = true` with its doc (`:66`–`:71`); the shell
   passes it (`MobileShellView.swift`, `isOnScreen: libraryOnScreen(width: width)`, merged clean). KEPT.
2. **The two lets read in the body**, so the view's key is observed: `let hold = model.hold(onScreen: isOnScreen)`
   (`:85`) and `let holdsScraps = isOnScreen && model.filter == .scraps` (`:86`). KEPT.
3. **The tasks.** ONE task holds the listing: `.task(id: hold) { await model.hold(hold) }` (`:139`), replacing
   `.task(id: model.sort) { await model.startAll() }` and `.task { await model.startBookless() }`, which are gone (a
   grep of the file: neither call appears). The scraps task keyed on `holdsScraps` — `.task(id: holdsScraps) { if
   holdsScraps { await scraps.start() } }` (`:146`–`:148`), not on `model.filter`. VM-55's `.task(id: [model.wingID,
   query]) { await model.search(query) }` (`:150`) as it was. KEPT.
4. **The next page.** On every note row's button, beside this run's styling (`.phoneType`, the corrected muted,
   `.phoneHitArea`): `.onAppear { if let listing = model.shownListing { model.rowAppeared(item.postID, in: listing) }
   }` (`:519`–`:521`) — the only ask for the next page. KEPT.
5. **The star's second call.** In the row's long-press Star button: `let stars = stars` / `let model = model`
   (`:528`–`:529`), then a Task that awaits `stars.toggle(target, from: .library)` (`:531`) and THEN calls
   `model.rowStarLanded()` (`:534`). KEPT — and **held by reading only**: no pin drives the row's button
   (`MobileLibraryRowActsTests` drives the model's door; VM-241 owns always-run tests for that kind).
6. **Nothing else of VM-64's in the view.** The row's delete confirm calls `model.confirmDeleteNote(item)`
   (`:163`–`:164`); rows are drawn only through `model.rows(books:)` (`:488`) and the model's empty-line fact
   `model.emptyListing(booksShown:)` (`:463`) — no read of `model.all` or `model.bookless` in the file (grep). KEPT.
7. **VM-64's doc comment** above `listingRows`, "VM-68 — the NOTE half is a page, never a cap…" (`:437`–`:441`), word
   for word. KEPT.
This run's own lines stand: the placeholder initializer `TextField(phonePlaceholder: tokens.chromeLabel("Search notes,
books…"), text: $query, tokens: tokens)` (`:240`); the search's `@FocusState` and its release on a hidden page through
`mobilePageShowing` (`:76`–`:79`, `:251`–`:257`); the page's edge-ground declaration (`:133`); every row's roles and
inks.

**The both-changed files that merged clean** (computed: changed on this branch since the base ∩ changed on main since
it, under `App/Variorum/` — exactly the map's nine plus the four): `Protection/MobileRoadFaces`,
`Shell/MobileListingFilters`, `Shell/MobileQuickNote`, `Shell/MobileShellView`, `Write/MobileMembership`,
`Write/MobileNoteTags`, `Write/MobileWriteView`, `MobileWingDoorTests`, `MobileWingsTests`. For each, `git diff HEAD`
after the merge carries exactly main's +/- line set (by script), and each was read for a clean merge that is wrong:
NONE, nothing changed. Main's lines there are marks, reads and tasks — no styling: the lock screen's
`MobileTiming.lockScreenAppeared()`; the box's `AppTiming` marks (inside this run's restyled box, its
`.onChange(of: focused)` whole); the shell's `isOnScreen:` argument, `MobileTiming.homeAppeared()` and
`libraryOnScreen(width:)` beside this run's edge-grounds board in `page(_:)` and main's `.clipped()` (the W-A1 redo's);
Write's timing marks, VM-70's hold and release, and VM-69's `refreshChip()` tasks on this run's restyled chips — the
sheets' own `.task { await model.refresh() }` still stand (`MobileNoteTags.swift:196`, `MobileMembership.swift:340`), so
"the sheet reads those on appear" holds; two doc lines; VM-64's `holdLibraryAsItsViewDoes` helper. Main's other phone
files (`MobileLibraryViewModel`, `MobileShellBand`, `MobileLine`, `MobileStructural`, `MobileUndoDoor`, the editor
model) were changed by main only.

**VM-64's new faces on this run's layer** (styling only; behaviour and every word VM-64's):
- *The readout, `Perf/MobileTimingView.swift`* — in its sibling's shape (`MobileEditTraceView`, which batch 1 and 2
  moved): the header `PhoneSheetHeader(tokens.path(["Settings", "timing"]), tokens:, titleInk: tokens.phone.muted) {
  dismiss() }` (`:180`; was an `HStack` of the path in `tokens.small` + `tokens.muted` and a `.plain` "Done" in
  `tokens.small`); the empty line `.phoneType(.meta)` in the corrected muted (was `tokens.small` + `tokens.muted`); the
  readout's text `.phoneType(.meta)` in ink (`:195`; was `.system(.caption, design: .monospaced)`, 12 pt — the edit
  trace's lines took exactly this move); Copy, Refresh, Reset `PhoneInlineActStyle(tokens:, tone: .accent / .accent /
  .muted, role: .control, alignment: .leading)` (`:213`, `:221`, `:231`; were `tokens.small` + an ink in `.plain`
  buttons). The role call is written into P-47-8 (§5). Kept: `MobileTimingCopy` whole ("Timing…", the headings, the
  rows — "Commits per leaving", "Commit tries" — the footer), "Done", the three accessibility labels.
- *Its Settings door* — the menu row above.
- Nothing else of VM-64's draws on the phone (a grep of main's `+` lines under `VariorumMobile/` and `Shared/` for
  fonts, inks, buttons, styles, paddings, frames, dividers, fields and colours: every hit is in these two files).

**The rules — before and after** (the batch-7 port, `vm-47-screens/b7-drafts/rules.swift`, copied to
`vm-47-screens/b7b-drafts/rules.swift` and brought up to the rules as they now stand: the one change since the port is
ladder round 3's R3-n1, `1306a9f07` — both faint rules' placeholder exemption narrowed to `prompt:` and
`\.phoneFieldPrompt` — applied verbatim; nothing else in the rule files changed since). "Raw merge" = the four files
resolved by the maps, the readout as main drew it. Outputs `vm-47-screens/b7b-scans-before.txt`,
`b7b-scans-after.txt`:

| Rule (suite · test) | Raw merge | This tree |
|---|---|---|
| this run's six rule suites (`MobilePhoneTypeSourceTests` ×4, `MobilePhoneControlsSourceTests` ×2, `MobileLookSourceTests` ×6 incl. the literal colour and the divider, `MobileFaintOnDoorsSourceTests`, `MobileFaintCarriesNoWordsSourceTests`, `MobileFieldPlaceholderSourceTests` ×2) — as written | 0 | 0 |
| main's `MobileNoteEntryDateTests.noPhoneFaceReadsTheEditorsUnobservedHeaderDate` · `MobileGatheringWordTests.noPhoneStringLiteralSaysSmart` | 0 · 0 (both exemptions matched once) | 0 · 0 |
| the same rules with their `Features/Perf/` exemption LIFTED (a measurement only — the rules are unchanged) | 8: the type-slot rule 6 (`MobileTimingView.swift:178, 184, 197, 218, 227, 238`, `tokens.small`), the sub-13 rule 1 (`:201`, the caption style), the controls rule 1 (`:183`, a private "Done" header) | 0 |

*Why the lifted row:* every one of this run's source rules exempts `Spike/` and `Features/Perf/` as "the two debug
harnesses", and VM-64 put a Release-shipped face — the readout, P-65-1 — into `Features/Perf/`. So the rules as written
cannot see it; it was measured with the exemption lifted, and is clean. **Left for the orchestrator (not done — a
guard's scope is not this batch's to change):** narrowing the exemption to the DEBUG-only files (`MobilePerfFixtureSeeder`;
`MobileTiming.swift` draws nothing) so the readout stays held, or ticketing it; until then nothing pins the readout's
roles. **[7b.7, the orchestrator's call — DONE, `d78853d8e`, test-only]** The exemption is narrowed, failing safe: one home, `MobileSourceRuleScope` (in `MobilePhoneTypeSourceTests.swift`), asked by all six rule suites — `Spike/` stays exempt as a folder, and a `Features/Perf/` file is SCANNED unless named in `exemptFiles` with its reason (today only `MobilePerfFixtureSeeder.swift`: its door is DEBUG-only, it draws nothing); no pattern changed, and the type rule's walk check now asserts the same exclusion through the scope plus that `MobileTimingView.swift` is walked.
Measured (the port with the narrowed exemption, `vm-47-screens/b7b-scans-narrowed.txt`): the raw merge 8 offenders, all in the readout (the six type slots, the caption, the private "Done") — red on old; this tree 0. Files now scanned that were not: `Features/Perf/MobileTimingView.swift` (the Release readout, presented outside `#if DEBUG`) and `Features/Perf/MobileTiming.swift` (compiled in every build, draws nothing) — the walk 88 → 90 files.
Phone `build-for-testing` into `vm47-fix`, incremental, 00:13:53–00:14:11, `** TEST BUILD SUCCEEDED **`; the stage window's arrays are unchanged (the six rule suites are in (a)) and now run from the products at `d78853d8e`.
The path sweep (`b7b-drafts/paths.py` — the batch-7 script with the UI-test folder added — and a suffix resolver,
`b7b-drafts/resolve.py`; output `vm-47-screens/b7b-paths.txt`, `b7b-paths-resolved.txt`): 860 path-like literals in the
four test folders; after resolving at a base and by path suffix, 150 unresolved, each class read — the same six
deliberate absence checks as batch 7 (`SignInFlow.swift`, `SyncCredentialsStore.swift`,
`FollowingSessionProvider.swift`, `Features/Shelf/WingSwitcherMenu.swift`, `Variorum/ProtectionStatusRow.swift`,
`Variorum/Features/Protection/LibraryWordsCard.swift`), `GRDB.swift`, `planted.swift`, a bare `.swift` extension, and
the rest fixtures (document and key-file names, crash reports, volume paths). **No test names a source path missing by
accident**; VM-64's tests add none.

**`MobileLibraryPagingTests`, read against the merged view.** `theTwoHundredAndFirstNoteIsReachableByScrolling` mounts
the view alone (`isOnScreen` defaults true) — `.task(id: hold)` holds the first page and each note row's `.onAppear`
(item 4) asks for the next while it scrolls: holds. `theBooklessDoorListsEveryLooseNote` sets `filter = .bookless`
before mounting, page 5 — the hold key is the Bookless question, the rows `model.rows(books:)`: holds.
`aNoteMintedWhileTheLibraryIsAwayIsListedWhenSheReturns` mounts the shell, which opens on the Bookcase (the Library
hidden: `libraryOnScreen` false, nothing held), mints, then `activate("Library")` — the tab's word is "Library" on both
trees; the return flips the key and re-asks: holds. `aWingSwitchedWhileTheLibraryIsAwayIsHonouredOnTheReturn` walked
away with `activate("Shelf")` — **on this tree the tab's accessibility label is "Bookcase"** (`MobileTabBar.word(.shelf)`,
her LK-5/SW-1, VM-52) and the driver matches a label exactly, so that step would have found no door: MOVED (below). Its
next steps hold: on the Bookcase root the wing door's label is the wing's name, "Home" (`MobileWingPath`), only the
current page's elements are in the tree, and the list's row "Work" switches; the return re-asks under the new wing's key.

**The tests that move** (`9fcf7b7a2`, test-only; the reason in the commit):
- `MobileLibraryPagingTests.aWingSwitchedWhileTheLibraryIsAwayIsHonouredOnTheReturn` (`:243`) and the gated speed
  suite's `MobileHerPathsPerfTests.typingInTheBoxWakesTheOffScreenLibrary` (its return loop, `:850`): `activate("Shelf")`
  → `activate("Bookcase")`, the messages and every assertion unchanged — the premise the join changes is the tab's word,
  and the fact each protects (the Shelf page's tab door is chosen) is the same. The precedent: VM-55's pins moved the same
  way at batch 6. A scan of all thirteen of VM-64's phone test files for words or symbols this run changed (the tab's
  word, Settings' doors, the retired builds, the router's old initializer): no other hit.
- One door added to this run's own pin, where the join made a fact no pin of either run holds:
  `MobileSettingsListTests.everyDoorIsAWholeRowAtLeastFortyFourTall` now holds "Open the timing readout" beside its three
  doors (both sizes). On main's styling (a `.plain` button, 4 pt above and below, the Mac's caption) the row answers far
  under 44 and at its word's width — red there by construction; that red is a snapshot away (this tree with the door set
  back to main's button), the orchestrator's if wanted.

**Builds** (headless, one at a time, into `App/Variorum/DerivedData/vm47-fix`, no QUIET window in force):
- Phone `build-for-testing` (`-scheme VariorumMobile -destination 'generic/platform=iOS Simulator'`) on the merge tree
  BEFORE its commit: 23:59:34–00:00:47, `** TEST BUILD SUCCEEDED **`, 0 errors, no warning in a touched file — then
  the merge committed (`3d55b51f6`) and pushed. No compile error to fix.
- Mac `build-for-testing` (`-scheme Variorum -destination 'platform=macOS'`) at `3d55b51f6`: 00:01:50–00:04:16,
  `** TEST BUILD SUCCEEDED **`, 0 errors.
- Phone again with the moved tests (`9fcf7b7a2`): 00:05:01–00:05:18, `** TEST BUILD SUCCEEDED **` (one warning in a
  touched test file, `MobileSettingsListTests.swift:130`, pre-existing — the same line at `:125` before the edit).
- `TK2SpikeUITests` `build-for-testing` (`'generic/platform=iOS Simulator'`; the branch holds
  `VariorumMobileUITests/MobileKeyboardRevealUITests.swift`): 00:05:28–00:05:39, `** TEST BUILD SUCCEEDED **`.
- Logs: the gitignored `vm-47-screens/b7b-phone-build1.log`, `b7b-mac-build1.log`, `b7b-phone-build2.log`,
  `b7b-uitest-build1.log`.

**The stage window (the orchestrator's — nothing here has run).** From `App/Variorum/`,
`test-without-building -derivedDataPath DerivedData/vm47-fix` at `9fcf7b7a2` (every later commit is records only),
`-only-testing` by type; every type below checked declared exactly once as a suite type in its target.

(a) The phone, BEFORE the whole-target gate — `MobileLibraryPagingTests` first; the suites of the four conflicted
files and of every both-changed file; VM-64's suites over those faces (the readout, the paging rules, the wing
listing, the row acts, the box's timing, read-once, the hold, the leaving, the fence); this run's rule suites and
main's two guards; the shell, bar, message line, Settings and Protection (81 types):
```zsh
phone=(MobileLibraryPagingTests MobileLibraryPagingRulesTests MobileLibraryRowActsTests MobileLibraryTests
MobileLibrarySortTests MobileFilterTests MobileEmptyStoreTests MobileDeletionTests MobileStarsTests MobileLibraryLookTests
MobileFilterRowGeometryTests MobilePathLineGeometryTests MobileHiddenPageKeyboardTests MobileFaintOnDoorsRenderedTests
MobileFieldPlaceholderRenderedTests MobileSettingsListTests MobileSettingsProtectionDoorTests MobileAppearanceTests
MobileTimingTests MobileEditTraceTests MobileLaunchPathTests MobileRoundOccasionTests MobileSavepointOnLeavingTests
MobileRelockCoordinatorTests MobileRelockPolicyTests MobileLockTeardownTests MobileQuickNoteUnderLockTests
MobileProtectionRoadTests MobileLobbyE6LineTests MobilePreDesignFaceTests MobileQuickNoteTests
MobileQuickNoteReadFailureTests MobileBoxOpenTimingTests MobileShellTests MobileNavigationTests MobileLivenessTests
MobileTabBarTests MobileRootMenuTests MobileScreenEdgeGroundsTests MobileEdgeGroundsBoardTests MobileMembershipTests
MobileMembershipSheetFaceTests MobileChipScopeTests MobileNoteTagsTests MobileWriteScrollAuthorityTests
MobileNoteOpenOnceTests MobileNoteHoldTests MobileLeavingSavesOnceTests MobileStructuralFlightFenceTests
MobilePerfWalkTests MobileShelfPerfTests MobileWingDoorTests MobileWingStandTests MobileWingListingTests
MobileWingDoorGeometryTests MobileWingListSheetTests MobileWingDoorShellTests MobilePhoneTypeSourceTests
MobilePhoneControlsSourceTests MobileLookSourceTests MobileFaintOnDoorsSourceTests MobileFaintCarriesNoWordsSourceTests
MobileFieldPlaceholderSourceTests MobileNoteEntryDateTests MobileGatheringWordTests MobileMessageLineFaceTests
MobileLineShowRuleTests MobileMessageLineGeometryTests MobileMessageLineHostTests MobileMessageLineInsetTests
MobileMessageLineSceneTests MobileLineDoorTests MobileLineDirectionTests MobileProtectionCheckTests
MobileProtectionCrossingsTests MobileProtectionPassphraseTests MobileProtectionCompositionTests
MobileProtectionAccountSectionTests MobileNoRawErrorPinTests MobileErrorLogPrivacyPinTests MobileWalkTests)
```
`xcodebuild test-without-building -project Variorum.xcodeproj -scheme VariorumMobile -destination
"platform=iOS Simulator,id=<simulator-udid>" -derivedDataPath DerivedData/vm47-fix ${phone/#/-only-testing:VariorumMobileTests/}`.
Expected: all green with the declared known issues only — `MobileTrashTests`' empty-tree diagnostic is not in this list;
P-47-7's four filter-row marks (`MobileFilterRowGeometryTests`); `MobileHerPathsPerfTests` is not in this list (its own
leg, (b)). Any other red is a finding to read — the four paging pins first.

(b) The gated speed suite, ALONE, its own invocation (VM-64's record: the suite reads the process's one timing recorder,
so nothing else may share the host; `xcodebuild` hands the test runner every environment variable prefixed
`TEST_RUNNER_`, with the prefix stripped, so the switch is set IN FRONT of `xcodebuild` on the same command line — never
in the scheme, never `export`ed into a shell that runs other legs):
```zsh
TEST_RUNNER_VM66_PERF=1 xcodebuild test-without-building -project Variorum.xcodeproj -scheme VariorumMobile \
  -destination "platform=iOS Simulator,id=<simulator-udid>" -derivedDataPath DerivedData/vm47-fix \
  -only-testing:VariorumMobileTests/MobileHerPathsPerfTests
```
Expected: 13 tests in 1 suite passed, none skipped (read the skipped lines — Swift Testing counts skipped tests in "N
tests … passed"), its counts holding (reads per open 1, editor builds per open 1, hidden-Library re-reads and redraws per
box save 0 and 0, savepoint attempts 1 on all four roads, registry growth 0, owner-adoption rows 0). In the whole phone
target the same 13 are SKIPPED by design — say them in words as the speed suite's.

(c) The Mac, beyond the gate's whole target — the commit-vocabulary scan over the readout's words, this run's theme
layer beside VM-64's shared types for the first time, VM-64's own Mac legs over those types (17 types):
```zsh
mac=(DeadVocabularyTests ThemeTokenTests NoLiteralColourTests SharedPageStyleTests PaletteDerivationTests
AppearanceChoiceTests BadgeFamilySplitTests MarkdownPaletteWritersTests AutosaveCoordinatorTests
AutosaveConsolidationTests SavepointOnLeaveTests SyncBeforeRoundTests FirstRoundRoadTests SyncSessionFenceTests
Phase9cAuthWiringTests AppBootstrapOffMainTests TestHostInertTests)
```
`xcodebuild test-without-building -project Variorum.xcodeproj -scheme Variorum -destination 'platform=macOS'
-derivedDataPath DerivedData/vm47-fix ${mac/#/-only-testing:VariorumTests/}`. Then the gate: the whole phone target,
(b) alone, and the whole Mac target on this tree. And the W-A1 redo's own UI test and window (its section above) on
the same products.

**PROVISIONAL:** none new — the readout's role call is P-47-8's (its row in §5 extended). **Self-assessment — the
risks in the join, ranked:**
1. **The readout in Study is no longer monospaced.** `meta` is SF Pro in Study (SF Mono in Terminal); the report never
   aligns columns (two lines per entry, a two-space indent), so nothing breaks, but it reads differently from what VM-64
   built — a look call inside P-47-8, and the readout is DRAFT for her wording pass anyway. At 13 pt in Terminal a
   summary line of ~50 mono characters can wrap at 402 pt where main's 12 pt caption did not.
2. **Nothing pins the readout's roles** (the `Features/Perf/` exemption, above) — measured clean once, by script.
3. **The two moved tab walks** rest on the driver finding "Bookcase" among the current page's elements after a
   `settle`; the same word drives VM-55's moved pins on this tree (green in batch 6's and 7's windows).
4. **The paging pins under this run's shell for the first time** — the edge-grounds board, `mobilePageShowing` and the
   W-C2 focus release sit on the same page modifier as VM-68's `libraryOnScreen`; they add environment values, not
   reads, so the hidden Library's zero re-reads should hold; the speed suite (b) is the evidence.
5. **Item 5** (`model.rowStarLanded()` after the star) is held by reading only, as VM-64's map says.

### Closeout (written 2026-11-19, before the merge — documents only; every slot is filled at the merge)

**Not done here, first:** nothing was built, run or captured in this pass, and no shared ledger or canon file was
edited. The canon lines, the parity row, the AppSpecRecord entry, the QUESTIONS bundle, the master plan's paragraph
and the run-finals row are DRAFT TEXT in `notes/plans/vm-47-closeout-drafts.md`, applied at the merge on latest main
and then deleted; the author's handoff is `notes/handoffs/vm-47-handoff.md` (a draft until its slots fill).

**The slots still open** (each written `‹PENDING: …›` in the three closeout files) — **brought current at the final
record pass (2026-11-20):** slots 1–3, 5's numbers and 7 are filled; 4, 5's PR and merge commit, and 6 stay open.
1. VM-64's three-file merge-in (`.gitignore`, `MobileSettingsView.swift`, `VariorumMobileApp.swift`) — its merge
   commit, what its timing door and readout sheet wear on this run's layer, and its narrow read (round 3's §3: a
   narrow cold pass, or the orchestrator's line-by-line check against VM-64's map). **FILLED:** batch 7b, `3d55b51f6`
   at main `64fde83b0` — FOUR conflicted files, `MobileLibraryView.swift` the fourth (§6 "Batch 7b — results"); the
   door a Diagnostics menu row after "Edit trace…", the readout in the edit trace's shape (P-47-8); the narrow read is
   ladder round 4, CLOSED.
2. The targeted window — batch 7's 64-type phone array and 25-type Mac leg plus what the merge-in adds; the join
   pin's first run and its snapshot red-on-old; the re-run of `MobileFaintOnDoorsSourceTests` (`94f4e752d` and
   `1306a9f07` both ride it). **FILLED:** batch 7's window (row 7.7: the phone's 64 types green, the Mac's 25 with one
   red this run had made, fixed `3c960718a`) and the post-merge window on the final tree (row W.11: the phone's 98
   types, the speed suite alone, the three snapshots — the join pin red on the raw merge —, the keyboard UI test both
   ways, the Mac's 21 types; the faint rules green).
3. The re-capture (row W.8) — the walk's re-capture lists (§6 "The walk's fixes (part A)" and "(batch 2)", the
   screens the joins drew: Book Details, Create Book, the membership sheet, Write, Settings), the two missing `m3`
   captures, c6's take peek and c8's caret; whether it reached the Account sheet; the walk file's FOR A LATER READER
   and §5 result blocks (still PENDING there). **FILLED:** the re-capture (row W.9, 164 of 166, read in the walk file's
   §4e–§4f — `m3`, the take peek and the caret caught; W-E4, W-E3, W-F1 found) and the final-tree captures after the
   redo (row W.11 (9), 119 of 119, read in §4g–§4h — `r05b` under "Gathering" shot); the Account sheet reached by no
   capture (her phone is its first sight); the walk file's FOR A LATER READER and §5 written at the final record pass.
4. The merge gate: the whole phone target and the whole Mac target on the tree that merges. **OPEN** — the whole
   phone target with VM-64's speed suite as its own leg, and the whole Mac target.
5. The PR number, the merge commit, the QUESTIONS number (VM-64's drafts take #280, so likely #281), the parity row's
   number (VM-64's take PL-79, so likely PL-80), `Tools/canon-size`'s line. **FILLED:** QUESTIONS #281, PL-80 (applied
   on the branch), the canon-size line in the handoff's Canon section; **OPEN:** the PR number and its merge commit.
6. The wave-1 phone install's preparation — this run is the last mobile merger: a Release device build of merged
   main, its signing check, main's sync version against production's, and the paste-ready block
   (`notes/plans/vm-44/plans/vm-45-install-runbook.md`); the install itself is hers. **OPEN.**
7. Whether `notes/plans/vm-47-screens/final/` stays until her sitting: the handoff's questions name captures there,
   and the closeout ritual deletes a merged effort's walk evidence (her 13x ruling) — a call for the orchestrator or
   her. **DECIDED (the orchestrator's call):** all four capture sets are KEPT until her sitting, the deletion held for
   her word ("delete the screens"); after the merge they sit in the main checkout's gitignored
   `notes/plans/vm-47-screens/` (`final/`, `recapture/`, `e4-before/`, `final-tree/`; §5 "Held for her hands").

**The rulings reconciled** (CLAUDE.md's closeout rule — each ruling the run built, read word by word against what
shipped; the plain-English version is in the handoff):
- **R-47-1** — "grounds - prose should not be on the tint". The record's test (§3, batch 3): wherever her words are
  read or written the ground is the paper, in light and in dark, under every palette. Shipped: the roots' lists, a
  book's contents, Archived, the Trash, Versions' listing and reader, the note in Write with its masthead (P-47-16,
  P-47-17); the grounds now reach the screen's edges (W-A1 — since the redo, painted by the shell beyond the band in
  each page's declared grounds; her words themselves stop at the band, as on main); pinned under two palettes. Read's cream page sits in the
  voice's own room, never the tint (R-13u-10). **Remainders:** the only prose inside a SHEET — the Blocks sheet's
  block previews (VM-149) and the tray's previews (VM-153) — still sits on the sheet's room, which in light is the
  palette's tint; the three hand-built overlays' grounds (VM-152); a peeked take card wears the take tint (R13's
  ruled register, kept for her look). Names inside sheets (books, tags, wings) sit on the room by the sizing sheet's
  own "sheets on the room".
- **R-47-2** — "voice only row". Shipped: Look ▸ Voice writes the library's voice through the Mac Settings' own
  write. No palette row, as ruled; the palette chooser is filed as VM-247 for a later call.
- **R-47-3** — her pick "Bookcase (Recommended)", the option reading "The top line says Bookcase, matching the tab,
  your swipe names and the Mac." Shipped on the Bookcase root's line in both voices (pinned). **The other places the
  phone still says "shelf"** (read over the merged tree at this pass): the pocket guide's seeded prose ("a book on
  your shelf", "The SHELF is home", "on the shelf's top line", "on the Shelf's"; and "Settings, on the shelf's top
  line" is now wrong twice, since Settings moved into the ⋯) — VM-212; the Debug-only guide door's note "The pocket
  guide is on your shelf." — VM-211; the shared refusal sentences about a shelf ("That shelf isn't there any more…"
  and its kin) name the Bookcase's shelves and are right as they are. "Pin to Shelf Top" is gone (VM-78's VM-83,
  merged in at batch 7). Comments, identifiers and file names are not rendered.
- **LK-1 / LK-2** — her words "follow the library but if the phone has dark mode on, that shouldn't change what your
  mac is like (the device dark mode)" (`notes/plans/vm-44/her-words.md`). Shipped: the voice and palette from the
  library's synced settings, observed both ways; light, dark or follow the system on this phone's own defaults, never
  synced. Remainder: before a library opens the phone wears Study under the sea-glass (P-47-15).
- **LK-5** — her words "Words on a chip" and "Roots and lists, not notes" (the rulings file: three words at 17 pt, the
  current one on a chip, 56 pt targets). Shipped as ruled on the three roots and the four pushed lists. Remainders:
  Read, Versions' reader and Protection carry no bar (P-47-18); the screens inside Settings are covered by its sheet;
  at 320 pt in Terminal at the largest sizes a word may shrink toward the 13 pt floor (never under it); the mockup's
  "the bar leaves while the keyboard is up" is VM-73's.
- **LK-6** — Terminal keeps its lowercase chrome: kept. P-47-39 asks whether her own quoted words should keep their
  capitals in Terminal.
- **SW-1** — the Starred · Bookcase · Library swipe kept and the tab says Bookcase; the wing title's swipe, dots and
  dropdown are VM-80's (wave 2).
- **The tickets' "every" lines.** VM-49 "a 44 pt minimum for every target": every site of audit G §2 is adopted, given
  a hit area or left with its owner (§6 "Batch 2 — results", the inventory; the formatting strip's 28 pt acts are her
  ruled exception). VM-48's batch-1 line "Nothing on the phone is set below 13 pt": held by the source rules and both type forms;
  the remainder is the editor's own body in Terminal at the smallest text setting (≈ 12.4 pt, VM-137). VM-53
  "reachable from every screen" (its title; its text says "from every root and from a note", which shipped): a pushed
  list, a book's Read page and Protection carry no Settings door of their own — a pushed list is one tap from a root
  by the bar — **no ticket owns that remainder; it needs a ticket or her acceptance of the text's scope** (since filed:
  VM-249, Needs Lillian). VM-52 "on
  every root and list": as LK-5 above. VM-54 "the take cards, the takes pill and the comment draft": the pin covers
  all three; the walk saw the cards and the draft follow and caught no pill (f5).

**Tickets.** The members VM-48, VM-49, VM-50, VM-51, VM-52, VM-53, VM-54 and VM-27 and the umbrella VM-47 close with
the merge. **Filed during the run (both Medium, Backlog):** VM-247 (Feature · Settings & onboarding — a Palette row in
Settings, the lock mockup's S1 draws it and no ticket owned it; §5 "Held for her hands") and VM-248 (Debt · Confirmed ·
Tests & tooling — a phone test that reads `@Dependency(\.database)` unscoped falls through to the live value and opens
or creates the simulator app's own store; batch 5's "The pin's unscoped round"); **and later VM-249** (Low, Improvement,
Needs Lillian — Settings from a pushed list, a book's Read page and Protection: VM-53's title says "every screen", its
text "every root and a note"). **Remainders, commented on each owner at the ticket pass** (the orchestrator's; each
fact from this record or the walk file; the handoff words them plainly; two added after the re-capture — VM-188: W-E1,
the takes pill drawn over the next block's first line while it shows; VM-137: the keyboard bar's own ground, which
since the redo has the note's paper behind it): VM-218 (W-A4,
W-D1, W-D2; Book Details' detail lines beside their labels — round 3's noted item; Create Book's ✓ in a fixed 14 pt
frame) · VM-93 (the filter row kept as words, P-47-10; P-47-7's Terminal-320 known issue, whose two strings name
VM-93; W-A11's Terminal-AX5 "bookless" shrink, which the known issue should also name; the full 44 × 44 width of the
filter doors) · VM-90 (the sort glyph's full 44) · VM-89 (W-A12, no date on a Library row) · VM-188 and VM-195 (T51–T54;
W-A13, the ⑂ mark 7 pt tall) · VM-152 (the overlays' fixed frames past xxxLarge; T63; the sheets' grabber and detents;
the overlays' grounds; W-B5, the scrim that lightens the note in dark) · VM-14 (T65; the walk's re-seed measured the
draft field and its Add at y 784 under a keyboard whose top is at y 583 — evidence to move its label from Suspected
to Confirmed) · VM-148 (the masthead: P-47-12,
P-47-29, the chips' capsules and one row, T44–T48, the cut title; Write's top edge, P-47-20) · VM-122 (a book's
contents' and Read's top edges, P-47-20; the system toolbar's "Details · Read" in the system's label colour — round 3's
noted item) · VM-100 and VM-99 (the Trash's and Archived's top edges, P-47-20; T97's separation) · VM-110 (Protection's
top edge, P-47-20; its words) · VM-147 (the Versions screen's top edge, P-47-20; W-C8's casing there) · VM-137 (the
editor body's floor in Terminal at the smallest setting; the paragraph scale taken at launch; the stale comment above
the one changed line of `MobileEditorTextView.applyVoiceChrome`; the markdown marker's ink; the text inset, already 20
pt visible; the process-global look the suites share across awaits, #195 MINOR 3's residual; the keyboard bar's 14 pt
chrome and its own ground) · VM-73 (T11; the bar above the keyboard while the box is focused) · VM-138 and VM-139 (the
keyboard bar's shape and glyph sizes; T56, her ruled exception) · VM-212 and VM-211 (the "shelf" words above) · VM-74
(T10, the box at rest) · VM-149 and VM-153 (the sheets' previews on the room; T87) · VM-41 (T71) · VM-86 / VM-101
(T103). **VM-112: nothing now** — its one item ("Pin to Shelf Top") left the phone with VM-83. **VM-61: nothing** (Done;
T50's Undo moved onto VM-55's one line at batch 6).

**Corrections to earlier sections (read these over them; those sections are the night's record and stay as written):**
- §6 "Batch 6 — results", meeting 3: "Pin to Shelf Top" / "Unpin from Shelf Top", left for VM-112 — gone since batch
  7's merge of main (VM-83 retired the Pin door); and `OpsRefusalTable.swift`'s dated comment, recorded there as
  left, was made true at `e9e865435` (comment only), a commit no other section records.
- §5's closing paragraph ("For the orchestrator to ticket at closeout (batch 5): a palette row…") — filed as VM-247.
- The orchestrator's handoff names "the doubled divider in the note's ⋯ sheet: VM-61 / VM-148" — it was fixed by W-B4
  (`fb649d6a8`); nothing is re-owned.
- §1's "CLAUDE.md's standing cap of three is unchanged for other runs": VM-64's branch carries her ruling that the
  standing cap is five (`742a39af0`); once VM-64 merges, that clause is history.
- §6's opening paragraph still names only the midway and round-1 ladder files and lists the walk, the canon deltas
  and the tickets as PENDING: the ladder is five files (`…-midway`, `…-round1`, `…-round2`, `…-round3`, `…-round4`
  — the last added after this line was first written), the walk is
  `notes/plans/vm-47-walk.md`, and this block carries the rest.
- Row 6.9 counts eight known issues on the phone ("the four standing ones"); main's VM-3 unwrapped the tutorial pair,
  so the merged tree expects fewer (batch 7's "The stage window" says which).

*Added at the final record pass (2026-11-20) — what the work after this block was written made stale, each checked
and now true or corrected:*
- The STATUS banner (written before batch 7b): rewritten (ladder round 4's R4-n1, confirmed).
- "VM-64's three-file merge-in" (slot 1 above; the drafts' and the handoff's opening slot lists): FOUR conflicted files —
  `MobileLibraryView.swift` the fourth (row 7b.1); corrected in the drafts and the handoff.
- W-A1's fix as "a sideways-only clip" (`MobileBandClip` — §6 "The walk's fixes (part A)", the old FOR A LATER READER,
  the drafts' AppSpecRecord narrative): REDONE — `MobileBandClip` deleted, main's clip back, the strips painted by the
  shell (`5daf61efd`; §6 "W-A1 redone"); the part-A block stays as the first fix's history; FOR A LATER READER and the
  drafts now say what stands.
- §1's cast line "three rounds at most": four rounds ran under her five-round word (§1's own later item); the ladder
  rows R2–R4 hold them.
- "Thirty-eight PROVISIONAL calls" (the old FOR A LATER READER, the drafts' (d1) and (e2), the handoff): forty-one since
  P-47-42 … P-47-44; corrected everywhere.
- "No ticket owns that remainder" (VM-53's scope, above; the drafts' (b) and (d1)): VM-249; corrected.
- The take peek and the takes pill listed as never seen (the old FOR A LATER READER; the handoff's evidence): caught at
  the re-capture (walk §4e E15, E17); corrected.
- The walk file's classes for W-E3 ("ANOTHER TICKET'S — VM-137") and W-F1 ("A QUESTION FOR HER"): both came from the
  first fix and are FIXED by the redo (their FIXED lines there); no §5 row is owed.
- §6 "W-A1 redone"'s pin matrix: the Read pin's red on the first fix is the DARK case alone — in light the cream page
  sat within the pin's tolerance of Read's own room (row W.11 (3): "the matrix's 'red ×2' was one too many"); a
  tolerance fact about the old tree, weakening no pin on the final tree (round 4's §2b).
- Row W.11 (9)'s "READ by a fresh reader — PENDING": read by two, flipped in place with the source commits (round 4's
  named residual).
- The orchestrator's handoff's newest block (15:45) predates batch 7, the re-capture, the redo and batch 7b: its new
  top block, written at this pass, supersedes it.

### The gate's one red — a frame-later timing mark crossing a suite boundary (implementer: Opus, 2026-11-20)

**Not done here, first:** nothing was built or run by the implementer (the orchestrator runs every window); the pin's
red at `07190ee14` and the fix's green at `bb0e2285d` are OWED (row G.1). Only
`App/Variorum/VariorumMobileTests/MobileBoxOpenTimingTests.swift` changed — no app, `Shared/` or Core code.

**The red as seen** (the orchestrator's gate log; the whole phone target in one launch, 1193 tests in 209 suites):
beside main's one known red, `anOpenThatFilesIsStillTimed` recorded two issues and failed after 0.059 s — `:98`
`recorder.isOpen(.boxOpenToNote)` → false, and `:101` `samples(.boxOpenToNote) == painted + 1` with `samples` → 1 and
`painted + 1` → 2 (the gate's line numbers); its premise at `:96` held. The suite's first test passed (0.029 s) just
before; the suite before it was `MobileBorderTraitTests` (this run's, VM-54), whose last test mounts a real surface
editor. Nothing was printed between the test's start and its issues. It did not reproduce in eleven launches (the suite
alone 3 of 3; the borders suite with it 8 of 8), and main's whole target passed it in two gate runs.

**The mechanism — proven by reading and the logged numbers, by elimination.** Every way `.boxOpenToNote` can stop being
open, or gain a sample, between the press (`:92`) and `:98`:
1. `AppTiming.notePainted()` → `recorder.endIfOpen(.boxOpenToNote)` (`Shared/AppTiming.swift:259–263`) — the ONLY call
   that both closes the span and records a sample. Its callers: this suite's own direct calls (synchronous, outside the
   window) and `MobileTiming.noteRendered()`'s frame-later closure (`VariorumMobile/Features/Perf/MobileTiming.swift:138–140`
   → `afterNextFrame` `:156–159` → `NextFrameTick.schedule` `:190–196`, a one-shot `CADisplayLink` added to `.main` in
   `.common`, fired at the next refresh, `:198–204`). An editor's first render schedules it
   (`MobileEditorViewModel.applyProjection`'s `.initialRender` arm, `MobileEditorViewModel.swift:1021–1024`; once per
   model — `loaded`, `:176` and `:1023`; the policy's first rule, `Shared/EditorBrain/EditorProjectionEngine.swift:153`).
   **It crosses a suite boundary:** the link holds its target until it fires, its closure captures nothing of its test,
   and nothing invalidates it when the test ends.
2. `AppTiming.boxOpenFiledNothing()` → `cancel` (`AppTiming.swift:218–221`) — only from a box's Open task on a nil filing
   (`MobileQuickNote.swift:905–911`). In the window the only box is the guard's own, which FILED (`:96` held). The first
   test's box ran its task inside the first test: an empty box's `file()` never suspends (`MobileQuickNote.swift:960–967`),
   and that test's passing `!isOpen(.boxOpenToKeyboard)` proves the cancel ran there (the keyboard span's only other
   closer, `keyboardUp`, needs a software keyboard, which the simulator never raises under `xcodebuild test` —
   `MobileHerPathsPerfTests`' header). No suite before this one constructs a box, and the test host mounts no shell
   (`VariorumMobileApp.swift:222–226`, `.hostingTests`). Cannot cross.
3. `recorder.cancel(.boxOpenToNote)` directly — `freshSpans`, before the press.
4. `recorder.reset()` (`Sources/VariorumCore/Diagnostics/TimingRecorder.swift:483–491`) — reached only through
   `MobileTiming.reset()` (`MobileTiming.swift:127–130`) from the readout's Reset (`MobileTimingView.swift:225`), never
   mounted in the target; ruled out by the numbers as well (a reset zeroes the count: `painted` would read 0, the log says
   1).
5. `recorder.setEnabled(false)` (`TimingRecorder.swift:254–264`) — no caller in the app or the test target (only `true`).
6. `recorder.restore(_:)` (`TimingRecorder.swift:515–525`, which drops open spans) — no caller; the timing file's load
   uses `absorb`, which keeps them, and runs only when the process persists — never in a test host
   (`MobileTiming.swift:73`, `:84`).
7. A second `begin` (`boxOpenPressed`) restarts and keeps the span open — not a closer; the 30 s stale limit is out of
   reach in 0.059 s.

The numbers close it: `painted` = 1 at `:99`, so exactly one `.boxOpenToNote` sample existed in the process. Only (1)
records one, and no suite before this one presses a box, so it came from a paint landing while a box span was open. Had
that paint landed in the first test's span, the guard's span would still have needed a non-recording closer inside its
window, and none of 2–6 exists there. So **one frame-later paint mark, scheduled outside the guard (which renders no
editor), fired during the guard's wait for the filing (`:93–96`, the only stretch between the press and `:98` where the
main run loop turns), closed the span and recorded its sample; the guard's own paint at `:100` then found nothing open.**
Both issues, both numbers.

**Still a suspicion, said plainly: which editor's mark, and why its frame came so late.** The likeliest is
`MobileBorderTraitTests.theCommentDraftsEdgeFollowsTheFlip`: `makeSurfaceEditor` (`MobileMarkdownTests.swift:29–41`, its
`loadOnce` at `:39`) schedules the mark, and the test runs only synchronous code to its end
(`MobileBorderTraitTests.swift:122–143`), so the mark is pending at the suite boundary; on main the suite before this one
renders no editor, which is why main never showed the red. For it to land in the guard rather than harmlessly earlier,
no refresh reached the main run loop from the borders test's end until after the first test's box task had cancelled its
spans — roughly 30–55 ms, two or three refreshes late. The run loop does turn in the gaps between tests and in the first
test's wait (one yield and one 2 ms sleep; the rest of that test is the in-memory store's synchronous setup), so on an
ordinary frame cadence the mark fires there — inside the first test's span, where it is harmless, since that test reads
its counts afterwards. The eleven green launches are consistent with this and do not rule it out. What starved the
display link in the whole-target launch is not readable from code; a launch with the timing signposts streamed
(subsystem `io.lduarte.Variorum`, category `timing`) beside the test events would show when the stray span ended.
**The fix does not depend on it.**

**The reproduction — `aPaintMarkAnEarlierRenderLeftCannotEndTheOpen` (`07190ee14`).** It drains what earlier tests left,
mints a note and renders an editor the real way (`makeEditor` + `loadOnce` → `.initialRender` → the mark), begins a
`noteOpenToScreen` span as the planted mark's witness, then runs the guard's own scenario — `freshSpans`, the box, the
press — with nothing in between that suspends (so the main run loop, the only place the mark can fire, does not turn
before the press); it waits for the filing, then for two refreshes of its own display link (`drainFrameLaterMarks`), so
the mark has certainly fired inside the span. **Deterministic:** the mark is pending at the press by the main thread's
own sequence; it has fired by the drain's second refresh by the drain's ordering (below); and nothing else can close
the span between (items 2–6). On this tree it is red at exactly two expectations — `recorder.isOpen(.boxOpenToNote)`
and `samples(.boxOpenToNote) == painted + 1` — with both premises holding (the note filed; the witness closed). **If the
mechanism were wrong** the pin would be GREEN at `07190ee14` (the mark would not end the span): the finding hollow. A red
on a PREMISE instead — the witness still open, or the drain's 10 s issue — means the mark was never planted or the
display link never ticked, and proves nothing either way.

**The fix — `bb0e2285d`, test-only, the one file.** `freshSpans`, which every test in the suite calls first, now awaits
`drainFrameLaterMarks()` after enabling the recorder and before cancelling the two spans, so every frame-later mark
already scheduled fires while nothing of the test's is open. **Why the drain is ordered by construction, not by time:**
it installs its own `CADisplayLink` on the run loop and in the mode `NextFrameTick` uses (`.main`, `.common`) after every
pending mark (the main actor runs one thing at a time), and returns at that link's second refresh. A link installed
earlier is due at a refresh no later than one installed after it, so every pending mark was due by the counter's first
refresh; the main run loop calls one refresh's links before it reaches the next, so by the counter's second every one
has been called — whatever their order within a refresh. The 10 s deadline only keeps a dead display link from hanging
the suite, and it records an issue rather than pass silently. VM-64's two tests keep their words and every
expectation; each now `await`s `freshSpans()`, and the suite's header says why.

**What it does not cover (said once):** a mark scheduled DURING a test by a predecessor's still-running work — an
editor whose FIRST render comes late, from a first load left un-awaited. No suite before this one leaves one: their
editors load awaited (`makeEditor` / `makeSurfaceEditor` + `loadOnce`), hosted screens tear down (`withHostedSurface`'s
`defer`), and their `start()` tasks belong to list and shelf models and are cancelled. The drain catches every mark
scheduled before the test begins.

**The suite's first test** (`anOpenThatFilesNothingLeavesNoOpenSpan`): exposed, never red by it — a stray paint in its
wait ends its note span early with a sample, but it reads its counts after the spans close, synchronously, so its
expectations hold whatever lands; on the tree before VM-64's cancel a stray could have satisfied its note-span
expectation by accident (its keyboard expectations stayed red). The shared `freshSpans` drains for it too.
**`MobileHerPathsPerfTests`** (gated, its own launch): exposed in principle — its earlier tests mount editors whose
marks are frame-later, and one landing inside a later Open's or note open's span would end that span early — but each
press there follows `idle(400 ms)` and polled waits (about two dozen refreshes of run-loop time at 60 Hz), and a stray
could only under-read a duration it records and never asserts: the counts it asserts (reads and builds per open,
savepoints per leaving) are counters a paint does not move, and each run still gathers one sample (the note's own paint
then finds nothing open). Left as it is; it could adopt the same drain if a duration there is ever asserted.

**The window (OWED — the orchestrator's; the slots):**
- At `07190ee14`: `-only-testing:VariorumMobileTests/MobileBoxOpenTimingTests` — expect the pin alone red, at its two
  named expectations, with both premises and both VM-64 tests green. ‹PENDING›
- At `bb0e2285d`: the same suite — expect green, three of three. ‹PENDING›
- At `bb0e2285d`: `MobileBorderTraitTests` and `MobileBoxOpenTimingTests` in one launch — expect green. ‹PENDING›
- At `bb0e2285d` (or the branch's head): the whole phone target, `-only-testing:VariorumMobileTests` — expect main's one
  known red only. ‹PENDING›
