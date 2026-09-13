# The 2026-09-12 use-report round — 17p · 18g · 18h · 18i · 18j (EXECUTION PLAN)

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
custom hex. This round takes all of it, grouped by KIND into five letters: **17p** the defects ·
**18g** colour palettes (+ the two-tone builds, R-Q11) · **18h** time (stamps, sort, the day search) ·
**18i** the confirmations setting · **18j** dark mode (13u4's item 6, pulled forward — R-Q12). The phone's opening-scroll complaint rides 17p if it shares the Mac's mechanism (Q-9).

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
  pass over the Opus-reviewed letters as last time. Order: **17p → 18h → 18i → 18g → 18j** (her two named
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
  unit (the kind on the one status seam + a setting + a bar slot). **18j (dark mode) IS phase-sized** — with 18g it makes TWO phase-sized units under ONE theme (appearance), AT the
  sizing guidance's line (said here, R-Q12); everything else is small. 18g goes after 18i and gets the Fable eye; 18j runs last.
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
| 13 | "a couple mixed color builds, like how terminal has tan and blue… like gold and black" + "light grey & green" + "a little more personality… or add a third batch" | The token layer + Settings | Two seeds through the one brain (R-Q11); the six in the mockup's second half | 18g | RULED (R-Q11) |
| 14 | "dark theme was somewhere in 13u but we can pull that forward and up and into this work" | Every surface, both voices | The Mac follows the system scheme (`RootView.swift:89`); dark tokens exist (R51) but no in-app choice and no dark walk has ever run; 13u4 item 6 → 18j | 18j | RULED (R-Q12) |

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

### 5.4 — 18g · colour palettes (rows 12 · 13 — the four pastels + the five two-tone builds + custom)
ONE batch after her eye on the mockup: `PaletteDerivation` (pure, in `Shared/Theme`, pinned — every
derived token's contrast against the room checked against a floor, both appearances), the resolver's
palette parameter, the two settings, the pane's swatch row + hex field, `ThemeTokenTests` extended
(default = byte-identical to today's four sets — the parity proof). R-Q11: the brain takes TWO seeds
(room, accent); the pastels are one-seed cases; the SIX two-tone builds (grey & green at her word) and the BOLD builds she keeps are named presets (one rule, two intensity tables). Evidence:
the pins; a walk in both voices × (default + 4 pastels + 6 duos + custom) × light and dark; captures.
Reviewer: `fable-reviewer`.

### 5.5 — 18j · dark mode (row 14 — 13u4's item 6, pulled forward at her word, R-Q12)
ONE phase-sized unit, run AFTER 18g (its dark readings ride the palettes): (1) the appearance choice —
follow system · light · dark — a LOCAL preference (device taste, the `readModeOutlineShown` class; the
voice and palette stay synced) applied at the window root (`preferredColorScheme` / the window's
appearance) so every `@Environment(\.colorScheme)` reader follows it; (2) the every-surface dark walk
in BOTH voices on the dev-store Debug build — the shell, the sidebar and its note box, the Library
(all three modes), the Shelf, the Pool/Snippets, every note mode (Write · Takes · Read · Lenses ·
Compare · Blocks · Canvas), the book modes, the ceremonies, the tray, the Trash, Settings and every
sheet — each capture verdicted RIGHT or FIXED (literal colours, system-default fills, unreadable ink,
the markdown palette, the callout swatches' dark variants, the reading page); the phone's shipped
dark mode is the look reference (13u's letter); (3) the R51 pin (fully black room in both voices)
extended to the palettes' dark families. Evidence: the sweep table (surface × voice → verdict, capture
name) is the acceptance record; the pins per fix. Reviewer: `fable-reviewer` (the round-end pass's
class — every surface).

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
- **R-Q10 — CAST AND ORDER AS PROPOSED.** Order **17p → 18h → 18i → 18g → 18j** (18j added at R-Q12); `opus-implementer` everywhere; `fable-reviewer` on 17p batch a and on 18g; `opus-reviewer` elsewhere; the round-end Fable pass over the Opus-reviewed letters as last round.

- **R-Q11 — THE PASTELS ARE IN; FIVE TWO-TONE BUILDS JOIN THEM (2026-09-12, after seeing the mockup).** Her words: *"yeah those look good, I like those. I want them included. I think I'd also like a couple mixed color builds, like how terminal has tan and blue. you can determine 5 that you think would look the coolest and most complimentary from a graphic design perspective and background, I want the app to feel good. like gold and black, for example."* → the four pastel seeds are APPROVED as mocked (adjusted at the walk at her eye); a TWO-TONE palette carries two seeds — the ROOM hue (panels, wash, take tints, hairline) and the ACCENT hue (the chrome words, chips) — through the same derivation brain; the architect's five, in the mockup's second half for her eye: **gold & black** (her example; dark-led — black room, gold words; light = ivory + deep gold) · **sage & terracotta** · **slate & amber** · **plum & cream** · **ink & coral**. 18g's scope widens by the second seed (one brain, `PaletteFamily` derived from `(roomSeed, accentSeed)`; a pastel is a two-tone whose accent seed equals its room seed at a deeper tone). The five names and seeds are hers to move at the walk. **Her clarification the same hour (verbatim):** *"i don't like this black bottom bar with the light theme. i meant multi color like rather than all purple, try out different combinations like the tan and blue, which is still a light theme. unless that dark bar is meant to be the dark theme, not a part of the light theme?"* → the black strip in the mockup was the DARK-MODE PREVIEW (18j), not part of any light theme (the mockup relabelled); a two-tone build is a LIGHT theme with two hues — the room hue and the accent hue — exactly as Terminal wears tan panels with a blue ring; its dark reading is 18j's, separate. **Then, on the relabelled mockup (verbatim):** *"i like them. i'd do a light grey one with red or something too"* → the five two-tone builds are APPROVED and a SIXTH joins — **AMENDED minutes later (verbatim):** *"hmm actually change that to light grey & green rather than light grey and red. I'd make them a little bit more memorable, the color themes don't also have to be so pastel, you can add a little more personality to them. or add a third batch"* → the sixth is **grey & green** (light grey panels, a clear green accent); and a THIRD BATCH of BOLDER builds joins the mockup for her eye — the same two-seed rule with the room tinted deeper and the accent more saturated, still light themes: **cobalt & tangerine · peach & indigo · butter & cobalt · rose & moss · teal & rust** (hers to keep, cut or rename). The brain therefore carries a per-preset INTENSITY (the pastel/two-tone level and the bold level — two L/S tables, one rule). 18g's preset list: default · 4 pastels · 6 two-tone builds · the bold builds she keeps · custom.
- **R-Q12 — DARK MODE COMES FORWARD INTO THIS ROUND (2026-09-12).** Her words: *"I think dark theme was somewhere in 13u but we can pull that forward and up and into this work as well I think it would make sense to do that."* → 13u4's item 6 (*"dark mode: R51's direction (fully black in both voices); the PHONE's shipped dark mode is the look reference; token work shared"*) MOVES here as **18j — DARK MODE**: today the Mac follows the SYSTEM appearance through `@Environment(\.colorScheme)` (`RootView.swift:89`) and the dark token sets exist (R51), but no in-app appearance choice exists and the surfaces have never been walked in dark; 18j = an appearance setting (follow system · light · dark), the every-surface dark walk in BOTH voices with the fixes it finds, and the palettes' dark readings (R-Q11) riding it. Phase-sized (an app-wide pass) — the round now holds TWO phase-sized units under ONE theme (appearance: 18g + 18j), at the sizing guidance's line; said here rather than split silently. The master plan's 13u4 row loses item 6 (recorded there).

- **R-Q13 — THE THREE BATCHES ARE IN; THE CUSTOM HEX AND "THE BRAIN" (2026-09-12, verbatim):** *"nice I like it, we'll start with that and I'll change them later if I feel like it. I can also still put in one hex and what's the "brain" that'll take care of the second value?"* → the four pastels, the six two-tone builds and the five bold builds all SHIP as 18g's presets (names and seeds hers to change later — a preset is a seed pair + an intensity, so changing one is a constants edit). **Custom = ONE hex, with an optional second.** The brain (`PaletteDerivation`, a pure function in `Shared/Theme/`) turns a seed hue into the whole tinted family by fixed lightness/saturation tables — the room very light in the hue, the wash a little deeper, the take tint and hairline between, the accent the SAME hue deep and saturated enough to read as ink on the room. With one hex it does exactly what the pastels do (accent = the seed's hue, deepened); a second hex, if she types one, replaces the accent's hue (the two-tone case). Nothing else is asked of her.
- **R-Q14 — THE OVERNIGHT RUN (2026-09-12, verbatim):** *"is everything prepared to keep running overnight? I'm going to go to sleep now but I want everything to keep running straight through - I've quit my app, so it should be refreshable."* → the round runs UNATTENDED to its close: 17p a (in flight) → its Fable ladder → 17p b → its Opus ladder → 18h (two batches) → 18i → 18g → 18j → the round-end Fable pass → the closeout → the install refresh at a zero-instance window behind the A1 backup (her app is QUIT — verified zero instances by `pgrep` at 05:4x; `caffeinate -dims` running detached). PROVISIONAL-and-continue on every non-author-only ambiguity; everything that needs her is BUNDLED into the author handoff's checklist for the morning; the standing author-only calls remain hard stops (none is expected — zero schema, zero `Sync/`, no deploy). The orchestrator drafts its successor handoff early with PENDING slots (the resiliency protocol's addendum 7) and cuts over at a clean seam if the context guideline is passed with much work left.
- **R-Q15 — ARCHITECTURE IS A REVIEW SUBJECT, NOT ONLY BUGS (2026-09-12, verbatim):** *"make sure to make use of your architecture phase training to ensure that the phase element isn't awkwardly tacked on and is well architected - the cold reviews should look to make sure there isn't a god brain or file happening as well as normal bug searches."* → the plan gains a **Review foci** section (below §11 — written at plan time, so a cold reviewer may read it without breaking isolation, per `notes/REVIEW_PROMPT.md`): per letter, the architectural shape the work must have and the god-brain/god-file smells the reviewer checks explicitly; the constitution's P-9 binds every batch; every brief carries its letter's foci.

**No opening question remains.** A batch that finds a new one follows §8's PROVISIONAL rule (QUESTIONS #102 next).

**Her morning sitting, 2026-09-13 (the question tool; recorded verbatim-faithful — the option she picked is named by its label, her own words quoted where she added any; SETTLED):**

- **R-Q16 — QUESTIONS #102 (the comment lane on every Read page): RATIFIED (a)** — *"Keep it everywhere"*: nothing covers text on any page; a note's left edge moves when it carries a comment. The PROVISIONAL arm stands as ruled.
- **R-Q17 — QUESTIONS #103 (the Notes card's one date slot): RULED — both where there is room, else the click-flip.** Her words: *"what surface is this? in the library / pool there's enough room to show both. if the area is small, the same UI i mentioned earlier of clicking on the time should switch to show you the date created or the date associated with the note"*. The surface is the Library's Notes mode (the Apple-Notes-shaped cards; capture `18h-1/08`, opened for her). Build: the card shows the stated day AND the sort's stamp where the row has room; where it is small, the masthead's click-flip grammar (edited ↔ created/the stated day). **Owed: a small build** — routed to the successor session (17q, below).
- **R-Q18 — QUESTIONS #104 (notes only while a day is armed): RATIFIED (a)** — *"Notes only"*, with the picker moved to `posts` so it never holds a value the list cannot honour (R1-3's half, already ruled in the 18h arbitration).
- **R-Q19 — J5 (the 64 pt lane): *"Keep 64 pt for now"***; her design idea RECORDED for the lane's next touch (13u2, or a 17 entry at her word): *"can the comment glyph and callout glyph not simply go under the little dots that indicate that you can move / drag the block? because if they stacked under that, it wouldn't be super wide"* — one narrow column where the drag handle (on hover, `textLeft − 22`), the badge and the glyph share the x and stack; on the read tier the handles are hidden, so the column is the decorations' alone.
- **R-Q20 — J3 (the long-note double move): *"the block I came from wins"*.** Her reasoning, verbatim: *"I'm inclined towards Only the block I came from, since switching between different modes is supposed to be seamless and keep the place you're writing in"*; confirmed after the explanation that "revealed minimally" means the page scrolls just enough that the block comes into view at the nearest page edge — no hover, no click. **Build:** when the entry landing names a block, the landing wins and the remembered place is not restored; the remembered place is used only when she comes back to the same block (or with no landing). One condition in `TakesBoardLayout`'s restore/landing step + a pin (the 60-block remount pin's sibling: remount with a landing on a far block → the landing's row at the page's edge, the remembered place ignored; remount with no landing → the remembered place). **Owed: a small build** — 17q, the successor session's first act.

**17q (for the successor's kickoff):** the two small builds above — R-Q20 (J3's condition) and R-Q17 (#103's card: both where room, click-flip where small) — one `opus-implementer` session, one Opus cold review (the Takes board half is the landing family: a `fable-reviewer` if the reviewer judges the restore/landing step touched — it is; cast Fable), on the dev-store Debug build, before 18i.

**QUESTIONS edits owed:** #102 → RATIFIED (a) 2026-09-13; #103 → RULED (her words; the build is 17q's); #104 → RATIFIED (a) 2026-09-13.

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

## 12. REVIEW FOCI (written at PLAN time, before any implementation — a cold reviewer treats each as a mandatory check; her R-Q15: architecture is a review subject, not only bugs)

**Round-wide, every ladder:** (F-0) **No god brain, no god file.** A type mixing concerns, or a file that grew past its shape to hold a new feature (P-9: `TakesViewModel` at 890 lines is the standing counterexample), is a finding at MAJOR — name the split. A new capability must be LAYERED ON the existing brain (a parameter, a subview, a pure function beside) never bolted on with special cases inside it; two copies of one rule anywhere are the drift class (MobileSoul §3). Every setting is read ONCE at its store and pushed down, never read per surface. Every new pure rule has a home in `Domain`/`Shared` and a unit pin; no literal colour, number-as-rule or string-as-rule in a view.

**17p:** (F-1) the Takes article's memory + reveal is ONE decision in `TakesBoardLayout` consumed by ONE view site; no second scroll mechanism beside the room; the landing request is spent exactly once (the batch-b BLOCKER's class). (F-2) the empty block's face is the pane's own line — nothing re-added elsewhere. (F-3) the comment lane is ONE constant + ONE decision (`inlineInset(needsLane:)`), the emoji's placement ONE rule shared by Write and the Outline; no `exclusionPaths`; no rendering attributes. (F-4) the tray's block-row Delete Now reuses the take row's confirm and purge road — no second confirm text, no second purge path.

**18h:** (F-5) the sort is a PARAMETER of the one catalog query, not a second query; the title order is a `LibrarySort` case; no stored stamp anywhere new (the no-denormalization rule); the relative-time wording is ONE pure brain (`TimeStampFace`) used by every row and the masthead; the masthead stamp is a third subview of the existing width-aware layout, not a second layout; the day search is one query arm with its plan pinned, its index (if any) its own commit.

**18i:** (F-6) the receipt/refusal/offer KIND lives on the ONE status seam (`StatusCenter.Item`), inferred at `speak` so no existing site changes; the setting is read by the centre once from the landed store; the quiet slot is ONE view every bar composes; no site-level `if setting` anywhere; the strings byte-unchanged.

**18g:** (F-7) the token layer stays ONE module: `VoiceTokens` keeps its static sets byte-identical (the parity pin), the resolver gains parameters (one resolver, no second token type, the old signature a forwarder); `PaletteDerivation` is a small pure file of its own — one rule, two intensity tables (pastel/two-tone, bold), a preset = (roomSeed, accentSeed?, intensity); no per-preset special-casing; the settings validated at the read (`Queries.themeSettings`), the setters refusing malformed values; the Appearance pane one row; `ThemeStore` gains setters only, no rules; the phone inherits by construction (verify). (F-8) contrast is pinned (accent on room ≥ 4.5:1 for every preset, both appearances) so a future seed edit cannot ship unreadable chrome.

**18j:** (F-9) the appearance choice is applied at ONE root (the window/scene), every `@Environment(\.colorScheme)` reader following it — no per-surface override; every dark fix is a TOKEN fix (a missing slot, a wrong slot, a literal removed), never an `if dark` branch in a view; the sweep table is complete (every surface × both voices) and each verdict names its capture; R51 (fully black room) pinned for every preset's dark family.

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
- **THE ORCHESTRATOR HANDOFF** (her ask at ~06:00, before sleeping — for a compaction of this session or a successor): `notes/plans/use-report-round-2026-09-12-orchestrator-handoff.md` (§0 paste-ready; §3 the install-refresh recipe; §4 the close's obligations). **The remaining briefs are COMMITTED** at `notes/plans/use-report-2026-09-12-briefs/R-2.md … R-7.md` (R-3 carries a correction to §4.7/§4.8: the Library surface is `LibraryCatalogModel` over `Queries.searchCatalog`, not `observeLibrary`); append each verbatim at the previous batch's close. **The palette mockup** she approved (three preset batches; the dark strips are 18j's previews) is committed at `notes/plans/use-report-2026-09-12-mockups/palettes.html` — the reference for 18g's seeds.
- **17p CLOSED as a letter (2026-09-12).** **18h CLOSED as a letter (2026-09-13)** — rows 9–11 FIXED; the Opus ladder ran to the cap (round 1: 1 BLOCKER · 3 MAJOR · 7 MINOR · 5 NIT; round 2: 1 MAJOR · 5 MINOR · 6 NIT; round 3: 3 MINOR · 7 NIT — everything fixed or recorded with an owner); the last code tree `634a57c4` (core 1545/167; iOS green; v1_17 `idx_commit_created`, marker 8); the LETTER CLOSEOUT is the last section of this file; canon deltas applied (AppSpec §7's index, §12's Library line; PL-22 corrected; KnownIssues' `ANALYZE` row + the 13u2 and 17q rows). **Her 2026-09-13 sitting recorded (R-Q16…R-Q20).** **THIS SESSION STOPS HERE at her word** ("it would be best to do that in a new session"): the ORCHESTRATOR HANDOFF is rewritten for the SUCCESSOR (`notes/plans/use-report-round-2026-09-12-orchestrator-handoff.md` §0 is the paste-ready kickoff). **Next, in the new session:** 17q (R-Q20's landing-wins condition + R-Q17's card + R3-1's one line + the #103 row wording) → 18i (R-5, in this file) → 18g (R-6) → 18j (R-7) → the round-end Fable pass over 18h + 18i → the closeout → the author handoff → the install refresh at a window she grants.

- **THE SUCCESSOR ORCHESTRATOR (2026-09-12, Fable, fresh context — spawned from the handoff's §0 at her word; `/architect-phase use-report round 2 (2026-09-12) — the SECOND SESSION`).** State verified against git before anything: `main` == `origin/main` at `53fb20c9`, tree clean, the CODE byte-identical to 18h's last tree `634a57c4` (`git diff --stat 634a57c4 HEAD -- Sources App` empty), zero `/Applications` instances by `pgrep`, `caffeinate -dims` still running from the first session. Preflight DONE in the kickoff's order: the handoff whole · this plan's §1–§3, §5, §7 (R-Q1…R-Q20), §8–§9, §12, LIVE STATUS, R-0, the R-1 brief, the 17p and 18h LETTER CLOSEOUTs, the 18h ladder's round 3 with its dispositions, the R-5/R-6/R-7 briefs in the briefs folder · her report · CLAUDE.md + canon · the standing-fixes rules and register · the resiliency protocol whole · KnownIssues whole · the review prompt · the three agent definitions · QUESTIONS #102–#104 (the three ratify/ruled lines ARE landed) · the code behind R-Q20 and R-Q17 (`TakesBoardLayout`'s restore/landing step, `TakesChoreographer.consumeLandings`, the board view's two hooks, the remount and reveal pins; `LibraryCatalogView.noteCard`/`CatalogNoteLine`, `LibraryTimeFace`, `MastheadStamp`, `TimeStampFace`, `LibraryCatalogModel.modeChanged`). **One correction to the handoff's §2:** the R-5 brief is NOT in this file (no `### R-5` header exists) — it is `notes/plans/use-report-2026-09-12-briefs/R-5.md`; it is appended verbatim at 17q's close like R-6/R-7. **Baseline adopted:** 18h's finals over `634a57c4` (core 1545/167 · Mac 217/37 + 206/34 · iOS green) — the code has not moved. **17q OPENED (this commit):** the R-8 brief appended below (the R-1 shape — pointers re-grepped against `634a57c4`, rules 1–8 restated, the walk named; scope: R-Q20's landing-wins condition · R-Q17's card + R3-2's row slot · R3-1's synchronous clear · the R3-4…R3-10 sweep — the KnownIssues row it resolves named), the 17q register row claimed in `phase-17-standing-fixes.md`. **Next:** spawn ONE `opus-implementer` on R-8 by pointer; on its report verify against git, write the ADJUDICATION (J14 onward), the `fable-reviewer` ladder (the landing family), 17q's close → 18i (R-5 appended) → 18g (R-6) → 18j (R-7) → the round-end Fable pass over 18h + 18i → the closeout → the author handoff → the install refresh at a window she grants.

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

**WHAT I HAVE NOT DONE (the record's first line).** **ONE PIN IS RED AT THE CLOSE and I stopped rather
than iterate on it** (the orchestrator's instruction at my context limit):
`TakesArticleScrollTests.aLongNoteEnteredOnAFarBlockRevealsItWithoutHaulingItToTheTop` — the guard that
the reveal still reveals — was green 3+ runs (logs `g16` · `g18` · `g19` · `nb2` · `nb3`, including two
15-suite runs) and is now reproducibly RED standalone, 3/3, on the BYTE-IDENTICAL committed code
(`git checkout --` of the test file to `a1f88379` reproduces it). The trace is below under **THE RED
PIN**; the behaviour it guards is green in USE (walk capture `07`, and the two red-on-old pins for the
rows themselves are green). Everything else in the batch is done. Also deliberately NOT done, by the
brief: nothing in `Sources/` (core — zero lines), `Sync/`, schema, `App/Variorum/Shared/`,
`PaneTextAuthority`, `PaneSurface`'s liveness or measurement brain, `BlockRangeIndex`,
`EditorTextView`, `TakesChoreographer`'s landing arms, `TakesEmptyStateView`'s layout, the typewriter
room's height rule, and the fan panel's embedded model. No QUESTIONS entry was needed (#102 is still
free): every decision here is R-Q1's or R-Q2's letter, and the one consequence of her ruling worth her
eye is recorded as an observation, not a new question.

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

1. the before/after capture diff (`f402ccce` vs HEAD, both voices) — **DONE (this commit)**
2. the scroll memory + the reveal rule (row 1, R-Q1) — **DONE (this commit)**
3. the empty block's face (row 2, R-Q2) — **DONE (this commit)**
4. the ＋ new block door's alignment (row 2) — **DONE (this commit)**
5. the walk + captures + the closing suites — **DONE (this commit)** — the walk is captured and green in USE; the closing run is **RED on ONE pin**, traced and recorded below, with everything else green

**Rows:** 1 · 2 — dispositions PENDING.

---

#### PIECE 1 — THE BEFORE/AFTER (the batch's first act; `f402ccce` vs `2bfc8461`, the SAME dev store)

**How.** `git worktree add ../variorum-before f402ccce` → `xcodebuild -scheme Variorum -configuration
Debug -derivedDataPath …/DD build` there (the SAME bundle id `io.lduarte.Variorum.debug`, the SAME dev
store) and the ordinary Debug build at HEAD; **never both running at once** (`pgrep` between every
launch; her `/Applications` build was running throughout at pid 23216 and was never touched). The
fixture was built by hand in the app at HEAD and then opened, unchanged, on the before binary: a new
note, **three blocks** — "Paragraph one." (given a second take through Block ▸ New Take (Branch), so
it carries ⑂2), "Paragraph two is a single line.", and an **EMPTY third** made by 18c's Return — with
the caret left in the third, so `block 3/3` is the note's CURRENT block. Style **stack**, wash on,
indicator **Outline ring**, both voices. The worktree and its DerivedData are removed; `git worktree
list` is clean.

**THE HEADLINE: the page's position, and nothing else, is what changed.**

| What | BEFORE (`f402ccce`) | AFTER (HEAD, `2bfc8461`) | Moved by |
|---|---|---|---|
| **The article's scroll on entering Takes** | **at the TOP** — "Paragraph one." (⑂2), "Paragraph two is a single line." and the empty third block all on screen, in both voices (`03`, `04`) | **scrolled to the CURRENT block's top** — blocks 1 and 2 are ABOVE the fold; the page shows the empty third block, its ⑂+ badge and the ＋ new block door and nothing else, in both voices (`01`, `02`) | `68632d31` (17o batch b piece 4, row 8): the N9 entry arm calls `landArticle(on:)` for the note's current block and the view spends it `anchor: .top`. **Her image 1 reproduced exactly.** |
| The empty block's placeholder | *"empty take — line kept"* present, at the pane's top-leading | **identical** — same string, same place | **NOTHING.** The R103 overlay is unchanged since 13 batch 9; what changed around it is that empty blocks became EVERYDAY (18c's Return mints one at every paragraph break, and 17o's ＋ new block door mints one on demand), so a face built for "a take deleted down to nothing" now greets a block she just made. |
| The ＋ new block door's alignment | dashed frame's leading edge flush with the PANE's frame, ~11 pt left of the prose | **identical** | **NOTHING** — the door has been padded from the cell's edge since 13b 1b. It reads as misalignment now because the empty third block is often the only thing on the page (row 1), which puts the door directly under an empty pane with nothing else to line up against. |
| The live pane's ring | Outline ring drawn (indicator = Outline ring) | identical | — (17o batch c's U-7 fix made the ring follow the preference; under indicator OFF there is NO ring, which is the state her image 1 was captured in and why the caret reads as sitting *in* the words) |
| Everything else on the board (chrome row, badges, bottom bar, both voices) | — | no visible delta | — |

**What this answers.** Her *"the take page looks like an absolute mess now"* and *"keeps trying to jump
to the bottom"* are **ONE regression with ONE cause** — `68632d31`'s entry landing — and *"I want it to
return to what it used to look like"* is satisfied for row 1 by restoring the page's position. The
empty block's face and the door's alignment are **NOT regressions**: they are old faces newly made
prominent, and R-Q2 rules them both. Nothing else on the board moved between the two trees.

**Captures:** `notes/plans/use-report-2026-09-12-screens/17p-a/01-after-takes-study-stack.png` ·
`02-after-takes-terminal-stack.png` · `03-before-takes-terminal-stack.png` ·
`04-before-takes-study-stack.png` (gitignored).

#### PIECE 2 — THE SCROLL MEMORY AND THE REVEAL RULE (row 1, her ruling R-Q1)

**RED ON OLD, measured before a line moved** (`TakesArticleScrollTests`, the mounted board + its REAL
`NSScrollView`, run on the pre-fix tree — `/tmp/red1.log`, local):

- `aThreeBlockNoteEnteredOnItsLastBlockOpensAtTheTop` — **`offset(article) → 86.0` where 0 is owed.**
  Her three-block note, entered on its last block, opened 86 pt down: blocks 1 and 2 off the screen.
  Her image 1, in a pin.
- `aBoardLeftScrolledComesBackWhereSheLeftIt` — **`abs(offset - 120) → 120.0`**, i.e. the re-mount came
  back at **0**: there was no scroll memory at all.

**What the pin measures and why it is mounted.** "Where does the page open" is only answerable by a
laid-out scroll view, so the suite hosts the whole `TakesBoardView` in a real window (the
`TakesRoomTests` pattern) and reads `scrollView.contentView.bounds` — the clip view's BOUNDS, whose
origin IS the scroll offset, so "on screen" is measured against that rect. The remount pin mounts a
SECOND board with a FRESH `TakesViewModel`, exactly as a mode round trip does.

**What shipped.**

1. **The memory is the SESSION's** — `EditorRouter.takesArticleOffsets[postID]`, an
   `@ObservationIgnored` per-note pixel offset beside Write's `scrollAnchors`, session-only and never
   persisted (R-Q1's "not across launches"). It has to live there and nowhere else: `TakesBoardView`'s
   model is per-mount `@State`, so `TakesViewModel` — and with it `TakesBoardLayout` — dies at every
   mode switch. Gated on `landingEnabled`, so the Write panel's embedded model never shares it.
2. **The restore is ONE-SHOT and decided at the first honest geometry.** `.scrollPosition($articleScroll)`
   + `.onScrollGeometryChange` give the article an offset it can read and set; a small state machine
   (`.undecided → .wanted(y) → .settled`) reads the memory at the FIRST geometry event — **not in
   `onAppear`**, whose ordering against that event is not ours to assume (measured: the geometry hook
   fires first, and a mount that records its own 0 before reading the memory erases the thing it came
   back for). `.wanted` holds while the lazy column's content is still growing and re-aims as it does
   — the 17o batch-b ladder's RAISE-M1 lesson (never restore against a pre-fill frame) in the board's
   vocabulary. Her hand outranks it: `articleScroll.isPositionedByUser` ends the restore on the spot.
   Nothing is written to the memory until `.settled`.
3. **A landing REVEALS.** `TakesBoardLayout.revealDecision(rowFrame:viewportHeight:)` is a pure rule —
   fully inside the viewport ⇒ `.none`; clipped, scrolled away, **or not realized at all** ⇒ `.reveal`
   (an unrealized row is proof it is off screen). The frames come from each article row's
   `onGeometryChange(for: CGRect) { $0.frame(in: .scrollView) }` (measured and confirmed: `.scrollView`
   IS the visible-region space — a row above the fold reports a negative `minY`), stored
   `@ObservationIgnored` and equality-gated, so a scroll re-renders nothing. The view spends a reveal
   with **`anchor: nil`** — SwiftUI's minimal scroll — never `.top`, and only after the restore has
   settled, and exactly once (`clearArticleLanding`, the batch-b BLOCKER's class).
4. **`TakesChoreographer` is untouched.** The N9 entry arm and the bloom arm still call
   `landArticle(on:)` exactly as they did — the three `TakesLandingTests` model pins ride UNMODIFIED.
   What changed is only how the article spends the request. Her R-Q1 keeps the entry landing; it is
   now a reveal.

**GREEN, and the guard against over-correcting.** Five pins in `TakesArticleScrollTests`: the two
red-on-old ones above; `aLongNoteEnteredOnAFarBlockRevealsItWithoutHaulingItToTheTop` (twelve blocks,
entered on the last: the board DOES go there — row 8 of the last round survives — but the block lands
at the FOOT of the viewport with everything above it on screen, `minY` 561 pt down a 619 pt page,
which is red on the old anchor's `minY ≈ 0`); and two pure/model pins for the decision and for
"spent exactly once". **`✔ Test run with 5 tests in 1 suite passed`**; the takes neighbourhood green in
one run — `✔ Test run with 64 tests in 9 suites passed` (`TakesArticleScrollTests` ·
`TakesRoomTests` · `TakesBoardTests` · `TakesArticleRenderTests` · `TakesBoardSoakTests` ·
`TakesCardHeightTests` · `TakesRailPagingTests` · `TakesEmptyStateTests` · `TakePaneMeasureTests`) plus
`✔ 10 tests in 2 suites` for `TakesLandingTests` · `CommandRouterTests`.

**One thing built, measured, and then REMOVED — recorded because the measurement is the finding.** The
first cut carried a bounded re-aim loop (the `JumpCorrectionLoop` doctrine: a lazy column scrolls to
its ESTIMATE of an unrealized row and the rows then realize taller). A DEBUG trace through a real
mount showed it never fired usefully — the budget burned inside one layout pass, and the reveal landed
correctly WITHOUT it because SwiftUI re-resolves `scrollTo(id:)` across the column's height growth on
this SDK. Unexercised machinery on the app's riskiest surface is worse than none, so it is gone; the
trace is the evidence, and a future point release that changes this behaviour is a TEXTKIT2 §5-class
re-measure, not a regression to rediscover.

**A consequence of her ruling, recorded rather than papered over** (not a deviation — R-Q1 says both
halves): on a LONG note whose current block is far from where she left the page, the restore puts her
back where she was and the entry landing then reveals the current block, so the page can move once
after the restore. On short notes — the case she reported — nothing moves at all. Her ruling keeps the
entry landing deliberately ("the entry landing is not retired"), so this is built exactly as ruled.

#### PIECES 3 + 4 — THE EMPTY BLOCK'S FACE AND THE DOOR'S EDGE (row 2, her ruling R-Q2)

**The oracle problem, and how it was answered.** Both halves of row 2 are claims about what a REAL
mount draws, and neither is reachable the usual way: a SwiftUI `Text` or `Button` is drawn, never
mounted as an `NSView` (KnownIssues' rig row). The accessibility tree was tried first and **is not an
option here — measured**: a hosted `TakesBoardView` reports exactly ONE accessibility element (the
hosting view, role `AXGroup`) with no children at all. So both pins ride DEBUG render oracles the views
themselves feed — the `TakesEmptyStateDoors` / `LensesGeometry` pattern this codebase already uses for
exactly this: **`TakesCellChrome`** (variantID → the chrome words that cell draws over its pane) and
**`TakesArticleDoorProbe`** (the ＋ new block door's own frame, in window space). One trap recorded: the
door's probe must sit INSIDE the new leading padding — outside it, it reads the padding's frame and
reports the old place.

**RED ON OLD, measured before either fix** (`TakesEmptyBlockFaceTests`, the oracles wired to the
SHIPPED code — `/tmp/red4.log`, local):

- `anEmptyBlockShowsNoPlaceholderWords` — the empty block's cell reported
  **`["empty take — line kept"]`** where `[]` is owed.
- `theNewBlockDoorsEdgeSitsOnTheProsesEdge` — **`door.minX 210.0 · prose 218.0 · off by 8.0`** — the
  door's dashed rect stood 8 pt left of the first character of the prose above it. Exactly the cell's
  `.padding(2)` plus the take pane's `textContainerInset` of 6; her image 2's daylight, in numbers.

**What shipped.**

- **The R103 overlay is GONE** (`TakesShared.swift`). An empty block in Takes renders as the pane's own
  empty line, exactly as Write renders it. The supersession is written where the overlay was: **only
  the FACE retires — R103's substance stands** (the block keeps its own line, its own pane and its ⑂+
  badge), and it is still pinned where it always was (`PaneTextAuthorityTests`,
  `TakesBoardSoakTests`), plus a new `theEmptyBlockStillHasItsOwnRow` here. The string had exactly one
  production reader (grepped); no tutorial or helper names it. `LensesBoardView` composes the same
  `TakesCellView`, so the Lenses columns inherit the change with no edit — verified by grep, and its
  suites ride green.
- **The door aligns to the prose.** `PaneTextView.takeSurfaceInset` (6) and
  `TakesBoardView.articleCellPadding` (2) are now NAMED where they were literals, and
  `TakesBoardView.articleTextLeadingInset` is their sum — the one number the article's `＋ new block`
  door pads by and the same one the cell's own padding uses, so the door cannot drift from the text it
  stands under. `TakesEmptyStateView`'s centred empty-NOTE layout is untouched, as the brief requires.

**GREEN:** `✔ Test run with 8 tests in 2 suites passed` (`TakesEmptyBlockFaceTests` ·
`TakesArticleScrollTests`), and the takes neighbourhood in one run — **`✔ Test run with 103 tests in 15
suites passed`** (adding `TakesLandingTests` · `PaneSurfaceTests` · `PaneTextAuthorityTests` ·
`LensesReorderTests` · `TakesPresentationTests` to piece 2's set).

**A refactor made mid-piece, and why (it is in the diff, so it is recorded here).** The restore's state
machine started as view `@State` written from inside the scroll-geometry action. Two facts moved it
onto `TakesBoardLayout`: a `@State` written and re-read inside ONE update transaction is not a promise
SwiftUI makes (measured earlier in this batch — a view-held reveal target never re-armed), and P-9 puts
rules in the model anyway. `TakesBoardLayout.consumeArticleGeometry(_:remembered:positionedByUser:)`
now answers `.scroll(y) | .remember(y) | .wait` and the view only performs it. **Checked, not assumed:**
the SwiftUI "Modifying state during view update" warning this surface already emitted is PRE-EXISTING
board chrome noise and the rate went DOWN, not up — 30 warnings over 3 mounts on the pre-fix tree
(10/mount), 55 over 7 mounts after (7.9/mount).

**Two environment notes, recorded so they are not met twice.** (1) WalkKit's `walk-cap` writes
`w<n>.png` where `n` is the window's index in ITS OWN listing and does **not** clear the directory — a
stale `w1.png` from an earlier run read as the current frame and cost three wrong conclusions. Always
capture into a FRESH directory. (2) The recorded first-launch pitfall is live: the first launch of the
HEAD build took every click and keystroke and showed nothing; quitting MY instance and relaunching
cleared it (her `/Applications` instance was never involved).

#### PIECE 5 — THE WALK (the acceptance gate: USE, on the DEV-STORE Debug build)

`io.lduarte.Variorum.debug` (`…/DerivedData/Variorum-dnpxwqhpxdqrdjbunktnzoahckpd/Build/Products/Debug/
Variorum.app`, bundle id verified), `cliclick` + `Tools/WalkKit`. **Her real-store app was RUNNING for
the first half of this batch** (pid 23216 at `/Applications/Variorum.app`) — discriminated by PATH at
every `pgrep`, never quit, never touched; she closed it herself part-way through. No Release build, no
`/Applications` refresh. The fixture is the note built by hand in piece 1 (three blocks: a fanned first
with two takes · a one-line second · an EMPTY third; the caret left in the third, so `block 3/3` is the
note's current block) plus **A Scandal in Bohemia, 262 blocks**, for the long-note rows.

| Row | The walk | What happened | Capture |
|---|---|---|---|
| **1** | the three-block fixture, current block = the third → Library → the note opens in Takes | **all three blocks on screen, the page at the TOP** — "Paragraph one." (⑂2), "Paragraph two is a single line.", the empty third, the ＋ new block door. Her image 1's page, answered | `05` |
| **1** (the reveal still reveals) | the 262-block note → ⌘2, entering on its current block (21/262) | the board **went** there and revealed it at the **FOOT** of the page, with six earlier blocks fully visible above it — never hauled to the top. Row 8 of the last round survives R-Q1 | `07` |
| **1** (the memory) | from there: ⌘1 (Write) → ⌘2 (Takes) | **the page came back PIXEL-IDENTICAL** — `08` and `09` are the same frame, block 21/262, same six blocks above. On a 262-block note | `08` · `09` |
| **2** (the face) | the empty third block, in every capture above | **an empty line and the caret, no words.** The ⑂+ badge still marks the row (R103's substance) | `05` · `10` · `11` |
| **2** (the door) | the ＋ new block door under the empty pane | its dashed frame's leading edge now sits **on the prose's left edge** (same x as "Paragraph one.", within ~1 pt); before, it stood 8 pt left | `05` · `10` · `11` |
| **both** | style **stack** and style **carousel** | identical on both | `05` (stack) · `10` (carousel) |
| **both** | voice **Study** and voice **Terminal** | identical in both | `05`/`10` (Study) · `11` (Terminal) |

**Captures** (in `notes/plans/use-report-2026-09-12-screens/17p-a/`, gitignored):
`01-after-takes-study-stack.png` · `02-after-takes-terminal-stack.png` ·
`03-before-takes-terminal-stack.png` · `04-before-takes-study-stack.png` (piece 1's before/after) ·
`05-walk-takes-study-stack-all-three.png` · `06-walk-left-scrolled.png` ·
`07-walk-reveal-at-the-foot-not-the-top.png` · `08-walk-long-note-left-here.png` ·
`09-walk-long-note-came-back-here.png` · `10-walk-carousel-style.png` ·
`11-walk-terminal-voice.png`.

**A walk note for the record:** the three stray empty `2026-09-12` notes in the dev store are mine —
the first launch's swallowed ⌘N presses minted them before the app started responding (the recorded
first-launch pitfall). Dev store only; harmless; not tidied so the ladder sees the same store I did.

#### THE RED PIN — what I know, measured, and where I stopped

**The pin:** `TakesArticleScrollTests.aLongNoteEnteredOnAFarBlockRevealsItWithoutHaulingItToTheTop`.
It is the **guard** that the reveal still reveals (row 8's door surviving R-Q1) — not one of the two
red-on-old pins for rows 1 and 2, both of which are green.

**What it asserts:** a twelve-block board entered on its last block moves (offset > 0) and lands that
block at the FOOT of the viewport, with everything above it on screen.

**The history, from the logs:** green in `/tmp/g16.log`, `/tmp/g18.log`, `/tmp/g19.log` (8/2), and in
two fifteen-suite runs `/tmp/nb2.log` and `/tmp/nb3.log` (**103 tests in 15 suites passed**). It then
failed once inside the 38-suite closing run, and now fails **3/3 standalone** — on the
byte-identical committed test file (`git checkout --` back to `a1f88379` reproduces it exactly), and
also 3/3 with a longer occasion-based settle. So it is not the settle budget and not my last edit.

**The failure's shape, twice measured:** `offset(article) → 0.0` (the board never moved at all) AND the
last block's article pane is not found by its `pane:article|<variantID>` identifier. Both together say
the composition under test is not the one the pin was written against.

**The prime suspect, and it is a RECORDED class:** the Mac suites run in the DEV-STORE APP's own
`UserDefaults.standard` (the test host IS `io.lduarte.Variorum.debug`), and `.incrementing` UUIDs mint
the SAME post id in every world — the 17o batch-b ladder's **R1-7**, owned by Phase 12 in KnownIssues.
The board reads three things from there per post (`TakesViewMemory`'s columns, the layout's slot
heights, and `@AppStorage` density), and between the green runs and the red ones **I ran the walk**,
which wrote real board memories into that same domain. `Queries.takesProjection`'s `fanStyle` is NOT
implicated (it comes from the in-memory store's `setting` table, default `.stack`, fresh per test) —
so the suspect is a per-post `UserDefaults` value, not the style setting.

**Where I stopped, and why:** at the orchestrator's instruction (my context past the degradation line)
I did not start another stabilization attempt. **The one-line check for whoever picks this up:** give
the harness its own `UserDefaults` (`TakesViewModel(session:postID:defaults:)` already takes one, and
`TakesBoardLayout` threads it) and see whether the pin goes green — that is R1-7's own proposed
injection, and if it does, this pin is the evidence that row's owner was waiting for.

#### CLOSING RUNS (this tree)

- **Mac, ONE `xcodebuild test` from `App/Variorum/`** over the thirty-eight type names this batch
  touched or leans on — the takes/pane family (`TakesArticleScrollTests` · `TakesEmptyBlockFaceTests` ·
  `TakesRoomTests` · `TakesBoardTests` · `TakesArticleRenderTests` · `TakesBoardSoakTests` ·
  `TakesCardHeightTests` · `TakesRailPagingTests` · `TakesEmptyStateTests` · `TakePaneMeasureTests` ·
  `TakePaneDurabilityTests` · `TakesSlotDragTests` · `TakesBufferConvergenceTests` ·
  `TakesDivideTests` · `FannedDefaultsBoardTests` · `WriteTakesPanelTests` · `TakesWordCountTests` ·
  `TakesPresentationTests` · `LensesReorderTests` · `PaneSurfaceTests` · `PaneTextAuthorityTests` ·
  `PanePublishDoorTests`), the landing/router family (`TakesLandingTests` · `CommandRouterTests` ·
  `StatusCenterTests` · `MoveAndExecuteTests` · `LandingOffsetTests` ·
  `CurrentBlockContinuityTests`) and the ten `Tutorial*` spine types →
  **`✘ Test run with 251 tests in 38 suites failed after 111.418 seconds with 2 issues`** — the two
  issues are the ONE red pin above, nothing else; thirty-eight suites for thirty-eight names, and the
  log's single `skipped` match is the `appintentsmetadataprocessor` build warning, checked by line
  (`/tmp/closing.log`, local).
- **The same set minus the Tutorial spine, twice, before the walk: `✔ Test run with 103 tests in 15
  suites passed`** (`/tmp/nb2.log`, `/tmp/nb3.log`) — the state the ladder should compare against.
- **Core: UNTOUCHED** — `git diff --stat 2bfc8461..HEAD -- Sources/` is empty. Zero `Sync/`, zero
  schema. `swift test` therefore not re-run; the round's baseline (1503/163) stands.
- **`App/Variorum/Shared/`: UNTOUCHED** (empty diff), so the iOS build is not owed and was not run.

#### THE ROWS, DISPOSITIONED

| # | Her words (short) | Disposition |
|---|---|---|
| **1** | *"the page keeps trying to jump to the bottom and not show the text above… it should remember your scroll position"* | **FIXED** — pins: `TakesArticleScrollTests.aThreeBlockNoteEnteredOnItsLastBlockOpensAtTheTop` (red-on-old **86.0 where 0 is owed**) · `…aBoardLeftScrolledComesBackWhereSheLeftIt` (red-on-old **the remount came back at 0 where 120 was left**; now stated in block terms on a 60-block lazy note) · `…theRevealDecisionOnlyMovesForARowThatIsNotFullyOnScreen` · `…theBoardRevealsAnOffScreenSlotLeavesAVisibleOneAloneAndSpendsItOnce`. Walked: captures `05` · `07` · `08` · `09`. The reveal's guard pin is the RED one above |
| **2** | *"the take page looks like an absolute mess now… the invitation to write a block is weird… The empty take — line kept instruction is not good"* | **FIXED** — pins: `TakesEmptyBlockFaceTests.anEmptyBlockShowsNoPlaceholderWords` (red-on-old **`["empty take — line kept"]` where `[]` is owed**) · `…theEmptyBlockStillHasItsOwnRow` (R103's surviving substance) · `…theNewBlockDoorsEdgeSitsOnTheProsesEdge` (red-on-old **door 210.0 vs prose 218.0, off by 8.0**). Walked: `05` · `10` · `11`, both voices, both styles |

**Nothing DISMISSED AS HOLLOW; nothing DEFERRED.** Piece 1's before/after is the evidence that her
*"return to what it used to look like"* had ONE cause for row 1 and none for row 2 — the face and the
door were unchanged since `f402ccce` and are ruled changes, not regressions.

#### WHAT THE LETTER'S CLOSEOUT INHERITS

- **CANON NOTE OWED (drafted for the orchestrator to apply at 17p's close).** **AppSpec §12**, the
  takes-presentations line: after *"the changing-block wash behind a default-on toggle (R13)"*, R103's
  face retires — suggested wording: *"…and an empty block in Takes is an empty LINE (17p batch a, her
  R-Q2 — this supersedes the FACE of Phase 13 batch 9's R103, whose substance stands: the kept line,
  its pane and its ⑂+ badge)."* **`notes/plans/phase-13-ui-design.md`'s R103** (line ~1662) should gain
  a dated sentence that its "the kept line says what it is" half was superseded on 2026-09-12. Nothing
  else in canon moves: the article's scroll memory is a LOCAL session value in `scrollAnchors`' class,
  never synced, never schema.
- **No new QUESTIONS entry** (#102 still free).
- **ONE observation for the J-list, hers if she wants it.** R-Q1 keeps BOTH halves — restore, then
  reveal-if-off-screen — so on a LONG note whose current block is far from where she left the page,
  the restore puts her back and the entry landing then reveals the current block, moving the page once
  more. On the notes she reported (two or three blocks) nothing moves at all. Built exactly as ruled;
  if she wants the restore to suppress the entry landing, it is one condition.
- **Mobile parity:** nothing in `Shared/` moved, so the phone inherits nothing by construction. Its
  own version of R-Q1 is already the mobile session's (R-Q9, PL-22); this batch's shape — remember the
  BLOCK at the top of the page, never a pixel offset, and reveal minimally — is the design note that
  session should read first, and the two measurements on `TakesBoardLayout.ArticlePlace` are why.
- **13u coordination:** this batch touched no 13u item's code. It hands 13u2's restyle continuation
  three additive seams on a surface it will re-dress: `TakesBoardLayout.revealDecision` /
  `ArticlePlace`, `TakesBoardView.articleTextLeadingInset`, and two DEBUG render oracles
  (`TakesCellChrome`, `TakesArticleDoorProbe`) — the in-process way to pin a hosted SwiftUI face now
  that the accessibility road is measured shut.

**Batch a CLOSED at this commit.** Everything is committed and pushed; no revert is in flight; the tree
is clean. The ONE red pin is named, traced and handed to the ladder.

**R-1 · ORCHESTRATOR'S VERIFICATION + ADJUDICATION (2026-09-12, the overnight run — she is asleep; these J-calls are hers to read in the morning):** verified against git (six commits `ee1f1f5a` · `991cfd10` · `664b7ad0` · `33fa46d5` · `a1f88379` · `066e2588`; `Sources/`, `App/Variorum/Shared/` and `Sync/` diff-empty against `2bfc8461`; no trailer lines; the tree clean, `main` == `origin/main`; zero app instances), the record, and captures `05` (the fixture note: all three blocks at the top, the empty third a ringed empty line with only the caret, the ＋ new block door's dashed edge under the prose's edge) and `07` (A Scandal in Bohemia, block 21/262 at the FOOT of the page with six blocks visible above it). **Rows 1 and 2 are FIXED as recorded.** Three judgment calls:

**(J1) The red guard pin was a REAL DEFECT in the batch's landing, not a harness flake — traced and fixed at the adjudication (the architect's small-fix latitude; the ladder reviews the fix as part of the diff).** The implementer's suspect was real but not the mechanism: the dev-store domain did hold `takesViewMemory.<post id 0>` (four columns — a main and three scratch lenses, alignment locked — written by the Takes lessons of the tutorial spine, whose models are built bare on `.standard`; the R1-7 class, KnownIssues, owner 12), and the 38-suite closing run was the first to run that spine beside the new suite; but giving the harness its own scrubbed `UserDefaults` suite (`TakesLifecycleFacesTests`' pattern; kept) left the pin red 3/3. Instrumentation on the mounted board then measured THREE things, in order: **(a)** the landing was spent at the article's FIRST geometry report with ZERO row frames reported, and a `scrollTo(anchor: nil)` against a row a lazy column has not realized is a no-op — so the far block was never revealed, and the three-block pin was green for the WRONG reason (its reveal silently did nothing rather than deciding the row was on screen); **(b)** a lazy column's rows report PLACEHOLDER frames first — every row 28 pt, then 50 pt, then measured, each pass on its own turn — so "the row is on screen" read from an early frame is the constitution's starved-host class (a twelve-row note fits in 400 pt on the first pass); **(c)** the article's position is a bound `ScrollPosition`, which SwiftUI re-applies on relayout until her hand moves the page, so a one-shot proxy scroll is undone by the next content-size change (65 pt, then back to 0 — the restore beside it survives only because it re-aims). Scrolling THROUGH the binding (`ScrollPosition.scrollTo(id:anchor:)`, with `.scrollTargetLayout()` on the rows) was tried and is a no-op from inside these geometry callbacks on this OS (the restore fell 11 rows short); rejected, the proxy stays the ONE scroll mechanism. **The fix, on the restore's own principle:** the landing is a bounded step machine on `TakesBoardLayout` (`ArticleLandingStep` / `ArticleRevealAim` — the model's words, mapped to anchors by the view; P-9): it WAITS while nothing is laid out, aims by DIRECTION at a row the column has not realized (beyond the realized rows → the foot; before them → the head), re-aims as the column realizes and measures its rows, never the far edge (R-Q1's letter), and ENDS AT HER HAND — a scroll (`consumeArticleGeometry`'s user branch), a click that migrates the live pane (`focus`'s `.migrated` arm only), an edit (`paneEdited`) — or after 64 aims, or at once for a row the note no longer holds. Within a mount it therefore persists through the settling passes; across mounts it dies with the model (the 17o batch-b BLOCKER was a request outliving its MOUNT). `revealDecision` gained the tall-row rule (a row taller than the page is on screen when its top is). The view re-enters the spend from the geometry hook, the landing's change AND each row's frame report. **Pins:** `TakesArticleScrollTests.aLongNoteEnteredOnAFarBlockRevealsItWithoutHaulingItToTheTop` red 3/3 on `066e2588` (offset 0, the row never realized) → green 3/3; its non-vacuity is now `articleLandingAims > 0` (a plain counter, the `measuredHeightWrites` precedent) instead of the request being nil; pure: `theLandingWaitsForRowsAimsByDirectionAndStaysUntilHerHand` · `theLandingAimsAtTheHeadForARowAboveTheRealizedOnes` · `theLandingEndsForAGoneRowAndAfterItsBoundedAims` · `herOwnScrollCancelsAPendingLanding`, and the tall-row cases in `theRevealDecisionOnlyMovesForARowThatIsNotFullyOnScreen`; the two suites green 3/3 (12 tests). **For the reviewer (F-1):** one decision on the layout, one view site, the proxy the one scroll; the ladder should look hard at the her-hand set (is any hand missing? is `focus`'s `.migrated` the right arm — the landed pane's own first-responder round trips `.unchanged` and must not end it) and at the 64-aim bound. **For KnownIssues at the close:** the R1-7 row gains the tutorial-spine instance (its Takes lessons write `takesViewMemory` for the lesson post into the shared domain) — recorded, not fixed here; the leftover key stays in the dev-store domain untouched (the ladder sees the same store).

**(J2) The implementer's design call is ACCEPTED:** the article's memory is the BLOCK at the top of the page, restored by one absolute idempotent `scrollTo(row, anchor: .top)` re-aimed until the row says so — both measurements that forced it (a raw offset 96 pt / nine blocks apart across mounts; a relative nudge doubling its own correction) are on the record, and J1's third finding (a bound position re-applied on relayout) is exactly why an absolute re-aimed restore is the only shape that survives. The sub-row place is deliberately not promised.

**(J3) The R-Q1 observation stands as ruled, bundled for her:** with both halves kept, a LONG note whose current block is far from where she left the page restores first and then reveals the current block once more; on the two- and three-block notes she reported nothing moves. One condition if she wants the restore to suppress the entry landing — hers to say.

The canon note drafted in the record (AppSpec §12's takes line: an empty block in Takes is an empty LINE — R-Q2 supersedes the FACE of Phase 13 batch 9's R103, its substance standing; a dated sentence at R103 in the 13 plan) is adopted for 17p's close. The three stray `2026-09-12` notes in the dev store are the implementer's; harmless. **Closing runs over the adjudication tree:** the two batch suites `✔ 12 tests in 2 suites` ×3; the batch's 38-suite closing set `✔ Test run with 255 tests in 38 suites passed after 112.473 seconds` (the batch's 251 + the four pure pins). **Batch a is CLOSED at the adjudication commit; the 17p batch-a Fable ladder opens over `2bfc8461..da75fd47`.**

### 17p batch a LADDER — ROUND 1 FINDINGS (fable-reviewer)

**Reviewer:** `fable-reviewer`, cold, round 1 over `git diff 2bfc8461..da75fd47` (the six code commits `991cfd10` · `664b7ad0` · `33fa46d5` · `a1f88379` · `066e2588` · `da75fd47`; `ee1f1f5a` and `d9602261` notes-only), read against `notes/REVIEW_PROMPT.md` verbatim, CLAUDE.md and the auto-loaded canon, this plan's §0–§5, §7 (R-Q1 · R-Q2), §8–§9, §12 (F-0 · F-1 · F-2), R-0, the R-1 brief, record and adjudication, `phase-17-standing-fixes.md`'s rules and the 17p row, her report, the previous round's R-6 ladder round 1 (the landing family's BLOCKER class), KnownIssues' R1-7 row, and the orchestrator's diagnostic traces (`/tmp/orch-diag1…4.log`, the `ORCH-DIAG geo/step` lines) as evidence for the adjudication's measured claims. Tree at `d9602261` (`main` == `origin/main`), code byte-identical to `da75fd47`; `Sources/`, `App/Variorum/Shared/`, `Sync/` and `CommandRoutingTests.swift` diff-empty against `2bfc8461` (verified); zero commit trailers on the eight commits (verified). **Evidence discipline:** every finding below was traced by reading, and the four mounted-board mechanisms (R1-1 · R1-2 · R1-4, and the F-1 clean-bill line) were then MEASURED through a temporary, untracked probe suite built on `TakesArticleScrollTests`' own harness (`ZZReviewProbeTests`, four tests, run once via `-only-testing`, then deleted — the tree is clean; the numbers are quoted where they are used). No code or test file was changed; this record is the one write.

#### Findings, severity-ranked

**R1-1 · MAJOR · `App/Variorum/Variorum/Features/Takes/TakesBoardLayout.swift:580–595` (`articlePlaceNow`) + `:628–655` (`restoreStep`) + `Features/Takes/TakesBoardView.swift:633` (the article `LazyVStack`'s `.padding(.vertical, 18)`) · a page LEFT AT THE TOP comes back 18 pt down, on every return — the commonest road she reported (a two/three-block note) is the one the restore gets wrong.** Mechanism: at offset 0 the first row's frame in `.scrollView` space has `minY == 18` (the column's top padding), so `articlePlaceNow` finds no row with `minY ≤ 0.5` and its fallback remembers row 1; on the remount `restoreStep` reads row 1's `minY == 18 > 2`, aims `scrollTo(row1, anchor: .top)`, SwiftUI aligns the row's top with the viewport's top (offset 18), the row now reports `minY == 0` and the restore settles there; every later round trip re-settles at 18 (row 1 is at `minY 0` the moment the page is at 18, so the memory keeps saying row 1 and the restore keeps agreeing). **Measured (probe, 12 blocks, no fact, no landing):** first mount `offset 0.0`, memory = row 1; remount `offset 18.0`, top row 1, `ready true`. The walk's round trip (captures 08/09) was on block 21 of 262 and the remount pin leaves at 800 pt — neither covers the top, and the page she described ("you only have two blocks… leave and come back") is exactly the uncovered case: the first block's card comes back flush under the chrome row, the page visibly not at rest. Fix: the memory carries an explicit TOP place (`ArticlePlace.top`, or `rowID: String?` with nil = top), remembered when `geometry.offset ≤ 0.5` (`rememberStep` takes the geometry it is called with), and a `.undecided` mount with `.top` remembered settles at once — a mount starts at 0, no scroll is issued; the row promise stands everywhere else. Pin (red on this tree): `TakesArticleScrollTests` — mount 12 blocks with no fact, settle, remount → `offset(article) == 0` (red: 18.0); a pure arm beside it: `consumeArticleGeometry(offset 0 …)` with row 1 reported at `minY 18` → `.remember(.top)`.

**R1-2 · MAJOR · `TakesBoardLayout.swift:414–440` (`articleLandingStep`'s `.wait`-and-keep) + `Features/Takes/TakesViewModel.swift:834–850` (`toggleExpanded` / `expandAllFans` / `closeAllFans`) + `:2312` (`run`, the "every gesture an Operations call" funnel) · the kept-alive landing RE-AIMS after her own board gestures and moves the page — the request outlives its moment WITHIN the mount (F-1's concern, the batch-b BLOCKER's class one mount narrower).** Mechanism: the landing survives while its row is on screen (`.wait`) and re-enters `.reveal` from every row-frame report; the her-hand set is scroll · migrating focus · edit only, and nothing in the expansion doors or the gesture funnel clears it — so a bloom on a row ABOVE the landed one (`toggleExpanded` → `board.toggleExpanded`, a footer or strip grows the row) pushes the landed row below the fold → `.reveal(.foot)` → `scrollTo(row, .bottom)` → the page scrolls down by the strip's height and the top rows leave the screen. **Measured (probe, 12 blocks entered on the last):** revealed at `offset 65`, `aims 12`, top row 1; `toggleExpanded(row 2)` → `offset 97`, `aims 33`, top row 2 — block 1 scrolled off after her click, and 21 aims spent on one bloom (the 64 bound is three blooms away). This is her complaint's class ("the page keeps trying to jump… and not show the text above") one gesture after entry, until her first scroll/click-away/keystroke. Fix: every board gesture is her hand — clear the landing in the three expansion doors and at the top of `run` (the migrate/edit arms stay); the settling passes J1 protects carry no gesture, so the placeholder-frame reasoning is untouched. Pins (red on this tree): model — `landArticle("far")` · `toggleExpanded("x")` → `articleLanding == nil` (red: "far"); face — the probe's shape, the offset unchanged after a bloom above the landed row (red: 65 → 97).

**R1-3 · MAJOR · `TakesViewModel.swift:656–658` (`articleLandingStep()` builds `projection.slots.map(\.placementID)` EAGERLY) called from `TakesBoardView.swift:589–594` (every realized row's `onGeometryChange` action → `spendArticleLanding`) and `:657` (the geometry hook) · P1's letter: with NO landing pending, every realized row's frame report on every scroll frame allocates an O(N) array in the note's block count before the layout's `guard let landing else { return .done }` can short-circuit.** Cost per scroll frame ∝ realized rows × N (≈ 12 × 262 String copies per frame on her 262-block note, at scroll rate, forever). Tiny in absolute terms — not perceptible — but "cost ∝ viewport + edit, never document size" is an invariant, and this is document size on the hottest path the batch added. Fix: guard on `board.articleLanding != nil` before building `order`, or pass `order` as an autoclosure the layout evaluates only past its guard (the `contains`/`firstIndex` walks inside a pending landing are bounded by the 64 aims and fine). Pin: an autoclosure counter — with nothing pending, `articleLandingStep` never evaluates `order` (red on this tree: evaluated on every call). Architectural/perf class — the traced degradation is the justification.

**R1-4 · MINOR · `TakesBoardLayout.swift:597–655` (`consumeArticleGeometry` / `restoreStep`) + `:562` (`articleRestoreAttempts`, and the doc above it) · a remembered row the note no longer holds never settles the restore, which STARVES the entry landing and freezes the stale memory until her hand — and the doc's claim ("Bounded so a memory naming a row the note no longer holds… settles instead of waiting forever") is false as built.** Mechanism: the memory is a placement id (`container_block.id`), gone after a delete, a merge, a divide-W or a version restore of the block that was at the top of the page while she was away (in Write, or from the phone via sync); `scrollTo(gone, .top)` is a no-op, so the geometry stops changing, and the 24-aim bound counts GEOMETRY REPORTS (3–8 per mount in the orchestrator's own traces), never turns — so `.wanted` never ends, `articleReadyForLanding` stays false, `articleLandingStep` returns `.wait` forever, and no `.remember` ever runs to correct the memory. **Measured (probe, 12 blocks, memory `"gone-row"`, fact = the last block, 20 settle turns):** `offset 0`, `aims 0`, `ready false`, memory still `"gone-row"`. On a long note that is the row-8 regression (the current block off screen at the top) for the rest of the session's entries into that note, until a hand scroll settles it. Fix: thread the slot order into `consumeArticleGeometry` (the view model has `projection.slots`) and settle at once when the remembered row is absent — the landing's own `guard order.contains` rule, applied to the restore. Pin (pure, red on this tree): `consumeArticleGeometry(…, remembered: "gone", …)` with a frame for "a" and order `["a"]` → settled and `.remember(a)` (red: `.scrollToRow("gone")` and `.wanted`).

**R1-5 · MINOR · `App/Variorum/VariorumTests/TakesArticleScrollTests.swift:450–470` (`theBoardRevealsAnOffScreenSlotLeavesAVisibleOneAloneAndSpendsItOnce`) · hollow on the claim its name makes, and pinned to a road production no longer takes.** "Spent exactly once" is asserted after the test calls `clearArticleLanding()` itself (`:459`, `:465`); and it pins `articleReveal(for:)`, which nothing in production calls since J1 (the spend is `articleLandingStep` → `revealDecision`). The record lists it among row 1's four pins. Fix: retire it (the J1 pins `theLandingWaitsForRows…` / `…EndsForAGoneRow…` / `herOwnScrollCancels…` cover the real road), or repoint its arms at `articleLandingStep`.

**R1-6 · MINOR (F-0) · `TakesViewModel.swift:629–636, :650–652` + `TakesBoardLayout.swift:482–491` · dead forwarders on the constitution's own counterexample, and the split worth naming.** `TakesViewModel.noteArticleViewport`, `.articleReveal(for:)` and `.articleReadyForLanding` have no production caller (grep; the view uses `noteArticleRowFrame` / `forgetArticleRowFrame` / `consumeArticleGeometry` / `articleLandingStep` / `articleLanding`); the layout's `noteArticleViewport` / `articleReveal(for:)` are reached only by R1-5's pin. The view model is 2,466 lines (P-9 cites it at 890) and the batch added ten forwarders, three dead. Fix: delete the three (and the layout pair with R1-5). Named, not demanded: the article-scroll machinery is ~350 of `TakesBoardLayout`'s 768 lines — five enums, two step machines, nine stored properties, and no dependence on the rest of the layout beyond `articleLanding` — a natural `TakesArticleScroll` type the layout owns; it is IN-shape today (session-only view geometry, the file's stated purpose), so this is a split candidate for the next touch, not a violation.

**R1-7 · NIT · stale docs from the `a1f88379` refinement:** `TakesViewModel.swift:666` names `EditorRouter.takesArticleOffsets` (the property is `takesArticlePlaces`); `EditorRouter.swift:80–81` still says "the row at the top of the viewport plus how far into it she was"; `TakesBoardView.swift:639` "The offset is the SESSION's"; `TakesArticleScrollTests.swift:193, :272, :300` "a row plus how far into it". The sub-row half was removed on purpose; the docs should say so.

**R1-8 · NIT · `TakesArticleScrollTests.swift:88–94` (the `Fixture.defaults` doc) records a mechanism the adjudication itself falsified** — "mounted THIS board as a four-column Lenses board and the reveal guard read offset 0 with no article pane": the Takes board renders `singleColumnArticle` unconditionally (`TakesBoardView.swift:163`; the columns memory drives Lenses), and J1 says the scrubbed suite left the pin red 3/3. Reword to what J1 found (the own-suite is right for the R1-7 class; the red was the unrealized-row spend).

**R1-9 · NIT · `App/Variorum/VariorumTests/TakesEmptyBlockFaceTests.swift:91` builds its model on `.standard` (the KnownIssues R1-7 class the sibling suite was just given its own domain for) and `TakesArticleScrollTests.swift:451` constructs `TakesBoardLayout(postID: "post", defaults: .standard)` beside the suite's own `freshBoard` helper.** Consistency only (the layout's init reads `takesSlotHeights.post` from the dev-store domain, writes nothing).

#### Considered and cleared (traced, measured where it mattered)

- **J1(c) — "a bound `ScrollPosition` is re-applied on relayout until her hand" — does NOT reach past the restore's settle.** The worry: after the restore settles (no re-aim any more) a content-size change without a hand (a bloom, a wrapped line) would snap the page to 0 and `.remember` would then overwrite the memory with row 1. **Measured (probe, 60 blocks, memory = row 31, no fact):** restored `offset 1038`, top row 31; `toggleExpanded(row 31)` → `offset 1038`, top row 31, memory row 31. The orchestrator's own trace agrees (`orch-diag2.log`: the remount's `494` re-aim then held through four content changes, `user=false` throughout) — the re-application is confined to the initial layout window the restore already re-aims through. Cleared; recorded so the next reader does not re-derive it.
- **The her-hand set as built:** `focus`'s `.migrated` arm only is RIGHT (the landed pane's own first-responder round trip is `.unchanged` and must not end it — `TakesViewModel.swift:529–533`); `paneEdited` clears after the zero-cost guard (`:696`), right; `isPositionedByUser` from the geometry hook (`:606`) is the scroll arm. What is missing is R1-2's gesture arms, not these.
- **The restore's shape (J2):** absolute, idempotent `scrollTo(row, .top)`, settled when the ROW reports `|minY| ≤ 2`, bounded, her hand outranks it; the memory gated on `landingEnabled` (`:672`, `:677`) so the Write panel's embedded model never shares it; session-only, never persisted, never synced; `@ObservationIgnored` on the frames/viewport/aims so a scroll re-renders nothing. Sound — R1-1 and R1-4 are two places, not the shape.
- **The choreographer is untouched** (`TakesChoreographer.swift:150–205` byte-identical to the pre-batch file); the three `TakesLandingTests` pins ride unmodified (`CommandRoutingTests.swift` diff-empty).
- **`.scrollView` as the visible-region space:** consistent with the probe (row 1 at `minY 18` at offset 0; a row above the fold negative) and the record's own measurement.
- **`onScrollGeometryChange` on the article `ScrollView` directly** (one scroll view → no "first one found" ambiguity); `.frame(in: .scrollView)` names the innermost CONTAINING scroll view, the article's, not a fan strip's.
- **The two red-on-old numbers for the rows** (86 where 0 is owed; 210 vs 218) are consistent with the mechanisms (the old `anchor: .top` landing; the cell padding 2 + inset 6); the J1 red (offset 0, `aims`-less) is visible in `orch-diag2.log:477–546` (65 → 0, the old one-shot spend undone by the initial position).
- **Two boards on one note (a second window)** share `takesArticlePlaces[postID]` exactly as Write's `scrollAnchors` does — the pre-existing class, not the batch's.

#### Review foci (§12), addressed

- **F-0 (no god brain, no god file):** the rule lives in ONE type (`TakesBoardLayout`) and is performed at ONE proxy; no setting is read per surface; no literal number-as-rule in the view (the door's inset is derived from two named constants; the 18 pt padding is pre-existing chrome). What the focus catches: the forwarder tax on the view model (R1-6, three dead) and the layout's doubling (named split, in-shape). Not a god-brain finding.
- **F-1 (one decision, one view site, no second scroll mechanism, spent once):** one decision on the layout, three entries funnelling through `spendArticleLanding` to the one `ScrollViewProxy`; the `ScrollPosition` binding issues no scroll (a user-scroll detector only) — no second mechanism beside the room. "Spent exactly once" is where the batch is short: the request is ended by her hand, and her hand is under-enumerated (R1-2, measured); across mounts it dies with the model (right).
- **F-2 (the empty block's face is the pane's own line, nothing re-added):** the overlay is gone; the string has no other reader anywhere under `App/` (grep: none); `TakesCellChrome` is a DEBUG oracle that draws nothing; `LensesBoardView` composes the same cell (`:519`, `:568`) and carries no landing; `TakesEmptyStateView`'s layout untouched; the door reuses the empty state's one verb (`TakesEmptyState.newBlockVerb`). Solid.

#### CLEAN BILL — checked and found solid

- **The two rows' pins and their red-on-old numbers** (`aThreeBlockNoteEnteredOnItsLastBlockOpensAtTheTop` 86 → 0; `aBoardLeftScrolledComesBackWhereSheLeftIt` at 800 pt on 60 blocks, within one block; `anEmptyBlockShowsNoPlaceholderWords` `["empty take — line kept"]` → `[]`; `theNewBlockDoorsEdgeSitsOnTheProsesEdge` 210 vs 218 → aligned) — mechanisms read, numbers consistent, the suites 9 + 3 tests as recorded.
- **The door's alignment:** `TakesBoardView.articleTextLeadingInset = articleCellPadding + PaneTextView.takeSurfaceInset`, both named where they were literals (`TakesBoardView.swift:903`, `PaneSurface.swift:696`), the cell's own padding on the same name; the probe sits inside the padding (the recorded trap honoured); `PaneSurface`'s liveness and measurement brain untouched (a constant naming only).
- **The DEBUG oracles** (`TakesCellChrome`, `TakesArticleDoorProbe`): `#if DEBUG`-gated storage, `@ViewBuilder` no-ops outside DEBUG, the `TakesEmptyStateDoors`/`LensesGeometry` pattern; reset per mount by the suite.
- **`revealDecision`'s tall-row rule and slack**; `revealAnchor`'s direction-by-realized-rows with `.foot` as the safe default; both pure, `nonisolated`, pinned with the arms read.
- **`noteArticleRowFrame`'s equality gate**, `forgetArticleRowFrame` on `onDisappear`, the viewport recorded from the geometry hook; the row-visibility ref-counts untouched.
- **The clear-landing arms in `focus` and `paneEdited`** land in the right branches.
- **Nothing in `Sources/`, `Sync/`, `App/Variorum/Shared/`, the schema; no product invention (every decision is R-Q1's or R-Q2's letter; #102 free); the canon note drafted for 17p's close is the right one (AppSpec §12's takes line + a dated sentence at R103).**
- **No trailer lines on the eight commits; no history rewrite; the tree clean at `d9602261`.**

**Counts: 0 BLOCKER · 3 MAJOR · 3 MINOR · 3 NIT.** No fix was made; the code is untouched until the orchestrator's follow-up.

#### Implementer's responses (round 1)

*The batch-a implementer (`opus-implementer`) under the cross-model flow: agree/dispute with rationale,
traced against the code at `d9602261` in my own context — nothing implemented, no code or test file
touched, this plan is the only file this edits. **9 AGREED · 0 DISPUTED.** The reviewer makes the final
call on each and implements its confirmed fixes itself. Kept short at the orchestrator's instruction
(my context is past the degradation line).*

**R1-1 (MAJOR — a page left AT THE TOP comes back 18 pt down) — AGREE, and it is mine.** Read and
confirmed: the article's `LazyVStack` carries `.padding(.vertical, 18)`
(`TakesBoardView.swift:633`), so at offset 0 row 1 reports `minY == 18` in `.scrollView` space,
`articlePlaceNow`'s first loop (`minY <= 0.5`, `TakesBoardLayout.swift:582`) matches nothing, the
fallback remembers row 1, and `restoreStep` then reads `|18| > 2` and aims. **Answering the
orchestrator's question: no — my restore never considered an explicit TOP place.** I wrote the fallback
as "no row straddles the fold, so take the first one" for the short-note and empty cases and never
reasoned about the column's own top padding; and neither pin reaches it (the remount pin leaves at 800
pt, the three-block pin never remounts). `ArticlePlace.top` (or `rowID: String?`) is the right shape —
and it also removes a scroll that a fresh mount does not need, since a mount starts at 0.

**R1-2 (MAJOR — the kept-alive landing re-aims after her own board gestures) — AGREE.** Confirmed:
`articleLandingStep` returns `.wait` WITHOUT clearing while the row is on screen
(`TakesBoardLayout.swift:421`), the view re-enters the spend from every row's frame report
(`TakesBoardView.swift:592–593`), and nothing in `toggleExpanded` / `expandAllFans` / `closeAllFans`
(`TakesViewModel.swift:834–850`) or `run` touches the landing. Worth stating for the fix's shape: in my
own batch this class could not exist — `spendArticleLanding` cleared the request unconditionally on
first spend — so the keep-alive is J1's, and the gesture arms are what it owes. Clearing at the top of
`run` plus the three expansion doors is the right set; the settling passes J1 protects carry no
gesture, so nothing about the placeholder-frame reasoning moves.

**R1-3 (MAJOR — P1: the eager `order` array on the hottest path) — AGREE.** Confirmed:
`TakesViewModel.articleLandingStep()` builds `projection.slots.map(\.placementID)` (`:656–658`) BEFORE
the layout's `guard let landing else { return .done }` can short-circuit, and the view calls it from
every realized row's geometry action. So with nothing pending the cost is realized rows × N per scroll
frame — document size on a path the batch added, which is exactly what P1 forbids however small the
absolute number. The autoclosure is the cleaner of the two fixes (it keeps the layout's guard as the
one place that decides), and the counter pin reads honestly.

**R1-4 (MINOR — a gone row starves the restore, and my doc is false) — AGREE, including the half
against my own comment.** Confirmed: the bound at `TakesBoardLayout.swift:562` is decremented once per
CALL of `restoreStep`, and each call is one geometry report — so with 3–8 reports per mount the 24 aims
are never reached and `.wanted` never ends, which keeps `articleReadyForLanding` false and starves the
landing. **Answering the orchestrator's question — why the bound counted geometry reports:** I wrote it
as "how many times may this restore aim", and an aim IS one geometry report by construction, so the
two looked like the same number; what I did not consider is that when `scrollTo` is a NO-OP the
geometry stops changing altogether, so the counter stops advancing at exactly the moment it was
supposed to save us. Settling at once on `!order.contains(remembered)` is the right fix and matches the
landing's own rule.

**R1-5 (MINOR — `theBoardRevealsAnOffScreenSlotLeavesAVisibleOneAloneAndSpendsItOnce` is hollow now) —
AGREE, with one point of record.** It was not hollow when written: `articleReveal(for:)` was the
production spend road at `066e2588` (`spendArticleLanding` called it), and the "spent once" arms were
checking that `clearArticleLanding` left nothing behind for a later mount. J1 replaced that road, so
today it pins a door nothing opens and asserts a clear the test itself performs. Retiring it is right;
repointing its arms at `articleLandingStep` would duplicate the J1 pins.

**R1-6 (MINOR, F-0 — three dead forwarders; the split named) — AGREE.** Confirmed by grep: the view
model's `noteArticleViewport` (`:629`), `articleReveal(for:)` (`:650`) and `articleReadyForLanding`
(`:636`) have no production caller. `noteArticleViewport` DID have one in my batch (the view's geometry
action called it) and J1's move of the viewport-recording inside `consumeArticleGeometry`
(`TakesBoardLayout.swift:601`) orphaned it — worth knowing so the delete is read as tidying a move, not
removing a seam. The `TakesArticleScroll` split is a fair "next touch" note and I would not do it
inside a ladder fix.

**R1-7 (NIT — stale docs from the `a1f88379` refinement) — AGREE.** All four are mine:
`TakesViewModel.swift:666` still names `takesArticleOffsets` (the property is `takesArticlePlaces`),
and `EditorRouter.swift:80–81`, `TakesBoardView.swift:639` and the three test comments still describe
the row-plus-delta memory the same commit removed on purpose.

**R1-8 (NIT — the `Fixture.defaults` doc records a falsified mechanism) — AGREE on the fact.** That doc
is the adjudication's, not mine, so I have no history to add; the code half is checkable and checks
out: the Takes board renders `singleColumnArticle` unconditionally (`TakesBoardView.swift:163`) and the
columns memory drives Lenses, so a four-column Lenses board cannot be what the pin mounted.

**R1-9 (NIT — `.standard` in the face suite) — AGREE, mine.** `TakesEmptyBlockFaceTests.swift:91`
builds `TakesViewModel(session:postID:)` on the default `.standard`, which is the R1-7 class the
sibling suite was just given its own domain for; giving it the same scrubbed suite is consistency at no
cost.

#### Reviewer's dispositions + fixes (round 1)

*The round-1 `fable-reviewer`, under the cross-model flow's follow-up authorization (the orchestrator's message; the implementer's responses above: 9 agreed, 0 disputed). Final calls made and the confirmed fixes implemented in this session — each bug-class fix with its red-on-old pin verified by behavioral revert (the four compile-on-old pins were run ONCE on the unfixed tree `1112d4b1` before any code moved: `scratchpad/red-round1.log` — 13 tests, 10 issues, the numbers below), committed per finding with path-scoped adds, no trailer lines, pushed after each. Nothing in `Sources/`, `App/Variorum/Shared/`, `Sync/`, `BlockRangeIndex`, `EditorTextView`, `PaneTextAuthority` or the choreographer was touched. Eight commits `d5ac3785` … `839342a3`.*

- **R1-1 · CONFIRMED-FIXED · `d5ac3785`.** `ArticlePlace` carries the TOP as a place of its own (`rowID: String?`, `static let top`); `rememberStep` takes the geometry and remembers `.top` when the page is at rest (`offset ≤ 0.5`); a `.undecided` mount with `.top` (or nothing) remembered settles at once and issues no scroll; `restoreStep` is total over the nil row. Pins: `TakesArticleScrollTests.aBoardLeftAtTheTopComesBackAtTheTop` (mounted, 12 blocks, no fact — **red on old 18.0 where 0 is owed**) · `theTopOfThePageIsRememberedAsTheTopAndRestoresWithoutAScroll` (pure: at rest → `.remember(.top)` never the padded first row; `.top` remembered → ready at once, no scroll; scrolled → the row at the top of the viewport).
- **R1-2 · CONFIRMED-FIXED · `12410b7d`.** Every board gesture is her hand: `toggleExpanded` / `expandAllFans` / `closeAllFans` and the Operations plumbing `run` / `runCopying` clear a pending landing beside the migrate and edit arms (the view model, where J1's arms live; the layout's `bloom` is left alone — the choreographer's bloom arm calls it BEFORE `landArticle`). The structure controller's acts (which use `session.runner` directly) are covered by construction — every mint ends in a focus migration and a delete/archive of the focused block makes the landed row gone (`.done`) — and were left untouched; recorded here. Pins: `herBoardGesturesEndAPendingLanding` (model — **red on old: the landing survived all four gestures**) · `herBloomAboveTheLandedRowLeavesThePageWhereItIs` (mounted, 12 blocks entered on the last, a bloom on row 2 — **red on old 65 → 97**; green: the landing nil and the page within 2 pt).
- **R1-3 · CONFIRMED-FIXED · `eb9a68a4`.** `articleLandingStep(order:)` takes the slot order as an `@autoclosure` evaluated only past its two guards; the view model's call site is unchanged in text and the O(N) map now runs only while a landing is pending and ready. Pin: `theLandingStepReadsTheSlotOrderOnlyWhenARequestIsPending` (the evaluation counter: 0 across three steps with nothing pending, 1 per step with a landing). Red-on-old is by construction rather than by run — on the round-1 tree the view model built the array before the call, unconditionally, and no test can observe an allocation; the traced degradation (realized rows × N String copies per scroll frame, forever, on a path the batch added) is the P1 justification.
- **R1-4 · CONFIRMED-FIXED · `53fb961b`.** `consumeArticleGeometry` gains `order: @autoclosure () -> [String]? = nil` (the view model passes `loaded ? slots : nil` — nil while the projection has not landed, so a late projection keeps the aim); `restoreStep` settles AT ONCE on a remembered row the order does not contain, remembering where the page is (the stale memory corrected). The false doc on `articleRestoreAttempts` reworded to what the bound covers (a row the column never brings to the fold) and what it cannot (a no-op scroll stops the reports). Pins: `aMemoryOfARowTheNoteNoLongerHoldsSettlesAndLetsTheLandingLand` (mounted — **red on old: aims 0, offset 0, the memory frozen at "gone-row"**) · `aRememberedRowTheNoteNoLongerHoldsSettlesAtOnce` (pure, with the slots-unknown arm keeping `.scrollToRow`).
- **R1-5 · CONFIRMED-FIXED · `7bca6804`.** `theBoardRevealsAnOffScreenSlotLeavesAVisibleOneAloneAndSpendsItOnce` retired (the implementer's point of record accepted: it was honest at `066e2588` and J1 replaced its road); the J1 step-machine pins carry the real one. Test-only; no pin owed.
- **R1-6 · CONFIRMED-FIXED (the forwarders) + CONFIRMED-RECORDED (the split) · `d3fe484b`.** `TakesViewModel.noteArticleViewport` / `articleReveal(for:)` / `articleReadyForLanding` and the layout's `noteArticleViewport` / `articleReveal(for:)` deleted (no production caller; the first orphaned by J1's move, as the implementer noted). **The `TakesArticleScroll` split is NAMED, not made:** the article-scroll machinery (~350 lines of `TakesBoardLayout`, five enums, two step machines, nine stored properties, coupled to the rest only through `articleLanding`) is a natural type the layout would own; in-shape today (session-only view geometry, the file's stated purpose), so it is a next-touch item — **owner 13u2** (the restyle continuation already inherits this surface's three additive seams per the batch record), for the orchestrator to copy into KnownIssues at 17p's close if it wants a row. Cleanliness class; no pin.
- **R1-7 · CONFIRMED-FIXED · `da84ef5c`** (with R1-8, one commit — the same files). `takesArticleOffsets` → `takesArticlePlaces`; the "plus how far into it she was" half corrected in `EditorRouter`, the view's comment and the three test comments to the row-or-top place with the sub-row pixels deliberately not promised.
- **R1-8 · CONFIRMED-FIXED · `da84ef5c`.** The `Fixture.defaults` doc reworded to what J1 found (the own suite is right for the R1-7 class; the Takes board renders the article unconditionally, so a four-column Lenses board was never what the pin mounted; the red was the unrealized-row spend).
- **R1-9 · CONFIRMED-FIXED · `839342a3`.** `TakesEmptyBlockFaceTests` builds its model on its own scrubbed `UserDefaults` suite; the layout's `.standard` construction went with the retired pin.

**Closing runs (this tree, `839342a3`; zero app instances by `pgrep` before each):** the two batch suites, three times — `✔ Test run with 18 tests in 2 suites passed after 10.674 seconds` · `… 18 tests in 2 suites passed after 10.674 seconds` · `… 18 tests in 2 suites passed after 10.658 seconds` (`TakesArticleScrollTests` 15 + `TakesEmptyBlockFaceTests` 3); the batch's 38-suite closing set in ONE `xcodebuild test` (the RECORD's type list, a zsh array) — **`✔ Test run with 261 tests in 38 suites passed after 118.012 seconds`** (the adjudication's 255 + the seven new pins − the one retired; the log's only `skipped` match is the `appintentsmetadataprocessor` build line). Core `swift test` not re-run (`Sources/` untouched); the iOS build not owed (`Shared/` untouched).

**For the implementer's sanity pass (the cross-model flow's next step) and the orchestrator:** the diff to read is `1112d4b1..839342a3` (eight commits, four files under `App/Variorum/Variorum/` — `TakesBoardLayout` · `TakesViewModel` · `TakesBoardView` (a comment) · `EditorRouter` (a comment) — and the two test files). Two things worth a second pair of eyes: (1) R1-4's `loaded ? slots : nil` — the "slots not yet known" arm is the guard against the app's asynchronous projection (`.task { await model.start() }` lands after the first geometry report; the tests adopt before mounting and cannot exercise the late arrival — the pure pin's nil arm states the contract); (2) R1-2 leaves the structure controller's acts uncleared by the reasoning above — if the implementer knows an act that ends in neither a migration nor a gone row, it names it and the fix is one line at that act. Nothing here is open; no QUESTIONS entry; the canon note drafted at the adjudication stands.


#### Implementer's sanity pass (round 1)

*The batch-a implementer (`opus-implementer`), the cross-model flow's one sanity pass over
`git diff 1112d4b1..839342a3` — read in my own context, nothing implemented, no code or test file
touched. **(1) CLEAR. (2) ONE ACT RAISED**, plus two consistency notes. Anything here goes back to the
reviewer for the final word.*

**(1) R1-4's `loaded ? slots : nil` arm on the real entry road — CLEAR, and the reasoning that makes it
safe is worth keeping.** Two facts from the batch's context settle it. **(a) A landing implies
`loaded`:** `articleLanding` is only ever set by `consumeLandings`, which runs from `adopt`, and
`adopt`'s FIRST line is `loaded = true` (`TakesViewModel.swift:418–419`) — so the landing and the
non-nil order arrive in the same call. **(b) The projection's arrival always produces at least one more
geometry report:** the article's `ScrollView` exists before any slot does (`singleColumnArithcle`
renders the empty state at `TakesBoardView.swift:559–568`), so the restore can indeed begin with
`order == nil` and aim at a no-op; but `adopt` replaces the empty state with N rows plus the typewriter
room, which changes `contentSize.height`, and `content` is one of `ArticleGeometry`'s three fields
(`TakesBoardLayout.swift:492–503`) — so `onScrollGeometryChange` republishes, and the gone-row check
runs with the order KNOWN on that report. A late projection therefore cannot leave the restore aimed at
a gone row. **The one edge, and it fails safe:** the pre-projection no-op aims spend
`articleRestoreAimsLeft`, so a slow enough load (≥24 reports before `adopt`) settles the restore by the
bound instead of by the order — the same outcome the fix wants (settled, the memory rewritten by
`rememberStep`, the landing free), just reached by the other door.

**(2) R1-2's uncleared acts — ONE that ends in neither a migration nor a gone row: the SLOT-HEIGHT
DRAG.** `TakesViewModel.slotDragChanged` / `slotDragEnded` / `resetSlotHeight` (`:1957–1968`, driven
from the handle's `DragGesture` and its double-tap at `TakesBoardView.swift:1050–1057`) writes
`TakesBoardLayout.slotHeights` directly (`:208–231`): **no Operations call, so neither `run` nor
`runCopying`; no mint, so no focus migration; no delete, so the landed row is still in the order.** And
what it changes is a ROW'S HEIGHT — R1-2's measured mechanism exactly: drag a slot above the landed one
taller and the landed row goes below the fold → `.reveal(.foot)` → the page scrolls after her hand.
It is her hand in the plainest sense (she is dragging the board). One line at
`slotDragEnded`/`resetSlotHeight` — or, cheaper and more robust, at `beginSlotDrag`, so a drag that is
still in flight cannot be fought either. (The structure controller's own acts I checked out as the
disposition says: every `session.runner.run` site there ends in a `parkFocus` on a new or neighbouring
block, or tombstones the block whose row was landed on — the previous round's ladder enumerated the
same eight sites. And the model's other bare-`session.runner` acts are not a hole: `choose` (`:860`)
and `archiveTake` (`:1299`) both go through `await run { … }`, so they are covered.)

**Two consistency notes, benign today, named so the reviewer can take them or leave them.** `setPage`
(the ◀ ▶ pager, `:824`) and `toggleMergeSelection` / `extendMergeSelection` (`:1254`) are also board
gestures outside all three arms, and I traced both as harmless right now — N40's fixed strip height
means a page turn changes no content height, and the merge pick draws a stroke overlay
(`TakesBoardView.swift`'s `washedCell` overlay) with no layout effect. They only matter if the rule is
meant to be "every board gesture is her hand" rather than "every gesture that can move the page"; the
first is the cheaper invariant to keep true.

**Everything else in the diff reads right to me.** `ArticlePlace.top` is the shape I should have
written (and `restoreStep`'s nil-row arm makes it total rather than relying on the `.undecided` settle);
the autoclosure keeps the layout's guard as the one decider for both R1-3 and R1-4; the three deleted
forwarders are the ones grep showed dead, `noteArticleViewport` included (orphaned by J1's move, as
recorded); R1-5's retirement is right and the J1 pins carry its road; the four doc corrections say what
`a1f88379` actually did. No `Sources/`, `Shared/`, `Sync/` or choreographer change in the diff
(`git diff --stat` confirms six files, four app + two test).

#### Reviewer's final word (round 1)

*The round-1 `fable-reviewer`, on the implementer's sanity pass above (`e419bccd`). One piece, `510a1f7c`, pushed; the tree clean at it.*

- **R1-4's `loaded ? slots : nil` arm — CLEARED, the implementer's reasoning adopted:** a landing implies `loaded` (`adopt` sets it before `consumeLandings`), the projection's arrival changes `contentSize` and so republishes the geometry with the order known, and the pre-projection edge fails safe by the bound. Nothing to change.
- **The slot-height drag — CONFIRMED-FIXED (`510a1f7c`).** `TakesViewModel.beginSlotDrag` and `resetSlotHeight` end a pending landing — the two gesture doors (the handle's `DragGesture.onChanged` calls `beginSlotDrag` before every `slotDragChanged`, `onEnded` follows it; the double-click is `resetSlotHeight`); no programmatic caller of either (grep). They write a row's HEIGHT through no Operations call and no migration — R1-2's measured mechanism, exactly as raised. Pin: two arms added to `herBoardGesturesEndAPendingLanding` — **red on old: the landing survived both doors** (`scratchpad/red-final.log`, 16 tests, 2 issues); green after.
- **`setPage` and the merge pick — DISMISSED as arms, and THE RULE SETTLED (written at `TakesBoardLayout.clearArticleLanding`):** her hand is every gesture that can change the article's CONTENT HEIGHT or the LIVE PANE, armed at the view model's GESTURE DOORS and never at a model method a programmatic road shares. The two are not arms on both counts: neither can move the article page (the fixed strip height; a stroke overlay — the implementer's traces confirmed), AND both sit on shared roads — `setPage` is the strip's settled-scroll write-back (`TakesBoardView.swift:1242`), which also fires after the programmatic `pageToReveal` at adopt, and `clearMergeSelection` is called by the structure controller after a merge/split (`TakesStructureController.swift:274, :836, :928`) — so an arm there would end a landing her hand did not. The implementer's "every board gesture" invariant is the cheaper sentence but not the cheaper truth: its arms would have to avoid exactly these shared doors anyway, so the rule names the mechanism (height or live pane) and the placement (gesture doors) instead. The next arm is not guesswork: a future gesture that changes a row's height or the live pane adds its door and its arm in the pin.
- **One hazard raised by me while placing the arm — DISMISSED AS HOLLOW by its own pin:** `articleLanding` is observed and the geometry hook's her-hand branch writes `nil` on every scroll frame once she has scrolled; if Observation woke on a same-value write the board's body would re-evaluate per frame. Pinned (`endingANothingPendingLandingWakesNoObserver`: two user-positioned reports and a clear with nothing pending → zero wakes; a real `landArticle` → one) and **green on both sides** — so no guard was added to `clearArticleLanding`; the pin stays as a labeled GUARD (a tripwire for a point-release change in Observation's behaviour), never claimed as red-on-old.

**Closing runs (tree `510a1f7c`; zero app instances by `pgrep` before each):** the two batch suites, three times — `✔ Test run with 19 tests in 2 suites passed after 10.648 seconds` · `… 19 tests in 2 suites passed after 10.639 seconds` · `… 19 tests in 2 suites passed after 10.657 seconds`; the batch's 38-suite closing set in ONE `xcodebuild test` — **`✔ Test run with 262 tests in 38 suites passed after 117.698 seconds`** (the dispositions' 261 + the guard; the log's only `skipped` match is the `appintentsmetadataprocessor` build line). Core and the iOS build not owed (`Sources/`, `Shared/` untouched throughout the ladder).

**The ladder's round-1 residue for the orchestrator:** none open. Recorded, not fixed: the `TakesArticleScroll` split (R1-6, owner 13u2 at the next touch); the KnownIssues R1-7 row's tutorial-spine instance stays as J1 left it. The round-1 findings are all dispositioned (9 CONFIRMED, fixed across `d5ac3785`…`839342a3` + `510a1f7c`; 0 DISMISSED); no new BLOCKER/MAJOR surfaced at the sanity pass, so under the ladder's rule round 2 is the fresh reviewer's re-review of the fixes (a real pass, not a rubber stamp), with this record and the dispositions above as its anchor.

### 17p batch a LADDER — ROUND 2 FINDINGS (fable-reviewer)

**Reviewer:** a FRESH `fable-reviewer`, cold, round 2 — a re-review of the round-1 fixes `git diff 1112d4b1..510a1f7c` (`d5ac3785` · `12410b7d` · `eb9a68a4` · `53fb961b` · `7bca6804` · `d3fe484b` · `da84ef5c` · `839342a3` · `510a1f7c`) read against the whole batch `git diff 2bfc8461..510a1f7c`, under `notes/REVIEW_PROMPT.md` verbatim, CLAUDE.md and the auto-loaded canon, this plan's §0–§5, §7 (R-Q1 · R-Q2), §8–§9, §12 (F-0 · F-1 · F-2), R-0, the R-1 brief · record · adjudication, and the WHOLE round-1 record above (findings · responses · dispositions · sanity pass · final word) as the anchor. Tree `f5e86272` == `origin/main`, code byte-identical to `510a1f7c` (`git diff --stat 510a1f7c..HEAD -- Sources App` empty); `Sources/`, `App/Variorum/Shared/`, `Sync/`, `TakesChoreographer.swift` and `CommandRoutingTests.swift` diff-empty against `2bfc8461` (verified); zero trailer lines on the nine commits (verified); zero app instances at every run. **Evidence discipline:** every round-1 fix was re-read at its site and its pin read; the two batch suites were run once on this tree (`✔ Test run with 19 tests in 2 suites passed after 10.692 seconds`, `scratchpad/r2-suites.log`); and the one open question the final word left ("is any hand missing?") was answered by ENUMERATION — every Operations road in the Takes model (16 bare `session.runner.run` sites + every `run`/`runCopying` caller) and in the structure controller (13 sites) mapped to its enclosing door and classified against the settled her-hand rule — and then MEASURED through a temporary, untracked probe suite on `TakesArticleScrollTests`' own harness (`ZZReviewProbeR2Tests`, three tests, run once via `-only-testing`, then deleted; the tree is clean; the numbers are quoted where used). No code or test file was changed; this record is the one write.

#### Findings, severity-ranked

**R2-1 · MAJOR · `App/Variorum/Variorum/Features/Takes/TakesStructureController.swift:260–285` (`runSplit`, the ONE body of the three split doors `splitEveryNewlineIntoBlocks` `:187` · `splitFocusedBlockAtNewlines` `:213` · `splitSelectedBlocksAtNewlines` `:229`) + `:676–698` (`turnTakesIntoBlocks`) + `Features/Takes/TakesViewModel.swift:1807–1822` (`applyCallout`) · THREE gesture doors on the Takes board change the article's CONTENT HEIGHT through a bare `session.runner.run` with no focus migration and no gone row — and none is a her-hand arm, so the kept-alive landing RE-AIMS the page after her own gesture. R1-2's exact mechanism, three doors over; the round-1 final word's completeness claim ("the structure controller's acts end in a focus migration or a gone row by construction"; the sanity pass: "the model's other bare-`session.runner` acts are not a hole") is false for these.** Mechanism: a landing pending after entry (the N9 arm, kept alive per J1) survives while its row is on screen; each of these doors inserts rows or pads a row ABOVE the landed one (the note-wide split multiplies every block with a newline; takes-to-blocks mints a block per take below its target, which a card's own menu names explicitly on any row — `TakesShared.swift:338–339`; a callout adds `TakesCalloutFrame.pad` × 2 to the row it frames — the cell menu's submenu names any row, `TakesShared.swift:405–428`, the routed door the focused one, `TakesBoardView.swift:285–288`); the projection re-lands, the landed row leaves the fold, every row's frame report re-enters `spendArticleLanding`, `articleLandingStep` → `.reveal(.foot)` → the page scrolls after her click. **Measured (probe, 12 blocks entered on the last, the R1-2 face pin's shape):** *the note-wide split* (eleven three-line blocks above the landed one): `offset 406 → 1047` (a 641 pt haul, her "the page keeps trying to jump… and not show the text above" verbatim), `aims 6 → 50`, the landing still pending, slots 12 → 34; *a callout on row 2* (`applyCallout(.color(defaultName), blockID:)`, the cell menu's own call): `offset 65 → 75`, `aims 13 → 31`, the landing still pending. *Takes-to-blocks* is traced, not separately measured — the same road (rows minted above the landed one through a bare runner, no `parkFocus`: the awk map shows `parkFocus` in `addBlockAtEnd` · `insertBlockBelowFocused` · `deleteFocusedBlock` · `archiveFocusedBlock` · `runDivide` · `runKeepOnTopDivide` · `moveTakeIntoBlockBelow` · `mergeSelectedBlocks` and in NONE of `runSplit` · `turnTakesIntoBlocks` · `deleteSelectedBlocks`). The note-wide split is a door she reaches for (18c's U-6, her own ruling last round), on the bottom bar's note row (`TakesBottomBar.swift:426–428`). **Fix (option a, the settled rule's letter — my recommendation for this ladder):** `board.clearArticleLanding()` at `runSplit`'s `model.setStatus(nil)` line (the one body; its three callers are all gesture doors and nothing programmatic reaches it — the `run` placement's own reasoning), at `turnTakesIntoBlocks`' `model.setStatus(nil)` (`:688`), and at `applyCallout`'s `status = nil` (`:1812`); correct the RULE's doc at `TakesBoardLayout.clearArticleLanding` (`TakesBoardLayout.swift:318–346`): the arms list gains the three doors, and the "by construction" sentence narrows to the doors that park focus (named above) and the gone-row ones (the ceremony releases A; a delete of the landed block) — with the enumeration table below copied there so the claim is checkable rather than asserted. Pins (red on this tree): three arms in `herBoardGesturesEndAPendingLanding` (model — `landArticle(far)` · the door · `articleLanding == nil`; takes-to-blocks on a branched block), and ONE mounted face pin for the split (`herNoteWideSplitLeavesThePageWhereItIs`: the probe's shape, twelve blocks with newlines above the landed one, `splitEveryNewlineIntoBlocks` then `adopt` — red on old 406 → 1047; green: the landing nil, the page within 2 pt). **Option (b), recorded for the `TakesArticleScroll` split's owner (13u2), not for this ladder:** this is the class's THIRD surfacing (J1's keep-alive → R1-2 → the sanity pass's drag → this), which is P-5's signal that door-by-door enumeration is the wrong shape; the structural arm is ONE line in `adopt` — a projection that arrives while a landing is pending and differs from the one the landing was judged against ends it (`if articleLanding != nil, new != projection { clearArticleLanding() }`, before `consumeLandings`) — every Operations road, hers or a sync arrival's, then ends a landing by construction and the "by construction" sentence becomes true; its one cost is that a sync arrival in the first second after entry ends the reveal (acceptable, and no one asked for a reveal-after-sync). I am not making that call in a ladder round — the enumerated arms are the settled rule's letter, and with the table below the enumeration is complete and checkable.

**The enumeration (every Operations road reachable from the TAKES board, classified — the table the "by construction" claim needed):**

| Door (file:line) | Road | Changes content height / the live pane? | Covered by | Verdict |
|---|---|---|---|---|
| `choose` · `pick` · `adoptLens` · lens CRUD · `setFanStyle` · `archiveTake` / `unarchiveTake` · `restoreDanglingPick` · `setTakeLabel` / `setTakeLocked` / `deleteTake` · `commitFocusedTake` · `toggleSeal` · `updateEntryDate` · `setNewlinesMintBlocks` · `setPostWordTarget` · `restoreCommit` · `structure.reorderBlock` | `run` / `runCopying` | various | the `run` arm (R1-2); no programmatic caller of `run` exists (verified: every caller is a gesture door) | covered |
| `branchTake` `:1178` · `newBlankTake` `:1194` · `newBlankTakeAsChosen` `:2023` | bare runner | yes (the fan grows) | `revealTake` → `focus` → `.migrated` (a fresh variant is never the live pane) | covered |
| `runDivideW` `:2406` · `runDivideDuplicating` `:2454` (the ceremony on the board) | bare runner | yes | the target is the focused block = the landed one (a click elsewhere already cleared) → A released → the row gone → `.done` | covered |
| `addBlockAtEnd` `:72` · `insertBlockBelowFocused` `:97` · `deleteFocusedBlock` `:137` · `archiveFocusedBlock` `:172` · `runDivide` `:513` · `runKeepOnTopDivide` `:558` · `moveTakeIntoBlockBelow` `:663` · `mergeSelectedBlocks` `:829` | bare runner | yes | `parkFocus` → `focus` → `.migrated` (the survivor / the mint differs from the live pane); a one-block delete → the row gone | covered |
| `moveTake` `:622` (reorder within the fan) | bare runner | no (same cards, same height) | — | not an arm (the rule's letter) |
| `deleteSelectedBlocks` `:882` | bare runner | yes (rows removed) | no arm — but a `.foot` landing whose rows above are deleted moves UP and stays on screen (`.wait`); a `.head` landing's rows above are off-screen and unclickable without a scroll (her hand) | no traced page move; no arm owed |
| **`runSplit` `:260` (three doors)** | bare runner | **yes (rows multiply above)** | **nothing** | **R2-1 — measured 406 → 1047** |
| **`turnTakesIntoBlocks` `:676`** | bare runner | **yes (rows minted above when a card above is the target)** | **nothing** | **R2-1 — traced** |
| **`applyCallout` `:1807` (two doors)** | bare runner | **yes (the frame's pad)** | **nothing** | **R2-1 — measured 65 → 75** |
| Lenses-host-only roads (`addWriteColumn` · `replaceColumnWithNewWrite` · `branchIntoColumn` · `blankIntoColumn` · `saveScratchAsLens` · `adoptColumn` · `promoteColumn` · `writeNewTakesEverywhere` · `saveCurrentChoicesAsLens`) | bare runner | n/a | host-gated to `.lenses`; the Lenses board holds no article landing | not reachable |
| `saveNoteVersion` `:1663` (`VersionActs.save`) | copy family | no (the copy is born archived; the article is untouched) | — | not an arm |

#### Considered and cleared (traced; measured where it mattered)

- **The density doors (`× n beside` / `n high`, `TakesBoardView.swift:403/413` → `pushDensity` → the model's `beneathCount`/`gridRows` setters):** by the rule's letter a candidate (a gesture that changes bloomed rows' heights). **Measured HOLLOW in the reachable shape** (probe: margin grid, the landed row bloomed by a bloom landing — the fan-panel door's shape — `gridRows` 1 → 3): `offset 333 → 333`, `aims 47 → 47`, content +2 pt; `beneathCount` cannot change height at all (N40's fixed strip). No arm; a pin would pass on both sides. *(One number from that probe worth the walk's eye, recorded rather than raised: a bloomed margin-grid landing spent 47 of its 64 aims settling a 12-block mount — the bound has thin headroom on a heavier note; if reached, the landing ends `.done` with the row possibly a few points short of the fold, which is the SAFE failure under her complaint. No failing shape found; SPECULATIVE; not a finding.)*
- **R1-1 (`ArticlePlace.top`):** `rememberStep` remembers `.top` at `offset ≤ 0.5`, `.undecided` with `.top`/nothing remembered settles without a scroll, `restoreStep` is total over the nil row; the mounted pin remounts at 0 and the pure pin covers rest/remembered-top/scrolled. A page left between 0.5 and the 18 pt padding remembers row 1 and comes back at 18 — inside the stated promise (the sub-row place is not promised). Solid.
- **R1-2's `run` arm on a "shared road":** the rule forbids arms on methods a programmatic road shares; `run`/`runCopying` are shared plumbing, but EVERY caller is a gesture door (the table) — no programmatic road passes through them. Consistent.
- **R1-3 (the autoclosure):** `articleLandingStep(order:)` evaluates past both guards; the VM's call site passes the map lazily; while pending the `contains`/`firstIndex`/`filter` walks are O(N) per aim, bounded by 64. `consumeArticleGeometry`'s `order()` is evaluated at the `.undecided`/`.wanted` arms (per report while a restore is pending, ≤ 24 + the settle), never at `.settled` — so the steady state costs nothing in N. Solid.
- **R1-4 (the gone row) and the `loaded ? slots : nil` arm:** re-traced the sanity pass's reasoning (a landing implies `loaded`; `adopt` changes `contentSize` and republishes; the pre-projection edge settles by the bound and the next report remembers) — holds. The pure pin's nil arm states the contract. Solid.
- **R1-5/R1-6:** the hollow pin gone; `noteArticleViewport` / `articleReveal(for:)` have no occurrence anywhere under `App/` (grep). **R1-7/R1-8/R1-9:** the four docs and the fixture doc say what the code does; the face suite on its own scrubbed domain.
- **The slot-drag arm (`510a1f7c`):** `beginSlotDrag` clears on every `onChanged` tick — a same-value nil write per drag frame, measured hollow by the guard pin (`endingANothingPendingLandingWakesNoObserver`); the model's `beginSlotDrag` guard makes the baseline write once. Fine.
- **`ScrollPosition.isPositionedByUser` outliving her first scroll:** once true it stays true for the mount, so the geometry hook's user branch would end any LATER landing after its first aim — but no landing can arrive within a mount after her scroll: every `pendingTakesLanding` setter lives on another mode (`WriteTakesPanel.swift:79` · `LensesBoardView.swift:284` · `BlocksWorkbenchView.swift:940`), whose switch REMOUNTS the board (`TakesBoardView.swift:133`, per-mount `@State`; `PostDetailView.swift:350`), and the N9 arm is once per model (`landingFocusDone`, never reset). Cleared.
- **Proxy scrolls do not flip `isPositionedByUser`** — if they did, the restore would settle at its first aim and `aBoardLeftScrolledComesBackWhereSheLeftIt` could not be green. It is (this tree, 19/2).
- **Two boards on one note (a second window)** share the memory exactly as Write's `scrollAnchors` — the pre-existing class (round 1's line stands).
- **The fences:** `Sources/`, `Shared/`, `Sync/`, `BlockRangeIndex`, `EditorTextView`, `PaneTextAuthority`, the choreographer — all untouched by the fixes (diff-empty). No product invention; #102 still free; the canon note drafted at the adjudication stands.

#### Review foci (§12), addressed

- **F-0 (no god brain, no god file):** the fixes added one enum case, one autoclosure, two arms' worth of one-liners and a doc; the rule lives in `TakesBoardLayout`, performed at the one proxy. The scattering the her-hand rule implies (now ten one-line arms across the view model, twelve with R2-1's) is the one architectural cost — named in R2-1's option (b) as the shape for the 13u2 split, not demanded here. Not a god-brain finding.
- **F-1 (one decision, one view site, no second mechanism, spent once):** one decision, one proxy, one `spendArticleLanding` — unchanged by the fixes and still right. "Ended at her hand" is where round 2 finds the fixes short (R2-1): her hand is under-enumerated by three doors, measured.
- **F-2 (the empty block's face):** untouched by the fixes; the R1-9 change is the suite's domain only; the oracle and the door's inset stand as round 1 cleared them.

#### CLEAN BILL — checked and found solid

- The nine round-1 fixes, each re-read at its site with its pin: R1-1's TOP place (mounted 18 → 0 + the pure rule) · R1-2's five arms and the two pins (the model arms; the face 65 → 97 → within 2) · R1-3's autoclosure and its counter · R1-4's settle-at-once with the slots-unknown arm · R1-5's retirement · R1-6's deletions · R1-7/8's docs · R1-9's domain · the slot-drag arms.
- `revealDecision` / `revealAnchor` / the step machine / the restore machine — unchanged by the fixes; the `@ObservationIgnored` discipline on every scroll-rate sink holds; no literal number-as-rule was introduced.
- The two batch suites green on this tree in my own run (19/2); the round-1 closing counts (19/2 ×3, 262/38) are consistent with the pins present.
- Zero `Sources/` / `Shared/` / `Sync/` / schema / choreographer / `CommandRoutingTests` change across the whole batch and the ladder; no trailer lines; no history rewrite; the tree clean at `f5e86272` after the probe's deletion.

**Counts: 0 BLOCKER · 1 MAJOR · 0 MINOR · 0 NIT.** R2-1 is NEW at MAJOR (the round-1 fix for its class was incomplete — three doors, two measured), so under the ladder's rule its fixes get round 3. No fix was made; the code is untouched until the orchestrator's follow-up.

#### Implementer's responses (round 2)

*The batch-a implementer (`opus-implementer`) under the cross-model flow: agree/dispute traced against
the code at `f5e86272` in my own context — nothing implemented, no code or test file touched, no suite
run; this plan is the only file this edits. **1 AGREED · 0 DISPUTED.** The reviewer makes the final call
and implements its confirmed fix itself.*

**R2-1 (MAJOR — three height-changing board doors outside the her-hand set) — AGREE, and the
completeness claim it falsifies is partly MINE, so here is exactly how I got it wrong.** All three
sites read as the finding says: `runSplit` (`TakesStructureController.swift:260–267`) and
`turnTakesIntoBlocks` (`:676–692`) each go `model.setStatus(nil)` → `model.session.runner.run { … }`
with no `parkFocus` anywhere in the body, and `applyCallout` (`TakesViewModel.swift:1807–1815`) goes
`status = nil` → `session.runner.run { … }` — none of the three touches `run`/`runCopying`, none mints
a pane the ring migrates to, and none removes the landed row from the order, so `articleLandingStep`
finds the request still pending and re-aims. **My sanity pass's error was a generalisation from two
samples:** I checked `choose` (`:860`) and `archiveTake` (`:1299`), found both routed through
`await run { … }`, and wrote "the model's other bare-`session.runner` acts are not a hole" without
enumerating them — `applyCallout` is exactly such an act and I never looked at it. On the controller I
leaned on the PREVIOUS round's ladder, which enumerated the eight `parkFocus` sites; I read that list
as if it enumerated the controller's Operations sites, and it does not — `runSplit`,
`turnTakesIntoBlocks` and `deleteSelectedBlocks` are outside it. The table in this finding is the
artifact that list should have been, and the note-wide split is the worst case precisely because it is
a door she reached for last round (18c's U-6) on the bottom bar's note row.

**Which shape I would build: (a) NOW, and (b) at the split — and I would not merge them.** Option (a)
is the settled rule's letter, it is three lines at three sites whose bodies I have just read (each has
its own `setStatus(nil)`/`status = nil` line to sit beside, and no programmatic caller reaches them),
and it is pinnable red-on-old today — that is what a ladder round should land. My reason for not
reaching for (b) here is the one the reviewer gives and one more: `adopt` is the board's convergence
seam (it settles the authority, prunes the merge selection, re-pages a lagging reveal and consumes the
landings), so adding "a changed projection ends a pending landing" there changes the meaning of every
arrival, sync included, on the surface whose landing family has already produced one BLOCKER and two
MAJORs this round and last. That is a change to reason about with the `TakesArticleScroll` type around
it, not inside a fix pass. **But I do think (b) is the right end state and I would say so louder than
"recorded":** P-5's signal is real — three surfacings of one class (J1's keep-alive → R1-2 → the drag →
these three doors) means the enumeration is the wrong shape, and the honest framing is that (a) is the
patch and (b) is the design. One caveat for whoever builds (b): `!=` on `Queries.TakesProjection` fires
on any field of any slot, so a pure metadata arrival (a word count, a comment) would end a landing too
— which is fine under her complaint (a landing that has to survive an arrival is not a landing she is
waiting on), but it should be written down as the chosen behaviour rather than discovered.

**Nothing else raised.** The density-doors clearing reads right to me (N40's fixed strip cannot change
height, and the margin-grid measurement is the reachable shape); the 47-of-64 aims note is worth the
orchestrator's eye as the reviewer files it — SPECULATIVE, and its failure mode (`.done` with the row a
few points short) is the safe direction under her report; and `deleteSelectedBlocks`' "no traced page
move" argument matches what I know of the two anchors (a `.foot` landing's rows above going away moves
it up and leaves it on screen).

#### Reviewer's dispositions + fixes (round 2)

*The round-2 `fable-reviewer`, under the cross-model flow's follow-up authorization (the orchestrator's message; the implementer's response above: 1 agreed, 0 disputed). Final call made and the confirmed fix implemented in this session — the pins written FIRST and run on the unfixed tree (`scratchpad/red-round2.log`, then `red-round2-final.log` with the three arm files stashed: 18 tests, 6 issues — the numbers below), then the arms, then green. Two commits, path-scoped adds, no trailer lines, pushed. Nothing in `Sources/`, `App/Variorum/Shared/`, `Sync/`, `BlockRangeIndex`, `EditorTextView`, `PaneTextAuthority` or the choreographer was touched; `TakesStructureController` (inside the batch's surface) carries two of the three arms.*

- **R2-1 · CONFIRMED-FIXED · `c005a8db` (the arms + the pins) + `fbe52f21` (the rule's doc).** Option (a), the settled rule's letter: `model.clearArticleLanding()` beside `model.setStatus(nil)` in `TakesStructureController.runSplit` (the one body of the three split doors — `splitEveryNewlineIntoBlocks` · `splitFocusedBlockAtNewlines` · `splitSelectedBlocksAtNewlines`; nothing programmatic reaches it) and in `turnTakesIntoBlocks`; `board.clearArticleLanding()` beside `status = nil` in `TakesViewModel.applyCallout`. The doc at `TakesBoardLayout.clearArticleLanding` names the three arms, retires "covered by construction" for "complete by enumeration", and carries the table of every Operations road reachable from the Takes board (road · height/live-pane? · covered-by) as the completeness proof — the next arm is a table row; the density menus are recorded as deliberately not arms; option (b) (one arm in `adopt`, with the implementer's projection-equality caveat) is recorded there for the `TakesArticleScroll` split, owner 13u2, not built. **Pins (all red on old, verified by stashing the three arm files):** `herBoardGesturesEndAPendingLanding` gains three arms (model — the callout frame, the note-wide split over a block minted with a newline, takes-to-blocks over a branched block: **red on old — the landing survived all three**) · `herCalloutAboveTheLandedRowLeavesThePageWhereItIs` (mounted, 12 blocks entered on the last, a frame on row 2 through the cell menu's own call: **red on old 65 → 75**, the landing pending; green: the landing nil and the page within 2 pt) · `herNoteWideSplitEndsTheLandingAndSpendsNoAim` (mounted, eleven three-line blocks above the landed one: **red on old aims 11 → 64** — the landing burned to its whole bound; green: the landing nil, aims unchanged). The harness gained a `text:` builder (blocks with newlines); the default is byte-identical to the old fixture text.

- **What the split's face pin does NOT promise, and why — a MEASURED correction to my own finding's proposed pin ("406 → 1047 → within 2 pt").** With the arm in place the landing ended and spent no aim, yet the page still moved 406 → 1268 after the split. Two temporary probes (instrumentation in the suite, run once, removed before the commit; `scratchpad/diag-round2.log` · `diag2-round2.log`) found the second mover: **a note-wide split moves the page identically with NO landing ever set and NO proxy scroll ever issued** — a page hand-positioned at 406 (no current-block fact, aims 0) went to 1268 on the split too, the last row staying at the foot (571 → 585 in the viewport) and the offset moving by exactly the height inserted above it. That is SwiftUI's own behaviour when the lazy column's IDENTITIES change (22 rows inserted above the visible region — it keeps the bottom-anchored content), the same on both sides of this fix, and independent of R2-1; on the old tree the landing's 53 extra aims merely fought it to a slightly different rest (1047 / 1095). So the split pin promises the landing's half — ended, no aim — and records the reflow in its doc; the callout is the discriminating face pin because a frame changes no identity (the landing was the ONLY mover, 65 → 75, and the page now stays). **For the orchestrator (an observation, SPECULATIVE as to whether this batch's `.scrollPosition($articleScroll)` binding changed the pre-batch behaviour — I did not build the pre-batch tree to compare):** after a structural act that inserts rows above her block, the page keeps her block where she sees it and the rows above it change — defensible, arguably the better reflow, and not something R-Q1 rules on; if the round wants her eye, it is a one-line QUESTIONS entry, else a KnownIssues note for the 13u2 split ("what an identity change does to the article's page is the framework's, measured 2026-09-12"). Not raised as a finding: no failing-on-old pin exists for it and no ruling says which reflow is wanted.

- **A harness fact worth the next round's eye (recorded, not a finding):** the suite's `scroll(_:to:)` (an `NSClipView.scroll(to:)` + `reflectScrolledClipView`) is NOT a user scroll to SwiftUI — `ScrollPosition.isPositionedByUser` does not flip on it. Measured (probe 2): with a landing pending, that scroll to 200 was re-aimed straight back to 406 (aims 12 → 21) instead of ending the landing. The remount pin works because no landing exists there and the memory is written from the geometry report regardless; `herOwnScrollCancelsAPendingLanding` is a pure pin for the same reason. The her-hand SCROLL arm is therefore walked (captures 08/09 of the batch record), never mounted-pinned; a real scroll-wheel event is what flips the flag.

**Closing runs (tree `fbe52f21`; zero app instances by `pgrep` before each):** the two batch suites, three times — `✔ Test run with 21 tests in 2 suites passed after 14.533 seconds` · `… 21 tests in 2 suites passed after 14.618 seconds` · `… 21 tests in 2 suites passed after 14.566 seconds` (`TakesArticleScrollTests` 18 + `TakesEmptyBlockFaceTests` 3); the batch's 38-suite closing set in ONE `xcodebuild test` (the RECORD's type list as a zsh array) — **`✔ Test run with 264 tests in 38 suites passed after 122.332 seconds`** (round 1's 262 + the two new mounted pins; zero `skipped` matches in the log). Core `swift test` not re-run (`Sources/` untouched); the iOS build not owed (`Shared/` untouched).

**For the implementer's sanity pass and round 3:** the diff is `5febae9e..fbe52f21` (two commits, three files under `App/Variorum/Variorum/Features/Takes/` — `TakesStructureController` · `TakesViewModel` · `TakesBoardLayout` (doc only) — and `TakesArticleScrollTests`). Two things worth a second pair of eyes: (1) the arm's placement at `runSplit` rather than at its three doors — a split the guards refuse ("already whole") leaves a landing pending, which is the rule's letter (a refused split cannot change content height) but differs from `run`, which clears even on a refusal; (2) the split pin's promise being the landing's half only, with the framework's reflow recorded rather than asserted. Nothing here is open; no QUESTIONS entry made (the reflow observation is the orchestrator's to bundle or file); the canon note drafted at the adjudication stands.

#### Implementer's sanity pass (round 2)

*The batch-a implementer (`opus-implementer`), the cross-model flow's one sanity pass over
`git diff 5febae9e..fbe52f21` — read in my own context, no code or test file touched, no suite run.
**(1) the arm's placement is RIGHT, with a reason worth keeping. (2) NO — I do not know, and I say so
plainly; but I can name a cheaper discriminator than the pre-batch rebuild.** Nothing raised as a
defect.*

**(1) The arm at `runSplit`'s body, not at its three doors — RIGHT, and the asymmetry with `run` is
benign in both directions.** Two cases have to be separated. A split that is ENTERED and splits
nothing ("already whole") is covered: the arm sits at `TakesStructureController.swift:266`, before the
`do`, so it fires on every entry regardless of what the operation reports. What is left pending is a
DOOR-level refusal — `structuralInFlight`, no target, a failed flush — where `runSplit` is never
entered. **That is the behaviour I would choose, and not only because a refused split changes no
content height:** a door-level refusal is a gesture that did nothing and SAID so (`speak(…)`, the
refusal in the toast). Clearing the landing there would give the refusal a second, invisible
consequence — the entry reveal she is still waiting for would be cancelled by a gesture the app just
told her it would not perform. The placement keeps the refusal inert, which is what a refusal should
be. **And the asymmetry with `run` (`TakesViewModel.swift:2321`, which clears before the operation and
so clears on a refusal too) fails safe in the other direction:** over-clearing costs at most a reveal
that does not happen, where under-clearing costs a page that moves after her hand — her complaint's
own direction. Both placements are safe; they are safe differently, and that is worth the doc line so
a later reader does not "fix" the asymmetry into the unsafe direction.

**(2) Whether the pre-batch board reflowed the same way on a split — I DO NOT KNOW, and my captures
cannot answer it.** Piece 1's before/after was a three-block note in Takes on `f402ccce`, both voices,
stack, at rest: **I never performed a split, or any structural act, on the before binary** — the
question the reviewer is asking was not one the batch had at that point. The worktree and its
DerivedData are gone (`git worktree remove --force` + `rm -rf`, recorded at piece 1's close), so
answering it that way is a cold rebuild plus a walk.

**What I DO know, and it narrows the question usefully.** The batch's `.scrollPosition($articleScroll)`
(`TakesBoardView.swift:645`) is new — the pre-batch article carried a `ScrollViewReader` and nothing
else (`git show f402ccce:…/TakesBoardView.swift` has `.scrollPosition` only on the two fan STRIPS,
`:1001`/`:1055`, never on the article) — so the reviewer is right that the binding's arrival is a live
candidate and my evidence cannot rule it out. But on the tested tree **that binding issues no scroll at
all**: `articleScroll` has exactly three occurrences (`:45` the `@State`, `:645` the modifier, `:657`
the `isPositionedByUser` read) and **no `articleScroll.scrollTo` call site anywhere** — the restore's
`.scrollToRow` goes through the PROXY (`column.scrollTo`), and the `scrollTo(y:)` I originally wrote
left with the pixel memory at `a1f88379`. So the only way the binding could be the mover is by its mere
PRESENCE changing the scroll view's anchoring, not by anything the batch asks it to do.

**Which makes the cheap discriminator one line, not a rebuild:** on a scratch branch, delete
`.scrollPosition($articleScroll)` (and the `positionedByUser:` argument's source) and re-run the
reviewer's no-landing probe — if the 406 → 1268 reflow persists, the framework's identity-change
anchoring is pre-existing and the binding is exonerated; if it vanishes, the batch owns it. That
isolates the binding instead of confounding it with every other change between `f402ccce` and here,
and it is the shape I would hand the 13u2 split rather than a KnownIssues note that says "measured
2026-09-12, cause unknown". **I would not gate this round on it:** no ruling says which reflow is
wanted, the direction it moves (her block stays where she can see it) is the defensible one, and the
landing's own half is pinned.

**Nothing else raised.** The three arms read right at their sites
(`TakesStructureController.swift:266` · `:697`, `TakesViewModel.swift:1813`), each beside the status
reset and each with the mechanism in its comment; the doc's move from "covered by construction" to
"complete by enumeration" with the table is the right correction of the claim I helped get wrong; the
harness fact about `NSClipView.scroll(to:)` not flipping `isPositionedByUser` matches what I found
building the remount pin (the memory is written from the geometry report regardless, which is why that
pin works) and is worth its record.

### 17p batch a LADDER — ROUND 3 FINDINGS (fable-reviewer)

**Reviewer:** a FRESH `fable-reviewer`, cold, round 3 — THE HARD CAP — a full pass FOCUSED on round 2's fixes `git diff 5febae9e..fbe52f21` (`c005a8db` the three arms + pins · `fbe52f21` the rule's doc), read against the whole ladder `git diff 1112d4b1..fbe52f21` and the whole batch `git diff 2bfc8461..fbe52f21`, under `notes/REVIEW_PROMPT.md` verbatim, CLAUDE.md and the auto-loaded canon, this plan's §0, §3 rows 1–2, §4.1–§4.2, §5.1, §7 (R-Q1 · R-Q2), §8–§9, §12 (F-0 · F-1 · F-2), R-0, the R-1 brief · record · adjudication, `phase-17-standing-fixes.md`'s 17p row, her report, and the WHOLE ladder record above — round 1 (findings · responses · dispositions · sanity pass · final word) and round 2 (findings with its enumeration table · response · dispositions + fixes · sanity pass) — as the anchor. Tree `17803ce4` == `origin/main`, code byte-identical to `fbe52f21` (the two commits after it are notes-only); `Sources/`, `App/Variorum/Shared/`, `Sync/`, `TakesChoreographer.swift` and `CommandRoutingTests.swift` diff-empty against `2bfc8461` (verified); zero trailer lines on every batch and ladder commit (verified); zero app instances at every run. **Evidence discipline:** the three arms were re-read at their sites with every caller enumerated by grep (every caller of `runSplit`'s three doors, `turnTakesIntoBlocks` and `applyCallout` is a gesture door — a button, a menu row, a routed command; nothing programmatic reaches them; the bare `branchTake` / `newBlankTake` are reached only by the Write panel's embedded model, whose `landingEnabled` is never set); the round-2 pins were read and the two batch suites run once on this tree (`✔ Test run with 21 tests in 2 suites passed after 14.667 seconds`, `scratchpad/r3-suites.log`); and the ONE row of round 2's enumeration table that is ARGUED rather than ARMED was MEASURED through a temporary, untracked probe suite on `TakesArticleScrollTests`' own harness (`ZZReviewProbeR3Tests`, five tests incl. two no-landing CONTROLS, run twice via `-only-testing`, then deleted — the tree is clean; a copy sits in the reviewer's scratchpad; the numbers are quoted where used). No code or test file was changed; this record is the one write.

#### Findings, severity-ranked

**R3-1 · MAJOR · `App/Variorum/Variorum/Features/Takes/TakesStructureController.swift:894–946` (`deleteSelectedBlocks` — the banner's Delete and the card menu's delete-picked row, `TakesBoardView.swift:529` · `TakesShared.swift:363`, its only two callers, both gesture doors) + `TakesBoardLayout.swift:355` (the rule's table row that EXEMPTS it) · the FOURTH door in R2-1's exact class: a gesture door that changes the article's CONTENT HEIGHT through a bare runner with no focus migration and — when the landed row is not among the picks — no gone row, and no arm; the kept-alive landing RE-AIMS the page after her click. Round 2's table excused this door by argument ("a `.foot` landing's rows above going away moves it UP, still on screen … no traced page move; no arm owed") — the argument is FALSIFIED BY MEASUREMENT, and the landing was the ONLY mover.** Mechanism: a ⌘-click on a row deliberately does NOT migrate the ring (`TakesBoardView.swift:893–903`, "the claim consumes the click, so the ring does not migrate here"), so picking rows leaves the entry landing pending; `deleteSelectedBlocks` goes `setStatus(nil)` → `session.runner.run { deleteBlock… }` → `clearMergeSelection` → `speak` with no `parkFocus` and no `clearArticleLanding`; the projection re-lands, the lazy column re-realizes its rows with PLACEHOLDER frames (J1's own finding (b) — 28 pt, then 50, then measured), the landed row reads as off the fold for a pass, every row's frame report re-enters `spendArticleLanding`, `articleLandingStep` → `.reveal(.foot)` → `scrollTo(row, .bottom)` — after her click. The table's reasoning assumed the rows' frames stay honest through the delete; a lazy column's identity change is exactly when they do not. **Measured (probe, 12 blocks entered on the last — the R1-2/R2-1 face pins' shape — two rows ABOVE the landed one ⌘-picked and deleted, twice):** with the landing pending, `offset 65 → 93` (`aims` +3 the first run, +7 the second; the landing still pending after); **the no-landing CONTROL (the same delete with `clearArticleLanding()` by hand before it): `offset 65 → 65`** — the framework's own reflow moved NOTHING here (unlike the split's insertion case), so the 28 pt is the landing's alone, the callout's discriminating shape one door over (65 → 75 there). The `.head` shape (memory = row 8, the current block row 2, two rows BELOW the landed one deleted): `offset 74 → 74` but `aims 16 → 30` — fourteen aims burned fighting the placeholder passes (the 64 bound is four such deletes away, after which the landing ends `.done`, the safe direction) with the page still; its control 74 → 74, aims unchanged. Her complaint's class ("the page keeps trying to jump… and not show the text above"), one gesture after entry, on a door she reaches for (⌘-click a few blocks, Delete). **Fix (option (a), the settled rule's LETTER — the rule at `clearArticleLanding` already says "every gesture that can change the article's CONTENT HEIGHT", and this door can):** `model.clearArticleLanding()` beside `model.setStatus(nil)` in `deleteSelectedBlocks` (`:932`; the same placement as `runSplit`'s and `turnTakesIntoBlocks`', after `structuralInFlight = true`, before the `do` — nothing programmatic reaches it); the table row at `TakesBoardLayout.swift:355` becomes "ITS OWN ARM (R3-1)", so that after this fix EVERY door in the table that can change height is ARMED and the "covered by" column carries NO argued exemption (the remaining non-arms cannot change height: `moveTake`, `saveNoteVersion`, the host-gated Lenses roads, and the measured-hollow density menus). Pins (red on this tree, verified by the probe's numbers): a model arm in `herBoardGesturesEndAPendingLanding` (`landArticle(far)` · two picks · `deleteSelectedBlocks()` · `articleLanding == nil` — red: the landing survives) and ONE mounted face pin `herDeleteAboveTheLandedRowLeavesThePageWhereItIs` (the probe's shape: twelve blocks entered on the last, rows 1–2 picked and deleted — red on old `65 → 93` with aims moving; green: the landing nil, the page within 2 pt, aims unchanged — the discriminating face, since the control shows the framework moves nothing on this shape). **Recorded, not demanded (the fifth surfacing of one class — J1's keep-alive → R1-2 → the drag → R2-1's three → this):** round 2's option (b) (one arm in `adopt`) stands as the end state for the `TakesArticleScroll` split (owner 13u2); the enumeration table's first argued row was wrong at its first use, which is P-5's signal about enumeration as a shape, not about this table's care. **Under the ladder's hard cap this is NEW at MAJOR in round 3: it is fixed under the cross-model flow's follow-up (the reviewer's own fix pass + the implementer's sanity pass), and anything still open after that is RECORDED for the author, never looped on — there is no round 4.**

**R3-2 · NIT · `TakesStructureController.swift:266–272` (`runSplit`'s arm comment) · the sanity pass's asymmetry sentence is worth the one doc line it asked for.** The arm sits at `runSplit`'s BODY, so a DOOR-level refusal (`structuralInFlight` · no target · a failed flush · the note-wide door's own "already whole" check, which runs BEFORE `runSplit`) leaves a landing pending, where `run` clears even on a refusal. Both placements fail safe in opposite directions (a refused split changes no height; over-clearing costs at most a reveal that does not happen) — MEASURED at this round: the note-wide door on an already-whole note leaves the landing pending; an ENTERED split on a whole block clears it. The comment should say so, so a later reader does not "fix" the asymmetry into the unsafe direction. Doc only; no pin.

#### The round-2 sanity pass's two items — the reviewer's final word (they returned to no one; this round closes them)

- **(1) The arm at `runSplit`'s body rather than its three doors — RIGHT, adopted as the implementer reasoned:** an entered-but-whole split is covered (the arm fires before the `do`, regardless of what the operation reports); a door-level refusal is a gesture that did nothing and SAID so, and cancelling the entry reveal there would give the refusal a second, invisible consequence. The asymmetry with `run` is benign in both directions (R3-2 records it in the code).
- **(2) Whether the pre-batch board reflowed the same way on a note-wide split — UNANSWERED, and deliberately not answered here:** the implementer's one-line discriminator (delete `.scrollPosition($articleScroll)` on a scratch branch and re-run the no-landing probe) is a PRODUCTION edit, which a review round does not make even temporarily; the batch's binding issues no scroll (verified: `articleScroll` has exactly three occurrences in `TakesBoardView.swift` — the `@State`, the modifier, the `isPositionedByUser` read — and no `scrollTo` site), so only its presence could be the mover. Not a finding (no ruling names the wanted reflow; no failing-on-old pin exists; the direction it moves keeps her block where she sees it). **For the orchestrator:** a KnownIssues line for 13u2's `TakesArticleScroll` split carrying the discriminator verbatim — or a one-line QUESTIONS entry if the round wants her eye on which reflow is wanted. This round's own measurement narrows it further: the framework moves NOTHING on a two-row DELETION above the visible region (control 65 → 65) while round 2 measured 406 → 1268 on a 22-row INSERTION — so whatever anchors the page, it is not symmetric in the row count's sign.

#### Considered and cleared (traced; measured where it mattered)

- **The three round-2 arms at their sites:** `runSplit` (`:266–272`, the one body of `splitEveryNewlineIntoBlocks` `:187` · `splitFocusedBlockAtNewlines` `:213` · `splitSelectedBlocksAtNewlines` `:229`), `turnTakesIntoBlocks` (`:695–700`), `applyCallout` (`TakesViewModel.swift:1812–1817`) — each beside its status reset, before the runner, fires on entry; every caller a gesture door (the bottom bar's note row and block row, the banner's bulk door, the routed `.callout`/`.takesToBlocks` commands, the card menu's rows on ANY row, Lenses' twin doors). On the Lenses host and the Write panel's embedded model the arm writes `nil` over `nil` (no landing is ever set there — `landingEnabled` is set at exactly one site, `TakesBoardView.swift:188`), which the guard pin `endingANothingPendingLandingWakesNoObserver` shows wakes no observer. Solid.
- **The three model-pin arms (`herBoardGesturesEndAPendingLanding`):** non-vacuous by construction — the split runs over a block minted WITH a newline so `runSplit` is entered, takes-to-blocks over a branched block, the callout with an explicit target; each asserts `articleLanding == nil` after. The two mounted face pins: the callout's `before > 0`, `aims > 0`, then landing nil and `|Δ| < 2` (the landing was the only mover, as the record says); the split's promise is the landing's half only (ended, no aim) with the framework's reflow recorded, not asserted — honest, and the right pin given round 2's control measurement. The harness's `text:` builder's default is byte-identical to the old prose (the diff shows the same string moved into `proseText`).
- **The enumeration table's other rows, verified this round:** the mint doors (`branchTakeRevealed` / `newBlankTakeRevealed` → `revealTake` → `focus`; `newBlankTakeAsChosen` → `revealChosenTake` → `revealTake`/`focus`; the bare `branchTake`/`newBlankTake` reached only from `WriteTakesPanel.swift:244/254`, the embedded model) — `.migrated(from:)` for a fresh variant since `PaneTextAuthority.focus` returns `.unchanged` only for the SAME pane (`PaneTextAuthority.swift:88–93`); the ceremony doors (`runDivideW` · `runDivideDuplicating`, `TakesViewModel.swift:2403–2469`) BOTH `parkFocus` on the second successor's rendered take as well as releasing A — doubly covered; the `parkFocus` doors end their landing SYNCHRONOUSLY inside `adopt` (`adopt` → `consumeLandings` → `focus` → `.migrated` → `clearArticleLanding`, all in one main-actor call before any layout pass re-realizes a row) — so "by construction" holds for THAT set for a stated reason, unlike the argued row R3-1 falsifies; `run`/`runCopying` callers all gesture doors (round 2's verification stands; `reorderBlock` spot-checked). `deleteSelectedBlocks` was the ONLY argued exemption in the table.
- **The `.head` shape's fourteen aims (probe B):** the page did not move (74 → 74) — the aims were `scrollTo(row2, .top)` against a row already at the head, idempotent; recorded as the budget-burn half of R3-1, not a second finding.
- **F-1's "spent exactly once" across mounts:** unchanged by the fixes — the landing dies with the model; `landingFocusDone` is once per model; every `pendingTakesLanding` setter lives on another mode whose switch remounts the board (round 2's line stands).
- **The fences:** `Sources/`, `Shared/`, `Sync/`, `BlockRangeIndex`, `EditorTextView`, `PaneTextAuthority`, the choreographer — untouched by round 2's fixes and by the whole ladder (diff-empty). No product invention; #102 still free; the canon note drafted at the adjudication stands. The 17p register row (`phase-17-standing-fixes.md:95`) names batch a's scope exactly as built.

#### Review foci (§12), addressed

- **F-0 (no god brain, no god file):** round 2 added three one-line arms and a doc table; the rule still lives in ONE type (`TakesBoardLayout`) and is performed at ONE proxy. The cost the focus names is now visible in the table itself: an enumeration that carried one ARGUED row beside its ARMED rows, and the argued row was wrong — after R3-1's fix every height-changing door is armed and no argument stands in for an arm. The structural end state (one arm in `adopt`, option (b)) stays recorded for 13u2, not built here. Not a god-brain finding.
- **F-1 (one decision, one view site, no second scroll mechanism, spent once):** one decision, one proxy, one `spendArticleLanding` — unchanged. "Ended at her hand" is where round 3 finds round 2's fix short by one door (R3-1, measured: the landing alone moved the page 28 pt after her Delete).
- **F-2 (the empty block's face):** untouched by rounds 1–2's fixes; the overlay stays gone, the oracle and the door's inset stand as round 1 cleared them.

#### CLEAN BILL — checked and found solid

- The three R2-1 arms and their five pin arms/faces, each re-read at its site with every caller enumerated; the two batch suites green on this tree in my own run (21/2), consistent with round 2's closing counts (21/2 ×3, 264/38).
- The rule's doc at `clearArticleLanding` says what the code does for every row but the one R3-1 corrects; the "by construction" retirement for "by enumeration" was the right correction, and the `parkFocus` set's coverage holds for a reason this record now states (synchronous clear inside `adopt`).
- `revealDecision` / `revealAnchor` / the landing step machine / the restore machine — unchanged by round 2; the `@ObservationIgnored` discipline on every scroll-rate sink holds; no literal number-as-rule introduced; nothing in the round-2 diff touches the geometry hook, the row-frame sinks or the proxy.
- The sanity pass's item (1) closed as RIGHT; item (2) closed as not-a-finding with the discriminator handed forward.
- Zero `Sources/` / `Shared/` / `Sync/` / schema / choreographer / `CommandRoutingTests` change across the whole batch and the ladder; no trailer lines on any of the eighteen commits since `2bfc8461`; no history rewrite; the tree clean at `17803ce4` after the probe's deletion.

**Counts: 0 BLOCKER · 1 MAJOR · 0 MINOR · 1 NIT.** R3-1 is NEW at MAJOR in round 3 — the hard cap: its fix lands under this round's cross-model follow-up (the reviewer's fix pass with its red-on-old pins, the implementer's one sanity pass), and whatever remains open after that is recorded for the author, never looped on. No fix was made; the code is untouched until the orchestrator's follow-up.

#### Implementer's responses (round 3)

*The batch-a implementer (`opus-implementer`) under the cross-model flow: traced against the code at
`17803ce4` in my own context — nothing implemented, no code or test file touched, no suite run; this
plan is the only file this edits. **2 AGREED · 0 DISPUTED.***

**R3-1 (MAJOR — `deleteSelectedBlocks` is the fourth door) — AGREE, and the ⌘-click's no-migration is
DELIBERATE exactly as the reviewer reads it.** I built beside that line: `onCommandClick` at
`TakesBoardView.swift:893–903` carries its own reason in the code — *"the claim consumes the click, so
the ring does not migrate here — picking blocks is not writing in one"* (13e E3, her A18) — and the
claim's return of `true` is what consumes the mouse-down before `PaneSurface`'s selection tracking
runs, so the ring genuinely stays where it was. **That is the whole reason this door is in the class:**
every other height-changing road either mints a pane the ring moves to or removes the landed row, and
this one is the only gesture in the board's vocabulary whose *design intent* is to leave the ring — and
therefore a pending landing — untouched while changing what is above it. The door itself reads as
traced: `TakesStructureController.swift:930–932` is `structuralInFlight = true` → `setStatus(nil)` →
the compound through a bare `model.session.runner.run`, with `clearMergeSelection` and `speak` after
and **no `parkFocus` anywhere in the body** (`:925–946`). The two callers are gesture doors
(`TakesBoardView.swift:529` the banner, `TakesShared.swift:363` the card row). **And I accept the
falsification of round 2's table row without reservation** — it was argued from "the frames stay
honest through the delete", and J1's own measurement (b) (placeholder frames, 28 → 50 → measured, one
pass each) says a lazy column's identity change is precisely when they do not; the no-landing control
at 65 → 65 makes the 28 pt the landing's alone, which is the cleanest attribution in the whole ladder.
The arm at `:932`, beside the status reset and before the `do`, matches `runSplit`'s and
`turnTakesIntoBlocks`' placement, and with the table row armed the "complete by enumeration" claim
finally has no argued exemption left in it.

**R3-2 (NIT — `runSplit`'s arm comment should carry the asymmetry) — AGREE.** It is the sentence my
round-2 sanity pass asked for and the right place for it: the arm is at the body
(`TakesStructureController.swift:266`), so a door-level refusal leaves the landing pending while `run`
(`TakesViewModel.swift:2321`) clears even on a refusal, and both fail safe in OPPOSITE directions. The
one addition I would make to the wording: say which way is unsafe, not just that they differ —
over-clearing costs at most a reveal that does not happen; under-clearing costs a page that moves after
her hand, which is her complaint's own direction. A reader who knows that cannot "tidy" the asymmetry
the wrong way.

**Nothing else raised, and one note on the shape rather than the code.** This is the class's fifth
surfacing and the second time an ENUMERATED exemption was wrong at its first use — which is exactly
P-5's signal, and it strengthens what I said at round 2: option (a) is the patch, option (b) (one arm
in `adopt`) is the design, and the `TakesArticleScroll` split (owner 13u2) should build it rather than
inherit a table that has now been corrected twice. I would not reopen it here; the hard cap is the
right place to stop enumerating.

#### Reviewer's dispositions + fixes (round 3)

*The round-3 `fable-reviewer`, under the cross-model flow's follow-up authorization (the orchestrator's message; the implementer's responses above: 2 agreed, 0 disputed). Final calls made and the confirmed fixes implemented in this session — the pins written FIRST and run on the unfixed tree by behavioral revert (the numbers below; `scratchpad/red-round3.log` · `red-round3b.log`), then the arms, then green. Three commits, path-scoped adds, no trailer lines, pushed after each: `5a84b7c3` (the arms + the pins) · `88d71ab0` (the rule's doc) · `e78bc896` (R3-2). Nothing in `Sources/`, `App/Variorum/Shared/`, `Sync/`, `BlockRangeIndex`, `EditorTextView`, `PaneTextAuthority` or the choreographer was touched (diff-empty against `2bfc8461`, verified). The temporary probe suite (`ZZReviewProbeR3Tests`, untracked, seven probes over the fix pass) is deleted; the tree is clean; a copy sits in the reviewer's scratchpad.*

- **R3-1 · CONFIRMED-FIXED · `5a84b7c3` + `88d71ab0` — WITH A MEASURED CORRECTION TO MY OWN FINDING'S ATTRIBUTION, recorded here because the class and the severity stand while the trigger and the mechanism do not.** The findings record above said the landing alone moved the page 65 → 93 "after her Delete" and named placeholder frames after the identity change as the mechanism. The fix pass falsified the trigger: with the delete arm in place and the pins written, `herPickAndDelete…` was STILL red (65 → 93, aims moving), and a step-wise probe located the mover — **ONE ⌘-click PICK, before any delete: `offset 65 → 93` within six turns, nine more aims, and it stays there for sixty more; the delete afterwards moves nothing** (its own no-landing control 65 → 65 stands; my round-3 control had cleared the landing BEFORE the picks, so it could not separate the two). The mechanism, read then measured: `mergeSelectionBanner` is composed ABOVE `singleColumnArticle` in the board's VStack (`TakesBoardView.swift:161–162`) and renders only while a selection exists, so a pick summons a banner row that SHRINKS THE ARTICLE'S VIEWPORT by its height — **measured 619 → 591, the 28 pt exactly** — the landed row at the foot (571–617 in 619, at rest from turn 6 through 72 with no gesture) now reads as clipped, and the kept-alive landing reveals it again after her click. A ⌘-click deliberately never migrates the ring (`onCommandClick`, `TakesBoardView.swift:893–903` — "picking blocks is not writing in one", 13e E3, as the implementer confirmed), which is why nothing else ended it. **This is a THIRD mechanism the rule never named — the article's VIEWPORT HEIGHT, chrome appearing above it — beside content height and the live pane; and it falsifies round 1's final-word dismissal of "the merge pick (a stroke overlay; no layout effect)": true of the CELL's rendering (`.overlay { stroke }` at `:914–919`), blind to the BANNER.** The fix, the rule's letter extended by the measured mechanism: `board.clearArticleLanding()` at the two PICK doors — `TakesViewModel.toggleMergeSelection` / `extendMergeSelection` (`:1254–1264`; their only callers are the ⌘-click handler's two shades) — AND at `TakesStructureController.deleteSelectedBlocks` beside `model.setStatus(nil)` (`:932`; the letter — rows removed through a bare runner with no `parkFocus`, armed at the door even though the pick before it has already ended the landing; both callers gesture doors). `clearMergeSelection` is deliberately NOT an arm — it is the shared road (the banner's "clear" AND the controller's post-act clears after a merge, a split or a delete), and a banner LEAVING grows the viewport, which can clip nothing — so round 1's placement half survives intact. The rule's doc at `clearArticleLanding` (`88d71ab0`): the mechanism sentence names the viewport; the arms list gains the three doors; the table gains the pick row and re-words the delete row (round 2's argued exemption retired — the delete armed by the letter, the pick the measured mover); "the merge pick" leaves the deliberately-not-arms paragraph with the reason it was wrong there; **no row in the table is argued any more — every door that can change content or viewport height is ARMED.** **Pins (all red on old, by behavioral revert on the tree without the arms):** `herBoardGesturesEndAPendingLanding` gains three arms — the pick (`toggleMergeSelection`), the extend (`extendMergeSelection`), the delete — **red on old: the landing survived the two pick doors** (`…09` where nil is owed; the delete arm's own red was recorded on the first run, before the pick doors were found) · `herPickAboveTheLandedRowLeavesThePageWhereItIs` (mounted, 12 blocks entered on the last, ONE pick on row 1 — **red on old: the landing pending, `|Δ| = 28.0` (65 → 93), aims 9 → 12**; green: the landing nil, the page within 2 pt, aims unchanged; the pin ALSO asserts the viewport shrank, so the MECHANISM is pinned, not only the outcome) · `herPickAndDeleteAboveTheLandedRowLeavesThePageWhereItIs` (the whole road — two picks, then the banner's Delete — **red on old: `|Δ| = 28.0`, aims 5 → 8**; green: landing nil, page at rest across the road, aims unchanged). The pins' 12-turn `before` is an honest rest: the timeline probe shows the reveal settled at turn 6 and unmoved through turn 72, so round 1's and round 2's face numbers (65 → 97, 65 → 75) were read at rest too.
- **R3-2 · CONFIRMED-FIXED · `e78bc896`.** `runSplit`'s arm comment carries the asymmetry WITH its direction, the implementer's wording adopted: a door-level refusal leaves a pending landing alone where `run` clears even on a refusal; both fail safe in opposite directions; over-clearing (a reveal that does not happen) is the only safe way to move, under-clearing (a page that moves after her hand) is her complaint's own direction; a refusal is a gesture that did nothing and said so, and must not gain a second, invisible consequence. Doc only; measured at this round (the note-wide door on an already-whole note leaves the landing pending; an entered split on a whole block clears it) — no pin owed.

**Closing runs (tree `e78bc896`; zero app instances by `pgrep` before each):** the two batch suites, three times — `✔ Test run with 23 tests in 2 suites passed after 18.557 seconds` · `… 23 tests in 2 suites passed after 18.457 seconds` · `… 23 tests in 2 suites passed after 18.439 seconds` (`TakesArticleScrollTests` 20 + `TakesEmptyBlockFaceTests` 3); the batch's 38-suite closing set in ONE `xcodebuild test` (the RECORD's type list as a zsh array, 38 names) — **`✔ Test run with 266 tests in 38 suites passed after 125.976 seconds`** (round 2's 264 + the two new mounted face pins; zero `skipped` matches in the log). Core `swift test` not re-run (`Sources/` untouched throughout the batch and the ladder); the iOS build not owed (`Shared/` untouched).

**For the implementer's one sanity pass (the cross-model flow's last step; nothing loops after it):** the diff is `8e1fd59c..e78bc896` (three commits, three files under `App/Variorum/Variorum/Features/Takes/` — `TakesViewModel` (the two pick arms) · `TakesStructureController` (the delete arm; R3-2's comment) · `TakesBoardLayout` (doc only) — and `TakesArticleScrollTests`). Worth its eyes: (1) the pick arms are on the view model's forwarders, not the layout's `toggleMergeSelection`/`extendMergeSelection` — the layout's are reached by `pruneMergeSelection`-class programmatic roads too, so the placement follows the settled rule (gesture doors, never a shared method); (2) `extendMergeSelection` from the banner-less state (the first ⌘⇧-click with no anchor) also summons the banner, so its arm is not redundant with the toggle's.

**The ladder's residue** (the hard cap — stated for the author; nothing here loops):

1. **The reflow observation (round 2's, unanswered as to cause):** a note-wide split that inserts rows above the visible region moves the page by exactly the inserted height with NO landing pending (406 → 1268), while a two-row DELETION above the fold moves it not at all (65 → 65, round 3's control) — the framework's own anchoring on a lazy column's identity change, asymmetric in the row count's sign; whether the batch's `.scrollPosition($articleScroll)` binding (present, issuing no scroll) changed the pre-batch behaviour is UNKNOWN. The implementer's one-line discriminator (delete the modifier on a scratch branch and re-run the no-landing split probe) is handed to **13u2's `TakesArticleScroll` split** as a KnownIssues line, or to QUESTIONS if the round wants her eye on which reflow is wanted (her block staying where she sees it is the defensible direction; no ruling names one). Not open as a defect.
2. **The `TakesArticleScroll` split's design (owner 13u2, R1-6 + round 2's option (b)) — WITH A CORRECTION FROM THIS ROUND:** option (b) as recorded ("one arm in `adopt` — a projection that arrives while a landing is pending and differs ends it") would NOT have caught R3-1: the banner is CHROME, not a projection arrival, and the viewport shrank with the projection byte-unchanged. The end state must therefore cover THREE mechanisms — content height (the `adopt` arm, (b)), viewport height (a geometry-hook rule: a viewport-height change arriving AFTER the landing has once judged its row on screen ends it — the restore beside it already reads the viewport from the same hook), and the live pane (`focus`'s `.migrated`, as today) — and the door-by-door arms retire only when all three seams exist. This is the fifth surfacing of the class and the third mechanism; the enumeration table is complete today (no argued row) and stays the checkable record until the split.
3. **R-Q1's observation (J3), unchanged:** on a LONG note whose current block is far from where she left the page, the restore puts her back and the entry landing then reveals the current block once more; on the two- and three-block notes she reported nothing moves. One condition if she wants the restore to suppress the entry landing — hers to say.
4. **KnownIssues, for 17p's close:** the R1-7 row's tutorial-spine instance (J1 — its Takes lessons write `takesViewMemory` for the lesson post into the shared domain) stays as recorded; the `TakesArticleScroll` split row (R1-6) gains items 1 and 2 above.
5. **Open defects after this round: NONE.** R3-1 and R3-2 are fixed and pinned; every round-1 and round-2 fix re-verified; the batch's rows 1 and 2 stand FIXED with their pins; the suites green (23/2 ×3, 266/38). Whatever the implementer's sanity pass raises is recorded beside this paragraph for the author, never fixed in a fourth round.

#### Implementer's sanity pass (round 3)

*The batch-a implementer (`opus-implementer`), the ladder's last sanity pass, over
`git diff 8e1fd59c..e78bc896` — read in my own context, no code or test file touched, no suite run.
**(1) the placement is RIGHT, with the stated reason corrected. (2) the extend arm is NOT redundant —
measured in the code: ⇧-click reaches `extendMergeSelection` with no toggle first, and the arm is the
only thing covering that road.** Nothing raised as a defect.*

**(1) The pick arms on the view model's forwarders — RIGHT, and the reason is a better one than the
note gives.** Checked by grep: the layout's selection methods have exactly four direct callers, all in
`TakesViewModel` — `pruneMergeSelection` (`:452`, from `adopt`) · `toggleMergeSelection` (`:1265`) ·
`extendMergeSelection` (`:1274`) · `clearMergeSelection` (`:1278`). So the *programmatic* road is
`pruneMergeSelection`, a DIFFERENT method; the layout's `toggleMergeSelection` /
`extendMergeSelection` are reached only through these forwarders, and an arm on the layout's own two
methods would in fact have been safe. **The placement is still the right one for two reasons that
survive that correction:** the forwarder is where the batch's other her-hand arms already live (the
three expansion doors, `run` / `runCopying`, `paneEdited`, `focus`'s `.migrated`), so the whole set
reads in one place instead of straddling the two types; and putting landing policy INSIDE the component
that owns the landing state is what `bloom` deliberately avoids — the choreographer's bloom arm calls
`board.bloom` *before* `landArticle`, so a layout-side arm there would cancel the landing the
choreographer is about to set. Keeping every arm on the model keeps that hazard in one type's view.
**And `clearMergeSelection` staying un-armed is right:** the structure controller calls it after a
merge, a split and a delete (`TakesStructureController.swift:951` and its siblings), each of which
already has its own arm, and a banner LEAVING gives the viewport 28 pt BACK — it can clip nothing.

**(2) NOT redundant — ⇧-click can be the FIRST pick, and then `extendMergeSelection` is the only road.**
`BlockSelection.extend` (`App/Variorum/Variorum/Registry/BlockSelection.swift:77–89`) falls through to
**`toggle(blockID)` when there is no anchor**, and the view's chord router sends a ⌘⇧-click straight
there (`TakesBoardView.swift:896–903`: `if extending { model.extendMergeSelection(to:) } else {
model.toggleMergeSelection(…) }` — no toggle on the extending branch). So on a board with nothing
picked, a ⌘⇧-click summons the banner — the 28 pt viewport shrink — through `extendMergeSelection`
alone, and without its arm R3-1's mechanism would survive on that one gesture. The same `else` branch
also fires when the anchor or the target is missing from `order` (a stale anchor after `pruneMergeSelection`
or a sync arrival), which is a second road to a banner-from-empty. Both arms are load-bearing; neither
is a belt on the other's braces.

**Nothing else raised, and the trigger's correction is the honest one.** I own the falsified half: my
round-1 sanity pass cleared the merge pick as "a stroke overlay with no layout effect" — true of the
overlay (`washedCell`'s `RoundedRectangle` stroke) and irrelevant, because the mover is the BANNER
above the article in the board's `VStack` (`TakesBoardView.swift:161–162`), a third seam — the
article's VIEWPORT height — that the rule named nowhere and that I did not think to look for. The
doc's three seams (content height · the live pane · the viewport) are the right generalisation, and
R3-2's comment now says which direction is unsafe to tidy toward, which was the point. With the
ladder's cap here, option (b) (one arm in `adopt`) stands as the design for the `TakesArticleScroll`
split, owner 13u2 — the recurrence count is now six, and a seam nobody enumerated is exactly what a
structural arm would have covered for free.

### 17p batch a LADDER — CLOSED (the orchestrator, 2026-09-12, at `cbddd4d0`; the hard cap reached)

Three rounds, one letter-half, over `2bfc8461..e78bc896`. **Round 1** (fable-reviewer, cross-model): 0 BLOCKER · 3 MAJOR · 3 MINOR · 3 NIT — all nine confirmed and fixed (`d5ac3785`…`839342a3`); the sanity pass raised the slot-height drag (fixed `510a1f7c`); the her-hand rule written at `TakesBoardLayout.clearArticleLanding`. **Round 2** (fresh): 1 MAJOR — three bare-runner doors (`runSplit` · `turnTakesIntoBlocks` · `applyCallout`) outside the rule, "by construction" falsified by a full road table; fixed `c005a8db` + `fbe52f21`. **Round 3** (fresh, the cap): 1 MAJOR · 1 NIT — the ⌘-click PICK (its banner shrinks the article's VIEWPORT by 28 pt; a third seam beside content height and the live pane) and the banner's delete, fixed `5a84b7c3` + `88d71ab0`; R3-2 `e78bc896`. Every fix red-on-old by behavioral revert; every sanity pass CLEAR at its end. **Finals on `e78bc896`:** the two batch suites 23/2 ×3; the 38-suite closing set **266/38 green**; core and iOS not owed (`Sources/`, `Shared/`, `Sync/`, the seam files and the choreographer untouched across batch and ladder; no trailers on any commit). **Open defects: none.**

**Residue, recorded for the author and the owners (nothing loops):**
1. **The recurrence signal (P-5).** The kept-alive landing's her-hand set surfaced SIX times across the ladder (J1's keep-alive → R1-2 → the slot drag → R2-1's three doors → R3-1's pick → the banner's delete), and twice an ENUMERATED exemption was wrong at first use. The rule now stands "complete by enumeration" with the road table as its proof and NO argued row — but the design both agents recommend is **option (b): one structural arm at `adopt` covering all three seams (content height · viewport height · the live pane)**, built INSIDE the `TakesArticleScroll` split (owner **13u2**, named at R1-6), with the implementer's caveat written down as chosen behaviour: `!=` on `Queries.TakesProjection` fires on any field, so a pure metadata arrival would end a landing too.
2. **The reflow discriminator (SPECULATIVE, to 13u2):** a note-wide split moves the page identically with NO landing at all (406 → 1268 — SwiftUI keeping bottom-anchored content when 22 rows are inserted above); whether the batch's new `.scrollPosition($articleScroll)` binding (present but issuing no scroll) changed pre-batch behaviour is unknown — the one-line discriminator is deleting the modifier on a scratch branch and re-running the no-landing probe. Not gated: no ruling says which reflow is wanted and the direction (her block stays where she sees it) is the defensible one.
3. **J3** — R-Q1's restore-then-reveal on a long note, as ruled; hers if she wants the one condition.
4. **KnownIssues at 17p's close:** the R1-7 row gains the tutorial-spine instance (its Takes lessons write `takesViewMemory` for the lesson post into the shared domain); a 13u2 row for items 1–2 above.

---
### R-2 · 17p batch b — BRIEF (THE CHROME SINGLES: the tray's block rows gain Delete Now; the Callout Emoji alert's field; the comment badge and the callout emoji never cover text — a left lane in the book Outline, the emoji inside the frame) — written by the orchestrator 2026-09-12, pointers verified against `8eaeeb3d` (re-grep after batch a)

**Spawn:** `opus-implementer`. **Review after:** `opus-reviewer` (chrome + decor; no seam, no defaults — the reviewer re-spawns as Fable if it judges the decor's inset change reaches the seam). **One acceptance unit:** the chrome singles — three independent rows on three surfaces, each small; ONE session because each is a few lines and the walk is one sitting. **Rows:** ledger 3 · 4 · 5 · 6. **Her rulings (§7, SETTLED):** R-Q3 (Delete Now on block rows; stranded originals stay without) and R-Q4 (a left lane; the emoji inside the frame; comments stay left).

**Read first, yourself:** `CLAUDE.md` + canon (AppSpec §12's comments/callouts lines — R7 margin comments, R16/R17/R27 callouts, R9 sacred margins; TEXTKIT2_NOTES §3 — overlays never rendering attributes; the iOS paragraph-style road for reserved room, never `exclusionPaths`); this plan's §1 (Q-3, Q-4), §3 rows 3–6, §4.3–§4.4, §7, §8–§9, R-0; batch a's RECORD (R-1) for what moved on the tree; `notes/plans/phase-17-standing-fixes.md`'s rules.

**Pointers (verified; re-grep):**
- **Row 3 — the tray:** `App/Variorum/Variorum/Features/Tray/TrayPanel.swift` — block rows `cellRows` `:937–960` → `row(...)` `:1112–1155` (Put back only); the take rows' Delete Now `:1060–1067` → `TrayViewModel.requestDeleteNowTake` `:620` → `TrashPurge.deleteNowConfirm(for: trashItem(for:))` → `confirmPendingPurge` `:638`; `trashItem(for:)` `:654` builds a `Queries.TrashItem` for a take — build the block's the same way (`kind: .block`; the Library's Trash row for a block is the model: `RecoveryView.swift:896–903`, `requestDeleteNow` `:400`); the panel's registry doors `TrayPanel.surfaceCapabilities` `:727` already declare `.deleteNow`; the explainer `App/Variorum/Shared/RecoveryCopy.swift:282` stays TRUE once the door exists (do not touch Shared/). Stranded originals (`rows.stranded`, `:980–996`) get NO door (the Trash's own rule `RecoveryView.swift:893`). Pins: `NoteTrayTests` / `TrayPanelShapeTests` — a leaving BLOCK row renders the Delete Now door (an oracle of the `TakesEmptyStateDoors` shape, or the registry walk's per-surface pin); the confirm asks every time; the purge lands (the take's existing pin as the template, `kind: .block`). Red on old: the door absent.
- **Row 4 — the alert:** `App/Variorum/Variorum/Features/Editor/CalloutMenu.swift:183–204` (`emojiAccessory`: `NSStackView` of an editable `NSTextField(frame: 200×24)` + a small button; the frame is ignored by the stack; an empty editable field's intrinsic width ≈ 0). Fix: `field.widthAnchor.constraint(greaterThanOrEqualToConstant: 200)` (+ `setContentHuggingPriority(.defaultLow, for: .horizontal)`), or lay the accessory out by hand with `translatesAutoresizingMaskIntoConstraints` — your call, the pin decides. Pin (`DoorSetTests` beside `:327`): build the accessory, `layoutSubtreeIfNeeded()` inside a window, assert the field's width ≥ 150 (red on old — measure and record the old number).
- **Rows 5–6 — the lane:** the decor places the badge at `x = max(2, textLeft − 36)` (`BlockDecor.swift:585–593`) and the emoji at `x = max(2, textLeft − width − 8)` (`:476–480`); `textLeft` = the text container's origin (`EditorViewModel.swift:3162`); the book Outline's inline editor sets `textContainerInset = (EditorTypography.inlineSurfaceInset, …)` (`EditorTextView.makeInlineEditor`, `:853–856`; `InlineEditorSurface` at `EditorView.swift:472–484`); the full editor's gutter floor is `EditorTypography.minGutter` = 28 (`:171`) and its inset is dynamic (`updateGutters`, `:525`). **The rule (R-Q4):** (a) the inline editor's LEFT inset grows by a LANE (`EditorTypography.commentLane`, one constant, ≈ 40 pt — the badge's 32 + air) whenever the note carries a comment or a callout emoji (the surface knows — `commentsByBlock` / `presentationsByBlock` on the model; a pure decision `EditorTypography.inlineInset(needsLane:)`), so the badge's existing rule lands in the lane; the RIGHT inset is untouched (the measure narrows by the lane; that is the point — sacred margins); (b) the EMOJI moves INSIDE the callout frame: `BlockDecor.calloutRect` (`:167–178`) grows a leading inset for the glyph when the presentation carries one, and the block's paragraph gets `firstLineHeadIndent`/`headIndent` room for it through the ONE presentation-style road the editor already uses for callouts (find where a callout block's paragraph style is applied — grep `calloutKind` in `EditorDocument`/`EditorSurfaceController`; the iOS-proven road: `tailIndent`/`firstLineHeadIndent`, TEXTKIT2 §3; NEVER `exclusionPaths`); the emoji label's origin becomes frame-relative (inside its top-leading corner), the same in Write and the Outline, so the two surfaces cannot disagree. Pins (red on old): in a mounted inline surface with a commented callout carrying an emoji, the badge rect and the emoji rect are DISJOINT from the block's text rect and from each other (`BlockDecor` geometry through the existing decor-state oracle); Write's placement unchanged for a plain comment (a parity pin: the margin card's rect byte-identical before/after when the gutter fits cards).

**What you do NOT do:** no `Shared/` edits (the explainer stays); no change to `BlockRangeIndex`/`EditorTextView`'s seam or the identity machinery; no rendering attributes; no `exclusionPaths`; no product invention — the lane's WIDTH and the emoji's inset are the batch's numbers, recorded; anything else → QUESTIONS #102+ PROVISIONAL.

**The rules you work under:** identical to R-1's rules 1–8 (the checkpoint protocol; one surface; pin before fix; the acceptance gate is USE; no invention; no trailers; the environment traps; close honestly) — read them there and follow them verbatim. **The walk:** on the dev-store Debug build — the tray (a note with a deleted block and a deleted take: both rows show Delete Now; a stranded original does not; the confirm asks); the Callout Emoji alert (the field wide, typing lands, the picker opens); a book whose note has a commented callout with an emoji in Outline (the badge in the lane, the emoji in the frame, the text untouched) and the same note in Write (the margin card as before). Captures under `notes/plans/use-report-2026-09-12-screens/17p-b/`; both voices.

### R-2 · RECORD (the implementer writes here from its first commit)

**LIVE STATUS — 17p batch b (`opus-implementer`, opened 2026-09-12 at `48f54268`).**

**WHAT I HAVE NOT DONE (the record's first line).** At this commit: nothing but the orientation and
this record. Deliberately NOT in scope, by the brief and held for the whole batch: `Sources/`
(core — zero lines), `Sync/`, schema, `App/Variorum/Shared/` (the tray explainer STAYS — it becomes
true once the door exists), `BlockRangeIndex`, `EditorTextView`'s seam and the identity machinery,
rendering attributes, `exclusionPaths`, `TakesEmptyStateView`, the Takes board (batch a's surface).
Stranded originals get NO Delete Now door (R-Q3's letter).

- **Orientation — DONE.** Read in my own context, in the brief's order: `CLAUDE.md` and the canon it
  auto-loads (CoreDescription · OverallModel · AppSpec — §12's comments/callouts lines (R7 margin
  comments, R16/R17/R27 callouts, R9 sacred margins) and §9's tray/purge ops · SyncSpec ·
  TEXTKIT2_NOTES — §3's overlays-never-rendering-attributes rule and the iOS paragraph-style/
  `exclusionPaths` finding, §4's defensive practices); this plan's §1 (Q-3 · Q-4), §3 rows 3–6,
  §4.3–§4.4, §7 (R-Q3 · R-Q4 — SETTLED), §8, §9, §12 (F-0 · F-3 · F-4), R-0 (P-1…P-9 + the
  application notes), R-1's BRIEF + RECORD + the orchestrator's adjudication + the three ladder
  rounds' findings and the LADDER — CLOSED residue (the her-hand rule's story: a rule stands
  "complete by enumeration" with a road table as its proof, and an ENUMERATED exemption was wrong
  twice at first use); `notes/plans/phase-17-standing-fixes.md`'s philosophy, standing rules and the
  17p row; `notes/SessionResiliencyProtocol.md`'s implementer half; `notes/QUESTIONS.md`'s tail
  (**#102 is free**). Then the code behind every row — `TrayPanel` (`cellRows` · `row(...)` ·
  `takeRow` · `TrayViewModel`'s purge doors · `surfaceCapabilities` · the confirm host) ·
  `TrayFilter` · `RecoveryView`'s block Delete Now + the stranded rule · `TrashPurge` ·
  `Queries.TrashItem`/`TrayItem`/`TrayTake` · `CalloutMenu.emojiAccessory` + `promptEmoji` ·
  `BlockDecor` (`calloutRect` · `renderCallouts` · `renderComments` · `leftCardRect` ·
  `gutterFitsCards`) · `EditorTypography`'s margins · `EditorTextView.makeInlineEditor`/
  `updateGutters` · `InlineEditorSurface` + its coordinator · `EditorViewModel.refreshDecorations`
  and the decor state's `textLeft`/`textRight` · the pins that ride (`TrayPanelMoveTests` ·
  `TrayPanelShapeTests` · `NoteTrayTests` · `DoorSetTests`/`CalloutEmojiPickerTests` ·
  `BlockDecorGeometryTests` · `MarginHoverCommentTests`' sweep pin). Tree clean at `48f54268`,
  `main` == `origin/main`. **Zero app instances** (`pgrep -fl 'Variorum.app/Contents/MacOS'` empty —
  her real-store app is quit for the night; every walk is on `io.lduarte.Variorum.debug`).

**Pieces (checkpoint order):**

1. **row 3 — the tray's block rows gain Delete Now** — **DONE (`e394ac76`)**, red-on-old measured
2. **row 4 — the Callout Emoji alert's collapsed field** — **DONE (this commit)**, red-on-old
   measured on the PRE-FIX code (no revert needed — the pin was written and run first)
3. **rows 5–6 — the decoration lane + the emoji inside the frame** — **DONE (`5712779e`)**,
   red-on-old measured
4. **the walk + captures + the closing suites** — **DONE (this commit).** All four rows walked green
   in USE, both voices, 18 captures. **The walk FOUND TWO DEFECTS in piece 3 — W-1 (`6c094a21`) and
   W-2 (`60766652`), both fixed and pinned.** Closing run: **`✔ 426 tests in 57 suites`**

**Rows:** 3 · 4 · 5 · 6 — dispositions PENDING.

**No revert is in flight.** FOUR ran across this batch — row 3's two (from `e394ac76`) and rows
5–6's one (from `5712779e`) — each announced in this record BEFORE it started, each restored by
`git checkout --` of a COMMITTED file (never a scratchpad copy), and after each the tree was verified
diff-clean against its commit and the suite re-run green.

---

#### PIECE 1 — ROW 3: DELETE NOW ON THE TRAY'S BLOCK ROWS (her ruling R-Q3)

**THE MECHANISM, TRACED MYSELF (by reading, then pinned).** `TrayPanel.cellRows` renders the leaving
BLOCK rows through `row(...)`, whose trailing `HStack` ended with exactly ONE button —
`Button(TrayPath.putBackVerb)`. Only `takeRow` carried a second (`RecoveryCopy.deleteNowVerb` → 
`TrayViewModel.requestDeleteNowTake` → `TrashPurge.deleteNowConfirm(for: trashItem(for: take))` →
`confirmPendingPurge`). Directly ABOVE those rows the panel renders `explainerLine` =
`RecoveryCopy.trayLeavingExplainer(home)` — *"Everything this note has on the 30-day clock. Put back
keeps a row; Delete Now ends its days early."* So on a block row the panel's own sentence named a
door that was not there, which is her image 3 exactly. The capability itself was never missing: the
Library's Trash gives a block the same door (`RecoveryView`, every kind but `.preservedOriginal`),
one Library away.

**WHAT SHIPPED — one rule, one cluster, one road.**

1. **The rule (`TrayPurgeDoor`, `Features/Tray/TrayFilter.swift`)** — which of the three populations
   the panel draws may end its own clock, enumerated over BOTH views (six answers, the filter
   matrix's own shape): a LEAVING block yes (R-Q3), a LEAVING take yes (her G5 ruling, unchanged), a
   stranded original NEVER (it rides its family's clock — R-Q3's *"stranded originals stay without
   one"*), an ARCHIVED row never (kept, no clock — her B2 ruling; there are no days to skip and the
   block is LIVE). Enumerated rather than argued, because the batch-a ladder's standard for a rule of
   this shape is *complete by enumeration* — an argued exemption was wrong twice there at first use.
2. **The face (`TrayRowVerbs`)** — the trailing verbs are ONE cluster now, shared by `row(...)` and
   `takeRow`. Row 3 would otherwise have been the THIRD hand-rolled copy of the same two buttons
   (styles, help, row 63's `fixedSize` rider); the order and both `CalmButtonStyle` roles are the take
   row's own, byte-for-byte. A `Purge` value carries the button and its help TOGETHER, so a row can
   never draw the verb without the sentence that says what it costs.
3. **The road (`TrayViewModel.requestDeleteNowBlock` + `trashItem(for: Queries.TrayItem)`)** —
   `requestDeleteNowTake`'s line for a block row and deliberately nothing more: the SAME
   `TrashPurge.deleteNowConfirm`, the same `confirmPendingPurge` → `TrashPurge.confirm` →
   `requestPurge`, and the same sentence the Trash's own block row asks
   (`RecoveryCopy.deleteNowConfirm(.block)`). No second confirm text, no second purge path (F-4).
   `savedVersions` stays at its default 0: the Trash's count names a NOTE's saved moments beside it,
   and a sentence about versions over a block row would be false.
4. **`Shared/` untouched** — the explainer at `RecoveryCopy.swift:282` is now TRUE on a block row,
   which is the whole of Q-3 option (a). `TrayPanel.surfaceCapabilities` already declared
   `.deleteNow`, so the registry walk and `thePurgeDoorRendersOnTrashSurfacesAndNowhereElse` ride
   UNMODIFIED — the trash-surfaces rule is satisfied by construction (every row this door reaches is
   already deleted and already counting down).

**THE ORACLE PROBLEM, and how it was answered.** *"Which doors did the panel actually draw on this
row"* is not reachable the usual way: batch a measured that a hosted SwiftUI tree reports ONE
accessibility element with no children in this test host, and a composition `dump` does not evaluate
a `ForEach`'s content closure — the row previews the shipped composition pins match are the
`ForEach`'s DATA (`[Queries.TrayItem]`), not its buttons. So the face rides a DEBUG render oracle the
view itself feeds, the `TakesCellChrome`/`TakesArticleDoorProbe` pattern: **`TrayRowDoorProbe`**,
recorded from the verb cluster's own `onAppear`, keyed by the row's id.

**PINS (green on this tree):**
- `TrayFilterTests.onlyTheLeavingViewsBlocksAndTakesMayEndTheirOwnClock` — the six-cell enumeration
  plus the BELT behind the two refusals (`TrashPurge.deleteNowConfirm` hands back nil for a
  `.preservedOriginal` whatever a surface offers, and DOES hand one back for a `.block`).
- `TrayFilterTests.theLeavingBlockRowDrawsBothVerbsAndTheOtherRowsDrawOne` — the FACE, over a real
  seeded store in a mounted 320×640 panel: the deleted block's row and the deleted take's row each
  report `["Put back", "Delete Now"]`; the archived block's row reports `["Put back"]`.
- `TrayPanelMoveTests.aLeavingBlockRowsDeleteNowConfirmsThenPurgesForGood` — the ROAD, the take pin's
  own shape: the target IS the Trash's row for that block (`.block` / the block id / the note), the
  confirm is `RecoveryCopy.deleteNowConfirm(.block)` and names no versions, the read-back hazard is
  driven (13l Act 2's rule), ONE `purge_intent` lands, and the row leaves every surface.
- `TrayPanelMoveTests.aBlockRowsPurgeDoorAsksEveryTime` — her round-10 ruling, on a block row.

**Green:** `✔ Test run with 47 tests in 4 suites passed after 1.743 seconds`
(`TrayFilterTests` · `TrayPanelMoveTests` · `TrayPanelShapeTests` · `NoteTrayTests`) — the four
shipped tray suites ride with the two new pins, unmodified.

**RED ON OLD — measured by TWO discriminating behavioral reverts over `e394ac76`, then restored**
(`git checkout --`; the tree verified diff-clean and re-run `✔ 47 tests in 4 suites` afterwards):

| The revert | What went red | The number |
|---|---|---|
| `deleteNow: nil` at `cellRows`' leaving-BLOCK call site (the fix's one line) | `theLeavingBlockRowDrawsBothVerbsAndTheOtherRowsDrawOne` | the deleted block's row reported **`["Put back"]`** where `["Put back", "Delete Now"]` is owed — and the deleted TAKE's row in the SAME mounted frame still reported `["Put back", "Delete Now"]`, so the pin discriminates the block row's door from the take's rather than the cluster's existence (`red1.log`, local) |
| `kind: .preservedOriginal` for `kind: .block` in `trashItem(for: Queries.TrayItem)` (the road's one word) | `aLeavingBlockRowsDeleteNowConfirmsThenPurgesForGood` · `aBlockRowsPurgeDoorAsksEveryTime` | `target.kind == .block → false`, then **`model.pendingPurge → nil`** at the `#require` — the shared belt (`TrashPurge.deleteNowConfirm` refusing a `.preservedOriginal`) swallowing the confirm, so the road pin is non-vacuous and the belt is live (`red2.log`, local) |

The ROAD pins' red on the PRE-BATCH tree is by COMPILATION (neither `requestDeleteNowBlock` nor
`trashItem(for: Queries.TrayItem)` existed) — the `CalloutEmojiPickerTests` precedent's form; the
second revert above is their discriminating measurement on this tree.

#### PIECE 2 — ROW 4: THE CALLOUT EMOJI ALERT'S FIELD (her *"the callout pane is broken"*, image 9)

**RED ON OLD, measured on the PRE-FIX code before a line of the fix was written** (the pin came
first here, so no revert was needed): `CalloutEmojiPickerTests.theEmojiFieldHasRoomToTypeIn` —
**`accessory.field.frame.width → 0.0`**, in a real 480×80 window after `layoutSubtreeIfNeeded()`.
Not a sliver: ZERO. Every other expectation in the same pin already passed, which is the rest of the
diagnosis — the BUTTON kept its own size (≥ 80) and the stack kept its shipped 320, so the accessory
had the room all along and spent all of it on the one arranged view with an intrinsic width
(`red3.log`, local).

**THE MECHANISM, TRACED MYSELF.** `CalloutMenu.emojiAccessory` built
`NSTextField(frame: 200 × 24)` and handed it to an `NSStackView`. A stack view lays its arranged
subviews out by INTRINSIC CONTENT SIZE and priorities and clears
`translatesAutoresizingMaskIntoConstraints` on the way in — so the construction frame is discarded
the moment the field becomes arranged, and the field was never 200 wide in any build. An empty
editable `NSTextField` has no intrinsic width to speak of (the placeholder does not give it one),
while `NSButton`'s title does; with nothing asking for width and nothing resisting compression, the
stack gave the button its fitting width and the field zero. The 13e E1 pin beside it
(`theAccessoryOffersTheSystemPickerBesideTheField`) checked the parts' EXISTENCE and the title, never
a measured frame, which is why a zero-width field shipped for a month.

**WHAT SHIPPED (three lines and two named numbers).** `field.setContentHuggingPriority(.defaultLow,
for: .horizontal)` — it takes the slack instead of handing it over — and
`field.widthAnchor.constraint(greaterThanOrEqualToConstant: CalloutMenu.emojiFieldMinWidth)`
activated AFTER the stack adopts the field (which is what gives the constraint a hierarchy); then the
accessory's own frame becomes its FITTING size, floored at the shipped
`emojiAccessoryMinWidth` — because `NSAlert` sizes an accessory view from its frame, and a frame
narrower than the content is how one of two arranged views gets squeezed whatever the constraints
say. Both numbers are named constants on `CalloutMenu` (200 — the width the field was constructed
with since 13e and never got; 320 — the shipped accessory width, now a floor rather than a promise).

**GREEN, with the claims tightened after the red measurement** (the floor was `>= 150` when the red
was taken and is `>= emojiFieldMinWidth` (200) now — 0.0 fails either): the field ≥ 200, the picker
door ≥ 80 (a fix that squeezed the BUTTON would have moved the defect, not ended it), the accessory
≥ 320 and as wide as what it holds, neither view clipped inside it, and typing lands and reads back
(`promptEmoji` returns `field.stringValue`, so the round trip is the prompt's whole contract).
`✔ Test run with 17 tests in 3 suites passed` (`CalloutEmojiPickerTests` · `CalloutSwatchTests` ·
`FormattingSurfacesTests`).

**One environment note for the record:** `-only-testing:VariorumTests/DoorSetTests` matches NOTHING —
that FILE holds four suite TYPES (`DuplicateBookNameDoorTests` · `CalloutSwatchTests` ·
`CalloutEmojiPickerTests` · `BookAscentDeclarationTests`) and the flag takes type names. A run that
names it silently tests fewer suites than it claims; caught here by reading the
`Test run with N tests in M suites` line against the number of names passed (the brief's own
instruction), and the closing run names types only.

#### PIECE 3 — ROWS 5–6: THE DECORATION LANE, AND THE GLYPH INSIDE ITS FRAME (her ruling R-Q4)

**THE MECHANISM, TRACED MYSELF — and it is TWO defects, not one.** A CONTAINED (book) editor's prose
starts `EditorTypography.inlineSurfaceInset` = 8 pt from its own left edge (`makeInlineEditor` sets
the inset; `updateGutters` returns early there because `maxColumnWidth` is nil), and
`EditorViewModel.sendDecorState` hands the decor `textLeft = textContainerOrigin.x` — so `textLeft`
IS 8 in the book's editor (measured: `view.proseLeft == 8` at rest). Both left-margin decorations
place themselves left of that edge and clamp at 2:

| The face | Its shipped rule | At `textLeft == 8` |
|---|---|---|
| the comment count badge | `x = max(2, textLeft - 36)`, 32 wide | **[2, 34]** — over the words, which start at 8 |
| the callout's glyph | `x = max(2, textLeft - width - 8)` | **[2, 2 + w]** — over the words, and over the badge |

That is her image 10 and the first half of image 11. **The second defect is width-independent and
shows in Write too:** the glyph's rule put it at `textLeft - w - 8` while `calloutRect`'s own leading
edge is `textLeft - 12` — so the glyph sat OUTSIDE its own card, in the bare margin to its left, and
at any gutter where a badge is also drawn the two aim at the same corner and collide. Her *"the
callout goes on top of the comment badge"* is that, and a lane alone would not have fixed it.

**WHAT SHIPPED — geometry only. No text attribute, no paragraph style, no `exclusionPaths`.**

1. **ONE constant and ONE decision** (review focus F-3): `EditorTypography.commentLane` (64) and
   `EditorTypography.inlineInset(needsLane:)`. The constant's doc carries the ARITHMETIC that
   produced it, term by term, so a future edit can check it rather than guess:
   `2 edge + 32 badge + 4 air + 12 card pad + 4 glyph pad + 18 glyph box = 72` from the view's left
   edge, less the surface's own 8.
2. **ONE trigger** — `BlockDecor.needsLane(_ state:)`, asked of the decoration state the overlay
   controller is already holding (it carries `comments` and `presentations`), so the lane has no
   second source of truth and no second trigger. Her R-Q4's words exactly: a comment OR a callout
   glyph. A callout with NO glyph reserves nothing (its 12 pt of card air always had room).
3. **The LEFT only.** `textContainerInset` is symmetric, so the pair rides as its mean and
   `EditorTextView.textContainerOrigin` is overridden to place the container at the LEADING inset —
   the container's width becomes `bounds - (leading + trailing)` and its right edge stays at
   `bounds - 8`. The measure narrows by the lane, which is the point (R9 — the margins stay sacred);
   growing the symmetric inset instead would have taken the lane off the right margin too, for room
   only the left needs. **Opt-in:** `reservesDecorLane` is set by `makeInlineEditor` alone, so
   `setDecorLane` is inert on every other surface and their inset paths are byte-identical.
4. **ONE prose-column derivation.** `EditorTextView.proseLeft`/`proseRight`, read by
   `sendDecorState`. On a symmetric surface both are IDENTICAL to the arithmetic that stood there
   (`textContainerOrigin.x == textContainerInset.width`, and the trailing inset IS that number), so
   every shipped decoration geometry is unchanged by identity rather than by luck — the old
   `bounds.width - textContainerInset.width` is simply wrong once the insets differ.
5. **The glyph is the FRAME's.** `BlockDecor.calloutLeadingPad(hasGlyph:)` grows the card's leading
   pad by the glyph's room (her R-Q4: *"the frame widens to hold it"*), `calloutGlyphRect(card:
   blockTop:)` places the glyph in the card's top-leading corner, and the TRAILING edge and the
   white-gap rule (R17) are untouched. ONE rule, shared by Write and the book's editor, so the two
   surfaces cannot disagree. The glyph's box is FIXED (18 × 17) rather than measured: a card whose
   pad followed a measured label would change shape with the glyph, and `promptEmoji` returns
   whatever she typed — a multi-glyph answer now clips inside its box instead of pushing the card
   past the badge (before, it clamped at 2 and sat on the words).
6. **The comment faces yield the gutter a card claims.** `BlockDecor.commentClearance(hasCallout:
   hasGlyph:own:)` is ONE answer for the badge and the margin card alike: their own shipped air where
   the block wears no card, the card's leading pad + 4 where it does. A plain callout's 12 + 4 is
   inside the margin card's own 28, so **Write's card does not move at all** — the parity claim, as
   arithmetic and as a pin.

**Five literals became named constants on `BlockDecor`** (`calloutGutterPad` 12 · `calloutGlyphPad` 4
· `calloutGlyphBox` 18 × 17 · `commentBadgeSize` 32 × 16 · `decorAir` 4) — F-0's "no
number-as-rule in a view", and the lane's arithmetic is built from them.

**THE GEOMETRY, AFTER (measured in the pin, a laned 620 pt book editor, `textLeft` 72):**

| | x-range | |
|---|---|---|
| the comment badge | **[2, 34]** | in the lane |
| the callout card | from **38** | its leading pad 34 = 12 + 4 + 18 |
| the glyph | **[42, 60]** | inside the card, 12 pt clear of the text |
| the prose | **[72, 612]** | the trailing inset untouched |

**PINS — `BlockDecorLaneTests` (9), all green, and none vacuous** (the `try?`/`guard`-return holes
were closed after the first run: the disjointness pins now assert exactly one badge, one glyph and
one card are drawn, and that the glyph's string is the glyph):
- `theBookEditorsLaneArrivesWithADecorationAndLeavesWithIt` — 8 → 72 on a comment, 8 → 72 on a glyph,
  **given back** to 8 when the note carries neither, and the trailing inset never moving.
- `aCommentedCalloutWithAGlyphCoversNoTextAndNothingElseEither` — the ROW: badge, glyph and prose
  pairwise disjoint in a real mounted surface, the glyph CONTAINED by its card, the badge stopping at
  the card's edge, everything left of the text (her *"comments stay on the left"*).
- `theLaneHoldsAtANarrowBookColumnToo` — the sweep, at 360 · 480 · 900 pt.
- `aLanedSurfaceStaysOnTextKit2` — the fallback canary armed over a laned surface through a real
  edit: silent, `textLayoutManager` non-nil, and the container really narrowed. Overriding
  `textContainerOrigin` is not a TK1 API (TEXTKIT2_NOTES §4.2), but "not a downgrade trigger" is a
  claim that must be measured, not assumed.
- `theFullEditorReservesNoLaneAtAll` — the opt-in: `setDecorLane` inert on the full editor.
- `theCardWidensToHoldItsGlyphAndTheGlyphSitsInside` ·
  `theCommentFacesYieldTheGutterACalloutCardClaims` · `theLanesTriggerIsACommentOrACalloutGlyph` —
  the pure rules.
- `writesMarginCardAndPlainCalloutAreWhereTheyShipped` — the PARITY pin: the margin card at a wide
  gutter is `(62, 40, 210, 54)`, a plain callout's card is `(16, 99, 424, 46)` and the narrow-gutter
  badge is `(24, 0, 32, 16)` — the numbers the shipped pins already assert.

**Green, the whole editor/decor neighbourhood in one run:** `✔ Test run with 123 tests in 18 suites
passed after 29.983 seconds` (`BlockDecorLaneTests` · `MarginHoverCommentTests` ·
`CalmPageHoverTests` · `EditorTypographyTests` · `BlockDecorGeometryTests` ·
`CommentsAndReorderTests` · `LongBlockLayoutPlannerTests` · `LongBlockLayoutHostedTests` ·
`DecorRegistrationMappingTests` · `DecorRegistrationWindowTests` · `PaneSurfaceTests` ·
`BlockHighlightTests` · `ParagraphGapTests` · `TypewriterRoomTests` · `FindAndReplaceTests` ·
`FocusHandoffTests` · `FormattingSurfacesTests` · `CalloutEmojiPickerTests`) — every shipped decor
pin riding UNMODIFIED, which is the parity proof.

**RED ON OLD — measured by the announced behavioral revert over `5712779e`** (an early `return` in
`EditorTextView.setDecorLane`, which is exactly the pre-batch state: the contained editor's prose at
8 pt), then restored by `git checkout --`, the tree verified diff-clean and the suite re-run
`✔ 9 tests in 1 suite` (`red4.log`, local). **15 issues across 4 of the 9 pins** — her images 10 and
11, in numbers:

| What the pin measured | The number |
|---|---|
| the badge over the words | `badge (2, 10, 32, 16)` **intersects** `prose (8, 10, 604, 34)` |
| the glyph over the words | `glyph (6, 10, 18, 17)` **intersects** the same prose — note that this is the NEW glyph rule already: with the card clamped to `minX 2` for want of a lane, *inside the frame* is still on top of the text, which is why the lane and the widened frame are ONE fix and not two |
| the two colliding | `badge (2, 10, 32, 16)` **intersects** `glyph (6, 10, 18, 17)` — her *"the callout goes on top of the comment badge"* |
| the badge on the card's tint | `badge.maxX 34.0` > `card.minX + 0.5 = 2.5` |
| comments not on the left of the text | `badge.maxX 34.0` > `textLeft 8.0` |
| the lane never reserved | `proseLeft → 8.0` where 72 is owed, twice (a comment; a glyph) |
| the container never narrowed | `textContainer.size.width → 604.0` where `≤ 556.0` is owed |
| and at every width | the same two overlaps at **360 · 480 · 900** pt |

**TWO THINGS RECORDED, NOT FIXED (residuals, with their owners):**
1. **A Write window narrow enough to sit at `minGutter` (28) still has no room** for a count badge
   beside a glyphed callout: the badge clamps at 2 and the prose starts at 28. It is no worse than
   what shipped (the badge clamped to 2 there before too) and it is not the book's editor, which is
   what rows 5–6 and her R-Q4 are about; the honest fix is a decoration-aware floor under Write's own
   `minGutter`, which moves Write's measure (R9) and is a ruling, not a batch's number. Owner: the
   13u2 restyle continuation.
2. **Her ruling estimates the lane at *"~40 pt"* and the built lane is 64**, because that estimate
   counted the badge alone while the same ruling also widens the frame to hold the glyph, and the
   widened pad stands between the badge and the text. 64 is the smallest width at which all three of
   her clauses hold at once. Stated here for her eye rather than filed as a question: it is a number
   the brief assigns to the batch, and no ruling is re-opened.

##### THE WALK'S OWN FINDING — W-1: THE LANE WAS NOT REACHING THE SURFACE (found in USE, fixed)

**This is why the gate is USE and not pins.** Every one of piece 3's nine pins was green, and the
first walk of the book Outline showed the defect UNCHANGED: the `#1` comment badge still sat on the
words, covering the "lo" of *"loose thoughts on structure"* (capture `06-w1-the-defect-the-walk-found
.png`), with no glyph drawn at all.

**The mechanism, traced from the capture.** Reserving the lane moves where the text begins, and every
decoration's rect is computed from that edge — but the render that RESERVES the lane is working from
the OLD `textLeft` (8). A second decoration pass is needed, and the model's decoration loop is driven
by `overlayLayoutDidSettle`, whose generation gate opens only on a REPORTED geometry change
(`EditorViewModel.attach` wires `onWidthReflow` to bump the generation and run the settle hop). An
inset change reports nothing: `applyFrameHeight` fires `onWidthReflow` only when the view's FRAME
width changes, and the lane changes the container's width, not the frame's. So the lane was reserved
and nothing ever re-read it.

**Why the pins did not catch it — stated plainly, because it is the lesson.** The mounted pins
rebuilt the decoration state from the view's NEW prose column BY HAND for their second pass
(`let settled = state(for: view, …)`), which simulated a loop that did not exist. A pin that
reproduces the production loop's EFFECT while bypassing its MECHANISM is green for the wrong reason —
the same class as batch a's own "the three-block pin was green for the WRONG reason (its reveal
silently did nothing)".

**The fix (one line) and its pin.** `setDecorLane` reports `onWidthReflow?()` when it actually changes
the inset — a lane IS a prose-column reflow, so the existing signal is the honest one rather than a
new mechanism beside it. Fires only on a real change, so the second pass writes nothing and the loop
closes after exactly one extra cycle. Pins:
`BlockDecorLaneTests.reservingTheLaneSaysSoSoTheDecorationsAreComputedAgain` (the report on reserve,
none on a settled re-ask, one more on giving it back, and INERT on a surface that reserves no lane).
**RED ON OLD, measured by the announced revert and restored** (`git checkout --`): removing the one
line left `reflows → 0` where 1 is owed, four times over (`red5.log`, local). At the W-2 fix below
the seam generalized from `onWidthReflow` to the controller's own `onProseColumnChanged`, because the
read tier's reflow signal (`onWidthChange` → `viewWidthChanged`) guards on `bounds.width` and a lane
changes the CONTAINER's width, not the frame's — so the editor's signal could not serve both.

##### THE WALK'S SECOND FINDING — W-2: THE LANE REACHED ONE SURFACE OF TWO (found in USE, fixed)

The rebuilt app showed the defect AGAIN, unchanged. **The book Outline renders a note through TWO
different text views** (`BookView`'s two branches, read at the capture rather than assumed):

| The row's state | The surface | Before W-2 |
|---|---|---|
| expanded, FOCUSED | `EditorView(inline: true)` → `InlineEditorSurface` → `EditorTextView.makeInlineEditor()` | lane ✓ |
| expanded, NOT focused | `ReadPostView` → `PaneTextView.makeReadSurface()` | **no lane** |

The second is what an Outline shows BY DEFAULT — nothing is focused until she clicks in — so it is
the surface her screenshots were of, and piece 3's fix had reached the other one. `PaneTextView` is a
SIBLING `NSTextView` subclass, not a subclass of `EditorTextView`, so it could inherit nothing.

**The fix: the lane becomes ONE BRAIN both adopt** (`App/Variorum/Variorum/Surface/DecorLane.swift`)
— `DecorLaneReservation` holds the state and the arithmetic, `DecorLaneSurface` is the one question
the decoration controller asks, and each text view is a three-line adopter (hold it, write the inset
it names, override `textContainerOrigin` to the leading edge it names). Two copies of that arithmetic
in two sibling classes is exactly the drift class (F-0). The controller's refresh call becomes the
HOST's own door (`EditorViewModel.proseColumnDidChange` / `ReadPostViewModel.pushOverlaysToSinks`),
so W-1's fix serves both surfaces through one seam; and `ReadPostViewModel` reads the same one
prose-column derivation.

**THE SWEEP TABLE, as the pin** (`…everyDecoratedSurfaceHasItsLaneAnsweredOneWayOrTheOther`) — the
constitution's closing form, over every host of `BlockDecorOverlayController` (there are exactly
three, grepped):

| Host | Surface | Lane | Why |
|---|---|---|---|
| `InlineEditorSurface` | `makeInlineEditor` | **YES** | prose at 8 pt; the book's focused note |
| `ReadPostView` | `makeReadSurface` | **YES** | prose at 8 pt; the book's unfocused note and Read's page — W-2's own cell |
| `EditorSurface` | `makeEditor` | **no** | its gutter is the dynamic centering inset, wide enough for a margin card at any window not at `minGutter` |
| *(a take pane)* | `makeTakeSurface` | **no** | hosts no decoration controller at all, so nothing to make room for |

`✔ Test run with 12 tests in 1 suite passed`.

#### PIECE 4 — THE WALK (the acceptance gate: USE, on the DEV-STORE Debug build)

`io.lduarte.Variorum.debug` (verified by `CFBundleIdentifier`), `cliclick` 5.1 + `Tools/WalkKit`, the
dev store's sample library. **Her real-store app was QUIT for the whole batch** — `pgrep -fl
'Variorum.app/Contents/MacOS'` empty at the open and at every launch; every instance in this record
lives under `scratchpad/17p-b/DD/…/Debug/Variorum.app` and was discriminated by PATH. No Release
build, no `/Applications` refresh.

**The fixture,** built by hand in the app: the sample library's `field notes` book, its one note
`2026-08-31`, whose block 1 (*"loose thoughts on structure"*) was given a **sand callout**, then the
**🔥 glyph** through the Callout Emoji alert (row 4's own walk), then a **comment** (*"a note in the
margin"*) — i.e. exactly the *commented callout carrying an emoji* rows 5–6 are about — plus a
deleted block and an archived block for the tray.

| Row | The walk | What happened | Capture |
|---|---|---|---|
| **4** | Block ▸ Callout ▸ Emoji… | the field stands at its full width beside *"Emoji & Symbols…"* — her image 9's sliver is gone | `01` |
| **4** | typing into it | the glyph lands and reads back (a paste and a picked glyph both) | `02` · `02b` |
| **4** | the picker door | *"Emoji & Symbols…"* opens the SYSTEM picker at the field, and the alert survives it (an alert BUTTON would have dismissed the prompt) | `03` |
| **4** | four glyphs in the field | the field holds them with room to spare — the accessory grew to its fitting size | `02b` |
| **5** | WRITE, the callout with its glyph | the 🔥 sits INSIDE the card's leading inset (the card grew leftward for it); before the batch it floated in the bare margin, LEFT of its own frame | `04` |
| **5** | WRITE, the same block with a comment | the margin card on the left, the glyph inside the card, the text untouched — all three clear of each other (both voices) | `05` · `05b` |
| **5 · 6** | **the BOOK OUTLINE** (her surface), Terminal | the `#1` badge in the LANE, the 🔥 inside the frame, *"loose thoughts on structure"* WHOLE and uncovered | `07` · `07b` |
| **5 · 6** | the same, **Study** | identical, in serif | `08` · `08b` |
| **5 · 6** | the book's paged mode, **"edit here"** → the CONTAINED EDITOR live | badge in the lane, glyph in the frame, the ring on the block, the caret in the text, all three disjoint | `09` |
| **3** | the tray's Leaving view, Study | the block row carries **Put back AND Delete Now** — the door the explainer above it promises; her image 3's missing button | `10` |
| **3** | Delete Now | the confirm asks, in the Trash's own words for a block: *"Delete this block for good? It skips the rest of its 30 days — there's no putting it back."* | `11` |
| **3** | Delete for Good | the act LANDED: *"The block is gone from the app now — the app's own cleanup removes the bytes."*, Leaving 0 | `12` |
| **3** | the Archived view | the archived block row keeps **Put back alone** — *"kept — no clock"*, nothing to skip | `13` |
| **3** | the same row, **Terminal** | both verbs, in mono | `14` |

**Captures** (in `notes/plans/use-report-2026-09-12-screens/17p-b/`, gitignored):
`01-row4-callout-emoji-alert-field-wide.png` · `02-row4-typing-lands-in-the-field.png` ·
`02b-row4-four-glyphs-typed-and-pasted.png` · `03-row4-the-picker-door-opens.png` ·
`04-row5-write-the-glyph-inside-its-card.png` ·
`05-row5-write-margin-card-and-glyph-both-clear-of-the-text.png` · `05b-row5-write-study-voice.png` ·
**`06-w1-the-defect-the-walk-found.png`** (the first walk's evidence: the badge over the "lo" of
"loose") · `07-rows56-outline-terminal-badge-in-the-lane-glyph-in-the-frame.png` ·
`07b-rows56-outline-terminal-full.png` · `08-rows56-outline-study-voice-same.png` ·
`08b-rows56-outline-study-full-window.png` ·
`09-rows56-the-contained-editor-live-all-three-disjoint.png` ·
`10-row3-the-block-row-carries-delete-now.png` ·
`11-row3-the-confirm-asks-with-the-blocks-own-sentence.png` ·
`12-row3-the-purge-lands-and-the-row-leaves.png` ·
`13-row3-the-archived-row-keeps-put-back-alone.png` ·
`14-row3-terminal-voice-the-block-row-both-verbs.png`.

**TWO WALK ROWS NOT REACHED, and why** (stated rather than implied): a **deleted TAKE row beside the
block row** — the Block menu has `Archive Take` but no *delete* take door (the takes board's card menu
owns it), and the take row's Delete Now is SHIPPED behaviour this batch did not touch, pinned by
`TrayPanelMoveTests.theLeavingSectionsDeleteNowConfirmsThenPurgesForGood` and by the face pin's own
take arm (which asserts the take row reports both verbs in the same mounted frame as the block row —
capture-free but from a real mount); and a **stranded original**, which needs a divide-W to exist.
Both are covered by the enumeration pin and by the shared belt
(`TrashPurge.deleteNowConfirm` refusing a `.preservedOriginal`).

**THREE ENVIRONMENT NOTES, recorded so they are not met twice.**
1. **The recorded first-launch pitfall is REAL and it cost this walk an hour.** The first launch of a
   fresh build took every click and every keystroke and showed nothing — `cliclick t:` and
   `osascript keystroke` both landed nowhere while the app was demonstrably frontmost, and a
   `kp:delete` DID land, so it was not focus. Quitting my instance and relaunching cleared it
   (batch a recorded the same thing). **Always prove the keyboard works with a throwaway probe
   before building a fixture by typing.**
2. **`osascript keystroke "<emoji>"` silently mangles the glyph** (a 💡 typed as `aa`), and
   `cliclick t:"💡"` refuses outright (*"Unable to get key code"*). The road that works is
   `pbcopy` + ⌘V — and the system emoji PANEL, once opened, stays in front of the alert and eats the
   next clicks, so close it by its own ✕ before touching the alert again.
3. **Typing a long string through `cliclick` loses characters against the 18c deferred-keystroke
   seam** — 32 characters typed in one call arrived as one. Chunked typing with 350 ms waits is the
   road. (The related observation — a surface that stopped accepting text entirely while an empty
   live block held the ring, on the pre-relaunch instance — is 13u1's deferred-keystroke item, not
   this batch's; recorded, not chased.)

#### CLOSING RUNS (this tree)

- **Mac, ONE `xcodebuild test` from `App/Variorum/`** over the fifty-seven type names this batch
  touched or leans on — the TRAY/recovery family (`TrayFilterTests` · `TrayPanelMoveTests` ·
  `TrayPanelShapeTests` · `NoteTrayTests` · `RecoveryDoorsTests` · `RecoveryExplainerTests` ·
  `TrashPurgeDoorsTests` · `TrashPurgeSharedLayerTests` · `TrashConfirmEdgeTests` ·
  `IAAndTrashShapeTests` · `TrashSurfaceTests` · `TrashPoolHonestyTests` · `SnippetGroupTrashTests`),
  the CALLOUT/doors family (`CalloutEmojiPickerTests` · `CalloutSwatchTests` ·
  `DuplicateBookNameDoorTests` · `BookAscentDeclarationTests` · `FormattingSurfacesTests`), the
  EDITOR/decor family (`BlockDecorLaneTests` · `BlockDecorGeometryTests` · `EditorTypographyTests` ·
  `CommentsAndReorderTests` · `MarginHoverCommentTests` · `CalmPageHoverTests` ·
  `LongBlockLayoutPlannerTests` · `LongBlockLayoutHostedTests` · `DecorRegistrationMappingTests` ·
  `DecorRegistrationWindowTests` · `PaneSurfaceTests` · `PanePublishDoorTests` ·
  `BlockHighlightTests` · `ParagraphGapTests` · `TypewriterRoomTests` · `FindAndReplaceTests` ·
  `FocusHandoffTests` · `BareArrivalFocusTests`), the READ-TIER family the W-2 fix reaches
  (`ReadTierTests` · `ReadRenderingTests` · `ReadModeTests` · `ReadLandingTests` ·
  `ReadArrivalMeasureTests` · `ReadingFlowLandingTests` · `ReadingFlowEstimateTests` ·
  `NavigatorReadRowsTests` · `PagedReadViewTests` · `PagePaginatorTests`), the registry walk
  (`CapabilityRegistryTests`) and the ten `Tutorial*` spine types →
  **`✔ Test run with 426 tests in 57 suites passed after 108.320 seconds`** — fifty-seven suites for
  fifty-seven names, zero `✘`, and the log's single `skipped` match is the
  `appintentsmetadataprocessor` build warning, checked by line
  (`scratchpad/17p-b/closing.log`, local).
- **Core: UNTOUCHED** — `git diff --stat 48f54268..HEAD -- Sources/` is EMPTY. Zero `Sync/`, zero
  schema, zero `Domain/`. `swift test` therefore not owed and not re-run; the round's baseline
  (1503/163) stands.
- **`App/Variorum/Shared/`: UNTOUCHED** (empty diff — the tray explainer stays, and is now true), so
  the iOS build is not owed and was not run.
- **The editor seam: UNTOUCHED** — `BlockRangeIndex`, `EditorSurfaceController` and `PaneTextAuthority`
  are diff-empty; `EditorTextView`'s change is GEOMETRY only (an opt-in container origin) and
  `PaneSurface`'s is the same, both default-inert. The fallback canary is asserted silent over a laned
  surface. Zero rendering attributes, zero `exclusionPaths`, zero paragraph-style writes.
- **No commit trailers** on any of this batch's commits (verified).

#### THE ROWS, DISPOSITIONED

| # | Her words (short) | Disposition |
|---|---|---|
| **3** | *"i don't know where Delete Now is here — the text talks about it but the button doesn't appear to be visible"* | **FIXED** — pins: `TrayFilterTests.theLeavingBlockRowDrawsBothVerbsAndTheOtherRowsDrawOne` (red-on-old **`["Put back"]` where `["Put back", "Delete Now"]` is owed**, with the take row in the same frame still reporting both) · `…onlyTheLeavingViewsBlocksAndTakesMayEndTheirOwnClock` (the six-cell enumeration + the shared belt) · `TrayPanelMoveTests.aLeavingBlockRowsDeleteNowConfirmsThenPurgesForGood` (red-on-old **`pendingPurge → nil`** under the kind revert) · `…aBlockRowsPurgeDoorAsksEveryTime`. Walked: `10`–`14`, both voices, the confirm and the landing |
| **4** | *"the callout pane is broken"* | **FIXED** — pin: `CalloutEmojiPickerTests.theEmojiFieldHasRoomToTypeIn` (red-on-old **`field.frame.width → 0.0`**, measured on the pre-fix code in a real window; the button and the accessory already passed, which is the rest of the diagnosis). Walked: `01` · `02` · `02b` · `03` |
| **5** | *"the callout goes on top of the comment badge which is on top of the text"* | **FIXED** — pins: `BlockDecorLaneTests.aCommentedCalloutWithAGlyphCoversNoTextAndNothingElseEither` (red-on-old **badge `(2,10,32,16)` ∩ prose `(8,10,604,34)`, glyph `(6,10,18,17)` ∩ both**) · `…theCardWidensToHoldItsGlyphAndTheGlyphSitsInside` · `…theLaneHoldsAtANarrowBookColumnToo` · `…everyDecoratedSurfaceHasItsLaneAnsweredOneWayOrTheOther` · `…reservingTheLaneSaysSoSoTheDecorationsAreComputedAgain` · `…aLanedSurfaceStaysOnTextKit2` · `…writesMarginCardAndPlainCalloutAreWhereTheyShipped` (the parity). Walked: `04` · `05` · `05b` · `07`–`09` |
| **6** | *"in book view the comment thing needs to be moved or only accessible on the left because it's blocking the text"* | **FIXED** — the same mechanism and the same pins; the badge lives in the lane and comments stay on the LEFT (her R5-3 letter). Walked: `07`–`09`, and `06` is the before |

**Nothing DISMISSED AS HOLLOW.** Every row had a measured mechanism and a red-on-old number.
**Nothing DEFERRED** except the two recorded residuals below, each with an owner.

#### WHAT THE LETTER'S CLOSEOUT INHERITS

- **NO CANON DELTA IS OWED.** All four rows are DEFECTS against behaviour AppSpec already describes:
  §12's R7 (comments in the margin, degrading to a count badge) and R16/R17/R27 (the callout frame and
  its glyph) and R9 (sacred margins) say what should happen; this batch makes the three contained
  surfaces do it. The lane is a LOCAL geometry constant, never synced, never schema. Her R-Q3 and R-Q4
  are recorded in this plan's §7 and want no second home.
- **NO NEW QUESTIONS ENTRY** — **#102 is still free.** Every decision here is R-Q3's or R-Q4's letter;
  the two numbers that were mine (the lane's width, the glyph's box) are recorded with their
  arithmetic rather than asked, exactly as the brief assigns them.
- **TWO RESIDUALS, with owners.**
  1. **A Write window narrow enough to sit at `minGutter` (28)** still has no room for a count badge
     beside a glyphed callout (the badge clamps at 2, the prose starts at 28). No worse than what
     shipped, and not the book's editor — the honest fix is a decoration-aware floor under Write's own
     `minGutter`, which moves Write's measure (R9) and is a ruling, not a batch's number.
     **Owner: 13u2** (the restyle continuation).
  2. **A multi-glyph callout answer CLIPS** inside the fixed 18 pt glyph box (before, it clamped at 2
     and sat on the words). Bounded and honest; a real fix is either a measured box — which makes the
     card change shape with the glyph and re-opens the lane's arithmetic — or a one-grapheme guard at
     `promptEmoji`, which is a product call about what *"a leading glyph"* means.
     **Owner: 13u2**, or her word.
- **ONE OBSERVATION FOR HER, not a question.** Her R-Q4 estimates the lane at *"~40 pt"*; the built
  lane is **64**, because that estimate counted the badge alone while the same ruling also widens the
  frame to hold the glyph, and the widened pad stands between the badge and the text. 64 is the
  smallest width at which all three of her clauses hold at once, and the arithmetic is in
  `EditorTypography.commentLane`'s doc term by term. If the narrower measure matters more to her than
  the badge's full size, the two levers are the badge's width and the glyph's box.
- **Mobile parity:** nothing in `Shared/` moved, so the phone inherits nothing by construction. The
  phone's own comment/callout decorations are the mobile session's; this batch's shape — ONE lane
  brain the contained surfaces adopt, the glyph inside its own frame — is the design note that
  session should read if it meets the same class.
- **13u coordination:** this batch touched no 13u item's code. It hands 13u2's restyle continuation
  four additive seams on surfaces it will re-dress: `EditorTypography.commentLane` /
  `inlineInset(needsLane:)`, `Surface/DecorLane.swift` (the reservation + the `DecorLaneSurface`
  protocol), `BlockDecor`'s five named gutter constants with `calloutLeadingPad` /
  `calloutGlyphRect` / `commentBadgeRect` / `commentClearance`, and `TrayRowVerbs` +
  `TrayRowDoorProbe` (the tray's shared verb cluster and the DEBUG oracle that can pin a mounted
  `ForEach` row's doors).

**Batch b CLOSED at this commit.** Everything is committed and pushed; no revert is in flight; the
tree is clean. My own dev-store leftovers: the `field notes` note now carries a callout with a 🔥
glyph, one comment, one archived empty block and one deleted empty block — deliberately left so the
ladder sees the same store I did.

**R-2 · ORCHESTRATOR'S VERIFICATION + ADJUDICATION (2026-09-12, the overnight run):** verified against git (nine commits `52c9e891`…`b84336bf`; `Sources/`, `App/Variorum/Shared/`, `Sync/`, `Domain/` diff-empty against `48f54268`; no trailer lines; the tree clean, `main` == `origin/main`; zero app instances), the record, and captures `06` (the before: the `#1` badge over the first letters of "loose"), `07` (the after in the book Outline: the badge in the lane, the 🔥 inside its card, the prose clear of both) and `10` (This Note's Tray: the leaving block row with Put back AND Delete Now). **Rows 3–6 are FIXED as recorded.** Judgment calls:

**(J4) The batch-b ladder runs as FABLE, not Opus.** The brief cast `opus-reviewer` with the proviso "re-spawned as Fable if the decor's inset change reaches the seam" — it does: `EditorTextView` (the live editor, AppSpec §15 risk 1) gains a `DecorLaneSurface` conformance, a `textContainerOrigin` override (documented, not TK1 — the fallback canary is pinned silent over a laned surface) and a reflow report from `setDecorLane`; `PaneSurface` (P-3's one pane component) adopts the same brain. The 17-entry rule (CLAUDE.md: a Fable cold review whenever the diff touches the editor seam) decides it; the Opus budget saved is not worth a seam change reviewed at the wrong effort.

**(J5) The lane is 64 pt where her R-Q4 estimated "~40" — ACCEPTED as built, bundled for her as an observation.** The estimate counted the badge alone; the ruling's other clause (the glyph inside the frame) widens the card's leading pad, and 64 is the least width at which the badge, the widened card and the prose are pairwise disjoint (the arithmetic term by term in `EditorTypography.commentLane`'s doc). Not a product question — her clauses fix the number; the two levers if she wants it narrower (the badge's width, the glyph's box) are hers to name. Sacred margins (R9): the lane narrows the MEASURE, never the trailing margin — as the brief required.

**(J6) The walk's two findings are the batch's headline and a lesson for the record.** W-1 (the lane reserved but never re-read) and W-2 (the book Outline renders an unfocused note through the READ TIER, a second text view the lane had not reached — the very surface her screenshots were of) were both invisible to nine green pins: the mounted pins rebuilt state by hand for their second pass and so simulated a loop that did not exist — the same "green for the wrong reason" class as batch a's three-block pin. Twice in one round: the cold reviewer is asked (F-0, F-3) to look for any remaining pin whose second pass is hand-fed rather than driven through the surface's own report; the USE gate (§8's C-2/C-3) earned its keep and stays. The fix's shape — ONE lane brain (`Surface/DecorLane.swift`) both text views adopt as three-line adopters, with the three-host sweep table as a pin — is the constitution's answer (the sweep-table closing form, the one-brain rule) and is accepted.

**(J7) The two residuals are accepted with their owner (13u2):** Write at `minGutter` 28 with no badge room beside a glyphed callout (a decoration-aware floor moves Write's measure — a ruling, R9's); the multi-glyph callout answer clipping in the fixed 18 pt box (a product call about what "a leading glyph" means — her word invited in the morning bundle; not a QUESTIONS entry, because the shipped behaviour is bounded and no ruling is needed to ship). The tray's two unreached walk rows (a deleted take beside a block row; a stranded original) are covered by the enumeration pin and the shared belt — accepted. No canon delta; #102 still free. The dev-store leftovers stay for the ladder.

**Closing runs verified by the record's lines:** `✔ Test run with 426 tests in 57 suites passed after 108.320 seconds` (one invocation over the tray/recovery, callout/doors, editor/decor, read-tier and registry families + the ten `Tutorial*` types). **Batch b is CLOSED; the 17p batch-b FABLE ladder opens over `48f54268..b84336bf`** (round 1; cross-model flow; the batch's implementer resumed for agree/dispute and the sanity pass).



*(Pointers re-verified by the orchestrator on 2026-09-12 after batch a's ladder, at `17803ce4`: `RecoveryView.swift` lives at `App/Variorum/Variorum/Features/Library/RecoveryView.swift` (`requestDeleteNow` `:400`; the stranded rule `:122–126`); `EditorTypography.swift` at `App/Variorum/Variorum/Theme/EditorTypography.swift` (`minGutter` `:171`, `inlineSurfaceInset` `:176`); `TrayPanel.swift`'s lines hold within one (`confirmPendingPurge` `:637`, `trashItem(for:)` `:653`); `CalloutMenu.emojiAccessory` `:179`; `BlockDecor` badge `:592`, emoji `:479`, `calloutRect` `:167`; `EditorTextView.makeInlineEditor` `:823`; `EditorViewModel` `textLeft` `:3162`; `DoorSetTests:327` is the accessory's title pin. Batch a moved nothing in this batch's files. The environment traps and rules 1–8 are R-1's, verbatim by reference; her app is QUIT for the night — an instance at `/Applications` means she is awake: never touch it.)*

### 17p batch b LADDER — ROUND 1 FINDINGS (fable-reviewer)

*(Cold review of `48f54268..b84336bf` — the seven code commits — against `notes/REVIEW_PROMPT.md`
verbatim, this plan's §3 rows 3–6, §4.3–§4.4, §5.1, §7 R-Q3/R-Q4, §12 F-0/F-3/F-4, R-0, the R-2 brief,
record and adjudication, AppSpec §12 (R7/R9/R16/R17/R27), TEXTKIT2_NOTES §3–§4, and the four suites
this batch touched, re-run here: `✔ Test run with 41 tests in 4 suites passed` (`BlockDecorLaneTests`
· `TrayFilterTests` · `TrayPanelMoveTests` · `CalloutEmojiPickerTests`). Zero app instances at
`/Applications` throughout. Every finding below was traced by me, by reading and — where a claim about
AppKit was load-bearing — by measurement; nothing was delegated. Format: `R1-n · severity · file:line ·
what · evidence · fix`.)*

#### Findings, severity-ranked

- **R1-1 · MAJOR · `App/Variorum/Variorum/Features/ReadTier/ReadPostView.swift:178–180` (the read
  tier's `onProseColumnChanged` door) and `App/Variorum/Variorum/Features/Editor/EditorView.swift:534`
  (`InlineEditorSurface.Coordinator.install`, where the contained editor's controller is built) · The
  lane narrows the measure by 64 pt but NEITHER contained host re-measures its height afterwards, so a
  note whose paragraphs re-wrap under the narrower column keeps its PRE-lane `contentHeight` and its
  last lines fall outside the surface's frame — on the read tier, which is the surface an Outline shows
  by default (W-2's own finding), persistently.** · *Evidence (traced, every step file:line):*
  `ReadPostViewModel.contentHeight` is written only by `remeasure()` (`ReadPostViewModel.swift:261`),
  reached from `applyProjection` (`renderFull`/`applyDifferential`), from `viewWidthChanged` (`:273`,
  gated on `bounds.width != lastMeasuredWidth` — a lane changes the CONTAINER's width, never the
  bounds'), and from `applyChrome` (`ReadPostView.swift:149`, gated on a chrome change). The lane is
  reserved inside `BlockDecorOverlayController.render` (`BlockDecor.swift:555–559`) — reached via
  `adoptDecorContext` → `refreshDecor` → `decorSink` — which writes `textContainerInset`
  (`PaneSurface.swift:573–574`) and narrows the container (measured by the batch's own pin
  `aLanedSurfaceStaysOnTextKit2`: `textContainer.size.width ≤ bounds − 64`); the host's door for that
  event is `pushOverlaysToSinks` (`ReadPostViewModel.swift:182`), which runs `refreshDecor` ONLY.
  `ReadPostView.swift:75` frames the surface at `model.contentHeight`. So in EITHER arrival order —
  projection first (`renderFull` → `remeasure` at the 604-wide container → H1; then the comment lands
  → lane → re-wrap to H2 > H1 → nothing writes H2) or decor context first (`refreshDecor` sends the
  empty state because `index.entries` is empty; then `renderFull` → `remeasure` H1 → `refreshBadges` →
  `refreshDecor` → NOW the lane, after the measurement in the same call chain) — the surface stays H1
  tall until a window resize or a projection change. The contained editor is the same class one host
  over: `InlineEditorSurface.Coordinator.remeasure` (`EditorView.swift:554`) runs at `install`, at
  `updateNSView` and on `didProcessEditing`; the lane lands on the async hops AFTER any synchronous
  render (`render` → `DispatchQueue.main.async` → `proseColumnDidChange` → the settle hop) and edits no
  storage, so no remeasure follows — there it heals at the next SwiftUI re-render or keystroke
  (transient); on the read tier nothing heals it. The walk could not see it: the fixture note is ONE
  line (captures `07b`/`09`, read here), which cannot re-wrap. This is the hole J6 named — the second
  pass was pinned by hand — with a different occupant: the lane is a REFLOW (the record's own words,
  W-1), and a reflow's other half is the height (`viewWidthChanged` → `remeasure` is exactly how a
  width reflow is handled one line below the new wiring). · *Pin (red on old):* through
  `withReadTier` with ONE long paragraph (~1,200 chars) in a 620-wide surface, the REAL
  `ReadPostSurfaceCoordinator.install(textView:)` (its wiring is the production wiring — the R1-5
  point), a comment added through the operations layer and delivered by the observation; after the
  hop, `abs(model.contentHeight − PaneMeasurement.height(of: textView)) < 0.5` — red on old (H1 < H2)
  — and the badge's final frame `maxX ≤ textView.proseLeft` (the loop-driven form of the disjointness
  pin). The inline twin through `withInlineEditor` + the real coordinator's `install(…) { height in }`,
  asserting the LAST reported height equals the measured one after `adoptComments`. · *Fix:* each
  host's prose-column door is its REFLOW door, not its decor door — read tier:
  `ReadPostViewModel.proseColumnDidChange()` = `remeasure()` (which already chains `refreshBadges` →
  `refreshDecor`, re-reading the ⑂ badges' y-positions too, which the re-wrap also moved and which
  `pushOverlaysToSinks` would have re-pushed STALE from stored state), wired at `:178`; inline editor:
  the coordinator composes `remeasure()` onto the controller's door after `:534` (the model keeps its
  `proseColumnDidChange` for the decorations; the height is the coordinator's to re-report, exactly as
  it is on every other trigger).

- **R1-2 · MINOR · `App/Variorum/Variorum/Surface/DecorLane.swift:64–71` (`reserve(needed:trailing:)`)
  · The brain reports a change on its FIRST call even when nothing moved, so every contained surface's
  first decoration render schedules a spurious host refresh, and the doc's contract ("nil when nothing
  changed"; `setDecorLane`'s "true when the prose column actually MOVED") is false at exactly the call
  every surface makes first.** · *Evidence:* `insets` starts nil; a first `reserve(needed: false, …)`
  computes `leading = 8`, and `guard insets?.leading != leading` is `nil != 8` → true → `insets =
  (8, 8)`, returns 8; `setDecorLane` (`EditorTextView.swift:401`, `PaneSurface.swift:569`) writes
  nothing (`abs(8 − 8) > 0.5` is false) but returns TRUE → `render` (`BlockDecor.swift:555–559`)
  schedules `onProseColumnChanged` → on the read tier a whole `pushOverlaysToSinks`, on the editor a
  generation bump + settle hop (`refreshBadges` + `refreshDecorations` + `considerLongBlockLayout`).
  Once per contained surface at mount — in a book Outline, once per visible read tier. Bounded (the
  second call is change-gated), no loop; but it is a wasted pass the record says does not happen, and
  it leaves `originX` = 8 so the `textContainerOrigin` override is ACTIVE on every laneless contained
  surface (returning what `super` would — harmless today, one edit away from not). The batch's pin
  `reservingTheLaneSaysSoSoTheDecorationsAreComputedAgain` starts with `needed: true` and so never
  meets it. · *Pin (red on old):* `PaneTextView.makeReadSurface().setDecorLane(needed: false) == false`
  and the same on `EditorTextView.makeInlineEditor()` (both return true today). · *Fix:* compare
  against the surface's RESTING leading (`insets?.leading ?? EditorTypography.inlineInset(needsLane:
  false)`), and release to `insets = nil` (defer to `super`) rather than to `(8, 8)`, so the override
  is live only while a lane is.

- **R1-3 · MINOR (architectural — the drift class F-0 names; no pin owed) ·
  `App/Variorum/Variorum/Features/Editor/EditorView.swift:675` (`BadgeOverlayController.render`) and
  `App/Variorum/Variorum/Features/ReadTier/ReadPostView.swift:243` (`ReadBadgeOverlay.render`) · The ⑂
  badge overlays on BOTH contained hosts still derive the prose column's right edge as `bounds.width −
  textContainerInset.width` — the arithmetic the batch's own comment at `EditorViewModel.swift:3173`
  calls "simply wrong once the insets differ" and created `proseRight` to retire — so the ONE
  prose-column derivation the record claims is two derivations on the very views the batch changed.**
  · *Evidence:* on a laned 620-wide surface `textContainerInset.width` is the MEAN (40), so
  `columnRight` reads 580 where the column ends at 612 (`proseRight`). The visible effect today is
  small — the `min(bounds − size − 8, columnRight + 6)` clamp usually wins on a contained surface (both
  arms land within ~6 pt) — which is why this is not a bug finding; the traced degradation is that the
  next change to the lane's width or the trailing inset moves the ⑂ badge by the difference on
  exactly these two hosts, silently, with no pin watching (the one-derivation rule exists to make that
  impossible). · *Fix:* both overlays read the edge through the surface (`proseRight` — the editor's
  overlay holds an `EditorTextView`; the read tier's holds an `NSTextView` and casts to `any
  DecorLaneSurface`, falling back to the old arithmetic for a surface that is not one); a small parity
  pin that the badge's x is unchanged on an unlaned surface.

- **R1-4 · MINOR (cleanliness) · `App/Variorum/Variorum/Features/Tray/TrayPanel.swift:1010–1018` (the
  ARCHIVED block row's `deleteNow:` argument) · The archived row constructs a `TrayRowVerbs.Purge` —
  with its own copy of the help sentence — behind `TrayPurgeDoor.offered(.block, view: model.view)`,
  inside the `else` branch of `if model.view == .leaving` where that rule is false by construction; the
  comment above it says "No purge door" while the code builds one, and the block's help sentence now
  exists twice (`:992–993`, `:1016–1017`) beside the take's near-copy (`:1116–1117`).** · *Evidence:*
  `cellRows` (`:964–1023`) renders the archived branch only when `model.view != .leaving`;
  `TrayPurgeDoor.offered(.block, view:)` is `view == .leaving` (`TrayFilter.swift:199`); the
  stranded-original site two rows down (`:1037–1049`) takes the OTHER road — a literal `nil` with the
  rule cited and the P-2 reason — so the file now states the same rule two ways. No behavior is wrong
  (the enumeration pin holds the rule; the face pin measured the archived row at `["Put back"]`);
  this is F-0's "two copies" letter applied to a sentence-as-rule. · *Fix:* the archived site passes
  `nil` as the stranded site does (the rule's enumeration is the pin), and the purge door's help
  sentence lives ONCE — a `TrayRowVerbs.Purge` factory per kind (`.block(act:)` / `.take(act:)`) or two
  statics beside `RecoveryCopy.deleteNowVerb`'s consumers in this file — so a third row type cannot
  mint a fourth copy. No pin (nothing observable changes).

- **R1-5 · MINOR (the pin-quality gap J6 asked this round to look for; the fix rides R1-1's pin) ·
  `App/Variorum/VariorumTests/BlockDecorLaneTests.swift:271–274` and `:307–310` (the two mounted
  disjointness pins' second pass) · W-1 and W-2 are pinned at their TRIGGER — `setDecorLane`'s return
  value (`reservingTheLaneSaysSoSoTheDecorationsAreComputedAgain`) and the `reservesDecorLane` flags
  (`everyDecoratedSurfaceHasItsLaneAnsweredOneWayOrTheOther`) — never at their EFFECT through the
  production loop: no pin on either host drives model → controller → host door → model → re-sent
  state and asserts the FINAL badge rect against the FINAL prose column, and the two mounted pins
  still hand-feed pass two (`let settled = state(for: view, …)`), which is the exact shape the record
  itself names as "green for the wrong reason".** · *Evidence:* the record (PIECE 3, W-1) states the
  lesson and then pins the trigger; R1-1 is what a loop-driven pin would have caught, because a pin
  that measures the SURFACE after the lane (rather than a hand-built state) reads its frame. ·
  *Fix:* R1-1's read-tier pin is written through the real `ReadPostSurfaceCoordinator.install` and the
  real observation, and asserts both halves (the badge's final `maxX ≤ proseLeft`; the height); the
  two hand-fed pins stay (they pin the pure geometry honestly) with their doc corrected to say so.

- **R1-6 · MINOR (PROVISIONAL — a product consequence the docs do not decide; goes to QUESTIONS #102,
  no code change) · `App/Variorum/Variorum/Surface/PaneSurface.swift:733–745` (`makeReadSurface`
  reserves the lane) · The lane reaches EVERY `ReadPostView` composition — the workspace's read-cheap
  pane (`RootView.swift:897`), the note window (`NoteWindowView.swift:94`), the spread/paged book
  (`SpreadBookView.swift:361`) — not only the book Outline her R-Q4 names; on those pages a commented
  note's prose column now stands 64 pt right of an uncommented note's, so the left edge of the calm
  page varies per note.** · *Evidence:* R-Q4's letter names "the book Outline's inline editor"; the
  record's sweep table lists the read-tier cell as a MECHANISM fact ("same 8 pt prose inset, same
  decorations, same defect") and the inheritance section says "#102 is still free — every decision
  here is R-Q3's or R-Q4's letter". The overlap defect did exist on those pages too (prose at 8 pt
  inside a 20 pt SwiftUI pad, decorations clamped at 2), so the shipped behaviour is the
  spec-defensible one ("nothing covers text"); but whether a Read page may shift its measure per note,
  or should reserve the lane ALWAYS (a stable edge) or never (comments as a count in the pad), is hers,
  and unrecorded. · *Fix:* record it as QUESTIONS #102 PROVISIONAL with the three options, the shipped
  one marked; nothing in code.

- **NIT-1 · `App/Variorum/Variorum/Surface/PaneSurface.swift:545–548` · the doc comment "Fires when
  layout gives the view a NEW width (batch 12 …)" is now orphaned above the lane's `MARK`, attached to
  nothing; `onWidthChange` at `:594` lost its doc.** Fix: move the three lines down to the property.
- **NIT-2 · `App/Variorum/Variorum/Features/Editor/EditorTextView.swift:388–393` ·
  `reservesDecorLane` is documented as "Read-only view of the opt-in" and has a setter (the factories
  use it).** Fix: the sentence.
- **NIT-3 · `App/Variorum/Variorum/Features/Editor/BlockDecor.swift:761` · the badge's own air to the
  text is the literal `own: 4` in the controller while `decorAir` (= 4) sits above as a named constant
  for a DIFFERENT gap (badge → card), and `EditorTypography.commentLane`'s arithmetic names only the
  latter.** Fix: name it (`commentBadgeAir`) so the two 4s are two named things (F-0's letter), or
  cite the constant at the call site.
- **NIT-4 · `EditorTextView.setDecorLane`/`textContainerOrigin` (`:401–423`) and
  `PaneTextView`'s (`PaneSurface.swift:569–584`) are byte-identical bodies.** The override must stay
  per class, but `setDecorLane` could live once in `extension DecorLaneSurface where Self: NSTextView`
  over a `lane` requirement. Optional; the record calls them "three-line adopters" knowingly.

#### Considered and cleared (traced; measured where it mattered)

- **The `textContainerOrigin` override under TextKit 2 is honored for hit-testing, caret geometry and
  drawing alike — MEASURED, not assumed** (a bare `NSTextView(usingTextLayoutManager: true)` subclass
  with the batch's override, 620 wide, in an offscreen window; `scratchpad/lane-hittest.swift`):
  symmetric inset 8 → `characterIndexForInsertion` at x = 41 → 4, x = 73 → 9; `firstRect(0..1)` x =
  13; first-line ink from 14 pt. Laned (origin 72, inset mean 40, container 540) → x = 41/60/73/80 → 0,
  x = 100 → 3; `firstRect` x = 77; the caret rect x = 77; ink from 78 pt; the container really 540.
  So `PaneTextView.mouseDown`'s `characterIndexForInsertion` (the read tier's click-to-focus offset)
  and AppKit's own caret placement agree with the drawn text on a laned surface. The batch's canary
  pin covers the downgrade question; this covers the geometry one it could not.
- **The reveal/anchor consumption cannot be stranded by the lane's generation bump:**
  `consumePendingReveal(deliveredBy:)` / `consumePendingAnchorRestore` use `generation >= pending…`
  (`EditorViewModel.swift:2009`, `:2022`), so a hop delivering a LATER generation still consumes; and
  `overlayLayoutDidSettle`'s "bumped between schedule and run re-arms on its own draw pass" holds
  because `onLayoutSettle` fires from `viewWillDraw` (`EditorTextView.swift:364–367`) and an inset
  change invalidates display.
- **No loop:** the second `setDecorLane` on a settled lane returns nil → false; `proseColumnDidChange`
  → `refreshDecorations` sends only on `state != lastDecorState`; the read tier's `pushOverlaysToSinks`
  re-runs `render` once and the guard closes it. Verified by reading both gates.
- **`updateGutters` cannot clobber the lane's mean inset on the inline editor** — it early-returns on
  `maxColumnWidth == nil` (`EditorTextView.swift:583`), and `makeInlineEditor` never sets one. No other
  writer of `textContainerInset` exists on either contained class (grepped: `:405`, `:588`, `:850`,
  `:916`; `PaneSurface.swift:574`, `:690`).
- **`LongBlockLayout.swift:314`** reads `bounds − 2 × inset.width` as the container width — on a laned
  surface that is `620 − 80 = 540`, the true container width, by construction of the mean. Correct by
  identity. `:447` reads `textContainerOrigin` (the override). Fine.
- **`PaneMeasurement.height`** uses `inset.height × 2` — vertical only; the lane never touches height.
- **The lane's trigger is whole-note, not viewport-scoped** (`presentationsByBlock`/`commentsByBlock`
  are the note's maps in both `sendDecorState`s), so scrolling never toggles it — R-Q4's "whenever the
  note has" letter. Cost per pass ∝ callouts + comments in the note, never the corpus (P1).
- **Sync/schema/core:** `git diff --stat 48f54268..b84336bf -- Sources App/Variorum/Shared` is empty;
  no `setting`, no column, no `Sync/` — the record's claims hold.
- **The tray road (F-4):** `requestDeleteNowBlock` → `TrashPurge.deleteNowConfirm(for: trashItem(for:))`
  → `confirmPendingPurge` → `TrashPurge.confirm` → `requestPurge([SyncPurgeTarget(table:
  item.kind.purgeTable, rowID: item.id)])` (`RecoveryActs.swift:343–397`); the target for a block is
  the `block` table + the block id, byte-equal to `Queries.trash`'s block arm (`Trash.swift:281`). The
  extra `blockID` the tray sets on a `.block` item is read by nothing on this road (the message is by
  kind — pinned). The stranded original keeps no door (the literal nil AND the belt). `surfaceCapabilities`
  already declared `.deleteNow`; the registry walk rides unmodified.
- **`TrayRowVerbs` layout parity:** the take row's outer `HStack(spacing: 8)` held the two buttons at
  spacing 8; the cluster is an `HStack(spacing: 8)` inside it — the gap between the verbs and to the
  `Spacer` is unchanged. Both `.fixedSize()` riders kept.
- **`CalloutMenu.emojiAccessory`:** the width anchor is activated after `NSStackView(views:)` adopted
  the field (a superview exists), `.defaultLow` hugging on the field gives it the slack, and the
  stack's frame is its fitting size floored at 320 — `NSAlert` sizes the accessory from the frame, so
  the field cannot be squeezed back. The pin measures in a real window (red-on-old 0.0 recorded).
- **`hasLeadingGlyph` is the ONE question** for the card's pad, the glyph's rect, the label count and
  the comment faces' clearance (four call sites, one function). A callout with no glyph reserves
  nothing; a glyph on a non-callout presentation is not a glyph (pinned).
- **The arithmetic** (`commentLane`'s doc): 2 + 32 + 4 + 12 + 4 + 18 = 72; 72 − 8 = 64; the after-table
  (badge [2, 34], card from 38, glyph [42, 60], prose from 72) recomputed by hand from the constants —
  consistent. Write's margin card and plain callout numbers recomputed through the defaulted
  parameters — byte-identical (the parity pin's numbers are the shipped pins' own).
- **Write at a gutter between 28 and 72 (not only AT `minGutter`):** the recorded residual 1 is
  narrower than the mechanism — with a glyphed callout AND a badge, the badge's `max(2, textLeft − 38
  − 32)` clamps at 2 for any `textLeft < 72`, i.e. any Write window narrower than `maxColumnWidth +
  144 = 824` pt, and the card's `textLeft − 34` then overlaps it. Not a regression (the badge clamped
  at 2 there before too; the glyph sat OUTSIDE its card at every width) and the residual's owner (13u2)
  is right; recorded here so 13u2 reads the true range, not "at 28".

#### Review foci (§12), addressed

- **F-0 (no god brain, no god file):** the lane is its own 100-line brain (`Surface/DecorLane.swift`) adopted by
  two classes; `BlockDecor` grew five constants and six pure functions inside its existing geometry
  enum; `TrayPanel.swift` (1,422 lines) gained one subview + a DEBUG probe, layered on, not bolted in;
  `EditorViewModel.swift` (3,508 lines) gained 11 — its size is standing, not this batch's. Two rules
  now exist twice where one should (R1-3, the prose-right derivation; R1-4, the help sentence) and one
  contract is false at its first call (R1-2). No literal colour; the literal `4` is NIT-3.
- **F-3 (ONE constant + ONE decision; the emoji's placement ONE rule; no `exclusionPaths`; no
  rendering attributes):** `EditorTypography.commentLane` + `inlineInset(needsLane:)` — one each;
  `calloutGlyphRect(card:blockTop:)` is the one glyph rule for Write and the Outline; grepped: zero
  `exclusionPaths`, zero rendering-attribute or paragraph-style writes in the diff. SATISFIED — with
  the height half of the reflow missing (R1-1).
- **F-4 (the tray reuses the take row's confirm and purge road — no second confirm text, no second
  purge path):** SATISFIED (traced above); the help SENTENCE is duplicated (R1-4), the confirm and the
  road are not.

#### CLEAN BILL — checked and found solid

- Rows 3–6 are FIXED against the mechanisms the plan traced (§4.3–§4.4), and each red-on-old number
  in the record is real: I re-derived the pre-batch geometry (badge [2, 34], glyph [2, 2 + w], prose from
  8) from the old code in the diff, and the four suites pass on this tree (41/4).
- The `textContainerOrigin` override is not a TK1 API and is honored consistently by NSTextView on
  TextKit 2 for drawing, caret and hit-testing (measured above) — the seam change is sound.
- Her R-Q3's letter (leaving blocks and takes yes; stranded originals never; archived never — kept, no
  clock) is the enumeration, pinned, with the shared belt behind the refusals; R-Q4's letter (badge in
  the lane; glyph inside the frame; the trailing inset untouched — R9; comments on the left) holds in
  the geometry and the pins.

#### Implementer's responses (round 1)

*(Cross-model flow: agree/dispute per finding, grounded in the code; no code changed, no fix applied.
I re-read each traced road before answering. Tally: **10 findings — 10 agree, 0 dispute.**)*

- **R1-1 · MAJOR · AGREE, and it is my omission exactly as traced.** The mechanism holds at every
  step I re-checked: `ReadPostViewModel.remeasure()` (`:262–270`) is the ONLY writer of
  `contentHeight`, `viewWidthChanged` (`:273`) gates on `bounds.width` — which a lane never moves —
  and `ReadPostView.swift:75` frames the surface at `model.contentHeight`, so a note that re-wraps
  under the narrower column keeps H1. **Why I wired `pushOverlaysToSinks` and not `remeasure`:** I was
  fixing a DECORATION staleness (W-1's "every rect was computed from the old edge"), so I reached for
  the door whose whole doc is *"Wiring DELIVERS … state computed before this host existed must not
  stay invisible"* (`:182–186`) — the re-push door — and never asked the second question a reflow
  asks. The reviewer's framing is the one that was missing and is in my own record's words: the lane IS
  a reflow (W-1), and `viewWidthChanged → remeasure` sits one line below my new wiring as the shape a
  reflow already had. **The fix is strictly better than a composition**, confirmed by reading:
  `remeasure()` → `refreshBadges()` → `refreshDecor()` (`:317`), so it publishes the height AND
  recomputes the ⑂ badge frames AND re-sends the decor state, where `pushOverlaysToSinks` pushes
  `badges` from STORED state (`badgeSink?(badges)`, `:183`) — i.e. it re-pushes the pre-lane badge
  positions, which is the staleness the reviewer names. The only thing `remeasure` does not do is
  re-arm `lastDecorState`; it does not need to, because after the lane the next state carries a new
  `textLeft` and `refreshDecorations`' `state != lastDecorState` gate opens on its own.
  **The inline editor's half is the same fix, and "transient" is generous:** the coordinator's
  `remeasure` (`EditorView.swift:554`) runs at `install`, at `updateNSView` and on
  `didProcessEditing`; `proseColumnDidChange` edits no storage, and `presentationsByBlock` /
  `commentsByBlock` are `@ObservationIgnored` (`EditorViewModel.swift:207–208`), so a comment
  arriving does not re-render the representable either — the heal waits for an unrelated SwiftUI pass
  or her first keystroke. So the coordinator should compose `remeasure()` onto the controller's door
  after `:534`, as the reviewer says, and the model keeps `proseColumnDidChange` for the decorations.
- **R1-2 · MINOR · AGREE.** Re-traced: `insets` starts nil, so `reserve(needed: false, trailing: 8)`
  computes `leading = 8`, `nil != 8` is true, and it returns the mean 8; `setDecorLane` then writes
  nothing (`abs(8 − 8) > 0.5` is false) and still returns true. The doc's contract is false at the
  call every contained surface makes first, and my pin
  (`reservingTheLaneSaysSoSoTheDecorationsAreComputedAgain`) opens with `needed: true` and so cannot
  meet it. The second half of the finding is the one I would have missed: releasing to `(8, 8)` rather
  than to nil leaves the `textContainerOrigin` override LIVE on a laneless contained surface, where it
  happens to return what `super` returns — a correctness-by-coincidence I should not have shipped,
  since the mean and the leading are equal only while no lane is reserved.
- **R1-3 · MINOR · AGREE.** Both lines are there as traced (`EditorView.swift:675`,
  `ReadPostView.swift:243`): `let columnRight = textView.bounds.width − textView.textContainerInset
  .width`. That is the exact arithmetic my own comment at `EditorViewModel.swift:3173` calls wrong
  once the insets differ, and `proseRight` exists to retire it — so the record's "ONE derivation" is
  true of the DECOR pass and false of the two badge overlays on the very surfaces the batch laned. I
  had not looked at the badge overlays at all; they are a separate controller from
  `BlockDecorOverlayController` and my sweep enumerated decor hosts, not badge hosts. The severity is
  right (the `min(…)` clamp hides it today) and so is the reason it still matters: nothing pins it, so
  the next change to the lane's width or the trailing inset moves the ⑂ badge silently.
- **R1-4 · MINOR · AGREE — and it is my own inconsistency, stated twice in one file.** The archived
  branch (`TrayPanel.swift:1010–1018`) passes a `Purge` behind `TrayPurgeDoor.offered(.block, view:
  model.view)`, which inside `else { … }` of `if model.view == .leaving` is false by construction, so
  the value is unreachable; the comment above it says "No purge door". Two rows down the stranded site
  (`:1037–1049`) takes the literal-nil road WITH the P-2 reason written out. I chose literal-nil there
  deliberately (a rendered door that can never act is P-2's defect) and then did not apply my own
  reasoning one call site up. The duplicated help sentence is the same class as the verb cluster the
  batch just de-duplicated, one register down.
- **R1-5 · MINOR · AGREE, without reservation — this is the finding I would most want made.** My
  record names the lesson (W-1: "a pin that reproduces the production loop's EFFECT while bypassing
  its MECHANISM is green for the wrong reason") and then pins the trigger anyway: the return value and
  the `reservesDecorLane` flags. The two mounted pins still hand-feed pass two
  (`let settled = state(for: view, …)`, `BlockDecorLaneTests:271–274` / `:307–310`), and the proof
  that this mattered is R1-1 — a pin that measured the SURFACE after the lane instead of a hand-built
  state would have read the stale frame. I agree with the disposition too: the hand-fed pins are
  honest pins of the PURE geometry and should stay with their doc corrected, and the loop-driven pin
  should be R1-1's.
- **R1-6 · MINOR / PROVISIONAL · AGREE, and the honest answer to the question put to me is that the
  per-note left edge was an ACCIDENT OF SCOPE, not a choice.** I opted the lane in at the FACTORY
  (`PaneSurface.swift:733–745`, `makeReadSurface`) because my sweep enumerated the three hosts of
  `BlockDecorOverlayController` and the read tier was the cell the walk found empty; I never
  enumerated the `ReadPostView` COMPOSITIONS, so the workspace pane, the note window and the paged
  book inherited the lane without my having weighed them. The OUTCOME is still the spec-defensible one
  — those pages had the same defect (prose at 8 pt, decorations clamped at 2) and "nothing covers
  text" is R-Q4's clause — but "a Read page's measure may shift 64 pt per note" is a face decision no
  ruling makes, and I should have filed it rather than let it ride on R-Q4's letter. QUESTIONS #102
  PROVISIONAL with the three options is right; I have no product view to add beyond noting that
  reserving ALWAYS on the read tier would cost every uncommented note 64 pt of measure, which is why
  the shipped arm is the defensible one to leave in place while she decides.
- **NIT-1 · AGREE.** My `MARK` + lane block was inserted immediately above `var onWidthChange`
  (`PaneSurface.swift:594`), so its three-line doc ("Fires when layout gives the view a NEW width…")
  now sits above my MARK, describing nothing. My insertion, my orphan.
- **NIT-2 · AGREE.** `reservesDecorLane` (`EditorTextView.swift:388–393`, and its twin) is a
  get/`set` pair — the factories write it — and the sentence says "Read-only view of the opt-in". The
  sentence is wrong, not the code.
- **NIT-3 · AGREE.** `own: 4` at `BlockDecor.swift:761` is the badge's air to the TEXT, while
  `decorAir` (= 4) names the badge's air to the CARD, and only the latter appears in
  `commentLane`'s arithmetic — two different gaps that happen to be the same number, one named and one
  literal. Naming it (`commentBadgeAir`) is F-0's letter and keeps the arithmetic's terms
  distinguishable.
- **NIT-4 · AGREE that it is a duplication; the reviewer's "optional" is the right call, and here is
  what I traded.** The two `setDecorLane` bodies are byte-identical and could live in
  `extension DecorLaneSurface where Self: NSTextView` — but only over a requirement that exposes the
  stored `lane` as settable on the protocol, which widens the seam: any adopter (and any future one)
  could then rewrite the reservation, where today `lane` is `private` in each class and the brain is
  the only writer. I took three duplicated lines over a wider protocol surface, knowingly, and said so
  in the record ("three-line adopters"). If the reviewer prefers the extension, an
  `internal(set)`-style narrowing is not expressible on a protocol requirement, so the honest shape
  would be a `func laneReservation() -> inout`-free accessor pair — more machinery than the three
  lines it removes. The reviewer has the final word.

- The 64-vs-"~40" observation (J5) is arithmetic, not a ruling; the doc carries it term by term.
- Sync-shape, schema, core, `Shared/`: untouched, as recorded. No commit trailers on any of the ten
  commits (checked).
- The `min`-clamp in both badge overlays is why R1-3 is architectural rather than a bug today.

**Counts:** 0 BLOCKER · 1 MAJOR (R1-1) · 5 MINOR (R1-2 … R1-6) · 4 NIT.

#### Reviewer's dispositions + fixes (round 1)

*(The cross-model flow's final word, made in the reviewer's own session after the implementer's
10/10 agree pass (`0b4e7fac`). Every bug-class fix below landed with its pin and a RED-ON-OLD number
measured by BEHAVIORAL REVERT — the pre-fix source file(s) restored from `b84336bf` via `git show`
onto the committed tree, the pin run red, the file(s) restored by `git checkout --`, the tree verified
diff-clean and the suite re-run green before the next commit. Commits per finding, path-scoped, plain
messages, pushed after each. `Sources/`, `App/Variorum/Shared/`, `Sync/`, `BlockRangeIndex`,
`PaneTextAuthority`: untouched (`git diff --stat b84336bf..HEAD -- Sources App/Variorum/Shared` is
empty). Zero app instances at `/Applications` at every timing run.)*

- **R1-1 · MAJOR · CONFIRMED-FIXED — `4e21cde0`.** The lane is a REFLOW, so each contained host's
  prose-column door is its reflow door: `ReadPostViewModel.proseColumnDidChange()` = `remeasure()`
  (publishes the re-wrapped height AND re-reads the ⑂ badges' fragment positions AND re-sends the
  decorations — `remeasure` → `refreshBadges` → `refreshDecor`; the decor gate opens on its own since
  the state's `textLeft` moved), wired at `ReadPostView.swift`'s `install` in place of
  `pushOverlaysToSinks` (which re-sent decorations only and pushed the badges from STORED pre-lane
  state — the implementer's own re-trace, adopted: `remeasure` is strictly better than a
  composition there); the inline coordinator composes its `remeasure()` onto the model's door after
  the controller is built (`EditorView.swift`, `InlineEditorSurface.Coordinator.install`) — the
  implementer's correction that the inline half is NOT transient is accepted (`presentationsByBlock`
  / `commentsByBlock` are `@ObservationIgnored`, so no SwiftUI pass follows a comment; the heal waited
  for her next keystroke). **Pins (loop-driven, the R1-5 shape):**
  `BlockDecorLaneTests.theReadTiersLaneReMeasuresItsHeightThroughTheProductionLoop` — the REAL
  `ReadPostSurfaceCoordinator.install`, the comment written through `Operations.addBlockComment` and
  delivered by the model's own decor-context observation, then the surface READ: published height ==
  measured (±0.5), grown by lines (non-vacuity: a 220-word paragraph at 600 pt), the badge's FINAL
  `maxX ≤ proseLeft`; `…theContainedEditorsLaneReReportsItsHeightThroughTheProductionLoop` — the real
  `InlineEditorSurface.Coordinator.install` with its height report captured as `makeNSView` captures
  it, the comment through `adoptComments`. **RED ON OLD (behavioral revert of `ReadPostView.swift` ·
  `ReadPostViewModel.swift` · `EditorView.swift` to `b84336bf`, the two pins run):** read tier
  **`contentHeight 448.0` vs measured `516.0`** (68 pt — four lines outside the frame) and inline
  **reported `448.0` vs measured `499.0`** (51 pt — three lines), each the ONLY failing expectation
  in its pin: the lane arrived, the badge stood in it, the height stayed behind — the traced
  mechanism in numbers (`scratchpad/…`, local). Restored, diff-clean, re-run green.
- **R1-2 · MINOR · CONFIRMED-FIXED — `a536e216`.** `DecorLaneReservation.reserve` measures "nothing
  changed" against the surface's RESTING leading inset (`inlineInset(needsLane: false)`), never against
  "never asked"; a released lane returns `insets` to nil, so the `textContainerOrigin` override defers
  to `super` exactly while no lane is reserved (the implementer's second half — correctness by
  coincidence — fixed with it). **Pin:** `BlockDecorLaneTests.theFirstLanelessAskReportsNoMovement`
  (both surfaces: the first two laneless asks report nothing; reserve → release → the resting numbers
  and nothing to say). **RED ON OLD (behavioral revert of `DecorLane.swift` to `b84336bf`):** both
  surfaces **returned `true` on the first laneless ask** — 2 issues, `EditorTextView` and
  `PaneTextView` each. Restored, diff-clean, re-run green.
- **R1-3 · MINOR (architectural) · CONFIRMED-FIXED — `aa52961e`.** Both ⑂ badge overlays
  (`BadgeOverlayController.render`, `ReadBadgeOverlay.render`) read the prose column's right edge
  through the surface's ONE derivation (`proseRight`); `ReadBadgeOverlay`'s surface is typed
  `ReadPostTextView` (it always was one; no other construction site — grepped). **No pin owed, by the
  finding's own letter:** the `min(bounds − size − 8, columnRight + 6)` clamp makes the old and new
  numbers coincide today (580 + 6 vs 612 + 6 both lose to `bounds − size − 8` for any badge wider
  than ~26 pt), so a pin would pass on both sides and be hollow; the traced degradation — the next
  change to the lane's width or the trailing inset moving the ⑂ badge silently on exactly these two
  hosts, with no pin watching — is the justification, and the derivation is now the one the decor
  pass reads. The shipped badge pins ride unmodified (parity).
- **R1-4 · MINOR (cleanliness) · CONFIRMED-FIXED — `5ad571ed`.** The archived row passes the literal
  `nil` with the rule cited, as the stranded site already did; the purge door's help sentence lives
  ONCE per kind (`TrayRowVerbs.Purge.block(act:)` / `.take(act:)` over one private `door(_:act:)`),
  byte-identical to the shipped sentences. No pin (nothing observable changes; the face pin measured
  the archived row at `["Put back"]` before and after, the enumeration pin holds the rule).
- **R1-5 · MINOR · CONFIRMED-FIXED — rides `4e21cde0`.** The effect-level pins for W-1/W-2 are R1-1's
  two `…ThroughTheProductionLoop` pins (host door → re-measure → the badge's FINAL rect, on BOTH
  hosts, through the real coordinators); the two hand-fed pins stay as pins of the pure geometry with
  their docs corrected to say so, and the file header names the split.
- **R1-6 · MINOR · CONFIRMED-RECORDED — `d6cc8f30`, QUESTIONS #102 PROVISIONAL.** The lane on every
  Read page (the workspace's read-cheap pane, the note window, the paged book — all through
  `makeReadSurface`, not only the book Outline R-Q4 names) was an accident of scope, per the
  implementer's own answer; the shipped arm (a) is the spec-defensible one and stands while she
  decides; (b) always reserve on the read tier (one stable edge, 64 pt of measure lost on every
  uncommented note); (c) the Outline's alone with the other pages' comment count drawn by the
  composition. No code change. Owner: her word at the morning bundle; the line is named in the entry.
- **NIT-1 · CONFIRMED-FIXED — `d39b6100`** (the orphaned `onWidthChange` doc returned to its
  property). **NIT-2 · CONFIRMED-FIXED — `d39b6100`** (`reservesDecorLane`'s sentence).
  **NIT-3 · CONFIRMED-FIXED — `d39b6100`** (`BlockDecor.commentBadgeAir` named beside `decorAir`; the
  call site reads the constant; the test's own `own: 4` literals stay as the test's statement of the
  number).
- **NIT-4 · DISMISSED (the implementer's trade stands).** Folding the two byte-identical
  `setDecorLane` bodies into `extension DecorLaneSurface where Self: NSTextView` needs a settable
  `lane` requirement on the protocol, which widens the seam — any adopter could then rewrite the
  reservation, where today `lane` is `private` in each class and the brain is the only writer. Three
  duplicated lines that cannot drift (they call the one brain and write what it returns) are the
  cheaper of the two costs; recorded as a knowing choice in the file already ("three-line adopters").
  No change.

**Closing runs (this tree, `d6cc8f30`; zero instances):** the batch's closing set in ONE
`xcodebuild test` from `App/Variorum/` over the record's 57 type names + `InlineEditorWindowTests`
(whose harness the new pins lean on) → **`✔ Test run with 432 tests in 58 suites passed after
109.638 seconds`** — 58 suites for 58 names, zero `✘`, zero `skipped` matches in the log
(`scratchpad/closing-r1.log`, local; the record's 426/57 + the three new pins + the harness suite's
three). The ten touched suites (`BlockDecorLaneTests` · `ReadTierTests` · `InlineEditorWindowTests` ·
`TrayFilterTests` · `TrayPanelMoveTests` · `TrayPanelShapeTests` · `NoteTrayTests` ·
`BlockDecorGeometryTests` · `MarginHoverCommentTests` · `PaneSurfaceTests`) three times: **`✔ Test
run with 96 tests in 10 suites passed`** ×3 (7.49 s · 7.52 s · 7.59 s). Core `swift test` not owed
(`Sources/` diff-empty); the iOS build not owed (`Shared/` diff-empty).

**Round-1 tally:** 1 MAJOR fixed · 4 MINOR fixed (R1-2 · R1-3 · R1-4 · R1-5) · 1 MINOR recorded
(R1-6 → #102) · 3 NIT fixed · 1 NIT dismissed. **Commits:** `4e21cde0` · `a536e216` · `aa52961e` ·
`5ad571ed` · `d39b6100` · `d6cc8f30` (+ this record). No trailers. The tree is clean; `main` ==
`origin/main`. The implementer's sanity pass over `b84336bf..HEAD` is next; anything it raises
returns here for the final word.

#### Implementer's sanity pass (round 1)

*(One pass over `git diff 0b4e7fac..10da023a`, read whole; nothing run — every claim below is a
read of code already in the diff or a grep named at its line. **CLEAR: no defect found in the nine
fixes.** Two observations follow, both for the reviewer's final word, neither a fix I would ask for.)*

**(1) THE LOOP IS CLOSED, on both hosts, at exactly one extra cycle — as designed, and now with a
second independent gate behind it.** Read tier: `render` → `setDecorLane(true)` → true → next turn
`proseColumnDidChange()` → `remeasure()` → `refreshBadges()` → `refreshDecor()`
(`ReadPostViewModel.swift:317`) → `decorSink` → `render` → `setDecorLane(needed: true)`, where the
brain's guard is now `(insets?.leading ?? resting) != leading` = `72 != 72` → nil → **false → nothing
scheduled**. Contained editor: `onProseColumnChanged` = `{ modelDoor?(); remeasure() }`
(`EditorView.swift:541–545`) — `modelDoor` → `proseColumnDidChange` → generation bump +
`overlayLayoutDidSettle` (async) → `refreshDecorations` → `render` → the same false; and
`remeasure()` → `reportHeight` → the `@Binding height` → SwiftUI → `updateNSView` → `applyChrome`
(chrome-gated) + `coordinator.remeasure()` (same number, `abs(height − newHeight) > 0.5` false → no
write). **The lane is asked from exactly one place — `render` — so no other road can re-enter it**,
and behind the real-change guard each model's own `state != lastDecorState` gate would stop a
re-entry anyway. One third candidate cleared: the read tier's new `contentHeight` re-frames the
surface, but only its HEIGHT, so `PaneTextView.layout()` takes the same-width branch
(`PaneSurface.swift:583–596`) → the A47 divergence check → already converged. **One ordering nuance I
hold that the fix depends on:** on the inline host `remeasure()` runs SYNCHRONOUSLY *before* the
model door's async hop, and the inset write it measures against happened synchronously inside the
previous turn's `render` — so the measurement sees the re-wrap rather than racing it. That is not an
assumption: the reviewer's own red-on-old numbers (448 → 499 inline, 448 → 516 read tier) are a
measurement of exactly this, and the pins poll the published height against
`PaneMeasurement.height` rather than a settle count.

**(2) NO SURFACE STARTS LIFE AT A NON-RESTING INSET.** `resting` is
`inlineInset(needsLane: false)` = `inlineSurfaceInset` = 8, and both surfaces that set
`reserves = true` are born at exactly 8: `makeInlineEditor` (`EditorTextView.swift:916–918`) and
`makeReadSurface` (`PaneSurface.swift:690`, through `makeSurface(inset: inlineSurfaceInset)`). They
are the only two — grepped. **And nothing can move a contained surface's inset out from under the
brain**, which is the sharper form of the question: the writers of `textContainerInset` on the two
contained classes are `setDecorLane` (`EditorTextView.swift:406`, `PaneSurface.swift:571`),
`updateGutters` (`:588`) and the factories (`:850` the full editor at `minGutter` 28, `:916` inline at
8, `PaneSurface:690`) — and `updateGutters` early-returns unless `maxColumnWidth != nil`, which is
assigned in exactly ONE place in the target (`EditorTextView.swift:851`, inside `makeEditor()` — the
full editor, which reserves no lane). So the first ask reports correctly on both surfaces, and the
released state is consistent too: `reserve` returns the resting mean *and* clears `insets` in the
same call, and `setDecorLane` then writes 8 back to the view before anything reads it, so
`proseRight` = `bounds − 8` whether it answers from `insets.trailing` or from the inset fallback —
the same number by construction.

**Two observations, for the reviewer.**
- **(a) NIT-class, the flip side of R1-2's improvement.** The brain is now the sole source of truth
  for `originX`/`proseRight` and no longer reads the view's actual inset. Today that is strictly
  better (R1-2's own point). The residual it creates is a FUTURE one: a host that ever set
  `maxColumnWidth` on a contained surface — or wrote `textContainerInset` directly — would have
  `updateGutters` move the container while the brain kept answering from `insets`, leaving the decor
  self-consistent and the TEXT somewhere else. Impossible today by the grep above. One sentence in
  `DecorLaneReservation`'s doc, or a `precondition(maxColumnWidth == nil)` beside
  `reservesDecorLane = true`, would make it impossible by construction rather than by census. The
  reviewer's call; I would not hold the round for it.
- **(b) R1-4's copy is byte-identical, confirmed against the pre-fix strings.** `Purge.block` /
  `.take` over the one private `door(_:act:)` produces *"Ends this block's remaining days now. There
  is no putting it back afterwards."* and its take twin — the same sentences the two call sites
  concatenated before (they differed only in where the source line broke, not in content), so the
  face pins and `theLeavingSectionsDeleteNowConfirmsThenPurgesForGood` ride on unchanged text, as the
  reviewer states. Recorded because I wrote both originals and am the one who can say the wording did
  not drift.

**The rest of the diff, read and sound:** R1-3's two overlays now read `proseRight` and
`ReadBadgeOverlay`'s surface is typed `ReadPostTextView` (it always was one — `install(textView:)`
is its only door); R1-5's two hand-fed pins keep their honest claim with their docs corrected to say
which half they pin; NIT-1/2/3 are the three sentences and the one named constant
(`commentBadgeAir` beside `decorAir` — the two 4s are two named gaps now); QUESTIONS #102 records
R1-6 with the shipped arm marked PROVISIONAL, which is where I left it. NIT-4 dismissed — agreed.

#### Reviewer's final word (round 1)

*(The round-1 `fable-reviewer`, on the implementer's sanity pass above (`8e1c6d82`). One record
note first: the pass had been inserted at line 1102 — beneath BATCH A's round-1 dispositions —
rather than beneath this batch's; its 70 lines were moved here byte-for-byte, nothing else touched.
Two pieces, `1faf6b8b` and `17b650ae`, pushed; the tree clean.)*

- **The loop's closure and the resting-inset census — ADOPTED as read.** The implementer's two
  traces match mine: the brain's `72 != 72` on re-entry, the one ask site (`render`), the models'
  equality gates behind it; both contained factories born at 8; `maxColumnWidth` assigned in
  `makeEditor` alone. Nothing to change on those.
- **(a) CONFIRMED-FIXED (`1faf6b8b`), placed where the hazard is, not beside the opt-in.** The two
  writers of one inset are the lane brain and `updateGutters`; the hazard the implementer names is
  exactly their meeting, so the guard lives at the meeting: `updateGutters` refuses a laned surface by
  `precondition(!lane.reserves, …)` after its `maxColumnWidth` guard (inert on both contained
  surfaces, which never pass that guard; a boolean on the full editor's frame path), and
  `DecorLaneReservation`'s doc states the one-writer contract in the brain's own words. A
  `precondition(maxColumnWidth == nil)` beside `reservesDecorLane = true` would have been checked at
  construction — always true there, and blind to a later assignment; this one fires at the first
  frame of any future surface that takes both. No pin: a precondition cannot be pinned without an
  exit test, and the sweep table already holds "the full editor reserves no lane".
- **(b) CONFIRMED — byte-identical, three ways, and now PINNED (`17b650ae`).** The implementer's
  confirmation as the author of both originals; my mechanical check — the two pre-fix concatenations
  copied verbatim from `b84336bf`'s `TrayPanel.swift:992–993` / `:1122–1123` against the factored
  `door(_:act:)`: `block` → equal, `take` → equal (a five-line Python evaluation, both `True`); and
  the words themselves held in `TrayFilterTests.onlyTheLeavingViewsBlocksAndTakesMayEndTheirOwnClock`
  (`Purge.block(act:).help` / `.take(act:).help` against the shipped sentences), so a future edit to
  the one sentence is a visible choice, never a silent drift.

**Suite line (tree `17b650ae`; zero app instances by `pgrep` before the run):** `✔ Test run with 54
tests in 6 suites passed after 8.404 seconds` — `BlockDecorLaneTests` · `TrayFilterTests` ·
`TypewriterRoomTests` · `EditorTypographyTests` · `InlineEditorWindowTests` · `PaneSurfaceTests` (the
lane suite, the tray rule's suite, and the full-editor suites that drive `updateGutters` through
`makeEditor`'s frame path). Core and the iOS build not owed (`Sources/`, `Shared/` untouched
throughout the ladder).

**The ladder's round-1 residue for the orchestrator:** none open. All ten findings dispositioned
(R1-1 MAJOR fixed; R1-2 · R1-3 · R1-4 · R1-5 fixed; R1-6 recorded, QUESTIONS #102; NIT-1/2/3 fixed;
NIT-4 dismissed); the sanity pass's two observations both taken. No new BLOCKER/MAJOR surfaced at the
sanity pass, so under the ladder's rule round 2 is the fresh reviewer's re-review of the fixes —
`git diff b84336bf..17b650ae` (`4e21cde0` · `a536e216` · `aa52961e` · `5ad571ed` · `d39b6100` ·
`d6cc8f30` · `1faf6b8b` · `17b650ae`) — with this record (findings · responses · dispositions ·
sanity pass · this word) as its anchor. The dev-store leftovers the batch left for the ladder are
untouched.

### 17p batch b LADDER — ROUND 2 FINDINGS (fable-reviewer)

*(A FRESH cold reviewer's re-review of the round-1 fixes — `git diff b84336bf..17b650ae`, the eight
commits `4e21cde0` · `a536e216` · `aa52961e` · `5ad571ed` · `d39b6100` · `d6cc8f30` · `1faf6b8b` ·
`17b650ae` — read against the whole batch `48f54268..17b650ae` for what they touched, with the whole
batch-b thread above (findings · responses · dispositions · sanity pass · final word) as the anchor,
`notes/REVIEW_PROMPT.md` verbatim, §3 rows 3–6, §4.3–§4.4, §5.1, §7 R-Q3/R-Q4, §12 F-0/F-3/F-4, R-0,
the R-2 brief/record/adjudication, QUESTIONS #102, AppSpec §12 (R7/R9/R16/R17/R27) and TEXTKIT2_NOTES
§3–§4. Every mechanism below was traced by me, by reading — and where the claim was about the
platform, by measurement. Nothing delegated; the tree at `cd89ad12` == `origin/main`, clean; zero app
instances at `/Applications` throughout. The thirteen touched-and-leaned-on suites re-run on this tree:
`✔ Test run with 113 tests in 13 suites passed after 9.797 seconds` (`BlockDecorLaneTests` ·
`TrayFilterTests` · `TrayPanelMoveTests` · `TrayPanelShapeTests` · `NoteTrayTests` ·
`CalloutEmojiPickerTests` · `ReadTierTests` · `InlineEditorWindowTests` · `PaneSurfaceTests` ·
`TypewriterRoomTests` · `EditorTypographyTests` · `BlockDecorGeometryTests` · `MarginHoverCommentTests`;
`scratchpad/r2-touched.log`, local). Format: `R2-n · severity · file:line · what · evidence · fix`.)*

#### Findings, severity-ranked

**No BLOCKER. No MAJOR. No MINOR.** Three NITs, all in the register R1-4 opened — none owes a pin
(nothing observable changes), none re-opens a ruling, and under the ladder's rule none opens a round 3.

- **R2-1 · NIT · `App/Variorum/Variorum/Features/Tray/TrayPanel.swift:1169–1171` (the `row(...)`
  builder's `deleteNow` doc) · The sentence "The three call sites in `cellRows` consult that one rule"
  has been false since R1-4 (`5ad571ed`).** · *Evidence:* the leaving-block site (`:990`) is the only
  `row(...)` caller that consults `TrayPurgeDoor.offered`; the archived site (`:1016`) and the stranded
  site (`:1038`) pass the literal `nil` with the rule cited in a comment — which is exactly the road
  R1-4 chose and the file's own comments now explain. The builder's doc still describes the pre-R1-4
  shape. · *Fix:* the sentence — one site consults the rule; the two whose answer the rule fixes at nil
  write the literal and cite it.

- **R2-2 · NIT · `App/Variorum/Variorum/Features/Tray/TrayPanel.swift:1237` (`TrayRowVerbs.Purge
  .init(help:act:)`) · R1-4's "the help sentence lives ONCE per kind" holds by census, not by
  construction.** · *Evidence:* the memberwise-shaped `init(help:act:)` stays internal and its only
  caller is the private `door(_:act:)` (grepped — both row sites use `.block(act:)` / `.take(act:)`
  since `5ad571ed`), so a fourth row type could still hand in a fourth sentence. · *Fix:* `private
  init` — the factories become the only door. (Noted beside it, no change asked: the leaving-block
  site's `: nil` arm at `:990–992` sits inside `if model.view == .leaving` where
  `offered(.block, view: .leaving)` is true by construction — the mirror of R1-4's dead branch, harmless,
  and the rule's one live consultation in the file.)

- **R2-3 · NIT (cleanliness; hollow today — no pin owed, optional) · `App/Variorum/Variorum/Surface/
  DecorLane.swift:87–90` (`reserve`'s `resting`) · The brain's one-writer contract ("both contained
  factories are born at the resting inset the brain measures against") is enforced by the census of two
  factories and one pin, not by the brain.** · *Evidence:* `resting` is read from the global
  `EditorTypography.inlineInset(needsLane: false)` while `trailing` arrives from the adopter as
  `inlineSurfaceInset` — the same number by two roads (`EditorTextView.swift:402`,
  `PaneSurface.swift:567`). A future contained adopter born at another inset would have its first
  laneless ask report a false move and be RELEASED to 8 rather than to its own inset; today no such
  adopter exists (`theFirstLanelessAskReportsNoMovement` pins both factories at 8), so a pin would pass on
  both sides. · *Fix (if wanted, one parameter):* the adopter hands the brain its resting inset once
  (`DecorLaneReservation(reserves:resting:)`, the trailing being that same number at rest by
  `textContainerInset`'s own symmetry), and the constant read goes.


#### Considered and cleared (traced; measured where it mattered)

- **R1-1 on the READ tier (`ReadPostView.swift:184–186` → `ReadPostViewModel.proseColumnDidChange`
  `:294–296` = `remeasure`):** the loop terminates where the final word says — `remeasure` →
  `refreshBadges` → `refreshDecor` → the state's `textLeft` moved (8 ↔ 72) → sent → `render` →
  `setDecorLane` → the brain's `(insets?.leading ?? resting) != leading` reads `72 != 72` → nil → false,
  nothing scheduled. **The async hop's re-measure reads the re-wrapped layout regardless of any display
  pass:** `PaneMeasurement.height` enumerates with `.ensuresLayout` (`PaneSurface.swift`, the ONE
  measurement brain), so it forces the narrowed container's layout itself. The read tier's decor walk is
  WHOLE-post (`refreshDecor`, no viewport pruning), so nothing is left out by the frame growing later;
  the height re-frame (`ReadPostView.swift:75`) drives `PaneTextView.layout()` down its same-width
  branch, whose `onLayoutPass` the read tier never wires (`install` wires `onWidthChange` only) — no A47
  re-entry. The RELEASE road traced too: comments gone with a plain callout left → S1 (72) sent → release
  → hop → S2 (8) sent → card redrawn at 8 → false; comments gone with nothing decorated → `State()` sent
  once, then equal — and `refreshBadges` re-reads the ⑂ badges at the wider column either way.
- **R1-1 on the INLINE host (`EditorView.swift:542–546`):** the one ordering question the fix depends
  on, MEASURED rather than assumed. `EditorViewModel.viewportBounds(of:)` (`:3290–3293`) returns
  `textView.bounds` for the inline editor, and `refreshDecorations` drops any block whose frame misses
  that window (`:3163`) — so if the model's settle hop (scheduled by `proseColumnDidChange` INSIDE the
  lane hop) ran BEFORE SwiftUI applied the re-reported height, a tail block pushed below the pre-lane
  height by the re-wrap would lose its decorations until the next trigger. It does not: a main-queue
  block dispatched from inside a main-queue block runs AFTER the runloop's BeforeWaiting observers
  (`beforeWaiting → A → beforeWaiting → B → beforeWaiting → C`, `scratchpad/drain-order.swift`, an
  NSApplication runloop with a `kCFRunLoopBeforeWaiting` observer), which is where SwiftUI/CA commit
  the `height` binding write into the view's frame — so the settle hop reads the grown bounds. The
  batch's inline pin, which sets the frame synchronously inside `reportHeight`, is therefore a faithful
  stand-in for the production commit. **The mount case is covered by a different road than the doc
  describes:** `BlockDecorOverlayController`'s convenience init pushes decorations
  (`BlockDecor.swift:471`) BEFORE the coordinator composes its door (`EditorView.swift:542`), so a note
  opened ALREADY commented reserves the lane under the model-only door — and `install`'s trailing
  `remeasure()` (`:563`) then measures the already-narrowed container (`.ensuresLayout`) and reports
  the laned height. Correct; noted so the next reader does not hunt for the composed door there.
- **R1-2 (`DecorLane.swift:85–92`):** the four cases of (`insets`, `needed`) traced — nil/false → nil;
  nil/true → (72, 8), mean 40; (72, 8)/true → nil; (72, 8)/false → nil, mean 8, the adopter writes 8 —
  and the override defers to `super` exactly while `insets` is nil (`originX`). Inside `setDecorLane`
  the brain mutates before the inset write and nothing reads between the two statements.
- **R1-3 (`EditorView.swift:693`, `ReadPostView.swift:253`):** on the FULL editor `proseRight` is
  `bounds − textContainerInset.width` by identity (`insets` nil) — the shipped ⑂ badge pins ride
  unmodified, as the disposition says; `ReadBadgeOverlay`'s only construction site hands it a
  `ReadPostTextView` (grepped, app and tests).
- **R1-4 (`TrayPanel.swift:990–992` · `:1016` · `:1038` · `:1244–1257`):** the factored sentences
  equal the pre-fix concatenations (the `17b650ae` pin holds them; re-derived from `b84336bf`'s two
  sites in the diff); the archived branch is the `else` of `if model.view == .leaving` (`:978`), so the
  literal nil states the truth; the take site keeps its rule consultation.
- **The sanity pass's (a) (`EditorTextView.swift:585–596`):** the precondition sits AFTER `guard let
  maxColumnWidth`, and `applyFrameHeight` calls `updateGutters()` on every frame of every
  `EditorTextView` (`:485`, `:501`) — inert on the inline editor by that guard, a boolean on the full
  editor's path; `maxColumnWidth` is assigned in `makeEditor` alone (`:862`) and no test assigns it to
  an inline editor (grepped `VariorumTests`).
- **The sanity pass's (b):** pinned words, green here.
- **A pending hop after dismantle cannot misfire:** `render` captures `onProseColumnChanged` strongly
  into the hop; after `uninstall` the read tier's `remeasure` guards on the detached `textView`
  (`detach` nils it), and the inline coordinator's `remeasure` guards on its weak `textView` with
  `reportHeight` nilled by `uninstall` (`EditorView.swift:571–580`).
- **NIT-1/2/3 (`d39b6100`):** the `onWidthChange` doc is back on its property (`PaneSurface.swift:591–594`);
  `reservesDecorLane`'s sentence matches its get/set; `commentBadgeAir` is read at the badge site
  (`BlockDecor.swift:762–764`) and the constant's doc says why it is not `decorAir`.
- **R1-6 → QUESTIONS #102:** the entry carries the three options with (a) marked PROVISIONAL and names
  the one line (`makeReadSurface`) and the sweep pin that changes with the answer. A note beside it, not
  a finding: the Outline's read tier sits in `StableSurface(followsShrinks: false)` (`BookView.swift`,
  18d), so a lane RELEASE — a shrink — is followed on that wrapper's own settle terms, exactly as any
  content shrink is; 18d's standing semantics, untouched here.
- **Cost (P1):** one extra whole-post measure + decor pass per lane TRANSITION per contained surface,
  ∝ the post; the settled state costs one comparison per render (the brain's guard). `PaneMeasurement`'s
  doc already names `ReadPostViewModel.remeasure` and the inline coordinator's as its two whole-post
  sites.
- **Record integrity:** the relocated sanity pass (`e4568ba2`) is byte-identical to `8e1c6d82`'s block
  (diffed against lines 1106–1171 there — only my range ends differ); the batch-b thread stands in
  order; LIVE STATUS names this round.
- **Sync/schema/core/Shared:** `git diff --stat 48f54268..17b650ae -- Sources App/Variorum/Shared` is
  empty; no `setting`, no column, no `Sync/`; no `Co-Authored-By`/`Claude-Session` line on any of the
  eight commits (checked).

#### Review foci (§12), addressed

- **F-0 (no god brain, no god file):** the fixes layered on — 11 lines on `ReadPostViewModel`, a
  composed closure on the inline coordinator, 28 on the brain, five on `TrayRowVerbs.Purge`; the two
  drift pairs round 1 named are closed (R1-3's second prose-right derivation; R1-4's sentence), and
  R2-2/R2-3 are the structural residue of those closures — census where construction is one line away.
  No literal number-as-rule was added; `commentBadgeAir` named the last one.
- **F-3 (ONE constant + ONE decision; the emoji's placement ONE rule; no `exclusionPaths`; no
  rendering attributes):** unchanged by the fixes and still true — `commentLane` + `inlineInset(needsLane:)`,
  `calloutGlyphRect` for both surfaces; the fix diff carries zero `exclusionPaths`, zero rendering
  attributes, zero paragraph-style writes (grepped). The reflow's height half round 1 found missing is
  now on both hosts through the production loop. SATISFIED.
- **F-4 (the tray reuses the take row's confirm and purge road):** unchanged and still one road; the
  help sentence is one per kind (R2-2 would make that structural). SATISFIED.

#### CLEAN BILL — checked and found solid

- R1-1 is FIXED as traced: on both contained surfaces the lane takes a reflow's whole road (height,
  ⑂ badges, decorations), the loop-driven pins measure the surface rather than a hand-built state, the
  loop terminates at the brain's equality, and the one platform assumption the inline half rests on
  (the commit precedes the settle hop) is measured true.
- R1-2 · R1-3 · R1-4 · R1-5 · NIT-1/2/3 and the sanity pass's (a)/(b) are fixed as their dispositions
  say; R1-6 is recorded as ruled; NIT-4's dismissal stands on its stated trade.
- Her R-Q3's letter (leaving blocks and takes yes; stranded originals never; archived never) and R-Q4's
  (the badge in the lane, the glyph inside the frame, the trailing inset untouched, comments on the left)
  hold in the geometry, the enumeration and the pins on this tree.

**Round-2 tally: 0 BLOCKER · 0 MAJOR · 0 MINOR · 3 NIT (R2-1 · R2-2 · R2-3).** No new BLOCKER/MAJOR, so
under the ladder's rule no round 3 is owed; the three NITs go to the implementer for agree/dispute and
return here for the final word and the fix pass (each a sentence or a keyword; no pin owed).

#### Implementer's responses (round 2)

*(Tally: **3 findings — 3 agree, 0 dispute.** All three verified at their lines; no code changed.)*

- **R2-1 · AGREE.** My sentence, stale since the reviewer's own R1-4 fix: `TrayPanel.swift:1169–1170`
  still reads "The three call sites in `cellRows` consult that one rule" while only the leaving-block
  site (`:990`) does — the archived (`:1016`) and stranded (`:1038`) sites now write the literal `nil`
  and cite the rule in a comment.
- **R2-2 · AGREE.** `Purge.init(help:act:)` (`TrayPanel.swift:1237`) is internal and its only caller
  is the private `door(_:act:)` (`:1252`), so "once per kind" is a census; `private init` makes the
  two factories the only door and the sentence true by construction.
- **R2-3 · AGREE that the contract is census-not-construction, and it is the SAME class as observation
  (a) of my round-1 sanity pass** — the brain (`DecorLane.swift:87`) reads `resting` from the global
  while `trailing` arrives from the adopter (`EditorTextView.swift:402`, `PaneSurface.swift:567`), so
  both of the brain's assumptions about its adopters rest on a two-factory census; handing the resting
  inset in once (`DecorLaneReservation(reserves:resting:)`) closes this and most of that one. Hollow
  today by the standing rule (the pin passes on both sides — `theFirstLanelessAskReportsNoMovement`
  pins both factories at 8), so I would take it as cleanliness or leave it; the reviewer's call.

#### Reviewer's dispositions + fixes (round 2)

*(The cross-model flow's final word, made in the round-2 reviewer's own session after the implementer's
3/3 agree pass (`51f2da42`). One record note first: the responses had been inserted INSIDE this round's
findings section — between the findings and the considered-and-cleared list — and were moved here
byte-for-byte, beneath the whole section, exactly as round 1's final word moved the misplaced sanity
pass; nothing else touched. Commits per finding, plain messages, pushed; `Sources/`,
`App/Variorum/Shared/`, `Sync/` and the editor seam untouched — the two fixes are one doc sentence and
one access keyword in `TrayPanel.swift`. Zero app instances at `/Applications` at every run.)*

- **R2-1 · NIT · CONFIRMED-FIXED — `d5602ae7`.** The `row(...)` builder's `deleteNow` doc now says
  which site consults the rule (the leaving-block site) and which two write the cited literal nil (the
  archived and stranded sites), and why — R1-4's own letter. No pin: a sentence.
- **R2-2 · NIT · CONFIRMED-FIXED — `c3918e48`.** `TrayRowVerbs.Purge.init(help:act:)` is `private`;
  `.block(act:)` / `.take(act:)` over the private `door(_:act:)` are the only door in, so "the sentence
  lives once per kind" holds by construction. Every existing site compiles unchanged (both row sites and
  the sentence pin use the factories). No pin: nothing observable.
- **R2-3 · NIT · DISMISSED on re-check — my own finding, and the implementer's "cleanliness or leave
  it" taken as leave it, for a reason the finding did not weigh.** The one-parameter shape it proposed —
  the adopter hands the brain its resting inset and the constant read goes — would have the brain
  compute the LANED leading as `resting + commentLane` itself: a second copy of F-3's ONE decision
  (`EditorTypography.inlineInset(needsLane:)`), the exact drift class the focus forbids. Keeping the
  decision whole means the brain consults it for BOTH arms, and its `false` arm IS the resting inset —
  so the "constant read" is the decision consulted, not a second rule; the `trailing` the adopters pass
  is that same constant by name. A future contained adopter at another inset would need the DECISION to
  take an inset parameter, a change with no consumer today. Hollow by the standing rule
  (`theFirstLanelessAskReportsNoMovement` holds both factories at 8 on both sides of any such change)
  and, as shaped, a net loss for F-3 — recorded, not fixed. The brain's doc already states the
  one-writer contract and the census behind it; the implementer's round-1 observation (a) stays closed
  by `1faf6b8b`'s precondition.

**Suite lines (tree `c3918e48`; zero instances by `pgrep` before each run):** the touched tray family +
the lane suite, once — `✔ Test run with 62 tests in 5 suites passed after 1.817 seconds`
(`TrayFilterTests` · `TrayPanelMoveTests` · `TrayPanelShapeTests` · `NoteTrayTests` ·
`BlockDecorLaneTests`); the batch's CLOSING SET, ONCE, in one `xcodebuild test` from `App/Variorum/`
over round 1's 58 type names — **`✔ Test run with 432 tests in 58 suites passed after 109.450
seconds`**, 58 suites for 58 names, zero `✘`, zero `skipped` matches in the log
(`scratchpad/r2-closing.log`, local). Core `swift test` and the iOS build not owed (`Sources/`,
`App/Variorum/Shared/` untouched throughout the ladder).

**Round-2 tally:** 2 NIT fixed (R2-1 · R2-2) · 1 NIT dismissed on re-check (R2-3). The implementer's
sanity pass over the two fixes is waived by the orchestrator (its follow-up: three NITs, not worth the
context) — recorded here; nothing loops after this word. **Last code hash: `c3918e48`.**

**Open after round 2: none.**

---

### 17p — LETTER CLOSEOUT (the orchestrator, 2026-09-12, the overnight run; both ladders capped or closed)

**What shipped (two batches + two Fable ladders, `2bfc8461..c3918e48`):** the Takes board's article opens where she left it — the BLOCK at the top of the page remembered per note for the session (`EditorRouter.takesArticlePlaces`), the top itself a place of its own, restored by one absolute idempotent `scrollTo(row, anchor: .top)` re-aimed until the row says so — and an entry landing only REVEALS (never a top anchor; a bounded step machine on `TakesBoardLayout` that waits for laid-out rows, aims by direction at an unrealized one, re-aims through the settling passes and ends at HER HAND — every gesture that can change the article's content height, its viewport height or the live pane, armed at the view model's gesture doors, the road table its completeness proof); an empty block in Takes is an empty LINE with the caret (R103's face retired, its substance kept) and the ＋ new block door stands on the prose's edge (a); This Note's Tray's leaving BLOCK rows carry Delete Now through the take rows' own confirm and purge road (one rule `TrayPurgeDoor`, one face `TrayRowVerbs`); the Callout Emoji alert's field has room to type (it measured 0 pt); the comment badge and the callout glyph never cover text on the contained surfaces — ONE decoration lane (`Surface/DecorLane.swift`, `EditorTypography.commentLane` = 64) both the book's inline editor and the read tier adopt, the glyph inside its own card, each host's prose-column door its reflow door (b). Her rulings R-Q1…R-Q4 built to the letter; no product invention beyond QUESTIONS #102 (PROVISIONAL).

**Dispositions (the ledger rows 17p owns — every row FIXED with its named pin; nothing DISMISSED AS HOLLOW, nothing DEFERRED; row 7 RETIRED to the mobile session at her word):**
- **a — the Takes board** (`ee1f1f5a..066e2588` + the adjudication `da75fd47` + its three-round Fable ladder to `e78bc896`): **row 1 FIXED** (`TakesArticleScrollTests.aThreeBlockNoteEnteredOnItsLastBlockOpensAtTheTop` red-on-old 86.0 where 0 is owed · `…aBoardLeftScrolledComesBackWhereSheLeftIt` the remount at 0 where 120 was left · `…aBoardLeftAtTheTopComesBackAtTheTop` 18.0 → 0 · `…aLongNoteEnteredOnAFarBlockRevealsItWithoutHaulingItToTheTop` offset 0 and the row never realized → revealed at the foot · the her-hand set `herBoardGesturesEndAPendingLanding` + the six mounted face pins, 65 → 97 / 65 → 75 / 65 → 93 → unchanged) · **row 2 FIXED** (`TakesEmptyBlockFaceTests.anEmptyBlockShowsNoPlaceholderWords` red-on-old `["empty take — line kept"]` where `[]` is owed · `…theNewBlockDoorsEdgeSitsOnTheProsesEdge` 210.0 vs 218.0). Walked: captures `05`–`11` in `…-screens/17p-a/`.
- **b — the chrome singles** (`52c9e891..b84336bf` + its Fable ladder to `c3918e48`): **row 3 FIXED** (`TrayFilterTests.theLeavingBlockRowDrawsBothVerbsAndTheOtherRowsDrawOne` red-on-old `["Put back"]` where both verbs are owed · `TrayPanelMoveTests.aLeavingBlockRowsDeleteNowConfirmsThenPurgesForGood` `pendingPurge → nil`) · **row 4 FIXED** (`CalloutEmojiPickerTests.theEmojiFieldHasRoomToTypeIn` red-on-old `field.frame.width → 0.0`) · **rows 5 and 6 FIXED** (`BlockDecorLaneTests.aCommentedCalloutWithAGlyphCoversNoTextAndNothingElseEither` red-on-old the badge `(2,10,32,16)` and the glyph `(6,10,18,17)` both ∩ the prose `(8,10,604,34)` · the three-host sweep table `…everyDecoratedSurfaceHasItsLaneAnsweredOneWayOrTheOther` · the loop-driven effect pins through the real coordinators, 448 vs 516 / 448 vs 499 · the parity pin `…writesMarginCardAndPlainCalloutAreWhereTheyShipped`). Walked: captures `01`–`14` in `…-screens/17p-b/` (`06` the before).
- **row 7 — RETIRED** to the mobile session (her R-Q9; the `mobile` branch's handoff §12.2 + §12.2a; PL-22).

**The ladders:** **batch a (Fable, three rounds — the cap):** round 1 (0 BLOCKER · 3 MAJOR · 3 MINOR · 3 NIT; 9 agreed · 0 disputed; all fixed by the reviewer; the sanity pass's slot-height drag fixed; the her-hand rule written) → round 2 (1 MAJOR new — three bare-runner doors outside the rule, "by construction" falsified by a full road table; fixed) → round 3 (1 MAJOR new — the ⌘-click pick's banner shrinking the article's VIEWPORT, a third seam; 1 NIT; both fixed; every sanity pass CLEAR). **batch b (Fable, two rounds — no round 3 owed):** round 1 (0 BLOCKER · 1 MAJOR · 5 MINOR · 4 NIT; 10 agreed · 0 disputed; nine fixed by the reviewer, NIT-4 dismissed as the implementer's trade, R1-6 → QUESTIONS #102; the sanity pass CLEAR, its two observations taken — a one-writer precondition and a byte-identity pin) → round 2 (0 BLOCKER · 0 MAJOR · 0 MINOR · 3 NIT; 3 agreed · 0 disputed; R2-1 and R2-2 fixed by the reviewer, R2-3 DISMISSED on the reviewer's own re-check as hollow and a net loss for F-3; the implementer's sanity pass on three nits WAIVED by the orchestrator, recorded).

**Finals over the letter's last code tree (`c3918e48`):** batch a's 38-suite closing set 266/38; batch b's closing set 432/58 (round 1) → `✔ Test run with 432 tests in 58 suites passed after 109.450 seconds` on `c3918e48` (round 2). Core 1503/163 and the iOS build UNCHANGED (`Sources/`, `App/Variorum/Shared/`, `Sync/`, `BlockRangeIndex`, `PaneTextAuthority` diff-empty across the letter); the FULL Mac suite runs at the round's close. No commit trailers.

**Canon deltas APPLIED in this commit:** `notes/AppSpec.md` §12's takes-presentations line — R-Q2 supersedes the FACE of R103 (an empty block in Takes is an empty line); `notes/plans/phase-13-ui-design.md` R103 — the dated supersession sentence; `notes/KnownIssuesAndTechDebt.md` — the R1-7 row AMENDED (the tutorial spine's `takesViewMemory` instance; the two suites on their own defaults) and TWO rows owned by 13u2 (the kept-alive landing's enumerated her-hand set with option (b)'s three-seam arm as the design and the reflow discriminator beside it; the decoration lane's two residuals — Write at `minGutter`, the multi-glyph clip); `notes/QUESTIONS.md` #102 (the lane on every Read page, PROVISIONAL). **Her morning items from this letter (the handoff carries them):** J3 (restore-then-reveal on a long note — one condition if she wants it), J5 (the 64 pt lane and its two levers), #102, the multi-glyph clip (what "a leading glyph" means), the recurrence signal on the landing family (six surfacings — option (b) at the 13u2 split).

**The 17 register row flips to CLOSED with this block copied into `notes/plans/phase-17-standing-fixes.md`.**

---


### R-3 · 18h batch 1 — BRIEF (TIME: created/edited stamps in the Library rows and the note's masthead; the Library sortable by time) — written by the orchestrator 2026-09-12

**Spawn:** `opus-implementer`. **Review after:** `opus-reviewer`. **One acceptance unit:** the Library's List/Notes rows + header, and the masthead's stamp — ONE theme (time), two faces over one core column. **Rows:** ledger 9 · 10. **Her rulings (§7, SETTLED):** R-Q7 (a quiet stamp at the trailing end of the masthead's second row — "edited today 1:33 AM" / "edited Sep 9" — a click flips to "created …", a click again returns; the Library rows get a muted trailing stamp) and R-Q8's first half (the sort; the day search is batch 2, R-4).

**CORRECTION to §4.7/§4.8 (found while drafting this brief):** the Library surface in her image 4 is `LibraryCatalogView` over `LibraryCatalogModel`, whose listing is `Queries.searchCatalog` (`Sources/VariorumCore/Queries/ShelfQueries.swift:367–458`) — ONE-SHOT per typed query, `limitPerKind: 40`, posts `ORDER BY COALESCE(last_touched_at, created_at) DESC, id DESC` — NOT `observeLibrary`/`LibraryViewModel` (that pair serves the older folder listing). `CatalogHit` (`:325–352`) carries `detail` = the entry date and NO stamps. So the sort and the stamps ride `searchCatalog`.

**Read first, yourself:** `CLAUDE.md` + canon (AppSpec §10 — the two stamps and what each means; §12's Library line; the no-denormalization rule); this plan's §1 (Q-7, Q-8), §3 rows 9–10, §4.7–§4.8 (with the correction above), §7, §8–§9, R-0; `notes/plans/phase-17-standing-fixes.md`'s rules (the pin discipline binds product batches too).

**Pointers (verified against `8eaeeb3d`; re-grep):**
- **Core (its own commit, FIRST):** `Queries.searchCatalog` gains `sort: LibrarySort = .lastTouched, direction: SortDirection = .desc` applied to the POST arm's ORDER BY (books stay by name; blocks by `updated_at`); `LibrarySort` (`Queries/Timeline.swift:97–108`) gains `.title` (`COALESCE(NULLIF(title,''), entry_date, created_at) COLLATE NOCASE` — the display-title order; pinned); `CatalogHit` gains `createdAt: String?` and `lastTouchedAt: String?` (nil-defaulted — every caller and pin compiles unchanged); `Queries.noteStamps(_:postID:)` or the note-header observation the masthead already holds gains the two stamps if it lacks them (grep `noteDisplayTitle` / the header observation in `EditorViewModel.swift:~600–620` — a held observation, never a one-shot: the 17o row-18/19 lesson). Pins: `swift test` state pins per sort/direction on a three-note fixture with distinct stamps; the title order; the stamps present.
- **The sort menu:** `LibraryCatalogView.swift:690–735` (the header's search field + the scope and mode pickers) — a `VoicedMenu` "sort ▾" (`Theme/VoiceControls.swift`) with edited · created · date · title and a direction row; `LibraryCatalogModel` (`:29–62`) holds `sort`/`direction`, remembered in `UserDefaults` (the `readModeOutlineShown` class — local UI state, never synced), and `search()` (`:161–180`) passes them. The Timeline mode keeps its own order (it is the timeline).
- **The row stamps:** the List row's line `CatalogNoteLine` (`:1300+`, `date:` today = `hit.detail`) gains a trailing muted stamp — RIGHT-aligned after the `Spacer()` — reading the SORT's own stamp (edited under edited/title, created under created, the entry date under date), worded by ONE pure brain `TimeStampFace.relative(iso:now:)` → "today 1:33 AM" · "yesterday" · "Sep 9" · "Sep 9, 2025" (tooltip: the full date-time); the Notes card's date line (`:872–935`, the Apple-Notes-shaped row) reads the same brain. The row-alignment pin (`LibraryRowAlignmentTests`) must ride: the stamp shares the line's first-text baseline.
- **The masthead stamp:** `PostDetailView.swift:298–318` (`MastheadRowTwo` — chip + tag cluster, width-aware; its pure `arrangement` pin in `MastheadLayoutTests`) — the stamp is a THIRD, trailing, quiet subview: on ONE line it sits at the cluster's trailing end (before the ⌗ door's line end — decide by reading `MastheadTagCluster`'s trailing flow and put it where the row's right edge stays calm); on TWO lines it rides the chip's line's right end. A `Button` styled `VoicedButtonStyle(.quiet)`, `lineLimit(1)`, `fixedSize()` (P-8), toggling `edited …` ↔ `created …` on click (session state per note, default edited); live under autosave (the held header observation). Pins: the arrangement pin extended for three subviews (pure); a face pin that an autosave moves the stamp; a pin that the click flips the words.
- **The DEBUG geometry oracle:** `MastheadGeometry` (`PostDetailView.swift:~789–920`) gains the stamp's frame keyed by post id (row 53's rule: keyed by subject).

**What you do NOT do:** no stored stamp anywhere new (the two columns exist; nothing denormalizes); no change to what `last_touched_at` MEANS (§10); no Sync/; no schema; the Timeline mode untouched; no product invention (the relative-wording thresholds are the batch's numbers, recorded; anything else → QUESTIONS #102+ PROVISIONAL).

**The rules you work under:** R-1's rules 1–8 verbatim. **The walk:** the Library sorted each way with the stamps reading right; type in a note → the masthead's "edited" moves; click → "created …"; both voices; captures under `…-screens/18h-1/`. **Close honestly:** core `swift test` (you touched `Sources/`) + the touched Mac suites (`LibraryPanelTests`, `LibraryRowAlignmentTests`, `MastheadLayoutTests`, `MastheadTagDoorTests`, `ConnectLibraryTests`, `SampleLibraryTests`) + the ten `Tutorial*Tests`; the iOS build (a core signature changed → `xcodebuild build -scheme VariorumMobile -destination 'generic/platform=iOS'`).

### R-3 · RECORD (the implementer writes here from its first commit)

**WHAT I DID NOT DO (the record's first line):** no schema, no migration, nothing in
`Sources/VariorumCore/Sync/`, nothing in `BlockRangeIndex` / `EditorTextView` /
`PaneTextAuthority` / `PaneMeasurement`; **no day search** (row 11 — that is batch 2's, R-4); no
change to what `last_touched_at` MEANS (AppSpec §10 untouched); the Timeline mode's own order
untouched; no stored stamp anywhere new (no denormalization); no new `setting` key (the sort is
LOCAL UI state, so AppSpec §7's seeds are untouched — see the canon note at the end).

**LIVE STATUS — THE BATCH IS CLOSED** (`2d43df7c` · `a33db2bf` · `440d5c52` · `4a838d70` ·
`f531955a`; every piece flipped in its own commit as it landed):

- **Piece 1 — THE CORE (`sort:`/`direction:` · `LibrarySort.title` · `CatalogHit`'s two stamps ·
  `NoteStamps.createdAt` · the ONE wording brain `TimeStampFace`):** DONE (`2d43df7c`).
  Pins: `Tests/VariorumCoreTests/LibraryTimeSortTests.swift` (8 tests) +
  `Tests/VariorumCoreTests/TimeStampFaceTests.swift` (8 tests). Red-on-old captured as compile
  errors on `87799c6a` (`scratchpad/18h-1/red-on-old-core.log`, quoted below); green after:
  `✔ Test run with 21 tests in 3 suites passed after 0.272 seconds` (the two new suites +
  18d's `NoteStampsTests` riding untouched, which is the parity proof for the struct's new field).
- **Piece 2 — the sort menu + the model's memory:** DONE (`a33db2bf`). A new small file
  `App/Variorum/Variorum/Features/Library/LibraryTimeFace.swift` (NOT more lines in the
  1,300-line `LibraryCatalogView.swift` — F-0/P-9) holding three things of one theme:
  `LibrarySortFace` (the words + two rules: each sort's natural direction, and which stamp a row
  shows under it), `LibrarySortMenu` (the ONE `VoicedMenu` door, its label saying what the list
  is doing — *"edited · newest first"*), and `CatalogRowStamp` (the row stamp piece 3 wires).
  `LibraryCatalogModel` gained `sort`/`direction` written through `setSort`/`setDirection`
  (which remember them in an INJECTED `UserDefaults` — `.standard` in the app, a scrubbed suite
  per pin, KnownIssues R1-7), `showsSortDoor` as a RULE (the Timeline mode is an order already,
  so the door stands down there — P-1's gating-is-data, P-2's no-dead-doors), and `search()`
  now hands both to `Queries.searchCatalog`. Pin: `VariorumTests/LibrarySortMenuTests.swift`
  (7 tests) — red-on-old `scratchpad/18h-1/red-on-old-piece2.log` (`extra argument 'defaults'`,
  `no member 'sortKey'`, `cannot find 'LibrarySortFace'`); green:
  `✔ Test run with 7 tests in 1 suite passed after 0.267 seconds`.
- **Piece 3 — the row stamps + `TimeStampFace` adopted by 18d's facts line:** DONE
  (`440d5c52`). `LibrarySortFace.rowStamp(sort, for: hit)` is the ONE rule (subject + stored value as
  ONE value, so a renderer cannot pick the subject from one sort and the value from another —
  "created today" over an edit stamp is the worst lie a date face can tell; notes only, said
  outright rather than left to the parse). `CatalogNoteLine` wears it trailing, past the
  `Spacer()`, on the title's baseline; the Notes card's date slot now shows the SAME words where
  it used to print the raw stored day (`2026-09-09`). `NoteBoxCopy.day` is a forwarder to
  `TimeStampFace.day`. Pins: `LibraryRowAlignmentTests.aNoteRowsTrailingStampSitsOnTheTitlesBaselineInBothVoices`
  (red-on-old: `BaselineProbe.baseline("note.stamp")` nil — no stamp existed) ·
  `LibrarySortMenuTests.aRowsStampIsTheSortsOwnStampInWords` (the real query's hit → the real
  rule → the real words: *edited Jul 1* · *created Jul 1* · *dated Jan 15*; a book row's nil) ·
  `…theNoteBoxsDayWordsAreTheOneBrainsNow` (the no-drift claim). Green:
  `✔ Test run with 12 tests in 2 suites passed after 2.755 seconds` and 18d's four NoteBox
  suites UNCHANGED — `✔ Test run with 17 tests in 4 suites passed after 0.010 seconds` (the
  forwarder's parity proof).
- **Piece 4 — the masthead stamp (row two's third subview + the oracle slot):** DONE
  (`4a838d70`). `MastheadRowTwo` lays out TWO OR THREE subviews: the stamp takes its ideal width at
  the line's TRAILING edge and the cluster reflows in the room between (which is what keeps the
  right edge calm — the stamp is pinned where she reads it, the tag cards move); on two lines
  the stamp rides the chip's line and the cluster keeps its full-width line below.
  `arrangement` gained `stampWidth: CGFloat = 0`, and a 0 stamp adds NOTHING — not even a gap —
  so the shipped pure pin and every mounted row-58/80b pin hold unchanged (**parity proved:
  `MastheadLayoutTests` + `MastheadTagDoorTests` 14/2 green before I touched them**). The stamp
  is `MastheadStamp` in its own file (a quiet `VoicedButtonStyle(.quiet)` button, `lineLimit(1)`
  + `fixedSize` per P-8) on a HELD `Queries.noteStamps` observation. Pins:
  `VariorumTests/MastheadStampTests.swift` (4 tests) — the pure three-subview rule, the mounted
  no-collision claim, **an autosave through the REAL runner moving the held read**, and the
  click flipping *edited* ↔ *created* through the Button's own closure; plus the narrow-width
  row-80b helper EXTENDED to hold the stamp to the same no-collision claim (an existing pin
  whose claim grew because row two grew — stated here rather than done quietly). Green:
  `✔ Test run with 4 tests in 1 suite passed after 2.045 seconds` and
  `✔ Test run with 11 tests in 1 suite passed after 14.293 seconds`.
  **A trap found and recorded:** a `Layout`'s subview that renders `EmptyView` while it waits
  for data contributes NO subview — and a view that is not in the tree never runs its `.task`,
  so the read that would fill it can never start (the stamp was blank forever, and the first
  run of all three mounted pins caught it). The waiting face is a zero-size `Color.clear`,
  which row two sizes at 0 and treats exactly as "no stamp".
- **Piece 5 — THE WALK (the acceptance gate) + the closing runs:** DONE (`f531955a`). Seventeen
  captures in `notes/plans/use-report-2026-09-12-screens/18h-1/` (gitignored; listed below), both
  voices, on the DEV-STORE Debug build (`io.lduarte.Variorum.debug`, pid 86093, built into
  `App/Variorum/DerivedData/18h1`); her `/Applications` app was not running before, during or
  after (`pgrep -fl 'Variorum.app/Contents/MacOS'` empty at the start and after my quit), and I
  left the dev store on Terminal · List · edited · newest first (capture 17).

---

### R-3 · THE WALK (the acceptance gate — USE, not mount)

| # | capture | what it shows |
|---|---|---|
| 1 | `01-shelf-terminal.png` | the dev-store build up, Terminal voice — the walk's starting state |
| 2 | `02-library-list-edited-newest-first.png` | the Library's List rows each wearing a muted trailing stamp — *edited today 11:08 am* · *edited today 4:49 am* · *edited sep 8* — and the new `edited · newest first ▾` door in the header |
| 3 | `03-sort-menu-open.png` | the door open: ✓ edited · created · date · title, a divider, ✓ newest first · oldest first |
| 4 | `04-sort-created-newest-first.png` | **created · newest first**: the listing REORDERED (the note that led under *edited* is gone from the top) and every row's stamp now reads *created …* |
| 5 | `05-sort-title-a-z.png` | **title · a–z** — picked from the menu and the direction came with it (A–Z, not Z–A: the natural-direction rule); the rows are in displayed-name order and their stamps are *edited …* |
| 6 | `06-sort-date-newest-first.png` | **date · newest first**: the future-dated note leads and says *dated sep 22*; notes with no stated day show no stamp (the honest silence — QUESTIONS #103's edge) |
| 7 | `07-sort-edited-oldest-first.png` | the direction alone: **edited · oldest first**, the list flipped (aug 31 → sep 1 → sep 4 → sep 7) |
| 8 | `08-notes-cards-with-stamp.png` | her Apple-Notes-shaped **Notes** cards: the date slot now says *edited today 11:08 am* where it printed the raw `2026-09-09` |
| 9 | `09-masthead-stamp-edited.png` | a note open: the masthead's second row — `~/the field guide` … `tutorial ×` `#` **`edited sep 8`** at the trailing end, quiet, on the chip's line |
| 10 | `10-masthead-stamp-moved-on-autosave.png` | **typed one word into the note** (`cliclick t:" walked"`) → the stamp moved to *edited today 1:22 pm* with no reopen — the held read, live |
| 11 | `11-masthead-stamp-flipped-to-created.png` | **clicked the stamp** → *created sep 8* |
| 12 | `12-masthead-stamp-returns-to-edited.png` | **clicked again** → *edited today 1:22 pm*. R-Q7's gesture, whole |
| 13 | `13-study-masthead-stamp.png` | the **Study** voice: *edited today 1:22 PM* in the serif, same place, proper case (the voice's own idiom) |
| 14 | `14-study-notes-cards.png` | Study's Notes cards with the stamp |
| 15 | `15-study-list-rows.png` | Study's List rows: the trailing stamps on the rows' own baselines |
| 16 | `16-timeline-has-no-sort-door.png` | the **Timeline** mode: no sort door (it has its own stamp control — `showsSortDoor` in the app, not only in a pin) |
| 17 | `17-restored-terminal-list-edited-newest.png` | the dev store left as I found it |

**What the walk changed in my understanding:** nothing about the design — but it is where I saw
that the stamp's words obey the VOICE's own casing (Terminal lowercases chrome, Study does not),
which is `tokens.chromeLabel` doing its job and the reason the stamp goes through it rather than
rendering a raw string.

---

### R-3 · DISPOSITIONS (every row this batch owns)

- **Ledger row 9 — "see the created time and last edited time easily on the library and within
  the note itself" — FIXED.** Pins: `LibraryTimeSortTests.everyNoteHitCarriesItsCreatedAndEditedStamps`
  · `…anUntouchedNotesEditedStampFallsBackToItsMint` · `…theNotesStampsReadCarriesTheMintBesideTheEdit`
  · `TimeStampFaceTests` (8) · `LibraryRowAlignmentTests.aNoteRowsTrailingStampSitsOnTheTitlesBaselineInBothVoices`
  · `LibrarySortMenuTests.aRowsStampIsTheSortsOwnStampInWords` · `MastheadStampTests` (4).
  Walked: captures 02 · 08 · 09–15.
- **Ledger row 10 — "i need to be able to sort the library by time" — FIXED.** Pins:
  `LibraryTimeSortTests.theCatalogSortsByEveryStampInBothDirections` · `…titleSortsOnTheDisplayedNameCaseInsensitively`
  · `…titleSortIgnoresCase` · `…theDefaultIsTheShippedEditedNewestFirstOrder` ·
  `…booksAndBlocksKeepTheirOwnOrderUnderEverySort` · `LibrarySortMenuTests` (9, incl. the memory
  and the unknown-value fallback). Walked: captures 02–07 · 16.
- **Nothing DISMISSED AS HOLLOW** (both rows are product rows — the capability was absent, which
  the compile-error red-on-old says exactly). **Nothing DEFERRED** except the day search, which
  was never this batch's (row 11 is R-4's).

### R-3 · THE BATCH'S OWN CALLS (recorded, not asked — §8's rule)

1. **The relative-time thresholds** (the brief says they are the batch's numbers): today carries
   the time, yesterday is the bare word, this year is the day, another year carries it. Recorded
   in `TimeStampFace`'s doc with the reasoning, and pinned.
2. **A sort pick takes its natural direction** (newest-first for a stamp, A–Z for a name); an
   explicit direction pick stands until the next sort pick. Not a product decision about what the
   app IS — it is what every list-sorting control in the OS does, and her ruling names "a
   direction toggle" without saying what a sort pick does to it. `LibrarySortFace.naturalDirection`,
   pinned, one line to change.
3. **The sort memory is LOCAL, never a synced `setting`** (the `readModeOutlineShown` class), so
   **AppSpec §7's `setting` seeds are untouched** and the lockstep marker stays 8.
4. **QUESTIONS #103 (PROVISIONAL, filed):** the Notes card has ONE date slot and the brief asks it
   to read the one brain — so the sort's stamp REPLACED the stated day there. Built as the brief
   says, with the two alternatives and the related "no stamp under the date sort for a note with
   no stated day" edge named on the same line.

### R-3 · THINGS FOUND AND DELIBERATELY NOT FIXED

- **A pre-existing double date on some List rows** (visible in capture 05): a note with no stored
  title but WITH an entry date shows that date as its TITLE (`DisplayTitle`'s fallback) and again
  in the row's own `date:` slot. Shipped since 13g batch 7; not this batch's surface and not a
  regression — recorded so the next reader does not blame the stamp for it.
- **`LibraryViewModel`'s hardwired `sort: .lastTouched, direction: .desc`** (the ledger row's
  original trace, `:48–50`) is UNTOUCHED: the §4.7/§4.8 correction is right — the Library she is
  looking at is `LibraryCatalogModel` over `searchCatalog`, and that other model serves the older
  folder listing. Changing it would have been a second surface.
- **The phone does not OFFER the title sort.** `MobileLibraryViewModel.sortWord` gained the case
  (it switches exhaustively, which is why the iOS build was owed and how it caught this), but
  `sortOptions` still lists the four stamps — whether the phone's picker gains A–Z, and whether
  the phone's rows gain stamps, is the mobile project's call. **The parity line this batch owes
  (`notes/MobileSoul.md` §6, for the letter's close):** *the Library's rows and the note's
  masthead now show a created/edited stamp (one shared brain, `TimeStampFace` in core `Domain`),
  and the Mac Library sorts by edited · created · date · title with a remembered direction — the
  phone owes a version of both.*

### R-3 · CLOSING THE BATCH (the three runs, exact lines)

- **Core (`swift test`, repo root — I touched `Sources/`):**
  `✔ Test run with 1519 tests in 165 suites passed after 58.745 seconds.`
  (the round's baseline was 1503/163; +16 tests in +2 suites is exactly this batch's two new core
  suites.)
- **Mac (ONE `xcodebuild test` from `App/Variorum/`, the touched suites + the ten `Tutorial*`
  spine types; TYPE names, zero `skipped:` lines):**
  `✔ Test run with 188 tests in 33 suites passed after 108.636 seconds.`
  The 33: `LibrarySortMenuTests` · `MastheadStampTests` · `LibraryRowAlignmentTests` ·
  `MastheadLayoutTests` · `MastheadTagDoorTests` · `LibraryPreviewBrainTests` ·
  `LibraryPanelHostTests` · `ConnectLibraryTests` · `SampleLibraryTests` · `NoteBoxCopyTests` ·
  `NoteBoxStateTests` · `NoteBoxHeightTests` · `BookNoteBoxSubjectTests` ·
  `NoteRowSelectionRuleTests` · `NoteRowRoutingTests` · `RowClickTimingTests` ·
  `LibraryRowClickTests` · `ShelfModelTests` · `PromoteAndPaletteTests` · `LibraryTagFaceTests` ·
  `NoteTagDeclarationTests` · `ContextBarDoorsTests` · `TagChipFitTests` · the ten `Tutorial*Tests`.
  *(The brief named six suites by FILE name; four of those files carry differently-named types —
  `LibraryPanelTests` is `LibraryPreviewBrainTests` + `LibraryPanelHostTests`, and so on. The
  first attempt named them as written and xcodebuild silently ran 21 suites; the list above is
  the re-run with the real type names. Recorded because a silently-skipped suite is the exact
  way a closing run lies.)*
- **iOS:** `** BUILD SUCCEEDED **`
  (`xcodebuild build -scheme VariorumMobile -destination 'generic/platform=iOS'`). **It FAILED
  first**, which is the point of owing it: `MobileLibraryViewModel.swift:82:9: error: switch must
  be exhaustive` — the phone's `sortWord` switches over every `LibrarySort` case, and `.title`
  was new. One line, with a comment saying why the phone answers for a sort it does not offer.

### R-3 · WHAT THE LETTER'S CLOSE OWES (drafted for the orchestrator)

- **`notes/AppSpec.md` §12** — the Library line gains the stamps and the sort. Draft: *"Ratified
  addition (18h batch 1, 2026-09-12 — her rulings R-Q7 · R-Q8's first half): the Library's rows
  (List and the Notes cards) carry a muted TIME STAMP — the sort's own, worded by the one pure
  brain `TimeStampFace` (`Domain`; today · yesterday · the day · the day with its year) — and the
  header carries a `sort ▾` door: edited · created · date · title, with a direction remembered
  LOCALLY (never a synced `setting`). The note's masthead wears the same stamp at the trailing
  end of its second row, flipping edited ↔ created on a click."*
- **`notes/AppSpec.md` §7** — **nothing owed**: no new `setting` key (the sort memory is local UI
  state), no schema, no migration, marker stays 8.
- **`notes/MobileSoul.md` §6** — the parity row quoted above.
- **`notes/QUESTIONS.md`** — **#103 is filed** (PROVISIONAL, the shipped arm marked).
- **`notes/KnownIssuesAndTechDebt.md`** — nothing owed by this batch.

**THE MEASUREMENT, CORRECTED (the ladder's R1-1 · R1-2 — the numbers the record should have
carried; probe log `scratchpad/18h-2/cost-probe3.log`, a throwaway suite deleted after the run).**

**What was wrong with the measurement above, in one sentence:** the probe and the pin both wrote
every fixture note ON the day they then searched, so the STAMP arm answered every row and SQLite's
`OR` short-circuited — **the savepoint arm never executed in anything I measured.** The pin's own
comment said so (*"the stamp arm answers most notes before the subquery runs at all"*) and I did not
draw the consequence. So the "+27% of the VM steps" figure measured extra `COALESCE` comparisons;
"note-shaped, not savepoint-shaped" was a claim about a path that did not run; and the 5578/5578
index comparison proved only that the planner ignores a `created_at`-only index for the CORRELATED
form. The verdict that rested on all three — *"no index needed"* — was wrong.

**The corrected measurement.** 300 notes × 2 takes × 2 savepoints, VM steps on the SHIPPED statement,
the day matching **NO** note (any past day — the feature's ordinary use):

| blocks/note | the shipped correlated arm | + `idx_commit_created` alone | uncorrelated `IN` alone | **uncorrelated `IN` + the index (shipped now)** | any form, a day matching every note |
|---|---|---|---|---|---|
| 1 | 18,016 | 18,016 | 12,630 | **6,636** | 7,078 |
| 20 | 206,116 | 206,116 | 126,630 | **6,636** | 7,078 |
| 100 | 998,116 | 998,116 | 606,630 | **6,636** | 7,078 |

The correlated arm's cost is **linear in blocks per note, summed over the corpus** — P1's forbidden
shape (OverallModel §5: *"cost ∝ what is on screen and what is being edited, never the total size of
the document or the corpus"*), on a query `search()` spawns per keystroke. The `LIMIT 40` cannot stop
it: the `ORDER BY` is a `COALESCE`, so the plan carries `USE TEMP B-TREE FOR ORDER BY` and every
row's `WHERE` is evaluated before any row is discarded.

**Why `idx_commit_created` alone changes nothing (the column that reads identically):** the app never
runs `ANALYZE` — I grepped `Sources/` and the app and found none; the only mention is a comment at
`Migrations.swift:491`, which says the same thing for `v1_15`'s index. With no `sqlite_stat1` the
planner keeps the correlated order whatever indexes exist. *With* `ANALYZE` it does re-order
(12,617 / 10,218 / 10,218) — which makes the correlated form's cost depend on statistics the app does
not create, on a per-keystroke query. That hazard is recorded for owner 12, not fixed here.

**What shipped:** the savepoint half turned around — `id IN (SELECT cb.container_id …)` — plus
`CREATE INDEX idx_commit_created ON commit_point(created_at)` as migration **v1_17 in its own schema
commit** (`33407d64`) ahead of the query (`f714ca73`). **An index is still not a SyncSpec §12 lockstep
event** (`v1_15_note_version_index`'s own reasoning: the mirrors carry no indexes beyond the PK by
design, so a local index changes no wire semantics, no column, no classification) — **the marker
stays 8**, and the phone gains the index by construction, the migration set being shared.

**And §4.8's promise, named (R1-2's second half).** §4.8 predicted *"one indexed seek"* on
`idx_container_touched`. The shipped plan — which I pasted into the original measurement verbatim and
did not read against that promise — says `SEARCH container USING INDEX idx_container_kind (kind=?)`:
the first arm compares `COALESCE(last_touched_at, created_at)`, and a COALESCE expression cannot use
a column index. **That is a deliberate trade, now stated instead of implied:** the filter compares
exactly the value the row DISPLAYS (and that the `.lastTouched` sort orders by), so a row reading
*edited today* can never fail to be found by today. The cost of the trade is bounded by the NOTE
count — the shipped listing's own documented shape, benchmarked since Phase 4 — never by the corpus.
The corpus-shaped half was the savepoint arm, and that is what R1-1 fixed.

**The pins that now hold it** (both re-written, because the originals could not fail):
`theSavepointArmIsDrivenByTheDaysOwnSavepoints` — the plan must use `idx_commit_created` and must not
be `CORRELATED`; red on old with v1_17 ALREADY in the store. And
`theDaySearchsWorkTracksTheDaysSavepointsNotTheCorpusBlocks` — 40 notes, the searched day matching
nothing, sweeping blocks-per-note: **red on old at 1,896 → 13,096** VM steps for 1 → 15 blocks each
(6.9× for 15× the blocks), **green after at 916 → 916** — flat, and less than half the old floor.

**RED ON OLD, piece 1 (the honest shape for a PRODUCT row — the capability is absent, so the pins
do not compile on `87799c6a`; full log `scratchpad/18h-1/red-on-old-core.log`):**

```
LibraryTimeSortTests.swift:62:38: error: extra arguments at positions #3, #4 in call
LibraryTimeSortTests.swift:92:44: error: type 'Queries.LibrarySort' has no member 'title'
LibraryTimeSortTests.swift:165:29: error: value of type 'Queries.CatalogHit' has no member 'createdAt'
LibraryTimeSortTests.swift:191:25: error: value of type 'Queries.CatalogHit' has no member 'lastTouchedAt'
LibraryTimeSortTests.swift:206:28: error: value of type 'Queries.NoteStamps' has no member 'createdAt'
TimeStampFaceTests.swift:105:17: error: cannot find 'TimeStampFace' in scope
```

*(Pointers re-verified by the orchestrator on 2026-09-12 during 17p batch b, at `48f54268`: `Queries.searchCatalog` `ShelfQueries.swift:367`, `CatalogHit` `:325`, `LibrarySort` `Timeline.swift:97`, `LibraryCatalogModel` `LibraryCatalogView.swift:22` with its call at `:167`; `MastheadRowTwo` is a `Layout` in its OWN file, `App/Variorum/Variorum/Features/Takes/MastheadRowTwo.swift:32` (the masthead that composes it is `PostDetailView.swift`). **Two more callers of `searchCatalog`** the brief did not name: `Features/CommandPalette/CommandPalette.swift:91` (`limitPerKind: 12`) and the phone's `VariorumMobile/Features/Shell/MobileLibraryViewModel.swift:144` — the new parameters are nil/defaulted so both compile unchanged, and the iOS build is owed for that reason exactly. Test suites and hand walks share the dev-store app's `UserDefaults.standard` (KnownIssues R1-7): the sort memory's harness gets its OWN scrubbed suite. Her app is QUIT for the night — an instance at `/Applications` means she is awake: never touch it.)*

**R-3 · ORCHESTRATOR'S VERIFICATION + ADJUDICATION (2026-09-12, the overnight run):** verified against git (six commits `2d43df7c`…`9cef4d28`, the core FIRST in its own commit; `Sync/` and `Persistence/` diff-empty; no trailer lines; the tree clean, `main` == `origin/main`; zero app instances), the record, and captures `03` (the Library header's `edited · newest first ▾` door open — edited · created · date · title, newest · oldest — the rows wearing "edited today 11:08 am" / "edited sep 8" at their trailing end) and `11` (the masthead's stamp flipped to "created sep 8" on a click, at the second row's trailing end beside the tag). **Rows 9 and 10 are FIXED as recorded.** Judgment calls:

**(J8) The shape is ACCEPTED and is the round's F-0 in practice:** the sort is a PARAMETER of the one catalog query with the shipped order byte-identical by default (the ⌘K palette and the phone's listing untouched — the two callers the append named); `LibrarySort.title` an enum case; no stored stamp anywhere new; ONE wording brain `TimeStampFace` in core `Domain` (its thresholds recorded, not asked); the sort door, its words and the row stamp in a NEW small file (`LibraryTimeFace.swift`) rather than 60 more lines in the 1,300-line catalog view; `MastheadRowTwo` grown to two-or-three subviews with `stampWidth` defaulted so every shipped masthead pin passed unmodified (the 3C parity proof); the stamp on a HELD `noteStamps` observation; 18d's `NoteBoxCopy.day` folded into the one brain as a forwarder (a second copy of one rule retired — MobileSoul §3's drift class closed where it was found). The sort memory is LOCAL (`UserDefaults`, injected — the R1-7 lesson applied), so **AppSpec §7 owes nothing** and the marker stays 8.

**(J9) QUESTIONS #103 stands PROVISIONAL as filed** — the Notes card's ONE date slot now reads the sort's stamp where it read the stated day; built as the brief instructed, the two alternatives and the no-stated-day edge named on the same line. Hers in the morning; one line to change. Her R-Q7 words ("a muted trailing stamp" on the rows) are satisfied under every sort; the card is the one face where the stamp displaces a fact rather than adding one, which is exactly why it is a question and not a call.

**(J10) The phone's one-line catch-up is ACCEPTED and is the parity line's seed:** `MobileLibraryViewModel.sortWord` switches exhaustively over `LibrarySort`, so `.title` had to be answered for the phone to compile — the iOS build FAILED first, which is the whole reason the brief owed it; the phone's picker still offers the four stamps, and whether it gains A–Z and row stamps is the mobile project's call (PL-22's neighbour — the MobileSoul §6 row drafted in the record is adopted for the round's close). The closing-run lesson (four of the brief's six suite names were FILE names, and `xcodebuild` silently ran 21 suites until the TYPE names were used) is recorded for every later brief in this round: **name suite TYPES**. The pre-existing double date on some List rows (13g batch 7's fallback title + the row's date slot) is recorded, not this batch's.

The canon note drafted under "WHAT THE LETTER'S CLOSE OWES" (AppSpec §12's Library line) is adopted for 18h's close. **Batch 1 is CLOSED; batch 2 (R-4, the day search) opens; the 18h Opus ladder runs once over both batches at the letter's end.**

---

### R-4 · 18h batch 2 — BRIEF (THE DAY SEARCH: "notes edited on a day" — a date field in the Library header over ONE union query) — written by the orchestrator 2026-09-12

**Spawn:** `opus-implementer`. **Review after:** `opus-reviewer`. **One acceptance unit:** half a batch — one query, one filter face. **Row:** ledger 11. **Her ruling (§7, SETTLED):** R-Q8 — build now, a small filter in the Library ("on day…" with a date field), the union query (the last-edit stamp OR a savepoint that day).

**Read first, yourself:** `CLAUDE.md` + canon (AppSpec §10 — ONE last-edit stamp per note, coarse not forensic; OverallModel §3 — the savepoint occasions incl. 13j's `closeAutoCommit`; §4's P1); this plan's §4.8 (the caveat is the product's honesty — the face must word it); R-3's RECORD (the sort's shape you extend); the standing-17 rules.

**Pointers (re-grep after R-3):** `Queries.searchCatalog` (`ShelfQueries.swift:367+`, now carrying `sort`/`direction` from R-3) gains `editedOn: String?` (a `YYYY-MM-DD` day in the USER's calendar — the caller converts; the query compares ISO text: `last_touched_at >= ? AND last_touched_at < ?` over the day's UTC bounds computed by the caller from the local day) OR `EXISTS (SELECT 1 FROM commit_point cp JOIN variant v ON v.id = cp.variant_id JOIN container_block cb ON cb.block_id = v.block_id AND cb.container_id = container.id WHERE cp.created_at >= ? AND cp.created_at < ?)` — the union of the two readings; `EXPLAIN QUERY PLAN` it: the first arm seeks `idx_container_touched`; the second arm's `commit_point` scan is bounded by the note's own savepoints via `idx_commit_variant` — if the plan shows a full `commit_point` scan, add `CREATE INDEX idx_commit_created ON commit_point(created_at)` as ITS OWN schema commit (17c P20's precedent: an index is not a §12 lockstep event; the marker stays 8) and MEASURE before/after (statement counts + the plan, never timings alone — 17c's discipline). The face: a date field in `LibraryCatalogView`'s header beside the sort menu ("on day…", cleared by ✕), `LibraryCatalogModel` holds it, `search()` passes it; the empty answer worded in ONE place (`LibraryCopy`-class: "No note's last edit or savepoint falls on Sep 9 — a note edited on two days is found by its last day, or by a savepoint from the earlier one"). Pins (core): a note edited Monday then Tuesday matches Tuesday only by the stamp; with a savepoint dated Monday it matches Monday too; a note with neither on the day is absent; the plan pinned (`EXPLAIN QUERY PLAN` contains the index names). The face pin: the field's value reaches the query.

**What you do NOT do:** no stored per-day edit log (forensic by definition — out of scope); no FTS; no Sync/; a schema commit ONLY for the index and only with the measured plan; no product invention beyond R-Q8 (the field's placement and the wording are the batch's; anything else → QUESTIONS #102+ PROVISIONAL).

**The rules:** R-1's rules 1–8 verbatim. **The walk:** the field set to today shows the notes she edited today; a day with nothing shows the sentence; captures under `…-screens/18h-2/`. **Close honestly:** core `swift test` + the Library suites + the tutorial spine + the iOS build (core signature).

### R-4 · RECORD (the implementer writes here from its first commit)

**WHAT I DID NOT DO (the record's first line):** **no schema, no migration, NO INDEX** — the measured
plan says none is needed (the verdict is under "THE MEASUREMENT" below), so the lockstep marker stays
**8** and there is no second commit ahead of the code; nothing in `Sources/VariorumCore/Sync/`;
nothing in `BlockRangeIndex` / `EditorTextView` / `PaneTextAuthority` / `PaneMeasurement`; no stored
per-day edit log and no FTS (both forbidden by the brief and by CoreDescription's "coarse, not
forensic"); no change to what `last_touched_at` MEANS (AppSpec §10 untouched); no change to the sort,
the row stamps or the masthead stamp (18h batch 1's, `2d43df7c…f531955a`); the Timeline mode's own
listing untouched; no new `setting` key (the day filter is transient UI state — see the batch's calls).

**MACHINERY HONESTY (the protocol's rule 7):** commit `5f9a3a89` — the one that landed the three
closing runs into this record — carries a GARBAGE MESSAGE: two heredocs on one shell line, and
`git commit -F -` read the python script instead of the message. Its CONTENT is exactly right (this
record, with the closing lines). It is not amended, because history is never rewritten here; this
line is the correction, and the message it should have carried is the one on the commit after it.

**LIVE STATUS — THE BATCH IS CLOSED** (`c3d81b31` · `ff112dab` · `dced175b` + this commit; piece 2,
the index, was measured and NOT needed, so there is no schema commit and the marker stays 8)

- **Piece 1 — THE CORE (the union query arm + the pure day→UTC-bounds rule):** DONE (`c3d81b31`). `DayBounds`
  (`Sources/VariorumCore/Domain/DayBounds.swift`) is the conversion: a local calendar day → the
  half-open UTC ISO window `[start, end)` the stored stamps are directly comparable against.
  `JournalDay.date(from:calendar:)` is the noon anchor it and `TimeStampFace.parse` now SHARE (the
  parse door had the only copy of that rule; a second copy would have been the drift class).
  `Queries.searchCatalog` gains `editedOn: DayBounds? = nil` — one ARM of the one query (F-5), whose
  SQL is built by `Queries.catalogPostsSQL` so the plan pin explains the SHIPPED statement rather than
  a retyped copy, and whose day predicate is the one documented constant `Queries.editedOnClause`.
  Pins: `Tests/VariorumCoreTests/DayBoundsTests.swift` (9) +
  `Tests/VariorumCoreTests/LibraryDaySearchTests.swift` (13).
  Red-on-old captured as compile errors on `bd85e6ef` in a throwaway worktree
  (`scratchpad/18h-2/red-on-old-core.log`, quoted below). Green after, with 18h batch 1's and 18d's
  stamp suites riding UNMODIFIED beside them (the parity proof for the `parse` refactor):
  `✔ Test run with 43 tests in 5 suites passed after 0.761 seconds.`
- **Piece 2 — THE INDEX: NOT NEEDED, measured, no commit.** See "THE MEASUREMENT".
- **Piece 3 — THE FACE (the header's day field · the model's day · the empty answer):** DONE
  (`ff112dab`). A new small file
  `App/Variorum/Variorum/Features/Library/LibraryDayFilter.swift` (NOT more lines in the 1,300-line
  `LibraryCatalogView.swift`, and NOT bolted into batch 1's `LibraryTimeFace.swift`, which is the
  sort-and-stamp file — F-0/P-9) holding two things of one theme: `LibraryDayFace` (the door's words
  and, in ONE place, the honest empty answer) and `LibraryDayField` (the door: `on day…` until she
  names a day, then the date field with its ✕). `LibraryCatalogModel` gained `editedOn` written
  through `setEditedOn` (which REFUSES a key that is not a real day rather than filtering by a
  guess), and `search()` converts it once through `DayBounds`. `showsSortDoor` became ONE rule under
  a truer name — `showsCatalogControls` — with batch 1's name kept as its forwarder so that pin
  reads unchanged (the 3C parity pattern); both controls stand down in the Timeline mode, and the
  SCOPE picker stands down while a day is armed (a day names notes). Both empty states — the List
  mode's and the Notes mode's — render the one `LibraryDayEmptyAnswer`.
  Pin: `App/Variorum/VariorumTests/LibraryDayFilterTests.swift` (9). Red-on-old captured as compile
  errors on `c3d81b31` in a throwaway worktree (`scratchpad/18h-2/red-on-old-face.log`, quoted
  below). Green: `✔ Test run with 9 tests in 1 suite passed after 0.110 seconds.`
- **Piece 4 — THE WALK (the acceptance gate) + the closing runs:** DONE (`dced175b`; the closing
  runs landed at `5f9a3a89`). Eleven captures in `notes/plans/use-report-2026-09-12-screens/18h-2/` (gitignored;
  the table below), both voices, on the DEV-STORE Debug build (`io.lduarte.Variorum.debug`, built
  into `App/Variorum/DerivedData/18h2`); her `/Applications` app was not running before, during or
  after (`pgrep -fl 'Variorum.app/Contents/MacOS'` empty at the start and after my quit), and I left
  the dev store as I found it — Terminal · List · edited · newest first · the day closed (capture
  10). **The walk found and fixed a face defect** (below). Closing runs: the three lines under
  "CLOSING THE BATCH".

---

**THE BATCH'S OWN CALLS (recorded, not asked — §8's rule; the brief grants the field's placement and
the wording, and names QUESTIONS for anything else):**

1. **The field sits in the header's control row, after `sort ▾`** — the filter row she already uses
   (search · scope · mode · sort), so the two things that shape the listing stand together.
2. **Closed until she opens it, and it opens on TODAY.** An always-armed date control would narrow
   the Library the moment the page drew, with no gesture behind it — the invisible-state hazard the
   app's own walk standard forbids. Opening picks today because that is what a date field does and
   what "what did I write today" wants.
3. **The day is NOT remembered across sessions** (unlike the sort, which is a posture). A Library
   that reopened still narrowed to a day she asked about yesterday hides most of her notes behind a
   control she does not remember setting.
4. **The empty answer carries the caveat; the armed door carries it on hover.** §4.8 calls the
   caveat "the product's honesty — the face must word it"; this is where it is worded, in one place
   both modes read. It is NOT a permanent banner over a listing that DID find notes — that would nag
   on every successful answer.
5. **QUESTIONS #104 (PROVISIONAL, filed):** while a day is armed the listing is NOTES ONLY (books
   and blocks carry no edit stamp), and the scope picker stands down with them. Built that way, with
   the two alternatives named.

---

**THE MEASUREMENT — ⚠️ THIS SECTION'S ORIGINAL VERDICT WAS WRONG AND IS CORRECTED BELOW** (the
ladder's R1-1/R1-2; the correction was applied at `f714ca73`, the fix's commit). The original text is
kept verbatim because a record that quietly replaces a falsified measurement teaches nothing; read it
with **THE MEASUREMENT, CORRECTED** immediately after it.

*(17c's discipline — the plan and the counts, never timings alone; probe log
`scratchpad/18h-2/plan-probe.log`, a throwaway suite deleted before this commit).* A store of **200
notes × 8 savepoints each = 1,600 savepoints**, the day set to the day they were all written:

```
==== BEFORE any new index
---- PLAN: day search
   SEARCH container USING INDEX idx_container_kind (kind=?)
   CORRELATED SCALAR SUBQUERY 1
     SEARCH cb USING INDEX idx_cblock_order (container_id=?)
     SEARCH v USING INDEX idx_variant_block (block_id=?)
     SEARCH cp USING COVERING INDEX idx_commit_variant (variant_id=? AND created_at>? AND created_at<?)
   USE TEMP B-TREE FOR ORDER BY
   rows=40 vmSteps=5578 sorts=1 fullscanSteps=0
---- PLAN: open catalog note arm (the SHIPPED listing, for scale)
   SEARCH container USING INDEX idx_container_kind (kind=?)
   USE TEMP B-TREE FOR ORDER BY
   rows=40 vmSteps=4376 sorts=1 fullscanSteps=0
==== AFTER CREATE INDEX idx_commit_created ON commit_point(created_at)
---- PLAN: day search
   (BYTE-IDENTICAL to the plan above)
   rows=40 vmSteps=5578 sorts=1 fullscanSteps=0
```

**The verdict: `idx_commit_created` is NOT needed and was NOT added.** The savepoint arm is
*correlated by `variant_id`*, so the planner reaches it through the note's own placements and takes
and finishes at `idx_commit_variant` — as a **COVERING** index read, never touching the
`commit_point` table at all, and bounded by the window (`created_at>? AND created_at<?` are in the
seek). A `created_at`-only index has nothing to offer that path: with it created, the plan and the VM
step count are **identical to the byte** (5578 / 5578), and `fullscanSteps` is **0** on both sides.
The union arm's whole cost over the shipped listing is +27% of the VM steps at 1,600 savepoints
(4376 → 5578), and it is note-shaped, not savepoint-shaped — pinned:
`theDaySearchsWorkTracksTheNotesNotTheSavepoints` (4 notes × 2 savepoints → 4 × 20 barely moves;
40 × 2 costs about ten times). **An index is not a SyncSpec §12 lockstep event** (17c/P20's
precedent) — but the point is moot here: no index was created, no schema commit exists, and the
**marker stays 8**.

**RED ON OLD, piece 1 (the honest shape for a PRODUCT row — the capability is absent, so the pins do
not compile on `bd85e6ef`; full log `scratchpad/18h-2/red-on-old-core.log`, captured in a throwaway
worktree at that commit):**

```
DayBoundsTests.swift:25:34: error: cannot find type 'DayBounds' in scope
DayBoundsTests.swift:32:35: error: cannot find 'DayBounds' in scope
DayBoundsTests.swift:127:43: error: type 'JournalDay' has no member 'date'
LibraryDaySearchTests.swift:84:31: error: extra argument 'editedOn' in call
LibraryDaySearchTests.swift:313:31: error: type 'Queries' has no member 'catalogPostsSQL'
LibraryDaySearchTests.swift:314:24: error: cannot infer contextual base in reference to member 'lastTouched'
```

---

### R-4 · THE WALK (the acceptance gate — USE, not mount)

| # | capture | what it shows |
|---|---|---|
| 00 | `00-before-the-focused-field-overflowed.png` | **the defect the walk found, before the fix:** the date field takes focus, grows a stepper, and — sized at its IDEAL width by `fixedSize` — prints its own digits through the ✕ beside it (`9/12/2025 ⇅ )25 ×`). Fixed in the same walk (a reserved width, `LibraryDayField.fieldWidth`); every capture below is after |
| 01 | `01-library-day-door-closed.png` | the Library at rest, Terminal voice: the header's new **`on day…`** door beside 18h batch 1's `edited · newest first ▾`; books, notes and blocks all listed |
| 02 | `02-day-opens-on-today.png` | **clicked `on day…`** → it opens on TODAY: the door reads `on sep 12`, the date field shows `9/12/2026` with its ✕, and the listing is the five notes edited today. The books section is gone and the scope picker (all · books · posts · blocks) is greyed — a day names notes (#104) |
| 03 | `03-empty-day-says-why.png` | **a day with nothing on it** (stepped to sep 11 in the field, whose calendar popover is open): *"no note's last edit or savepoint falls on sep 11."* and under it the caveat — *"a note keeps one edit stamp, so a note edited on two days answers for the later one — earlier days show up where a savepoint landed."* §4.8's honesty, on the surface |
| 04 | `04-sep-8-the-union-answers.png` | **THE UNION, on her real store.** Picked sep 8 from the calendar: 30-odd notes answer, and the FIRST row is *start here — **edited today 1:22 pm***. Its stamp is today's, and the stamp arm compares exactly the value that row displays — so the only thing that can have matched sep 8 is a SAVEPOINT from that day. The capability her row 11 asked for, doing the thing the caveat says it does |
| 05 | `05-notes-mode-day-armed.png` | the **Notes** mode under the same day: her Apple-Notes-shaped cards, the day filter riding the one listing |
| 06 | `06-notes-mode-empty-day.png` | the Notes mode on an empty day — **the same two sentences, word for word** (one wording, both modes) |
| 07 | `07-cleared-whole-library-back.png` | **✕** → the door reads `on day…` again, books are back, the scope picker is live again |
| 08 | `08-timeline-has-no-day-door.png` | the **Timeline** mode: neither the sort door nor the day field (one rule — `showsCatalogControls`, in the app and not only in a pin) |
| 09 | `09-study-voice-day-armed.png` | the **Study** voice: `on Sep 12` and the field in the serif, the same place, the voice's own casing |
| 10 | `10-restored-terminal-day-closed.png` | the dev store left as I found it |

**What the walk changed in my understanding — and in the code:** capture 00. A `DatePicker` in
`.field` style is TWO controls: unfocused it is a plain date, focused it grows a stepper (and, on
macOS 26, a calendar popover). `fixedSize()` measures the unfocused one, so the focused control
overflowed its reserved room and drew its digits over the ✕. The fix is a reserved width
(`LibraryDayField.fieldWidth = 108`, measured at ~88 pt focused plus slack for a wider locale's
date). **No red-on-old pin exists for it and that is deliberate, said plainly:** the defect appears
only when a real window gives a real control keyboard focus, and the harness cannot mount a whole
surface (KnownIssues R1-7's own rule — *pin brains, walk faces*). The before/after captures are its
evidence, which is exactly why the gate is USE.

---

### R-4 · DISPOSITIONS (every row this batch owns)

- **Ledger row 11 — *"how difficult it would be to implement being able to search for any note
  edited on a particular day"* — FIXED.** Pins: `LibraryDaySearchTests` (13) — the two readings
  (`aNoteEditedMondayThenTuesdayAnswersForTuesdayByItsStamp` ·
  `aSavepointFromMondayBringsTheNoteBackForMonday`), the absence
  (`aNoteWithNeitherAStampNorASavepointOnTheDayIsAbsent`), the correlation
  (`aSavepointOnAnotherNotesBlockNeverAnswersHere` ·
  `aSavepointOnADeletedBlockNoLongerAnswersForTheNote`), the COALESCE
  (`anUntouchedNotesMintCountsAsItsEdit`), the window
  (`theWindowIsHalfOpenAtBothEnds`), the scope (`onlyNotesAnswerADay` ·
  `archivedAndDeletedNotesStayOutOfTheDaysAnswer`), the composition
  (`theDayComposesWithTheTypedQueryAndTheSort`) and the measurement
  (`theSavepointArmIsBoundedByTheNotesOwnSavepoints` ·
  `theDaySearchIsOneStatementWhereTheOpenCatalogIsThree` ·
  `theDaySearchsWorkTracksTheNotesNotTheSavepoints`) · `DayBoundsTests` (9 — the midnight and the
  two DST pins the brief names, plus the day whose midnight never happened) ·
  `LibraryDayFilterTests` (9 — the field's value reaching the query through the control's own
  binding, the clear, the refusal, the words, the two composing controls).
  Walked: captures 01–10.
- **Nothing DISMISSED AS HOLLOW** (a product row — the capability was absent, which the compile-error
  red-on-old says exactly). **Nothing DEFERRED.**

### R-4 · THINGS FOUND AND DELIBERATELY NOT FIXED

- **A third private copy of the statement-capture helper was NOT made.** `ReadLayerP1Tests` and
  `NotePickerShapeTests` each carry their own private `captureStatements` + `sqlite3_stmt_status`
  reader, each with a comment saying it is *"kept private here for the same reason it is private
  there"*. My measurement needs are smaller (a statement COUNT and one VM-step read), so they are
  four inline lines rather than a third copy of that machinery — but the two existing copies are a
  hoist candidate for whoever next touches either file (the project's own hoist-at-next-touch rule).
- **The scope picker greys out rather than announcing itself.** A disabled control with a tooltip is
  the quietest honest answer, but it is a control changing state for a reason she must hover to
  learn — named as option (c) in QUESTIONS #104 rather than decided here.
- **`idx_commit_created` was not created.** Measured, not assumed — see THE MEASUREMENT. A future
  query that filters savepoints by day WITHOUT the note correlation (a global "what did I save on
  Tuesday") would want it; this one does not, and an index nothing uses is a write cost on every
  savepoint for nothing.

### R-4 · WHAT THE LETTER'S CLOSE OWES (drafted for the orchestrator)

- **`notes/AppSpec.md` §12** — the Library line (which batch 1's close already amends) gains the
  filter. Draft, to sit after batch 1's sentence: *"…and a **day filter** (`on day…`) answers "notes
  edited on this day" as the UNION of the note's own last-edit stamp and any savepoint written that
  day on a take it holds — the honest reading under §10's one-stamp-per-note design, with the caveat
  worded on the surface where the answer is empty. A day names NOTES: books and blocks stand down
  while one is armed (QUESTIONS #104, PROVISIONAL)."*
- **`notes/AppSpec.md` §7** — **nothing owed**: no schema, no migration, no index, no new `setting`
  key (the day is transient UI state, not even remembered). **The lockstep marker stays 8.**
- **`notes/MobileSoul.md` §6** — the parity row this batch owes, for the letter's close: *the Mac's
  Library answers "which notes did I edit on this day" (the last-edit stamp OR a savepoint from that
  day, one query arm; the day→UTC conversion is core's `DayBounds`) — the phone owes a version of
  the question, and the conversion is already shared.*
- **`notes/QUESTIONS.md`** — **#104 is filed** (PROVISIONAL, the shipped arm marked).
- **`notes/KnownIssuesAndTechDebt.md`** — nothing owed by this batch (the statement-capture hoist
  above is a note in this record, not a deferral: nothing is broken).

---

**RED ON OLD, piece 3 (the same honest shape one layer up — the face pins do not compile on
`c3d81b31`, the tree that already carries the core; full log
`scratchpad/18h-2/red-on-old-face.log`):**

```
LibraryDayFilterTests.swift:107:25: error: cannot find 'LibraryDayField' in scope
LibraryDayFilterTests.swift:109:28: error: value of type 'LibraryCatalogModel' has no member 'editedOn'
LibraryDayFilterTests.swift:154:19: error: value of type 'LibraryCatalogModel' has no member 'setEditedOn'
LibraryDayFilterTests.swift:232:22: error: cannot find 'LibraryDayFace' in scope
LibraryDayFilterTests.swift:264:27: error: value of type 'LibraryCatalogModel' has no member 'showsCatalogControls'
```

---

### R-4 · CLOSING THE BATCH (the three runs, exact lines)

- **Core (`swift test`, repo root — I touched `Sources/`):**
  `✔ Test run with 1541 tests in 167 suites passed after 56.799 seconds.`
  (batch 1 closed at 1519/165; +22 tests in +2 suites is exactly this batch's two new core suites —
  `DayBoundsTests` 9 + `LibraryDaySearchTests` 13.)
- **Mac (ONE `xcodebuild test` from `App/Variorum/`, TYPE names throughout — batch 1's closing set
  plus mine plus the ten `Tutorial*` spine types; zero `skipped:` lines):**
  `✔ Test run with 208 tests in 37 suites passed after 109.228 seconds.`
  The 37: `LibraryDayFilterTests` (new) · `LibrarySortMenuTests` · `MastheadStampTests` ·
  `LibraryRowAlignmentTests` · `MastheadLayoutTests` · `MastheadTagDoorTests` ·
  `LibraryPreviewBrainTests` · `LibraryPanelHostTests` · `ConnectLibraryTests` ·
  `SampleLibraryTests` · `NoteBoxCopyTests` · `NoteBoxStateTests` · `NoteBoxHeightTests` ·
  `BookNoteBoxSubjectTests` · `NoteRowSelectionRuleTests` · `NoteRowRoutingTests` ·
  `RowClickTimingTests` · `LibraryRowClickTests` · `ShelfModelTests` · `PromoteAndPaletteTests` ·
  `LibraryTagFaceTests` · `NoteTagDeclarationTests` · `ContextBarDoorsTests` · `TagChipFitTests` ·
  `StarTargetingTests` · `StarDeclarationTests` · `StarActingTests` (the ⌘K palette's own suites —
  the palette is `searchCatalog`'s other caller) · the ten `Tutorial*Tests`.
  Batch 1's 33 all passed UNCHANGED beside the new one, which is the parity proof for
  `showsSortDoor` becoming a forwarder and for `search()`'s new argument.
- **iOS (`xcodebuild build -scheme VariorumMobile -destination 'generic/platform=iOS'` — a core
  signature changed again):** `** BUILD SUCCEEDED **`. It did NOT fail first this time: `editedOn:`
  is defaulted and the phone's `MobileLibraryViewModel` call compiles untouched — unlike batch 1's
  `LibrarySort.title`, which the phone's exhaustive `switch` had to answer for.


*(Pointers re-verified by the orchestrator on 2026-09-12 after 18h batch 1 — `Queries.searchCatalog` is now `ShelfQueries.swift:399` with `sort:`/`direction:` (R-3's `2d43df7c`); `idx_container_touched` is created at `Sources/VariorumCore/Persistence/Migrations.swift:42` (the composite live-row form) and `idx_commit_variant ON commit_point(variant_id, created_at)` at `:807`; `commit_point` has NO index on `created_at` alone today. QUESTIONS' next free number is **#103** unless R-3 took it (read the file's tail). Her app is QUIT for the night — an instance at `/Applications` means she is awake: never touch it.)*


**R-4 · ORCHESTRATOR'S VERIFICATION + ADJUDICATION (2026-09-13, the overnight run):** verified against git (six commits `c3d81b31`…`e526f557`, the core FIRST and alone; `Sync/` and `Persistence/` diff-empty — no index, no migration, the marker 8; no trailer lines; the tree clean, `main` == `origin/main`; zero app instances), the record, and captures `04` (the Library with `on sep 8` armed: "start here — edited today 1:22 pm" at the top of the answer — the stamp arm compares exactly the value that row displays, so only a Sep 8 savepoint can have matched; the union working on her real store) and `00` (the before: the focused `DatePicker`'s stepper printing its digits through the ✕; and the empty day's two-line answer wording the §4.8 caveat in her voice). **Row 11 is FIXED as recorded.** Judgment calls:

**(J11) The measured "no index" is ACCEPTED and is the batch's best decision:** `EXPLAIN QUERY PLAN` at 200 notes × 8 savepoints shows the savepoint arm as a `SEARCH … USING COVERING INDEX idx_commit_variant (variant_id=? AND created_at>? AND created_at<?)` reached through `idx_cblock_order` → `idx_variant_block`, `fullscanSteps = 0`; creating `idx_commit_created` left the plan and the VM step count byte-identical (5578 / 5578) because the subquery is correlated by `variant_id`. An index nothing uses is a write on every savepoint for nothing — 17c's discipline (statement counts + the plan, never timings alone) applied exactly, and pinned (`theSavepointArmIsBoundedByTheNotesOwnSavepoints` · `theDaySearchsWorkTracksTheNotesNotTheSavepoints` — P1's letter). The one-statement shape (`Queries.catalogPostsSQL` built once, `editedOnClause` one documented constant) is F-5's "one query arm with its plan pinned".

**(J12) `DayBounds` in core `Domain` is the right home, and `JournalDay.date(from:calendar:)` as the shared noon anchor closes a drift:** the day→UTC conversion (23-/25-hour days, a day whose midnight never happened, both ends pinned) is a pure rule the phone already needs (its parity row says so), and `TimeStampFace.parse` had carried the only copy of the noon rule inside its door — one rule now, two consumers. QUESTIONS **#104** (the listing is notes-only while a day is armed; the scope picker greys out) stands PROVISIONAL as filed; the greyed control with a tooltip is the quiet honest answer, named as option (c) rather than decided — hers in the morning.

**(J13) The walk's field defect is ACCEPTED without a red-on-old pin, said plainly:** a `.field` `DatePicker` grows a stepper on focus, so `fixedSize()` measured the unfocused control; the room is reserved (`LibraryDayField.fieldWidth`) and the before is capture `00`. The rig cannot give a real control keyboard focus (KnownIssues' real-click row), so this is walk-verified — the same class as the previous round's J11. Two machinery notes stand as recorded: `5f9a3a89` carries a garbage message (two heredocs on one line fed the script to `git commit -F -`); its content is right, it is NOT amended (history is never rewritten), and `2435bfbe` carries the message it should have had; and the record-hygiene move `e526f557` left R-3's record byte-identical. The hoist candidate (two private `captureStatements` copies in `ReadLayerP1Tests` / `NotePickerShapeTests`) is noted for whoever next touches either — the hoist-at-next-touch rule.

The canon notes drafted under both batches' "WHAT THE LETTER'S CLOSE OWES" (AppSpec §12's Library line with the stamps, the sort, the day filter and its caveat; §7 owes nothing; MobileSoul §6's two rows) are adopted for 18h's close. **Batch 2 is CLOSED; the 18h letter's ladder opens — ONE Opus ladder over both batches, `2d43df7c..e526f557` (same-model flow: findings to the batch implementers for agree/dispute, the orchestrator arbitrates against the spec, the owning batch's implementer fixes; round 2 with a fresh reviewer).**

---

### 18h LADDER — ROUND 1 FINDINGS (opus-reviewer)

*(Cold review of `2d43df7c..e526f557` — BOTH batches, run 2026-09-12 against the tree at `e7c1fa97`
(`main` == `origin/main`, notes-only after `e526f557`). Scope check first, per the reviewer's own
contract: the diff touches **no** editor seam (`EditorTextView` / `PaneTextAuthority` /
`PaneMeasurement` / `BlockRangeIndex` all diff-empty), **no** custody or keychain code, **nothing** in
`Sources/VariorumCore/Sync/`, and changes **no** default's meaning (`searchCatalog`'s defaulted
parameters reproduce the shipped order byte-identically — pinned by
`LibraryTimeSortTests.theDefaultIsTheShippedEditedNewestFirstOrder`). Opus is the right seat; no
Fable re-spawn is owed.*

**Counts: 1 BLOCKER · 3 MAJOR · 7 MINOR · 5 NIT.**

Verification runs I made myself (not the record's, mine): core
`swift test --filter 'LibraryDaySearchTests|DayBoundsTests|TimeStampFaceTests|LibraryTimeSortTests|NoteStampsTests'`
→ `43 tests in 5 suites passed`; Mac
`-only-testing:` `LibraryDayFilterTests` · `LibrarySortMenuTests` · `MastheadStampTests` ·
`MastheadLayoutTests` · `LibraryRowAlignmentTests` → `36 tests in 5 suites passed`
(`DerivedData/review18h`). Zero app instances at `/Applications` before and after.

#### Findings, severity-ranked

**R1-1 · BLOCKER · batch 2 · `Sources/VariorumCore/Queries/ShelfQueries.swift:541-563`
(`Queries.editedOnClause`) — the day filter's savepoint arm costs Σ(blocks × takes) over the WHOLE
corpus on every query for a past day (P1).**

*Mechanism, traced:* the arm is `(stampInWindow) OR EXISTS (correlated subquery)`. SQLite
short-circuits `OR`, so the `EXISTS` runs for **every note whose own stamp is NOT in the day** — which
is every note in the store whenever she asks about a past day, i.e. the feature's ordinary use. Per
such note the subquery walks `idx_cblock_order` (its live placements) → `idx_variant_block` (each
block's takes) → `idx_commit_variant` (a probe per take), so the work is proportional to that note's
blocks × takes, summed over the corpus. The `ORDER BY` is a `COALESCE` expression, so the plan carries
`USE TEMP B-TREE FOR ORDER BY` (the pin itself records it): the `LIMIT 40` cannot stop the pass early
— every row's `WHERE` is evaluated. Note also that §4.8's promise (*"one indexed seek, cost ∝ the
day's notes"*) dissolved in the build: the first arm wraps `last_touched_at` in `COALESCE`, so
`idx_container_touched` is unusable and the recorded plan reads `SEARCH container USING INDEX
idx_container_kind (kind=?)` — the whole post table. Nothing in the record says so.

*Measured* (my own probe, `sqlite3` on the shipped statement's exact shape, schema + the four real
indexes, `ANALYZE`d):

| store (300 notes) | day matching every note (the record's fixture shape) | day matching none |
|---|---|---|
| 100 blocks/note × 2 takes × 2 savepoints | **0.19 ms** | **26.9 ms** |

and at a fixed empty day, 300 notes: 1 block/note **1.0 ms** → 20 blocks **5.0 ms** → 100 blocks
**28.2 ms** — linear in blocks, not in notes. `search()` is spawned per KEYSTROKE in the Library's
search field (`LibraryCatalogView.swift:807-809`), so with a day armed every keystroke pays it. This
is OverallModel §5's P1 in its own words — *"No operation's cost may scale with total document or
corpus size"* — and the escalation is real: the shipped listing was ∝ notes (documented, benchmarked);
the new arm is ∝ blocks + takes, i.e. ∝ corpus.

*Proposed fix (measured, on the same store and the same empty day):* make the savepoint half
UNCORRELATED and give it the index the correlated form could not use —
`… OR id IN (SELECT cb.container_id FROM commit_point cp JOIN variant v ON v.id = cp.variant_id JOIN
container_block cb ON cb.block_id = v.block_id AND cb.deleted_at IS NULL WHERE cp.created_at >= ? AND
cp.created_at < ?)` plus `CREATE INDEX idx_commit_created ON commit_point(created_at)` in its own
schema commit (17c/P20's precedent; not a §12 lockstep event, marker stays 8). Measured:
**26.87 ms → 0.17 ms** (the plan becomes `LIST SUBQUERY … SEARCH cp USING INDEX idx_commit_created
(created_at>? AND created_at<?)`, then a bloom-filtered join — cost ∝ the DAY's savepoints, which is
what P1 asks for). Semantics are identical (the `container_id` correlation becomes the subquery's
projection). Without the index the uncorrelated form is worse (95 ms), so the two changes ship
together. *The pin that would be red on old:* the existing
`theDaySearchsWorkTracksTheNotesNotTheSavepoints`, re-fixtured so the searched day matches NO note and
the notes carry many blocks — see R1-2.

**R1-2 · MAJOR · batch 2 · `Tests/VariorumCoreTests/LibraryDaySearchTests.swift:379-417` + R-4's
"THE MEASUREMENT" + the J11 adjudication — the measurement that decided "no index needed" never
executes the arm it measures.**

*Mechanism, traced:* in the probe (*"200 notes × 8 savepoints each … the day set to the day they were
all written"*) and in the pin (`steps(notes:savepointsEach:)` writes every note at
`2026-09-09T09:00` and searches `2026-09-09`), **every** note satisfies the stamp arm, so the `OR`
short-circuits and the correlated `EXISTS` never runs. The pin's own comment says it out loud —
*"the stamp arm answers most notes before the subquery runs at all"* — without drawing the
consequence. So: the *"+27% of the VM steps"* figure measures the extra `COALESCE` comparisons, not
the union; *"note-shaped, not savepoint-shaped"* is a claim about an arm that did not execute; the
before/after index comparison (5578/5578, byte-identical) is real but only proves the PLANNER ignores
a `created_at`-only index for the CORRELATED form — which is exactly the shape R1-1 says should
change. The plan pin (`theSavepointArmIsBoundedByTheNotesOwnSavepoints`) is sound as far as it goes:
it asserts the plan's *shape*, and its `!text.contains("SCAN commit_point")` is satisfied by a path
whose cost is nonetheless corpus-shaped. My own contrast on ONE store: **0.19 ms** (their fixture
shape) vs **26.9 ms** (a day nothing matched) — a 140× gap that the fixture hides by construction.

*Fix:* re-fixture `theDaySearchsWorkTracksTheNotesNotTheSavepoints` so the searched day matches NO
note (the arm must run) and the notes carry many blocks, and assert the work tracks the DAY's
savepoints rather than the corpus's blocks; record the corrected measurement in R-4 and re-adjudicate
J11 on it. This finding stands even if R1-1 is downgraded: an evidence claim the record makes and the
adjudication rests on is falsifiable as written.

**R1-3 · MAJOR · batch 2 · `LibraryCatalogView.swift:989-993` and `:1018-1021` (both empty-answer
sites) — the day's empty answer asserts a fact about the DAY whenever the listing is empty for ANY
reason.**

*Mechanism, traced:* the branch is `if model.hits.isEmpty { if let day = model.editedOn {
LibraryDayEmptyAnswer(...) } }` — the day is the only condition. Two reachable paths make the headline
(*"No note's last edit or savepoint falls on Sep 9."*) false:

1. **A typed query.** `model.query = "zzz"` with a day armed → the post arm's `LIKE` filters every
   note out → `hits` empty → the day answer, even though notes WERE edited that day. The search field
   sits two controls from the day door, so this is the likely path.
2. **A scope of books or blocks.** `searchCatalog` returns POSTS ONLY while a day is armed
   (`ShelfQueries.swift:426`, `:461`), and `LibraryCatalogModel.filtered` then applies `scope`
   (`:271-278`): with `scope == .books` the result is `[]`. The scope picker is
   `.disabled(model.editedOn != nil)` (`:822`) but its VALUE is not reset, so the only escape is ✕ —
   and what she reads meanwhile is a confident, wrong sentence about the day. This is the face the
   batch itself calls *"the product's honesty"* (`LibraryDayFilter.swift:31-40`), so a false headline
   is the worst place to land it.

*Fix:* (a) show the day answer only when the day is the ONLY narrowing (`query` empty and `scope` in
`{.all, .posts}`), otherwise word it for the real cause (*"No note matching "zzz" was edited on Sep
9."*) or fall back to `Nothing matches.`; and (b) arming a day should move a `.books`/`.blocks` scope
to `.posts` (#104's own option (c), which the record considered only for the picker's state, never for
a scope already set). *Red on old:* a model pin — `model.scope = .books; model.setEditedOn(today);
await model.search()` — asserting the day's notes are listed (or that the empty wording names the
scope); fails on this tree.

**R1-4 · MAJOR · batch 2 (and batch 1's `.title`) · `LibraryCatalogView.swift:256-259`
(`limitPerKind: 40`) — the day's answer and the A–Z order are silently truncated at 40.**

*Mechanism, traced:* `searchCatalog`'s post arm ends `ORDER BY … LIMIT ?` with `limitPerKind: 40`, and
nothing in the List or Notes body draws a count or a "more" affordance (I grepped: no
`hits.count`/section count anywhere in the file). Before this letter the cap was benign — the listing
was "the 40 most recently edited", an inherently top-N answer. Two of this letter's faces turn it into
a WRONG answer: "which notes did I edit on Sep 8" returns the day's 40 newest-edited notes and says
nothing about the rest, and "title · A–Z" returns the alphabetically-first 40 while reading as the
library. Her own walk is already near the edge — capture `04`'s caption says *"30-odd notes answer"*
for one day on her real store.

*Fix:* either lift the cap while a day is armed (the answer set IS the feature) or draw the truncation
("showing the first 40 — narrow the day or the search"). One line either way. *Red on old:* a core pin
— 45 notes edited on one day, `editedOn` set, assert all 45 answer (or that the model reports
truncation); fails on this tree.

**R1-5 · MINOR · batch 1 · `Sources/VariorumCore/Domain/TimeStampFace.swift:203-212`
(`formatted`) — a `DateFormatter` is built and ICU-templated on every single call, and the tooltip is
computed eagerly.**

*Mechanism, traced:* `formatted` allocates a `DateFormatter` and calls
`setLocalizedDateFormatFromTemplate` per invocation. `CatalogRowStamp.body`
(`LibraryTimeFace.swift:205-212`) calls `TimeStampFace.stamp(...)` AND `TimeStampFace.tooltip(...)` —
`.help(_:)` takes a `String`, so the tooltip is built whether or not anyone hovers. At
`limitPerKind: 40` that is 80 formatter builds per full list body evaluation, on the main thread, and
the list re-evaluates on every keystroke, selection change and row recycle. *Measured* (compiled
`swiftc -O`, this machine): **76 µs per build → 6.10 ms for 80**, versus **0.054 ms for 80 formats
through one cached formatter** — 110×. Viewport-bounded, so not a P1 breach, but it is 6 ms of avoidable
main-thread work on the app's "snappy always" surface.

*Fix:* a tiny static cache in `TimeStampFace` keyed by `(template, locale.identifier,
calendar.identifier, timeZone.identifier)` (the same `nonisolated(unsafe) static let` shape
`DateFormatter.variorumISO8601` already uses), and compute the tooltip lazily. Justification rather
than a bug pin: this is a measured degradation, not a wrong output, so its evidence is the numbers
above.

**R1-6 · MINOR · batch 1 + 2 · `App/Variorum/Variorum/Features/Library/LibraryCatalogView.swift`
(now 1,509 lines) — the letter cited this file as its god-file example and then added ~85 lines of
model state to it.**

Both batches correctly put their faces in new small files (`LibraryTimeFace.swift` 215,
`LibraryDayFilter.swift` 190) and say so in their headers (*"NOT more lines in the 1,300-line
`LibraryCatalogView.swift`"*). But `LibraryCatalogModel` — an `@Observable` model of ~250 lines with
its own selection algebra, tag loading, note-card loading and now the sort memory and the day — still
lives inside the view file, and this letter grew that file by ~200 lines net. CLAUDE.md's
hoist-at-next-touch rule and F-0/P-9 both point the same way: the model is a clean, mechanical
extraction to `LibraryCatalogModel.swift` beside the two new files, and the letter touched it twice.
*Degradation traced:* every future Library batch reads 1,500 lines to change 5, and the two 18h
batches each had to re-navigate it; that is the cost P-9 names.

**R1-7 · MINOR · batch 1 · `LibraryTimeFace.swift:49-57` vs
`VariorumMobile/Features/Shell/MobileLibraryViewModel.swift:81-94` — one core vocabulary, two
wordings.**

`Queries.LibrarySort` now has two word tables that DISAGREE for the same case: the Mac says
`edited` / `created` / `date` / `title`, the phone says `last touched` / `created` / `entry date` /
`title`. F-0's own line is *"two copies of one rule anywhere are the drift class (MobileSoul §3)"*.
The phone's copy predates this batch, so this is half-inherited — but 18h added the second table and
the one-line `.title` catch-up rather than hoisting the words to `Shared/`, and the parity row it
drafted (*"the phone owes a version of both"*) will land the divergence on the phone's next touch.
*Fix (cheap, at whoever touches next):* move the word table to `Shared/` beside `TimeStampFace`'s
consumers and let each platform choose which cases it OFFERS, not what they are CALLED.

**R1-8 · MINOR · batch 2 · `Sources/VariorumCore/Domain/DayBounds.swift:63-71`
(`init(containing:calendar:)`) — a public force-unwrapping initializer with no production caller, and
its documented consumer does not exist.**

*Mechanism, traced:* I grepped every non-test source: the only production construction is
`DayBounds(day:)` at `LibraryCatalogView.swift:256`. The doc calls `init(containing:)` *"the door a
'today' filter uses"*, but the today door is `LibraryDayField`'s Button, which goes through
`JournalDay.dayString(from: now, calendar:)` and then `setEditedOn` — never this initializer. Second,
the force-unwrap's proof (`everyDayOfAYearRoundTripsThroughItsOwnKey`) holds for a GREGORIAN calendar
only: `dayString` emits the current calendar's own components while `JournalDay.isValid` validates
against proleptic Gregorian, so under a Hebrew `Calendar.current` (selectable in macOS Language &
Region) a leap year's month 13 yields `"5786-13-05"`, `isValid` returns false, `init?` returns nil and
the `!` traps. No production path reaches it today, which is exactly why it should either gain a
caller or be removed — a force-unwrap kept alive only by its own pin is the kind of thing a later
batch adopts innocently.

**R1-9 · MINOR · batch 2 ·
`App/Variorum/VariorumTests/LibraryDayFilterTests.swift:130-141`
(`openingTheClosedDoorPicksToday`) — the pin cannot fail for the behaviour it names.**

The test's comment says *"The closed door's own action, the one its Button calls"*, but it drives
`field.dateBinding.wrappedValue = clock.current`. The closed branch of `LibraryDayField`
(`LibraryDayFilter.swift:150-157`) renders a Button whose closure is
`onPick(JournalDay.dayString(from: now, calendar: calendar))` — the binding is a different code path
that happens to produce the same string because the pin passes `clock.current` as the value. Change the
Button to open on, say, yesterday and this pin still passes. *Fix:* expose the closed door's action the
way `dateBinding` is exposed (a `var todayPick: String` or an `openAction` closure) and assert through
it — the batch's own "never hand-feed, drive the real closure" standard, applied to the one control it
missed.

**R1-10 · MINOR · batch 1 · `Sources/VariorumCore/Queries/Timeline.swift:126` (`LibrarySort.title`'s
expression) — the A–Z order can disagree with the displayed name across a timezone boundary.**

*Mechanism, traced:* the SQL is `COALESCE(NULLIF(title,''), entry_date, created_at)` — the third link
is the raw UTC instant. `DisplayTitle.note`'s third link is `day(fromStamp:)`, the LOCAL calendar day
of that instant (`DisplayTitle.swift:125-140`, deliberately local *"so the two slots mean the same KIND
of day"*). Inside the created-at group the two agree (the local-day map is monotone in the instant),
but ACROSS the groups they can invert: in UTC−5, an untitled note with no `entry_date` created
`2026-03-05T02:00:00.000Z` displays **2026-03-04** yet sorts at `"2026-03-05T02…"`, which is greater
than a note whose `entry_date` is `"2026-03-05"` and which displays **2026-03-05** — so A–Z lists
*2026-03-05* before *2026-03-04*. Narrow (untitled, undated, created within the offset window of
midnight, beside an entry-dated neighbour on the boundary day) but the doc's claim is absolute:
*"It orders by what she is LOOKING AT, never the raw column."* *Fix:* either `substr(created_at, 1, 10)`
with the known caveat, or say in the doc that the created-at link orders by the instant. *Red on old:*
a core pin with a fixed non-UTC calendar and that pair; fails on this tree.

**R1-11 · MINOR · batch 2 · `LibraryCatalogView.swift:822` + `:835` — an armed day survives into the
Timeline mode, where its door is not drawn but the scope picker stays disabled.**

`showsCatalogControls` (`:83`) hides BOTH the sort menu and the day field in `.timeline`, but the scope
`Picker`'s `.disabled(model.editedOn != nil)` sits outside that `if`. So: arm a day → switch to
Timeline → the scope picker is dead, its tooltip says *"A day names notes — clear it to scope books and
blocks again"*, and the control that would clear it is not on screen. Switching back restores it.
*Fix:* one line — `.disabled(model.showsCatalogControls && model.editedOn != nil)`, or clear the day
when the mode leaves the catalog (the `clearSelection`-on-mode-switch precedent one screen away).

**R1-12 · NIT · batch 2 · `LibraryCatalogView.swift:823-824` — `.help(model.editedOn == nil ? "" :
…)`.** An empty help string is a placeholder standing in for "no tooltip"; the chrome's own idiom
elsewhere is to apply the modifier conditionally. Cosmetic, but it is a string-as-rule sitting in a
view body (F-0's line).

**R1-13 · NIT · batch 2 · `LibraryCatalogView.swift:85-86` — `showsSortDoor` is a forwarder kept alive
only so a pin written in the SAME letter reads unchanged.** The 3C parity pattern exists for pins the
batch must not touch; both names here were minted eleven commits apart by the same letter, and
`LibraryDayFilterTests.theTimelineModeOffersNeitherCatalogControl` already asserts both. Rename the
batch-1 assertion and retire the alias, or the next reader has two names for one rule with no
distinction between them.

**R1-14 · NIT · batch 1 · `MastheadStamp.swift:71` + `PostDetailView.swift:888-896` —
`PostDetailOracle.flipStamp` / `stampShown` / `stampEditedAt` are global and NOT keyed by post id,**
while the brief's own row-53 rule ("keyed by subject") was applied to `MastheadGeometry.stampFrame`
beside them. With two note windows open in a DEBUG build the last `onAppear` wins. DEBUG-only and
harmless today; noted because the rule was stated and then applied to only one of the two oracles.

**R1-15 · NIT · batch 2 · `LibraryDayFilter.swift:188` — `.frame(maxWidth: 520)` is an unnamed
number-as-rule in a view body** (F-0's own line), in a file that otherwise names its one measured
constant (`fieldWidth = 108`, with the walk's measurement in its doc). Give it a name and a sentence.

**R1-16 · NIT · batch 1 · `Sources/VariorumCore/Queries/Timeline.swift:10-41` — `TimelineItem.stamp`
can now hold a TITLE.** `Queries.library(sort: .title)` is reachable (the enum is public and
`observeLibrary` takes it), and it would put the display title into a field documented as *"the value
of the ordering stamp for this row — feeds the next page's cursor"*. Nothing calls it that way today
(the sort menu drives `searchCatalog` only), so this is a latent trap rather than a bug. One sentence
on the case, or refuse `.title` in `library()`, closes it.

**R1-17 · NIT · batch 1 · `LibraryCatalogView.swift:1047` — the Notes card's stamp is not
"trailing".** R-Q7's letter is *"the Library rows get a muted trailing stamp too"*; on the List row it
is past the `Spacer()` (correct), on the Notes card it sits immediately after the title, before the
`Spacer()`. That is the Apple-Notes shape she pointed at, so it is probably right — but QUESTIONS #103
frames the card's question as *which fact* only, never *where*, so her word "trailing" is unanswered on
the one surface that diverges from it. Worth one clause in #103.

#### Considered and cleared (traced, and measured where it mattered)

- **`MastheadRowTwo`'s two-subview parity.** I read the arithmetic rather than trusting the claim: a
  zero-width stamp contributes `tail = 0`, `baseline = max(chip, cluster, 0)` is unchanged since
  baselines are non-negative, the one-line height extension is `if stamp.width > 0`, and `twoLines`
  falls back to `plan.chip.height` and `y + 0` exactly as before. `MastheadLayoutTests` +
  `MastheadTagDoorTests` pass unmodified — verified by my own run, not the record's.
- **The waiting face.** `MastheadStamp`'s `Color.clear.frame(width: 0, height: 0)` instead of
  `EmptyView` is correct and load-bearing: a `Layout` subview that renders `EmptyView` contributes no
  subview, so `plan`'s `guard subviews.count == 2 || 3` would refuse and the `.task` would never run.
  The trap and its fix are both in the record, and the three mounted pins cover it.
- **The held read.** `anAutosaveMovesTheStampWithoutReopeningTheNote` drives a real
  `ops.autosave` through the real runner and waits on the observation's own delivery — a one-shot
  implementation fails it. The 17o row-18/19 lesson is genuinely applied, not just cited.
- **`Queries.noteStamps`' third field is free** — `container` was already fetched; `editedAt`/`savedAt`
  byte-unchanged and 18d's `NoteStampsTests` ride green beside the new suites (I ran them together).
- **The savepoint arm's CORRECTNESS.** `cb.container_id = container.id AND cb.deleted_at IS NULL` is
  the right correlation (I2's live ownership), and the two pins that would break without it
  (`aSavepointOnAnotherNotesBlockNeverAnswersHere`, `aSavepointOnADeletedBlockNoLongerAnswersForTheNote`)
  both exercise the real ops. Leaving `v.deleted_at` unfiltered is deliberate and documented. My
  findings are about the arm's COST, never its answer.
- **`DayBounds`' rule.** The noon anchor, the half-open window, 23-/25-hour days and the day whose
  midnight never happened are all pinned against real zone data, and the tiling pin is the one that
  makes the two ends compose. This is the strongest work in the letter.
- **Sync.** Zero writes, zero `Sync/`, zero schema, zero migration, no new `setting` key — the sort
  memory is `UserDefaults` (injected, scrubbed per pin: R1-7's lesson applied), the day is not even
  remembered. Marker 8 stands. S1–S5 untouched.
- **No denormalization, nothing forensic.** No stamp is stored anywhere new; the day search reads
  existing columns and stores no per-day edit log (which CoreDescription forbids by definition). The
  hits carry raw ISO text and the words are derived per RENDERED row.
- **`NoteBoxCopy.day` → `TimeStampFace.day`.** A real drift retirement, and
  `theNoteBoxsDayWordsAreTheOneBrainsNow` asserts the equality over four offsets rather than asserting
  the forwarder exists.
- **The sort default.** `searchCatalog()` with no arguments reproduces the shipped
  `COALESCE(last_touched_at, created_at) DESC, id DESC` exactly — pinned, and the ⌘K palette and the
  phone's listing both take it untouched (their suites ran green in the record's Mac set and in mine).
- **The garbage commit message on `5f9a3a89`.** Content correct, correction recorded in the batch's own
  record, history not rewritten. Right call; nothing owed.

#### Review foci (§12), addressed

- **F-0 — no god brain, no god file.** Partly clean, partly R1-6 and R1-7. Clean: both batches put
  their faces in new small files rather than in the catalog view, and said why in the file headers;
  the new capability is a PARAMETER on the existing query and a THIRD SUBVIEW of the existing layout,
  not special cases inside either; the sort memory is read once at the model's init and pushed down;
  every new pure rule (`TimeStampFace`, `DayBounds`, `LibrarySortFace`, `LibraryDayFace`) has a home
  and a unit pin. Not clean: the 1,509-line `LibraryCatalogView.swift` gained ~85 lines of model state
  when the model was the obvious hoist (**R1-6**), and the sort vocabulary now has two disagreeing word
  tables across the platforms (**R1-7**). Two smaller F-0 lines: a number-as-rule (**R1-15**) and a
  string-as-rule (**R1-12**) in view bodies.
- **F-5 — 18h's own foci**, item by item: *the sort is a PARAMETER of the one catalog query, not a
  second query* — **clean** (`catalogPostsSQL`, one builder, `booksAndBlocksKeepTheirOwnOrderUnderEverySort`).
  *The title order is a `LibrarySort` case* — **clean** (with the latent `TimelineItem.stamp` trap,
  R1-16, and the display-order edge, R1-10). *No stored stamp anywhere new* — **clean**. *The
  relative-time wording is ONE pure brain used by every row and the masthead* — **clean**, and it
  retired 18d's second copy. *The masthead stamp is a third subview of the existing width-aware layout,
  not a second layout* — **clean**, parity proved by my own re-run of the untouched pins. *The day
  search is one query arm with its plan pinned, its index (if any) its own commit* — **the arm is one
  and the plan is pinned, but the plan pin asserts SHAPE and the cost pin never runs the arm**: this is
  where **R1-1** and **R1-2** land. No index was created; my measured recommendation is that one
  should be, together with an uncorrelated arm.

#### CLEAN BILL — checked and found solid

1. **The ISO/day dual door and its thresholds** (`TimeStampFace`) — today-with-time, bare yesterday,
   day, day-with-year; a future stamp reads as a day; a day-precision subject never invents a time; a
   non-stamp returns nil so a face draws nothing. Eight pins, all against fixed calendar/locale/now.
2. **`DayBounds`' timezone work** — the noon anchor, the half-open window, the western day straddling
   two UTC dates, the 23- and 25-hour days, São Paulo's missing midnight, and the 365-day round trip.
3. **The union's answer** — both readings pinned through the REAL operations on a travelling clock
   (her Monday/Tuesday case, the savepoint rescue, the correlation, the live-placement join, the
   half-open boundary at 23:59:59.998 and 00:00:00.000, archived/deleted exclusion, composition with
   the typed query and the sort).
4. **The default order is byte-identical** to what shipped, and every other `searchCatalog` caller
   (⌘K palette, the phone) compiles and behaves untouched — the iOS build failing FIRST on
   `LibrarySort.title` is exactly why that build was owed.
5. **`MastheadRowTwo`'s growth to three subviews** — the pure `arrangement` rule (a 0-width stamp adds
   no gap), the trailing placement, the baseline sharing, the two-line chip yield, and the mounted
   no-collision claims across voices, widths and tag counts.
6. **The stamp's held observation** — a real `ValueObservation`, `removeDuplicates`, cost bounded to
   the note's own rows, the flip as per-note view state reset by `.task(id:)`, and the words routed
   through `tokens.chromeLabel` so each voice's casing is the voice's.
7. **The sort's memory** — injected `UserDefaults`, scrubbed per pin, a second model over the same
   store reopening where she left it, a different store opening on the default, and an unrecognised
   stored value falling back rather than leaving the list in a shape no menu row matches.
8. **`setEditedOn` refuses a non-day** rather than filtering by a guess, and the model never holds a
   value the query would drop.
9. **Sync-shape and canon**: no writes, no `Sync/`, no schema, no migration, no `setting` seed, marker
   8; nothing stored, nothing copied, nothing forensic; PROVISIONALs filed as QUESTIONS #103 and #104
   with their alternatives and their one-line-to-change lines named.
10. **Both batches' recorded runs reproduce** — I re-ran the core suites (43/5) and five Mac suites
    (36/5) myself, green, on the reviewed tree.

---

#### Implementer's responses (round 1, batch 2)

*(The same-model agree/dispute pass, written by 18h batch 2's implementer. **I re-traced and
re-measured R1-1 and R1-2 myself before answering** — the hallucination guard cuts both ways, and a
finding against my own measurement is exactly the one I must not take on trust. My probe is a
throwaway suite (deleted; log `scratchpad/18h-2/cost-probe3.log`) that builds stores by raw insert
(a COST probe — correctness stays pinned through the real ops), reads `SQLITE_STMTSTATUS_VM_STEP` on
the SHIPPED statement (`Queries.catalogPostsSQL`) and on the reviewer's candidate, and prints
`EXPLAIN QUERY PLAN` for each. **Step counts, not timings** — 17c's discipline, and they carry one
thing timings cannot: they are machine-independent.)*

**R1-1 · BLOCKER — AGREE, without reservation, and the reviewer's fix shape is what I would build.**
My own numbers, 300 notes × 2 takes × 2 savepoints, the day matching NO note (the ordinary use — any
past day):

| blocks/note | SHIPPED | SHIPPED + `idx_commit_created` | uncorrelated `IN` | uncorrelated `IN` + index | any form, a day that matches every note |
|---|---|---|---|---|---|
| 1 | 18,016 | **18,016** | 12,630 | **6,636** | 7,078 |
| 20 | 206,116 | **206,116** | 126,630 | **6,636** | 7,078 |
| 100 | 998,116 | **998,116** | 606,630 | **6,636** | 7,078 |

The mechanism is exactly as traced: `OR` short-circuits, so the correlated `EXISTS` runs for every
note whose own stamp misses the day, at that note's blocks × takes. 5.5× the blocks is 5.5× the work
(18,016 → 998,116 is 55× for 100× the blocks — the fixed per-note overhead is the rest), and
`search()` is spawned per keystroke while a day is armed. That is P1's own sentence — *"cost ∝ what
is on screen and what is being edited, never the total size of the document or the corpus"* — and my
`editedOnClause` breaks it. **The `LIMIT 40` cannot save it**: the `ORDER BY` is a `COALESCE`
expression, so the plan carries `USE TEMP B-TREE FOR ORDER BY` and every row's `WHERE` is evaluated
before any row is discarded. I built the arm the way the brief's own sketch wrote it and never
questioned the shape; that is mine, not the brief's.

**Two refinements my re-measurement adds to the finding, both strengthening it:**

1. **`idx_commit_created` ALONE does nothing on the shipped store — because the app never runs
   `ANALYZE`** (I grepped: no `ANALYZE` anywhere in `Sources/` or the app; the only mention is a
   comment at `Migrations.swift:491`). With no `sqlite_stat1`, the planner keeps the correlated
   order (`SEARCH cp USING COVERING INDEX idx_commit_variant`) and the step counts are **identical to
   the byte** with and without the index — the column above. *With* `ANALYZE` the planner does
   re-order the correlated subquery to start at `idx_commit_created` (12,617 / 10,218 / 10,218), which
   is why this looks like a near-miss. It is not a near-miss: it is a fix that depends on statistics
   the app does not create, on a per-keystroke query. The uncorrelated form wins **without stats**,
   which is the only condition that matters here.
2. **The fixed form is not merely better, it is FLAT AND FREE**: 6,636 steps at 1, 20 and 100 blocks —
   *below* the 7,078 the same query costs on a day that matches every note. The day filter stops being
   a cost at all.

So: **the uncorrelated `id IN (…)` + `CREATE INDEX idx_commit_created ON commit_point(created_at)`,
the index in its OWN schema commit ahead of the code that relies on it** (CLAUDE.md's model-changes-
get-their-own-commit rule; 17c/P20's precedent that an index is not a §12 lockstep event — **the
marker stays 8**, and I will say so again in the record). Semantics are identical: the correlation
`cb.container_id = container.id` becomes the subquery's projection, so the set is the same set — and
the five correctness pins that would break if it were not (`aSavepointOnAnotherNotesBlockNeverAnswersHere`,
`aSavepointOnADeletedBlockNoLongerAnswersForTheNote`, the two Monday/Tuesday pins,
`anUntouchedNotesMintCountsAsItsEdit`) all ride unchanged as the proof.

**The pin that goes RED on the shipped code** (and it is the corrected R1-2 pin, so the two findings
close together): `theDaySearchsWorkTracksTheNotesNotTheSavepoints`, re-fixtured so **the searched day
matches NO note** and the fixture sweeps blocks-per-note, asserting the VM step count does not grow
with blocks — red on old at 18,016 → 206,116 (11.4× for 20× the blocks, where the claim is ~1×),
green after at 6,636 → 6,636. Beside it a plan pin: the plan must contain `idx_commit_created` and
must NOT contain `CORRELATED SCALAR SUBQUERY`. Both are step/plan assertions, never timings.

**R1-2 · MAJOR — AGREE.** The probe and the pin both write every note on the searched day, so the
`OR` short-circuits and the arm I was measuring never executed; the pin's own comment says it out
loud (*"the stamp arm answers most notes before the subquery runs at all"*) and I did not draw the
consequence. The "+27% of the VM steps" figure measures extra `COALESCE` comparisons, and
"note-shaped, not savepoint-shaped" was a claim about an arm that did not run. The 5578/5578
index comparison is real but proves only that the planner ignores a `created_at`-only index for the
CORRELATED form **without stats** — which R1-1 is precisely about. **The §4.8 half is agreed too and
is the part I should have caught while writing the record:** §4.8 predicted *"one indexed seek"* on
`idx_container_touched`, and the plan I pasted into THE MEASUREMENT verbatim says `SEARCH container
USING INDEX idx_container_kind (kind=?)` — because the first arm wraps the column in `COALESCE`,
exactly as the pre-existing `.lastTouched` sort does. I quoted the contradiction and did not name it.
The record will name it: **the day predicate cannot use `idx_container_touched` while it compares
the same COALESCE the row displays, and that is a deliberate trade** (the filter must never disagree
with the words beside it — a row reading *edited today* must be found by today), **whose cost is
bounded by the note count, not the corpus** — which is the shipped listing's own documented shape.

**R1-3 · MAJOR — AGREE, and it is the worst of the four, because the sentence it makes false is the
one the batch calls the product's honesty.** I re-read both sites (`LibraryCatalogView.swift:989-993`,
`:1018-1021`): the day is the only condition. Both paths are real — I confirmed by reading rather
than by running: (1) a typed query narrows the post arm's `LIKE` to nothing and the headline still
asserts a fact about the day; (2) `filtered` applies `scope` AFTER a day-armed `searchCatalog` has
returned posts only, so `.books` or `.blocks` yields `[]` with the picker disabled and ✕ the only
escape. **What I would build:** (a) the day answer renders only when the day is the ONLY narrowing
(`query` empty and the scope not restricted to a kind the day cannot answer); with a typed query
beside it the headline names the query too (*"No note matching "zzz" was edited on Sep 9."*) and
keeps the caveat, since the caveat is still the reason a note she remembers is missing; (b) arming a
day moves a `.books`/`.blocks` scope to `.posts` — **this reverses my own #104 recommendation and I
say so plainly**: I argued against a control moving under her hand, and the reviewer's trace shows
the alternative is an unreachable listing under a false sentence, which is worse. #104's shipped arm
gains that amendment rather than being re-opened. *Red on old:* a model pin —
`model.scope = .books; model.setEditedOn(today); await model.search()` — asserting the day's notes
are listed; and a wording pin for the typed-query headline.

**R1-4 · MAJOR (shared with batch 1) — AGREE on the defect; a note on the fix's shape.** The trace is
right: `limitPerKind: 40` was a benign top-N for *"the 40 most recently edited"* and this letter turned
it into a wrong answer twice — the day's answer is a SET (its size is the fact she asked for) and
A–Z is an ordering of the whole library. My walk's own capture 04 says *"30-odd notes answer"* on her
real store, which is one tutorial book away from silent truncation. **What I would build:** ask for
`limitPerKind + 1`, show the first 40, and let the model report `truncated` — so a "showing the first
40 — narrow the day or the search" line can be drawn without ever claiming a count the query did not
establish. I would NOT lift the cap unbounded: the listing's cost is ∝ the rows returned and a day
early in a big corpus can be large; an honest bound beats an unbounded promise. The fix lives in ONE
place (`LibraryCatalogModel.search()` + the two bodies' empty/footer slots) whichever batch is
charged with it — it is one fix, not two. *Red on old:* 45 notes on one day, `editedOn` set, assert
the model reports truncation (and, with the `+1` probe, that it knows there are more than 40).

**R1-6 · MINOR (shared) — AGREE.** `LibraryCatalogModel` is ~250 lines of model inside a 1,509-line
view file, and I added to it while my own file header says the opposite. It is a pure mechanical move
to `LibraryCatalogModel.swift` beside the two new files, and I would do it as its OWN commit with no
behaviour in it — which also makes the R1-3 and R1-4 fixes land somewhere readable.

**R1-8 · MINOR — AGREE, and the finding is sharper than it says.** `DayBounds.init(containing:)` has
no production caller (I re-grepped: the only production construction is `DayBounds(day:)` at
`LibraryCatalogView.swift:256`), its doc names a door that does not go through it, and the
force-unwrap's proof is Gregorian-only. **The part worth escalating:** the same mismatch reaches the
SHIPPED path. `JournalDay.dayString` emits the CURRENT calendar's components while `JournalDay.isValid`
validates proleptic Gregorian — so under a non-Gregorian `Calendar.current` the day key the field
produces (`"5786-13-05"`) is refused by `setEditedOn` and the filter would silently never arm. That
predates me (`JournalDay` is Phase 8's) but my code inherits it. **What I would build:** delete
`init(containing:)` and its pin (dead code whose only keeper is its own test is the class the finding
names), and give the day filter an explicit GREGORIAN calendar carrying the user's TIME ZONE — her
local day boundaries, the store's own day grammar — rather than `Calendar.current` wholesale. That is
consistent with `entry_date`/`JournalDay` everywhere else in the store, and it is two lines.

**R1-9 · MINOR — AGREE.** The pin drives `dateBinding`, not the closed door's Button closure, and
passes only because it feeds the same value the closure would compute. It is my own *"never
hand-feed"* standard applied to every control but the one. Fix: expose the closed door's action
(`var todayPick: String`, or an `openAction` closure) and assert through it, so changing the Button
to open on yesterday turns it red.

**R1-11 · MINOR — AGREE.** Read and confirmed: `showsCatalogControls` gates the sort menu and the day
field, but the scope `Picker`'s `.disabled(model.editedOn != nil)` sits outside that `if`
(`LibraryCatalogView.swift:825`), so in Timeline the picker is dead with its clearing door off screen.
One line: `.disabled(model.showsCatalogControls && model.editedOn != nil)`.

**R1-12 · NIT — AGREE.** `.help("")` is a placeholder standing in for "no tooltip" and a string-as-rule
in a body. Apply the modifier conditionally.

**R1-15 · NIT — AGREE.** `.frame(maxWidth: 520)` is an unnamed number-as-rule in the one file that
otherwise names and justifies its measured constant. It gets a name and a sentence (it is the
caveat's measure — the line length at which two sentences of explanation stay readable).

**R1-13 · NIT — AGREE, with one precision.** `showsSortDoor` is a forwarder for a pin minted by the
SAME letter, which is not what the 3C parity pattern is for (that pattern protects pins a batch must
not touch). I would rename the batch-1 assertion and retire the alias. The precision: I kept it
deliberately and said so in the record, so this is a judgment I lost rather than an oversight — the
right reading is the reviewer's, because two names for one rule with no distinction is exactly the
drift the same letter should not ship.

**Not mine to answer** (batch 1's, recorded here only so the tally is complete): R1-5, R1-7, R1-10,
R1-14, R1-16, R1-17.

**Tally, batch 2's findings: 9 agreed · 0 disputed** (R1-1 BLOCKER · R1-2, R1-3, R1-4 MAJOR · R1-6,
R1-8, R1-9, R1-11 MINOR · R1-12, R1-13, R1-15 NIT — eleven items over nine numbered findings, two of
them shared with batch 1). **Nothing disputed, and two of them (R1-1's shape and R1-2's falsified
measurement) overturn a judgment the record and the J11 adjudication both rest on** — the corrected
measurement above is the evidence for re-adjudicating it. No code was edited in this pass.

#### Implementer's responses (round 1, batch 1)

*(The same-model agree/dispute pass, written by 18h batch 1's implementer. I re-traced every
finding in the code myself before answering, and **re-measured the two that rest on numbers** —
R1-5's formatter cost with my own `swiftc -O` probe, and R1-10's timezone claim against a real
`sqlite3` on our exact stamp format. Where I disagree it is with a FIX's shape or a finding's
premise, never with a defect; each is said outright rather than folded into an agreement. No code
was edited in this pass.)*

**R1-4 · MAJOR (shared with batch 2) — AGREE, and batch 2's `limitPerKind + 1` shape is the right
one.** Re-traced: `LibraryCatalogModel.search()` asks for `limitPerKind: 40`
(`LibraryCatalogView.swift:259`), the post arm ends `ORDER BY … LIMIT ?`
(`ShelfQueries.swift:449`), and I re-grepped the whole catalog view for a count or a "more" — there
is none (the only two hits for `count` in the file are the pick's own labels). The finding's
distinction is the one that matters and I missed it while building: *"the 40 most recently edited"*
is an inherently top-N answer that a cap tells the truth about, while **"title · A–Z" is an
ordering of the WHOLE library**, and a capped alphabetical listing reads as the library while being
its first 40 names. My own walk shows it: capture `05` lists 28 rows of `2026-…` day-names under
A–Z and the alphabet never reaches a letter — on her real store the As are the whole answer. The
masthead's own words make it worse (*"everything — sortable, searchable"*). I agree with batch 2
that the cap should NOT be lifted unbounded (the listing's cost is ∝ rows returned) and that the
honest shape is ask for 41, show 40, let the model report `truncated`. **One fix, one place**
(`search()` + the two bodies' footer slots) — it closes the day's answer and A–Z together, and I
have no claim on which batch carries it. *Red on old for my half:* 45 notes named `a…`–`z…`,
`setSort(.title)`, assert the model reports truncation (and, with the +1 probe, that it knows there
are more than 40); fails on this tree.

**R1-5 · MINOR — AGREE on the defect and on the cache; DISPUTE the fix's second half (the lazy
tooltip).** The mechanism is exactly as traced and it is mine: `TimeStampFace.formatted`
(`TimeStampFace.swift:203`) allocates a `DateFormatter` and calls
`setLocalizedDateFormatFromTemplate` on **every** call, and `CatalogRowStamp.body` calls both
`stamp` (`LibraryTimeFace.swift:205`) and `tooltip` (`:211`) — `.help(_:)` takes a built `String`,
so the tooltip is paid whether or not anyone hovers. Two builds per row × 40 rows per body
evaluation, on the main thread, re-evaluated per keystroke.

*My own measurement* (a throwaway `swiftc -O` probe, this machine, fixed calendar/locale, 400
iterations, warmed): **72.4 µs per build+format → 5.79 ms for 80**, versus **1.8 µs per format
through a cached formatter → 0.141 ms for 80**. That is 41× rather than the finding's 110× (my
cached number is slower than the reviewer's 0.68 µs/call, probably a different warm state), and it
confirms the finding's substance: ~5.8 ms of avoidable main-thread work per full list body. Not a
P1 breach — it is bounded by the viewport, as the finding says — but it is on the surface the
project's first principle calls *snappy, always*.

**The dispute, and it is narrow:** *"compute the tooltip lazily"* is not available. `.help` takes a
value, not a closure, and SwiftUI offers no hover-deferred help; building one with `.onHover` +
`@State` adds per-row state and a redraw on every pointer entry, which costs more than the 72 µs it
saves. Once the cache lands, a tooltip build is one `string(from:)` — 1.8 µs — and the eagerness
stops being worth machinery. **So: the cache, and only the cache.** Its shape, since the file has
no lock today: a `nonisolated(unsafe) private static let cache` guarded by an `NSLock` (the
`StoreKey.sweptAccounts` / `SyncSchema.columnCatalog` pattern already in `Sources/`, both static
caches behind an `NSLock`), keyed by `(template, locale.identifier, calendar.identifier,
timeZone.identifier)` — a plain `nonisolated(unsafe) static var` dictionary without the lock would
be a data race, which the existing `variorumISO8601` precedent does not license (it is an immutable
`let`).

**R1-6 · MINOR (shared) — AGREE.** `LibraryCatalogModel` is a ~250-line `@Observable` inside the
1,509-line view file that this letter's own briefs cite as the god-file example, and I added ~50 of
those lines (the sort state, its memory, `showsSortDoor`) while my new file's header says the
opposite in so many words. It is a mechanical move to `LibraryCatalogModel.swift` beside
`LibraryTimeFace.swift` and `LibraryDayFilter.swift`, with no behaviour in the commit — and, as
batch 2 says, doing it FIRST makes the R1-3/R1-4 fixes land somewhere readable. One fix, not two;
whichever batch carries it should carry it alone.

**R1-7 · MINOR — AGREE, and to the orchestrator's question: the `Shared/` hoist is mechanically
small, with ONE consequence that is not mechanical.** Re-read both tables: `LibrarySortFace.label`
(`LibraryTimeFace.swift:49`) says `edited` · `created` · `date` · `title`;
`MobileLibraryViewModel.sortWord` (`:81`) says `last touched` · `created` · `entry date` · `title`.
They disagree on two of the four shared cases. The phone's table predates me — but **I minted the
second wording** and then added `.title` to the phone's rather than hoisting, so the drift is
this batch's to own.

*Small, mechanically:* `App/Variorum/Shared/` is a `PBXFileSystemSynchronizedRootGroup` (verified in
`Variorum.xcodeproj/project.pbxproj`), so a new file there compiles into BOTH targets with no
project edit — the table is ~15 lines and there are exactly two call sites. *Not mechanical:* one
wording then wins, and the phone's picker VISIBLY changes (*last touched* → *edited*, *entry date* →
*date*). I think that is correct rather than merely convenient — **her R-Q8 names those four words
herself** (*"edited (the default, as today) · created · date (entry date) · title A–Z"*), so the
Mac's table is the ruled one and the phone's is the older one — but it is a phone-visible string
change, so it is the orchestrator's to route (and MobileSoul's parity row already says the phone
owes a version of this vocabulary). The reviewer's framing is the right rule to hoist under: **each
platform chooses which cases it OFFERS (`sortOptions` stays the phone's four stamps), never what
they are CALLED.**

**R1-10 · MINOR — AGREE on the mechanism; DISPUTE the first proposed fix; and to the orchestrator's
question: a doc correction is honest, but it is NOT the best available — there is a one-expression
fix that makes the SQL agree with the words.** I re-read both sides. `DisplayTitle.day(fromStamp:)`
(`DisplayTitle.swift:137-140`) is the LOCAL calendar day of the stored instant, and **its own doc
says why** — *"the two slots must mean the same KIND of day: `entry_date` is written by
`JournalDay.dayString(from:)` over `Calendar.current`, so a UTC-sliced fallback beside it would read
a day later for anything written after early evening in a negative-offset zone."* My SQL's third
link (`Timeline.swift:126`) is the raw instant. Inside the created-at group the two agree (the
local-day map is monotone in the instant); across the groups they can invert exactly as traced. My
doc's claim — *"it orders by what she is LOOKING AT, never the raw column"* — is therefore false at
that boundary, which is the real defect.

**The dispute:** the finding's first option, `substr(created_at, 1, 10)`, **does not fix it.** That
is a UTC slice — precisely the thing `DisplayTitle`'s doc rejects — so the same note created
`2026-03-05T02:00:00.000Z` in UTC−5 still sorts under `2026-03-05` while displaying `2026-03-04`.
It removes the time component and leaves the inversion.

**What does fix it, measured:** `date(created_at, 'localtime')`. I ran it on our exact stamp format
in `sqlite3` 3.51: `TZ=America/New_York sqlite3 :memory: "SELECT date('2026-03-05T02:00:00.000Z','localtime')"`
→ **`2026-03-04`** (and `2026-03-05` under `TZ=UTC`), i.e. byte-identical to what
`DisplayTitle.day(fromStamp:)` shows, with and without the trailing `Z`. One expression, no stored
column, no per-row Swift. Its two honest costs, both worth saying: the order becomes
**process-timezone-dependent** (two devices in different zones order these rows differently — but
their DISPLAYED names differ too, which is the whole point of matching), and it inherits R1-8's
`Calendar.current`-vs-Gregorian mismatch under a non-Gregorian system calendar (SQLite's `localtime`
is Gregorian; `JournalDay.dayString` is not). **My recommendation:** `date(created_at,'localtime')`
as the third link, with a doc sentence naming the timezone dependence — and, if the orchestrator
prefers the smaller landing, the doc correction alone is honest and I will not argue against it
(the case is genuinely narrow: untitled, undated, created inside the offset window of midnight,
beside an entry-dated neighbour on the boundary day). *Red on old either way:* a core pin with a
fixed non-UTC calendar and that exact pair; fails on this tree.

**R1-14 · NIT — AGREE on the defect; DISPUTE the premise, and the correction makes the finding
LARGER, not smaller.** `PostDetailOracle.stampShown` / `stampEditedAt` / `flipStamp`
(`PostDetailView.swift:892-896`) are indeed global, and the brief did ask for the row-53
keyed-by-subject rule. But the finding says the rule *"was applied to `MastheadGeometry.stampFrame`
beside them"* — **it was not**: `stampFrame` is a plain `static var CGRect?` (`:927`) written by
`case .stamp: stampFrame = frame` (`:936`), with no post id anywhere. The only keyed slot in that
oracle is `cardFrames` (`:910`), and its key is a TAG id, not a subject. So **all four** of the
oracles this batch added are unkeyed, and I wrote a comment on the probe slot claiming the
one-masthead assumption instead of doing what the brief asked (*"keyed by post id (row 53's rule)"*)
— that is mine, and the record should say so rather than the finding's half of it. DEBUG-only and
harmless with one window, as the finding says. *The fix if it is taken:* key all four by post id —
which touches the shipped `MastheadLayoutTests` reads of `pathChipFrame`/`cardFrames` if it is done
consistently, so the smaller honest landing is to key the three `PostDetailOracle` fields (no
shipped reader) and state the one-detail assumption in `MastheadGeometry`'s own doc.

**R1-16 · NIT — AGREE, and one grep sharpens it.** `Queries.library` selects
`\(sort.expression) AS stamp` (`Timeline.swift:135`) and `observeLibrary`
(`Observations.swift:43`) takes the full `LibrarySort`, so `.title` can put a display NAME into a
field documented as *"the value of the ordering stamp for this row — feeds the next page's cursor"*.
Nothing reaches it today (every caller passes `.lastTouched`: `LibraryViewModel:48`/`:65`,
`CompareBoardView:227`, `ReadingViews:110`, `TimelineView:64`, `MobileLibraryViewModel:110`), and
the keyset cursor itself is `timelinePage`'s, which takes `TimelineOrder` and cannot see `.title` at
all. **What I checked beyond the finding:** the faces that consume a `TimelineItem.stamp` go through
`BlockHistoryFace.stampText` (`Shared/BlockHistoryFace.swift:271`), which parses with the one
canonical formatter and **returns nil on anything that is not a stamp** — so a title arriving there
would render nothing rather than raw text. That fail-safe is what keeps this a NIT.
*Closure, cheapest first:* a sentence on the `.title` case and on `TimelineItem.stamp`. *Stronger,
one line:* have `library()` select a stable date (`COALESCE(last_touched_at, created_at) AS stamp`)
while ORDERING by `sort.expression` — the field's doc becomes true again for every sort, and the
grep above says no caller reads `stamp` as "the value I sorted by". I would take the stronger one;
either closes it.

**R1-17 · NIT — AGREE.** Confirmed at `LibraryCatalogView.swift:1047`: on the Notes card the stamp
sits in the title's `HStack` before the `Spacer()`, where the List row's is past it. R-Q7's word is
*"trailing"*, and the card diverges from it deliberately — the Apple-Notes card she pointed at puts
the date beside the title — but I never said so where she will read it: **#103 asks which FACT the
card shows and never asks where it sits.** The clause belongs in #103 (one sentence naming the
divergence and the alternative: the stamp past the `Spacer()`, beside the book names). It lands with
the fixes; it is a notes edit, not a code one.

**Not mine to answer** (batch 2's, listed only so the tally is complete): R1-1, R1-2, R1-3, R1-8,
R1-9, R1-11, R1-12, R1-13, R1-15.

**Tally, batch 1's findings: 8 agreed · 0 disputed as defects.** (R1-4 MAJOR shared · R1-5, R1-6
shared, R1-7, R1-10 MINOR · R1-14, R1-16, R1-17 NIT.) **Three carry a dissent the orchestrator must
arbitrate, and none of them shrinks a finding:** R1-5's fix loses its second half (a lazy `.help` is
not available and stops being worth machinery once the formatter is cached); R1-10's first proposed
fix (`substr`) does not fix the traced defect, and a measured one-expression alternative
(`date(created_at,'localtime')`) does; R1-14's premise is wrong in the direction that makes it
bigger (neither oracle is keyed, not one of two). Two of the eight are SHARED with batch 2 and are
one fix each, not two.

#### Orchestrator's ARBITRATION (round 1) — against the spec, same-model flow (2026-09-13)

*(Written after both implementers' responses — batch 2's under `#### Implementer's responses (round 1, batch 2)` (`0e08913a`, 9 agreed · 0 disputed) and batch 1's under `#### Implementer's responses (round 1, batch 1)` (`9c619f8f`, 8 agreed · 0 disputed, three dissents on fix SHAPE and one correction — ruled below). The spec outranks both agents; a dispute is a reason to re-check, never a veto.)*

- **R1-1 BLOCKER — CONFIRMED; the reviewer's fix shape is the ruling.** P1 (OverallModel §5) in its own words: the correlated `EXISTS` behind the `OR` runs for every note whose stamp misses the day — the ordinary use — at Σ(blocks × takes) over the corpus, measured 26.9 ms on a 300-note store and linear in blocks per note. The fix: the savepoint half UNCORRELATED (`id IN (SELECT cb.container_id …)`) so the day's own savepoints are the driver, plus `CREATE INDEX idx_commit_created ON commit_point(created_at)` **in its own schema commit ahead of the query that uses it** (CLAUDE.md: schema changes get their own commit; 17c/P20's precedent: an index touches no synced column and is not a SyncSpec §12 lockstep event — the marker stays 8; the phone's migration set gains the same index when it next builds, by construction of the shared migrations). Measured together 26.87 → 0.17 ms (the reviewer) and, in VM steps on the shipped statement (batch 2's own re-measure), FLAT at 6,636 across 1 → 100 blocks per note where the shipped form reads 18,016 → 998,116; the index alone does nothing for the correlated form — and batch 2 found the deeper reason: **the app never runs `ANALYZE`** (no `sqlite_stat1`), so the planner keeps the correlated order regardless — which is exactly why R-4's probe and my J11 saw 5578/5578. The `ANALYZE` absence is RECORDED (a KnownIssues note at the round's close, owner 12 — a statistics-dependent plan on a per-keystroke query is a hazard class of its own), not fixed here. **Owner: batch 2.** Red on old: `theDaySearchsWorkTracksTheNotesNotTheSavepoints` RE-FIXTURED so the searched day matches NO note on notes carrying many blocks, asserting the VM steps track the day's savepoints — plus the plan pin asserting `idx_commit_created` is used.
- **R1-2 MAJOR — CONFIRMED, and J11 is RE-ADJUDICATED here:** the measurement never executed the arm it measured (every fixture note satisfied the stamp arm, so the `EXISTS` short-circuited); "note-shaped, not savepoint-shaped" was a claim about an arm that did not run, and I accepted it. The corrected measurement lands in R-4's record with the fix; §4.8's "one indexed seek" promise dissolved by the `COALESCE` is to be stated in the record (the sort's `COALESCE(last_touched_at, created_at)` order makes `idx_container_touched` unusable — a pre-existing shape the letter inherited from `searchCatalog`'s own ORDER BY, now named). **Owner: batch 2.**
- **R1-3 MAJOR — CONFIRMED, both halves:** (a) the day's sentence only when the day is the ONLY narrowing (query empty, scope ∈ {all, posts}); otherwise the wording names the real cause, or the plain `Nothing matches.`; (b) arming a day moves a `.books`/`.blocks` scope to `.posts` — this is #104's own option (c) applied to the VALUE, not new product: "a day names notes" is the shipped PROVISIONAL arm's letter, and a disabled picker holding a value the listing cannot honour is a face defect, not a design. #104 gains one clause. **Owner: batch 2.** Red on old: the model pin the reviewer names.
- **R1-4 MAJOR — CONFIRMED as a defect of the DAY's answer; RULED in two halves:** (1) while a day is armed the cap is LIFTED — the day's predicate bounds the answer set (cost ∝ the day's notes, P1-safe), and a day's answer that hides notes is wrong, not merely incomplete; (2) for the capped listing under every sort (the `.title` order included) the truncation is DRAWN in one quiet line (the P-2 grammar — the app says what it did: "showing the first 40 — narrow the search"), a `LibraryCopy`-class string in the one place; the shape both implementers proposed — ask for `limitPerKind + 1`, show 40, report `truncated` — is adopted (no count query: a count is a second statement per keystroke). Not product invention: the cap shipped at 13g; naming it is honesty. **Owner: batch 2 for both halves** (one hand in `LibraryCatalogView`/`LibraryDayFilter`; batch 1's implementer reviews the title half in its own sanity read). Red on old: the 45-notes core pin; the face: the line present under a truncated listing.
- **R1-5 MINOR — CONFIRMED (measured 110× by the reviewer, 41× by batch 1's own probe — the defect is the same), no pin owed (a degradation, not a wrong output). Batch 1's dissent on shape is UPHELD:** the static formatter cache keyed by template · locale · calendar · timeZone, guarded by an `NSLock` (the `StoreKey.sweptAccounts` / `SyncSchema.columnCatalog` pattern — `variorumISO8601` is an immutable `let` and does not license a mutable dictionary); the tooltip stays EAGER (`.help` takes a built `String`; a hover-deferred build costs more than the cached 1.8 µs it would save). **Owner: batch 1.**
- **R1-6 MINOR (F-0) — CONFIRMED; the extraction is RULED IN this round** as a mechanical move: `LibraryCatalogModel` to `Features/Library/LibraryCatalogModel.swift`, byte-identical body, zero test edits (the 3C parity proof). **Owner: batch 2** — done FIRST as a behaviour-free commit (both implementers' preference: the other fixes then land somewhere readable), zero test edits.
- **R1-7 MINOR — CONFIRMED in principle; RULED as a Shared hoist, small:** the sort words move to `App/Variorum/Shared/` beside `TimeStampFace`'s consumers (one table; each platform chooses which cases it OFFERS). Touches `Shared/` → the iOS build is owed. The phone's picker strings change (*last touched* → *edited*, *entry date* → *date*): RULED — her R-Q8 names those four words herself, so the Mac's table is the ruled one and the phone adopting her words is parity, not invention; PL-22 notes it. **Owner: batch 1.**
- **R1-8 MINOR — CONFIRMED and SHARPENED by batch 2's own re-read:** `DayBounds.init(containing:)` has no production caller and its force-unwrap is unsafe under a non-Gregorian calendar — REMOVE it and its pin (a public door nothing walks through is the drift class). And the shipped path is reached too: `JournalDay.dayString` (the CURRENT calendar) vs `JournalDay.isValid` (proleptic Gregorian) means under a non-Gregorian `Calendar.current` the filter would silently never arm. Ruling: the day filter's calendar is an EXPLICIT Gregorian calendar carrying the user's time zone (the day KEY is Gregorian ISO by `JournalDay`'s own definition; the time zone is what makes it her day) — one construction site, pinned under a Hebrew `Calendar.current`. **Owner: batch 2.**
- **R1-9 MINOR — CONFIRMED:** drive the closed door's real action (expose it as `dateBinding` is exposed). **Owner: batch 2.**
- **R1-10 MINOR — CONFIRMED as stated; RULED as a DOC correction, not a sort change.** Batch 1 measured that `substr(created_at,1,10)` (the reviewer's first shape) does NOT fix it — a UTC slice — and that `date(created_at,'localtime')` DOES (byte-identical to the displayed name on our stamp format); but that expression makes the ORDER process-timezone-dependent per row and inherits R1-8's calendar mismatch, for an inversion that needs an untitled, undated note created within the offset window of midnight beside an entry-dated neighbour on the boundary day. The smaller honest landing is the ruling: the doc says the created-at link orders by the INSTANT and names the corner; the `localtime` expression is recorded in the doc as the available fix if she ever meets it. No pin (a doc). **Owner: batch 1.**
- **R1-11 MINOR — CONFIRMED:** clear the day when the mode leaves the catalog (the `clearSelection`-on-mode-switch precedent), which also answers the picker's dead state. **Owner: batch 2.** Red on old: a model pin — mode → `.timeline` leaves `editedOn` nil.
- **R1-12 · R1-13 · R1-15 NIT — CONFIRMED, batch 2.** **R1-14 · R1-16 · R1-17 NIT — CONFIRMED, batch 1** — R1-14 WIDENED by batch 1's own correction: `MastheadGeometry.stampFrame` is not keyed either; all FOUR oracles the batch added are unkeyed, so all four are keyed by post id (DEBUG-only, small); R1-16: refuse `.title` in `Queries.library()` with a documented precondition rather than a sentence; R1-17: one clause on #103 — "trailing" on the card is unanswered by her word.

**The order of work (one agent at a time):** batch 2's implementer first — R1-6's extraction FIRST (behaviour-free), then R1-1's index commit, then the query, then R1-2's re-fixture and record correction, R1-3, R1-4, R1-8, R1-9, R1-11, the three NITs; core `swift test` + the Library suites + the tutorial spine + the iOS build; then batch 1's implementer — R1-5, R1-7 (Shared → iOS build), R1-10, R1-14, R1-16, R1-17 + the #103 clause; the same closing runs. Then round 2 with a FRESH `opus-reviewer` over the fixes.

---

#### Batch 2's fixes (round 1)

*(Applied in the arbitration's order, one commit per finding, path-scoped, each pushed as it landed.
Every red-on-old below was run on the tree the fix landed on — for the face findings that meant
writing the pin BEFORE the fix and watching it fail in place, which is cheaper and more honest than a
worktree: the committed tree IS the pre-fix tree. `Sync/` untouched; `Shared/` untouched. The last
code hash is `bfe8d75c`.)*

| # | finding | commit | pin | red on old |
|---|---|---|---|---|
| 1 | **R1-6** the model's extraction | `1667a8cb` | — (behaviour-free) | nothing to be red on; the parity proof is ZERO test edits, 33/5 green unmodified |
| 2 | **R1-1** the index, its own schema commit | `33407d64` | `MigrationTests.theDaySearchIndexArrivesForAnOlderStore` | a v1_16 store carries no `idx_commit_created`; migrating adds exactly one index |
| 3 | **R1-1** the query turned around | `f714ca73` | `LibraryDaySearchTests.theSavepointArmIsDrivenByTheDaysOwnSavepoints` · `…theDaySearchsWorkTracksTheDaysSavepointsNotTheCorpusBlocks` | the plan carried `CORRELATED SCALAR SUBQUERY` and no `idx_commit_created` **with v1_17 already in the store**; the steps read **1,896 → 13,096** for 1 → 15 blocks per note (6.9× for 15× the blocks). Green: **916 → 916** — flat, and less than half the old floor |
| 4 | **R1-2** the record's correction | `e695f63f` | — (a record) | the falsified measurement is kept in place under a warning, with the corrected table beside it |
| 5 | **R1-3** both halves | `62f8870e` | `LibraryDayFilterTests.armingADayMovesABooksScopeToNotes` · `…theDaysSentenceIsNotSpokenForAScopeItCannotDescribe` · `…theEmptyAnswerNamesTheTypedQueryWhenOneIsNarrowingToo` | `scope → .books` where `.posts` is owed **and** the listing `[]` where the day's note is owed; `dayForEmptyAnswer` and `emptyAnswer(query:)` did not exist |
| 6 | **R1-4** both halves | `6066c6f9` | `LibraryDaySearchTests.aDaysAnswerIsNotCappedWhenTheCallerLiftsTheCap` · `LibraryDayFilterTests.theDaysAnswerIsWholeAndACappedListingSaysSo` · `…theProbeIsExactAtThePagesEdge` | `limitPerKind: nil` did not compile (the parameter was a non-optional `Int`); no `truncated` member; the day's answer stopped at 40 of 45 |
| 7 | **R1-8** the calendar + the removal | `7a5f7da6` | `LibraryDayFilterTests.theFiltersCalendarIsGregorianAndKeepsHerTimeZone` | `LibraryDayFace.calendar` did not exist; every site took `Calendar.current` whole |
| 8 | **R1-9** the closed door's action | `b403b879` | `LibraryDayFilterTests.openingTheClosedDoorPicksToday`, rewritten | `openOnToday()` did not exist; the old pin drove the BINDING and could not fail |
| 9 | **R1-11** leaving the catalog | `b40cab03` | `LibraryDayFilterTests.leavingTheCatalogClearsTheDay` | `editedOn → "2026-09-17"` where nil is owed |
| 10 | **R1-12 · R1-13 · R1-15** | `bfe8d75c` | the two suites green with batch 1's three assertions renamed | — (cosmetic; R1-13's proof is that the alias is gone and nothing references it) |

**What each fix actually changed, beyond the table:**

- **R1-1.** The savepoint half is now `OR id IN (SELECT cb.container_id …)` and the driver is
  v1_17's `idx_commit_created`. The set is the same set — the correlation became the subquery's
  projection — and the five correctness pins rode unchanged, which is the proof. **The `ANALYZE`
  finding is the part worth carrying forward:** the app never runs it, so with no `sqlite_stat1` the
  planner keeps a correlated order whatever indexes exist; the index alone left the step counts
  identical to the byte. The arbitration records that for owner 12.
- **R1-3(b) reverses my own QUESTIONS #104 recommendation and #104 says so now** (the amendment is
  filed on the question itself): I argued against a control moving under her hand, and the trace
  showed the alternative is an unreachable listing under a confidently false sentence. The scope
  moves once, on arming, and does NOT move back on clearing — a control that moves twice is worse
  than one that moves once.
- **R1-4** made `limitPerKind` optional (`nil` = unbounded), which is `Queries.library(limit:)`'s own
  convention two screens down in the same file; the day lifts the cap and everything else asks for
  `pageSize + 1`, draws `pageSize`, and reports `truncated` — no `COUNT(*)`, which would be a second
  statement per keystroke. The two plain empty sentences moved into the new `LibraryCopy.swift`
  beside the truncation line, so no listing sentence is a literal in a view body any more.
- **R1-8** removed `DayBounds.init(containing:)` outright rather than making it failable: a public
  door nothing walks through, whose force-unwrap was sound only in a Gregorian calendar its signature
  did not require. **Recorded, not fixed:** the row STAMPS still word themselves in
  `Calendar.current` (batch 1's `TimeStampFace`), so a non-Gregorian user would read one calendar in
  the rows and another in the day door — batch 1's surface, named here so it is not lost.
- **R1-11** gave the view ONE door for a mode change (`modeChanged()`) rather than two calls a future
  mode could forget one of.

**Two honesty notes on the mechanics:** R1-11's PIN rode in R1-9's commit (`b403b879`) because both
live in `LibraryDayFilterTests.swift` and the test file was staged with the R1-9 fix; R1-11's own
commit carries the model and the view. And the R1-3 fix was written before its pin, so I reverted it
with `git checkout --` (announced, from the committed tree — never a scratchpad copy), wrote the pin,
watched it fail on the real pre-fix code, and re-applied the identical edits.

**THE CLOSING RUNS (this batch's fixes, at `bfe8d75c`):**

- **Core (`swift test`, repo root):** `✔ Test run with 1542 tests in 167 suites passed after 59.799 seconds.`
  (+1 over the batch's close: `MigrationTests`' new index pin. The day-search suite grew by two and
  lost none — two measurement pins were REWRITTEN in place, and `DayBoundsTests` lost the retired
  initializer's pin, which is the −1 that balances it.)
- **Mac (ONE `xcodebuild test` from `App/Variorum/`, TYPE names, zero `skipped:` lines — the same 37
  suites the batch closed on):** `✔ Test run with 215 tests in 37 suites passed after 111.111 seconds.`
  (+7 over the batch's 208: the five new day-filter pins and the two R1-4 ones.)
- **iOS (`xcodebuild build -scheme VariorumMobile -destination 'generic/platform=iOS'` — the
  migration set is shared, so the phone gains v1_17 by construction):** `** BUILD SUCCEEDED **`.

**What I did NOT do in this pass:** nothing in `Sources/VariorumCore/Sync/`, nothing in
`App/Variorum/Shared/` (R1-7 is batch 1's), no editor-seam file, no new `setting` key, no mirror DDL
— **the lockstep marker stays 8**, as the migration's own comment says. Batch 1's findings (R1-5,
R1-7, R1-10, R1-14, R1-16, R1-17) are untouched, except that R1-13's rename edited three assertions
in `LibrarySortMenuTests` — which is the fix itself, and they pass.

#### Batch 1's fixes (round 1)

*(Applied in the arbitration's order, one commit per finding, path-scoped, each pushed as it
landed. `Sync/` untouched, no schema, no migration, no new `setting` key — **the marker stays 8**.
`Shared/` IS touched (R1-7's whole point), so the iOS build was owed and ran twice. Her app was
running at `/Applications` for none of this — `pgrep` empty before the timed runs — and no walk was
needed: every fix here is a brain, a doc or a DEBUG oracle, and the one user-visible change (the
phone's picker words) is pinned on the simulator rather than guessed at. The last code hash is
`4159a5b6`.)*

| # | finding | commit | pin | red on old / the number |
|---|---|---|---|---|
| 1 | **R1-5** the formatter cache | `ccb3e69b` | `TimeStampFaceTests.theFormatterCacheAnswersPerLocaleCalendarAndZone` | no pin owed (a degradation). **Re-measured on the LANDED shape** (`swiftc -O`, 25 bodies × 80 calls): one 40-row list body **6.01 ms → 0.313 ms, 19×**. The pin that IS owed is the cache's own new risk |
| 2 | **R1-7** one table for the words | `dd78de17` | `MobileLibrarySortTests.theSortVocabularyIsPinned`, rewritten | the phone answered *"last touched"* / *"entry date"* where her R-Q8's words are *edited* / *date*; run for real on the simulator, **2 tests in 1 suite passed** |
| 3 | **R1-10** the A–Z doc | `a1728f2b` | — (a doc) | the corner worked as an example, and the `localtime` measurement recorded beside it |
| 4 | **R1-14** the four oracles keyed | `a4847522` | the three mounted stamp pins, each now naming its note | the pins read a global; with two note windows the last `onAppear` answered for both |
| 5 | **R1-16** `library()` refuses `.title` | `38307a68` | `LibraryTimeSortTests.theStampListingStillServesEveryStampSort` | a precondition cannot be pinned without trapping the process; the pin holds the other half (the guard does not over-fire) |
| 6 | **R1-17** the #103 clause | `821c6ecd` | — (a question) | — |
| 7 | **the calendar cousin** (the ladder's ruling) | `4159a5b6` | `TimeStampFaceTests.theStampsSpeakTheStoresOwnCalendarNotTheSystems` | the stamps defaulted to `Calendar.current` while the day door spoke Gregorian-in-her-zone — one screen, two calendars under a non-Gregorian system setting |

**What each fix actually changed, beyond the table:**

- **R1-5.** The cache is keyed by the WHOLE shape — template · locale · calendar · time zone —
  behind an `NSLock` (`StoreKey.sweptAccounts` / `SyncSchema.columnCatalog`; `variorumISO8601`
  beside it is an immutable `let` and licenses nothing mutable). The lock covers the dictionary;
  the formatter formats outside it, on the thread-safety the shared ISO formatter has relied on
  since Phase 1. **The tooltip stays EAGER, as ruled.** The re-measured 19× is smaller than the
  review's 110× and my own earlier 41× for raw per-call numbers. **[CORRECTED AT ROUND 2, R2-11 —
  the sentence that stood here said "the gap is the lock and the hash, which is the price of not
  racing a dictionary", and that is falsifiable and wrong.]** Round 2 measured the landed shapes on
  this machine (200k iterations): building per call **71.8 µs**, the cached path end-to-end
  **0.54 µs**, of which the lock + hash is **0.15 µs** and `JournalDay.storeCalendar`'s per-call
  construction (added under it by the calendar ruling) **0.08 µs**. So the lock and the hash cannot
  account for a 110× → 19× narrowing; what my own harness was paying beyond them is UNATTRIBUTED
  rather than newly explained — the honest correction is to withdraw the cause, not to invent a
  second one. The fix is BETTER than the record claimed: ~132× on the reviewer's numbers, and
  either way what left the main thread is ~5.7 ms per keystroke. **The pin exists because the FIX has a failure the slow code could not have:** a key
  that forgets part of the shape hands back a formatter speaking the wrong calendar or zone, so the
  same template is asked under four shapes and each must answer as itself — including 23:30 UTC
  being already tomorrow in Tokyo.
- **R1-7.** `Shared/LibrarySortWords.swift` holds the one table; both platforms' names are
  forwarders, so every call site and pin reads unchanged except the phone's own vocabulary pin,
  which is the fix. **Her words win by ruling** (R-Q8 names the four). What stays platform-side is
  copy no other platform says — the direction's wording and the Mac door's composed label — with a
  line in the file saying they move here when the phone grows a direction control, rather than
  being minted twice. **PL-22 owes the note** (the phone's picker strings changed).
- **R1-10.** The doc names the corner with its example and records `date(created_at,'localtime')`
  as the available fix with the measurement that says it works, plus the two reasons it was not
  taken — and records that the reviewer's first suggestion (`substr`) is NOT a fix, since a UTC
  slice is exactly what `DisplayTitle.day(fromStamp:)`'s own doc rejects.
- **R1-14.** The probe slot carries the post id (`case stamp(String)`); `MastheadGeometry` keeps
  `stampFrames` per note and `PostDetailOracle` keeps three dictionaries with `resetStamp(_:)`
  beside them. Both keep a one-window read so nothing outside this batch has to care. The finding
  believed `stampFrame` was already keyed; my response corrected that, the arbitration widened it
  to all four, and this is that.
- **R1-16.** `precondition` rather than a graceful fallback, because silently re-ordering a listing
  the caller asked for would be a quieter lie than the one being closed; the message names the
  alternative (`searchCatalog`, which carries no `stamp`). **Writing the pin found something worth
  the record: `TimelineItem.stamp` was ALREADY not always an instant** — under `.entryDate` it is a
  DAY key, true since Phase 8 — so the pin asks the one time-brain (`TimeStampFace.parse`, which
  knows both of the store's shapes) rather than the instant parser. A title parses as neither,
  which is exactly the line being drawn.
- **The calendar cousin.** `JournalDay.storeCalendar` in core `Domain`, beside the day grammar it
  is about; `TimeStampFace`'s eight public entry points default to it (so no caller passes
  anything), 18d's facts line follows through its own forwarder, and `LibraryDayFace.calendar`
  forwards so batch 2's pin rides unchanged. **What did NOT move:** `JournalDay.dayString`'s own
  calendar default stays `.current` — that parameter mints `entry_date` values throughout Phase 8's
  operations, and re-pointing it from the side is wider than this letter.

**THE CLOSING RUNS (this batch's fixes, at `4159a5b6`):**

- **Core (`swift test`, repo root):** `✔ Test run with 1545 tests in 167 suites passed after 58.037 seconds.`
  (+3 over batch 2's 1542: the two new `TimeStampFaceTests` and the one new `LibraryTimeSortTests`.)
- **Mac (ONE `xcodebuild test` from `App/Variorum/`, TYPE names, zero `skipped:` lines):**
  `✔ Test run with 204 tests in 34 suites passed after 108.697 seconds.`
  (The 34 = batch 1's closing 33 + `LibraryDayFilterTests`. The count is 204 rather than batch 2's
  215 because that run carried three day-search suites this set does not; every suite common to
  both is green in both.)
- **iOS (`xcodebuild build -scheme VariorumMobile -destination 'generic/platform=iOS'`):**
  `** BUILD SUCCEEDED **` — and, because R1-7 changed a phone-visible string and its pin, the
  mobile suite was RUN, not merely compiled: `✔ Test run with 2 tests in 1 suite passed` on the
  `Variorum-batch6a` simulator (`VariorumMobileTests/MobileLibrarySortTests`).

**What I did NOT do in this pass:** no walk (no user-visible Mac change: a cache, a doc, DEBUG
oracles, a precondition and a calendar default that is byte-identical for a Gregorian user — the
one visible change is the PHONE's picker words, pinned on the simulator); nothing in
`Sources/VariorumCore/Sync/`, no editor-seam file, no schema, no migration, no `setting` key;
**#103's RULING (R-Q17) left exactly as written** — I added only the clause the question never
carried, and the build of her ruling is 17q's. Batch 2's findings are untouched except that R1-7's
hoist moved the phone's `sortWord` body, which is the fix.

---

### 18h LADDER — ROUND 2 FINDINGS (opus-reviewer)

*(A FRESH cold reviewer, zero implementation context. Round 2 is the re-review of round 1's fixes
`e526f557..4159a5b6` — batch 2's ten (`1667a8cb` · `33407d64` (SCHEMA v1_17) · `f714ca73` ·
`62f8870e` · `6066c6f9` · `7a5f7da6` · `b403b879` · `b40cab03` · `bfe8d75c`) and batch 1's seven
(`ccb3e69b` · `dd78de17` · `a1728f2b` · `a4847522` · `38307a68` · `821c6ecd` · `4159a5b6`) — read
against the whole letter `2d43df7c^..4159a5b6` for what they touched. Anchor: the recorded round-1
findings, both implementers' responses and the orchestrator's arbitration, read in full before the
code. Tree `6c4d59de` == `origin/main`, notes-only after `4159a5b6`; zero `/Applications` instances
before, during and after.*

*Scope check first, per the reviewer's own contract: the diff touches **no** editor seam
(`EditorTextView` / `PaneTextAuthority` / `PaneMeasurement` / `BlockRangeIndex` all diff-empty over
the whole letter), **no** custody or keychain code, **nothing** in `Sources/VariorumCore/Sync/` or
`Server/` (verified by `git diff --stat` over both paths — empty), and changes **no** default's
meaning (`searchCatalog()` with no arguments still reproduces the shipped
`COALESCE(last_touched_at, created_at) DESC, id DESC`, pinned; `limitPerKind` gained `nil` but kept
its 20). `lockstepVersion` is still **8** (`SyncSchema.swift:101`). Opus is the right seat; no Fable
re-spawn is owed.*

**Counts: 0 BLOCKER · 1 MAJOR · 5 MINOR · 6 NIT.**

Verification runs I made myself (not the record's): core `swift test` → **`1545 tests in 167 suites
passed`** (60.6 s — the recorded closing number, reproduced on this tree); Mac
`-only-testing:` `LibraryDayFilterTests` · `LibrarySortMenuTests` · `MastheadStampTests` ·
`MastheadLayoutTests` · `LibraryRowAlignmentTests` · `MastheadTagDoorTests` → **`46 tests in 6
suites passed`** (`DerivedData/review18h-r2`). Two external facts checked through one Sonnet lookup
(Apple docs): `DateFormatter` concurrent `string(from:)` and SwiftUI's `\.calendar` — both cited
where they bear.

#### Findings, severity-ranked

**R2-1 · MAJOR · batch 2 (R1-11's fix) · `LibraryCatalogModel.swift:241-244` +
`LibraryCatalogView.swift:219` — clearing the day on a mode change leaves the LISTING narrowed by a
day the header no longer shows.**

*Mechanism, traced:* `modeChanged()` sets `editedOn = nil` when the mode leaves the catalog, and it
is the only thing `.onChange(of: model.mode)` calls. **Nothing re-runs `search()` on a mode change** —
I grepped every `model.search()` call site in the view (`:211` the one-shot `.task`, `:261` rename,
`:278` the delete signal, `:391` the query field, `:396` the scope picker, `:425/:429` the sort door,
`:437/:441` the day field, `:784` archive) and the mode picker's binding is `set: { model.mode = $0 }`
with no task; `.task(id: model.mode)` (`:214`) calls only `refreshNoteCards()`. So: arm a day in List
mode (`hits` = that day's notes) → switch to Timeline (`editedOn` = nil, `hits` untouched) → switch
back to List. The header now reads `on day…` (closed), the scope picker is live again, and the list
is still the day's notes with **nothing on screen saying so** — the invisible-state hazard the fix's
own doc comment names, moved one step down. Any later keystroke, scope pick or sort pick repairs it
silently, which is what makes it read as "notes went missing" rather than as a filter.

This is a REGRESSION of the fix, not of the letter: before `b40cab03` the day survived the round trip
and `hits` agreed with it (the complaint was only the dead scope picker, which the reviewer's own
one-line alternative — `.disabled(model.showsCatalogControls && model.editedOn != nil)` — would have
closed without touching state).

*Fix:* make the mode change re-read when it cleared something — `func modeChanged() async` that
`await search()`s after clearing (the view already spawns tasks for every other listing change), or
clear the day on ENTERING the catalog rather than on leaving, or take the reviewer's original
`.disabled(...)` line and leave `editedOn` alone. *Red on old:* a model pin —
`setEditedOn(day); await search(); mode = .timeline; modeChanged(); mode = .list; modeChanged()` and
assert the notes the day excluded are listed again; fails on this tree (`hits` is unchanged).

**R2-2 · MINOR · batch 2 (R1-4's fix) · `LibraryCatalogModel.swift:346-363` +
`LibraryCatalogView.swift:616-619` — `truncated` is a WHOLE-listing flag read by a NOTES-ONLY body,
so the Notes mode can say "showing the first 40" over a complete list of notes.**

*Mechanism, traced:* `capped(_:to:)` counts per kind but collapses to ONE `over` boolean, and
`search()` stores it as `truncated` (`:324`). `notesBody` draws only `hits.filter { $0.kind == .post }`
(`:601`) and then `if model.truncated { LibraryTruncationLine(...) }` (`:616`). With `scope == .all`
(the default) in Notes mode, a books or blocks arm that came back with 41 rows sets the flag even
though every NOTE is drawn — so the line asserts a truncation of a listing the body does not show.
Reachable two ways: >40 live books with no query, or >40 matching named-block/pool-scrap hits under
any typed query (the block arm runs whenever the query is non-empty, `ShelfQueries.swift:479`). The
List mode is honest by comparison (its truncated section is on screen); the Notes mode is not.

*Fix:* have `capped` return the truncation PER KIND (or a `truncatedKinds: Set<Kind>`), and let each
body read its own — `notesBody` the post kind, `listBody` any. *Red on old:* a model pin — 41 books
+ 3 notes, `mode = .notes`, `await search()`, assert the notes body's truncation is false while the
list body's is true; fails on this tree (one flag, true for both).

**R2-3 · MINOR · batch 2 (R1-4's fix) · `LibraryCatalogModel.swift:316` ·
`LibraryCatalogView.swift:866` · `ShelfQueries.swift:462` — lifting the cap for the day un-bounded
three things that were bounded by it, and two of them carry docs that still say they are bounded.**

*Mechanism, traced:* `let cap: Int? = day == nil ? Self.pageSize + 1 : nil` makes the day's answer
unbounded — correct for the ANSWER (the ruling) — but everything downstream of `hits` inherited the
40-row bound and nothing was re-reasoned: (1) `loadTagChips(for: postIDs)` runs for every hit in
BOTH modes; (2) `loadNoteCards(for: postIDs)` in Notes mode runs `NoteCards.load` (three statements,
one of them `Queries.smartBookMembership` per smart book) over the whole set — and that function's
own doc (`LibraryCatalogView.swift:866`) still reads *"∝ books × rows on screen and FLAT in corpus …
A 200-row page costs 0.15 ms"*, a claim whose "rows on screen" premise the cap lift removed; (3) the
eager `DisplayTitle.note` map in `searchCatalog` whose comment (`ShelfQueries.swift:462`) says *"this
row-set is bounded by `limitPerKind`, so it is computed eagerly rather than lazily"* — nil is not a
bound. All three re-run per keystroke while a day is armed. **Not a P1 breach as I can measure it**:
the cost is ∝ the DAY's notes, not the corpus, and a day's notes are small in her store (her own
walk capture `04` says "30-odd"). It is the docs that are now false and the reasoning that is now
missing.

*Fix:* either bound the derived reads to the drawn window (the `observeLibrary` discipline the same
model cites elsewhere), or — cheaper and honest — correct the two doc claims to say what now bounds
them (the day's own predicate) and state the accepted ceiling. *No red-on-old pin owed* (a
degradation + two falsified doc claims, R1-5's class); the evidence is the two sentences above and
the `cap == nil` branch.

**R2-4 · MINOR · batch 1 (R1-7's fix) · `App/Variorum/Shared/LibrarySortWords.swift:50` +
`VariorumMobile/Features/Shell/MobileLibraryViewModel.swift:88` — the hoist changed an UNRULED,
phone-only picker string, against the hoisted file's own stated limit.**

*Mechanism, traced:* the arbitration's warrant for changing the phone's words is *"her R-Q8 names
those four words herself"* — **edited · created · date · title**. `.lastMajorRevision` is not among
them, the Mac does not offer it (`LibrarySortFace.offered`, `LibraryTimeFace.swift:45`), and the
phone does (`sortOptions`, `:77`). So the one case only ONE platform shows had its shipped, live
string changed from *"last meaningful edit"* — AppSpec §10's own vocabulary for
`last_major_revision_at` (*"meaningful edits only"*) — to *"revised"*, on nobody's ruling. The file
that made the change states the rule that forbids it four lines earlier: *"What stays platform-side
is copy no other platform says"* (`LibrarySortWords.swift:26-30`) — a word no other platform says is
exactly what this is. There was no drift to retire on that case: one table, one consumer.

*Fix:* keep her four in `Shared/` and leave `.lastMajorRevision`'s word on the phone (or restore
*"last meaningful edit"* in the shared table). *Disposition, not a pin:* the phone's own vocabulary
pin (`MobileLibraryTests.theSortVocabularyIsPinned`) is the assertion either way — it was edited to
match the change, so it will be edited back. If the shipped word is kept, it is a phone-visible
product change made from a Mac letter and belongs in PL-22 as a change, not as a note.

**R2-5 · MINOR · batch 1 (R1-16 + R1-7 together) · `Timeline.swift:194` +
`MobileLibraryViewModel.swift:96` — the letter gave the phone a WORD for `.title` and, in the same
letter, made the listing the phone uses TRAP on it.**

*Mechanism, traced:* `Queries.library` now `precondition(sort != .title, …)` — live in release
builds. The phone's listing is `observeLibrary(sort: sort, …)` → `Queries.library`
(`MobileLibraryViewModel.swift:106`), and its `setSort(_ next: Queries.LibrarySort)` (`:96`) accepts
any case with no guard; only `sortOptions` keeps `.title` out today. Meanwhile R1-7 gave `.title` a
word in the shared table *specifically so the phone's picker can say it*, and this letter's own
parity line says *"the phone owes a version of both"* (the sort included). So the very next mobile
touch that adds `.title` to `sortOptions` — the touch the parity row invites — turns a picker tap
into a process trap rather than a degraded order. That is precisely R1-16's own stated worry ("a
later batch adopts the reachable spelling innocently"), left open on the platform the same letter
pointed at it.

*Fix:* one line on the phone — `setSort` refuses (or clamps) a sort `observeLibrary` cannot serve —
or make the core guard a documented `throws`/clamp for the observation path. *Red on old:* a mobile
pin — `model.setSort(.title)` then `#expect(model.sort != .title)`; fails on this tree.

**R2-6 · MINOR · batch 2 (R1-8 + the calendar ruling) · `LibraryDayFilter.swift:177-187` — the day
door's own `DatePicker` still renders in the SYSTEM calendar, which is the one screen the "one
calendar per letter" ruling set out to make single-calendar.**

*Mechanism, traced:* R1-8 named the filter's calendar (`LibraryDayFace.calendar` →
`JournalDay.storeCalendar`, Gregorian in her zone) and `4159a5b6` moved the row STAMPS onto the same
one, with the stated reason *"a non-Gregorian user would have read two calendars on one screen"*.
The `DatePicker` at `:177` carries no `.environment(\.calendar, calendar)` (nor `\.timeZone`), so it
formats through SwiftUI's `EnvironmentValues.calendar` — Apple documents that key as *"The current
calendar that views should use when handling dates"* and lists it in the same topic group as
`DatePicker` and `datePickerStyle(_:)`; unoverridden it tracks the user's Language & Region calendar.
*(Apple's reference does not spell out "DatePicker consults this" in those words — flagging the
citation's edge honestly — but the environment key exists for exactly this and the override
`.environment(\.calendar, …)` is the documented way to force a non-default one.)* Consequence under
a Hebrew or Japanese system calendar: the field shows that calendar's digits while the label beside
it (`LibraryDayFace.openLabel`, Gregorian) and every row stamp read Gregorian. The FILTER still works
— the binding converts through the named calendar (`:157`, `:165`) — so this is a display
disagreement, not a wrong answer, on the one control that draws a calendar.

*Fix:* one modifier — `.environment(\.calendar, calendar)` on the `DatePicker` (and `\.timeZone` for
symmetry). *No crisp red-on-old pin* (a test cannot set `Calendar.current`, and the modifier is not
observable from outside the view) — the batch's own idiom applies: demonstrate the trap on the road
not taken, as `theFiltersCalendarIsGregorianAndKeepsHerTimeZone` already does, and let the walk carry
the rest.

**R2-7 · NIT · batch 2 (R1-12's fix) · `VoiceControls.swift:134-141`, used at
`LibraryCatalogView.swift:408` — `help(ifPresent:)` trades an empty tooltip string for a
`_ConditionalContent` identity flip on the scope Picker.** The `@ViewBuilder` `if/else` returns two
different structural branches, so arming or clearing a day changes the Picker's view identity and
SwiftUI tears the segmented control down and rebuilds it rather than updating it. Nothing of ours
holds state inside it, so the cost is a rebuild and a lost transition, not a bug — but the shape is
the conditional-modifier hazard, and the F-0 complaint (a `cond ? "" : "…"` string-as-rule in a body)
is equally answered by giving the picker a MEANINGFUL tooltip in both states ("Scope the listing to
books, notes or blocks" / the day's line), which keeps one identity.

**R2-8 · NIT · batch 2 (R1-8's fix) · `DayBounds.swift:49` — the type still defaults to
`Calendar = .current`,** which is the exact default R1-8 named as the trap ("every site took
`Calendar.current` whole"). Both production constructions pass `LibraryDayFace.calendar` explicitly
(`LibraryCatalogModel.swift:308`) and every pin names its calendar, so nothing is wrong today; but a
type whose doc now explains why `Calendar.current` is unsafe for day keys should not hand it out as
the default. Either drop the default (make it required, as `TimeStampFace`'s callers already do by
convention) or default it to `JournalDay.storeCalendar` beside the rest.

**R2-9 · NIT · batch 1 (R1-14's fix) · `MastheadStamp.swift:71` +
`PostDetailView.swift:894-916` — the four keyed oracles are written on `.onAppear` and cleared only
by a pin.** `flipStamp[postID] = { flip() }` retains a closure per note ever mounted, and
`stampShown`/`stampEditedAt`/`stampFrames` grow the same way; `resetStamp(_:)` exists but is called
only from the test helper. DEBUG-only, so no shipped consequence — but the keying fix's own reason
(a stale report satisfying a pin) survives in the other direction: a `stampShown[postID]` left by an
earlier mount answers a later pin that forgot to reset. A `.onDisappear { PostDetailOracle
.resetStamp(postID) }` beside the `.onAppear` closes it in one line.

**R2-10 · NIT · batch 1 · `LibraryCatalogModel.swift:289-296` — the fallback doc claims more than
the code does.** *"A remembered value the app does not recognise … reads as the shipped default
rather than leaving the list in a shape no menu row matches."* A stored `"last_major_revision"` IS
recognised by `LibrarySort(rawValue:)` and is NOT offered by `LibrarySortFace.offered`, so it reads
back, the door label says *"revised · newest first"* and no menu row carries the ✓ — exactly the
shape the sentence promises cannot happen. Only a hand-edited plist reaches it. Either validate
against `LibrarySortFace.offered` on read, or narrow the sentence to what it means.

**R2-11 · NIT · batch 1 (R1-5's record) · the fix's own doc,
`TimeStampFace.swift:209-245`, and the batch-1 fix note's *"the gap is the lock and the hash"* —
falsifiable, and the fix is better than the record says.** Measured on this machine (`swiftc -O`,
200k iterations of the landed shapes): building a formatter per call **71.8 µs**; the cached path
end-to-end **0.54 µs** (the lock + hash is **0.15 µs** of it, and `JournalDay.storeCalendar`'s
per-call construction — which the calendar ruling added under it — is **0.08 µs**). So the lock and
the hash cannot account for a 110× → 19× narrowing; whatever the re-measure's harness was paying, it
was not that. Nothing to change in the code; the doc's causal sentence should not stand as the
record's explanation.

**R2-12 · NIT · F-0 residue after R1-6 · `LibraryCatalogView.swift:869` and `:950`,
`LibraryCatalogModel.swift` (529 lines) — the extraction is real and verified, and it left two
database readers behind.** I checked the move byte-for-byte (every line removed from the view
reappears in the model; the only additions are the header and six imports — so "no test changed" is
a true parity proof) and the view is down from 1,509 to **1,101** lines. What did not go with the
model: `enum NoteCards` and `enum TagChips`, ~110 lines of `Database` reading inside a view file,
which is the same concern-mixing the extraction was for; and the model itself now mixes listing
state, the selection algebra, the info panel's subject, the bounded reads and four tag-editing
operations. Named rather than filed: the next Library touch moves the two readers beside the model
(or into `Queries`), and the tag acts are the model's own next split.

#### Considered and cleared (traced, and measured or run where it mattered)

- **R1-1's turnaround is correct AND cheap, and I checked both halves myself.** The uncorrelated
  `id IN (SELECT cb.container_id …)` is the same SET as the correlated `EXISTS` (the correlation
  became the subquery's projection; `cb.deleted_at IS NULL` still fences I2's live ownership), which
  is why the five correctness pins rode unmodified — that is the real proof, not the prose. The plan
  pin now asserts the DRIVER (`idx_commit_created`) and the ABSENCE of `CORRELATED`, which is the
  shape claim the old pin could not make, and the step pin's re-fixture (the searched day matches
  NOTHING, blocks-per-note swept 1 → 15) is exactly the arm the old fixture short-circuited past. I
  re-ran both green. The populated-day path is covered too: the plan pin's own fixture has a
  savepoint ON the searched day, so the `LIST SUBQUERY` shape is what is pinned, not the empty case.
- **v1_17 is a schema commit of its own, ahead of the query that uses it** (`33407d64` touches only
  `Migrations.swift` + `MigrationTests.swift`; `f714ca73` is the next commit) — CLAUDE.md's rule
  followed to the letter, and `theDaySearchIndexArrivesForAnOlderStore` proves a v1_16 store gains
  exactly one index. Not a §12 lockstep event (the mirrors carry no indexes beyond the PK by design,
  SyncSpec §2), and the marker is still 8 — I read `SyncSchema.swift:101` rather than trusting it.
- **`Sync/`, `Server/` and the editor seam are diff-empty across the WHOLE letter**, not just the
  fixes. Zero writes, zero new `setting` key, nothing stored, nothing copied, nothing forensic.
- **R1-3's two halves are honest and pinned.** `dayForEmptyAnswer` gates the day's sentence on the
  scope, the wording names a typed query and trims it, and `setEditedOn` moves a books/blocks scope
  to notes so the gated case is unreachable rather than merely guarded. #104 carries the amendment
  and says the arm reversed its own recommendation, which is the right way to record a reversal.
- **R1-9's rewrite genuinely bites.** `openOnToday()` is the Button's own closure and the pin calls
  nothing else; change the door to open on yesterday and it fails. The old binding-driven version
  could not.
- **R1-5's cache is safe as built.** The key carries template · locale identifier · calendar
  identifier · time-zone identifier; the dictionary is behind an `NSLock` and the formatter formats
  outside it — Apple documents `DateFormatter` as thread-safe for non-mutating use on macOS 10.9+ in
  64-bit modern behaviour (*"In macOS 10.9 and later NSDateFormatter is thread safe so long as you
  are using the modern behavior in a 64-bit app"*), which this is. The cache's own new failure mode
  (a key that forgets part of the shape) is pinned across four shapes including 23:30 UTC being
  tomorrow in Tokyo.
- **R1-14's keying is complete.** All four oracles (`stampShown`, `stampEditedAt`, `flipStamp`,
  `stampFrames`) are per-note, the probe slot carries the id, and the three mounted pins name their
  note; the one-window readers are labelled as such.
- **R1-16's precondition does not over-fire** — I ran `theStampListingStillServesEveryStampSort`; and
  the pin's own discovery (that `TimelineItem.stamp` is a DAY key under `.entryDate`, true since
  Phase 8) is recorded rather than papered over.
- **R1-10's landing is the right size.** The doc now says the created-at link orders by the INSTANT,
  names the corner with its example, records `date(created_at,'localtime')` as the available fix with
  the measurement that says it works and the two reasons it was not taken, and records that `substr`
  is NOT a fix. A doc correction with its own falsification attached.
- **R1-13 is properly retired** — `showsSortDoor` is gone, not aliased, and the three assertions in
  `LibrarySortMenuTests` were renamed in the same commit.
- **The record's own honesty.** R-4's falsified measurement is kept verbatim under a warning with the
  corrected table beside it, the garbage commit message is recorded and not amended, and the R1-3
  fix's write-then-revert-then-pin sequence is announced. That is the standard this ladder is for.
- **My own reproduction of the closing runs:** core 1545/167 and six Mac suites 46/6, both green on
  this tree.

#### Review foci (§12), addressed

- **F-0 — no god brain, no god file.** *Materially improved and verified:* R1-6's extraction is a
  byte-for-byte move (I diffed it line by line), the view is 1,509 → 1,101 lines, and every new rule
  of this letter has a small home with a unit pin (`TimeStampFace`, `DayBounds`, `JournalDay
  .storeCalendar`, `LibrarySortFace`, `LibraryDayFace`, `LibrarySortWords`, `LibraryCopy`). R1-7
  retired a real cross-platform duplication; R1-15 and R1-12 pulled a number and a string out of
  view bodies. *Not clean:* the two database readers left in the view file and the 529-line model's
  mixed concerns (**R2-12**), the shared word table overreaching into copy only one platform says
  (**R2-4**), and R1-12's cure carrying a small identity hazard (**R2-7**).
- **F-5 — 18h's own foci**, item by item after the fixes: *the sort is a PARAMETER of the one catalog
  query* — **clean** (`catalogPostsSQL`, one builder). *The title order is a `LibrarySort` case* —
  **clean**, and R1-16 fenced the one listing that could not carry it (with **R2-5** as the fence's
  own loose end). *No stored stamp anywhere new* — **clean**. *ONE pure wording brain used by every
  row and the masthead* — **clean**, and the calendar ruling closed the two-calendars-on-one-screen
  hole it opened, except on the control that draws a calendar (**R2-6**). *The masthead stamp is a
  third subview of the existing width-aware layout* — **clean**, parity re-proved by my own run of
  the untouched `MastheadLayoutTests` / `MastheadTagDoorTests`. *The day search is one query arm with
  its plan pinned, its index its own commit* — **now clean, and this is the fix the ladder existed
  for**: the arm is uncorrelated, the plan pin asserts the driver, the step pin runs the arm it
  measures, and v1_17 landed alone ahead of the query. The cap lift that rode with it is where
  **R2-2** and **R2-3** land.

#### CLEAN BILL — checked and found solid

1. **The day search's cost shape after R1-1** — the plan (driver `idx_commit_created`, no
   `CORRELATED`, no `SCAN commit_point`), the step pin over the arm that now actually runs, and the
   set-identity argument confirmed by the five correctness pins riding unmodified.
2. **v1_17's discipline** — its own commit, ahead of its query, exactly one index added to an older
   store, no lockstep event, marker 8 read from the source.
3. **The extraction's parity** — verified line-for-line, not taken on the record's word: zero body
   changes, zero test edits.
4. **The union's answer, unchanged by the turnaround** — the Monday/Tuesday pair, the savepoint
   rescue, the cross-note correlation, the live-placement fence, the half-open boundary, and
   archived/deleted exclusion all still pinned through the real operations on a travelling clock.
5. **`DayBounds` and `JournalDay.storeCalendar`** — the noon anchor, the half-open window, 23-/25-hour
   days, São Paulo's missing midnight, the 365-day round trip, and the Hebrew trap demonstrated on
   the road no longer taken. The removal of `init(containing:)` is the right call and its proof pin
   was re-pointed rather than deleted.
6. **The cap's `+1` probe** — exact at 40 and 41, and the day's answer whole at 45; `LibraryCopy`
   holds all three listing sentences so no wording lives in a body.
7. **The formatter cache** — key, lock, documented thread-safety, and a pin for the failure only a
   cache can have. Measured 71.8 µs → 0.54 µs per call here.
8. **Sync-shape and canon** — no writes, no `Sync/`, no `Server/`, no `setting` seed, no editor seam,
   no denormalization, nothing forensic; marker 8; QUESTIONS #103 (with R-Q17's ruling and R1-17's
   clause) and #104 (with R1-3(b)'s amendment) both filed as recorded.
9. **The recorded closing runs reproduce** — core `1545 tests in 167 suites`, Mac `46 tests in 6
   suites`, both run by me on this tree.

**One obligation, not a finding:** the arbitration promises a `notes/KnownIssuesAndTechDebt.md` row
for the **`ANALYZE` absence** (a statistics-dependent plan on a per-keystroke query, owner 12) "at
the round's close" — it is not in the file yet, and the round is not closed. Named here so the close
does not lose it.

#### Orchestrator's ARBITRATION (round 2) — against the spec (2026-09-13)

*(A deliberate shortening, recorded with its reason: she asked that 18h finish in THIS session and the rest of the round move to a new one, and these twelve findings are mechanical — so each implementer's agree/dispute is FOLDED into its fix pass: it disputes in its record where it disagrees, else it fixes. The ladder's letter otherwise stands: round 3 with a FRESH reviewer follows, focused on these fixes.)*

- **R2-1 MAJOR — CONFIRMED (a regression by R1-11's fix):** clearing the day on a mode change without re-running `search()` leaves the day's answer on screen with no filter shown. Fix: the day is cleared through the one door that re-searches (`setEditedOn(nil)` + `search()`, or the mode change re-searches when it changed the model's inputs); a model pin — arm a day, leave the catalog, return → the whole library listed. **Owner: batch 2.**
- **R2-2 MINOR — CONFIRMED:** `truncated` is read by the notes-only body but computed for the whole listing; the flag is computed for the KIND the body draws. Pin: books over the cap, notes under it → no line in Notes mode. **Owner: batch 2.**
- **R2-3 MINOR — CONFIRMED as DOCS, not code:** with a day armed the answer is bounded by the DAY's notes — cost ∝ the query's answer, which is what P1 asks for — so the tag-chip / note-card reads and the title map are bounded by the same set; the two docs that still claim "rows on screen" / "bounded by `limitPerKind`" are corrected to say so. **Owner: batch 2.**
- **R2-4 MINOR — CONFIRMED:** the hoist changed an unruled phone-only string (`last meaningful edit` → `revised`); her R-Q8 names four words and that case is not one of them — the phone's word for that case is RESTORED (the table carries her four; the phone keeps its own for the rest). **Owner: batch 1.**
- **R2-5 MINOR — CONFIRMED:** one guard on the phone's `setSort` refusing `.title` (a word without an offer), pinned. **Owner: batch 1.**
- **R2-6 MINOR — CONFIRMED:** the `DatePicker` takes `\.calendar` = `LibraryDayFace.calendar` — the one screen the calendar ruling was for. **Owner: batch 2.**
- **R2-7…R2-12 NIT — CONFIRMED, by owner as the record marks them:** the conditional-`help` identity flip (a stable modifier, the string conditional); `DayBounds`' surviving `.current` default → `JournalDay.storeCalendar`; the DEBUG oracles reset between pins; the fallback doc trimmed to what the code does; the R1-5 record's attribution corrected to the measured split (71.8 µs → 0.54 µs; lock + hash 0.15 µs); the F-0 residue (`NoteCards` / `TagChips` still in the view file; the model's next split) RECORDED for 13u2, not done here.

**The order:** batch 2's implementer (R2-1, R2-2, R2-3, R2-6 + its NITs), then batch 1's (R2-4, R2-5 + its NITs); core + the Library/masthead suites + the tutorial spine + the iOS build at each end; then **round 3** — a fresh `opus-reviewer`, the cap, focused on these fixes; anything still open after it is recorded for her, never looped on. The `ANALYZE` KnownIssues row (owner 12) is owed at the round's close, as the reviewer notes.

---

#### Batch 2's fixes (round 2)

*(The arbitration's order, one commit per finding, each pushed as it landed. My agree/dispute is
folded in as instructed: **nothing is disputed** — R2-1 is a regression of my own R1-11 fix and the
reviewer's trace is exact. `Sync/` untouched; `Shared/` untouched. Zero `/Applications` instances
before, during and after — she is awake, so the check ran before each timing run. Last code hash:
`f1f60061`.)*

| # | finding | commit | pin | red on old |
|---|---|---|---|---|
| 1 | **R2-1** MAJOR — the mode round trip | `be4a70ff` | `LibraryDayFilterTests.returningToTheCatalogListsTheWholeLibraryAgain` | `hits` unchanged across the round trip — the note the day excluded stayed excluded while the header read `on day…` |
| 2 | **R2-2** the truncation line's subject | `9e04513b` | `…theNotesBodysTruncationIsAboutNotes` | no `listingIsTruncated` / `notesAreTruncated`; ONE flag, true for both bodies (41 books + 3 notes said "showing the first 40" over a complete list of notes) |
| 3 | **R2-3** the two docs | `ec148df7` | — (docs; the arbitration's own call) | the two sentences quoted in the finding |
| 4 | **R2-6 · R2-8 · R2-7** | `cf7f95d6` | — (a display environment a test cannot set · a default both callers override · a view-identity shape) | — |
| 5 | **R2-10** the fallback comment | `f1f60061` | — (a comment) | the sentence quoted in the finding |

**What each changed, beyond the table:**

- **R2-1.** `modeChanged()` is now `async` and re-reads when it cleared the day; the view spawns it
  the way it spawns every other listing change. The model's convention (write here, the caller spawns
  the read) bends exactly once, and the doc says why: the caller is an `onChange` that cannot know
  whether anything was cleared. **This was my own regression** — R1-11 changed state on a road that
  had no re-read on it, and the reviewer is right that the shipped alternative
  (`.disabled(showsCatalogControls && …)`) would have closed the original complaint without touching
  state. The fix keeps the clear, because a filter whose door is off screen is the worse of the two.
- **R2-2.** `capped` already counted per kind and then threw the detail away. It now returns
  `Set<Kind>`; the List body reads `listingIsTruncated` (it draws every kind), the Notes body reads
  `notesAreTruncated`. R1-4's two pins moved to the name that means what they assert.
- **R2-3.** Both sentences now name what actually bounds the derived reads — the answer the query
  returned, which is the cap when a caller passes one and the DAY's notes when it does not — and the
  accepted ceiling is written down rather than implied: *a day on which she edited a thousand notes
  would load a thousand cards per keystroke, and the fix then is to bound the derived reads to the
  DRAWN window.* Cost ∝ the answer is what P1 asks for; cost ∝ the corpus is what it forbids, and the
  day's predicate is what keeps it on the right side.
- **R2-6.** The `DatePicker` takes `\.calendar` and `\.timeZone` from the filter's own calendar. The
  binding always converted correctly, so no answer was ever wrong — it was the one control that
  DRAWS a calendar showing a different one from the label beside it.
- **R2-7.** Closed the other way, as the reviewer suggested: a meaningful tooltip in both states
  (one view identity, no `_ConditionalContent` teardown of the segmented picker), with both sentences
  named in `LibraryCopy` so the body chooses between names and not literals. `help(ifPresent:)` had
  no callers left and is **removed** — R1-8's own lesson about a door nothing walks through.
- **R2-8.** `DayBounds.init?(day:calendar:)` defaults to `JournalDay.storeCalendar`.
- **R2-10.** The sort's fallback comment is narrowed to what the code does, and the one line that
  would make the old sentence true (validating against `LibrarySortFace.offered` on read) is named
  for whoever meets it. It sits in the file batch 2 extracted, which is why it is here and not with
  batch 1's.

**NOT done, with the reason (not a dispute):** **R2-9** — the DEBUG oracles' `.onDisappear` reset.
The findings mark it batch 1's (R1-14's fix), and it lives in `MastheadStamp.swift` +
`PostDetailView.swift`, which are batch 1's files and which batch 1's implementer runs into next; two
hands in one file across two sessions is the collision this order exists to avoid. **R2-12** is
RECORDED for 13u2 by the arbitration, not done here: `NoteCards` and `TagChips` (~110 lines of
database reading) are still in the view file, and the model's own next split is the tag acts.

**THE CLOSING RUNS (round 2's fixes, at `f1f60061`):**

- **Core (`swift test`, repo root):** `✔ Test run with 1545 tests in 167 suites passed after 56.472 seconds.`
  (unchanged in count — round 2 added no core pin; `DayBounds`' default and the two docs are covered
  by the pins already there.)
- **Mac (ONE `xcodebuild test` from `App/Variorum/`, TYPE names, zero `skipped:` lines — the same 37
  suites):** `✔ Test run with 217 tests in 37 suites passed after 110.035 seconds.`
  (+2 over round 1's 215: R2-1's and R2-2's pins.)
- **iOS (`xcodebuild build -scheme VariorumMobile -destination 'generic/platform=iOS'`):**
  `** BUILD SUCCEEDED **`.

**The marker stays 8**; no schema, no migration, no `setting` key, no mirror DDL in this pass.

#### Batch 1's fixes (round 2)

*(Four items, one commit each, path-scoped and pushed as they landed. **Nothing disputed** — one
finding (R2-4) is fixed in substance with its fix's SHAPE argued in the commit and below, which is
the agree/dispute the shortened arbitration folded into this pass. `Sync/` untouched; `Sources/`
moved in COMMENTS ONLY (R2-11's numbers — `git diff` over the core file shows no non-doc line), so
the core run below is a courtesy rather than an obligation. Her app was absent from `/Applications`
at every timed run. The last code hash is `634a57c4`.)*

| # | finding | commit | pin | red on old |
|---|---|---|---|---|
| 1 | **R2-4** the unruled word restored | `f96c7181` | `MobileLibrarySortTests.theSortVocabularyIsPinned` | the phone answered *"revised"* where *"last meaningful edit"* has shipped since the parity round; and `ruledLabel(.lastMajorRevision)` did not exist to say the table gives no word where no ruling gave one |
| 2 | **R2-5** the phone's door refuses `.title` | `aee25810` | the same pin, driving `setSort(.title)` on a real model | **`model.sort → .title` where `.entryDate` is owed** — measured with the guard REVERTED (announced; restored with `git checkout --` from the committed tree, never a copy) |
| 3 | **R2-9** the four oracles reset on disappear | `0f80ec7f` | the mount harness, so all three mounted stamp pins assert it | with the `.onDisappear` reverted: `flipStamp` retained, `stampShown → "edited Jun 30"`, `stampEditedAt → 2026-07-01 00:00:01`, `stampFrames → (787.5, 40.0, 102.5, 18.0)` — all four still there after the window went |
| 4 | **R2-11** the record's attribution | `634a57c4` | — (a record + a doc) | the sentence that stood was falsifiable; it is marked corrected in place |

**What each fix actually changed, beyond the table:**

- **R2-4.** `LibrarySortWords.ruledLabel` answers HER FOUR and nil for anything else; `label`
  falls back to `unruledLabel` — *"last meaningful edit"*, AppSpec §10's own vocabulary, the
  phone's shipped string. **The one place I read the ruling's substance rather than its letter,
  argued rather than done quietly:** the arbitration says *"the phone keeps its own for the rest"*,
  and I kept the WORD rather than the LOCATION. The Mac can still be asked for that case — a
  hand-edited `libraryCatalogSort` of `last_major_revision` parses and reaches the door's label,
  which is R2-10's own scenario — so both platforms need an answer, and two files each holding the
  same string is the drift R1-7 retired three commits earlier. What the finding forbids is
  CHANGING the word; `ruledLabel` is what makes "her four, and only hers" a claim a pin holds. **If
  the orchestrator wants the literal split it is one line**, and round 3 can take it. Batch 2's
  R2-10 comment named the door's wrong-shape example by the string this restores, so it moved with
  it.
- **R2-5.** One guard, at the door, with the reason written where the next reader stands: this
  model's listing is `observeLibrary` → `Queries.library`, which refuses `.title` by a precondition
  that is **live in release**, and the same letter gave `.title` a word so a picker could say it.
  The state it leaves is named rather than hidden: the phone can NAME `.title` and cannot BE it
  until its listing can serve it — `searchCatalog`'s road, not `library`'s, and a mobile decision.
- **R2-9.** `resetStamp(_:)` now clears the FOURTH oracle beside its own three
  (`MastheadGeometry.stampFrames`), so one call is the whole cleanup rather than three-quarters of
  it, and `.onDisappear` calls it. The pin rides in the mount harness so all three mounted pins
  assert the teardown rather than one of them.
- **R2-11.** The cause is **withdrawn, not replaced**: round 2's split (71.8 µs built · 0.54 µs
  cached · 0.15 µs lock+hash · 0.08 µs `storeCalendar`) cannot explain a 110× → 19× narrowing, and
  inventing a second explanation would repeat the first mistake — what my harness paid beyond them
  is unattributed and now says so. The fix is better than the record claimed (~132× on the
  reviewer's numbers); what left the main thread per keystroke is the same ~5.7 ms either way. The
  function's own doc now carries the measured numbers.

**THE CLOSING RUNS (at `634a57c4`):**

- **Core (`swift test`, repo root — comment-only movement, run anyway):**
  `✔ Test run with 1545 tests in 167 suites passed after 57.694 seconds.` (unchanged from round 1's
  close, as a doc-only core change should be.)
- **Mac (ONE `xcodebuild test` from `App/Variorum/`, TYPE names, zero `skipped:` lines — the same
  34 suites as round 1's close):** `✔ Test run with 206 tests in 34 suites passed after 109.852 seconds.`
  (+2 over round 1's 204: R2-9's four assertions ride inside three existing tests, and the two new
  tests are batch 2's day-filter pins landing in `LibraryDayFilterTests` between the runs.)
- **iOS:** `** BUILD SUCCEEDED **`, and the two phone-visible fixes RUN rather than compiled —
  `✔ Test run with 2 tests in 1 suite passed after 0.063 seconds`
  (`VariorumMobileTests/MobileLibrarySortTests` on the `Variorum-batch6a` simulator).

**What I did NOT do:** no walk (nothing user-visible moved on the Mac: a shared word table, a phone
guard, DEBUG-only oracle cleanup, and two records — the phone's picker string is the only visible
change and it is pinned on the simulator); nothing in `Sync/`, no schema, no migration, no
`setting` key — **marker 8**; **R2-10 and R2-12 are not mine** (R2-10 landed with batch 2 at
`f1f60061`; R2-12's F-0 residue is RECORDED for 13u2 by the arbitration, not done here).

---

### 18h LADDER — ROUND 3 FINDINGS (opus-reviewer)

*(A FRESH cold reviewer, zero implementation context. **Round 3 is the hard cap** — a full pass
FOCUSED on round 2's fixes `4159a5b6..634a57c4` (batch 2's `be4a70ff` · `9e04513b` · `ec148df7` ·
`cf7f95d6` · `f1f60061`; batch 1's `f96c7181` · `aee25810` · `0f80ec7f` · `634a57c4`), read against
the whole ladder `e526f557..634a57c4` and the whole letter `2d43df7c^..634a57c4` for what they
touched. Anchor: the recorded round-1 findings, both implementers' responses, both arbitrations,
both fix passes, read in full before the code. Tree `780caa56` == `origin/main`, notes-only after
`634a57c4`; zero `/Applications` instances before, during and after.)*

*Scope check first, per the reviewer's own contract: over the WHOLE letter the diff touches **no**
editor seam (`EditorTextView` / `PaneTextAuthority` / `PaneMeasurement` / `BlockRangeIndex`
diff-empty), **no** custody or keychain code, and **nothing** in `Sources/VariorumCore/Sync/` or
`Server/` — I ran `git diff --stat 2d43df7c^..634a57c4 -- Sources/VariorumCore/Sync Server` and it
is empty. `lockstepVersion` is **8**, read from `SyncSchema.swift:101`. The one DEFAULT that moved
is a display calendar (`NoteBoxCopy.day`/`stampsLine` from `.current` to
`JournalDay.storeCalendar`), byte-identical for a Gregorian user and the ladder's own ruled fix —
not a product default's meaning. Opus is the right seat; no Fable re-spawn is owed.*

**Counts: 0 BLOCKER · 0 MAJOR · 3 MINOR · 7 NIT.** Nothing here blocks the letter's close.

Verification runs I made myself (not the record's): core `swift test --filter
'LibraryDaySearchTests|DayBoundsTests|TimeStampFaceTests|LibraryTimeSortTests|NoteStampsTests|MigrationTests'`
→ **`65 tests in 7 suites passed`**; Mac `-only-testing:` `LibraryDayFilterTests` ·
`LibrarySortMenuTests` · `MastheadStampTests` · `MastheadLayoutTests` · `LibraryRowAlignmentTests` ·
`MastheadTagDoorTests` → **`48 tests in 6 suites passed`** (`DerivedData/review18h-r3`; round 2's
reviewer saw 46/6 before its two new pins landed); iOS `xcodebuild build -scheme VariorumMobile
-destination 'generic/platform=iOS'` → **`** BUILD SUCCEEDED **`**. And one independent measurement
of the letter's central claim: I rebuilt the four real tables and their five real indexes in a
scratch `sqlite3` file and ran `EXPLAIN QUERY PLAN` over the SHIPPED statement —

```
|--SEARCH container USING INDEX idx_container_kind (kind=?)
|--LIST SUBQUERY 1
|  |--SEARCH cp USING INDEX idx_commit_created (created_at>? AND created_at<?)
|  |--SEARCH v USING INDEX sqlite_autoindex_variant_1 (id=?)
|  |--SEARCH cb USING INDEX uq_cblock_ownership (block_id=?)
|  `--CREATE BLOOM FILTER
`--USE TEMP B-TREE FOR ORDER BY
```

— the day's own savepoints drive it, each joins to its take by PK and to its placement through the
live-ownership partial index, and nothing walks a note's blocks. R1-1's turnaround is right, and it
is right for the reason the record gives.

#### Findings, severity-ranked

**R3-1 · MINOR · batch 2 (R2-1's fix) · `LibraryCatalogModel.swift:253` +
`LibraryCatalogView.swift:219` — making `modeChanged()` async also deferred `clearSelection()`, so
the destructive bulk bar and the info panel can draw for a frame in a mode that shows no
selection.**

*Mechanism, traced:* the mode change's whole handler is now
`.onChange(of: model.mode) { _, _ in Task { await model.modeChanged() } }`, and `clearSelection()`
is the first statement INSIDE that async function. A `Task {}` body cannot run before the current
synchronous update completes, so the pick survives the update in which the mode changed. The bulk
bar is not mode-gated — it is `if selectedPosts.count > 1` inside the header's control row
(`LibraryCatalogView.swift:444`), which every mode draws — and it carries
`Button("Delete \(selectedPosts.count) notes…", role: .destructive)` at `:474-477`; the info panel
(`:186-203`, on `model.infoHit`) is in the same window. So with two or more notes picked in List
mode, switching to Notes or Timeline renders at least one frame of exactly what the function's own
doc forbids: *"a bar offering to delete notes she cannot see highlighted is the invisible-selection
hazard the walk's own standard forbids"* (`clearSelection`'s doc, `:229-232`), and P-0's rule the
`.onChange`'s own comment restates at `:215-218`. Before `be4a70ff` the clear was synchronous and
the window did not exist.

The fix note in the record says the model's convention (*"write here, the caller spawns the read"*)
*"bends exactly once, here"* — this is what the bend costs, and it is avoidable without the bend.

*Fix:* keep the clear synchronous and let the caller spawn the read, as every other listing change
in this file already does — `func modeChanged() -> Bool` (clear; return whether the day was
cleared), and `.onChange { if model.modeChanged() { Task { await model.search() } } }`. One line
either side, the R2-1 pin survives as `model.mode = .timeline; _ = model.modeChanged(); await
model.search()`. *Red on old:* the honest shape here is a compile pin, the same shape this letter's
product rows used — a pin that calls `modeChanged()` WITHOUT `await` and asserts
`model.selectedPosts.isEmpty` on the next line does not compile on this tree.

**R3-2 · MINOR · batch 1 · `LibraryCatalogView.swift:1069-1071` (the List row's raw date slot)
beside `:1080-1083` (the new stamp) — the Library's two modes now word the same fact in two
grammars, and under the `date` sort the List row prints one day twice.**

*Mechanism, traced:* `CatalogNoteLine` still renders `Text(date)` with `date = hit.detail`, which
for a post is the RAW stored `entry_date` (`ShelfQueries.swift:474`, `detail: $0["entry_date"]`) —
no `TimeStampFace`, no `tokens.chromeLabel`. The batch changed the Notes CARD's one slot to the
brain's words (`:1047`, `CatalogRowStamp`) and ADDED the stamp to the List row without touching its
raw slot. Two consequences, both on screen:

1. **Under `sort == .date`** `LibrarySortFace.rowStamp` returns `subject: .dated, stamp: hit.detail`
   (`LibraryTimeFace.swift:130`) — the SAME column the raw slot printed — so a note with a stated
   day renders `Title  2026-09-08  …  dated Sep 8`: one fact, twice, in two formats.
2. **Under every sort** the List row shows a raw ISO day beside worded stamps while the Notes card
   shows only words — so the same note reads `2026-09-08` in one mode and `dated Sep 8` in the
   other. `LibraryTimeFace.swift:22-24` states the opposite as the reason `CatalogRowStamp` exists:
   *"the ONE muted trailing stamp BOTH row renderers wear, so the List row and the Notes card can
   never say a note's time differently."* That claim holds for the STAMP and is falsified for the
   ROW. Review focus F-5's *"the relative-time wording is ONE pure brain used by every row"* is
   unmet on the one surface that kept a second date grammar.

QUESTIONS #103 does not cover it: it asks *which fact* the CARD's slot shows (and R1-17 added
*where* on the card) — the List row's raw slot is named nowhere.

*Fix:* word the List row's `date:` slot through `TimeStampFace.day` (a formatting change inside the
one brain's remit), or drop the raw slot under the `date` sort where the trailing stamp already says
it. Because it changes what she reads on the surface her image 4 pointed at, the honest landing is
one clause on **#103** so it rides R-Q17's build in **17q** rather than being changed silently.
*Red on old:* a face pin over `CatalogNoteLine` asserting the row's two date texts are not the same
day twice under `.entryDate` — fails on this tree.

**R3-3 · MINOR · both batches · the close's recorded-but-unlanded obligations, one of which
currently asserts the opposite of what shipped.**

Four items are drafted or promised and are not in the repo. Three are ordinary close work; the
third is a canon file saying something false today.

1. **The `ANALYZE` KnownIssues row (owner 12)** — round 1's arbitration: *"The `ANALYZE` absence is
   RECORDED (a KnownIssues note at the round's close, owner 12 …)"*; round 2's reviewer named it
   again as *"one obligation, not a finding"*. `grep -in analyze notes/KnownIssuesAndTechDebt.md`
   returns nothing. It matters beyond bookkeeping: `Migrations.swift:544-546` and
   `ShelfQueries.swift:585-589` both now rest their reasoning on the absence of `sqlite_stat1`, so
   whoever adds `ANALYZE` later changes the plan these two comments describe.
2. **R2-12's F-0 residue** — the arbitration says it is *"RECORDED for 13u2"*, but it exists only in
   this plan file's arbitration paragraph. Every other 13u2 item lives in
   `notes/KnownIssuesAndTechDebt.md` (rows 31, 45, 48–55); `grep -n "NoteCards\|TagChips\|
   LibraryCatalogModel"` over that file returns nothing, so the person who runs 13u2 will not find
   it. CLAUDE.md's rule is that deferred work names its owner in that file.
3. **`notes/MobileSoul.md` §6, PL-22 — currently FALSE about 18h.** The row reads *"**NOTHING OWED
   by construction:** 17p (Mac board and chrome), **18h** (Mac Library and masthead faces; the core
   column on `TimelineItem` is additive)"*. This letter changed two PHONE-VISIBLE picker strings
   (*last touched* → *edited*, *entry date* → *date*, `LibrarySortWords.swift` + the phone's
   forwarder) and added a phone-side guard (`MobileLibraryViewModel.setSort` refusing `.title`).
   Round 1's arbitration ordered *"PL-22 notes it"* and batch 1's own record wrote *"**PL-22 owes
   the note** (the phone's picker strings changed)"*. Until it lands, a mobile session reading
   PL-22 is told 18h touched nothing of theirs.
4. **AppSpec §12's Library line** — drafted in both batch records and not applied (`grep -n 18h
   notes/AppSpec.md` is empty). Expected at the letter's close; listed so the close does not lose it
   beside the other three.

*Fix:* land all four at the letter's close; (3) is a correction, not an addition.

**R3-4 · NIT · batch 1 (R2-4's fix) · `App/Variorum/Shared/LibrarySortWords.swift:71-77` — the
judgment the orchestrator asked round 3 for, plus the one thing the shape should still change.**

**The shape is ACCEPTED.** The arbitration's letter was *"the table carries her four; the phone
keeps its own for the rest"*, and the fix kept the WORD (*"last meaningful edit"*, restored
byte-exact and pinned) while keeping the LOCATION shared. I checked the implementer's argument
rather than taking it: `LibraryCatalogModel.init` (`:299-303`) parses ANY `LibrarySort` raw value
out of `libraryCatalogSort`, `LibrarySortFace.doorLabel` (`LibraryTimeFace.swift:74-78`) calls
`label(sort)` on whatever came back, and nothing validates against `LibrarySortFace.offered` (R2-10
was ruled a comment, not a guard) — so the MAC genuinely reaches
`LibrarySortWords.label(.lastMajorRevision)` today. A phone-only home would therefore have minted a
second copy of that string on the Mac side, which is the drift R1-7 retired three commits earlier.
Substance restored, no second copy, pinned both ways (`ruledLabel(.lastMajorRevision) == nil` AND
`M.sortWord(.lastMajorRevision) == "last meaningful edit"`). Nothing to redo.

**What should still change is the FALLBACK's arity.** `label` is `ruledLabel(sort) ?? unruledLabel`,
and `unruledLabel` is a single constant named and documented for exactly one case (*"the word for
the one case no ruling names"*). `ruledLabel`'s switch is exhaustive with no `default`, so a future
`LibrarySort` case does fail the build there — but the cheapest way to satisfy the compiler is
`case .newThing: nil`, and that silently labels the new sort *"last meaningful edit"* on both
platforms. The guard that caught `.title` in this very letter was an exhaustive switch returning a
WORD; the `??` gives that property away one layer up. *Fix:* make the fallback a switch too (or fold
both into one exhaustive `label`), so the next case must be answered rather than inheriting a word
about a different column. *No pin owed* (a compile-time shape).

**R3-5 · NIT · batch 2's calendar ruling, one door short · `Sources/VariorumCore/Domain/
JournalDay.swift:58` — `date(from:calendar: = .current)` still hands out the default R2-8 removed
from its own inverse.**

R2-8 changed `DayBounds.init?(day:calendar:)` to default to `JournalDay.storeCalendar` with the
reason *"a type whose own doc explains why the system calendar is unsafe for a day KEY should not
hand it out as the default"*. `JournalDay.date(from:)` — the function that reads a Gregorian day key
into an instant, and the function the Hebrew-calendar trap in `DayBounds`' own removal comment is
ABOUT — kept `.current`. Concretely: `JournalDay.date(from: "2026-09-12", calendar: .current)` under
a Hebrew `Calendar.current` passes `isValid` (which is proleptic Gregorian) and then builds
year 2026 / month 9 / day 12 as a HEBREW date, returning a silently wrong instant — non-nil, so no
caller can notice. Every production caller passes a calendar explicitly today
(`TimeStampFace.swift:200`, `DayBounds.swift:56`, `LibraryDayFilter.swift:87` and `:164` — I grepped
all of `Sources` and `App`), which is exactly the state R2-8 called "the safe answer for the next
one". *Fix:* the same one line. *No red-on-old pin* (no caller reaches it), same class as R2-8.

**R3-6 · NIT · batch 2 (R2-1's fix) · `LibraryCatalogModel.swift:256` — `modeChanged()` writes
`editedOn = nil` directly, past the door the field's own `private(set)` exists to force.**

`editedOn` is `private(set)` with `setEditedOn` as its one documented door (`:121-129`), and that
door does two things: refuse a non-day, and move a books/blocks scope to notes. The arbitration's
own wording for this fix was *"the day is cleared through the one door that re-searches
(`setEditedOn(nil)` + `search()`…)"*. `nil` happens to take the same path today, so nothing is wrong
now — but the model now has two writers of one field, and QUESTIONS #104's option (c) (restore the
previous scope on clearing) is precisely the behaviour that would live in the door and be skipped
here. *Fix:* `setEditedOn(nil)` in `modeChanged`. *No pin owed* (byte-identical behaviour today).

**R3-7 · NIT · batch 1 · `Sources/VariorumCore/Queries/Timeline.swift:158` + the `.title` doc /
`LibraryTimeSortTests.titleSortsOnTheDisplayedNameCaseInsensitively` — "case-insensitively" is an
ASCII-only claim.**

`COLLATE NOCASE` folds `A–Z` only. Measured (`sqlite3`, five rows, `ORDER BY x COLLATE NOCASE`):
`apple · Apple · Zoe · Émile · émile` — every accent-initial title sorts after every ASCII one, and
`É`/`é` are adjacent only by code-point luck. The pins exercise ASCII alone, so they are true; the
doc's word and the test's name are broader than the SQL. Not worth ICU (SQLite has no built-in
locale collation, and the fix would be a Swift-side sort, which re-opens the "cost ∝ what the query
returned" trade the letter just settled). *Fix:* one clause in the `.title` doc naming the ASCII
fold as the accepted shape — the same landing R1-10 took for the timezone corner two paragraphs up.

**R3-8 · NIT · batches 1 and 2 · `LibraryTimeFace.swift:175`, `LibraryDayFilter.swift:206` and
`:218-220` — three tooltip literals in view bodies, one of which re-spells the shared word table.**

R2-7 moved the scope picker's pair into `LibraryCopy` on F-0's *"no string-as-rule in a view"*.
Three siblings stayed: `LibrarySortMenu`'s `.help("Sort the notes — edited · created · date · title,
newest or oldest first")`, which hard-codes the four words `LibrarySortWords` now owns (rename one
there and this tooltip is stale — the drift R1-7 existed to close, one file over), and
`LibraryDayField`'s `.help("Clear the day — list every note again")` and `"Show only the notes
edited on one day"`, which sit beside a `LibraryDayFace` that names its other two sentences. *Fix:*
the sort tooltip composes from `LibrarySortFace.offered` + `LibrarySortWords.label`; the day's two
join `LibraryDayFace`.

**R3-9 · NIT · batch 2 · `App/Variorum/Variorum/Features/Library/LibraryCopy.swift:47` — `import
SwiftUI` sits mid-file, between the `LibraryCopy` enum and `LibraryTruncationLine`.** Legal Swift
and it compiles; it is also the only file in the letter that does it, and a reader scanning the
header for what a file depends on will miss it. *Fix:* move it up beside `import Foundation`.

**R3-10 · NIT · batch 1 (R2-9's fix) · `MastheadStamp.swift:78` + `PostDetailView.swift:918-923` —
the `.onDisappear` reset is per MOUNT, not per note, and it reaches across into another oracle's
storage.** Two DEBUG-only edges the fix leaves: with the SAME note open in two windows, closing
either one runs `resetStamp(postID)` and clears the oracles the other masthead is still
maintaining (`flipStamp[postID]` stays nil until that view re-appears); and a `.task(id: postID)`
swap on one instance — the view staying, the note changing — runs no `onDisappear`, so the previous
note's three entries and its `stampFrames` row survive exactly as before. Also, `PostDetailOracle
.resetStamp` now mutates `MastheadGeometry.stampFrames`, so one oracle owns another's storage
lifetime. No shipped consequence (all `#if DEBUG`), and no pin is owed; noted because R2-9's own
reason was oracle hygiene and these are the same hygiene. *Fix, if ever:* reset from the `.task(id:)`
transition (which is the per-note boundary) rather than from `onDisappear`, and let
`MastheadGeometry` clear its own row.

#### Considered and cleared (traced, and measured or run where it mattered)

- **R2-1's fix answers the finding it was written for**, and its pin bites: `returningToTheCatalog
  ListsTheWholeLibraryAgain` drives the real round trip on a travelling clock and asserts the
  excluded note is listed again. R3-1 is about the SHAPE the fix chose, not about the regression,
  which is closed.
- **R2-2's per-kind truncation is correct through the whole path.** `search()` calls
  `capped(filtered(all), to:)`, so the scope filter runs BEFORE the count and each kind's `over` is
  about rows that survived scoping; `listBody` reads `listingIsTruncated` (it draws every kind) and
  `notesBody` reads `notesAreTruncated` (it draws `hits.filter { $0.kind == .post }`). I re-derived
  the 41-books/3-notes case by hand and ran the pin.
- **The cap lift is bounded by the answer, not the corpus.** With a day armed `limitPerKind` is nil,
  and both the books and blocks arms are skipped (`ShelfQueries.swift:434` and `:479` guard on
  `editedOn == nil`), so nothing unbounded reads a second kind; the post arm's `LIMIT -1` is SQLite's
  own "no limit". The derived reads (`loadTagChips`, `loadNoteCards`, the eager `DisplayTitle.note`
  map) run over the day's answer, and both docs now say so with the ceiling named. Cost ∝ the
  answer, never ∝ the corpus — R2-3's landing is honest.
- **R2-5's guard is the only door.** `MobileLibraryViewModel.sort` is `private(set)` and
  `MobileLibraryView.swift:209-213` picks only from `sortOptions`, so `setSort` is the sole writer;
  the guard makes `Queries.library`'s release-live precondition unreachable from the phone, and the
  pin drives the real model.
- **R2-6's modifier is on the right view and cannot change an answer.** The `DatePicker`'s binding
  converts both ways through `calendar` (`LibraryDayFilter.swift:163-166`) whatever the environment
  says, so the change is display-only, and `\.timeZone` riding along keeps the drawn day and the
  computed key the same day.
- **R2-7's cure removed the hazard rather than trading it.** One `.help` with a ternary over two
  named constants is one view identity; `help(ifPresent:)` is deleted and `grep` finds no caller.
- **R1-1's turnaround, independently.** The plan above is mine, not the record's; the set-identity
  argument (the correlation became the subquery's projection, `cb.deleted_at IS NULL` still fencing
  I2) is confirmed by the five correctness pins riding unmodified, and
  `theDaySearchsWorkTracksTheDaysSavepointsNotTheCorpusBlocks` runs the arm the old fixture
  short-circuited past.
- **v1_17's discipline, re-read from git:** `33407d64` touches `Migrations.swift` +
  `MigrationTests.swift` and nothing else, and `f714ca73` (the query) is the next commit — the
  schema-first rule to the letter. Not a §12 lockstep event; marker 8 read from the source.
- **The formatter cache is safe as built and R2-11's withdrawal is the right correction.** Key =
  template · locale · calendar identifier · time-zone identifier; the dictionary is behind an
  `NSLock` and the formatter formats outside it (the templates in play carry no week-based fields,
  so nothing else about a `Calendar` can change the output). Withdrawing an unsupported cause rather
  than inventing a second one is the standard this ladder is for.
- **`MastheadRowTwo`'s three-subview arithmetic.** I read it rather than trusting the parity claim: a
  zero-width stamp contributes `tail = 0`, adds no gap to either branch, leaves `baseline` and both
  heights untouched, and `oneLine` is only chosen when `chip + gap + clusterMinimum + tail <= width`,
  so the cluster's proposal can never be squeezed under the stamp. `MastheadLayoutTests` and
  `MastheadTagDoorTests` pass unmodified in my own run.
- **Sync-shape and canon.** Zero writes, zero `Sync/`, zero `Server/`, no schema beyond v1_17's local
  index, no `setting` key, marker 8; no stamp stored anywhere new, nothing copied across entities,
  no per-day edit log (nothing forensic). QUESTIONS #103 (R-Q17's ruling + R1-17's clause) and #104
  (R1-3(b)'s amendment) both read as the records describe.
- **The recorded closing runs reproduce**, plus the iOS build, all three run by me on this tree.

#### Review foci (§12), addressed

- **F-0 — no god brain, no god file.** *Materially better and verified:* R1-6's extraction stands
  (`LibraryCatalogView.swift` 1,509 → 1,101 lines; the model in its own file), every new rule of the
  letter has a small home with a unit pin (`TimeStampFace`, `DayBounds`, `JournalDay.storeCalendar`,
  `LibrarySortFace`, `LibraryDayFace`, `LibrarySortWords`, `LibraryCopy`), R1-7 retired a real
  cross-platform duplication and R2-4 stopped it one case short of overreach, and R2-7/R1-15 pulled
  a string and a number out of view bodies. *Still open, all recorded and none new to this round:*
  the two `Database` readers (`NoteCards`, `TagChips`) left in the view file and the 529-line
  model's mixed concerns (R2-12 — but see **R3-3(2)**: "recorded for 13u2" has no row in the file
  13u2's items live in), three surviving tooltip literals (**R3-8**), and the shared table's
  catch-all fallback (**R3-4**).
- **F-5 — 18h's own foci**, item by item after round 2:
  - *the sort is a PARAMETER of the one catalog query, not a second query* — **clean**
    (`catalogPostsSQL`, one builder, one statement, `booksAndBlocksKeepTheirOwnOrderUnderEverySort`).
  - *the title order is a `LibrarySort` case* — **clean**; R1-16 fenced the listing that cannot carry
    it and R2-5 closed the fence's phone-side loose end. One doc overclaim remains (**R3-7**).
  - *no stored stamp anywhere new (the no-denormalization rule)* — **clean**, re-checked against the
    schema: no column added, `CatalogHit`/`NoteStamps` carry READ values only.
  - *the relative-time wording is ONE pure brain used by every row and the masthead* — **almost**:
    one brain, adopted by the masthead, the Notes card and 18d's facts line (whose second copy it
    retired), **but the List row's own date slot still prints the raw stored day** (**R3-2**).
  - *the masthead stamp is a third subview of the existing width-aware layout, not a second layout* —
    **clean**, arithmetic read and parity re-proved by my own run of the untouched pins.
  - *the day search is one query arm with its plan pinned, its index (if any) its own commit* —
    **clean, and independently measured** (the plan above): uncorrelated, driven by `idx_commit_
    created`, the plan pin asserting the driver and the absence of `CORRELATED`, the step pin running
    the arm it measures, and v1_17 alone in the commit before the query.

#### CLEAN BILL — checked and found solid

1. **The day search's cost shape** — my own `EXPLAIN QUERY PLAN` on the shipped statement over the
   real schema and indexes: `LIST SUBQUERY` driven by `idx_commit_created`, take by PK, placement by
   `uq_cblock_ownership`. P1's shape, not P1's breach.
2. **R2-1's regression is genuinely closed** — the day and the listing now leave together, pinned on
   the real round trip.
3. **R2-2's flag is per kind end to end**, and R1-4's two cap pins moved to the name that means what
   they assert.
4. **R2-4 restored the phone's word byte-exact, and the shared location is the right call** — the
   Mac reaches that label through a parsed remembered value, so the literal split would have minted
   the second copy R1-7 retired (traced, not taken on the record's word).
5. **R2-5 makes `Queries.library`'s release-live precondition unreachable from the phone**, with
   `sort` `private(set)` and the picker offering only `sortOptions`.
6. **R2-6/R2-7/R2-8/R2-10 are each the smaller honest landing**, and R2-7 deleted the door it
   emptied.
7. **R2-9's keying + teardown**, with all four oracles reset by one call and every mounted stamp pin
   asserting it.
8. **R2-11 withdraws a falsified cause instead of replacing it** — and the code it describes is
   unchanged and correct.
9. **v1_17: its own commit, ahead of its query, one index on an older store, no lockstep event,
   marker 8** — read from git and from the source, not from the record.
10. **Sync-shape, canon and the invariants** — no writes, no `Sync/`, no `Server/`, no editor seam,
    no denormalization, nothing forensic, no `setting` seed; I2's live-ownership fence intact inside
    the new subquery.
11. **All three recorded closing runs reproduce on this tree** — core 65/7 (targeted), Mac 48/6,
    iOS `BUILD SUCCEEDED`.

**Open after the cap, for her record rather than another round:** nothing of consequence. The three
MINORs are a one-line shape correction (R3-1), a wording question that belongs on QUESTIONS #103 so
17q builds it with her ruling (R3-2), and four close obligations of which one — MobileSoul §6's
PL-22 — currently states the opposite of what shipped (R3-3). The seven NITs are cleanliness. **The
ladder is capped here; nothing is looped on.**

#### Orchestrator's DISPOSITIONS (round 3 — the cap; nothing loops) (2026-09-13)

- **R3-1 MINOR (batch 2)** — CONFIRMED-RECORDED: the async `modeChanged()` defers `clearSelection()` off the mode-change update, so the bulk bar (a destructive Delete) and the info panel can draw for a frame in a mode that shows no selection. The fix (a synchronous clear returning whether a re-read is owed; the caller spawns the search) is ONE line and is **17q's** (the successor's first entry touches this file for #103) — KnownIssues row, owner 17q.
- **R3-2 MINOR (batch 1)** — CONFIRMED-RECORDED as a clause on QUESTIONS **#103**: the List row prints the raw `entry_date` beside the title while the Notes card speaks the brain's words (under the `date` sort the row shows the same day twice); 17q builds the card with her R-Q17 and words the row's slot through the one brain in the same act.
- **R3-3 (both)** — CONFIRMED and LANDED IN THIS COMMIT: AppSpec §7's `commit_point` DDL gains `idx_commit_created`; §12's Library line gains the stamps, the sort and the day filter; `MobileSoul.md` PL-22 corrected (18h changed two phone-visible picker strings and added a phone-side guard; the parity notes for 17p and 18h folded in); KnownIssues gains the `ANALYZE` row (owner 12) and the 13u2 row for R2-12's F-0 residue.
- **R3-4 (the fallback as a switch) · R3-5 (`JournalDay.date(from:)`'s `.current` default) · R3-6 (`modeChanged` past the `private(set)` door) · R3-7 (the A–Z doc's "case-insensitively" is ASCII-only — `COLLATE NOCASE`) · R3-8 (three tooltip literals) · R3-9 (a mid-file `import`) · R3-10 (the oracle reset per mount)** — NITs, CONFIRMED-RECORDED on the 17q KnownIssues row with R3-1; hers to read, 17q's to sweep if the entry has room.
- **R2-4's shape — the reviewer's judgment ACCEPTED** (the Mac genuinely reaches `label(.lastMajorRevision)`; the literal split would have re-minted the retired copy). **Open defects after the cap: none.**

---

### 18h — LETTER CLOSEOUT (the orchestrator, 2026-09-13; the Opus ladder closed at round 3 (the cap))

**What shipped (two batches + one Opus ladder over both, `2d43df7c..634a57c4`):** the Library sorts by edited · created · date · title with a remembered direction — a PARAMETER of the one catalog query (`Queries.searchCatalog(sort:direction:)`, the shipped order byte-identical by default), the door and its words in `LibraryTimeFace.swift` and the one word table in `Shared/LibrarySortWords.swift` (her R-Q8's four words, the phone reading them); the rows (List and the Notes cards) and the note's masthead wear a muted stamp — the sort's own — worded by ONE pure brain `TimeStampFace` in core `Domain` on the one store calendar (`JournalDay.storeCalendar`, Gregorian in her time zone), the masthead's flipping edited ↔ created on a click on a HELD `noteStamps` observation; 18d's day rule folded into that brain; `LibraryCatalogModel` extracted to its own file (batch 1); the day search — `on day…` in the Library header, ONE query arm: the note's own last-edit stamp in the day's UTC window (`DayBounds`, core `Domain`, both ends pinned across DST) OR a savepoint written that day on a take it holds, the savepoint half an UNCORRELATED `IN` over the new `idx_commit_created` (v1_17 — an index, not a lockstep event; marker 8), the day's answer uncapped and every capped listing saying when it is a page; the empty day's sentence speaks only for the day and names the real cause otherwise; arming a day narrows to notes and moves the scope to posts; leaving the catalog clears the day (batch 2). Her rulings R-Q7 and R-Q8 built to the letter; PROVISIONALs #103 and #104 — both RULED at her 2026-09-13 sitting (#103's build is 17q's).

**Dispositions (the ledger rows 18h owns — every row FIXED with its named pin; nothing DISMISSED AS HOLLOW; nothing DEFERRED):**
- **row 9 FIXED** (`LibraryTimeSortTests.everyNoteHitCarriesItsCreatedAndEditedStamps` · `TimeStampFaceTests` ×8 · `LibraryRowAlignmentTests.aNoteRowsTrailingStampSitsOnTheTitlesBaselineInBothVoices` · `MastheadStampTests` ×4 — a PRODUCT row: red-on-old is the capability's absence, the pins not compiling on `87799c6a`). Walked: `18h-1/02 · 08 · 09–15`.
- **row 10 FIXED** (`LibraryTimeSortTests.theCatalogSortsByEveryStampInBothDirections` · `…theDefaultIsTheShippedEditedNewestFirstOrder` · `LibrarySortMenuTests` ×9). Walked: `18h-1/02–07 · 16`.
- **row 11 FIXED** (`LibraryDaySearchTests` ×13 incl. the two readings, the correlation, the half-open window, the composition; `DayBoundsTests` ×9; `LibraryDayFilterTests` ×9; the ladder's `theDaySearchsWorkTracksTheNotesNotTheSavepoints` re-fixtured — red on old 1,896 → 13,096 for 1 → 15 blocks per note, green flat 916 → 916 — and the plan pin requiring `idx_commit_created`). Walked: `18h-2/01–10`.

**The ladder (Opus, same-model flow):** round 1 — 1 BLOCKER · 3 MAJOR · 7 MINOR · 5 NIT (17 agreed · 0 disputed; three shape dissents upheld); the BLOCKER was the day search's savepoint arm: a correlated `EXISTS` behind an `OR` that ran for every note whose stamp missed the day, Σ(blocks × takes) over the corpus, P1 — and the batch's measurement (and my J11 on it) never executed that arm; fixed as an uncorrelated `IN` + the index (26.9 → 0.17 ms; steps flat). The other fixes: the record's measurement corrected in place; the empty day's sentence conditioned on the day being the only narrowing; the day uncapped, the page named; the explicit Gregorian calendar; the force-unwrapping door removed; the closed door's real action pinned; the day cleared on leaving the catalog; the formatter cache (19×); the sort words hoisted to Shared; the A–Z doc corrected; all four masthead oracles keyed; `library()` refusing `.title`; #103's clause. Round 2 (fresh): 0 BLOCKER · 1 MAJOR · 5 MINOR · 6 NIT — the MAJOR a regression by R1-11's fix (the day cleared on a mode change with no re-read), fixed `be4a70ff`; the truncation line per body; the docs; the `DatePicker`'s calendar; the phone's unruled word restored and its `setSort` guarded; the oracles reset; the R1-5 attribution withdrawn (the agree/dispute folded into the fix passes, recorded). Round 3 (fresh, the cap): 0 BLOCKER · 0 MAJOR · 3 MINOR · 7 NIT — recorded, routed to 17q / #103 / this close (the dispositions above); the reviewer's independent `EXPLAIN QUERY PLAN` confirms the day search's turnaround from the outside.

**Finals over the letter's last code tree (`634a57c4`):** core `✔ Test run with 1545 tests in 167 suites passed` · Mac (the letter's closing sets) batch 2's 37-suite set `✔ 217 tests in 37 suites` (`f1f60061`) · batch 1's 34-suite set `✔ 206 tests in 34 suites` (`634a57c4`) · iOS green (`MobileLibrarySortTests` 2/1 run on the simulator). `Sync/` untouched; the ONE schema change is v1_17's index (its own commit, `MigrationTests.theDaySearchIndexArrivesForAnOlderStore`). No commit trailers (one garbage MESSAGE, `5f9a3a89`, content correct, never amended).

**Canon deltas APPLIED in this commit:** `notes/AppSpec.md` §7's `commit_point` DDL block gains `idx_commit_created`; §12's Library line gains the stamps, the sort, the day filter and its caveat. §7's `setting` seeds: NOTHING (the sort memory is local UI state). **For the round's close:** `notes/MobileSoul.md` PL-22 gains 18h's parity notes (the stamps and the A–Z sort the phone owes; the day search; the phone's picker strings now her words); KnownIssues gains the `ANALYZE` note (owner 12). **Her items from this letter:** #103's build (17q), J11's re-adjudication (recorded here, nothing to do).

---

### R-8 · 17q — BRIEF (HER TWO MORNING BUILDS + the 18h cap's residue: the Takes entry landing WINS over the remembered place (R-Q20); the Library's Notes card shows the stated day AND the sort's stamp where there is room, the click-flip where small (R-Q17 / QUESTIONS #103); the List row's raw day slot through the one brain (R3-2); the synchronous selection clear (R3-1); the seven NITs swept) — written by the SUCCESSOR orchestrator 2026-09-12 (the session opened at `53fb20c9`; code byte-identical to `634a57c4`), pointers verified against that tree

**Spawn:** `opus-implementer`. **Review after:** `fable-reviewer` — the Takes half is the LANDING FAMILY (the last two rounds' Fable ladders found a BLOCKER and three MAJORs there; her R-Q20 changes what a landing MEANS against the memory), so the whole entry takes the Fable eye; cross-model flow. **One acceptance unit:** two small builds and one residue sweep, ONE session because each is a few lines and the walk is one sitting (the 17p batch-b shape). **Ledger rows:** none new — this is 17q, a lettered entry in `notes/plans/phase-17-standing-fixes.md` (register row claimed; the record stays HERE). **Her rulings (§7, SETTLED — build to them, never re-open):** **R-Q20** (J3: *"the block I came from wins"* — when the entry landing names a block, the landing wins and the remembered place is not restored; the remembered place is used only when she comes back to the same block, or with no landing) · **R-Q17** (#103: *"in the library / pool there's enough room to show both. if the area is small, the same UI i mentioned earlier of clicking on the time should switch to show you the date created or the date associated with the note"* — the Notes card shows the stated day AND the sort's stamp where the row has room; where it is small, the masthead's click-flip grammar). **The 18h ladder's cap residue (KnownIssues row "The 18h ladder's residue at the cap", owner 17q — this entry resolves the row):** R3-1 (MINOR) and R3-4…R3-10 (NITs); R3-2 rides #103's build. **Review foci F-0 · F-1 · F-5 (§12) bind.**

**Read first, yourself, in this order:** `CLAUDE.md` and the canon it loads (AppSpec §12's takes-presentations line and its Library line — both carry this round's supersessions; §10 the two stamps); this plan's §0, §7 (R-Q1, R-Q7, R-Q17, R-Q20 — and the "17q (for the successor's kickoff)" paragraph under them), §8–§9, §12 (F-0, F-1, F-5), R-0; **the R-1 brief + record + its three-round ladder + the 17p LETTER CLOSEOUT** (the landing family's whole 17p history: the restore is ONE-SHOT and settles by the ROW, the landing is a bounded REVEAL spent after the restore, her hand ends both — J1…J5 in the R-1 adjudication, J3 being the observation her R-Q20 now rules on); **the R-3 brief + record + the 18h ladder's rounds 1–3 findings and dispositions + the 18h LETTER CLOSEOUT** (R1-17's "trailing" clause and R3-1…R3-10 are this entry's residue, with their traced mechanisms and proposed fixes already written); `notes/QUESTIONS.md` #103 whole (the RULED line, the R3-2 clause, the R1-17 clause with its three readings); `notes/plans/phase-17-standing-fixes.md`'s rules; `notes/SessionResiliencyProtocol.md`'s implementer half (restated below).

**Pointers (verified against `634a57c4`'s code; re-grep before relying on a line):**
- **The restore/landing step (R-Q20):** `App/Variorum/Variorum/Features/Takes/TakesBoardLayout.swift` — the memory's shape `ArticlePlace` `:599–606` (a row identity: the BLOCK at the top of the page, or `.top`); the one-shot restore `ArticleRestore` `:616–620`; **the decision `consumeArticleGeometry(_:remembered:positionedByUser:order:)` `:685–718`** — its `.undecided` branch `:696–708` reads the memory and enters `.wanted(remembered)`; `restoreStep` `:725–766` aims until the row says so; `articleReadyForLanding` `:641–643` (a landing is considered only once the restore is `.settled` — that ordering is WHY a long note moves twice today: restore first, then the reveal); the landing's seed `landArticle(on:)` `:312–316` (armed by `TakesChoreographer.consumeLandings`, `App/Variorum/Variorum/Features/Takes/TakesChoreographer.swift:150–214` — the bloom arm `:167–186` for the fan-panel door, the N9 arm `:189–212` for the note's CURRENT block on entry, `if current != nil` — the fall-through to the first slot never lands); `articleLandingStep(order:)` `:486–516`. The view's two hooks: `App/Variorum/Variorum/Features/Takes/TakesBoardView.swift:645–665` (the geometry report → `consumeArticleGeometry` → `spendArticleLanding`) and `:677–679` (`.onChange(of: model.articleLanding, initial: true)`). **The ordering question you must TRACE before choosing the condition's home:** which arrives first at a mount — the FIRST honest geometry report (which decides the restore) or the projection that arms the landing (`consumeLandings`)? If the landing can arrive AFTER the restore has entered `.wanted`, the condition has two halves: (i) in `.undecided`, a landing naming a row OTHER than the remembered one settles the restore at once (no scroll issued — the page starts at the top and the landing reveals from there); (ii) in `landArticle(on:)`, a pending `.wanted(place)` whose `place.rowID != placementID` is settled the same way. "The same block" = the landing's `placementID` equals the remembered `ArticlePlace.rowID` (then the restore runs as today and the reveal is `.none` by construction — the block is at the top). A landing that names a block INSIDE the remembered page but not at its top still wins under her letter (the page opens at the top, the block is visible or revealed at the foot) — say so in the record; it is the ruled reading, not a corner. The memory itself is untouched (`EditorRouter.takesArticlePlaces`, `App/Variorum/Variorum/EditorRouter.swift:88`); the her-hand rule, the room, the reveal's `anchor` and the bounded step machine are untouched.
- **The pins to sit beside (R-Q20):** `App/Variorum/VariorumTests/TakesArticleScrollTests.swift` — the 60-block remount pin `aBoardLeftScrolledComesBackWhereSheLeftIt` `:281–352` (its harness: `withSession(blocks:)`, `landingModel`, `mount`, `scroll(_:to:)`, `settle`, `topOfPage`, `offset`) and the far-block reveal pin `aLongNoteEnteredOnAFarBlockRevealsItWithoutHaulingItToTheTop` `:366–418` (how a landing is armed in a test: `router.registerDetail` + `router.noteFocusedBlock(…)` on the last block); the pure-decision pins from `:420` on (`consumeArticleGeometry` driven directly with `noteArticleRowFrame` — the cheap shape for the condition's own pin). The R-1 record's landing pins in `CommandRoutingTests.swift` must ride unmodified.
- **The Notes card (R-Q17 / #103):** `App/Variorum/Variorum/Features/Library/LibraryCatalogView.swift` — `noteCard(_:)` `:626–668` (the title `HStack`: title · `CatalogRowStamp(face: LibrarySortFace.rowStamp(model.sort, for: hit))` · `Spacer` · the book names); the List row's call `postRow` `:708–714` passing `date: hit.detail` AND `stamp:`; **`CatalogNoteLine` `:1043–1093`** — `if let date { Text(date) … }` `:1069–1071` is the RAW `entry_date` slot R3-2 names (the same fact the trailing stamp says under the `date` sort — one day printed twice). The words: `App/Variorum/Variorum/Features/Library/LibraryTimeFace.swift` — `LibrarySortFace.stampSubject` `:105–111`, `RowStamp` `:120–125`, `rowStamp(_:for:)` `:127–142`; `CatalogRowStamp` `:189–219`. The brain: `Sources/VariorumCore/Domain/TimeStampFace.swift` — `Subject` `:64–81` (`.dated` is day-precision), `day(_:now:)` `:98–106`, `stamp(_:iso:now:)` `:124–131`, `stamp(_:day:now:)` `:134`, the tooltips `:146–170`. The hit's facts: `Queries.CatalogHit` (`Sources/VariorumCore/Queries/ShelfQueries.swift:325–355` — `detail` is the raw `entry_date` for a post; `createdAt` · `lastTouchedAt` since 18h). **The click-flip grammar to REUSE, never re-mint:** `App/Variorum/Variorum/Features/Takes/MastheadStamp.swift` — `showsCreated` `@State`, `flip()`, the `.help` wording, `VoicedButtonStyle(role: .quiet)`, the two-subject `subject`/`date` computed pair (the flip is VIEW state per note, defaulting to the sort's stamp — the batch-1 call, unchanged). **"Where there is room" — ONE width-aware decision, not two layouts:** the precedents are `ViewThatFits(in: .horizontal)` in `Features/Editor/CommitBar.swift:242–260` (its doc explains why every member must be `fixedSize` for the judgement to be honest) and `MastheadRowTwo` (`Features/Takes/MastheadRowTwo.swift`, the width-aware two-subview layout). Recommended: a small `CatalogCardStamps` view in `LibraryTimeFace.swift` (never inside `LibraryCatalogView.swift` — F-0/P-9; that file is 1,101 lines) that offers TWO arrangements to `ViewThatFits`: (1) the stated day (`.dated`, via the one brain) AND the sort's stamp, both `fixedSize` + `lineLimit(1)`; (2) ONE flipping stamp — the sort's stamp by default, a click flipping to the stated day (`.dated`) and back — reusing `MastheadStamp`'s grammar (hoist the flip into a shared `FlippingStamp` face both consume if that is cleaner; the masthead's own pins must ride unmodified). Under the `date` sort the two facts are ONE fact (the sort's stamp IS the stated day): arrangement (1) shows it ONCE (the stated day + the EDIT stamp is the honest second — say so in the record as the batch's call, PROVISIONAL on #103), never the same day twice (R3-2's letter). A note with NO stated day shows only the sort's stamp in both arrangements. **Where the pair sits** (#103's R1-17 clause — her word "trailing" unanswered on the card): build reading **(i)** — both beside the title, the shape she pointed at — and record it as the batch's call on #103 (PROVISIONAL; readings (ii)/(iii) are one `Spacer` away).
- **The List row (R3-2):** `CatalogNoteLine`'s `date:` slot goes through the one brain — the stated day in `TimeStampFace`'s words (`stamp(.dated, day:now:)` — *dated Sep 8*), and under the `date` sort the row shows the day ONCE (the trailing stamp already says it: drop the beside-the-title slot when `stamp.subject == .dated`, or the reverse — one rule, stated in the doc). The alignment pins (`LibraryRowAlignmentTests`) construct the line with the defaults and must ride; a face pin asserts the row's two date texts are never the same day twice under `.entryDate` (red on old).
- **R3-1 (the synchronous clear):** `App/Variorum/Variorum/Features/Library/LibraryCatalogModel.swift:253–258` (`modeChanged() async` — `clearSelection()` deferred off the mode-change update by the `Task {}` at `LibraryCatalogView.swift:219`) → `func modeChanged() -> Bool` (clear synchronously; return whether the day was cleared) and `.onChange { if model.modeChanged() { Task { await model.search() } } }`; the R2-1 pin `returningToTheCatalogListsTheWholeLibraryAgain` (`LibraryDayFilterTests`) survives as `_ = model.modeChanged(); await model.search()`. Pin: the reviewer's shape — a pin that calls `modeChanged()` without `await` and asserts `selectedPosts.isEmpty` on the next line (does not compile on the old tree = red on old, the product-row class), OR a behavioural pin that reads the selection synchronously after the mode flip.
- **The NIT sweep (R3-4…R3-10; each a few lines; no pin owed where behaviour is byte-identical — say which):** R3-4 `App/Variorum/Shared/LibrarySortWords.swift:71–77` — the fallback becomes an exhaustive switch (or `label` folds both), so a new `LibrarySort` case must be answered (compile-time shape; the pins `ruledLabel(.lastMajorRevision) == nil` and `sortWord(.lastMajorRevision) == "last meaningful edit"` ride) · R3-5 `Sources/VariorumCore/Domain/JournalDay.swift:58` — `date(from:calendar:)`'s default → `JournalDay.storeCalendar` (R2-8's own rule; every caller passes one explicitly today) · R3-6 `LibraryCatalogModel.modeChanged` writes `editedOn = nil` past the `private(set)` door → `setEditedOn(nil)` · R3-7 `Sources/VariorumCore/Queries/Timeline.swift:158` + `LibraryTimeSortTests.titleSortsOnTheDisplayedNameCaseInsensitively` — one clause naming the ASCII fold (`COLLATE NOCASE`) as the accepted shape · R3-8 three tooltip literals — `LibraryTimeFace.swift:175` composes from `LibrarySortFace.offered` + `label`; `LibraryDayFilter.swift:206` and `:218–220` join `LibraryDayFace` · R3-9 `Features/Library/LibraryCopy.swift:47` — the mid-file `import SwiftUI` to the header · R3-10 `MastheadStamp.swift:78` + `PostDetailView.swift:918–923` — DEBUG-only oracle hygiene (reset from the `.task(id:)` transition; `MastheadGeometry` clears its own row) — take it if it is the few lines the reviewer describes, else record it as left with its reason. Re-grep every one of these lines.

**What you build (in this order, each its own commit):**
1. **R-Q20 — the landing wins (the condition + its pin).** Trace the mount ordering first (above) and write the finding into your record before the code. The pin, RED ON OLD: `TakesArticleScrollTests` — the 60-block remount pin's sibling: scroll deep and leave (the memory holds a far row) · arm a landing on a DIFFERENT far block (the `noteFocusedBlock` road, as the reveal pin does) · remount → the landing's row is on screen at the page's edge (the reveal's own assertion shape) AND the remembered row is NOT at the top (old: the restore put the remembered row at the top first, then the reveal moved the page again — assert on the two-move signature you measure: the restore's `scrollToRow` issued, or the remembered row's frame at the top before the reveal); the mirror — remount with NO landing → the remembered place (the existing pin, unchanged); and the same-block case — a landing on the remembered row → the restore runs and the reveal is `.none`. Plus the pure-decision pin on `consumeArticleGeometry` (a remembered row + a pending landing on another row → `.settled` at once, no `.scrollToRow`). Every existing landing and restore pin rides unmodified (a change needs a written reason).
2. **R-Q17 — the card (both where room, the flip where small) + R3-2 (the List row's slot).** The width-aware face (above); pins: a geometry oracle at a WIDE card width (both stamps present, the stated day's words and the sort's words) and at a NARROW one (one stamp; a flip through the same DEBUG oracle shape `MastheadStamp` uses shows the stated day); under `.entryDate` the wide card and the List row each print the day ONCE (red on old for the row); the `LibraryRowAlignmentTests` and `MastheadStampTests` pins ride unmodified. Update `notes/QUESTIONS.md` #103 in the same commit: the build landed (R-Q17's letter), the R3-2 clause resolved, the R1-17 clause's reading (i) BUILT PROVISIONAL with its one line named.
3. **R3-1 — the synchronous clear** (above; its pin).
4. **The NIT sweep** (R3-4…R3-10 — one commit, or one per item; the record says which behaviour changed and which is byte-identical).
5. **The walk (the acceptance gate — USE).** On the DEV-STORE Debug build (`io.lduarte.Variorum.debug`; `cliclick` + `Tools/WalkKit/`; NEVER `/Applications`; `pgrep -fl 'Variorum.app/Contents/MacOS'` first — the author is AWAKE and may be using her real-store app at `/Applications/Variorum.app`: discriminate by PATH, NEVER quit or kill it): (a) a long note (60+ blocks — the Sherlock sample stories qualify): in Takes scroll deep, → Write, click a block FAR from the remembered page, → Takes: the clicked block is revealed and the old place is NOT restored first (no double move — watch it); → Write on the SAME block, → Takes: the remembered place; a two-block note round-trips unmoved; the fan-panel door on a far block still reveals; (b) the Library's Notes mode at a wide window: each card shows the stated day and the sort's stamp; under `sort ▾ date` the day once; narrow the window until the card is small: one stamp, a click flips it to the stated day and back; the List row under `date` shows the day once; (c) the Library: pick two notes in List, switch to Notes → no bulk bar frame (R3-1); both voices for (b); captures into `notes/plans/use-report-2026-09-12-screens/17q/` (gitignored); list them in your RECORD.

**What you do NOT do:** no change to the memory's SHAPE (`ArticlePlace`), the reveal's anchor rule, the her-hand set, the room, `TakesChoreographer`'s two landing arms (what a landing NAMES is untouched — only what it outranks), `PaneTextAuthority`, `PaneSurface`, `BlockRangeIndex`, `EditorTextView`, anything in `Sources/VariorumCore/Sync/`; no schema; no new `setting`; no change to the List row's TRAILING stamp or the masthead's stamp (their pins ride); no new string in a view (F-0 — the words are the brain's); no product invention — a decision §7 and #103 do not make goes to `notes/QUESTIONS.md` at the next free number (**#105**; read the file's tail first) with 2–3 options, the most spec-defensible built and marked PROVISIONAL. Never re-open R-Q1, R-Q7, R-Q17 or R-Q20.

**The rules you work under (restated; they bind):**
1. **Checkpoint protocol:** commit per coherent piece (the landing condition · the card + the row · R3-1 · the sweep · the walk); push after every commit (`git pull --rebase` first, then `git push origin main`); write your RECORD's LIVE STATUS section at your FIRST commit and flip it in the same commit as each piece (`DONE (hash)` · `IN-PROGRESS — exactly what remains` · `NOT-STARTED`); every unverified claim marked PENDING; counts land as PENDING and flip when the run completes; **synchronous foreground waits only** — never end your turn awaiting a backgrounded build or suite (poll a log with `grep -q '<EXIT LINE>' <log> && break; sleep 5`, repeating past the Bash timeout); never spawn subagents (one Sonnet lookup for EXTERNAL facts only, if ever); note every death/resume in the record; announce a behavioral revert BEFORE starting it (commit first, so `git checkout -- <file>` is the safe restore), never restore from a scratchpad copy.
2. **One unit per session** — this entry's five pieces. A second unit in your way (the Outline's shadow editor, the lane, anything on the 13u2 rows) → stop, record, hand off.
3. **Pin before fix — no exceptions:** trace each mechanism yourself (the ladder findings are the reviewer's READ; the J3 observation is the orchestrator's), write the red-on-old pin, watch it fail on the pre-fix code (a behavioral revert where a code revert is impractical), then fix, then green. A pin green on both sides → the item is DISMISSED AS HOLLOW, recorded, not fixed. Product rows (R-Q17's card) pin as geometry oracles; R-Q20 is a bug-class row under her ruling — its red-on-old is the double move.
4. **The acceptance gate is USE** (piece 5). An implementer's "done" is a claim; the walk is the verification; the captures are the record.
5. **No product invention** (above).
6. **No `Co-Authored-By` / `Claude-Session` trailer lines** on commits; never rewrite history; never `git checkout` over uncommitted work; path-scoped `git add`.
7. **Environment traps (verbatim-faithful from the round):** instance checks via `pgrep -fl 'Variorum.app/Contents/MacOS'` discriminated by PATH — her real-store app may be RUNNING and is NEVER quit/killed; no Release builds, no `/Applications` refresh; core tests via `swift test` from the repo root (you touch `Sources/` at R3-5 and R3-7 — run the touched core suites); Mac app tests from `App/Variorum/` with suite-level `-only-testing:VariorumTests/<SuiteTypeName>` only (**TYPE names, never file names** — a file name matches nothing and `xcodebuild` runs the rest silently; **zsh does not word-split an unquoted `$var` — put the `-only-testing` arguments in an ARRAY**; read the `Test run with N tests in M suites` line and the `skipped:` lines — Swift Testing COUNTS skipped tests); `xcodebuild build-for-testing` compiles without the runner; NEVER add a custom build configuration; zsh `pipestatus`; scratch and screenshots in gitignored dirs inside the worktree (`scratchpad/`, the screens folder); the A1 backup rail before ANY touch of the real store (you have no reason to touch it). The identity oracle runs per keystroke in DEBUG; the pane component's ONE measurement brain is `PaneMeasurement`. The real-click rig cannot mount a WHOLE surface (KnownIssues) — pin brains and rows, walk faces. The Mac suites write the dev-store's `UserDefaults` (KnownIssues row 46) — forget what your pins set (`router.forgetCurrentBlock`, the remount pins' pattern). Flake rules: the latency pin and `CanvasDragTrackingTests` red under load are known; 3/3 green isolated clears them. **The DEBUG geometry oracles are singleton statics under parallel suites** (KnownIssues row 53) — key any new oracle by its subject id, and reset what you set.
8. **Close honestly:** at the END run the touched Mac suites — `TakesArticleScrollTests` · `CommandRoutingTests` · `LibraryRowAlignmentTests` · `LibrarySortMenuTests` · `LibraryDayFilterTests` · `MastheadStampTests` · `MastheadLayoutTests` · `MastheadTagDoorTests` · the new suite(s) — + the ten `Tutorial*Tests` spine types in ONE `xcodebuild test` invocation from `App/Variorum/`; core `swift test --filter 'LibraryTimeSortTests|TimeStampFaceTests|DayBoundsTests|LibraryDaySearchTests|NoteStampsTests'` (you touch `Sources/`); the iOS build (`xcodebuild build -scheme VariorumMobile -destination 'generic/platform=iOS'`) if you touch `App/Variorum/Shared/` (R3-4 does). Record the exact lines. Then write your RECORD below (the disposition per item — R-Q20 · R-Q17 · R3-1 · R3-2 · R3-4…R3-10 — with the pin names and the red-on-old numbers; the mount-ordering trace; the card's arrangement call; the walk table with the capture filenames; things found and deliberately not fixed; the canon note owed — AppSpec §12's takes line gains R-Q20's sentence and its Library line R-Q17's, drafted for the orchestrator to apply; the KnownIssues row this entry resolves) and END with a one-paragraph report to the orchestrator: what shipped, hashes, counts, what is PENDING or open.

### R-8 · RECORD (the implementer writes here from its first commit)

**WHAT I HAVE NOT DONE (the record's first line).** *(Opened 2026-09-12 at `e02438a9`; this line is
kept honest at every commit.)* By the brief: nothing in `Sources/VariorumCore/Sync/`, no schema, no
migration, no new `setting`; nothing in `PaneTextAuthority` · `PaneSurface` · `BlockRangeIndex` ·
`EditorTextView` · `PaneMeasurement`; no change to the memory's SHAPE (`ArticlePlace`), the reveal's
anchor rule, the her-hand set, the typewriter room, or `TakesChoreographer`'s two landing arms (what a
landing NAMES is untouched — only what it outranks); no change to the List row's TRAILING stamp or to
the masthead's stamp; no Release build and no `/Applications` touch. **PENDING at this commit:** every
piece below.

**LIVE STATUS — 17q (`opus-implementer`, opened 2026-09-12 at `e02438a9`).**

| # | piece | state |
|---|---|---|
| 0 | orientation + the mount-ordering trace | **DONE (this commit)** |
| 1 | R-Q20 — the landing wins over the remembered place (the condition + its pins) | **DONE (this commit)** |
| 2 | R-Q17 — the card (both where room, the flip where small) + R3-2 (the List row's lead slot) + QUESTIONS #103 | **DONE (this commit)** — R3-2's red-on-old is measured by BEHAVIORAL REVERT at the next commit (see below: no revert is in flight at this commit) |
| 3 | R3-1 — the synchronous selection clear | **NOT-STARTED** |
| 4 | the NIT sweep (R3-4…R3-10) | **NOT-STARTED** |
| 5 | the walk (the acceptance gate) + the closing runs | **NOT-STARTED** |

**Items:** R-Q20 · R-Q17 · R3-2 · R3-1 · R3-4 · R3-5 · R3-6 · R3-7 · R3-8 · R3-9 · R3-10 —
dispositions PENDING.

- **Orientation — DONE.** Read in my own context, in the brief's order: `CLAUDE.md` and the canon it
  auto-loads (CoreDescription · OverallModel · AppSpec — §10's two stamps, §12's takes-presentations
  line and its Library line, both carrying this round's supersessions · SyncSpec · TEXTKIT2_NOTES);
  this plan's §0, §7 (R-Q1 · R-Q7 · R-Q17 · R-Q20 and the "17q (for the successor's kickoff)"
  paragraph), §8–§9, §12 (F-0 · F-1 · F-5), R-0 (P-1…P-9 + the application notes); the **R-1 brief +
  record + its three-round ladder + the 17p LETTER CLOSEOUT** (the landing family whole: J1's bounded
  step machine, J2's row-identity memory, J3's observation her R-Q20 now rules on; R1-1's TOP place,
  R1-4's gone-row settle, R2-1's three bare-runner doors, R3-1's PICK and its banner — the third
  seam); the **R-3 brief + record + the 18h ladder's rounds 1–3 with their dispositions + the 18h
  LETTER CLOSEOUT**; `notes/QUESTIONS.md` #103 whole (the RULED line, the R3-2 clause, the R1-17
  clause with its three readings) and #104; `notes/plans/phase-17-standing-fixes.md`'s philosophy,
  its "Standing rules for every entry" and the 17q register row; `notes/SessionResiliencyProtocol.md`
  whole; `notes/KnownIssuesAndTechDebt.md`'s 17q row. Then the code: `TakesBoardLayout` (the landing's
  step machine `:300–536`, the restore `:560–766`), `TakesChoreographer.consumeLandings` `:150–206`,
  `TakesBoardView`'s three spend sites (`:588–593` the row frames · `:645–668` the geometry hook ·
  `:679–681` the landing's change) and `singleColumnArticle` `:554–575`, `TakesViewModel`'s forwarders
  `:605–676` and `adopt` `:418`, `TakesArticleScrollTests`' harness; `LibraryCatalogView.noteCard`
  `:641–668` · `tagsRow`/`postRow` `:700–716` · `CatalogNoteLine` `:1043–1093`, `LibraryTimeFace.swift`
  whole, `MastheadStamp.swift` whole, `TimeStampFace` (core `Domain`), `LibraryCatalogModel`
  (`setEditedOn` `:121–129`, `clearSelection` `:225–232`, `modeChanged` `:234–258`),
  `LibraryDayFilter` · `LibraryCopy` · `Shared/LibrarySortWords` · `JournalDay` · `Timeline.LibrarySort`
  · `PostDetailOracle.resetStamp`. **Tree clean at `e02438a9`, `main` == `origin/main`.**
  **Her real-store app is NOT running** (`pgrep -fl 'Variorum.app/Contents/MacOS'` empty at open) — it
  is never touched either way; every walk is on `io.lduarte.Variorum.debug`.

---

#### THE MOUNT-ORDERING TRACE (written BEFORE the code, as the brief requires)

**The question:** at a mount, which arrives first — the FIRST honest geometry report (which decides
the restore) or the projection that arms the landing (`TakesChoreographer.consumeLandings` →
`landArticle`)?

**The answer is: IT DEPENDS ON THE SURFACE, and both orders are real — so the condition needs both
halves the brief anticipated.** Traced by reading, three facts:

1. **In the APP the GEOMETRY is first.** `TakesBoardView`'s article `ScrollView` exists from the very
   first layout pass whether or not the note has slots — `singleColumnArticle`
   (`TakesBoardView.swift:554–575`) renders `TakesEmptyStateView` INSIDE the `ScrollView` when
   `model.projection.slots.isEmpty`. So `onScrollGeometryChange` (`:646`) fires with `viewport > 0`
   on that first pass. The projection, by contrast, arrives from `.task { await model.start() }`
   (`:176`) → `observeTakes` → `deliver` → `adopt` (`TakesViewModel.swift:418`), which is
   asynchronous and therefore lands AFTER the first layout. `consumeLandings` (`:456`) — and with it
   the only two `landArticle` callers in the codebase (the bloom arm and the N9 entry arm,
   `TakesChoreographer.swift:167–186` / `:189–212`) — runs inside `adopt`. **So on the real board the
   restore has already entered `.wanted(remembered)` by the time the landing is armed.**
2. **…and the restore cannot have MOVED anything yet.** Before `adopt` the article has zero rows, so
   the restore's `.scrollToRow(rowID)` is a proxy scroll at an id the column does not hold — a no-op
   (the same fact R1-4 rests on). That is what makes the second half of the condition sufficient:
   settling the restore at `landArticle` time cancels it before it can scroll for real.
3. **In the PIN HARNESS the LANDING is first.** `TakesArticleScrollTests.landingModel` calls
   `adopt` BEFORE `mount` (`:180–190`), exactly as `CommandRoutingTests` does, so the landing is
   already armed when the first geometry report arrives and the restore is still `.undecided`.

**Consequence for the condition's home — both halves, one rule.** A single pure predicate
(`TakesBoardLayout.landingOutranks(_:remembered:)`) is consulted at the two places the two orders
reach:
  **(i)** `consumeArticleGeometry`'s `.undecided` branch — a landing already pending that names a row
  OTHER than the remembered one settles the restore at once, no scroll issued (the harness's order,
  and the app's if a projection ever lands before the first geometry);
  **(ii)** `landArticle(on:)` — a restore already `.wanted(place)` whose `place.rowID` differs from
  the arriving landing is settled on the spot (the app's order).
A `.settled` restore is left alone in both (nothing to cancel), and a memory of `.top` already
settles at once with no scroll, so a landing trivially wins there and no branch is owed.

---

#### PIECE 1 — R-Q20: THE LANDING WINS OVER THE REMEMBERED PLACE

**RED ON OLD, measured before a line of the rule moved** (`/tmp/17q-red1.log`, local — the counter
and the three pins on the tree with the OLD rule: `✘ Test run with 23 tests in 1 suite failed after
21.998 seconds with 7 issues`):

- `theLandingOutranksARememberedRowButNotTheSameOne` — **six issues.** The harness's order (a): the
  step was **`.scrollToRow("left")` where `.remember(.top)` is owed**, the restore left
  **`.wanted(rowID: "left")` where `.settled` is owed**, **`articleRestoreAims → 1` where 0 is
  owed**, and `articleReadyForLanding → false` (the landing could not even be spent yet). The app's
  order (d): the same two, after the landing arrived mid-restore.
- `aLandingOnAnotherBlockWinsOverTheRememberedPlace` (mounted, 60 blocks, left at 800 pt, returning
  on the note's LAST block) — **`second.board.articleRestoreAims → 3` where 0 is owed**: the page
  was hauled to the remembered row first and the reveal then moved it again. J3's double move, in a
  number.
- `aLandingOnTheBlockSheLeftAtTheTopStillRestoresThePlace` — **GREEN on both sides, deliberately**:
  it is the mirror guard (she comes back to the same block; the memory still rules), not a
  red-on-old claim. Said outright rather than counted as evidence.

**Why the number and not the page.** Both roads end at the SAME rest — a reveal's
`scrollTo(row, .bottom)` is absolute, so the destination cannot discriminate. What her ruling
removes is the MOVE, and "the page was left alone on the way" is measurable only as the restore's own
aim count. So the counter `TakesBoardLayout.articleRestoreAims` was added beside the shipped
`articleLandingAims` (the same `measuredHeightWrites` precedent: a plain counter, not DEBUG-gated),
and the pins read it through `model.board` — **no new view-model forwarder** (R1-6's lesson: the
batch that added ten forwarders shipped three dead ones).

**What shipped.** ONE pure predicate, `TakesBoardLayout.landingOutranks(_:remembered:)` — a landing
outranks a remembered ROW when it names a different one (nil for no landing, and for the TOP, which
settles at once and issues no scroll anyway) — consulted at the two places the two mount orders
reach, per the trace above:

1. **`consumeArticleGeometry`'s `.undecided` branch** — a landing already pending at the first
   geometry settles the restore at once and issues no scroll (the pins' order, and the app's if a
   projection ever beats the first layout).
2. **`landArticle(on:)`** — a restore already `.wanted(place)` at a different row is settled on the
   spot (the app's own order). Nothing has moved when it fires: before `adopt` the column holds no
   rows, so the restore's aims were no-ops at an id the column does not hold.

`TakesChoreographer` is **untouched** — what a landing NAMES is unchanged; only what it outranks
moved. The memory's shape, the reveal's anchor rule, the bounded step machine, the her-hand set and
the room are all byte-unchanged (`git diff` touches `TakesBoardLayout.swift` and the one test file).

**Two consequences of her letter, recorded rather than hidden** (both written into
`landingOutranks`' doc so the next reader finds them in the code):

1. **A landing on a block that was INSIDE the page she left — visible, but not the row at its top —
   wins too**, so the page opens at the top and reveals that block at the foot rather than restoring
   the view she had. That is her letter exactly (*"the remembered place is not restored"*); ranking
   the memory above a landing whose row it already shows is a rule she did not ask for. It is the
   ruled reading, not a corner.
2. **The memory is rewritten the moment the landing wins**: settling without aiming lets
   `rememberStep` record the page's current place (the top), and the memory then converges to
   wherever the reveal comes to rest — which is what she comes back to next time.

**GREEN:** `✔ Test run with 23 tests in 1 suite passed after 21.989 seconds`
(`TakesArticleScrollTests`, 20 shipped + 3 new), and the landing neighbourhood in one run —
`✔ Test run with 76 tests in 10 suites passed after 67.090 seconds` (`TakesArticleScrollTests` ·
`TakesLandingTests` · `CommandRouterTests` · `TakesRoomTests` · `TakesBoardTests` ·
`TakesEmptyBlockFaceTests` · `TakesArticleRenderTests` · `TakesBoardSoakTests` ·
`CurrentBlockContinuityTests` · `LandingOffsetTests`). Every shipped landing and restore pin rides
**unmodified** — the only test-file change is the three appended pins.

---

#### PIECE 2 — R-Q17: THE CARD SHOWS BOTH WHERE THERE IS ROOM (and R3-2: the List row's day)

**ONE rule, both note renderers.** `LibrarySortFace.rowStamps(_:for:)` answers what a note row's two
time facts are: **`stated`** — the day she stated (`entry_date`), the fact the Notes card's one slot
carried from 13g until 18h — and **`other`** — the SORT's own stamp, *or the EDIT stamp when the sort
IS that day*, so one fact is never printed twice. It also says which of the two the sort is about
(`sorted` / `unsorted`, the small card's opening face and what her click reveals) and what the List
row puts beside its title (`listDay` — nothing under the `date` sort, where the trailing stamp is
already saying that day). The List row's TRAILING stamp is `rowStamp(sort, for: hit)`, byte-unchanged
from 18h, as the brief requires.

**The card's face.** `CatalogCardStamps` (in `LibraryTimeFace.swift`, never in the 1,101-line
`LibraryCatalogView.swift` — F-0/P-9) offers **two arrangements to `ViewThatFits(in: .horizontal)`**:
the pair side by side, and ONE flipping stamp. Every member is `fixedSize` + `lineLimit(1)` — which
is what makes the judgement honest (the N15 gotcha `CommitBar.boxPair` records: a compressible child
makes `ViewThatFits` call every arrangement a fit). **Measured, not assumed:** at 520 pt the pair
drew and the flipping stamp's `onAppear` never ran; at 120 pt the reverse. So `ViewThatFits` places
only the arrangement it chose, which is what the oracle reads.

**The small card's flip reuses the masthead's grammar, and is deliberately NOT the same TYPE.** A
quiet `VoicedButtonStyle(role: .quiet)` button, the flip as VIEW state per note defaulting to the
SORT's own stamp, the tooltip saying the whole fact plus what a click will show. It is not hoisted
into a shared `FlippingStamp` because the two flips differ in both halves that matter: `MastheadStamp`
flips between two SUBJECTS of a HELD `noteStamps` observation and carries the masthead's geometry
probe, while the card flips between two already-computed `RowStamp`s a catalog hit carries. What they
share is the WORDS (`TimeStampFace`, one brain) and the tooltip grammar, and both already read them
from the same place — so there is no second copy of a RULE, only a second twelve-line button. **The
hoist is NAMED for the next touch** (13u2's Library restyle) rather than forced through
`MastheadStamp`, whose pins the brief requires to ride unmodified. They do (`MastheadStampTests` 4/1,
untouched).

**The DEBUG words oracle** (`CatalogStampOracle`, `LibraryTimeFace.swift`) is the `TakesCellChrome`
pattern with row 53's rule applied: keyed by the NOTE, one entry per SLOT (`card.wide.stated` ·
`card.wide.other` · `card.small` · `card.only` · `row.date` · `row.stamp`) so a body that runs twice
records once, reset by the pin before every mount, and the flip door torn down on `onDisappear`
(R3-10's own hygiene, applied at birth rather than inherited).

**GREEN:** `✔ Test run with 21 tests in 4 suites passed after 9.535 seconds` —
`LibraryCardStampsTests` (5 new) · `LibraryRowAlignmentTests` · `LibrarySortMenuTests` ·
`MastheadStampTests`, **the last three UNMODIFIED** (the parity proof: `CatalogNoteLine` kept its
`date: String?` parameter, so the alignment pins construct the line exactly as they did; the trailing
stamp keeps its `note.stamp` baseline id because the new day slot passes `baselineProbeName: "date"`).

**The three calls this batch made inside her ruling — all recorded on QUESTIONS #103 as PROVISIONAL,
each one line to change:** (i) the pair sits BESIDE THE TITLE (reading (i) of #103's R1-17 clause —
the shape she pointed at); (ii) under the `date` sort the second fact is the EDIT stamp (the brief's
own call: the sort's stamp there IS the stated day, and "both" cannot mean one fact twice); (iii) a
note with NO stated day under the `date` sort now shows the EDIT stamp where it used to show nothing
— not a special case but a CONSEQUENCE of the one rule (the first slot is silent, the second is "the
other fact"), and it arrives at the answer #103's own "related edge" paragraph floated, from the
other end.

**RED ON OLD FOR R3-2 — PENDING at this commit, and the revert is announced here before it starts
(the resiliency protocol's addendum 2).** R3-2's defect is a COMPOSITION, so its red needs both
halves reverted: (1) `CatalogNoteLine`'s day slot back to `Text(date)` raw (with the oracle write
kept, so the pin can still read what drew), and (2) the call site's `date:` back to `hit.detail`. The
pin `theListRowSpeaksTheOneBrainAndNeverPrintsOneDayTwice` builds the line the way the call site does,
so reverting (1) alone shows half of it and the pin's own `pair.listDay` shows the other. **At THIS
commit no revert is in flight and the tree is the fixed one**; the pre-revert copies go in
`scratchpad/17q-prerevert/` and the restore is `git checkout --`, never a copy-back. The numbers land
in the next commit.

