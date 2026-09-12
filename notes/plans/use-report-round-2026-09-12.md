# The 2026-09-12 use-report round — 17p · 18g · 18h · 18i (EXECUTION PLAN, v1)

**STATUS: v2 — RULED AND RUNNING (the kickoff sitting of 2026-09-12: every Q-1…Q-10 answered — §7 is the record; §1 keeps the questions as asked). First batch: 17p batch a (R-1).** *(v1, the same day: READY FOR THE KICKOFF SITTING.)* Run shape, hers: `/architect-phase`, the second round
"in the mold of" the 2026-09-06 use-report round — a Fable orchestrator that stays LEAN, `opus-implementer`
on every batch, `fable-reviewer` where the landing family or a default's meaning moves, `opus-reviewer`
elsewhere. Runs NOW, before 13u1 (her sequencing, the same as last round's).**

**Sources:** her report of 2026-09-12 — `notes/author-reports/2026-09-12-use-report.md`, verbatim, with
the image manifest (ten files in the gitignored `notes/plans/use-report-2026-09-12-screens/author/`).
The previous round's record and handoff are the precedent and the vocabulary:
`notes/plans/use-report-round-2026-09-06.md` · `notes/handoffs/use-report-round-2026-09-06-handoff.md`.

---

## 0. What this round is (one paragraph)

Three days after the last round refreshed her install, she wrote in the app again and the Takes page
"looks like an absolute mess" and "keeps trying to jump to the bottom" — and the two are ONE defect:
the last round's row-8 fix made the Takes board scroll its current block to the TOP of the viewport on
every entry, and the typewriter room (13f W7) lets the LAST block sit there with nothing above it, so a
two-block note opens showing only its empty third block and a dashed door (§4.1). Around that sit
eight smaller things — the empty block's placeholder under the caret, a Delete Now the tray's copy
promises but its block rows lack, a collapsed field in the Callout Emoji alert, the comment badge and
the callout's emoji drawn over the text in the book Outline, the confirmation toasts "always
appearing" — and four asks that change what the app IS: created/edited times in the Library and the
note, the Library sortable by time, an "edited on this day" search, and pastel colour palettes with a
custom hex. This round takes all of it, grouped by KIND into four letters: **17p** the defects ·
**18g** colour palettes · **18h** time (stamps, sort, the day search) · **18i** the confirmations
setting. The phone's opening-scroll complaint rides 17p if it shares the Mac's mechanism (Q-9).

## 1. Her asks, and THE SITTING'S QUESTIONS (Q-1…Q-10 — recommended option FIRST; her rulings land here VERBATIM-FAITHFUL the turn she gives them)

Her words are quoted from the report; the ledger (§3) carries the rows.

- **Q-1 — THE TAKES SCROLL RULE.** *"it's absolutely infuriating the way the page keeps trying to jump
  to the bottom and now show the text above… even if you left it scrolled up and you only have two
  blocks, if you leave and come back to the page it won't be showing the top two — it's bizarre, it
  should remember your scroll position."* The mechanism is §4.1. Options: **(a) RECOMMENDED — remember
  the article's scroll per note for the session and restore it on entry (Write's `scrollAnchors`
  class); a landing (the current block on entry, a bloom from the fan panel) only REVEALS its slot
  when it is off-screen, minimally, never anchored to the top; the typewriter room stays.** (b) the
  same, but also persist the scroll across launches beside the persisted caret (the 17o-b quit-write
  class) — more machinery for a cold launch that already lands on the remembered block. (c) retire
  the entry landing entirely (the page always opens where it was; the caret ring still marks the
  current block) — loses row 8's "go there" for the fan-panel door, which she asked for.
- **Q-2 — THE EMPTY BLOCK'S FACE IN TAKES.** *"the invitation to write a block is weird… The empty
  take — line kept instruction is not good… I want it to return to what it used to look like."* The
  placeholder is Phase 13 batch 9's R103 ("a take deleted down to nothing KEEPS the block's own line —
  and the kept line says what it is"), never meant for a block she just minted; 18c's Return and the
  17o ＋ new block door made empty blocks everyday, and under the indicator OFF the live pane has no
  ring, so the caret sits over the words (image 1). Options: **(a) RECOMMENDED — a LIVE empty pane
  shows only the caret (the caret is the invitation); a NOT-live empty block shows one faint word in
  the pane's own first-line position, never over anything — the word hers (candidate: "empty");
  the ＋ new block door aligns to the text's left edge, not the cell's.** (b) no placeholder at all —
  an empty block is an empty line exactly as Write renders it (R103's "says what it is" retired; the
  ⑂+ badge still marks the row). (c) keep R103's words, fix only the overlap and the alignment.
- **Q-3 — DELETE NOW ON THE TRAY'S BLOCK ROWS.** *"i don't know where Delete Now is here — the text
  talks about it but the button doesn't appear to be visible."* §4.3: only the TAKE rows carry it
  (her G5 fourth-sitting ruling); the block rows have Put back alone while the explainer promises
  both. Options: **(a) RECOMMENDED — block rows in Leaving get Delete Now (the same confirm-every-time
  door the Library's Trash gives a block; stranded originals stay without one — they ride their
  family's clock, as the Trash's own rule says).** (b) reword the explainer to promise it for takes
  only. The purge-doors rule ("TRASH SURFACES, never the writing flow") is satisfied either way.
