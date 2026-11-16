# VM-44 — lock-and-protection.html. REVISED after sitting 1 (plans/sitting-1-rulings.md):
# backgrounding keeps the library open for the dial's minutes (5 · 10 · 30 · never, default 10; Castle only); a full close always locks;
# the app switcher shows the page as today (the cover frames are gone); after an unlock she lands on the home screen with a button back to
# where she was; Lock library now is a lock icon on the home screen (the home mockup's) plus the Protection section; leaving Castle works
# on the phone; the Private eye shows only where a mark exists and the AI-marks switch is on.
from base import *

# ---------- the app's own words (verbatim from Shared/Protection/ProtectionWords.swift and ProtectionCopy.swift, as the phone renders them) ----------
W_LEAD = "Enter your passphrase or your twelve words to open your library."
W_IDLE = "Lock your library after you haven’t used Variorum for:"
W_IDLESUB_MAC = "Switching to another app doesn’t lock it; time away does. Variorum always locks when your iPhone sleeps or its screen locks."
W_LOCKNOW = "Locking closes the library and forgets its key until you unlock it again."
W_KEYSTONE = "While Variorum is open and unlocked, everything in it is readable — that is what open means. Locking is how you end that."
W_WORDSSEC = "Variorum doesn’t keep your twelve words, so looking makes new ones for you to write down. Your library’s key doesn’t change."
W_KEYDOORS = "Every copy of this library opens with your current passphrase or words; on this iPhone, its quiet road opens it too, if it still holds that copy’s key."
W_SYNCEDPASS = "This library syncs with your account, so your account’s passphrase changes with it, on every device."
W_PROMISE = "Castle is one promise: no quiet road through Apple, ever, on any device of the account."
W_USESTD_LEAD = "Leaving Castle hands everything to Standard: your library gets a new key, with a fresh Apple road and this iPhone’s on-device road back."
# rule 12's leave sentence is hers and names "this Mac"; a test pins the app's words to the rule. The phone's device noun is her wording call (LP-7).
W_LEAVE_PHONE = "Your library and all your backups will open through your Apple account and this iPhone again; if you want Castle-era writing to stay Castle-protected, don’t leave."

# ---------- this file's drafted lines ----------
D_IDLESUB = "Switching apps doesn’t lock it. Time away does. Closing Variorum always locks it."
D_BACK = "Back to where you were"
D_LOCKNOW = "Lock library now"   # the Mac's "Lock Library Now", in sentence case

I_EYE = '<svg width="16" height="16" viewBox="0 0 20 20" fill="none" stroke="currentColor" stroke-width="1.7" stroke-linecap="round" stroke-linejoin="round"><path d="M2.5 10S5.5 4.5 10 4.5 17.5 10 17.5 10 14.5 15.5 10 15.5 2.5 10 2.5 10Z"/><circle cx="10" cy="10" r="2.2"/></svg>'
I_RET = '<svg width="20" height="20" viewBox="0 0 20 20" fill="none" stroke="currentColor" stroke-width="1.8" stroke-linecap="round" stroke-linejoin="round"><path d="M8 5 3.5 9.5 8 14M3.5 9.5H12a4.5 4.5 0 010 9h-1"/></svg>'

BOOKCASE = shell(lst(*HOME_WRITING), n=9, chipset=HOME_CHIPS, chip_on=2)
NOTE_T = "On keeping a commonplace book"
NOTE_P1 = "I started copying sentences into a notebook the winter I stopped trusting my memory for them."
NOTE_P2 = ("The first ones were other people’s: a line from a letter, a recipe note, something overheard on the ferry. "
           "Later they were mine, and the book stopped being a record and became a place to think")
NOTE_P3 = "A commonplace book is not a diary. Nothing in it has to be true of the day it was written."


def lobby(face=True, typed='', bad='', words=False, wordtext='', kbd=False, opening=False, cls=''):
    tight = ' tight' if kbd else ''
    h = '<div class="lobby%s"><div class="lk">%s</div><h4>Open your library</h4>' % (tight, I_LOCK)
    if opening:
        h += ('<div style="height:40px"></div><div style="display:flex;gap:10px;align-items:center;justify-content:center">'
              '<i class="spin" style="width:16px;height:16px"></i><span class="p15 m" style="margin:0">Opening your library…</span></div></div>')
        return h + hi()
    h += '<p class="lead">%s</p>' % W_LEAD
    if words:
        h += fld('<div>' + wordtext + caret() + '</div>' if wordtext else "Your twelve words, separated by spaces", ('area ' + ('bad' if bad else 'focus')) if wordtext else 'area ph')
        if bad: h += refuse(bad)
        h += btn("Open with the words", 'pri')
    else:
        if face: h += btn(I_FACE.format(22) + "Unlock with Face ID", 'pri') + '<div class="orl">or</div>'
        h += fld((typed + caret()) if typed else "Passphrase", ('bad' if bad else 'focus') if typed else 'ph')
        if bad: h += refuse(bad)
        h += btn("Open", 'sec' if face else 'pri') + btn("Use your twelve words instead", 'txt')
    h += '</div>'
    return h + (kb() if kbd else hi())


