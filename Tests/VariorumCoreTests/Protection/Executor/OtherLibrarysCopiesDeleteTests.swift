//
//  OtherLibrarysCopiesDeleteTests.swift
//  VariorumCoreTests — VX-309 U1c piece 1 (VX-265): RULE 19's delete — "Copies of other libraries are listed and can be
//  deleted" — counts THIS MAC'S copies of the other library, and only those. A library's device ID is its own on each Mac
//  (rule 23): Make this my library mints a fresh one, so the library that stepped aside filed its backups under ITS device
//  ID's `<mac8>`, never the open library's. This Mac's copies of another library are therefore told by PLACE — every copy
//  in this Mac's own container (per Mac and per login) — and, in the far folder, by the same `<library8>/<mac8>` subfolder
//  this Mac's container files that library's backups under; another Mac's copies in a shared folder, an unattributed far
//  copy and the open library's own copies are never touched.
//

import Foundation
import Testing

@testable import VariorumCore

@Suite("VX-309 U1c — rule 19's delete: this Mac's copies of another library, and only those")
struct OtherLibrarysCopiesDeleteTests {
    /// A catalogued copy, planted.
    static func copy(
        _ id: String, place: CatalogPlace, folders: [String], name: String = "variorum-backup-2026-10-19-120000.sqlite",
        kind: CopyKind = .backup, library: String?, mac: MacAttribution
    ) -> CatalogCopy {
        CatalogCopy(
            id: id, place: place, folders: folders, name: name, kind: kind, stamp: PF.t0, nameFingerprint8: nil,
            servingKeyFiles: [], fingerprint: nil, candidateFingerprints: [], library: library, mac: mac)
    }

    /// The library that stepped aside (X) filed its backups under ITS OWN device ID's `<mac8>` — beside the library and in
    /// the picked folder — and stepped aside whole into Previous Libraries; another Mac sharing the picked folder filed
    /// X's copies under ITS `<mac8>`; a far copy sits outside any Mac subfolder. The open library's own copies are
    /// retention's. RED ON THE PRE-FIX TREE: the fence compared every copy's `<mac8>` with the OPEN library's — so X's own
    /// backups (beside the library and in the picked folder) were never this Mac's, and only the Previous Library went.
    @Test func anotherLibrarysCopiesThisMacMadeGoWhateverMac8TheyCarry() async throws {
        let fixture = try EX(.standard)
        let other = "cccc3333-0000-4000-8000-000000000003"
        let x8 = ProtectionNames.library8(other)
        let xOnThisMac8 = "dddd4444"  // X's device ID on THIS Mac (rule 23 — never the open library's)
        let anotherMac8 = "eeee5555"
        let open8 = ProtectionNames.library8(fixture.libraryID)
        let ownMac8 = ProtectionNames.mac8(fixture.deviceID)
        let besideTheLibrary = Self.copy(
            "container:Backups/\(x8)/\(xOnThisMac8)/a.sqlite", place: .container,
            folders: ["Backups", x8, xOnThisMac8], library: other, mac: .mac8(xOnThisMac8))
        let inThePickedFolder = Self.copy(
            "farFolder:Backups/\(x8)/\(xOnThisMac8)/a.sqlite", place: .farFolder,
            folders: ["Backups", x8, xOnThisMac8], library: other, mac: .mac8(xOnThisMac8))
        let previousLibrary = Self.copy(
            "container:Previous Libraries/2026-10-19-120000/variorum.sqlite", place: .container,
            folders: ["Previous Libraries", "2026-10-19-120000"], name: "variorum.sqlite", kind: .previousLibrary,
            library: other, mac: .thisMacsContainer)
        let anotherMacs = Self.copy(
            "farFolder:Backups/\(x8)/\(anotherMac8)/a.sqlite", place: .farFolder,
            folders: ["Backups", x8, anotherMac8], library: other, mac: .mac8(anotherMac8))
        let unattributed = Self.copy(
            "farFolder:Backups/safety-copies/variorum-adopt-safety-2026-10-19-120000/variorum.sqlite", place: .farFolder,
            folders: ["Backups", "safety-copies", "variorum-adopt-safety-2026-10-19-120000"], name: "variorum.sqlite",
            kind: .adoptionSafetyCopy, library: other, mac: .unattributed)
        let openLibrarys = Self.copy(
            "container:Backups/\(open8)/\(ownMac8)/a.sqlite", place: .container,
            folders: ["Backups", open8, ownMac8], library: fixture.libraryID, mac: .mac8(ownMac8))
        let all = [besideTheLibrary, inThePickedFolder, previousLibrary, anotherMacs, unattributed, openLibrarys]
        for copy in all { fixture.world.copies[copy.id] = fixture.world.live }
        let executor = fixture.executor()
        var library = try fixture.unlocked(executor)
        _ = try await executor.offerDelete(&library, copies: all, catalog: Catalog(copies: all))
        #expect(fixture.world.copies[besideTheLibrary.id] == nil, "X's backup beside the library is this Mac's (its container)")
        #expect(fixture.world.copies[inThePickedFolder.id] == nil,
                "X's backup in the picked folder, filed under the subfolder this Mac's container files X under")
        #expect(fixture.world.copies[previousLibrary.id] == nil, "the Previous Library — this Mac's container")
        #expect(fixture.world.copies[anotherMacs.id] != nil, "another Mac's copy in the shared folder — never")
        #expect(fixture.world.copies[unattributed.id] != nil, "a far copy outside any Mac subfolder — never claimed")
        #expect(fixture.world.copies[openLibrarys.id] != nil, "the open library's copies are retention's, not rule 19's")
        #expect(library.section.actInFlight == nil, "the act ended")
    }
}
