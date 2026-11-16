# VM-44 — library-and-search.html (throwaway generator; static HTML out).
import sys, os
sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
from base import *
def ncard(title, stamp, preview, where, star=False):
    return ('<div class="ncard"><div class="nt"><span class="x">%s</span>%s</div><div class="np2">%s</div><div class="nf"><span>%s</span><span>%s</span></div></div>'
            % (title, STAR if star else '', preview, where, stamp))

# ---------------------------------------------------------------- 1 · LS-1, small
def nr2(title, stamp, preview, star=False):
    return ('<div class="nrow"><div class="nt"><span class="x">%s</span>%s<span class="st">%s</span></div><div class="np2l">%s</div></div>'
            % (title, STAR if star else '', stamp, preview))
SHORT = {"today 2:14 PM": "2:14 PM", "today 1:02 PM": "1:02 PM", "today 8:40 AM": "8:40 AM"}
a_cards = library(rows=['<div style="height:8px"></div>'] + [ncard(t, s, p, w, k.get('star', False)) for t, s, p, w, k in LIB])
a_list = library()
a_two = library(rows=[nr2(t, SHORT.get(s, s), p, k.get('star', False)) for t, s, p, w, k in LIB])
a_tog = library(mid='<div class="chips" style="height:48px"><span style="font:400 13px var(--sans);color:var(--meta);padding-left:4px">64 notes</span><span class="seg"><span class="on">List</span><span>Cards</span></span></div>')
J = [("Thursday 12 November", "9:15 PM", "Second entry. The ferry timetable changes in December; wrote it down twice."),
     ("Thursday 12 November", "8:40 AM", "Slept badly. The heron was back on the jetty before seven, standing like a question mark."),
     ("Wednesday 11 November", "7:55 AM", "Rain on the skylight. Finished the Montaigne chapter and understood half."),
     ("Tuesday 10 November", "6:30 PM", "10 km along the river path. Left knee fine until the bridge, then not."),
     ("Sunday 8 November", "10:02 AM", "M. called about the move. Said yes before I had thought about it."),
     ("Friday 6 November", "8:11 AM", "No coffee in the house. A short entry, and a resentful one."),
     ("Wednesday 4 November", "9:47 PM", "Physio says rest. I say eight easy kilometres is rest."),
     ("Monday 2 November", "7:20 AM", "First frost. The jetty boards rang like a xylophone.")]
JHEAD = bookhead("Journal", "13 entries · daily journal", '<span class="pill fill">✎ Today</span>' + MORE, star=True)
JFOOT = '<div class="qe"><div class="qebox">New entry</div></div>'
j_day = P(JHEAD, lst(sec("November 2026"), *[nr(d, t, p) for d, t, p in J]), JFOOT, hi())
j_words = P(JHEAD, lst(sec("November 2026"), *[nr(p, d.split(' ', 1)[1].replace('November', 'Nov') + ', ' + t, '') for d, t, p in J]), JFOOT, hi())
s1 = [
    opt(a_cards, "LS-1 (a)", "Cards.", "Title, two lines of the note, then where it lives and when. About four notes a screen, each in a box.", small=True),
    opt(a_list, "LS-1 (b)", "A list, like Apple Notes.", "Title; then the stamp and one line of the note; then its book. Five or six notes a screen. The grader’s pick, carried through this file.", mine=True, small=True),
    opt(a_two, "LS-1 (b2)", "The list with two lines.", "The sizing sheet’s row: the stamp moves up beside the title and the note gets two lines. More to tell notes apart; the book is not shown, and four or five fit.", small=True),
    opt(a_tog, "LS-1 (c)", "A List / Cards switch.", "Both, as on the Mac. One more row of controls before the first note, and two faces to build.", small=True),
    opt(j_day, "LS-1 journal (ii)", "A journal entry leads with its day.", "The day is the name; the time and the first words follow. The rule the Mac’s core already uses, so nothing forks.", mine=True, small=True),
    opt(j_words, "LS-1 journal (i)", "A journal entry leads with its words.", "The first words are the name; the day and time drop to the second line. The orchestrator’s lean. The bold column stops reading as a calendar.", small=True),
]

