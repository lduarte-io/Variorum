# Outbound brief: stargazing.tech — Variorum distribution (Phase 13r)

**From:** the Variorum 13r orchestrator, at the author's kickoff sitting (2026-09-25).
**Carried by:** the author — this repo's agents never touch `~/dev/stargazing-tech`; she tasks the
site agent with this brief (the standing channel, the pre-13x FAQ brief's precedent).
**Why now:** 13r ships Variorum's first distributable build (Sparkle auto-update + a notarized DMG);
the friends beta follows directly. The site is the ruled hosting home (sitting ruling R-13r-2).

## What the site needs to provide

1. **Static hosting for the update feed and the installers**, at stable HTTPS URLs (Sparkle/ATS
   require HTTPS):
   - `https://stargazing.tech/variorum/appcast.xml` — the Sparkle feed. **Must be served with a
     short/no cache lifetime** (an update propagates when this file changes).
   - `https://stargazing.tech/variorum/downloads/Variorum-<version>.dmg` — the installers.
     Immutable once published; long caching is fine and good.
   - These paths are a PROPOSAL — adjust freely, but **report the final URLs back before they're
     needed**: the appcast URL is baked into the shipped app (U2), so it must be settled first and
     is expensive to move later.
   - Publishing flow: the Variorum release pipeline produces `appcast.xml` + the DMG as files; the
     author (or a road you two agree) places them. Nothing dynamic is needed — plain static files.
2. **A Variorum download page** for the friends beta — design and copy are yours and hers; the
   functional needs are only: the current DMG link, the version, and the requirement line
   (**macOS 26 or later, Apple silicon**). It can stay unlisted/linkable-only for the beta.
3. **The support mailbox: `support@stargazing.tech`** — create/confirm it and tell her where it
   lands. The app's Help ▸ Send Feedback… and the opt-in crash-report flow both draft mail to this
   address from day one.

## Timing

- The **appcast URL decision** (item 1): needed before Variorum's U2 unit closes — soon.
- The **mailbox** (item 3): before the beta's first install.
- The **page** (item 2): before the beta link goes to friends; content can iterate after.

## Explicitly not in this brief

The privacy-policy page (its own standing row on the Variorum side; the beta page may link whatever
exists), the app icon / brand art for the page (the brand assets live in Variorum's `notes/brand/`
— the striped V is the ratified logo), and any launch marketing (post-beta).
