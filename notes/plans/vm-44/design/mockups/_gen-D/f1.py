# VM-44 — first-run-and-joining.html. REVISED after sitting 1 (plans/sitting-1-rulings.md):
# the Bookcase and capture box with nothing in front; "I already use Variorum" lives in the welcome card (the full-screen fork and the
# Settings-road alternatives are gone); a short phone tour as band cards; the pocket guide as a seeded book; voice and palette follow the
# library while light or dark stays each device's own; in-app crash reporting, opt-in; no routine receipts.
from base import *

# ---------- the app's own words (verbatim from Shared/Protection/ProtectionWords.swift, SyncStatusViews.swift, AuthViews.swift,
# TourOfferCard.swift, TourScript.swift, DiagnosticsCopy.swift, MobileEmptyStore.swift), device nouns as the phone renders them ----------
W_WORDSCARD = "Your library is encrypted — tap here to record the twelve words that are its key."
W_REMINDER = "Your library is only secured through iCloud Keychain right now — please add a passphrase and keep your twelve words to ensure continued access."
W_LOOKLEAD = "Write these down now. They open your library — on this iPhone and on any copy of it — for as long as they are its words."
W_SETLEAD = "A passphrase is a convenience over your twelve words — easier to type, and either one can reset the other."
W_JOINLEAD = "Your account already syncs. Type its passphrase or its twelve words once — your library’s own passphrase and twelve words are replaced by your account’s."
W_JOINWORDS = "Your twelve words are %s’s twelve words. Your previous twelve words still open backups made with them. If you don’t have your account’s words written down, you can make new ones at any time." % EMAIL
W_E6 = "Your account’s passphrase hasn’t been typed on this iPhone yet — type it once and it opens this library here too."
W_E6B = "If you don’t know it, set one you do with Reset forgotten passphrase."
SAMPLE = ["harbor", "velvet", "orchard", "signal", "meadow", "lantern", "copper", "winter", "gather", "pencil", "island", "quiet"]
EMPTY_BOOKS = "No books yet — Today’s Entry starts your journal."

# ---------- the drafted lines of this file (each is filed for wording-list-2.md where it is first drawn) ----------
D_WELCOME = "New here? Just start writing. Already use Variorum? Bring your library to this iPhone."
D_NEWDOOR = "I’m new"
D_USEDOOR = "I already use Variorum"          # her words, sitting 1
D_TOUR1T = "Write a note"
D_TOUR1 = "Type in the box below. File saves it. Open saves it and opens it."
D_SIGNHELP = "Use the account your other device syncs with. If it doesn’t sync yet, turn on sync there first."
D_CLOSE1 = "You can close this. Sync keeps going."
D_CLOSE2 = "Keep Variorum open while it syncs. If you leave, it carries on when you come back."
D_ARRIVE = "Your books will appear when the first sync finishes."
D_DOORLINE = "Already use Variorum? Sign in…"
D_OUT1 = "You’re signed out."
D_OUT2 = "Nothing syncs until you sign in again."


def welcome(reg=False):
    d = dr if reg else (lambda l, w: l)
    return bcard([(d(D_WELCOME, "The welcome card’s one sentence."), '')],
                 [(d(D_USEDOOR, "Welcome card door: opens sign-in and the join (her words at sitting 1)."), False),
                  (d(D_NEWDOOR, "Welcome card door: seeds the Welcome shelf and starts the tour."), False)], glyph=mark(30), title="Welcome to Variorum.")


def tourcard(reg=False):
    d = dr if reg else (lambda l, w: l)
    return ('<div class="bcard"><div class="step">Step 1 of 5</div><div class="tt">%s</div><div class="ln">%s</div>'
            '<div class="doors"><span class="door">%s</span><span class="door qt">End tour</span></div></div>'
            % (d(D_TOUR1T, "The phone tour’s first card: its title."), d(D_TOUR1, "The phone tour’s first card: its sentence."), d("Next", "Tour card door (the Mac: “next ⟶”).")))


wordscard = bcard([(W_WORDSCARD, '')], [("Later", True)], x=True, glyph=I_KEY)
remcard = bcard([(W_REMINDER, '')], [("Set a passphrase…", False), ("Not now", True)], glyph=I_KEY)


def wgrid():
    return '<div class="wgrid">%s</div>' % ''.join('<div><span>%d</span>%s</div>' % (i + 1, w) for i, w in enumerate(SAMPLE))


LESSONS = ["Start here", "Write a note", "Blocks", "Takes: two versions of a paragraph", "Commit and history", "Books, shelves and chapters",
           "Wings", "Tags and gatherings", "Sync with your other devices", "Protect your library"]


def guide():
    dr("Start here · Write a note · Blocks · Takes: two versions of a paragraph · Commit and history · Books, shelves and chapters · Wings · Tags and gatherings · Sync with your other devices · Protect your library",
       "The pocket guide’s ten lesson titles. Placeholders: the guide is written for the phone at the end, once the flows are built.")
    rows = ''.join('<div class="grow"><span class="lnum">%d</span>%s</div>' % (i + 1, t) for i, t in enumerate(LESSONS))
    nav = '<div class="gnav"><span class="cbtn">%s</span><span style="flex:1"></span><span class="cbtn">%s</span></div>' % (I_BACK, I_MORE)
    dr(GUIDE_META, "The pocket guide’s line on the Bookcase row.")
    head = '<div class="ghead"><div class="t">the pocket guide</div><div class="m">%s</div></div>' % dr("10 lessons · in Welcome", "The line under the guide’s title on its contents screen.")
    return nav + head + '<div class="list" style="background:var(--surface);border-top:1px solid var(--line)">%s</div>' % rows + tabs_words(1) + hi()


