# Per-note / per-journal protection (DESIGN NOTE — for a future row)

**Status: DESIGN NOTE ONLY — created 2026-08-19 at the author's
instruction ("please record the rest of the notes we have today on the
architecture of per note / per journal in a note for a future row").
There is deliberately NO master-plan row yet** — she creates it at her
word; this note waits so the row's design sitting starts with the whole
conversation in front of it. Binding nothing beyond her verbatim words.

**What is NOT this note's scope:** the APP-LEVEL lock — ruled into 13l
the same day (whole-app Touch ID/Face ID gate, passphrase fallback,
honest wording; see the 13l brief, scope item 6). That item covers her
named walk-by-snooping threat and ships independently of everything
below.

## Her words (2026-08-19, verbatim)

The original ask:

> "i've been thinking about adding a setting where people have to put in
> their passphrase or biometric unlock particular notes or books (like
> journals). what would the lift on that look like? i know right now
> things are not encrypted on the disk so i'm conflicted."

The product case:

> "I do like the idea of having my journal locked, it makes me feel like
> I would feel safer writing in it."

The honesty constraint:

> "I feel like very few people would know to extract a file from a disk,
> but i don't want to imply more protection with a password than is
> real."

The sequencing instinct (hers, and this note's standing disposition):

> "my instinct is that it is important to me but that given that
> everything has been written assuming plaintext rows, it is more of a
> design sitting and shouldn't be rushed out. it also doesn't need to be
> rushed out for v1."

## The threat-model layers (the framing that resolved her conflict)

Four layers, four different jobs — the design should always name which
one it is buying:

1. **FileVault / iOS file protection** — the device at rest (off,
   stolen, disk pulled). Already the standing 14b answer for the
   plaintext local store.
2. **The login password** — the session.
3. **The app-level lock (13l)** — present company at an unlocked,
   logged-in machine. Presence control, no cryptography, honest by
   wording.
4. **Per-note protection (this note)** — the same presence threat at
   finer grain, PLUS (only in shape B below) real at-rest guarantees
   past FileVault.

## Shape A — the per-note access gate (the mid-size phase)

A per-note flag; the app refuses to RENDER protected content until
biometric/passphrase succeeds; unlock state is session-scoped. Crypto
lift ≈ zero. **The real cost center is the redaction sweep:** content
leaks through many more surfaces than the editor — library cards,
search, the tray and Trash listings, lenses/Compare, lineage views, the
block-TOC's derived first sentence, exports, the canvas. A gate that
covers the editor but shows a first line on a card is a false promise.

- **Enforce centrally in the Queries layer** (protected containers
  redact at the query, not per-view) — the one-read-layer architecture
  makes this tractable; audit it with the 13b capability-matrix
  discipline.
- The flag column is a small additive **§12 lockstep event**.
- The phone honors the flag (Face ID); the flag syncs, so mobile is
  automatic once its faces comply.
- For a protected note, "invisible to every derived surface until
  unlocked" is the FEATURE, not a limitation — which is exactly what
  makes A a genuine PREFIX of B, never throwaway work.

## Shape B — real at-rest sealing (the large phase, if ever)

What Apple Notes' locked notes actually are. What it adds over
A-plus-FileVault: someone at the *unlocked* machine with a DB browser,
malware reading the file in-session, store copies landing somewhere
unencrypted. Real threats, narrower margin than "not encrypted on disk"
suggests.

- The entire read layer assumes plaintext rows (search, render, diff,
  the bridge's hash sweep) — this is WHY 14b confined encryption to the
  one wire boundary. B means a local-seal boundary in front of protected
  rows; big, invasive, its own design sitting.
- The primitives all EXIST (the 14b cipher, AAD discipline, the key
  vault, per-class keys). The invasiveness is read-side, not
  cryptographic.
- **B-lite, the targeted variant:** seal only the JOURNAL class locally,
  its class key held in the Keychain behind a biometric access-control
  gate (Face ID/Touch ID literally IS the key release). If the
  Apple-Notes-taught expectation ("locked = encrypted") ever needs to be
  TRUE, make it true for journals specifically rather than encrypting
  the world.

## The knots (the future sitting's agenda)

- **Protected BOOKS vs protected notes.** A note lives in many books —
  protect the membership or the note? Lean: per-note truth with a
  book-level convenience ("protect all members"), but hers to rule.
- **Visible titles while locked.** Apple Notes says yes; users will map
  to that precedent. Also the precedent's trap: Apple Notes taught
  everyone locked = encrypted — the honesty wording must carry here even
  more than at the app lock.
- **Trash/tray behavior** for protected notes (13j's surfaces are a
  sweep target like every other listing).
- **The Fragments bridge.** A protected Variorum journal is still
  readable in Fragments today (journal-class E2EE decrypts on both
  ends). Options when the phase runs: Fragments grows its own app lock
  (same walk-by logic on the phone), protection crosses the bridge as a
  contract ask, or the asymmetry is accepted knowingly. A contract-file
  conversation (`notes/fragments-bridge-contract.md`), hers to carry.
- **The 13n MCP door.** Protected notes excluded from grants BY DEFAULT
  — rhymes with §9's standing "journals excluded from 'always'" consent
  rule; the two features should share one instinct.
- **Search sequencing.** The whole-library-search row carries a KICKOFF
  PIN (added 2026-08-19 at her instruction): before the indexing is
  designed/built, ask her whether this decision needs reconsidering if
  it wasn't already handled — **the index must never contain what
  protection hides.** Even under later retrofit the cost is a re-index,
  not a redesign, PROVIDED the search design keeps the exclusion door in
  mind — which the pin guarantees.

## The honesty doctrine (hers)

One true sentence in the feature's own settings description, always:
what the lock does (hides from view), what it does not (no encryption;
FileVault covers the files). If shape B ships for a class, the sentence
upgrades to the truth it earned — never before.

## Standing disposition

Not v1 (her word). Not rushed (her word — "more of a design sitting").
The decision checkpoint is the whole-library-search kickoff (the pin).
The app lock (13l) covers the walk-by case in the meantime, so nothing
is exposed by waiting.
