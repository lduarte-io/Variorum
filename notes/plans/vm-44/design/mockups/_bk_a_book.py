# VM-44 books designer — a-book.html (throwaway generator; static HTML out).
import sys, os
sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
from _bk_base import *

Q = lambda s: '“%s”' % s
HOME_CHIPS = ["★ Starred", "Unshelved", "✎ Writing", "Reading &amp; reference", "☼ Life", "Welcome", "All"]
WRITING = [brow("Essays", "8 notes · #essay #goals", STAR), brow("Blog drafts", "7 notes · #blog #draft"),
           brow("Letters", "3 notes · finished", FIN), brow("Ideas inbox", "3 notes · 5 waiting", badge(5))]
NEWBOOK = '<div class="addrow">+ New book on Writing</div>'
def bookcase(*over):
    return P(mast("Home"), dots(0), chips(HOME_CHIPS, 2), lst(*WRITING, NEWBOOK), qe_rest(), tabs_words(1), hi(), *over)

ESSAYS = [
    ("Against the tidy desk", "Oct 9", "A clean desk is a desk that has given up on surprising you.", dict(pin=True)),
    ("On keeping a commonplace book", "1:02 pm", "I started copying sentences into a notebook the winter I stopped trusting my memory for them.", dict(star=True)),
    ("The case for slow mornings", "Yesterday", "Nothing good I have written began after nine o’clock, and I have stopped pretending otherwise.", {}),
    ("Why I write in pencil first", "Oct 21", "Pencil forgives. Ink argues back. A keyboard has opinions about everything, mostly wrong.", {}),
    ("What the river taught me about revision", "Sep 27", "Every spring the river moves its bank a little and nobody calls it a mistake.", {}),
    ("Letters I never sent", "Sep 15", "There is a drawer of them, and the drawer is the point.", {}),
    ("Walking as a writing tool", "Sep 3", "The paragraph I could not finish at the desk finished itself somewhere past the bakery.", dict(shared=True)),
    ("Notes on attention", "Aug 22", "Attention is the only thing I own that grows when I spend it.", {}),
]
def essays_list(): return [nrow(t, s, p, **k) for t, s, p, k in ESSAYS]
ESSAYS_HEAD = lambda right=TRAY0 + READ + MORE: bookhead("Essays", "8 notes · #essay #goals", right, star=True)
def essays(*over, cls=''):
    return P(ESSAYS_HEAD(), lst(*essays_list()), foot("New note in this book…"), hi(), *over, cls=cls)

BLOG = {
    "Published": [("Five apps I deleted this year", "Aug 9", "None of them were bad. All of them wanted me back.", {}),
                  ("A year of daily notes", "Aug 18", "Three hundred and forty entries, eleven of them worth rereading.", {})],
    "In progress": [("Draft: on phones and attention", "Tue", "I want a phone that is boring in the best way.", dict(pin=True)),
                    ("How I organise research", "Aug 27", "Folders failed me, tags failed me, and then I stopped organising and started writing.", {}),
                    ("The tyranny of the blank page", "Sep 5", "The blank page is not empty. It is full of everything you have not decided yet.", {})],
    "Someday": [("Ideas for a newsletter", "Sep 23", "Monthly, short, one good link and one honest paragraph.", {}),
                ("Why I still print things", "Oct 2", "Paper shows me the shape of a piece before I have read a word of it.", {})],
}
UNFILED = ("what if the essay is actually a letter?", "9:12 am", "Or a letter that keeps forgetting who it is to.", {})
def blog_rows(chapters=("Published", "In progress", "Someday"), unfiled=False, cur=None):
    out = []
    for c in chapters:
        out.append(sec(c, str(len(BLOG[c]))))
        out += [nrow(t, s, p, cur=(t == cur), **k) for t, s, p, k in BLOG[c]]
    if unfiled:
        out.append(sec("unfiled", "1"))
        out.append(nrow(*UNFILED[:3]))
    return out
BLOG_HEAD = bookhead("Blog drafts", "7 notes · 3 chapters · #blog", TRAY0 + READ + MORE)
BLOG_HEAD8 = bookhead("Blog drafts", "8 notes · 3 chapters · #blog", TRAY0 + READ + MORE)

J = [("Thursday 12 November", "9:15 pm", "Second entry. The ferry timetable changes in December; wrote it down twice."),
     ("Thursday 12 November", "8:40 am", "Slept badly. The heron was back on the jetty before seven, standing like a question mark."),
     ("Wednesday 11 November", "7:55 am", "Rain on the skylight. Finished the Montaigne chapter and understood half."),
     ("Tuesday 10 November", "6:30 pm", "10 km along the river path. Left knee fine until the bridge, then not."),
     ("Sunday 8 November", "10:02 am", "M. called about the move. Said yes before I had thought about it."),
     ("Friday 6 November", "8:11 am", "No coffee in the house. A short entry, and a resentful one."),
     ("Wednesday 4 November", "9:47 pm", "Physio says rest. I say eight easy kilometres is rest."),
     ("Monday 2 November", "7:20 am", "First frost. The jetty boards rang like a xylophone.")]
JHEAD = bookhead("Journal", "14 entries · daily journal · #health", TRAY0 + READ + MORE, star=True)

def notepage(title, chip, paras, top='', bottom='', right=MORE, cls='', over=()):
    return P(nav(cb(I_SEARCH) + right), top,
             '<div class="page"><div class="ntitle">%s</div><div class="nchip">%s</div>%s</div>' % (title, chip, ''.join('<p>%s</p>' % p for p in paras)),
             bottom, hi(), *over, cls=cls)
def strip(text, sub, top=False, prev=True, nxt=True):
    return ('<div class="strip%s"><span class="sbtn%s">%s</span><span class="smid">%s%s<span>&nbsp;· %s</span></span><span class="sbtn%s">%s</span></div>'
            % (' top' if top else '', '' if prev else ' off', I_BACK2, I_LIST, text, sub, '' if nxt else ' off', I_FWD))
BLANK = ["The blank page is not empty. It is full of everything you have not decided yet.",
         "That is why it is heavy. A page with one bad sentence on it weighs almost nothing: the sentence can be fixed, or crossed out, or kept as a warning. A page with no sentence on it is still carrying every sentence it might have had.",
         "So I have stopped starting with the page. I start with a list of what the piece will not be about, and the page gets lighter with each line.",
         "The trick, if it is one, is to decide something small and wrong on purpose. The second decision is always easier than the first."]
CHIP_BLOG = 'in <b>Blog drafts</b> · #blog #draft'

