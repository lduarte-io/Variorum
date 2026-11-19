# VM-47 — the ladder, round 1 (the whole run's diff)

**Run record: `notes/plans/vm-47-sizes-and-look.md`.** Reviewer: a fresh `fable-reviewer`,
`notes/REVIEW_PROMPT.md` verbatim with zero framing, 2026-11-19. Scope: the run's diff `fe85ea6d5..HEAD`
(HEAD `c5dbae56b`), the two merges of main (`057c7cd87`, `40352bde2` — VX-980's Mac/Core search files, notes)
excluded as not this run's work; the run-only commit set and its file list were derived with
`git log --no-merges --not origin/main` and reviewed file by file. The midway review's findings and
dispositions (`notes/plans/vm-47-ladder-midway.md`) were re-checked, not re-litigated. Read-only throughout;
no phone suite was run (stage-gated), so the record's run counts were checked by disposition-tracing against
the code and the pins' own text, not re-execution. Tally: **0 BLOCKER · 0 MAJOR · 1 MINOR · 4 NIT.**

## 1. The reviewer's report (verbatim)

### The midway fix pass, re-checked (round 1's standing duty)

- **M-1 (the 13 pt floor in `PhoneType.uiFont`) — APPLIED AS CONFIRMED.** The floor sits after
  `scaledUIFont`, so it covers BOTH branches (`PhoneType.swift:347–355`: the `.fullRange` raw `scaledFont`
  and `.holdsAtXXXLarge`'s capped one both flow through the one guard); under the floor it returns
  `baseUIFont(spec, voice:, pointSize: floorSize)` — the confirmed fix shape exactly. The pin
  `theUIKitFormIsNeverBelowThirteenPointsEither` exists (`MobilePhoneLayerTests.swift:108`), mirrors
  `nothingIsEverBelowThirteenPoints` (:88), and its red-on-old was proven in the snapshot (20 issues,
  ladder-midway §3). `Face.body` recorded for VM-137 in batch 1's "Recorded and left" — present.
- **m-1 / m-2 (the two comment edits)** — both landed: `MobileEditorStyle.baseParagraphStyle`'s comment now
  says launch-time (:316–320, naming VM-137); `PhoneSegmentedChoice`'s contract carries the refusing-site
  sentence. No code change, as confirmed.

### Findings

**[MINOR] · `App/Variorum/VariorumMobile/Features/Shell/MobileShellView.swift` (the theme `.task`) +
`MobileShellRouter.bindTheme` · The theme store's start is coupled to the shell VIEW's identity while its
binding is coupled to the SESSION — a ready(A)→ready(B) transition that kept the shell's identity would
leave the new store never started (the phone frozen on the placeholder). HOLLOW today — comment-only, no
pin.** Evidence (traced): `bindTheme(session:)` is idempotent per `ObjectIdentifier(session)` and mints a NEW
store for a new session; `.task { … await router.theme?.start() }` runs once per view identity/appearance.
The shell is mounted under `switch bootstrap.state` (`VariorumMobileApp.swift:69`), and every road to a new
session today passes through a non-`.ready` case (lock, reopen, adopt), which changes the switch branch,
recreates the shell and restarts the task — so no reachable input sequence produces the wrong state, and no
red-on-old pin exists (a fix would be hollow by the protocol; the `quickNote.bind(session:)` beside it has
carried the same shape since S3). Disposition wanted: one sentence in `bindTheme`'s doc comment — a future
road that swaps sessions WITHOUT leaving `.ready` must also restart the store's `start()` (or key the task
on the session) — so the coupling is on the page when someone builds that road. No code change.

**[NIT] · `App/Variorum/VariorumMobile/Features/Shell/MobileRootMenu.swift:63–67` · `Item.id` is the item's
title — two same-worded items would collide in the menu's `ForEach`.** Today the menu holds one item and
later umbrellas' doors are distinct words, so nothing misbehaves and no pin exists. Worth one sentence in
`items(settings:)`'s comment (titles double as identity) for the umbrella that appends; or nothing.

**[NIT] · `App/Variorum/VariorumMobile/Features/Write/MobileNoteActions.swift:108–116 + settingsRow` · With
both `undoRow` and `redoRow` absent (empty stacks) and the Settings door present, the sheet draws two
adjacent dividers** (the body's own after `redoRow`'s empty slot, then `settingsRow`'s leading one).
Cosmetic; the doubled-divider shape pre-exists this run when both rows are absent. No action, or fold the
divider into the row group on VM-148/VM-61's next touch.

**[NIT] · `App/Variorum/VariorumMobile/Features/Shell/MobileTabBar.swift:99–101, 163–169` · The bar's first
frame (width still 0) assumes the widest chip sides; at AX5 in Terminal the first frame can draw a chip that
does not yet fit, corrected on the first geometry pass.** Already named in batch 4's self-assessment (risk
4); invisible in practice (one frame). No action — listed so the record shows it was checked, not missed.

**[NIT] · `App/Variorum/VariorumMobile/Features/Read/MobileReadView.swift` (the batch-3 ground comment) ·
"never the / the cream read page" — a doubled word across the comment's line break.** Words only.

### Open items the record already owns (not findings — closeout evidence still owed)

All honestly marked PENDING in the LIVE STATUS; none claimed done. Before closeout the record still owes:
batch 3's Mac leg (the recomputed 102 types + the seven theme types) and its two-part walk (rows 3.12–3.15);
batch 4's and 5's suite counts (`MobileTabBarTests`, `MobileSettingsListTests`, `MobileAppearanceTests`,
`MobileRootMenuTests`, `MobileSettingsProtectionDoorTests`); **VM-27's red-on-old snapshot run**
(`~/dev/variorum-vm-47-rol5` — built, not yet run; the pin's red-on-old is by trace until it runs); the
batches-4-and-5 walk (135 captures); the whole phone and Mac targets after VM-55's merge re-lands. The
VM-54 red-on-old is PROVEN (4 red on old in `rol3`, green on new — `vm-47-walk-b3.md`), as are the path
line's (22 issues) and M-1's (20 issues).

### Clean bill (checked, solid)

- **The midway's scope (batches 1–2) re-spot-checked, not re-derived:** my own grep confirms zero
  `tokens.small/muted/faint/body/title` reads and no literal size under 13 in the phone tree outside the
  named exceptions (`MobileBlockDecor.emojiFont` at exactly 13; the pre-existing 14 pt keyboard-bar chrome,
  recorded for VM-137/VM-139); the midway's clean-bill mechanisms I re-read (`SharedPageStyle`'s macOS
  accessor compiled to nil, `PhoneMetrics.phoneHitArea`, the sheet header, `PhoneSegmentWidths`) are as it
  said.
- **The Mac cannot have changed:** `VoiceTokens.swift` has a zero-line diff over the whole run range; the
  run's only Mac-target source change is `Theme/AppearanceChoice.swift`, which lost exactly the declarations
  that moved to `Shared/Theme/AppearanceChoiceRule.swift` (cases, `settingKey`, `remembered` — byte-for-byte
  by diff) and kept `appearanceName` + `AppearanceController` untouched as an extension beside the owner;
  the `ThemeStore` hoist is a `git mv` whose only deltas are the two additive members (`onLanded`,
  `placeholder:` defaulting to the Mac's) and the `#if os(macOS)` fence around the two Mac-only adoptions;
  `SyncStatusViews`' changes sit entirely inside the styled (phone) arm with the nil arm untouched; every
  other `Shared/` addition is code the Mac compiles but never renders. No Mac test file changed except by
  the moved declarations' home.
- **VM-27 (the doubled Protection door):** the mechanism is real in the pre-fix code (one `protectionDoor`
  gate fed the env door and the standing row), the fix removes exactly the env door
  (`.environment(\.protectionPaneDoor, nil)`), the standing row's gate is the same closure so no state loses
  its one door, and the pin mounts the real bootstrap + a keys-refusing services chain and asserts exactly
  one "Protection…" element that opens the screen, over both doored faces. The Mac's sidebar row is another
  call site, untouched.
- **The library's look (VM-51):** the resolution road is genuinely the ONE settings → tokens road
  (`VoiceTokens.resolve(settings:dark:)` → the four-parameter resolver); the placeholder equals an empty
  library's own read (`unsetStoreVoice`/`unsetStorePalette` = Study/sea-glass, pinned equal in
  `thePlaceholderIsWhatAnEmptyLibraryReads`); `MobileEditorStyle` now has ONE app writer (`adopt`, called
  where the store lands), main-actor storage (QUESTIONS #195 MINOR 3 closed as claimed), and a palette face
  built once per landing that shares the voice's colour objects; `setVoice` routes through
  `Operations.setThemeVoice` (S1-shaped, the Mac's own write); the retired `MobileVoicePreference` is read
  nowhere (file deleted, source pin holds it); dark stays the device's and resolving writes nothing (pinned
  against the `setting` table byte-for-byte).
- **Piece 3.10 (the editor-seam exception — read as editor-seam class, my Fable duty):** the fenced
  `MobileEditorTextView.swift` diff is EXACTLY one line (`backgroundColor = face.room` → `face.paper`);
  `MobileEditorViewModel.swift` and `Shared/EditorBrain/` have zero-line diffs; `Face.paper` is a NAME for
  the existing `surface` slot (no second truth), which is `tokens.surface` as the settings road resolves it
  in every voice/palette/appearance — the Mac editor's own ground (`EditorSurfaceChrome.paper`). A landed
  look re-runs `applyVoiceChrome` through the existing restyle road, so the ground follows. The pins
  (`theEditorsGroundIsThePaper` over both voices × light/dark × two palettes; the Write source pin) are
  real and ran green in batch 3's phone window.
- **VM-54:** the mechanism is true (`CALayer.borderColor` freezes a resolved `CGColor`; UIKit re-resolves
  view properties, never layer ones); `MobileTraitBorder` re-resolves at `registerForTraitChanges` and at
  each `set`, owned per bordered view, weak-captured; all four audit sites converted; red-on-old PROVEN
  (4 red in the `rol3` snapshot, green on new).
- **The bottom bar (VM-52):** the fit rule is pure and measures the rendered (voice-cased) word at SEMIBOLD
  (the widest), so selection cannot change a chip's fit; the `tab` role holds at xxxLarge with the floor;
  where it shows is the destination builder's, not a flag — a book's contents/Trash/Archived/Versions'
  listing wear it, the Versions reader (`model.reading != nil`), Read and Protection do not (PROVISIONAL
  P-47-18, honestly optioned and held for her); `tabSelected` pops the LEFT stack to its root before the
  page change (P-47-19) and the mounted pins prove the note under a pushed list deregisters its editor
  exactly as Back would; the bar is the band's index (`MobileShellBand.pages` order); SW-1's "Bookcase"
  landed in word and spoken label with the navigation pin moved and its premise-change traced
  (`vm-47-walk-b3.md`) — the coordinator's test-only fix `8eb727f2e` matches the trace (buttons only) and
  keeps the pin's teeth (selected-trait movement still asserted).
- **Settings (VM-53):** ONE scrolling list on the shared controls only (no private build — the source pin
  stands); groups/rows/hairlines per the mockup's grammar; the sync row's phone arm at 17/44 with the meta
  line and the Mac's nil arm byte-identical; the appearance choice is the Mac's brain shared (the enum
  byte-for-byte, same key, strange-value-reads-as-system) with the phone's owner writing ONLY window
  overrides and THIS device's `UserDefaults` — never the `setting` table (pinned against the table's rows);
  `isDark(system:)` at the app root is correct even if the root's scheme ever reflected an override
  (f∘f = f for all three cases — checked); the first-frame road is pinned
  (`didBecomeVisibleNotification`, synchronous) and the watch dies with its owner (pinned). The ⋯ menu's
  items are data with the mounted door pinned on all three roots and the gear gone; the note's door opens
  the shell's sheet only after its own sheet is gone (`onDisappear` latch), driven end-to-end by
  `aNotesActionsOpenSettingsThroughTheWholeShell`.
- **Her rulings honored as worded:** R-47-1 (prose never on the tint — the roots' list regions, the pushed
  pages, Write's screen/masthead/editor on the paper; Read's cream page with the VOICE's room around it;
  bars and sheets on the room; held by `MobileLookSourceTests`' real tree walks, red-on-old measured);
  R-47-2 (the voice rows write the LIBRARY's voice, words kept); LK-1/LK-2 (voice+palette synced, light/dark
  local); LK-5/SW-1 (words on a chip, 56 pt, Bookcase); LK-6 (Terminal lowercase chrome via `chromeLabel`
  everywhere, spoken labels plain). Where her ruling is silent the run built the defensible option and
  marked it PROVISIONAL (P-47-15…26 — each with real options and the built one named); nothing invented.
- **Scope discipline:** zero `Sources/VariorumCore` lines in the run-only commit set (no `Sync/`, no
  schema, no operations); the editor seam held to the one authorized line; the four shared-risk files'
  line-range claims in batch 5's record match the diffs (no path-line padding, wing-door, swipe or
  `selectPage` line touched — checked against VM-55's named seams); no corpus-proportional cost (the type
  cache is per role·voice·category, the theme observation is the tiny setting table, restyles are O(open
  editors) at rare acts); no history rewrites; no commit trailers (checked over the run-only set); the
  shared ledgers (QUESTIONS, TICKETS, master plan) untouched on this branch with the merge-time lines
  written down; `notes/plans/vm-47-screens/` gitignored with nothing committed under it; the worktree clean.
- **Copy:** the string-literal diff over batches 3–5 matches batch 5's "Every new rendered line" list
  exactly (group names, the Mac's appearance words, "More", "Settings" ×2, "Bookcase"; retired: "Sync",
  "Shelf", the trace button's words) — nothing unlisted changed; everything new is sentence-case, no shouty
  caps; VoiceOver labels stay plain words.
- **Review foci:** no plan-time "Review foci" section exists in the plan or beside it (checked); the five
  batch self-assessments' riskiest-calls lists stand in, and every item in batches 3, 4 and 5's lists was
  checked above (the placeholder, the process-global residual, the palette re-base road, the grounds as
  background lines, the pre-first-landing window; W-009's deferral with owners, the pop-on-leaving render,
  the mounted-pin premises, the fit's two faces, the taller bar's share; the window-writing owner, the Mac
  file's lost declaration, the undrivable system menu, the onDisappear ask, Protection's visible stack, the
  Shared additions) — batches 1–2's were addressed by the midway review and re-checked by spot.

**Recommended disposition:** the MINOR is a one-sentence doc comment on `bindTheme` (no code, no pin — the
state is unreachable today); the NITs need no action beyond, at most, a comment line each. Nothing goes to
`notes/QUESTIONS.md` — no finding turns on undefined product behavior. **No MAJOR found: under her
five-round rule this round does not earn another**, subject to the owed evidence (the pending stage windows
and walks) coming back as the record expects — a red there re-opens as its own trace, not as this round's.

## 2. Dispositions

The cross-model flow: the findings went to the implementer (the batch-3 closer, Opus, 2026-11-19) verbatim; its
agree/dispute below returns to this reviewer for the final call. Nothing was changed for this step — the reviewer
calls first.

| # | Finding | Implementer | What would change | Pin | Reviewer's final call |
|---|---|---|---|---|---|
| R1-m1 | [MINOR] the theme store's start is per shell identity, its bind per session | **AGREE** — hollow; the premise re-traced against `AppBootstrap` and holds (§2a) | one sentence in `MobileShellRouter.bindTheme`'s doc comment (§2a gives it) | none possible: no reachable input produces the state; a pin would be hollow by the protocol | **CONFIRMED** as proposed (§2b, 1) — the sentence lands on `bindTheme`'s doc comment as §2a words it; no code, no pin (hollow as filed) |
| R1-n1 | [NIT] `MobileRootMenu.Item.id` is the title | **AGREE** | one sentence in `items(settings:)`'s doc comment (§2a) | none useful: with one item a uniqueness pin is green on both sides | **CONFIRMED** as proposed (§2b, 2) — one sentence in `items(settings:)`'s doc comment (an item's word is its identity, so each must be distinct); no pin |
| R1-n2 | [NIT] two adjacent dividers in the note's ⋯ sheet | **AGREE** on the effect, with one correction to the mechanism (§2a) | nothing now — VM-61 / VM-148's next touch of the sheet | none (a `Divider` is not an accessibility element; a geometry pin would be heavier than the defect) | **CONFIRMED** as proposed, §2a's corrected mechanism adopted (§2b, 3) — no action here; **owner: VM-61 / VM-148**, at that sheet's next touch (its rows made subview-aware, the `MobileSettingsGroup` shape) — named here as the reviewer's condition requires |
| R1-n3 | [NIT] the bar's first frame at width 0 assumes the widest chip sides | **AGREE** — no action | nothing | none (one frame; not observable in process) | **CONFIRMED**, no action (§2b, 4) — one frame, corrected by the first geometry pass; batch 4's recorded risk 4 |
| R1-n4 | [NIT] a doubled word in `MobileReadView`'s ground comment | **DISPUTE** — the doubled word is not in the file (§2a) | nothing — the line is her R-13u-10 words, verbatim | — | **DISMISSED** — the reviewer's own error (§2b, 5): its evidence was a filtered diff grep (only lines holding "room"/"background"), which set :115's trailing "the" beside :117's leading "the"; the file has no doubled word, and :117 is her words, never to be edited |

### 2a. The implementer's answers

**R1-m1 (MINOR) — AGREE, hollow; the premise checked against the bootstrap.**
- *The two halves, as the reviewer says.* `MobileShellRouter.bindTheme(session:)` (`MobileShellRouter.swift:114–125`)
  is idempotent per `ObjectIdentifier(session)` and mints a NEW `ThemeStore` for a new session; the store is
  started only by the shell's `.task` (`MobileShellView.swift:288–294`, `await router.theme?.start()`), which runs
  once per appearance of that view identity and is never re-keyed on the session. The shell is mounted in the app's
  `switch bootstrap.state` under `case .ready(let session)` (`VariorumMobileApp.swift:69`).
- *The premise — "every session change passes through a non-ready case" — holds.* `AppBootstrap.state` is written
  `.ready(_)` in exactly ONE place: the open's landing (`AppBootstrap.swift:506`), reached only through
  `beginOpening` (`:314–330`), which writes `state = .opening` synchronously and then AWAITS a detached open
  (`routeAndOpen` — the road's facts, `openStore`, the migration set, off the main actor) before landing. Every road
  that replaces the session goes there through a non-ready state written BEFORE awaited off-main work: the lock
  (`lockOnNewRoad`, `:1471–1479`: `.opening`, then the lobby, which waits for her unlock), the re-key
  (`reopenAround`, `:1342–1349`), "make this my library" (`makeThisMyLibrary`, `:959`), bringing in a plaintext
  export (`bringInPlaintextExport`, `:824`); and the empty-slot adoption (`makeThisMyLibraryInTheEmptySlot`, `:889`)
  starts only from a non-ready state (the missing library or the lobby) and then calls `beginOpening`. The app's
  one other `.ready` match (`VariorumMobileApp.swift:255`) is the scene-phase handler reading the session, not a mount. Each awaits real I/O (closing the pool, re-keying, opening and
  migrating), so SwiftUI renders the non-ready branch in between, the shell leaves the tree, its `.task` is
  cancelled, and the next `.ready` mounts a fresh shell whose `.task` starts the new store. No road writes `.ready`
  over `.ready`.
- *A second road I checked — identifier reuse.* `bindTheme` keys on `ObjectIdentifier(session)`, and an identifier
  can be reused once its object is freed; a NEW session at an OLD session's address would be mistaken for the old one
  and keep the old store. It cannot happen: the held store retains its session strongly (`ThemeStore.swift:31`,
  `private let session: AppSession`), so the old session cannot be freed — nor its address reused — while the router
  still holds the store that names it. And a remount over the SAME session (re-keyed nothing) re-runs `start()` on
  the kept store, which opens a fresh observation each call (`ThemeStore.start`, `:66–87`; a cancelled loop ends on
  `CancellationError`) — correct.
- *What the reviewer's coupling shares, said for the comment.* The theme store is not the only thing built for the
  shell's identity: every model the shell holds (`shelfModel`, `libraryModel`, `starsModel`, `trashModel`, …) is
  `@State` initialized from `session` in `MobileShellView.init` (`:165–170`), and `router.quickNote.bind(session:)`
  (`:176`) has the same per-session idempotence. So a road that swapped sessions without leaving `.ready` would leave
  the WHOLE shell on the old session, not only the theme; the remedy then is keying the shell on its session in the
  app's ready branch (`.id(ObjectIdentifier(session))`), which restarts the theme's task with it.
- *The change I would make* (`MobileShellRouter.swift`, `bindTheme`'s doc comment, after its last sentence "…reaches
  the editors whichever device wrote it."): *"The bind is per SESSION but the store is STARTED by the shell's
  `.task`, once per shell identity: today every new session reaches the shell through a non-ready bootstrap state
  (`AppBootstrap.beginOpening` writes `.opening` before its awaited open), which remounts the shell. A road that
  swapped sessions WITHOUT leaving `.ready` would leave the new store unstarted — and every `@State` model the shell
  built from the old session — so it must key the shell on its session (VM-47 ladder round 1, R1-m1)."* No code
  change; no pin (unreachable).

**R1-n1 (NIT) — AGREE.** `MobileRootMenu.Item.id` is `title` (`MobileRootMenu.swift:66`) and the menu's `ForEach(items)`
(`:83`) keys on it; two items with one word would collide. Today `items(settings:)` (`:71–77`) holds one. *The change I
would make:* in `items(settings:)`'s doc comment, after "Later umbrellas append theirs.": *"An item's word is its
identity in the menu (`Item.id`), so each item's word must be distinct."* No pin: with one item a uniqueness check
is green on both sides.

**R1-n2 (NIT) — AGREE on the effect; the mechanism is a little different from the finding's words.** The sheet's
body (`MobileNoteActions.swift:101–115`) is: Divider (`:108`) · `undoRow` · `redoRow` · `settingsRow` · Divider
(`:112`) · `deleteRow`, and `settingsRow` (`:269–277`) draws its OWN leading Divider (`:271`). With both stacks empty
(`undoRow`/`redoRow` render nothing — P-2) and the shell's door present, the adjacent pair is the body's divider
BEFORE the undo group (`:108`) and `settingsRow`'s own (`:271`) — not a divider "after `redoRow`'s empty slot". The
pre-run shape (`fe85ea6d5`, `:110` and `:113`) doubled the same way when both rows were absent, as the reviewer says;
outside a shell (no door) today's sheet doubles exactly as it did before. *If it is done:* `settingsRow` draws its
leading divider only when an undo or redo row renders (`if door.undoLabel != nil || door.redoLabel != nil`), so the
group's two dividers never touch — a one-line condition, but a layout change on a sheet VM-61/VM-148 rebuild; I
agree with "no action now". No pin: a `Divider` is not an accessibility element.

**R1-n3 (NIT) — AGREE, no action.** `MobileTabBar`'s width is `@State` 0 until `onGeometryChange` reports
(`MobileTabBar.swift:101, 121`); `chipSide(_:)` returns the widest side (16) at width 0 (`:165`) and the chip then
does not shrink (`shrinkingToFloor: side == nil` is false), so at AX5 in Terminal the first layout may draw a chip
that does not fit, corrected on the first geometry pass. Assuming the narrowest instead would make the default
size's first frame the wrong one. Already batch 4's self-assessment risk 4. No pin (one frame, not observable
in process).

**R1-n4 (NIT) — DISPUTE: there is no doubled word.** `MobileReadView.swift:115–118` reads: *"VM-51: the room around
the cream page is the VOICE's own, never the / palette's — the Mac's rule (R-13u-10, her "leave that white so that /
the cream read page isn't on a colorful background"; R2: only the / room follows the voice), now that the phone
wears a palette."* — "never the / palette's" and "so that / the cream read page" (her words, verbatim, as the
Mac's `VoiceTokens.swift:454–455`, `ReadModeView.swift:848–849` and `ReadPageRoomTests.swift:6–7` quote them). A
script over every comment line of the file at `c5dbae56b` (the reviewer's HEAD) and at HEAD finds no word repeated
across a line break and none within a line; the comment was written once (`af487bfe7`) and not touched since.
Nothing to change — and the "so that the" is hers, so it must not be edited.

### 2b. The reviewer's final calls (verbatim, 2026-11-19)

The reviewer's reply was cut off once by a usage limit and resumed in the same session; nothing in the worktree
changed in between. Its reply:

**1 (MINOR, theme store started per shell while bound per session) — CONFIRMED as the implementer proposes.** Its premise-check strengthens the trace: one `.ready` assignment site reached only through `.opening`; every session-replacing road passes through a non-ready state; the identifier-collision case is ruled out because the held store keeps the old session alive. The remedy sentence lands on `bindTheme`'s doc comment as the implementer worded it (the coupling is the shell's generally; keying the shell on its session is the remedy). No code, no pin — hollow as filed.

**2 (NIT, menu items identified by their title) — CONFIRMED as the implementer proposes.** One sentence in `items(settings:)`'s doc comment: each item's word must be distinct, since the word is the identity. No pin.

**3 (NIT, adjacent dividers in the note's ⋯ sheet) — CONFIRMED as the implementer proposes, with its corrected mechanism adopted as the record's.** The touching pair is the body's unconditional divider before the undo group (`MobileNoteActions.swift:108`) and the Settings row's own leading divider (`:271`); my "after redoRow's empty slot" was the same adjacency described loosely. Leaving it to VM-61/VM-148 is ACCEPTABLE: not a regression (the empty-stacks state drew a doubled hairline before this run), and the honest fix is not one line — the Settings row's leading divider is load-bearing whenever undo or redo renders, so removing the double needs the sheet's rows to go subview-aware (the `MobileSettingsGroup` shape), exactly that sheet's next-touch work. Condition: the §2 disposition row names the owner (VM-61/VM-148) so the hand-off is on the page.

**4 (NIT, tab bar's first frame assumes widest chip padding) — CONFIRMED, no action.** One frame, corrected by the first geometry pass, already batch 4's recorded risk.

**5 (NIT, doubled word in `MobileReadView`'s comment) — DISMISSED; the implementer's dispute is correct and the finding was my error.** I re-read lines 115–118 myself before ruling: the text runs "never the / palette's …" and "… so that / the cream read page …" — no doubled word at my reviewed HEAD or now. My evidence was a FILTERED diff grep (matching only lines containing "room"/"background") that dropped lines 116–118's middles and juxtaposed line 115's trailing "the" with line 117's leading "the" — I cited grep output as if it were a reading. Line 117 quotes her R-13u-10 words verbatim and must not be edited. Withdrawn and recorded as wrong, not deferred.

**The confirmed fix pass, in full** (the implementer applies; nothing is FINDER-FIXES; nothing goes to QUESTIONS): (1) one doc-comment sentence on `MobileShellRouter.bindTheme`; (2) one doc-comment sentence on `MobileRootMenu.items(settings:)`; (3) no code — the divider pair recorded in §2 with its owner; (4) nothing; (5) nothing — §2 records the dismissal and the filtered-grep reason. No rendered word, no behaviour change ⇒ no pin anywhere; no stage window owed for this pass beyond a compile. §1's pending-evidence list (batch 3's Mac leg and walk, batch 4/5 counts, VM-27's red-on-old snapshot run, the batches-4/5 walk, the post-re-land whole targets) stands unchanged. Round-1 tally after dispositions: 0 BLOCKER · 0 MAJOR · 1 MINOR · 3 NIT confirmed · 1 NIT dismissed — no MAJOR, so under her five-round rule no further round is earned, subject to the owed evidence coming back as the record expects.

**The orchestrator's note on rounds.** By her rule this ladder has earned no further round on its findings. One
more cold read is taken anyway, as round 2, because substantial change enters after this round: VM-55's merge
re-landed across the phone's root and sheet files, and whatever the run's one walk turns up. Round 2 reads those
and this pass's two comment sentences.
