# VX-309 — Author handoff, 2026-10-20

**Phase 5 of the Castle rebuild (copies and words) is CLOSED: built, laddered, walked and merged.** PR: https://github.com/lduarte-io/Variorum/pull/182 (merged by merge commit at the coordinator's GO-MERGE). The run record is
`notes/plans/vx-309-copies-and-words.md`: §1b the cut, §5 the briefs, §6 the unit records and arbitrations, §6-L
the ladder, §8 the walk, §9 the closeout. The new road is still Debug-only, `lockstepVersion` stays 13 and artifact
17 is still held. No release and no `/Applications` refresh came with this close: nothing changed on the Release road.

Fable orchestrated up to the walk's throwaway block; Opus finished the walk and the closeout after your Fable
credits ran out (your word: "I'm happy with Opus, let's just keep going").

## Your checklist

1. **QUESTIONS #237, your VX-309 bundle.** The calls that matter, in order:
   - **VX-469: entering Castle leaves a Previous Library's quiet roads.** A library you made from a backup can
     enter Castle while the library you stepped away from (in Previous Libraries) still opens silently through Look
     inside. Deleting that library's copies doesn't remove its quiet roads either. Options: (a) as built, (b)
     entering Castle also sweeps Previous Libraries' quiet roads on this Mac, (c) the Castle confirm says so.
   - **VX-470: bringing in a plain-text copy from a Castle library lands in Standard.** That reads against rule 17's
     "You never leave Castle by opening something." Options: (a) as built (the confirm says "in Standard"), (b)
     refuse while in Castle, (c) land it in Castle with your current pair typed.
   - **VX-463: the twelve-words fields show what you type; the passphrase field hides it.** Conceal the words
     too (with the reveal eye), or keep them visible so you can check them?
   - **VX-468: the what's-new card appeared on a just-restored library's first open.** Fine there, or should it
     wait?
   - **The join message (F-U2-1)** now reads: *"Your twelve words are <email>'s twelve words. Your previous twelve
     words still open backups you made before today. If you don't have your account's words written down, you can
     make new ones at any time."* This is your draft with only the "If this is your first time signing in" lead-in
     dropped. I had first dropped the whole middle sentence, which was my misreading, and I fixed it. Both texts are
     in #237.
   - **The twin-less far copy (P-VX309-R1-1)** and **entry dates through a plain-text copy (F-R2)**: two smaller
     option questions, written out in #237.
   - Everything else in #237 is a PROVISIONAL built as its option (a). Accept them as a set, or pick any to change.
2. **No rotation of the dev words.** Recorded as your word; `dev-castle.env` stays true.
3. **Kick off what's next when you're ready.** The release switch's plan is `notes/plans/vx-329-release-switch.md`,
   with a paste-ready kickoff at its top. Its first questions are yours (below).

---

## VX-309 Phase 5, copies + words
DONE: built, laddered (round 2 clean: 0 blocker, 0 major) and walked; merges at the coordinator's GO-MERGE.

THE COPIES (rules 17–19, 21, 27):
- [x] The pair leg lands in the picked backup folder (P-VX306-U1a-4 came due): one backup in two places with the same name, one a day in the picked folder; walked byte-identical
- [x] VX-302 Retention per library per Mac (VX-411 folded): newest 14 beside the library, 14 days + 4 weeks in the picked folder, only this Mac's pairs of this library. A future-dated copy never takes a slot (a red the Mac suite caught, fixed and pinned)
- [x] VX-397 Shared far folder: the due-check and Data Safety's count read per library per Mac
- [x] VX-265 A separate delete choice for other libraries' copies: walked on a throwaway; the open library's rows never carry it, and the lobby shows none
- [x] VX-210 The honest line about copies in folders Variorum doesn't manage
- [x] VX-209's remainder: the synced confirm's sentence (with VX-264 item 7's concrete line)
- [x] VX-305's hand-offs: T-5, Make this my library into the empty slot from the missing face (walked: landed held, with the fresh-words card), and reopening a Previous Library through the doors
- [x] T-8 (your ruling): a plaintext export brought in lands as a NEW library (walked: Standard, not held, counts in the receipt, your old library set aside whole)

THE WORDS:
- [x] VX-379's phase-5 share: the guide's new-road chapter (three lessons, Start Here passages leading) + Data Safety's "what opens a backup" line, walked in Study and Terminal. The truth-check and your real store's re-seed ride VX-329's window as planned
- [x] VX-211 Passphrase strength: the 12-character floor as the only refusal plus one quiet hint on every new-road setter (walked live)
- [x] VX-213's share: record corrections + privacy text. **pg_temp is still held for your go** (VX-329's window)
- [x] VX-264's copy words: item 5's older-libraries sentences + item 7's concrete per-library line
- [x] VX-263's route finder → one sentence: *"Every copy of this library opens with your current passphrase or words; on this Mac, its quiet road opens it too, if it still holds that copy's key."*
- [x] VX-317 — already done at VX-348 (stale tracker row)
- [x] Pre-rebuild copy refusal — superseded
- [x] VX-301 — superseded