# ---------------------------------------------------------------- 2 · the Library in one wing
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
def snip(text, tag=''):
    t = '<div class="nw">%s</div>' % tag if tag else ''
    return '<div class="nrow"><div class="np2l" style="color:var(--ink);font-size:17px;line-height:24px;margin:0">%s</div>%s</div>' % (text, t)
l_snip = library(on=4, rows=[sec("Snippets is the one room every wing shares."), snip("a heron, standing like a question mark"), snip("the sea doesn’t keep appointments"),
                             snip("Every lighthouse is a promise somebody keeps at night.", "#quote"), snip("salt on the window glass")],
                 foot='<div class="qe"><div class="qebox">New snippet</div></div>')
TAIL = [nr("Books to return to the library", "Sep 30", "The Montaigne, the tide tables, and the one about knots I never opened.", "No book"),
        nr("What the river taught me about revision", "Sep 27", "Every spring the river moves its bank a little and nobody calls it a mistake.", "Essays"),
        nr("Letters I never sent", "Sep 15", "There is a drawer of them, and the drawer is the point.", "Essays"),
        nr("Sunday 13 September", "Sep 13", "First swim since June. Cold enough to rearrange my opinions.", "Journal"),
        nr("Walking as a writing tool", "Sep 3", "The paragraph I could not finish at the desk finished itself somewhere past the bakery.", "Essays")]
l_page = library(rows=TAIL + ['<div class="loadline">Loading more notes…</div>'])
l_end = library(rows=TAIL[2:] + [nr("Notes on attention", "Aug 22", "Attention is the only thing I own that grows when I spend it.", "Essays"),
                                 '<div class="endline">All 64 notes in Home</div>'])
