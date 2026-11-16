# VM-44 mockup — compare-concept.html: Compare on the phone. A CONCEPT, to be built after v1 (W-186, W-177, SC-1).
# REVISED after sitting 1: the order is ruled — two takes of one block first, then her idea (notes as tabs, lined up block by block).
# The two other shapes (one column, the quick flip) are no longer drawn.
# Draft working record, not canon.
from base import *

MORE_CSS = r"""
/* ---- added for the compare concept (in the sizing sheet's spirit; listed in the notes) ---- */
h1 .concept{display:inline-block;background:#8A4B12;color:#fff;border-radius:8px;padding:3px 12px;font:650 14px/20px -apple-system,Arial,sans-serif;margin-left:12px;vertical-align:4px;letter-spacing:0}
.ctabs{display:flex;height:44px;background:var(--room);padding:0 12px;flex:none;position:relative}
.ctabs div{flex:1;min-width:0;padding:0 4px;text-align:center;font:400 15px/42px var(--chrome);color:var(--muted2);white-space:nowrap;overflow:hidden;text-overflow:ellipsis}
.ctabs div.on{font-weight:600;color:var(--ink)}
.ctabs div.plus{flex:none;width:44px;padding:0;color:var(--accent);display:flex;align-items:center;justify-content:center}
.ctabs div.plus svg{width:20px;height:20px}
.ctabs div svg{width:14px;height:14px;vertical-align:-2px;margin-right:4px}
.ctabs i.ind{position:absolute;bottom:0;height:3px;border-radius:2px 2px 0 0;background:var(--accent)}
.cpage{flex:1;background:var(--paper);position:relative;overflow:hidden;border-top:1px solid var(--line)}
.cpage .pg{position:absolute;top:0;bottom:0;width:402px;padding:16px 20px 0;background:var(--paper)}
.cpage .pg.seam{box-shadow:-1px 0 0 var(--line)}
.arow{display:grid}
.arow>.ac{grid-area:1/1;min-width:0;display:flex;flex-direction:column}
.arow>.ac.hid{visibility:hidden}
.blk.chg:before,.blk.only:before{content:"";position:absolute;left:-12px;top:5px;bottom:5px;width:3px;border-radius:2px;background:var(--accent)}
.blk.only{background:var(--takeTint);box-shadow:0 0 0 6px var(--takeTint);border-radius:4px}
.blk.only:before{left:-13px;top:-1px;bottom:-1px}
.olab{display:block;font:500 13px/18px var(--chrome);color:var(--accent);margin-top:2px}
.gapbox{flex:1;min-height:44px;margin:0 0 14px;border:1.5px dotted var(--seam);border-radius:12px;display:flex;align-items:center;justify-content:center;font:400 13px/18px var(--chrome);color:var(--muted2)}
.gapbox.quiet{border-color:transparent;color:transparent}
.gapbox.tapd{background:rgba(59,106,89,.10);border-color:var(--accent);border-style:solid;box-shadow:none;border-radius:12px}
.gapline{display:flex;align-items:center;gap:10px;height:30px;margin:-4px 0 12px;font:400 13px/18px var(--chrome);color:var(--muted2);white-space:nowrap}
.gapline:before,.gapline:after{content:"";flex:1;border-top:1.5px dotted var(--seam)}
.tapd{background:rgba(59,106,89,.12);box-shadow:0 0 0 6px rgba(59,106,89,.12);border-radius:4px}
.dk .tapd{background:rgba(144,193,175,.16);box-shadow:0 0 0 6px rgba(144,193,175,.16)}
.wchip{height:48px;border-radius:24px;padding:0 18px 0 16px;display:inline-flex;align-items:center;gap:6px;font:500 17px/22px var(--chrome);background:var(--glass);
  box-shadow:0 0 0 1px var(--glassEdge),0 4px 16px rgba(0,0,0,.14);color:var(--muted2);flex:none;white-space:nowrap}
.wchip.on{color:var(--accent);background:var(--wash)}
.wchip svg{width:18px;height:18px}
.gcap .lab{padding:0 4px;font:500 15px/20px var(--chrome);white-space:nowrap;font-variant-numeric:tabular-nums}
.nrel{flex:none;background:var(--room);padding:2px 20px 10px;font:400 13px/18px var(--chrome);color:var(--muted2);text-align:center}
.fcol.sm{width:262px}
.fcol.sm .phone{zoom:.652}
.src{display:block;font:600 13px/18px var(--chrome);color:var(--muted2);margin:0 0 2px;white-space:nowrap;overflow:hidden;text-overflow:ellipsis}
.pairb{background:var(--takeTint);box-shadow:0 0 0 6px var(--takeTint);border-radius:4px}
.holdb{height:52px;border-radius:26px;flex:1;display:flex;align-items:center;justify-content:center;gap:8px;font:500 17px/22px var(--chrome);color:var(--ink);background:var(--glass);
  box-shadow:0 0 0 1px var(--glassEdge),0 4px 16px rgba(0,0,0,.14);white-space:nowrap;overflow:hidden}
.holdb.down{background:var(--accent);color:var(--paper);transform:scale(.97)}
.holdb svg{width:20px;height:20px}
.lrow{background:var(--paper)}
.cnt{font:400 13px/18px var(--chrome);color:var(--muted2);padding:0 14px 10px}
ul.plainl{max-width:1000px;margin:6px 0 6px 0;padding-left:20px;color:#3b3832;font-size:13.5px;line-height:1.55}
ul.plainl b{font-weight:650;color:#24221E}
ul.plainl i.w{font-style:normal;background:#EFE7D2;border-radius:4px;padding:0 4px}
h3{max-width:1000px}
.xxl .ctabs div{font-size:21px}
.xxl .olab,.xxl .gapbox{font-size:19px;line-height:24px}
.xxl .wchip{font-size:21px}
.xxl .gcap .lab{font-size:19px}
"""

