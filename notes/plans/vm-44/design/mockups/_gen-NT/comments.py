# VM-44 mockup — comments-and-callouts.html: NT-10 (marker and glyph placement), the comments sheet, the callout chooser.
from base import *

CO = 'For a moment he had staggered and nearly fallen, but the brandy brought a tinge of colour into his cheeks.'
ONE = 'Most of what is in it I did not write.'
B2S = 'To Sherlock Holmes she is always <i>the</i> woman. In his eyes she eclipses and predominates the whole of her sex.'
FORK = I_FORK
CMT = I_CMT
SAND = {'lt': '#F7F1DE', 'dk': '#262012'}


def hit(style):
    return '<span class="hit44" style="position:absolute;%s"></span>' % style


def nt10(mode, dark=False):
    def a_block(text, takes=0, cm=0, m0=False):
        t = text + ('&nbsp; ' + mk(cm, 'c') if cm else '')
        tk = '<span style="position:absolute;right:-8px;top:4px">%s</span>' % mk(takes) if takes else ''
        return '<div class="blk" style="%s%s"><p>%s</p>%s</div>' % ('padding-right:36px;' if takes else '', 'margin:0' if m0 else '', t, tk)

    def b_block(text, takes=0, cm=0, m0=False, top=5):
        g = ''
        if takes:
            g += '<span style="color:var(--accent);display:flex">%s</span>' % FORK
        if cm:
            g += '<span style="color:var(--commentInk);display:flex">%s</span>' % CMT
        return '<div class="blk" style="%s"><p>%s</p><span class="mkg" style="top:%dpx">%s</span></div>' % ('margin:0' if m0 else '', text, top, g)

    def c_block(text, takes=0, cm=0, under=False, m0=False):
        m = (mk(takes) if takes else '') + (mk(cm, 'c') if cm else '')
        return blk(text, m, under=under, style='margin:0' if m0 else '')

    if mode == 'a':
        body = (a_block(B1, 3, 1) + a_block(B2S, 0, 2) + '<div class="callout">%s</div>' % a_block('<span class="gin">⚓</span>' + CO, 4, m0=True) +
                a_block(ONE, 2, 1) + a_block(B4))
        over = hit('left:356px;top:237px;width:44px;height:44px') + hit('left:164px;top:288px;width:44px;height:44px')
    elif mode == 'b':
        body = (b_block(B1, 3, 1) + b_block(B2S, 0, 2) + '<div class="callout"><span class="gl">⚓</span>%s</div>' % b_block(CO, 4, m0=True, top=32) +
                b_block(ONE, 2, 1) + b_block(B4))
        over = hit('left:0;top:235px;width:44px;height:44px') + hit('left:0;top:281px;width:44px;height:24px;outline-color:#C2410C')
    else:
        body = (c_block(B1, 3, 1, under=True) + c_block(B2S, 0, 2) + '<div class="callout"><span class="gl">⚓</span>%s</div>' % c_block(CO, 4, under=True, m0=True) +
                c_block(ONE, 2, 1) + c_block(B4))
        over = hit('left:308px;top:293px;width:88px;height:44px') if not dark else ''
    ph = phone(topbar(), page(body, mast_html=mast(), pad='10px'), over=fade(0, 60) + over, dark=dark)
    return ph


def A():
    return section(
        'A — NT-10: where the comment marker, the takes mark and the callout glyph sit',
        'The same five blocks under each answer: a fanned, commented block whose last line is full; a commented block; a callout with a glyph and four takes; a one-line block with both marks; a plain block. '
        'The phone’s gutter is 20 pt (the Mac’s is the width of a margin). Dashed green is a 44 pt hit area; dashed orange is one that cannot be had.',
        row(frame(nt10('a'), 'NT-10 (a)', 'Today’s places, at the new sizes.',
                  'The takes mark rides the first line’s trailing edge and the comment count follows the last word; the callout glyph leads the text. '
                  'Cost: every fanned block is set 36 pt narrower to make room (visible in the first and fourth blocks), the comment count pushes a full last line onto a new one, and the glyph indents the callout’s first line. '
                  'That is three ways a decoration moves her prose, which is the one thing the Mac’s rule forbids. The takes target also sits at the far edge, away from the comment’s.', 'q'),
            frame(nt10('b'), 'NT-10 (b)', 'The Mac’s rule: everything in the leading gutter.',
                  'Marks stack down the left gutter from the block’s first line and the measure never moves. Cost at phone width: a 20 pt gutter holds a 15 pt glyph and no count, so three takes and nine look the same; '
                  'the 44 pt hit area has to reach 24 pt into the first letters of the line, where she taps to place the caret; a second mark 22 pt below it cannot have its own 44 pt (orange); '
                  'and the whole lane lies in the system’s back-swipe edge.', 'q'),
            frame(nt10('c'), 'NT-10 (c)', 'One cluster at the block’s trailing foot; the glyph in the gutter.',
                  'What she presses and what she only reads are split. The marks she presses (takes, comments) sit together at the end of the block: in the last line’s free space when there is some, '
                  'just under it when the line is full. They carry their counts, share one 88 × 44 pt area clear of every edge gesture, and are always in the same place. '
                  'The callout glyph, which is only read, follows the Mac’s rule and sits in the gutter inside the wash. The measure and the left edge never move; the only cost is 20 pt more air under a marked block whose last line is full.', 'pick'),
            frame(nt10('c', dark=True), 'NT-10 (c) dark', 'The pick in dark.', 'The callout’s wash is the palette’s dark sand; marks keep the accent and the comment ink.')))


