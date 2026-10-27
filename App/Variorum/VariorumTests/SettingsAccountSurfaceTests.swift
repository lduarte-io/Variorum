//
//  SettingsAccountSurfaceTests.swift
//  VariorumTests
//
//  VX-309 U2 piece 10 — RIDER VX-453, the road half (`SettingsAccountSearchTests` is the search half). The account section
//  renders in `ProtectionPane` (`roadStanding?.account`), and its catalog row is declared exactly where it renders (P-1's
//  declared ⇔ rendered, one layer down). At runtime the results pane asks the index whether the window shows the
//  section, so a window without it never names it. Mac only (it reads `AppSettingsView` and the faces' sources).
//  VX-329 U1 — THE RELEASE SWITCH: one road, so one catalog and one rendered map (today's account-less variants went with
//  today's road); the window's question is the section's presence (`accountSection:`), never the road.
//

import Foundation
import Testing

@testable import Variorum

@MainActor
@Suite("VX-453 — the account section's row joins where the section renders")
struct SettingsAccountSurfaceTests {
    @Test func theCatalogAddsOneRowBesideTheProtectionPanesOwn() throws {
        let rows = SettingsCatalog.rows
        #expect(rows.filter { $0.id == "account" }.count == 1, "the section's row, once")
        #expect(rows.filter { $0.id != "account" } == SettingsCatalog.paneRows, "the account row adds ONE row and changes none")
        let row = try #require(rows.first { $0.id == "account" })
        #expect(row.pane == .protection && row.title == ProtectionWords.accountSectionTitle,
                "the section's own title — one text, the face's and the search's")
        let protection = rows.filter { $0.pane == .protection }.map(\.id)
        #expect(protection == ["protection", "account"], "beside the pane's own row")
        #expect(SettingsSearch.findings(matching: "account", in: SettingsSearch.wholeIndex(accountSection: false)).isEmpty,
                "a window without the section never names it")
        #expect(!SettingsSearch.findings(matching: "account", in: SettingsSearch.wholeIndex(accountSection: true)).isEmpty,
                "a window with it finds it")
    }

    @Test func theRowIsRenderedWhereItIsDeclared() {
        #expect(AppSettingsView.rowIDsRendered[.protection] == ["protection", "account"])
        #expect(AppSettingsView.paneRowIDs[.protection] == ["protection"])
        let declared = Set(SettingsCatalog.rows.map(\.id))
        let rendered = Set(AppSettingsView.rowIDsRendered.values.flatMap { $0 })
        #expect(declared == rendered, "declared ⇔ rendered")
    }

    /// The faces, by source: the results pane asks the index for the window's section, and the section renders its title
    /// from the one constant the row carries.
    @Test func theResultsPaneAsksForTheWindowsSection() throws {
        let features = URL(fileURLWithPath: #filePath).deletingLastPathComponent().deletingLastPathComponent()
            .appendingPathComponent("Variorum/Features")
        let view = try String(contentsOf: features.appendingPathComponent("Settings/AppSettingsView.swift"), encoding: .utf8)
        // VX-590 (A JUSTIFIED EDIT, the ritual — the VX-620 run, batch 2): the index takes a second
        // window question, the MCP pane's sharing face, beside this one; the account question is
        // asked exactly as before (the second question's own pin: `MCPSharingFaceTests`).
        #expect(view.contains("SettingsSearch.wholeIndex(accountSection: accountSection, mcpSharingFace: mcpSharingFace)"))
        #expect(view.contains("accountSection: roadStanding?.account != nil"))
        let section = try String(contentsOf: features.appendingPathComponent("Protection/RoadAccountSheet.swift"),
                                 encoding: .utf8)
        #expect(section.contains("Section(ProtectionWords.accountSectionTitle)"))
    }
}
