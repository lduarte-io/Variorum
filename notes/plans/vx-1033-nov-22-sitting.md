# VX-1033 — the Nov 22 sitting: wave-1 handoffs, wave-2 questions, the phone install, what runs next

**Ticket: VX-1033 · Branch: `vx-1033-nov-22-sitting` · Worktree: `~/dev/variorum-vx-1033` · the Pro**

## FOR A LATER READER

*(Kept current while the sitting runs; rewritten at its close.)*

- **The phone install is done.** The app built from `fe1493c16` (wave 1 + VM-24 + VM-243, equal to main's product
  code) went onto her iPhone in place over Wi-Fi with `devicectl`, no cable, on 2026-11-22. She chose it over the
  handoff's two-install order, so VM-24's "before" session on the wave-1 app was not run; the new app's own
  "rescued" counter stands in for it. No safety copy was taken, at her word.
- **The text-loss recording is VM-250 (Urgent).** Typing at a block's end while the keyboard is predicting made the
  note redraw, lost the last letter, and let the prediction land in the wrong place; one piece of damage was saved to
  the store. The redraw trigger is VM-24's snap-back (fixed on main, unproven against inline predictions on a
  device). Still live on main: a whole-note redraw underneath in-progress keyboard text.
- **Phone sync lag** — the reader's report is `notes/plans/vx-1033/phone-sync-lag-report.md`. The phone lacks none of
  the Mac's sync speed-ups; the lag is the driver and fixed per-round costs (see "Findings" below).
- **Rulings so far** are under "Her rulings". The bundles QUESTIONS #276–#282 are still open.

## Her opening words (2026-11-22, verbatim)

"hello fable it's time for us to propel things into the next wave of mobile & variorum mac work! the plan for this
session is for us to handle all of the handoffs from wave 1, answer the questions about mobile wave 2, install the new
build on my phone, and finally I have a new feature improvement I want to add on the mac app that we can plan through
together. once we're ready for wave 2 of mobile, I'll have you open all of the tmux sessions and name / start them
all. I can start a wave coordinator when we're ready for that too. I'll sign back into the apple developer thing but
I'll probably wait to release 1.5 til the new feature i'm envisioning today is done. you can mint a ticket for this
work, /architect-phase discipline as always when making any changes. my phone is nearby and unlocked - let's try the
install over wifi to see if we can avoid needing a cable. the fragments repo at dev/fragments has a way of installing
without a cable that has worked overnight even when my phone is locked for fragments, so see if that helps. my phone
is unlocked though and ready for install. also - the phone syncing has been very slow. that's a problem, not sure why
it's so slow (the mac app did have some tickets that made sync a lot faster, not sure if we have to implement those).
and finally, I have some bug reports that I want you to analyze the videos of / ticket appropriately. the mobile one
especially I'm going to include now because it can lead to text loss - I don't even know how it's triggered exactly,
it's something about new lines and blocks, but it starts to just freak out and delete random halves of a line. you can
use a sonnet or opus subagent if you want to look through frame by frame to try to understand what's happening - the
keyboard shows what i'm pressing on normally i think - but this is a serious problem. in general, the phone's editor
is very buggy and problematic, so i don't know if that's being fixed in wave 2 or if it was fixed in wave 1, or if it
needs an investigation run, but this can't continue. i don't know how much the mobile catch up focuses on just adding
new things versus fixing what's already made, but if it doesn't include some serious tech debt tackling / handling, I
want us to plan that today. you can use opus subagents to scan through the whole codebase there and see if my general
/architect-phase principles are followed - I was only working and doing cold reviews with opus 4.8 for a while (now,
with 5.5, opus is actually great!!) and I just feel like the app is overall quite buggy, not sure if we're just adding
new things or if we're fixing it. anyway. let's get started with all of this, mobile install, I'm available to do
whatever I need to do post install, and you can start working on all these other threads in the meantime / alongside
that as well."

And, on sync, a little later: "it does eventually sync, it's just noticable that it takes a long time"

## Her rulings (in her words; the bundle addenda land in `notes/QUESTIONS.md` at the close)

