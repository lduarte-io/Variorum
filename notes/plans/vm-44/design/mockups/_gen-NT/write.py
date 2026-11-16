# VM-44 mockup — note-write.html: the Write surface end to end.
# REVISED after sitting 1 (plans/sitting-1-rulings.md): the bar, the quick row, the formatting setting, Return and backspace as the Mac,
# no place readout, no routine receipts, the book strip at the foot. The alternatives she ruled on are gone.
from base import *

M1 = mk(3) + mk(1, 'c')
DW = '<span class="dw">draft</span>'


def rest_blocks():
    return blk(B1, M1, under=True) + blk(B2) + blk(B3) + blk(B4)


def gap(h=16):
    return '<div style="height:%dpx;flex:none"></div>' % h


# ---------------------------------------------------------------- A. at rest
def A():
    dr('4 blocks', 'The fourth masthead chip: opens the blocks list.')
    a1 = phone(topbar(), page(rest_blocks(), mast_html=mast(), pad='10px'), over=fade(0, 70))
    a2 = phone(topbar(TITLE),
               page(blk('other name. In his eyes she eclipses and predominates the whole of her sex.') + blk(B3) + blk(B4) +
                    blk('I keep the notebook in the kitchen drawer now, between the string and the takeaway menus, which is where a thing goes when you mean to use it.', mk(2), under=False) +
                    blk('Most of what is in it I did not write. That is the point of it.') + blk(B2)), over=fade(0, 70))
    a3 = phone(topbar(), page(rest_blocks(), mast_html=mast(), pad='10px'), over=fade(82, 60) + bookstrip('3 of 8', 'Drafts'))
    a1d = phone(topbar(), page(rest_blocks(), mast_html=mast(), pad='10px'), over=fade(0, 70), dark=True)
    a4 = phone(topbar(right='<span class="tbtn s">Done</span>'),
               '<div class="pagep"><div class="mast"><div class="t-title ttl-field">On keeping a commonplace book%s</div>%s</div>'
               '<div class="in" style="padding-top:10px;opacity:.45"><div class="t-body">%s</div></div></div>' % (CARET, chips(*STD_CHIPS), blk(B1) + blk(B2)),
               over=kbd('done'))
    return section(
        'A — a note at rest', 'The prose is the screen. The title has its own row and wraps; the note’s facts are one row of chips; three tools stay in the bar. '
        'The app’s bottom bar (Starred · Bookcase · Library) never shows inside a note.',
        row(frame(a1, 'A1', 'She opens the note from the Library.',
                  'Bar: back · find · the note’s menu, each 44 pt. Title: Iowan 24, its own row, two lines if it needs them; a tap edits it in place (A4). '
                  'Chips, one row that scrolls sideways (32 pt capsules, 44 pt hit areas): the book, the tags, the date, the blocks list. Each opens its sheet in one tap (section B; the blocks list is section F). '
                  'The first block wears its marks at its foot: three takes, one comment.', 'ruled'),
            frame(a2, 'A2', 'She scrolls.',
                  'The title and chips scroll away with the page. A slim 48 pt bar stays, carrying the title small and nothing else: no “block 3 of 4” line. '
                  'Tapping the title opens the jumps (G2): top, end, a block, find. Tapping the status bar returns to the top, as everywhere on iOS.', 'ruled'),
            frame(a3, 'A3', 'The same note, opened from a book.',
                  'The book strip sits at the foot: where she is in the book (“3 of 8 · Drafts”) with ‹ and › to step in the book’s order. Its design is the books mockup’s (<code>a-book.html</code>); this frame shows its place. '
                  'It hides while the keyboard is up, when the keyboard bar has that edge.', 'ruled'),
            frame(a1d, 'A1 dark', 'The same screen in dark.', 'The room is black and the paper carries the hue (#0F1A16), as on the Mac. Marks keep the accent and the comment ink.'),
            frame(a4, 'A4', 'She taps the title.',
                  'The title becomes a field where it stands, at its own size, wrapping as she types; the prose dims. Return or Done saves the name. No alert, and no line afterwards. '
                  'A refusal is a sentence at the foot (D5), never a raw error.')))


# ---------------------------------------------------------------- B. what the chips open
def B():
    days = ''.join('<b>%s</b>' % d for d in 'SMTWTFS')
    cells = ''.join('<i class="o">%d</i>' % d for d in (28, 29, 30))
    for d in range(1, 32):
        cells += '<i class="%s">%d</i>' % ('on' if d == 25 else '', d)
    cal = ('<div class="cal"><div class="mo">July 2026<span><span>‹</span><span>›</span></span></div><div class="gr">%s%s</div></div>' % (days, cells))
    body = (cal + gap(12) + mrow(I_UP, 'Shift date a day earlier', cls='') + mrow(I_X, 'Clear date', cls='last') + '<div style="flex:1"></div>')
    b1 = phone(topbar(), page(rest_blocks(), mast_html=mast(), pad='10px'), over=dimmer() + sheet(300, 'Entry date', body, right='Set', left='<span class="tbtn">Cancel</span>'))

    bk = (sech('This note is in') + mrow(I_BOOK, 'Essays', det='8 notes', trail=ib(I_MORE, 'mut'), cls='last') +
          sech('Add to a book') + '<div class="srch">%s%s</div>' % (I_FIND, dr('Find a book', 'Placeholder in the books sheet’s search field.')) +
          ''.join(mrow(I_BOOK, n, det=d, trail=ib(I_PLUS, 'acc')) for n, d in
                  (('Blog drafts', '7 notes'), ('Reading notes', '6 notes'), ('Journal', '13 entries · daily'), ('Recipes', '5 notes'), ('Lisbon trip', '4 entries'), ('Running log', '4 entries'))) +
          '<div class="band" style="flex:1"></div>')
    b2 = phone(topbar(), page(rest_blocks(), mast_html=mast(), pad='10px'), over=dimmer() + sheet(150, 'Books', bk))

    tg = ('<div class="srch" style="margin-top:2px">%s%s</div>' % (I_TAG, dr('Add a tag, like life/goals', 'Placeholder in the tags sheet’s field.')) +
          sech('On this note', tight=True) + mrow(I_TAG, 'essay', trail=ib(I_X, 'mut')) + mrow(I_TAG, 'goals', trail=ib(I_X, 'mut'), cls='last') +
          sech('Suggestions') + ''.join(mrow(I_TAG, n, trail=ib(I_PLUS, 'acc')) for n in ('draft', 'idea', 'reading', 'source')) + '<div class="band" style="flex:1"></div>')
    b3 = phone(topbar(), page(rest_blocks(), mast_html=mast(), pad='10px'), over=dimmer() + sheet(250, 'Tags', tg))
    return section(
        'B — what each chip opens', 'Real sheets with a grabber and detents, one header for all of them (Iowan 20 title, Done at 64 × 44). A sheet opens only as tall as it needs. None of these acts leaves a line behind: the chip itself shows the change.',
        row(frame(b1, 'B1', 'She taps the date chip.',
                  'A calendar, not a typed “2026-08-09”. It opens on the note’s day (or, undated, on the day it was written). Day cells are 44 pt. '
                  'Set saves it; Cancel or a swipe down changes nothing. “Shift date a day earlier” and “Clear date” are the Mac’s two other date acts, as rows. The chip then reads the day in words (“Jul 25”).'),
            frame(b2, 'B2', 'She taps the book chip.',
                  'The books that hold the note, then the current wing’s books to add it to, with a find field. A row’s ＋ adds; a held book’s ⋯ carries Remove from this book, Move to chapter and Diverge for this book. '
                  'The ownership choice (copy or move) and Arrivals belong to the books mockups.'),
            frame(b3, 'B3', 'She taps the tags chip.',
                  'Type a path and Return applies it; a suggestion’s ＋ applies it; a worn tag’s ✕ removes it (a 44 pt target at the row’s end). Suggestions are the current wing’s tags.')))