- **Q-4 — THE BADGE, THE EMOJI AND THE TEXT (the book Outline).** *"the callout goes on top of the
  comment badge which is on top of the text. not good it should move it. and in book view the
  comment thing needs to be moved or only accessible on the left because it's blocking the text."*
  §4.4: both decorations place themselves LEFT of `textLeft` and clamp at 2 pt, so in a surface whose
  text starts ~40 pt from the edge they land on the words, and on each other. Options: **(a)
  RECOMMENDED — the inline editor reserves a LEFT LANE (≈40 pt) whenever the note carries a comment
  or a callout emoji, the badge lives in the lane, and the emoji moves INSIDE the callout frame's own
  leading inset (the glyph is the frame's, so the frame widens to hold it); nothing ever covers
  text; comments stay on the left (her R5-3 letter).** (b) no lane: the badge degrades to the inline
  strip under the block where the gutter is too narrow (R7's inline grammar) — but the strip's room is
  the widened gap that exists only under the inline setting. (c) hide the badge where there is no
  room (the comments panel and the block menu stay the doors) — a silent door.
- **Q-5 — THE CONFIRMATIONS.** *"there's these little text confirmation popups that are always
  appearing… i either need them off, more subtle in the bottom bar in more muted text, or a setting if
  i can turn it on or off. maybe the setting is the best option?… i don't always need it less
  noticable because for some operations it's the right confirmation text to show."* §4.5: every
  message funnels through ONE `StatusCenter.speak`; ~105 sites, most of them REFUSALS ("Click into a
  block first…") that must always show. Design: the messages gain a KIND — refusal · offer (carries a
  button) · receipt (the after-the-fact "Blocks joined — ⌥⌘Z undoes it", "Block divided", the
  newlines-chip sentence, "Moved — now block 3 of 8") — and a setting governs RECEIPTS ONLY:
  **toast** (today) · **quiet** (a muted line in the bottom bar, fading) · **off**. Refusals and offers
  always toast. Her call: **the DEFAULT — RECOMMENDED quiet**; alternatives toast (today's look,
  opt-down) or off.
- **Q-6 — COLOUR PALETTES.** *"I need basic color themes that also update the lightly colored text
  like (this note) and commit. I want at least lavender, mint green, pink, blue, a pastel set. and
  maybe the ability to choose the hex code of your default theme (should recolor the tan panels
  basically) and the text that is going on top of those panels."* §4.6 + the mockup
  `notes/plans/use-report-2026-09-12-mockups/palettes.html`. Design: a PALETTE layered on a VOICE —
  the voice keeps its idioms and type (R1/R12 untouched: still exactly two voices); the palette is
  ONE seed hue from which a pure brain derives the room (the tan panels), the wash, the accent (the
  coloured chrome words), the take tint/line and the hairline; four named seeds (lavender · mint ·
  pink · blue) plus **custom** (a hex field); "default" keeps each voice's shipped colours
  byte-identical. Dark mode stays FULLY BLACK (R51) — only the accent, wash and tints derive.
  Stored as synced settings (`theme_palette` an enum; `theme_tint` a validated 6-hex-digit value —
  structured, not prose, inside `setting.value`'s PLAIN promise; the reviewer checks this). Questions:
  (i) both voices take palettes — **RECOMMENDED yes**; (ii) the four seeds as mocked, adjusted at her
  eye; (iii) the custom field recolours the same family the presets do (one brain, no per-token
  picker — **RECOMMENDED**), or a per-token picker (more, and a second brain).
- **Q-7 — WHERE THE TIMES GO.** *"I need to be able to see the created time and last edited time
  easily on the library and within the note itself — maybe a little clock icon, maybe just the
  actual details somewhere. I like how apple notes does it where you can see the time it was last
  edited and if you click on it you see when it was created."* Options for the NOTE: **(a)
  RECOMMENDED — a quiet stamp at the trailing end of the masthead's second row ("edited today 1:33
  AM" / "edited Sep 9") that toggles to "created …" on click (Apple Notes' gesture), live under the
  autosave stamp;** (b) a clock glyph beside the ⌗ door opening a small popover with both. For the
  LIBRARY: a muted trailing stamp on every List row (edited, or the sort's own stamp when sorting by
  created); the Notes card's date line shows the same. Relative words today/yesterday, else the date;
  the exact time in the tooltip. Her call on (a)/(b) and on whether the stamp shows the time or only
  the day at rest.
- **Q-8 — SORT, AND THE DAY SEARCH.** *"i need to be able to sort the library by time… the time alone
  is a minimum… how difficult it would be to implement being able to search for any note edited on a
  particular day."* Sort: the Library gains a `sort ▾` voiced menu — edited (the default, as today) ·
  created · date (entry date) · title A–Z — with a direction toggle, remembered locally. The day
  search — the answer to her question is in §4.8: **cheap** (an indexed range on `last_touched_at`,
  one statement; with one honest caveat: only the LAST edit day is stored per note, so a note edited
  Monday and Tuesday answers Tuesday only — the savepoints (one per session since 13j) give the
  earlier days, and a UNION over them answers "edited on" the way she means it). Options: **(a)
  RECOMMENDED — build it in this round as a small filter in the Library header ("on day…" with a date
  field), the union query, one batch beside the sort;** (b) defer to 13o (search) with the query
  designed here.
- **Q-9 — THE PHONE.** *"the mobile app also has this issue to an even worse degree where it defaults
  to showing NONE of the written text lines… that could be fixed now during this round as well if
  it's shared."* Which surface: the Write page on opening a note, or the takes browser sheet? The
  trace (§4.9) finds the candidate on the WRITE page — the arrival lands at the note's end and the
  typewriter room makes the end a legal top — the same room-plus-landing class as the Mac's, NOT the
  same code (the phone's scroll is `UITextView` content offset; nothing shared moves). A screenshot
  from her decides. If confirmed: a 17p mobile batch on the phone's Write arrival (reveal, never
  land-at-top; remember the offset per note for the session).
- **Q-10 — THE CAST AND THE ORDER.** Recommended: `fable-reviewer` on 17p batch a (the landing family
  — the last round's batch-b ladder found a BLOCKER there) and on 18g (a default's meaning: the
  voice/palette resolution reaches every surface); `opus-reviewer` elsewhere; the round-end Fable
  pass over the Opus-reviewed letters as last time. Order: **17p → 18h → 18i → 18g** (her two named
  pains first; the palettes last because they are the widest surface change and their mockup wants
  her eye before the build).

## 2. Where this sits — numbering, sequencing, the fences

- **Four letters, why.** CLAUDE.md's rule splits fixes (17) from product (18). The Takes scroll and
  face, the tray door, the alert, the badge/emoji lane and the phone's arrival are DEFECTS →
  **17p** (claimed in `notes/plans/phase-17-standing-fixes.md`'s register). Palettes (**18g**), time
  stamps + sort + the day search (**18h**) and the confirmations setting (**18i**) change what the app
  IS → the master plan's Phase 18 row. Letters are allocation order; the running order is Q-10's.
- **Sizing (`notes/PhaseSizingGuidance.md`), stated:** 17p is six defect rows in two one-surface
  batches (the Takes board; the chrome singles — the phone's row left for the mobile session, R-Q9); 18g one unit (the token layer + one
  settings row + the mockup's four seeds); 18h one unit (a core column on the listing item, a sort
  menu, two stamps, one filter) — the day search is its second half and may be held (Q-8); 18i one
  unit (the kind on the one status seam + a setting + a bar slot). Nothing here is phase-sized; the
  widest change is 18g's palette resolution, which is why it goes last and gets the Fable eye.
- **THE 13u FENCE — untouched, as last round:** nothing here touches `BlockRangeIndex`,
  `EditorTextView`'s seam, `CrossBlockEditPlanner` or `PaneTextAuthority`'s liveness contract. The
  Takes scroll is the BOARD's (`TakesBoardLayout`/`TakesChoreographer`/the article's `ScrollView`),
  never the pane's authority; a session that finds it must change the authority stops and records.
  The Outline's shadow second editor (KnownIssues, 13u2) is NOT this round's — the badge lane fix
  must not depend on it.
- **Zero schema, zero `Sync/`, the marker stays 8.** 18h adds a column to a QUERY item
  (`TimelineItem.lastTouchedAt`), not to a table; 18g/18i add `setting` KEYS (upsert-only, enum-valued
  — the `fan_style` class), not columns. If a session believes it needs a migration it stops.

## 3. THE LEDGER — her items, every one a row

Status vocabulary: OPEN · TRACED · FIXED(pin) · RECORDED · DEFERRED(owner) · HERS. "Traced" means
traced by READING, unproven — the pin is the first act of every fix. Image numbers are the report's.

| # | Her words (short) | Surface | Traced mechanism / architect's read (file:line) | Letter · batch | Status |
|---|---|---|---|---|---|
| 1 | "the page keeps trying to jump to the bottom and not show the text above… it should remember your scroll position" (image 1: block 3/3, only the empty block visible) | Takes article | The N9 entry arm scrolls the CURRENT block to the TOP (`TakesChoreographer.consumeLandings`, `:196–205` → `landArticle`; the view's `column.scrollTo(landing, anchor: .top)`, `TakesBoardView.swift:616–619`) and the typewriter room (`typewriterRoom`, `:606/:646`) makes the last block a legal top; no scroll memory exists for the article — §4.1 | 17p · a | RULED (R-Q1) — batch a |
| 2 | "the take page looks like an absolute mess now… misaligned… the invitation to write a block is weird… The empty take — line kept instruction is not good" (images 1, 2) | Takes cell | The R103 placeholder overlay (`TakesShared.swift:191–204`: `padding(.leading, 8)`, `.top, 6`) sits where the live caret sits, under the indicator OFF no ring frames the pane (`PaneDecoration.resolve`, `PaneSurface.swift`), and "＋ new block" aligns to the CELL's edge (`TakesBoardView.swift:582–598`) while the prose sits `textContainerInset` + 2 pt inboard — §4.2 | 17p · a | RULED (R-Q2) — batch a |
| 3 | "i don't know where Delete Now is here — the text talks about it but the button doesn't appear" (image 3) | This Note's Tray | Block rows render Put back only (`TrayPanel.row(...)`, `:1112–1155`); take rows carry Delete Now (`:1060`); the explainer is the panel's (`RecoveryCopy.swift:282`) — §4.3 | 17p · b | RULED (R-Q3) — batch b |
| 4 | "the callout pane is broken" (image 9) | Callout Emoji alert | `CalloutMenu.emojiAccessory` (`:183–204`): an `NSStackView` of an editable field with no width constraint — an empty editable `NSTextField` has a near-zero intrinsic width, so the stack gives the button its size and the field the sliver — §4.4a | 17p · b | TRACED |
| 5 | "the callout goes on top of the comment badge which is on top of the text" (image 11) | Book Outline (inline editor) | The emoji label at `x = max(2, textLeft − width − 8)` (`BlockDecor.swift:476–480`); the badge at `x = max(2, textLeft − 36)` (`:585–593`); both clamp onto the text when `textLeft` is small — §4.4b | 17p · b | RULED (R-Q4) — batch b |
| 6 | "in book view the comment thing needs to be moved or only accessible on the left because it's blocking the text" (image 10) | Book Outline | The same mechanism as 5, the badge alone | 17p · b | RULED (R-Q4) — batch b |
| 7 | "the mobile app also has this issue to an even worse degree where it defaults to showing NONE of the written text lines" | Phone (surface TBD) | Candidate: the Write arrival + the phone's typewriter room (`MobileEditorViewModel.jumpToBlock` shows the room's contract, `:838–860`); NOT shared code with the Mac's row 1 — §4.9 | — (mobile) | DEFERRED (the mobile app project row — her ruling R-Q9; written to the mobile branch's handoff §12.2; PL-22) |
| 8 | "little text confirmation popups that are always appearing… blocks joining… a newline divide" (images 6, 7) | `StatusCenter` + the toast | ONE seam: `StatusCenter.speak` (`Registry/StatusCenter.swift:49–62`, 6 s auto-dismiss) rendered by `StatusToast` at the shell's bottom (`RootView.swift:177`, `NoteWindowView.swift:106`); the editor's `statusMessage` forwards to it (`EditorViewModel.swift:71–73`); no kind, no setting — §4.5 | 18i | RULED (R-Q5: quiet default, toast an option) |
| 9 | "see the created time and last edited time easily on the library and within the note itself" (image 4) | Library rows + the note masthead | `TimelineItem` carries `createdAt` and the sort `stamp` only (`Queries/Timeline.swift:10–23`); the List row shows `hit.detail` (the entry date) beside the title (`LibraryCatalogView.swift:978`); the masthead has no stamp (`MastheadRowTwo`: chip + tags) — §4.7 | 18h · 1 | RULED (R-Q7) |
| 10 | "i need to be able to sort the library by time" | Library header | `LibraryViewModel.start` hardwires `sort: .lastTouched, direction: .desc` (`:48–50`); core `LibrarySort` already has entryDate · createdAt · lastTouched · lastMajorRevision (`Timeline.swift:97–108`), no title case; no control in the header (`LibraryCatalogView.swift:690–735`) — §4.8 | 18h · 1 | TRACED |
| 11 | "how difficult it would be to implement being able to search for any note edited on a particular day" | Library filter | Cheap: `idx_container_touched` on `last_touched_at`; the honest caveat and the savepoint union — §4.8 | 18h · 2 | RULED (R-Q8: build now) |
| 12 | "basic color themes… lavender, mint green, pink, blue, a pastel set… the hex code of your default theme" (image 5) | The token layer + Settings | `VoiceTokens.resolve(voice:dark:)` picks one of four static token sets (`Shared/Theme/VoiceTokens.swift:153–160`); `ThemeStore` reads `Queries.themeSettings` (six keys); 67 resolve sites consume tokens, none hold a literal — §4.6 | 18g | RULED (R-Q6) |

## 4. The traces (the architect's read — by reading, never by running; the pin decides)

### 4.1 Rows 1 — why Takes opens at the bottom (and why image 1 IS image 2)
The last round's 17o batch b (row 8, *"open takes mode in write from the takes menu is also not
automatically navigating you to where the take is"*) taught the board to scroll to a landing: the bloom
arm sets `landArticle(on:)`, and — the over-reach — so does the N9 entry arm whenever the note's
CURRENT block (the persisted `CurrentBlockMemory`, i.e. the block she last typed in) names a slot
(`TakesChoreographer.swift:196–205`: *"the board ENTERS on the note's current block, so the page shows
it"*). The view spends the landing with `column.scrollTo(landing, anchor: .top)`
(`TakesBoardView.swift:616–619`). Anchor TOP puts that block's top edge at the viewport's top — every
block above it leaves the screen — and the typewriter room (13f W7, `typewriterRoom(viewport:)` at
`:606`, height from `TypewriterRoom.height`) is exactly the content extent that lets the LAST block sit
at the top. So: she types in the last block in Write (the current block), switches to Takes, and the
page opens with blocks 1–2 above the fold and the empty third block alone under the chrome — image 1.
Scrolling up and coming back does nothing, because the entry arm fires on every mount and there is no
scroll memory on the board (Write's `session.editorRouter.scrollAnchors[postID]`, `EditorViewModel.swift:522`,
has no Takes twin). **The fix (Q-1 (a)):** (i) the board remembers the article's offset per note for
the session (a `scrollPosition`-bound anchor or an offset read on scroll — the implementer's choice,
pinned at the model), restored before any landing is considered; (ii) a landing REVEALS — the model
computes "is the slot's row inside the viewport?" from the rows' reported frames (the
`rowAppeared`/`rowDisappeared` hooks at `:574–575` already exist) and asks the view to scroll only when
it is not, with `anchor: nil` (SwiftUI's minimal scroll) — never `.top`; (iii) the bloom arm keeps
its request (row 8's door still "goes there") under the same reveal rule. Pin (red on old): mount the
board on a three-block note whose current block is the last, read the article's offset after the
settle → 0 (old: the last block's y). Second pin: leave at offset N, re-mount → N.

### 4.2 Row 2 — the empty block's face
`TakesCellView` overlays *"empty take — line kept"* on any resolved take whose text is empty
(`TakesShared.swift:191–204`) at `(8, 6)` from the cell's top-leading — the pane's first line sits at
`textContainerInset` (`PaneSurface.makeSurface`, `:644`), so under a live pane the caret is drawn
through the words (image 1). Two things changed around it, not it: 18c's Return mints empty blocks
on every paragraph break, and 17o batch c's U-7 fix (`PaneDecoration.resolve`) draws NO ring for a
live pane under the indicator OFF — so the only frame an empty block ever had is gone, and the
placeholder is all that shows. The ＋ new block door (`:582–598`) pads from the CELL's edge; the prose
is inset by the pane's `inset` + the cell's `.padding(2)` — the ~16 pt she reads as misaligned (her
image 2: the door at 480, the words at 500). **The before/after capture diff is the batch's FIRST
ACT:** build the pre-round tree (`f402ccce`, a scratch worktree) and the current tree, open the same
three-block fixture note in Takes in both voices, capture, and table every visible delta — so
"return to what it used to look like" is answered by evidence, not by memory. Then Q-2's ruling.

### 4.3 Row 3 — the tray's Delete Now
`TrayPanel.cellRows` renders block rows through `row(...)` (`:1112–1155`), which carries ONE verb,
Put back; only `takeRow` (`:1060–1067`) has Delete Now — her G5 fourth-sitting addition *"to keep the
capability"* because takes stopped rowing in the global Trash (D1). Blocks DO row in the global Trash
with Delete Now (`RecoveryView.swift:896–903`, every kind but preserved originals), so a block's purge
door exists — one Library away. The panel's explainer (`RecoveryCopy.swift:282`: *"Put back keeps a
row; Delete Now ends its days early"*) describes the panel, so on a block row it promises a door that
is not there. Q-3 (a) adds it through the same confirm (`TrashPurge.deleteNowConfirm`) and the same
purge act the Trash uses; the stranded originals keep no door (the Trash's own rule, `:893`).

### 4.4 Rows 4–6 — the callout alert, the badge and the emoji
**(a) The alert.** `CalloutMenu.emojiAccessory` (`:183–204`) builds an `NSStackView` (`.horizontal`,
`.firstBaseline`, frame 320×26) of an editable `NSTextField(frame: 200×24)` and a small button. An
arranged subview's frame is ignored — the stack lays out by intrinsic size and priorities — and an
empty editable field's intrinsic width is next to nothing, so the field collapses to the sliver in
image 9 while the button keeps its size. Fix: a width constraint on the field (≥ 200) and hugging
priorities, or a fixed-width accessory laid out by hand. Pin: build the accessory, force layout in a
window, assert the field's width ≥ 150 (red on old). The 13e E1 pin (`DoorSetTests:327`) checked the
title only.
**(b) The lane.** `BlockDecor` places the comment badge at `x = max(2, textLeft − 36)` when the gutter
cannot fit cards (`:585–593`) and the callout's emoji at `x = max(2, textLeft − width − 8)`
(`:476–480`). In Write the text starts far from the edge, so both land in the margin. The book
Outline's inline editor starts its text ≈ 40 pt in, so both clamp onto the first characters — and
onto each other, since both target the same corner. Q-4 (a): the inline editor reserves a left lane
whenever any of its blocks carries a comment or a callout emoji (its `textContainerInset.width`, read
by the decor as `textLeft`), the badge keeps its lane rule, and the emoji moves INSIDE the frame
(`calloutRect` grows a leading inset for it; the text's `firstLineHeadIndent` for a callout block
gives it room — the iOS-proven paragraph-style road, TEXTKIT2 §3, never `exclusionPaths`). Pins:
the badge's and the emoji's rects never intersect the block's text rect, in a mounted Outline surface
with a commented callout (red on old).

### 4.5 Row 8 — the confirmations have one seam
Every message in the app reaches the shell through `StatusCenter.speak(_:action:)`
(`Registry/StatusCenter.swift`), rendered by `StatusToast` at the bottom centre (`RootView.swift:177`;
`NoteWindowView.swift:106`), 6 s auto-dismiss; `EditorViewModel.statusMessage` and the boards'
`setStatus` forward there. ~105 call sites; by reading, roughly 80 are refusals (the "Click into a
block first…" family, `OpsRefusalCopy`, `RefusalCopy`), ~5 are offers (an `Item.Action`), and ~20 are
RECEIPTS — her two images are receipts (`EditorSurfaceController.swift:2215` *"Blocks joined — ⌥⌘Z
undoes it."*; `OpsRefusalCopy.swift:38` the newlines-chip sentence; `FannedDefaults.swift:188/207/216`;
`TakesStructureController.swift:517/627`; `BlockTOCView.swift:333/370/417`). Design (Q-5): `Item.kind`
(`.refusal` the default of `speak`, so every existing site and pin is unchanged; `.offer` implied by
an action; `.receipt` by a new `receipt(_:)` door the ~20 sites adopt) + a synced setting
`receipt_style` ∈ `toast · quiet · off` (enum, the `fan_style` class) + the bottom bar's QUIET slot
(a muted line at the bar's trailing end before the word counts, fading on the same 6 s clock — the
CommitBar's footer already owns that corner). A pin per class: a refusal toasts under every setting;
a receipt lands where the setting says. The strings are untouched.

### 4.6 Row 12 — palettes over voices
`VoiceTokens` (`App/Variorum/Shared/Theme/VoiceTokens.swift`) is the ONE colour layer both platforms
carry — four static sets, resolved by `resolve(voice:dark:)`; 67 sites consume tokens, none holds a
literal (the one-module rule held). A PALETTE is therefore a resolver extension, not a sweep:
`resolve(voice:palette:dark:)` starts from the voice's set and, for a non-default palette, REPLACES
the tinted family from one seed hue through a pure brain (`PaletteDerivation`, in `Shared/Theme`,
unit-tested: seed → room · wash · accent · takeTint · takeLine · line, light and dark; the dark
room stays `.black` per R51 and only the accent/wash/tints derive). Presets are four seeds; custom is
her hex. Study's serif and Terminal's mono, markers and lowercasing are the VOICE's and never move
(R1's "never a palette swap" was about voices being MORE than colours — a palette beneath a voice
keeps that true). Settings: `theme_palette` (enum) + `theme_tint` (6 hex digits, validated on read;
malformed reads as default) in `Queries.themeSettings` + `ThemeStore` setters; the Appearance pane
gains one row (a swatch strip + the hex field). The phone reads the same tokens through
`MobileEditorStyle.face` (`VoiceTokens.resolve`), so it inherits the palette from the synced setting
for free — the parity line names it. The mockup is `notes/plans/use-report-2026-09-12-mockups/palettes.html`.

### 4.7 Row 9 — the stamps
`container.last_touched_at` (every keystroke, COALESCE `created_at`) is "last edited";
`created_at` is "created"; both are on the row the listing already reads. `TimelineItem` carries
`createdAt` and the sort's `stamp` — add `lastTouchedAt` (additive, nil-defaulted, every caller
compiles). The List row's date slot today shows `hit.detail` — the entry date — (`LibraryCatalogView.swift:978`);
the Notes card its own date line. The note's masthead row two is `MastheadRowTwo` (chip + tags,
width-aware); the stamp joins as a third, trailing, quiet subview — or rides the tag cluster's line
end — the batch's layout call, pinned through the existing row-two arrangement pin. The stamp is a
held observation on the note row (the chrome-titles class, 17o row 18/19's lesson: never a one-shot).

### 4.8 Rows 10–11 — sort, and "edited on a day"
Sort is a face over an existing core vocabulary; title A–Z is one added `LibrarySort` case
(`ORDER BY title COLLATE NOCASE, id`) — core, additive, its own commit. The day search: with
`idx_container_touched (last_touched_at, id) WHERE deleted_at IS NULL`, "notes whose last edit fell on
day D" is `last_touched_at >= D AND last_touched_at < D+1` — one indexed seek, cost ∝ the day's notes.
The caveat, said plainly: the store keeps ONE edit stamp per note (coarse, not forensic), so a note
edited Monday then Tuesday answers only Tuesday. Since 13j a savepoint lands per changed take when she
leaves a note (`closeAutoCommit`) and the idle backstop covers the rest, so `commit_point.created_at`
carries the earlier days for anything she came back to; `UNION` the two (a `commit_point(created_at)`
partial index if the scan shows — measure first, 17c's discipline) and "edited on" answers the way she
means it, from 13j's date onward; before that, only the last-edit stamp knows. Difficulty: one query
+ one date field in the Library header — half a batch. Q-8 says now or 13o.

### 4.9 Row 7 — the phone (candidate, unconfirmed)
The Mac's row 1 is board code; nothing in `Shared/` scrolls. The phone's Write page lands its arrival
caret and keeps a typewriter room as a bottom inset (`MobileEditorViewModel.jumpToBlock`, `:838–860`,
states the contract: *"the typewriter room's bottom inset already makes any block's top a legitimate
scroll target"*), so an arrival that lands at the note's END shows the room and no text — the same
CLASS as the Mac's. Her screenshot decides which surface; the fix is the phone's own (a reveal, never
a land-at-top; the offset remembered per note for the session).

## 5. The four letters

### 5.1 — 17p · the defects (`notes/plans/phase-17-standing-fixes.md` — claimed; dispositions copied there at the close)
- **Batch a — THE TAKES BOARD (rows 1 · 2):** first act the before/after capture diff (§4.2); then
  the scroll memory + the reveal rule (§4.1, Q-1); then the empty block's face and the door's
  alignment (Q-2). Files: `TakesBoardLayout` (the memory + the reveal decision, pure and pinned),
  `TakesChoreographer` (the entry arm asks to REVEAL), `TakesBoardView` (the `ScrollView` binding; the
  door's alignment), `TakesShared` (the placeholder), `LensesBoardView` (mirrors what the shared face
  changes). Evidence: the two model pins red-on-old; a walk on the dev-store Debug build — a
  three-block note entered from Write's last block shows all three; leave scrolled, return, same
  offset; the fan-panel door still reveals its block; both voices; captures. Reviewer: `fable-reviewer`.
- **Batch b — THE CHROME SINGLES (rows 3 · 4 · 5 · 6):** the tray's block-row Delete Now (Q-3); the
  alert's field; the lane + the emoji inside the frame (Q-4). Files: `TrayPanel`, `CalloutMenu`,
  `BlockDecor`, the inline editor's inset, the callout rect. Evidence: three red-on-old pins (the
  field's width; the badge/emoji rects disjoint from the text rect; the block row's door through the
  registry walk); walked in Write and the book Outline, both voices. Reviewer: `opus-reviewer`.
- ~~**Batch c — THE PHONE (row 7)**~~ — **RETIRED at the sitting (R-Q9):** the phone's Write arrival is the mobile session's, standalone or with the post-13u catch-up; the item lives on the `mobile` branch (`mobile-round-2-orchestrator-handoff.md` §12.2) and in PL-22.

### 5.2 — 18h · time (stamps · sort · the day search)
- **Batch 1 — STAMPS + SORT (rows 9 · 10):** core first (`TimelineItem.lastTouchedAt`; the title
  sort case — one commit), then the Library's `sort ▾` menu with direction, remembered in
  `UserDefaults` (the `readModeOutlineShown` class — local UI state), the row stamps (List + Notes),
  the masthead stamp with its click-to-created toggle (Q-7). Evidence: a core pin per sort; a face
  pin that the stamp follows an autosave; walked. Reviewer: `opus-reviewer`.
- **Batch 2 — THE DAY SEARCH (row 11, at her word):** the union query (core, pinned with a note edited
  on two days), the header's date field, the empty answer worded. Reviewer: `opus-reviewer`.

### 5.3 — 18i · the confirmations setting (row 8)
ONE batch: `StatusCenter.Item.kind`, the `receipt(_:)` door, the ~20 receipt sites classified (the
table in the record), the `receipt_style` setting (core `Queries.themeSettings` + `ThemeStore` — the
appearance family; the Appearance pane's row), the bar's quiet slot. Evidence: the per-class pins;
walked with the setting cycled. Reviewer: `opus-reviewer`.

### 5.4 — 18g · colour palettes (row 12)
ONE batch after her eye on the mockup: `PaletteDerivation` (pure, in `Shared/Theme`, pinned — every
derived token's contrast against the room checked against a floor, both appearances), the resolver's
palette parameter, the two settings, the pane's swatch row + hex field, `ThemeTokenTests` extended
(default = byte-identical to today's four sets — the parity proof). Evidence: the pins; a walk in
both voices × four seeds × custom × light and dark; captures. Reviewer: `fable-reviewer`.

## 6. THE KICKOFF PROMPT (paste-ready — for a SUCCESSOR orchestrator if this session cuts over; `notes/SessionResiliencyProtocol.md`)

> `/architect-phase use-report round 2 (2026-09-12)` — you are the orchestrator of the 2026-09-12 use-report round (17p · 18g · 18h · 18i). Read, in this order: CLAUDE.md and the canon it loads; `notes/plans/use-report-round-2026-09-12.md` WHOLE (§7 her rulings are settled — never re-open them; LIVE STATUS says where the round stands; the Records carry every batch's brief, record and adjudication); `notes/author-reports/2026-09-12-use-report.md`; the previous round's `notes/plans/use-report-round-2026-09-06.md` §8 (the process this round binds by reference) and its handoff; `notes/plans/phase-17-standing-fixes.md`'s rules and the 17p row; `notes/KnownIssuesAndTechDebt.md`; `notes/SessionResiliencyProtocol.md`; the three agent definitions in `.claude/agents/`. Verify the state against git before anything (`git log --oneline -8`, `git status -sb`, `pgrep -fl 'Variorum.app/Contents/MacOS'`). Then continue from LIVE STATUS's **Next**. One agent at a time; briefs by pointer from this file; records repo-first; the ladder per letter; the round-end Fable pass; the closeout ritual; her walk before the install refresh.

## 7. Her rulings (the record — the kickoff sitting, 2026-09-12; verbatim-faithful: the option she picked is named by its label, her own words quoted where she added any; SETTLED)

- **R-Q1 — REMEMBER + REVEAL ONLY.** She picked *"Remember + reveal only"*: a per-note scroll memory for the session, restored on entry; a landing (the current block on entry, a fan-panel bloom) scrolls only when the block is off-screen, minimally, never to the top; the typewriter room stays. (Not across launches; the entry landing is not retired.)
- **R-Q2 — NO PLACEHOLDER ANYWHERE.** She picked *"No placeholder anywhere"*: an empty block in Takes is an empty line exactly as Write renders it; the ⑂+ badge still marks the row. **This SUPERSEDES Phase 13 batch 9's R103 wording** ("the kept line says what it is") — the R103 ruling's SUBSTANCE stands (a take deleted down to nothing KEEPS the block's own line — the line is not removed), its FACE (the "empty take — line kept" overlay) is retired. The ＋ new block door aligns to the text's left edge (from Q-2's shared text, unopposed).
- **R-Q3 — DELETE NOW ON THE TRAY'S BLOCK ROWS.** She picked *"Add it to block rows"*: Leaving's block rows get Delete Now with the same confirm-every-time door the Library's Trash gives a block; stranded originals stay without one (they ride their family's clock).
- **R-Q4 — A LEFT LANE; THE EMOJI INSIDE THE FRAME.** She picked *"Reserve a left lane; emoji inside the frame"*: the book Outline's inline editor reserves ~40 pt on the left whenever the note has a comment or a callout emoji; the badge sits in the lane; the emoji moves inside the callout frame's leading inset; nothing covers text; comments stay on the left.
- **R-Q5 — RECEIPTS: QUIET BY DEFAULT, TOAST STAYS AN OPTION.** Her words: *"Quiet should be the default, but toast should still be an option"* → the setting is three-way (toast · quiet · off), the default QUIET; refusals and offers always toast; the strings are untouched.
- **R-Q6 — ONE SEED HUE, BOTH VOICES, CUSTOM HEX.** She picked the recommended option: four presets (lavender · mint · pink · blue) + a custom hex; one brain derives the room, wash, accent, take tints and hairline; Terminal and Study both accept a palette; dark stays black; the setting syncs; the seeds are adjusted at her eye during the walk.
- **R-Q7 — THE MASTHEAD STAMP, CLICK TOGGLES.** She picked the recommended option: at the trailing end of the "in no book" row, *edited today 1:33 AM* (or *edited Sep 9*); a click flips it to *created …*, a click again returns; the Library rows get a muted trailing stamp too.
- **R-Q8 — THE DAY SEARCH, BUILT NOW.** She picked *"Build now, small filter in the Library"*: a date field in the Library header ("on day…"), the union query (the last-edit stamp OR a savepoint that day), half a batch beside the sort menu.
- **R-Q9 — THE PHONE: THE WRITE PAGE — AND IT LEAVES THIS ROUND.** She picked *"The Write page when a note opens"*; then, minutes later, her instruction verbatim: *"the mobile bug can be noted and I can handle it in a separate variorum mobile session - that repo has its own rules, if it's not shared. I would like you to write about it in the plans for that repo though, to be completed as a standalone part or with 13u, if I work on mobile after 13u is done."* → **17p batch c is RETIRED from this round.** The item is written into the mobile branch's plan (`notes/plans/mobile-round-2-orchestrator-handoff.md` §12.2 on `mobile`, commit pushed) with the trace, the ruled shape (reveal minimally, remember the offset per note for the session, the room stays) and the fences; the parity line is `notes/MobileSoul.md` §6 row PL-22. Owner: the mobile app project row.
- **R-Q10 — CAST AND ORDER AS PROPOSED.** Order **17p → 18h → 18i → 18g**; `opus-implementer` everywhere; `fable-reviewer` on 17p batch a and on 18g; `opus-reviewer` elsewhere; the round-end Fable pass over the Opus-reviewed letters as last round.

**No opening question remains.** A batch that finds a new one follows §8's PROVISIONAL rule (QUESTIONS #102 next).

## 8. Process (binding on every batch)
- **The previous round's §8 binds by reference** (`notes/plans/use-report-round-2026-09-06.md` §8):
  the correction round's C-1…C-7 with her U-14 amendment (the implementer walks and captures; the
  orchestrator verifies by record and capture, spot-checks where thin; she walks once at the end;
  no install refresh without that walk), the standing-17 rules, the cast's effort levels, the lean
  orchestrator, session resiliency, no commit trailer, walk tooling on the dev-store Debug build only,
  captures per batch under `notes/plans/use-report-2026-09-12-screens/<letter-batch>/`.
- **The constitution (R-0 below) binds every batch.**
- **PROVISIONAL rule:** a batch that finds a NEW product question writes it to `notes/QUESTIONS.md`
  (next free: **#102**) with 2–3 options, builds the most spec-defensible marked PROVISIONAL, and the
  round bundles it for her. It never re-opens a Q-n she has ruled.

## 9. Environment traps, baselines, coordination
- **Baselines at open (the last round's finals, 2026-09-09):** core 1503/163 · the FULL Mac suite
  2462/424 over `fd434824` · iOS build green · marker 8. **Run your own** before the first batch.
  Flake rules stand (KnownIssues: the latency pin, `CanvasDragTrackingTests`, the real-click rig).
- The 13j environment traps bind by reference; the identity oracle per keystroke in DEBUG; the
  macOS-26 widening rule; the pane component's ONE measurement brain (`PaneMeasurement`) — a batch that
  sizes a surface reads it, never `usageBoundsForTextContainer`.
- **Her app:** the real-store build is never quit by a session; walks run on `io.lduarte.Variorum.debug`;
  the install refresh follows her final walk at a zero-instance window behind the A1 backup.

## 10. Obligations at close (per letter, then the round)
Each letter: every row dispositioned (FIXED with its named pin · DISMISSED AS HOLLOW · DEFERRED with
an owner); the ladder complete or capped with its residue recorded; the suites green; the walks
captured; the canon deltas applied exactly as ruled (AppSpec §12 for the palettes and the stamps;
§7's setting seeds for the three new keys; QUESTIONS); 17p's dispositions copied into the
standing-fixes file. The round: the master plan's pointer and running order; the 17 register and the
18 row; the MOBILE PARITY LINE (the palette rides the synced setting; the phone's arrival if built);
the author handoff with her checklist at the top; the install refreshed after her walk; the closeout
paragraph; push.

## 11. Image manifest
`notes/author-reports/2026-09-12-use-report.md` — every file in `…-screens/author/` mapped to its row.

---

## LIVE STATUS

*(The orchestrator's transcript-proof state — flipped in the same commit as every piece. A fresh
session with only the repo continues the round from here.)*

- **Orchestrator:** the Fable session of 2026-09-12 (author-attended; `/architect-phase use-report
  round 2 (2026-09-12)`). Preflight DONE: CLAUDE.md + canon · the previous round's handoff, plan
  (§0–§3, §7–§11, LIVE STATUS) and her 09-06 report · the master plan · KnownIssues whole · the sizing
  guidance · the resiliency protocol · the review prompt · the standing-fixes rules and register · the
  three agent definitions · the code behind every row (§4). Her ten screenshots copied and the folder
  gitignored; her report saved verbatim. **Tree at open:** `3805e210`, clean, `main` == `origin/main`.
- **THE KICKOFF SITTING — DONE (2026-09-12):** Q-1…Q-10 all answered in one sitting (§7, R-Q1…R-Q10); the mechanical flips landed at the opening commit `0fc6347e` (the 17 register's 17p row · the Phase 18 row's 18g/18h/18i · running-order row 3d · the Current-phase pointer · the sequence line). **Baselines:** the code tree is BYTE-IDENTICAL to the last round's final full run (`fd434824`'s code = `9c00e3cd`; every commit since is `notes/`-only — verified by `git diff --stat 9c00e3cd HEAD -- Sources App`), so its finals STAND as this round's baseline: core 1503/163 · Mac FULL 2462/424 · iOS green · marker 8; the fresh core run this session: **`swift test` 1503/163 green** (2026-09-12, `scratchpad/use-report-2/core-baseline.log`).
- **In flight: 17p batch a** (`opus-implementer` on R-1, spawned 2026-09-12 after `8df4f6c0`). The orchestrator does not edit this file while the batch holds the tree; batch b's brief (R-2) is drafted in scratch and appended at batch a's close. **Next after:** the batch-a adjudication → the batch-a Fable ladder → R-2.

## Records

### R-0 · The constitution (copied verbatim from `.claude/skills/architect-phase/SKILL.md`, which preserves it byte-verbatim from `notes/plans/phase-13b-make-it-work.md`; BINDING on every batch of this round)

#### The architectural rules (the 13b constitution, P-1…P-9 — PRESERVED BYTE-VERBATIM from `notes/plans/phase-13b-make-it-work.md`; phase-specific names inside them — D3/D4, Stage 0/1, `TakesViewModel` — are the rules' provenance and worked examples, kept as written; the rules themselves are general and BINDING in every phase this skill runs)

- **P-1 — One capability registry.** Every user-facing act is declared
  exactly once: verb, scope (block/take/post/book), per-mode availability
  rule, its doors (menu / context / bar / shortcut / palette), and its
  refusal copy. Surfaces render their doors FROM the registry; gating is
  data, never per-view if-statements. A registry-walk test asserts every
  declared door exists and every rendered door is declared. This kills the
  D3/D4 class structurally — the capability matrix stays green by
  construction instead of by audit.
- **P-2 — Fire-and-DO (R115).** A rendered door either performs the act —
  including any mode-switch choreography, done visibly for the user — or
  delivers the operations layer's real refusal. A door that can never act in
  its context isn't rendered. Lecture-and-redirect is retired.
- **P-3 — One text surface, one liveness authority.** ONE TK2 surface
  component (live + read modes; one measurement brain — the width-gated
  remeasure; the shared canary) that every pane composes; the live editor
  core's identity machinery (`BlockRangeIndex`, crystallization) becomes its
  live mode, not a sibling implementation. "What text does this pane show,
  and is it live" is answered by ONE pure, unit-tested authority
  (`PaneTextAuthority`); views never re-derive it. Its invariants stated as
  code: exactly one live pane; the live pane is buffer-authoritative; read
  panes are projection-authoritative once caught up.
- **P-4 — Broadcasts carry signals, never decisions.** NotificationCenter
  may announce that something happened (mode changed, post opened); no
  listener derives business state or availability from a broadcast, and no
  flow's correctness depends on broadcast ordering. Cross-feature flows
  route through composition. (Stage 0's survey enumerates today's
  notification bus; Stage 1 disciplines it.)
- **P-5 — The friction doctrine (R116).** Repeated pushback against a rule
  marks an under-architected feature. The response is never another patch:
  write the feature's DESIGN MEMO — intended behavior whole, edge cases
  enumerated on paper, refusal wordings, undo story — get the author's
  rulings on the product-flavored edges, then build to the memo. Happy path
  ships first, but the edges are *decided at design time*, not discovered by
  the author. First two memos owed: **merge** and **the W ceremony**.
- **P-6 — The tutorial is the executable spec (R113).** The guided tutorial
  flow is the contract for every happy path. It stays green — automated
  where the harness allows, screenshot-walked otherwise — and any change
  that breaks a tutorial step is a regression by definition.
- **P-7 — Find bugs before she does.** Every layer keeps a proactive
  harness: the ops-layer soaks (exist), the board/view-model invariant soak
  (Stage 1), the registry walk (P-1), the per-batch scripted screenshot
  walkthrough. Red-on-old stays absolute: no bug-class fix without a pin
  that fails on the pre-fix code.
- **P-8 — Standing law, consolidated.** P1–P3 performance invariants bind
  the rebuilt layer exactly as they bind the substrate (invalidation ∝
  realized rows; one live editor; virtualized long views). Overlays, never
  rendering attributes. Chrome `fixedSize` texts always carry a `lineLimit`
  (the b6dae25 class). `Theme/VoiceControls.swift` is THE chrome vocabulary.
  Complexity lives in the store; restraint lives in the UI.
- **P-9 — No god objects in the frontend either.** A view model mixing
  board layout, text authority, and gesture routing splits by concern
  (`TakesViewModel` at 890 lines is the standing counterexample). Same
  hygiene rule as the substrate, applied where it was being waived.

#### Applying the constitution — precisions proven in 13b's build record (added 2026-07-22 at the author's EOL-directive review; the P-1…P-9 block above stays byte-verbatim — these bind the same way, as application notes)

- **P-1's scope is the ROUTED vocabulary, grown incrementally.** The
  registry covers acts routed through shared doors (menu bar, bottom
  bars, take-card context menus, shortcuts, the ⌘K palette);
  surface-local doors that already work are NOT retro-declared
  wholesale — the registry grows to cover them as work touches them
  (the 1b scope call, reviewer-sustained). Acts whose ONLY doors are
  inline on cards/rows declare the `.surface` door case rather than
  mis-filing under `.contextMenu` (the 3D precedent).
- **P-3 keeps TWO deliberate surface kinds.** The FULL-DOCUMENT editor
  (`EditorTextView` + `BlockRangeIndex` + crystallization/reconciler —
  the app's riskiest, best-tested identity machinery, AppSpec §15 risk
  1) is never absorbed into the pane surface; the PANE surface
  (`PaneSurface`) is the one component every pane composes. Both kinds
  consult the ONE authority (`PaneTextAuthority`) and the ONE per-post
  autosave coordinator (`AppSession.autosave(forPost:)`). Any liveness
  extension (cross-post editing, canvas cards) extends the authority's
  one-live-ring contract ON the authority — never a second liveness
  mechanism beside it.
- **Layer placement:** storage-coupled code lives feature-side, never
  in the shared `Registry/`/`Surface/` layers; the storage owner keeps
  its plumbing — cross-seam moves route bytes through a few NAMED
  internal primitives on the owner rather than exposing storage
  internals (the 3C seam). Parity refactors keep every pre-move name
  as computed forwards/typealiases so every existing pin compiles and
  passes UNMODIFIED — zero test edits is the parity proof (the 3C
  pattern).
- **The overlay/sink delivery law (the starved-host and N14 classes,
  each ended in 13b only after recurring adjacent):** every
  equality-gated sink delivers its stored state AT WIRE TIME — wiring
  is the delivery — and overlay geometry refreshes trigger on EVERY
  input axis (storage edits, width reflows, AND the first post-layout
  display pass); state computed before layout exists is garbage that
  equality gates then freeze. The closing form for any recurrence of a
  fixed class is the sweep table: instance × host/path, each cell
  FIXED-with-named-pin or provably SAFE with the mechanism stated.


### R-1 · 17p batch a — BRIEF (THE TAKES BOARD: the page opens where she left it and never lands a block at the top; an empty block is an empty line; the ＋ new block door aligns to the text) — written by the orchestrator 2026-09-12, pointers verified against `8eaeeb3d`

**Spawn:** `opus-implementer`. **Review after:** `fable-reviewer` (the landing family — the last round's batch-b ladder found a BLOCKER in this family). **One acceptance unit:** the Takes board's article (one surface — Lenses mirrors only what the SHARED cell face changes). **Rows:** ledger 1 and 2. **Her rulings (§7, SETTLED — build to them, never re-open):** R-Q1 (remember + reveal only) and R-Q2 (no placeholder anywhere; the door aligns to the text's edge).

**Read first, yourself, in this order:** `CLAUDE.md` and the canon it loads (AppSpec §4 P1–P3; §12's takes presentations; TEXTKIT2_NOTES §2 — scroll-to-location is the least reliable subsystem); this plan's §0, §1 (Q-1, Q-2), §3 rows 1–2, §4.1–§4.2, §7, §8–§9, and R-0 (the constitution); the previous round's R-6 brief + record + its three ladder rounds in `notes/plans/use-report-round-2026-09-06.md` (the landing family's whole history — `### R-6` … `### 17o batch b LADDER — ROUND 3 FINDINGS`; the BLOCKER there was a landing seed never cleared; the RAISE-M1 was a cold-mount anchor restored against the pre-fill frame — both are this batch's classes); `notes/plans/phase-17-standing-fixes.md`'s rules; `notes/SessionResiliencyProtocol.md`'s implementer half (restated below).

**Pointers (verified; re-grep before relying on a line):**
- The entry landing's over-reach: `App/Variorum/Variorum/Features/Takes/TakesChoreographer.swift:150–205` (`consumeLandings` — the bloom arm `:167–182` sets `landArticle` for the fan-panel door, RIGHT; the N9 arm `:189–204` sets it for the CURRENT block on every entry, the defect).
- The view spends it with anchor TOP: `App/Variorum/Variorum/Features/Takes/TakesBoardView.swift:616–619` (`column.scrollTo(landing, anchor: .top)` inside the article's `ScrollViewReader`, `:557`); the rows' visibility hooks `:574–575` (`rowAppeared`/`rowDisappeared` → `TakesBoardLayout.rowVisibility`, `TakesBoardLayout.swift:245–256`); the room `:606` + `:646–652` (`typewriterRoom(viewport:)` → `TypewriterRoom.height`).
- The landing's model half: `TakesBoardLayout.swift:309–317` (`articleLanding` / `landArticle(on:)` / `clearArticleLanding()`); its pins: `App/Variorum/VariorumTests/CommandRoutingTests.swift:262–311` (the batch-b landing pins — they must ride, or change with a written reason).
- Write's memory to mirror: `App/Variorum/Variorum/EditorRouter.swift:66` (`scrollAnchors: [String: Int]`, `@ObservationIgnored`, per post, session-only) and the cold-mount restore's lesson (the 17o-b ladder's RAISE-M1: restore AFTER the fill frame, parked for the settle hop).
- The placeholder to retire: `App/Variorum/Variorum/Features/Takes/TakesShared.swift:191–204` (the `.overlay(alignment: .topLeading)` over an empty resolved take — "empty take — line kept"); the R103 comment above it explains what it was; the pane's text inset `App/Variorum/Variorum/Surface/PaneSurface.swift:644` (`textContainerInset = NSSize(width: inset, height: inset)`) and the cell's `.padding(2)` (`TakesBoardView.swift:812`) — the ~16 pt the door is off by.
- The door: `TakesBoardView.swift:577–598` (`＋ new block` after the `ForEach`, padded from the CELL's edge); its empty-state twin `TakesShared.swift:76–117` (`TakesEmptyStateView` — leave its centred layout alone; only the in-article door aligns).
- Lenses: `App/Variorum/Variorum/Features/Takes/LensesBoardView.swift` renders the same `TakesCellView` — verify by grep that it inherits the placeholder's removal and needs no edit; it has no article scroll landing.

**What you build (in this order, each its own commit):**
1. **The before/after capture diff — FIRST, before any code.** `git worktree add ../variorum-before f402ccce` (the last round's baseline tree), build its Debug app there (`xcodebuild -scheme Variorum -configuration Debug build` inside that worktree — the SAME bundle id and the SAME dev store; never run the two apps at once; quit one before launching the other; `pgrep` between), open the same fixture note (three blocks: a fanned first block with two takes, a one-line second, an EMPTY third; the current block = the third — type in it in Write first) in Takes in BOTH voices, stack style, and capture; then the same on the current tree. Write the delta TABLE (what moved, by how much, which commit — `git log f402ccce..HEAD -- <file>` names the suspects) into your RECORD under "The before/after". Remove the worktree afterwards (`git worktree remove ../variorum-before`, and its DerivedData). This answers her "return to what it used to look like" with evidence.
2. **The scroll memory + the reveal rule (row 1, R-Q1):** (a) `TakesBoardLayout` gains a per-note article-position memory for the SESSION (the `scrollAnchors` class: keyed by post id, `@ObservationIgnored`, held on the session-scoped owner so it survives the board's remount — read how `TakesViewModel` is constructed per mount and where a session-scoped home is; the fan-panel's embedded model must NOT share it — `landingEnabled` is the discriminator); the representation is yours — the top-visible row's placement id plus an in-row offset is the robust SwiftUI shape (`scrollPosition(id:)`/`scrollTargetLayout`, or a preference-read offset); (b) on entry the memory is restored BEFORE any landing is considered (the RAISE-M1 lesson: after the fill frame); (c) a landing — the bloom arm AND the N9 arm — becomes a REVEAL: a pure decision in `TakesBoardLayout` (`revealDecision(landing:visibleRows:) -> .none | .reveal(placementID)`) that asks for a scroll ONLY when the slot is not among the visible rows, and the view spends a reveal with `anchor: nil` (SwiftUI's minimal scroll) — NEVER `.top`; the room stays; (d) the request is spent exactly once (the batch-b BLOCKER's class — a seed that re-lands every later mount). Pins (RED ON OLD, by behavioral revert): a three-block board whose current block is the third, mounted → the decision is `.none` when the row is visible and the article's position is the top (old: `.top` landing to the third's y); leave with the second row at the top, re-mount → the second row at the top; the fan-panel bloom on an off-screen slot → `.reveal`; the same slot on-screen → `.none`; the request spent once.
3. **The empty block's face (row 2, R-Q2):** delete the overlay (`TakesShared.swift:191–204`) — an empty block renders as the pane's own empty line, exactly as Write's; the ⑂+ badge still marks the row; write the R103 supersession as a comment where the overlay was (the substance — the line is KEPT — is untouched); check every reader of the string "empty take — line kept" (grep; the tutorial/helper too) and retire them; pin: a resolved empty take renders no placeholder text (a geometry/oracle pin of the same shape as `TakesEmptyStateDoors`).
4. **The door's alignment (row 2):** the in-article `＋ new block` door's leading edge aligns with the prose's left edge (the pane inset + the cell padding — compute from the same constants, never a magic number; a `TakesBoardLayout`/`TakesCellView` static both consult); pin: the door's x equals the first pane's text x in a mounted board (a geometry oracle; both voices).
5. **The walk (the acceptance gate — USE).** On the DEV-STORE Debug build (`io.lduarte.Variorum.debug`; `cliclick` + `Tools/WalkKit/`; NEVER `/Applications`; `pgrep -fl 'Variorum.app/Contents/MacOS'` first — her real-store app is RUNNING today (she is using it): it lives at `/Applications/Variorum.app`; discriminate by PATH and NEVER quit or kill it; test windows will flash beside it, which is fine): the fixture note; type in the last block in Write → Takes → ALL THREE blocks visible, the page at the top; scroll so block 2 is at the top, → Write → Takes → block 2 still at the top; Write's bar "Takes" on a far block in a long note → the board reveals it (row 8 of the last round still true); the empty third block shows an empty line, no words, the caret when clicked; the door's edge on the prose's edge; stack AND carousel styles; both voices. Captures into `notes/plans/use-report-2026-09-12-screens/17p-a/` (gitignored); list the files in your RECORD.

**What you do NOT do:** no change to `PaneTextAuthority`, `PaneSurface`'s liveness or measurement brain, `BlockRangeIndex`, `EditorTextView`, anything in `Sources/VariorumCore/Sync/`; no schema; nothing in the fan PANEL's embedded model's behaviour (`WriteTakesPanel`); no change to what "the current block" IS (the Act 10 row-39 rule); the typewriter room's height rule is untouched; `TakesEmptyStateView`'s layout is untouched; no product invention — a decision §7 does not make goes to `notes/QUESTIONS.md` at the next free number (**#102**; read the file's tail first) with 2–3 options, the most spec-defensible built and marked PROVISIONAL.

**The rules you work under (restated; they bind):**
1. **Checkpoint protocol:** commit per coherent piece (the capture diff · the memory + reveal · the placeholder · the door · the walk); push after every commit (`git push origin main`); write your RECORD's LIVE STATUS section at your FIRST commit and flip it in the same commit as each piece (`DONE (hash)` · `IN-PROGRESS — exactly what remains` · `NOT-STARTED`); every unverified claim marked PENDING; counts land as PENDING and flip when the run completes; **synchronous foreground waits only** — never end your turn awaiting a backgrounded build or suite (poll a log with `grep -q '<EXIT LINE>' <log> && break; sleep 5`, repeating past the Bash timeout); never spawn subagents; note every death/resume in the record; announce a behavioral revert BEFORE starting it (commit first, so `git checkout -- <file>` is the safe restore), never restore from a scratchpad copy.
2. **One surface per session** — the Takes board's article. A second unit in your way → stop, record, hand off.
3. **Pin before fix — no exceptions:** trace each row's mechanism yourself (§4.1–§4.2 are the architect's READ, not proof), write the red-on-old pin, watch it fail on the pre-fix code (a behavioral revert where a code revert is impractical), then fix, then green. A pin green on both sides → the row is DISMISSED AS HOLLOW, recorded, not fixed.
4. **The acceptance gate is USE** (piece 5). An implementer's "done" is a claim; the walk is the verification; the captures are the record.
5. **No product invention** (above). Never re-open R-Q1/R-Q2.
6. **No `Co-Authored-By` / `Claude-Session` trailer lines** on commits; never rewrite history; never `git checkout` over uncommitted work; path-scoped `git add`.
7. **Environment traps (verbatim-faithful from the last round):** instance checks via `pgrep -fl 'Variorum.app/Contents/MacOS'` discriminated by PATH; her real-store app may be running — NEVER quit/kill it; no Release builds, no `/Applications` refresh; core tests via `swift test` from the repo root; Mac app tests from `App/Variorum/` with suite-level `-only-testing:VariorumTests/<SuiteTypeName>` only (TYPE names; read the `Test run with N tests in M suites` line and the `skipped:` lines — Swift Testing COUNTS skipped tests); `xcodebuild build-for-testing` compiles without the runner; NEVER add a custom build configuration (SPM deps build RELEASE under any configuration not named exactly "Debug", stripping the DEBUG oracles); zsh `pipestatus`; scratch and screenshots in gitignored dirs inside the worktree (`scratchpad/`, the screens folder); the A1 backup rail before ANY touch of the real store (you have no reason to touch it). The identity oracle runs per keystroke in DEBUG; the pane component's ONE measurement brain is `PaneMeasurement` — never read `usageBoundsForTextContainer` yourself. The real-click rig cannot mount a WHOLE surface (KnownIssues) — pin brains, walk faces. Flake rules: the latency pin and `CanvasDragTrackingTests` red under load are known; 3/3 green isolated clears them.
8. **Close honestly:** at the END run the touched Mac suites + `CommandRoutingTests` + `TakesLandingTests`-class suites you touched + the ten `Tutorial*Tests` spine types in ONE `xcodebuild test` invocation from `App/Variorum/`; core `swift test` if you touched `Sources/` (you should not); the iOS build (`xcodebuild build -scheme VariorumMobile -destination 'generic/platform=iOS'`) if you touched `App/Variorum/Shared/` (you should not). Record the exact lines. Then write your RECORD below (the dispositions per row with the pin names and the red-on-old numbers; the before/after table; the walk table with the capture filenames; things found and deliberately not fixed; the canon note owed — AppSpec §12's takes line gains R-Q2's supersession of R103's face, drafted for the orchestrator to apply) and END with a one-paragraph report to the orchestrator: what shipped, hashes, counts, what is PENDING or open.

### R-1 · RECORD (the implementer writes here from its first commit)

**LIVE STATUS — 17p batch a (`opus-implementer`, opened 2026-09-12 at `2bfc8461`).**

**WHAT I HAVE NOT DONE (the record's first line).** *(Flipped at each piece; at the batch's close this
line states what the batch deliberately left.)* At this commit: everything but the orientation — the
five pieces are NOT-STARTED.

- **Orientation — DONE.** Read in my own context, in the brief's order: `CLAUDE.md` and the canon it
  auto-loads (CoreDescription · OverallModel · AppSpec — §4's P1–P3 and §12's takes presentations ·
  SyncSpec · TEXTKIT2_NOTES — §2 the viewport/scroll-to-location risk, §3's macOS-26 findings); this
  plan's §0, §1 (Q-1 · Q-2), §2, §3 rows 1–2, §4.1–§4.2, §7 (R-Q1 · R-Q2 — SETTLED), §8, §9, R-0
  (P-1…P-9 + the application notes), and the R-1 brief in full; the previous round's `### R-6` brief ·
  record · adjudication and its three ladder rounds (the landing family's whole history — the R1-1
  BLOCKER's never-cleared seed, R1-5's stale-generation hop, R2-1's document-end landing, RAISE-M1's
  pre-fill-frame anchor restore, R3-1's revived exemption); `notes/plans/phase-17-standing-fixes.md`'s
  philosophy + "Standing rules for every entry". Then the code: `TakesChoreographer.consumeLandings` ·
  `TakesBoardLayout` (the landing, `rowVisibility`, the card geometry) · `TakesBoardView`
  (`singleColumnArticle`, `articleRow`, `washedCell`, `typewriterRoom`, the fan strips'
  `.scrollPosition` + `stripBinding` idiom) · `TakesShared` (`TakesCellView`, the R103 overlay, the
  empty-state face and its DEBUG door oracle) · `TakesViewModel` (`adopt`, `landingEnabled`,
  `notePaneSelection`, `board`) · `PaneSurface.makeSurface`/`makeTakeSurface` (inset 6) ·
  `EditorRouter` (`scrollAnchors` — the session-scoped precedent) · `LensesBoardView` ·
  `TakesRoomTests`'s mounted-board harness (a real `NSHostingView<TakesBoardView>` with its real
  `NSScrollView` — the geometry oracle this batch's pins ride) · `CommandRoutingTests`' three landing
  pins. Tree clean at `2bfc8461`, `main` == `origin/main`. **Her real-store app IS running**
  (`pgrep` → pid 23216 at `/Applications/Variorum.app/Contents/MacOS/Variorum`) — never touched, never
  quit; every walk is on `io.lduarte.Variorum.debug`.

**Pieces (checkpoint order):**

1. the before/after capture diff (`f402ccce` vs HEAD, both voices) — **NOT-STARTED**
2. the scroll memory + the reveal rule (row 1, R-Q1) — **NOT-STARTED**
3. the empty block's face (row 2, R-Q2) — **NOT-STARTED**
4. the ＋ new block door's alignment (row 2) — **NOT-STARTED**
5. the walk + captures + the closing suites — **NOT-STARTED**

**Rows:** 1 · 2 — dispositions PENDING.
