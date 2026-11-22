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

| 8 | The handoffs' short list (a–k), put to her in chat | "a-f I agree with your recommendtations. g - agree the mac should show that it's archived. h - agree that mac should hide it. i - might as well fix this. j - agree with your recommendation, k, agreed." The list: (a) the seven overnight merge gates confirmed; (b) VM-64 P-2-1 — a key typed while a divide or merge lands is refused and said — kept; (c) VM-64 P-71-1 — switching tabs is not leaving a note — kept (but see her first look, item on the Library tab, below: the two meet); (d) VM-55 P-55-3 — refusal lines fade by themselves — kept, judged in use; (e) VM-55 P-55-19 — a direction's colour changes from the alarm red to a neutral one; (f) VM-55 P-55-2, -14, -15, -18 — the interim wing behaviour ratified as built; (g) VM-78 call 1 — an archived gathering is marked "(archived)" on the Mac too; (h) VM-78 call 2 — the Mac stops offering Diverge on a gathering's row; (i) VX-1030 — the three stale SurfaceContracts lines are corrected; (j) VX-980 P-980-3 — option (a), the Settings row only, no automatic check; (k) VX-68 stays closed, VM-250 carries the watch. |
| 9 | The Mac bundles (#276 VX-980's remainder, #278 VX-981) and VM-47's look calls (#281) | "agreed that we will simply handle the vx bundles later - i'm more concerned at the moment with getting the next mobile wave running and the next vx feature planned so that can be kicked off, the only deadline on going through that bundle is before the next release really (though I will do it earlier than that)." |
| 10 | Phone sync | "i think the phone sitting open not syncing is probably why it's so slow - the mac automatically catches up, but the phone probably had a lot ot catch up on or something. let's mint a ticket for trimming the rounds and not doing cleanup off every round - it doesn't have to be done this wave, but we should fix it. also - it looks like the mac does sync, if i just open it, i see it syncing and then it says synced, whenever it's missing something." and "sync speedup can happen at a later point - it's not urgent, i do think it should be fixed, but it's less urgent than all of these editor issues." |
| 11 | The editor | "vm-252: I want to fix these in the next wave, they're very bothersome. it seems like there is the whole problem that comes together from this wohle class of issue about page redrawing beneath in progress keyboard text, and all of those issues. what's the root level solution? we need to think deeply from a system perspective on how we can fix this and make the app performant and work correctly. do we need a separate phone editor core because of all of this random extra stuff? it really annoys me that the predictions and autocorrect are causing these issues. if we need a workaround / different approach on the phone, i don't want the phone's compromises to affect the mac editor's experience - i like where the mac is at and I'm wary of changing it to accomodate the phone. how does this impact your proposal? i'm ready for any phone 15 minute session that's needed." |
| 12 | Castle | "you should start a new audit against the final castle rules. getting castle rules right is the MOST important part of this phoen work in many ways - that's the place where I could lose trust." (An Opus reader was started on it the same hour.) |

## Her first look at the wave-1 phone app (2026-11-22, verbatim)

"ok i opened it. just for starters - the bottom bar is moving when i swipe between screens, which should never happen
(the bar should stay still and just the highlighted pill should change). I also want an option to change font size on
the app (or maybe we just need to make the font size a bit smaller - it looks big to me). I also don't think thte Home
* Bookcase and Home * Starred thing is necessary - it says on the bottom what area you're in. also, a kebab menu for
settings makes less sense than just showing a settings gear. also - let's just only show the trash icon within
library. also - clicking on library should bring me to library, not whatever note i last had open. you can mint a vm
ticket for having another are ain the lirbary (after Scraps) that shows recently open notes, and that can work like
the mac's recently open notes - ability to click to close all of them, or close them one by one, stays in memory,
goes to about 20 or something (? not sure exactly where the mac caps). that would be a useful addition. also - not
sure if the phone alreay has a ticket for showing what the preview text of a note is within lirbary in that list, but
it should. and I should be able to choose whether I want to see preview text and a bit of the note (like how apple
notes looks on the phone, with cards and some details (what book it's in, tags, first sentence), or just titles. that
should be easy to switch  between. the top row should also collapse while I'm scrolling - I'm open to ideas on how
that should happen, but right now the app just feels like it's fighting for space (the home library, then large
searchbar, then different options to click between is a lot...) open to ideas on that, but I just don't love the
current design. i also don't like the trash bin emoji, it looks out of place. the same trash bin icon the mac usesi s
what we should use. new note should also be a writing icon, the way it's a writing icon on the mac app). I just want
you to record all of this feedback and early impressions and start making plans for fixing it."

On the iPhone-backup question (VM-15), in the same message: "also - hasn't this always been true for backups that you
put in iCloud? if I put my mac backups in iCloud, or put a mac backup on a flashdrive while I was in standard (and then
switched to castle), there's still an apple opened key on that mac backup? i thought we said that we give deleting
keys from old backups our best attempt but can't guarantee it, and you should delete your backup. no? it wouldn't open
your new library, right? but that backup is still openable? tell me if my read on that is right."

On working between notes: "also - i'm interested in exploring more ways to work between several open notes on the
phone (like how I told you about that recently opened area. maybe we can take some lessons from browser apps ? and
from within that area you could be able to see your tabs or something? file a ticket for potential improvement there
- not a needed v1 feature, but something in the long run I want to plan for."

And a few minutes later: "I feel like I like the new UI less than theo ld one in many ways - it feels forgettable and
overly crowded. it didn't get the same treatment that the mac got in many ways - the pills are rounded boxes, it looks
like a forgettable phone UI. it used to look more distinct and principled. so I don't know what the path towards
restoring that is, but we've got to look at it. also - why is purple the default? seaglass is the default color on the
mac. so what's even the deal with this purple ?? did it sync from what my mac is on (dark mode purple)? and why can I
not change the color of the phone in settings?"

## Her ask for the editor design proposal (2026-11-22, verbatim)

After the three options were put to her in chat (keep and defend the one text view; one live block per text view; a
fully custom text input):

"hmm. i feel like B's cost is somewhat significant. should the phone default to not making new blocks on new lines? not
being able to drag and edit across a new line is frustrating. I feel conflicted on this - it seems like the phone is
struggling to do what the mac did at great effort (make a block based editor FEEL like a regular editor in write), and
only the fully custom text input would really bring what the mac has - right? is my read on that wrong? I feel
conflicted on what path to take here. I feel like a writing app where you can't select across multiple paragraphs is
going to be difficult to use / be happy with for people. Think more deeply on this and make a deisgn proposal page for
me with the different options and what each one costs, what each one would be good at, what problems we'll have with
each one. this should take the most effort of anything thus far - this is the soul of the mobile app and how we make
it a great app, rather than a mid one."

The page: `notes/plans/vx-1033/design/phone-editor-proposal.html`. The outside facts behind it:
`notes/plans/vx-1033/ios-text-input-research.md`.

**Her decision on the page (2026-11-22, verbatim):** "ok i read your recommendation, I think that the page is the truth
is a good approach. make a full design plan for that, then spawn one cold review of the plan that is adversarially
focused on where it breaks, what needs to be improved, handled, etc. that being said - i'm not that worried about the
current editor being buggy, i don't really think that just for me we need to fix the current editor if we're going to
change the whole thing. it's not a HUGE issue and doesn't come up that frequently, it's a HUGE issue for launch, but I
don't think we need to build fixes for it if we're going to change the whoel thing anyway. how can we test this on my
phone? I want to get this issue sorted and this plan done - that's my current top priority."

So: option D is chosen; today's editor is not patched (the "safety fixes first" step is dropped); the effort's ticket
is **VM-271** and its plan is `notes/plans/vm-271-phone-editor-core.md`, with one adversarial cold review beside it.

Also that hour: "I started a stage coordinator named nov22 by the way - i'm going to do the ambient app fixes /
improvements and I wanted to get that effort started."

## Tickets born at this sitting

- **VX-1033** — the sitting itself.
- **VM-250** (Urgent, Bug, Confirmed, Editor) — typing at a block's end while the keyboard is predicting loses letters
  and can damage the next block, and the damage is saved.
- **VM-251** (High, Feature, App shell) — the capture box's wing symbol; under VM-72.
- **VX-1032** (Medium, Feature, Library & sidebar, Backlog) — hide tags in the Library view: one setting for all, and
  a per-book choice.

- **VM-252** (Urgent, Bug, Confirmed, Editor) — a key typed after a refused edit and before the page's repair can
  save the wrong text into the wrong block (the editor audit's finding 1; the gap read by the orchestrator too).
- From her first look, under Home, wings and capture (VM-72): **VM-253** the bottom bar moves on a swipe · **VM-254**
  text size · **VM-255** the home pages' top line (no page word, a gear, the trash door only on the Library, the
  Mac's icons) · **VM-256** the Library tab opens the Library · **VM-265** a direction's neutral colour (P-55-19) ·
  **VM-247** the palette row, promoted from Backlog to Todo.
- From her first look, under The Library (VM-87): **VM-257** a Recently open area · **VM-258** cards with details or
  titles only · **VM-259** the top rows give way while scrolling.
- **VM-260** (High, not seated) — the phone's look, a second pass. **VM-261** (Parked, after v1) — working between
  several open notes.
- Sync, under Speed, second pass (VM-176): **VM-262** fewer server calls per round and the cleanup off every round ·
  **VM-263** the phone asks for changes while it sits open · **VM-264** a failed round retried, a request timeout.
- **VX-1034** (Low, Backlog) — the Mac's note-in-books list marks an archived gathering and stops offering Diverge on
  a gathering's row (VM-78's two calls, ruled).

- From the audit of the phone app outside the editor and the Castle audit, under The lock (VM-103): **VM-266**
  (Urgent) the library can lock after she has come back, and the lock waits behind an uncancellable sync round ·
  **VM-267** lock and unlock made solid · **VM-270** the phone writes backup copies it never prunes or lists, and
  three sentences name doors it lacks. Under The Library (VM-87): **VM-268** move the Library's paging and the Today
  door to shared code first. Under Home, wings and capture (VM-72): **VM-269** double-tap guards and untrue first
  paints.
- **VM-271** (Urgent, Umbrella) — the phone's editor core, the page is the truth. Its plan:
  `notes/plans/vm-271-phone-editor-core.md`.

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
| ~14:10 | The editor audit returned; VM-252 filed; the phone-app audit and the Castle audit started. |
| ~14:20 | Her first look at the wave-1 app recorded verbatim; VM-253 to VM-265 and VX-1034 filed; VM-247 promoted. |
| ~14:40 | The phone-app audit and the Castle audit returned; VM-266 to VM-270 filed; VX-1030's canon lines corrected. |
| ~15:10 | The editor design proposal page written; she chose option D. |
| ~15:40 | VM-271 minted; the outside research and the code inventory filed; the plan's draft v1 written and sent to one adversarial cold review (Opus). |
