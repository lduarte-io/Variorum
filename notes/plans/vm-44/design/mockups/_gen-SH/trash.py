# VM-44 — trash-archive-tags.html (throwaway generator; static HTML out). Revision pass: drawn to sitting-1-rulings.md.
import sys, os
sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
from base import *
N = Num()

def trw(title, meta, preview='', act='Put back', sel=None, cls=''):
    tick = ''
    if sel is not None:
        tick = '<span class="selc%s">%s</span>' % (' on' if sel else '', I_CHECK if sel else '')
        cls += ' selm' + (' selon' if sel else '')
    p = '<div class="p">%s</div>' % preview if preview else ''
    a = '<span class="pb"><span>%s</span></span>' % act if act and sel is None else ''
    return '<div class="trw %s">%s<div class="mid"><div class="t">%s</div>%s<div class="m">%s</div></div>%s</div>' % (cls, tick, title, p, meta, a)

# ---------------------------------------------------------------- 1 · the Trash
TR = [
    ("Old packing list", 'note · <span class="soon">leaves today</span>'),
    ("Questions for the accountant", "note · 18 days left"),
    ("Scratch", "book · 24 days left"),
    ("There is a drawer of them, and for a while I thought the drawer was the point.", "block · from Letters I never sent · 25 days left"),
    ("Books to borrow", "note · 27 days left"),
    ("(empty block)", "block · from Grocery list · 28 days left"),
    ("(empty block)", "block · from The case for slow mornings · 29 days left"),
]
TKINDS = ["All", "Notes", "Books", "Blocks", "Takes", "Snippet groups", "Originals"]
TSUB = "In Home. Deleted things wait here for 30 days, then they’re gone."
def trash(rows, *over, on=0, right=MORE, bar=True, cls='', head=None, foot=''):
    return room("Trash", TSUB, right, chips(TKINDS, on, fade=True), lst(*rows), foot, cls=cls, bar=bar, over=over)
def trows(sel=None, skip=()):
    return [trw(t, m, sel=(None if sel is None else (i in sel))) for i, (t, m) in enumerate(TR) if i not in skip]
DOORS = ('<div class="footdoors"><div class="fl">Tidy up</div><div class="fd">Delete 2 empty blocks…</div>'
         '<div class="fd">Delete 2 unused tags…</div><div class="fgap"></div><div class="fd danger">Empty Trash…</div></div>')
t_rest = trash([sec("7 things · leaving soonest first")] + trows())
t_foot = trash(trows()[4:] + [DOORS])
def tsheet(title, meta, *groups, top=None):
    return sheet(top, '<div class="shead"><span class="st" style="display:-webkit-box;-webkit-line-clamp:2;-webkit-box-orient:vertical;overflow:hidden">%s</span><span class="hb">Cancel</span></div>' % title,
                 '<div class="ssub">%s</div>' % meta, *groups)
t_row = trash([sec("7 things · leaving soonest first")] + trows(),
              tsheet("Questions for the accountant", "note · deleted Oct 31 · 18 days left",
                     grp(mrow("Put back", icon=I_PUTBACK, cap="Back in the Library.")),
                     '<div style="height:20px"></div>',
                     grp(mrow("Delete now…", icon=I_TRASH, cls='danger', cap="Skips the rest of its 30 days.")), top=540))
t_blk = trash([sec("7 things · leaving soonest first")] + trows(),
              tsheet("There is a drawer of them, and for a while I thought the drawer was the point.", "block · from Letters I never sent · 25 days left",
                     grp(mrow("Put back", icon=I_PUTBACK, cap="Back where it was in the note."), mrow("Open note", icon=I_OPEN)),
                     '<div style="height:20px"></div>',
                     grp(mrow("Delete now…", icon=I_TRASH, cls='danger', cap="Skips the rest of its 30 days.")), top=464))
t_conf = trash([sec("7 things · leaving soonest first")] + trows(),
               confirm(None, "Delete this note for good?", ["It skips the rest of its 30 days — there’s no putting it back."],
                       [btn("Delete now", 'alarm'), btn("Cancel", 'quiet')]))
