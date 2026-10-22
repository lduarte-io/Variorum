//
//  RoadLockViewNamesPinTests.swift
//  VariorumTests — VX-306 ladder round 1, NIT 1: THE NEW ROAD'S LOBBY RESTATES NO CATALOGUE FOLDER NAME. Rule 27's
//  *Restore from Backup…* reads the app's own Backups folder (VX-329 U1: no longer reveals it); the catalogue's one name for it is
//  `CatalogNames.backupsFolderName` (the names-never-restated discipline — a restated literal can drift from the
//  catalogue's own reading of the container). A SOURCE pin over `RoadLockView` (code lines only — the comments may name
//  the folder): red while the face spelled `"Backups"` itself, green once it reads the catalogue's name. The value both
//  sides resolve is the same folder, so a behaviour pin would be green on both — this is why the pin reads the source.
//

import Foundation
import Testing

@testable import Variorum
import VariorumCore

@Suite("VX-306 ladder r1 NIT 1 — RoadLockView names the Backups folder by the catalogue's name")
struct RoadLockViewNamesPinTests {
    /// `RoadLockView`'s code lines, from its declaration to the end of the file (it is the file's last type).
    static func roadLockViewCode() throws -> String {
        let source = try String(
            contentsOf: URL(fileURLWithPath: #filePath)
                .deletingLastPathComponent().deletingLastPathComponent().deletingLastPathComponent()
                .appendingPathComponent("Variorum/StoreLockView.swift"),
            encoding: .utf8)
        guard let start = source.range(of: "\nstruct RoadLockView: View {") else { return "" }
        return source[start.lowerBound...]
            .split(separator: "\n", omittingEmptySubsequences: false)
            .filter { !$0.trimmingCharacters(in: .whitespaces).hasPrefix("//") }
            .joined(separator: "\n")
    }

    @Test func theBackupsFolderIsTheCataloguesName() throws {
        let code = try Self.roadLockViewCode()
        #expect(!code.isEmpty, "RoadLockView found")
        #expect(!code.contains("\"\(CatalogNames.backupsFolderName)\""), "RoadLockView restates the Backups folder's name")
        #expect(code.contains("CatalogNames.backupsFolderName"))
        // VX-329 U1: the Finder reveal of the Backups folder (`backupsFolder(besideStore:)`) left with today's road
        // (§6's "the Finder-revealing restore"); the name still rides `copiesHome`, the Restore door's gate — and the
        // folder it looks for is the catalogue's own place for the container's backups.
        let root = FileManager.default.temporaryDirectory.appendingPathComponent("vx306-nit1-\(UUID().uuidString)", isDirectory: true)
        defer { try? FileManager.default.removeItem(at: root) }
        let slot = root.appendingPathComponent(CatalogNames.libraryFilename)
        try FileManager.default.createDirectory(at: root, withIntermediateDirectories: true)
        #expect(!RoadLockView.copiesHome(besideStore: slot), "no copies home yet")
        try FileManager.default.createDirectory(
            at: root.appendingPathComponent(CatalogNames.backupsFolderName, isDirectory: true), withIntermediateDirectories: true)
        #expect(RoadLockView.copiesHome(besideStore: slot), "the catalogue's Backups folder is a copies home")
    }
}
