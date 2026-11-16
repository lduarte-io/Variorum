# VM-44 mockup — note-write.html: the Write surface end to end.
from base import *

M1 = mk(3) + mk(1, 'c')


def rest_blocks():
    return blk(B1, M1, under=True) + blk(B2) + blk(B3) + blk(B4)


def gap(h=16):
    return '<div style="height:%dpx;flex:none"></div>' % h


# ---------------------------------------------------------------- A. at rest
def A():
    a1 = phone(topbar(), page(rest_blocks(), mast_html=mast(), pad='10px'), over=fade(0, 70))
    a2 = phone(topbar(TITLE, 'block 3 of 4'),
               page(blk('other name. In his eyes she eclipses and predominates the whole of her sex.') + blk(B3) + blk(B4) +
                    blk('I keep the notebook in the kitchen drawer now, between the string and the takeaway menus, which is where a thing goes when you mean to use it.', mk(2), under=False) +
                    blk('Most of what is in it I did not write. That is the point of it.') + blk(B2)), over=fade(0, 70))
    a3 = phone(topbar(), page(rest_blocks(), mast_html=mast(), pad='10px'), over=fade(0, 70), dark=True)
    a4 = phone(topbar(right='<span class="tbtn s">Done</span>'),
               '<div class="pagep"><div class="mast"><div class="t-title ttl-field">On keeping a commonplace book%s</div>%s</div>'
               '<div class="in" style="padding-top:10px;opacity:.45"><div class="t-body">%s</div></div></div>' % (CARET, chips(*STD_CHIPS), blk(B1) + blk(B2)),
               over=kbd('done'))
    return section(
        'A — a note at rest', 'The prose is the screen. The title has its own row and wraps; the note’s facts are one row of chips; two tools stay in the bar. '
        'This is the NT-5 sketch’s masthead (2), unchanged in shape, with a fourth chip added for the blocks list.',
        row(frame(a1, 'A1', 'She opens the note from the Library.',
                  'Bar: back · find · the note’s menu, each 44 pt. Title: Iowan 24, its own row, two lines if it needs them; a tap edits it in place (A4). '
                  'Chips, one row that scrolls sideways (32 pt capsules, 44 pt hit areas): the book, the tags, the date, the blocks list. Each opens its sheet in one tap (section B; the blocks list is section F). '
                  'The first block wears its markers at its foot: three takes, one comment (their place is NT-10’s, drawn in <code>comments-and-callouts.html</code>).'),
            frame(a2, 'A2', 'She scrolls.',
                  'The title and chips scroll away with the page; only the 48 pt bar stays. It now carries the title small and, under it, where she is (“block 3 of 4”, the Mac bottom bar’s own readout). '
                  'Nothing is pinned over the prose and no line is sliced at an edge. Tapping the status bar returns to the top, as everywhere on iOS; tapping the bar’s title opens the place menu (G2).'),
            frame(a3, 'A1 dark', 'The same screen in dark.', 'The room is black and the paper carries the hue (#0F1A16), as on the Mac. Markers keep the accent and the comment ink.'),
            frame(a4, 'A4', 'She taps the title.',
                  'The title becomes a field where it stands, at its own size, wrapping as she types; the prose dims. Return or Done files the name. No alert. '
                  'A refusal is a sentence at the foot (D5), never a raw error. On an untitled note the field would offer the first line faint, as the Mac’s does (W-152, a hoist; not drawn).')))


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
          sech('Add to a book') + '<div class="srch">%sFind a book</div>' % I_FIND +
          ''.join(mrow(I_BOOK, n, det=d, trail=ib(I_PLUS, 'acc')) for n, d in
                  (('Blog drafts', '7 notes'), ('Reading notes', '6 notes'), ('Journal', '13 entries · daily'), ('Recipes', '5 notes'), ('Lisbon trip', '4 entries'), ('Running log', '4 entries'))) +
          '<div class="band" style="flex:1"></div>')
    b2 = phone(topbar(), page(rest_blocks(), mast_html=mast(), pad='10px'), over=dimmer() + sheet(150, 'Books', bk))

    tg = ('<div class="srch" style="margin-top:2px">%sAdd a tag — type a path like life/goals</div>' % I_TAG +
          sech('On this note', tight=True) + mrow(I_TAG, 'essay', trail=ib(I_X, 'mut')) + mrow(I_TAG, 'goals', trail=ib(I_X, 'mut'), cls='last') +
          sech('Suggestions') + ''.join(mrow(I_TAG, n, trail=ib(I_PLUS, 'acc')) for n in ('draft', 'idea', 'reading', 'source')) + '<div class="band" style="flex:1"></div>')
    b3 = phone(topbar(), page(rest_blocks(), mast_html=mast(), pad='10px'), over=dimmer() + sheet(250, 'Tags', tg))
    return section(
        'B — what each chip opens', 'Real sheets with a grabber and detents, one header for all of them (Iowan 20 title, Done at 64 × 44). A sheet opens only as tall as it needs.',
        row(frame(b1, 'B1', 'She taps the date chip.',
                  'A calendar, not a typed “2026-08-09”. It opens on the note’s day (or, undated, on the day it was written — the Mac’s <code>EntryDatePickerDay</code> rule). Day cells are 44 pt. '
                  'Set files it; Cancel or a swipe down changes nothing. “Shift date a day earlier” and “Clear date” are the Mac’s two other date acts, as rows. The chip then reads the day in words (“Jul 25”), never raw ISO.'),
            frame(b2, 'B2', 'She taps the book chip.',
                  'The books that hold the note, then the current wing’s books to add it to, with a find field. A row’s ＋ adds; a held book’s ⋯ carries Remove from this book and Diverge for this book. '
                  'Sizes only: the ownership choice (copy or move) and Arrivals belong to the books mockups, and the list is one wing’s, so no twins.'),
            frame(b3, 'B3', 'She taps the tags chip.',
                  'Type a path and Return applies it; a suggestion’s ＋ applies it; a worn tag’s ✕ removes it (a 44 pt target at the row’s end, not a word). Suggestions are the current wing’s vocabulary.')))