# ---------------------------------------------------------------- section 1: the contents list
s1 = [
    opt(bookcase(), "BK-1 (a)", "The way in.",
        "The Bookcase exactly as sketched in <code>BK-1-bookcase.html</code> (a) — not redrawn. Tap a row to open the book. Press and hold a row for the book’s menu (section 4). "
        "The trailing mark is the star, the finished ✓ or the count waiting at Arrivals."),
    opt(essays(), "contents", "A plain book.",
        "She tapped “Essays”. Rows are LS-1 (b): the name, then the stamp and one line of the note’s own words. The pinned note floats first and wears the muted pin (BK-4 (a)); "
        "a note that also lives in another book wears the shared mark; the starred note keeps its star. The bar: back, Arrivals (calm, nothing waiting), Read, and ⋯ for the book’s menu. "
        "The foot is the book’s own capture box, so “new note” is never the last row of a long list.", mine=True),
    opt(P(BLOG_HEAD, lst(*blog_rows()), foot("New note in this book…"), hi()), "contents", "A book with chapters.",
        "“Blog drafts”. Chapters are section labels with their counts; a pinned note floats to the top of its own chapter, not of the book. "
        "Press and hold a chapter label to rename, move or delete it; “New chapter…” is in the ⋯ menu."),
    opt(P(JHEAD, lst(sec("November 2026"), *[nrow(d, t, p) for d, t, p in J]), foot("+ New entry"), hi()), "BK-9 (a)", "The daily Journal.",
        "The day leads each entry and the second line carries the time and the first words, so two entries on one day are told apart. "
        "“+ New entry” at the foot mints a fresh entry dated today, even when today already has one; the ✎ Today door on the home screen still opens the day’s first. "
        "No chapters are offered on a journal.", mine=True),
    opt(P(JHEAD.replace("14 entries", "412 entries"),
          lst(sec("February 2025"), nrow("Monday 3 February", "7:02 am", "Ice on the inside of the window. Wrote in gloves."),
              nrow("Sunday 2 February", "9:40 pm", "The first page of the new notebook is always the worst one."),
              sec("January 2025"), nrow("Friday 31 January", "6:55 am", "Ran before light. Counted four foxes and one other runner."),
              nrow("Wednesday 29 January", "8:30 pm", "Nothing to report, which I report."),
              nrow("Tuesday 28 January", "7:15 am", "The kettle has started to sing a different note."),
              '<div class="winline">showing the first 300 notes — <b>show 112 more ›</b></div>'),
          foot("+ New entry"), hi()), "long content", "A long book, scrolled to the end of its window.",
        "A real journal runs to hundreds of entries. The list reads a bounded window (300 rows) and says so in the Mac’s words; “show 112 more” reads the next window. "
        "Nothing here waits on the size of the book, so there is no loading state to draw."),
]

# ---------------------------------------------------------------- section 2: states
LETTERS = [("To the editor, unsent", "Oct 30", "Sir — your correspondent is wrong about herons, and I can prove it from my kitchen window."),
           ("Dear M.", "Oct 12", "I have started this four times, which tells you most of what it says."),
           ("To the landlord, about the skylight", "Sep 29", "It does not leak, exactly. It reconsiders.")]
LISBON = [("Arrival", "Jun 2", "The light here is yellow in the afternoon, like an old photograph of itself."),
          ("Alfama, getting lost on purpose", "Jun 3", "Every staircase is a decision someone made four hundred years ago."),
          ("The bakery on Rua da Rosa", "Jun 4", "Closes at two. We learned this at ten past."),
          ("Last morning", "Jun 6", "Packed badly so there would be something to fix on the train.")]
OLD = [("The podcast, first attempt", "Mar 2024", "Twenty minutes of me clearing my throat, and one good sentence at the end."),
       ("Zine layout notes", "Jan 2024", "Eight pages, one staple, no table of contents."),
       ("Garden plan", "Nov 2023", "Beans along the fence. Nothing ambitious near the door.")]
QUOTES = [("Annie Dillard", "Oct 3", "How we spend our days is, of course, how we spend our lives.", "No book"),
          ("Montaigne", "Oct 10", "I quote others only in order the better to express myself.", "Reading notes"),
          ("Mary Oliver", "Oct 17", "Attention is the beginning of devotion.", "No book"),
          ("Anne Lamott", "Oct 24", "Almost all good writing begins with terrible first efforts.", "Essays"),
          ("Eliot", "Oct 31", "It is never too late to be what you might have been.", "No book"),
          ("Sebald", "Nov 7", "Men and animals regard each other across a gulf of mutual incomprehension.",
           I_BOOK + "owned by “Reading notes”")]
s2 = [
    opt(P(bookhead("Letters", "3 notes" + ' ' + stc("✓ finished"), TRAY0 + READ + MORE),
          lst(*[nrow(*x) for x in LETTERS]),
          band("Finished — its table of contents is done; the writing inside can still change.", "Reopen"), hi()),
        "state", "Finished.",
        "The state is a chip beside the count, in the Mac’s word. The capture box gives way to one line that says what finished means and carries the Reopen door; "
        "the notes still open and edit. Pin, reorder and add refuse here with ““Letters” is finished — reopen it first.”"),
    opt(P(bookhead("Lisbon trip", "4 entries" + ' ' + stc("✓ sealed", '') + stc("owns its notes"), TRAY0 + READ + MORE),
          lst(sec("June 2026"), *[nrow(*x) for x in LISBON]),
          band("Sealed — the book is done; no note in it can change.", "Unseal…"), hi()),
        "state", "Sealed, and owning its notes.",
        "Sealed reads “✓ sealed”, never the finished ✓ alone. “Owns its notes” is its own chip: each note here lives only here, so no row wears the shared mark. "
        "Notes open read-only. Unseal… asks first (it reopens the book too)."),
    opt(P(bookhead("Old projects", "3 notes" + ' ' + stc("archived"), TRAY0 + READ + MORE),
          band("Archived — kept under Archived, off the Bookcase.", "Unarchive"),
          lst(*[nrow(*x) for x in OLD]), foot("New note in this book…"), hi()),
        "state", "Archived.",
        "Opened from the Archived room’s Books group. The line at the top says where it is kept and carries Unarchive. Collecting is paused, "
        "but a note she adds by hand still lands, so the capture box stays."),
    opt(P(bookhead("Quotes", "gathering · 6 notes · gathers #quote", READ + MORE),
          lst(*[nrow(t, s, p, where=w) for t, s, p, w in QUOTES]), foot("New note in this gathering…"), hi()),
        "kind", "A gathering.",
        "It says “gathering”, never “smart”. A gathering holds nothing, so each row’s third line says where the note lives — a book, “No book”, or “owned by …” "
        "when a book owns it. No Arrivals door, no chapters, no pins. A note written here is born wearing #quote so it matches."),
    opt(P(bookhead("Receipts", "no notes yet", TRAY0 + READ + MORE),
          lst('<div class="empty">This book has no notes yet.</div>'), foot("New note in this book…"), hi()),
        "empty", "An empty book.",
        "The Mac’s sentence, with the capture box under it. A gathering that matches nothing says “This gathering shows no notes yet.”; an archived gathering says "
        "“This gathering is archived, so it shows nothing until you unarchive it.”"),
    opt(essays(cls='dk'), "dark", "The contents list in dark.",
        "The room is black and the paper carries the hue, as on the Mac. Marks keep their own inks: the star blue, the pin and shared mark muted."),
    opt(P(bookhead("Blog drafts", "7 notes · 3 chapters · #blog", TRAY0 + READ + MORE),
          lst(*blog_rows(("In progress", "Someday"))), foot("New note in this book…"), hi(), cls='xl'),
        "largest text", "The densest screen at the largest standard text size.",
        "Names and previews take two lines each instead of truncating; chapter labels, counts and the capture box grow with them. "
        "The bar’s round buttons keep their 44 pt. About four notes show per screen; nothing overlaps."),
]

