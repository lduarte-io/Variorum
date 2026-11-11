# Variorum

A native Mac writing app that keeps your choices open. The paragraph is the atomic unit; every paragraph can hold many takes — alternate versions, kept side by side for as long as you want. Journaling, blog posts, and books are one model underneath: blocks, pointers, and history that never destroys anything.

Variorum is a real, shipped app — [download it at stargazing.tech/variorum](https://stargazing.tech/variorum). It's fast, end-to-end encrypted, and built with a singular vision.

## A letter from Lillian

Variorum opens with its own readme: why I built it, what it's for, and what I hope it does. It's the first note in every new library and its text lives in this repository at LETTER.md.

## How this was built

AI wrote the code. I directed everything — every product decision, every spec line, roughly a quarter million typed words of direction over four months. The entire build record ships in this repo: the specs and the mental model in `notes/`, several hundred plan and fix files with their review ladders, and the process constitution every session ran under (`CLAUDE.md`).

This isn't a cleaned-up history. The record keeps the failures, the corrections, and the arguments, because the record is the proof: it shows who decided what, when, and why. If you want to understand how a person and AI actually build something ambitious together, start with the letter (in the app, and on the site), then `notes/README.md` — the map of the record: the layout, the canon files, the house dialect, and the reading paths. A post about what building it was like is coming; a link will land here.

(VX-nnn ids throughout refer to a private tracker; the repo-first records for each live in `notes/plans/fixes/`.)

## Building it yourself

Requirements: macOS 26+, Xcode 27+.

You can build and test Variorum with no account, no signing identity and no server. BUILDING.md has the steps.

- Core package: `swift build` / `swift test` at the repo root.
- The app: open `App/Variorum/` and build the `Variorum` scheme (Debug uses a local dev store; no account, signing team, or server needed).
- Sync is optional and off by default in dev builds; the server half lives in `Server/`.

## Open source, closed contribution

Variorum is open source with closed contribution — the SQLite model. I'm not accepting pull requests at the moment because I prefer developing to reviewing and don't currently have a plan for sorting through other people's AI generated PRs. Sole authorship also keeps relicensing, the App Store, and the project's vision intact. If that ever changes, this section will change first.

Bugs and ideas are welcome as issues. Each one goes into my private work queue and is prioritized there. I prefer to work in waves, with releases when they're ready.

Found a security issue? See SECURITY.md — I want to hear it, and the response posture is: confirm, pin, fix, write it up. Please don't post it in the public issues.

## iOS App

The iOS app lives in this repository too, in App/Variorum/VariorumMobile/, sharing App/Variorum/Shared/ with the Mac app. It's in development and hasn't been released.

## License

AGPL-3.0. The name "Variorum" and the logo are not licensed for use on derived products.