# ---------------------------------------------------------------- C. writing: the bar, Return, backspace
def C():
    def typing(blocks, receipt='', cells=None, on=None, dark=False, extra='', sub='block 3 of 4'):
        return phone(topbar(TITLE, sub), page(blocks, pad='14px'),
                     over=fade() + bar(cells, receipt, on=on) + extra + kbd(), dark=dark)

    pre = 'It was not that he felt any emotion akin to love for Irene Adler. All emotions, and that one particularly, were abhorrent to his cold, precise but admirably balanced mind. He was, I take it, the most perfect reasoning and '
    post = 'machine that the world has seen, but as a lover he would have placed himself in a false position.'
    tail2 = 'other name. In his eyes she eclipses and predominates the whole of her sex.'

    c1 = typing(blk(tail2) + blk(pre + 'observing' + CARET + ' ' + post) + blk(B4))
    c1d = typing(blk(tail2) + blk(pre + 'observing' + CARET + ' ' + post) + blk(B4), dark=True)
    strip = [I_X, '<b style="font:700 17px/1 var(--chrome)">B</b><i style="font:italic 500 17px/1 var(--prose);margin-left:1px">I</i>',
             '<span style="font:600 19px/1 var(--chrome)">#</span>', I_BUL, I_CHK, I_OUT, I_IN]
    stylemenu = menu([('Bold', '<b style="font:700 17px/1 var(--chrome)">B</b>'), ('Italic', '<i style="font:italic 500 18px/1 var(--prose)">I</i>'),
                      ('Strikethrough', '<s style="font:500 16px/1 var(--chrome)">S</s>'), ('Code', ic('m7 5.5-4.5 4.5L7 14.5M13 5.5l4.5 4.5-4.5 4.5')), ('Link…', I_LINK)],
                     'left:60px;bottom:389px;width:232px')
    c2 = phone(topbar(TITLE, 'block 3 of 4'), page(blk(tail2) + blk(pre + 'observing' + CARET + ' ' + post) + blk(B4), pad='14px'),
               over=fade() + '<div class="fbar" style="bottom:333px;justify-content:center"><span class="gcap" style="gap:2px">%s</span></div>' %
               ''.join(gc(c, i == 1) for i, c in enumerate(strip)) + stylemenu + kbd())

    # NT-1
    seam = 'seam'
    n0 = typing(blk(tail2, cls=seam) + blk(pre + 'obser' + CARET + 'ving ' + post, cls=seam) + blk(B4, cls=seam))
    na = typing(blk(tail2, cls=seam) + blk(pre.rstrip(), cls=seam) + blk(CARET + 'observing ' + post, cls=seam) + blk(B4, cls=seam),
                receipt=rcpt('Divided'), sub='block 4 of 5')
    one = 'outline:1.5px dotted var(--seam);outline-offset:5px;border-radius:3px'
    nb = typing(blk(tail2, cls=seam) + '<div style="height:6px"></div>' +
                blk(pre + 'obser<br>' + CARET + 'ving ' + post, style=one) + '<div style="height:6px"></div>' + blk(B4),
                cells=[AA, I_NEWB, I_FORK, I_MORE])

    # NT-2
    z0 = typing(blk(tail2, cls=seam) + blk(B3, cls=seam) + blk(CARET + B4, cls=seam), sub='block 4 of 4')
    za = typing(blk(tail2, cls=seam) + blk(B3 + ' ' + CARET + B4, cls=seam), receipt=rcpt('Merged'), sub='block 3 of 3')
    zb = phone(topbar(TITLE, 'block 4 of 4'), page(blk(tail2, cls=seam) + blk(B3, cls=seam) + blk(CARET + B4, cls=seam), pad='14px'),
               over=fade(327, 150) + '<div class="fbar" style="bottom:389px;justify-content:flex-start">%s</div>' %
               rcpt('Backspace stops at a block’s start.', 'Merge with previous', ref=True, x=True) + bar() + kbd())
    return (section(
        'C — writing: the keyboard up',
        'The bar is the LK-4 sketch’s pick: no band; one glass capsule at the trailing edge, over the ragged end of the line; the freed space at its left is where receipts land, beside her thumb. '
        'The capsule gains one cell for NT-1. Frames from here show the page scrolled into the note, so the bar carries the title.',
        row(frame(c1, 'C1', 'She taps into the prose.',
                  'The keyboard rises with the capsule: Aa (the formatting strip) · the in-block newline (NT-1) · takes for this block · the block menu. Four 44 pt cells in a 48 pt capsule. '
                  'The prose runs to the keyboard behind it; the last lines fade.'),
            frame(c1d, 'C1 dark', 'The same, in dark.', 'The glass darkens with the room; glyphs stay in ink.'),
            frame(c2, 'C2', 'She taps Aa.',
                  'The capsule grows into the LK-3 pick: seven 44 pt cells (close · style · heading · bullet · checkbox · outdent · indent). The style cell opens bold, italic, strikethrough, code and link as menu rows (shown); '
                  'heading opens its levels on a tap. Close returns the four resting cells.'))) +
        section(
            'NT-1 — what Return does', 'Three frames, drawn with the block seams on so the blocks show (the dotted lines are the app’s own seam face; at rest they are off). '
            'The first is where she is; the next two are the same keystroke under each answer.',
            row(frame(n0, 'before', 'Her caret is inside a word, mid-paragraph, and she presses Return.', 'One block of four. The caret sits in “obser|ving”.'),
                frame(na, 'NT-1 (a)', 'The Mac’s model: Return makes a block.',
                      'The block divides at the start of the word, so “observing” rides down whole; at a block’s end Return opens an empty block below; in an empty block it chains. '
                      'It is the Mac’s rule through the shared <code>TypedReturn</code>, so the same typing makes the same blocks on both devices. '
                      'The receipt lands by the thumb with Undo. The bar’s second cell (↵) is the newline that stays inside the block — the phone’s ⇧⏎. '
                      'The per-note switch “Newlines make blocks” (the note’s menu, E2) turns the note back to (b).', 'pick'),
                frame(nb, 'NT-1 (b)', 'Return is content, as today.',
                      'The same keystroke puts a line break inside the block, exactly at the caret; it is still one block (outlined). '
                      'The bar’s second cell is instead “new block below”, and “Make every newline a block” in the note’s menu is the repair. '
                      'Cost: a paragraph typed mid-note on the phone is not a block until she says so, so structure drifts from what the Mac would make. '
                      '(c) is (a) with the note’s switch off by default: it looks like this frame until she turns it on.', 'q'))) +
        section(
            'NT-2 — backspace at a block’s start', 'Same convention: seams on.',
            row(frame(z0, 'before', 'Her caret is at the very start of the last paragraph and she presses backspace.', 'Two blocks, a seam between them.'),
                frame(za, 'NT-2 (a)', 'Both carves, as the Mac.',
                      'The two blocks become one, joined by the Mac’s own seam rule, with the caret where the break was. Beside an empty block, backspace removes the empty block instead. '
                      'The receipt offers Undo. This is what a text editor does, and it is the shared <code>SeamCarvePlan</code>.', 'pick'),
                frame(zb, 'NT-2 (b)', 'Only the empty-block carve; a texted seam stays deliberate.',
                      'Backspace beside an empty block removes it; at a seam with words on both sides nothing changes and a refusal says why, with the merge one tap away. '
                      'A refusal stays until dismissed (✕) and sits above the bar because it needs the width. The sentence is a proposal; today’s is longer and names the ⋯ menu.', 'q'))))


