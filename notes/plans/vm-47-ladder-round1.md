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

PENDING — the cross-model flow: these findings go to the implementer verbatim; its agree/dispute returns to
this reviewer for the final call.
