# VM-44 — library-and-search.html (throwaway generator; static HTML out). Revision pass: drawn to sitting-1-rulings.md.
import sys, os
sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
from base import *

N = Num()

# ---------------------------------------------------------------- 1 · the Library in one wing
BOOKS3 = [brow("Essays", "8 notes · #essay #goals", STAR), brow("Journal", "13 entries · daily journal", STAR), brow("Blog drafts", "7 notes · #blog #draft")]
l_rest = library()
l_all = library(on=0, rows=[sec("Books", "10"), *BOOKS3, '<div class="morerow">all 10 ›</div>', sec("Notes", "64"), *lib_rows(4)])
l_stamp = library('<div class="zone b" style="top:356px;height:44px;left:12px;right:268px"></div>',
                  '<div class="pop" style="left:14px;top:402px">Edited Nov 12, 2026 at 1:02 PM</div>')
l_sort = library(SCRIM, ctx(184, ["§Sort by", ("Edited", '', 'ck'), ("Created", '', 'nock'), ("Date", '', 'nock'), ("Title", '', 'nock'),
                                  ("Newest first", '', 'ck gap'), ("Oldest first", '', 'nock')], right=16, width=230))
POOLROWS = [nr(t, s, p, **k) for t, s, p, w, k in LIB if w == "No book"]
l_pool = library(on=3, rows=[sec("4 notes · 2 in gatherings"), *POOLROWS,
                             '<div class="sec tap" style="margin-top:8px"><span>In gatherings</span><span class="n">2 ›</span></div>'])
TAIL = [nr("Books to return to the library", "Sep 30", "The Montaigne, the tide tables, and the one about knots I never opened.", "No book"),
        nr("What the river taught me about revision", "Sep 27", "Every spring the river moves its bank a little and nobody calls it a mistake.", "Essays"),
        nr("Letters I never sent", "Sep 15", "There is a drawer of them, and the drawer is the point.", "Essays"),
        nr("Sunday 13 September", "Sep 13", "First swim since June. Cold enough to rearrange my opinions.", "Journal"),
        nr("Walking as a writing tool", "Sep 3", "The paragraph I could not finish at the desk finished itself somewhere past the bakery.", "Essays")]
l_page = library(rows=TAIL + ['<div class="loadline">Loading more notes…</div>'])
l_end = library(rows=TAIL[2:] + [nr("Notes on attention", "Aug 22", "Attention is the only thing I own that grows when I spend it.", "Essays"),
                                 '<div class="endline">All 64 notes in Home</div>'])
l_empty = library(wing="Taxes 2025", rows=['<div class="empty">No notes in Taxes 2025 yet.<small>Write one in the box below.</small></div>'])
s1 = [
    opt(l_rest, N(), "The Library, in Home.",
        "She taps Library. Only Home’s notes. The row is the ruled one: the note’s name; then the time and one line of the note’s words; then where it lives. "
        "A note she never named leads with its first words, never a raw date. A journal entry leads with its day. An empty note says “Untitled” and “No text yet”. "
        "The whole row opens the note. Above: search, the day filter, sort; then the rooms as chips."),
    opt(l_all, N(), "All: books, then notes.",
        "She taps All. The Mac’s shape: a short Books section with a door to the rest, then the notes."),
    opt(l_stamp, N(), "She taps a time.",
        "The time is its own small target (outlined, 44 pt tall). Tapping it shows the whole fact, as the Mac’s hover does. Tapping anywhere else closes it. The rest of the row still opens the note."),
    opt(l_sort, N(), "Sort.",
        "The sort button beside the field. The Mac’s four, and a direction. The phone remembers the choice."),
    opt(l_pool, N(), "Pool.",
        "Notes in no book. The count uses the Mac’s words, and the notes a gathering already shows wait behind one row instead of vanishing. A quick note from the capture box lands here."),
    opt(l_page, N(), "Scrolling far down.",
        "The list loads the next page as she nears the end and says so. There is no cut at 200: every note in the wing can be reached by scrolling."),
    opt(l_end, N(), "The end of the list.", "The last row is followed by the count, so the end reads as the end and not as a cut.", small=True),
    opt(l_empty, N(), "A wing with no notes.", "One sentence naming the wing, and where to start.", small=True),
]

