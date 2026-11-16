# VM-44 — home-wings-capture.html (throwaway generator; static HTML out). Revision pass: drawn to sitting-1-rulings.md.
import sys, os
sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
from base import *

N = Num()
def chipstrip_end(items, on):
    return chips(items, on, fade=False).replace('class="chips"', 'class="chips" style="justify-content:flex-end"')
ALLTAIL = ["Reading &amp; reference", "☼ Life", "Welcome", "All"]

def note(title, chipline, paras, *below, right=MORE, cls='', over=()):
    # a note never shows the bottom bar (LK-5: roots and lists, not notes)
    body = ''.join('<p>%s</p>' % p for p in paras)
    return P(nav(right), '<div class="page"><div class="ntitle">%s</div><div class="nchip">%s</div>%s</div>' % (title, chipline, body),
             *below, hi(), *over, cls=cls)

# ---------------------------------------------------------------- 1 · at rest
r_busy = P(wmast("Home"), dots(0), chipstrip_end(ALLTAIL, 3), lst(*home_all()), qe(), tabs_words(1), hi())
r_solo = home()
r_few = home(wing="Taxes 2025", chipset=["★ Starred", "Unshelved", "All"], on=1,
             rows=[brow("Receipts", "No notes yet"), '<div class="addrow">+ New book</div>'])
r_none = home(wing="Poetry", chipset=["★ Starred", "All"], on=1,
              rows=['<div class="empty">No books here yet.<small>1 note is in the Library.</small></div>',
                    '<div class="addrow" style="justify-content:center;margin-top:12px">+ New book</div>'])
s1 = [
    opt(r_busy, N(), "Home, a full wing, with All chosen.",
        "She opens the app. The wing’s name is the title; nine dots show Home is the first of nine. The Bookcase has the whole screen and scrolls as one list. "
        "The capture box is one line at the foot, with Today beside it. The bar is three words; the current one sits on a chip. "
        "Search opens the Library’s search. ⋯ holds New book, Shelves, Wings, Select, Archived, Trash, Tags and Settings."),
    opt(r_solo, N(), "The same wing, one shelf chosen.",
        "She taps the Writing chip. One shelf, four books, and New book at the end of the shelf it will land on. The rest of the flow starts here."),
    opt(r_few, N(), "A nearly empty wing.",
        "Taxes 2025 holds one book with no notes. The last dot is lit. The layout is the same however full the wing is."),
    opt(r_none, N(), "A wing with no books.",
        "Poetry has one loose note and no books. One sentence, where the note is, and the New book door."),
]

# ---------------------------------------------------------------- 2 · stepping wings
drag_mast = ('<div class="mast drag"><span class="wname" style="left:-34px;opacity:.3">Home</span><span class="wname" style="left:118px">Work</span>'
             '<div class="mbtns" style="margin-left:auto"><span class="cbtn">%s</span><span class="cbtn">%s</span></div></div>' % (I_SEARCH, I_MORE))
drag_dots = '<div class="dots"><i class="half"></i><i class="half"></i>' + '<i></i>' * 7 + '</div>'
w_drag = P(drag_mast, drag_dots, chips(HOME_CHIPS, 2).replace('class="chips fade"', 'class="chips fade" style="opacity:.38"'),
           '<div class="list dimmed">%s</div>' % ''.join(WRITING + [NEWBOOK]), qe(), tabs_words(1), hi(),
           zone(54, 80, "1"), '<div class="hand r" style="left:226px;top:60px"></div>')
