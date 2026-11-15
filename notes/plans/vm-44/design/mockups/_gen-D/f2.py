from base import *

# ---------- the app's own words (verbatim from Shared/Protection/ProtectionWords.swift and ProtectionCopy.swift, as the phone renders them) ----------
W_LEAD = "Enter your passphrase or your twelve words to open your library."
W_IDLE = "Lock your library after you haven’t used Variorum for:"
W_IDLESUB = "Switching to another app doesn’t lock it; time away does. Variorum always locks when your iPhone sleeps or its screen locks."
W_LOCKNOW = "Locking closes the library and forgets its key until you unlock it again."
W_KEYSTONE = "While Variorum is open and unlocked, everything in it is readable — that is what open means. Locking is how you end that."
W_WORDSSEC = "Variorum doesn’t keep your twelve words, so looking makes new ones for you to write down. Your library’s key doesn’t change."
W_KEYDOORS = "Every copy of this library opens with your current passphrase or words; on this iPhone, its quiet road opens it too, if it still holds that copy’s key."
W_SYNCEDPASS = "This library syncs with your account, so your account’s passphrase changes with it, on every device."
W_PROMISE = "Castle is one promise: no quiet road through Apple, ever, on any device of the account."

BOOKCASE = shell(lst(*HOME_WRITING), n=9, chipset=HOME_CHIPS, chip_on=2)
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

def notescreen(kbd=True, third=False, cls=''):
    nav = ('<div class="nav"><span class="cbtn">%s</span><div class="r"><span class="cbtn">%s</span><span class="cbtn">%s</span></div></div>'
           % (I_BACK, I_SEARCH, I_MORE))
    body = '<div class="note"><h4>On keeping a commonplace book</h4><p>%s</p><p>%s%s</p>%s</div>' % (
        NOTE_P1, NOTE_P2, caret(), '<p>%s</p>' % NOTE_P3 if third else '')
    return nav + body + (kb() if kbd else hi())

# =============================== A — the lobby ===============================
def secA():
    l1 = phone(lobby(face=True), faceid(628))
    l2 = phone(lobby(face=False, typed="••••••••••••••", bad="That passphrase doesn’t open this library.", kbd=True))
    l3 = phone(lobby(words=True, wordtext="harbor velvet orchard signal meadow lantern copper winter gather pencil island",
                     bad="There are twelve words — you entered 11.", kbd=True))
    l4 = phone(lobby(opening=True))
    l5 = phone(lobby(face=True), cls='dk')
    return ('<h2>A — the lobby: unlocking</h2>'
            '<p class="lede">The lobby is built and shared with the Mac (<code>ProtectionLobbyModel</code>); what changes is its size and when she meets it. '
            'It appears only when a Castle library is locked: a cold launch, a lapsed window, the phone having locked, or Lock Library Now. A Standard library never shows it while a quiet road works (rule 8).</p>'
            + row(
        opt(l1, "L1", "Face ID arm.", "She opened Variorum and the library is locked. The lobby asks for Face ID on its own, once, as it does today; the system’s glance is in progress. "
            "No note or book is drawn behind it: the page is built only after the library opens. If the glance fails, the button asks again and the passphrase field is right there."),
        opt(l2, "L2", "Passphrase arm, with a refusal.", "A phone set to <b>Always ask</b> keeps no key at all (rule 9), so there is no Face ID button and the keyboard comes up at once. "
            "A wrong passphrase: the field wears the alarm edge and the built sentence says so. <b>Open</b> tries again; <b>Use your twelve words instead</b> swaps the field (L3)."),
        opt(l3, "L3", "Twelve-words arm, with a refusal.", "A three-line box in her own face, so twelve words wrap where she can check them. Eleven were typed; the built sentence counts them. "
            "The other built refusals use the same line: an unknown word is named, and a failed checksum says to compare with what she wrote down."),
        opt(l4, "L4", "Opening.", "Face ID matched or the secret was right. The store opens off the main thread; this line stands for the moment it takes, then she lands where LP-4 says (section B)."),
        opt(l5, "L1 · dark", "The lobby in dark.", "Black room, the accent lifted, the primary button’s label in the paper ink."),
    ))