I_HAND = ic('M7 10V4.5a1.5 1.5 0 0 1 3 0V9M10 9V3.5a1.5 1.5 0 0 1 3 0V9M13 9V5a1.5 1.5 0 0 1 3 0v7a5 5 0 0 1-5 5h-1a5 5 0 0 1-4.3-2.5L3 10.5a1.4 1.4 0 0 1 2.3-1.5L7 11')
I_SWAP = ic('M4 7h12M13 4l3 3-3 3M16 13H4M7 10l-3 3 3 3')

TA = 'On keep…place book'
TB = 'On keep…book — talk'
TA3, TB3 = 'On…book', 'On…— talk'
TC = I_SEAL + 'Nov 10'


def T(s, on=True):
    return s.replace('[[', '<span class="wash-add">' if on else '').replace(']]', '</span>' if on else '')


# The two notes. The essay, and the duplicate she cut down for a talk. Each row: (kind, text) per note.
E1 = 'I started copying [[sentences]] into a notebook the winter I stopped trusting my memory [[for them]].'
K1 = 'I started copying [[lines]] into a notebook the winter I stopped trusting my memory.'
S2 = 'To Sherlock Holmes she is always <i>the</i> woman. I have seldom heard him mention her under any other name.'
E3 = ('It was not that he felt any emotion akin to love for Irene Adler. [[All emotions, and that one particularly, were abhorrent to his cold, precise but admirably balanced mind.]] '
      'He was[[, I take it,]] the [[most perfect]] reasoning and observing machine that the world has seen[[, but as a lover he would have placed himself in a false position]].')
K3 = 'It was not that he felt any emotion akin to love for Irene Adler. He was the [[finest]] reasoning and observing machine that the world has seen.'
E4 = 'He never spoke of the softer passions, save with a gibe and a sneer. They were admirable things for the observer.'
K5 = 'So I keep the notebook. Thank you. I would love your questions.'
ROWS = [(('chg', E1), ('chg', K1)),
        (('same', S2), ('same', S2)),
        (('chg', E3), ('chg', K3)),
        (('only', E4), ('gap', '')),
        (('gap', ''), ('only', K5))]
# a third note: a saved version from Nov 10 (three blocks, one of them moved)
V1 = 'I started copying [[lines]] into a notebook the winter I stopped trusting my memory [[for them]].'
V3 = 'It was not that he felt any emotion akin to love for Irene Adler. He was, I take it, the most perfect reasoning and observing machine that the world has seen.'
ROWS3 = [r + (c,) for r, c in zip(ROWS, [('chg', V1), ('moved', S2), ('chg', V3), ('gap', ''), ('gap', '')])]

GAPW = drs('2 · A3', 'Not in this note', 'Says a block is missing from the note on this tab.')
ONLYW = drs('2 · A1', 'Only in this note', 'Marks a block the other note does not have.')
for _f, _l, _w in [
        ('1 · T1, 2 · A1', 'Changes', 'Chip that turns the change marks on and off.'),
        ('2 · A9', 'Moved', 'Marks a block that sits in a different place in this note.'),
        ('2 · A3 alt', '1 block not in this note', 'One-line form of a missing block (the open CMP-1 alternative).'),
        ('2 · A5', 'Copy to the other note', 'Block menu: adds these words as a take on the matching block.'),
        ('2 · A5, A7', 'Open this note', 'Leaves Compare and opens the note at this block.'),
        ('2 · A5', 'Copy text', 'Block menu: copies the block’s words.'),
        ('2 · A6', 'Show it', 'On an empty place: goes to the note that has the block.'),
        ('2 · A6', 'Copy it here', 'On an empty place: would copy the block into this note (open, CMP-2).'),
        ('2 · A7', 'Add a note…', 'Adds a third tab.'),
        ('1 · T2', 'against chosen', 'Switch in the takes sheet: wash each take against the chosen one.'),
        ('1 · T2', '5 changes', 'Count under a washed take.'),
        ('3 · D1', 'Compare with…', 'Row in the note’s menu: opens the picker.'),
        ('3 · D2', 'Search notes', 'Placeholder in the picker.'),
        ('3 · D2', 'Saved versions', 'Picker section: the note’s saved versions.'),
        ('3 · D2', 'Recent notes', 'Picker section.'),
        ('3 · D4', 'Go to this block', 'Row on a lineage member’s menu.')]:
    drs(_f, _l, _w)


