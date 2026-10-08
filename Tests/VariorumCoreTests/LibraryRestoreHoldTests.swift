import Foundation
import Testing

@testable import VariorumCore

// Phase 13x U2 row 7 — the restore-hold flag's pins: set/read/clear
// round-trip, the unreadable-marker-is-held honesty rule, and the
// held-by-location semantics (two stores, two independent holds).

@Suite("13x U2 — the restore-hold marker")
struct LibraryRestoreHoldTests {
    private func temporaryStoreURL() throws -> URL {
        let folder = FileManager.default.temporaryDirectory
            .appendingPathComponent("variorum-13x-hold-\(UUID().uuidString)", isDirectory: true)
        try FileManager.default.createDirectory(at: folder, withIntermediateDirectories: true)
        return folder.appendingPathComponent("variorum.sqlite", isDirectory: false)
    }

    @Test func aHoldSetAtAdoptionReadsBackAndClearsOnResume() throws {
        let store = try temporaryStoreURL()
        #expect(LibraryRestoreHold.isHeld(besideStore: store) == false)
        let asOf = Date(timeIntervalSince1970: 1_780_000_000)
        let now = Date(timeIntervalSince1970: 1_790_000_123)
        try LibraryRestoreHold.set(besideStore: store, asOf: asOf, now: now)
        let hold = try #require(LibraryRestoreHold.read(besideStore: store))
        #expect(LibraryRestoreHold.isHeld(besideStore: store))
        // ISO-8601 round-trip is second-granular.
        #expect(abs(hold.heldAt.timeIntervalSince(now)) < 1)
        #expect(abs((hold.asOf ?? .distantPast).timeIntervalSince(asOf)) < 1)
        #expect(LibraryRestoreHold.clear(besideStore: store))
        #expect(LibraryRestoreHold.isHeld(besideStore: store) == false)
        // Clearing an absent marker is released, not an error.
        #expect(LibraryRestoreHold.clear(besideStore: store))
    }

    @Test func aFreshAdoptionOverwritesTheStandingHold() throws {
        let store = try temporaryStoreURL()
        try LibraryRestoreHold.set(
            besideStore: store, asOf: Date(timeIntervalSince1970: 1_000_000),
            now: Date(timeIntervalSince1970: 2_000_000))
        try LibraryRestoreHold.set(
            besideStore: store, asOf: nil, now: Date(timeIntervalSince1970: 3_000_000))
        let hold = try #require(LibraryRestoreHold.read(besideStore: store))
        #expect(hold.asOf == nil)
        #expect(abs(hold.heldAt.timeIntervalSince(Date(timeIntervalSince1970: 3_000_000))) < 1)
    }

    @Test func anUnreadableMarkerReadsAsHeldNeverAsAbsence() throws {
        let store = try temporaryStoreURL()
        try Data("not json at all {{{".utf8)
            .write(to: LibraryRestoreHold.markerURL(besideStore: store))
        let hold = try #require(LibraryRestoreHold.read(besideStore: store))
        #expect(hold.asOf == nil)
        #expect(LibraryRestoreHold.isHeld(besideStore: store))
        // Resume still clears a torn marker.
        #expect(LibraryRestoreHold.clear(besideStore: store))
        #expect(LibraryRestoreHold.isHeld(besideStore: store) == false)
    }

    @Test func holdsAreIndependentPerStoreLocation() throws {
        let storeA = try temporaryStoreURL()
        let storeB = try temporaryStoreURL()
        try LibraryRestoreHold.set(besideStore: storeA, asOf: nil, now: Date())
        #expect(LibraryRestoreHold.isHeld(besideStore: storeA))
        #expect(LibraryRestoreHold.isHeld(besideStore: storeB) == false)
    }
}