w_work = home(wing="Work", chipset=WORK_CHIPS, on=3, rows=WORK_ALL)
WORKLIB = [
    nr("Spec — export subset", "today 1:02 PM", "Export only what the reader can see, and say what was left out.", "Product specs", star=True),
    nr("Weekly sync", "Nov 9", "Agenda: the release pass, who owns the importer, the Q4 list.", "Meeting notes"),
    nr("Faster cold start", "Nov 9", "Measure first. The store opens off the main thread already, so…", "Ideas inbox"),
    nr("Expense report reminder", "Nov 8", "Hotel, two dinners, the train back. Receipts are in the blue folder.", "No book"),
    nr("1:1 with D.", "Oct 15", "Wants a smaller team and a longer runway; asked about the phone app.", "Meeting notes"),
    nr("Onboarding notes", "Oct 12", "Three things nobody tells you in the first week, and one they tell you twice.", "No book"),
]
w_lib = library(wing="Work", rows=WORKLIB)
w_menu = home(wing_menu(1), wing="Work", chipset=WORK_CHIPS, on=3, rows=WORK_ALL)
s2 = [
    opt(w_drag, N(), "Swiping the title, halfway.",
        '<span class="n1">1</span> She drags the title band to the left. “Work” comes in as “Home” leaves; the dots move with it. The page underneath dims and does not slide, '
        "so this never looks like the Starred · Bookcase · Library swipe. Past halfway it settles on Work; short of it springs back."),
    opt(w_work, N(), "Settled on Work.",
        "The title, the dots, the shelf strip and the books are Work’s. Nothing is said: the title is the news. A new note from the box now lands in Work’s Pool."),
    opt(w_lib, N(), "The same swipe from the Library.",
        "On the Library the band steps wings in place: the list, the search field and the filters follow. Trash sits in the title band on the Library, as on the Mac."),
    opt(w_menu, N(), "All nine.",
        "She taps the wing’s name. Nine rows with each wing’s size, the current one ticked. A pick lands on that wing’s Bookcase. "
        "The swipe is for neighbours; this is the jump. The ⋯ at the top of the list opens wing management (next section)."),
]

# ---------------------------------------------------------------- 3 · managing wings (ruled: in full, behind a ⋯)
def wrow(name, b, n, home=False):
    return mrow(name, cls='serif', cap=wcount(b, n) + (' · can’t be renamed or deleted' if home else ''),
                trail=('' if home else RDOTS)).replace('class="mid"', 'class="mid" style="font-weight:600"').replace('class="c13"', 'class="c13" style="font-weight:400;font-family:var(--sans)"')
def wings_sheet(*extra, wings=WINGS, top=70):
    return sheet(top, shead('Wings'), '<div class="ssub">Each wing is a separate library.</div>',
                 grp(*[wrow(w, b, n, home=(i == 0)) for i, (w, b, n) in enumerate(wings)]),
                 grp(mrow("New wing…", cls='acc')), *extra)
BASEW = dict(wing="Work", chipset=WORK_CHIPS, on=3, rows=WORK_ALL)
m_sheet = home(wings_sheet(), **BASEW)
m_acts = home(wings_sheet(),
              ctx(652, [("Rename wing…", sm(I_PENCIL)), ("Move everything to another wing…", sm(I_WING)), ("Delete wing…", sm(I_TRASH), 'danger gap')], right=24, width=330),
              **BASEW)
m_new = home(sheet(318, shead("New wing", right="Make wing", left="Cancel", roff=False),
                   field("Garden", focus=True),
                   '<div class="c13b" style="margin-top:0">A wing is a separate library in the same app — a different room in the same house. Nothing crosses between wings except what you move or copy yourself.</div>',
                   kb('return'), cls='kbd'), **BASEW)
REFUSE = '<div class="msg refusal" style="margin:0 20px 8px"><span>“Poetry” still holds 1 note — move or delete them first, then the empty wing can go — or move everything to another wing.</span></div>'
m_refuse = home(sheet(70, shead('Wings'), '<div class="ssub">Each wing is a separate library.</div>', REFUSE,
                      grp(*[wrow(w, b, n, home=(i == 0)) for i, (w, b, n) in enumerate(WINGS)])), **BASEW)
def wingpick(title, sub, skip="Home"):
    return sheet(196, shead(title, right="Cancel", strong=False), '<div class="ssub">%s</div>' % sub,
                 grp(*[mrow(w, cls='serif', v=wcount(b, n)).replace('class="mid"', 'class="mid" style="font-weight:600"') for w, b, n in WINGS if w != skip]))
m_evpick = home(wingpick("Move everything to", "From Poetry", skip="Poetry"), **BASEW)
m_evconf = home(confirm(None, "Move everything in “Poetry” to “Fiction”?",
                        ["1 note moves. “Poetry” ends empty — then Delete wing… can take it."],
                        [btn("Move everything"), btn("Cancel", 'quiet')]), **BASEW)
m_del = home(confirm(None, "Delete the wing “Poetry”?", ["It’s empty. Its shelves go with it; nothing else is touched."],
                     [btn("Delete wing", 'alarm'), btn("Cancel", 'quiet')]), **BASEW)
