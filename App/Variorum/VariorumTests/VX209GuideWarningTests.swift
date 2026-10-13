//
//  VX209GuideWarningTests.swift
//  VariorumTests
//
//  VX-209 — THE GUIDE'S OLDER-COPY WARNING (RUN VX-201, unit U5, step 3; the
//  brief is §G of notes/plans/fixes/vx-201-castle-prelaunch-fixes.md, the
//  record its "U5 RECORD (VX-209)"). Her pre-launch scope: a warning in the
//  field guide's Castle section with instructions for reading an old backup —
//  written against what RUNS (`VX209WayBackRoundTripTests` reproduced the
//  audit's §W.2 trace), never against the unrun reading.
//
//  THE RE-VERIFICATION THE BRIEF ASKED FOR changed the instruction: §W.2's
//  road was "check Settings ▸ Protection and choose Use Castle again", but
//  every adoption lands HELD (13x round 3) and a standing hold refuses Use
//  Castle at its door (13x F1 R1-M1). The road that works is Resume Sync
//  FIRST, then Use Castle — pinned here on the reproduced library itself.
//
//  RED ON OLD (behavioural reverts, notes/plans/fixes/vx-201-u5-reverts/):
//    · R-209-guide-seed  — the Mac's lesson 2 renders without the paragraph:
//                          the seeded pin goes red;
//    · R-209-guide-words — the paragraph says §W.2's unverified road (no
//                          Resume Sync): the words pin goes red.
//  The road pin is a BOUND (green on both sides): it proves the shipped
//  behavior the words lean on.
//

import Dependencies
import Foundation
import GRDB
import Testing
import VariorumCore

@testable import Variorum

@MainActor
@Suite("VX-209 — the field guide warns about older copies, with the road that works", .serialized)
struct VX209GuideWarningTests {
    private var paragraph: String { ProtectionCopy.privacyOlderCopyParagraph }

    // MARK: - The words: the doors by their own names, the road in order

    @Test func theWarningNamesTheDoorsAndTheRoadThatWorks() {
        // The doors, by the words they wear (a rename turns this red).
        #expect(paragraph.contains(LibraryOpenCopy.restoreSectionTitle))
        #expect(paragraph.contains("File ▸ \(LibraryOpenCopy.openLibraryDoor)"))
        #expect(paragraph.contains("Settings ▸ \(SettingsPane.dataSafety.title) ▸"))
        #expect(paragraph.contains("Settings ▸ \(SettingsPane.protection.title)"))
        #expect(paragraph.contains("Previous Libraries"), "names the road that does NOT undo it")
        // The road, in the order that works: Resume Sync, then Use Castle.
        let resume = paragraph.range(of: LibraryOpenCopy.resumeSyncDoor)
        let useCastle = paragraph.range(of: "choose Use Castle again")
        #expect(resume != nil && useCastle != nil, "the road names both presses")
        if let resume, let useCastle {
            #expect(resume.lowerBound < useCastle.lowerBound, "Resume Sync comes first")
        }
        // The generic road (a library left reading Standard by an older build).
        #expect(paragraph.contains("any time Protection says Standard when you chose Castle"))
    }