YOUR CALLS AT THE KICKOFF (all answered at the sitting):
- [x] #236's acceptance — your kickoff accepted it (the QUESTIONS edit lands at the merge)
- [x] VX-455's home: post-release; its not-yet line was reworded here (pin-covered; the face needs an account with no vault)
- [x] W-VX308-3 — kept app-level (record only)
- [x] F-U4-3 — kept the ruled pair (record only)
- [x] VX-211's shape — floor + quiet hint
- [x] Riders: VX-450 · VX-451 · VX-453 · VX-454 · VX-444 joined (+ standing VX-456 · VX-457), all landed. VX-456 has one arm left (VX-462). VX-449 · VX-452 · VX-101 · VX-100 stayed out

TICKETS MINTED (VX-461 … VX-475):
- **High**: VX-461 Data Safety's "Export an unencrypted copy" writes an empty file (both roads; a VX-329 input) · VX-469 Castle entry leaves a Previous Library's quiet roads (needs you) · VX-470 plain-text bring-in from Castle lands Standard (needs you)
- **Medium**: VX-463 words fields in clear text (needs you) · VX-465 the dev library's device ID drifted between walks (trace before VX-329) · VX-471 a failed bring-in after the step-aside leaves the slot empty · VX-472 a failed copy-delete leaves the open library's acts stuck
- **Low**: VX-462 the join message after set-up → stop → re-join (VX-456's last arm; known-issue pins in place) · VX-464 the join refusal says "this library" for the account's passphrase · VX-466 a renamed migration id reads as "newer Variorum" · VX-467 Make-mine's own first backup skips the picked folder · VX-468 what's-new after a restore (needs you) · VX-473 the hold banner's "catch up with your account" over an unsynced library (seen live) · VX-474 two test traps · VX-475 the attacker test reads an old SQL file
- Comments: VX-329 (seven switch inputs) · VX-234 (the Protection row's "escrow" blurb) · VX-264 · VX-456 · VX-379 · VX-213 · VM-8 (the phone's guide chapter and passphrase faces)

Later phases, from this run:
- [ ] VX-329: the release switch (plan written: `notes/plans/vx-329-release-switch.md`)
- [ ] VX-212 Phase 6, the poison-row case. Whether the switch waits for it is your call
- [ ] VM board: the phone's new-road faces (VM-8's ledger row)
- [ ] The throwaway project stays up until the rebuild releases; then you delete it (~1¢/hr). It now also holds walk accounts A and B with their test vaults

---

## Your questions, answered

**"Is fixing the export bug a custody change?"** No, I said that imprecisely. The export button lives in Data
Safety, and the fix is about file access when you pick a folder, not about keys. Any Opus run can fix it without a
Fable review. What does need Fable (or your waiver) is a change inside custody/keychain code, `Sync/` or the editor
seam: VX-462's fix, and the switch itself.

**"Was the phase's aim achieved, and is the switch still possible?"** Yes to both. Every member landed, the ladder
closed clean and the walk checked the important paths on a real build. Nothing found blocks VX-329. Two tickets
should be settled before the switch:
- **VX-461.** Rule 26 tells everyone to export before the switch, so either fix the export button first (small) or
  have the switch-day steps name another road.
- **VX-465.** Trace the device-ID drift. It's probably a dev-only test artifact, but if it can happen in Release,
  the "this Mac's copies" counts and retention would be wrong.

Your three design calls (VX-469, VX-470, VX-463) don't block the switch mechanically, but they're Castle-promise
questions better answered before anyone else uses it.

**"What has to happen before this is actually live?"** In order:
1. **This merge.** The coordinator gives GO-MERGE, then I write the shared ledgers on latest main (QUESTIONS #236's
   acceptance + #237, the record entry, the master plan) and merge. VX-309 is then closed.
2. **Your answers to #237** (above).
3. **Your calls before VX-329 starts:** does the switch wait for VX-212 (phase 6)? Fable credits back, or a waiver,
   for the switch's cold review (it's custody code)? Fix VX-461 first (I'd say yes; it could ride VX-329 as a
   rider)?
