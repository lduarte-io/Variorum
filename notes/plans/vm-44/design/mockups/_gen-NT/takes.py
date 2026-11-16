# VM-44 mockup — takes-and-history.html: the badge, the pill at the foot, the takes sheet, History and lineage, whole-note versions.
# REVISED after sitting 1: tapping the badge opens the pill at the foot; History and lineage is one sheet with a per-take tab and a per-block tab;
# commit is one tap in the quick row; no routine receipts.
from base import *

M1 = mk(3) + mk(1, 'c')
B3C = mk(2, 'conflict')
DW = '<span class="dw">draft</span>'
FIRST = 'I started copying sentences…'


def gap(h=16):
    return '<div style="height:%dpx;flex:none"></div>' % h


def behind(dark=False):
    return topbar() + page(blk(B1, M1, under=True) + blk(B2) + blk(B3, B3C, under=False) + blk(B4), mast_html=mast(), pad='10px')


UPC = ic('M5 12.5 10 7.5l5 5', 2)


def pill(label, state='choose', bottom=26):
    """The pill at the foot. state: 'choose' (a Choose button) · 'is' (this take is the chosen one) · 'done' (just chosen)."""
    if state == 'choose':
        c = '<span class="choose">%s%s</span>' % (I_CHECK, drs('A2–A4', 'Choose', 'The pill’s button: makes the take on screen the note’s take.'))
    else:
        c = '<span class="choose done">%s %s</span>' % (I_CHECK, 'chosen')
    return ('<div class="fbar" style="bottom:%dpx"><span class="pill2"><span class="gc">%s</span><span class="lab">%s%s</span><span class="gc">%s</span>%s</span></div>'
            % (bottom, ic('M12.5 4 6.5 10l6 6', 2), label, UPC, ic('M7.5 4 13.5 10l-6 6', 2), c))


# ---------------------------------------------------------------- A
def A():
    a1 = phone(behind(), over=fade(0, 70))

    def pk(text, label, state, dark=False, tint=True):
        first = '<div class="blk %s"><p>%s</p></div>' % ('peek' if tint else '', text)
        return phone(topbar(), page(first + blk(B2) + blk(B3, B3C) + blk(B4), mast_html=mast(), pad='10px'),
                     over=fade(0, 130) + pill(label, state), dark=dark)
    a2 = pk(B1, 'take 1/3 · original', 'is')
    a3 = pk(B1W, 'take 2/3 · warmer', 'choose')
    a4 = phone(topbar(), page(blk(B1W, M1, under=True) + blk(B2) + blk(B3, B3C) + blk(B4), mast_html=mast(), pad='10px'),
               over=fade(0, 130) + pill('take 2/3 · warmer', 'done'))
    a3d = pk(B1W, 'take 2/3 · warmer', 'choose', dark=True)
    return section(
        'A — the badge, the pill at the foot, and choosing',
        'Her words: “i like the takes badge. i also like being able to click on it to swipe between them at the bottom a lot … that’s a way easier way to work with your existing takes than the current multi click menu and I love how fast that makes it.” '
        'So: the badge shows, a tap on it opens the pill at her thumb, and from there every take is one swipe or one tap away.',
        row(frame(a1, 'A1', 'A note with two fanned blocks, at rest.',
                  'A fanned block wears the takes badge with its count (“3”), an 18 pt glyph in a 44 pt hit area at the block’s foot; a plain block wears nothing. '
                  'The third block’s badge reads “2 · conflict” in the alarm ink: one of its takes came from a sync conflict (the take’s own label, which the store already carries).', 'ruled'),
            frame(a2, 'A2', 'She taps the badge on the first block.',
                  'The pill appears at the foot and the block takes the take tint, so she can see which block the pill is for. The pill: previous · which take this is · next · its state. '
                  'She starts on the take the note uses, so the pill says “✓ chosen”. Each arrow is a 44 pt cell. Swiping the block sideways opens the same pill without the tap.', 'ruled'),
            frame(a3, 'A3', 'She swipes the block, or taps ›.',
                  'The block shows take 2 in place, aligned to the text column. The pill reads “take 2/3 · warmer” (the build’s words) and its button becomes Choose: a word, not a bare ✓. '
                  'Swiping or tapping again steps through the fan; scrolling or tapping elsewhere closes the pill and the chosen take returns. ' + DW, 'ruled'),
            frame(a4, 'A4', 'She taps Choose.',
                  'The note now says take 2. The pill shows “✓ chosen” and closes on its own. That is the pill’s own state, not a message: nothing left the page, so there is no line and no Undo. The other takes are still one tap away.', 'ruled'),
            frame(a3d, 'A3 dark', 'The pill in dark.', 'The tint is the palette’s dark take tint; the pill is dark glass.'))
        + '<p class="note">The small ⌃ beside the pill’s label opens every take at once, as cards (section B). The capsule above the keyboard has a takes cell that opens the same cards, because there she usually wants a new take.</p>')


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
SFOOT = ('<div class="sfoot"><span class="t-meta" style="flex:none">%s</span><span class="btn fill">%s %s</span><span class="btn fill">%s %s</span>%s</div>'
         % (drs('B1', 'New take', 'Label in the takes sheet’s foot bar.'), I_BRANCH, drs('B1', 'Branch', 'Foot bar button: a new take that copies the one the note shows (the Mac: New branched take).'),
            I_BLANK, drs('B1', 'Blank', 'Foot bar button: a new empty take (the Mac: New blank take).'), ib(I_MORE)))