# ---------------------------------------------------------------- C. writing: the bar, the quick row, the formatting strip
PRE = 'It was not that he felt any emotion akin to love for Irene Adler. All emotions, and that one particularly, were abhorrent to his cold, precise but admirably balanced mind. He was, I take it, the most perfect reasoning and '
POST = 'machine that the world has seen, but as a lover he would have placed himself in a false position.'
TAIL2 = 'other name. In his eyes she eclipses and predominates the whole of her sex.'


def typing(blocks, barhtml=None, dark=False, extra='', fadeh=96):
    return phone(topbar(TITLE), page(blocks, pad='14px'), over=fade(327, fadeh) + (barhtml if barhtml is not None else bar()) + extra + kbd(), dark=dark)


def C():
    mid = blk(TAIL2) + blk(PRE + 'observing' + CARET + ' ' + POST) + blk(B4)
    c1 = typing(mid)
    c1d = typing(mid, dark=True)
    c2 = typing(mid, qrow(undo=True, redo=False))
    items = [('Remove', I_CHEV), None,
             ('Name block…', I_NAME), ('Callout', I_CALLOUT), None,
             ('Merge with previous', I_MERGE), ('Merge with next', I_MERGE), ('Divide at the cursor', I_DIV), ('New block below', I_NEWB), None,
             ('History and lineage', I_HIST)]
    c3 = typing(mid, qrow(on=5), extra=menu(items, 'right:16px;bottom:389px;width:262px'))
    c4 = typing(mid, bar(receipt=rcpt(dr('Committed', 'The one line a deliberate act gets: said after Commit, beside the thumb.'), dr('Name…', 'Door on the commit line: opens the name field (C5).'))))
    namef = ('<div class="fbar" style="bottom:333px"><span class="namef"><span class="tx">first pass%s</span><span class="tbtn s" style="padding:0 14px">Save</span></span></div>' % CARET)
    c5 = typing(mid, namef)
    namefe = ('<div class="fbar" style="bottom:333px"><span class="namef"><span class="tx ph">%s</span><span class="tbtn s" style="padding:0 14px;color:var(--faint2)">Save</span></span></div>'
              % dr('Name this commit', 'Placeholder in the commit name field.'))
    c5e = typing(mid, namefe)

    stylemenu = menu([('Bold', '<b style="font:700 17px/1 var(--chrome)">B</b>'), ('Italic', '<i style="font:italic 500 18px/1 var(--prose)">I</i>'),
                      ('Strikethrough', '<s style="font:500 16px/1 var(--chrome)">S</s>'), ('Code', I_CODE), ('Link…', I_LINK)],
                     'right:120px;bottom:389px;width:232px')
    c6 = typing(mid, fmt_strip(False, on=1), extra=stylemenu)
    c7 = typing(mid, fmt_strip(True))

    def pick(label, det, demo, on, last=False):
        ck = '<span class="ckm">%s</span>' % (I_CHECK if on else '')
        return ('<div class="pickrow%s"><div class="mid"><div class="lab">%s</div><div class="det">%s</div><div class="demo">%s</div></div>%s</div>'
                % (' last' if last else '', label, det, demo, ck))
    demo7 = '<span class="gcap" style="gap:2px">%s</span>' % ''.join('<span class="gc">%s</span>' % c for c in FMT7)
    demo11 = '<span class="gcap">%s</span>' % ''.join('<span class="gc c">%s</span>' % c for c in FMT11)
    sbody = ('<div style="margin-top:-6px;padding:0 8px"><span class="tbtn">‹ Settings</span></div>' +
             sech(dr('Formatting bar', 'Settings ▸ Writing: the section that chooses the formatting strip’s shape.'), tight=True) +
             pick(dr('Seven big buttons', 'Setting choice: the default strip.'),
                  dr('Easier to tap. Less-used styles are in a menu.', 'One line under the default choice.'), demo7, True) +
             pick(dr('All eleven in one row', 'Setting choice: the compact strip.'),
                  dr('Everything is one tap. The buttons are smaller.', 'One line under the compact choice.'), demo11, False, last=True) +
             '<div class="band" style="flex:1"></div>')
    c8 = phone(topbar(), page(rest_blocks(), mast_html=mast(), pad='10px'), over=dimmer() + sheet(70, 'Writing', sbody))

    return section(
        'C — writing: the keyboard up',
        'Her ruling on the bar: the white strip goes; ONE glass capsule sits at the trailing edge, over the ragged end of the line. Nothing else rides above the keyboard, and ordinary acts say nothing '
        '(“i feel like it’ll feel too noisy”). Her idea for the ⋯: “when you click on the ... it could expand into common things like undo, redo, etc.”',
        row(frame(c1, 'C1', 'She taps into the prose. The capsule at rest.',
                  'Four 44 pt cells in a 48 pt capsule: Aa (the formatting strip) · ↵ (a new line inside this block; Return itself makes a new block) · takes for this block · ⋯. '
                  'The prose runs to the keyboard behind it and the last lines fade. No strip, no band.', 'ruled'),
            frame(c1d, 'C1 dark', 'The same, in dark.', 'The glass darkens with the room; glyphs stay in ink.'),
            frame(c2, 'C2', 'She taps ⋯. The capsule grows into the quick row.',
                  'In place, toward the leading edge: close · Undo · Redo · Comment · Commit · ⋯. Undo and Redo act on the last thing done in this note, typing or structure, and grey out when there is nothing (Redo, here). '
                  'Comment opens this block’s comments. Commit is a word because it has no glyph anyone knows. The last cell, set apart by a hairline, opens the full block menu (C3). '
                  'The row stays open until she closes it or types, so two undos are two taps.', 'ruled'),
            frame(c3, 'C3', 'She taps the row’s last cell: the full block menu.',
                  'Everything else for this block, nearest-first: History and lineage by the thumb; then the structure acts, with Merge with next beside Merge with previous; then the block’s name and callout; removal furthest, behind one more tap '
                  '(Remove › holds Archive block and Delete block…). Comment and Commit are not repeated here: they are one row below. In the blocks list, where there is no quick row, the same menu shows them (F1).', 'ruled'),
            frame(c4, 'C4', 'She taps Commit.',
                  'The take is committed at once, one commit per press. This is the one ordinary act that answers: a commit changes nothing she can see, and she pressed it on purpose to know it is kept. '
                  'The line sits beside her thumb, offers “Name…”, and leaves on its own in a few seconds. ' + DW, 'ruled'),
            frame(c5e, 'C5', 'She taps Name….',
                  'The capsule becomes a field where it sits, the keyboard already up. This answers her question (“how would the commit box show up and let you write in it?”): it is one line above the keyboard, nothing opens over the note. ' + DW),
            frame(c5, 'C5 typed', 'She types a name.',
                  'Save or Return names the commit she just made; it never makes a second one. A tap on the page puts the field away and the commit stays unnamed. It can be named later in History (takes-and-history, C3).'))
        + row(frame(c6, 'C6 · LK-3, the default', 'She taps Aa: seven big buttons.',
                    'The capsule becomes the formatting strip: close · style · heading · bullet · checkbox · outdent · indent, each 44 pt. The style cell opens bold, italic, strikethrough, code and link as menu rows (shown); '
                    'heading opens its levels. Close returns the four resting cells.', 'ruled'),
              frame(c7, 'C7 · LK-3, the other setting', 'The same tap with “All eleven in one row” chosen.',
                    'All eleven in one capsule, no menu: close · bold · italic · strikethrough · code · link · heading · bullet · checkbox · outdent · indent. Each cell is 31 pt wide and 44 tall. '
                    'Her words: “i’d do the eleven in one row but that wouldnt work for someone with poor vision”, so it is the choice, not the default.', 'ruled'),
              frame(c8, 'C8', 'Settings ▸ Writing: the row that chooses.',
                    'Two choices, each with a small picture of its strip and one line. The tick marks the default. All four lines are drafts. ' + DW, 'ruled')))