# =============================== B — staying open ===============================
def secB():
    g1 = phone(notescreen(kbd=True))
    def switcher(cover):
        if cover:
            inner = '<div class="scr"><div class="cover">%s</div></div>' % mark(120)
        else:
            inner = '<div class="scr"><div style="height:54px;flex:none"></div>%s</div>' % notescreen(kbd=True)
        return phone('<div class="swside l"></div><div class="swside r"></div>'
                     '<div class="swlabel"><span class="appicon">%s</span>Variorum</div><div class="swcard">%s</div>' % (mark(26), inner), cls='sys')
    g2a = switcher(False)
    g2b = switcher(True)
    g3 = phone(notescreen(kbd=True), zone(292, 196, "1", 'b'))
    g4 = phone(lobby(face=True), faceid(628))
    g5 = phone(notescreen(kbd=False, third=True), zone(292, 196, "1", 'b'))
    g5a = phone(BOOKCASE)
    tl = ('<div class="tl">'
          '<div class="who">She switches apps</div><div class="bar"><span class="open" style="flex:5">Up to the dial’s minutes (10 by default): the library stays open</span>'
          '<span class="lock" style="flex:3">Past the dial: locked on return, before any page shows</span><span class="ask" style="flex:3">Face ID or a secret → the note she left</span></div>'
          '<div class="who">The iPhone locks</div><div class="bar"><span class="lock" style="flex:8">Locks with the phone wherever iOS reports it (LP-2, a device probe decides the promise); otherwise the minutes above apply</span>'
          '<span class="ask" style="flex:3">Face ID or a secret → the note she left</span></div>'
          '<div class="who">She closes Variorum</div><div class="bar"><span class="lock" style="flex:8">Always locked: the key lives only in the running app’s memory, so ending the app ends it</span>'
          '<span class="ask" style="flex:3">Face ID or a secret → the Bookcase</span></div>'
          '<div class="who">Lock Library Now</div><div class="bar"><span class="lock" style="flex:8">Locked at once; pending typing is saved first</span>'
          '<span class="ask" style="flex:3">Face ID or a secret → the note she left</span></div>'
          '<div class="who">A Standard library</div><div class="bar"><span class="open" style="flex:11">Never locks and never shows the lobby: Standard has quiet roads, so a lock there would be theatre (rule 8). None of this section applies.</span></div>'
          '</div>')
    return ('<h2>B — staying open for a few minutes</h2>'
            '<p class="q">“app staying unlocked for a few minutes damn.” · “fully closing the app rather than just backgrounding it should make the library lock automatically though.” · “and a lock now button should be there like the mac.”</p>'
            '<p class="lede">Today a Castle library locks every time Variorum leaves the screen, and she comes back to the lobby and then to the shelf with her note gone. '
            'Her rulings give the phone the Mac’s reading, the one the shared sentence already states: switching apps does not lock; time away does. '
            'No key is written anywhere new, so no Castle rule moves. What each leaving does:</p>' + tl
            + row(
        opt(g1, "G1", "She is writing, under Castle.", "Mid-sentence in an essay; a message arrives and she switches to Messages. On leaving, the app saves her typing and runs one sync round, as today. It does not lock."),
        opt(g2a, "LP-3 (a)", "The app switcher: the page, as today.", "What iOS shows of Variorum while it waits in the background: her page, with only the secret fields covered. "
            "With a window of minutes, that page sits readable in the switcher for as long as the library is open.", q=True),
        opt(g2b, "LP-3 (b) · my pick", "The app switcher: covered, under Castle.", "Whenever Variorum is not in front, a Castle library’s screen is replaced by the room and the mark. Nothing of hers is in the picture. "
            "The cost is honest: the cover also shows while Control Center or a notification is pulled over the app. Standard keeps (a).", mine=True,
            small="LP-3 (c), a cover only after the window lapses, cannot be built: iOS takes the picture at leaving, before anyone knows how long she will be away."),
        opt(g3, "G3", "Back inside the window.", "Four minutes later she returns. Nothing happens: no lobby, no glance, no reload. <span class=\"n2\">1</span> The same note, the same scroll position, the caret where she left it, the keyboard up. "
            "This is the whole point of the ruling, and it must feel like any other app."),
        opt(g4, "G4", "Back after the window lapsed.", "Twenty minutes later, with the dial at 10. The app checks the time on return and locks before drawing anything, so the first thing on screen is the lobby, never a flash of the page. "
            "Face ID is asked on its own (an Always ask phone shows L2)."),
        opt(g5, "LP-4 (b) · my pick", "…and then the note she left.", "After the glance she is back in the same note, on the same tab, at the same place <span class=\"n2\">1</span>, keyboard down until she taps. "
            "The place is remembered in memory only; nothing about it is written while the library is locked, so a full close forgets it and opens on the Bookcase.", mine=True),
        opt(g5a, "LP-4 (a)", "…or the Bookcase, as today.", "The unlock rebuilds the app from the top and she finds her note again by hand. This, more than the glance, is what makes today’s lock feel like a punishment.", q=True),
    ))