def cell(kind, text, on=True, tap=False, gap_tap=False):
    if kind == 'gap':
        return '<div class="gapbox%s%s">%s</div>' % ('' if on else ' quiet', ' tapd' if gap_tap else '', GAPW)
    cls = {'same': '', 'chg': 'chg', 'only': 'only', 'moved': 'chg'}[kind] if on else ''
    lab = ''
    hide = '' if on else ' style="visibility:hidden"'
    if kind == 'only':
        lab = '<span class="olab"%s>%s</span>' % (hide, ONLYW)
    if kind == 'moved':
        lab = '<span class="olab"%s>Moved</span>' % hide
    return '<div class="blk %s%s"><p>%s%s</p></div>' % (cls, ' tapd' if tap else '', T(text, on), lab)


def pg(show, on=True, rows=ROWS, left=0, tap=None, seam=False):
    out = ''
    for i, r in enumerate(rows):
        cells = ''
        for j, (kind, text) in enumerate(r):
            hit = (tap == i and j == show)
            cells += '<div class="ac%s">%s</div>' % ('' if j == show else ' hid', cell(kind, text, on, tap=hit and kind != 'gap', gap_tap=hit and kind == 'gap'))
        out += '<div class="arow">%s</div>' % cells
    return '<div class="pg%s" style="left:%dpx"><div class="t-body">%s</div></div>' % (' seam' if seam else '', left, out)


def tabs(names, at=0.0, plus=False):
    n = len(names)
    w = (378 - (44 if plus else 0)) / n
    cur = int(round(at))
    cells = ''.join('<div class="%s">%s</div>' % ('on' if (i == cur and abs(at - cur) < .01) else '', nm) for i, nm in enumerate(names))
    if plus:
        cells += '<div class="plus">%s</div>' % I_PLUS
    ind = '<i class="ind" style="left:%dpx;width:%dpx"></i>' % (12 + 8 + at * w, w - 16)
    return '<div class="ctabs">%s%s</div>' % (cells, ind)


def footbar(on=True, count='1 of 4', bottom=26):
    chip = '<span class="wchip%s">%sChanges</span>' % (' on' if on else '', I_CHECK if on else '')
    step = ('<span class="gcap">%s<span class="lab">%s</span>%s</span>' % (gc(I_UP), count, gc(I_DOWN))) if (on and count) else '<span></span>'
    return '<div class="fbar" style="bottom:%dpx">%s%s</div>' % (bottom, chip, step)


def cbar(title='Compare'):
    return topbar(title, right=ib(I_MORE))


def cmp(show=0, on=True, names=(TA, TB), rows=ROWS, dark=False, cls='', over='', tap=None, count='1 of 4', plus=False, band='', foot=True, fadeh=120):
    page = '<div class="cpage">%s</div>' % pg(show, on, rows, tap=tap)
    f = (fade(0, fadeh) + footbar(on, count)) if foot else ''
    return phone(cbar(), tabs(list(names), show, plus), band, page, dark=dark, cls=cls, over=f + over)


def sframe(ph, fid, title, text, kind=''):
    return '<div class="fcol sm">%s<div class="cap"><span class="id %s">%s</span><b>%s</b> %s</div></div>' % (ph, kind, fid, title, text)


def gap(h=16):
    return '<div style="height:%dpx;flex:none"></div>' % h


def lrow(title, prev='', meta='', acc='', style='', title_cls='t-row'):
    p = '<div class="t-prev ell">%s</div>' % prev if prev else ''
    m = '<div class="t-meta">%s</div>' % meta if meta else ''
    return '<div class="lrow" style="%s"><div class="mid"><div class="%s ell">%s</div>%s%s</div>%s</div>' % (style, title_cls, title, p, m, acc)