def NT():
    seam = 'seam'
    n0 = typing(blk(TAIL2, cls=seam) + blk(PRE + 'obser' + CARET + 'ving ' + POST, cls=seam) + blk(B4, cls=seam))
    na = typing(blk(TAIL2, cls=seam) + blk(PRE.rstrip(), cls=seam) + blk(CARET + 'observing ' + POST, cls=seam) + blk(B4, cls=seam))
    nb = typing(blk(TAIL2, cls=seam) + blk(PRE + 'obser<br>' + CARET + 'ving ' + POST, cls=seam) + blk(B4, cls=seam), bar(on=1))

    z0 = typing(blk(TAIL2, cls=seam) + blk(B3, cls=seam) + blk(CARET + B4, cls=seam))
    za = typing(blk(TAIL2, cls=seam) + blk(B3 + ' ' + CARET + B4, cls=seam))
    ze0 = typing(blk(TAIL2, cls=seam) + blk(B3, cls=seam) + '<div class="blk seam empty">%s</div>' % CARET + blk(B4, cls=seam))
    ze1 = typing(blk(TAIL2, cls=seam) + blk(B3 + CARET, cls=seam) + blk(B4, cls=seam))
    return (section(
        'NT-1 — Return makes a new block', 'Her ruling: “I think return should make a new block, as on the mac.” Drawn with the block seams on so the blocks show (the dotted lines are the app’s own seam face; at rest they are off).',
        row(frame(n0, 'before', 'Her caret is inside a word, mid-paragraph, and she presses Return.', 'One block of four. The caret sits in “obser|ving”.'),
            frame(na, 'NT-1', 'Return: the block divides.',
                  'It divides at the start of the word, so “observing” rides down whole. At a block’s end Return opens an empty block below; in an empty block it opens another. '
                  'It is the Mac’s rule through the shared <code>TypedReturn</code>, so the same typing makes the same blocks on both devices. Nothing is said: the page shows it, and Undo in the quick row takes it back.', 'ruled'),
            frame(nb, 'NT-1 · the newline key', 'The same caret, and she taps ↵ in the capsule instead.',
                  'A line break inside the block, exactly at the caret; it is still one block. This is the phone’s ⇧⏎. '
                  'The note’s own switch, “Newlines make blocks” in the note’s menu (E2), is the Mac’s chip: off, Return goes back to being a new line in this note.', 'ruled'))) +
        section(
            'NT-2 — backspace joins blocks, and removes an empty one', 'As on the Mac (accepted). Seams on.',
            row(frame(z0, 'before', 'Her caret is at the very start of the last paragraph and she presses backspace.', 'Two blocks with words in both, a seam between them.'),
                frame(za, 'NT-2', 'The two blocks become one.',
                      'Joined by the Mac’s own seam rule, with the caret where the break was. No line: a backspace is typing, and Undo in the quick row puts the seam back. '
                      'This is the shared <code>SeamCarvePlan</code>. (A merge chosen from the menu does say so, because she is not looking at the seam when she picks it: D4.)', 'ruled'),
                frame(ze0, 'before', 'Her caret is in an empty block and she presses backspace.', 'An empty block between two paragraphs.'),
                frame(ze1, 'NT-2 · empty', 'The empty block is gone.',
                      'The caret lands at the end of the block above. Nothing is said. An empty block is removed only when it has nothing unshown (no other take, no comment), the operation’s own check.', 'ruled'))))


