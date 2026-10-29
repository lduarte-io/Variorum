//
//  SampleLibraryFreshStore.swift
//  Shared (Variorum + VariorumMobile)
//
//  VX-633 U2b — R-633-16, her D1 ruling at the 2026-10-28 sitting
//  (`notes/plans/vx-633-prince-book.md`, "Her D1/D3 rulings"): **FRESH STORES
//  ONLY.** "Existing stores are untouched at the release — the Prince seeds
//  only on a fresh store's launch road; an existing store (hers, the testers')
//  gets it via Help ▸ Restore "the prince", which arranges it properly … The
//  phone mirrors: its first-write occasion seeds the launch book on a fresh
//  store only — an existing phone store never gains the Prince by update."
//
//  ── WHY A GUARD AT ALL (the seeder's doctrine, bent for one book) ────────
//  `SampleLibrarySeeder` has NO virgin-store guard by design (its header —
//  her Act 3 ruling, "every reader's store"), and each launch book carries its
//  OWN device mark, so every book that ever joined the launch seeded into
//  existing stores at their next occasion (the 5a/U6 precedent). U2 built the
//  Prince that way (its record's PROVISIONAL D1); her ruling removes it FOR
//  THE PRINCE — `Book.seedsFreshStoresOnly`. Every other book never asks this
//  file: Sherlock's, Jekyll's and Encryption Explained's launch behaviour is
//  byte-unchanged, and no restore door reads it (`SeededBookRestore` calls the
//  seed itself, never the launch road).
//
//  ── WHAT "FRESH" MEANS — store truth AND the device's record ─────────────
//  Not "a store that predates the Prince" (her letter is EXISTING stores, and
//  a store whose Sherlock was deleted and purged predates the Prince with no
//  evidence left): **a store is fresh when it has never held writing** — no
//  note or snippet row, live or in the Trash, and no book row but the seed's
//  own. Gatherings never count: they hold nothing, and the starred-notes
//  gathering is the Mac launch's own furniture, seeded right after the launch
//  book — a launch whose book seed was refused would otherwise read its own
//  furniture as her library at the next launch.
//
//  Store truth covers what the device marks cannot. The marks are
//  `UserDefaults`, lost with a reinstall or a store moved to a new Mac, and an
//  existing store mis-read as fresh would not only GAIN the Prince but be
//  ARRANGED: the launch book's full mint is the Welcome arrangement's birth
//  signal, so the store would be silently retrofitted — the one thing the
//  arrangement exists to refuse.
//
//  The device's record covers what store truth cannot. On the Mac a store
//  this device already SETTLED — the Welcome arrangement's launch mark is
//  `done` or `declined` — is an existing store by the device's own word even
//  when it reads empty (a new library on a used Mac: the per-Mac seeding
//  doctrine her R-510-25 kept — a device that has seeded does not seed again;
//  before VX-633 its Sherlock mark said so). Nothing is judged there, so the
//  launch road never writes the Prince into a store it has settled.
//
//  ── WHEN it is judged, per platform (one brain, two occasions) ───────────
//    · The Mac's launch (`LaunchFurniture`) asks at the DECIDING reads — the
//      early read and the one inside the latch, AFTER the sync gate — so an
//      account store is judged by what its first clean round brought: a new
//      device joining her library finds writing and declines, never seeding
//      the Prince into her library (nor arranging it).
//    · The phone's first-write occasion fires AT her first write, when her
//      own note already exists, so its fact is taken at LAUNCH
//      (`MobileFirstWriteFurniture.prime`) — the starter Journal's precedent.
//      An untaken fact (the read failed, or `prime` never ran) is not fresh:
//      never a guess that seeds — and never a decision either (ladder R1 F2,
//      `.untaken`): that decline is NOT recorded, so the next occasion, its
//      fact taken, asks again (the starter Journal's rule).
//
//  ── RESUMING the seed's own partial copy ─────────────────────────────────
//  A fresh store's launch can stop partway (the Mac window closed, the phone
//  locked) and leave the book half minted — and its own rows then read as
//  writing. The book's OWN partial copy (its reserved name holding at least
//  one title it ships — never a book of hers that merely shares the name) is
//  completed, exactly as before, on every road except a settled one.
//
//  ── RECORDED residuals (not built) ───────────────────────────────────────
//    · A process death INSIDE the skeleton turn after the book row and before
//      the front note leaves a book holding none of its titles: not resuming,
//      and — if anything else was written by then — not fresh, so the launch
//      declines; Help ▸ Restore completes it (U2's residual 13, one turn
//      earlier).
//    · On an ACCOUNT store the Mac judges after the first clean round, so a
//      note she writes during that wait (≤ 20 s) on a brand-new account makes
//      the store read not fresh. A real fresh install is signed out (no wait);
//      the window is the persisted-session road only.
//