s3 = [
    opt(m_sheet, N(), "Wings, in full.",
        "From the ⋯ at the top of the list of nine, or ⋯ ▸ Wings… on any root. One row per wing with what it holds. Each wing but Home has a ⋯. "
        "New wing… is the last row. Everything the Mac can do with a wing is here; nothing more (the Mac has no reorder, so none is drawn)."),
    opt(m_acts, N(), "A wing’s ⋯.",
        "She taps ⋯ on Poetry. Rename, move everything to another wing, delete. Rename opens the same small sheet as New wing, with the name filled in."),
    opt(m_new, N(), "New wing.",
        "A name and the Mac’s one sentence about what a wing is. “Make wing” switches to it. Nothing else is said: the new title is the news."),
    opt(m_refuse, N(), "Delete refuses while the wing holds anything.",
        "The Mac’s rule and the Mac’s sentence: it says what the wing still holds and names the way out. A refusal always shows, and stays until she acts."),
    opt(m_evpick, N(), "Move everything: pick the wing.", "The other eight, with their sizes.", small=True),
    opt(m_evconf, N(), "Move everything asks.",
        "The Mac’s question and facts: what moves, and that the wing ends empty. After it the Wings sheet shows Poetry holding nothing."),
    opt(m_del, N(), "Delete an empty wing.",
        "The Mac’s confirm. After it the row is gone and nothing is said: she has just confirmed it. If she was standing in that wing, she lands in Home."),
]

# ---------------------------------------------------------------- 4 · the app follows a note (SW-2, ruled: the Mac's rule)
f_tap = home(zone2(721, 62, 292, 12, "1", 't'), wing="Work", chipset=WORK_CHIPS, on=3, rows=WORK_ALL)
JTXT = ["Slept badly. The heron was back on the jetty before seven, standing like a question mark.",
        "Second entry, later. The ferry timetable changes in December; wrote it down twice."]
f_open = note("Thursday 12 November", "<b>Journal</b> · in Home · today", JTXT)
f_back = home()
s4 = [
    opt(f_tap, N(), "In Work, she taps Today.",
        '<span class="n1">1</span> Today opens today’s first journal entry. The Journal lives in Home, and she is standing in Work.'),
    opt(f_open, N(), "The entry opens, and the app follows it.",
        "The entry opens in Write. The app’s one wing follows the note she is in. No line is shown for it; the note’s own facts say “in Home”. "
        "No bottom bar: the bar shows on roots and lists, never inside a note."),
    opt(f_back, N(), "Back.", "Back lands on Home’s Bookcase: the app has one wing and it followed the note. The title says where she is.", small=True),
]

# ---------------------------------------------------------------- 5 · capture
def cap(foot, rows=None, over=(), wing="Home", cls=''):
    return home(*over, wing=wing, rows=rows, foot=foot, bar=False, cls=cls)
EMPTYBOX = '<div class="qe"><div class="qebox"><span class="caret" style="margin:0 2px 0 0"></span>New note</div></div>'
ONE = ["Walk note: the ferry timetable changes in December"]
MANY = ["Walk note: the ferry timetable changes in December, and the morning boat now leaves at seven forty.",
        "Tell M. before Friday. Ask at the kiosk whether the winter pass covers the early boat.",
        "Also: the kiosk man says the heron has been there every morning since October.",
        "He calls it the harbour master"]
FILED = rcpt("Filed in the Pool.", "Open ›")
c_focus = cap(EMPTYBOX + qact(on=False) + kb('return'))
c_one = cap(qe_typed(ONE) + qact() + kb('return'))
c_many = cap(qe_typed(MANY, cap=True) + qact() + kb('return'))
c_away = cap(qe_typed(ONE) + qact() + kb('return'),
             over=('<div class="zone b" style="top:150px;height:262px"><span>2</span></div>',
                   '<div class="hand d" style="left:180px;top:428px"></div>', zone2(424, 64, 12, 12, "1", 't')))
c_kept = home(foot=qe_typed(ONE, caret=False, today=True))
c_filed = cap(FILED + EMPTYBOX + qact(on=False) + kb('return'))
c_open = P(nav(MORE), '<div class="page"><div class="nchip" style="margin-top:0"><b>No book</b> · in Home · today</div><p>Walk note: the ferry timetable changes in December<span class="caret"></span></p></div>', kb('return'))
MS = ['Flour, water, salt, patience. The last one is the only ingredient that is not sold. <span class="tok">{#recipe}</span> <span class="tok">{t:"Bread, as a poem"}</span>']
c_ms = cap(qe_typed(MS) + qact() + kb('return'))
c_msf = cap(rcpt("Filed in “Recipes”.", "Open ›") + EMPTYBOX + qact(on=False) + kb('return'))
c_ref = cap(rcpt("The note wasn’t created. The store couldn’t take it just now. Your text is still here — try again in a moment.", refusal=True, x=True)
            + qe_typed(ONE) + qact() + kb('return'))