# ---------------------------------------------------------------- section 3: a note opened from a book (BK-5)
TOC = (shead("Blog drafts", "Done") + '<div class="ssub">7 notes · 3 chapters</div>' + seg(["Blog drafts", "Essays"], 0)
       + '<div class="grp">' + ''.join(
           [glab("Published"), trow("Five apps I deleted this year"), trow("A year of daily notes"),
            glab("In progress"), trow("Draft: on phones and attention", pin=True), trow("How I organise research"),
            trow("The tyranny of the blank page", cur=True, meta="reading"),
            glab("Someday"), trow("Ideas for a newsletter"), trow("Why I still print things")]) + '</div>')
BOOKS_SHEET = (shead("Books", "Done") + seg(["Blog drafts", "Essays"], 0)
               + grp(trow("Draft: on phones and attention", pin=True), trow("How I organise research"),
                     trow("The tyranny of the blank page", cur=True, meta="note 5 of 7"), trow("Ideas for a newsletter"))
               + grp(mrow("Pin to top", PINM), mrow("Move to chapter", I_LIST, v="In progress " + CHEV), mrow("Remove from this book", I_X))
               + glab("Appears in 1 gathering") + grp(mrow("In flight", I_TAG, v="remove #draft"))
               + grp(mrow("Add to book…", I_PLUS, cls='acc')))
s3 = [
    opt(notepage("The tyranny of the blank page", CHIP_BLOG, BLANK, top=strip("note 5 of 7", "In progress", top=True)), "BK-5 (b) · top",
        "A thin strip under the bar.",
        "She tapped the note in “Blog drafts”. The strip says where she is in the Mac’s words (“note N of M · chapter”); ‹ and › step in the book’s own order, pins first; "
        "the middle opens the contents. Cost: 48 pt of chrome above her title, at the far end of the screen from her thumb."),
    opt(notepage("The tyranny of the blank page", CHIP_BLOG, BLANK, bottom=strip("note 5 of 7", "In progress")), "BK-5 (b) · foot",
        "The same strip at the foot.",
        "Where the Mac puts it (the book’s bottom bar) and where the thumb is. It shows only while the note was opened from a book, and it steps aside while the keyboard is up, "
        "so it never competes with the keyboard bar. The note’s own “in Blog drafts” chip is unchanged.", mine=True),
    opt(notepage("The tyranny of the blank page", CHIP_BLOG, BLANK, bottom=strip("note 5 of 7", "In progress"), over=(sheet(196, TOC),)), "BK-5 (b) · tap",
        "Tap the strip’s middle: the contents.",
        "The book’s contents as one-line rows, the open note washed and marked, pins shown. Tap a row to go there. The two-name switch at the top draws only when the note "
        "lives in more than one book, and changes which book ‹ › step through.", mine=True),
    opt(notepage("The tyranny of the blank page", CHIP_BLOG, BLANK, over=(sheet(130, BOOKS_SHEET),)), "BK-5 (a)",
        "No strip; the Books sheet grows into the panel.",
        "She tapped “in Blog drafts” under the title. One sheet carries the contents, the switcher, this note’s pin, chapter and remove doors, the gatherings it appears in and “Add to book…”. "
        "Everything is in one place, but stepping to the next note is open, scroll, tap, every time."),
    opt(notepage("Why I still print things", CHIP_BLOG.replace(' #draft', ''),
                 ["Paper shows me the shape of a piece before I have read a word of it.",
                  "On a screen every paragraph is the same height: the height of the screen. On paper the long one looks long, and I can see from across the room that the middle is where the trouble is.",
                  "I print, I walk away, I come back and read it standing up. Standing up is the important part."],
                 bottom=msg("That’s the book’s last note.") + strip("note 7 of 7", "Someday", nxt=False)), "edge",
        "The last note.",
        "› is dimmed on the last note and ‹ on the first; pressing it says so in the Mac’s words instead of doing nothing."),
]

# ---------------------------------------------------------------- section 4: the menus (one table)
BOOKMENU = (shead("Essays", "Done") + '<div class="ssub">8 notes · on Writing, in Home</div>'
            + grp(mrow("Unstar", I_STARO), mrow("Rename…", I_PENCIL), mrow("Book settings…", I_GEAR))
            + grp(mrow("New chapter…", I_LIST), mrow("Duplicate book…", I_SHARED), mrow("Move to shelf", I_SHELF, v="Writing " + CHEV),
                  mrow("Move to wing", I_WING, v="Home " + CHEV))
            + grp(mrow("Finish", I_CHECK), mrow("Seal…", I_LOCK), mrow("Own its notes…", I_BOOK))
            + grp(mrow("Archive", I_ARCH), mrow("Delete book…", I_TRASH, cls='danger')))
NOTEMENU = (shead("The tyranny of the blank page", "Done") + '<div class="ssub">in Blog drafts · In progress</div>'
            + grp(mrow("Star", I_STARO), mrow("Rename…", I_PENCIL))
            + grp(mrow("Pin to top", PINM), mrow("Move to chapter", I_LIST, v="In progress " + CHEV), mrow("Move up", I_UP), mrow("Move down", I_DOWN))
            + grp(mrow("Move to wing", I_WING, v=CHEV), mrow("Copy to wing", I_WING, v=CHEV), mrow("Export note…", I_EXPORT))
            + grp(mrow("Archive", I_ARCH), mrow("Remove from this book", I_X), mrow("Delete note…", I_TRASH, cls='danger')))
def swiped(t, s, p):
    return ('<div class="swipe"><span class="act r2">%s Pin</span><span class="act r">%s More</span><div class="sr2" style="background:var(--surface)">%s</div></div>'
            % (PINM.replace('class="pin"', 'style="color:#fff"'), I_MORE, nrow(t, s, p)))