# ---------------------------------------------------------------- A. her idea
def A():
    a1 = cmp(0)
    # mid-swipe: both pages on screen, the rows meeting across the seam
    mid = '<div class="cpage">%s%s</div>' % (pg(0, True, left=-190), pg(1, True, left=212, seam=True))
    a2 = phone(cbar(), tabs([TA, TB], .47), mid, over=fade(0, 120) + footbar(True, '1 of 4'))
    a3 = cmp(1)
    a4 = cmp(1, on=False)
    m5 = menu([('Copy to the other note', I_FORK), ('Open this note', I_PEN), None, ('Copy text', I_COPY)], 'left:56px;top:240px;width:290px')
    a5 = cmp(0, tap=0, over=m5)
    m6 = menu([('Show it', I_EYE), ('Copy it here', I_DOWN)], 'left:96px;top:478px;width:230px')
    a6 = cmp(1, tap=3, over=m6)
    m7 = menu([('Related blocks only', ''), ('Add a note…', I_PLUS), None, ('Open this note', I_PEN)], 'right:10px;top:104px;width:250px')
    a7 = cmp(0, over='<div class="dimmer" style="background:transparent"></div>' + m7)

    # CMP-1 alternative: no padding; a one-line marker where a block is missing
    nat = ('<div class="pg" style="left:0"><div class="t-body">%s%s%s<div class="gapline">1 block not in this note</div>%s</div></div>'
           % (cell('chg', K1), cell('same', S2), cell('chg', K3), cell('only', K5)))
    q1 = phone(cbar(), tabs([TA, TB], 1), '<div class="cpage">%s</div>' % nat, over=footbar(True, '1 of 4'))

    # no relationship
    SM = ['Nothing good was ever decided before the second coffee, and I have the minutes to prove it.',
          'The first hour belongs to whoever is awake for it. I give mine to the window and the kettle.',
          'By nine the day has opinions. Before that it only has weather.']
    unrel = '<div class="pg" style="left:0"><div class="t-body">%s</div></div>' % ''.join(blk(s) for s in SM)
    band = '<div class="nrel">There is no relationship here</div>'
    a8 = phone(cbar(), tabs([TA, 'The case for slow mornings'], 1), band, '<div class="cpage">%s</div>' % unrel)

    a9 = cmp(2, names=(TA3, TB3, TC), rows=ROWS3, plus=True, count='1 of 5')
    a10 = cmp(0, dark=True)
    a11 = cmp(0, names=(TA3, TB3), cls='xxl', fadeh=150)

    return section(
        '2 — then: her idea, the notes as tabs, lined up block by block',
        'Two notes, one tab each. Swipe sideways to change tabs; the page does not move up or down, so the same block sits at the same height in both. '
        'Here: the essay, and the copy she cut down for a talk.',
        row(frame(a1, 'A1', 'She opens Compare from the essay. The first tab is the note she came from.',
                  'The tabs are the two notes’ names; the current one is in ink with a bar under it. A bar at the left of a block means it is different in the other note; '
                  'the washed words are the ones that differ. The fourth block is washed whole: it is only in this note. '
                  'At the foot: <i class="w">Changes</i> turns the marks on and off; the arrows step to the next change. The pages are for reading; nothing here edits.'),
            frame(a2, 'A2', 'She swipes left. Mid-swipe.',
                  'The talk slides in. Each block meets its partner at the same height across the seam. The bar under the tabs follows her finger. '
                  'Only the page moves; the top bar, the tabs and the foot stay still.'),
            frame(a3, 'A3', 'The second tab: the talk.',
                  'Same heights. The third block is shorter here, so white space follows it and the next row still starts level. '
                  'The fourth block was cut from the talk: a dotted box holds its place and says <i class="w">Not in this note</i>. The last block is new in the talk. '
                  'Each tab washes its own words; nothing is struck through, so each page reads as the real note.'),
            frame(a4, 'A4', 'She taps Changes to turn the marks off.',
                  'A plain page. The blocks keep their places, so swiping still lines up; the box becomes plain white space. The choice is remembered for this compare.'),
            frame(a5, 'A5', 'She taps a block that differs.',
                  '<i class="w">Copy to the other note</i> adds these words as a take on the matching block there. It is never chosen for her and replaces nothing '
                  '(the Mac’s bring-back rule). Nothing is said; the block in the other tab now wears the takes badge. '
                  '<i class="w">Open this note</i> leaves Compare and opens this note at this block, ready to edit. With three notes, the first row asks which one.'))
        + row(frame(a6, 'A6 · CMP-2', 'On the talk, she taps the empty place.',
                  '<i class="w">Show it</i> swipes to the note that has the block. <i class="w">Copy it here</i> would put a copy in this note at this place. '
                  'No operation does that today (only Snippets copy into a note), so it is hers to rule before it is built.', 'q'),
              frame(q1, 'A3 alt · CMP-1', 'The other way to handle a missing block: no padding.',
                    'Each tab keeps its own natural length. A missing block is one line, and no white space follows a shorter block. '
                    'Less blank screen, but only the block at the top of the screen lines up when she swipes; the rest shift. '
                    'Drawn first is A3: the same place in every tab is the simpler promise, and it is her words. Still open (CMP-1).', 'q'),
              frame(a7, 'A7', 'She taps ⋯.',
                    '<i class="w">Related blocks only</i> (the Mac’s setting) hides everything that has no partner, so no boxes show. '
                    '<i class="w">Add a note…</i> adds a third tab. <i class="w">Open this note</i> opens the current tab’s note.'),
              frame(a8, 'A8 · state', 'Two notes that share no blocks.',
                    'The Mac’s own line, said once under the tabs. Each note keeps its own order and nothing is marked or padded. Swiping keeps the scroll position, nothing more. '
                    'There is no Changes button, because there is nothing to mark.', 'new'),
              frame(a9, 'A9 · state', 'Three notes; she is on a saved version.',
                    'With three, the names shorten further; ＋ adds another (the Mac allows four). A saved version wears the seal and its date. A block that sits in a different place in this note says '
                    '<i class="w">Moved</i> and stays in its row (the Mac marks it and never guesses). With three, every tab is marked against the first. Two notes come first.', 'new'))
        + row(frame(a10, 'A1 dark', 'The first tab in dark.', 'The bar, the washes and the chip use the dark palette’s accent and take tint.'),
              frame(a11, 'A1 · largest text', 'The first tab at the largest text size.',
                    'Her words scale; the rows still match because each row is as tall as its taller version. The tab names shorten in the middle. The foot stays two controls.', 'new')))


