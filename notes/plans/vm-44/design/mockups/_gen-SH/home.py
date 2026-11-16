# VM-44 — home-wings-capture.html (throwaway generator; static HTML out).
import sys, os
sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
from base import *

Q = lambda s: '“%s”' % s
def chipstrip_end(items, on):
    return chips(items, on, fade=False).replace('class="chips"', 'class="chips" style="justify-content:flex-end"')
ALLTAIL = ["Reading &amp; reference", "☼ Life", "Welcome", "All"]

def note(title, chipline, paras, *below, right=MORE, bar=True, tab=1, cls='', over=()):
    body = ''.join('<p>%s</p>' % p for p in paras)
    return P(nav(right), '<div class="page"><div class="ntitle">%s</div><div class="nchip">%s</div>%s</div>' % (title, chipline, body),
             *below, tabs_words(tab) if bar else '', hi() if bar else '', *over, cls=cls)

# ---------------------------------------------------------------- 1 · at rest
r_busy = P(wmast("Home"), dots(0), chipstrip_end(ALLTAIL, 3), lst(*home_all()), qe(), tabs_words(1), hi())
r_solo = home()
r_few = home(wing="Taxes 2025", chipset=["★ Starred", "Unshelved", "All"], on=1,
             rows=[brow("Receipts", "No notes yet"), '<div class="addrow">+ New book</div>'])
r_none = home(wing="Poetry", chipset=["★ Starred", "All"], on=1,
              rows=['<div class="empty">No books in Poetry yet.<small>Its one note is in the Library.</small></div>',
                    '<div class="addrow" style="justify-content:center;margin-top:12px">+ New book</div>'])