def notescreen(kbd=True, third=False, private=False):
    nav = ('<div class="nav"><span class="cbtn">%s</span><div class="r"><span class="cbtn">%s</span><span class="cbtn">%s</span></div></div>'
           % (I_BACK, I_SEARCH, I_MORE))
    chips_ = ''
    if private is not None and private is not False:
        cs = '<span>Essays</span>' + ('<span>%s%s</span>' % (I_EYE, dr("Private", "Chip on a note marked Private on a Mac (shown only where the mark exists and the AI-marks switch is on).")) if private == 'on' else '')
        chips_ = '<div class="nchipr">%s</div>' % cs
    body = '<div class="note"><h4>%s</h4>%s<p>%s</p><p>%s%s</p>%s</div>' % (
        NOTE_T, chips_, NOTE_P1, NOTE_P2, caret() if kbd else '.', '<p>%s</p>' % NOTE_P3 if third else '')
    return nav + body + (kb() if kbd else hi())


def backcard():
    return ('<div class="bcard go"><span class="gl">%s</span><div class="mid"><div class="t1">%s</div><div class="t2">%s</div></div><span class="xx">✕</span></div>'
            % (I_RET, dr(D_BACK, "The button on the home screen after an unlock: returns to the note or screen she left (her words: “back to where i was”, not final)."), NOTE_T))


# =============================== A — the lobby ===============================
def secA():
    l1 = phone(lobby(face=True), faceid(628))
    l2 = phone(lobby(face=False, typed="••••••••••••••", bad="That passphrase doesn’t open this library.", kbd=True))
    l3 = phone(lobby(words=True, wordtext="harbor velvet orchard signal meadow lantern copper winter gather pencil island",
                     bad="There are twelve words — you entered 11.", kbd=True))
    l4 = phone(lobby(opening=True))
    l5 = phone(lobby(face=True), cls='dk')
    return ('<h2>A — the lock screen: unlocking</h2>'
            '<p class="lede">The lock screen is built and shared with the Mac (<code>ProtectionLobbyModel</code>); what changes is its size and when she meets it. '
            'It appears only when a Castle library is locked: a fresh start of the app, the dial’s minutes having passed, or Lock library now. A Standard library never shows it while a quiet road works (rule 8). Every sentence is the build’s.</p>'
            + row(
        opt(l1, "L1", "Face ID arm.", "She opened Variorum and the library is locked. The screen asks for Face ID on its own, once, as it does today; the system’s glance is in progress. "
            "No note or book is drawn behind it: the page is built only after the library opens. If the glance fails, the button asks again and the passphrase field is right there."),
        opt(l2, "L2", "Passphrase arm, with a refusal.", "A phone set to <b>Always ask</b> keeps no key at all (rule 9), so there is no Face ID button and the keyboard comes up at once. "
            "A wrong passphrase: the field wears the alarm edge and the built sentence says so. <b>Open</b> tries again; <b>Use your twelve words instead</b> swaps the field (L3)."),
        opt(l3, "L3", "Twelve-words arm, with a refusal.", "A three-line box in her own face, so twelve words wrap where she can check them. Eleven were typed; the built sentence counts them. "
            "The other built refusals use the same line: an unknown word is named, and a failed checksum says to compare with what she wrote down."),
        opt(l4, "L4", "Opening.", "Face ID matched or the secret was right. The store opens off the main thread; this line stands for the moment it takes, then she lands on the home screen (section B)."),
        opt(l5, "L1 · dark", "The lock screen in dark.", "Black room, the accent lifted, the primary button’s label in the paper ink.", st=True),
    ))


