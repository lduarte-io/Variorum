# VM-44 books designer — arrivals.html (throwaway generator; static HTML out). Revision pass: drawn to sitting-1-rulings.md.
import sys, os
sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
from _bk_base import *
_opt, _n = opt, [0]
def opt(frame, oid, *a, **k):      # number every frame so the wording list can point at it
    _n[0] += 1
    return _opt(frame, "%d · %s" % (_n[0], oid), *a, **k)
BAR = tabs_words(1)          # the bottom bar: on roots and lists, never inside a note (LK-5)

HOME_CHIPS = ["★ Starred", "Unshelved", "✎ Writing", "Reading &amp; reference", "☼ Life", "Welcome", "All"]
WRITING = [brow("Essays", "8 notes · #essay #goals", STAR), brow("Blog drafts", "7 notes · #blog #draft"),
           brow("Letters", "3 notes · finished", FIN), brow("Ideas inbox", "3 notes · 5 waiting", badge(5))]
bookcase = P(mast("Home"), dots(0), chips(HOME_CHIPS, 2), lst(*WRITING, '<div class="addrow">+ New book on Writing</div>'), qe_rest(text='New note'), BAR, hi(),
             '<div class="zone" style="top:384px;height:66px"></div>')
INBOX = [nrow("Faster cold start", "Nov 9", "Measure first. The store opens off the main thread already."),
         nrow("Undo history panel", "Nov 3", "A list of what ⌥⌘Z would undo, newest first."),
         nrow("Keyboard shortcuts on iPad", "Oct 29", "Not planned. Written down so I stop thinking about it.")]