TAPHINT = drs('B1', 'Tap a take’s words to edit them.', 'One line under the takes sheet’s title.')
CONFLICT = drs('B3', 'Edited on two devices. Both versions are here.', 'The conflict take’s one line (worded at sitting 1).')


def B():
    cards = (card(CHOSEN, 'original', B1, 'chosen', HBTN(1)) + card('Take 2', 'warmer', B1W, '', HBTN(0), CHOOSE) + card('Take 3', 'shorter', B1S, '', HBTN(0), CHOOSE) +
             '<div style="flex:1"></div>')
    b1 = phone(behind(), over=dimmer() + sheet(70, 'Takes', cards, meta=TAPHINT, foot=SFOOT))
    m = menu([('New branched take', I_BRANCH), ('Label…', I_NAME), ('Lock take', I_SEAL), None, ('Move up', I_UP), ('Move down', I_DOWN), None,
              ('Move take into a block below', I_NEWB), None, ('Archive take', I_ARCH), ('Delete take…', I_TRASH, 'al')], 'right:22px;top:330px;width:290px')
    b2 = phone(behind(), over=dimmer() + sheet(70, 'Takes', cards, meta=TAPHINT, foot=SFOOT) + m)

    c3 = (card(CHOSEN, '', 'It was not that he felt any emotion akin to love for Irene Adler. All emotions were abhorrent to his cold, precise mind.', 'chosen', HBTN(2)) +
          card('Take 2', '<b style="color:var(--alarm);font-weight:600">conflict</b>', 'It was not that he felt anything like love for Irene Adler. All emotions were abhorrent to his cold, precise mind.', '',
               HBTN(0), CHOOSE, note=CONFLICT) +
          sech('Archived takes', tight=True) + '<div class="expl">Set aside, out of the fan — kept, with no clock.</div>' +
          card('Archived', 'colder', 'He felt nothing for Irene Adler, and said so.', 'arch', '', '<span class="tbtn sm s">Unarchive</span>') + '<div style="flex:1"></div>')
    b3 = phone(behind(), over=dimmer() + sheet(70, 'Takes', c3, meta='It was not that he felt any emotion…', foot=SFOOT))

    live = (card(CHOSEN, 'original', B1, 'chosen', HBTN(1)) +
            card('Take 2', 'warmer', 'That winter I began copying other people’s sentences into a little notebook, and it felt like keeping company' + CARET, 'live', '', '', more=True) + '<div style="flex:1"></div>')
    b4 = phone(behind(), over=dimmer() + sheet(70, 'Takes', live, meta=FIRST) +
               '<div class="fbar" style="bottom:333px;z-index:9"><span></span><span class="gcap">%s%s</span></div>' % (gc(AA), gc(I_KBD)) +
               kbd().replace('class="kb-abs"', 'class="kb-abs" style="z-index:9"'))
    b5 = phone(behind(), over=dimmer() + sheet(70, 'Takes', cards, meta=TAPHINT, foot=SFOOT), dark=True)
    cx = (card(CHOSEN, 'original', B1, 'chosen', HBTN(1)) + card('Take 2', 'warmer', B1W, '', HBTN(0), CHOOSE) + '<div style="flex:1"></div>')
    b6 = phone(behind(), over=dimmer() + sheet(70, 'Takes', cx, meta=FIRST, foot=SFOOT), cls='xxl')
    return section(
        'B — every take at once: the takes sheet', 'For reading takes side by side, editing one, or making a new one. It opens from the ⌃ on the pill and from the takes cell above the keyboard. Nothing here leaves a line behind except a deleted take, which answers “Take deleted · Undo”.',
        row(frame(b1, 'B1', 'She taps ⌃ on the pill.',
                  'A native sheet: grabber, swipe down, one header. Each card: its state (“✓ Chosen” with the green tick, or “Take 2”), its label, a 44 pt ⋯; the take’s words at the note’s own size; '
                  'a foot row with History (and how many commits the take has) on the left and Choose on the right. '
                  'Tapping a take’s words edits it in place (B4). The foot bar makes a new take: Branch copies the take the note shows, Blank starts empty; its ⋯ holds Copy all takes and Turn all takes into blocks. ' + DW),
            frame(b2, 'B2', 'She taps a card’s ⋯.',
                  'New branched take (from this card) · Label… · Lock take · Move up · Move down · Move take into a block below · Archive take · Delete take…. '
                  'History is on the card’s foot, not in this menu. Removal is last and in the alarm ink; delete asks first.'),
            frame(b3, 'B3 · conflict, archived', 'She opens the block whose badge read “2 · conflict”.',
                  'Her ruling: the signal stays as drawn. The conflict take’s label is in the alarm ink and the card says once, plainly, what happened. It is an ordinary take: Choose it, edit it, or delete it. '
                  'Below the fan, Archived takes with the Mac’s sentence; an archived card offers Unarchive alone. A locked take shows a lock beside its label and refuses edits in the build’s words '
                  '(“This take is locked — unlock it from its card’s ⋯, or branch it.”). ' + DW, 'ruled'),
            frame(b4, 'B4 · keyboard up', 'She taps take 2’s words.',
                  'That card becomes the one live editor, ringed in the accent; the sheet stays at full height and the card scrolls clear of the keyboard. The capsule offers only Aa and “keyboard down”: '
                  'inside a take, Return is a new line, as on the Mac. Done or a swipe down saves and closes.', 'new'),
            frame(b5, 'B1 dark', 'The sheet in dark.', 'Cards sit on the dark card colour; the chosen ring and tick use the dark chosen green (7.8:1).'),
            frame(b6, 'B1 at the largest text size', 'The sheet at xxxLarge.',
                  'Her words in the cards are 23 pt and keep scaling into the accessibility sizes; labels, buttons and the header stop at xxxLarge. Card rows grow to 52 pt and the foot bar keeps one row.', 'new')))


