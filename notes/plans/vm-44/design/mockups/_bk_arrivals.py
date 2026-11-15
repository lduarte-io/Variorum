# VM-44 books designer — arrivals.html (throwaway generator; static HTML out).
import sys, os
sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
from _bk_base import *

HOME_CHIPS = ["★ Starred", "Unshelved", "✎ Writing", "Reading &amp; reference", "☼ Life", "Welcome", "All"]
WRITING = [brow("Essays", "8 notes · #essay #goals", STAR), brow("Blog drafts", "7 notes · #blog #draft"),
           brow("Letters", "3 notes · finished", FIN), brow("Ideas inbox", "3 notes · 5 waiting", badge(5))]
bookcase = P(mast("Home"), dots(0), chips(HOME_CHIPS, 2), lst(*WRITING, '<div class="addrow">+ New book on Writing</div>'), qe_rest(), tabs_words(1), hi(),
             '<div class="zone" style="top:384px;height:66px"></div>')
INBOX = [nrow("Faster cold start", "Mon", "Measure first. The store opens off the main thread already."),
         nrow("Undo history panel", "Nov 3", "A list of what ⌥⌘Z would undo, newest first."),
         nrow("Keyboard shortcuts on iPad", "Oct 29", "Not planned. Written down so I stop thinking about it.")]
def inbox(right, rows=INBOX, meta="3 notes · collects #idea", *over, cls=''):
    return P(bookhead("Ideas inbox", meta, right), lst(*rows), foot("New note in this book…"), hi(), *over, cls=cls)

OWN = lambda s: '<div class="own">%s%s</div>' % (I_SHARED if s.startswith('also') else I_BOOK, s)
def arow(title, why, since, reason=None, own=None, arms=("Add", "Dismiss"), archived=False, sel=None, cls=''):
    mark = '<span class="amark">archived</span>' if archived else ''
    r = '<div class="rsn">“%s”</div>' % reason if reason else ''
    o = OWN(own) if own else ''
    w = '<div class="why">%s%s</div>' % ('<b>%s</b> · ' % why if why else '', since)
    if sel is None:
        a = '<div class="arms">%s</div>' % ''.join('<span class="arm %s">%s</span>' % ('dis' if x == 'Dismiss' else 'add', x) for x in arms) if arms else '<div style="height:8px"></div>'
        return '<div class="arow %s"><div class="at"><span class="x">%s</span>%s</div>%s%s%s%s</div>' % (cls, title, mark, w, r, o, a)
    c = '<span class="selc%s">%s</span>' % (' on' if sel else '', I_CHECK if sel else '')
    return '<div class="arow selm%s">%s<div class="at"><span class="x">%s</span>%s</div>%s%s%s</div>' % (' selon' if sel else '', c, title, mark, w, r, o)

MAP = dict(title="Map of every walk", why="Tagged #idea", since="waiting since Nov 3")
KEEP = dict(title="The keeper’s logbook as a frame", why="Tagged #idea", since="waiting since Nov 6")
BREAD = dict(title="Write the bread recipe as a poem", why="Tagged #idea", since="waiting since Nov 9", own="owned by “Recipes”", arms=("Copy in", "Dismiss"))
WHATIF = dict(title="what if the essay is actually a letter?", why="Proposed by Claude", since="waiting since yesterday",
              reason="It answers the question in ‘Letters I never sent’ — worth keeping beside the other essay ideas.")
POD = dict(title="The podcast, first attempt", why="Caught up after reopening the book", since="waiting since today 9:12 AM", archived=True)
ALL5 = [MAP, KEEP, BREAD, WHATIF, POD]
SELECT = '<span class="pill">Select</span>'
def fbar(a="Add all", d="Dismiss all", fill=False, off=False):
    return '<div class="fbar">%s%s</div>' % (btn(a, 'fill' if fill else 'plain', off), btn(d, 'plain', off).replace('class="btn plain', 'style="color:var(--meta)" class="btn plain'))
def review(rows, title, right=SELECT, left=BACK, footer=None, extra='', sub="Ideas inbox · oldest first", cls='', over=()):
    f = fbar() if footer is None else footer
    return P(nav(right, left), '<div class="btitle">%s</div><div class="sub">%s</div>' % (title, sub), lst(*rows), extra, f, hi(), *over, cls=cls)