# ---------------------------------------------------------------- 2 · Snippets: view, add, edit, delete
def snip(text, tag='', dots=True):
    t = '<div class="nw">%s</div>' % tag if tag else ''
    return '<div class="snip"><div class="mid"><div class="tx">%s</div>%s</div>%s</div>' % (text, t, '<span class="rdots">%s</span>' % I_MORE if dots else '')
SNIPS = [("a heron, standing like a question mark", ""), ("the sea doesn’t keep appointments", ""),
         ("Every lighthouse is a promise somebody keeps at night.", "#quote"), ("salt on the window glass", "")]
SHARED = sec("Snippets is the one room every wing shares.")
SNIPBOX = '<div class="qe"><div class="qebox">New snippet</div></div>'
def snippets(*over, rows=None, foot=SNIPBOX, bar=True):
    rows = [SHARED] + [snip(t, g) for t, g in SNIPS] if rows is None else rows
    return library(*over, on=4, rows=rows, foot=foot, bar=bar)
n_rest = snippets()
ADDROW = '<div class="qact"><span class="sp"></span><span class="pill fill">Add</span></div>'
n_add = snippets(foot=qe_typed(["the kettle has started to sing a different note"]) + ADDROW + kb('return'), bar=False,
                 rows=[SHARED] + [snip(t, g) for t, g in SNIPS[:2]])
n_menu = snippets(SCRIM, ctx(430, [("Edit", sm(I_PENCIL)), ("Delete snippet", sm(I_TRASH), 'danger gap')], right=20, width=230))
n_edit = snippets(sheet(250, shead("Edit snippet", right="Save", left="Cancel"),
                        '<div class="editbox">the sea doesn’t keep appointments, and neither do I<span class="caret"></span></div>',
                        kb('return'), cls='kbd'))
n_del = snippets(rows=[SHARED] + [snip(t, g) for t, g in SNIPS if not t.startswith("the sea")],
                 foot=rcpt("Snippet moved to the Trash.", "Undo") + SNIPBOX)
s2 = [
    opt(n_rest, N(), "Snippets.",
        "The Mac’s name and its one sentence about wings. Each snippet in full, with its tag. Each row has a visible ⋯. The box at the foot adds one."),
    opt(n_add, N(), "Add.",
        "She types in the box. Return is a new line, as in the capture box; Add keeps it as a snippet and clears the box. The new snippet joins the list, so nothing is said."),
    opt(n_menu, N(), "A snippet’s ⋯.",
        "Edit and Delete. Tapping the snippet itself also opens Edit. Dragging a snippet into a note stays on the Mac and is not drawn."),
    opt(n_edit, N(), "Edit.",
        "The snippet’s words in a small sheet with the keyboard. Save keeps the change; Cancel leaves it as it was."),
    opt(n_del, N(), "After Delete.",
        "The row leaves. One short line with Undo, because something left the page. It waits in the Trash for 30 days like anything else. The line’s words are a draft."),
]

# ---------------------------------------------------------------- 3 · acting on rows
def swiped(i, kind):
    rows = lib_rows()
    t, s, p, w, k = LIB[i]
    if kind == 'star':
        rows[i] = '<div class="swipe"><div class="act l star">%sStar</div>%s</div>' % (I_STARF, nr(t, s, p, w, cls='sl', **k))
    else:
        rows[i] = ('<div class="swipe"><div class="act arch">%sArchive</div><div class="act alarm">%sDelete</div>%s</div>'
                   % (I_ARCH, I_TRASH, nr(t, s, p, w, cls='sr2', **k)))
    return rows
r_star = library(rows=swiped(3, 'star'))
r_left = library(rows=swiped(3, 'left'))
r_conf = library(confirm(None, "Delete note", ["The note goes to the Trash for 30 days. You can put it back from there until then."],
                         [btn("Delete", 'alarm'), btn("Cancel", 'quiet')]))