# =============================== A — a brand-new user ===============================
def secA():
    a1 = phone(shell(empty(EMPTY_BOOKS), n=1, bandhtml=band(welcome(reg=True))))
    a2 = phone(shell(lst(*WELCOME_ROWS), n=1, chipset=WELCOME_CHIPS, chip_on=2, bandhtml=band(tourcard(reg=True))))
    a3 = phone(guide())
    a4s = shell(lst(*WELCOME_ROWS), n=1, chipset=WELCOME_CHIPS, chip_on=2, bandhtml=band(wordscard))
    a4 = phone(a4s)
    look = P(W_LOOKLEAD) + wgrid() + '<div style="flex:1"></div>' + btn("I’ve written them down") + '<div style="height:26px"></div>'
    a5 = phone(a4s, sheet("Your twelve words", look, done=''))
    a6 = phone(a4s, sheet("Your twelve words", look, done=''),
               alert("These words won’t be shown again.", "", [("Go back", False), ("Close", True)]))
    a7 = phone(shell(lst(*NEWUSER_ROWS), n=1, chipset=WELCOME_CHIPS, chip_on=3, bandhtml=band(remcard)))
    setp = (P(W_SETLEAD, 'm') + fl("Passphrase") + fld("••••••••" + caret(), 'bad')
            + refuse("Your passphrase needs at least 12 characters.") + fl("Again") + fld("", 'ph')
            + btn("Set passphrase", 'pri off'))
    a8 = phone(shell(lst(*NEWUSER_ROWS), n=1, chipset=WELCOME_CHIPS, chip_on=3),
               sheet("Set a passphrase", setp, done='Cancel', quiet_done=True, extra=kb()))
    a9 = phone(a4s, cls='dk')
    two = ('<div class="bcard x"><div class="hd"><div class="gl">%s</div><div><div class="ln first" style="display:-webkit-box;-webkit-line-clamp:3;-webkit-box-orient:vertical;overflow:hidden">%s</div></div></div>'
           '<div class="doors"><span class="door qt">Later</span></div><span class="xx">✕</span>'
           '<div style="height:1px;background:var(--line);margin:0 -16px 12px"></div>'
           '<div class="ln" style="display:-webkit-box;-webkit-line-clamp:3;-webkit-box-orient:vertical;overflow:hidden">%s</div>'
           '<div class="doors"><span class="door">Set a passphrase…</span><span class="door qt">Not now</span></div></div>') % (I_KEY, W_WORDSCARD, W_REMINDER)
    a10 = phone(shell(lst(*NEWUSER_ROWS), n=1, chipset=WELCOME_CHIPS, chip_on=3, bandhtml=band(two)), cls='xl')

    return ('<h2>A — a brand-new user’s first open (FR-1, ruled)</h2>'
            '<p class="lede">Her ruling: the first open is the Bookcase and the capture box with nothing in front; the app’s asks arrive as cards above the capture box, one at a time. '
            'It is also CastleRules rule 2 as amended: the twelve words are shown “never before the first screen”. Today the phone shows the words first and never asks for a passphrase at all.</p>'
            + row(
        opt(a1, "A1", "First open.", "She installed Variorum and opened it. The library was made quietly (Standard, rule 8) and no words were shown; the first look makes the ones she records (rule 2). "
            "The Bookcase and the capture box are live at once; she can just type. One card sits in the band: the welcome card, with the phone’s one question as its two doors. "
            "<b>I already use Variorum</b> opens sign-in (B1). <b>I’m new</b> seeds the Welcome shelf, starts the short tour (A2), and retires the card for good.",
            mine=True, small="The title is the Mac’s. The sentence and “I’m new” are drafts " + NEW + "; “I already use Variorum” is her wording. The card can be ignored: if she simply writes, the Welcome shelf seeds at her first note."),
        opt(a2, "A2", "After “I’m new”: the tour’s first card.", "The Welcome shelf now holds <b>the pocket guide</b> and <b>the prince</b>. The tour is band cards, in the same place every ask of the app’s lives: one card at a time, a step count, one sentence, "
            "<b>Next</b> and <b>End tour</b>. Each card points at something on the screen she is on (here, the box under it). Nothing dims and nothing blocks; she can type through it.",
            mine=True, small="Five steps, drafted: write a note · your books · inside a note (blocks, Return) · takes · wings and the Library. The step label and “End tour” are the Mac’s words; the title, sentence and “Next” are drafts " + NEW
                             + ". The tour’s script is its own ticket; this is its first card and its shape."),
        opt(a3, "A3", "The pocket guide, as a book.", "She tapped <b>the pocket guide</b> on the Welcome shelf. It is an ordinary seeded book written for the phone: ten short lessons she can read, edit and delete. "
            "Only the contents list is drawn. The lessons are written at the end, once the flows are built, and get her wording pass.",
            mine=True, small="The ten titles are placeholders " + NEW + ". The book’s own screen (bar, rows, strip) is the books mockup’s; this frame shows only that the guide is a book and what it holds."),
        opt(a4, "A4", "After the tour: the words card.", "The band’s next card. The whole line is the door, as on the Mac; <b>Later</b> brings it back at the next launch; "
            "<b>✕</b> dismisses it and says “You can record your twelve words any time in Settings ▸ Protection.”", mine=True,
            small="Rule 2’s own sentence, with “tap here” for the Mac’s “click here” (hers to word)."),
        opt(a5, "A5", "She tapped the card: the look.", "A full sheet that cannot be swiped away. Tapping mints the words (rule 6’s act; the key does not change) and shows them once. "
            "<b>I’ve written them down</b> goes to A6. No Copy door is drawn. In the app switcher the words are covered, as secret fields are today.",
            small="Sample words, not real ones. Twelve 44 pt cells in two columns so each word can be checked with a finger."),
        opt(a6, "A6", "The warning before it closes.", "Her words: “These words won’t be shown again.” <b>Go back</b> returns to the words; <b>Close</b> ends the look, and the card retires. "
            "From then on fresh words live behind Settings ▸ Protection ▸ Record your twelve words…"),
    ) + row(
        opt(a7, "A7", "The third launch: rule 3’s ask.", "A week of journal entries later. The same card, the one home for both asks, now carries the passphrase reminder in the rule’s own sentence. "
            "<b>Set a passphrase…</b> opens A8. <b>Not now</b> puts it away; it returns weekly twice, then with “Don’t show again”. Never a popup, never a second bar.", mine=True),
        opt(a8, "A8", "Set a passphrase, keyboard up.", "The Mac’s sheet at phone size. A refusal: eight characters typed, and the line under the field says why the button is not ready. "
            "<b>Set passphrase</b> lights at twelve characters with both fields equal. The sheet closes on success and the card is gone, which is the answer."),
        opt(a9, "A4 · dark", "The band in dark.", "The room is black, the paper carries the hue, the card sits on the paper colour with the palette’s line.", st=True),
        opt(a10, "A7 · largest text", "The densest band, at xxxLarge.", "Both asks still owed (she chose Later on the words): one card, two asks, each keeping its own doors. "
            "At this size each sentence clamps to three lines and a tap on the sentence opens the ask as a sheet with the whole text. "
            "The rule a builder needs: the band never takes more than about a third of the screen, the capture box never leaves the screen, and the list keeps at least two rows.", st=True),
    ))