# ---------------------------------------------------------------- C
def lrow(title, prev='', meta='', acc='', cls='', style='', title_cls='t-row'):
    p = '<div class="t-prev ell">%s</div>' % prev if prev else ''
    m = '<div class="t-meta">%s</div>' % meta if meta else ''
    return '<div class="lrow %s" style="background:var(--paper);%s"><div class="mid"><div class="%s ell">%s</div>%s%s</div>%s</div>' % (cls, style, title_cls, title, p, m, acc)


SEG = lambda on: '<div class="seg"><span class="%s">Commits</span><span class="%s">Lineage</span></div>' % ('on' if on == 0 else '', 'on' if on == 1 else '')
S_TAKE = drs('C2', 'Each take keeps its own commits.', 'Scope line under the Commits tab: commits are per take.')
S_BLOCK = drs('C6', 'For the whole block, not one take.', 'Scope line under the Lineage tab: lineage is per block, the same from either door.')
SC_COMMITS = '<div class="scope">%s%s</div>' % (I_FORK, S_TAKE)
SC_LINEAGE = '<div class="scope">%s<span><b>%s</b></span></div>' % (I_TREE, S_BLOCK)


def fch(on=0):
    names = ('all takes', 'original', 'warmer', 'shorter')
    return '<div class="fchips">%s</div>' % ''.join('<span class="chip%s">%s</span>' % (' on' if i == on else '', t) for i, t in enumerate(names))


COMMITROW = ('<div style="display:flex;gap:8px;padding:0 16px 14px"><span class="field">%s</span><span class="btn solid">Commit</span></div>'
             % drs('C2', 'Name (optional)', 'Placeholder beside the Commit button in the history sheet.'))