s5 = [
    opt(c_focus, N(), "She taps the box.",
        "The keyboard comes up and the bar leaves. The box stays one line. Under it, with no band behind them: the two helper keys on the left, Open and File on the right, greyed until there are words. "
        "Today steps aside while she types so the box has the full width."),
    opt(c_one, N(), "A short note.",
        "The box is as tall as the words. File is the filled button, under the thumb: it saves the note and clears the box. Open saves it and opens it. Return is only ever a new line."),
    opt(c_many, N(), "Several paragraphs.",
        "Return made each paragraph. The box grows to about eight lines, then scrolls inside itself; the Bookcase keeps a row. The note is saved as she types."),
    opt(c_away, N(), "Putting the keyboard away.",
        '<span class="n1">1</span> She swipes down on the box, or <span class="n2">2</span> taps anywhere on the Bookcase above it. The keyboard goes down. Nothing is filed and she goes nowhere. '
        "(Today the only ways out are filing or leaving the screen.)"),
    opt(c_kept, N(), "Her words are still in the box.",
        "The keyboard is down, the bar and Today are back, and what she typed is kept. Tapping the box brings the keyboard and the two buttons back, with the caret at the end."),
    opt(c_filed, N(), "She taps File.",
        "The box clears and the keyboard stays for the next note. One short line: “Filed in the Pool.” with Open ›, the Mac’s words. "
        "This is the one line kept for an ordinary act, because the note has just gone somewhere she cannot see from the Bookcase. It leaves by itself."),
    opt(c_open, N(), "She taps Open instead.",
        "The note opens with the keyboard still up and the caret at the end of what she typed. No line: she is looking at the note. Back returns to the Bookcase with an empty box."),
    opt(c_ms, N(), "A tag and a title, with the helper keys.",
        "“#tag” types {#} and “title” types {t:\"\"}, each with the caret inside. The Mac’s box reads these two marks when a note files; the keys save three keyboard pages of hunting for braces."),
    opt(c_msf, N(), "Filed with a tag and a title.",
        "The note is titled “Bread, as a poem” and wears #recipe; the braces are gone from its text. The book Recipes collects that tag, so the line names the book — the Mac’s rule."),
    opt(c_ref, N(), "A filing that fails.",
        "The line says so in the Mac’s words and stays until she closes it. Her text is still in the box. A refusal always shows."),
]

# ---------------------------------------------------------------- 6 · the lock button, and coming back (Castle only)
k_home = home('<div class="zone" style="top:57px;height:54px;left:204px;right:112px"><span style="right:auto;left:5px;bottom:14px">1</span></div>', lock=True)
k_bar = P(wmast("Home"), dots(0), chips(HOME_CHIPS, 2), lst(*WRITING, NEWBOOK), qe(), tabs_lock(1), hi())
BACKCARD = bcard("Back to where you were", "On keeping a commonplace book")
k_back = home(lock=True, band=BACKCARD)
k_note = note("On keeping a commonplace book", "<b>Essays</b> · in Home · #essay",
              ["I started copying sentences into a notebook the winter I stopped trusting my memory for them.",
               "It was not a diary. A diary asks what happened; a commonplace book asks what was worth keeping, which is a harder and kinder question.",
               "The first winter I filled forty pages and reread none of them."])
s6 = [
    opt(k_home, N(), "The lock button, under Castle.",
        '<span class="n1">1</span> A lock sits first among the round buttons at the top of the home screen. One tap locks the library at once; what she was typing is saved first. '
        "It is drawn only when the library is under Castle, so most frames in this file do not show it. The Protection section in Settings keeps its own Lock library now row.", mine=True),
    opt(k_bar, "LP-5 · the other spot", "The same button at the end of the bottom bar.",
        "Her words left the spot open: “at the top of the homescreen or in the bottom bar or something”. Here it is the bar’s last cell, so it also shows on lists. The top is drawn everywhere else.", small=True),
    opt(k_back, N(), "After an unlock: home, with a way back.",
        "She unlocks and lands on the home screen. If she was somewhere else when it locked, one quiet card sits in the band above the capture box, naming the note. "
        "A tap goes back there; ✕ puts the card away. It also goes once she opens anything or files a note. The first line is a draft for her wording pass."),
    opt(k_note, N(), "She taps the card.", "The note, at the block she was in. No bar, as in every note.", small=True),
]