# =============================== B — staying open ===============================
def secB():
    g1 = phone(notescreen(kbd=True))
    inner = '<div class="scr"><div style="height:54px;flex:none"></div>%s</div>' % notescreen(kbd=True)
    g2 = phone('<div class="swside l"></div><div class="swside r"></div>'
               '<div class="swlabel"><span class="appicon">%s</span>Variorum</div><div class="swcard">%s</div>' % (mark(26), inner), cls='sys')
    g3 = phone(notescreen(kbd=True), zone(292, 196, "1", 'b'))
    g4 = phone(lobby(face=True), faceid(628))
    g5 = phone(shell(lst(*HOME_WRITING), n=9, chipset=HOME_CHIPS, chip_on=2, bandhtml=band(backcard())))
    g6 = phone(notescreen(kbd=False, third=True), zone(292, 196, "1", 'b'))
    g7 = phone(BOOKCASE)
    tl = ('<div class="tl">'
          '<div class="who">She switches apps</div><div class="bar"><span class="open" style="flex:5">Up to the dial’s minutes (10 by default): the library stays open</span>'
          '<span class="lock" style="flex:3">Past the dial: locked on return, before any page shows</span><span class="ask" style="flex:3">Face ID or a secret → the home screen, with a button back</span></div>'
          '<div class="who">She closes Variorum</div><div class="bar"><span class="lock" style="flex:8">Always locked: the key lives only in the running app’s memory, so ending the app ends it</span>'
          '<span class="ask" style="flex:3">Face ID or a secret → the home screen</span></div>'
          '<div class="who">Lock library now</div><div class="bar"><span class="lock" style="flex:8">Locked at once; pending typing is saved first</span>'
          '<span class="ask" style="flex:3">Face ID or a secret → the home screen, with a button back</span></div>'
          '<div class="who">The iPhone itself locks</div><div class="bar"><span class="cov" style="flex:11">Not ruled yet (LP-2). The lock work’s first ticket is a probe of what iOS tells the app when the phone locks; until it reports, only the minutes above apply and no sentence promises more.</span></div>'
          '<div class="who">A Standard library</div><div class="bar"><span class="open" style="flex:11">Never locks and never shows the lock screen: Standard has quiet roads, so a lock there would be theatre (rule 8). None of this section applies (“this only matters for castle, right?” — yes).</span></div>'
          '</div>')
    return ('<h2>B — staying open for a few minutes</h2>'
            '<p class="q">“app staying unlocked for a few minutes damn.” · “fully closing the app rather than just backgrounding it should make the library lock automatically though.” · “and a lock now button should be there like the mac.”</p>'
            '<p class="lede">Today a Castle library locks every time Variorum leaves the screen, and she comes back to the lock screen and then to the shelf with her note gone. '
            'Her rulings give the phone the Mac’s reading: switching apps does not lock; time away does; closing the app always does. '
            'No key is written anywhere new, so no Castle rule moves. What each leaving does:</p>' + tl
            + '<p class="ruled"><b>Chosen.</b> The existing dial (5 · 10 · 30 · never), default 10. The app switcher shows the page as today (“Show the page as today”). '
              'After an unlock: “the home screen but there should be a ‘back to where i was’ button”. No longer drawn: a covered app switcher, and landing straight back on the note.</p>'
            + row(
        opt(g1, "G1", "She is writing, under Castle.", "Mid-sentence in an essay; a message arrives and she switches to Messages. On leaving, the app saves her typing and runs one sync round, as today. It does not lock."),
        opt(g2, "G2 · LP-3", "The app switcher: the page, as today.", "What iOS shows of Variorum while it waits in the background: her page, with only the secret fields covered (the twelve words, a passphrase being typed). "
            "Nothing new is built here; today’s cover of marked fields stays exactly as it is.", mine=True),
        opt(g3, "G3", "Back inside the dial’s minutes.", "Four minutes later she returns. Nothing happens: no lock screen, no glance, no reload. <span class=\"n2\">1</span> The same note, the same scroll position, the caret where she left it, the keyboard up. "
            "This is the whole point of the ruling, and it must feel like any other app.", mine=True),
        opt(g4, "G4", "Back after the minutes passed.", "Twenty minutes later, with the dial at 10. The app checks the time on return and locks before drawing anything, so the first thing on screen is the lock screen, never a flash of the page. "
            "Face ID is asked on its own (an Always ask phone shows L2).", mine=True),
        opt(g5, "G5 · LP-4", "After the unlock: the home screen, with a way back.", "She lands on the home screen, as after any fresh start. One card sits in the band above the capture box: a button back to where she was, naming the note. "
            "One tap returns her (G6). <b>✕</b> puts it away; so does opening anything else. It never returns once used or dismissed.", mine=True,
            small="“Back to where you were” is a draft " + NEW + " (her words: “doesn’t have to be worded exactly like that”). The lock icon also sits on this screen; its place is drawn in <code>home-wings-capture.html</code>."),
        opt(g6, "G6", "She taps it: back in the note.", "The same note, at the same place <span class=\"n2\">1</span>, keyboard down until she taps. "
            "If the note was deleted or moved by a sync while locked, the button names its book instead, or is not shown.", mine=True),
        opt(g7, "G7", "After a full close: the home screen, no button.", "She swiped Variorum away, or the phone ended it. The library is locked, and after the unlock she is on the home screen with nothing in the band. "
            "The place she left is held in the running app’s memory only and is never written down, so a closed app has none to offer.", q=True,
            small="Open, drawn the most defensible way: keeping the place across a full close would mean writing it somewhere outside the locked library, and nothing stored is being changed. If she wants the button after a full close too, that is a new decision."),
    ))


