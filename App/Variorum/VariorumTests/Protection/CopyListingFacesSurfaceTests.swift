//
//  CopyListingFacesSurfaceTests.swift
//  VariorumTests — VX-309 U1c, the Mac faces by source (Mac only — the faces' files are the Mac target's): VX-265's
//  *Delete…* on an other library's row in BOTH listings (the empty-slot sheet's and Data Safety's Restore list) and its own
//  confirm; VX-210's one honest line in both, only when such copies exist (P-2); the bootstrap composing the delete road on
//  both roads. Red by construction on the pre-unit tree (no delete door, no line).
//

import Foundation
import Testing

@testable import Variorum
import VariorumCore

@MainActor
@Suite("VX-309 U1c — the listing's faces: rule 19's delete door and VX-210's line (by source)")
struct CopyListingFacesSurfaceTests {
    static var appRoot: URL {
        URL(fileURLWithPath: #filePath)
            .deletingLastPathComponent()  // Protection
            .deletingLastPathComponent()  // VariorumTests
            .deletingLastPathComponent()  // App/Variorum
    }

    /// A source file's CODE lines (comments dropped).
    static func code(_ relative: String) throws -> String {
        let source = try String(contentsOf: appRoot.appendingPathComponent(relative), encoding: .utf8)
        return source.split(separator: "\n").filter {
            let line = $0.trimmingCharacters(in: .whitespaces)
            return !line.hasPrefix("//") && !line.hasPrefix("///")
        }.joined(separator: "\n")
    }

    /// VX-265: the empty-slot sheet's rows carry *Delete…* only where the row's library has a choice and the road exists;
    /// the confirm is its own phase (never part of another act's confirm); Data Safety's rows carry it through Settings' own
    /// presenter.
    @Test func bothListingsCarryTheDeleteDoorAndItsOwnConfirm() throws {
        let sheet = try Self.code("Variorum/Features/Protection/CopyDoorsSheet.swift")
        #expect(sheet.contains("ForEach(listing.all) { row in listingRow(row, delete: listing.deleteChoice(for: row)) }"))
        #expect(sheet.contains("if model.offersDelete, let delete {"))
        #expect(sheet.contains("Button(ProtectionWords.deleteCopiesDoor) { model.openDeleteCopies(delete) }"))
        #expect(sheet.contains("case .deleteCopies(let confirm):"))
        #expect(sheet.contains("DeleteCopiesConfirm(model: confirm)"))
        #expect(sheet.contains("Button(ProtectionWords.deleteCopiesButton, role: .destructive) { Task { await model.delete() } }"))
        #expect(sheet.contains("if let deleteCopies, let choice = list.listing.deleteChoice(for: row) {"))
        let settings = try Self.code("Variorum/Features/Settings/SettingsSceneContent.swift")
        #expect(settings.contains("deleteCopies: { choice in libraryOpen.beginDeleteCopies(roads: roads, choice: choice) })"))
        let pane = try Self.code("Variorum/Features/Settings/DataSafetyPane.swift")
        #expect(pane.contains("deleteCopies: roadDoors.deleteCopies)"))
        let door = try Self.code("Variorum/LibraryOpenDoor.swift")
        #expect(door.contains("func beginDeleteCopies(roads: CopyDoorsRoads, choice: CopyDeleteChoice) {"))
        let bootstrap = try Self.code("Shared/AppBootstrap.swift")
        #expect(bootstrap.contains("await ProtectionCopyDoors.deleteCopies(session, libraryID: libraryID)"))
        #expect(bootstrap.contains("return await self.deleteCopiesWithNoLibraryOpen(libraryID, context: context)"))
    }

    /// VX-210: the one honest line, in both listings, gated on the copies Variorum leaves as they are (P-2).
    @Test func bothListingsSayTheOneLineOnlyWhenItIsTrue() throws {
        let sheet = try Self.code("Variorum/Features/Protection/CopyDoorsSheet.swift")
        #expect(sheet.contains("if listing.unmanagedCopies > 0 {"))
        #expect(sheet.contains("if list.listing.unmanagedCopies > 0 {"))
        #expect(sheet.components(separatedBy: "Text(ProtectionWords.copiesElsewhereLine)").count == 3, "both faces")
    }
}