gone = lib_rows(); del gone[3]
r_deld = library(rows=gone, foot=rcpt("Note moved to the Trash — 30 days to put it back.", "Undo") + qe(today=False))
r_arch = library(rows=gone, foot=rcpt("Note archived — it’s kept in Archived, with no countdown.", "Undo") + qe(today=False))
t1, s1_, p1, w1, k1 = LIB[1]
r_menu = library(SCRIM, lift(196, nr(t1, s1_, p1, w1, **k1)),
                 ctx(292, [("Unstar", sm(I_STARF)), ("Rename…", sm(I_PENCIL)), ("Duplicate with tags", sm(I_COPY)), ("Duplicate without tags", sm(I_COPY)),
                           ("Move to wing…", sm(I_WING)), ("Copy to wing…", sm(I_WING)), ("Export note…", sm(I_SHARE)), ("Archive", sm(I_ARCH)),
                           ("Delete note…", sm(I_TRASH), 'danger gap')], head="Edited Nov 12, 2026 at 1:02 PM", right=24, width=290))
dup = lib_rows()
dup.insert(0, nr("On keeping a commonplace book", "today 2:31 PM", "I started copying sentences into a notebook the winter I stopped trusting my memory for them.", "Essays"))
r_dup = library(rows=dup)
def actbar(*items): return '<div class="actbar">%s</div>' % ''.join('<span class="ab %s">%s%s</span>' % (c, i, l) for l, i, c in items)
SELHEAD = '<div class="selbar"><span class="n">3 notes selected</span><span class="hb">Done</span></div>'
SELACTS = actbar(("Tags", I_TAG, ''), ("Archive", I_ARCH, ''), ("Delete 3…", I_TRASH, 'danger'))
r_sel = P(SELHEAD, lst(*lib_rows(sel={1, 3, 4})), SELACTS, hi())
r_selconf = P(SELHEAD, lst(*lib_rows(sel={1, 3, 4})), SELACTS, hi(),
              confirm(None, "Delete 3 notes?", ["The 3 notes go to the Trash for 30 days. You can put them back from there until then."],
                      [btn("Delete", 'alarm'), btn("Cancel", 'quiet')]))
s3 = [
    opt(r_star, N(), "Swipe right: star.",
        "A short swipe shows Star; a full swipe stars. The star appears on the row and nothing is said. The same swipe unstars."),
    opt(r_left, N(), "Swipe left: archive, delete.",
        "Archive in the quiet ink, Delete in the alarm ink at the edge. A full swipe does not delete; Delete always asks."),
    opt(r_conf, N(), "Delete asks.",
        "The Mac’s confirm: where it goes, for how long, and that it can come back."),
    opt(r_deld, N(), "After Delete.",
        "The row leaves. The Mac’s line, with Undo: something left the page. Undo is the same act as Put back in the Trash."),
    opt(r_arch, N(), "After Archive.",
        "No confirm: archiving loses nothing. The row leaves and the Mac’s line shows, with Undo, as she ruled. Undo is the existing unarchive."),
    opt(r_menu, N(), "Press and hold: the row’s menu.",
        "Every act a note has in v1, headed by the whole time stamp: both duplicates, move and copy to a wing, export, archive, delete. Each also has a visible door: the swipes, or the note’s own ⋯."),
    opt(r_dup, N(), "After Duplicate with tags.",
        "The copy is the new first row. Nothing is said, because she can see it. With tags, a book that collects those tags takes the copy as it would any tagged note; without tags it lands in the Pool."),
    opt(r_sel, N(), "Select several.",
        "From ⋯ ▸ Select…. Rows grow a tick; the title band becomes the count, in the Mac’s words. The foot carries what the Mac’s bulk row carries: tags, archive, delete. The search field, filters, box and bar step aside."),
    opt(r_selconf, N(), "Delete several.", "One confirm naming the count, the Mac’s words. Then one line with Undo: “3 notes moved to the Trash — 30 days to put them back.”", small=True),
]

