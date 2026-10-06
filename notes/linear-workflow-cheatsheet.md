# Linear workflow — Lillian's cheat sheet (2026-10-06)

*The deep record: `notes/plans/workflow-transition-2026-10-06.md`. This is the fridge-door version.*

## The one rule
**Linear = status & numbering. The repo = truth.** A ticket is a pointer + one-liner, never a spec.

## Names
| Thing | What it is |
|---|---|
| **VX-N** | a Mac/core ticket (team VX, "Stargazingtech") |
| **VM-N** | a mobile ticket (team VM — its own board & numbering) |
| **Project** | the epic / phase ("13o — Search", "13n — The MCP door") |
| **Flagship** | a project's first ticket, titled the effort's name — **its number IS the effort's number**, names the branch & PR, points at the plan file |
| **Run ticket** | `Run: <theme>` — the one number for a bundle of small fixes |
| **Needs Lillian** | the state = your adjudication queue (one board column shows everything waiting on you) |
| **Parked** | deferred-with-a-written-reason (the old "deferred work needs an owner") |

## The three sizes of work
1. **One small ticket** → `/run-phase vx-42` — its own branch `vx-42-slug`, its own PR; record = commit message + PR.
2. **A RUN (bug fixes bundled under one orchestrator)** → `/run-phase vx-15 vx-16 vx-18` — it mints ONE run ticket whose number names the single branch + PR; the members become sub-issues, keep their numbers, close one by one. Pin-per-member; one cold review for the whole diff.
3. **A phase/epic** → `/architect-phase vx-5` (≡ `/architect-phase 13o`) — project + flagship; plan file carries `Ticket · Project · Branch` in its header.

**You never pick the directory** — the orchestrator's first job is seating itself: right worktree/branch, created fresh from origin/main if needed, removed after the PR merges.

## Branches & PRs
- Branch = `vx-123-slug` (Linear's copy-branch-name gives exactly this). PR title `VX-123: …`.
- **Merge commits only — never squash** (canon cites commit SHAs).
- "Fixes VX-123" / "Part of VX-123" in commits & PRs auto-link (the webhook's on).
- Every GitHub number is a PR now — issues deleted, archived at `notes/source/github-issues-export-2026-10-06.json`.

## Where things are
- **Live board:** linear.app · **snapshot in repo:** `notes/TICKETS.md` (generated — never hand-edit).
- **In-flight table:** top of `notes/DetailedPlanForPhases.md` — what's running, on which branch/worktree/machine.
- **Old ledgers:** frozen archives. KnownIssues → `notes/KnownIssuesArchive-2026-10-06.md`; 17/19 letters → their files; VR → `notes/plans/vr-to-vx-map.md`.
- **Ready kickoffs:** 13o = **VX-5** (Pro) · 13x = **VX-6** (Pro) · 13s = **VX-7** (Air) · mobile catch-up = **VM-4**. One-line prompt: `/architect-phase vx-5`.

## The machine rules
- **`Tools/stage`** — the Pro's lock for anything touching the screen or a store (walks, Debug launches, EVERY xcodebuild test run). `Tools/stage status · claim · release`. Headless `swift build/test` never needs it.
- **The Air never runs suites** — it ssh'es to the Pro and claims the stage there.
- Keys for automation: `~/.variorum/linear.key` · `~/.variorum/github.token` (0600). Start tmux servers from a GUI terminal on the Pro (Keychain access).

## Filing a bug from anywhere
Just make a ticket in Linear (phone app works) — title + a sentence. No owner, no letter, no ceremony; the next triage adds the plan-file pointer and a project/Parked state. Or tell any session and it files it properly.