4. **VX-329's own run.** The new system turns on in Release. Today's whole deciding and writing code is deleted
   (the design's §3.15 list; VX-233 and VX-406 go with it). The protection suites run under Release, there's a Fable
   cold review, and the plain-text-copy and key-history facts for the website are rewritten (F-U2-4).
   Two rehearsals, before any real store crosses:
   - **The switch-day steps on the throwaway project**, start to finish. In particular this must prove how a
     fresh library gets your synced writing back. Today's account holds your writing under today's sync keys; the
     new account vault is new (artifact 17). Rule 15 says the account keeps every sync key it has ever had; VX-329
     has to show that this holds across the switch, not assume it.
   - **A byte-copy of your real store** on the Pro's dev slot: Look inside, then Make this my library, with your
     hands and your real passphrase/words. This is the first time your actual library meets the new road.
5. **Switch day** (your go): the mirror deploy (marker 13→14) and the new build on every device in one window.
   The order is below.
6. **Your acceptance on both Macs and the phone, then the release at your word.** I draft the release notes for
   you. After that: the website facts to the site agent, then you delete the throwaway project.

## What to test, and when (your hands)

**Now, before VX-329:** nothing on your real stores. The new road is Debug-only, so your real Macs keep running
today's road. Your part now is #237 and the kickoff calls.

**During VX-329's run:** the rehearsal on a byte-copy of your real store (the session sets it up; you type). Watch
for: does your library open, look right, and are the counts true.

**Switch day, the Air first.** This is my proposed order; VX-329 writes the exact steps and rehearses them first.
0. **On the Pro, before anything:** check that sync is caught up and make an export by whatever road VX-329 names.
   The session takes the A1 safety copy. Nothing is deleted at any point: your old store stays whole as a copy
   (rule 26's "kept whole").
1. **The Air.** Install the new build. It starts fresh (no migration):
   - The first open should be calm: the Bookcase and the band card, no popup.
   - Record the twelve words on paper and set a passphrase. Try a short one to see the hint, then use a long one.
   - Sign in. If the Air is the first device on your account it **sets up** the account, and its passphrase and
     words become the account's. Otherwise it **joins** and the join message names your email.
   - Confirm your writing arrived.
2. **The Air, the Castle round trip:** Use Castle (both secrets) → choose Touch ID → ⌃⌘L locks → reopen with Touch
   ID → reopen with the passphrase → set the idle dial → Use Standard back, or stay in Castle if that's where you
   want to live.
3. **The Air, backups:** Settings ▸ Data Safety ▸ Back Up Now, with a second folder picked. In Finder, check that
   the same backup sits beside the library and in your folder. A second press the same day adds one only beside the
   library.
4. **The Air, the restore drill:** Restore from Backup → Look inside (read-only) → Make this my library on a fresh
   backup → held, the banner, the receipt, the old one in Previous Libraries → Resume Sync when ready.
5. **The Pro.** Install, start fresh, sign in. It joins the account and the join message names your email. Check
   the writing, and check that edits flow both ways with the Air.
6. **Two-Mac checks I couldn't walk on one Mac:** enter Castle on one Mac → the other follows. Its "Done" notice
   should stay until you press OK, even with receipts set to off (VX-457). Then Change passphrase on one Mac → the
   other asks for the new one when it next needs it.
7. **The phone:** install, join, sync, lock. The phone's new-road build has to be ready first (VM board, checked at
   VX-329's kickoff).

**Do you need to hand-test things like "set up a library from new"? Mostly no.** The suites cover the logic
closely: every act's rows, every refusal, interruptions and resumes, how each screen derives its state, and the
doors' routes. This phase alone ran about 1,200 Mac tests across its batches, plus the core suite, plus a walk.
A fresh library's calm first open is pinned and was created by hand twice in this walk. On switch day you'll do it
anyway on the Air, because starting fresh *is* the switch's path, so you'll see it for free.

Where your hands matter is what tests can't reach:
- Apple's own systems: iCloud Keychain moving keys between your Macs, Touch ID, and the sandbox's folder
  permissions (exactly where the export bug hid).
- The production server.
- Your real library's size and history.
- How the sentences read to you.

Steps 1–7 above are aimed at those.

---

## Where things stand after the walk

- **The dev store:** Standard, `e11e5233`, the restore hold and banner standing, Resume never pressed, signed out,
  0 instances. The dev pair is unchanged.
- **Walk slips (all in §8):**
  - Two early captures held the dev words because the words field shows typed text (both deleted, never committed;
    VX-463).
  - A stale September Debug build ran for about 8 seconds on the missing face. Recovered whole and cmp-verified.
  - One test-account password was typed visibly into an email field. The capture was deleted; it's a throwaway
    account's password.
- **What I couldn't walk, and why** (all pin-covered):
  - The "move not yet" line: it needs an account with no vault.
  - VX-457's follow: it needs a second device.
  - VX-211's 11-character refusal press.
  - T-8's archived-book and wing shapes. The pane's export button was broken (VX-461), so the walk used the test
    suite's own export fixture.

## Machinery notes (for the next session)

- The walk's Debug app lives at `App/Variorum/DerivedData/vx309/…/Variorum.app` in the worktree. The standard
  DerivedData path holds a September build; never launch that one on the dev store.
- cliclick's Return doesn't reach save/open panels or the ⌘K palette. Use System Events key codes 36 (Return) and
  53 (Esc).
- Settings scroll: real wheel events from a tiny scratchpad tool (`scrolldown`); setting the scroll bar through
  accessibility snaps back.
- Secrets go into fields only as env-read keystrokes (`osascript … keystroke (system attribute "VAR")`), each field
  clicked directly. Take captures only before typing.