# ---------------------------------------------------------------- B. comments
def cc(text, date, cls='', acts=None):
    more = '<span class="more">%s</span>' % ib(I_MORE, 'mut')
    if acts is not None:
        return ('<div class="ccard %s"><div class="tx" style="padding-right:10px">%s</div><div style="display:flex;align-items:center;justify-content:space-between;height:44px">'
                '<span class="dt" style="height:auto;margin:0">%s</span><span style="display:flex;align-items:center">%s</span></div></div>' % (cls, text, date, acts))
    return '<div class="ccard %s"><div class="tx">%s</div><div class="dt">%s</div>%s</div>' % (cls, text, date, more)


C1 = cc('Find the Montaigne quote for this paragraph.', 'Jul 25, 2026 at 10:00 AM')
C2 = cc('Too neat? The winter detail might be doing all the work.', 'Nov 3, 2026 at 8:40 PM')
DRAFT_TXT = 'Check the 1580 edition for the wording — I think it’s “borrowed” not'


def draft(text='', go=False, ph='Write a comment…'):
    f = '<span class="fld">%s</span>' % text if text else '<span class="fld ph">%s</span>' % ph
    return '<div class="draft">%s<span class="add%s">Add</span></div>' % (f, ' go' if go else '')


def page_behind():
    return topbar() + page(blk(B1, mk(3) + mk(2, 'c'), under=True) + blk(B2) + blk(B3) + blk(B4), mast_html=mast(), pad='10px')


def csheet(top, body, foot, meta='Block 1 of 4 · I started copying sentences…', kb=False, title='Comments'):
    s = sheet(top, title, body, meta=meta, foot=foot)
    if kb:
        s = s.replace('class="sheet" style="', 'class="sheet" style="bottom:327px;border-radius:28px 28px 0 0;')
    return s


