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
- **17p batch a CLOSED** (`opus-implementer` on R-1; six commits `ee1f1f5a`…`066e2588`; rows 1–2 FIXED; the walk captured). **Adjudicated** (R-1's ADJUDICATION, J1–J3; the J1 fix `da75fd47`). **Ladder round 1 COMPLETE** (fable-reviewer, cross-model flow): 0 BLOCKER · 3 MAJOR · 3 MINOR · 3 NIT, all nine confirmed and fixed (`d5ac3785`…`839342a3`), the implementer's sanity pass raised the slot-height drag (fixed `510a1f7c`), the her-hand rule settled at `TakesBoardLayout.clearArticleLanding`; closing runs on `510a1f7c`: the two suites 19/2 ×3, the 38-suite set 262/38 green; residue: the `TakesArticleScroll` split named for 13u2. **In flight: round 2** (a FRESH `fable-reviewer` re-reviewing `1112d4b1..510a1f7c`, anchored on the round-1 findings, dispositions, sanity pass and final word). **Next after:** round 2's dispositions (a new BLOCKER/MAJOR ⇒ round 3; cap 3) → append R-2 (pointers re-verified 2026-09-12: `RecoveryView.swift` is under `Features/Library/`, `EditorTypography.swift` under `Theme/`; lines within four of the brief's) → batch b.

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
