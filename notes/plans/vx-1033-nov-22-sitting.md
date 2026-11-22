# VX-1033 — the Nov 22 sitting: wave-1 handoffs, wave-2 questions, the phone install, what runs next

**Ticket: VX-1033 · Branch: `vx-1033-nov-22-sitting` · Worktree: `~/dev/variorum-vx-1033` · the Pro**

## FOR A LATER READER

*(Kept current while the sitting runs; rewritten at its close. Last rewritten just before a context compaction,
2026-11-22 late afternoon.)*

- **The editor design has LEFT this sitting (2026-11-22, late).** After the second round of reviews she moved VM-271's
  design to a fresh, standalone design session that starts from the ground up. Everything that session needs is in
  **`notes/plans/vm-271-design-session-brief.md`**: her words, the problem, the three reviews' findings, the direction
  the orchestrator recommended exactly as it was told to her, her lean against it, and the reading order. Plan v2 is
  marked not approved. What remains of this sitting is its close (RESUME HERE, "Still owed").
- **The sitting narrowed to one thing: the phone's editor core (VM-271).** Her other sessions take the Mac feature,
  the Mac bug, and the remaining wave-1 handoff bundles and wave-2 questions. Mobile wave 2 waits until VM-271 is
  done ("I'd rather the core of the app be stable before making more changes").
- **The phone install is done.** The app built from `fe1493c16` went onto her iPhone in place over Wi-Fi with
  `devicectl`, no cable, no safety copy at her word. VM-24's "before" session was skipped and is no longer owed.
- **Four audits and one research report are in `notes/plans/vx-1033/`:** phone sync lag, the phone editor, the phone
  app outside the editor, the phone against the Castle rules, and outside facts on iOS text input; plus the code
  inventory for the new core.
- **Her text-loss recording is VM-250; the traced corruption window is VM-252.** Both stay open as launch gates and
  are NOT to be patched in today's editor, at her word.
- **The editor decision:** from the proposal page (`notes/plans/vx-1033/design/phone-editor-proposal.html`, five
  options) she chose "the page is the truth". The plan is `notes/plans/vm-271-phone-editor-core.md`, **draft v2**.
  v1's cold review (`notes/plans/vm-271-plan-cold-review-1.md`) found three blockers; v2 keeps accept-then-read
  only for typing inside a block and makes every structural gesture go through her doors with the Mac's shared rules
  deciding the result. She agrees with v2 broadly and asked for a second round: a general cold review and a
  sync-focused one. Both were running when this was written (see RESUME HERE).
- **Rulings so far** are in "Her rulings" below and, for the plan, in the plan's own §2 and §20.

## RESUME HERE (state at the compaction)

**Read this paragraph first; it supersedes what follows where they differ (2026-11-22, ~17:20).** Both second-round
reviews landed and were put to her, with one recommended direction ("for structure, the library goes first"). She
leaned against it and took the design out of this sitting. Her words: "I can see from how all of this is going that
this is very castle-esque in effort and I think that I simply need to start a new conversation and slow things down
to the point where I understand everything and where it is really thoroughly, the trade offs thoroughly, and think
more about what the solution should be. … I'm raising it from being an offshoot of a catch all planning session to a
new, fresh, standalone design session. … I will say that my initial lean is that v3 is not the correct approach at
all - a note that doesn't let you write a newline because it's waiting on sync is a broken app, honestly." Her full
message is in `notes/plans/vm-271-design-session-brief.md` §1. So: **no v3 is to be written here; the plan is marked
not approved; the positions listed below are history, kept for the new session's reference.** This sitting's
remaining work is its close ("Still owed", below). The hold "nothing is merged to main until the plan is approved"
no longer has its condition; whether this branch merges now, with the plan marked not approved, was put to her and
is hers to say.