# =============================== B — a Mac user adding the phone ===============================
def secB():
    home_empty = shell(empty(EMPTY_BOOKS), n=1, bandhtml=band(welcome()))

    signin = (P("Sign in with your Stargazing account:") + fld(EMAIL) + fld("••••••••••••" + caret(), 'focus') + btn("Sign In")
              + btn("Create an account…", 'txt')
              + P13(dr(D_SIGNHELP, "Help line under the sign-in form, for someone whose other device does not sync yet.")))
    b1 = phone(home_empty, sheet("Sign in", signin, done='Cancel', quiet_done=True, extra=kb()))

    def join(plan, castle=False, typed='', bad=False, kbd=False, ready=False):
        body = P13("Signed in as %s." % EMAIL) + P(W_JOINLEAD) + P(plan, 'm')
        if castle:
            body += (fl("On this iPhone") + radio("Face ID", "This iPhone keeps the new key behind Face ID.", True)
                     + radio("Always ask", "No copy of the key stays on this iPhone; you type every time.") + '<div style="height:6px"></div>')
        body += fl("Your account’s passphrase") + fld((typed or '') + caret(), 'bad' if bad else 'focus')
        if bad: body += refuse("That passphrase doesn’t open this account.")
        body += btn("Or your account’s twelve words", 'txt')
        if not kbd: body += '<div style="flex:1"></div>'
        body += btn("Sync this library", 'pri' if ready else 'pri off')
        if not kbd: body += '<div style="height:26px"></div>'
        return sheet("Sync this library", body, done='Cancel', quiet_done=True, extra=kb() if kbd else '')
    b2 = phone(home_empty, join("Your account is in Standard, like this library."))
    b3 = phone(home_empty, join("Your account is in Castle, so this library goes into Castle too.", castle=True, typed="••••••••••••••••", ready=True))
    b4s = (P13("Signed in as %s." % EMAIL) + P("Your account is in Standard, like this library.", 'm') + fl("Your account’s passphrase")
           + fld("•••••••••••••" + caret(), 'bad') + refuse("That passphrase doesn’t open this account.")
           + btn("Or your account’s twelve words", 'txt') + btn("Sync this library", 'pri'))
    b4 = phone(home_empty, sheet("Sync this library", b4s, done='Cancel', quiet_done=True, extra=kb()))
    work = (P13("Signed in as %s." % EMAIL) + '<div style="height:400px"></div><div style="display:flex;gap:10px;align-items:center;justify-content:center">'
            '<i class="spin" style="width:16px;height:16px"></i><span class="p15 m" style="margin:0">Changing your library’s keys…</span></div>')
    b5 = phone(home_empty, sheet("Sync this library", work, done=''), faceid(270))

    def roundsheet(pct, count):
        top = P("Syncing your library with your account…") + '<div class="prog"><i style="width:%d%%"></i></div><div class="count">%s</div>' % (pct, count)
        body = (top + '<div class="quiet">' + P("Sync is on, and you’re in Castle now, like your account.")
                + '<div style="height:10px"></div>' + P(W_JOINWORDS, 'm') + '</div>'
                + P13(dr(D_CLOSE1, "Under the first sync’s progress: the sheet can be closed."))
                + P13(dr(D_CLOSE2, "Under the first sync’s progress: the phone syncs only while open.")))
        return sheet("Sync this library", body, done='Done')
    b6 = phone(home_empty, roundsheet(37, "Syncing — 40,000 of 108,000"))
    b7 = phone(shell(empty(dr(D_ARRIVE, "The Bookcase’s empty line while the first sync is still saving.")), n=1, status=stat("Syncing — saving 12,000 of 108,000")))
    b8 = phone(shell(lst(*HOME_WRITING), n=9, chipset=HOME_CHIPS, chip_on=2, status=stat("Synced 9:41 AM", 'ok')))
    b9 = phone(shell(lst(*HOME_WRITING), n=9, chipset=HOME_CHIPS, chip_on=2), wing_menu(0))
    e6 = bcard([(W_E6, ''), (W_E6B, 'm')], [("Use it here", False), ("Later", True)], x=True, glyph=I_KEY)
    b10 = phone(shell(lst(*HOME_WRITING), n=9, chipset=HOME_CHIPS, chip_on=2, bandhtml=band(e6)))

    taps = ('<table class="bn"><tr><th></th><th>Today (as built, audit D §4b)</th><th>Drawn here</th></tr>'
            '<tr><td>First thing shown</td><td>Twelve words for a library the join is about to replace</td><td>Her Bookcase, empty, with one card</td></tr>'
            '<tr><td>Surfaces crossed</td><td>Words card → Shelf → Settings sheet → Account sheet → Settings again → Protection screen (scrolled to the bottom) → join sheet → words moment → first-round sheet</td>'
            '<td>The Bookcase and one sheet that changes its face three times: sign in → sync this library → progress</td></tr>'
            '<tr><td>Taps, not counting typing</td><td>About 12</td><td>3: <b>I already use Variorum</b> on the card, <b>Sign In</b>, <b>Sync this library</b> (plus Face ID’s glance under Castle, and <b>Done</b> if she wants the sheet gone)</td></tr>'
            '<tr><td>Typing</td><td>Email, password, one account secret</td><td>The same. Rule 14 keeps the account secret: joining always types one.</td></tr>'
            '<tr><td>Words shown on the way</td><td>A throwaway set (“did it change my 12 words?”)</td><td>None. Words are shown only at a look (rule 2), and a landed join retires the look’s card (rule 2, R-510-28).</td></tr></table>')

    return ('<h2>B — someone who already uses Variorum adds this phone (FR-2, ruled)</h2>'
            '<p class="lede">The launch’s central road. Her ruling: “I already use Variorum” lives in the welcome card on the Bookcase, with no screen in front of it, and joining is one sheet: sign in, the Standard or Castle arm, honest sync progress.</p>'
            '<p class="ruled"><b>Chosen:</b> the welcome card (“I think I already use variorum welcome card is probably fine”). No longer drawn: a full-screen fork before the Bookcase, and a Settings-only road.</p>'
            + row(
        opt(b1, "B1", "She tapped “I already use Variorum”.", "A sheet over the Bookcase, keyboard up, the Account sheet’s own words. <b>Sign In</b> checks the account. <b>Create an account…</b> swaps to the create form "
            "(a new account has nothing to join; it lands in D3). <b>Cancel</b> returns to A1 with the card still there.", mine=True,
            small="The grey help line is a draft " + NEW + ": many people have no account yet, because sync is what makes one useful. Its twin is a door on the Mac that names the phone (W-227)."),
        opt(b2, "B2", "Signed in: the sheet becomes the join. Standard arm.", "The same sheet, a new face; she never sees Settings. The app has read the account: it already syncs, and it is in Standard. "
            "She types the account’s passphrase once (rule 14). <b>Or your account’s twelve words</b> swaps the field for the words box. <b>Sync this library</b> lights when something is typed.", mine=True,
            small="The lead is the built sentence, verbatim. On a phone whose own words were never shown, its last clause is what read as “did it change my 12 words?” — a wording call for her pass (LP-10)."),
        opt(b3, "B3", "The same face when the account is in Castle.", "One more choice, the built one: how this iPhone opens the library from now on. Face ID is preselected; <b>Always ask</b> keeps no key on the phone (rule 9). "
            "Passphrase typed, the button is ready.", mine=True),
        opt(b4, "B4", "A refusal, keyboard up.", "A wrong passphrase. The field wears the alarm edge and the built sentence names the account, not the library. Nothing has changed; she types again or switches to the words. "
            "The sheet scrolls its lead away under the keyboard so the field, the refusal and the button stay in view."),
        opt(b5, "B5", "Castle: the keys change, Face ID is enrolled.", "After <b>Sync this library</b> under Castle the library’s keys change as it follows the account into Castle, and the Face ID item is made, so iOS asks for a glance. "
            "The sheet stays up through it; today the whole screen drops and returns here."),
        opt(b6, "B6", "The first sync, with honest progress.", "The sheet’s third face. The Mac’s sync row words, large: a count that moves, a bar, and what the join did (the posture, then rule 7’s told-plainly sentence, read while she waits). "
            "<b>Done</b> is live throughout and closes the sheet; sync carries on.", mine=True,
            small="The two grey lines under the card are drafts " + NEW + ": the sheet can be closed, and the phone syncs only while it is open."),
    ) + row(
        opt(b7, "B7", "She closed the sheet while it saves.", "The Bookcase, still empty, because rows land when the save finishes. The line under the wing’s name carries the count (“saving” is the row’s own word for this phase). "
            "The empty state says where her books are, so an empty screen is never read as lost writing.",
            small="The empty line is a draft " + NEW + ". On her library the save runs four to five minutes and holds the writer (VX-497); until that lands, the capture box should say it is waiting rather than accept a note and hang."),
        opt(b8, "B8", "Landed: her Bookcase.", "The Home wing, her shelves, her books. Nine dots under the wing name: all nine wings came with the account. The line under the wing’s name reads the row’s own “Synced 9:41 AM” for a moment, then clears. "
            "No message is added: her books arriving is the answer."),
        opt(b9, "B9", "Nine wings.", "She tapped the wing name. The shell’s dropdown lists the nine with their counts; a swipe on the name steps between them. Drawn to show the road ends in the real library, not a flat list."),
        opt(b10, "B10", "If she joined with the twelve words.", "Rule 3’s last clause: the account’s passphrase has never been typed on this iPhone. The band says so in the built sentences. "
            "<b>Use it here</b> asks for the passphrase once. <b>Later</b> and <b>✕</b> put it away; it returns from the third launch and a week after each dismissal, with no “don’t show again”."),
    ) + '<h3>What the road costs</h3>' + taps)