# =============================== C — Settings ===============================
def secC():
    s1 = phone(BOOKCASE, sheet("Settings", settings_body(0, reg=True), flush=True))
    s2 = phone(BOOKCASE, sheet("Settings", settings_body(470), flush=True))
    s3 = phone(BOOKCASE, sheet("Settings", settings_body(0), flush=True), cls='xl')
    return ('<h2>C — Settings, as a real scrolling list</h2>'
            '<p class="lede">Today Settings is a fixed stack of 11.5 pt words that cannot scroll, reachable only from the shelf, with two “Protection…” rows stacked whenever sync is locked or not on yet (VM-27), '
            'and a temporary “Record edit trace” row shipping in Release. Here it is one grouped, scrolling sheet at the sizing sheet’s sizes, opened from the masthead’s ⋯ on any root screen. '
            'The first group is the library: sync status with its act, the account, and <b>one</b> Protection row that says the posture.</p>'
            + row(
        opt(s1, "S1", "Settings, top.", "She tapped ⋯ ▸ Settings. Rows are 52 pt, labels SF 17, details SF 13; section names sit on the room, rows on the paper. "
            "<b>Sync now</b> runs a round. <b>Account…</b> opens the Account sheet. <b>Protection…</b> pushes section D inside this sheet, so Done returns her to where she was. "
            "Look: voice and palette follow the library, light or dark is this iPhone’s own (her ruling; drawn again in <code>first-run-and-joining.html</code>, E1).",
            small="The sync row’s other states use the same row: the sentence changes and the trailing act becomes that state’s door (Sign in…, Protection…, Account…). Group names and the new rows are drafts " + NEW + "."),
        opt(s2, "S2", "Settings, scrolled.", "The rest: the Writing row (which holds the formatting-bar choice drawn in <code>note-write.html</code>, C8), tags, Help with the tour and the pocket guide, and Crash reports, off until she turns it on. "
            "Debug-only rows (the edit trace, the 100k fixture, the spike) are gone from Release (W-214)."),
        opt(s3, "S1 · largest text", "Settings at xxxLarge.", "Today this screen is the one that cannot grow. Here rows grow with their text and the list scrolls; nothing is clipped, and every row is still one full-width target.", st=True),
    ))


# =============================== D — Protection ===============================
def prot_inner(castle=True, joined=True, xl=False, reg=False):
    d = dr if reg else (lambda l, w: l)
    h = sech("Sync", first=True)
    if joined:
        h += sgroup(srow("This library syncs with your account.", sub="Signed in as %s. Synced 9:38 AM" % EMAIL),
                    srow("Sync now", cls='act'), srow("Stop syncing here…", cls='act'), srow("Sign out…", cls='act'))
    else:
        h += sgroup(srow("This library doesn’t sync.", sub="Signed in as %s. Your account already syncs." % EMAIL),
                    '<div style="padding:4px 20px 12px">%s</div>' % btn("Sync this library…", 'pri'))
    if castle:
        sub = d(D_IDLESUB, "The line under the lock dial: what locks the library and what does not (the Mac’s line also promises a lock when the phone sleeps, which waits on LP-2).")
        lock = d(D_LOCKNOW, "The lock button in Protection (the Mac’s “Lock Library Now”, in sentence case).")
        if xl:
            dial = srow("Lock after time away", val="10 minutes ⌄")
        else:
            dial = ('<div class="srow pad"><div class="lab">%s</div><div class="dial"><span>5 minutes</span><span class="on">10 minutes</span><span>30 minutes</span><span>never</span></div>'
                    '<div class="sub" style="margin:6px 0 4px">%s</div></div>') % (W_IDLE, sub)
        h += (sech("On this iPhone")
              + sgroup(srow("Face ID opens your library on this iPhone.", val='<span style="color:var(--accent);font:400 15px var(--sans)">Use Always ask</span>'),
                       dial, srow(lock, sub=W_LOCKNOW, cls='act', glyph=I_LOCKS))
              + (stext(sub) if xl else ''))
    h += (sech("Your passphrase")
          + (sgroup(srow("Change passphrase…", cls='act'), srow("Reset forgotten passphrase…", cls='act')) + stext(W_SYNCEDPASS) if (castle or joined)
             else sgroup(srow("Set a passphrase…", cls='act')))
          + sech("Your twelve words") + sgroup(srow("Record your twelve words…", cls='act')) + stext(W_WORDSSEC)
          + '<div style="height:16px"></div>' + sgroup(srow("Check my passphrase or twelve words…", cls='act')) + stext(W_KEYDOORS))
    if castle:
        h += (sech("You’re in Castle.") + sgroup(srow("Use Standard…", cls='act'), srow("Replace All Keys…", cls='act')) + stext(W_PROMISE))
    else:
        h += sech("You’re in Standard.") + sgroup(srow("Use Castle…", cls='act'))
    h += stext(W_KEYSTONE) + '<div style="height:48px"></div>'
    return h


