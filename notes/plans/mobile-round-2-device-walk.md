# The device walk — nine things only her phone can settle

**Written 2026-08-23, for the window she offered** (*"I'm here with my
phone"*). The queue is `mobile-round-2-batch-4.5-briefs.md` §4b; **this
file is the phone-holder's version** — what to do, what to watch, what to
say back. Results are recorded here as they come in.

**Order matters in three places and nowhere else:** **D8 must be first**
(it needs the very first launch after the install), **D4 kills the app**,
and **D9 restarts the phone**, so it goes last.

---

## Before anything: the install

A fresh **Release** build goes to the phone. It carries **everything the
round has fixed and she has been working around by hand**:

- the quick note **no longer destroys the second paragraph** when she
  edits the first one of a pasted capture;
- a **refused save no longer wipes the box and the error**;
- **Delete Now, Empty Trash, the Library row's Delete Note and the Shelf
  row's Delete Book all actually work** (they did nothing before);
- **the destructive-undo warning's Undo no longer cancels the undo**;
- the formatting strip **fits a 320 pt screen**;
- plus E1's instrumentation, armed as the walk says.

**So the working caveats she has been living with end at this install.**

---

## 1 · D8 — time the first launch *(must be the very first thing)*

**Do:** after the install completes, open the app and count how long
until you can see and touch the shelf.

**Why:** the app opens the database and runs its migrations **on the main
thread before the first paint** — a P2 violation. The simulator says
**54 ms** first-launch and **5 ms** on a reopen, but simulator disk is
host-SSD-fast and **the device number has never been taken.** The fix
(4.5e) is designed and unbuilt; this number decides how urgent it is.

**Tell me:** roughly how long, and whether it felt instant or not. Then
force-quit and open again — **is the second open noticeably faster?**

---

## 2 · D3 — is "Delete Note…" red?

**Do:** open a note → the **⋯** menu → look at **Delete Note…**.

**Why:** a screenshot capture showed it rendering **black rather than
red**, most likely an artifact of how the capture works — but it is a
colour a deletion door leans on, so it was flagged rather than assumed
away.

**Tell me:** red or black.

---

## 3 · D7 — where does the caret go?

**Do:** on the home screen's quick-note box, **paste two paragraphs**.
Wait a second for it to save. Now **tap into the first paragraph and fix
something** — a backspace is enough.

**Why:** the box holds at the boundary and says so (the first paragraph
is already a real block; that edit belongs in the editor). **That is
correct and it protects the text.** But the caret is believed to jump to
the very end afterwards, which is confirmed in tests and never seen in a
hand.

**Tell me:** after the held edit, **where is the cursor** — where you
were typing, or at the end? And **did the box say anything** about
holding at the boundary?

---

## 4 · D6 — dictate into a two-paragraph capture

**Do:** same box, still holding two paragraphs. **Dictate** something
into it.

**Why:** iOS dictation **rewrites the whole field** as it refines, which
looks to the box exactly like editing the frozen first paragraph. **On
the build she has been running, that case destroyed the second
paragraph.** The fix makes it hold instead — but nobody has watched
dictation do it on real hardware.

**Tell me:** did anything get lost, and did it behave the same way the
typed edit in step 3 did?

---

## 5 · D4 — swipe-kill with unsaved text *(this one kills the app)*

**Do:** type something new into the quick-note box and **immediately**
swipe up to kill the app — do not wait. Reopen.

**Why:** the box promises *"nothing you type is lost"*, and the tests
say plainly they **cannot reach** whether iOS really delivers the
background signal before a kill, or whether the background grant buys
enough real wall clock. **This is the device half of that promise.**

**Tell me:** was the text there when you reopened — in the box, or as a
note?

**Then repeat once with the phone locking** instead of a swipe-kill
(type, lock the phone, wait a moment, unlock): the app's own comment says
file protection can cut the store off mid-round, and a refused save
should now **keep the text and say why** instead of clearing the box.

---

## 6 · E1 — the crash gesture, instrumented *(the big one)*

**Do:** arm the instrumentation as the app's own arming step says — the
walk step written into the build tells you where — then, in a note with
several paragraphs, **select multiple lines at the very end and delete
them.** That is the exact gesture that used to crash. Then do some
ordinary typing with **autocorrect** doing its thing, and a bit of
**dictation**.

**Why:** the crash is fixed, but **why the wrong edit-verdict got used is
still unproven** — the suspicion is that iOS bundles a delete and a
re-insert into one transaction wider than the approval it was given. The
instrumentation flags exactly that shape. **13u is about to build a much
bigger gesture in this same seam**, so settling it now is worth the
window.

**Tell me:** what the readout says — especially **whether anything is
flagged**, and the counts it shows.

---

## 7 · M16 — drag a two-paragraph selection inside one note

**Do:** in a note, select two whole paragraphs, **long-press and drag
them** somewhere else in the same note. Drop.

**Why:** unsettleable from the code — no drag delegate is configured, so
whether this is even reachable is a device fact. If it is, the source
deletion may be planned as a **block** delete while the drop lands the
text as plain content.

**Tell me:** could you drag at all? If yes — did the paragraphs move
cleanly, and is anything missing afterwards?

---

## 8 · D5 — the bridge connect door *(skip if it isn't there)*

**Do:** Settings → the account sheet → look for **Journal bridge
(Fragments)** and its connect door. If it is there, tap it once.

**Why:** the iOS arm of that sign-in flow **compiles but has never run on
a device.** There is also an open judgement about whether the door
belongs on the phone at all.

**Tell me:** is the door there, and does tapping it open a browser sheet
cleanly or fail?

---

## 9 · D9 — the strip at Display Zoom *(restarts the phone — do last)*

**Do:** Settings → Display & Brightness → **Display Zoom → Larger Text**.
The phone restarts. Then open a note and tap **Aa**.

**Why:** at that width the eleven formatting buttons render at **23 pt**
instead of 28 — below the size she pre-ruled tappable. The alternative
was two buttons off the screen entirely, so the architect ruled *accept
23* — **but no human has ever seen it.**

**Tell me:** does the row look cramped, and **can you actually tap the
two on the ends** (`×` and the outdent arrow)? Then put Display Zoom back
if she prefers it off.

---

## RESULTS

*(filled in as she reports; each becomes a disposition in
`mobile-round-2.md`)*

| # | row | result |
|---|---|---|
| 1 | D8 cold launch | |
| 2 | D3 destructive colour | |
| 3 | D7 caret after a hold | |
| 4 | D6 dictation | |
| 5 | D4 swipe-kill + lock | |
| 6 | **E1 the crash seam** | |
| 7 | M16 drag-move | |
| 8 | D5 bridge door | |
| 9 | D9 Display-Zoom strip | |