# =============================== C — sync status afterwards ===============================
def secC():
    home = lambda **k: shell(lst(*HOME_WRITING), n=9, chipset=HOME_CHIPS, chip_on=2, **k)
    c1 = phone(home(status=stat("Synced 9:38 AM", 'ok')))
    c2 = phone(home(status=stat("Waiting to sync (offline) · 3 pending", 'off')))
    stalled = bcard([("Sync incomplete — some changes haven’t arrived yet", '')], [("Sync now", False), ("Later", True)])
    c3 = phone(home(bandhtml=band(stalled)))
    menu = ('<div class="dim"></div><div class="menu r"><div class="srhead"><b>Synced 9:38 AM</b><span>Signed in as %s</span></div>'
            '<div class="mi s">Sync now</div><div class="mi s">Settings</div><div class="mi s">Archived</div><div class="mi s" style="border:0">Trash</div></div>') % EMAIL
    c4 = phone(home(), menu)
    table = ('<table class="bn"><tr><th>The sync row says (built words)</th><th>Where the phone shows it</th><th>Door</th></tr>'
             '<tr><td>Synced 9:38 AM</td><td>The line under the wing’s name for a moment after a round, then nothing; always at the head of the ⋯ menu and in Settings</td><td>Pull down, or ⋯ ▸ Sync now</td></tr>'
             '<tr><td>Syncing… · Syncing — 40,000 of 108,000 · — saving 12,000 of 108,000</td><td>The line under the wing’s name, for as long as it is true</td><td>none needed</td></tr>'
             '<tr><td>Waiting to sync (offline) · 3 pending</td><td>The line under the wing’s name, for as long as it is true</td><td>none; it syncs when the network returns</td></tr>'
             '<tr><td>Another change landed mid-sync — retrying</td><td>The line under the wing’s name</td><td>none</td></tr>'
             '<tr><td>Sync incomplete — some changes haven’t arrived yet · Sync error</td><td>A band card</td><td>Sync now</td></tr>'
             '<tr><td>Sync locked — this iPhone hasn’t unlocked your account’s sync keys</td><td>A band card</td><td>Protection…</td></tr>'
             '<tr><td>Sync paused — this account’s encryption keys were replaced</td><td>A band card</td><td>Protection… (the follow lives there; W-204)</td></tr>'
             '<tr><td>Sync paused — this library belongs to a different account</td><td>A band card</td><td>Account…</td></tr>'
             '<tr><td>Sync paused — Variorum needs an update</td><td>A band card, with “Your account syncs in a newer format than this version reads. Nothing is lost while sync is paused.”</td><td>None exists on the phone today; it needs one (the App Store page)</td></tr>'
             '<tr><td>Signed out · Sync isn’t on for this library yet</td><td>Section D</td><td>Sign in… · Turn on sync…</td></tr></table>')
    return ('<h2>C — where sync status lives afterwards</h2>'
            '<p class="lede">Today the only sign of sync is a row inside Settings. Three tiers, calm first: <b>nothing at rest</b>; a <b>quiet line under the wing’s name</b> while there is something to say that needs nothing from her; '
            'a <b>band card</b> when sync needs her hands. The full row with its doors stays in Settings and heads the ⋯ menu. The line sits in the row the wing dots already own, so nothing below it ever moves. '
            'Every sentence here is the sync row’s own.</p>'
            + row(
        opt(c1, "C1", "Caught up.", "A round just finished: the line reads the row’s own “Synced 9:38 AM” for a moment, then clears, and the masthead is as calm as before. Pulling down on any root list runs a round (the phone’s Sync now)."),
        opt(c2, "C2", "Offline.", "No network. The line stays while it is true and counts what is waiting to go up, in the row’s words. She keeps writing; nothing is asked of her."),
        opt(c3, "C3", "A round failed.", "Sync needs her, so it is a card in the band, where every ask of the app’s lives. <b>Sync now</b> tries again; <b>Later</b> puts the card away until the next launch. "
            "The states that need Protection or the Account sheet use the same card with that door."),
        opt(c4, "C4", "The full row, one tap away.", "The masthead’s ⋯ menu leads with the sync row and its act, and is where Settings lives. "
            "Lock library now is not in this menu: her ruling puts it on the home screen as a lock icon (drawn in <code>home-wings-capture.html</code>) and in Protection (the lock file)."),
    ) + '<h3>Every state of the row, and its home</h3>' + table)