def prot(scroll=0, cls='', extra='', **k):
    bar = '<div class="scrollbar2" style="top:%dpx;height:%dpx"></div>' % (6 + scroll * 0.5, 380)
    body = '<div class="scrl"><div style="margin-top:-%dpx">%s</div>%s</div>' % (scroll, prot_inner(**k), bar)
    return phone(BOOKCASE, sheet("Protection", body, flush=True, back=True), extra, cls=cls)


def secD():
    p1 = prot(0, reg=True)
    p2 = prot(640)
    p3 = prot(0, castle=False, joined=False)
    p4 = prot(240, cls='xl', xl=True)
    p5 = prot(0, cls='dk')
    leave = (P(W_USESTD_LEAD) + '<div class="quiet">' + P(dr(W_LEAVE_PHONE, "Rule 12’s leave sentence with “this iPhone” for “this Mac”. The rule’s own sentence is hers and names the Mac; the phone’s wording waits for her pass (LP-7).")) + '</div>'
             + fl("Your passphrase") + fld("••••••••••••••••") + fl("Your twelve words") + fld("Your twelve words, separated by spaces", 'area ph')
             + '<div style="flex:1"></div>' + btn("Use Standard", 'pri off') + '<div style="height:26px"></div>')
    p6 = phone(BOOKCASE, sheet("Use Standard", leave, done='Cancel', quiet_done=True))
    work = ('<div style="height:330px"></div><div style="display:flex;gap:10px;align-items:center;justify-content:center">'
            '<i class="spin" style="width:16px;height:16px"></i><span class="p15 m" style="margin:0">Changing your library’s keys…</span></div>')
    p7 = phone(BOOKCASE, sheet("Use Standard", work, done=''))
    p8 = prot(430, castle=False, joined=True)
    return ('<h2>D — the Protection screen, cleaned up</h2>'
            '<p class="lede">The built screen follows the Mac pane’s order, which puts the one door a new device needs (“Sync this library…”) last, under four sections of 11.5 pt captions, '
            'and leaves a Castle user with “You’re in Castle.” and no door. The same shared faces, re-ordered for a phone: <b>sync first</b>, then <b>what this iPhone does</b> (the gate, the dial, the lock), '
            'then the secrets, then the posture with its doors, and the keystone sentence at the foot.</p>'
            + row(
        opt(p1, "P1", "Protection, a Castle library that syncs.", "Settings ▸ Protection…. The Sync group says the state and carries its acts. <b>On this iPhone</b> is new on the phone (VM-25): "
            "the gate row (<b>Use Always ask</b> switches it), the dial at its default of 10 minutes, and <b>Lock library now</b> with its one sentence. This section shows only under Castle.", mine=True,
            small="The dial’s question is the Mac’s sentence. The line under it is a draft " + NEW + ": the Mac’s own line also says Variorum “always locks when your iPhone sleeps or its screen locks”, and that half waits on the LP-2 probe. "
                  "“Lock library now” is the Mac’s label in sentence case."),
        opt(p2, "P2", "Protection, scrolled.", "The secrets: change or reset the passphrase, record new words, check either. Then the posture as a section of its own with its doors under it: "
            "<b>Use Standard…</b> (P6) and <b>Replace All Keys…</b>. The keystone line closes the screen (VM-26)."),
        opt(p3, "P3", "A Standard library that hasn’t joined yet.", "Someone who dismissed the welcome card and came the long way. Signed in, account already syncing: the screen leads with the join as a full-width button, not a link at the bottom. "
            "No “On this iPhone” section: a Standard library has no lock, so the dial and the lock are not rendered, as on the Mac."),
        opt(p4, "P1 · largest text", "“On this iPhone” at xxxLarge.", "The densest screen in this file. Sentences wrap, rows grow, the list scrolls. The four-way dial no longer fits across, so at accessibility sizes it becomes a menu row "
            "(“Lock after time away · 10 minutes”), the built label and choices, and its line moves below the group.", st=True),
        opt(p5, "P1 · dark", "Protection in dark.", "Rows on the dark paper, section names on the black room, the selected dial segment on the paper.", st=True),
    ) + '<h3>Leaving Castle, on the phone (LP-7, ruled)</h3>'
        '<p class="lede">Her ruling: “if you can go into castle on phone, you should be able to leave it.” Rule 12 is the contract: leaving types the passphrase and the twelve words, and hands everything to Standard. '
        'The door is drawn; its sentences are the Mac’s, and the ones marked <span class="held">her wording pass</span> wait for her before they ship on a phone.</p>'
        + row(
        opt(p6, "P6", "She taps Use Standard….", "One sheet, the Mac’s confirm at phone size. What leaving does (the built lead, with this iPhone named). Then rule 12’s leave sentence, set apart so it is read. "
            "Both secrets are typed (rule 12), and <b>Use Standard</b> lights when both are there. <b>Cancel</b> changes nothing.", mine=True,
            small="Both sentences " + HELD + ". The leave sentence is rule 12’s, which says “this Mac”; it is drawn with “this iPhone”, and that change is hers to word. "
                  "It also says “all your backups” on a phone that keeps none of its own (W-208). The title, the two field labels and the button are the Mac’s."),
        opt(p7, "P7", "The keys change.", "The built line, while the library gets its new Standard key. The sheet stays up through it. If anything fails the library is still under its old key and the sheet says so (the built “Nothing changed.” sentences)."),
        opt(p8, "P8", "Afterwards.", "The sheet closes on the Protection screen, which now reads “You’re in Standard.” with <b>Use Castle…</b> under it, and has no “On this iPhone” section: a Standard library does not lock. "
            "That change is the answer; no message is added. Her other devices follow out quietly, each with its own notice (rule 12).", mine=True,
            small="The Mac shows a line here (“You’re in Standard now.”). Under her receipts ruling the phone lets the screen say it."),
    ))


