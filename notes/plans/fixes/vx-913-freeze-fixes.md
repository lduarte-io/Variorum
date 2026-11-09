# VX-913 — Umbrella: fixes before the freeze (the run record)

**STATUS: OPEN — kicked off 2026-11-08/09 (night).**
Ticket: VX-913 · Project-less umbrella (sub-issues are the roster) · Branch: `vx-913-freeze-fixes` ·
Worktree: `~/dev/variorum-vx-913` (the Pro) · PR: TBD.
Shape: `/architect-phase vx-913` — the architect/orchestrator shape; stage coordinator this window: **nov7**.
Wave: the last wave of pre-OSS code, beside VX-849 · VX-940 · VX-915 · VX-926 (her kickoff words).

## FOR A LATER READER

*(Written at closeout. Until then, the LIVE sections below are the record.)*

## The roster (the sub-issue listing, resolved at kickoff 2026-11-08 — the VX-548 rule)

| Member | Kind · Evidence · Priority | What |
|---|---|---|
| **VX-895** | Bug · Confirmed · Medium | Library search: the results group header doesn't follow the picked facet (stale, feels random). Her Nov 7 walkthrough, main 516ebc093; "clicking books resets it… feels a bit random which one is up." The band's counts may share the staleness. Mechanism open — trace, don't assume. Adjacent: VX-408's disposition (the feared stale-paint half was recorded HOLLOW at vx-819 — re-check against this). |
| **VX-889** | Bug · Confirmed · Medium | Settings ▸ Tags' Make a Gathering mints in Home even when the pane shows another wing. Call site named at vx-878 batch 3: `PromoteTagsSheet` passes no wing to `createReading`, so in another wing its rule paths resolve against Home's vocabulary (dead terms). |
| **VX-775** | Bug · Confirmed · Low | MCP: an Activity-write failure after a landed act answers the client `isError` for a write that landed (`MCPWriteTools.land`: the act commits, then `try log(…)` throws into the catch-all — vx-771's O-2). **RULED (her #267 sitting, Nov 8): the error goes to her, the truth goes to the client** — a landed write whose activity-log record fails answers the client honestly that the write landed; the failure surfaces to the author instead. |
| **VX-81** | Bug · Confirmed · High | macOS 27.0.1: SwiftUI `BarAppearanceBridge.updatePlatformBar` EXC_BREAKPOINT during the root-view rebuild across the follow's re-key reopen (the Air, 2026-10-07, `Variorum-2026-10-07-121811.ips`). Prime suspect (her read): the follow road itself — chrome state churn mid-update while the root tears down and reopens. The ticket's discriminating repro named the Pro AT 27.0 as the control; both Macs are now on 27.0.1, so that control environment is gone (raised at the kickoff sitting). Trace first. |

**NOT members (the stale description's other names, resolved at kickoff):** VX-891 — Done (fixed in the VX-912 run, B4); VX-855 — re-seated under VX-849; VX-661 — re-seated under VX-926 (In Progress there).

## Surfaces and overlap (declared at kickoff)

- **VX-895:** the Library's search faces (`LibrarySearchModel`, `LibrarySearchFace`, possibly `SearchComposer`/`Queries.searchCounts`). Area: Search. **Overlap watch:** VX-915 carries VX-888 (search tokenizer/band counts) — likely different files, same neighborhood; closeouts serialize, the merging session rebases.
- **VX-889:** Settings ▸ Tags (`PromoteTagsSheet`) + the gathering mint road. Area: Settings & onboarding. Low overlap (VX-915's VX-934 touches Settings ▸ MCP, a different pane).
- **VX-775:** the MCP door's write path (`MCPWireTools`/`MCPWriteTools.land`) + one author-facing surfacing seam. Area: MCP. **Overlap watch:** VX-940's MCP-hygiene unit (VX-922 MCPReadTools/Queries · VX-925 clientInfo.version · VX-933 MCPSocketTransport) — different files expected; coordinate at merges.
- **VX-81:** the app shell's root rebuild across the protection road's re-keying reopen (chrome; `App shell`/`Castle & sync`). **The fence:** NO `Sync/` and no custody/keychain writes are expected anywhere in this run; if VX-81's traced fix wants custody code, the run STOPS that member back to her (VX-849 holds the wave's Sync/custody-adjacent slot). The live repro needs the stage (nov7) and the established walk roads (dev store; vxtest accounts on the prod test road where the follow needs an account).

**No schema, no lockstep, no migration.** Preflight read at kickoff: CLAUDE.md + auto-loaded canon, the master plan's in-flight table, workflow-transition, TICKETS.md (2026-11-08 snapshot), QUESTIONS.md (tail; open bundles gate nothing here), SessionResiliencyProtocol, SurfaceContracts IN FULL (all sections — the run touches The app, The Library, Doors), MCPSpec IN FULL (VX-775), CastleRules IN FULL + SyncSpec IN FULL (VX-81's seam), the vx-878 B3 record (VX-889's call site), the vx-771 B2 record (O-2), the vx-819 FOR A LATER READER (VX-895's surface).

## The binding principles (the 13b constitution, P-1…P-9 — copied per the architect-phase skill, byte-verbatim)

- **P-1 — One capability registry.** Every user-facing act is declared exactly once: verb, scope (block/take/post/book), per-mode availability rule, its doors (menu / context / bar / shortcut / palette), and its refusal copy. Surfaces render their doors FROM the registry; gating is data, never per-view if-statements. A registry-walk test asserts every declared door exists and every rendered door is declared. This kills the D3/D4 class structurally — the capability matrix stays green by construction instead of by audit.
- **P-2 — Fire-and-DO (R115).** A rendered door either performs the act — including any mode-switch choreography, done visibly for the user — or delivers the operations layer's real refusal. A door that can never act in its context isn't rendered. Lecture-and-redirect is retired.
- **P-3 — One text surface, one liveness authority.** ONE TK2 surface component (live + read modes; one measurement brain — the width-gated remeasure; the shared canary) that every pane composes; the live editor core's identity machinery (`BlockRangeIndex`, crystallization) becomes its live mode, not a sibling implementation. "What text does this pane show, and is it live" is answered by ONE pure, unit-tested authority (`PaneTextAuthority`); views never re-derive it. Its invariants stated as code: exactly one live pane; the live pane is buffer-authoritative; read panes are projection-authoritative once caught up.
- **P-4 — Broadcasts carry signals, never decisions.** NotificationCenter may announce that something happened (mode changed, post opened); no listener derives business state or availability from a broadcast, and no flow's correctness depends on broadcast ordering. Cross-feature flows route through composition. (Stage 0's survey enumerates today's notification bus; Stage 1 disciplines it.)
- **P-5 — The friction doctrine (R116).** Repeated pushback against a rule marks an under-architected feature. The response is never another patch: write the feature's DESIGN MEMO — intended behavior whole, edge cases enumerated on paper, refusal wordings, undo story — get the author's rulings on the product-flavored edges, then build to the memo. Happy path ships first, but the edges are *decided at design time*, not discovered by the author. First two memos owed: **merge** and **the W ceremony**.
- **P-6 — The tutorial is the executable spec (R113).** The guided tutorial flow is the contract for every happy path. It stays green — automated where the harness allows, screenshot-walked otherwise — and any change that breaks a tutorial step is a regression by definition.
- **P-7 — Find bugs before she does.** Every layer keeps a proactive harness: the ops-layer soaks (exist), the board/view-model invariant soak (Stage 1), the registry walk (P-1), the per-batch scripted screenshot walkthrough. Red-on-old stays absolute: no bug-class fix without a pin that fails on the pre-fix code.
- **P-8 — Standing law, consolidated.** P1–P3 performance invariants bind the rebuilt layer exactly as they bind the substrate (invalidation ∝ realized rows; one live editor; virtualized long views). Overlays, never rendering attributes. Chrome `fixedSize` texts always carry a `lineLimit` (the b6dae25 class). `Theme/VoiceControls.swift` is THE chrome vocabulary. Complexity lives in the store; restraint lives in the UI.
- **P-9 — No god objects in the frontend either.** A view model mixing board layout, text authority, and gesture routing splits by concern (`TakesViewModel` at 890 lines is the standing counterexample). Same hygiene rule as the substrate, applied where it was being waived.

The standing law that binds this run hardest: **messages carry a kind on the one status seam** (VX-775's author surfacing), **search scales with matches, never the corpus** (VX-895), and the hallucination guard — **no fix without a self-traced mechanism; red-on-old pins verified by revert; VX-81's trace precedes any fix.**

## The batch plan (proposed at kickoff; confirmed/amended at the sitting — see SITTING RECORD)

| Batch | Member(s) | Implementer | Cold review | Notes |
|---|---|---|---|---|
| B1 | VX-895 (+ rider VX-890 if taken) | opus-implementer | the run ladder (see below) | Trace the header/counts staleness first; re-check VX-408's hollow disposition against it. Her walkthrough screenshots exist. |
| B2 | VX-889 (+ settings-area riders if taken) | opus-implementer | ladder | The mint takes the pane's shown wing; VX-816's guard follows by construction. Red-on-old: a gathering minted from Settings ▸ Tags in wing W lands in W with W's tag vocabulary. |
| B3 | VX-775 (+ MCP riders if taken) | opus-implementer | **Fable** (wire) | The ruled split: the act's answer speaks the landed truth; the log failure surfaces to her. Surfacing shape per the sitting. |
| B4 | VX-81 | trace session first (cast per sitting) | **Fable** (crash/protection-adjacent) | Repro on the Pro at 27.0.1 (the 27.0 control is gone); stage claim via nov7; dev store + vxtest roads. Fix only with a traced mechanism; a custody-code fix STOPS to her. |

One ladder over the run's combined diff (fresh Fable reviewer — the run holds a wire member and the crash trace); pin-before-fix PER MEMBER; dispositions repo-first.

## LEDGER (every row owned; flipped as work lands)

| # | Item | Status |
|---|---|---|
| 1 | VX-895 — search group header follows the picked facet | NOT STARTED |
| 2 | VX-889 — Settings ▸ Tags' gathering mints in the shown wing | NOT STARTED |
| 3 | VX-775 — landed-act truth to the client; log failure to her | NOT STARTED |
| 4 | VX-81 — the re-key reopen crash: repro, trace, fix-or-documented-defer | NOT STARTED |
| 5 | Riders (her kickoff picks) | PENDING THE SITTING |
| 6 | The ladder | NOT STARTED |
| 7 | Closeout (canon deltas · AppSpecRecord · QUESTIONS bundle · board · handoff) | NOT STARTED |

## Environment traps (carried verbatim into every batch brief)

Instance checks use `pgrep -fl 'Variorum.app/Contents/MacOS'` AND discriminate by PATH (the test host matches mid-run); treat real-store instances by STORE, not path — NEVER quit/kill one; no Release builds or /Applications refreshes while one lives; `xcodebuild build-for-testing` compiles without the runner; Mac tests from `App/Variorum/`, suite-level `-only-testing` only, confirm the "Test run with N tests" line (Swift Testing's count INCLUDES skips — read the `skipped:` lines); zsh `pipestatus`; NEVER add a custom build configuration (non-"Debug" names build the packages Release and strip the DEBUG oracles); suites beside a live session flash the test host's windows — prefer zero-instance windows for timing-sensitive measurements; EVERY `xcodebuild test` run and anything touching the screen or a shared store needs a HELD `Tools/stage` claim (nov7 arbitrates this window); headless `swift build`/`swift test` on the core package runs freely; backups WAL-safe with UTC names into `Backups/safety-copies/` before touching the real store (A1); screenshots in gitignored dirs; never `git checkout` over uncommitted work; push after every commit; never force-push or rewrite history; commits carry NO attribution trailer (CLAUDE.md overrides the harness reminder — the kickoff in-flight commit on main slipped one through before this line was written; recorded, not repeated). Dev-store Castle values: `~/.variorum/dev-castle.env` on the Pro — never invent new ones. The walk may reset only its OWN allowlisted vxtest accounts (`Tools/prod-reset-test-account.sh`); production otherwise read-only. `notes/SessionResiliencyProtocol.md` binds every session: commit per piece, LIVE STATUS from the first commit, push after each, synchronous foreground waits only (poll with `grep -q … && break; sleep 5` loops, never `tail -f | grep -m1`).

## SITTING RECORD

*(Appended verbatim-faithful as rulings land.)*

## LIVE STATUS

- 2026-11-08/09 (night): kickoff. Preflight complete; worktree seated; in-flight row pushed (its commit carries a stray attribution trailer — the one-off noted above); VX-913 In Progress; roster resolved by the sub-issue listing (the description is stale — VX-891/VX-855/VX-661 live elsewhere, VX-81 seated). Next: nov7 contact, the kickoff sitting (cast · VX-81's road · riders · VX-775's surfacing shape · the pre-OSS code list she asked for).