def end_rows(sw=True):
    third = swiped(*BLOG["In progress"][2][:3]) if sw else nrow(*BLOG["In progress"][2][:3])
    return [sec("In progress", "3"), nrow(*BLOG["In progress"][0][:3], pin=True), nrow(*BLOG["In progress"][1][:3]), third,
            sec("Someday", "2")] + [nrow(t, s, p) for t, s, p, k in BLOG["Someday"]] + [sec("unfiled", "1"), nrow(*UNFILED[:3])]
CHAPTER = (shead("Move to chapter", "Done") + '<div class="ssub">“what if the essay is actually a letter?”</div>'
           + grp(mrow("Published", v="2"), mrow("In progress", v="3"), mrow("Someday", v="2"), mrow("unfiled", cls='on', trail='<span class="ck">%s</span>' % I_CHECK))
           + grp(mrow("New chapter…", I_PLUS, cls='acc')))
WINGS = [("Work", "5 books"), ("Fiction", "4 books"), ("Research", "3 books"), ("Family", "2 books"), ("Health", "1 book"),
         ("Side project", "2 books"), ("Poetry", "2 books"), ("Taxes 2025", "1 book")]
WING = (shead("Move to wing", "Cancel", strong=False) + '<div class="ssub">In “Home”. Moving the book takes its notes with it.</div>'
        + grp(*[mrow(w, v=c + ' ' + CHEV, cls='serif') for w, c in WINGS])
        + '<div class="c13b" style="margin-top:0">A wing is a separate library. The book’s 8 notes and their tags go with it; it lands unshelved there.</div>')
CANCEL = btn("Cancel", "quiet")
s4 = [
    opt(essays(sheet(66, BOOKMENU)), "book menu", "The book’s menu: one table.",
        "⋯ on the book’s bar, or press and hold the book’s row anywhere it appears (Bookcase, Library, Starred, Archived). One list, grouped: identity, structure and place, "
        "the three state doors, then archive and delete. “Pin to shelf top” is gone — it was the star. Off the Bookcase the same table drops “Move to shelf”; "
        "on a gathering it reads Edit rule…, Bind into a book…, Make a book from this gathering… and Delete gathering…, with no state doors.", mine=True),
    opt(P(BLOG_HEAD, lst(*blog_rows()), foot("New note in this book…"), hi(), sheet(66, NOTEMENU)), "note menu", "A note’s menu inside a book.",
        "Press and hold a note row (a tap still opens it). The note’s own doors first, then its place in this book — Pin to top (Unpin once pinned), Move to chapter (BK-10 (a)), Move up and Move down — "
        "then wings and export, then archive, Remove from this book (Release on a book that owns its notes) and delete. A gathering’s rows show the note’s own doors only."),
    opt(P(BLOG_HEAD8, lst(*end_rows()), foot("New note in this book…"), hi()), "swipe", "The two commonest acts on a swipe.",
        "Swipe a row left for Pin and More; More opens the same menu, so nothing is reachable only by a long press. The list is scrolled to its end: "
        "a note added from the phone sits under “unfiled” until it is given a chapter."),
    opt(P(BLOG_HEAD8, lst(*end_rows(False)), foot("New note in this book…"), hi(), sheet(None, CHAPTER)), "BK-10 (a)", "Move to chapter.",
        "From the unfiled note’s menu. The book’s chapters in order with their counts, the current place ticked, and “New chapter…” so a chapter can be made on the way. "
        "Tapping one moves the note and closes the sheet; the row reappears under its new label."),
    opt(essays(sheet(None, WING)), "nine wings", "Move to wing, with eight to choose from.",
        "The other eight wings as 52 pt rows; the sentence is the Mac’s. Picking one asks once — “Move “Essays” to “Work”?” — naming any books its notes leave behind, "
        "then says “Moved “Essays” to “Work”.” The row is not drawn when there is no other wing."),
    opt(essays(confirm(None, "Delete “Essays”?",
                       ["Deleting a plain book never touches a note — the 8 notes in it stay in the Library, and in any other books that hold them.",
                        "It goes to the Trash — Put back returns it for 30 days."],
                       [btn("Delete book", "alarm"), CANCEL])), "delete", "Deleting a plain book.",
        "Every delete asks. The two sentences are the Mac’s. The daily Journal gets this same confirm now, beside Archive, as on the Mac."),
    opt(P(bookhead("Recipes", "5 notes" + ' ' + stc("owns its notes"), TRAY0 + READ + MORE),
          lst(nrow("Lentil soup, the Tuesday one", "Nov 1", "Onion, carrot, cumin, and more lemon than seems right."),
              nrow("Bread, no-knead", "Oct 19", "Flour, water, salt, patience. Start it the night before.")),
          foot("New note in this book…"), hi(),
          confirm(None, "Delete “Recipes”?",
                  ["“Recipes” owns its notes. Delete the book only, and 4 of its notes go back to the Pool, and 1 stays archived — or delete the book and its 5 notes together.",
                   "Either way the book goes to the Trash for 30 days, and Put back returns whatever went in together, together."],
                  [btn("Delete book only", "alarm"), btn("Delete book and its 5 notes", "alarm"), CANCEL])), "delete · owned",
        "A book that owns its notes: two choices.",
        "Book only, or the book and its notes together; the first choice says honestly where the notes go, the archived one included. "
        "Archive on an owned book asks with the twin of this sheet (“Archive book only” / “Archive book and its 5 notes”)."),
    opt(essays(sheet(None, shead("Duplicate “Essays”", "Duplicate", left="Cancel"), field("Essays copy", label="Name"),
                     grp(mrow("With copies of its notes", trail=toggle(False))),
                     '<div class="c13b" style="margin-top:0">The duplicate holds the same notes — editing a note in either book edits it in both. Turn the switch on for copies that can go their own way.</div>'
                     '<div class="c13b">It’s a new book with this one’s settings and chapters — not owned, not finished, unshelved.</div>')), "duplicate",
        "Duplicate book.",
        "A name, one switch and the Mac’s two sentences. On a book that owns its notes the switch is on and fixed (“its duplicate carries copies of them”). Not offered on a gathering."),
]

# ---------------------------------------------------------------- section 5: book settings
INBOX = [nrow("Faster cold start", "Mon", "Measure first. The store opens off the main thread already."),
         nrow("Undo history panel", "Nov 3", "A list of what ⌥⌘Z would undo, newest first."),
         nrow("Keyboard shortcuts on iPad", "Oct 29", "Not planned. Written down so I stop thinking about it.")]
def inbox(*over, cls=''):
    return P(bookhead("Ideas inbox", "3 notes · collects #idea", arr(5) + READ + MORE), lst(*INBOX), foot("New note in this book…"), hi(), *over, cls=cls)
