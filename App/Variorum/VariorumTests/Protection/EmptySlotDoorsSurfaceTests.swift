//
//  EmptySlotDoorsSurfaceTests.swift
//  VariorumTests — VX-309 U1b pieces 1–2: the Mac faces with NO library open, by source (Mac only — the faces' files are
//  the Mac target's). The missing face's and rule 27's *Restore from Backup…* are, on the new road, the doors over this
//  Mac's copies (rule 17: "The app's Restore from Backup is this door" — the arc's availability gap, F-U1b-2) while today's
//  road keeps the Finder reveal; the doors' sheet renders the listing with each row's doors; Make this my library's confirm
//  carries T-5's one-field arm. Red by construction on the pre-unit tree (no `restoreDoor`, no listing phase, no T-5 arm).
//

import Foundation
import Testing

@testable import Variorum
import VariorumCore

@MainActor
@Suite("VX-309 U1b — the faces with no library open offer the doors over this Mac's copies (by source)")
struct EmptySlotDoorsSurfaceTests {
    private static var appRoot: URL {
        URL(fileURLWithPath: #filePath)
            .deletingLastPathComponent()  // Protection
            .deletingLastPathComponent()  // VariorumTests
            .deletingLastPathComponent()  // App/Variorum
    }

    /// A source file's CODE lines (comments dropped).
    private static func code(_ relative: String) throws -> String {
        let source = try String(contentsOf: appRoot.appendingPathComponent(relative), encoding: .utf8)
        return source.split(separator: "\n").filter {
            let line = $0.trimmingCharacters(in: .whitespaces)
            return !line.hasPrefix("//") && !line.hasPrefix("///")
        }.joined(separator: "\n")
    }

    /// The composition: the missing face gets the doors' Restore only on the new road (today's road — nil — keeps the
    /// Finder reveal byte for byte); rule 27's face (the new road only) gets it with its copies-home gate.
    @Test func theFacesWithNoLibraryOpenTakeTheDoorsRestoreOnTheNewRoadOnly() throws {
        let app = try Self.code("Variorum/VariorumApp.swift")
        #expect(app.contains("restoreDoor: bootstrap.newRoad ? { libraryOpen.openRestoreList(bootstrap: bootstrap) } : nil)"))
        #expect(app.contains("restoreDoor: { libraryOpen.openRestoreList(bootstrap: bootstrap) },"))
        #expect(app.contains("copiesHome: bootstrap.liveStoreURL.map(RoadLockView.copiesHome(besideStore:)) ?? false)"))
        let missing = try Self.code("Variorum/LibraryMissingView.swift")
        #expect(missing.contains("if let restoreDoor, lobby.copiesHomeExists {"))
        #expect(missing.contains("} else if restoreDoor == nil, let folder = lobby.backupsFolderURL {"),
                "today's road keeps the Finder reveal")
        let lock = try Self.code("Variorum/StoreLockView.swift")
        #expect(lock.contains("if let restoreDoor, copiesHome {"))
    }

    /// The presenter's door lists this Mac's copies through the doors' ONE brain, on the new road only.
    @Test func thePresentersRestoreListIsTheDoorsListingOnTheNewRoad() throws {
        let door = try Self.code("Variorum/LibraryOpenDoor.swift")
        #expect(door.contains("func openRestoreList(bootstrap: AppBootstrap) {"))
        #expect(door.contains("bootstrap.newRoad,"))
        #expect(door.contains("let roads = bootstrap.copyDoorsRoadsWithoutALibrary() else { return }"))
        #expect(door.contains("Task { await fresh.beginListing() }"))
        let sheet = try Self.code("Variorum/Features/Protection/CopyDoorsSheet.swift")
        #expect(sheet.contains("case .listing(let listing):"))
        #expect(sheet.contains("} else if model.intoTheEmptySlot {"), "T-5's confirm arm")
    }
}