# =============================== C — Settings ===============================
def settings_body(scroll=0, castle=True):
    lib = [srow("Synced 9:38 AM", sub="Signed in as %s" % EMAIL, val='<span style="color:var(--accent);font:400 17px var(--sans)">Sync now</span>'),
           srow("Account…", chev=True),
           srow("Protection…", val="Castle" if castle else "Standard", chev=True)]
    if castle: lib.append(srow("Lock Library Now", cls='act', glyph=I_LOCKS))
    inner = (sech("Library", first=True) + sgroup(*lib)
             + sech("Look") + sgroup(srow("Terminal", cls='voice', check=False), srow("Study", cls='voice', check=True), srow("Appearance", val="System", chev=True))
             + sech("Writing") + sgroup(srow("Writing and commits", sub="Segmentation, commit cadence, seams", chev=True))
             + sech("Tags") + sgroup(srow("Manage Tags", chev=True))
             + sech("Help") + sgroup(srow("Open the pocket guide", chev=True), srow("What’s new", chev=True), srow("Acknowledgments", chev=True))
             + '<div class="stext" style="text-align:center;padding:20px 20px 48px">Variorum for iPhone</div>')
    bar = '<div class="scrollbar2" style="top:%dpx;height:%dpx"></div>' % (6 + scroll * 0.72, 520)
    return '<div class="scrl"><div style="margin-top:-%dpx">%s</div>%s</div>' % (scroll, inner, bar)

def secC():
    s1 = phone(BOOKCASE, sheet("Settings", settings_body(0), flush=True))
    s2 = phone(BOOKCASE, sheet("Settings", settings_body(282), flush=True))
    s3 = phone(BOOKCASE, sheet("Settings", settings_body(0), flush=True), cls='xl')
    return ('<h2>C — Settings, as a real scrolling list</h2>'
            '<p class="lede">Today Settings is a fixed stack of 11.5 pt words that cannot scroll, reachable only from the shelf, with two “Protection…” rows stacked whenever sync is locked or not on yet (VM-27), '
            'and a temporary “Record edit trace” row shipping in Release. Here it is one grouped, scrolling sheet at the sizing sheet’s sizes, opened from the masthead’s ⋯ on any root screen. '
            'The first group is the library: sync status with its act, the account, <b>one</b> Protection row that says the posture, and under Castle the lock.</p>'
            + row(
        opt(s1, "S1", "Settings, top.", "She tapped ⋯ ▸ Settings. Rows are 52 pt, labels SF 17, details SF 13; section names sit on the room, rows on the paper. "
            "<b>Sync now</b> runs a round. <b>Account…</b> opens the Account sheet. <b>Protection…</b> pushes section D inside this sheet, so Done returns her to where she was. "
            "<b>Lock Library Now</b> appears only under Castle (LP-5 (b)).", mine=True,
            small="The sync row’s other states use the same row: the sentence changes and the trailing act becomes that state’s door (Sign in…, Protection…, Account…)."),
        opt(s2, "S2", "Settings, scrolled.", "The rest: the pocket guide’s door and What’s new (FR-5, FR-3) under Help, Acknowledgments, tags. The Writing row is a placeholder for the settings another mockup owns (W-212). "
            "Debug-only rows (the edit trace, the 100k fixture, the spike) are gone from Release (W-214)."),
        opt(s3, "S1 · largest text", "Settings at xxxLarge.", "Today this screen is the one that cannot grow. Here rows grow with their text and the list scrolls; nothing is clipped, and every row is still one full-width target."),
    ))