l_empty = library(wing="Taxes 2025", rows=['<div class="empty">No notes in Taxes 2025 yet.<small>Write one in the box below.</small></div>'])
s2 = [
    opt(l_rest, "1", "The Library, in Home.",
        "She taps Library. Only Home’s notes. Each row: the note’s name, or its first words if she never named it, never a raw date; a stamp in the Mac’s time words and one line of the note; then its book. "
        "A journal entry leads with its day. An empty note says “Untitled” and “No text yet”. The whole row opens the note. Above: search, the day filter, sort; then the rooms as chips."),
    opt(l_all, "2", "All: books, then notes.",
        "She taps All. The Mac’s shape: a short Books section with a door to the rest, then the notes. Books and notes are never mixed into one run."),
    opt(l_stamp, "3", "She taps a stamp.",
        "The stamp is its own small target (outlined, 44 pt tall). Tapping it shows the whole fact, as the Mac’s hover does: the year always, and the minute. Tapping anywhere else closes it. The rest of the row still opens the note."),
    opt(l_sort, "4", "Sort.",
        "The sort button beside the field. The Mac’s four: edited, created, date, title, and a direction. The phone remembers the choice. It is offered under every filter, not only All."),
    opt(l_pool, "5", "Pool (today “Bookless”).",
        "Notes in no book. The count uses the Mac’s words, and the notes a gathering already shows wait behind one row instead of vanishing."),
    opt(l_snip, "6", "Snippets (today “Scraps”).",
        "The Mac’s name and its one sentence about wings. Each snippet in full, with its tag. The box at the foot adds one. Open under LS-3: this is view and add; edit, move and delete would be a row menu."),
    opt(l_page, "7", "Scrolling far down.",
        "The list loads the next page as she nears the end and says so. There is no cut at 200: every note in the wing can be reached by scrolling."),
    opt(l_end, "8", "The end of the list.", "The last row is followed by the count, so the end reads as the end and not as a cut.", small=True),
    opt(l_empty, "9", "A wing with no notes.", "One sentence naming the wing, and where to start.", small=True),
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
r_arch = library(rows=gone, foot=rcpt("Note archived — it’s kept in Archived, with no countdown.", "Undo") + qe(today=False))
t1, s1_, p1, w1, k1 = LIB[1]
r_menu = library(SCRIM, lift(196, nr(t1, s1_, p1, w1, **k1)),
                 ctx(292, [("Unstar", sm(I_STARF)), ("Rename…", sm(I_PENCIL)), ("Duplicate with tags", sm(I_COPY)), ("Duplicate without tags", sm(I_COPY)),
                           ("Move to wing…", sm(I_WING)), ("Copy to wing…", sm(I_WING)), ("Export note…", sm(I_SHARE)), ("Archive", sm(I_ARCH)),
                           ("Delete note…", sm(I_TRASH), 'danger gap')], head="Edited Nov 12, 2026 at 1:02 PM", right=24, width=290))
def actbar(*items): return '<div class="actbar">%s</div>' % ''.join('<span class="ab %s">%s%s</span>' % (c, i, l) for l, i, c in items)
r_sel = P('<div class="selbar"><span class="n">3 notes selected</span><span class="hb">Done</span></div>', '<div class="sub">Tap rows to add or remove them.</div>',
          lst(*lib_rows(sel={1, 3, 4})),
          actbar(("Tags", I_TAG, ''), ("Archive", I_ARCH, ''), ("Delete 3…", I_TRASH, 'danger')), hi())
r_selconf = P('<div class="selbar"><span class="n">3 notes selected</span><span class="hb">Done</span></div>', '<div class="sub">Tap rows to add or remove them.</div>',
              lst(*lib_rows(sel={1, 3, 4})), actbar(("Tags", I_TAG, ''), ("Archive", I_ARCH, ''), ("Delete 3…", I_TRASH, 'danger')), hi(),
              confirm(None, "Delete 3 notes?", ["The 3 notes go to the Trash for 30 days. You can put them back from there until then."],
                      [btn("Delete", 'alarm'), btn("Cancel", 'quiet')]))
s3 = [
    opt(r_star, "10", "Swipe right: star.",
        "A short swipe shows Star; a full swipe stars. The star appears on the row and nothing is said. The same swipe unstars."),
    opt(r_left, "11", "Swipe left: archive, delete.",
        "Archive in the quiet ink, Delete in the alarm ink at the edge. A full swipe does not delete; Delete always asks."),
    opt(r_conf, "12", "Delete asks.",
        "The Mac’s confirm: where it goes, for how long, and that it can come back. After it, the row leaves and the Mac’s line shows: “Note moved to the Trash — 30 days to put it back.”"),
    opt(r_arch, "13", "After Archive.",
        "No confirm: archiving loses nothing. The row leaves and one line says where it went, in the Mac’s words, with Undo. Kept because the note left the screen. Undo is new here; it is the existing unarchive."),
    opt(r_menu, "14", "Press and hold: the row’s menu.",
        "Every act a note has, in one list, headed by the whole stamp. The Mac’s row list plus Duplicate and Archive. Each act also has a visible door: the swipes, or the note’s own ⋯. Export opens the share sheet."),
    opt(r_sel, "15", "Select several.",
        "From ⋯ ▸ Select…. Rows grow a tick; the title band becomes the count, in the Mac’s words. The foot carries what the Mac’s bulk row carries: tags, archive, delete. The search field, filters, box and bar step aside."),
    opt(r_selconf, "16", "Delete several.", "One confirm naming the count, the Mac’s words. Then one line: “3 notes moved to the Trash — 30 days to put them back.”", small=True),
]

# ---------------------------------------------------------------- 4 · search
def hit(title, where, stamp, passages, more=None, star=False):
    h = '<div class="hh"><div class="nt"><span class="x">%s</span>%s<span class="st">%s</span></div><div class="nw">%s</div></div>' % (title, STAR if star else '', stamp, where)
    ps = ''.join('<span class="psg">%s</span>' % p for p in passages)
    m = '<div class="alln">%s</div>' % more if more else ''
    return h + ps + m + '<div class="grpend"></div>'
def switches(arch=False, com=False):
    return ('<div class="swrow"><span class="sw1">%s Archived</span><span class="sw1">%s Commits</span></div>' % (toggle(arch), toggle(com)))
def searching(q, body, *over, arch=False, com=False, kbd=False, cls='', wing="Home", scope=None, focus=None):
    f = (not q) if focus is None else focus
    return P(wmast(wing, buttons=('more',), extra=TRASHB), dots(wi(wing)), searchrow("Search " + wing, q=q, focus=f, cancel=True), switches(arch, com),
             lst(*body), kb('search') if kbd else hi(), *over, cls=cls)
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
SCOPEFOOT = '<div class="endline" style="padding-top:6px">Only Home is searched. Swipe the title to search another wing.</div>'
q_focus = searching('', ['<div class="empty" style="padding-top:36px">Search the words in Home.<small>Notes, titles, book names, snippets and comments. Other wings are separate.</small></div>'], kbd=True)
q_res = searching('ferry', ['<div class="cnt">3 notes · 6 passages</div>', *FERRY, ARCHFOOT, SCOPEFOOT])
CACILHAS = hit("Day 3 — Cacilhas", "Lisbon trip", "Nov 5",
               ["We took the <mark>ferry</mark> across for grilled fish and nearly missed the last one back.",
                "<i>commit · Nov 5</i>Took the <mark>ferry</mark> to Cacilhas. Fish. Ran for the boat."], more="all 4 ›")
q_com = searching('ferry', ['<div class="cnt">3 notes · 6 passages · 1 commit</div>', *FERRY[:2], CACILHAS, ARCHFOOT, SCOPEFOOT], com=True)
q_land = P(nav(MORE), '<div class="page"><div class="ntitle">Day 3 — Cacilhas</div><div class="nchip"><b>Lisbon trip</b> · in Home · Nov 5</div>'
           '<p>Woke late. The tiles on the building opposite are the blue of a swimming pool somebody loved.</p>'
           '<p>We took the <mark class="sel">ferry</mark> across for grilled fish and nearly missed the last one back.</p>'
           '<p>The last ferry leaves at 1:20, which we proved by running for it.</p></div>',
           '<div class="findbar"><span class="fq">%s ferry<i>1 of 4</i></span><span class="fb">%s</span><span class="fb">%s</span><span class="fb" style="width:auto;padding:0 8px;font:600 17px var(--sans)">Done</span></div>'
           % (sm(I_SEARCH, 16), I_UP, I_DOWN), hi())
q_none = searching('lighthouse', ['<div class="empty" style="padding-top:36px">Nothing found in Home.<small>Only Home is searched. Swipe the title to search another wing.</small></div>'], kbd=True, focus=True)
TAGGED = [nr("Write the bread recipe as a poem", "Nov 7", "Flour, water, salt, patience. The last one is the only ingredient that is not sold.", "Recipes"),
          nr("Grandmother’s lemon cake", "Oct 30", "Three lemons, and she would say four if they are small. Butter the tin twice.", "Recipes", star=True),
          nr("Soup for a cold", "Oct 19", "Ginger, more ginger than seems reasonable, and a whole head of garlic.", "Recipes"),
          nr("Bread, second attempt", "Oct 11", "Wetter dough, longer wait. The crust sang when it came out.", "Recipes"),
          nr("What to cook when nobody is hungry", "Sep 29", "Toast. Good toast, with the good butter, and nothing said about it.", "Recipes")]
q_tag = searching('#recipe', ['<div class="cnt">1 book · 5 notes</div>', sec("Books"), brow("Recipes", "#recipe flows here"), sec("Notes tagged #recipe", "5"), *TAGGED])
s4 = [
    opt(q_focus, "17", "She taps the search field.",
        "The field lives at the top of the Library, under the wing’s name, and says which wing it searches. The search button on the Bookcase and Starred comes here with the field ready. "
        "Two plain switches add the archive and her commits. The rooms and the bar step aside; Cancel ends the search."),
    opt(q_res, "18", "Results for “ferry”.",
        "Search reads the words inside notes, not only titles. First the honest count, in the Mac’s words. Then each note with the lines that match, the word marked. “all 4 ›” shows the rest of that note’s lines. "
        "At the foot: how many more sit in the archive, with a door that turns the switch on; and the scope, said plainly."),
    opt(q_com, "19", "With Commits on.",
        "Lines kept by a commit join the list, each marked “commit” with its day, as on the Mac. They never show without the switch."),
    opt(q_land, "20", "She taps a line.",
        "The note opens in Write at that block, with the match selected and Find ready to step through the rest. Back returns to the same results, where she left them."),
    opt(q_none, "21", "Nothing found.",
        "“lighthouse” is in the Fiction wing, not Home. The line says nothing was found here, and why that might be: one wing at a time. If the archive had a match, the “show archived” door would sit here too."),
    opt(q_tag, "22", "Searching a tag.",
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
    opt(d_sheet, "23", "She taps the calendar button.",
        "The Mac’s “when” door as a sheet. One day or a run of days; today is ringed, the chosen day filled. Nothing changes until she taps a day. "
        "The sentence under the month says what the list will show — the Mac’s own sentence. “Any day” clears it."),
    opt(d_on, "24", "Notes edited on that day.",
        "A chip under the field says the filter is on, in the Mac’s words; ✕ clears it. The list is the notes whose last edit, or a commit, fell on that day."),
    opt(d_none, "25", "A day with nothing.", "The Mac’s sentence.", small=True),
]

# ---------------------------------------------------------------- 6 · the largest text, dark
x_xl = library(cls='xl', rows=lib_rows(5))
x_dk = library(cls='dk')
x_dkq = searching('ferry', ['<div class="cnt">3 notes · 6 passages</div>', *FERRY, ARCHFOOT, SCOPEFOOT], cls='dk')
s6 = [
    opt(x_xl, "26", "The Library at the largest text size.",
        "The densest screen in this file. Titles wrap to two lines instead of cutting; the preview takes two lines; three notes show. The chips scroll, and the field and buttons grow."),
    opt(x_dk, "27", "The Library, dark.", ""),
    opt(x_dkq, "28", "Search results, dark.", "The matched word stays readable on the dark wash."),
]

INTRO = """
<p class="lede"><b>VM-44 mockups — the Library and search.</b> Today the phone’s Library is the 200 most recently touched notes from all nine wings with a silent cut, an untitled note is a raw date
printed twice, there is no preview, and search reads titles only: “ferry” finds nothing though several notes contain it.</p>
<p class="q">“showing preview more lot apple notes so i know what each note is.” · “it’s hard to find items in the library.”</p>
<p class="lede">The Library here is one wing’s notes under the ruled shell. The note row is still open (LS-1), so its alternatives are drawn once, small; the grader’s pick, (b), is carried through the rest.
Stamps are the Mac’s time words (“today 2:14 PM”, “yesterday”, “Nov 10”). Pool and Snippets are the Mac’s names for today’s Bookless and Scraps (LS-3’s lean, not yet ruled).</p>
"""
sections = [
    ("1 · The open question: the note row (LS-1)", '<p class="lede">The same notes under each option, then the Journal under each reading.</p>', s1),
    ("2 · The Library in one wing", '<p class="lede">Rows, the stamp, sort, the rooms as chips, and paging with no cut.</p>', s2),
    ("3 · Acting on rows", '<p class="lede">Swipes for the three common acts, a menu for all of them, and selecting several.</p>', s3),
    ("4 · Search: the one finder", '<p class="lede">Full text, in the current wing, said plainly.</p>', s4),
    ("5 · The day filter", '<p class="lede">“Notes edited on this day.”</p>', s5),
    ("6 · The largest text size, and dark", '', s6),
]
NOTES = """
<div class="pick" style="max-width:1500px"><h2>Open questions drawn here, and my picks</h2>
<p><b>LS-1, the row.</b> Pick: (b), the grader’s. It is the Apple Notes row she named, it keeps the book on the row, and at larger text sizes its preview grows to two lines by itself (frame 26).
The one thing that pushes toward (b2): the Mac’s stamp for today is long (“today 2:14 PM”), and inside the preview line it costs about a third of the line. If she finds one line thin on her phone, (b2) is the same row with the stamp moved up.</p>
<p><b>LS-1, the journal entry.</b> Pick: (ii), the day leads — the rule the Mac’s core applies today, in the Library and in the Journal alike, so the two devices name an entry the same way.</p>
<p><b>LS-3, Pool and Snippets.</b> Drawn with the Mac’s names and view-and-add for Snippets. Not ruled.</p>
<p><b>Undo on the archive line</b> is my addition; it calls the existing unarchive. Cut it and the line stands as the Mac’s.</p></div>

<h2>Build notes</h2>
<table class="bn">
<tr><th>Screen</th><th>Work-list rows it delivers</th><th>Shared brain it stands on</th><th>What is new</th><th>Must not get wrong</th><th>Size</th></tr>
<tr><td>The Library listing (rows, preview, names)</td><td>W-033, W-037, W-038, W-039, W-040, W-032</td>
<td>Core <code>Queries.catalogNotesPage</code> (keyset pages, carries profile and stored title), Core <code>NoteCardFace</code> (lead and preview), Core <code>leadingBlockTexts</code>. Hoist owed: <code>LibraryCardName</code>, <code>LibraryCardRead</code>.</td>
<td>A flat, length-capped “first words for these rows” read in Core (W-038); the row face.</td>
<td>One page at a time, never a fixed cap; the end shows the count. Previews are read once per page, off the main thread, and never inside a held observation (today’s listing re-reads on every autosave). The first block’s text is cut in SQL, not after fetching. Scoped to the wing. An untitled note leads with first words; a journal entry with its day; an empty note says “Untitled · No text yet”. The preview carries on from the lead and never repeats it.</td><td>L</td></tr>
<tr><td>The stamp and its whole fact</td><td>W-041</td>
<td>Core <code>TimeStampFace</code> (<code>relative</code>, <code>tooltip</code>). Hoist owed: <code>LibrarySortFace</code>.</td>
<td>The tap target on the stamp; the small popover.</td>
<td>The stamp is the sort’s own (edited under Edited, created under Created). Its hit area is 44 pt tall and at least 64 wide and sits inside the row; every other point of the row opens the note. Never the raw day key.</td><td>S</td></tr>
<tr><td>Sort, the rooms, All</td><td>W-042, W-050, W-051, W-053, W-052 (view and add)</td>
<td>Shared <code>LibrarySortWords</code>; Core <code>poolPosts</code> (loose and tucked); Mac-local Pool words (<code>PoolPostsView</code>’s count line) — hoist owed.</td>
<td>The chip row with Pool, Snippets, Archived; the capped Books section under All.</td>
<td>The sort and its direction are remembered per device. Archived is a chip, one tap away, never the last row. Snippets is the one room all wings share and says so.</td><td>M</td></tr>
<tr><td>Swipes, the row menu</td><td>W-010, W-046, W-047, W-048, W-036, W-233</td>
<td>Core <code>archiveContainer</code>, <code>duplicateAsVersion(_:tags:)</code>, <code>deleteContainer</code>; Shared <code>RecoveryCopy</code> (confirm and receipts). Hoist owed: the Mac’s row table, <code>NoteDuplicate</code>, <code>DuplicateCopy</code>.</td>
<td>Leading and trailing swipe panels (104 pt each); the menu’s head line.</td>
<td>A full swipe never deletes. Delete always confirms. Star says nothing; Archive, Delete and Duplicate each leave one line. No act is press-and-hold only.</td><td>M</td></tr>
<tr><td>Select several</td><td>W-049</td>
<td>Shared <code>RecoveryCopy</code> (<code>deleteNotesConfirmTitle</code>, receipts). Hoist owed: <code>LibraryBulkRow</code>’s acts, <code>LibraryCopy.notesPicked</code>.</td>
<td>The select mode (shared with Arrivals and the Trash).</td>
<td>One confirm naming the count; one line for the whole act. Leaving select mode clears the picks.</td><td>M</td></tr>
<tr><td>Search (field, results, switches)</td><td>W-059, W-060, W-061, W-062, W-063 (not drawn)</td>
<td>Core <code>SearchQuery</code>, <code>SearchScope(wingID:)</code>, <code>searchGroups</code>, <code>SearchCounts</code>, <code>SearchTagOffer</code>; Mac-local but pure <code>LibrarySearchQuestion</code>, <code>LibrarySearchModel</code>, <code>SearchAnswerCopy</code>, <code>LibrarySearchCopy</code> — hoist owed.</td>
<td>The results list as grouped rows; the two switches.</td>
<td>Always one wing, and the screen says which. Cost follows the matches, never the library: pages, with “loading more…”. No capped list; every “all N ›” opens the rest. Commits never list without their switch. The archive foot counts places, and its door only turns the switch on. The Trash is never searched. The count line counts what is listed.</td><td>L</td></tr>
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
the two-switch row (48 pt, the system’s switch); the filter chip with ✕ (32 pt capsule in a 44 pt row); the select bar and its three-act foot (60 pt); the month grid (46 pt cells); the “loading” and “end” lines (13 pt).
Not drawn: the search order door (W-063), tag chips on rows (W-045), the Timeline (W-044).</p>
"""
write('library-and-search.html', 'VM-44 mockups — the Library and search', INTRO, sections, NOTES, check_dir=os.environ.get('SH_CHECK'))