H = lambda n: "Arrivals — %d waiting" % n

def swl(d): return '<div class="swipe"><span class="act l">%s Add</span><div class="sl">%s</div></div>' % (I_CHECK, arow(**d))
def swr(d): return '<div class="swipe"><span class="act r">%s Dismiss</span><div class="sr">%s</div></div>' % (I_X, arow(**d))

MAP_NOTE = ["Pin every walk where a paragraph arrived.",
            "Not the route — the place. The bench by the weir where the second section of the commonplace essay turned up. The bakery corner. The bridge, twice.",
            "After a year the map would say where I think, which is not where I thought I thought."]
def notepage(title, chip, paras, bottom='', cls='', over=()):
    return P(nav(cb(I_SEARCH) + MORE), '<div class="page"><div class="ntitle">%s</div><div class="nchip">%s</div>%s</div>' % (title, chip, ''.join('<p>%s</p>' % p for p in paras)),
             bottom, hi(), *over, cls=cls)
WAITSTRIP = '<div class="strip"><span class="smid" style="padding:0 20px;justify-content:flex-start">%sWaiting at Arrivals<span>&nbsp;· not in “Ideas inbox” yet</span></span></div>' % I_TRAY

LAW = '<div class="c13b" style="margin-top:4px">Adding a note to a book never copies it — a copy only happens because you choose one, and it always remembers where it came from.</div>'
LEAD = lambda s: '<div class="c13b" style="font-size:15px;line-height:21px;color:var(--ink);margin-top:0">%s</div>' % s

# ---------------------------------------------------------------- 1 where the count shows
s1 = [
    opt(bookcase, "BK-3 · count", "On the Bookcase row.",
        "The book’s row carries the number waiting as its one trailing mark, and says it in the meta line too (“3 notes · 5 waiting”). Core already delivers the count with the row; the phone has never read it. "
        "The frame is BK-1 (a), not redrawn; the dashed outline is an annotation."),
    opt(inbox(arr(5) + READ + MORE), "BK-3 · count", "On the book’s bar.",
        "Inside the book the Arrivals door sits in the bar beside Read: filled, with the number, while something waits. Tapping it pushes the review. "
        "The waiting notes are not in the list below — an arrival is not a member, and is never counted or listed as one.", mine=True),
    opt(inbox(TRAY0 + READ + MORE), "BK-3 · calm", "The same door with nothing waiting.",
        "Calm, as on the Mac: the tray alone in the muted ink, no number. It still opens the review, which then says what Arrivals is for. A gathering has no such door."),
]

# ---------------------------------------------------------------- 2 the review
SPEC = [dict(title="Why the heron stands on one leg", why="Starred", since="waiting since Nov 2"),
        dict(title="Reading list for the winter", why="Matched the book’s new rule, set by Claude", since="waiting since Nov 4"),
        dict(title="Thursday 5 November", why="Filed for today — another book owns it", since="waiting since Nov 5", own="owned by “Lisbon trip”"),
        dict(title="Lentil soup, the Tuesday one", why="Came back while another book owns it", since="waiting since Nov 8", own="owned by “Recipes”"),
        dict(title="Expense report reminder", why="Filed here from another wing — the note lives with another book now", since="waiting since Nov 9"),
        dict(title="Books to borrow", why="Matched when the book was made", since="waiting since Nov 10"),
        dict(title="Gift ideas", why="Caught up after un-archiving", since="waiting since yesterday"),
        dict(title="Questions for the accountant", why=None, since="waiting since Oct 12")]