# =============================== D — Protection ===============================
def prot_inner(castle=True, joined=True, xl=False):
    h = sech("Sync", first=True)
    if joined:
        h += sgroup(srow("This library syncs with your account.", sub="Signed in as %s. Synced 9:38 AM" % EMAIL),
                    srow("Sync now", cls='act'), srow("Stop syncing here…", cls='act'), srow("Sign out…", cls='act'))
    else:
        h += sgroup(srow("This library doesn’t sync.", sub="Signed in as %s. Your account already syncs." % EMAIL),
                    '<div style="padding:4px 20px 12px">%s</div>' % btn("Sync this library…", 'pri'))
    if castle:
        if xl:
            dial = srow("Lock after time away", val="10 minutes ⌄")
        else:
            dial = ('<div class="srow pad"><div class="lab">%s</div><div class="dial"><span>5 minutes</span><span class="on">10 minutes</span><span>30 minutes</span><span>never</span></div>'
                    '<div class="sub" style="margin:6px 0 4px">%s</div></div>') % (W_IDLE, W_IDLESUB)
        h += (sech("On this iPhone")
              + sgroup(srow("Face ID opens your library on this iPhone.", val='<span style="color:var(--accent);font:400 15px var(--sans)">Use Always ask</span>'),
                       dial, srow("Lock Library Now", sub=W_LOCKNOW, cls='act', glyph=I_LOCKS))
              + (stext(W_IDLESUB) if xl else ''))
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

def prot(scroll=0, cls='', **k):
    bar = '<div class="scrollbar2" style="top:%dpx;height:%dpx"></div>' % (6 + scroll * 0.5, 380)
    body = '<div class="scrl"><div style="margin-top:-%dpx">%s</div>%s</div>' % (scroll, prot_inner(**k), bar)
    return phone(BOOKCASE, sheet("Protection", body, flush=True, back=True), cls=cls)

def secD():
    p1 = prot(0)
    p2 = prot(640)
    p3 = prot(0, castle=False, joined=False)
    p4 = prot(240, cls='xl', xl=True)
    p5 = prot(0, cls='dk')
    return ('<h2>D — the Protection screen, cleaned up</h2>'
            '<p class="lede">The built screen follows the Mac pane’s order, which puts the one door a Mac user needs (“Sync this library…”) last, under four sections of 11.5 pt captions, '
            'and leaves a Castle user with “You’re in Castle.” and no door. The same shared faces, re-ordered for a phone: <b>sync first</b>, then <b>what this iPhone does</b> (the gate, the dial, the lock), '
            'then the secrets, then the posture, and the keystone sentence at the foot. Every sentence is the build’s.</p>'
            + row(
        opt(p1, "P1", "Protection, a Castle library that syncs.", "Settings ▸ Protection…. The Sync group says the state and carries its acts. <b>On this iPhone</b> is new on the phone (VM-25): "
            "the gate row (<b>Use Always ask</b> switches it), the idle dial at its default of 10 minutes, and <b>Lock Library Now</b> with its one sentence. "
            "The dial’s caption is the shared sentence, which this design finally makes true on the phone.", mine=True,
            small="LP-1: the existing per-device dial and default (5 · 10 · 30 · never, 10). LP-6: one default for Face ID and Always ask phones. The caption’s last sentence promises a lock when the phone locks; it ships only as the LP-2 probe allows."),
        opt(p2, "P2", "Protection, scrolled.", "The secrets: change or reset the passphrase, record new words, check either. Then the posture as a section of its own with its doors under it: "
            "<b>Use Standard…</b> (held today for her phone wording, LP-7) and <b>Replace All Keys…</b>. The keystone line closes the screen (VM-26)."),
        opt(p3, "P3", "A Standard library that hasn’t joined yet.", "A Mac user who dismissed the welcome card and came the long way. Signed in, account already syncing: the screen leads with the join as a full-width button, not a link at the bottom. "
            "No “On this iPhone” section: a Standard library has no lock, so the dial and the lock are not rendered, as on the Mac."),
        opt(p4, "P1 · largest text", "“On this iPhone” at xxxLarge.", "The densest screen in this file. Sentences wrap, rows grow, the list scrolls. The four-way dial no longer fits across, so at accessibility sizes it becomes a menu row "
            "(“Lock after time away · 10 minutes”), the built label and choices, and its caption moves below the group."),
        opt(p5, "P1 · dark", "Protection in dark.", "Rows on the dark paper, section names on the black room, the selected dial segment on the paper."),
    ))

