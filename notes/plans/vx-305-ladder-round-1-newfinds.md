# VX-305 ladder round 1 — the two pre-existing generator finds (NEW-1, NEW-2): trace, classify, pin, fix

**Not done, first:** (filled at close — PENDING.)

The brief: the round-1 fixes record's §"Found by the generator, outside the round"
(`notes/plans/vx-305-ladder-round-1-fixes.md`) carries both minimal sequences; both reproduce on the round's base
`e4ee1f083`. One implementer session (Opus), headless (`swift build` / `swift test`), scope
`Sources/VariorumCore/Protection/` + `Tests/VariorumCoreTests/Protection/` + this record.

## LIVE STATUS (flipped in the same commit as each piece; PENDING = unverified)

- **NEW-2 (promise 13, no tamper) — the priority:** traced (below); classified **a CHECKER bug**; pin + fix — PENDING.
- **NEW-1 (promise 3, a replayed pre-landing capture):** traced (below); classified **a MODEL bug** (P-U4-6's
  memory-wins arm too narrow); pin + fix — PENDING.
- The runs at the end (the protection set in Debug, `swift build -c release`) — PENDING.

## NEW-2 — the trace

*(PENDING — written with its pin.)*

## NEW-1 — the trace

*(PENDING — written with its pin.)*
