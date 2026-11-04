# VX-724 handoff — the book's bottom bar + VARIORUM 1.0, released

**Closed 2026-11-01, one evening, kickoff to public release.** PR #213 (merge `53493f1ca`); the record's FOR A LATER READER section is the read: `notes/plans/fixes/vx-724-book-position-bottom-bar.md`.

## Her checklist

- **Nothing is owed for the release itself.** Variorum 1.0 (build 10632) is live: the DMG at https://dl.stargazing.tech/variorum/Variorum-1.0.dmg (verified byte-identical), the appcast live (your notes verbatim; betas will be offered 1.0 by Sparkle), the site's version data at 1.0, `/Applications` on the Pro refreshed to the shipped notarized build behind a fresh A1.
- Your landing-page copy work (the Air, unpushed) — pull the site repo there before your next deploy so it carries the 1.0 version data (`0df26a8`).
- When you next open Variorum on the Pro you'll see the What's New sheet once (you're crossing 0.10.7 → 1.0 like any beta tester).
- The Air's Variorum install updates itself via Sparkle, or refresh it at your convenience.
- One disclosure: during the install-verify step a version-print probe accidentally launched the freshly installed app against your real store for about a minute; it quit gracefully, zero instances after, and the A1 safety copy predates it. Nothing observed amiss; your store's newest A1 is `variorum-a1-1.0-release-20261102T030334Z`.
- Standing, not this effort's: VX-216 (your author-attended sitting) remains ready whenever you want it; VX-500's PR stays held at your word.

## What shipped

The book Outline's position line left the top and became a bottom bar: "note N of M · ‹chapter›" leading, "book · N chapters · M notes" trailing-right, separated; the quiet receipt floats above it (R-724-2); full pane width (R-724-3); position wins a width squeeze (R-724-4); R-724-1 amends 13c A6's reach (scrub/progress ban stands, one sanctioned bar). Your 1.0 notes verbatim in `ReleaseNotes-1.0.md`. Fresh installs never see the notes automatically (the ledger records silently on first launch); updaters see them once; Help ▸ What's New is the manual door.

## The run, in one breath

Architect shape: Opus built; two-round Opus ladder — r1's one BLOCKER was the stale A6 "no bottom chrome" pin, rescoped into `outlinesOnlyBottomChromeIsThePositionBar` with A6's teeth kept and the placement arms revert-proven; r2 clean (no BLOCKER/MAJOR). Evidence: 65 tests in 3 suites + the reviewer's independent 15-suite sweep green; the acceptance walk on the dev store's prince. Step-0 release gate PASSED (drill 11/11; both-arms first-run walk, dev slot byte-identical after, production at rest). Canon-size at closeout: 129,133 / 150,000 (headroom 20,867).

## Filed tickets, by priority

- **Low:** VX-725 (the Outline bar's four-names rename, Books · Debt) · VX-726 (the A6-successor pin's shared oracle key + unconditional forget, Tests & tooling · Debt · Suspected — matters only if suites ever interleave).

## Mobile parity

Nothing mobile-visible (Mac Outline chrome; the phone never drew the line).