# ---------------------------------------------------------------- 7 · Starred, the ⋯ menu, moving across wings
STAR_ROWS = [sec("Books", "2"), brow("Journal", "13 entries · daily journal", STAR), brow("Essays", "8 notes · #essay #goals", STAR),
             sec("Notes", "2"), nr("On keeping a commonplace book", "today 1:02 PM", "I started copying sentences into a notebook the winter I stopped trusting my memory for them.", "Essays", star=True),
             nr("Grocery list", "Nov 10", "Oat milk, lemons, the good butter, stamps, something for the neighbour with the piano.", "No book", star=True)]
st_home = P(wmast("Home"), dots(0), lst(*STAR_ROWS), tabs_words(0), hi())
st_empty = P(wmast("Poetry"), dots(7), lst('<div class="empty">Nothing starred in Poetry.<small>Swipe a row right to star it.</small></div>'), tabs_words(0), hi())
m_more = home(SCRIM, ctx(104, [("New book…", sm(I_BOOK)), ("Shelves…", sm(I_SHELF)), ("Wings…", sm(I_WING)), ("Select…", sm(I_SELECT), 'gap'),
                               ("Archived", sm(I_ARCH), 'gap'), ("Trash", sm(I_TRASH)), ("Tags", sm(I_TAG)), ("Settings", sm(I_GEAR), 'gap')]))
LIFEBASE = lambda *over, rows=None, foot=None: P(wmast("Home"), dots(0), chipstrip_end(ALLTAIL, 1),
                                                 lst(*(LIFE + ['<div class="addrow">+ New book on Life</div>'] if rows is None else rows)),
                                                 foot or '', qe(), tabs_words(1), hi(), *over)
m_pick = LIFEBASE(wingpick("Move to a wing", "“Recipes” is in Home"))
m_conf = LIFEBASE(confirm(None, "Move “Recipes” to “Family”?", ["Its 5 notes come with it, tags and all. It arrives unshelved."], [btn("Move"), btn("Cancel", 'quiet')]))
m_done = LIFEBASE(rows=[LIFE[0], LIFE[2], '<div class="addrow">+ New book on Life</div>'], foot=rcpt("Moved “Recipes” to “Family” with its 5 notes."))
m_nconf = library(confirm(None, "Move “On keeping a commonplace book” to “Work”?",
                          ["It leaves “Essays” — a wing is a separate library, and a book only holds notes of its own wing. Its tags come with it."],
                          [btn("Move"), btn("Cancel", 'quiet')]))
m_copy = library(foot=rcpt("Copied “Grocery list” to “Family” — a separate library; the copy waits in its Pool.") + qe(today=False))
s7 = [
    opt(st_home, N(), "Starred is a root, inside the wing.",
        "She taps Starred (or swipes the page right). Home’s starred books and notes, in two short sections, with the same rows as everywhere else. Swipe a row to unstar."),
    opt(st_empty, N(), "Starred with nothing in it.", "One sentence, naming the wing, and how to star.", small=True),
    opt(m_more, N(), "The ⋯ menu, on every root.",
        "New book; then Shelves… and Wings…, which open the two management sheets (shelves are drawn in a-book.html); Select; the three rooms; Settings. Each is one tap from any root."),
    opt(m_pick, N(), "Move a book to another wing: pick the wing.",
        "From Move to wing in the book’s menu (a-book.html). The Mac’s prompt, and where the book is now. A note’s menu opens the same sheet for Move to wing… and Copy to wing…"),
    opt(m_conf, N(), "The confirm, for a book.",
        "The Mac’s question and facts: what comes with it and where it arrives."),
    opt(m_done, N(), "After the move.",
        "The book has left this wing. One line says where it went, in the Mac’s words. It is kept because something left the page. There is no Undo on it: the Mac has none for a move between wings."),
    opt(m_nconf, N(), "The confirm, for a note.",
        "The same road from a note’s row in the Library. The Mac names the books the note will leave. After it the row leaves and the Mac’s line shows, as for a book."),
    opt(m_copy, N(), "After a copy to another wing.",
        "The note stays; the copy is in a wing she cannot see from here, so the Mac’s line is kept, for the same reason as the filed line.", small=True),
]