s1 = [
    opt(r_busy, "1", "Home, a busy wing, with All chosen.",
        "She opens the app. The wing’s name is the title; nine dots show Home is the first of nine. The Bookcase has the whole screen and scrolls as one list. "
        "The capture box is one line at the foot, with Today beside it. The bar is three words; the current one sits on a chip. "
        "Search opens the Library’s search. ⋯ holds New book, New shelf, Archived, Trash, Tags and Settings."),
    opt(r_solo, "2", "The same wing, one shelf chosen.",
        "She taps the Writing chip. One shelf, four books, and New book at the end of the shelf it will land on. This is the frame the rest of the flow starts from. "
        "The shelf chips are BK-1 (a), still open; swapping in another shelf shape changes only this strip."),
    opt(r_few, "3", "A nearly empty wing.",
        "Taxes 2025 holds one book with no notes. The last dot is lit. The layout does not change with how full the wing is: same title, same strip, same box at the foot."),
    opt(r_none, "4", "A wing with no books.",
        "Poetry has one loose note and no books. One true sentence, where the note is, and the New book door. The capture box works as everywhere."),
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
GRIP = '<span style="color:var(--faint);font:400 20px var(--sans);flex:none;width:28px;text-align:center">≡</span>'
MOREA = '<span style="color:var(--accent);flex:none;width:44px;height:44px;display:flex;align-items:center;justify-content:center;margin-right:-10px">%s</span>' % I_MORE
def wrow(name, b, n, home=False):
    return mrow(name, cls='serif', cap=wcount(b, n) + (' · always first, cannot be renamed or deleted' if home else ''),
                trail=('' if home else MOREA) + GRIP).replace('class="mid"', 'class="mid" style="font-weight:600"').replace('class="c13"', 'class="c13" style="font-weight:400;font-family:var(--sans)"')
w_manage = home(sheet(70, shead('Wings<span class="opn">open</span>'),
                      '<div class="ssub">Each wing is a separate library.</div>',
                      grp(*[wrow(w, b, n, home=(i == 0)) for i, (w, b, n) in enumerate(WINGS)]),
                      grp(mrow("New wing…", cls='acc'))),
                wing="Work", chipset=WORK_CHIPS, on=3, rows=WORK_ALL)
w_rowmenu = home(sheet(70, shead('Wings<span class="opn">open</span>'),
                       '<div class="ssub">Each wing is a separate library.</div>',
                       grp(*[wrow(w, b, n, home=(i == 0)) for i, (w, b, n) in enumerate(WINGS)]),
                       grp(mrow("New wing…", cls='acc'))),
                 ctx(652, [("Rename wing…", sm(I_PENCIL)), ("Move everything to another wing…", sm(I_WING)), ("Delete wing…", sm(I_TRASH), 'danger gap')], right=24, width=330),
                 wing="Work", chipset=WORK_CHIPS, on=3, rows=WORK_ALL)
w_new = home(sheet(318, shead("New wing", right="Make wing", left="Cancel", roff=False),
                   field("Garden", focus=True),
                   '<div class="c13b" style="margin-top:0">A wing is a separate library in the same app — a different room in the same house. Nothing crosses between wings except what you move or copy yourself.</div>',
                   kb('return'), cls='kbd'),
             wing="Work", chipset=WORK_CHIPS, on=3, rows=WORK_ALL)
s2 = [
    opt(w_drag, "5", "Swiping the title, halfway.",
        '<span class="n1">1</span> She drags the title band to the left. “Work” comes in as “Home” leaves; the dots move with it. The page underneath dims and does not slide, '
        "so this never looks like the Starred · Bookcase · Library swipe. Letting go past halfway settles on Work; short of it springs back."),
    opt(w_work, "6", "Settled on Work.",
        "The title, the dots, the shelf strip and the books are Work’s. Nothing else is said: the title is the news. A new note from the box now lands in Work. "
        "Swiping the page still goes Starred · Bookcase · Library, inside Work."),
    opt(w_lib, "7", "The same swipe from the Library.",
        "On the Library the band steps wings in place: the list, the search field (“Search Work”) and the filters re-scope under her. This is the Mac’s Library rule. "
        "Trash sits in the title band on the Library, as on the Mac."),
    opt(w_menu, "8", "The list of all nine.",
        "She taps the wing’s name. Nine rows with each wing’s size, the current one ticked; uneven sizes read at a glance. A pick lands on that wing’s Bookcase (the Mac’s rule for a deliberate switch). "
        "The swipe is for neighbours; this is the jump. The two rows at the foot are open: whether the phone makes and manages wings is not ruled."),
    opt(w_manage, "9", "Manage wings, if the phone gets it.",
        "From “Manage wings…”. One row per wing with what it holds. ≡ drags to reorder (the Mac has no reorder door today, so this half is doubly open). ⋯ opens the row’s acts. Home has neither."),
    opt(w_rowmenu, "10", "A wing’s acts.",
        "She taps ⋯ on Poetry. Rename, move everything to another wing, delete. Delete on a wing that still holds things refuses in the Mac’s words: "
        "“Poetry” still holds 1 note — move or delete them first, then the empty wing can go — or move everything to another wing."),
    opt(w_new, "11", "New wing.",
        "From “New wing…”. A name and the Mac’s one sentence about what a wing is. “Make wing” switches to it; the new title is the receipt."),
]

# ---------------------------------------------------------------- 3 · the app follows a note
f_tap = home(zone2(721, 62, 292, 12, "1", 't'), wing="Work", chipset=WORK_CHIPS, on=3, rows=WORK_ALL)
JTXT = ["Slept badly. The heron was back on the jetty before seven, standing like a question mark.",
        "Second entry, later. The ferry timetable changes in December; wrote it down twice."]
f_open = note("Thursday 12 November", "<b>Journal</b> · in Home · today", JTXT, rcpt("Now in Home."))
f_backA = home()
f_backB = home(wing="Work", chipset=WORK_CHIPS, on=3, rows=WORK_ALL)
f_tab = note("On keeping a commonplace book", "<b>Essays</b> · in Home · #essay",
             ["I started copying sentences into a notebook the winter I stopped trusting my memory for them.",
              "It was not a diary. A diary asks what happened; a commonplace book asks what was worth keeping, which is a harder and kinder question."],
             rcpt("Now in Home."), tab=2)
s3 = [
    opt(f_tap, "12", "In Work, she taps Today.",
        '<span class="n1">1</span> Today opens today’s journal entry. The Journal lives in Home, and she is standing in Work.'),
    opt(f_open, "13", "The entry opens, and the app follows it.",
        "The entry opens in Write. The app’s one wing follows the note she is in, so the line at the foot says “Now in Home.” — the Mac’s words. "
        "It is kept because she did not ask for the switch and cannot see it from inside a note. It leaves by itself."),
    opt(f_backA, "SW-2 (i)", "Back, the Mac’s way.", "Back lands on Home’s Bookcase: the app has one wing and it followed the note. The Mac’s rule, read plainly.", mine=True, small=True),
    opt(f_backB, "SW-2 (ii)", "Back, the other way.", "Back returns her to Work, where she was. Kinder to a quick journal visit; needs the phone to remember the wing she left, which the Mac does not do.", small=True),
    opt(f_tab, "14", "A note left open in another tab.",
        "A Home note was open on the Library tab. She tapped Bookcase, stepped to Work, then tapped Library again. The note is still there, untouched, and the app follows it: “Now in Home.” "
        "Stepping wings never closes her work. This case exists only if the bar shows on pushed screens (W-007); if it stays on roots only, a switch can only start from a root."),
]

# ---------------------------------------------------------------- 4 · capture
def cap(foot, rows=None, over=(), wing="Home", cls=''):
    return home(*over, wing=wing, rows=rows, foot=foot, bar=False, cls=cls)
EMPTYBOX = '<div class="qe"><div class="qebox"><span class="caret" style="margin:0 2px 0 0"></span>New note</div></div>'
ONE = ["Walk note: the ferry timetable changes in December"]
MANY = ["Walk note: the ferry timetable changes in December, and the morning boat now leaves at seven forty.",
        "Tell M. before Friday. Ask at the kiosk whether the winter pass covers the early boat.",
        "Also: the kiosk man says the heron has been there every morning since October.",
        "He calls it the harbour master"]
c_focus = cap(EMPTYBOX + qact("Home", on=False) + kb('return'))
c_one = cap(qe_typed(ONE) + qact("Home") + kb('return'))
c_many = cap(qe_typed(MANY, cap=True) + qact("Home") + kb('return'))
c_filed = cap(rcpt("Filed in the Pool.", "Open ›") + EMPTYBOX + qact("Home", on=False) + kb('return'))
c_rest = home(foot=rcpt("Filed in the Pool.", "Open ›") + qe())
c_open = P(nav(MORE), '<div class="page"><div class="nchip" style="margin-top:0"><b>No book</b> · in Home · today</div><p>Walk note: the ferry timetable changes in December<span class="caret"></span></p></div>', kb('return'))
MS = ['Flour, water, salt, patience. The last one is the only ingredient that is not sold. <span class="tok">{#recipe}</span> <span class="tok">{t:"Bread, as a poem"}</span>']
c_ms1 = cap(qe_typed(MS) + qact("Home") + kb('return'))
c_ms2 = cap(qe_typed(MS) + qact("Home", keys=True) + kb('return'))
c_msf = cap(rcpt("Filed in “Recipes”.", "Open ›") + EMPTYBOX + qact("Home", on=False) + kb('return'))
c_ref = cap(rcpt("The note wasn’t created. The store couldn’t take it just now. Your text is still here — try again in a moment.", refusal=True, x=True)
            + qe_typed(ONE) + qact("Home") + kb('return'))
s4 = [
    opt(c_focus, "15", "She taps the box.",
        "The keyboard comes up and the bar leaves. The box stays one line. Under it, with no band behind them: “in Home” says where the note will land, then Open and File, greyed until there are words. "
        "Today steps aside while she types so the box has the full width."),
    opt(c_one, "16", "A short note.",
        "The box is as tall as the words. File is the filled button, under the thumb: it saves the note and clears the box. Open saves it and opens it in the note. Return is only ever a new line."),
    opt(c_many, "17", "Several paragraphs.",
        "Return made each paragraph. The box grows to about eight lines, then scrolls inside itself; the Bookcase keeps a row. Nothing here can lose words: the note is saved as she types, and neither button depends on Return."),
    opt(c_filed, "18", "She taps File.",
        "The box clears and the keyboard stays for the next note. One quiet line says where it went, with the Mac’s words and its door: “Filed in the Pool.” Open ›. "
        "This line is kept because she cannot otherwise see the note she just filed. It leaves by itself; the note is then the first row of the Library."),
    opt(c_rest, "19", "The same line with the keyboard down.",
        "The line sits above the box and never over it, on the room, not on the list. Tapping Open › opens that note. Filing never loads the note’s screen, so it is the fast path."),
    opt(c_open, "20", "She taps Open instead.",
        "The note opens with the keyboard still up and the caret at the end of what she typed, so she can keep going. No line: she is looking at the note. Back returns to the Bookcase with an empty box."),
    opt(c_ms1, "W-025 (i)", "Tags and a title, typed.", "The Mac’s box reads {#tag/path} and {t:\"…\"} when a note files, and the contract leaves the phone’s face to this effort. (i) is the Mac’s rule and nothing more: she types the braces. They are three keyboard pages deep on a phone.", small=True),
    opt(c_ms2, "W-025 (ii)", "The same, with two keys.", "Two small keys beside the buttons put the braces in for her: “#tag” types {#} and “title” types {t:\"\"} with the caret inside. Nothing new to learn or store; only fewer taps.", mine=True, small=True),
    opt(c_msf, "21", "Filed with a tag and a title.",
        "She taps File. The note is titled “Bread, as a poem” and wears #recipe; the braces are gone from its text. Because the book Recipes collects that tag, the line names the book — the Mac’s rule for where a filed note landed."),
    opt(c_ref, "22", "A filing that fails.",
        "If the store cannot take the note, the line says so in the Mac’s words and stays until she closes it. Her text is still in the box. A refusal always shows."),
]

# ---------------------------------------------------------------- 5 · Starred, the ⋯ menu, moving across wings
STAR_ROWS = [sec("Books", "2"), brow("Journal", "13 entries · daily journal", STAR), brow("Essays", "8 notes · #essay #goals", STAR),
             sec("Notes", "2"), nr("On keeping a commonplace book", "today 1:02 PM", "I started copying sentences into a notebook the winter I stopped trusting my memory for them.", "Essays", star=True),
             nr("Grocery list", "Nov 10", "Oat milk, lemons, the good butter, stamps, something for the neighbour with the piano.", "No book", star=True)]
st_home = P(wmast("Home"), dots(0), lst(*STAR_ROWS), tabs_words(0), hi())
st_empty = P(wmast("Poetry"), dots(7), lst('<div class="empty">Nothing starred in Poetry.<small>Swipe a row to the right to star it.</small></div>'), tabs_words(0), hi())
m_more = home(SCRIM, ctx(104, [("New book…", sm(I_BOOK)), ("New shelf…", sm(I_SHELF)), ("Select…", sm(I_SELECT), 'gap'),
                               ("Archived", sm(I_ARCH), 'gap'), ("Trash", sm(I_TRASH)), ("Tags", sm(I_TAG)), ("Settings", sm(I_GEAR), 'gap')]))
RECIPES = brow("Recipes", "5 notes · #recipe")
m_book = P(wmast("Home"), dots(0), chipstrip_end(["Reading &amp; reference", "☼ Life", "Welcome", "All"], 1), lst(*LIFE, '<div class="addrow">+ New book on Life</div>'), qe(), tabs_words(1), hi(),
           SCRIM, lift(254, RECIPES),
           ctx(326, [("Star", sm(I_STARO)), ("Rename…", sm(I_PENCIL)), ("Move to shelf…", sm(I_SHELF)), ("Move to wing…", sm(I_WING)),
                     ("Archive", sm(I_ARCH)), ("Delete book…", sm(I_TRASH), 'danger gap')], right=24))
def wingpick(title, sub, skip="Home"):
    return sheet(196, shead(title, right="Cancel", strong=False), '<div class="ssub">%s</div>' % sub,
                 grp(*[mrow(w, cls='serif', v=wcount(b, n)).replace('class="mid"', 'class="mid" style="font-weight:600"') for w, b, n in WINGS if w != skip]))
m_pick = P(wmast("Home"), dots(0), chipstrip_end(["Reading &amp; reference", "☼ Life", "Welcome", "All"], 1), lst(*LIFE), qe(), tabs_words(1), hi(), wingpick("Move to a wing", "“Recipes” is in Home"))
m_conf = P(wmast("Home"), dots(0), chipstrip_end(["Reading &amp; reference", "☼ Life", "Welcome", "All"], 1), lst(*LIFE), qe(), tabs_words(1), hi(),
           confirm(None, "Move “Recipes” to “Family”?", ["Its 5 notes come with it, tags and all. It arrives unshelved."], [btn("Move"), btn("Cancel", 'quiet')]))
m_done = P(wmast("Home"), dots(0), chipstrip_end(["Reading &amp; reference", "☼ Life", "Welcome", "All"], 1), lst(LIFE[0], LIFE[2], '<div class="addrow">+ New book on Life</div>'),
           rcpt("Moved “Recipes” to “Family” with its 5 notes."), qe(), tabs_words(1), hi())
m_nconf = library(confirm(None, "Move “On keeping a commonplace book” to “Work”?",
                          ["It leaves “Essays” — a wing is a separate library, and a book only holds notes of its own wing. Its tags come with it."],
                          [btn("Move"), btn("Cancel", 'quiet')]))
m_copy = library(foot=rcpt("Copied “Grocery list” to “Family” — a separate library; the copy waits in its Pool.") + qe(today=False))
s5 = [
    opt(st_home, "23", "Starred is a root, inside the wing.",
        "She taps Starred (or swipes the page right). Home’s starred books and notes, in two short sections, with the same rows as everywhere else. Swipe a row to unstar. No capture box here: the Mac has it on the Bookcase and the Library."),
    opt(st_empty, "24", "Starred with nothing in it.", "One sentence, naming the wing, and how to star.", small=True),
    opt(m_more, "25", "The ⋯ menu, on every root.",
        "Makes things (New book, New shelf), starts selecting, and holds the three rooms and Settings so each is one tap from any root. The Library’s ⋯ adds nothing else; its Trash button is the same door as this row."),
    opt(m_book, "26", "A book row’s menu.",
        "She presses and holds Recipes. The books designer owns this list (a-book.html); the wing door is the row this file adds. The same row sits in the book’s own ⋯, so it is never press-and-hold only."),
    opt(m_pick, "27", "Pick the wing.",
        "The Mac’s prompt, “Move to a wing”, and where the thing is now. The other eight wings with their sizes. A note’s menu opens the same sheet for Move to wing… and Copy to wing…"),
    opt(m_conf, "28", "The confirm, for a book.",
        "The Mac’s question and the Mac’s facts: what comes with it and where it arrives. Move, or Cancel."),
    opt(m_done, "29", "After the move.",
        "The book is gone from this wing’s shelf. One line says where it went, in the Mac’s words. Kept, because a thing just left the screen for a place she cannot see."),
    opt(m_nconf, "30", "The confirm, for a note.",
        "The same road from a note’s row in the Library. The Mac names the books the note will leave. Copy to wing… asks nothing."),
    opt(m_copy, "31", "After a copy.",
        "The note stays; the copy is in the other wing. The Mac’s line says where it waits.", small=True),
]

# ---------------------------------------------------------------- 6 · the largest text, dark
x_xl = P(wmast("Home"), dots(0), chips(HOME_CHIPS, 2), lst(*WRITING[:4], NEWBOOK), qe(), tabs_words(1), hi(), cls='xl')
x_xlcap = P(wmast("Home"), dots(0), chips(HOME_CHIPS, 2), lst(*WRITING[:2]),
            '<div class="qe"><div class="qebox typed">Walk note: the ferry timetable changes in December<span class="caret"></span></div></div>',
            '<div class="qact" style="height:52px"><span class="dest" style="margin-right:auto;font-size:17px">in Home</span><span class="pill" style="height:52px;border-radius:26px">Open</span><span class="pill fill" style="height:52px;border-radius:26px">File</span></div>',
            kb('return'), cls='xl')
x_dk = P(wmast("Home"), dots(0), chips(HOME_CHIPS, 2), lst(*WRITING, NEWBOOK), qe(), tabs_words(1), hi(), cls='dk')
x_dkcap = home(wing="Home", foot=rcpt("Filed in the Pool.", "Open ›") + qe_typed(["Ask the kiosk about the winter pass"]) + qact("Home") + kb('return'), bar=False, cls='dk')
x_dkmenu = home(wing_menu(1, manage=False), wing="Work", chipset=WORK_CHIPS, on=3, rows=WORK_ALL, cls='dk')
s6 = [
    opt(x_xl, "32", "Home at the largest text size.",
        "The system’s largest standard size. Names, counts, chips, the box and the bar all grow; the three bar words still fit, and the shelf strip scrolls. Fewer books show, none are cut off mid-word."),
    opt(x_xlcap, "33", "Capture at the largest text size.", "Her words are 23 pt in the box. The buttons grow with their labels; the Bookcase gives up rows first."),
    opt(x_dk, "34", "Home, dark.", "The room is black and the paper carries the sea-glass hue, as on the Mac."),
    opt(x_dkcap, "35", "Capture, dark.", "A second note being typed just after the first was filed."),
    opt(x_dkmenu, "36", "The nine wings, dark.", "", small=True),
]

INTRO = """
<p class="lede"><b>VM-44 mockups — the home screen, wings and capture.</b> Today the phone shows every wing at once, has no way to change wing, and its capture box is a 34 pt dashed outline
whose Return key opens the note and can lose words. These frames draw the home screen as she ruled it at the first sitting, as one flow.</p>
<p class="q">“On the wing title (left)” · “Bookcase gets the screen” · “New line; File and Open buttons” · “Words on a chip” · Today: “Keep it” · “I think we need to word things more simply.”</p>
<p class="lede">Every line on a screen is either the Mac’s own (wing words, “Filed in …”, “Now in …”, the move confirms) or a short draft for her wording pass. Routine acts say nothing;
a line shows only for a refusal, a note that was filed out of sight, or something that left the screen. A green label marks my pick where a question is still open.</p>
"""
sections = [
    ("1 · The home screen at rest", '<p class="lede">The wing band, the shelf strip, the Bookcase, the capture box with Today, the bar.</p>', s1),
    ("2 · Stepping between wings", '<p class="lede">Swipe the title for the next wing; tap it for all nine. The page swipe below stays Starred · Bookcase · Library.</p>', s2),
    ("3 · When a note belongs to another wing (SW-2)", '<p class="lede">The Mac’s rule: a switch she makes lands on the new wing’s Bookcase; opening a note from another wing carries the app’s wing with it, and says so.</p>', s3),
    ("4 · The capture box", '<p class="lede">File is the common path and the fast one. Open is the deliberate one.</p>', s4),
    ("5 · Starred, the ⋯ menu, and moving across wings", '<p class="lede">The Mac’s Move to Wing and Copy to Wing, from a row.</p>', s5),
    ("6 · The largest text size, and dark", '', s6),
]
NOTES = """
<div class="pick" style="max-width:1500px"><h2>Open questions drawn here, and my picks</h2>
<p><b>SW-2, what Back does after the app followed a note</b> (frames SW-2 (i) and (ii)). Pick: (i), the Mac’s rule as written — one wing for the whole app, and it follows the note. It needs nothing new and the title band tells her at once where she is.
(ii) is worth it only if the Today button from another wing proves to strand her in Home every morning.</p>
<p><b>W-025, the phone’s face for the capture marks.</b> Pick: (ii), two small keys. Her words were that these marks are “more for quicknotes on the phone”, and braces are three keyboard pages deep there.</p>
<p><b>Wing management on the phone</b> (New wing, rename, reorder, delete, move everything). Not picked: drawn where it would live, tagged open. The Mac has no reorder door, so reorder would be new on both.</p>
<p><b>BK-1</b> is drawn as the chip row (a) throughout and touches only the strip under the dots.</p></div>

<h2>Build notes</h2>
<table class="bn">
<tr><th>Screen</th><th>Work-list rows it delivers</th><th>Shared brain it stands on</th><th>What is new</th><th>Must not get wrong</th><th>Size</th></tr>
<tr><td>The wing band (title, dots, swipe)</td><td>W-015, W-018, W-019, W-033, W-007 (the bar)</td>
<td>Shared <code>WingState</code> (current wing, memory, revalidate; <code>readScope</code> must return the wing on iOS), Core <code>Queries.wings</code>. Hoist owed: <code>WingSwitcherBrain.next(after:in:)</code>, <code>WingsModel</code>.</td>
<td>The band as a drag target; the dots; the dimmed page while dragging.</td>
<td>The drag belongs to the band only (about 80 pt tall); the page’s own swipe must not start there, and the band’s must not start on the page. The page re-reads once, when the drag settles, never per frame. A wing deleted on another device returns her to Home. Every listing and every new note, book and tag follows the wing. From the Library the step is in place; it never jumps to the Bookcase.</td><td>M</td></tr>
<tr><td>The list of nine</td><td>W-017</td>
<td>Core <code>Queries.wings</code>, <code>wingContents</code>; hoist owed: <code>WingsModel</code>, <code>WingCopy</code> (“Wings — each a separate library”).</td>
<td>A menu anchored under the title, 52 pt rows with sizes.</td>
<td>A pick lands on that wing’s Bookcase, the current wing included. Sizes are read when the menu opens, not held. It scrolls past about eleven wings.</td><td>S</td></tr>
<tr><td>Manage wings, New wing (open)</td><td>W-021</td>
<td>Core <code>createWing</code>, <code>renameWing</code>, <code>deleteWing</code>, <code>moveWingContents</code>; Shared <code>WingWords.lesson</code>, <code>notEmpty</code>.</td>
<td>The sheet; reorder would need a Core operation that does not exist.</td>
<td>Delete refuses unless empty and names what is left. Home has no rename and no delete.</td><td>M</td></tr>
<tr><td>The app follows a note; “Now in …”</td><td>W-019, W-020</td>
<td>Core <code>effectiveWing(ofPost:)</code>; hoist owed: <code>WingFollow</code> (<code>nowIn</code>).</td>
<td>The line on the note screen.</td>
<td>A follow never lands on a Bookcase and never closes a note. The line shows only when the wing really changed. Today already opens the Journal’s wing in Core; the phone must follow it rather than mint in the current wing.</td><td>S</td></tr>
<tr><td>The capture box: focus, grow, File, Open</td><td>W-022, W-023, W-024, W-027, W-034, and the lag rows from audit F (2A, 2B, 2F, 1B)</td>
<td>Core <code>importPost(wingId:)</code>; the phone’s own <code>MobileQuickNote</code> model (mint after a second, autosave, file on leaving); hoist owed: <code>QuickEntryFileCopy</code> (“File”, “Filed in …”, “Open ›”), <code>CaptureLanding</code>.</td>
<td>A soft-keyboard rule (Return is a newline, two buttons file); the box growing by lines to a cap; the destination word; the line with its door.</td>
<td>File must not build the note screen at all: save, clear, keep the keyboard, show the line. Open must keep the keyboard up across the push (no down-then-up) and put the caret at the end of her text. One filing per press. Leaving the screen or the app still files what is in the box. The box’s height never changes the Bookcase’s layout rule, only how many rows show. The bar leaves while the keyboard is up.</td><td>M</td></tr>
<tr><td>Capture marks</td><td>W-025</td>
<td>Shared <code>CaptureMicrosyntax</code>, <code>TypedTagPath</code>.</td>
<td>The two helper keys (pick ii).</td>
<td>Only braced forms parse; the tags are found or made in the current wing, never another wing’s; the line names a book only when a book really seated the note.</td><td>S</td></tr>
<tr><td>Refusal on filing</td><td>W-012, W-013</td>
<td>Hoist owed: <code>QuickEntryCopy.refusal</code>; Shared <code>OpsRefusalTable</code>.</td><td>—</td>
<td>Her text stays in the box. Never a raw error.</td><td>S</td></tr>
<tr><td>Starred as a root</td><td>W-054, W-033</td>
<td>Core <code>Queries.starred(db, wingID:)</code>; hoist owed: <code>SidebarRowLeads</code> for untitled rows.</td>
<td>Two sections; the shared note and book rows.</td>
<td>Per wing. Untitled notes lead with their first words, never a date.</td><td>M</td></tr>
<tr><td>The ⋯ menu on a root</td><td>W-008, W-050, W-010</td><td>—</td><td>One menu on all three roots.</td>
<td>Archived, Trash, Tags and Settings are one tap from every root.</td><td>S</td></tr>
<tr><td>Move or copy to a wing</td><td>W-036, W-100, W-048</td>
<td>Core <code>moveNoteToWing</code>, <code>copyNoteToWing</code>, <code>moveReadingToWing</code>; hoist owed: <code>WingDestinationSheet</code>’s rule, <code>WingCopy</code> and <code>WingBookMoves</code>’ confirm sentences.</td>
<td>The picker sheet; the confirm as a sheet.</td>
<td>The confirm’s facts come from the same read as the act (books left behind, notes that come along, a same-name twin). A note in a finished book refuses with the Mac’s sentence. Offered only while a second wing exists.</td><td>M</td></tr>
<tr><td>Largest text, dark</td><td>W-001, W-002, W-004, W-005</td><td>The phone type layer over <code>VoiceTokens</code>; <code>PaletteDerivation</code>.</td><td>—</td>
<td>Chrome grows to the largest standard size and holds; her words keep growing. The bar’s three words must fit at that size.</td><td>—</td></tr>
</table>
<p class="note-ann"><b>Added to the sizing sheet’s vocabulary</b> (in its spirit): the wing band’s nine dots (7 pt, not a target; the band is); the Today button at the box’s height (48 pt);
the two-button row under a focused box (44 pt buttons, no band behind them, a 13 pt “in ‹wing›” word); the helper key (a 32 pt capsule in a 44 pt hit area);
the press-and-hold menu with a 13 pt head line; the “open” tag (annotation only). The capture box is drawn at the sheet’s 48 pt and 12 pt radius, so it is 4 pt shorter than in a-book.html.</p>
"""
write('home-wings-capture.html', 'VM-44 mockups — the home screen, wings and capture', INTRO, sections, NOTES, check_dir=os.environ.get('SH_CHECK'))