def B():
    kb = kbd().replace('class="kb-abs"', 'class="kb-abs" style="z-index:9"')
    safe = '<div style="height:30px;background:var(--room);flex:none"></div>'
    b1 = phone(page_behind(), over=dimmer() + csheet(330, gap8() + C1 + C2 + '<div style="flex:1"></div>', draft() + safe))
    b2 = phone(page_behind(), over=dimmer() + csheet(70, gap8() + C1 + C2 + '<div style="flex:1"></div>', draft(DRAFT_TXT + CARET, go=True), kb=True) + kb)
    kept = '<div class="kept"><span>Not added yet — kept from before</span><span class="tbtn sm" style="height:32px">Discard</span></div>'
    b3 = phone(page_behind(), over=dimmer() + csheet(330, gap8() + C1 + C2 + '<div style="flex:1"></div>', kept + draft(DRAFT_TXT, go=True) + safe))
    ed = ('<div class="ccard ed"><div class="tx" style="padding-right:10px">Find the Montaigne quote for this paragraph — the one about borrowing%s</div>'
          '<div style="display:flex;justify-content:flex-end;height:44px;align-items:center"><span class="tbtn sm">Cancel</span><span class="tbtn sm s">Save</span></div></div>' % CARET)
    b4 = phone(page_behind(), over=dimmer() + csheet(70, gap8() + ed + C2 + '<div style="flex:1"></div>', '', kb=True) + kb)
    fold = '<div style="display:flex;align-items:center;height:44px;padding:0 20px;font:600 15px/20px var(--chrome);color:var(--muted2)">▾ Deleted (2)</div>'
    racts = '<span class="tbtn sm s">Restore</span>' + ib(I_MORE, 'mut')
    rc = ('<div style="margin:0 16px 10px;padding:10px 12px;border-radius:12px;background:var(--wash);font:400 15px/20px var(--chrome)">Comment deleted — it’s under Deleted below, restorable.</div>')
    b5 = phone(page_behind(), over=dimmer() + csheet(70, gap8() + rc + C1 + fold + cc('Too neat? The winter detail might be doing all the work.', 'deleted just now', 'del', racts) +
                                                    cc('Cut this whole opening.', 'deleted Nov 9', 'del', racts) + '<div style="flex:1"></div>', draft() + safe, meta='Block 1 of 4 · I started copying sentences…'))
    b6 = phone(page_behind(), over=dimmer() + csheet(70, gap8() + C1 + fold + cc('Too neat? The winter detail might be doing all the work.', 'deleted just now', 'del', racts) +
                                                    cc('Cut this whole opening.', 'deleted Nov 9', 'del', racts) + '<div style="flex:1"></div>', draft() + safe) +
               '<div class="dimmer" style="z-index:8"></div>' + alert(300, 'Delete this comment forever?', 'It leaves every device, and there’s no putting it back.', (('Delete forever', 'al'), ('Cancel', ''))))
    emp = ('<div style="flex:1;display:flex;align-items:center;justify-content:center;padding:0 40px"><span class="t-ctl2" style="color:var(--muted2)">No comments on this block yet.</span></div>')
    b7 = phone(page_behind(), over=dimmer() + csheet(560, emp, draft() + safe, meta='Block 2 of 4 · To Sherlock Holmes she is always…'))
    sealed = ('<div style="flex:none;padding:12px 20px 14px;background:var(--room);border-top:1px solid var(--line);font:400 15px/20px var(--chrome);color:var(--ink);display:flex;gap:10px;align-items:center">'
              '<span style="color:var(--muted2);display:flex;width:20px">%s</span>This note is sealed — unseal it to change comments.</div>' % I_SEAL)
    b8 = phone(page_behind(), over=dimmer() + csheet(430, gap8() + C1 + '<div style="flex:1"></div>', sealed + safe))
    b9 = phone(page_behind(), over=dimmer() + csheet(70, gap8() + C1 + '<div style="flex:1"></div>', draft('Check the 1580 edition' + CARET, go=True), kb=True, meta='Block 1 of 4') + kb, cls='xxl')
    b10 = phone(page_behind(), over=dimmer() + csheet(330, gap8() + C1 + C2 + '<div style="flex:1"></div>', draft() + safe), dark=True)
    return section(
        'B — the comments sheet', 'Comments belong to the block, never to a take. The sheet opens from the block’s comment mark or from Comments in the block menu. '
        'It is a native sheet, so the keyboard is the system’s to avoid: the field you type in is pinned to the sheet’s foot and rides above the keyboard.',
        row(frame(b1, 'B1', 'She taps the comment mark under the first block.',
                  'A sheet at the height it needs, the page still visible above it. Each comment is a card on the comment tint: her words at 17 pt, the date at 13 pt, one 44 pt ⋯ (Edit · Delete). '
                  'Tapping a comment’s words edits it in place (B4), the Mac panel’s one-writing-surface grammar. The field at the foot says “Write a comment…” (the Mac’s placeholder, laid out by the field itself, so it sits at the text origin).'),
            frame(b2, 'B2 · keyboard up', 'She taps the field and types.',
                  'The sheet rises to full height and its foot sits on the keyboard, so the field is always in view; it grows to four lines, then scrolls. Add turns solid once there are words. '
                  'Return makes a new line; Add files the comment. The comments above scroll under the header.'),
            frame(b3, 'B3 · the draft is kept', 'She swiped the sheet away mid-sentence, then came back.',
                  'NT-11 (a): any close keeps the draft, whether Done, a swipe down, a tap outside, or the app leaving the screen. Reopening the block’s comments puts the words back in the field with one quiet line saying they are not added yet, and Discard to drop them. '
                  'Keeping never files: the page’s count still reads 2. The kept line’s words are a proposal (the Mac says “Unsaved · ⌘⏎”).', 'pick'),
            frame(b4, 'B4', 'She taps a comment’s words.',
                  'The card becomes the editor, ringed, with Cancel and Save beneath it (the Mac’s words). Emptying it says “A comment needs some text — Delete removes it.” An edit left unfinished is kept the same way a draft is.'),
            frame(b5, 'B5', 'She deletes a comment from its ⋯.',
                  'It moves under “Deleted (2)”, a fold that opens here, and the Mac’s receipt says so. A deleted comment is muted, with Restore at 44 pt on its row and its ⋯ holding only “Delete forever…”, '
                  'so restoring and destroying are never neighbours. Restore answers “Comment restored.”'),
            frame(b6, 'B6 · confirm', 'She taps Delete forever….', 'The Mac’s confirm, word for word. The destroying choice is in the alarm ink; Cancel is the default.', 'new'),
            frame(b7, 'B7 · empty', 'Comments on a block that has none.', 'A short sheet: the build’s empty line and the field. Opening it from the block menu on a block with no comments lands here, ready to type.', 'new'),
            frame(b8, 'B8 · refusal', 'Comments on a block in a sealed note.',
                  'She can read them. The field is replaced by the Mac’s sentence; nothing can be added, edited or deleted until the note is unsealed.', 'new'),
            frame(b9, 'B2 at the largest text size', 'Typing a comment at xxxLarge.',
                  'Her words in the cards and the field are 23 pt and keep scaling into the accessibility sizes; the date, the header and Add stop at xxxLarge. The field still clears the keyboard because it is pinned to the sheet, not placed by hand.', 'new'),
            frame(b10, 'B1 dark', 'The sheet in dark.', 'Cards use the dark comment tint (#201C12) with the comment ink for dates.')))