t_back = trash([sec("6 things · leaving soonest first")] + trows(skip=(1,)), foot=rcpt("Note put back.", "Open ›"))
sw = trows()
sw[4] = '<div class="swipe"><div class="act alarm">%sDelete now</div>%s</div>' % (I_TRASH, trw(*TR[4], cls='sr', act=''))
t_swipe = trash([sec("7 things · leaving soonest first")] + sw)
def twobar(a, b): return ('<div class="actbar two"><span class="ab">%s%s</span><span class="ab danger">%s%s</span></div>' % (sm(I_PUTBACK, 20), a, sm(I_TRASH, 20), b))
t_sel = P('<div class="selbar"><span class="n">2 selected</span><span class="hb">Done</span></div>',
          lst(*trows(sel={1, 4})), twobar("Put back 2", "Delete now 2…"), hi())
t_empty = trash([sec("7 things · leaving soonest first")] + trows(),
                confirm(None, "Empty the Trash?", ["7 things go for good: 3 notes, 1 book, 3 blocks."], [btn("Empty Trash", 'alarm'), btn("Cancel", 'quiet')]))
t_sweep = trash(trows()[4:] + [DOORS],
                confirm(None, "Delete these 2 empty blocks for good?",
                        ["None holds any words, commits, comments, a name, a callout or a link to a living block. They skip the rest of their 30 days — there’s no putting them back."],
                        [btn("Delete 2 empty blocks", 'alarm'), btn("Cancel", 'quiet')]))
t_none = trash(['<div class="empty">The Trash is empty.</div>'])
t_filt = trash(['<div class="empty">No takes in the Trash.<small>The Takes filter is on, and other things are waiting here.</small></div>'], on=4)
s1 = [
    opt(t_rest, N(), "The Trash, in Home.",
        "From the Trash button on the Library, or ⋯ ▸ Trash on any root. Each row says what the thing is, where it came from and how long it has left; the one leaving today is marked. "
        "The only button on a row is Put back. Delete now is never beside it. Chips narrow by kind, in the Mac’s words. The bar stays: this is a list."),
    opt(t_foot, N(), "The foot of the list.",
        "Scrolled to the end. The doors that remove for good live here, away from every Put back: the two tidy-up doors, then Empty Trash in the alarm ink. "
        "“Delete 2 empty blocks…” shows only while such blocks exist. The unused-tags door is the second way into the tag screen’s sweep, kept as she ruled."),
    opt(t_row, N(), "She taps a row.",
        "A deleted thing cannot be opened, so a tap asks what to do with it. Put back on top; Delete now below, in its own group, a thumb’s width away."),
    opt(t_blk, N(), "The same for a block.", "A block’s row shows its words, up to two lines. Its sheet adds Open note, as today.", small=True),
    opt(t_conf, N(), "Delete now asks, every time.",
        "The Mac’s sentence. The alarm button says what it does. After it the row leaves and nothing more is said: she just confirmed it."),
    opt(t_back, N(), "After Put back.",
        "The row leaves. One line, the Mac’s, with a door to the note: it left this page for a place she cannot see from here. A block says “Put back where it was.”"),
    opt(t_swipe, N(), "A swipe as the short way.",
        "Swipe a row left for Delete now; it still asks, and the row’s Put back button slides away so the two are never side by side. Swipe right for Put back. The swipes repeat doors that are already on screen."),
    opt(t_sel, N(), "Select several.",
        "From ⋯ ▸ Select…. The two acts sit at opposite ends of the foot. Delete now asks once, naming the count."),
    opt(t_empty, N(), "Empty Trash asks.",
        "The Mac’s sentence, with the count by kind. Only this wing’s Trash is emptied, because only this wing’s is shown."),
    opt(t_sweep, N(), "The empty-blocks door asks.",
        "The Mac’s sentence: what an empty block is, and that there is no putting them back."),
    opt(t_none, N(), "Nothing in the Trash.", "The Mac’s line. Nothing is drawn until the first read lands, so “empty” never flashes.", small=True),
    opt(t_filt, N(), "Nothing of one kind.", "The Mac’s line when a filter hides the rest.", small=True),
]