# =============================== E — where Lock library now lives ===============================
def secE():
    e1 = prot(120, extra=zone(536, 76, "1", 'b').replace('style="', 'style="z-index:9;'))
    e2 = phone(lobby(face=True))
    return ('<h2>E — Lock library now (LP-5, ruled)</h2>'
            '<p class="lede">Her ruling: “there should be a lock icon at the top of the homescreen or in the bottom bar or something”, besides the Protection section. Two doors, both only under Castle.</p>'
            '<p class="ruled"><b>The lock icon on the home screen</b> is drawn in <code>home-wings-capture.html</code> (the home mockup owns that screen and where the icon sits). '
            '<b>The button in Protection</b> is drawn here. No longer drawn: a row in the ⋯ menu, a Settings row, a Home Screen quick action.</p>'
            + row(
        opt(e1, "E1", "The button, beside its dial.", "<span class=\"n2\">1</span> Settings ▸ Protection ▸ On this iPhone. The button sits under the dial that decides when the library locks by itself, with the Mac’s one sentence saying what locking does.", mine=True),
        opt(e2, "E2", "After the press, from either door.", "Typing is saved, the library closes, its key is forgotten, and the lock screen stands. Unlocking lands on the home screen with the button back to where she was (G5).", mine=True),
    ))


# =============================== F — the Private eye ===============================
def secF():
    f1 = phone(notescreen(kbd=False, third=True, private='on'))
    f2 = phone(notescreen(kbd=False, third=True, private='off'))
    return ('<h2>F — the Private eye (LP-8, ruled)</h2>'
            '<p class="lede">Her words: “follow the same only show it if an mcp is active elsewhere - users who don’t have the mac app shouldn’t see it.” The phone cannot know whether an AI client is approved on a Mac, because grants never sync (and no ticket will make them). '
            'What does sync is the mark itself and the library’s AI-marks switch. So the rule is: the eye shows only where a note or book carries the mark and that switch is on.</p>'
            + row(
        opt(f1, "F1", "A note she marked Private on her Mac.", "The note wears one more chip, the eye and the word. It is read here, not set: Private is set on the Mac in v1, and the note’s menu shows it as a read-only row (<code>note-write.html</code>, E7). "
            "The same eye sits on the note’s row in the Library and on a Private book’s row.", mine=True,
            small="“Private” is the mark’s own name on the Mac; as a chip on the phone it is a draft " + NEW + "."),
        opt(f2, "F2", "The same library with the switch off, or a library with no marks.", "No eye anywhere. A phone-only user has never set a mark, so this is the only state she ever sees. The phone has no switch of its own for it: it follows the library’s.", mine=True),
    ))