DOWN = '<span class="ib mut" style="transform:rotate(90deg)">%s</span>' % I_CHEV
OLD = 'I started copying lines into a notebook the winter I stopped trusting my memory.'
HT = 'History and lineage'


def C():
    tail2 = 'other name. In his eyes she eclipses and predominates the whole of her sex.'
    mid = blk(tail2) + blk(B3.replace('He was, I take it,', 'He was,' + CARET + ' I take it,')) + blk(B4)
    c0 = phone(topbar(TITLE), page(mid, pad='14px'), over=fade() + qrow(on=4) + kbd())
    c1 = phone(topbar(TITLE), page(mid, pad='14px'), over=fade() + bar(receipt=rcpt(dr('Committed', 'The one line a deliberate act gets: said after Commit (the same line as note-write C4).'), dr('Name…', 'Door on the commit line: opens the name field.'))) + kbd())
    back_all = drs('C3', 'All commits', 'Back label in the reading pane.')
    rail = (SEG(0) + SC_COMMITS + fch(0) + COMMITROW +
            lrow('The take now', B1, 'original · ✓ chosen · the take you’re in') +
            lrow('first pass', '', 'Jul 25 at 10:00 AM · saved by hand · original', ib(I_CHEV, 'mut')) +
            lrow('3 quiet commits', '', 'Jul 22 – Jul 24 · original', DOWN, title_cls='t-ctl2') +
            lrow('The take now', B1W, 'warmer') +
            lrow('before Claude’s edit · after Claude’s edit', '', 'Nov 2 at 4:12 PM · warmer', ib(I_CHEV, 'mut'), style='background:var(--takeTint)') +
            lrow('The take now', B1S, 'shorter') +
            sech('Deleted takes', tight=True) +
            lrow('I keep a second notebook for things I only half believe.', '', '28 days left', '<span class="tbtn sm s">Put back</span>', title_cls='t-prev') +
            '<div class="band" style="flex:1"></div>')
    c2 = phone(behind(), over=dimmer() + sheet(70, HT, rail, meta=FIRST))
    rail_t = (SEG(0) + SC_COMMITS + fch(2) + COMMITROW +
              lrow('The take now', B1W, 'warmer · ' + dr('the take this card shows', 'Marks the take whose card’s History button was tapped (the Mac says “the take you’re in”).')) +
              lrow('before Claude’s edit · after Claude’s edit', '', 'Nov 2 at 4:12 PM · warmer', ib(I_CHEV, 'mut'), style='background:var(--takeTint)') +
              lrow('2 quiet commits', '', 'Oct 30 – Nov 1 · warmer', DOWN, title_cls='t-ctl2') +
              '<div class="band" style="flex:1"></div>')
    c2t = phone(behind(), over=dimmer() + sheet(70, HT, rail_t, meta=FIRST))

    def pane(back, title, meta, text, count, acts, seg=None):
        sub = ('<div style="display:flex;align-items:center;justify-content:space-between;padding:0 8px 0 8px;margin-top:-6px"><span class="tbtn">‹ %s</span>'
               '<span style="display:flex">%s%s</span></div>' % (back, ib(I_UP), ib(I_DOWN)))
        sg = ('<div class="seg" style="margin-top:8px"><span class="%s">plain</span><span class="%s">%s</span></div>' % ('' if seg else 'on', 'on' if seg else '', seg or 'against now')) if seg is not None else ''
        return (sub + '<div style="padding:4px 20px 0"><div class="t-row">%s</div><div class="t-meta">%s</div></div>' % (title, meta) + sg +
                '<div class="band" style="flex:1;margin-top:%dpx;padding:16px 20px 0"><div class="t-body">%s</div><div class="t-meta" style="margin-top:12px">%s</div></div>' % (0 if seg is not None else 12, text, count) +
                '<div class="sfoot">%s</div>' % acts)
    washed = ('I started copying <span class="wash-rem">lines</span> <span class="wash-add">sentences</span> into a notebook the winter I stopped trusting my memory <span class="wash-add">for them</span>.')
    acts = '<span class="btn solid" style="flex:none">%s Restore</span><span class="btn fill">Bring back as a take</span><span class="btn fill" style="flex:none">Name…</span>' % I_UNDO
    c3 = phone(behind(), over=dimmer() + sheet(70, HT, pane(back_all, 'first pass', 'Jul 25 at 10:00 AM · saved by hand · original', washed, '2 changes since', acts, seg='against now'), meta=FIRST))

    rail2 = (SEG(0) + SC_COMMITS + fch(0) + COMMITROW +
             lrow('The take now', OLD, 'original · ✓ chosen · the take you’re in') +
             lrow(B1, '', 'just now · quiet · original', ib(I_CHEV, 'mut'), style='box-shadow:inset 3px 0 0 var(--accent)', title_cls='t-prev') +
             lrow('first pass', '', 'Jul 25 at 10:00 AM · saved by hand · original', ib(I_CHEV, 'mut')) +
             lrow('3 quiet commits', '', 'Jul 22 – Jul 24 · original', DOWN, title_cls='t-ctl2') + '<div class="band" style="flex:1"></div>')
    c4 = phone(behind(), over=dimmer() + sheet(70, HT, rail2, meta=FIRST))
    c5 = phone(behind(), over=dimmer() + sheet(70, HT, pane(back_all, 'first pass', 'Jul 25 at 10:00 AM · saved by hand · original', OLD, 'predates a split', acts, seg=''), meta=FIRST) +
               '<div class="dimmer" style="z-index:8"></div>' +
               alert(300, 'This saved moment predates a split of this block', 'Restoring will resurrect the full pre-split text into this take’s buffer — the split-off half still exists next door.',
                     (('Restore anyway', 'al'), ('Cancel', ''))))

    def lin(verb, words, where, counts, acc='', me=False, mute=False):
        return ('<div class="lin%s" style="%s"><div class="mid"><div class="vb">%s</div><div class="t-prev ell" style="color:var(--ink)">%s</div><div class="t-meta">%s · %s</div></div>%s</div>'
                % (' me' if me else '', 'opacity:.55' if mute else '', verb, words, where, counts, acc))
    whole = 'To Sherlock Holmes she is always <i>the</i> woman. I have seldom heard him mention her under any other name. In his eyes she eclipses and predominates the whole of her sex. It was not that he felt any emotion akin to love for Irene Adler.'
    fam = (SEG(1) + SC_LINEAGE + '<div class="expl">family · older above</div>' +
           '<div class="gen">came from</div>' +
           lin('divided', whole, 'kept as lineage', '2 takes · 1 commit', ib(I_CHEV, 'mut')) +
           '<div class="gen">this generation</div>' +
           lin('this block', 'It was not that he felt any emotion akin to love for Irene Adler. All emotions…', 'here', '2 takes · 2 commits', me=True) +
           lin('divided', 'To Sherlock Holmes she is always the woman. I have seldom heard him…', 'this note', '1 take', ib(I_CHEV, 'mut')) +
           '<div class="gen">came of it</div>' +
           lin('a version', 'It was not that he felt any emotion akin to love for Irene Adler…', 'in “On keeping a commonplace book — talk”', '1 take', ib(I_CHEV, 'mut')) +
           lin('extracted', 'but as a lover he would have placed himself in a false position.', 'in the Trash', '1 take', mute=True) +
           '<div class="band" style="flex:1"></div>')
    lmeta = 'It was not that he felt any emotion…'
    c6 = phone(behind(), over=dimmer() + sheet(70, HT, fam, meta=lmeta))
    lacts = '<span class="btn solid">Put back</span><span class="btn fill">Bring back as a take</span>'
    c7 = phone(behind(), over=dimmer() + sheet(70, HT, pane('Lineage', 'The take as kept', 'divided · kept as lineage · take 1 of 2 · 1 commit', whole, '', lacts), meta=lmeta))
    emp = (SEG(1) + SC_LINEAGE + '<div class="band" style="flex:1;display:flex;align-items:center;justify-content:center;padding:0 40px 140px;text-align:center">'
           '<span class="t-ctl2" style="color:var(--muted2)">Nothing came before or after this block — it was never divided, merged, extracted or copied.</span></div>')
    c8 = phone(behind(), over=dimmer() + sheet(70, HT, emp, meta='He never spoke of the softer passions…'))
    return section(
        'C — commit, and History and lineage as one sheet',
        'Her ruling: commit is one tap in the quick row and saves at once; naming is optional, afterwards. History and lineage is ONE sheet with two tabs, opened from two doors: “History and lineage” in the block menu, and the History button on each take card. '
        'Her note on it: “there is a lineage element that isn’t from any one particular take.” So the two tabs say what they belong to. <b>Commits</b> belong to a take: a row of take chips filters them, and a take card’s door arrives already filtered to that take. '
        '<b>Lineage</b> belongs to the block: it has no take filter, says so in one line, and is the same list whichever door she came through.',
        row(frame(c0, 'C0', 'The quick row, her thumb on Commit.',
                  'Above the keyboard: ⋯, then Commit. Two taps from typing to a kept commit, with no sheet. (Drawn in full in <code>note-write.html</code>, C2–C5.)', 'ruled'),
            frame(c1, 'C1', 'Committed.',
                  'The take is committed at once, one commit per press (the cell latches, so a double tap is one commit). The line says so beside her thumb and offers “Name…”, which turns the capsule into a one-line name field. '
                  'This is the one ordinary act that answers, because a commit changes nothing she can see. ' + DW, 'ruled'),
            frame(c2, 'C2 · door 1', 'She taps History and lineage in the block menu.',
                  'One sheet, two tabs. Commits is first. One line says what the tab belongs to; under it the take chips (all takes, or one). '
                  'Then: name and commit from here. Then the list, newest first, each row one line: its name, or its first words when unnamed; when; “saved by hand” or “quiet”; which take. '
                  'Each take’s list is led by “The take now”. Quiet runs fold into one row. An AI edit made through the Mac shows as its before/after pair on a wash, never folded. '
                  'Deleted takes wait at the foot with Put back. ' + DW, 'ruled'),
            frame(c2t, 'C2 · door 2', 'From a take card instead: she taps History on “warmer”.',
                  'The same sheet, the same tab, already filtered to that take: its chip is on and the list is its commits only. Tapping “all takes” widens it. The Lineage tab is right there and does not change with the chip.', 'ruled'),
            frame(c3, 'C3', 'She taps “first pass”.',
                  'The commit opens as a reading pane: its full text at the note’s size. “plain · against now” switches a word-level wash (removed words struck, added words washed), with the count beneath. '
                  'The ↑ ↓ buttons, or a swipe, step to the next commit without going back. Three acts in the thumb row: Restore, Bring back as a take, Name…. ' + DW))
        + row(frame(c4, 'C4', 'She taps Restore.',
                    'The take now says the commit’s words, and the words it replaced were kept first as one quiet commit: the marked row, “just now”. That row is the answer; no message is shown. '
                    'Back on the page the block shows the restored text. (Her ruling #274, unwired on the phone today.)', 'ruled'),
              frame(c5, 'C5 · refusal', 'She restores a commit from before the block was divided.',
                    'The Mac’s warning, in the Mac’s words, before anything changes. The removing choice wears the alarm ink; Cancel is the default.', 'new'),
              frame(c6, 'C6 · either door', 'She taps Lineage.',
                    'The block’s family, older above, in bands. One line under the tabs says it plainly: this is for the whole block, not one take. There are no take chips here, and the list is the same whether she came from the block menu or from a take card. '
                    'Each member is one row: how it is related (divided, merged, extracted, copied, a version), its first words, where it lives, its counts. This block is marked. '
                    'A member in the Trash is muted and has no acts; a member in another wing names the wing and offers only Go to its wing. ' + DW, 'ruled'),
              frame(c7, 'C7', 'She taps the original the block was divided from.',
                    'The same reading pane, now on that block: an original kept as lineage names its text “the take as kept”. Its acts: Put back (it returns to the note it was set aside from, whole) and Bring back as a take '
                    '(its words become the last take in this block’s fan, never chosen). Nothing is said after either: the block’s takes badge counts one more.'),
              frame(c8, 'C8 · empty', 'Lineage on a plain block.',
                    'The Mac’s one empty line, under the same scope line. While a large family is being read the same place shows a spinner.', 'new')))