    @Test func theWarningKeepsTheGuidesRegister() {
        #expect(!paragraph.contains(CopyRegisterPinTests.forbidden))
        #expect(paragraph.firstMatch(of: /\bMac\b/.wordBoundaryKind(.simple)) == nil,
                "Shared copy names no device by a literal")
        let shouted = paragraph.split(separator: " ").filter { word in
            let letters = word.filter(\.isLetter)
            return letters.count > 1 && letters.allSatisfy(\.isUppercase)
        }
        #expect(shouted.isEmpty, "no capitals for emphasis: \(shouted)")
        #expect(paragraph.first?.isUppercase == true && paragraph.hasSuffix("."))
    }

    // MARK: - The seeded guide: the Mac's lesson 2 carries it

    @Test func theMacsGuideClosesTheCastleLessonOnTheWarning() async throws {
        let db = try AppDatabase.inMemory()
        let lessonTwo: String = try await withDependencies {
            $0.database = db
            $0.uuid = .incrementing
            $0.date = .constant(Date(timeIntervalSince1970: 1_782_950_400))
            $0.withRandomNumberGenerator = WithRandomNumberGenerator(SystemRandomNumberGenerator())
        } operation: { @MainActor in
            let session = AppSession(database: db)
            // The seeded-book marks are injected (never the dev store's defaults).
            session.seededBookMarkIsSet = { _ in false }
            session.markSeededBook = { _ in }
            let bookID = try await TutorialSeeder.restore(session: session)
            return try await db.read { db in
                guard let lesson = try String.fetchOne(
                    db,
                    sql: """
                        SELECT c.id FROM reading_post rp
                        JOIN container c ON c.id = rp.post_id AND c.deleted_at IS NULL
                        WHERE rp.reading_id = ? AND rp.deleted_at IS NULL AND c.title = ?
                        """,
                    arguments: [bookID, ProtectionCopy.privacyLessonTwoTitle])
                else { return "" }
                return try Queries.renderedText(db, containerID: lesson)
            }
        }
        #expect(lessonTwo.contains(ProtectionCopy.privacyOlderCopyParagraph),
                "the Mac's lesson 2 carries the older-copy warning verbatim")
        #expect(lessonTwo.contains(ProtectionCopy.privacyCastleFloorSentence),
                "beside the Castle lesson it belongs to")
        for shared in ProtectionCopy.privacyLessonTwoParagraphs {
            #expect(lessonTwo.contains(shared), "the shared paragraphs stay whole")
        }
    }

    // MARK: - The road is real (BOUND): on the reproduced library itself

    /// On the library §W.2's round trip leaves behind (the Castle copy brought
    /// back, reading Standard): the restore hold stands, Use Castle refuses
    /// at its door with the one sentence, Resume Sync clears the hold, and
    /// Use Castle then opens its first screen. Green on both sides — the
    /// shipped behavior the guide's road leans on.
    @Test func afterTheWayBackResumeSyncThenUseCastleIsTheRoadThatOpens() async throws {
        try await withDependencies {
            $0.date = .constant(Date(timeIntervalSince1970: 1_790_000_000))
            $0.uuid = .incrementing
        } operation: { @MainActor in
            let world = try await VX209CastleWorld.make()
            defer { try? FileManager.default.removeItem(at: world.dir) }
            try await world.unlockIntoReady()
            let bootstrap = world.bootstrap
            // The composition root's wiring of the hold (VariorumApp's).
            let hold = RestoreHoldModel(storeURL: world.storeURL)
            hold.wireGates(
                sync: SyncSession(database: try AppDatabase.inMemory(), allowsSync: true),
                protection: bootstrap.protection)

            // §W.2's round trip: the Standard-era backup, then the Castle copy back.
            let first = LibraryOpenModel(bootstrap: bootstrap)
            first.begin(picked: world.snapshot)
            try await VX209CastleWorld.waitUntil { first.phase == .confirm }
            await first.confirmAdoption()
            try await Task.sleep(for: .milliseconds(1100))
            let castleCopy = try #require(try FileManager.default.contentsOfDirectory(
                at: LibraryAdoption.previousLibrariesHome(besideStore: world.storeURL),
                includingPropertiesForKeys: nil).first)
            let second = LibraryOpenModel(bootstrap: bootstrap)
            second.begin(picked: castleCopy)
            try await VX209CastleWorld.waitUntil { second.phase == .unlock }
            await second.unlock(passphrase: VX209CastleWorld.passphrase)
            try await VX209CastleWorld.waitUntil { second.phase == .confirm }
            await second.confirmAdoption()
            await bootstrap.relanding?.value
            #expect(world.backing.auto == world.castleKey && world.backing.gated == nil,
                    "premise: the way-back landed the old way")

            // The hold stands: Use Castle refuses at its door.
            hold.refresh()
            #expect(hold.isHeld, "every adoption lands held")
            let runner = PostureSwitchRunner(leaves: inertLeaves(world))
            let refused = PostureSwitchModel(
                mode: .enter, runner: runner, controller: bootstrap.protection, vaultTie: nil)
            await refused.start()
            #expect(refused.phase == .failed(ProtectionCopy.resumeSyncFirst), "\(refused.phase)")

            // Resume Sync (the banner's one press) — then Use Castle opens.
            await hold.resume()
            #expect(!hold.isHeld && !LibraryRestoreHold.isHeld(besideStore: world.storeURL))
            let opened = PostureSwitchModel(
                mode: .enter, runner: runner, controller: bootstrap.protection, vaultTie: nil)
            await opened.start()
            #expect(opened.phase == .explain, "Use Castle opens its first screen: \(opened.phase)")
        }
    }

    /// The runner's leaves for a door-only start (local-only, signed out;
    /// nothing past the first screen is driven).
    private func inertLeaves(_ world: VX209CastleWorld) -> PostureSwitchRunner.Leaves {
        PostureSwitchRunner.Leaves(
            scope: world.bootstrap.storeVariant.rawValue, storeURL: world.storeURL,
            database: try! AppDatabase.inMemory(), gate: world.gate,
            keyStore: .inMemory(), keyProvider: DeviceKeySyncProvider(store: .inMemory()),
            vault: nil, transport: nil, signedIn: { false },
            appleKeys: .inMemory(backing: InMemoryAppleKeyBacking(key: world.apple)),
            libraryKeyInHand: { nil as StoreKey? }, posture: { .standard }, alwaysAsk: { false },
            biometryAvailable: { true },
            moveCustody: { _ in .refused("inert") },
            rekeyLibrary: { _, _, _ in }, pauseSync: {}, resumeSync: {},
            takeSnapshot: { .notKept }, preSwitchSnapshots: { _ in [] }, deleteSnapshotPairs: { _ in 0 },
            defaults: { UserDefaults(suiteName: "io.lduarte.variorum.tests.vx209.inert")! },
            reconcile: {}, now: { Date() }, log: { _ in })
    }
}