# ---------------------------------------------------------------- C. two takes of one block
def C():
    B1X = 'I [[copy]] sentences into a notebook [[because my memory stopped keeping them]].'
    B1WX = '[[That]] winter I [[began]] copying [[other people’s]] sentences into a [[little]] notebook[[, and it felt like keeping company]].'
    peek = '<div class="blk peek"><p>%s</p></div>' % T(B1X)
    pillh = ('<div class="fbar" style="bottom:26px"><span class="pill2"><span class="gc">%s</span><span class="lab">take 3/3 · shorter</span><span class="gc">%s</span>'
             '<span class="choose">%sChoose</span></span></div>' % (ic('M12.5 4 6.5 10l6 6', 2), ic('M7.5 4 13.5 10l-6 6', 2), I_CHECK))
    chip = '<div class="fbar" style="bottom:88px;justify-content:flex-start"><span class="wchip on">%sChanges</span></div>' % I_CHECK
    t1 = phone(topbar(), page(peek + blk(B2) + blk(B3) + blk(B4), mast_html=mast(), pad='10px'), over=fade(0, 190) + chip + pillh)

    def card(state, label, text, cnt='', chosen=False):
        st = '<span class="st">%s%s</span>' % (I_CHECK if chosen else '', state)
        c = '<div class="cnt">%s</div>' % cnt if cnt else ''
        return ('<div class="tcard%s"><div class="hd">%s<span class="lb">%s</span></div><div class="bd">%s</div>%s</div>'
                % (' chosen' if chosen else '', st, label, text, c))
    seg = '<div class="seg"><span>plain</span><span class="on">against chosen</span></div>'
    body = (seg + card('chosen', 'take 1 · original', B1, chosen=True) + card('take 2', 'warmer', T(B1WX), '5 changes') + card('take 3', 'shorter', T(B1X), '2 changes') +
            '<div style="flex:1"></div>')
    behind = topbar() + page(blk(B1) + blk(B2) + blk(B3) + blk(B4), mast_html=mast(), pad='10px')
    t2 = phone(behind, over=dimmer() + sheet(70, 'Takes', body, meta='I started copying sentences… · 3 takes'))
    return section(
        '1 — first: two takes of one block', 'Her ruling on the order: “Takes first, then tabs.” This is the Mac’s take diff, in the phone’s take grammar (W-177). It needs nothing moved into shared code and proves the washes on the phone.',
        row(frame(t1, 'T1', 'She swipes a block to peek another take, with Changes on.',
                  'The pill she already has (opened by a tap on the takes badge), plus one chip. On, the words that differ from the chosen take are washed. Off, the take is plain, as today. The chip is remembered.'),
            frame(t2, 'T2', 'The takes sheet, set to “against chosen”.',
                  'The History pane’s switch (<i class="w">plain · against now</i>), one word changed. Every other take is washed against the chosen one, with a count. '
                  'A take is often a full rewrite; then most of it is washed, which is honest but says little.')))