s2 = [
    opt(review([arow(**d) for d in ALL5], H(5)), "BK-3 (a)", "The review, full screen.",
        "She tapped the door. The header is the Mac’s (“Arrivals — 5 waiting”). Rows are oldest first. Each says the note’s name, <b>why it waits</b> in the Mac’s words, <b>since when</b>, "
        "and — for a note an AI client proposed — the client’s reason in its own words. Add and Dismiss are on every row; a note another book owns shows “owned by” and offers Copy in instead of Add; "
        "an archived note wears its mark. The foot carries the two bulk doors.", mine=True),
    opt(review([swl(MAP), swr(KEEP)] + [arow(**d) for d in ALL5[2:]], H(5)), "BK-3 (a) · swipe", "Swipe to judge.",
        "Swipe a row right to add it, left to dismiss it; a full swipe commits. The buttons on the row do the same thing, so the swipe is a shortcut and never the only door. "
        "(Both rows are shown mid-swipe; in use it is one at a time.)", mine=True),
    opt(notepage("Map of every walk", "No book · #idea", MAP_NOTE, bottom=WAITSTRIP), "open", "Opening a waiting note never adds it.",
        "She tapped the row’s name. The note opens as any note does, to read or edit; one quiet line at the foot says it is still waiting. Back returns to the review, where the row is exactly as she left it. "
        "Add and Dismiss stay in the review, as on the Mac."),
    opt(review([arow(**d) for d in ALL5[1:]], H(4), extra=msg("“Map of every walk” added at the end of the book.", "Open ›")), "receipt", "After adding one.",
        "The row leaves, the count drops, and one quiet line says where the note went, with a door to it. The review stays open — its own acts never close it. "
        "Dismiss says “Dismissed “Map of every walk” — it won’t come back on its own; add it by hand any time.” Neither has an undo, as on the Mac."),
    opt(review([arow(**dict(d, sel=(d is KEEP or d is WHATIF))) for d in ALL5[1:]], "2 selected", right='<span class="pill fill">Done</span>',
               left='<span class="pill">Select all</span>', footer=fbar("Add 2", "Dismiss 2", fill=True)), "multi-select", "Select, then Add N or Dismiss N.",
        "“Select” turns each row into a tick target and the foot’s doors into the selection’s: Add 2, Dismiss 2. Each press judges the picked rows in the list’s order and answers with one message. "
        "“Select all” picks every row; Done leaves the mode.", mine=True),
    opt(review([arow(**d) for d in ALL5[1:]], H(4),
               over=(confirm(None, "Dismiss all 4 waiting notes?", ["None of them will come back on their own — you can still add any of them by hand."],
                             [btn("Dismiss 4", "alarm"), btn("Cancel", "quiet")]),)), "Dismiss all", "Dismiss all asks once, with the count.",
        "The one bulk door that confirms, because nothing undoes it. The count in the title is the header’s. Add all, Add N and Dismiss N act without asking."),
    opt(review([arow(**BREAD)], H(1),
               extra=msg("Added 3 notes at the end of the book. One is archived, so it waits in the book’s archived line. “Write the bread recipe as a poem” waits on your choice — it lives in another book, so Copy in or Move in on its row decides.")),
        "Add all", "After Add all: the row that needs a choice stays.",
        "Three were added in the order they arrived. The note another book owns cannot simply be added, so it is named, kept, and left for her to decide on its own row. One message per press, the Mac’s sentences."),
    opt(review([arow(**BREAD)], H(1),
               over=(sheet(None, shead("Add “Write the bread recipe as a poem” to “Ideas inbox”?", "Cancel", strong=False).replace('class="st"', 'class="st" style="padding:10px 0"'),
                           LEAD("This note belongs to “Recipes”, which owns its notes."),
                           choice("Copy in", "Only a copy can come in: a linked copy joins “Ideas inbox”; the original stays in “Recipes”, unchanged."), LAW),)),
        "choice", "A row that needs a choice opens the membership choice sheet.",
        "She tapped Copy in. The same sheet every ownership refusal opens (<code>a-book.html</code>, section 6), here in its one-choice form: the note is owned elsewhere, so only a copy can come in, and the sheet says so before she commits."),
    opt(review([arow(title="The case for slow mornings", why="Tagged #reading", since="waiting since Nov 10", own="also in “Essays”", arms=("Copy in", "Move in", "Dismiss"))],
               H(1), sub="Reading notes · owns its notes",
               over=(sheet(None, shead("Add “The case for slow mornings” to “Reading notes”?", "Cancel", strong=False).replace('class="st"', 'class="st" style="padding:10px 0"'),
                           LEAD("“Reading notes” owns its notes. This note also lives in “Essays”."),
                           choice("Copy in", "A linked copy joins “Reading notes”; the original stays in “Essays”, unchanged."),
                           choice("Move in", "It leaves “Essays”, and lives only in “Reading notes”."), LAW),)),
        "choice · two", "The other case: a book that owns its notes.",
        "When the book being reviewed owns its notes and the arrival also lives elsewhere, the row offers Copy in, Move in and Dismiss with an “also in” line, and either arm opens the two-choice sheet."),
    opt(review(['<div class="empty">Nothing is waiting. Notes this book’s rule brings in while its dial says “wait at Arrivals,” and notes an AI proposes, wait here for you.</div>'],
               "Arrivals", right='', footer='',
               extra=msg("Copied “Write the bread recipe as a poem” in at the end of the book — a linked copy; the original stays where it was.", "Open ›")),
        "empty", "Nothing waiting.",
        "After the last judgment the review stays and says, in the Mac’s sentence, what Arrivals is for. The bulk doors and Select are not drawn with nothing to act on. This is also what the calm door opens."),
    opt(inbox(TRAY0 + READ + MORE,
              INBOX + [nrow("Map of every walk", "Nov 3", "Pin every walk where a paragraph arrived."),
                       nrow("The keeper’s logbook as a frame", "Nov 6", "Tell the lighthouse story entirely in logbook entries."),
                       nrow("what if the essay is actually a letter?", "Yesterday", "Or a letter that keeps forgetting who it is to."),
                       nrow("Write the bread recipe as a poem", "Nov 9", "Flour, water, salt, and patience in the wrong order.", shared=True),
                       '<div class="winline">1 archived <b>›</b></div>'],
              "7 notes · 1 archived · collects #idea"), "after", "Back in the book.",
        "The door is calm again. The four notes she added sit at the end in the order they arrived; the copy wears the shared mark; the archived one is counted honestly and kept behind the book’s archived line, not in the list."),
    opt(review([arow(**d) for d in ALL5[1:]], H(4), extra=msg("“Ideas inbox” is at its note cap — extend the cap in its settings.", refusal=True)), "refusal", "A refusal.",
        "Nothing happened, and the line says why in the alarm ink; the row stays. In bulk the same reason is counted (“2 couldn’t be added: …”) and the rest keep waiting. "
        "This sentence points at the note cap, which the phone’s settings do not carry yet (BK-8) — a builder must give it a road or a different sentence."),
    opt(review([arow(**dict(d, arms=None)) for d in SPEC], "Arrivals — 8 waiting", sub="a specimen · every other reason a note can wait", footer='', right=''),
        "vocabulary", "The rest of the why-it-waits words.",
        "Not a real book: one row for each remaining reason the Mac can say (starred; a rule edit, with the client that set it; a journal filing; a return while owned; the wing mend; the backfill; a catch-up), "
        "and last an arrival from before reasons were recorded, which shows since-when only. The row buttons are left off this specimen."),
    opt(review([arow(**d) for d in ALL5], H(5), cls='dk'), "dark", "The review in dark.", "The room is black, the rows sit on the dark paper, and the AI’s reason keeps the reading face."),
    opt(review([arow(**d) for d in ALL5[:4]], H(5), cls='xl'), "largest text", "The review at the largest standard text size.",
        "Names wrap to two lines, the why and since lines wrap rather than truncate, and the row buttons grow. About three rows show per screen; the bulk doors keep their place at the foot."),
]