SET_TOP = (shead("Book settings", "Done") + field("Ideas inbox", label="Name")
           + glab("Collecting")
           + grp('<div class="sent"><i>Gathers from:</i><b>#idea</b></div>', '<div class="sent"><i>New matches:</i><b>wait at Arrivals</b></div>',
                 '<div class="sent"><i>Notes written here are tagged:</i><b>#idea</b></div>', mrow("Edit…", cls='acc', v=CHEV))
           + glab("State")
           + grp(mrow("Finished", cap="Finished means the table of contents is done — the writing inside can still change. A finished book opens as pure text.", trail=toggle(False)),
                 mrow("Seal…", cap="Sealed means the book is done.", v=CHEV),
                 mrow("Own its notes…", cap="An owned book is the only place its notes live.", v=CHEV)))
SET_BOTTOM = (shead("Book settings", "Done") + glab("State")
              + grp(mrow("Finished", cap="Finished means the table of contents is done — the writing inside can still change. A finished book opens as pure text.", trail=toggle(False)),
                    mrow("Seal…", cap="Sealed means the book is done.", v=CHEV),
                    mrow("Own its notes…", cap="An owned book is the only place its notes live.", v=CHEV))
              + grp(mrow("Date-stamped entries", cap="Notes written here get the day’s date, are named by it until you title them, and the book sorts by date.", trail=toggle(False)),
                    mrow("Use as daily journal"))
              + grp(mrow("Move to wing", cap="In “Home”. Moving the book takes its notes with it.", v="Home " + CHEV))
              + grp(mrow("Archive", cap="Archiving keeps it forever — off the Bookcase, under Archived, with no countdown."),
                    mrow("Delete book…", cls='danger')))
RULE = (shead("Rule — “Ideas inbox”", "Save", left="Cancel")
        + glab("Collects every note that matches:") + seg(["any of these", "all of these"], 0)
        + grp(term("#idea"), term("★ starred"), term("#draft", neg=True))
        + '<div class="tchips">%s%s</div>' % (tchip("+ tag", x=False, cls='add'), tchip("+ starred", x=False, cls='add'))
        + glab("New matches:") + seg(["join quietly at the end", "wait at Arrivals"], 1)
        + glab("Notes written here are tagged:")
        + '<div class="tchips">%s%s</div>' % (tchip("#idea"), tchip("+ tag", x=False, cls='add'))
        + '<div class="c13b">blank = none</div>')
TAGS_HOME = ["blog", "draft", "essay", "goals", "idea", "quote", "reading", "recipe", "travel"]
def tagpicker(on=("idea",), title="Tags in Home"):
    return (shead(title, "Done") + field("Find or make a tag", ph=True)
            + grp(*[mrow("#" + t, cls='on' if t in on else '', trail='<span class="ck">%s</span>' % I_CHECK if t in on else '') for t in TAGS_HOME])
            + '<div class="c13b" style="margin-top:0">These are Home’s tags. Each wing keeps its own, and this book lives in Home.</div>')
SEALED_SET = (shead("Book settings", "Done") + field("Lisbon trip", label="Name")
              + glab("State")
              + grp(mrow("Finished", cap="A sealed book stays finished — Unseal reopens it.", trail=toggle(True), cls='off'),
                    mrow("Unseal", cap="Sealed — the book is done; no note in it can change.", v=CHEV),
                    mrow("Stop owning", cap="This book owns its notes — each one lives only here.", v=CHEV))
              + grp(mrow("Move to wing", cap="In “Home”. Moving the book takes its notes with it.", v="Home " + CHEV))
              + grp(mrow("Archive…", cap="Archiving keeps it forever — off the Bookcase, under Archived, with no countdown."),
                    mrow("Delete book…", cls='danger')))
GATH_SET = (shead("Gathering settings", "Done") + field("Quotes", label="Name")
            + glab("Collecting")
            + grp('<div class="sent"><i>Gathers from:</i><b>#quote</b></div>', mrow("Edit…", cls='acc', v=CHEV))
            + grp(mrow("Notes an owned book holds", v="as the app does (shown) " + CHEV))
            + grp(mrow("Bind into a book…"), mrow("Make a book from this gathering…"))
            + grp(mrow("Move to wing", cap="In “Home”. A gathering shows the notes of the wing it’s in.", v="Home " + CHEV))
            + grp(mrow("Archive", cap="Archiving keeps it forever — off the Bookcase, under Archived, with no countdown."),
                  mrow("Delete gathering…", cls='danger')))
FORKS = ["Walking as a writing tool<span>also in “Blog drafts”</span>", "On keeping a commonplace book<span>also in “Reading notes”</span>"]
SEAL_LINES = ["Sealed means the book is done: no note in it can change until you unseal it.", "Sealing finishes the book too.",
              "These notes also live in other books, so each gets its own copy here, sealed with the book — the originals stay where they are, still editable:"]
