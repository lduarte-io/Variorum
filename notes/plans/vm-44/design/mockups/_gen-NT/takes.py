# VM-44 mockup — takes-and-history.html: the marker, the peek, the takes sheet, History and lineage, whole-note versions.
from base import *

M1 = mk(3) + mk(1, 'c')
B3C = mk(2, 'conflict')


def gap(h=16):
    return '<div style="height:%dpx;flex:none"></div>' % h


def behind(dark=False):
    return topbar() + page(blk(B1, M1, under=True) + blk(B2) + blk(B3, B3C, under=False) + blk(B4), mast_html=mast(), pad='10px')


def pill(label, choose='Choose', done=False, bottom=26):
    c = ('<span class="choose done">%s chosen</span>' % I_CHECK) if done else ('<span class="choose">%s%s</span>' % (I_CHECK, choose))
    return ('<div class="fbar" style="bottom:%dpx"><span class="pill2"><span class="gc">%s</span><span class="lab">%s</span><span class="gc">%s</span>%s</span></div>'
            % (bottom, ic('M12.5 4 6.5 10l6 6', 2), label, ic('M7.5 4 13.5 10l-6 6', 2), c))


# ---------------------------------------------------------------- A
def A():
    a1 = phone(behind(), over=fade(0, 70))
    peeked = '<div class="blk peek"><p>%s</p></div>' % B1W

    def pk(done=False, dark=False):
        first = ('<div class="blk"><p>%s</p><span class="mkf">%s</span></div>' % (B1W, M1)).replace('class="blk"', 'class="blk under"') if done else peeked
        return phone(topbar(), page(first + blk(B2) + blk(B3, B3C) + blk(B4), mast_html=mast(), pad='10px'),
                     over=fade(0, 130) + pill('take 2/3 · warmer', done=done), dark=dark)
    return section(
        'A — the marker, the peek, and choosing',
        'Her ruled phone grammar, kept whole: one take at a time, swipe to peek, ✓ to choose. What changes is that the sign of it can be seen and pressed, and the pill moves to the thumb.',
        row(frame(a1, 'A1', 'A note with two fanned blocks, at rest.',
                  'A fanned block wears the takes mark with its count (“3”), an 18 pt glyph in a 44 pt hit area at the block’s foot; a plain block wears nothing. '
                  'The third block’s mark reads “2 · conflict” in the alarm ink: one of its takes arrived from a sync conflict (the take’s own label, which the store already carries). '
                  'A tap on a mark opens the takes sheet (B1). Where the marks sit is NT-10’s (drawn in <code>comments-and-callouts.html</code>); they are one helper here.'),
            frame(pk(), 'A2', 'She swipes the first paragraph sideways.',
                  'The block shows take 2 in place, on the take tint, aligned to the text column. The pill floats at the foot, where her thumb is, and never covers the next paragraph: '
                  'previous · “take 2/3 · warmer” (the build’s words) · next · Choose. Each arrow is a 44 pt cell; Choose is a labelled button, not a bare ✓. '
                  'Swiping again steps through the fan; scrolling or tapping elsewhere ends the peek and the chosen take returns.'),
            frame(pk(done=True), 'A3', 'She taps Choose.',
                  'The note now says take 2. The pill confirms with “✓ chosen” in the chosen green and fades. Nothing structural happened, so there is no Undo: the other takes are still one swipe away.'),
            frame(pk(dark=True), 'A2 dark', 'The peek in dark.', 'The tint is the palette’s dark take tint; the pill is dark glass.')))


# ---------------------------------------------------------------- B
def card(state, label, text, cls='', foot_left='', foot_right='', lock=False, note='', more=True):
    lk = '<span class="lk">%s</span>' % I_SEAL if lock else ''
    hd = '<div class="hd"><span class="st">%s</span><span class="lb">%s</span>%s%s</div>' % (state, label, lk, ib(I_MORE, 'mut') if more else '')
    nt = '<div class="nt">%s</div>' % note if note else ''
    ft = '<div class="ft"><span>%s</span><span>%s</span></div>' % (foot_left, foot_right) if (foot_left or foot_right) else ''
    return '<div class="tcard %s">%s<div class="bd">%s</div>%s%s</div>' % (cls, hd, text, nt, ft)