# ---------------------------------------------------------------- 2 · Archived
ASUB = "In Home. Notes and books you set aside — kept, with no countdown."
ASEARCH = '<div class="search" style="margin:2px 20px 10px">%s Search archived notes and books…</div>' % I_SEARCH
AROWS = [sec("Books", "2"),
         trw("Old projects", "book · 4 notes · archived Oct 18", act="Unarchive"),
         trw("Autumn reading", "gathering · shows nothing while archived", act="Unarchive"),
         sec("Notes", "2"),
         trw("Letters I never sent", "archived Oct 18 · Essays", preview="There is a drawer of them, and the drawer is the point.", act="Unarchive"),
         trw("Packing list for Lisbon", "archived Oct 18 · No book", preview="Two shirts too many, as always. The good shoes. The small notebook.", act="Unarchive")]
def archived(rows, *over, foot='', cls=''):
    return room("Archived", ASUB, MORE, ASEARCH, lst(*rows), foot, cls=cls, over=over)
a_rest = archived(AROWS)
a_un = archived([AROWS[0], AROWS[1], AROWS[2], sec("Notes", "1"), AROWS[5]], foot=rcpt("Note unarchived — it’s back in the Library.", "Open ›"))
a_menu = archived(AROWS, SCRIM, lift(338, AROWS[4].replace('<span class="pb"><span>Unarchive</span></span>', '')),
                  ctx(424, [("Unarchive", sm(I_PUTBACK)), ("Open", sm(I_OPEN)), ("Delete note…", sm(I_TRASH), 'danger gap')], right=24))
a_none = archived(['<div class="empty">Nothing archived.</div>'])
s2 = [
    opt(a_rest, N(), "Archived, in Home.",
        "From the Archived chip in the Library, or ⋯ ▸ Archived. Books first, then notes: archived books have a home here, which they lack on the phone today. "
        "A book’s row says what it is and holds; a gathering’s says it shows nothing while archived (the Mac’s words). A note’s row keeps its preview. "
        "Tap a row to open it; the button unarchives. The field searches this room only."),
    opt(a_un, N(), "She unarchives a note.",
        "The row leaves; the Mac’s line says where the note is now, with a door to it. A book says “Unarchived “Old projects” — it’s back on the Bookcase.” "
        "Archiving from the Library is the other half (library-and-search.html), with its Undo."),
    opt(a_menu, N(), "Press and hold a row.", "Unarchive, Open, and Delete, which sends it to the Trash with the usual confirm.", small=True),
    opt(a_none, N(), "Nothing archived.", "The Mac’s line. A search with no match says “No archived note matches that.”", small=True),
]

# ---------------------------------------------------------------- 3 · tags
TAGS = [("blog", 0, "7 notes"), ("draft", 0, "9 notes"), ("essay", 0, "8 notes"), ("idea", 0, "3 notes"), ("life", 0, "2 sub-tags"),
        ("goals", 1, "2 notes"), ("health", 1, "5 notes"), ("people", 0, "not used"), ("quote", 0, "6 notes · 1 snippet"), ("reading", 0, "6 notes"),
        ("recipe", 0, "5 notes"), ("someday", 0, "not used"), ("travel", 0, "4 notes")]
def tg(name, depth, count, sel=None, more=True):
    cls = ' d1' if depth else ''
    tick = ''
    if sel is not None:
        tick = '<span class="selc%s">%s</span>' % (' on' if sel else '', I_CHECK if sel else '')
        cls += ' selm' + (' selon' if sel else '')
    m = '<span class="tm">%s</span>' % I_MORE if more and sel is None else '<span style="width:12px"></span>'
    return '<div class="tg%s">%s<span class="tn"><i>#</i>%s</span><span class="tc">%s</span>%s</div>' % (cls, tick, name, count, m)