# ---------------------------------------------------------------- D. the selection's acts, and the lines that do show
def D():
    selpre = ('It was not that he felt any emotion akin to love for Irene Adler. All emotions, and that one particularly, were abhorrent to his cold, precise but admirably balanced mind. '
              'He was, I take it, the most perfect reasoning and observing machine that the world has seen, ')
    selspan = 'but as a lover he would have placed himself in a false position.'
    em = ('<div class="editm" style="left:24px;top:262px"><span>Copy</span><span class="a">%s</span><span class="a">%s</span><span class="a">%s</span><span>›</span></div>'
          % (dr('Extract', 'Short name in the selection’s menu (the Mac: Extract Selection).'), dr('Make block', 'Short name in the selection’s menu (the Mac: Make Block from Selection).'),
             dr('New take', 'Short name in the selection’s menu (the Mac: Move Selection into a New Take).')))
    d2 = phone(topbar(TITLE), page(blk(TAIL2) + blk(selpre + '<span class="sel">' + selspan + '</span>') + blk(B4), pad='14px'),
               over=fade() + em + bar() + kbd())
    d3 = phone(topbar(TITLE), page(blk(TAIL2, cls='seam') + blk(selpre.rstrip(), cls='seam') + blk(CARET + selspan, cls='seam') + blk(B4, cls='seam'), pad='14px'),
               over=fade() + bar() + kbd())
    d4 = phone(topbar(TITLE), page(blk(TAIL2) + blk(B3 + ' ' + CARET + B4), pad='14px'),
               over=fade() + bar(receipt=rcpt(dr('Merged', 'The short line after a merge, with Undo (the Mac’s line is longer and names ⌥⌘Z).'))) + kbd())
    d4b = phone(topbar(TITLE), page(blk(TAIL2) + blk(B3) + blk('I keep the notebook in the kitchen drawer now, between the string and the takeaway menus, which is where a thing goes when you mean to use it.') +
                                    blk('Most of what is in it I did not write. That is the point of it.') + blk(B2)),
                over=fade(0, 110) + foot_rcpt(dr('Block deleted', 'The short line after a block is deleted, with Undo. Its twins: “Block archived”, “Note archived”, “Take deleted”.')))
    d5 = phone(topbar(TITLE), page(blk(CARET + B1, M1, under=True) + blk(B2) + blk(B3), pad='14px'),
               over=fade(327, 150) + '<div class="fbar" style="bottom:389px;justify-content:flex-start">%s</div>' %
               rcpt('This is the note’s first block — there’s nothing above to merge with.', '', ref=True, x=True) + bar() + kbd())

    acts = [
        ('Undo · Redo', 'Undo · Redo', 'quick row · the note’s menu', 'text undo, and structural undo / redo', 'Nothing said; the page shows it.'),
        ('Comment', 'Comments…', 'quick row · list ⋯ · the page mark', 'addBlockComment …', 'Nothing said.'),
        ('Commit', 'Commit Take', 'quick row · list ⋯', 'commit', '“Committed · Name…” (C4): the one act that answers.'),
        ('History and lineage', 'History · Lineage', 'full menu · list ⋯ · take card', '—', 'One sheet, two tabs (takes-and-history, section C).'),
        ('Callout', 'Callout', 'full menu · list ⋯', 'updateBlockPresentation', 'Opens the chooser (comments-and-callouts, section C). Nothing said.'),
        ('Name block…', 'Name Block…', 'full menu · list ⋯', 'setBlockName', 'A field in the blocks list row. Nothing said.'),
        ('New block below', 'New Block Below', 'full menu · list ⋯', 'newBlock', 'Nothing said (her example of too noisy).'),
        ('Divide at the cursor', 'Divide Block at Cursor', 'full menu only (needs a caret)', 'divide · keep-on-top when fanned', 'Nothing said. One default on a fanned block; no preset sheet.'),
        ('Merge with previous · Merge with next', 'Merge Blocks', 'full menu · list ⋯ · list bulk bar', 'merge · carry-all when fanned', '“Merged · Undo” (D4). A block leaves the page.'),
        ('Split this block at its newlines', 'Split This Block at Its Newlines', 'full menu · list ⋯, only when the block holds a newline', 'splitBlockAtNewlines', 'Nothing said.'),
        ('Move up · down · to top · to end', '(Blocks mode)', 'list ⋯ (under Move ›) · drag in the list', 'reorder', 'Nothing said. Never offered above the keyboard.'),
        ('Extract', 'Extract Selection', 'the selection’s menu', 'extract', 'Nothing said. Only at a block’s start or end; elsewhere the refusal names Make block.'),
        ('Make block', 'Make Block from Selection', 'the selection’s menu', 'the shared StructuralGesturePlanner', 'Nothing said.'),
        ('New take', 'Move Selection into a New Take', 'the selection’s menu', 'moveSpanToNewTake', 'Nothing said; the takes mark appears. New on the phone (W-185).'),
        ('Archive block', 'Archive Block', 'full menu (under Remove ›) · list ⋯ · list swipe', 'archive (the block’s archived_at)', '“Block archived · Undo”.'),
        ('Delete block…', 'Delete Block', 'full menu (under Remove ›) · list ⋯ · list swipe · list bulk bar', 'deleteBlock', '“Block deleted · Undo” (D4b).'),
    ]
    tbl = ('<h3>Every block act, its doors, and whether it says anything</h3><p class="note">One definition, three doors: the quick row and full menu above the keyboard, the blocks list’s row menu, the selection’s menu. '
           'Names are the Mac’s words in sentence case; the Mac column is the capability registry’s verb. The last column is her receipts ruling applied row by row: a line with Undo only when something leaves the page, and for refusals.</p>'
           '<table class="plain"><tr><th>Phone name</th><th>The Mac’s verb</th><th>Doors</th><th>Operation (AppSpec §9)</th><th>What is said afterwards</th></tr>%s</table>' %
           ''.join('<tr>%s</tr>' % ''.join('<td>%s</td>' % c for c in a) for a in acts))
    return section(
        'D — the selection’s acts, and the only lines that show',
        'Her ruling: “Only removals and refusals.” A short line with Undo when something leaves the page (a deleted block, a merge, an archive), and a refusal when the app cannot do what she asked. Everything else is silent. '
        'The line sits left of the capsule while the keyboard is up, and at the foot of the screen when it is down.',
        row(frame(d2, 'D2', 'She selects the end of a paragraph.',
                  'The selection’s own menu carries the three span acts by short names: Extract (the span leaves to a block of its own), Make block (a middle span), New take (the span moves into a new take of this block). '
                  'The next page (›) holds the system’s acts. ' + DW),
            frame(d3, 'D3', 'She taps Extract.', 'The span is its own block below (seams on to show it), the caret at its start. Nothing is said: nothing left the page. Undo is two taps away in the quick row.', 'ruled'),
            frame(d4, 'D4', 'She taps Merge with previous in the full menu.',
                  'Two blocks became one, so a block left the page: one short line, left of the capsule, with Undo. It leaves on its own in a few seconds.', 'ruled'),
            frame(d4b, 'D4b', 'Keyboard down: she deleted a block from the blocks list.',
                  'The same line at the foot of the screen: one 44 pt glass capsule, Undo at 60 × 44. It never enters the masthead and never moves the prose. The deleted block is in this note’s tray (F3) either way.', 'ruled'),
            frame(d5, 'D5 · refusal', 'She asks to merge the first block with a previous one.',
                  'A refusal is a sentence in words (the build’s own), in ink rather than muted, with ✕. It stays until she dismisses it or acts again. No raw error text ever reaches this line (W-013).', 'new'))) + tbl