CHOSEN = I_CHECK + 'Chosen'
HBTN = lambda n: '<span class="tbtn sm">%s&nbsp;History · %d</span>' % (I_HIST.replace('<svg', '<svg width="18" height="18"'), n)
CHOOSE = '<span class="tbtn sm s">Choose</span>'
SFOOT = ('<div class="sfoot"><span class="t-meta" style="flex:none">New take</span><span class="btn fill">%s Branch</span><span class="btn fill">%s Blank</span>%s</div>'
         % (I_BRANCH, I_BLANK, ib(I_MORE)))


def B():
    cards = (card(CHOSEN, 'original', B1, 'chosen', HBTN(1)) + card('Take 2', 'warmer', B1W, '', HBTN(0), CHOOSE) + card('Take 3', 'shorter', B1S, '', HBTN(0), CHOOSE) +
             '<div style="flex:1"></div>')
    b1 = phone(behind(), over=dimmer() + sheet(70, 'Takes', cards, meta='Block 1 of 4 · tap a take’s words to edit it', foot=SFOOT))
    m = menu([('New branched take', I_BRANCH), ('Label…', I_NAME), ('Lock take', I_SEAL), None, ('Move up', I_UP), ('Move down', I_DOWN), None,
              ('Move take into a block below', I_NEWB), None, ('Archive take', I_ARCH), ('Delete take…', I_TRASH, 'al')], 'right:22px;top:330px;width:290px')
    b2 = phone(behind(), over=dimmer() + sheet(70, 'Takes', cards, meta='Block 1 of 4 · tap a take’s words to edit it', foot=SFOOT) + m)

    c3 = (card(CHOSEN, '', 'It was not that he felt any emotion akin to love for Irene Adler. All emotions were abhorrent to his cold, precise mind.', 'chosen', HBTN(2)) +
          card('Take 2', '<b style="color:var(--alarm);font-weight:600">conflict</b>', 'It was not that he felt anything like love for Irene Adler. All emotions were abhorrent to his cold, precise mind.', '',
               HBTN(0), CHOOSE, note='Kept from a sync: this block was edited on two devices at once, and both versions were kept.') +
          sech('Archived takes', tight=True) + '<div class="expl">Set aside, out of the fan — kept, with no clock.</div>' +
          card('Archived', 'colder', 'He felt nothing for Irene Adler, and said so.', 'arch', '', '<span class="tbtn sm s">Unarchive</span>') + '<div style="flex:1"></div>')
    b3 = phone(behind(), over=dimmer() + sheet(70, 'Takes', c3, meta='Block 3 of 4', foot=SFOOT))

    live = (card(CHOSEN, 'original', B1, 'chosen', HBTN(1)) +
            card('Take 2', 'warmer', 'That winter I began copying other people’s sentences into a little notebook, and it felt like keeping company' + CARET, 'live', '', '', more=True) + '<div style="flex:1"></div>')
    b4 = phone(behind(), over=dimmer() + sheet(70, 'Takes', live, meta='Block 1 of 4 · editing take 2') +
               '<div class="fbar" style="bottom:333px;z-index:9"><span></span><span class="gcap">%s%s</span></div>' % (gc(AA), gc(I_KBD)) +
               kbd().replace('class="kb-abs"', 'class="kb-abs" style="z-index:9"'))
    b5 = phone(behind(), over=dimmer() + sheet(70, 'Takes', cards, meta='Block 1 of 4 · tap a take’s words to edit it', foot=SFOOT), dark=True)
    cx = (card(CHOSEN, 'original', B1, 'chosen', HBTN(1)) + card('Take 2', 'warmer', B1W, '', HBTN(0), CHOOSE) + '<div style="flex:1"></div>')
    b6 = phone(behind(), over=dimmer() + sheet(70, 'Takes', cx, meta='Block 1 of 4', foot=SFOOT), cls='xxl')
    return section(
        'B — the takes sheet', 'The browser’s content survives (real prose in every card, a clear chosen state, labels); the container becomes a real sheet and every control a real target. '
        'It opens from a block’s takes mark or the bar’s takes cell.',
        row(frame(b1, 'B1', 'She taps the takes mark on the first block.',
                  'A native sheet: grabber, swipe down, one header. Each card: its state (“✓ Chosen” with the green tick, or “Take 2”), its label, a 44 pt ⋯; the take’s words at the note’s own size; '
                  'a foot row with History (and how many commits the take has) on the left and Choose on the right. Choose is a word, so the tick only ever means “this is the one”. '
                  'Tapping a take’s words edits it in place (B4). The foot bar makes a new take: Branch copies the take the note shows, Blank starts empty; its ⋯ holds Copy all takes and Turn all takes into blocks.'),
            frame(b2, 'B2', 'She taps a card’s ⋯.',
                  'New branched take (from this card, so any take can be branched without swiping to it first) · Label… · Lock take · Move up · Move down · Move take into a block below · Archive take · Delete take…. '
                  'History left this menu for the card’s foot. Removal is last and in the alarm ink; delete asks first.'),
            frame(b3, 'B3 · conflict, archived', 'She taps the mark that read “2 · conflict”.',
                  'The conflict take’s label is in the alarm ink and the card explains itself once, in plain words (a proposal; the Mac shows only the label). It is an ordinary take: Choose, edit, or delete it. '
                  'Below the fan, Archived takes with the Mac’s sentence; an archived card offers Unarchive alone. A locked take shows a lock beside its label and refuses edits in the build’s words '
                  '(“This take is locked — unlock it from its card’s ⋯, or branch it.”).', 'new'),
            frame(b4, 'B4 · keyboard up', 'She taps take 2’s words.',
                  'That card becomes the one live editor, ringed in the accent; the sheet stays at full height and the card scrolls clear of the keyboard. The bar offers only Aa and “keyboard down”: '
                  'inside a take, Return is always content, as on the Mac, so the newline cell is not needed. Done or a swipe down saves and closes.', 'new'),
            frame(b5, 'B1 dark', 'The sheet in dark.', 'Cards sit on the dark card colour; the chosen ring and tick use the dark chosen green (7.8:1).'),
            frame(b6, 'B1 at the largest text size', 'The sheet at xxxLarge.',
                  'Her words in the cards are 23 pt and keep scaling into the accessibility sizes; labels, buttons and the header stop at xxxLarge. Card rows grow to 52 pt and the foot bar keeps one row.', 'new')))