def tagrows(skip=()): return [tg(*t) for t in TAGS if t[0] not in skip]
GSUB = "Each wing has its own tags."
NEWTAG = '<span class="pill">New tag</span>'
def tags(rows, *over, foot=None, cls=''):
    f = band("2 tags are not used.", "Delete 2 unused tags…") if foot is None else foot
    return room("Tags — in Home", GSUB, NEWTAG, lst(*rows), f, cls=cls, over=over, tab=1)
g_rest = tags(tagrows())
g_menu = tags(tagrows(), SCRIM, ctx(446, [("New child tag…", sm(I_PLUS)), ("Rename…", sm(I_PENCIL)), ("Make a gathering…", sm(I_BOOK)), ("Delete tag…", sm(I_TRASH), 'danger gap')], right=20))
g_ren = tags(tagrows(), sheet(332, shead("Rename tag", right="Rename", left="Cancel"),
                              field("draft", focus=True, label="#"),
                              '<div class="c13b" style="margin-top:0;color:var(--alarm)">A tag named “draft” already exists — rename it, then try again.</div>',
                              kb('return'), cls='kbd'))
g_conf = tags(tagrows(), confirm(None, "Delete tag?", ["Deleting “life” also deletes its 2 sub-tags — every note wearing any of them loses those tags."],
                                 [btn("Delete", 'alarm'), btn("Cancel", 'quiet')]))
g_done = tags(tagrows(skip=("life", "goals", "health")), foot=rcpt("Deleted #life and its 2 sub-tags.", "Undo") + band("2 tags are not used.", "Delete 2 unused tags…"))
g_sweep = tags(tagrows(), sheet(404, shead("Unused tags in Home", right="Cancel", strong=False),
                                '<div class="c13b" style="margin-top:0">No note or block wears these — nothing in the Trash does either. Uncheck any you want to keep; Undo puts the rest back.</div>',
                                '<div class="grp">%s%s</div>' % (tg("people", 0, "", sel=True), tg("someday", 0, "", sel=True)),
                                btn("Delete 2 tags", 'alarm')))
g_swept = tags(tagrows(skip=("people", "someday")), foot=rcpt("Deleted 2 unused tags.", "Undo"))
g_new = tags(tagrows(), sheet(360, shead("New tag", right="Add", left="Cancel"), field("garden", focus=True, label="#"),
                              '<div class="c13b" style="margin-top:0">It joins Home’s tags.</div>', kb('return'), cls='kbd'))
s3 = [
    opt(g_rest, N(), "Tags, in Home.",
        "From ⋯ ▸ Tags on any root (and from Settings). The title is the Mac’s: it names the wing, and the list follows the wing. One tag per row with a count of what wears it, kept as she ruled; a tag inside another is indented. "
        "Each row has a visible ⋯, so no act hides behind a long press. New tag is a button. While any tag is unused, the foot offers the Mac’s sweep."),
    opt(g_menu, N(), "A tag’s ⋯.",
        "She taps ⋯ on “life”. New child tag, Rename, Make a gathering (the Mac’s door; a-book.html draws what it opens), and Delete, set apart."),
    opt(g_ren, N(), "Rename, and its refusal.",
        "A field with the tag’s name. Here she typed a name another tag already has; the Mac’s sentence says so and the sheet stays open. A refusal always shows."),
    opt(g_conf, N(), "Delete asks.",
        "The Mac’s title and its consequence, which counts the tags inside. “Delete” in the alarm ink."),
    opt(g_done, N(), "After Delete: Undo.",
        "The three rows leave. One line with Undo, kept as she ruled: a deleted tag has no Trash, and Undo puts it back on every note that wore it. The line’s words are a draft; the Mac has none for a single tag."),
    opt(g_sweep, N(), "The unused-tags sweep.",
        "From the foot here, or from the Trash’s foot. The Mac’s title and line (with “Undo” for the Mac’s key), every unused tag ticked; untick any to keep. The button counts what will go."),
    opt(g_swept, N(), "After the sweep.", "The Mac’s line, with Undo. The foot’s offer is gone because nothing is unused.", small=True),
    opt(g_new, N(), "New tag.", "A name, and where it lands: the wing she is in.", small=True),
]