# =============================== D — signed out, and empty ===============================
def secD():
    d1 = phone(shell(empty(EMPTY_BOOKS, door=dr(D_DOORLINE, "The empty Bookcase’s door line once the welcome card has been answered.")), n=1))
    out = bcard([(dr(D_OUT1, "Band card: signed out of a library that syncs."), ''), (dr(D_OUT2, "Band card: second line, signed out."), 'm')],
                [("Sign in…", False), ("Later", True)])
    d2 = phone(shell(lst(*HOME_WRITING), n=9, chipset=HOME_CHIPS, chip_on=2, bandhtml=band(out)))
    setup = (P13("Signed in as %s." % EMAIL) + P("Your library’s passphrase and twelve words become the account’s. Nothing is replaced.")
             + P("Your account starts in Standard, like this library.", 'm')
             + P("This library has no passphrase yet. Choose one — your account is locked under your passphrase and your twelve words.")
             + fld("New passphrase", 'ph') + fld("Again", 'ph') + fld("Your twelve words", 'ph')
             + btn("Record your twelve words…", 'txt') + '<div style="flex:1"></div>' + btn("Turn on sync", 'pri off') + '<div style="height:26px"></div>')
    d3 = phone(shell(lst(*NEWUSER_ROWS), n=1, chipset=WELCOME_CHIPS, chip_on=3), sheet("Turn on sync", setup, done='Cancel', quiet_done=True))
    return ('<h2>D — signed out, and a phone-only account</h2>' + row(
        opt(d1, "D1", "Signed out, nothing written, the card answered.", "The standing fallback. The empty state’s second line is a door: it opens B1, the same single road (W-228).",
            small="The door line is a draft " + NEW + "."),
        opt(d2, "D2", "Signed out of a library that syncs.", "She signed out, or the session ended. Nothing syncs, and the app says so where its asks live. <b>Sign in…</b> opens B1 (signing back in is a join, rule 16). "
            "The longer choice, “use this library on this iPhone only”, stays in Protection.",
            small="Both lines are drafts " + NEW + "."),
        opt(d3, "D3", "A new account, made on the phone: turn on sync.", "Her words: “some people will only use the phone app.” She took <b>Create an account…</b> at B1, so there is nothing to join; this library’s passphrase and words become the account’s (rule 7). "
            "The built set-up, at phone sizes. A library with no passphrase chooses one here. If she never recorded her words, <b>Record your twelve words…</b> runs the look (A5) without leaving the sheet, so the road has no dead end.",
            small="Afterwards a Mac, or another phone, joins this account exactly as this phone joined in B2."),
    ))