# ---------------------------------------------------------------- C
def lrow(title, prev='', meta='', acc='', cls='', style='', title_cls='t-row'):
    p = '<div class="t-prev ell">%s</div>' % prev if prev else ''
    m = '<div class="t-meta">%s</div>' % meta if meta else ''
    return '<div class="lrow %s" style="background:var(--paper);%s"><div class="mid"><div class="%s ell">%s</div>%s%s</div>%s</div>' % (cls, style, title_cls, title, p, m, acc)


SEG = lambda on: '<div class="seg"><span class="%s">Commits</span><span class="%s">Lineage</span></div>' % ('on' if on == 0 else '', 'on' if on == 1 else '')
FCH = ('<div class="fchips"><span class="chip on">All takes</span><span class="chip">original</span><span class="chip">warmer</span><span class="chip">shorter</span></div>')
COMMITROW = '<div style="display:flex;gap:8px;padding:0 16px 14px"><span class="field">Name this commit (optional)</span><span class="btn solid">Commit</span></div>'
DOWN = '<span class="ib mut" style="transform:rotate(90deg)">%s</span>' % I_CHEV
OLD = 'I started copying lines into a notebook the winter I stopped trusting my memory.'


def C():
    tail2 = 'other name. In his eyes she eclipses and predominates the whole of her sex.'
    c1 = phone(topbar(TITLE, 'block 3 of 4'), page(blk(tail2) + blk(B3.replace('He was, I take it,', 'He was,' + CARET + ' I take it,')) + blk(B4), pad='14px'),
               over=fade() + bar(receipt=rcpt('Committed', 'Name…')) + kbd())
    rail = (SEG(0) + COMMITROW + FCH +
            lrow('The take now', B1, 'original · ✓ chosen · the take you’re in') +
            lrow('first pass', '', 'Jul 25 at 10:00 AM · saved by hand · original', ib(I_CHEV, 'mut')) +
            lrow('3 quiet commits', '', 'Jul 22 – Jul 24 · original', DOWN, title_cls='t-ctl2') +
            lrow('The take now', B1W, 'warmer') +
            lrow('before Claude’s edit · after Claude’s edit', '', 'Nov 2 at 4:12 PM · warmer', ib(I_CHEV, 'mut'), style='background:var(--takeTint)') +
            lrow('The take now', B1S, 'shorter') +
            sech('Deleted takes — on the 30-day clock', tight=True) +
            lrow('I keep a second notebook for things I only half believe.', '', '28 days left', '<span class="tbtn sm s">Put back</span>', title_cls='t-prev') +
            '<div class="band" style="flex:1"></div>')
    hist_meta = 'Block 1 of 4 · I started copying sentences…'
    c2 = phone(behind(), over=dimmer() + sheet(70, 'History', rail, meta=hist_meta))

    def pane(back, title, meta, text, count, acts, seg=None):
        sub = ('<div style="display:flex;align-items:center;justify-content:space-between;padding:0 8px 0 8px;margin-top:-6px"><span class="tbtn">‹ %s</span>'
               '<span style="display:flex">%s%s</span></div>' % (back, ib(I_UP), ib(I_DOWN)))
        sg = ('<div class="seg" style="margin-top:8px"><span class="%s">plain</span><span class="%s">%s</span></div>' % ('' if seg else 'on', 'on' if seg else '', seg or 'against now')) if seg is not None else ''
        return (sub + '<div style="padding:4px 20px 0"><div class="t-row">%s</div><div class="t-meta">%s</div></div>' % (title, meta) + sg +
                '<div class="band" style="flex:1;margin-top:%dpx;padding:16px 20px 0"><div class="t-body">%s</div><div class="t-meta" style="margin-top:12px">%s</div></div>' % (0 if seg is not None else 12, text, count) +
                '<div class="sfoot">%s</div>' % acts)
    washed = ('I started copying <span class="wash-rem">lines</span> <span class="wash-add">sentences</span> into a notebook the winter I stopped trusting my memory <span class="wash-add">for them</span>.')
    acts = '<span class="btn solid" style="flex:none">%s Restore</span><span class="btn fill">Bring back as a take</span><span class="btn fill" style="flex:none">Name…</span>' % I_UNDO
    c3 = phone(behind(), over=dimmer() + sheet(70, 'History', pane('All commits', 'first pass', 'Jul 25 at 10:00 AM · saved by hand · original', washed, '2 changes since', acts, seg='against now'), meta=hist_meta))

    rail2 = (SEG(0) + '<div style="margin:0 16px 12px;padding:10px 12px;border-radius:12px;background:var(--wash);font:400 15px/20px var(--chrome)">'
             'Saved moment restored into this take — the moments themselves are never overwritten, so nothing was lost.</div>' + FCH +
             lrow('The take now', OLD, 'original · ✓ chosen · the take you’re in') +
             lrow(B1, '', 'just now · quiet · original', ib(I_CHEV, 'mut'), style='box-shadow:inset 3px 0 0 var(--accent)', title_cls='t-prev') +
             lrow('first pass', '', 'Jul 25 at 10:00 AM · saved by hand · original', ib(I_CHEV, 'mut')) +
             lrow('3 quiet commits', '', 'Jul 22 – Jul 24 · original', DOWN, title_cls='t-ctl2') + '<div class="band" style="flex:1"></div>')
    c4 = phone(behind(), over=dimmer() + sheet(70, 'History', rail2, meta=hist_meta))
    c5 = phone(behind(), over=dimmer() + sheet(70, 'History', pane('All commits', 'first pass', 'Jul 25 at 10:00 AM · saved by hand · original', OLD, 'predates a split', acts, seg=''), meta=hist_meta) +
               '<div class="dimmer" style="z-index:8"></div>' +
               alert(300, 'This saved moment predates a split of this block', 'Restoring will resurrect the full pre-split text into this take’s buffer — the split-off half still exists next door.',
                     (('Restore anyway', 'al'), ('Cancel', ''))))

    def lin(verb, words, where, counts, acc='', me=False, mute=False):
        return ('<div class="lin%s" style="%s"><div class="mid"><div class="vb">%s</div><div class="t-prev ell" style="color:var(--ink)">%s</div><div class="t-meta">%s · %s</div></div>%s</div>'
                % (' me' if me else '', 'opacity:.55' if mute else '', verb, words, where, counts, acc))
    whole = 'To Sherlock Holmes she is always <i>the</i> woman. I have seldom heard him mention her under any other name. In his eyes she eclipses and predominates the whole of her sex. It was not that he felt any emotion akin to love for Irene Adler.'
    fam = (SEG(1) + '<div class="expl">family · older above</div>' +
           '<div class="gen">came from</div>' +
           lin('divided', whole, 'kept as lineage', '2 takes · 1 commit', ib(I_CHEV, 'mut')) +
           '<div class="gen">this generation</div>' +
           lin('this block', 'It was not that he felt any emotion akin to love for Irene Adler. All emotions…', 'here', '2 takes · 2 commits', me=True) +
           lin('divided', 'To Sherlock Holmes she is always the woman. I have seldom heard him…', 'this note', '1 take', ib(I_CHEV, 'mut')) +
           '<div class="gen">came of it</div>' +
           lin('a version', 'It was not that he felt any emotion akin to love for Irene Adler…', 'in “On keeping a commonplace book — talk”', '1 take', ib(I_CHEV, 'mut')) +
           lin('extracted', 'but as a lover he would have placed himself in a false position.', 'in the Trash', '1 take', mute=True) +
           '<div class="band" style="flex:1"></div>')
    lmeta = 'Block 3 of 4 · It was not that he felt any emotion…'
    c6 = phone(behind(), over=dimmer() + sheet(70, 'History', fam, meta=lmeta))
    lacts = '<span class="btn solid">Put back</span><span class="btn fill">Bring back as a take</span>'
    c7 = phone(behind(), over=dimmer() + sheet(70, 'History', pane('Lineage', 'The take as kept', 'divided · kept as lineage · take 1 of 2 · 1 commit', whole, '', lacts), meta=lmeta))
    emp = (SEG(1) + '<div class="band" style="flex:1;display:flex;align-items:center;justify-content:center;padding:0 40px 140px;text-align:center">'
           '<span class="t-ctl2" style="color:var(--muted2)">Nothing came before or after this block — it was never divided, merged, extracted or copied.</span></div>')
    c8 = phone(behind(), over=dimmer() + sheet(70, 'History', emp, meta='Block 4 of 4 · He never spoke of the softer passions…'))
    return section(
        'C — commit, and History and lineage as one surface',
        'Reached per the NT-5 pick, both doors: “Commit take” and “History and lineage” side by side in the block menu (<code>note-write.html</code>, D1 and F1), and each take card’s History button (B1), which opens the same sheet filtered to that take. '
        'The Block History overlay is retired, as on the Mac. Compare (the two-box face) stays out with the rest of Compare until after v1.',
        row(frame(c1, 'C1', 'She taps Commit take in the block menu.',
                  'The take is committed at once, one filing per press (the row latches, so a double tap is one commit). The receipt says so beside her thumb and offers “Name…”, '
                  'which opens the history sheet with the name field focused. Naming is optional and can happen later.'),
            frame(c2, 'C2', 'She taps History and lineage.',
                  'One sheet, two faces on a segmented control. Commits is the default. At the top: name a commit and file it. Then the take filter (All takes, or one take). '
                  'Then the rail, newest first, every take’s moments in one list, each one line: its name, or its first words when unnamed; when; “saved by hand” or “quiet”; which take. '
                  'Each take’s list is led by “The take now”. Quiet runs fold into one row. An AI edit made through the Mac shows as its before/after pair on a wash, never folded. '
                  'Deleted takes wait at the foot on the 30-day clock with Put back.'),
            frame(c3, 'C3', 'She taps “first pass”.',
                  'The moment opens as a reading pane: its full text at the note’s size. “plain · against now” switches a word-level wash (removed words struck, added words washed), with the count beneath. '
                  'The ↑ ↓ buttons, or a swipe, step to the next moment without going back, so reading never needs the list. Three acts in the thumb row: Restore, Bring back as a take, Name….'),
            frame(c4, 'C4', 'She taps Restore.',
                  'The take now says the moment’s words, and the words it replaced were kept first as one quiet commit (marked), her ruling #274, unwired on the phone today. '
                  'The receipt is the Mac’s sentence. Back on the page the block shows the restored text.'),
            frame(c5, 'C5 · refusal', 'She restores a moment from before the block was divided.',
                  'The Mac’s warning, in the Mac’s words, before anything changes. The removing-flavoured choice wears the alarm ink; Cancel is the default.', 'new'),
            frame(c6, 'C6', 'She switches to Lineage on a block that was divided.',
                  'The family, older above, in bands. Each member is one row: how it is related (divided, merged, extracted, copied, a version), its first words, where it lives, its counts. '
                  'This block is marked. A member in the Trash is muted and has no acts; a member in another wing names the wing and offers only Go to its wing.'),
            frame(c7, 'C7', 'She taps the original the block was divided from.',
                  'The same reading pane, now on that block: an original kept as lineage names its moment “the take as kept”. Its acts: Put back (it returns to the note it was set aside from, whole) and Bring back as a take '
                  '(its words become the last take in this block’s fan, never chosen; the receipt is the Mac’s “Brought back as a take on this block — it’s the last take in its fan.”).'),
            frame(c8, 'C8 · empty', 'She opens Lineage on a plain block.',
                  'The Mac’s one empty line. While a large family is being read the same place shows a spinner and “Reading this block’s family…”.', 'new')))