# ---------------------------------------------------------------- 4 · search
def hit(title, where, stamp, passages, more=None, star=False):
    h = '<div class="hh"><div class="nt"><span class="x">%s</span>%s<span class="st">%s</span></div><div class="nw">%s</div></div>' % (title, STAR if star else '', stamp, where)
    ps = ''.join('<span class="psg">%s</span>' % p for p in passages)
    m = '<div class="alln">%s</div>' % more if more else ''
    return h + ps + m + '<div class="grpend"></div>'
def switches(arch=False, com=False):
    return ('<div class="swrow"><span class="sw1">%s Archived</span><span class="sw1">%s Commits</span></div>' % (toggle(arch), toggle(com)))
def scope(allw=False, wing="Home"):
    return '<div class="scopeseg">%s</div>' % seg([wing, "All wings"], 1 if allw else 0)
def searching(q, body, *over, arch=False, com=False, kbd=False, cls='', wing="Home", focus=None, allw=False):
    f = (not q) if focus is None else focus
    place = "Search all wings" if allw else "Search " + wing
    return P(wmast(wing, buttons=('more',), extra=TRASHB), dots(wi(wing)), searchrow(place, q=q, focus=f, cancel=True), scope(allw, wing), switches(arch, com),
             lst(*body), kb('search') if kbd else tabs_words(2) + hi(), *over, cls=cls)
FERRY = [
    hit("Walk note: the ferry timetable changes in December", "No book", "today 2:14 PM",
        ["Walk note: the <mark>ferry</mark> timetable changes in December, and the morning boat now leaves at seven forty."]),
    hit("Thursday 12 November", "Journal", "today 8:40 AM",
        ["Second entry, later. The <mark>ferry</mark> timetable changes in December; wrote it down twice."]),
    hit("Day 3 — Cacilhas", "Lisbon trip", "Nov 5",
        ["We took the <mark>ferry</mark> across for grilled fish and nearly missed the last one back.",
         "The last <mark>ferry</mark> leaves at 1:20, which we proved by running for it."], more="all 4 ›"),
]
ARCHFOOT = '<div class="morerow" style="border:0;color:var(--meta);font-weight:400">1 more in the archive —&nbsp;<span style="color:var(--accent);font-weight:500">show archived</span></div>'
q_focus = searching('', ['<div class="empty" style="padding-top:36px">Search your notes.<small>Notes, books, snippets and comments.</small></div>'], kbd=True)
q_res = searching('ferry', ['<div class="cnt">3 notes · 6 passages</div>', *FERRY, ARCHFOOT])
CACILHAS = hit("Day 3 — Cacilhas", "Lisbon trip", "Nov 5",
               ["We took the <mark>ferry</mark> across for grilled fish and nearly missed the last one back.",
                "<i>commit · Nov 5</i>Took the <mark>ferry</mark> to Cacilhas. Fish. Ran for the boat."], more="all 4 ›")
q_com = searching('ferry', ['<div class="cnt">3 notes · 6 passages · 1 commit</div>', *FERRY[:2], CACILHAS, ARCHFOOT], com=True)
q_land = P(nav(MORE), '<div class="page"><div class="ntitle">Day 3 — Cacilhas</div><div class="nchip"><b>Lisbon trip</b> · in Home · Nov 5</div>'
           '<p>Woke late. The tiles on the building opposite are the blue of a swimming pool somebody loved.</p>'
           '<p>We took the <mark class="sel">ferry</mark> across for grilled fish and nearly missed the last one back.</p>'
           '<p>The last ferry leaves at 1:20, which we proved by running for it.</p></div>',
           '<div class="findbar"><span class="fq">%s ferry<i>1 of 4</i></span><span class="fb">%s</span><span class="fb">%s</span><span class="fb" style="width:auto;padding:0 8px;font:600 17px var(--sans)">Done</span></div>'
           % (sm(I_SEARCH, 16), I_UP, I_DOWN), hi())