# ---------------------------------------------------------------- D. the doors
def D():
    behind = topbar() + page(blk(B1) + blk(B2) + blk(B3) + blk(B4), mast_html=mast(), pad='10px')
    g1 = (mrow(I_STAR, 'Star') + mrow(I_SEAL, 'Seal', det='Read-only until you unseal it', cls='last') + gap() +
          mrow(I_VERS, 'Save a version', det='Keeps the whole note as it is now') + mrow(I_HIST, 'Versions', val='2', chev=True) +
          mrow(I_SWAP, 'Compare with…', chev=True) + mrow(I_SWAP, 'Compare with latest version', cls='last') + gap() +
          mrow(I_LIST, 'Blocks', val='4', chev=True) + mrow(I_TRAY, 'This note’s tray', val='2', chev=True) + mrow(I_LINK, 'References', val='1', chev=True, cls='last') +
          '<div class="band" style="flex:1"></div>')
    d1 = phone(behind, over=dimmer() + sheet(70, 'Note', g1, meta='1,204 words · 4 blocks · edited today at 9:12 AM'))

    srch = '<div class="srch">%sSearch notes</div>' % I_FIND
    chev = ib(I_CHEV, 'mut')
    pick = (srch + sech('Versions of this note', tight=True) +
            lrow('On keeping a commonplace book — talk', 'I started copying lines into a notebook the winter I stopped…', 'Essays · Nov 11 · version of this note', chev) +
            sech('Saved versions') +
            lrow('Nov 12, 2026 at 9:12 AM', '', '4 blocks', chev) + lrow('Nov 10, 2026 at 4:30 PM', '', '3 blocks · saved for you', chev) +
            sech('Recent notes') +
            lrow('The case for slow mornings', 'Nothing good was ever decided before the second coffee, and I…', 'Essays · yesterday', chev) +
            lrow('Walk note: the ferry timetable changes in December', 'and the morning boat now leaves at seven forty. Tell M. before…', 'No book · today', chev) +
            '<div class="band" style="flex:1"></div>')
    d2 = phone(behind, over=dimmer() + sheet(70, 'Compare with', pick, right='Cancel'))

    expl = '<div class="expl" style="font-size:15px;line-height:20px">Whole moments of this note, saved by hand.</div>'
    rows = (lrow('Nov 12, 2026 at 9:12 AM', '', '4 blocks', ib(I_MORE, 'mut')) + lrow('Nov 10, 2026 at 4:30 PM', '', '3 blocks · saved for you', ib(I_MORE, 'mut')) + '<div class="band" style="flex:1"></div>')
    m3 = menu([('Read', I_EYE), ('Compare with now', I_SWAP), None, ('Restore', I_HIST), ('Promote', I_UP), ('Delete…', I_TRASH, 'al')], 'right:14px;top:330px;width:240px')
    d3 = phone(behind, over=dimmer() + sheet(70, 'Versions', expl + rows, meta=TITLE) + m3)

    def lin(verb, words, where, counts, acc=''):
        return ('<div class="lin"><div class="mid"><div class="vb">%s</div><div class="t-prev ell" style="color:var(--ink)">%s</div><div class="t-meta">%s · %s</div></div>%s</div>'
                % (verb, words, where, counts, acc))
    fam = ('<div class="seg"><span>Commits</span><span class="on">Lineage</span></div><div class="gen">this generation</div>' +
           lin('this block', 'I started copying sentences into a notebook the winter…', 'here', '3 takes · 1 commit') +
           '<div class="gen">came of it</div>' +
           lin('a version', 'I started copying lines into a notebook the winter…', 'in “On keeping a commonplace book — talk”', '1 take', ib(I_MORE, 'mut')) +
           '<div class="band" style="flex:1"></div>')
    m4 = menu([('Go to this block', I_CHEV), ('Compare with now', I_SWAP), ('Bring back as a take', I_FORK)], 'right:14px;top:420px;width:250px')
    d4 = phone(behind, over=dimmer() + sheet(70, 'History and lineage', fam, meta='I started copying sentences…') + m4)

    return section(
        '3 — where Compare is reached from, and how the second note is picked', 'Four doors, one act. Every door lands on A1 with the note she came from as the first tab.',
        row(frame(d1, 'D1', 'The note’s menu.',
                  'Two rows under Versions. <i class="w">Compare with…</i> opens the picker (D2). <i class="w">Compare with latest version</i> is the Mac’s one-press door; '
                  'it shows only while the note has a saved version.'),
            frame(d2, 'D2', 'She taps Compare with…',
                  'The Mac’s picker, as a sheet. The note’s own versions come first and say so (a duplicate is a version of the note it came from); then its saved versions by date; '
                  'then recent notes. Typing searches every note. One tap picks and opens Compare.'),
            sframe(d3, 'D3', 'A saved version’s ⋯ in Versions.', '<i class="w">Compare with now</i> (the Mac’s words) opens Compare with that version as the second tab. A saved version is sealed: it reads, it does not take copies.'),
            sframe(d4, 'D4', 'A duplicate’s link, in a block’s lineage.', 'A block that lives on in a duplicate shows as <i class="w">a version</i>. Its ⋯ gains <i class="w">Compare with now</i>: Compare opens on the two notes, scrolled to this block.')))


# ---------------------------------------------------------------- E. honest notes
HOIST = ('<table class="plain"><tr><th>Piece</th><th>Where it lives today</th><th>For the phone</th><th>Size</th></tr>'
         '<tr><td>PostAlignment</td><td>Mac only (<code>Features/Takes/TakesModels.swift</code>)</td>'
         '<td>Hoist as it is. It is pure: it pairs two notes’ blocks by lineage, never by order, and marks a moved block. Each row it returns is one lined-up position in A.</td><td>S</td></tr>'
         '<tr><td>CompareComposition</td><td>Mac only (<code>Features/Takes/CompareModels.swift</code>)</td>'
         '<td>Hoist as it is, with its pins. It decides which rows line up and which stretches run free (so unrelated runs share a row instead of a parade of gaps), and it holds “related blocks only”. Two notes use its one-peer case.</td><td>S</td></tr>'
         '<tr><td>LineDiff</td><td>Mac only (<code>Features/Takes/DiffView.swift</code>)</td>'
         '<td>Not needed for A or T. The washes inside a pair come from <code>Domain/TextCompare</code>, word-level and already in Core. Hoist LineDiff only if the phone wants “Ignore whitespace” or the diff saved as text.</td><td>S, later</td></tr>'
         '<tr><td>VersionCompareDoor</td><td>Mac only, tied to the Mac’s command router</td>'
         '<td>Do not hoist. The phone writes its own small door. Its words are already shared (<code>VersionsCopy</code>).</td><td>S</td></tr>'
         '<tr><td>The picker’s ranking (version peers first)</td><td>Mac only (<code>NotePickerSheet</code>’s source)</td><td>Hoist the query; draw the phone’s own sheet (D2).</td><td>S</td></tr>'
         '<tr><td>Already shared, nothing to do</td><td>Core</td>'
         '<td><code>Queries.blockKinship</code>, <code>versionPeers</code>, <code>lineagePeers</code>, <code>noteVersions</code>, <code>latestNoteVersionID</code>, <code>diffPair</code>; '
         '<code>Domain/TextCompare</code>; <code>Operations.bringBackFromLineage</code> (A5’s copy).</td><td>—</td></tr></table>')