s5 = [
    opt(inbox(sheet(70, SET_TOP)), "settings", "Book settings, as a sheet.",
        "⋯ ▸ Book settings… on “Ideas inbox”. The name is a visible field. Collecting is the Mac’s three sentences with one Edit… door. "
        "State carries the three doors, each with the Mac’s one-line meaning — replacing today’s “freezes its notes”, which was wrong.", mine=True),
    opt(inbox(sheet(118, SET_BOTTOM)), "settings · scrolled", "The rest of the sheet.",
        "The journal switch and “Use as daily journal”, the wing row with its sentence, then Archive and Delete. Every row is 52 pt or taller. "
        "A book’s word target and note limit stay out for now (BK-8 (a))."),
    opt(inbox(sheet(70, RULE)), "collecting", "Edit…: the rule, the join dial, the outflow tags.",
        "One screen for the three Collecting sentences. The rule is the simple face (BK-6 (b)): any or all of a flat list of terms, each a tag or ★ starred, each with a “not” switch. "
        "The join dial is two words. The outflow is a set of tag chips — several, one or none. Save says “Saved the rule for “Ideas inbox”.” and, if the outflow changed, offers "
        "“Also tag the 3 current members with #idea now?”", mine=True),
    opt(inbox(sheet(70, tagpicker())), "wing-correct", "“+ tag”: only this wing’s tags.",
        "The picker lists the tags of the wing the book lives in and nothing else, so a rule can never name a tag from another wing (today it can, and the term is dead). "
        "Typing a new path makes the tag in this wing (“Made the tag #…”)."),
    opt(inbox(confirm(None, "Finish “Ideas inbox”?", [], [btn("Finish"), btn("Open Arrivals first", "plain"), CANCEL],
                      after=["5 waiting at Arrivals will be dismissed."])), "finish",
        "Finish says what it will dismiss.",
        "Turning Finished on while notes wait asks first, in the Mac’s line; with nothing waiting it simply acts, as on the Mac. "
        "“Open Arrivals first” is my addition, not ruled: a way out for someone who has not looked at what is waiting. Today the phone dismisses them silently.", mine=True),
    opt(essays(confirm(None, "Seal “Essays”?", SEAL_LINES, [btn("Seal"), CANCEL], items=FORKS)), "seal", "Seal… lists what will be copied.",
        "The Mac’s confirm, whole: what sealed means, that it finishes the book too, and the notes that live elsewhere and so get their own sealed copy here. "
        "With none it says “None of its notes lives in another book, so nothing needs copying.”; with arrivals waiting it adds the dismissal line."),
    opt(essays(confirm(None, "Seal “Essays”?", SEAL_LINES, [btn("Sealing…", off=True), btn("Cancel", "quiet", off=True)], items=FORKS)), "working",
        "While it works.",
        "Sealing or owning a large shared book copies notes, so it can take a moment. The sheet stays, the button says what is happening and nothing else can be pressed; "
        "it closes on the receipt “Sealed “Essays” — the book is done. 2 shared notes got their own copies here.”"),
    opt(essays(confirm(None, "Make “Essays” own its notes?",
                       ["An owned book is the only place its notes live — put one of them in another book and you’ll get a copy.",
                        "These notes also live in other books. Each gets its own copy here; the originals stay in their other books:"],
                       [btn("Own its notes"), CANCEL], items=FORKS)), "own", "Own its notes… lists the copies.",
        "The same shape as Seal. Stop owning needs no confirm: ““Essays” no longer owns its notes — they stay, and can live in other books too.”"),
    opt(P(bookhead("Lisbon trip", "4 entries" + ' ' + stc("✓ sealed") + stc("owns its notes"), TRAY0 + READ + MORE),
          lst(sec("June 2026"), *[nrow(*x) for x in LISBON]), hi(), sheet(150, SEALED_SET)), "settings · sealed",
        "The same sheet on a sealed book.",
        "Finished is on and dimmed with the Mac’s reason; the doors read Unseal and Stop owning. Nothing here can end in a raw error: "
        "the only way to reopen is the door that says so."),
    opt(P(bookhead("Quotes", "gathering · 6 notes · gathers #quote", READ + MORE),
          lst(*[nrow(t, s, p, where=w) for t, s, p, w in QUOTES]), hi(), sheet(70, GATH_SET)), "settings · gathering",
        "Gathering settings: the same pane.",
        "One sentence (“Gathers from”), the row for notes an owned book holds (as the app does · show them · hide them), the two conversions, the wing row with the gathering’s own sentence, "
        "Archive and Delete gathering…. No Finish, Seal or Own — they are not drawn rather than drawn and refused."),
]

# ---------------------------------------------------------------- section 6: the membership choice sheet
COMMON = ["I started copying sentences into a notebook the winter I stopped trusting my memory for them.",
          "The notebook is not a diary and not a quarry. It is closer to a guest book: other people sign it, and I learn who has been visiting.",
          "Montaigne kept his on the beams of his ceiling. I keep mine in a drawer, which says something about both of us."]
def common(*over): return notepage("On keeping a commonplace book", "in <b>Essays</b> · #essay #goals", COMMON, over=over)
LAW = '<div class="c13b" style="margin-top:4px">Adding a note to a book never copies it — a copy only happens because you choose one, and it always remembers where it came from.</div>'
s6 = [
    opt(common(sheet(None, shead("Add “On keeping a commonplace book” to “Reading notes”?", "Cancel", strong=False).replace('class="st"', 'class="st" style="padding:10px 0"'),
                     '<div class="c13b" style="font-size:15px;line-height:21px;color:var(--ink);margin-top:0">“Reading notes” owns its notes. This note also lives in “Essays”.</div>',
                     choice("Copy in", "A linked copy joins “Reading notes”; the original stays in “Essays”, unchanged."),
                     choice("Move in", "It leaves “Essays”, and lives only in “Reading notes”."), LAW)), "copy or move",
        "The membership choice sheet.",
        "She chose “Add to book…” on the note and picked a book that owns its notes. Instead of a refusal sentence with nowhere to go, the sheet opens: "
        "two choices in the Mac’s words, each a whole-width button, and the law of copies said once underneath. The same sheet opens from Arrivals’ Copy in and Move in.", mine=True),
    opt(common(sheet(None, shead("Add “Sebald” to “Essays”?", "Cancel", strong=False),
                     '<div class="c13b" style="font-size:15px;line-height:21px;color:var(--ink);margin-top:0">This note belongs to “Reading notes”, which owns its notes.</div>',
                     choice("Copy in", "Only a copy can come in: a linked copy joins “Essays”; the original stays in “Reading notes”, unchanged."), LAW)), "copy only",
        "When only a copy can come in.",
        "The other direction: the note is owned elsewhere, so there is one choice and the sheet says why."),
    opt(common(sheet(None, shead("Add “Dear M.” to “Reading notes”?", "Cancel", strong=False),
                     '<div class="c13b" style="font-size:15px;line-height:21px;color:var(--ink);margin-top:0">“Reading notes” owns its notes. This note also lives in “Letters”.</div>',
                     choice("Copy in", "A linked copy joins “Reading notes”; the original stays in “Letters”, unchanged."),
                     choice("Move in", "It can’t move: “Letters” is finished, so the note can’t leave it — copy it in instead, or reopen “Letters” first.", off=True), LAW)), "refusal",
        "A move that cannot happen says why.",
        "Move in is dimmed with the Mac’s sentence in its place, naming the book that holds the note and the road that would free it."),
    opt(P(nav(cb(I_SEARCH) + MORE),
          '<div class="page"><div class="ntitle">On keeping a commonplace book</div><div class="nchip">in <b>Reading notes</b> · #essay #goals</div>%s</div>' % ''.join('<p>%s</p>' % p for p in COMMON),
          msg("Moved into “Reading notes” — it left “Essays”."), hi()), "receipt", "After Move in.",
        "The sheet closes and one quiet line says what happened; the chip under the title now names the owning book. Copy in says "
        "“Copied into “Reading notes” — a linked copy; the original stays where it was.”"),
]

# ---------------------------------------------------------------- section 7: creating a book and a gathering
def newbook(kind, body, create, top=120, keyboard=True, roff=False):
    k = kb('return') if keyboard else ''
    return bookcase(sheet(top, shead("New book", create, left="Cancel", roff=roff), seg(["Book", "Journal book", "Gathering"], kind), body, cls='kbd' if keyboard else '') ,
                    '<div style="position:absolute;left:0;right:0;bottom:0;z-index:7">%s</div>' % k if keyboard else '')
GRULE = (glab("Shows every note that matches:") + seg(["any of these", "all of these"], 1)
         + grp(term("#quote"), term("★ starred"), term("#draft", neg=True))
         + '<div class="tchips">%s%s</div>' % (tchip("+ tag", x=False, cls='add'), tchip("+ starred", x=False, cls='add'))
         + '<div class="c13b">In Home. A gathering shows the notes of the wing it’s in.</div>')