q_none = searching('lighthouse', ['<div class="empty" style="padding-top:36px">Nothing found in Home.</div>',
                                  '<div class="btn plain" style="margin:22px 60px 0">Search all wings</div>'], kbd=True, focus=True)
ALLW = [
    hit("The keeper’s daughter", "Short stories · <span class=\"winglbl\">Fiction</span>", "Oct 28",
        ["Every <mark>lighthouse</mark> is a promise somebody keeps at night, and she was tired of keeping it.",
         "From the gallery the <mark>lighthouse</mark> threw its one long sentence across the water."]),
    hit("Notes on Trinity House", "Sources · <span class=\"winglbl\">Research</span>", "Sep 14",
        ["The last manned <mark>lighthouse</mark> in England was automated in 1998."]),
    hit("Every lighthouse is a promise somebody keeps at night.", "Snippet · <span class=\"winglbl\">every wing</span>", "Aug 30", []),
]
q_allw = searching('lighthouse', ['<div class="cnt">2 notes · 1 snippet · 3 passages</div>', *ALLW], allw=True)
TAGGED = [nr("Write the bread recipe as a poem", "Nov 7", "Flour, water, salt, patience. The last one is the only ingredient that is not sold.", "Recipes"),
          nr("Grandmother’s lemon cake", "Oct 30", "Three lemons, and she would say four if they are small. Butter the tin twice.", "Recipes", star=True),
          nr("Soup for a cold", "Oct 19", "Ginger, more ginger than seems reasonable, and a whole head of garlic.", "Recipes"),
          nr("Bread, second attempt", "Oct 11", "Wetter dough, longer wait. The crust sang when it came out.", "Recipes"),
          nr("What to cook when nobody is hungry", "Sep 29", "Toast. Good toast, with the good butter, and nothing said about it.", "Recipes")]
q_tag = searching('#recipe', ['<div class="cnt">1 book · 5 notes</div>', sec("Books"), brow("Recipes", "#recipe flows here"), sec("Notes tagged #recipe", "5"), *TAGGED])
s4 = [
    opt(q_focus, N(), "She taps the search field.",
        "The field lives at the top of the Library, under the wing’s name. The search button on the Bookcase and Starred comes here with the field ready. "
        "Under it, the scope: this wing, or all wings. It starts on this wing every time. Two plain switches add the archive and her commits. Cancel ends the search."),
    opt(q_res, N(), "Results for “ferry”, in Home.",
        "Search reads the words inside notes, not only titles. First the count, in the Mac’s words. Then each note with the lines that match, the word marked. “all 4 ›” shows the rest of that note’s lines. "
        "At the foot: how many more sit in the archive, with a door that turns the switch on."),
    opt(q_com, N(), "With Commits on.",
        "Lines kept by a commit join the list, each marked “commit” with its day, as on the Mac. They never show without the switch."),
    opt(q_land, N(), "She taps a line.",
        "The note opens in Write at that block, with the match selected and Find ready to step through the rest. Back returns to the same results. No bar: this is a note."),
    opt(q_none, N(), "Nothing found in this wing.",
        "“lighthouse” is not in Home. One sentence, and one button that flips the scope for her. If the archive had a match, the “show archived” door would sit here too."),
    opt(q_allw, N(), "All wings.",
        "The same search across all nine. Each result names its wing after its book; a snippet belongs to every wing. "
        "Tapping a result from another wing opens the note and the app follows it there (the Mac’s rule). The Mac’s twin of this switch is VX-987."),
    opt(q_tag, N(), "Searching a tag.",
        "“#recipe” narrows the Library to the notes that wear it, as ordinary rows, and lists the book the tag flows into with the Mac’s reason. A plain word that names a tag offers it as one chip: “tag: #recipe ›”."),
]

# ---------------------------------------------------------------- 5 · the day filter
def cal():
    wk = ''.join('<span>%s</span>' % d for d in "SMTWTFS")
    cells = []
    for d in range(1, 31):
        c = ' class="on"' if d == 10 else (' class="now"' if d == 12 else '')
        cells.append('<span%s><b>%d</b></span>' % (c, d))
    cells += ['<span class="o">%d</span>' % d for d in range(1, 6)]
    return ('<div class="cal"><div class="calh"><span class="ar">%s</span>November 2026<span class="ar">%s</span></div><div class="calw">%s</div><div class="calr">%s</div></div>'
            % (I_BACK2, I_FWD, wk, ''.join(cells)))
