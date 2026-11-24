# VM-24 — the snap-back, and the faint text after a dash: your handoff

**Status: merged to main 2026-11-20 (PR #19, merge commit `fe1493c16`).** The run started 2026-11-20 at about 03:50
while you slept and ran through the night under the stage coordinator (nov18). Both tickets are Done. Your words that covered it: "if you finish
vm-24 before i'm back, do your own closeout and i'll start from handoffs for everythign."

**Two apps, one order — read this before the cable.**

1. **The wave-1 app** is the one VM-47 built from the wave-1 merge (`226edf626`):
   `~/Library/Developer/Xcode/DerivedData/vm47-wave1-device/Build/Products/Release-iphoneos/VariorumMobile.app`.
   Its install block is the top of `notes/handoffs/vm-47-handoff.md`. It does NOT hold this run's fixes, which is
   the point: your "before" count runs on it. The script is `notes/handoffs/vm-24-morning-phone-session.md`
   (fifteen minutes; on main since this run merged).
2. **The "after" app** holds this run's two fixes:
   `~/Library/Developer/Xcode/DerivedData/vm24-after-device/Build/Products/Release-iphoneos/VariorumMobile.app`,
   built 2026-11-20 at 07:14 from the merge commit `fe1493c16` in a clean checkout. Its install block is "Installing
   the after app" below. Install it **only once the "before" counts are copied out** to the Mac. Nobody
   rebuilds main for the wave-1 install: main now carries the fixes, and a fresh build would leave no "before".

*How to read this file:* **VM-NNN** and **VX-NNN** are tickets. A **pin** is a test written to fail on the old code
and pass on the fix. A **test window** is a test run on the shared Mac, granted by the coordinator. The **walk** is a
scripted session on a simulator that photographs each step. The **review** is the cold code review by a fresh
reviewer. The record behind everything here is `notes/plans/vm-24-unwarned-edit-routing.md`; its FOR A LATER READER
section is the short version.

---

## Your checklist

- [ ] **1. The "before" session** on the wave-1 app — `notes/handoffs/vm-24-morning-phone-session.md`. Seven ways of
  entering text, a Copy of the edit trace after each, and one minute of yes-or-no checks for the dash bug. Paste the
  result to a session; it goes into the record under "The before session".
- [ ] **2. Install the "after" app, then the same session again** — "The after session" below says what is new in
  the readout and the two extra things only your phone can show.
- [ ] **3. Your calls** — five small ones, in "Your calls" below. They are QUESTIONS #282.
- [ ] **4. The wording pass** — the edit trace's new lines, in "The wording pass" below.
- [ ] **5. The gate's call** — the coordinator (nov18) called the gate passed while you slept: the whole phone
  test target with no failure, the speed suite alone, and the Mac suites that read the phone's source. No whole Mac
  run, because nothing shared or Mac-side changed. That call is yours to confirm.
- [ ] **6. The tickets filed** — one, at the bottom.

## What was wrong, in plain words

**VM-24 — the snap-back.** Before the keyboard changes your text it usually asks the editor first, and the editor
remembers which paragraph the change belongs to. Some changes arrive without asking: some autocorrections and
predictions, dictation's words as they form, a candidate-bar commit, and sometimes an ordinary key when the keyboard
slips another change in first (your phone recorded exactly that in August). For those the editor had to work out the
paragraph from the text system's own report of what changed, and that report is sometimes widened to the whole
paragraph including its end. At the end of a paragraph with another paragraph after it, the widened report looked
like a change spanning two blocks. The editor refused it and redrew the note from what was saved, so the word you had
just entered jumped back, with a flicker. Your saved text was never at risk.

**The fix:** the editor now reads what changed from the text system's first notice, before the widening, and routes
the change to its paragraph. A change that truly spans two blocks is still refused, exactly as before. While a
divide or merge is landing, such a change now meets the keystroke fence the timing run built (withheld, and the
phone says so), where before it caused a redraw in the middle of the act.

**VM-243 — the faint text after a dash.** On the phone a typed character takes its look from the character before
it. After a dash, that character is the dash, which is drawn faint on purpose. The markdown styling marks what it
has styled with its own tag and only ever clears text carrying that tag; the phone's keyboard copies the look but
not the tag. So the faint ink was inherited from character to character — along the line, through Return, into the
next paragraph — and nothing ever cleared it, until the note was re-opened. The same thing made a line typed under
a heading come out in the heading's large bold face, and text after a closing `*` come out faint.

**The fix:** every character you type is set to the plain body look where it lands, and the line's styling is then
worked out fresh. Plain text typed in plain text costs nothing extra. Text that is already faint in a note is
cleared the next time you open that note.

Both fixes are on the phone only. Nothing in the shared code or the Mac changed.

## The evidence

- **The test that has been red since 2026-10-25 is green**, all three of its cases, with its file untouched. That
  test was the bug's standing pin; it was never excused or wrapped.
- **New pins, each seen red on the old code and green on the fix** in test windows: an unasked-about change at a
  paragraph's end, mid-paragraph and as a replacement; the "key whose approval was spent" shape from your phone's
  August trace; the same change during a divide; and for VM-243 a dash line, the paragraph after it, a closing
  marker, a heading, and the very end of a note. A control pin proves a change that truly spans two blocks is still
  refused.
- **The walk** (a dedicated simulator, the same script on main's code and on the fix): the BEFORE screenshots show
  the dash line and the paragraph after it faint and "word" in the heading's big face; the AFTER screenshots show
  only the dash faint. The screenshots are kept for you on the Pro in
  `~/dev/variorum/App/Variorum/DerivedData/vm24-walk-screens/` (`before/` and `after/`; start with
  `g-note-end-keyboard-down.png` in each) — say "delete the screens" when you have looked.
- **What the walk could not show, said plainly:** the simulator's keyboard asked the editor before every key,
  autocorrection and paste, so the walk met no unasked-about change and no snap-back to avoid. For VM-24 the proof
  is the pins, and your phone's two sessions.
- **The review:** one round, a fresh reviewer, no blocker and no major finding; two minor and a nit, all words or
  comments, all fixed and confirmed.
- **The gate:** the whole phone test target ran 1,226 tests in 215 suites with no failure — the first time since
  October that main's standing red is gone. The speed suite, run alone, passed its 13. The 22 Mac suites that read
  the phone's source passed (129 tests). The whole Mac target was not run: nothing in the shared code or the Mac
  changed (the coordinator read the rule the same way).

## The after session (the same fifteen minutes, on the "after" app)

Do the morning script again, exactly as before. What is new in the readout's first lines:

```
  widened           4   (past the change)
  rescued           1   (snap-backs avoided)
  no capture        0   (expected 0)
...
desync recoveries   0
```

- **rescued** counts changes that would have snapped back on the old code and were kept. Compare it with the
  "desync recoveries" of your "before" session: that is the before-and-after.
- **desync recoveries** should now be 0 in ordinary writing.
- **no capture** should be 0. If it is not, some way of entering text on your phone reports without the first
  notice the fix reads, and I want to know which step it was.

Two things only your phone can show, a minute each:

1. **Dictation and the candidate bar.** Dictate a sentence mid-note, and if you ever use a keyboard with a candidate
   bar, commit a word from it. Does the text look right while it forms and after? (The fix resets a typed
   character's look; whether the system draws anything of its own on forming text was not seen on a simulator.)
2. **The dash bug's three questions** from the morning script, again: with the fix, "one", "two" and " b" should be
   in full ink, and a line under a heading in the body face.

## Installing the "after" app

**Nothing has been installed and no phone was contacted.** The road is the same one as the wave-1 install
(`notes/plans/vm-44/plans/vm-45-install-runbook.md`, with the differences `notes/handoffs/vm-47-handoff.md` lists in
its morning block); only the build's path changes. The session helping you asks the coordinator for the stage first.

| | |
|---|---|
| The build | Release, a generic iOS device build from a clean checkout at exactly `fe1493c16`; BUILD SUCCEEDED; `codesign --verify --deep --strict` OK; about 52 MB |
| Bundle id · version · build | `io.lduarte.VariorumMobile` · 1.0 · 1 — the same as the wave-1 app, so the version cannot tell them apart. The way to tell: Settings ▸ Diagnostics ▸ Edit trace… shows a "rescued" line only on the "after" app |
| Signing | Apple Development, the same team as the wave-1 app; the entitlements identical to it; nothing minted, refreshed or prompted |
| Against the wave-1 app | three phone editor files differ (the two fixes and the trace); no shared or Core file, no package version, no project setting |
| Sync version | 15, unchanged: nothing pauses |
| The first open | NO migration (the wave-1 app's one migration will already have run) |

The step that changes, in place of the runbook's `APP=` line:

`APP="$HOME/Library/Developer/Xcode/DerivedData/vm24-after-device/Build/Products/Release-iphoneos/VariorumMobile.app"`

As ever: Variorum fully quit on the phone, install in place, **never uninstall**. A safety copy before this second
install is your call; this build adds no migration, so going back to the wave-1 app is the same install the other
way.

## Your calls (QUESTIONS #282)

1. **No run ticket.** The phase skill says several tickets make a run with a fresh `Run:` ticket. Your words made
   VM-24 the run and VM-243 a rider, so VM-24 names the branch and the PR and VM-243 closed on its own. Say if you
   want a `Run:` ticket over both for the record.
2. **VX-68 is closed** (the "gate-less insertion" watch row: "the first place to look on any typing-flicker
   report"). Its class is what VM-24 fixed. PROVISIONAL: reopen it if you would rather it watch until your "after"
   session.
3. **The Mac's twin is a ticket, not a fix** (VX-1031). The Mac reads the same widened report, but no way of
   entering text on the Mac is shown to arrive unasked-about, and nothing is fixed here without a traced cause.
4. **VM-243 is built to "what the Mac draws"**: the dash faint, its words and everything after in full ink (the
   ticket's own "what should happen").
5. **Faint text already in a note** is not swept: it clears when that note is next opened. Say if you want it
   cleared in place instead.

## The wording pass

The edit trace's readout (Settings ▸ Diagnostics ▸ Edit trace…) gained three lines and three per-event marks. All
are draft:

- `widened N (past the change)` · `rescued N (snap-backs avoided)` · `no capture N (expected 0)`
- on an event's line: `widened — changed at N len M` · `rescued` · `no capture`

Two notes for the same pass:

- **In the Terminal voice the readout's older "gate-less … (autocorrect/dictation — expected)" line wraps** on the
  phone's width (it did before this run; only about 45 characters fit there). This run's own new lines were
  shortened to fit both voices. The older line is yours: shorter words, or each explanation on its own line.
- **"snap-backs avoided" is slightly generous in one rare case:** during a divide or merge, a rescued change is
  still withheld by the keystroke fence (the phone says "Another structural change is still landing."). It is
  counted as rescued because the old code would have redrawn the page mid-act.

## Housekeeping

- `Tools/canon-size`: 143606 (harness limit 150000, headroom 6394) — unchanged; this run touched no loaded canon
  file.
- Canon: `notes/TEXTKIT2_NOTES.md` §3 gained the run's two findings and their rules; `notes/MobileSoul.md` gained
  parity row PL-81. No AppSpec or SurfaceContracts line moved.
- Kept on the Pro for your sitting: the "after" app (above) and the walk's screenshots. Everything else of the run —
  its worktree, its test builds, the walk's throwaway driver, the branch — is removed.

## Not done, or left for later — honestly

- **Your phone's two sessions** — the run's first unit was the measurement, and it needs your hands. Until then
  VM-24 has no number from a real keyboard.
- **The walk did not drive one act:** pasting over a selected word (the driver did not find the menu's Paste).
  Pasting at a paragraph's end was walked.
- **The Mac** (call 3).
- **A second review round** was not run: the first found no blocker or major, which is the rule for stopping.

## The tickets filed

Tickets filed:

- [ ] VX-1031 (Low, Exploration, Backlog): Mac editor — an edit that reaches the storage unasked is still routed
  from TextKit's widened report (the phone's VM-24 twin); is any Mac road exposed?