# ---------------------------------------------------------------- D
def D():
    expl = ('<div class="expl" style="font-size:15px;line-height:20px">Whole moments of this note, saved by hand. Opening one reads it; restoring makes the note say that again — and saves where it is now first, so none of its words are lost.</div>')
    save = '<div style="padding:0 16px 14px"><div class="btn solid" style="width:100%%;height:48px;font-size:17px">%s Save a version</div></div>' % I_VERS
    rows = (lrow('Nov 12, 2026 at 9:12 AM', '', '4 blocks', ib(I_CHEV, 'mut')) + lrow('Nov 10, 2026 at 4:30 PM', '', '3 blocks · saved for you', ib(I_CHEV, 'mut')) + '<div class="band" style="flex:1"></div>')
    d1 = phone(behind(), over=dimmer() + sheet(70, 'Versions', expl + save + rows, meta=TITLE))
    band = '<div class="idband">A saved version of “On keeping a commonplace book” · Nov 10, 2026 at 4:30 PM</div>'
    read = (band + '<div class="band" style="flex:1;padding:16px 20px 0"><div class="t-body">%s%s%s</div></div>' % (blk(OLD), blk(B2), blk(B3)) +
            '<div class="sfoot"><span class="btn solid">Restore</span><span class="btn fill">Promote</span><span class="tbtn al" style="flex:none">Delete…</span></div>')
    backv = '<div style="margin-top:-6px;padding:0 8px"><span class="tbtn">‹ %s</span></div>' % drs('D2', 'All versions', 'Back label when reading a saved version.')
    d2 = phone(behind(), over=dimmer() + sheet(70, 'Versions', backv + read, meta=''))
    d3 = phone(behind(), over=dimmer() + sheet(70, 'Versions', backv + read) + '<div class="dimmer" style="z-index:8"></div>' +
               alert(170, 'Make the note say this again?',
                     'Where the note is right now is saved as a new version first, so none of its words are lost. The note keeps its name, its books and everything that points at it.<br><br>'
                     'A version holds the words, not the history. Going with these paragraphs, and held by no version: 1 saved moment and 2 deleted takes. Nothing puts them back. '
                     'Promote instead keeps everything — it makes this moment a note of its own and deletes nothing.',
                     (('Restore', 'pri'), ('Promote instead', ''), ('Cancel', ''))))
    emp = (expl + save + '<div class="band" style="flex:1;display:flex;align-items:center;justify-content:center;padding:0 40px 60px;text-align:center">'
           '<span class="t-ctl2" style="color:var(--muted2)">No saved moments yet.</span></div>')
    d4 = phone(behind(), over=dimmer() + sheet(400, 'Versions', emp, meta=TITLE))
    return section(
        'D — whole-note versions', 'From the note’s menu: Save a version, and Versions. One sheet where saving and the list live together (today Save is in one sheet and the list is a pushed screen whose title is its smallest text). Every sentence here is the Mac’s.',
        row(frame(d1, 'D1', 'She taps Versions in the note’s menu.',
                  'The explainer is the shared sentence at 15 pt in the corrected ink. Save a version is a full-width button above the list; a new version appears as the list’s first row, which is its answer. '
                  'Each version is a 64 pt row: when it was saved, how many blocks, “saved for you” when it was automatic.'),
            frame(d2, 'D2', 'She taps a version.',
                  'It reads on the paper, not editable, under a band that says what it is (the Mac’s identity sentence). Three acts in the thumb row: Restore, Promote, Delete…. '
                  'Compare with now stays out until Compare arrives, after v1. ' + DW),
            frame(d3, 'D3', 'She taps Restore.',
                  'The Mac’s confirm with its real cost: the title, the reassurance, then exactly what goes with the current paragraphs and is held by no version, and the kinder road. Restore saves now first, then lands.'),
            frame(d4, 'D4 · empty', 'A note with no versions.', 'A sheet only as tall as it needs. The empty line is the shared one without its Mac keystroke.', 'new')))