import Foundation
import GRDB
import VariorumCore

/// **R-633-16 — what a launch road knows about whether the store is FRESH.**
/// Asked only of a book that seeds fresh stores alone
/// (`SampleLibrarySeeder.Book.seedsFreshStoresOnly`); every other book ignores
/// it. `nonisolated` and app-type-free (the header's reason).
nonisolated enum SampleLibraryFreshness: Sendable, Equatable {
    /// Judge it at the deciding reads — after the sync gate, inside the latch
    /// — by what the store holds. The Mac's launch on a store this device has
    /// not settled (and every caller that names nothing).
    case readAtDecision
    /// Taken at LAUNCH, before her first write — the phone's first-write
    /// occasion (`MobileFirstWriteFurniture.prime`).
    case takenAtLaunch(Bool)
    /// **The phone's launch-time fact was NEVER TAKEN** (`prime` never ran, or
    /// its read failed) — VX-633 ladder R1 F2. Not fresh (never a guess that
    /// seeds), and NOT A DECISION either: the decline is never recorded
    /// (`SampleLibrarySeeder.Outcome.freshnessUntaken`), so the next
    /// occasion, its fact taken, asks again — the starter Journal's
    /// never-a-guess rule, which skips without deciding. The seed's own
    /// partial copy still completes (store truth, read at the decision).
    case untaken
    /// This device already SETTLED the store's launch (the Mac's Welcome
    /// arrangement mark is `done` or `declined`) — an existing store by the
    /// device's own record; nothing is judged.
    case settled
}

nonisolated enum SampleLibraryFreshStore {
    /// **A store that has never held writing** — no `container` row (a note or
    /// a snippet), live or in the Trash, and no BOOK `reading` row but
    /// `ownBook`'s (the seed's own, by its reserved name; a gathering never
    /// counts — the header's reason). Two indexed EXISTS probes: P1-clean.
    static func storeIsFresh(_ db: Database, ownBook: String) throws -> Bool {
        let holdsWriting = try Bool.fetchOne(
            db,
            sql: """
                SELECT EXISTS (SELECT 1 FROM container)
                    OR EXISTS (SELECT 1 FROM reading WHERE kind = 'book' AND name <> ?)
                """,
            arguments: [ownBook]) ?? true
        return !holdsWriting
    }

    /// **The seed's own partial copy stands**: its book (found by the reserved
    /// name) holds at least one title it ships — the front matter or a
    /// chapter. A book of hers that merely shares the name holds none.
    static func isResuming(bookExists: Bool, presentTitles: Set<String>, shippedTitles: [String]) -> Bool {
        bookExists && shippedTitles.contains { presentTitles.contains($0) }
    }

    /// **May the launch road mint a fresh-only book here?** A settled store:
    /// never. Otherwise the book's own partial copy is completed, and a fresh
    /// store is seeded; anything else is an existing store. The store read is
    /// a closure so the taken and settled arms never pay for it.
    static func mayMint(
        _ freshness: SampleLibraryFreshness, resuming: Bool, storeIsFresh: () throws -> Bool
    ) rethrows -> Bool {
        switch freshness {
        case .settled: return false
        case .takenAtLaunch(let fresh): return resuming || fresh
        case .untaken: return resuming
        case .readAtDecision: return try resuming || storeIsFresh()
        }
    }
}