# =============================== E — where Lock now lives ===============================
def secE():
    menu = ('<div class="dim"></div><div class="menu r"><div class="srhead"><b>Synced 9:38 AM</b><span>Signed in as %s</span></div>'
            '<div class="mi s">Sync now</div><div class="mi s">Settings</div><div class="mi s">Archived</div><div class="mi s" style="border:0">Trash</div>'
            '<div class="mi lockrow">%s&nbsp; Lock Library Now</div></div>') % (EMAIL, I_LOCKS)
    e1 = phone(BOOKCASE, menu)
    e2 = phone('<div class="hgrid">%s</div><div class="qa"><span class="appicon">%s</span><div class="qamenu">'
               '<div class="ours sep">Lock Library Now<span>%s</span></div><div>Edit Home Screen</div><div>Share App</div><div class="red">Remove App</div></div></div>'
               % ('<i></i>' * 20, mark(54), I_LOCKS), cls='sys')
    e3 = phone(lobby(face=True))
    return ('<h2>E — LP-5: where Lock Library Now lives</h2>'
            '<p class="lede">On the Mac it is a File-menu command (⌃⌘L) and a button in the pane: one step from anywhere, and beside its dial. The section’s button (P1) is settled. The question is the quick door.</p>'
            + row(
        opt(e1, "LP-5 (d) · my pick", "The masthead’s ⋯ menu.", "Two taps from any root screen, the File menu’s twin: ⋯, then <b>Lock Library Now</b>, last in the menu and set apart. Rendered only under Castle. "
            "With it, the Settings row (S1) and the section’s button (P1) come free, since Settings and Protection are where its explanation lives.", mine=True,
            small="LP-5 (a) is P1 alone: three taps deep, too far for “hand someone your phone”. LP-5 (b) is S1."),
        opt(e2, "LP-5 (c)", "A Home Screen quick action.", "Press and hold the app icon: the lock without opening the app first. Useful inside the window, when Variorum is in the background and still open. "
            "Worth adding after the in-app doors; it needs no new screen.", q=True),
        opt(e3, "E3", "After the press.", "From any of the doors: typing is saved, the library closes, its key is forgotten, and the lobby stands. Unlocking returns her to where she pressed it (LP-4)."),
    ))