def notes():
    return ('<h2>Build notes</h2><table class="bn">'
            '<tr><th>Screen</th><th>Delivers</th><th>Stands on</th><th>New</th><th>Do not get wrong</th><th>Size</th></tr>'
            '<tr><td>L1–L4 · the lock screen</td><td>Sizing only (W-001’s layer applied to <code>MobileRoadFaces</code>); W-199 wording stays hers</td><td>Shared <code>ProtectionLobbyModel</code>, <code>ProtectionOpenRoad</code>, <code>ProtectionWords.lobby*</code></td><td>Nothing</td>'
            '<td>Keep the single automatic Face ID ask on appear and on return to active. Never build the page behind the lock screen. The words box is three lines in the prose face and must not autocorrect or capitalise.</td><td>S</td></tr>'
            '<tr><td>G1, G3, G4 · the dial’s minutes</td><td>W-187 (her high priority; the shape and LP-1, ruled)</td><td>Phone <code>MobileRelock</code> / <code>MobileRelockPolicy</code> over Shared <code>DeviceSettings.idleLockMinutes</code>; the dead <code>locksOnReturn</code> arm becomes the live one</td><td>No new brain</td>'
            '<td>Ruled: backgrounding keeps the library open for the dial’s minutes (5 · 10 · 30 · never, default 10), only under Castle; fully closing always locks. <code>locksOnLeaving</code> stops locking; the leaving flush and sync round stay. On return, compare the time away with the dial <b>before</b> any content draws; lock first, then show the lock screen. '
            'The key stays in process memory only: nothing is persisted that says “unlocked”, so a swipe-away, an eviction or a crash all come back locked. “never” on the dial still locks on a full close.</td><td>M</td></tr>'
            '<tr><td>The phone itself locking</td><td>W-190 (LP-2, unruled)</td><td>Nothing today observes it</td><td>A device probe of the protected-data notifications</td>'
            '<td>The probe is the lock work’s first ticket. Until it reports and she rules, no sentence on the phone promises a lock when the phone locks (the dial’s line is drawn without it); the minutes are what applies. No undocumented notification.</td><td>S</td></tr>'
            '<tr><td>G2 · the app switcher</td><td>W-192 closes as ruled (LP-3: as today); W-193 only if the words card still draws outside <code>.ready</code></td><td>Phone <code>SnapshotPrivacy</code>, unchanged</td><td>Nothing</td>'
            '<td>Ruled: the switcher shows the page as today. Do not widen the cover. Keep the marked fields (the twelve words, secret fields) covered as they are; the words look must stay inside that cover when it moves into the band’s sheet.</td><td>—</td></tr>'
            '<tr><td>G5–G7 · the home screen and the way back</td><td>W-191 (LP-4, ruled)</td><td><code>MobileShellView</code>’s tab and navigation paths, held above the tree the lock tears down; the band (Shared <code>WordsBand</code>’s ledger) for the card’s place</td><td>An in-memory place record (tab, stacks, note, scroll); the band card with the button</td>'
            '<td>Ruled: after an unlock she lands on the home screen, with a button back to where she was. The record is memory only: never written to disk, never restored after the process ends (G7, drawn as open). One tap restores tab, stack, note and scroll. The card goes when used, dismissed, or when she opens anything else. If the note was deleted or moved while locked, name its book or show no card.</td><td>M</td></tr>'
            '<tr><td>S1–S3 · Settings</td><td>W-211, W-217 (absorbs VM-27), W-214, W-213, W-219 and W-226’s rows, W-216’s group</td><td><code>MobileSettingsView</code>; Shared <code>SyncStatusViews</code> for the first row</td><td>The grouped scrolling list; the ⋯ door from every root screen</td>'
            '<td>One Protection row, always: the sync row’s door and the standing button must never both render. Protection pushes inside the sheet. Rows grow with Dynamic Type; nothing is a fixed-height word. No Lock row at the list’s root (the icon and the Protection button are the two doors).</td><td>M</td></tr>'
            '<tr><td>P1–P5 · Protection</td><td>W-188, W-189 (absorb VM-25), W-200 (absorbs VM-26), W-201, part of W-208</td><td>Shared <code>RoadCrossingsModel</code> (<code>setIdleMinutes</code>, <code>lockNow</code>, <code>canLock</code>), <code>RoadGateRow.idleChoices</code>, <code>ProtectionCopy.idle*</code> / <code>lockNow*</code> / <code>keystoneOpenMeansReadable</code>; <code>MobileProtectionScreen</code> and <code>MobileProtectionDoors</code></td><td>Face only: the section, and the new order</td>'
            '<td>The dial does nothing until W-187 lands, so they ship together. “On this iPhone” renders only when <code>canLock</code> (Castle). The join leads the screen whenever it is owed.</td><td>M</td></tr>'
            '<tr><td>P6–P8 · leaving Castle</td><td>W-208’s held door (LP-7, ruled)</td><td>Shared <code>RoadCrossingsModel</code> and the crossing confirm (<code>ProtectionWords.useStandard*</code>, <code>leaveSentence</code>, <code>crossing*</code>)</td><td>The phone face of the leave confirm</td>'
            '<td>Ruled: it works on the phone. Rule 12 unchanged: both secrets typed; a new Standard key carrying every earlier key; the Apple road and this iPhone’s on-device road back. The leave sentence is pinned to the rule’s text by a test and names the Mac: the phone’s sentence waits for her wording pass before the door ships. '
            'A crash leaves the old state or the new one (rule 20). No message after: the screen’s posture line is the answer.</td><td>M</td></tr>'
            '<tr><td>E1–E2 · Lock library now</td><td>W-189 (LP-5, ruled)</td><td>Shared <code>RoadCrossingsModel.lockNow</code> → <code>AppBootstrap.lock()</code></td><td>The Protection button (here); the home screen’s lock icon (the home mockup)</td>'
            '<td>The lock’s own teardown already flushes typing and commits; keep it. Not rendered under Standard. Both doors call the one act.</td><td>S</td></tr>'
            '<tr><td>F1–F2 · the Private eye</td><td>W-058 (LP-8, ruled)</td><td>Core store truth (<code>container.ai_private_at</code>, <code>reading.ai_private_at</code>, synced) and the synced <code>ai_marks</code> setting</td><td>The chip and the row eye</td>'
            '<td>Ruled: draw the eye only where a mark exists and the AI-marks switch is on. Read no grants (they never sync) and add no phone switch. Read-only in v1: no phone door writes the mark. Reads only for the rows drawn (P1).</td><td>S</td></tr></table>'
            '<p class="lede" style="margin-top:18px"><b>Words.</b> Every sentence on these screens is the build’s, verbatim, except the lines marked <span class="new">draft</span> (listed in <code>design/wording-list-2.md</code>) and the two leave sentences marked <span class="held">her wording pass</span>. '
            'Shared labels that are title-cased today (“Replace All Keys…”) stay as built; bringing them to sentence case is a wording item for her pass (LP-10).</p>'
            '<p class="lede"><b>Added to the sizing sheet’s vocabulary:</b> the <b>settings row</b> (52 minimum, SF 17 label, SF 13 detail, a trailing value in SF 15 or an act in the accent, hairline from the gutter) in full-width groups on the paper under section names on the room; '
            'the <b>dial</b> (a 44 pt segmented control on the wash, SF 15, the chosen segment on the paper; a menu row at accessibility sizes); the <b>lock screen</b> layout (64 pt mark, Iowan 24 title, 52 pt buttons and fields); '
            'the <b>way-back card</b> (a band card that is one row: a glyph, the button’s words, the note’s name, ✕). The form field, full-width button, switch and band card are shared with the first-run file.</p>')


