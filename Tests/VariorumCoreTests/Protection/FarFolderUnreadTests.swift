//
//  FarFolderUnreadTests.swift
//  VariorumCoreTests — VX-1013 (`notes/plans/fixes/vx-1013-open-far-folder-wait.md`, D-1013-1 and D-1013-3): the launch
//  road reads the CONTAINER only and leaves the far folder (her picked backup folder, often iCloud-synced) to one walk
//  off the launch path. The catalogue says which places it did not read (`Catalog.unreadPlaces`), and `assess` never
//  concludes "none anywhere" from a place it never read: rule 27 is not claimed on a partial listing (the lobby's
//  refusal, the two unlocked faults), and the offer's search is owed where a backup MIGHT hold the library's own key
//  file (the search reads every place and answers). The SAME worlds read in full keep today's verdicts byte for byte.
//  Facts built directly; red on the pre-fix tree by behavioural revert of `Assess.swift`'s three readings (the record's
//  LIVE STATUS says how and with what counts).
//

import CryptoKit
import Foundation
import Testing

@testable import VariorumCore

@Suite("VX-1013 — an unread far folder is indeterminate: rule 27 never claimed on a partial listing")
struct FarFolderUnreadTests {
    // MARK: - The catalogue says which places it read (D-1013-1)

    @Test func aCatalogueReadsEveryPlaceByDefault() throws {
        #expect(Catalog().unreadPlaces.isEmpty && Catalog().readsEveryPlace)
        let key = StoreKey.mint()
        let far = CatalogEntry(
            place: .farFolder, folders: CF.macFolder(CF.lib1, CF.macA), name: CF.pairName(CF.stamp(1), key),
            bytes: try CF.format3(library: CF.lib1, key: key))
        let full = Catalog.build([far])
        #expect(full.readsEveryPlace && full.keyFiles.count == 1)
        // A place the listing did not read contributes nothing, and says so.
        let partial = Catalog.build([far], unreadPlaces: [.farFolder])
        #expect(partial.unreadPlaces == [.farFolder] && !partial.readsEveryPlace)
        #expect(partial.keyFiles.isEmpty && partial.copies.isEmpty && partial.foreign.isEmpty)
        #expect(partial != Catalog.build([]), "a partial listing is never mistaken for a full empty one")
    }

    // MARK: - Rule 27 at the lobby (`AssessRules.lobby`)

    static func lobbyRefuses(_ catalog: Catalog, session: SessionFact = .signedOut) -> Bool {
        let facts = ProtectionFacts(
            scope: AWorld.scope, storeFile: .present, unlocked: nil, session: session, catalog: catalog, now: AWorld.now)
        return assess(facts).lobby.noKeyFileAnywhere != nil
    }