# =============================== E — Settings: look, help, crash reports ===============================
def secE():
    home = shell(lst(*HOME_WRITING), n=9, chipset=HOME_CHIPS, chip_on=2)
    e1 = phone(home, sheet("Settings", settings_body(196, castle=False, reg=True), flush=True))
    e2 = phone(home, sheet("Settings", settings_body(470, castle=False, crash=False), flush=True))
    e3 = phone(home, sheet("Settings", settings_body(196, castle=False), flush=True), cls='dk')
    return ('<h2>E — Settings: the look, help, and crash reports</h2>'
            '<p class="lede">Three rulings land in the Settings list. The whole list (its top, Protection, the largest text size) is drawn in <code>lock-and-protection.html</code>; these frames are the same list, scrolled.</p>'
            + row(
        opt(e1, "E1 · LK-1, LK-2", "Settings ▸ Look.", "Her ruling: “follow the library but if the phone has dark mode on, that shouldn’t change what your mac is like.” <b>Voice</b> (Study or Terminal) and <b>Palette</b> are the library’s: "
            "they read the synced setting, and changing one here changes it on every device, which the line under them says. <b>Appearance</b> is this iPhone’s own: System, Light or Dark, kept on the device and never synced.", mine=True,
            small="All the labels and both lines are drafts " + NEW + ". Today the phone follows the system only and offers two voice rows with ticks."),
        opt(e2, "E2 · tour, guide, crash reports", "Settings, scrolled to Help and Crash reports.", "<b>Take the tour</b> starts the band-card tour again from its first card (A2), from any wing. <b>Open the pocket guide</b> opens the seeded book (A3), and puts it back if she deleted it. "
            "<b>Crash reports</b>: in v1, in the app, and off until she turns it on. One switch, the Mac’s label, and one line saying what on means.", mine=True,
            small="“Crash reports” and “Collect crash reports” are the Mac’s words. The line under the switch is a draft " + NEW + ", cut down from the Mac’s longer promise. What the reports hold and how one is sent is the build ticket’s to settle with her (W-216)."),
        opt(e3, "E1 · dark", "The same list with the iPhone in dark.", "Appearance set to System and the phone in dark mode: this iPhone is dark. Her Mac is not touched, and the voice and palette are still the library’s.", st=True),
    ))


