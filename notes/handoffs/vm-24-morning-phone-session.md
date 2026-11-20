# VM-24 — the "before" session on your phone (about fifteen minutes)

*Written 2026-11-20 by the VM-24 run for your morning. It needs nothing but the wave-1 build that VM-47 prepared
(its handoff, `notes/handoffs/vm-47-handoff.md`, has the install block). The same install serves VM-64's timing
readout and this count. Nothing here needs a second build.*

**What this is for.** VM-24 is the bug where a word the keyboard just put in snaps back to what was there before,
with a flicker of the page. Your phone already carries a recorder for it, the edit trace. This session counts, per
way of entering text, how many edits arrived without the editor being asked first and how many snap-backs followed.
That is the "before". The same session on the fixed build later is the "after".

**One thing that matters:** do this on the app VM-47 built from the wave-1 merge (`226edf626`), the one waiting in
`~/Library/Developer/Xcode/DerivedData/vm47-wave1-device/`. Do not let a session rebuild main for this install. If
VM-24's fix has merged by the morning, a fresh build of main would carry the fix and there would be no "before".

## Set up (two minutes)

1. Open Variorum on the phone. Make a new note. Type four short paragraphs, a line or two each, with a Return
   between them. Any words.
2. Go back out of the note and open it again. (This makes every paragraph a settled block, which is where the bug
   can happen.)
3. Open Settings (the ⋯ on the Bookcase, Library or Starred page, or the ⋯ inside the note). Under **Diagnostics**,
   turn on **Record edit trace**. Then open **Edit trace…** and press **Clear**. Close Settings.
4. On the phone, open Apple Notes and make one note called "trace". You will paste into it after each step.

Keep Variorum running for the whole session. If you swipe it away, the counts start again from zero (the switch
stays on), so copy first.

## The seven steps

Do each step in the scratch note, **in the second or third paragraph, not the last one**, unless the step says
otherwise. After each step: Settings ▸ Diagnostics ▸ **Edit trace…** ▸ **Copy**, switch to Apple Notes, type the
step's letter and paste under it. Do **not** press Clear between steps; the counts add up and I subtract.

If you ever see a word jump back or the page flicker, stop, Copy right then, and write one line under the paste
saying what you had just done. That one line is worth more than the rest.

- **A. Plain typing, mid-note.** Tap at the end of the second paragraph. Type two sentences at your normal speed,
  with autocorrect on, mistakes and all. Then tap into the middle of the third paragraph and type a few words there.
- **B. Autocorrect.** At the end of the second paragraph, type about ten words spelled wrong on purpose and let the
  keyboard fix each one when you press space ("teh", "recieve", "definately", "wierd", and so on).
- **C. Predictions.** Type a few letters of a word and tap the finished word in the bar above the keyboard. Do that
  about ten times. Then tap three or four suggested next words in a row without typing.
- **D. Dictation.** Tap at the end of the second paragraph, press the microphone, and say two sentences. Stop
  dictation. Then do it once more with the caret in the middle of the third paragraph.
- **E. The spelling menu.** Type three wrong words and reject the autocorrection (tap the small x, or keep typing
  so the red underline stays). Tap each underlined word and choose the suggestion from the menu.
- **F. Paste.** Copy a few words from anywhere. Paste them at the end of the second paragraph, then in the middle
  of the third paragraph. Then select one word in the note and paste over it.
- **G. The end of the note (the comparison).** Tap at the very end of the last paragraph and type two sentences,
  letting autocorrect fix a few words.

If you swipe-type or use text shortcuts in daily use, add a step **H** doing a little of that mid-note, and paste
after it the same way.

## One minute for the dash bug (VM-243), no trace needed

In the same scratch note, at the end:

1. Type `- one`, press Return twice, type `two`. Is "one" faint? Is "two" faint?
2. On a new line type `*a* b`. Is " b" faint?
3. Go back out of the note and open it again. Is the faint ink gone?

Three yes-or-no answers, in the same Apple Notes note. A screenshot helps if anything looks odd.

## Getting it to the session

Apple Notes syncs to the Mac. Open the "trace" note there, copy everything, and paste it to the VM-24 session (the
tmux window named `vm-24`). If that session is gone, paste it to any session and say "this is the VM-24 before
count"; it goes into `notes/plans/vm-24-unwarned-edit-routing.md` under "The before session".

You can delete the scratch note afterwards. Leave **Record edit trace** on if you plan to do the "after" session
soon; it costs a few numbers per keystroke and nothing else.

## What the numbers will say (so you can glance at them)

The first lines of each paste look like this:

```
gate calls          212
storage edits       96
  gate-less         7
  arming rejected   1
...
desync recoveries   0
```

"gate-less" and "arming rejected" together are the edits that arrived unwarned. "desync recoveries" is the number
of snap-backs. A zero there is a real answer too: it would mean the bug is rare on your phone in ordinary use, and
the fix's proof then rests on the test that has been red since October going green, plus the "after" session's own
counter of edits it rescued.

**One limit, said plainly:** this build's trace does not record how wide TextKit made each report, so "widened" is
read from each line's length against its change, not measured. The snap-back count itself is exact.