# ---------------------------------------------------------------- E. the note's menu
def E():
    behind = topbar() + page(rest_blocks(), mast_html=mast(), pad='10px')
    seal_det = dr('Stops edits until you unseal it.', 'One line under Seal in the note’s menu.')
    ver_det = dr('Keeps the whole note as it is now.', 'One line under Save a version in the note’s menu.')
    g1 = (mrow(I_UNDO, 'Undo divide') + mrow(I_REDO, 'Redo', cls='off last') + gap() +
          mrow(I_STAR, 'Star') + mrow(I_SEAL, 'Seal', det=seal_det) + mrow(I_VERS, 'Save a version', det=ver_det) +
          mrow(I_HIST, 'Versions', val='2', chev=True, cls='last') + gap() +
          mrow(I_LIST, 'Blocks', val='4', chev=True) + mrow(I_TRAY, 'This note’s tray', val='2', chev=True) + mrow(I_LINK, 'References', val='1', chev=True, cls='last') + gap() +
          mrow(I_BOOK, 'Add to a book…') + mrow(I_WING, 'Move to wing…') + mrow(I_WING, 'Copy to wing…', cls='last') + '<div class="band" style="flex:1"></div>')
    meta = '1,204 words · 4 blocks · edited today at 9:12 AM'
    e1 = phone(behind, over=dimmer() + sheet(70, 'Note', g1, meta=meta))
    g2 = (mrow(I_WING, 'Copy to wing…', cls='last') + gap() +
          mrow(I_DUP, 'Duplicate with tags') + mrow(I_DUP, 'Duplicate without tags') + mrow(I_ARCH, 'Archive', cls='last') + gap() +
          mrow(I_COPY, dr('Copy text', 'Row in the note’s menu: copies the words on screen.')) + mrow(I_SHARE, 'Export note…', cls='last') + gap() +
          mrow(I_CAL, 'Date', val='Jul 25', chev=True) + mrow(I_UP, 'Shift date a day earlier', cls='last') + gap() +
          mrow(I_NL, 'Newlines make blocks', trail=tog(True)) + mrow(I_NEWB, 'Make every newline a block', cls='last') + gap() +
          mrow(I_COUNT, 'Word target', val='1,204 of 1,500', chev=True, cls='last') + gap() +
          mrow(I_TRASH, 'Delete note…', cls='danger last') + '<div style="flex:1"></div>')
    e2 = phone(behind, over=dimmer() + sheet(70, 'Note', g2, meta=meta))

    wt = ('<div class="expl">A target shows progress beside the word counts. It is a measure, never a wall — nothing refuses at the boundary.</div>'
          '<div style="display:flex;gap:8px;padding:0 16px 12px"><span class="field" style="color:var(--ink)">1500%s</span><span class="btn fill">Clear</span><span class="btn solid">Set</span></div>'
          '<div style="margin:0 20px;height:8px;border-radius:4px;background:var(--wash)"><div style="width:80%%;height:8px;border-radius:4px;background:var(--accent)"></div></div>'
          '<div class="t-meta" style="padding:8px 20px 0">1,204 of 1,500 words</div><div style="flex:1"></div>' % CARET)
    e3 = phone(behind, over=dimmer() + sheet(330, 'Word target — this note', wt, right='Done') +
               '<div class="kb-abs" style="z-index:9"><div class="kbd" style="height:290px"><div style="display:grid;grid-template-columns:repeat(3,1fr);gap:7px;padding:6px 4px">%s</div></div></div>' %
               ''.join('<div class="k" style="width:auto;height:52px;line-height:52px;font-size:25px%s">%s</div>' % (';background:transparent;box-shadow:none' if c in ('', '⌫') else '', c)
                       for c in ('1', '2', '3', '4', '5', '6', '7', '8', '9', '', '0', '⌫')))

    def choice(t, d, last=False):
        return ('<div class="pickrow%s"><div class="mid"><div class="lab" style="font-weight:600">%s</div><div class="det">%s</div></div><span class="chev" style="width:28px;color:var(--faint2);margin-top:10px">%s</span></div>'
                % (' last' if last else '', t, d, I_CHEV.replace('<svg', '<svg width="16" height="16"')))
    ex = (choice(dr('Just the text', 'Export choice (the same line as export-and-share, frame 3).'), dr('The note as it reads now.', 'One line under “Just the text”.')) +
          choice(dr('With takes and tags', 'Export choice (the same line as export-and-share, frame 3).'), dr('Every take, the title and the tags.', 'One line under “With takes and tags”.'), last=True) +
          '<div class="band" style="flex:1"></div>')
    e4 = phone(behind, over=dimmer() + sheet(560, 'Export note', ex, right='Cancel'))

    wings = ["Home", "Work", "Fiction", "Research", "Family", "Health", "Side project", "Poetry", "Taxes 2025"]
    here = dr('It’s here now', 'Marks the wing a note is already in, in the Move to wing list.')
    wr = ''.join(mrow(I_WING, w, val=here if i == 0 else '', cls=('off' if i == 0 else '') + (' last' if i == 8 else '')) for i, w in enumerate(wings))
    e5 = phone(behind, over=dimmer() + sheet(250, 'Move to wing', wr, right='Cancel'))

    e6 = phone(behind, over=dimmer() + sheet(70, 'Note', mrow(I_UNDO, 'Undo divide') + mrow(I_REDO, 'Redo', cls='off last') + gap() +
                                             mrow(I_STAR, 'Star') + mrow(I_SEAL, 'Seal', det='Stops edits until you unseal it.') +
                                             mrow(I_VERS, 'Save a version', det='Keeps the whole note as it is now.') + mrow(I_HIST, 'Versions', val='2', chev=True, cls='last') + gap() +
                                             mrow(I_LIST, 'Blocks', val='4', chev=True) + mrow(I_TRAY, 'This note’s tray', val='2', chev=True) + '<div class="band" style="flex:1"></div>',
                                             meta='1,204 words · 4 blocks'), cls='xxl')
    g7 = (mrow(I_STAR, 'Star') + mrow(I_SEAL, 'Unseal', det=dr('Sealed notes can’t be edited.', 'One line under Unseal on a sealed note.')) +
          mrow(I_EYE, dr('Private', 'Read-only row on a note marked Private on a Mac.'), det=dr('Not shared with AI. Set on your Mac.', 'One line under the Private row.'), cls='off last') + gap() +
          mrow(I_VERS, 'Save a version', det='Keeps the whole note as it is now.', cls='off') + mrow(I_HIST, 'Versions', val='1', chev=True, cls='last') + '<div class="band" style="flex:1"></div>')
    sealed = (chip(I_SEAL, 'Sealed'), chip(I_EYE, 'Private')) + STD_CHIPS[:2]
    e7 = phone(topbar() + page(rest_blocks(), mast_html=mast(cs=sealed), pad='10px'), over=dimmer() + sheet(380, 'Note', g7, meta='312 words · 3 blocks · sealed Oct 2'))
    return section(
        'E — the note’s menu', 'The bar’s ⋯. One sheet holds every act on the note itself, in the Mac’s words, so the masthead can stay three facts and two tools. It opens at the large detent and scrolls. '
        'There is no Read mode for a single note in v1 (her ruling), so no mode row is drawn anywhere.',
        row(frame(e1, 'E1', 'She taps ⋯ in the bar.',
                  'Under the title, the note’s facts in one readable line: words, blocks, when it was last edited. '
                  'Then: Undo and Redo, each naming its entry (“Undo divide”), greyed when there is nothing (the same pair as the quick row, for when the keyboard is down); Star; Seal, which becomes Unseal on a sealed note (E7); Save a version; Versions. '
                  'Then the doors to the note’s other surfaces: Blocks, This note’s tray, References. Then Add to a book, Move to wing, Copy to wing. ' + DW),
            frame(e2, 'E2', 'She scrolls the menu.',
                  'Duplicate with tags · Duplicate without tags · Archive (the note leaves the list, so it answers with the Mac’s “Note archived” line and Undo). '
                  'Copy text (the words on screen) · Export note… (asks which file, E4). Date (opens B1) · Shift date a day earlier. '
                  'Newlines make blocks (the Mac’s per-note switch) · Make every newline a block. Word target (E3). Delete note… last, in the alarm ink, after a gap; it asks first, as today.'),
            frame(e3, 'E3', 'She taps Word target.',
                  'The Mac’s sentence and its two acts, Clear and Set, with a number pad. The facts line in E1 then reads “1,204 of 1,500 words”. A target never refuses anything.'),
            frame(e4, 'E4', 'She taps Export note….',
                  'Her ruling: “Yes, ask which file.” A short sheet with the two files; picking one opens the system share sheet. The whole road is drawn in <code>export-and-share.html</code>. ' + DW, 'ruled'),
            frame(e5, 'E5 · nine wings', 'She taps Move to wing….',
                  'Her nine wings as 52 pt rows; the wing the note is in is marked and cannot be picked. Choosing one asks first with the Mac’s confirm, which names the books the note leaves behind; then the app follows the note to its wing (the Mac’s rule). '
                  'Copy to wing… is the same list. ' + DW),
            frame(e6, 'E1 at the largest text size', 'The same menu at xxxLarge.',
                  'Row labels are 23 pt and rows grow to 64 pt; the facts line wraps to what fits; detail lines wrap rather than truncate. Chrome stops growing here; her prose behind keeps scaling through the accessibility sizes.', 'new'),
            frame(e7, 'E7 · sealed, Private', 'A sealed note that was marked Private on her Mac.',
                  'Seal has become Unseal. The Private row and the eye chip show only because this note carries the mark and the library’s AI-marks switch is on (her ruling: “users who don’t have the mac app shouldn’t see it”); '
                  'a library with no marks never draws either. The row is read here, not changed: Private is set on the Mac in v1. ' + DW, 'ruled')))