def notes():
    return ('<h2>Build notes</h2><table class="bn">'
            '<tr><th>Screen</th><th>Delivers</th><th>Stands on</th><th>New</th><th>Do not get wrong</th><th>Size</th></tr>'
            '<tr><td>A1 · the band and the welcome card</td><td>W-194 (absorbs VM-23), W-222 in part, W-201 (FR-1 and FR-2, ruled)</td><td>Shared <code>WordsBand</code> for the band’s ledger; the Mac’s <code>TourOfferCard</code> record and never-returns law (Mac-local today: hoist owed)</td>'
            '<td>The phone face of the band; the welcome card’s two doors</td><td>Ruled: nothing in front of the Bookcase and the capture box. Flip <code>ProtectionRoad.wordsCardAtCreation</code> off for the phone so nothing is drawn before <code>.ready</code>. One card at a time, in a fixed order: welcome, the tour, then the words and passphrase card, then sync asks. The band sits above the capture box and never over it.</td><td>M</td></tr>'
            '<tr><td>A2 · the phone tour</td><td>W-222 (the tour half)</td><td>The Mac’s <code>TourEngine</code> and <code>TourScript</code> shapes once hoisted; a phone script of its own</td><td>Tour steps as band cards; re-entry from Settings ▸ Help</td>'
            '<td>Ruled: a short phone tour as band cards, re-enterable from Help. No dimming, no ring that blocks touches; she can type through it. End tour retires it; Help starts it again. Its closing hands on to the words card (rule 2 allows the words at the tutorial’s close or from the card; here it is the card).</td><td>M</td></tr>'
            '<tr><td>A3 · the pocket guide as a book</td><td>W-219, W-218, W-220, W-221, W-223 in part</td><td><code>MobileTutorialSeeder</code>; Shared Prince seeder</td><td>A Release seed moment and a Help row in Settings</td>'
            '<td>Ruled: rewritten for the phone as a seeded book, written at the end once the flows are built; her wording pass. Seed only on a fresh store that has never held writing; a store that will join an account must not seed first (the join’s dedupe is the fallback, not the plan).</td><td>M</td></tr>'
            '<tr><td>A4–A6 · the words card and the look</td><td>W-194, W-193 (moot once the card is gone)</td><td>Shared <code>WordsBand</code>, <code>WordsLookModel</code>, <code>ProtectionWords.wordsLook*</code></td><td>Face only</td>'
            '<td>Nothing stores the words; the look mints them (rule 2), so never render the sheet twice for one tap. The words stay privacy-marked so the app switcher covers them as it does today. No swipe-to-dismiss: only the button, then the warning. The card retires at Close, and at a landed set-up, join or move.</td><td>S</td></tr>'
            '<tr><td>A7–A8 · rule 3’s reminder and Set a passphrase</td><td>W-195</td><td>Shared <code>PassphraseReminderModel</code>, <code>SetPassphraseModel</code></td><td>Face only</td>'
            '<td>The schedule is the model’s (third launch, weekly twice, then “Don’t show again”; and at the first launch after a quiet road failed). Same card as the words, never a second bar, never an alert. No message after the passphrase is set: the sheet closes and the card is gone.</td><td>S</td></tr>'
            '<tr><td>B1–B6 · the one sheet</td><td>W-201, W-228, W-204 in part</td><td>Shared <code>AuthViews</code>, <code>RoadAccountModel</code>, <code>RoadAccountFaces</code> (join and set-up), <code>ProtectionWords.join*</code>, <code>firstRound*</code></td>'
            '<td>The composition: sign-in, join and first round as three faces of one sheet, opened from the card</td><td>Ruled: one sheet. After sign-in, read the account’s situation and show the join arm or the set-up arm; never drop her on Settings. Rule 14: a join always types one account secret; there is no quiet join. '
            'The Castle arm re-keys: keep the sheet standing through it (today the screen goes down and comes back). The told-plainly sentence of rule 7 must still be said; here it rides the progress face.</td><td>M</td></tr>'
            '<tr><td>B6–B8 · honest progress</td><td>W-202</td><td>Shared <code>SyncStatusViews</code> (<code>progressCount</code>: “N of M”, “saving …”, “N so far”)</td><td>The empty-state line during a first round</td>'
            '<td>Use the row’s own sentence, never a second wording. With no server total the count reads “40,000 so far” and the bar is indeterminate. The save phase holds the writer (VX-497): gate or word the capture box until it lands. No added line when the sync lands.</td><td>S</td></tr>'
            '<tr><td>B10 · the account-passphrase card</td><td>W-196</td><td>Shared <code>WordsBand</code> (the E6 row), <code>ProtectionWords.accountPassphraseCard*</code></td><td>Face only</td><td>No “don’t show again”: it returns until a passphrase is typed here.</td><td>S</td></tr>'
            '<tr><td>C1–C4 · sync status</td><td>W-202, W-204</td><td>Shared <code>SyncStatusViews</code> (<code>SyncRowFace</code>: label, kind, doors)</td><td>The line under the wing’s name; the card for states with a door; the ⋯ menu’s head</td>'
            '<td>The line lives in the wing-dots row so it never shifts a list. With nine dots the longest sentence fits at the default size with a few points to spare; at larger sizes the dots give way to the line while it shows. It is read-only; its door is the ⋯ menu (a 44 pt target). Cards only for states that carry a door. The out-of-date state has no door on the phone and needs one.</td><td>M</td></tr>'
            '<tr><td>D1–D3 · signed out and set-up</td><td>W-228, part of W-201</td><td>Shared <code>RoadAccountFaces</code> (set-up arm), <code>ProtectionWords.account*</code></td><td>The door line; the look reachable from inside the set-up sheet</td>'
            '<td>The set-up asks for the twelve words; a phone-only user who never recorded them must be able to do so from the sheet.</td><td>S</td></tr>'
            '<tr><td>E1 · voice, palette, appearance</td><td>W-213; the Look rows of W-211 (LK-1, LK-2, ruled)</td><td>Core <code>Queries.ThemeSettings</code> / <code>AppearanceQueries</code> (<code>theme_voice</code>, <code>theme_palette</code>, synced); a device-local appearance preference</td><td>The three rows and their two lines</td>'
            '<td>Ruled: voice and palette follow the library’s synced setting; light or dark stays each device’s own and is never written to the library. A change to voice or palette here is the library’s change and reaches the Mac.</td><td>S</td></tr>'
            '<tr><td>E2 · the tour and guide doors; crash reports</td><td>W-219’s door, W-222’s re-entry, W-216 (SC-6, ruled in v1), W-226’s row</td><td>The Mac’s <code>CrashReporting</code> and <code>DiagnosticsCopy</code> as the model to follow (Mac-local; the phone needs its own collector)</td><td>Two Help rows; the Crash reports group</td>'
            '<td>Ruled: in-app crash reporting, opt-in, in v1. Off by default; nothing is ever sent on its own. The line under the switch must stay true of what is built.</td><td>M</td></tr></table>'
            '<p class="lede" style="margin-top:18px"><b>Drafted words.</b> Every line marked <span class="new">draft</span> in a caption is a designer’s wording and is listed in <code>design/wording-list-2.md</code> for her pass. Every other sentence is the build’s or the Mac’s, verbatim.</p>'
            '<p class="lede"><b>Added to the sizing sheet’s vocabulary:</b> the <b>band card</b> (paper, radius 12, the palette’s take line, SF 15 sentence, SF 15 semibold doors on a 44 pt row, ✕ in a 44 pt cell), with a step line for the tour; '
            'the <b>line under the wing’s name</b> (SF 13 corrected muted, trailing in the wing-dots row); the <b>form field</b> (52 tall, radius 12, a 2 pt accent or alarm edge); the <b>full-width button</b> (52 tall, radius 12, SF 17 semibold); '
            'the <b>progress bar</b> (6 pt, wash and accent); the <b>switch</b>. All sit on the five type sizes, the 44 pt minimum and the spacing scale.</p>')