def gap8():
    return '<div style="height:4px;flex:none"></div>'


# ---------------------------------------------------------------- C. callouts
COLS = [('blue', '#E8F1F8', '#14202B'), ('green', '#EAF3E7', '#17251A'), ('sand', '#F7F1DE', '#262012'), ('violet', '#EFEAF6', '#1F1A2A'), ('rose', '#F8ECEC', '#2A1A1C')]


def callout_page(colour_i=2, glyph='⚓', dark=False, on=True, extra_blocks='', pad='14px'):
    hexv = COLS[colour_i][2 if dark else 1]
    co = ('<div class="callout" style="background:%s">%s<div class="blk" style="margin:0"><p>%s</p></div></div>'
          % (hexv, '<span class="gl">%s</span>' % glyph if glyph else '', CO)) if on else blk(CO)
    return topbar(TITLE, 'block 3 of 5') + page(blk('other name. In his eyes she eclipses and predominates the whole of her sex.') + co + extra_blocks + blk(B3) + blk(B4), pad=pad)


def chooser(sel=2, glyph='⚓', dark=False, foc=False):
    sw = ''.join('<div class="%s"><i style="background:%s">Aa</i>%s</div>' % ('on' if i == sel else '', c[2 if dark else 1], c[0]) for i, c in enumerate(COLS))
    body = (mrow(I_CALLOUT, 'Callout', trail=tog(True), cls='last') + sech('Colour', tight=True) + '<div class="sw5">%s</div>' % sw +
            sech('Glyph', tight=True) +
            '<div style="display:flex;align-items:center;gap:12px;padding:0 16px 0 20px"><span class="glf%s">%s%s</span>'
            '<span class="t-meta" style="flex:1">One glyph beside the block. Leave it empty for none.</span><span class="tbtn sm">Clear</span></div><div style="flex:1"></div>'
            % (' foc' if foc else '', glyph, CARET if foc else ''))
    return body