# ---------------------------------------------------------------- F. blocks, reorder, the tray
def F():
    behind = topbar() + page(rest_blocks(), mast_html=mast(), pad='10px')

    def brow(n, text, marks='', acc=None, hd=False, cls='', lead=''):
        m = '<div style="margin-top:2px;display:flex;gap:10px">%s</div>' % marks if marks else ''
        return ('<div class="brow2 %s">%s<span class="n">%s</span><div class="mid"><div class="t-prev clamp2%s" style="color:var(--ink)">%s</div>%s</div><span class="acc">%s</span></div>'
                % (cls, lead, n, ' hd' if hd else '', text, m, acc if acc is not None else ib(I_MORE, 'mut')))

    rows = (brow('1', B1, mk(3) + mk(1, 'c')) + brow('2', B2) + brow('3', B3) + brow('4', B4) + '<div class="band" style="flex:1"></div>')
    flat = [('Commit take', I_COMMIT), ('History and lineage', I_HIST), None, ('Comments', I_CMT), ('Callout', I_CALLOUT), ('Name block…', I_NAME), None,
            ('New block below', I_NEWB), ('Merge with previous', I_MERGE), ('Merge with next', I_MERGE), None, ('Move', I_CHEV), None,
            ('Archive block', I_ARCH), ('Delete block…', I_TRASH, 'al')]
    f1 = phone(behind, over=dimmer() + sheet(70, 'Blocks', rows, left='<span class="tbtn">Select</span>'))
    f1m = phone(behind, over=dimmer() + sheet(70, 'Blocks', rows, left='<span class="tbtn">Select</span>') + menu(flat, 'right:12px;top:262px;width:270px'))

    pk = lambda on: '<span class="pk%s">%s</span>' % (' on' if on else '', I_CHECK if on else '')
    grip = ib(I_GRIP, 'mut')
    rows2 = (brow('1', B1, mk(3) + mk(1, 'c'), acc=grip, lead=pk(False)) + brow('2', B2, acc=grip, lead=pk(True)) + '<div class="dropline"></div>' +
             brow('4', B4, acc=grip, lead=pk(False), cls='lift') + brow('3', B3, acc=grip, lead=pk(True)) + '<div class="band" style="flex:1"></div>' +
             '<div class="bulk"><span class="tbtn">Merge</span><span class="tbtn">Split at newlines</span><span class="tbtn al">Delete…</span></div><div style="height:30px;background:var(--room)"></div>')
    f2 = phone(behind, over=dimmer() + sheet(70, dr('2 selected', 'The blocks list’s title while rows are picked.'), rows2, right='Done'))

    seg = lambda a, b, on: '<div class="seg"><span class="%s">%s</span><span class="%s">%s</span></div>' % ('on' if on == 0 else '', a, 'on' if on == 1 else '', b)
    fch = lambda on: '<div class="fchips">%s</div>' % ''.join('<span class="chip%s">%s</span>' % (' on' if i == on else '', t) for i, t in enumerate(('all', 'blocks', 'takes')))

    def trow(text, meta, last=False):
        return ('<div class="brow2" style="padding-left:20px"><div class="mid"><div class="t-prev clamp2" style="color:var(--ink)">%s</div><div class="t-meta" style="margin-top:2px">%s</div></div>'
                '<span class="acc"><span class="tbtn sm s">Put back</span>%s</span></div>' % (text, meta, ib(I_MORE, 'mut')))
    tr = (seg('Leaving · 2', 'Archived · 0', 0) + fch(0) +
          '<div class="expl">Everything this note has on the 30-day clock. Put back keeps a row; Delete Now ends its days early.</div>' +
          trow('Ryder passed his tongue over his parched lips. “I will tell you it just as it happened, sir,” said he.', 'block · deleted Nov 7 · 25 days left') +
          trow('I keep a second notebook for things I only half believe.', 'take · in block 1 · deleted Nov 10 · 28 days left') + '<div class="band" style="flex:1"></div>')
    f3 = phone(behind, over=dimmer() + sheet(70, 'This note’s tray', tr))
    te = (seg('Leaving · 2', 'Archived · 0', 1) + fch(0) +
          '<div class="expl">Kept out of this note, with no clock. Archiving a block keeps it here with no countdown.</div>'
          '<div class="band" style="flex:1;display:flex;align-items:center;justify-content:center;padding:0 40px 120px;text-align:center"><span class="t-ctl2" style="color:var(--muted2)">Nothing archived from this note.</span></div>')
    f4 = phone(behind, over=dimmer() + sheet(70, 'This note’s tray', te))
    return section(
        'F — the blocks list, reordering, and this note’s tray',
        'The blocks list is the phone’s Blocks workbench and the block door for when the keyboard is down: every row is a jump target and carries the block menu. The tray gets its own door and its own sheet.',
        row(frame(f1, 'F1', 'She taps the “4 blocks” chip (or Blocks in the note’s menu).',
                  'Her words at Iowan 15, two lines a row, rows at least 64 pt. A tap on a row jumps to that block and closes the sheet. A row shows its takes and comments counts. '
                  'Each row’s ⋯ is a 44 pt target. Swiping a row left offers Archive and Delete…. Select enters F2.'),
            frame(f1m, 'F1 · the menu', 'She taps a row’s ⋯.',
                  'The block menu, whole and flat because there is room and no quick row here: Commit take and Comments lead it; nothing is folded but Move › (up · down · to top · to end). '
                  '“Divide at the cursor” is absent because there is no caret. This is how a block is reached without raising the keyboard (W-136).'),
            frame(f2, 'F2', 'She taps Select, picks two blocks, and drags the fourth up.',
                  'Each row gains a pick circle (24 pt drawn, the row is the target) and a grip. Dragging by the grip reorders: the row lifts, a line shows where it lands. Nothing is said; Undo takes it back. '
                  'The foot bar acts on the picked rows: Merge (adjacent rows only; else it says so), Split at newlines, Delete…. Merge and Delete answer with their line and Undo. One Done, in the header.'),
            frame(f3, 'F3', 'She taps This note’s tray in the note’s menu.',
                  'The Mac’s shape: two views, Leaving and Archived, and one filter (all · blocks · takes). The explainer is the Mac’s sentence at a readable 13 pt. '
                  'Put back is a 44 pt button at the row’s end; Delete Now sits apart, in the row’s ⋯, so the restoring act and the removing act never share an edge.'),
            frame(f4, 'F4 · empty', 'She switches to Archived with nothing in it.', 'The Mac’s empty line, centred on the paper. The segment shows the zero so she knows before tapping.', 'new')))