# ---------------------------------------------------------------- D
def D():
    expl = ('<div class="expl" style="font-size:15px;line-height:20px">Whole moments of this note, saved by hand. Opening one reads it; restoring makes the note say that again — and saves where it is now first, so none of its words are lost.</div>')
    save = '<div style="padding:0 16px 14px"><div class="btn solid" style="width:100%%;height:48px;font-size:17px">%s Save a version</div></div>' % I_VERS
    rows = (lrow('Nov 12, 2026 at 9:12 AM', '', '4 blocks', ib(I_CHEV, 'mut')) + lrow('Nov 10, 2026 at 4:30 PM', '', '3 blocks · saved for you', ib(I_CHEV, 'mut')) + '<div class="band" style="flex:1"></div>')
    d1 = phone(behind(), over=dimmer() + sheet(70, 'Versions', expl + save + rows, meta=TITLE))
    band = '<div class="idband">A saved version of “On keeping a commonplace book” · Nov 10, 2026 at 4:30 PM</div>'
    read = (band + '<div class="band" style="flex:1;padding:16px 20px 0"><div class="t-body">%s%s%s</div></div>' % (blk(OLD), blk(B2), blk(B3)) +
            '<div class="sfoot"><span class="btn solid">Restore</span><span class="btn fill">Promote</span><span class="tbtn al" style="flex:none">Delete…</span></div>')
    d2 = phone(behind(), over=dimmer() + sheet(70, 'Versions', '<div style="margin-top:-6px;padding:0 8px"><span class="tbtn">‹ All versions</span></div>' + read, meta=''))
    d3 = phone(behind(), over=dimmer() + sheet(70, 'Versions', '<div style="margin-top:-6px;padding:0 8px"><span class="tbtn">‹ All versions</span></div>' + read) + '<div class="dimmer" style="z-index:8"></div>' +
               alert(170, 'Make the note say this again?',
                     'Where the note is right now is saved as a new version first, so none of its words are lost. The note keeps its name, its books and everything that points at it.<br><br>'
                     'A version holds the words, not the history. Going with these paragraphs, and held by no version: 1 saved moment and 2 deleted takes. Nothing puts them back. '
                     'Promote instead keeps everything — it makes this moment a note of its own and deletes nothing.',
                     (('Restore', 'pri'), ('Promote instead', ''), ('Cancel', ''))))
    emp = (expl + save + '<div class="band" style="flex:1;display:flex;align-items:center;justify-content:center;padding:0 40px 60px;text-align:center">'
           '<span class="t-ctl2" style="color:var(--muted2)">No saved moments yet.</span></div>')
    d4 = phone(behind(), over=dimmer() + sheet(400, 'Versions', emp, meta=TITLE))
    return section(
        'D — whole-note versions', 'From the note’s menu: Save a version, and Versions. One sheet where saving and the list live together (today Save is in one sheet and the list is a pushed screen whose title is its smallest text).',
        row(frame(d1, 'D1', 'She taps Versions in the note’s menu.',
                  'The explainer is the shared sentence at 15 pt in the corrected ink. Save a version is a full-width button above the list. Each version is a 64 pt row: when it was saved, how many blocks, “saved for you” when it was automatic.'),
            frame(d2, 'D2', 'She taps a version.',
                  'It reads on the paper, not editable, under a band that says what it is (the Mac’s identity sentence). Three acts in the thumb row: Restore, Promote, Delete…. '
                  'Compare with now and the Compare doors stay Mac-only until Compare arrives.'),
            frame(d3, 'D3', 'She taps Restore.',
                  'The Mac’s confirm with its real cost: the title, the reassurance, then exactly what goes with the current paragraphs and is held by no version, and the kinder road. Restore saves now first, then lands.'),
            frame(d4, 'D4 · empty', 'A note with no versions.', 'A sheet only as tall as it needs. The empty line is the shared one without its Mac keystroke (the phone names the button above it instead).', 'new')))