NESTED = (shead("Rule — “In flight”", "Save", left="Cancel")
          + glab("Shows every note that matches:") + seg(["any of these", "all of these"], 0)
          + grp(term("#essay"), term("(#blog and not #draft)", locked=True), term("(★ starred and #goals)", locked=True))
          + '<div class="tchips">%s%s</div>' % (tchip("+ tag", x=False, cls='add'), tchip("+ starred", x=False, cls='add'))
          + '<div class="c13b">Two of these terms are groups, shown as they were written. A group keeps working exactly as it is; here it can be kept or removed, and its inside is not edited.</div>')
s7 = [
    opt(newbook(0, field("Field notes", focus=True, label="Name") + '<div class="c13b">Lands on Writing, in Home.</div>', "Create"), "new book",
        "New book: the name is ready to type.",
        "“+ New book on Writing” on the Bookcase, or New book… in the masthead’s ⋯. The Name field has the keyboard on arrival; the three kinds are one 44 pt control; "
        "the line under the field says which shelf and wing it will be born on — the shelf she was looking at, the wing she is standing in. Cancel mints nothing.", mine=True),
    opt(newbook(2, field("Keepers", label="Name") + GRULE, "Create", top=70, keyboard=False), "BK-6 (b)", "Create a gathering: the simple rule editor.",
        "Choosing Gathering grows the rule editor in place, because a gathering is made from its rule. Any or all of a flat list; each term is a tag or ★ starred; "
        "“not” is a switch on the row; ✕ removes it. This reads “all of #quote, ★ starred and not #draft”.", mine=True),
    opt(bookcase(sheet(70, tagpicker(on=("quote",)))), "wing-correct", "“+ tag” inside the editor.",
        "The same picker as in book settings: Home’s tags only, because the gathering will live in Home. In another wing it lists that wing’s tags."),
    opt(bookcase(sheet(70, shead("New book", "Create", left="Cancel", roff=True), seg(["Book", "Journal book", "Gathering"], 2), field("Keepers", label="Name"),
                       glab("Shows every note that matches:") + seg(["any of these", "all of these"], 0)
                       + '<div class="tchips">%s%s</div>' % (tchip("+ tag", x=False, cls='add'), tchip("+ starred", x=False, cls='add'))
                       + '<div class="c13b">Add a tag or ★ starred — a gathering is made from its rule, and shows every note that matches it.</div>'
                       + msg("A gathering needs a rule.", refusal=True))), "refusal", "No rule, no gathering.",
        "With no term, Create is dimmed and the hint is the Mac’s sentence; pressing it anyway says “A gathering needs a rule.” Emptying the rule of an existing gathering refuses the same way and offers “Delete this gathering…”."),
    opt(P(bookhead("In flight", "gathering · 9 notes", READ + MORE), lst(*essays_list()[:4]), hi(), sheet(70, NESTED)), "BK-6 (b) · nested",
        "A rule with groups, made on the Mac.",
        "The top level is editable as usual. A group inside it shows as one locked row, in the same words the Collecting sentence uses; it can be removed but not opened. "
        "Nothing is lost by saving from the phone: the groups are written back untouched."),
]