# ---------------------------------------------------------------- 3 the alternatives, small
B_ALT = P(bookhead("Ideas inbox", "3 notes · collects #idea", READ + MORE),
          lst('<div class="sec tap"><span>Arrivals — 5 waiting</span><span class="n">Add all · Dismiss all ⌄</span></div>',
              arow(**MAP), arow(**KEEP), arow(**BREAD),
              '<div class="sec tap"><span>The book</span><span class="n">3 notes</span></div>', *INBOX),
          foot("New note in this book…"), hi())
C_ALT = inbox(arr(5) + READ + MORE, INBOX, "3 notes · collects #idea",
              sheet(330, shead(H(5), "Done", left="Select"), '<div style="background:var(--surface);border-top:1px solid var(--line)">%s%s%s</div>' % (arow(**MAP), arow(**KEEP), arow(**BREAD)), fbar()))
s3 = [
    opt(review([arow(**d) for d in ALL5], H(5)), "BK-3 (a)", "Full screen.", "All five rows, their reasons and both bulk doors on one screen; room for the AI’s reason and the ownership line. One push away from the book.", mine=True, small=True),
    opt(B_ALT, "BK-3 (b)", "A section at the top of the contents.", "Nothing to open: the waiting notes head the list. But three arrivals push the book’s own notes off the first screen, arrivals read as if they were in the book, and select mode has to share a list with members.", small=True),
    opt(C_ALT, "BK-3 (c)", "A sheet at a medium detent.", "The book stays in view behind it. But only two and a half rows fit above the bulk doors, the AI’s reason is the first thing to be cut, and a sheet over a sheet follows as soon as a row needs a choice.", small=True),
]