intro = ('<p class="lede"><b>VM-44 mockup round, revised after sitting 1 — the lock and protection.</b> The unlock, what staying open for a few minutes looks like, Settings as a real list, the Protection screen re-ordered, leaving Castle, Lock library now, and the Private eye. '
         'Study voice under the sea-glass palette, light; the lock screen and Protection also in dark; Settings and Protection at the largest text size. The shell behind the sheets is the home mockup’s, kept as a thin layer.</p>'
         '<p class="ruled"><b>What she chose.</b> Backgrounding keeps the library open for the dial’s minutes (5 · 10 · 30 · never, default 10; it only matters under Castle); fully closing the app always locks. '
         'The app switcher shows the page as today. After an unlock: the home screen, with a button back to where she was. Lock library now: a lock icon on the home screen, and the Protection section. '
         'Leaving Castle works on the phone. The Private eye shows only where a mark exists and the AI-marks switch is on; grants do not sync. Still unruled: what happens when the phone itself locks (LP-2), until a probe reports.</p>'
         '<p class="lede">These are a writing app’s privacy faces. Nothing here changes a Castle rule or anything stored: the key stays where it is today, in the running app’s memory. Only acts, doors and words move. '
         'A green tag marks a frame drawn as she ruled it; an amber tag marks the one point still open; a dark green tag a state (dark, largest text).</p>')

page('lock-and-protection.html', 'VM-44 — the lock and protection', intro, secA() + secB() + secC() + secD() + secE() + secF() + notes())