    /// A library in the slot and nothing this Mac holds for it: read in full, rule 27's refusal (today's verdict);
    /// with the far folder unread, nothing is said — the far walk that lands later decides.
    @Test func ruleTwentySevenIsNeverClaimedAtTheLobbyOnAPartialListing() {
        #expect(Self.lobbyRefuses(Catalog.build([])), "read in full, nothing anywhere: rule 27 — today's verdict")
        #expect(!Self.lobbyRefuses(Catalog.build([], unreadPlaces: [.farFolder])),
                "the far folder unread: it might hold a key file — nothing claimed")
        #expect(!Self.lobbyRefuses(Catalog.build([], unreadPlaces: [.farFolder]), session: .signedIn(accountID: PF.id(), email: nil)))
    }

    /// The far folder holds a key file that would open it: unread, nothing said; read, nothing said (it might open —
    /// today's verdict). The two readings agree whenever the far folder could hold a road.
    @Test func aFarKeyFileThatWouldOpenItSaysNothingReadOrUnread() throws {
        let key = StoreKey.mint()
        let entries = [
            CatalogEntry(place: .farFolder, folders: CF.macFolder(CF.lib1, CF.macA), name: CF.snapshotName(CF.stamp(1), key)),
            CatalogEntry(place: .farFolder, folders: CF.macFolder(CF.lib1, CF.macA), name: CF.pairName(CF.stamp(1), key),
                         bytes: try CF.format3(library: CF.lib1, key: key)),
        ]
        #expect(!Self.lobbyRefuses(Catalog.build(entries)))
        #expect(!Self.lobbyRefuses(Catalog.build(entries, unreadPlaces: [.farFolder])))
    }

    // MARK: - Rule 27 after a quiet-road open (`AssessRules.repairs`) and rule 21's offer (`AssessRules.acts`)

    static func hasNoKeyFileFault(_ assessment: Assessment) -> Bool {
        assessment.faults.contains { if case .noKeyFileAnywhere = $0 { return true } else { return false } }
    }

    /// Opened by a quiet road with the key file beside the library GONE and no sealed copy to write back, the
    /// container holding no backup of it. Read in full with nothing anywhere: rule 27's fault, no offer (today's).
    /// With the far folder unread: no rule 27 claimed — the offer's search is owed instead (it reads every place and
    /// answers: the far backup's key file, or rule 27 itself). Read in full WITH a far backup holding the current key's
    /// file: the offer, no fault (today's).
    @Test func theLiveKeyFileGoneClaimsNothingOnAPartialListing() throws {
        let world = try AWorld(.standard)
        var facts = try world.facts()
        facts.catalog = Catalog.build([])
        let full = assess(facts)
        #expect(Self.hasNoKeyFileFault(full), "read in full, nothing anywhere: rule 27 — today's verdict")
        #expect(!full.acts.contains(.offerKeyFile))

        facts.catalog = Catalog.build([], unreadPlaces: [.farFolder])
        let partial = assess(facts)
        #expect(!Self.hasNoKeyFileFault(partial), "the far folder unread: nothing claimed — \(partial.faults)")
        #expect(partial.acts.contains(.offerKeyFile), "the search is owed: it reads every place and answers")

        let farPair = CatalogEntry(
            place: .farFolder, folders: CF.macFolder(world.world.library, CF.macA),
            name: CF.pairName(CF.stamp(1), world.key), bytes: try CF.format3(library: world.world.library, key: world.key))
        facts.catalog = Catalog.build([farPair])
        let farHolds = assess(facts)
        #expect(!Self.hasNoKeyFileFault(farHolds) && farHolds.acts.contains(.offerKeyFile), "today's offer")
    }

    /// The key file beside the library is ANOTHER key's (a stray), no sealed copy of the library's own, no backup in
    /// the container, the stray's history not reaching the current key: read in full, rule 27's second fault arm
    /// (today's); the far folder unread, the stray is still said (`liveKeyFileIsAnotherKeys`) but rule 27 is not
    /// claimed, and the offer's search is owed.
    @Test func aStrayInTheLivePlaceClaimsNothingMoreOnAPartialListing() throws {
        let world = try AWorld(.standard)
        var facts = try world.facts()
        let stray = CatalogEntry(
            place: .container, name: ProtectionNames.keyFilename,
            bytes: try CF.format3(library: world.world.library, key: StoreKey.mint()))
        facts.catalog = Catalog.build([stray])
        let full = assess(facts)
        #expect(Self.hasNoKeyFileFault(full), "read in full: rule 27's second arm — today's verdict")
        #expect(full.faults.contains { if case .liveKeyFileIsAnotherKeys = $0 { true } else { false } })

        facts.catalog = Catalog.build([stray], unreadPlaces: [.farFolder])
        let partial = assess(facts)
        #expect(!Self.hasNoKeyFileFault(partial), "the far folder unread: nothing claimed — \(partial.faults)")
        #expect(partial.faults.contains { if case .liveKeyFileIsAnotherKeys = $0 { true } else { false } },
                "the stray beside the library is a container fact — still said")
        #expect(partial.acts.contains(.offerKeyFile))
    }

    // MARK: - Rule 3's no-backup-yet moment (R-1013-A1 — option (a): the container answers it on a partial listing)

    static func owesTheFirstBackupMoment(_ assessment: Assessment) -> Bool {
        assessment.acts.contains(.askPassphrase(.beforeFirstBackup))
    }

    /// R-1013-A1: a library with no passphrase and no backup of it in this Mac's CONTAINER — the place every backup run
    /// lands first — still owes rule 3's "always right before the first backup" moment when the far folder is unread (the
    /// launch road's creation and Make this my library's reopen keep it: no later assessment feeds the reminder). Read in
    /// full with no backup anywhere: owed (today's). A container backup of the library: not owed, read or unread. A ruling
    /// pin, green on both sides of the fix by construction (row 12 is untouched); the record's option (b) — not owed while
    /// the far folder is unread — turns it red (the mutation run in LIVE STATUS).
    @Test func theNoBackupYetMomentIsOwedOnAPartialListing() throws {
        var world = try AWorld(.standard)
        world.passphraseSet = false
        var facts = try world.facts()
        facts.catalog = Catalog.build(try world.entries())
        #expect(Self.owesTheFirstBackupMoment(assess(facts)), "read in full, no backup anywhere: owed — today's")

        facts.catalog = Catalog.build(try world.entries(), unreadPlaces: [.farFolder])
        #expect(Self.owesTheFirstBackupMoment(assess(facts)),
                "the far folder unread, no backup in the container: still owed (R-1013-A1) — rule 3's always")

        let backup = CF.macFolder(world.world.library, CF.macA)
        let pair = [
            CatalogEntry(place: .container, folders: backup, name: CF.snapshotName(CF.stamp(1), world.key)),
            CatalogEntry(place: .container, folders: backup, name: CF.pairName(CF.stamp(1), world.key),
                         bytes: try CF.format3(library: world.world.library, key: world.key)),
        ]
        facts.catalog = Catalog.build(try world.entries() + pair, unreadPlaces: [.farFolder])
        #expect(!Self.owesTheFirstBackupMoment(assess(facts)), "a container backup of the library: not owed")
        facts.catalog = Catalog.build(try world.entries() + pair)
        #expect(!Self.owesTheFirstBackupMoment(assess(facts)), "read in full with a backup: not owed — today's")
    }

    /// The healthy open never meets the indeterminate readings: a live key file of the current key reads the same
    /// faults, repairs and acts whether or not the far folder was read (the launch road's happy path changes nothing).
    @Test func aHealthyLibraryAssessesTheSameReadOrUnread() throws {
        let world = try AWorld(.standard)
        var facts = try world.facts()
        let full = assess(facts)
        facts.catalog = Catalog.build(try world.entries(), unreadPlaces: [.farFolder])
        let partial = assess(facts)
        #expect(full.faults == partial.faults && full.repairs == partial.repairs, "\(full.faults) vs \(partial.faults)")
        #expect(full.acts == partial.acts && full.launch == partial.launch && full.lobby == partial.lobby)
    }
}