# ---------------------------------------------------------------- D. the block menu, selection, receipts
def D():
    tail2 = 'other name. In his eyes she eclipses and predominates the whole of her sex.'
    b3c = B3.replace('He was, I take it,', 'He was,' + CARET + ' I take it,')
    items = [('Remove', I_CHEV), None,
             ('Name block…', I_NAME), ('Callout', I_CHEV), ('Comments', I_CMT), None,
             ('Merge', I_CHEV), ('Divide at the cursor', I_DIV), ('New block below', I_NEWB), None,
             ('History and lineage', I_HIST), ('Commit take', I_COMMIT)]
    d1 = phone(topbar(TITLE, 'block 3 of 4'), page(blk(tail2) + blk(b3c) + blk(B4), pad='14px'),
               over=fade() + bar(on=3) + menu(items, 'right:16px;bottom:389px;width:262px') + kbd())

    selpre = ('It was not that he felt any emotion akin to love for Irene Adler. All emotions, and that one particularly, were abhorrent to his cold, precise but admirably balanced mind. '
              'He was, I take it, the most perfect reasoning and observing machine that the world has seen, ')
    selspan = 'but as a lover he would have placed himself in a false position.'
    em = '<div class="editm" style="left:24px;top:262px"><span>Copy</span><span class="a">Extract</span><span class="a">Make block</span><span class="a">New take</span><span>›</span></div>'
    d2 = phone(topbar(TITLE, 'block 3 of 4'), page(blk(tail2) + blk(selpre + '<span class="sel">' + selspan + '</span>') + blk(B4), pad='14px'),
               over=fade() + em + bar() + kbd())
    d3 = phone(topbar(TITLE, 'block 4 of 5'), page(blk(tail2, cls='seam') + blk(selpre.rstrip(), cls='seam') + blk(CARET + selspan, cls='seam') + blk(B4, cls='seam'), pad='14px'),
               over=fade() + bar(receipt=rcpt('Extracted')) + kbd())
    d4 = phone(topbar(TITLE, 'block 2 of 3'), page(blk(tail2) + blk(B3) + blk('I keep the notebook in the kitchen drawer now, between the string and the takeaway menus, which is where a thing goes when you mean to use it.') +
                                                    blk('Most of what is in it I did not write. That is the point of it.') + blk(B2)),
               over=fade(0, 110) + foot_rcpt('Block deleted — it’s in this note’s tray.'))
    d5 = phone(topbar(TITLE, 'block 1 of 4'), page(blk(CARET + B1, M1, under=True) + blk(B2) + blk(B3), pad='14px'),
               over=fade(327, 150) + '<div class="fbar" style="bottom:389px;justify-content:flex-start">%s</div>' %
               rcpt('This is the note’s first block — there’s nothing above to merge with.', '', ref=True, x=True) + bar() + kbd())

    acts = [
        ('Commit take', 'Commit Take', 'bar ⋯ · list ⋯', 'commit', 'One filing per press; the receipt offers “Name…” (takes-and-history, C1).'),
        ('History and lineage', 'History · Lineage', 'bar ⋯ · list ⋯ · take card', '—', 'One surface, two faces (takes-and-history, section C).'),
        ('Comments', 'Comments…', 'bar ⋯ · list ⋯ · the page marker', 'addBlockComment …', 'Shows the count when there are any.'),
        ('Callout', 'Callout', 'bar ⋯ · list ⋯', 'updateBlockPresentation', 'Opens the chooser (comments-and-callouts, section C), not a submenu of pale swatches.'),
        ('Name block…', 'Name Block…', 'bar ⋯ · list ⋯', 'setBlockName', 'A field in the blocks list row, not an alert.'),
        ('New block below', 'New Block Below', 'bar ⋯ · list ⋯', 'newBlock', 'Receipt carries Undo (NT-12 (a)).'),
        ('Divide at the cursor', 'Divide Block at Cursor', 'bar ⋯ only (needs a caret)', 'divide · keep-on-top when fanned', 'One default on a fanned block (NT-7 (b)); no preset sheet.'),
        ('Merge with previous · Merge with next', 'Merge Blocks', 'bar ⋯ (under Merge ›) · list ⋯ · list bulk bar', 'merge · carry-all when fanned', 'NT-8: next beside previous now; select-then-merge in the blocks list (F2).'),
        ('Split this block at its newlines', 'Split This Block at Its Newlines', 'bar ⋯ · list ⋯, only when the block holds a newline', 'splitBlockAtNewlines', 'The repair for blocks typed under NT-1 (b).'),
        ('Move up · down · to top · to end', '(Blocks mode)', 'list ⋯ (under Move ›) · drag in the list', 'reorder', 'Never offered above the keyboard; the list is where order is seen.'),
        ('Extract', 'Extract Selection', 'the selection’s edit menu', 'extract', 'Only at a block’s start or end; elsewhere the refusal names Make block.'),
        ('Make block', 'Make Block from Selection', 'the selection’s edit menu', 'the shared StructuralGesturePlanner', 'A middle span becomes its own block.'),
        ('New take', 'Move Selection into a New Take', 'the selection’s edit menu', 'moveSpanToNewTake', 'New on the phone (W-185).'),
        ('Archive block', 'Archive Block', 'bar ⋯ (under Remove ›) · list ⋯ · list swipe', 'archive (the block’s archived_at)', 'Receipt: Undo.'),
        ('Delete block…', 'Delete Block', 'bar ⋯ (under Remove ›) · list ⋯ · list swipe · list bulk bar', 'deleteBlock', 'Asks first, naming the tray; receipt: Undo.'),
    ]
    tbl = ('<h3>The block menu as one table</h3><p class="note">One definition, three doors. Above the keyboard the menu folds Merge and Remove into submenus so it fits between the status bar and the bar '
           '(nine rows, 420 pt); in the blocks list (F1) the same table opens flat. The selection acts live where a selection’s acts live on a phone, in its edit menu. '
           'Names are the Mac’s words in sentence case; the Mac column is the capability registry’s verb.</p>'
           '<table class="plain"><tr><th>Phone name</th><th>The Mac’s verb</th><th>Doors</th><th>Operation (AppSpec §9)</th><th>Note</th></tr>%s</table>' %
           ''.join('<tr>%s</tr>' % ''.join('<td>%s</td>' % c for c in a) for a in acts))
    return section(
        'D — the block menu, the selection’s acts, and receipts',
        'Every structural act answers with a receipt beside the thumb: in the space left of the bar while the keyboard is up, at the foot of the screen when it is down. A receipt leaves on its own; a refusal stays until dismissed.',
        row(frame(d1, 'D1', 'She taps the bar’s ⋯.',
                  'The block menu, grouped and nearest-first: commit and history by the thumb (the NT-5 pick’s pair); then the structure acts; then the block’s notes; removal furthest, behind one more tap. '
                  'Merge › holds “with previous” and “with next”; Remove › holds Archive block and Delete block…. Takes has its own cell on the bar, so it is not repeated here.'),
            frame(d2, 'D2', 'She selects the end of a paragraph.',
                  'The selection’s own menu carries the three span acts by short names: Extract (the span leaves to a block of its own), Make block (a middle span), New take (the span moves into a new take of this block). '
                  'The next page (›) holds the system’s acts and Block ›, which repeats D1.'),
            frame(d3, 'D3', 'She taps Extract.', 'The span is its own block below (seams on to show it), the caret at its start, and the receipt “Extracted · Undo” sits left of the bar. One tap undoes it.'),
            frame(d4, 'D4', 'Keyboard down: she deleted a block from the blocks list.',
                  'The receipt is one 44 pt glass line at the foot, with Undo at 60 × 44. It never enters the masthead and never moves the prose. It follows the synced receipt setting (SW-6) and fades as the Mac’s quiet line does.'),
            frame(d5, 'D5 · refusal', 'She asks to merge the first block with a previous one.',
                  'A refusal is a sentence in words (the build’s own), in ink rather than muted, with ✕. It stays until she dismisses it or acts again. No raw error text ever reaches this line (W-013).', 'new'))) + tbl


