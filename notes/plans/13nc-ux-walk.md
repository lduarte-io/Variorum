# 13n-c — the Opus UX-reviewer walk (ledger row 13, leg 2)

**Walker:** Opus 5.5 (`claude-opus-5-5`), a fresh session, 2026-10-11 evening (19:20–20:05 MDT). Worktree
`~/dev/variorum-vx-165`, branch `vx-165-13n-c`, from tip `2e35aebb`. The author's named refresh condition: "specifically
had an opus UX reviewer walk it to flag problematic flows, hard to find buttons, weird spacing or looks, etc."

**Mandate:** walk the real app on screen (the dev-store Debug build only) and flag what reads wrong to fresh eyes. I changed
no code. Dispositions are the orchestrator's: I flag, I do not fix. The inputs were the phase plan's rulings, the U1–U6
walk subsections, the HELD-WALKS RECORD's taste list T-1…T-17, and the drawn states in `vx-156-grant-ux-mockups.html`
(rendered locally to PNG with an offscreen WebKit snapshot; never published).

**Captures:** `notes/plans/13n-c-screens/walk-ux/` (gitignored, `.gitignore:66`, `git check-ignore` verified). Crops are
named `<nn>-crop.png` / `<nn>-foot.png` beside their full captures.

**How the asks were raised.** A scripted stdio client named `ux-walk` (one `initialize`, then `tools/call`) was piped to the
Debug shim only (`…/DerivedData/vx165-ux/…/variorum-mcp` — it reaches only the dev container). It raised a real connection
request, which I approved with a write-new grant on one book. It then raised a BOOK ask (`create_note` into a book it can't
reach), a HOME-WING ask (`create_note` with `wing_id ""`), and NOTE asks (`read_note` on an unreached note). `claude-code`
(approved, with the fixture's wing grants) drove one `move_note_to_wing`. Before every client run I checked that her app
was absent (`pgrep`). No `claude mcp` registration was made, and her user-scope entry was never touched.

**Scope check (the reviewer contract):** none of the findings below touch the editor seam, custody or keychain code,
`Sync/`, or a default's meaning. Finding 1 is bug-class chrome in `Features/MCP/`.

## LIVE STATUS

| # | Leg | Status |
|---|---|---|
| 0 | Preflight: the plan's rulings, units, walk records and taste list; WalkKit; the scale-fixture road | DONE |
| 1 | Build the tip's Debug app; stage claim; A1 prestage copy + scale seed | DONE — `** BUILD SUCCEEDED **` into `App/Variorum/DerivedData/vx165-ux` (an APFS clone of `vx165-u6`, built incrementally); stage `ux-walk` claimed for 90 min; no instance running before launch; `stage.sh notes=30,long=1,books=20,shelves=3` → **the restore source `…/Variorum-dev/Backups/safety-copies/scale-prestage-20261012T012517Z`**. The wing part (`wing=1`) was added by a relaunch, so the ONE-WING state could be walked first |
| 2 | Zero-client gating | WALKED (Study, light) |
| 3 | The grant sheet on the scaled seed | WALKED (Settings-hosted and window-hosted) |
| 4 | Settings ▸ MCP | WALKED (Study + Terminal, light; Terminal dark) |
| 5 | The share doors | WALKED except the bulk bar (see NOT WALKABLE) |
| 6 | Icons + popovers | WALKED (Study + Terminal, light + dark) |
| 7 | ⌘L, the masthead cycle, the one-wing state, ⌥⌘, | WALKED |
| 8 | Receipts | WALKED (share, already-reaching refusal, allow-once, wing move, undo) |
| 9 | The guide's MCP chapter, all seven lessons | WALKED (re-seeded via Help ▸ Restore Tutorial…, read on screen in Read) |
| 10 | T-15 | WALKED |
| 11 | Terminal + dark | WALKED (Terminal light + dark; Study dark not walked) |
| 12 | Restore | DONE (evidence at the end) |

## FINDINGS (ranked by how much they would bother a real user)

Each finding gives the surface · what reads wrong · the captures · a suggested fix size.

**1 · An answered ask's sheet pops up again by itself when the same client asks the same thing again — BUG-CLASS (flow).**
- **Surface:** every ask host (the main window, a note window, Settings ▸ MCP).
- **What I saw:** I answered the Home-wing ask with Esc (Don't allow). The client raised it again, and the sheet appeared
  with no press of mine (`28b-clean-before-crop.png` → `28c-clean-after-ask-crop.png`). Second proof: I answered the
  "Fixture 0006" note ask Once from the in-note mark. When that client re-asked, the sheet popped up unpressed over the
  BOOKCASE (`67-crop.png`). This breaks arrival X ("asks never present themselves"), R-13nb-23's etiquette, and lesson
  7's own promise, "nothing pops up and nothing interrupts you".
- **Mechanism (traced):** `MCPAskSheet.swift:131-139`. The sheet's item binding reads the host's `askID` through
  `door.ask(id)`. Every answer removes the ask from the queue, including Esc, which is Don't allow's `.cancelAction`
  (`:95-96`). So the sheet closes because its GETTER turns nil, and the setter at `:136`, which alone clears `askID`, never
  runs. The host's state keeps the answered id: `RootView.swift:84/392` `mcpAskSheetID`, `NoteWindowView.swift:155`, and
  `MCPPane.swift:199` `answering`. `MCPAsk.id` is deterministic (client␟kind␟scope␟rung, `MCPWriteSupport.swift:64-66`),
  so an identical ask arriving later makes the getter non-nil and the sheet presents itself.
  - The live round (4) missed this because its later asks named different targets.
- **Red-on-old pin:** present an ask through the modifier's binding in a hosted harness, answer it through
  `door.answer`, re-enqueue an equal `MCPAsk`, and assert the item stays nil (red on the current tree).
- **Fix size:** small code — clear the host's id when the sheet disappears or its ask leaves.

**2 · Approve… defaults to a standing ALWAYS read on a book she never chose — flow (T-3 + T-4, worse together).**
- **Surface:** the connection request's Approve… sheet ("Grant access — ux-walk").
- **What I saw:** the sheet opens pre-filled with A book · the most recently edited book (here "Fixture book 011 — the
  kitchen in winter", touched by the fixture) · Read · **Always**. The confirm reads "Grant read in “Fixture book 011 —
  the kitchen in winter” always, including to future entries".
  - So one Return on a first-time approval hands a new client a standing grant on a place she never picked.
  - There is still no road to approve without sharing something (T-3). The same pre-pick happened on claude-code's
    re-approval.
- **Captures:** `19-approve-uxwalk.png`, `11-crop.png`.
- **Fix size:** design — an approve-only road, or no pre-picked place and Once as the approval sheet's default.

**3 · The bulk Share door is hidden behind an unlabeled chevron, and the guide tells users to look for it there — hard to find (T-1).**
- **What I saw (the walker's capture, judged by me):** at the default 1380-pt window, three selected notes collapse the
  bulk bar's doors to bare chevrons, and the selection panel's line is cut off ("3 notes selected — the Tag, Untag and
  Dele…") (`46-walker-bulkbar-crop.png`, from `walk/w6-bulkbar-with-client-w0.png`).
  - Lesson 5 says "⌘-click several notes in the Library and the controls at the top of the list offer Share 3 notes with
    AI…". At this width nothing on screen says Share.
- **Fix size:** chrome — the doors keep their words, the panel wraps; or design if the row needs a different home.

**4 · A client row's "Revoke" shuts the client out and drops every grant in one press, with no confirm — flow, copy.**
- **What I saw:** claude-code's row read "3 shared places". One press of Revoke left it "denied", with every grant gone.
- The client row and each grant row use the same word, "Revoke", but the reach differs completely.
- Approve… afterwards restores one grant, not the three.
- **Captures:** `05-mcp-pane-top-study.png`, `07-zero-clients-pane-*.png`.
- **Fix size:** copy + chrome — a distinct verb ("Deny…" / "Disconnect…") and a confirm naming the N places it takes back.

**5 · T-17's face: the book popover's Revoke does not say it takes back the WING — copy.**
- **What I saw:** in one popover, claude-code's row reads "through the Home wing grant · Change… · Revoke" and ux-walk's
  own book grant reads "Change… · Revoke". The two presses look identical but differ by a whole wing
  (`71-crop.png`, dark Terminal).
- The why line names the wing; the button does not, and the eye goes to the button.
- I am judging the face only — the design is ruled.
- **Fix size:** copy — "Revoke the Home wing grant…" (or a confirm naming the wing), only on a wider-grant row.

**6 · The one-wing note (her new words today) is shown nowhere — copy without a surface.**
- **What I saw:** with one wing, ⌘L does nothing and says nothing (`01-foot.png`). View ▸ Switch Wing… is grey with no
  visible note (`03-view-menu-crop.png`). ⌘K "switch wing" lists no command, only a guide passage (`02-crop.png`).
- **Mechanism:** the note is declared only at `CapabilityRegistry.swift:2326`. The menu button is `.disabled` at
  `EditorCommands.swift:477-479`, and no code consumes `.switchWing`'s `unavailableNote`. A grey macOS menu item shows no
  help.
- AppSpec §12: "A door that did nothing speaks a refusal."
- **Fix size:** chrome — ⌘L with one wing speaks the note as a refusal (and/or the palette lists the act, grey, with it).

**7 · The shared icon reads as a faint speckle at row size, worst in Terminal — looks (ledger row 5's watch item: confirmed).**
- **What I saw:** at the Bookcase row size the dotted-triangle glyph is about a third of the title's cap height, with a
  hairline stroke.
  - In Study it is findable but faint (`21-crop.png`).
  - In Terminal's bold mono it reads as dust beside the name (`66-crop.png`), and in dark Terminal as a grey-green speck
    (`70-crop.png`).
  - The pending `questionmark.bubble` beside it reads clearly in every voice, so legibility is the shared glyph's size
    and weight, not the pick.
- **Fix size:** chrome — scale the glyph to the row's cap height and weight, per voice.

**8 · T-15: the "ask was let go" line lands at the top of the pane, inside the server card, clipped under the header — looks/flow.**
- **What I saw:** I pressed Answer… on Waiting's only row after deleting its note. The Waiting section vanished, the page
  shifted, and the line "“a letter” is gone, so ux-walk's ask was let go." appeared at the very top edge of the scroll
  area, inside the server status card, with the card's top cut off (`51-gone-line-pressed.png`).
- It was visible this time only because the page shifted; the walker saw it entirely off-screen.
- It reads as server status, not as the answer to her press.
- **Fix size:** chrome — render the caption where the pressed row was (Waiting's own foot).

**9 · The grant sheet's confirm does not read as a button — looks.**
- **What I saw:** the confirm is a long accent-coloured sentence, right-aligned, often wrapping to two lines, beside a
  plain "Cancel" (`13-sheet-sherlock17-picked.png`, `19-approve-uxwalk.png`, `33-crop.png`).
- The ask sheet beside it uses a filled default button ("Once"), so the two sheets teach opposite things.
- **Fix size:** chrome — give the confirm a bezel/fill (her sentence stays the label).

**10 · Shared with AI lists one place once per grant, shadowed grants included, and "N shared places" counts grants — looks/copy.**
- **What I saw (store state from earlier walks):** "o ladrão de raios · book" appeared five times — three for
  claude-code (edit · always, read and suggest · always, read · always) and one each for u3-walk and u2-walk.
  claude-code's row said "3 shared places" for that one book (AX dump at the walk's start; `06-mcp-pane-u1.png`,
  `06-mcp-pane-u2.png`).
- A real user reaches this through the client row's additive Change….
- **Fix size:** design — fold a client's grants per place under the widest, or say "3 grants".

**11 · System blue where the voice's accent belongs — looks (T-7, wider than recorded).**
- **Where:** the window-hosted grant sheet's radios and segments (`33-crop.png`), every ask sheet's filled "Once"
  (`23-crop.png`, `27-crop.png`, `36-crop.png`), and the popovers' Change…/Revoke links, even in dark Terminal
  (`71-crop.png`).
- The Settings-hosted grant sheet draws the voice's slate accent (`19-approve-uxwalk.png`).
- **Fix size:** chrome (the tint).

**12 · The in-note popover hangs off the window's edge, and the app behind shows through it — looks (T-5, T-14).**
- **What I saw:** the indicator sits at the window's far right edge, so its popover centres there and hangs half past the
  window. The translucent material then takes the colour of whatever is behind — a pink browser toolbar in
  `35-crop2.png`.
- The Private lock in the same spot is faint grey, about 600 pt from the title (`74-walker-lock-crop.png`, the walker's
  capture).
- **Fix size:** chrome — anchor the popover to open leftward / an opaque background; a firmer lock tint.

**13 · Activity speaks raw tool ids — copy.**
- **What I saw:** "ux-walk was refused read_note on “a letter”", "… create_note on “Home” (3 times)", and "… show_in_app
  on …" sit beside natural rows like "claude-code read “Fixture 0006 …”" (`64-terminal-pane-2.png`).
- **Fix size:** copy — "was refused reading “a letter”", "was refused making a note in Home".

**14 · The ask sheet's write-new line overpromises for a book — copy.**
- **What I saw:** a BOOK ask says "If you allow it, it can also make new notes, apply tags and build books."
  (`23-crop.png`). `create_book` is wing-scope only (`MCPToolCatalog.swift`, its `scopes: [.wing]`), so "build books"
  can't be true of a book grant.
- The line is the generic rung blurb (`MCPPaneCopy.swift:508`).
- **Fix size:** copy — scope-aware blurb, or drop "build books" on a book ask.

**15 · Receipt rough edges — copy/looks.**
- **T-11 confirmed:** the allow receipt says "read **in** “Fixture 0006 …”" (`37-foot.png`), where the grant confirm says
  "Grant read **on** “…”" (`33-crop.png`).
- **T-13 confirmed:** ⌥⌘A's receipt still carried Change… · Revoke › at about 4 s and was gone by about 10 s
  (`39b-receipt-4s-foot.png`, `39c-receipt-10s-foot.png`).
- **The wing-move line runs into the bar's hint** with no separator: "…it left 1 book · ⌥⌘Z undoes Open › ⌘j today ·
  ⌘n new note" (`72-foot.png`, dark Terminal). The single move also names no note ("moved a note") — P-13nc-U6-7's
  fallback, so Open › is the only way to learn which note.
- **Fix size:** copy + chrome (a separator before the hint).

**16 · The sourced picker's empty white box and a doubled shelf word — looks.**
- **What I saw:** after typing "sherl" the book picker shows three rows over about 400 pt of empty white, and the popover
  hangs past the Settings window's bottom edge onto the main window (`12-crop.png`). This is D-W1's recorded trade, seen
  in use.
- The Welcome sherlock row says "Welcome" twice: its context line "Welcome · 13 notes · owned · …" and its right-side
  distinguisher "Welcome".
- **Fix size:** chrome — shrink once rows land (or cap the popover inside its window); suppress a distinguisher that
  repeats the context line.

**17 · The guide chapter — copy (the chapter reads well overall; these are the rough spots).**
- **Missing titles in Read:** the lessons run on without their titles, so lesson 6's recipes start abruptly after "…one
  Revoke covers them all." Pointers like lesson 3's "(the next lesson)" and lesson 1's "The last lesson in this chapter"
  aim at untitled stretches (`63-c6.png`, `62-c2.png`). This is the standing Read idiom, but this chapter leans on
  cross-references.
- **Lesson 1:** "way in" twice (the walker's note, confirmed on screen).
- **Lesson 4:** "An entry ⌘J made keeps asking…" reads oddly ("An entry made with ⌘J…").
- **Lesson 5:** promises "Share 3 notes with AI…" at the top of the list (finding 3).
- **Lesson 7:** "nothing pops up" is false while finding 1 stands.
- The new lesson 6 reads well: concrete, ordered from narrowest to widest grant, and its while-connected register sits
  fine.

**18 · Smaller confirmations from the taste list.**
- **T-2:** "MCP Settings…" sits above "Settings…" (AX read of the app menu).
- **T-16:** Terminal truncates the pane description to "…and how to set up any…" (`64-terminal-pane-top.png`).

## CLEAN-WALK LIST (walked and found right)

**Zero clients.**
- The Edit menu lists no Share item (AX).
- The Bookcase book menu has no "Share with AI…" (`09-crop.png`).
- Every Bookcase shared icon is gone (`08-crop.png`).

**The connection request and the grant sheet.**
- The request face reads "Connection request — ux-walk · First seen 7 seconds ago. No access until approved." (AX).
- ⌥⌘, with a request waiting lands on the pane (`18-…png`).
- The sectioned book picker: Recently edited → Starred → shelves in strip order, with context lines (`11-crop.png`).
- Typing filters; the three sherlocks are told apart by shelf ("Welcome") and made day ("made Oct 14/17, 2024") and never
  by an ordinal (`12-crop.png`).
- The picked one's confirm reads "Grant read in “the adventures of sherlock holmes” (made Oct 17, 2024) always,
  including to future entries" — VX-269's clause with the distinguisher (`13-…png`).
- The window-hosted sheet opens from the Library row menu with WHO, "Notes in Home", the note pre-filled and its scope
  line (`33-crop.png`).

**Doors.**
- The Library note row menu has "Share with AI…" in its own group (`32-crop.png`).
- The Bookcase book menu has "Share with AI…" after Book Settings… (`54-crop.png`).
- Book Settings' grant row reads "Shared with claude-code (read, suggest, write new and edit), ux-walk (read, suggest and
  write new) · Share…" beside the Private row (`55-crop.png`).

**Asks wait.**
- The pending bubble is legible on a Bookcase row, beside the masthead's wing word, on a Library row and in the note's
  context bar (`21-crop.png`, `48-crop.png`, `34b-crop.png`).
- A press opens THAT ask: the book ask, the Home-wing ask ("…in the Home wing, including notes added later") and the
  note ask (`23-crop.png`, `25-crop.png`, `36-crop.png`).
- Once → "Allowed ux-walk: read in “…” once."; the mark leaves and the shared icon stays (`37-*.png`).
- Waiting: the row, its age and Answer…; ⌥⌘, lands there (`47-…png`).

**The in-note indicator and ⌥⌘A.**
- The shared popover reads "Shared with · claude-code read, suggest, write new and edit · always · through the Home wing
  grant · Change… · Revoke" (`35-crop2.png`).
- ⌥⌘A in a note already reached gives "ux-walk already reaches this note (read)." (`38-foot.png`).
- ⌥⌘A with history gives "Shared “o museu” with ux-walk — read, once. Change… Revoke ›" (`39-…-foot.png`).

**⌘L and the masthead.**
- ⌘L opens on the current wing, with its foot "Home is the current wing · ⏎ switches · hold ⌘ and tap L to step · esc
  closes / Snippets is the one room every wing shares." (`26b-crop.png`).
- Held ⌘ + L + L + release switches and speaks "Now in “variorum”." (`56-crop.png`).
- Hovering the masthead word shows "Next wing: “Home” — or ⌘L to choose one", and a click cycles with "Now in Home."
  (`57-*.png`).

**The wing move.** "Undo claude-code's wing move" in the Edit menu; ⌥⌘Z → "Undid: claude-code's wing move"
(`72-foot.png`, `73-foot.png`).

**The guide.**
- Help ▸ Restore Tutorial…'s confirm reads plainly (`58-crop.png`).
- The guide re-seeded to 11 chapters with "AI & the MCP door" last and its seven lessons in order, "how to use it" sixth
  (`61-crop.png`).
- Every lesson was read on screen in Read; each checkable sentence matches what this walk saw.

**Settings ▸ MCP in Terminal.** The section titles "Shared with AI", "Open book" with "your daily Journal and anything
Private still ask every time", Activity's "all 148 ›", Connect a client's three segments, and the path and command all
render cleanly in light and dark (`64-*.png`, `65-*.png`, `68-*.png`). Terminal's lowercase idiom collides with nothing.

## NOT WALKABLE (said plainly)

**Could not stage.**
- **The bulk bar:** synthetic ⌘-clicks (cliclick and a held System Events ⌘) opened the note instead of extending the
  selection, three tries. T-1 was judged on the walker's capture, not re-walked.
- **⌥⌘A without history:** every approval mints a grant (T-3), so no approved client can lack history.
- **The empty Activity line:** this store holds 148 rows.
- **A wing ask's mark on a ⌘L switcher row:** my one attempt was pre-empted by finding 1's self-presenting sheet.

**Not pressed.**
- The receipt's Change… / Revoke ›, Open › and ⌥⌘O. The walker walked them; I judged the faces only.
- The setup menu's Copy buttons. The clipboard was left untouched; the faces were judged in Terminal.

**Not walked.**
- **Narrow width:** I did not shrink the main window. The Settings window is fixed at 720 pt, and the window sheet was
  judged at the default 1380 pt.
- **Study dark and the dark grant sheet.** Only Terminal dark was walked.
- **T-6, T-8/T-10, T-9, T-12** were not re-staged; the walker's captures stand for them.

## RESTORE EVIDENCE

- **Appearance:** set back to Follow system and Study in Settings ▸ General (AX read-back: Study 1, Follow system 1).
  `appearanceChoice` was absent at the start, so it was deleted afterwards (`defaults read` → not found).
- **Dev instance:** quit by identity (`tell application id "io.lduarte.Variorum.debug" to quit`); `pgrep -fl
  'Variorum.app/Contents/MacOS'` empty.
- **Dev store:** restored by `Tools/ScaleFixture/restore.sh …/scale-prestage-20261012T012517Z` → "Restored (verified)".
  All four files are `cmp`-identical to the prestage copy (8,671,232 · 32,768 · 803,432 · keys 120). Every client,
  grant, wing, move, re-seeded guide and voice change this walk made is gone.
- **Stage:** `Tools/stage release --who ux-walk` → "STAGE RELEASED"; status "STAGE FREE".
- **Never touched:** her real store, `/Applications/Variorum.app`, her `~/.claude.json` user-scope registration and the
  clipboard. No code changed; this record is the only file written.
