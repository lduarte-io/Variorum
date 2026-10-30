# VX-292 + VX-559 — her morning handoff (2026-10-30, the overnight run under R-292-16)

Good morning. The onboarding overhaul is merged and released to stargazing.tech as **0.10.7** per your overnight word (the release results and any stops are in the last section — read it first if anything looks off). The one running record is `notes/plans/vx-292-onboarding.md`; the ladder is `notes/plans/vx-292-ladder-round1.md`; the PROVISIONAL bundle is QUESTIONS **#255**.

## YOUR CHECKLIST

1. **Two presses on the Air, after installing 0.10.7** (your word via the coordinator): **Help ▸ Restore Field Guide…** (picks up both efforts' guide edits — the Prince classics walk, the registry-verb labels, vx-105's first lesson) and **Help ▸ Restore “readme”** if you want the letter in your real store.
2. **The Prince front-note sentence (yours, held).** `about this text` ends "Restarting the tutorial will restore this book to its default state as well." — written as a forward promise, now FALSE as stated (the tour drives and mends deletions only; it never resets the book). Trim, keep, or give a corrected sentence; nothing was changed.
3. **P-292-4 — the sea-glass depth, your eye in-app.** Built BOLD (light room #E5F0EC, wash #CBE2D9); the soft alternative lands within 1.011:1 of Mint (a near-duplicate). Settings ▸ General shows it live.
4. **P-292-5 — the palette rows' naming, your eye.** The row titled **Default** holds the sea-glass; your old colours are **Classic** in their own row (alternatives incl. "Original"/"Plain" in #255).
5. **P-292-2 — the default flip's reach.** Read-time: any EXISTING library that never picked a palette wakes in sea glass after updating (your real store included, unless you ever clicked a palette). The release notes say so publicly. If you'd rather it were fresh-stores-only, it's one small change.
6. **The words-card toast observation (U4's, held).** A toast over the Bookcase lands on the band's LOWEST card — now the words card (the welcome card above it is clear; this is the old U1 yes-click hazard relocated). The one-modifier fix moves where a canon-ruled toast sits, so it waited for you.
7. **The tour-mend's recorded edges (#255's P-292-7)** — three things to know exist, none urgent: a tour-start mend also runs the Welcome arrangement (its standing re-own/re-tag reach, same as your own Help presses); purged deletions mend nothing (the floor); and the delete→mend→rename chain can re-mint a twin (three deliberate acts deep — the complete fix is VX-716, Parked).
8. **The #255 pass** when you have energy: thirteen P-292 items + four copy observations (two wording departures the real app forced; the end card's keep-going line doesn't name the Settings stop; step 8's "It opens on edit" is wrong on a note left on read). All taste-sized.
9. **Declined riders still open:** VX-707, VX-343, VX-71 (your "no riders for now" stands; they're untouched).
10. **One leftover, one command:** the merged branch `vx-292-onboarding` still exists locally and on GitHub (my delete was permission-blocked; the worktree itself is removed). `git branch -d vx-292-onboarding && git push origin --delete vx-292-onboarding` when you like.

## WHAT SHIPPED (one breath each)

- **The tour**: thirteen steps + a five-stop leg around the Prince — the flip and back on the bilingual paragraph, Read and its switch, Lenses opening "il principe 1532" live, Compare & Blocks, the book arc (up · Book/Read · down through the Index), home, one of your own; the leg ends opening Settings on General. It drives (your modes win once per arrival; your own switches are never overruled), lands step 3's chapter through the book's own ascent, and mends a missing or deletion-broken Prince through its own restore door — only where everything the road would do is undoing deletions.
- **The welcome card** (VX-559): yes · no only; no shows "This can always be started from Help ▸ Take the Onboarding Tutorial." in the card, then it's gone for good; existing stores' answers hold.
- **Sea glass** (VX-710): the seventeenth palette, from the icon's own #C2DDD3, now the unset-store default; Classic is one click back.
- **The Prince sweep** (R-292-1): the tour and the guide's classics walk teach the Prince; restore-door names quote their constants everywhere.

## TICKETS

- **Done at the merge**: VX-292, VX-559, VX-710, VX-712 (closed HOLLOW — its trace pin proved the lesson's ⌘K road works; A-292-4), VX-713 (fixed). VX-415 closed superseded by VX-559.
- **Born, all Low · Parked with reasons**: VX-716 (seed-provenance marker — the rename-after-mend corner's complete fix), VX-717 (MCP chapter landing races a Finished book's mode seed), VX-718 (the test-host stack-guard crash class, tracked).

## THE NIGHT'S SHAPE (if you want the story)

Five units, each closed through a coordinator-granted stage window (red-on-old watches, suite-TYPE gates, dev-store walks). The windows earned their keep four times: U2's first pass caught four never-run fixture pins red on the clean tree plus a real gate hole on Finished books (fixed same hour with the door's own admission gate); U3's gate caught one stale pin (the tab-table scan — fixed by reading the real constants); U4's window caught the test HOST's own Bookcase polluting unscoped test oracles (fixed by scoping every read to its own world). The ladder ran once, cross-model: round 1's one MAJOR — the mend gate fired on renamed/released chapters, which are edits your R-292-11 protects, not deletions — was fixed as the whole-effect gate with five pins; round 2 closed clean. vx-105 merged first; this merged second with the foreseen pin conflicts resolved to the combined truth; the merge gate ran the full Mac and full mobile targets.

**Canon-size: 126,918 / 150,000 (headroom 23,082)** — no crossing. MOBILE PARITY: nothing mobile-visible (the phone's one token road is `VoiceTokens.resolve(voice:dark:)` — palette-free; verified three ways, and the coordinator's contrary inference was checked and withdrawn).

## THE RELEASE (filled at the release's end — read this before anything else if a line below says STOPPED)

- **RELEASED AND LIVE: Variorum 0.10.7 (build 10595), from main e91a76b5f** (= the VX-292 merge c5ed35908 + the board snapshot). No command was refused; nothing stopped.
- **A1 first:** `…/Variorum/Backups/safety-copies/variorum-a1-0.10.7-release-20261030T173601Z/` — all six files cmp-verified identical (the store was unwritten since Oct 25, as expected).
- **The first-run gate:** FirstRunDrillTests 11/11 on this commit; the scripted first-run walk PASSED both arms on the prod test road (set-up then join; the vxtest account reset to rest by its own cleanup leg; signed out; zero instances). The dev slot was set aside WHOLE by one rename and restored the same way — the hold marker untouched (Oct 20), and the only store-file delta against my pre-drill md5 log is the drill's own test host opening the store at 11:47, before the set-aside (mtimes prove it; nothing touched the slot while aside).
- **Installed:** /Applications/Variorum.app now 0.10.7 (CFBundleVersion 10595), staged beside the old, codesign --verify --deep --strict PASS before and after the swap, launched by nobody.
- **Published, in the runbook's order:** the preflight busted-probe 404'd (the name unpublished) → the DMG to R2 (31,881,124 bytes) → verify-published dmg PASS (bytes identical, sha256 6881f8b7…) → the appcast to the site → verify-published appcast PASS (live feed byte-identical; the 0.10.7 enclosure reachable; no-cache header) → the page at stargazing.tech/variorum shows 0.10.7 with its download. The site repo carried your site agent's un-deployed round-3 nits — I merged and redeployed the combined tree, so both its nits and 0.10.7 are live.
- **What's New in the app:** the folded notes (this effort's + the readme/classics bullets) ship in the appcast item and the app's What's New.