# ---------------------------------------------------------------- G. long note, sealed, find
def G():
    long_title = 'Full draft — v3'
    lt = [blk('“This is indeed a mystery,” I remarked. “What do you imagine that it means?”'),
          blk('“I have no data yet. It is a capital mistake to theorise before one has data. Insensibly one begins to twist facts to suit theories, instead of theories to suit facts. But the note itself. What do you deduce from it?”', mk(2)),
          blk('I carefully examined the writing, and the paper upon which it was written.'),
          blk('“The man who wrote it was presumably well to do,” I remarked, endeavouring to imitate my companion’s processes. “Such paper could not be bought under half a crown a packet. It is peculiarly strong and stiff.”'),
          blk('“Peculiar—that is the very word,” said Holmes. “It is not an English paper at all. Hold it up to the light.”'),
          blk('I did so, and saw a large “E” with a small “g,” a “P,” and a large “G” with a small “t” woven into the texture of the paper.')]
    g1 = phone(topbar(long_title), page(*lt), over=fade(0, 70))
    jm = menu([(dr('Top of note', 'Jump menu row (the Mac has “End of note”).'), I_TOP), ('End of note', I_END), None,
               (dr('Go to a block…', 'Jump menu row: opens the blocks list.'), I_LIST), ('Find in note…', I_FIND)], 'left:76px;top:112px;width:250px')
    g2 = phone(topbar(long_title), page(*lt), over=fade(0, 70) + jm)

    def brow(n, text, hd=False, cur=False):
        return ('<div class="brow2" style="%s"><span class="n" style="width:36px">%s</span><div class="mid"><div class="t-prev clamp2%s" style="color:var(--ink)">%s</div></div><span class="acc">%s</span></div>'
                % ('box-shadow:inset 3px 0 0 var(--accent)' if cur else '', n, ' hd' if hd else '', text, ib(I_MORE, 'mut')))
    rows = ('<div class="srch">%s%s</div>' % (I_FIND, dr('Find a block', 'Placeholder in the blocks list’s find field.')) +
            brow('208', '## A scandal in Bohemia', hd=True) + brow('209', 'This account of you we have from all quarters received. Be in your chamber then at that hour, and do not take it amiss if your visitor wear a mask.”') +
            brow('210', '“This is indeed a mystery,” I remarked. “What do you imagine that it means?”') +
            brow('211', '“I have no data yet. It is a capital mistake to theorise before one has data.') +
            brow('212', 'I carefully examined the writing, and the paper upon which it was written.', cur=True) +
            brow('213', '“The man who wrote it was presumably well to do,” I remarked, endeavouring to imitate my companion’s processes.') +
            brow('214', '“Peculiar—that is the very word,” said Holmes. “It is not an English paper at all.') +
            '<div class="band" style="flex:1;padding:16px 20px"><span class="t-meta"><span class="spin"></span>%s</span></div>' % dr('Loading more…', 'Shown at the foot of a long blocks list while rows are read.'))
    g3 = phone(topbar(long_title), page(*lt), over=dimmer() + sheet(70, 'Blocks', rows, meta='1,480 blocks · 40,035 words', left='<span class="tbtn">Select</span>'))

    sealed = (chip(I_SEAL, 'Sealed'),) + STD_CHIPS[:3]
    g4 = phone(topbar(), page(rest_blocks(), mast_html=mast(cs=sealed), pad='10px'),
               over=fade(0, 130) + foot_rcpt('This note is sealed — unseal it to edit.', 'Unseal', ref=True, x=True))
    f = B1.replace('sentences', '<span class="hl cur">sentences</span>')
    b2 = 'Copying other people’s <span class="hl">sentences</span> is slower than underlining them, and the slowness is the use of it.'
    find = ('<div class="find" style="bottom:333px"><span class="f" style="margin-left:2px">%ssentences<em>1 of 2</em></span><span class="gc">%s</span><span class="gc">%s</span><span class="tbtn s" style="padding:0 10px">Done</span></div>'
            % (I_FIND, ic('M5 12.5 10 7.5l5 5', 2), ic('M5 7.5 10 12.5l5-5', 2)))
    g5 = phone(topbar(TITLE), page(blk(f, M1, under=True) + blk(b2) + blk(B2), pad='14px'), over=fade() + find + kbd('search'))
    return section(
        'G — the long note, a sealed note, and find',
        'A 40,000-word note needs three jumps: the top, the end, a block. None of it is new chrome: the slim bar that is already there opens them. There is no place readout (her ruling).',
        row(frame(g1, 'G1', 'She is deep in “Full draft — v3”.',
                  'The bar carries the title and nothing else. The whole screen below it is prose.', 'ruled'),
            frame(g2, 'G2', 'She taps the title in the bar.',
                  'The jumps: Top of note · End of note · Go to a block… · Find in note…. The status-bar tap still jumps to the top. Top and End land with the keyboard down. ' + DW, 'ruled'),
            frame(g3, 'G3 · loading', 'She taps Go to a block….',
                  'The blocks list opens at the block she is on (marked by the bar at its edge), with a find field for the note’s blocks. Headings read as landmarks in semibold. '
                  'It is windowed: rows arrive as she scrolls, and the line at the foot says so while they are read. A tap jumps there. ' + DW, 'new'),
            frame(g4, 'G4 · sealed', 'She opens a sealed note and taps into the prose.',
                  'The seal is the first chip (“Sealed”), so the state is a fact of the note. The keyboard does not rise; the refusal at the foot says why (the build’s sentence) and carries the one act, Unseal. '
                  'In a sealed book the same line reads the book’s sentence and offers no Unseal. The word is Seal and Unseal throughout; today’s build says “locked”.', 'ruled'),
            frame(g5, 'G5', 'She taps find in the bar and types.',
                  'The system’s find navigator, floating without the white band: the field with its “1 of 2” count, previous and next, Done. Matches are washed on the page, the current one stronger. '
                  'Find is in v1; replace comes after (her ruling), so no replace door is drawn.', 'ruled')))