# ---------------------------------------------------------------- E. the note's menu
def E():
    behind = topbar() + page(rest_blocks(), mast_html=mast(), pad='10px')
    g1 = (mrow(I_UNDO, 'Undo divide') + mrow(I_REDO, 'Redo', cls='off last') + gap() +
          mrow(I_STAR, 'Star') + mrow(I_SEAL, 'Seal', det='Read-only until you unseal it') + mrow(I_VERS, 'Save a version', det='Keeps the whole note as it is now') +
          mrow(I_HIST, 'Versions', val='2', chev=True, cls='last') + gap() +
          mrow(I_LIST, 'Blocks', val='4', chev=True) + mrow(I_TRAY, 'This note’s tray', val='2', chev=True) + mrow(I_LINK, 'References', val='1', chev=True, cls='last') + gap() +
          mrow(I_BOOK, 'Add to a book…') + mrow(I_WING, 'Move to wing…') + mrow(I_WING, 'Copy to wing…', cls='last') + '<div class="band" style="flex:1"></div>')
    meta = '1,204 words · 4 blocks · edited today at 9:12 AM'
    e1 = phone(behind, over=dimmer() + sheet(70, 'Note', g1, meta=meta))
    g2 = (mrow(I_WING, 'Copy to wing…', cls='last') + gap() +
          mrow(I_DUP, 'Duplicate with tags') + mrow(I_DUP, 'Duplicate without tags') + mrow(I_ARCH, 'Archive', cls='last') + gap() +
          mrow(I_COPY, 'Copy text') + mrow(I_SHARE, 'Export note…', cls='last') + gap() +
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

    sh = ('<div class="share"><div style="display:flex;gap:12px;align-items:center"><div style="width:48px;height:60px;border-radius:8px;background:var(--paper);box-shadow:inset 0 0 0 1px var(--takeLine);'
          'display:flex;align-items:center;justify-content:center;font:600 11px/1 var(--mono);color:var(--muted2)">.md</div><div><div style="font:600 17px/22px var(--chrome)">On keeping a commonplace book.md</div>'
          '<div class="t-meta">Markdown document · 8 KB</div></div></div><div class="apps"><div><i></i>AirDrop</div><div><i></i>Messages</div><div><i></i>Mail</div><div><i></i>Notes</div></div>'
          '<div class="sr">Copy%s</div><div class="sr">Save to Files%s</div></div>' % (I_COPY.replace('<svg', '<svg width="22" height="22"'), I_ARCH.replace('<svg', '<svg width="22" height="22"')))
    e4 = phone(behind, over=dimmer() + sh)

    wings = ["Home", "Work", "Fiction", "Research", "Family", "Health", "Side project", "Poetry", "Taxes 2025"]
    wr = ''.join(mrow(I_WING, w, val='this note is here' if i == 0 else '', cls=('off' if i == 0 else '') + (' last' if i == 8 else '')) for i, w in enumerate(wings))
    e5 = phone(behind, over=dimmer() + sheet(250, 'Move to wing', wr, right='Cancel'))

    e6 = phone(behind, over=dimmer() + sheet(70, 'Note', mrow(I_UNDO, 'Undo divide') + mrow(I_REDO, 'Redo', cls='off last') + gap() +
                                             mrow(I_STAR, 'Star') + mrow(I_SEAL, 'Seal', det='Read-only until you unseal it') +
                                             mrow(I_VERS, 'Save a version', det='Keeps the whole note as it is now') + mrow(I_HIST, 'Versions', val='2', chev=True, cls='last') + gap() +
                                             mrow(I_LIST, 'Blocks', val='4', chev=True) + mrow(I_TRAY, 'This note’s tray', val='2', chev=True) + '<div class="band" style="flex:1"></div>',
                                             meta='1,204 words · 4 blocks'), cls='xxl')
    return section(
        'E — the note’s menu', 'The bar’s ⋯. One sheet holds every act on the note itself, in the Mac’s words, so the masthead can stay three facts and two tools. It opens at the large detent and scrolls.',
        row(frame(e1, 'E1', 'She taps ⋯ in the bar.',
                  'Under the title, the note’s facts in one readable line: words, blocks, when it was last edited (W-158’s count and VM-22’s stamp; the exact created and edited times sit under a tap on the line). '
                  'Then: Undo and Redo, each naming its entry (“Undo divide”), greyed when there is nothing; Star; Seal (the Mac’s word, NT-4 (a)); Save a version; Versions. '
                  'Then the doors to the note’s other surfaces: Blocks, This note’s tray (out from under “blocks”), References (today’s “more info”). Then Add to a book, Move to wing, Copy to wing. '
                  'A note marked Private on the Mac shows a row “Private — never shared with AI” with the eye here, read-only for v1 (LP-8).'),
            frame(e2, 'E2', 'She scrolls the menu.',
                  'Duplicate with tags · Duplicate without tags (both doors, LS-4) · Archive (absent today; the receipt is the Mac’s “Note archived — it’s kept in Archived, with no countdown.”). '
                  'Copy text (what is on screen, her R15 rule; NT-3) · Export note… (the full document, through the share sheet, E4). Date (opens B1) · Shift date a day earlier. '
                  'Newlines make blocks (the per-note switch of NT-1) · Make every newline a block (the repair). Word target (E3). Delete note… last, in the alarm ink, after a gap; it asks first, as today.'),
            frame(e3, 'E3', 'She taps Word target.',
                  'The Mac’s sentence and its two acts, Clear and Set, with a number pad. The count line in E1 then reads “1,204 of 1,500 words”. A target never refuses anything.'),
            frame(e4, 'E4', 'She taps Export note….',
                  'The system share sheet with the note as a Markdown document (the Variorum document format, which re-imports whole). No app-drawn chrome; the phone’s export grammar is the share sheet (MobileSoul §5.7).'),
            frame(e5, 'E5 · nine wings', 'She taps Move to wing….',
                  'Her nine wings as 52 pt rows; the wing the note is in is marked and cannot be picked. Choosing one asks first with the Mac’s confirm, which names the books the note leaves behind, then the receipt names where it went. '
                  'Copy to wing… is the same list. The picker’s shape is the wing mockups’ to settle; this frame only shows nine fit.'),
            frame(e6, 'E1 at the largest text size', 'The same menu at xxxLarge.',
                  'Row labels are 23 pt and rows grow to 64 pt; the facts line wraps to what fits; detail lines wrap rather than truncate. Chrome stops growing here; her prose behind keeps scaling through the accessibility sizes.', 'new')))


# ---------------------------------------------------------------- F. blocks, reorder, the tray
def F():
    behind = topbar() + page(rest_blocks(), mast_html=mast(), pad='10px')

    def brow(n, text, marks='', acc=None, hd=False, cls='', lead=''):
        m = '<div style="margin-top:2px;display:flex;gap:10px">%s</div>' % marks if marks else ''
        return ('<div class="brow2 %s">%s<span class="n">%s</span><div class="mid"><div class="t-prev clamp2%s" style="color:var(--ink)">%s</div>%s</div><span class="acc">%s</span></div>'
                % (cls, lead, n, ' hd' if hd else '', text, m, acc if acc is not None else ib(I_MORE, 'mut')))

    rows = (brow('1', B1, mk(3) + mk(1, 'c')) + brow('2', B2) + brow('3', B3) + brow('4', B4) + '<div class="band" style="flex:1"></div>')
    flat = [('Commit take', I_COMMIT), ('History and lineage', I_HIST), None, ('Comments', I_CMT), ('Callout', I_CHEV), ('Name block…', I_NAME), None,
            ('New block below', I_NEWB), ('Merge with previous', I_MERGE), ('Merge with next', I_MERGE), None, ('Move', I_CHEV), None,
            ('Archive block', I_ARCH), ('Delete block…', I_TRASH, 'al')]
    f1 = phone(behind, over=dimmer() + sheet(70, 'Blocks', rows, left='<span class="tbtn">Select</span>'))
    f1m = phone(behind, over=dimmer() + sheet(70, 'Blocks', rows, left='<span class="tbtn">Select</span>') + menu(flat, 'right:12px;top:262px;width:270px'))

    pk = lambda on: '<span class="pk%s">%s</span>' % (' on' if on else '', I_CHECK if on else '')
    grip = ib(I_GRIP, 'mut')
    rows2 = (brow('1', B1, mk(3) + mk(1, 'c'), acc=grip, lead=pk(False)) + brow('2', B2, acc=grip, lead=pk(True)) + '<div class="dropline"></div>' +
             brow('4', B4, acc=grip, lead=pk(False), cls='lift') + brow('3', B3, acc=grip, lead=pk(True)) + '<div class="band" style="flex:1"></div>' +
             '<div class="bulk"><span class="tbtn">Merge</span><span class="tbtn">Split at newlines</span><span class="tbtn al">Delete…</span></div><div style="height:30px;background:var(--room)"></div>')
    f2 = phone(behind, over=dimmer() + sheet(70, '2 selected', rows2, right='Done'))

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
        'The blocks list is the phone’s Blocks workbench and the block door for when the keyboard is down: every row is a jump target and carries the same block menu. The tray gets its own door and its own sheet.',
        row(frame(f1, 'F1', 'She taps the “4 blocks” chip (or Blocks in the note’s menu).',
                  'Her words at Iowan 15, two lines a row, rows at least 64 pt. A tap on a row jumps to that block and closes the sheet. A row shows its takes and comments counts. '
                  'Each row’s ⋯ is a 44 pt target. Swiping a row left offers Archive and Delete…. Select enters F2.'),
            frame(f1m, 'F1 · the menu', 'She taps a row’s ⋯.',
                  'The same block menu as D1, flat because there is room: nothing folded but Move › (up · down · to top · to end). “Divide at the cursor” is absent because there is no caret here. '
                  'This is how a block is reached without raising the keyboard (W-136).'),
            frame(f2, 'F2', 'She taps Select, picks two blocks, and drags the fourth up.',
                  'Each row gains a pick circle (24 pt drawn, the row is the target) and a grip. Dragging by the grip reorders: the row lifts, a line shows where it lands, and the move is one Undo. '
                  'The foot bar acts on the picked rows: Merge (adjacent rows only; else it says so), Split at newlines, Delete…. One Done, in the header.'),
            frame(f3, 'F3', 'She taps This note’s tray in the note’s menu.',
                  'The Mac’s shape: two views, Leaving and Archived, and one filter (all · blocks · takes). The explainer is the Mac’s sentence at a readable 13 pt in the corrected ink. '
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
    g1 = phone(topbar(long_title, 'block 212 of 1,480'), page(*lt), over=fade(0, 70))
    jm = menu([('Top of note', I_TOP), ('End of note', I_END), None, ('Blocks…', I_LIST), ('Find in note…', I_FIND)], 'left:76px;top:112px;width:250px')
    g2 = phone(topbar(long_title, 'block 212 of 1,480'), page(*lt), over=fade(0, 70) + jm)

    def brow(n, text, hd=False, cur=False):
        return ('<div class="brow2" style="%s"><span class="n" style="width:36px">%s</span><div class="mid"><div class="t-prev clamp2%s" style="color:var(--ink)">%s</div></div><span class="acc">%s</span></div>'
                % ('box-shadow:inset 3px 0 0 var(--accent)' if cur else '', n, ' hd' if hd else '', text, ib(I_MORE, 'mut')))
    rows = ('<div class="srch">%sFind a block</div>' % I_FIND +
            brow('208', '## A scandal in Bohemia', hd=True) + brow('209', 'This account of you we have from all quarters received. Be in your chamber then at that hour, and do not take it amiss if your visitor wear a mask.”') +
            brow('210', '“This is indeed a mystery,” I remarked. “What do you imagine that it means?”') +
            brow('211', '“I have no data yet. It is a capital mistake to theorise before one has data.') +
            brow('212', 'I carefully examined the writing, and the paper upon which it was written.', cur=True) +
            brow('213', '“The man who wrote it was presumably well to do,” I remarked, endeavouring to imitate my companion’s processes.') +
            brow('214', '“Peculiar—that is the very word,” said Holmes. “It is not an English paper at all.') +
            '<div class="band" style="flex:1;padding:16px 20px"><span class="t-meta"><span class="spin"></span>Reading more blocks…</span></div>')
    g3 = phone(topbar(long_title, 'block 212 of 1,480'), page(*lt), over=dimmer() + sheet(70, 'Blocks', rows, meta='1,480 blocks · 40,035 words', left='<span class="tbtn">Select</span>'))

    sealed = (chip(I_SEAL, 'Sealed'),) + STD_CHIPS[:3]
    g4 = phone(topbar(), page(rest_blocks(), mast_html=mast(cs=sealed), pad='10px'),
               over=fade(0, 130) + foot_rcpt('This note is sealed — unseal it to edit.', 'Unseal', ref=True, x=True))
    f = B1.replace('sentences', '<span class="hl cur">sentences</span>')
    b2 = 'Copying other people’s <span class="hl">sentences</span> is slower than underlining them, and the slowness is the use of it.'
    find = ('<div class="find" style="bottom:333px"><span class="gc">%s</span><span class="f">%ssentences<em>1 of 2</em></span><span class="gc">%s</span><span class="gc">%s</span><span class="tbtn s" style="padding:0 10px">Done</span></div>'
            % (I_MORE, I_FIND, ic('M5 12.5 10 7.5l5 5', 2), ic('M5 7.5 10 12.5l5-5', 2)))
    g5 = phone(topbar(TITLE, 'block 1 of 4'), page(blk(f, M1, under=True) + blk(b2) + blk(B2), pad='14px'), over=fade() + find + kbd('search'))
    return section(
        'G — the long note, a sealed note, and find',
        'A 40,000-word note needs a sense of place and three jumps: the top, the end, a block. None of it is new chrome: the bar that is already there carries it.',
        row(frame(g1, 'G1', 'She is deep in “Full draft — v3”.',
                  'The bar’s second line says where she is: “block 212 of 1,480”. It updates as she scrolls (a read of the viewport’s first block, nothing that grows with the note). The whole screen below the bar is prose.'),
            frame(g2, 'G2', 'She taps the title in the bar.',
                  'The place menu: Top of note · End of note · Blocks… · Find in note…. The status-bar tap still jumps to the top. Top and End land with the keyboard down.'),
            frame(g3, 'G3 · loading', 'She taps Blocks….',
                  'The list opens at the block she is on (marked), with a find field for the note’s blocks. Headings read as landmarks in semibold. '
                  'It is windowed: rows arrive as she scrolls, and the line at the foot says so while they are read. A tap jumps there.', 'new'),
            frame(g4, 'G4 · sealed', 'She opens a sealed note and taps into the prose.',
                  'The seal is the first chip (“Sealed”), so the state is a fact of the note, not an extra masthead line. The keyboard does not rise; the refusal at the foot says why and carries the one act, Unseal, at full size. '
                  'In a sealed book the same line reads the book’s sentence and offers no Unseal. The word is Seal throughout (NT-4 (a)); today’s build says “locked”.', 'new'),
            frame(g5, 'G5', 'She taps find in the bar and types.',
                  'The system’s find navigator, kept, floating without the white band: the field with its “1 of 2” readout, previous and next, Done. Matches are washed on the page, the current one stronger. '
                  'Find only for v1 (NT-14 (b)); its ⋯ is where replace would arrive later.')))


NOTES = notes_table([
    ('A1–A4 · the masthead', 'W-149 (her high priority), W-151, W-009, W-161; W-152 once hoisted', 'MobileWriteScreen and MobileEditorViewModel’s header read; Core renameContainer; Core EntryDatePickerDay for the chip’s day words',
     'The scroll-away header; the place line; the title field in place', 'The header is one swappable layer (the NT-5 sketch’s masthead 1 or 3 is a re-skin). The bar never pins anything over the prose. The place line reads the viewport’s first block only (P1). Chips are 44 pt hit areas inside one sideways-scrolling row, never a wrapping row.', 'M'),
    ('B1 · the date', 'W-153, W-154', 'Core setEntryDate, shiftEntryDate, EntryDatePickerDay', 'The calendar sheet', 'Stores the day (not a moment); undated notes open on the day they were written; Shift renders only on a dated note, as the Mac’s door does.', 'S'),
    ('B2–B3 · books and tags', 'Sizes for the two existing sheets (W-003’s header and rows); W-010’s visible remove', 'MobileMembership, MobileNoteTags, Shared TypedTagPath', 'Nothing but the faces', 'Lists are one wing’s. The ownership choice and Arrivals are the books mockups’. Remove and add are 44 pt accessories, never words.', 'S'),
    ('C1–C2 · the bar and strip', 'W-134, W-135 (her high priority)', 'MobileKeyboardBar; Shared MarkdownSurfaceDoors', 'One capsule; the newline cell', 'These are the LK-4 and LK-3 sketch picks, not yet hers: keep the bar a single view so the three-button or flat variants swap in. Close is ✕ at the leading end.', 'M'),
    ('NT-1 · Return', 'W-125, W-126, W-127', 'Shared TypedReturn (compiled into iOS, no phone caller today); Core setSegmentationDefault; Core splitBlockAtNewlines', 'The ↵ cell; the per-note switch row',
     'Faces only: how the keystroke reaches the brain is the editor seam’s work and is not drawn. Must pass autocorrect, dictation and marked text on a device. List continuation keeps its own Return. The switch’s words are the Mac’s (“newlines make blocks”).', 'M'),
    ('NT-2 · backspace', 'W-128', 'Shared SeamCarvePlan and the two carve arms', 'Nothing on the face but the receipt', 'The join is the Mac’s rule, not a new one. An empty block is removed only when it has nothing unshown (the op’s own precondition).', 'M'),
    ('D1–D5 · block menu, receipts', 'W-136, W-138, W-140 (NT-12), W-185, W-129, W-012, W-013, W-145, W-146', 'MobileBlockMenu, MobileEditMenuSeam, MobileStructural; Shared StructuralUndoCopy; the Mac’s CrossBlockEditCopy once hoisted',
     'The grouped menu; the receipt capsule in two places; the refusal line', 'One table, three doors: do not fork the list per door. Every receipt that reports an undoable act carries Undo and names the act. A press that finds nothing to undo says so and offers no Redo (VM-16). Receipts honour the synced setting; refusals always show.', 'M'),
    ('E1–E6 · the note’s menu', 'W-150, W-046, W-047, W-036, W-157, W-158, W-155, W-232, W-233, W-058 (read-only), W-171’s door', 'MobileNoteActions; Core duplicateAsVersion, the note archive (container.archived_at), setPostWordTarget, shiftEntryDate; Shared VersionActs; the Mac’s NoteDuplicate, NoteExport, WingNoteDoors once hoisted',
     'Composition; the facts line; the word-target sheet', 'Each row is its own small ticket; the sheet is only the table they land in. Copy text follows what is on screen; Export is the full document. Delete note… keeps its confirm. Words are the Mac’s, set in sentence case here; the shared strings are title case today, so the casing is her wording pass.', 'M'),
    ('F1–F2 · blocks and reorder', 'W-141, W-144, W-136, W-142 later', 'MobileBlockList; Core reorder, merge, splitBlockAtNewlines, deleteBlock; Queries.blockTOC', 'Row menu; drag to reorder; the bulk bar',
     'The drag reads one named coordinate space (MobileSoul §5.9). Reorder is one structural undo entry. The list stays windowed. “Done Done” goes: one Done.', 'M'),
    ('F3–F4 · the tray', 'W-171', 'MobileNoteTray; Shared RecoveryCopy; the Mac’s TrayFilter once hoisted', 'Two views and a filter in a sheet of its own', 'Put back and Delete Now never share an edge. The explainer is the Mac’s full sentence, not the shrunk one.', 'M'),
    ('G1–G3 · the long note', 'W-149’s place line; W-136; perf rows untouched', 'Queries.blockTOC (windowed); the editor’s own arrival scroll', 'The place menu; the list’s find field', 'Nothing here may cost in proportion to the note. Top and End use the editor’s existing landing road; the scrubber is not proposed.', 'S'),
    ('G4 · sealed', 'W-155 (NT-4), W-013', 'Core lockPost / unlockPost; Shared OpsRefusalTable', 'The seal chip; the refusal with its act', 'A note in a sealed book defers to the book’s sentence and shows no Unseal.', 'S'),
    ('G5 · find', 'W-132 (find half)', 'The system find navigator', 'Only the missing band', 'Replace stays off for v1.', 'S'),
])

INTRO = ('<p class="lede">VM-44, the note’s designer. The Write surface end to end at phone-right sizes: a note at rest, what its chips open, writing with the keyboard up, Return and backspace (NT-1, NT-2), '
         'the block menu as one table, receipts by the thumb, the note’s menu, the blocks list with reordering, this note’s tray, the long note, a sealed note, and find. '
         'Frames read left to right; the caption under each says what she did to get there and what each control does.</p>'
         '<p class="note"><b>Starting points, kept swappable.</b> The bar is the LK-4 / LK-3 sketch’s pick and the masthead is the NT-5 sketch’s; she has not ruled on either. '
         'Captions tagged <span class="cap"><span class="id q">brown</span></span> are an open question’s other answer; <span class="cap"><span class="id pick">green</span></span> is my pick; '
         '<span class="cap"><span class="id new">dark green</span></span> is a state (empty, loading, refusal, largest text). Nothing here says how the editor works inside; these are faces and flows over the existing brains.</p>')

BODY = A() + B() + C() + D() + E() + F() + G() + '<h2>Build notes</h2>' + NOTES + (
    '<p class="note" style="margin-top:14px"><b>Added to the sizing sheet’s vocabulary</b> (all at its sizes and inks): the glass receipt capsule and its refusal form; the bar’s place line (13 pt under a 15 pt title in the 48 pt bar); '
    'the block-list row (number · two preview lines · a 44 pt accessory); the pick circle, grip and drop line; the bulk bar; the calendar card; the switch; the system edit-menu capsule.</p>')

write('note-write.html', 'The note — Write, end to end', INTRO, BODY)
