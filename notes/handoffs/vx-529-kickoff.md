# VX-529 — the catch-up for a pair changed elsewhere (the orchestrator kickoff; written at VX-510's closeout, 2026-10-24)

**HER MANDATE (R-510-19, 2026-10-24: "VX-529: its own run, next"; the boundary R-510-20, verbatim in the VX-510
record):** "ok - no - we are NOT changing the castle rules at all. literally not even close to being an option. we
DIED to get that design to the point it is in - we aren't changing anything stored anywhere. so if you need to type
both secrets, that's fine, we just need to present that to users in a way that makes sense. because if you had sync,
you could move that library aside and let sync fill it in with your account passphrase, right? like you COULD get a
new library with the new passphrase there."

## THE PASTE-READY KICKOFF PROMPT (for her)

```
/architect-phase vx-529 — a passphrase changed on one device leaves the account's other devices on the old one: a
second Castle device stops syncing with no door to catch up (reproduced live on production at VX-510 — the repro is
the run record's "THE CHANGED-ELSEWHERE REPRO" section). READ FIRST, IN FULL, YOURSELF:
notes/handoffs/vx-529-kickoff.md (this file — the boundary R-510-20, the repro, the two roads), then
notes/plans/fixes/vx-510-first-run-sync.md's "THE CHANGED-ELSEWHERE REPRO" and rulings R-510-19/-20, then the
standard preflight (CLAUDE.md + canon, SyncSpec WHOLE, CastleRules WHOLE, SurfaceContracts' protection bullet,
SessionResiliencyProtocol). THE DESIGN MEMO COMES FIRST (P-5): the catch-up's whole behavior on paper — edges
enumerated, refusal wordings, both roads — brought to me for rulings BEFORE any build. The Castle rules are FROZEN:
nothing stored changes anywhere (no schema, no vault shape, no key-file shape, no custody-record shape).
```

## WHAT IS KNOWN (the VX-510 repro, live on production — verify, never trust)

- The follow covers POSTURE changes and KEY replacements only; nothing makes a second device take a PAIR (passphrase/
  words) changed elsewhere — rule 7 is silent on it. In Castle the lagging device cannot sync on its passphrase; in
  Standard it syncs on the quiet roads with a silently stale passphrase.
- The lagging device's state, observed live: the account's NEW passphrase refuses the lobby ("That passphrase doesn't
  open this library." — no VX-113 sentence); the OLD one opens it with "the typed secret opens the library but not the
  account's vault (changed elsewhere?)" in the log only; Settings ▸ Sync offers NO follow; Change passphrase old→new
  refuses WRONGLY ("That passphrase doesn't open this library." — the old one does open it; the refusal fires on the
  NEW passphrase's half); the twelve words (unchanged by a passphrase change) DO load the sync keys — a per-session
  workaround nobody would find. The check door's fourth answer names the state honestly ("…doesn't open this library,
  but it opens your account." — P-VX510-B3-2).
- W-12's sentence ("backups you made before today") is rule 7's own and reads wrong here — VX-526 holds it.

## THE BOUNDARY (R-510-20 — binding; the memory `castle-design-is-frozen`)

- NEVER a change to the Castle rules or to anything stored: no schema event, no vault-shape change, no per-library key
  storage, no custody-record change. The store-each-library's-key option is WITHDRAWN by her word.
- The catch-up TYPES BOTH SECRETS where it must ("if you need to type both secrets, that's fine, we just need to
  present that to users in a way that makes sense").
- Her second road is REAL and should be presented as one: set the library aside and re-join the account fresh — a new
  library fills from sync under the account's current pair. Caveat she accepted: unsynced writing stays in the
  set-aside library (it can be brought back by hand).

## THE SHAPE OFFERED AT VX-510 (recorded, NOT ruled — the memo weighs it, she rules)

A "Follow your account…" catch-up once the library is open (the old secret opened it): one door that types the
account's current secret and re-locks the library's key under the account's pair (rule 7's join re-lock — no key
change, no stored-shape change); the lobby naming the account's new passphrase as a road ("your account's passphrase
was changed on ‹device› — type it here after opening with your old one", VX-113's class); the check door's fourth
answer carrying the same door; the key door's wrong refusal replaced by VX-113's sentence. Plus the set-aside-and-
rejoin road said plainly beside it.

## MACHINERY

- Branch `vx-529-<slug>` in its own worktree; the record `notes/plans/fixes/vx-529-<slug>.md`; the standing cast
  (Fable orchestrates and cold-reviews, Opus implements); pin-before-fix; the custody/`Sync/` slot — the fix touches
  custody seams, so at most one such effort runs at a time and the Fable review is mandatory.
- The prod test accounts (`std`, `castle`) stand as the live-proof vehicle if she keeps them at VX-510's closeout;
  the repro's exact legs are the acceptance's template (the VX-510 record's repro section).
- The dev-store rules, the stage, and the A1 rail bind as everywhere (CLAUDE.md).