# ---------------------------------------------------------------- 4 · the largest text, dark
x_xl = trash([sec("7 things · leaving soonest first")] + trows(), cls='xl')
x_dk = trash([sec("7 things · leaving soonest first")] + trows(), cls='dk')
x_dka = archived(AROWS, cls='dk')
x_dkt = tags(tagrows(), cls='dk')
s4 = [
    opt(x_xl, N(), "The Trash at the largest text size.", "Names wrap to two lines; Put back grows and keeps its place at the row’s edge; the facts drop under the name. Three or four things a screen."),
    opt(x_dk, N(), "The Trash, dark.", ""),
    opt(x_dka, N(), "Archived, dark.", "", small=True),
    opt(x_dkt, N(), "Tags, dark.", "", small=True),
]

INTRO = """
<p class="lede"><b>VM-44 mockups — the Trash, Archived and tags.</b> Revised after the first sitting: every frame follows <code>plans/sitting-1-rulings.md</code>.
Today the Trash puts “Put back” and “Delete Now” side by side as 14 pt-tall words 18 pt apart on every row; the Archived room is the last row
under the whole Library and shows no books; the tag manager lists every wing’s tags together, twins included, and every act hides behind a long press. All three read every wing at once.</p>
<p class="q">“many of the button affordances are absolutely tiny” · the three additions, all kept: “Undo after deleting a tag, Unused-tags door in the Trash, Counts in the tag list”</p>
<p class="lede"><b>What was chosen, in one line each.</b> The three rooms belong to the wing she is in and say so. The act that restores is the row’s one button; Delete now stays off the row.
Kept: Undo after deleting a tag, the unused-tags door at the Trash’s foot, counts in the tag list. The bar shows on all three rooms, because they are lists.
Lines: only when something leaves the page (a put-back, an unarchive, a deleted tag) and for refusals. The words are the Mac’s; the few drafts are in <code>design/wording-list-1.md</code>.</p>
"""
sections = [
    ("1 · The Trash", '<p class="lede">Put back on the row. Delete now behind a tap, a swipe or the select bar. Empty Trash and the sweep at the foot.</p>', s1),
    ("2 · Archived", '<p class="lede">Notes and books, one tap from any root.</p>', s2),
    ("3 · Tags", '<p class="lede">Per wing, with visible doors, the delete confirm and its undo, and the unused-tags sweep.</p>', s3),
    ("4 · The largest text size, and dark", '', s4),
]
NOTES = """
<div class="pick" style="max-width:1500px"><h2>Still open here</h2>
<p><b>Nothing is waiting on a ruling.</b> Delete now is off the row; the unused-tags door sits at the Trash’s foot and under Tags; a deleted tag’s line carries Undo; the tag list shows counts.</p>
<p>One thing a builder must settle, not her: the tag counts need a bounded read. If that read cannot be made cheap, say so before cutting them, because she chose to keep them.</p></div>

<h2>Build notes</h2>
<table class="bn">
<tr><th>Screen</th><th>Work-list rows it delivers</th><th>Shared brain it stands on</th><th>What is new</th><th>Must not get wrong</th><th>Size</th></tr>
<tr><td>The Trash (rows, kinds, the row sheet)</td><td>W-033 (per wing), W-002, W-010, W-032, W-057</td>
<td>Core <code>observeTrash(wingID:)</code>; Shared <code>RecoveryCopy</code> (every word here), <code>TrashPutBack</code>, <code>TrashPurge</code>, <code>RecoveryActs</code>.</td>
<td>The row with one button; the tap sheet; the swipes.</td>
<td>Put back and Delete now never share an edge. Delete now always confirms. Nothing draws until the first read lands (no “empty” flash). Scoped to the wing, and Empty Trash counts and empties only what is shown. A sealed note’s refusal is the Mac’s sentence. The list is windowed.</td><td>M</td></tr>
<tr><td>Select several in the Trash</td><td>W-055</td>
<td>Shared <code>RecoveryActs</code> (the VX-671 selection).</td><td>The two-button foot.</td>
<td>One confirm naming the count for Delete now; Put back needs none.</td><td>S</td></tr>
<tr><td>Empty Trash, the empty-blocks sweep</td><td>W-056</td>
<td>Shared <code>RecoveryActs</code> (the sweep), Core <code>sweepEmptyTrashBlocks</code>; <code>RecoveryCopy.deleteEmptyBlocksLabel</code>, <code>deleteEmptyBlocksConfirm</code>, <code>emptyTrashConfirm</code>.</td>
<td>The foot group.</td>
<td>The sweep door shows only while such blocks exist, and never deletes more than the confirm named. The receipts after a purge are the Mac’s three (synced, once synced, local).</td><td>S</td></tr>
<tr><td>Archived (books and notes)</td><td>W-050, W-117, W-033, W-046 (the other half), W-061 (search this room)</td>
<td>Core <code>observeArchivedPosts</code>, <code>observeArchivedReadings</code>, <code>unarchiveReading</code>; Shared <code>RecoveryCopy</code>, <code>BookArchiveCopy</code>; the Mac room’s copy (<code>ArchivedView</code>: subtitle, sections, the book’s detail line, the empty lines) — hoist owed.</td>
<td>The Books group; the room’s own search field.</td>
<td>An archived book opens (the books designer’s frame), still archived. A gathering’s row says it shows nothing while archived. Unarchiving a living book resumes collecting, and what it catches up on waits at Arrivals. Per wing. Windowed, with a marker if older ones are not listed.</td><td>M</td></tr>
<tr><td>Tags (the list, the row acts)</td><td>W-229, W-010, W-231 (the door only)</td>
<td>Core <code>observeTags(wingID:)</code>, <code>createTag(wingID:)</code>, <code>renameTag</code>, <code>deleteTag</code>; Shared <code>TagDeletion</code>, <code>OpsRefusalTable</code> (<code>duplicateTagPath</code>); Mac-local <code>TagManagerCopy</code> — hoist owed.</td>
<td>The visible ⋯ on each row; the counts.</td>
<td>Only this wing’s tags; a new tag is born in this wing. The counts are kept (ruled) and need a bounded read: one grouped count per page of tags, never a scan per row. Rename refuses a name that exists, in words. Delete names the sub-tags it takes.</td><td>M</td></tr>
<tr><td>Delete tag’s undo; the unused-tags sweep</td><td>W-230</td>
<td>Core <code>deleteUnusedTags</code>, <code>Queries.tagSubtreeIsWorn</code>, the structural undo entry “Delete Tag” / “Delete Unused Tags”; <code>TagManagerCopy</code> (sweep title, line, button, receipts).</td>
<td>The line with Undo outside a note.</td>
<td>Undo is the session’s structural undo, not a second mechanism; if a same-name tag was made meanwhile it refuses with the Mac’s sentence and keeps the entry. A tag worn only by something in the Trash is not “unused”. The sweep deletes only what is still unused at the press.</td><td>S</td></tr>
<tr><td>Largest text, dark</td><td>W-001, W-004</td><td>The phone type layer.</td><td>—</td><td>Put back stays a 44 pt target at every size and never wraps under the name.</td><td>—</td></tr>
</table>
<p class="note-ann"><b>Added to the sizing sheet’s vocabulary</b> (in its spirit): the room row with one capsule act (the sheet’s 32 pt capsule in a 44 pt hit area, at the trailing edge);
the foot doors (48 pt rows, the alarm one last after a gap); the two-button select foot; the tag row (52 pt, indent 24 per level, a 44 pt ⋯); a 20 pt pushed-room title (the sheet’s screen-title role).
The bar shows on these pushed rooms (W-007, ruled: roots and lists, never inside a note).</p>
"""
write('trash-archive-tags.html', 'VM-44 mockups — the Trash, Archived and tags', INTRO, sections, NOTES, check_dir=os.environ.get('SH_CHECK'))