INTRO = """
<p class="lede"><b>VM-44 mockups — Arrivals.</b> Today the phone has no Arrivals at all: no count on a book’s row, no door, no review, no reason and no way to add or dismiss.
Notes her own tags and stars send to a book, a journal entry that has to wait, and anything an AI client proposes all pile up unseen — and the one act that touches them, Finish, dismisses them without a word.
These frames draw question <b>BK-3</b>: where a book’s waiting notes show, and how she judges them on a phone.</p>
<p class="lede">The book is the seeded “Ideas inbox” (collects #idea; new matches wait at Arrivals). The seed has three notes waiting; two more are drawn so the frames can show a proposal with its reason and an archived note —
five in all. Words are the Mac’s own (<code>ArrivalsCopy</code>, <code>ArrivalsReviewCopy</code>), set in sentence case. A green label marks my pick.</p>
"""
sections = [
    ("1 · Where the waiting notes show", '<p class="lede">A count in two places and nowhere else: the book’s row on the Bookcase, and the door in the book’s bar.</p>', s1),
    ("2 · The review — BK-3 (a), my pick", '<p class="lede">The flow in order: open, judge one, open a note to read it, select several, the bulk doors, the row that needs a choice, the end.</p>', s2),
    ("3 · The three shapes side by side, small", '<p class="lede">The same five arrivals in each option of BK-3.</p>', s3),
]
NOTES = """
<div class="pick" style="max-width:1500px"><h2>My pick: BK-3 (a), the full-screen review</h2>
<p>It is the Mac’s “one home, in the full book area” in a phone’s grammar: a pushed screen with the Mac’s header, a row that has room for why, since-when, the AI’s reason and the ownership line,
visible Add and Dismiss with swipes as their shortcut, and a foot that carries the bulk doors and becomes the selection’s. It keeps arrivals out of the contents list, which matters because an arrival is not a member.
(b) is tempting for a book with one or two waiting but makes the book’s own list unreadable at five; (c) is (a) with less room and a sheet-on-sheet the moment a choice is needed.</p>
<p>What would change my mind: if she wants to judge without leaving the list, (b) could be offered only while three or fewer wait — but that is two faces to build and keep in step.</p></div>

<h2>Build notes</h2>
<table class="bn">
<tr><th>Screen</th><th>Work-list rows it delivers</th><th>Shared brain it stands on</th><th>What is new</th><th>Must not get wrong</th><th>Size</th></tr>
<tr><td>The count (Bookcase row, book bar)</td><td>W-101 (the door and count), part of W-067</td>
<td>Core <code>ShelfBook.arrivalCount</code> (already delivered by <code>Queries.bookshelf</code>, never read on the phone); Mac-local <code>ArrivalsCopy.doorCount</code> / <code>doorHelp</code> — hoist owed.</td>
<td>The filled door with a number; the calm door.</td>
<td>The count is arrivals only — never added to “N notes”. The door draws on a book, never on a gathering. Cost stays with the rows drawn.</td><td>S</td></tr>
<tr><td>The review (rows, why, since, open)</td><td>W-101, W-104 (the archived mark and line)</td>
<td>Core <code>Queries.BookArrival</code>, <code>ArrivalProvenance</code>, <code>seatArrival</code>, <code>dismissArrival</code>, <code>TimeStampFace.relative</code>. Hoists owed: <code>BookArrivalsModel</code>, <code>ArrivalsCopy</code>, <code>ArrivalsReviewCopy</code> (<code>why</code>, <code>reason</code>, <code>since</code>, <code>nothingWaiting</code>), <code>ArchivedLineCopy</code>.</td>
<td>The pushed screen; the row; swipe panels; the “still waiting” line on an opened note.</td>
<td>Rows oldest first. Opening a row never seats it. The review’s own acts never close it. No undo on Add or Dismiss — so no “Undo” door is drawn. The proposal’s reason is the client’s prose, shown as written and never as the app’s voice. An arrival with no recorded reason shows since-when only. The list is windowed.</td><td>L</td></tr>
<tr><td>Copy in / Move in on a row</td><td>W-102, W-108</td>
<td>Core <code>OwnershipDecision</code>, <code>copyPostIntoReading(answering:)</code>, <code>movePostIntoReading(answering:)</code>. Hoist owed: <code>MembershipChoiceCopy</code>, the arms’ “owned by” / “also in” lines.</td>
<td>The arms on the row; the choice sheet opened from the review.</td>
<td>Which arms draw is the ownership decision’s, never a guess from the row. A move that would leave a finished or sealed book is dimmed with its sentence.</td><td>M</td></tr>
<tr><td>Select, Add N / Dismiss N, Add all / Dismiss all</td><td>W-103</td>
<td>Mac-local pure <code>ArrivalsBulk</code> (<code>ArrivalsReviewRules.swift</code>) and the bulk words in <code>ArrivalsReviewCopy</code> — hoist owed.</td>
<td>The select mode (the phone’s multi-select grammar, shared with the Library’s — VM-31); the foot bar that changes with the selection.</td>
<td>Per-row acts in listing order; one message per press; rows that need a choice are named, kept waiting and kept selected; a book-level refusal ends the run and counts the rest as waiting. Only Dismiss all confirms, and its count is the header’s, read at the press.</td><td>M</td></tr>
<tr><td>Empty, receipt, refusal</td><td>W-101, W-012 (the one message line), W-013</td>
<td>The same hoisted copy; Shared <code>OpsRefusalTable</code>.</td>
<td>—</td>
<td>Receipts follow the synced <code>receipt_style</code>; refusals always show. The note-cap refusal names a setting the phone does not have yet (BK-8).</td><td>S</td></tr>
</table>
<table class="bn" style="max-width:1000px">
<tr><th>Why it waits (the stamp’s kind)</th><th>The Mac’s words, as the row says them</th></tr>
<tr><td>proposed</td><td>Proposed by ‹client› — and under it the client’s reason, in quotes</td></tr>
<tr><td>rule_edit</td><td>Matched the book’s new rule (“, set by ‹client›” when an AI set it)</td></tr>
<tr><td>backfill</td><td>Matched when the book was made</td></tr>
<tr><td>catchup</td><td>Caught up after restoring the book · after reopening the book · after un-archiving · after unsealing the book</td></tr>
<tr><td>tagged</td><td>Tagged #‹tag› (“by ‹client›” when an AI tagged it)</td></tr>
<tr><td>starred</td><td>Starred (“by ‹client›” when an AI starred it)</td></tr>
<tr><td>journal_filing</td><td>Filed for today — another book owns it</td></tr>
<tr><td>owned_elsewhere</td><td>Came back while another book owns it</td></tr>
<tr><td>wing_mend</td><td>Filed here from another wing — the note lives with another book now</td></tr>
<tr><td>no stamp</td><td>(no reason) waiting since …</td></tr>
</table>
<p class="note-ann"><b>Added to the sizing sheet’s vocabulary</b> (in its spirit): the arrival row (name 17, why and since 13, the reason in Iowan 15 italic, 32 pt row buttons inside a 44 pt band);
104 pt swipe panels (Add in the accent, Dismiss in the meta ink); a 26 pt selection tick in a 44 pt target; a two-button foot bar (48 pt); the filled count door (44 pt).
Everything else — the confirm sheet, the choice sheet, the message line — is shared with <code>a-book.html</code>.</p>
"""
write('arrivals.html', 'VM-44 mockups — Arrivals', INTRO, sections, NOTES, check_dir=os.environ.get('BK_CHECK'))