INTRO = """
<p class="lede"><b>VM-44 mockups — inside one book.</b> Today the phone’s book is a list of bare titles with two text links at its foot: no previews, no pin mark, no sign of
what is waiting, none of the finished / sealed / owned / archived family, one “Book Details” half-sheet with two acts, and a Finish that silently dismisses arrivals she never saw
(audit B: 118 capabilities, 62 absent, 24 stale). These frames draw the book whole, in the phone’s grammar, on the Mac’s words.</p>
<p class="q">“it just needs a lot of love and attention. yes it's missing features but also what's already there is seriously behind too.”</p>
<p class="lede">Read each row left to right; the caption under a frame says how she got there and what each control does. A green label marks my pick where a question is open
(BK-4, BK-5, BK-6, BK-9, BK-10). Words in the frames are the Mac’s own, set in sentence case. The Bookcase itself is <code>sketches/BK-1-bookcase.html</code> (a) and is not redrawn; Arrivals has its own file,
<code>mockups/arrivals.html</code>.</p>
"""
sections = [
    ("1 · The contents list", '<p class="lede">One row anatomy for every kind of book (LS-1 (b)), with the book’s doors in the bar and at the foot rather than after the last row.</p>', s1),
    ("2 · States, kinds, dark and the largest text", '<p class="lede">The state family the phone lacks today, each said in the Mac’s word; then the same list in dark and at the largest standard text size.</p>', s2),
    ("3 · A note opened from a book — question BK-5", '<p class="lede">Today a note opened from a book forgets the book. The alternatives for what the Mac calls the Book Panel, side by side.</p>', s3),
    ("4 · The menus: one table of acts", '<p class="lede">A book’s acts are split today between a long press and a half-sheet, with two doors (“Pin to shelf top”, “Star”) writing one truth. One table, shown wherever a book or a note in a book appears.</p>', s4),
    ("5 · Book settings and the state doors", '<p class="lede">The Mac’s settings pane as a phone sheet: the Collecting sentences, the join dial, the outflow tags, and Finish · Seal · Own with their confirms.</p>', s5),
    ("6 · The membership choice sheet", '<p class="lede">Every refusal that says “it can come in as a copy, or move in” opens this sheet instead of ending there.</p>', s6),
    ("7 · Creating a book and a gathering — question BK-6", '<p class="lede">The New book sheet with the keyboard up, and the simple rule editor.</p>', s7),
]
NOTES = """
<div class="pick" style="max-width:1500px"><h2>My picks on the open questions drawn here</h2>
<p><b>BK-4 (a)</b> a muted pin on the row — the contents list is the phone’s table of contents, and a floating row needs its reason.
<b>BK-5 (b), at the foot</b> — the strip is the Mac’s bottom bar in the thumb’s reach, it hides with the keyboard, and its middle opens a light contents sheet; the heavy Books sheet of (a) can follow.
<b>BK-6 (b)</b> — a flat any / all list with a “not” switch per term; groups made on the Mac show as locked rows that survive a save.
<b>BK-9 (a)</b> “+ New entry” at the Journal’s foot. <b>BK-10 (a)</b> “Move to chapter” in the note’s menu inside a book, with “New chapter…” on the way.</p>
<p>What would change my mind on BK-5: if the note’s own foot is needed for the keyboard bar at rest (the note designer’s call), the strip moves under the top bar (frame “BK-5 (b) · top”) with no other change.</p></div>

<h2>Build notes</h2>
<table class="bn">
<tr><th>Screen</th><th>Work-list rows it delivers</th><th>Shared brain it stands on</th><th>What is new</th><th>Must not get wrong</th><th>Size</th></tr>
<tr><td>Contents list (book, chapters, journal, gathering, empty, long)</td>
<td>W-079, W-080, W-083, W-084, W-085, W-086, W-087, W-091 (the mark), W-073</td>
<td>Core <code>Queries.assembleReading</code> (pins float by construction; <code>ReadingEntry.pinned</code> is already delivered), Core <code>DisplayTitle</code> / <code>NoteCardFace</code> for names and previews, Core <code>newJournalEntry</code> and <code>newPostInReading(entryDate:)</code>. Hoists owed: <code>BookEmptyStateCopy</code>, <code>GatheringNoteDoor</code>, <code>BookWindowLine</code> words.</td>
<td>The row with a preview; the bar (Arrivals · Read · ⋯); the foot capture box; “unfiled” header; month headers in a journal.</td>
<td>A journal’s new note is a dated entry (today the phone mints undated notes). The foot door refuses before minting on a finished, sealed or full book. Rows read a bounded window — never the whole book. Never the raw day key; never “smart”.</td><td>M</td></tr>
<tr><td>States and badges</td><td>W-114, W-106, W-116 / W-117 (the archived band), W-120</td>
<td>Core <code>ownershipFacts</code>. Hoists owed: <code>OwnershipBadgeCopy</code>, <code>BookStateCopy</code> (the “✓ sealed” / “✓ finished” / “archived” mark), <code>BookSettings</code> captions.</td>
<td>State chips beside the count; the state band in place of the capture box; the shared mark and “owned by” line on rows.</td>
<td>Sealed is never drawn as the finished ✓ alone. A finished book’s text stays editable — only the foot door and the order freeze. The badge family follows the synced <code>ownership_badges</code> switch.</td><td>M</td></tr>
<tr><td>The book strip on a note (BK-5)</td><td>W-088, W-089 (its light form)</td>
<td>Hoists owed: <code>BookNoteStep</code> (the stepper and its first / last words) and the bottom bar’s position wording; Core <code>assembleReading</code> for the order.</td>
<td>The <code>.note</code> route must carry which book the note was opened from (it carries none today); the strip; the contents sheet with the switcher for shared notes.</td>
<td>‹ › follow the order the book renders, pins included, and flush pending typing before stepping. The strip draws only for a note opened from a book and hides with the keyboard. One live editor: stepping replaces the note, it does not stack screens.</td><td>M</td></tr>
<tr><td>The book’s menu and a note’s menu in a book</td>
<td>W-070, W-071, W-078, W-077 (Move up / down), W-081, W-082, W-091, W-100, W-109, W-115, W-116, W-118, W-119, W-010</td>
<td>Hoists owed: <code>BookRowMenu</code>’s table with <code>BookStateDoorSet</code> and <code>BookArchiveDoorSet</code>, <code>BookNoteTitleMenu</code>, <code>PinNote</code> and <code>RemoveFromBook</code> words, <code>DuplicateBookCopy</code>, the wing move confirm (W-016), <code>postDropPlan</code> for the pinned-group edge. Core ops for every act.</td>
<td>The menu as a sheet of 52 pt rows; row swipes; the chapter picker; the wing picker.</td>
<td>One table with derived faces — never a second hand-kept list. Pin and Star are different things: the book’s star is the union star; a note’s pin is per book and refuses on a finished book. Delete always asks; the owned book’s first choice splits Pool and archived honestly. Move up / down stop at the pinned group’s edge.</td><td>M + M</td></tr>
<tr><td>Book settings, the rule screen, the state confirms</td>
<td>W-096, W-097, W-098, W-105, W-106, W-112, W-113, W-100, W-013 (no raw refusals), W-074 (editing a living book’s rule)</td>
<td>Hoists owed: <code>BookSettingsModel</code>, <code>CollectingCopy</code>, <code>BookStateCopy</code> (finish / seal / own / unseal confirms and receipts), <code>RuleEditorModel</code> and <code>RuleEditorCopy</code>, <code>OutflowChooser</code>, <code>HideOwnedChoice</code>. Core <code>lockReading</code>, <code>sealReading</code>, <code>setReadingOwned</code>, <code>setReadingOutflow</code>, <code>setReadingIntakeSeating</code>, <code>RuleEditing</code>.</td>
<td>The sheet; the confirm sheet with a list; the working state.</td>
<td>Finish asks whenever N &gt; 0 and the N in the sentence is the set the act will dismiss (one shared predicate). State doors are not drawn on a gathering. Reopen on a sealed book is never offered. The Shared-with row (AI grants) is left out: the phone runs no MCP door — confirm at the sitting.</td><td>L</td></tr>
<tr><td>The membership choice sheet</td><td>W-108, W-102, W-092</td>
<td>Core <code>OwnershipDecision</code>, <code>copyPostIntoReading</code>, <code>movePostIntoReading</code> (and their <code>answering:</code> forms for an arrival). Hoist owed: <code>MembershipChoiceCopy</code>.</td>
<td>The sheet; opening it from every add road an ownership refusal reaches.</td>
<td>The add list is the note’s own wing’s books, with “(archived)” marked. A move that would leave a finished or sealed book is dimmed with its reason, not hidden.</td><td>M</td></tr>
<tr><td>New book and Create gathering</td><td>W-072, W-073, W-074</td>
<td>Core <code>createReading(shelfId:)</code> with the per-wing name guard, Core <code>RuleGrammar</code> / <code>RuleEditing</code>, Core <code>allTags(_:wingID:)</code>. Hoist owed: <code>RuleEditorModel</code>, <code>RuleEditorCopy</code>.</td>
<td>The flat rule face with a “not” switch; locked rows for groups; the wing-scoped tag picker.</td>
<td>The picker passes the wing the book will live in. The mint passes the standing wing and the solo’d shelf (today both are always Home, unshelved). A rule with groups round-trips byte for byte when saved from the phone. Legacy date or profile terms show the Mac’s read-only notice.</td><td>M (the simple face) · L if the full tree is ruled</td></tr>
</table>
<p class="note-ann"><b>Added to the sizing sheet’s vocabulary</b> (in its spirit, sizes from its scales): a grouped-rows card for sheets (paper card, 14 pt radius, 52 pt rows, on the room);
a confirm sheet (title 20, lines 15, stacked 50 pt buttons, the destructive one in the alarm ink on paper); a state chip (24 pt, wash, 13 semibold);
the book strip (48 pt, room, 60 pt-wide ‹ › targets); a segmented choice (44 pt); a switch; a term row with a “not” switch; row swipe panels; one message line (15 pt; refusals in the alarm ink).</p>
"""
write('a-book.html', 'VM-44 mockups — a book', INTRO, sections, NOTES, check_dir=os.environ.get('BK_CHECK'))