NOTES = (
    '<h2>What it would take <small>the honest part</small></h2>'
    '<h3>What must move into shared code first</h3>' + HOIST +
    '<h3>What is easy</h3><ul class="plainl">'
    '<li><b>The pages.</b> Compare only reads, so no page holds a live editor (P3 holds without effort). The phone already draws a note’s blocks this way.</li>'
    '<li><b>The washes.</b> <code>TextCompare</code> is in Core and the History pane already draws them.</li>'
    '<li><b>The doors.</b> The words are shared; each door is one row.</li>'
    '<li><b>Takes against chosen (T).</b> Every brain is in Core and the peek exists. Size S.</li></ul>'
    '<h3>What is hard on a phone</h3><ul class="plainl">'
    '<li><b>Row heights.</b> A row is as tall as its tallest version, which is only known once both are laid out. Rows off screen are estimates, so a long note can shift under the thumb. '
    'The build must measure only the rows on screen (P1) and hold the top visible row still.</li>'
    '<li><b>Tall empty places.</b> A long block missing from one note leaves a third of the screen blank (CMP-1).</li>'
    '<li><b>The swipe.</b> It competes with the system’s back swipe at the left edge, and with the take peek, which is also a sideways swipe. Compare pages do not peek.</li>'
    '<li><b>Copying a block into another note.</b> No operation does it; only Snippets copy into a note today. Adding as a take on a matching block exists (CMP-2).</li>'
    '<li><b>A divide.</b> One block here can be two there; the row stacks the two. A moved block is marked, never guessed.</li>'
    '<li><b>More than two notes.</b> What each tab’s marks are measured against needs a rule (A9).</li>'
    '<li><b>Tab names.</b> A note and its duplicate have nearly the same title, so their tabs shorten to nearly the same words (A9). A saved version’s date is clearer than a duplicate’s name.</li>'
    '<li><b>Rewrites.</b> Word washes say little when a take or a block was rewritten whole.</li></ul>'
    '<h3>The order, as ruled</h3><ul class="plainl">'
    '<li><b>First: two takes of one block</b> (section 1; W-177, S). It needs no hoist and proves the washes on the phone.</li>'
    '<li><b>Then: her tabs, for two notes, read-only, with padded rows</b> (section 2; W-186, L). It maps one-to-one onto <code>PostAlignment</code>’s rows, each page stays a real note, and it grows to three or four notes.</li>'
    '<li>Not drawn any more: one column with the pairs stacked, and a hold-to-flip button. The hold uses the same lined-up pages as the tabs, so it could be added later as a second gesture if she asks for it.</li></ul>'
    '<h2>Still open for the author (none of it gates v1)</h2><ul class="plainl">'
    '<li><b>CMP-1.</b> A missing block: a box as tall as the block, so everything lines up (A3), or one line and only the top block lines up (A3 alt)? Drawn first: A3.</li>'
    '<li><b>CMP-2.</b> Copying across. Is “add as a take on the matching block” the right meaning of copying a block over? And may a block be copied into a note where it is missing (a new operation)?</li>'
    '<li><b>CMP-3.</b> Is Compare read-only on the phone, with Open this note as the way to edit? The Mac edits in place. Drawn: read-only.</li>'
    '<li><b>CMP-4.</b> Two notes only at first, or up to four as on the Mac? Drawn: two, with three shown once.</li>'
    '<li><b>CMP-5.</b> Should each page wash only its own words (drawn), or also show the other note’s words struck through?</li>'
    '<li><b>CMP-6.</b> The Mac’s Compare also holds Outline (make an outline note beside the note). Not drawn here; does it come to the phone at all?</li></ul>'
    '<h2>Every line that is a draft</h2><p class="note">Also listed in <code>design/wording-list-2.md</code>.</p><ul class="plainl">'
    '<li>Screen title: <i class="w">Compare</i>. Tabs: the notes’ own names, shortened in the middle.</li>'
    '<li>Foot: <i class="w">Changes</i> · <i class="w">1 of 4</i>.</li>'
    '<li>On the page: <i class="w">Not in this note</i> · <i class="w">Only in this note</i> · <i class="w">Moved</i> · (A3 alt) <i class="w">1 block not in this note</i>.</li>'
    '<li>A block’s menu: <i class="w">Copy to the other note</i> · <i class="w">Open this note</i> · <i class="w">Copy text</i>. An empty place’s menu: <i class="w">Show it</i> · <i class="w">Copy it here</i>.</li>'
    '<li>The ⋯ menu: <i class="w">Add a note…</i> (and <i class="w">Related blocks only</i>, the Mac’s words).</li>'
    '<li>Takes: <i class="w">Changes</i> · <i class="w">plain · against chosen</i> · <i class="w">5 changes</i>.</li>'
    '<li>Doors: <i class="w">Compare with…</i> · <i class="w">Search notes</i> · <i class="w">Saved versions</i> · <i class="w">Recent notes</i> · <i class="w">Go to this block</i>.</li>'
    '<li>The Mac’s own words, reused: <i class="w">There is no relationship here</i> · <i class="w">Versions of this note</i> · <i class="w">Compare with</i> (the picker) · <i class="w">Compare with latest version</i> · <i class="w">Compare with now</i> · '
    '<i class="w">version of this note</i> · <i class="w">a version</i> · <i class="w">Bring back as a take</i> · <i class="w">Read · Restore · Promote · Delete…</i> · <i class="w">plain · against now</i>.</li></ul>'
    '<h2>Build notes</h2>' + notes_table([
        ('1 · T1–T2 · takes (first)', 'W-177', 'Core Queries.diffPair, Domain/TextCompare; the phone’s existing peek and takes sheet', 'The Changes chip on the peek; the “against chosen” switch', 'The wash is a view; it stores nothing. Off is today’s peek, byte for byte.', 'S'),
        ('2 · A1–A11 · the tabs (second)', 'W-186 (after v1, her word)', 'Hoisted PostAlignment, CompareComposition; Core Queries.blockKinship, versionPeers, Domain/TextCompare, Operations.bringBackFromLineage',
         'The tab strip; the lined-up row (as tall as its taller version); the dotted place-holder; the Changes chip; the change stepper',
         'Pair by lineage, never by order or by matching text. Gaps and bars only where lineage speaks; two unrelated notes say so and pad nothing. Measure only the rows on screen. Compare writes nothing except A5’s take.', 'L'),
        ('3 · D1–D4 · the doors', 'W-186; reopens C·V2 (versions in Compare)', 'Shared VersionsCopy; Core noteVersions, latestNoteVersionID, versionPeers; the hoisted picker ranking', 'The picker sheet; two menu rows; two ⋯ rows',
         'Compare with latest version shows only while a saved version exists. A saved version is sealed: it never receives a copy.', 'S'),
    ]) +
    '<p class="note" style="margin-top:14px"><b>Added to the sizing sheet’s vocabulary</b>: the tab strip (44 pt, names at 15 pt, a 3 pt bar under the current one); the lined-up row; '
    'the dotted place-holder and its one-line form; the change bar in the gutter and the whole-block wash; the Changes chip (a word on a 48 pt chip, in her words-on-a-chip grammar); '
    'the change stepper (a 48 pt capsule, two 44 pt arrows); the small frame (a true-size phone drawn at 65%).</p>')