d_sheet = library(sheet(286, shead("When"), seg(["On a day", "Between days"], 0), cal(),
                        '<div class="armed">Showing notes edited <b>on Nov 10</b>.</div>', grp(mrow("Any day", cls='acc'))))
DAYROWS = [nr(t, s, p, w, **k) for t, s, p, w, k in LIB if s == "Nov 10"]
d_on = library(when='on', rows=[sec("2 notes"), *DAYROWS],
               mid='<div class="fbarrow"><span class="fchip">edited on Nov 10 %s</span></div>' % I_X)
d_none = library(when='on', rows=['<div class="empty">No note’s last edit or commit falls on Nov 4.</div>'],
                 mid='<div class="fbarrow"><span class="fchip">edited on Nov 4 %s</span></div>' % I_X)
s5 = [
    opt(d_sheet, N(), "She taps the calendar button.",
        "The Mac’s “when” door as a sheet. One day or a run of days; today is ringed, the chosen day filled. Nothing changes until she taps a day. "
        "The sentence under the month says what the list will show — the Mac’s own. “Any day” clears it."),
    opt(d_on, N(), "Notes edited on that day.",
        "A chip under the field says the filter is on, in the Mac’s words; ✕ clears it. The list is the notes whose last edit, or a commit, fell on that day."),
    opt(d_none, N(), "A day with nothing.", "The Mac’s sentence.", small=True),
]

# ---------------------------------------------------------------- 6 · the largest text, dark
x_xl = library(cls='xl', rows=lib_rows(5))
x_dk = library(cls='dk')
x_dkq = searching('ferry', ['<div class="cnt">3 notes · 6 passages</div>', *FERRY, ARCHFOOT], cls='dk')
s6 = [
    opt(x_xl, N(), "The Library at the largest text size.",
        "The densest screen in this file. Titles wrap to two lines instead of cutting; the preview takes two lines; three notes show. The chips scroll, and the field and buttons grow."),
    opt(x_dk, N(), "The Library, dark.", ""),
    opt(x_dkq, N(), "Search results, dark.", "The matched word stays readable on the dark wash."),
]