NOTES = notes_table([
    ('A1–A3 · marker, peek, choose', 'W-136’s marker door; T1/T2 sizing (grade 2 screens 14–15); W-170’s place (NT-10)', 'MobileTakesChrome, MobileTakesController (the phone’s own takes brain); the chosen take lives on the pointer (I3)',
     'The foot pill; the count; the conflict word on the mark', 'The gesture and the pill’s words do not change. The peek tint aligns to the text column and the measure never moves. The mark’s conflict word reads the take’s label; it adds no new store state. VoiceOver needs labels on the mark and the pill (W-014).', 'M'),
    ('B1–B6 · the takes sheet', 'W-148 (takes third), W-174, W-175, W-179; W-003’s header; W-172', 'MobileTakesBrowser and its Core ops (branchVariant, newBlankVariant, lockVariant, archiveVariant, deleteVariant, reorderTake, takeToBlockBelow, takesToBlocks); Core TakeLabelFace',
     'A native sheet; card foot row; the per-card branch', 'One live card at a time (P3). The keyboard fix the old overlay needed is the sheet’s own now. I10 refusals keep the build’s sentences. Borders re-resolve on a light/dark flip. Choose is a word; the tick is only a state.', 'M'),
    ('C1 · commit', 'W-180', 'Core commit, renameCommitPoint, Domain SavepointName', 'The latch; the “Name…” door on the receipt', 'One filing per press. Naming never re-files. The app says “commit” (the Mac’s vocabulary rule).', 'S'),
    ('C2–C5 · the commits face', 'W-183, W-181 (her ruling #274), W-182, W-148 (history third)', 'Core Queries.blockHistory, Domain CommitRail and TextCompare, restoreCommit(insuringBuffer: true), bringBackCommitAsTake; the Mac’s CommitsFaceModel and CommitsFaceCopy once hoisted to Shared',
     'The phone face: a rail that pushes a reading pane', 'Hoist the model first; do not fork it. Restore flushes pending typing, then insures. The rail scales with the block’s history, never the note. The wash is view-time only. Compare is not built here.', 'L'),
    ('C6–C8 · the lineage face', 'W-184', 'Core Queries.lineagePeers / lineageTree, Domain LineageFamily, bringBackFromLineage, placeBlock; the Mac’s LineageFaceModel and LineageFaceCopy once hoisted', 'The banded family list; the member pane',
     'Depends on the commits face (one composition). Put back only on placeable members. A Trash member has no acts; another wing’s member only “Go to its wing”. The lineage fence lives in the operation.', 'L'),
    ('D1–D4 · versions', 'Sizes for V1 (grade 2 screen 30); part of W-150', 'MobileVersions; Shared VersionActs, VersionsCopy', 'One sheet instead of a sheet plus a pushed screen', 'The restore confirm keeps its real-cost paragraph whole. The shared empty sentence names ⌘⇧S; the phone needs its own ending.', 'S'),
])

INTRO = ('<p class="lede">VM-44, the note’s designer. Takes on the phone in her ruled grammar (one take at a time, swipe to peek, ✓ to choose), made visible and pressable; the takes browser as a proper sheet; '
         'History and lineage as one surface; whole-note versions. Frames read left to right.</p>'
         '<p class="note">Seeded content: Essays ▸ “On keeping a commonplace book”, whose first block has three takes (original, warmer, shorter), one comment and one commit named “first pass”. '
         'The conflict take, the divided block’s family and the saved versions are drawn states over the same note.</p>')

BODY = A() + B() + C() + D() + '<h2>Build notes</h2>' + NOTES + (
    '<p class="note" style="margin-top:14px"><b>Added to the sizing sheet’s vocabulary</b>: the peek pill (52 pt glass, two 44 pt arrows, a label, a labelled Choose); the take card with a foot row; '
    'the sheet foot bar; the reading pane with its plain / against-now switch and step buttons; the lineage row and generation band; the identity band; the in-sheet receipt.</p>')

write('takes-and-history.html', 'The note — takes, history and lineage, versions', INTRO, BODY)