NOTES = notes_table([
    ('A1–A4 · the masthead', 'W-149 (her high priority), W-151, W-009, W-161; W-152 once hoisted', 'MobileWriteScreen and MobileEditorViewModel’s header read; Core renameContainer; Core EntryDatePickerDay for the chip’s day words',
     'The scroll-away header; the slim title bar that opens the jumps; the title field in place', 'Ruled: title on its own row, chips, both scroll away, a slim bar with the title stays; no place readout anywhere. The bar never pins anything over the prose. Chips are 44 pt hit areas inside one sideways-scrolling row, never a wrapping row. The app’s bottom bar is never shown inside a note (LK-5).', 'M'),
    ('A3 · the book strip’s place', 'W-088 (BK-5, ruled: at the foot; the strip itself is <code>a-book.html</code>’s)', 'The book’s order read (Queries.assembleReading), as the books mockup names it', 'Only its place in the note: the foot', 'At the foot, and hidden while the keyboard is up so it never stacks on the keyboard bar.', 'S'),
    ('B1 · the date', 'W-153, W-154', 'Core setEntryDate, shiftEntryDate, EntryDatePickerDay', 'The calendar sheet', 'Stores the day (not a moment); undated notes open on the day they were written; Shift renders only on a dated note, as the Mac’s door does. No line afterwards.', 'S'),
    ('B2–B3 · books and tags', 'Sizes for the two existing sheets (W-003’s header and rows); W-010’s visible remove; BK-10’s Move to chapter row', 'MobileMembership, MobileNoteTags, Shared TypedTagPath', 'Nothing but the faces', 'Lists are one wing’s. The ownership choice and Arrivals are the books mockups’. Remove and add are 44 pt accessories, never words.', 'S'),
    ('C1–C3 · the capsule, the quick row, the full menu', 'W-134 (her high priority), W-136, W-138', 'MobileKeyboardBar, MobileBlockMenu; Shared StructuralUndoCopy for the undo names',
     'One right-aligned capsule; the quick row (close · Undo · Redo · Comment · Commit · ⋯); the menu behind its last cell', 'Ruled (LK-4): no white strip, one capsule. The quick row grows in place and stays open until closed or typed past. Undo and Redo grey when empty. Open for the builder to confirm with her: whether the quick row’s Undo is one press for both text and structure (drawn) or structure only as the note’s menu is today.', 'M'),
    ('C4–C5 · commit', 'W-180', 'Core commit, renameCommitPoint, Domain SavepointName', 'The commit line with “Name…”; the name field in the bar’s place', 'One commit per press (the cell latches). Naming never commits again. The line is the only routine line in the note and leaves on its own.', 'S'),
    ('C6–C8 · the formatting strip and its setting', 'W-135 (her high priority), a row in W-212’s Writing settings', 'Shared MarkdownSurfaceDoors; the setting’s home is device settings (my reading: a phone’s button size should not change another phone’s; confirm)',
     'Two strip layouts; one Settings choice', 'Ruled (LK-3): seven big cells with the rest in a menu is the default; all eleven in one compact row is the choice. Compact cells are 31 × 44, under the 44 pt minimum by her decision. Close is ✕ at the leading end in both.', 'M'),
    ('NT-1 · Return', 'W-125, W-126, W-127', 'Shared TypedReturn (compiled into iOS, no phone caller today); Core setSegmentationDefault; Core splitBlockAtNewlines', 'The ↵ cell; the per-note switch row',
     'Ruled: Return makes a block, as on the Mac; ↵ in the capsule is the in-block newline. How the keystroke reaches the brain is the editor seam’s work and is not drawn. Must pass autocorrect, dictation and marked text on a device. List continuation keeps its own Return. Nothing is said after a divide.', 'M'),
    ('NT-2 · backspace', 'W-128', 'Shared SeamCarvePlan and the two carve arms', 'Nothing on the face', 'Ruled: both carves, as the Mac. The join is the Mac’s rule, not a new one. An empty block is removed only when it has nothing unshown (the op’s own precondition). No line: it is typing.', 'M'),
    ('D2–D5 · selection acts, the lines that show', 'W-140 (NT-12, now ruled), W-185, W-129, W-012, W-013, W-145, W-146', 'MobileEditMenuSeam, MobileStructural; Shared StructuralUndoCopy; the Mac’s CrossBlockEditCopy once hoisted',
     'The removal line in two places; the refusal line', 'Ruled: a line with Undo only for a merge, an archive, a delete; refusals always; nothing else. W-140 therefore lands differently from its title: New block below says nothing, and its Undo is the quick row’s. Do not bring back a line per act behind a setting: the synced receipt setting does not add lines on the phone. A press that finds nothing to undo says so (a refusal) and offers no Redo (VM-16).', 'M'),
    ('E1–E7 · the note’s menu', 'W-150, W-046, W-047, W-036, W-157, W-158, W-155, W-232, W-233, W-058 (the Private row, read-only), W-171’s door', 'MobileNoteActions; Core duplicateAsVersion, the note archive (container.archived_at), setPostWordTarget, shiftEntryDate; Shared VersionActs; the Mac’s NoteDuplicate, NoteExport, WingNoteDoors once hoisted',
     'Composition; the facts line; the word-target sheet; the export ask', 'Each row is its own small ticket; the sheet is only the table they land in. Copy text follows what is on screen and says nothing after. Export asks which file. Archive answers with its line and Undo. Delete note… keeps its confirm. The Private row and chip draw only where the mark exists and the library’s AI-marks switch is on; grants do not sync and are not read. No Read mode row in v1.', 'M'),
    ('F1–F2 · blocks and reorder', 'W-141, W-144, W-136, W-142 later', 'MobileBlockList; Core reorder, merge, splitBlockAtNewlines, deleteBlock; Queries.blockTOC', 'Row menu; drag to reorder; the bulk bar',
     'The drag reads one named coordinate space (MobileSoul §5.9). Reorder is one structural undo entry and says nothing. The list stays windowed. One Done.', 'M'),
    ('F3–F4 · the tray', 'W-171', 'MobileNoteTray; Shared RecoveryCopy; the Mac’s TrayFilter once hoisted', 'Two views and a filter in a sheet of its own', 'Put back and Delete Now never share an edge. The explainer is the Mac’s full sentence.', 'M'),
    ('G1–G3 · the long note', 'W-149’s jumps; W-136; perf rows untouched', 'Queries.blockTOC (windowed); the editor’s own arrival scroll', 'The jump menu on the title; the list’s find field', 'Nothing here may cost in proportion to the note. No readout is computed or drawn. Top and End use the editor’s existing landing road.', 'S'),
    ('G4 · sealed', 'W-155 (NT-4, ruled: Seal / Unseal), W-013', 'Core lockPost / unlockPost; Shared OpsRefusalTable', 'The seal chip; the refusal with its act', 'A note in a sealed book defers to the book’s sentence and shows no Unseal.', 'S'),
    ('G5 · find', 'W-132 (find half; NT-14 ruled)', 'The system find navigator', 'Only the missing band', 'Replace is after v1; draw no door for it.', 'S'),
])

INTRO = ('<p class="lede">VM-44, the note’s designer, revised after sitting 1. The Write surface end to end at phone-right sizes: a note at rest, what its chips open, writing with the keyboard up (the capsule, the quick row, the formatting strip and its setting), '
         'Return and backspace, the only lines the app says, the note’s menu, the blocks list with reordering, this note’s tray, the long note, a sealed note, and find. '
         'Frames read left to right; the caption under each says what she did to get there and what each control does.</p>'
         '<p class="ruled"><b>What she chose, now drawn as the only answer.</b> '
         'The bar: one right-aligned capsule, no strip; ⋯ grows into Undo · Redo · Comment · Commit, then the full menu. The formatting strip: a setting, seven big by default. '
         'Return makes a block (NT-1); backspace joins blocks and removes an empty one (NT-2). The masthead scrolls away and a slim title bar stays, with no place readout. '
         'Lines: only removals and refusals, plus Commit. Seal / Unseal; Merge with next beside previous; find now, replace later; no single-note Read mode in v1; the book strip at the foot. '
         'The side-by-side alternatives for these are removed.</p>'
         '<p class="note">Captions tagged <span class="cap"><span class="id ruled">green</span></span> draw a ruling; <span class="cap"><span class="id new">dark green</span></span> is a state (empty, loading, refusal, largest text). '
         '<span class="dw">draft</span> marks a frame holding a designer’s wording, listed in <code>design/wording-list-2.md</code>. Nothing here says how the editor works inside; these are faces and flows over the existing brains.</p>')

BODY = A() + B() + C() + NT() + D() + E() + F() + G() + '<h2>Build notes</h2>' + NOTES + (
    '<p class="note" style="margin-top:14px"><b>Added to the sizing sheet’s vocabulary</b> (all at its sizes and inks): the glass line capsule and its refusal form; the quick row (a word cell and a hairline before the last cell); '
    'the compact formatting cell (31 × 44); the name field in the bar’s place; the setting choice row with a small picture; the block-list row (number · two preview lines · a 44 pt accessory); '
    'the pick circle, grip and drop line; the bulk bar; the calendar card; the switch; the system edit-menu capsule.</p>')

write('note-write.html', 'The note — Write, end to end', INTRO, BODY)