NOTES = notes_table([
    ('A1–A4 · badge, pill, choose', 'W-136’s badge door; T1/T2 sizing (grade 2 screens 14–15); W-170’s place (NT-10, ruled)', 'MobileTakesChrome, MobileTakesController (the phone’s own takes brain); the chosen take lives on the pointer (I3)',
     'A tap on the badge opens the pill; the pill at the foot; the count; the conflict word on the badge; the ⌃ to the cards', 'Ruled: the visible badge, and tapping it for the pill at the foot. The swipe still works and opens the same pill. The pill’s words do not change. The tint aligns to the text column and the measure never moves. The badge’s conflict word reads the take’s label; it adds no store state. Choosing says nothing but the pill’s own “✓ chosen”. VoiceOver needs labels on the badge and the pill (W-014).', 'M'),
    ('B1–B6 · the takes sheet', 'W-148 (takes third), W-174, W-175, W-179; W-003’s header; W-172', 'MobileTakesBrowser and its Core ops (branchVariant, newBlankVariant, lockVariant, archiveVariant, deleteVariant, reorderTake, takeToBlockBelow, takesToBlocks); Core TakeLabelFace',
     'A native sheet; card foot row; the per-card branch; the conflict line', 'One live card at a time (P3). I10 refusals keep the build’s sentences. Borders re-resolve on a light/dark flip. Choose is a word; the tick is only a state. The conflict take’s signal is as drawn (ruled); its line is “Edited on two devices. Both versions are here.” A deleted or archived take answers with its line and Undo; nothing else does.', 'M'),
    ('C0–C1 · commit', 'W-180', 'Core commit, renameCommitPoint, Domain SavepointName', 'Commit in the quick row; the line with “Name…”; the name field (note-write C5)', 'Ruled: one tap, saves at once, naming optional afterwards. One commit per press. Naming never commits again. The app says “commit” (the Mac’s vocabulary rule).', 'S'),
    ('C2–C5 · the Commits tab', 'W-183, W-181 (her ruling #274), W-182, W-148 (history third)', 'Core Queries.blockHistory, Domain CommitRail and TextCompare, restoreCommit(insuringBuffer: true), bringBackCommitAsTake; the Mac’s CommitsFaceModel and CommitsFaceCopy once hoisted to Shared',
     'The phone face: a list that pushes a reading pane; the take chips; the scope line', 'Ruled: one sheet, two doors. The take card’s door arrives filtered to its take; the block menu’s door arrives on all takes. Hoist the model first; do not fork it. Restore flushes pending typing, then insures; the kept row is the answer, no message. The list scales with the block’s history, never the note. The wash is view-time only.', 'L'),
    ('C6–C8 · the Lineage tab', 'W-184', 'Core Queries.lineagePeers / lineageTree, Domain LineageFamily, bringBackFromLineage, placeBlock; the Mac’s LineageFaceModel and LineageFaceCopy once hoisted', 'The banded family list; the member pane; the block scope line',
     'Ruled: Lineage is per block. It never reads the take chip, never shows one, and is identical from either door. Depends on the Commits tab (one composition). Put back only on placeable members. A Trash member has no acts; another wing’s member only “Go to its wing”. The lineage fence lives in the operation.', 'L'),
    ('D1–D4 · versions', 'Sizes for V1 (grade 2 screen 30); part of W-150', 'MobileVersions; Shared VersionActs, VersionsCopy', 'One sheet instead of a sheet plus a pushed screen', 'The restore confirm keeps its real-cost paragraph whole. The shared empty sentence names ⌘⇧S; the phone needs its own ending.', 'S'),
])

