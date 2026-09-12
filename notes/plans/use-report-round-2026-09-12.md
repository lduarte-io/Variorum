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
- **17p batch a CLOSED + its LADDER CLOSED** (three rounds, the cap; every finding fixed; finals 266/38; residue in `### 17p batch a LADDER — CLOSED`). **17p batch b CLOSED** (`opus-implementer` on R-2; nine commits `52c9e891`…`b84336bf`; rows 3–6 FIXED; the walk found and fixed W-1/W-2; closing run 426/57 green). **Adjudicated** (R-2's ADJUDICATION, J4–J7: the ladder as FABLE for the seam contact; the 64 pt lane accepted, bundled for her; the walk's lesson; the residuals to 13u2). **In flight: the 17p batch-b Fable ladder, round 1** (`fable-reviewer`, `{PHASE}` = "17p batch b", over `48f54268..b84336bf`; cross-model flow). **Next after:** the ladder's dispositions → 17p's LETTER CLOSEOUT (the dispositions block copied into `phase-17-standing-fixes.md` under a `CLOSED` heading — the 17o shape; the canon note at AppSpec §12's takes line + R103; the KnownIssues rows: R1-7's tutorial-spine instance, 13u2's option-(b) + reflow discriminator + the two lane residuals) → append R-3 (staged with its pointer notes) → 18h batch 1.

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