def notes():
    return ('<h2>Build notes</h2><table class="bn">'
            '<tr><th>Screen</th><th>Delivers</th><th>Stands on</th><th>New</th><th>Do not get wrong</th><th>Size</th></tr>'
            '<tr><td>L1–L4 · the lobby</td><td>Sizing only (W-001’s layer applied to <code>MobileRoadFaces</code>); W-199 wording stays hers</td><td>Shared <code>ProtectionLobbyModel</code>, <code>ProtectionOpenRoad</code>, <code>ProtectionWords.lobby*</code></td><td>Nothing</td>'
            '<td>Keep the single automatic Face ID ask on appear and on return to active. Never build the page behind the lobby. The words box is three lines in the prose face and must not autocorrect or capitalise.</td><td>S</td></tr>'
            '<tr><td>G1, G3, G4 · the window</td><td>W-187 (her high priority)</td><td>Phone <code>MobileRelock</code> / <code>MobileRelockPolicy</code> over Shared <code>DeviceSettings.idleLockMinutes</code>; the dead <code>locksOnReturn</code> arm becomes the live one</td><td>No new brain</td>'
            '<td><code>locksOnLeaving</code> stops locking; the leaving flush and sync round stay. On return, compare the time away with the dial <b>before</b> any content draws; lock first, then show the lobby. '
            'The key stays in process memory only: nothing is persisted that says “unlocked”, so a swipe-away, an eviction or a crash all come back locked. “never” on the dial still locks on a full close.</td><td>M</td></tr>'
            '<tr><td>The phone locking</td><td>W-190, LP-2</td><td>Nothing today observes it</td><td>A device probe of the protected-data notifications</td>'
            '<td>The public signal is unproven on a device. Until the probe, the caption’s “always locks when your iPhone sleeps or its screen locks” must not ship as a promise; the minutes are the fallback that always works. No undocumented notification.</td><td>S</td></tr>'
            '<tr><td>LP-3 · the switcher cover</td><td>W-192, W-193</td><td>Phone <code>SnapshotPrivacy</code>, widened from marked spans to the whole shell under Castle</td><td>The cover face (room + mark)</td>'
            '<td>The cover must be up before iOS takes its picture, so it rides the scene going inactive, not the background flush. It also covers every sheet and the words look.</td><td>S</td></tr>'
            '<tr><td>LP-4 · back where she was</td><td>W-191</td><td><code>MobileShellView</code>’s tab and navigation paths, held above the tree the lock tears down</td><td>An in-memory place record (tab, stacks, note, scroll, caret)</td>'
            '<td>Memory only: never written to disk, never restored after the process ends. If the note was deleted or moved by a sync round while locked, land on its book or the Bookcase, quietly.</td><td>M</td></tr>'
            '<tr><td>S1–S2 · Settings</td><td>W-211, W-217 (absorbs VM-27), W-214, W-219 and W-226’s rows, W-213’s row</td><td><code>MobileSettingsView</code>; Shared <code>SyncStatusViews</code> for the first row</td><td>The grouped scrolling list; the ⋯ door from every root screen</td>'
            '<td>One Protection row, always: the sync row’s door and the standing button must never both render. Protection pushes inside the sheet. Rows grow with Dynamic Type; nothing is a fixed-height word.</td><td>M</td></tr>'
            '<tr><td>P1–P3 · Protection</td><td>W-188, W-189 (absorb VM-25), W-200 (absorbs VM-26), W-201, part of W-208</td><td>Shared <code>RoadCrossingsModel</code> (<code>setIdleMinutes</code>, <code>lockNow</code>, <code>canLock</code>), <code>RoadGateRow.idleChoices</code>, <code>ProtectionCopy.idle*</code> / <code>lockNow*</code> / <code>keystoneOpenMeansReadable</code>; <code>MobileProtectionScreen</code> and <code>MobileProtectionDoors</code></td><td>Face only: the section, and the new order</td>'
            '<td>The dial does nothing until W-187 lands, so they ship together. “On this iPhone” renders only when <code>canLock</code> (Castle). The join leads the screen whenever it is owed. '
            '“Use Standard…” needs her phone wording of rule 12’s sentence before it renders (LP-7); until then the posture section says so rather than standing doorless.</td><td>M</td></tr>'
            '<tr><td>E1–E2 · Lock Library Now</td><td>W-189, LP-5</td><td>Shared <code>RoadCrossingsModel.lockNow</code> → <code>AppBootstrap.lock()</code></td><td>The ⋯ row; later, the quick action</td>'
            '<td>The lock’s own teardown already flushes typing and commits; keep it. Not rendered under Standard. The quick action must lock without first drawing the page.</td><td>S</td></tr></table>'
            '<p class="lede" style="margin-top:18px"><b>Words.</b> Every sentence on these screens is the build’s, verbatim, including the shared labels that are title-cased today (“Lock Library Now”, “Replace All Keys…”, “Manage Tags”); '
            'bringing those to sentence case is a wording item for her pass (LP-10). New words here are only labels of mine: the Settings group names (Library, Look, Writing, Tags, Help), “Writing and commits”, “What’s new”, “Variorum for iPhone”.</p>'
            '<p class="lede"><b>Added to the sizing sheet’s vocabulary:</b> the <b>settings row</b> (52 minimum, SF 17 label, SF 13 detail, a trailing value in SF 15 or an act in the accent, hairline from the gutter) in full-width groups on the paper under section names on the room; '
            'the <b>dial</b> (a 44 pt segmented control on the wash, SF 15, the chosen segment on the paper; a menu row at accessibility sizes); the <b>lobby</b> layout (64 pt mark, Iowan 24 title, 52 pt buttons and fields); '
            'the <b>switcher cover</b> (the room and the cards mark). The form field, full-width button and band card are shared with the first-run file.</p>')

intro = ('<p class="lede"><b>VM-44 mockup round — the lock and protection.</b> The unlock, what staying open for a few minutes looks like, Settings as a real list, the Protection screen re-ordered, and where Lock Library Now lives. '
         'Study voice under the sea-glass palette, light; the lobby and Protection also in dark; Settings and Protection at the largest text size. The shell behind the sheets is the graders’ picks, kept as a thin layer.</p>'
         '<p class="lede">These are a writing app’s privacy faces. Nothing here changes a Castle rule or anything stored: the key stays where it is today, in the running app’s memory. Only acts, doors and words move. '
         'A green tag marks a pick; an amber tag marks an alternative drawn for her.</p>')

page('lock-and-protection.html', 'VM-44 — the lock and protection', intro, secA() + secB() + secC() + secD() + secE() + notes())
