# Phase 13x — Library portability

**Ticket: VX-6 · Project: 13x — Library portability · Branch: `vx-6-13x-library-portability` · Worktree: `~/dev/variorum-13x` (the Pro)**

*(This file holds the KICKOFF; the execution plan lands here after the kickoff's design look,
authored by this phase's orchestrator. Written 2026-10-06 at the workflow transition.)*

## KICKOFF MESSAGE (the author launches a fresh orchestrator with `/architect-phase 13x`)

You are the orchestrator for **Phase 13x — LIBRARY PORTABILITY**: the AirDrop-your-library
promise made true by built doors. Her kickoff framing (2026-10-06): *"make airdropping a corpus
easy and opening a previous library backup easy (there's probably significant overlap there)."*

**The workflow is new — read it first.** PREFLIGHT, complete and never delegated: CLAUDE.md +
its auto-loaded canon · **`notes/plans/workflow-transition-2026-10-06.md`** · the master plan's
IN-FLIGHT table · `~/dev/variorum/notes/TICKETS.md` (main's copy) · `notes/QUESTIONS.md` ·
`notes/SessionResiliencyProtocol.md` — **and, because this phase IS custody work:
`notes/SyncSpec.md` IN FULL and `notes/sync-postmortem-fragments.md` before any `Sync/` line.**
Work in THIS worktree on THIS branch; one PR titled `VX-6: …`, merge commit, at closeout.
Linear: VX-6 In Progress at kickoff → In Review → Done at merge.

**THE SPEC is `notes/FuturePhases.md`'s 13x row, read WHOLE**, plus the built substrate it rides:
13p's keyed `openStore(at:)`, the ciphertext backups, and the drill-proven key legs (passphrase ·
recovery phrase · escrow); the adoption door's shape lives on pre-13x's roads
(`notes/plans/pre-13x-postures-design.md` + its design-history/review files). Deliverables the
row names: the hand-off act, the adoption door, the same-Mac older-key restore, the three held
FAQ entries publish. Project ticket **VX-64** (vault-bootstrap can't open an encrypted store —
the bare openStore road consults the Keychain) was filed here at the reconciliation: TRIAGE IT
at kickoff (confirm the mechanism and whether it is this phase's or mis-homed).

**The Fable rider binds end to end:** custody/keychain and any `Sync/` line is Fable work with a
Fable cold review — this phase HOLDS the one Sync/-custody slot while it runs (13o and 13s must
not touch those seams; check the in-flight table). The stage rule binds every `xcodebuild test`
run, walk, Debug launch and store reset (`Tools/stage`); restore drills run on throwaway scopes
per the standing seams, never her real store; the A1 safety-copy ritual guards any
`/Applications` refresh. Where her hands are needed (AirDrop between real devices, a second-Mac
leg), pause and ask — never work around. Ambiguity that gates the core stops and reports;
PROVISIONAL otherwise, logged in QUESTIONS. Closeout per CLAUDE.md: the in-flight row retires,
the PR merges, hard stop.