# ---------------------------------------------------------------- 8 · the largest text, dark
x_xl = P(wmast("Home"), dots(0), chips(HOME_CHIPS, 2), lst(*WRITING[:4], NEWBOOK), qe(), tabs_words(1), hi(), cls='xl')
x_xlcap = P(wmast("Home"), dots(0), chips(HOME_CHIPS, 2), lst(*WRITING[:2]),
            '<div class="qe"><div class="qebox typed">Walk note: the ferry timetable changes in December<span class="caret"></span></div></div>',
            '<div class="qact" style="height:52px"><span class="mkey">#tag</span><span class="mkey">title</span><span class="sp"></span><span class="pill" style="height:52px;border-radius:26px">Open</span><span class="pill fill" style="height:52px;border-radius:26px">File</span></div>',
            kb('return'), cls='xl')
x_dk = P(wmast("Home", lock=True), dots(0), chips(HOME_CHIPS, 2), lst(*WRITING, NEWBOOK), BACKCARD, qe(), tabs_words(1), hi(), cls='dk')
x_dkcap = home(wing="Home", foot=qe_typed(["Ask the kiosk about the winter pass"]) + qact() + kb('return'), bar=False, cls='dk')
x_dkmenu = home(wing_menu(1), wing="Work", chipset=WORK_CHIPS, on=3, rows=WORK_ALL, cls='dk')
s8 = [
    opt(x_xl, N(), "Home at the largest text size.",
        "The system’s largest standard size. Names, counts, chips, the box and the bar all grow; the three bar words still fit, and the shelf strip scrolls."),
    opt(x_xlcap, N(), "Capture at the largest text size.", "Her words are 23 pt in the box. The keys and buttons grow with their labels; the Bookcase gives up rows first."),
    opt(x_dk, N(), "Home, dark, under Castle.", "The room is black and the paper carries the sea-glass hue, as on the Mac. The lock button and the way-back card are drawn here too."),
    opt(x_dkcap, N(), "Capture, dark.", ""),
    opt(x_dkmenu, N(), "The nine wings, dark.", "", small=True),
]