| # | Question | Her answer |
|---|---|---|
| 1 | Which app goes on the phone: the newest only, or the wave-1 app first and then the newest | She picked "Newest only (Recommended)". |
| 2 | A safety copy of the phone's library before the install | "no, I don't need a safety copy. all of my notes are synced in variorum sync & on my macbook air." |
| 3 | The phone's Sync row before the install | She picked "Synced, with a recent time". |
| 4 | VM-76 — a line after File saying where the quick note went | "a line with open & I think a little symbol to click on to change what wing it's going to (when users have multiple wings) would be nice - similar to the mac app quick capture" → option (a); the wing symbol is VM-251. |
| 5 | VM-95 — a note's tags on the phone's Library row | "the library row shouldn't show the note's tags, and i want a ticket filed for there to be a mac option to hide tags on a book in the library view (both a general setting for hiding all tags, and a per book setting - maybe i want to hide my journal's tags, for example, because it has a lot of them)." → option (a), VM-95 closed; the Mac option is VX-1032. |
| 6 | VM-169 — the line after dismissing a waiting note | She picked "The Mac's line, no Undo (Recommended)". VM-169 closed. |
| 7 | VM-15 — the library and the iPhone's own backup | OPEN. Her question back: "why can it hold an older wrapped key the app can't bring along? what does the app can't bring it along mean? I don't understand the issue fully." Explained in chat; her answer is awaited. |

## Tickets born at this sitting

- **VX-1033** — the sitting itself.
- **VM-250** (Urgent, Bug, Confirmed, Editor) — typing at a block's end while the keyboard is predicting loses letters
  and can damage the next block, and the damage is saved.
- **VM-251** (High, Feature, App shell) — the capture box's wing symbol; under VM-72.
- **VX-1032** (Medium, Feature, Library & sidebar, Backlog) — hide tags in the Library view: one setting for all, and
  a per-book choice.

## Findings

### The text-loss recording (her phone, the build from `beb638033`, recorded 2026-11-21)

Read frame by frame by an Opus reader; the key frames were checked by the orchestrator. The frames and the reader's
notes are local on the Pro in the main checkout's `notes/plans/textloss-screens/` (ignored by git: they show her
note's text). The timeline, the trace and the open questions are on VM-250.

### Phone sync lag

The reader's full report: `notes/plans/vx-1033/phone-sync-lag-report.md`. Spot-checked by the orchestrator: the
driver's constants (`App/Variorum/Shared/SyncSession.swift`: 3 s after local writes settle, 2 s after the network
returns), that no timer, poll or socket exists in the driver, that Castle locks the phone's library on every leaving
(`MobileRelockPolicy.locksOnLeaving`), that `SupabaseTransport` defaults to `URLSession.shared`, and the scheduler's
"the next trigger retries" rule. The per-round call count (13) is the reader's and was not recounted.

In short:

1. Every Mac sync speed-up lives in Core, `Shared/` or the server, and was already in her phone's previous build.
   Nothing is missing on the phone.
2. Neither app asks the server on its own. A change from another device is heard only at launch or unlock, after a
   local edit settles, when the network returns, or at Sync now.
3. Under Castle the phone locks on every trip out of the app, so every return is Face ID, a cold store, rebuilt
   services and then the first round. The Mac never locks on an app switch.
4. A round makes about 13 server calls in sequence even with nothing to send, with a new edit's push near the end;
   after every clean round the purge janitor reads at the scale of the library (VM-182).
5. A failed round is not retried until the next trigger, and requests carry no timeout of their own.

## LIVE STATUS

| When (2026-11-22) | What |
|---|---|
| 12:56 | Bout start: both repos pulled, board snapshot pushed (`37cf317fe`). |
| ~13:00 | The phone found over the local network; both prepared apps' signatures verified. |
| ~13:15 | The install, under a stage claim (`nov22-sitting`), released after. |
| ~13:30 | VM-250 filed; two Opus readers started (sync lag; the phone editor audit). |
| ~13:40 | Her four wave-2 answers recorded; VM-251 and VX-1032 filed; VM-95 and VM-169 closed. |
| ~13:50 | The sync reader returned; VX-1033 minted; this record opened. |