def inbox(right, rows=INBOX, meta="3 notes · collects #idea", *over, cls=''):
    return P(bookhead("Ideas inbox", meta, right), lst(*rows), foot("New note in this book…"), BAR, hi(), *over, cls=cls)

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
    return P(nav(right, left), '<div class="btitle">%s</div><div class="sub">%s</div>' % (title, sub), lst(*rows), extra, f, BAR, hi(), *over, cls=cls)
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
    opt(bookcase, "count", "On the Bookcase row.",
        "The book’s row carries the number waiting as its one trailing mark, and says it in the line under the name too (“3 notes · 5 waiting”). The dashed outline is an annotation."),
    opt(inbox(arr(5) + READ + MORE), "count", "On the book’s top bar.",
        "Inside the book the Arrivals door sits in the top bar beside Read: filled, with the number, while something waits. Tapping it opens the review. "
        "The waiting notes are not in the list below — an arrival is not in the book yet, and is never counted or listed as if it were."),
    opt(inbox(TRAY0 + READ + MORE), "calm", "The same door with nothing waiting.",
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
FULL = ('<div class="msg refusal" style="align-items:center"><span>“Ideas inbox” is full — its limit is 3 notes.</span><b style="color:var(--accent)">Book settings ›</b></div>')
s2 = [
    opt(review([arow(**d) for d in ALL5], H(5)), "review", "The review, full screen.",
        "She tapped the door. The header is the Mac’s (“Arrivals — 5 waiting”). Rows are oldest first. Each says the note’s name, <b>why it waits</b> in the Mac’s words, <b>since when</b>, "
        "and — for a note an AI client proposed — the client’s reason in its own words. Add and Dismiss are on every row; a note another book owns shows “owned by” and offers Copy in instead of Add; "
        "an archived note wears its mark. The foot carries the two bulk doors, then the bottom bar: this is a list."),
    opt(review([swl(MAP), swr(KEEP)] + [arow(**d) for d in ALL5[2:]], H(5)), "swipe", "Swipe to add or dismiss.",
        "Swipe a row right to add it, left to dismiss it; a full swipe commits. The buttons on the row do the same thing, so the swipe is a shortcut and never the only door. "
        "(Both rows are shown mid-swipe; in use it is one at a time.)"),
    opt(notepage("Map of every walk", "No book · #idea", MAP_NOTE, bottom=WAITSTRIP), "open", "Opening a waiting note never adds it.",
        "She tapped the row’s name. The note opens as any note does, to read or edit; one quiet strip at the foot says it is still waiting. Back returns to the review, where the row is exactly as she left it. "
        "Add and Dismiss stay in the review, as on the Mac. No bottom bar: this is a note."),
    opt(review([arow(**d) for d in ALL5[1:]], H(4)), "after Add", "After adding one.",
        "The row leaves and the count drops. Nothing is said: adding is an ordinary act and she can see it happened. The review stays open — its own acts never close it."),
    opt(review([arow(**d) for d in ALL5[1:]], H(4), extra=msg("Dismissed “Map of every walk” — it won’t come back on its own; add it by hand any time.")), "after Dismiss", "After dismissing one.",
        "The row leaves, and this time one line shows, in the Mac’s words: something left the page. There is no Undo on it, because the Mac has none for a dismissal — the line says how to get the note back instead. "
        "Whether the phone should add an Undo here is open (see the notes)."),
    opt(review([arow(**dict(d, sel=(d is KEEP or d is WHATIF))) for d in ALL5[1:]], "2 selected", right='<span class="pill fill">Done</span>',
               left='<span class="pill">Select all</span>', footer=fbar("Add 2", "Dismiss 2", fill=True)), "select", "Select, then Add N or Dismiss N.",
        "“Select” turns each row into a tick target and the foot’s doors into the selection’s: Add 2, Dismiss 2. Each press acts on the picked rows in the list’s order. "
        "“Select all” picks every row; Done leaves the mode."),
    opt(review([arow(**d) for d in ALL5[1:]], H(4),
               over=(confirm(None, "Dismiss all 4 waiting notes?", ["None of them will come back on their own — you can still add any of them by hand."],
                             [btn("Dismiss 4", "alarm"), btn("Cancel", "quiet")]),)), "Dismiss all", "Dismiss all asks once, with the count.",
        "The one bulk door that confirms, because nothing undoes it. The count in the title is the header’s. Add all, Add N and Dismiss N act without asking."),
    opt(review([arow(**BREAD)], H(1),
               extra=msg("“Write the bread recipe as a poem” waits on your choice — it lives in another book, so Copy in or Move in on its row decides.")),
        "Add all", "After Add all: the row that needs a choice stays.",
        "Three were added in the order they arrived; the archived one sits behind the book’s archived line. The note another book owns cannot simply be added, so it stays, and one line says why. "
        "It is the Mac’s sentence, and it shows because something she asked for did not happen."),
    opt(review([arow(**BREAD)], H(1),
               over=(sheet(None, shead("Add “Write the bread recipe as a poem” to “Ideas inbox”?", "Cancel", strong=False).replace('class="st"', 'class="st" style="padding:10px 0"'),
                           LEAD("This note belongs to “Recipes”, which owns its notes."),
                           choice("Copy in", "Only a copy can come in: a linked copy joins “Ideas inbox”; the original stays in “Recipes”, unchanged."), LAW),)),
        "choice", "A row that needs a choice opens the membership choice sheet.",
        "She tapped Copy in. The same sheet every ownership refusal opens (<code>a-book.html</code>, section 7), here in its one-choice form: the note is owned elsewhere, so only a copy can come in, and the sheet says so before she commits."),
    opt(review([arow(title="The case for slow mornings", why="Tagged #reading", since="waiting since Nov 10", own="also in “Essays”", arms=("Copy in", "Move in", "Dismiss"))],
               H(1), sub="Reading notes · owns its notes",
               over=(sheet(None, shead("Add “The case for slow mornings” to “Reading notes”?", "Cancel", strong=False).replace('class="st"', 'class="st" style="padding:10px 0"'),
                           LEAD("“Reading notes” owns its notes. This note also lives in “Essays”."),
                           choice("Copy in", "A linked copy joins “Reading notes”; the original stays in “Essays”, unchanged."),
                           choice("Move in", "It leaves “Essays”, and lives only in “Reading notes”."), LAW),)),
        "choice · two", "The other case: a book that owns its notes.",
        "When the book being reviewed owns its notes and the arrival also lives elsewhere, the row offers Copy in, Move in and Dismiss with an “also in” line, and either arm opens the two-choice sheet."),
    opt(review(['<div class="empty">Nothing is waiting. Notes this book’s rule brings in while its dial says “wait at Arrivals,” and notes an AI proposes, wait here for you.</div>'],
               "Arrivals", right='', footer=''),
        "empty", "Nothing waiting.",
        "After the last one the review stays and says, in the Mac’s sentence, what Arrivals is for. The bulk doors and Select are not drawn with nothing to act on. This is also what the calm door opens."),
    opt(inbox(TRAY0 + READ + MORE,
              INBOX + [nrow("Map of every walk", "Nov 3", "Pin every walk where a paragraph arrived."),
                       nrow("The keeper’s logbook as a frame", "Nov 6", "Tell the lighthouse story entirely in logbook entries."),
                       nrow("what if the essay is actually a letter?", "yesterday", "Or a letter that keeps forgetting who it is to."),
                       nrow("Write the bread recipe as a poem", "Nov 9", "Flour, water, salt, and patience in the wrong order.", shared=True),
                       '<div class="winline">1 archived <b>›</b></div>'],
              "7 notes · 1 archived · collects #idea"), "after", "Back in the book.",
        "The door is calm again. The four notes she added sit at the end in the order they arrived; the copy wears the shared mark; the archived one is counted and kept behind the book’s archived line, not in the list."),
    opt(review([arow(**d) for d in ALL5[1:]], H(4), extra=FULL), "refusal", "A refusal: the book is full.",
        "Nothing happened, and the line says why in the alarm ink; the row stays. The door opens Book settings, where the note limit is now shown and can be raised (<code>a-book.html</code>, section 6). "
        "In bulk the same reason is counted and the rest keep waiting."),
    opt(review([arow(**dict(d, arms=None)) for d in SPEC], "Arrivals — 8 waiting", sub="a specimen · every other reason a note can wait", footer='', right=''),
        "words", "The rest of the why-it-waits words.",
        "Not a real book: one row for each remaining reason the Mac can say (starred; a rule edit, with the client that set it; a journal filing; a return while owned; the wing mend; the backfill; a catch-up), "
        "and last an arrival from before reasons were recorded, which shows since-when only. The row buttons are left off this specimen."),
    opt(review([arow(**d) for d in ALL5], H(5), cls='dk'), "dark", "The review in dark.", "The room is black, the rows sit on the dark paper, and the AI’s reason keeps the reading face."),
    opt(review([arow(**d) for d in ALL5[:4]], H(5), cls='xl'), "largest text", "The review at the largest standard text size.",
        "Names wrap to two lines, the why and since lines wrap rather than truncate, and the row buttons grow. About three rows show per screen; the bulk doors keep their place at the foot."),
]

INTRO = """
<p class="lede"><b>VM-44 mockups — Arrivals.</b> Revised after the first sitting: every frame follows <code>plans/sitting-1-rulings.md</code>.
Today the phone has no Arrivals at all: no count on a book’s row, no door, no review, no reason and no way to add or dismiss.
Notes her own tags and stars send to a book, a journal entry that has to wait, and anything an AI client proposes all pile up unseen — and the one act that touches them, Finish, dismisses them without a word.</p>
<p class="q">Arrivals: “Full-screen review” · the “Open Arrivals first” button on the Finish confirm: “Keep it” · which acts show a line: “Only removals and refusals”</p>
<p class="lede"><b>What was chosen, in one line.</b> A count on the Bookcase row and on the book’s top bar; a full-screen review that says why each note waits and since when, with swipe to add or dismiss,
selecting several, and a Dismiss all that asks once. The two smaller shapes (a section inside the contents, a half-height sheet) are gone.</p>
<p class="lede">The book is the seeded “Ideas inbox” (collects #idea; new matches wait at Arrivals). The seed has three notes waiting; two more are drawn so the frames can show a proposal with its reason and an archived note —
five in all. Words are the Mac’s own (<code>ArrivalsCopy</code>, <code>ArrivalsReviewCopy</code>), in sentence case; the drafts are in <code>design/wording-list-1.md</code>.</p>
"""
sections = [
    ("1 · Where the waiting notes show", '<p class="lede">A count in two places and nowhere else: the book’s row on the Bookcase, and the door in the book’s top bar.</p>', s1),
    ("2 · The review", '<p class="lede">The flow in order: open, add or dismiss one, open a note to read it, select several, the bulk doors, the row that needs a choice, the end.</p>', s2),
]
NOTES = """
<div class="pick" style="max-width:1500px"><h2>Still open here</h2>
<p><b>Undo after a dismissal.</b> Her rule is a short line with Undo when something leaves the page. A dismissed arrival leaves the page, but the Mac has no Undo for a dismissal: the note is simply added by hand later.
Drawn: the Mac’s line, without Undo. An Undo here would be new behaviour on both platforms, so it is hers to ask for.</p>
<p><b>Adding says nothing.</b> The Mac shows a line after Add (“… added at the end of the book.”). On the phone it is an ordinary act, so no line is drawn. Say if Add should keep its line.</p></div>

<h2>Build notes</h2>
<table class="bn">
<tr><th>Screen</th><th>Work-list rows it delivers</th><th>Shared brain it stands on</th><th>What is new</th><th>Must not get wrong</th><th>Size</th></tr>
<tr><td>The count (Bookcase row, the book’s top bar)</td><td>W-101 (the door and count), part of W-067</td>
<td>Core <code>ShelfBook.arrivalCount</code> (already delivered by <code>Queries.bookshelf</code>, never read on the phone); Mac-local <code>ArrivalsCopy.doorCount</code> / <code>doorHelp</code> — hoist owed.</td>
<td>The filled door with a number; the calm door.</td>
<td>The count is arrivals only — never added to “N notes”. The door draws on a book, never on a gathering. Cost stays with the rows drawn.</td><td>S</td></tr>
<tr><td>The review (rows, why, since, open)</td><td>W-101, W-104 (the archived mark and line)</td>
<td>Core <code>Queries.BookArrival</code>, <code>ArrivalProvenance</code>, <code>seatArrival</code>, <code>dismissArrival</code>, <code>TimeStampFace.relative</code>. Hoists owed: <code>BookArrivalsModel</code>, <code>ArrivalsCopy</code>, <code>ArrivalsReviewCopy</code> (<code>why</code>, <code>reason</code>, <code>since</code>, <code>nothingWaiting</code>), <code>ArchivedLineCopy</code>.</td>
<td>The pushed screen with the bottom bar (W-007: a list); the row; swipe panels; the “still waiting” strip on an opened note.</td>
<td>Rows oldest first. Opening a row never seats it. The review’s own acts never close it. Add says nothing; Dismiss shows the Mac’s line, with no Undo (the Mac has none). The proposal’s reason is the client’s prose, shown as written and never as the app’s voice. An arrival with no recorded reason shows since-when only. The list is windowed.</td><td>L</td></tr>
<tr><td>Copy in / Move in on a row</td><td>W-102, W-108</td>
<td>Core <code>OwnershipDecision</code>, <code>copyPostIntoReading(answering:)</code>, <code>movePostIntoReading(answering:)</code>. Hoist owed: <code>MembershipChoiceCopy</code>, the arms’ “owned by” / “also in” lines.</td>
<td>The arms on the row; the choice sheet opened from the review.</td>
<td>Which arms draw is the ownership decision’s, never a guess from the row. A move that would leave a finished or sealed book is dimmed with its sentence.</td><td>M</td></tr>
<tr><td>Select, Add N / Dismiss N, Add all / Dismiss all</td><td>W-103</td>
<td>Mac-local pure <code>ArrivalsBulk</code> (<code>ArrivalsReviewRules.swift</code>) and the bulk words in <code>ArrivalsReviewCopy</code> — hoist owed.</td>
<td>The select mode (the phone’s multi-select grammar, shared with the Library’s — VM-31); the foot bar that changes with the selection.</td>
<td>Per-row acts in listing order; no line when every row was added; rows that need a choice are named in one line, kept waiting and kept selected; a book-level refusal ends the run and counts the rest as waiting. Only Dismiss all confirms, and its count is the header’s, read at the press.</td><td>M</td></tr>
<tr><td>Empty, the dismissal line, refusals</td><td>W-101, W-012 (the one message line), W-013, W-099 (the full-book refusal’s door)</td>
<td>The same hoisted copy; Shared <code>OpsRefusalTable</code>.</td>
<td>—</td>
<td>Lines show only for a dismissal and for refusals; refusals always show. The full-book refusal carries a door to Book settings, where the note limit is shown and editable (ruled, BK-8).</td><td>S</td></tr>
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
104 pt swipe panels (Add in the accent, Dismiss in the meta ink); a 26 pt selection tick in a 44 pt target; a two-button foot bar (48 pt) above the bottom bar; the filled count door (44 pt).
Everything else — the confirm sheet, the choice sheet, the message line — is shared with <code>a-book.html</code>.</p>
"""
write('arrivals.html', 'VM-44 mockups — Arrivals', INTRO, sections, NOTES, check_dir=os.environ.get('BK_CHECK'))