INTRO = ('<p class="lede">VM-44, the note’s designer, revised after sitting 1. Takes on the phone: the badge she can see, the pill at her thumb, every take as cards; committing in one tap; '
         'History and lineage as one sheet; whole-note versions. Frames read left to right.</p>'
         '<p class="ruled"><b>What she chose.</b> The visible badge, and tapping it for the pill at the foot. The conflict take’s signal as drawn. '
         'Commit in the quick row, saving at once. History and lineage as ONE sheet (Commits per take, Lineage per block), opened from the block menu and from each take card. '
         'No message after an ordinary act; the only line here is the commit’s.</p>'
         '<p class="note">Seeded content: Essays ▸ “On keeping a commonplace book”, whose first block has three takes (original, warmer, shorter), one comment and one commit named “first pass”. '
         'The conflict take, the divided block’s family and the saved versions are drawn states over the same note. Sheets name their block by its first words, never by a number.</p>')

BODY = A() + B() + C() + D() + '<h2>Build notes</h2>' + NOTES + (
    '<p class="note" style="margin-top:14px"><b>Added to the sizing sheet’s vocabulary</b>: the pill (52 pt glass, two 44 pt arrows, a label with ⌃, a labelled Choose); the take card with a foot row; '
    'the sheet foot bar; the scope line under a tab; the reading pane with its plain / against-now switch and step buttons; the lineage row and generation band; the identity band.</p>')

write('takes-and-history.html', 'The note — takes, history and lineage, versions', INTRO, BODY)