def C():
    c1 = phone(callout_page(), over=dimmer().replace('class="dimmer"', 'class="dimmer" style="background:transparent"') + sheet(486, 'Callout', chooser()))
    c2 = phone(callout_page(3), over=sheet(486, 'Callout', chooser(sel=3)))
    emo = ''.join('<div style="font:400 28px/44px var(--chrome);text-align:center">%s</div>' % e for e in '⚓🪶📌💡🔥🌿⭐🧭📎🌙☕🔑🌵🎈🧩🔔🌊🍂📚🎯🧠❓❗🍋')
    ekb = ('<div class="kb-abs" style="z-index:9"><div class="kbd" style="height:327px;padding:8px 10px 0"><div class="t-meta" style="padding:2px 6px 6px;color:var(--keyink);opacity:.6">Frequently used</div>'
           '<div style="display:grid;grid-template-columns:repeat(8,1fr)">%s</div></div></div>' % emo)
    c3 = phone(callout_page(3, glyph='🪶', pad='0px'), over=sheet(212, 'Callout', chooser(sel=3, glyph='🪶', foc=True)).replace('class="sheet" style="', 'class="sheet" style="bottom:327px;') + ekb)
    two = ('<div class="callout" style="background:#14202B"><div class="blk" style="margin:0"><p>Most of what is in it I did not write. That is the point of it.</p></div></div>')
    c4 = phone(callout_page(2, dark=True, extra_blocks=two), dark=True, over=fade(0, 60))
    return section(
        'C — the callout chooser', 'Callout in the block menu opens one small sheet instead of a submenu of near-white squares and a separate emoji alert. The block changes behind the sheet as she chooses.',
        row(frame(c1, 'C1', 'She taps Callout in the block menu.',
                  'One switch turns the frame on and off (today’s “Toggle Callout” and “Remove Callout” were two rows for one thing). Colour: the five theme colours as swatches large enough to compare, each showing its real wash with ink on it and its name beneath; the chosen one is ringed. '
                  'Glyph: one field holding the one glyph. There is one kind of frame today (callout), so there is no kind row; a second kind would be a row above Colour. The sheet does not dim the page, so the block is seen changing.'),
            frame(c2, 'C2', 'She taps violet.', 'The block behind takes the violet wash at once; nothing else to confirm. Colours are theme token names, never stored values, so they follow the palette and dark.'),
            frame(c3, 'C3 · keyboard up', 'She taps the glyph field.',
                  'The emoji keyboard opens straight away and the sheet rides above it. The field takes one grapheme: picking another replaces it; Clear empties it. The glyph appears in the block’s gutter as she picks.', 'new'),
            frame(c4, 'Callouts in dark', 'Two callouts on the dark page.', 'Sand with a glyph and blue without, on the palette’s dark washes. Takes and comments share one frame: the wash belongs to the block.')))


NOTES = notes_table([
    ('NT-10 · marks on the page', 'W-170; W-136’s marker door; grade 2’s cross-cutting 8 (three marker styles become one)', 'MobileBlockDecor, MobileTakesChrome (the phone’s faces); the marks’ geometry reads the laid-out block as today',
     'The foot cluster; counts; the glyph in the gutter', 'Decorations stay off the live storage. The measure and the left edge never move for a mark (pin it, as the Mac pins each surface). The cluster is drawn only for blocks on screen (P1, P3). 44 pt hit areas; VoiceOver labels (“3 takes”, “2 comments”).', 'S'),
    ('B1–B10 · the comments sheet', 'W-148 (comments third), W-165 (VM-18, NT-11), W-166 (VM-14), W-167, W-168, W-169', 'MobileComments; Shared CommentDraftPark (already parks refused drafts); Core add / edit / delete / restore / purgeBlockComment; the Mac’s CommentComposition once hoisted',
     'A native sheet with the field pinned to its foot; edit in place; the kept line', 'Every close parks the draft, per block; keeping never files and never changes the count. The field is laid out by the sheet (no hand-placed frames), which is what removes the under-the-keyboard defect and the misplaced placeholder together. Restore and Delete forever never share an edge. All writes refuse under a seal in the Mac’s words.', 'M'),
    ('C1–C4 · the callout chooser', 'Sizes for C7 (grade 2 screen 6); W-139’s palette fork retired', 'MobileCallout; Core BlockPresentation and updateBlockPresentation; the callout palette hoisted to one shared table of token names', 'One sheet replacing a submenu and an alert',
     'Colour is a token name. One grapheme only. The update is the op’s read-modify-write; a no-op writes nothing. Under a seal the sheet does not open; the refusal is the Mac’s.', 'S'),
])

INTRO = ('<p class="lede">VM-44, the note’s designer. Three things: where a block’s marks and a callout’s glyph sit on a page with a 20 pt gutter (NT-10, three answers side by side), '
         'the comments sheet with the keyboard up and a draft that survives any close (NT-11), and the callout chooser. Frames read left to right.</p>'
         '<p class="note">Seeded content: Essays ▸ “On keeping a commonplace book” (first block: three takes, comments). The callout paragraph is the seeded sand callout with its ⚓.</p>')

BODY = A() + B() + C() + '<h2>Build notes</h2>' + NOTES + (
    '<p class="note" style="margin-top:14px"><b>Added to the sizing sheet’s vocabulary</b>: the comment card (comment tint, 17 pt prose, 13 pt date in the comment ink); the pinned draft field with its Add button; '
    'the kept-draft line; the colour swatch (56 × 44, the real wash, its name at 13 pt); the one-glyph field. The marks themselves are the sheet’s own (18 pt glyph, 13 pt semibold count, 44 pt hit area).</p>')

write('comments-and-callouts.html', 'The note — comments and callouts', INTRO, BODY)