INTRO = """
<p class="lede"><b>VM-44 mockups — the home screen, wings and capture.</b> Revised after the first sitting: every frame follows <code>plans/sitting-1-rulings.md</code>.
Today the phone shows every wing at once, has no way to change wing, and its capture box is a 34 pt dashed outline whose Return key opens the note and can lose words.</p>
<p class="q">“On the wing title (left)” · “Bookcase gets the screen” · “New line; File and Open buttons” · “Words on a chip” · Today: “Keep it” · “Follow the note” · “Keep the helper keys” ·
“Roots and lists, not notes” · “#9 seemed like a fine approach - it can be hidden behind 3 dots” · “there should be a lock icon at the top of the homescreen or in the bottom bar or something”</p>
<p class="lede"><b>What was chosen, in one line each.</b> Wings: swipe the title, tap it for the list. Wing management: in full, behind a ⋯. A note from another wing: the app follows it. Capture marks: the two helper keys.
A quick note lands in the current wing’s Pool. The bar: on roots and lists, never inside a note. Lines: none for ordinary acts; a short line only when something leaves the page, for a refusal,
and for a note filed or copied somewhere she cannot see. One spot is still open and drawn both ways: where the lock button sits.</p>
"""
sections = [
    ("1 · The home screen at rest", '<p class="lede">The wing band, the shelf strip, the Bookcase, the capture box with Today, the bar.</p>', s1),
    ("2 · Stepping between wings", '<p class="lede">Swipe the title for the next wing; tap it for all nine. The page swipe below stays Starred · Bookcase · Library.</p>', s2),
    ("3 · Managing wings", '<p class="lede">Make, rename, delete and move a wing’s contents — what the Mac does, behind a ⋯, because some people will only use the phone.</p>', s3),
    ("4 · When a note belongs to another wing", '<p class="lede">The Mac’s rule: opening a note from another wing carries the app’s wing with it.</p>', s4),
    ("5 · The capture box", '<p class="lede">File is the common path and the fast one. Open is the deliberate one. The keyboard can be put away without either.</p>', s5),
    ("6 · The lock button, and coming back", '<p class="lede">Under Castle only. A Standard library never locks, so it shows neither.</p>', s6),
    ("7 · Starred, the ⋯ menu, and moving across wings", '<p class="lede">The Mac’s Move to wing and Copy to wing.</p>', s7),
    ("8 · The largest text size, and dark", '', s8),
]
NOTES = """
<div class="pick" style="max-width:1500px"><h2>Still open here</h2>
<p><b>Where the lock button sits (LP-5).</b> Drawn at the top of the home screen, first among the round buttons; the bottom-bar spot is the small frame beside it. Also open with it: whether Starred and the Library carry
the button too. It is drawn on the Bookcase only, because her words name the home screen.</p>
<p><b>The words on the way-back card</b> (“Back to where you were”) and every other drafted line are in <code>design/wording-list-1.md</code>.</p>
<p><b>Two lines kept beyond removals and refusals:</b> “Filed in …” after File, and the Mac’s line after a copy to another wing. Both name something that went where she cannot see it. Cut either and nothing else changes.</p></div>

<h2>Build notes</h2>
<table class="bn">
<tr><th>Screen</th><th>Work-list rows it delivers</th><th>Shared brain it stands on</th><th>What is new</th><th>Must not get wrong</th><th>Size</th></tr>
<tr><td>The wing band (title, dots, swipe)</td><td>W-015, W-018, W-019, W-033, W-007 (the bar)</td>
<td>Shared <code>WingState</code> (current wing, memory, revalidate; <code>readScope</code> must return the wing on iOS), Core <code>Queries.wings</code>. Hoist owed: <code>WingSwitcherBrain.next(after:in:)</code>, <code>WingsModel</code>.</td>
<td>The band as a drag target; the dots; the dimmed page while dragging.</td>
<td>The drag belongs to the band only (about 80 pt tall); the page’s own swipe must not start there, and the band’s must not start on the page. The page re-reads once, when the drag settles, never per frame. A wing deleted on another device returns her to Home. Every listing and every new note, book and tag follows the wing. From the Library the step is in place; it never jumps to the Bookcase. The bar shows on the three roots and on every pushed list; never inside a note.</td><td>M</td></tr>
<tr><td>The list of nine</td><td>W-017</td>
<td>Core <code>Queries.wings</code>, <code>wingContents</code>; hoist owed: <code>WingsModel</code>, <code>WingCopy</code>.</td>
<td>A menu anchored under the title, 52 pt rows with sizes, a ⋯ at its head.</td>
<td>A pick lands on that wing’s Bookcase, the current wing included. Sizes are read when the menu opens, not held. It scrolls past about eleven wings. With one wing it still opens, so the ⋯ is reachable.</td><td>S</td></tr>
<tr><td>Wings: the sheet, New wing, rename, move everything, delete</td><td>W-021, W-016</td>
<td>Core <code>createWing</code>, <code>renameWing</code>, <code>deleteWing</code>, <code>moveWingContents</code>; Shared <code>WingWords.lesson</code>, <code>notEmpty</code>; hoist owed: <code>WingCopy</code>’s <code>deleteTitle</code>, <code>deleteMessage</code>, <code>everythingTitle</code>, <code>everythingMessage</code>.</td>
<td>The sheet with a ⋯ per wing; two doors to it (the list’s ⋯, and ⋯ ▸ Wings… on a root).</td>
<td>Delete refuses unless the wing is empty and names what is left. Home has no rename and no delete. Move everything’s facts come from the same read as the act. No reorder: the Mac has none. Deleting the wing she stands in lands her in Home.</td><td>M</td></tr>
<tr><td>The app follows a note</td><td>W-019, W-020</td>
<td>Core <code>effectiveWing(ofPost:)</code>; hoist owed: <code>WingFollow</code>.</td>
<td>—</td>
<td>A follow never lands on a Bookcase and never closes a note. No line is shown for it; the note’s facts name the wing. Today already opens the Journal’s wing in Core; the phone must follow it rather than mint in the current wing. Back lands on the followed wing’s Bookcase.</td><td>S</td></tr>
<tr><td>The capture box: focus, grow, File, Open</td><td>W-022, W-023, W-024, W-027, W-034, and the lag rows from audit F (2A, 2B, 2F, 1B)</td>
<td>Core <code>importPost(wingId:)</code>; the phone’s own <code>MobileQuickNote</code> model (mint after a second, autosave, file on leaving); hoist owed: <code>QuickEntryFileCopy</code> (“File”, “Filed in …”, “Open ›”), <code>CaptureLanding</code>.</td>
<td>A soft-keyboard rule (Return is a newline, two buttons file); the box growing by lines to a cap; the filed line with its door.</td>
<td>File must not build the note screen at all: save, clear, keep the keyboard, show the line. Open must keep the keyboard up across the push (no down-then-up) and put the caret at the end of her text. One filing per press. A quick note lands in the current wing’s Pool unless a book collects its tag. The box’s height never changes the Bookcase’s layout rule, only how many rows show. The bar leaves while the keyboard is up.</td><td>M</td></tr>
<tr><td>Putting the keyboard away</td><td>new — her report at the trace (no W row yet; it belongs with W-022)</td>
<td>The phone’s own <code>MobileQuickNote</code>.</td>
<td>Swipe down on the box, or tap the Bookcase above it; the box at rest showing a kept draft.</td>
<td>Putting the keyboard away never files and never navigates. The draft stays in the box, saved, until she files it, opens it or clears it. Leaving the screen or the app still files what is in the box, as today.</td><td>S</td></tr>
<tr><td>Capture marks</td><td>W-025</td>
<td>Shared <code>CaptureMicrosyntax</code>, <code>TypedTagPath</code>.</td>
<td>The two helper keys.</td>
<td>Only braced forms parse; the tags are found or made in the current wing, never another wing’s; the line names a book only when a book really seated the note.</td><td>S</td></tr>
<tr><td>Refusal on filing</td><td>W-012, W-013</td>
<td>Hoist owed: <code>QuickEntryCopy.refusal</code>; Shared <code>OpsRefusalTable</code>.</td><td>—</td>
<td>Her text stays in the box. Never a raw error.</td><td>S</td></tr>
<tr><td>The lock button</td><td>W-189</td>
<td>Shared <code>RoadCrossingsModel.lockNow</code> → <code>AppBootstrap.lock()</code>; <code>ProtectionCopy.lockNowLabel</code> as its spoken label.</td>
<td>A round button in the home screen’s title band.</td>
<td>Drawn only under Castle. Pending typing lands before the lock. One tap, no confirm, as on the Mac. The spot (top or bar) is hers to settle.</td><td>S</td></tr>
<tr><td>After an unlock: home, and the way-back card</td><td>W-191</td>
<td>New: a small “where she was” record kept across a relock (the route and block, never text).</td>
<td>The card in the band above the capture box.</td>
<td>An unlock always lands on the home screen. The card shows only when she was somewhere else; it names the note by its title, opens it at her block, and leaves on a tap, on ✕, or once she opens or files anything. One card in the band at a time (FR-1’s band). If the note was deleted meanwhile, no card.</td><td>M</td></tr>
<tr><td>Starred as a root</td><td>W-054, W-033</td>
<td>Core <code>Queries.starred(db, wingID:)</code>; hoist owed: <code>SidebarRowLeads</code> for untitled rows.</td>
<td>Two sections; the shared note and book rows.</td>
<td>Per wing. Untitled notes lead with their first words, never a date.</td><td>M</td></tr>
<tr><td>The ⋯ menu on a root</td><td>W-008, W-050, W-010, the doors to W-021 and W-069</td><td>—</td><td>One menu on all three roots.</td>
<td>Archived, Trash, Tags and Settings are one tap from every root.</td><td>S</td></tr>
<tr><td>Move or copy to a wing</td><td>W-036, W-100, W-048</td>
<td>Core <code>moveNoteToWing</code>, <code>copyNoteToWing</code>, <code>moveReadingToWing</code>; hoist owed: <code>WingDestinationSheet</code>’s rule, <code>WingCopy</code> and <code>WingBookMoves</code>’ confirm sentences.</td>
<td>The picker sheet; the confirm as a sheet.</td>
<td>The confirm’s facts come from the same read as the act (books left behind, notes that come along, a same-name twin). A note in a finished book refuses with the Mac’s sentence. Offered only while a second wing exists. No Undo on the line.</td><td>M</td></tr>
<tr><td>Largest text, dark</td><td>W-001, W-002, W-004, W-005</td><td>The phone type layer over <code>VoiceTokens</code>; <code>PaletteDerivation</code>.</td><td>—</td>
<td>Chrome grows to the largest standard size and holds; her words keep growing. The bar’s three words must fit at that size.</td><td>—</td></tr>
</table>
<p class="note-ann"><b>Added to the sizing sheet’s vocabulary</b> (in its spirit): the wing band’s nine dots (7 pt, not a target; the band is); the Today button at the box’s height (48 pt);
the row under a focused box (two 32 pt helper keys in 44 pt hit areas, then two 44 pt buttons, no band behind them); the band card above the capture box (60 pt, paper, one line of chrome and one of her words, a 44 pt ✕);
a third round button in the title band (the lock); the press-and-hold menu; the “open” tag (annotation only).</p>
"""
write('home-wings-capture.html', 'VM-44 mockups — the home screen, wings and capture', INTRO, sections, NOTES, check_dir=os.environ.get('SH_CHECK'))