INTRO = ('<p class="lede">VM-44, a concept only. Her words: “having thought about it I would like to have a compare mode, maybe with the notes as different tabs that you can swipe between and still '
         'have the notes line up block by block? that’s just one idea on it and again, probably won’t even be in v1 of the mobile app”. '
         'This reverses the earlier exclusion (MobileSoul §4.5). Nothing here is in v1. Frames read left to right.</p>'
         '<p class="ruled"><b>The order, as she ruled it: “Takes first, then tabs.”</b> Section 1 is comparing two takes of one block, which is built first. Section 2 is her idea, the notes as tabs lined up block by block, which follows. '
         'Section 3 is how Compare is reached. The two other shapes drawn before (one column, a quick flip) are gone.</p>'
         '<p class="note">What Compare is on the Mac: up to four notes side by side, their blocks paired by lineage (a duplicate’s blocks remember the blocks they came from), never by order or by '
         'matching text; gaps only where that lineage speaks; a note’s duplicates and saved versions offered first. '
         'Seeded content: Essays ▸ “On keeping a commonplace book” and its duplicate “On keeping a commonplace book — talk”, drawn here cut down for a talk: one block reworded, one shortened, one cut, one added.</p>')

TOK = ('<h2>Token values used</h2><p class="note">Study voice under the sea-glass palette, light, with one dark frame; every size, ink, radius and component is '
       '<code>sketches/sizing-sheet.html</code>’s (type 13 · 15 · 17 · 20 · 24, 44 pt touch minimum, gutter 20). The note’s top bar, masthead, takes peek, takes sheet, History and Versions sheets are '
       '<code>note-write.html</code>’s and <code>takes-and-history.html</code>’s, reused through the same generator (<code>mockups/_gen-NT</code>). '
       'No keyboard shows in Compare, so the capsule above the keyboard is not drawn; nothing here says a line after an act. Draft working record, not canon.</p>')

BODY = C() + A() + D() + NOTES + TOK

title = 'Compare on the phone'
doc = ('<!doctype html><html lang="en"><head><meta charset="utf-8"><title>%s — concept, after v1</title><meta name="viewport" content="width=device-width,initial-scale=1">'
       '<style>%s</style></head><body><h1>%s <span class="concept">concept, after v1</span></h1>%s%s</body></html>' % (esc(title), CSS + MORE_CSS, title, INTRO, BODY))
p = os.path.abspath(os.path.join(OUT, 'compare-concept.html'))
open(p, 'w').write(doc)
dump_drafts('compare-concept')
print(p, len(doc), '· drafts:', len(DRAFTS))