INTRO = """
<p class="lede"><b>VM-44 mockups — the Library and search.</b> Revised after the first sitting: every frame follows <code>plans/sitting-1-rulings.md</code>.
Today the phone’s Library is the 200 most recently touched notes from all nine wings with a silent cut, an untitled note is a raw date printed twice, there is no preview, and search reads titles only.</p>
<p class="q">“showing preview more lot apple notes so i know what each note is.” · “it’s hard to find items in the library.” · “List, one preview line (middle)” · “Day first” · “Pool and Snippets” ·
“View, add, edit, delete” · “it should be current wing with a switch to all” · “Duplicate (both kinds), Multi-select, Undo on archive, Move / copy to wing”</p>
<p class="lede"><b>What was chosen, in one line each.</b> The row: the title; the time and one line of the note’s words; where it lives. A journal entry leads with its day. The rooms are Pool and Snippets.
Snippets can be viewed, added, edited and deleted. Search covers the current wing, with a switch to all wings. The note acts in v1: both duplicates, selecting several, Undo on archive, move and copy to a wing.
Lines: none for ordinary acts; a short line with Undo only when something leaves the page (archive, delete), and for refusals.</p>
"""
sections = [
    ("1 · The Library in one wing", '<p class="lede">Rows, the time stamp, sort, the rooms as chips, and paging with no cut.</p>', s1),
    ("2 · Snippets", '<p class="lede">View, add, edit and delete.</p>', s2),
    ("3 · Acting on rows", '<p class="lede">Swipes for the three common acts, a menu for all of them, and selecting several.</p>', s3),
    ("4 · Search", '<p class="lede">The words inside notes, in this wing, with a switch to all wings.</p>', s4),
    ("5 · The day filter", '<p class="lede">“Notes edited on this day.”</p>', s5),
    ("6 · The largest text size, and dark", '', s6),
]
NOTES = """
<div class="pick" style="max-width:1500px"><h2>Still open here</h2>
<p><b>Nothing is waiting on a ruling.</b> Two small calls are mine and easy to reverse: the scope switch is drawn as a two-word control (“Home · All wings”) rather than a toggle, so it names the wing it searches;
and it goes back to the current wing each time search opens.</p>
<p><b>Drafted lines</b> (the snippet lines, the search hints, the two empty lines) are in <code>design/wording-list-1.md</code>.</p></div>

<h2>Build notes</h2>
<table class="bn">
<tr><th>Screen</th><th>Work-list rows it delivers</th><th>Shared brain it stands on</th><th>What is new</th><th>Must not get wrong</th><th>Size</th></tr>
<tr><td>The Library listing (rows, preview, names)</td><td>W-033, W-037, W-038, W-039, W-040, W-032, W-007 (the bar)</td>
<td>Core <code>Queries.catalogNotesPage</code> (keyset pages, carries profile and stored title), Core <code>NoteCardFace</code> (lead and preview), Core <code>leadingBlockTexts</code>. Hoist owed: <code>LibraryCardName</code>, <code>LibraryCardRead</code>.</td>
<td>A flat, length-capped “first words for these rows” read in Core (W-038); the row face.</td>
<td>One page at a time, never a fixed cap; the end shows the count. Previews are read once per page, off the main thread, and never inside a held observation (today’s listing re-reads on every autosave). The first block’s text is cut in SQL, not after fetching. Scoped to the wing. An untitled note leads with first words; a journal entry with its day; an empty note says “Untitled · No text yet”. The preview carries on from the lead and never repeats it.</td><td>L</td></tr>
<tr><td>The time stamp and its whole fact</td><td>W-041</td>
<td>Core <code>TimeStampFace</code> (<code>relative</code>, <code>tooltip</code>). Hoist owed: <code>LibrarySortFace</code>.</td>
<td>The tap target on the stamp; the small popover.</td>
<td>The stamp is the sort’s own (edited under Edited, created under Created). Its hit area is 44 pt tall and at least 64 wide and sits inside the row; every other point of the row opens the note. Never the raw day key.</td><td>S</td></tr>
<tr><td>Sort, the rooms, All, Pool</td><td>W-042, W-050, W-051, W-053</td>
<td>Shared <code>LibrarySortWords</code>; Core <code>poolPosts</code> (loose and tucked); Mac-local Pool words (<code>PoolPostsView</code>’s count line) — hoist owed.</td>
<td>The chip row with Pool, Snippets, Archived; the capped Books section under All.</td>
<td>The sort and its direction are remembered per device. Archived is a chip, one tap away, never the last row. The names are Pool and Snippets everywhere; “Bookless” and “Scraps” are gone.</td><td>M</td></tr>
<tr><td>Snippets: view, add, edit, delete</td><td>W-052 (the v1 part: no groups, no search, no drag into a note)</td>
<td>Core <code>newBlock</code> into the pool container, <code>autosave</code>, <code>deleteBlock</code>, <code>restoreBlock</code>; Mac-local <code>SnippetsCopy</code> (<code>deleteRow</code>) and <code>WingCopy.snippetsShared</code> — hoist owed.</td>
<td>The row with a visible ⋯; the add box; the edit sheet.</td>
<td>Snippets is the one room all wings share and says so. Delete is a tombstone with the ordinary 30 days, and its Undo is the session’s structural undo. Edit writes the snippet’s one take through autosave; a fanned snippet edits the take shown.</td><td>M</td></tr>
<tr><td>Swipes, the row menu, both duplicates</td><td>W-010, W-046, W-047, W-048, W-036, W-233</td>
<td>Core <code>archiveContainer</code>, <code>duplicateAsVersion(_:tags:)</code>, <code>deleteContainer</code>; Shared <code>RecoveryCopy</code> (confirm and lines). Hoist owed: the Mac’s row table, <code>NoteDuplicate</code>, <code>DuplicateCopy</code>.</td>
<td>Leading and trailing swipe panels (104 pt each); the menu’s head line; Undo on the archive and delete lines.</td>
<td>A full swipe never deletes. Delete always confirms. Star and Duplicate say nothing; Archive and Delete each leave one line with Undo. No act is press-and-hold only.</td><td>M</td></tr>
<tr><td>Select several</td><td>W-049</td>
<td>Shared <code>RecoveryCopy</code> (<code>deleteNotesConfirmTitle</code>, lines). Hoist owed: <code>LibraryBulkRow</code>’s acts, <code>LibraryCopy.notesPicked</code>.</td>
<td>The select mode (shared with Arrivals and the Trash).</td>
<td>One confirm naming the count; one line with Undo for the whole act. Leaving select mode clears the picks.</td><td>M</td></tr>
<tr><td>Search (field, scope, results, switches)</td><td>W-059, W-060, W-061, W-062, W-063 (not drawn); the all-wings switch is new on both platforms (the Mac’s is VX-987)</td>
<td>Core <code>SearchQuery</code>, <code>SearchScope(wingID:)</code> (nil for all wings), <code>searchGroups</code>, <code>SearchCounts</code>, <code>SearchTagOffer</code>; Mac-local but pure <code>LibrarySearchQuestion</code>, <code>LibrarySearchModel</code>, <code>SearchAnswerCopy</code>, <code>LibrarySearchCopy</code> — hoist owed.</td>
<td>The results list as grouped rows; the scope control; the two switches; the wing named on a result.</td>
<td>The current wing by default, every time search opens. Under All wings every result names its wing, and tapping one follows the note to its wing. Cost follows the matches, never the library: pages, with “loading more…”. No capped list; every “all N ›” opens the rest. Commits never list without their switch. The archive foot counts places, and its door only turns the switch on. The Trash is never searched. The count line counts what is listed. The bar shows under results; it leaves while the keyboard is up.</td><td>L</td></tr>
<tr><td>Landing on a match</td><td>W-064</td>
<td>Shared <code>SearchLanding</code>; the note’s Find (the note designer’s face).</td><td>—</td>
<td>Lands at the block, the match selected, Find armed with the same word; never at the top of the note. Back returns to the results as they were.</td><td>M</td></tr>
<tr><td>The day filter</td><td>W-043</td>
<td>Core <code>searchCatalog(editedOn:)</code>, <code>DayBounds</code>. Hoist owed: <code>LibraryDayFace</code> (the sentence, the chip, the empty lines), the month grid’s rule.</td>
<td>The sheet with the month.</td>
<td>Nothing arms until a day is tapped. “Between days” is two taps. The answer is last edit or a commit on that day.</td><td>M</td></tr>
<tr><td>Largest text, dark</td><td>W-001, W-004, W-005</td><td>The phone type layer.</td><td>—</td><td>Titles wrap rather than cut; the stamp never truncates.</td><td>—</td></tr>
</table>
<p class="note-ann"><b>Added to the sizing sheet’s vocabulary</b> (in its spirit): the stamp popover (15 pt, one line); the passage line (her words at Iowan 15 with a 2 pt rule at its left, the match on the wash, 44 pt minimum);
the scope control (the 44 pt two-word choice) and the two-switch row (48 pt, the system’s switch); the snippet row (her words at 17, a 44 pt ⋯); the filter chip with ✕ (32 pt capsule in a 44 pt row);
the select bar and its three-act foot (60 pt); the month grid (46 pt cells); the “loading” and “end” lines (13 pt).
Not drawn: the search order door (W-063), tag chips on rows (W-045), the Timeline (W-044), snippet groups.</p>
"""
write('library-and-search.html', 'VM-44 mockups — the Library and search', INTRO, sections, NOTES, check_dir=os.environ.get('SH_CHECK'))