**In flight.** Two Opus reviewers of plan v2, started 2026-11-22, each writing to the session scratchpad
(the session-specific scratchpad folder; its full path is in the session's memory file, not here):
`vm-271-plan-cold-review-2.md` (general, adversarial: checks v2's dispositions and attacks what is new) and
`vm-271-plan-sync-review.md` (sync only: the two-device matrix, the placement check, the rescue, tokens against a
sync apply, deliveries onto the page, offline, Castle, and whether the Mac has the same hole). Their hand-backs
arrive in the session as messages. If a file is there and no hand-back came, read the file.

**Update, 2026-11-22 ~16:15 (after the compaction).** The sync review landed and is in the repo:
`notes/plans/vm-271-plan-sync-review.md` (Opus; two blockers, eight majors, nine minors, a 28-cell two-device matrix,
seven decisions for her). Read whole by the orchestrator and spot-checked in the code, all holding: `divide` and
`merge` take `guardedBy` and check neither the text they were planned on nor (for `merge`) the fans; the MCP door's
`divideBlock` guards exactly that race; `Repairs.swift` treats a live unplaced block as legal; `hasPendingAutosave`
reads only the coordinators; the Mac's seam join reads fans from the store; SyncSpec §7 accepts structural duplicates
on the premise "structural editing is desktop-only"; every autosave writes the container row. Its cell 7 (a version
restore racing unpushed phone typing) is the reviewer's inference and was not run. The general review was still
running. What it changes in the positions below, pending her word:
- *Item 3 is answered, and differently from v2.* The save-time placement check catches only saves made after the phone
  has heard of the other device's change; the common case is words saved (and pushed) before it hears, which strand in
  lineage in every order of arrival. The catch belongs at the delivery, in the editor that wrote the words, with a
  store-level hint at open as the backstop. §20.1's parameter becomes optional. The Mac has the same hole today, and
  phone Return and backspace make it more frequent on the Mac.
- *New, and a blocker:* a structural act planned on the map's text and run on rows a sync pull just changed overwrites
  the other device's words (v2's §10.1 adopts the operation's result as the save base). Every structural operation the
  new editor sends carries a `WriteGuard` re-checking the texts, the fan and the adjacency it was planned on; a result
  is adopted as `stored` only when it equals the ruled page.
- *Item 4 (the rescue) is per cause, not one shape:* rebase her words into a merged successor when that composes
  exactly, else a new block; a locked or deleted shown take becomes a take on the same block; a remote delete, archive
  or move are hers to rule (the canon lets the delete win; a moved block is visible elsewhere).
- *Hers:* the review's D1–D7 (where stranded words are caught; whether `autosave` gains the check; the rescue per
  cause; SyncSpec §7's accepted duplicates now that the phone divides and joins; the Mac's exposure; refuse-and-undo
  versus re-plan; words refused at a lock).

**Update, 2026-11-22 ~16:50.** The general review landed and is in the repo:
`notes/plans/vm-271-plan-cold-review-2.md` (Opus; verdict "would not approve v2 yet; the direction is right, the
specification is not"; three blockers N1–N3, majors N4–N16, a row-by-row check of the identity table, the roads that
bypass the doors, the saver traced, ten more probe steps). Read whole by the orchestrator and spot-checked, all
holding: the Mac's seam join refuses on a live active fan only, read from the store, and locked takes do not refuse
(`EditorEditRoute.swift`'s `textedSeamMerge` doc); the archived-take and comment guards are the carve's; the
coordinator keeps the first record's base for a whole save run and has no way to drop an entry; divide, divideW,
extract and merge copy comments to their successors; typed crystallization fires at the next paragraph's first
character, not at Return; the phone's edit helper calls the public `insertText`; the compound's outcome carries no
take id; the phone has no ceremony sheets and no Merge with Next; the Mac's structural door says "The store leads —
the surface is never pre-written optimistically" and replays keys typed during a flight.

**Two errors in v2 that were the orchestrator's own,** to be said to her plainly: §8.2 gave the backspace join the
carve's refusals (an archived take, a comment, a locked take), which contradicts her ruling "backspace at block start
joins with mac's exact rules"; and §5.3's "known without asking (one take, no comments)" is false for every block a
divide, extract or merge produces.

**Where the two reviews meet, and the orchestrator's position for v3 (hers to hear before v3 is written):** v2 is
optimistic: it writes the ruled page from the map's copy of facts only the library holds, and lets the library answer
afterwards. The Mac never does that. N1–N3, N9, N10, N12 of the general review and B1, M2, M4 of the sync review are
all costs of that one choice. Position: **for structure, the library leads.** A structural gesture is caught at her
door and held; the operation runs, guarded on the texts, the takes and the neighbours it was planned on; the page is
then brought to the operation's result by one small edit through the text view's own calls; keys typed meanwhile are
held and replayed, as on the Mac. That removes tokens, the hold-and-rebase, the inverse of a refused act and the
optimistic rebase, and makes a change from another device and her own act reach the page by the same road. Its cost:
a structural key waits for the library (a few milliseconds on an ordinary note, longer when something holds the
writer), and it leans on the probe question v2 kept as the fallback (a key declined and re-issued on a later turn).
The in-call door of v2 stays as the alternative if the probe shows a later-turn edit upsets the keyboard and an
in-call edit does not; Return making an empty block may keep the in-call door for feel, since it reads no library
fact. It supersedes, in the new editor only, VM-64's P-2-1 (a key typed while a divide or merge lands is refused and
said), which she kept this morning: hers to say.

**More that is hers, from the general review:** the open end's typed road (store what is on the page, untrimmed, as
the idle mint does; or tidy the line above her caret while she types; or mint one paragraph late); the full list of
shared-code changes (more than v2's two: the coordinator's per-entry refusal and a way to drop an entry, the
session's flush roads learning about acts in flight); the first-change quiet commit of §15.5 as a new auto-commit
occasion; more units than eight (the Write screen's chrome has none; U2 and U3a are each more than one session).

**When they land.** Read each whole (reading is not delegated). Scan for private text, copy each beside the plan
(`notes/plans/vm-271-plan-cold-review-2.md`, `notes/plans/vm-271-plan-sync-review.md`), commit. Spot-check the
load-bearing claims in the code before accepting them. Write v3 of the plan with a disposition for every finding
(add to its §21). Bring her the findings and v3 together, in plain words. She wants to keep talking the sensitive
parts through; do not rush to approval.

**The sensitive parts she wants talked through** (my position on each, so it is not lost):
1. *The doors.* v2 catches structural gestures inside the text view's `insertText`, `deleteBackward`, `cut` and
   `paste` overrides and makes the ruled edit there, synchronously, through the text view's own calls. The phone
   already ships one such door (Return, for list continuation) and predictions still work on her phone. The
   fallback is decline at the gate and re-issue on the next turn (React Native's shape). Whether either upsets the
   keyboard is the probe's first question and the plan's kill criterion K2. If both fail, a single text view cannot
   give the Mac's results and the choice returns to her (a custom text input under the same core, or results that
   differ from the Mac's).
2. *Identity.* §8's table says which region is which block after every act; a token goes on every region an
   operation may re-identify; the head (the first block's mark) is re-pointed like any mark. It must be proven by
   an oracle that runs the real shared rules and real operations, because a text-only comparison passes a wrong
   binding.
3. *A save checks its block is still in this note* (§11.3, §20.1). Today `autosave` writes into a take whose block
   has no placement (verified: `editableVariant` → `ensurePlacementUnlocked` is a no-op without a placement), so a
   block merged on another device silently takes her words into lineage; and a refused save is held pending forever
   (`AutosaveCoordinator` keeps the entry). The fix proposed is one optional parameter on `autosave` and on the
   coordinator's entry. It is an operation-contract change: hers alone. She leans yes, pending the sync review. Open:
   whether the Mac has the same hole (asked of the sync reviewer), and whether the check must also hold at apply
   time on other devices.
4. *The rescue* (§11.4, §20.2). v2 says: a new block at the region's place; for a note sealed elsewhere, the words
   stay on the page with Copy. I am not settled on this. A rescue block can duplicate text that survives in a merged
   block; a take on the successor is closer to the model's own conflict-as-variant but has no single successor after
   a merge. The sync reviewer was asked to compare.
5. *Normalizing.* The page is made to match the Mac's result at the gesture (a join's space, a divide's trim, the
   cut's settle). The one adopt-the-page case is the idle mint of the open end, stored untrimmed (§20.3, hers).
6. *Text still forming.* The marked range is cut out of what is saved. At a durability moment a prediction's guess
   is discarded, dictation and a composition are accepted (§20.5, hers). Inline predictions start off.
7. *Outside changes.* Facts (takes, comments, locks) update the map at once. Structural deliveries and undo for
   regions she is not in do not wait for the keyboard; the region she is in is lowered and rebuilt. A swipe-peek
   must not bounce the keyboard (the probe measures both ways).
8. *Size.* Eight units in four runs. U1 is the probe on her phone, run from a FRESH session with a kickoff (she
   agreed). Decisions gating run 2: §20.1, §20.2, §20.3; §20.4 and §20.6 are ruled.

**Her rulings on the plan so far:** option D chosen · today's editor not patched · a cheap switch that only chooses
which screen opens a note, no dual support, the old editor deleted when features move · wave 2 waits · backspace at a
block's start joins with the Mac's exact rules · Return makes a block, with a "new line" key · the Mac's per-note
"newlines make blocks" switch comes to the phone and lives in the note, not in Settings (VM-141, pulled into U3b) ·
the probe runs in a new session.

**Still owed at this sitting's close** (after she approves the plan): today's rulings written into
`notes/QUESTIONS.md` as bundle addenda in her words (#277 VM-55: P-55-2/-14/-15/-18 ratified, P-55-3 kept, P-55-19 →
neutral colour, VM-265; #279 VM-78: both marks, the Mac hides Diverge, VX-1034, VX-1030 done; #280 VM-64: P-2-1 and
P-71-1 kept, the gates confirmed; #282 VM-24: VX-68 stays closed, the before-session skipped; #276 VX-980: P-980-3
option (a); the rest of #276, all of #278 and #281 stay open for her other session) · an `notes/AppSpecRecord.md`
entry for the sitting and the SurfaceContracts correction · the master plan's in-flight row for VM-271 ·
`Tools/canon-size` · `notes/handoffs/vx-1033-handoff.md` with her checklist · the PR (`VX-1033: …`, a merge commit,
never squash) and merge to main · VX-1033's disposition comment and Done · the board snapshot · memory · the kickoff
message for VM-271's run 1 (`/architect-phase vm-271`, U1 the probe then U2 the core) for a fresh session.

**Working rules that bit or held this session:** subagents are Opus or Sonnet only, never Fable, at most two at a
time, always with `model` pinned · the stage goes through coordinator **nov22** (she started it for the Ambient
work) · nothing is merged to main until the plan is approved (an unapproved plan on main reads as the plan) · her
words go into records verbatim · no text of her notes is ever committed (the recording's frames are local only, in
the main checkout's `notes/plans/textloss-screens/`) · pages for her are local HTML with the absolute path, never an
Artifact, never opened for her · no time predictions; sizes are fine · the Mac's editor is not to change · the
Castle design is frozen.

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

**On the switch (2026-11-22):** "why are we adding the new editor behind a switch rather than just building the new
editor?" — answered in chat: the new editor arrives in pieces and its first piece has no takes, lenses, badges or
find, so the switch lets her hold the risky part early without losing her daily app; and the draft's dual support
(features working with both editors, the old one living on to a separate retirement run) was more than that needs.
Her reply: "ok I suppose a cheap switch for an early look is fine - I just want us to be strategic with the work, but
it makes sense to me to do a cheap try first. about the shape of the work - make plans for how we're going to do this
and I will follow them. we can do the part that we can do here, then you'll leave me with a kickoff message for the
next part of the plan. i imagine we'll do this before wave 2? also - i'm planning that feature I mentioned in another
window, I'll handle filing the mac bug in a different window, and I'll handle the handoffs / wave 2 questions in
another session as well. we can fully focus on this work - is there any loose thread that I should be aware of to
handle outside of this session?"

So this session's scope narrows to the editor core (VM-271): the plan's revision after its cold review, the probe on
her phone, the kickoff for what follows. The Mac feature, the Mac bug, the remaining handoff bundles and the wave-2
questions are hers in other sessions.

**On the order (2026-11-22):** "i'll probably just wait and only run wave2 once this is done. I'd rather the core of
the app be stable before making more changes. "that session" will not add anything to questions first - i probably
won't even run it until all of the other issues / handoffs /etc. are done." So mobile wave 2 waits for VM-271, and
this session writes today's rulings into `notes/QUESTIONS.md` at its close.

**On plan v2 (2026-11-22):** her words are in the plan's §2, verbatim. In short: she agrees broadly; wants a second
cold review and a sync-focused one (both started, Opus); ruled "backspace at block start joins with mac's exact rules
- yes" and "return makes a block - yes, agreed"; asked for the Mac's per-note "newlines make blocks" switch on the
phone, living in the note and not in Settings (VM-141, pulled into VM-271's U3b); agreed the probe runs in a new
session from a kickoff; and asked what "a save checks it is still in this note" means (answered in chat: the block's
place in the note; a block merged, divided with takes, deleted, archived or moved on another device has left it, and
today's save writes into it anyway).

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
| ~15:55 | Plan v2 written after the first review; her broad agreement and rulings recorded; two Opus reviews of v2 started (general, sync). A context compaction followed. |
| ~16:15 | The sync review landed, read whole, spot-checked, copied to `notes/plans/vm-271-plan-sync-review.md`. The general review still running. |
| ~16:50 | The general review landed, read whole, spot-checked, copied to `notes/plans/vm-271-plan-cold-review-2.md`. Both reviews put to her in chat with one position (for structure, the library leads). v3 not written: it waits for her word on that. |
| ~17:20 | She leaned against that direction and moved VM-271's design to a fresh standalone design session. `notes/plans/vm-271-design-session-brief.md` written for it; plan v2 marked not approved; a kickoff prompt for the new session given to her in chat. |
