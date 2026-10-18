//
//  LaunchFurniture.swift
//  Variorum (Mac)
//
//  17y B-SEED (item (q), the tutorial-seed trace) — THE LAUNCH'S FURNITURE,
//  in one callable place. Moved VERBATIM out of `VariorumApp`'s window
//  `.task` so the pins drive the PRODUCTION composition rather than a
//  replica of it: the defect this batch traced (a fresh store born without
//  its field guide) lived exactly in the gap between what a launch does and
//  what the tests' own copy of a launch did. `VariorumApp` calls this and
//  nothing else; the marks and the first-round wait are injectable only so a
//  headless pin never reads or writes the test host's defaults (the test host
//  IS the Debug app's domain) and never waits twenty seconds — nil is
//  production, exactly as each seeder's own parameters already read it.
//
//  What it runs, in order (each seeder's own header carries its rules):
//
//    · Pre-13u Act 3: THE SAMPLE LIBRARY — the Sherlock adventures as a real
//      book, seeded once per store. Her ruling is default-on in every
//      reader's store, which puts this on every launch's path, so where it
//      sits matters: the caller runs it inside the window's own `.task` and
//      after `start()`, so (1) first paint is already done — nothing in the
//      launch awaits it — and (2) the sign-in question is settled, so the
//      gate reads facts instead of a coin flip (the starter journal's
//      batch-5 MAJOR, whose duplicate book propagated to every device).
//      Idempotent by construction and resumable, so a re-run after an
//      unlock — or after a cancelled seed — is safe. pre-13x 5a: BOTH seeded
//      books, in order — Sherlock, then *Encryption Explained* (its own
//      mark, so an existing store seeds only the new one); 18l-c U6 adds
//      Jekyll. 13i-d U7: Sherlock's outcome decides whether this launch is a
//      FRESH store's birth (below).
//    · 13i-b U4 (P-13ib-4): the STARRED-NOTES gathering — an ordinary
//      gathering on ★, seeded once per store (fresh AND existing), her
//      deletion honoured; same occasion, same gate, its own mark.
//    · 13i-d U7 — THE WELCOME ARRANGEMENT AT A FRESH STORE'S BIRTH (the
//      sitting record §7/§17/§19.3): only when this launch's Sherlock seed
//      minted every story; an existing store is marked `declined` and NEVER
//      retrofitted (the restore doors are its road). Same occasion, after
//      every other furniture seed.
//    · 17y B-SEED — THE FIELD GUIDE AT BIRTH: on that same arrange-now road,
//      BEFORE the arrangement shelves it (`TutorialSeeder.seedAtBirth`, the
//      arrangement's `beforeArranging`). Until this batch nothing on the
//      launch path seeded the guide — it had only ever been a door — so a
//      fresh store's Welcome lacked it (her report). Silent, latched, and
//      deciding from one read: a live guide, her deletion, or tutorial
//      residue each leave the store as it is.
//
//      THE RESIDUAL, NAMED (the Jekyll precedent — 18l-c U6): the guide is
//      not judged by the sync dedupe (that would be `Sync/`), so a fresh
//      signed-OUT store that later signs into an account already holding a
//      field guide shows two — both live, nothing lost, either deletable.
//

import Foundation
import VariorumCore

@MainActor
enum LaunchFurniture {
    /// The device marks the seeds keep — nil everywhere is production (each
    /// seeder's own `UserDefaults` key for the store variant).
    struct Marks {
        /// Per seeded book: the seeder's `loadMark` / `saveMark` pair.
        var book: ((SampleLibrarySeeder.Book) -> (load: () -> Bool, save: (Bool) -> Void))?
        /// The starred-notes gathering's pair.
        var starred: (load: () -> Bool, save: (Bool) -> Void)?
        /// The Welcome arrangement's launch mark (absent · pending · done · declined).
        var welcome: (load: () -> String?, save: (String) -> Void)?

        static let production = Marks()
    }

    /// Every seed a launch runs, in the launch's order. Answers the Welcome
    /// arrangement's launch decision (nil only if `Book.launchSet` ever
    /// stopped carrying Sherlock). Silent by design — every outcome is
    /// logged by its own seeder, none is ever surfaced.
    /// 17y B-DEDUPE (R-17y-8): the loop iterates the LAUNCH SET — Jekyll
    /// left the default seed; the Restore doors still mint it from
    /// `Book.all`.
    @discardableResult
    static func seed(
        session: AppSession,
        storeVariant: AppDatabase.StoreVariant,
        gate: SampleLibrarySeeder.SyncGate,
        marks: Marks = .production,
        firstRoundWait: Duration? = nil
    ) async -> SampleLibraryWelcome.LaunchOutcome? {
        var sherlockOutcome: SampleLibrarySeeder.Outcome?
        for book in SampleLibrarySeeder.Book.launchSet {
            let mark = marks.book?(book)
            let outcome = await SampleLibrarySeeder.seedIfNeeded(
                session: session,
                book: book,
                storeVariant: storeVariant,
                gate: gate,
                firstRoundWait: firstRoundWait,
                loadMark: mark?.load,
                saveMark: mark?.save)
            if book == .sherlock { sherlockOutcome = outcome }
        }
        await StarredGatheringSeeder.seedIfNeeded(
            session: session,
            storeVariant: storeVariant,
            gate: gate,
            firstRoundWait: firstRoundWait ?? SampleLibrarySeeder.firstRoundWait,
            loadMark: marks.starred?.load,
            saveMark: marks.starred?.save)
        guard let sherlockOutcome else { return nil }
        return await SampleLibraryWelcome.arrangeAtLaunch(
            session: session, sherlock: sherlockOutcome,
            storeVariant: storeVariant,
            guideName: TutorialSeeder.bookName,
            // 17y B-SEED: the field guide is born with the store, on the
            // arrangement's arrange-now road only — so Welcome holds it at
            // first open (§19.3) and an existing store never grows one.
            // 13s-b U1b: the example snippet FIRST (the oldest group is the
            // Snippets rail's first card — R-13s-26), then the guide, then
            // the readme LAST — the newest thing a fresh Library leads
            // with (R-13s-29/39). VX-306 ladder r2 m2: the readme's Start
            // Here passages only where this store opens on the new road
            // (the road's own rule for the variant — today's road, Release
            // included, seeds her five blocks alone until VX-329).
            beforeArranging: {
                _ = await ExampleSnippetSeeder.seedAtBirth(session: session)
                _ = await TutorialSeeder.seedAtBirth(session: session)
                _ = await ReadmeSeeder.seedAtBirth(
                    session: session,
                    onTheNewRoad: ProtectionRoad.opensOnTheNewRoad(devStore: storeVariant == .dev))
            },
            loadMark: marks.welcome?.load,
            saveMark: marks.welcome?.save)
    }
}