intro = ('<p class="lede"><b>VM-44 mockup round, revised after sitting 1 — getting in.</b> A new user’s first open, someone who already uses Variorum adding this phone, where sync status lives afterwards, the signed-out states, and the Settings rows three rulings add. '
         'Study voice under the sea-glass palette, light; one frame in dark and one at the largest text size. The shell around each screen (wing masthead, shelf chips, one-line capture box, word tabs) is the home mockup’s, kept as a thin layer here.</p>'
         '<p class="q">“I want to get the mobile app done and out there so that people can start actually using variorum synced between devices (since very few people have multiple macs).”</p>'
         '<p class="ruled"><b>What she chose.</b> First open: the Bookcase and the capture box with nothing in front; the app’s asks are cards above the box, one at a time. “I already use Variorum” lives in the welcome card. Joining is one sheet. '
         'The pocket guide is a seeded book, written for the phone at the end. A short phone tour as band cards, re-enterable from Help. Voice and palette follow the library; light or dark is each device’s own. Crash reporting in the app, opt-in. '
         'No message after an ordinary act.</p>'
         '<p class="lede">Read as flows, left to right. A green tag marks a frame drawn as she ruled it; a dark green tag a state (dark, largest text). Nothing here changes a Castle rule or anything stored: only acts, doors and words.</p>')

page('first-run-and-joining.html', 'VM-44 — first run and joining', intro, secA() + secB() + secC() + secD() + secE() + notes())
